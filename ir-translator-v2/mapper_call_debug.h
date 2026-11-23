/* mapper_call_debug.h — include after llvm-c/Core.h, and after the declaration
 * of mapper_use_scalable_vector() (or replace that line with your own flag).  */
#include <llvm-c/Core.h>
#include <stdio.h>
#include <stdlib.h>

static const char *mapper_kind_name(LLVMTypeKind K) {
    switch (K) {
    case LLVMVoidTypeKind:           return "void";
    case LLVMIntegerTypeKind:        return "integer";
    case LLVMPointerTypeKind:        return "pointer";
    case LLVMFunctionTypeKind:       return "function";
    case LLVMStructTypeKind:         return "struct";
    case LLVMArrayTypeKind:          return "array";
    case LLVMVectorTypeKind:         return "FIXED-vector";       /* <N x T>   */
    case LLVMScalableVectorTypeKind: return "SCALABLE-vector";    /* <vscale..>*/
    case LLVMTargetExtTypeKind:      return "target-ext";         /* LLVM >= 15 */
    default:                         return "other";
    }
}

static void mapper_print_type(const char *Tag, LLVMTypeRef T) {
    if (!T) { fprintf(stderr, "  %-16s : <NULL>\n", Tag); return; }
    char *S = LLVMPrintTypeToString(T);              /* must LLVMDisposeMessage */
    LLVMTypeKind K = LLVMGetTypeKind(T);
    fprintf(stderr, "  %-16s : %-38s kind=%s(%d)",
            Tag, S, mapper_kind_name(K), (int)K);
    if (K == LLVMVectorTypeKind || K == LLVMScalableVectorTypeKind)
        fprintf(stderr, "  lanes(min)=%u", LLVMGetVectorSize(T));
    fputc('\n', stderr);
    LLVMDisposeMessage(S);
}

static void mapper_print_value(const char *Tag, LLVMValueRef V) {
    if (!V) { fprintf(stderr, "  %-16s : <NULL>\n", Tag); return; }
    size_t L = 0;
    const char *N = LLVMGetValueName2(V, &L);        /* borrowed, do NOT free */
    char *S = LLVMPrintValueToString(V);             /* must LLVMDisposeMessage */
    fprintf(stderr, "  %-16s : name=%.*s  valuekind=%d  %s\n",
            Tag, (int)L, N, (int)LLVMGetValueKind(V), S);
    LLVMDisposeMessage(S);
}

/* Returns non-zero on any problem. Call this BEFORE LLVMBuildCall2. */
static int
mapper_check_call_signature(LLVMTypeRef FnTy, LLVMValueRef Fn,
                            LLVMValueRef *Args, unsigned NumArgs,
                            const char *Site)
{
    int Bad = 0;

    if (!Fn) {
        fprintf(stderr, "[%s] callee is NULL (LLVMGetNamedFunction miss?)\n", Site);
        return 1;
    }
    if (!FnTy || LLVMGetTypeKind(FnTy) != LLVMFunctionTypeKind) {
        fprintf(stderr, "[%s] 2nd arg is not a FunctionType "
                        "(it is the whole signature, NOT the return type)\n", Site);
        mapper_print_type("FnTy", FnTy);
        return 1;
    }

    /* LLVMGetParamTypes fills a CALLER-preallocated array of CountParamTypes()
       entries -- it does no bounds checking and returns void. */
    unsigned NP = LLVMCountParamTypes(FnTy);
    LLVMTypeRef *P = (LLVMTypeRef *)calloc(NP ? NP : 1, sizeof *P);
    LLVMGetParamTypes(FnTy, P);

    /* (1) Opaque-pointer trap: LLVMTypeOf(Fn) is 'ptr' on LLVM 15+.
           The declaration's signature is LLVMGlobalGetValueType(Fn). */
    if (LLVMIsAFunction(Fn)) {
        LLVMTypeRef DeclTy = LLVMGlobalGetValueType(Fn);
        if (DeclTy != FnTy) {
            Bad = 1;
            fprintf(stderr, "\n=== [%s] call-site FnTy != callee's declared type ===\n", Site);
            mapper_print_value("callee", Fn);
            mapper_print_type("call-site FnTy", FnTy);
            mapper_print_type("declared FnTy", DeclTy);
            fprintf(stderr, "  HINT: use LLVMBuildCall2(B, LLVMGlobalGetValueType(F), F, ...)\n");
        }
    }

    /* (2) Arity */
    if (NumArgs < NP) {
        Bad = 1;
        fprintf(stderr, "\n=== [%s] too FEW args: %u supplied, %u declared ===\n",
                Site, NumArgs, NP);
    }
    if (NumArgs > NP && !LLVMIsFunctionVarArg(FnTy)) {
        Bad = 1;
        fprintf(stderr, "\n=== [%s] too MANY args: %u supplied, %u declared, not vararg ===\n",
                Site, NumArgs, NP);
    }

    /* (3) Reproduce CallInst::init's exact assertion, but report instead of abort */
    for (unsigned i = 0; i < NumArgs; ++i) {
        if (!Args[i]) {
            Bad = 1;
            fprintf(stderr, "\n=== [%s] arg[%u] is NULL ===\n", Site, i);
            continue;                       /* LLVMTypeOf(NULL) would crash */
        }
        LLVMTypeRef A = LLVMTypeOf(Args[i]);
        if (i >= NP) continue;              /* vararg slot: LLVM does not check it */

        if (P[i] == A) continue;            /* <-- the exact C++ comparison */

        Bad = 1;
        fprintf(stderr, "\n=== [%s] BAD SIGNATURE at arg %u / %u ===\n",
                Site, i, NumArgs);
        mapper_print_value("callee", Fn);
        mapper_print_type("expected", P[i]);
        mapper_print_type("actual  ", A);
        mapper_print_value("arg value", Args[i]);

        char *F = LLVMPrintTypeToString(FnTy);
        fprintf(stderr, "  full FnTy       : %s\n", F);
        LLVMDisposeMessage(F);

        LLVMTypeKind KE = LLVMGetTypeKind(P[i]);
        LLVMTypeKind KA = LLVMGetTypeKind(A);
        if ((KE == LLVMVectorTypeKind        && KA == LLVMScalableVectorTypeKind) ||
            (KE == LLVMScalableVectorTypeKind && KA == LLVMVectorTypeKind)) {
            fprintf(stderr,
                "  >>> HINT: fixed <N x T> vs scalable <vscale x N x T>.\n"
                "      mapper_use_scalable_vector() = %d. The signature and the\n"
                "      argument came from DIFFERENT get_llvm_type() paths.\n",
                mapper_use_scalable_vector());
        }
        int EV = (KE == LLVMVectorTypeKind || KE == LLVMScalableVectorTypeKind);
        int AV = (KA == LLVMVectorTypeKind || KA == LLVMScalableVectorTypeKind);
        if (EV && AV)
            fprintf(stderr,
                "  >>> HINT: LLVMGetVectorSize() expected=%u actual=%u -- identical\n"
                "      numbers do NOT mean identical types (vscale x 2 == 2 x T).\n",
                LLVMGetVectorSize(P[i]), LLVMGetVectorSize(A));
    }

    free(P);
    return Bad;
}

static LLVMValueRef
mapper_build_call2_checked(LLVMBuilderRef B, LLVMTypeRef FnTy,
                           LLVMValueRef Fn, LLVMValueRef *Args,
                           unsigned NumArgs, const char *Name)
{
    if (mapper_check_call_signature(FnTy, Fn, Args, NumArgs,
                                    Name ? Name : "LLVMBuildCall2"))
        abort();     /* fail HERE, with a readable dump, not inside Instructions.cpp */
    return LLVMBuildCall2(B, FnTy, Fn, Args, NumArgs, Name);
}

#define BUILD_CALL2(B,Ty,Fn,Args,N,Name) \
    mapper_build_call2_checked(B, Ty, Fn, Args, N, Name)
