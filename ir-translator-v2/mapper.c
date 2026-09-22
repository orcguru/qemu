#include <stdio.h>
#include <limits.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <llvm-c/Core.h>
#include <llvm-c/Target.h>
#include <llvm-c/TargetMachine.h>
#include <llvm-c/Transforms/PassBuilder.h>
#include <llvm-c/BitReader.h>
#include <llvm-c/Linker.h>
#include <llvm-c/Support.h>
#include <stdbool.h>
#include <glib.h>
#include "tcg_ast.h"
#include "tcg_context.h"
#include "parser.tab.h"
#include "lexer.yy.h"
#include "mapper_util.h"
#include "util.h"
#include "operand_static_types.h"
#include "mapper.h"
#include "tcg2llvm.h"

#define LLVMNoInlineAttribute       32
#define LLVMAlwaysInlineAttribute   3
#define QEMUAOT_CC                  124

extern char *lineptr;
int cfg_xmm_count = XMM_COUNT;
void debug_print_instr(TcgContext *ctx, const char *msg) {}

char *g_template_path = NULL;
LLVMTargetMachineRef g_target_machine = NULL;
LLVMModuleRef g_module = NULL;
LLVMContextRef g_context = NULL;
LLVMBuilderRef g_builder = NULL;
LLVMAttributeRef g_attr_target_features = NULL;
LLVMAttributeRef g_attr_noinline = NULL;
LLVMAttributeRef g_attr_alwaysinline = NULL;
LLVMAttributeRef g_attr_nounwind = NULL;

LLVMValueRef get_input_val_for_operand(const Operand *op) {

}

LLVMTypeRef get_llvm_type(LLVMType type) {
    LLVMTypeRef ty = NULL;
    switch (type) {
        case LLVMInt8: ty = LLVMInt8Type(); break;
        case LLVMInt16: ty = LLVMInt16Type(); break;
        case LLVMInt32: ty = LLVMInt32Type(); break;
        case LLVMInt64: ty = LLVMInt64Type(); break;
#if defined(__aarch64__)
        case LLVMVector8xi8: ty = LLVMVectorType(LLVMInt8Type(), 8); break;
        case LLVMVector4xi16: ty = LLVMVectorType(LLVMInt16Type(), 4); break;
        case LLVMVector2xi32: ty = LLVMVectorType(LLVMInt32Type(), 2); break;
        case LLVMVector1xi64: ty = LLVMVectorType(LLVMInt64Type(), 1); break;
        case LLVMVector16xi8: ty = LLVMVectorType(LLVMInt8Type(), 16); break;
        case LLVMVector8xi16: ty = LLVMVectorType(LLVMInt16Type(), 8); break;
        case LLVMVector4xi32: ty = LLVMVectorType(LLVMInt32Type(), 4); break;
        case LLVMVector2xi64: ty = LLVMVectorType(LLVMInt64Type(), 2); break;
#elif (defined(__riscv) && __riscv_xlen == 64)
        case LLVMVector8xi8:
        case LLVMVector16xi8:
            ty = LLVMScalableVectorType(LLVMInt8Type(), 8); break;
        case LLVMVector4xi16:
        case LLVMVector8xi16:
            ty = LLVMScalableVectorType(LLVMInt16Type(), 4); break;
        case LLVMVector2xi32:
        case LLVMVector4xi32:
            ty = LLVMScalableVectorType(LLVMInt32Type(), 2); break;
        case LLVMVector1xi64:
        case LLVMVector2xi64:
            ty = LLVMScalableVectorType(LLVMInt64Type(), 1); break;
#endif
        default: assert(0);
    }
    return ty;
}

/*
 * Notice: LLVMInt128 store not supported
 */
void do_store(const Operand *op, LLVMValueRef val, StackAlloca *stack, OpCodeType opc, int cnt) {
    char var_name[32] = {0};
    if ((op->kind == OP_SLOT && op->slot.type == SUB_SLOT_TMP) || op->kind == OP_VEC) {
        LLVMType val_ty = get_operand_type(op);
        LLVMType stack_ty = op->kind == OP_SLOT ? stack->tmp.ty[op->slot.idx] : stack->vector.ty[op->vec.idx];
        assert(val_ty != LLVMInvalidType && stack_ty != LLVMInvalidType);
        assert((val_ty <= LLVMInt64 && stack_ty <= LLVMInt64 && val_ty <= stack_ty) ||
               (val_ty <= LLVMInt64 && stack_ty > LLVMInt64) ||
               (val_ty > LLVMInt64 && stack_ty > LLVMInt64));
        if (val_ty <= LLVMInt64 && stack_ty <= LLVMInt64 && val_ty < stack_ty) {
            val = LLVMBuildZExt(g_builder, val, get_llvm_type(stack_ty), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "zext", 0));
        } else if ((val_ty <= LLVMInt64 && stack_ty > LLVMInt64) || (val_ty <= LLVMVector1xi64 && stack_ty > LLVMVector1xi64)) {
            // Store overwrite the whole content of vector type with zero background
            assert(op->kind != OP_VEC || (op->vec.offset * 8) % (llvm_vector_elem_bit_counts[val_ty * 2] * llvm_vector_elem_bit_counts[val_ty * 2 + 1]) == 0);
            int elem_cnt = (llvm_vector_elem_bit_counts[stack_ty * 2] * llvm_vector_elem_bit_counts[stack_ty * 2 + 1]) / (llvm_vector_elem_bit_counts[val_ty * 2] * llvm_vector_elem_bit_counts[val_ty * 2 + 1]);
            LLVMValueRef constants[16];
            if (val_ty > LLVMInt64) {
                if (val_ty != LLVMVector1xi64) {
                    val = LLVMBuildBitCast(g_builder, val, get_llvm_type(LLVMVector1xi64), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc", 0));
                }
                LLVMValueRef index = LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0);
                val = LLVMBuildExtractElement(g_builder, val, index, assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "val", 0));
                val_ty = LLVMInt64;
            }
            LLVMValueRef element_value = LLVMConstInt(get_llvm_type(val_ty), 0, 0);
            for (int i = 0; i < elem_cnt; i++) {
                constants[i] = element_value;
            }
            LLVMValueRef vec_zero = LLVMConstVector(constants, elem_cnt);
            LLVMValueRef index = LLVMConstInt(get_llvm_type(LLVMInt64), op->kind == OP_SLOT ? 0 : ((op->vec.offset * 8) / llvm_vector_elem_bit_counts[val_ty * 2 + 1]), 0);
            val = LLVMBuildInsertElement(g_builder, vec_zero, val, index, assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "vec", 0));
            if (((stack_ty - val_ty) % 4) != 0) {
                val = LLVMBuildBitCast(g_builder, val, get_llvm_type(stack_ty), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc", 0));
            }
        } else if (val_ty > LLVMInt64 && stack_ty > LLVMInt64 && val_ty != stack_ty) {
            assert((llvm_vector_elem_bit_counts[val_ty * 2] * llvm_vector_elem_bit_counts[val_ty * 2 + 1]) ==
                (llvm_vector_elem_bit_counts[stack_ty * 2] * llvm_vector_elem_bit_counts[stack_ty * 2 + 1]));
            val = LLVMBuildBitCast(g_builder, val, get_llvm_type(stack_ty), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc", 0));
        } else {
            assert(0);
        }
        build_store_with_alignment(g_builder, val, op->kind == OP_SLOT ? stack->tmp.alloca[op->slot.idx] : stack->vector.alloca[op->vec.idx], stack_ty <= LLVMInt64 ? 8 : 16);
        return;
    }
    if (op->kind == OP_SLOT && op->slot.type == SUB_SLOT_XREG) {
        build_store_with_alignment(g_builder, val, stack->xreg.alloca[op->slot.idx], 8);
        return;
    }
    if ((op->kind == OP_SLOT && op->slot.type == SUB_SLOT_ENVVAR) || op->kind == OP_ENV) {
        LLVMValueRef offset = LLVMConstInt(get_llvm_type(LLVMInt64), op->kind == OP_SLOT ? envvar_offsets[op->slot.idx] : op->env.offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(g_builder, stack->env, offset, assemble_name_3(&var_name[0], sizeof(var_name), "addr", op->kind == OP_SLOT ? envvar_type_str[op->slot.idx] : "envoff", opcode_type_str[opc], cnt));
        build_store_with_alignment(g_builder, val, addr, op->kind == OP_SLOT ? 8 : GET_ALIGNMENT_FROM_CONSTANT(op->env.offset));
        return;
    }
    assert(0);
}

static LLVMValueRef get_or_add_func_with_qemuaot_cc(const char *name, FuncInstrList *f, int with_ret) {
    // Trampoline may have already been defined
    LLVMValueRef F = LLVMGetNamedFunction(g_module, name);
    if (!F) {
        LLVMTypeRef arg_types[XREG_MAX + 2 * XMM_COUNT_MAX + MAX_ADDED_ARGS] = {NULL};
        int arg_cnt = 0;
        for (int i = 0; i < (XREG_MAX + 2 * XMM_COUNT_MAX); ++i) {
            arg_types[arg_cnt++] = get_llvm_type(qemuaot_default_param_type[i]);
        }
        for (int i = 0; i < f->added_param_count; ++i) {
            arg_types[arg_cnt++] = get_llvm_type(f->added_param_type[i]);
        }
        LLVMTypeRef f_type = LLVMFunctionType(LLVMVoidType(), arg_types, arg_cnt, 0);
        F = LLVMAddFunction(g_module, name, f_type);
        LLVMAddAttributeAtIndex(F, -1, g_attr_target_features);
        LLVMAddAttributeAtIndex(F, -1, g_attr_nounwind);
        LLVMSetFunctionCallConv(F, QEMUAOT_CC);
        char sec_name[128] = {0};
        sprintf(sec_name, ".text.%s", name);
        LLVMSetSection(F, sec_name);
        for (int i = 0; i < (XREG_MAX + 2 * XMM_COUNT_MAX); ++i) {
            LLVMSetValueName(LLVMGetParam(F, i), qemuaot_default_param_name[i]);
        }
        for (int i = 0, arg_idx = (XREG_MAX + 2 * XMM_COUNT_MAX); i < f->added_param_count; ++i, ++arg_idx) {
            LLVMSetValueName(LLVMGetParam(F, arg_idx), f->added_param_name[i]);
        }
    }
    return F;
}

LLVMValueRef build_store_with_alignment(LLVMBuilderRef B, LLVMValueRef Val, LLVMValueRef PointerVal, unsigned Bytes) {
    LLVMValueRef ST = LLVMBuildStore(B, Val, PointerVal);
    LLVMSetAlignment(ST, Bytes);
    return ST;
}

LLVMValueRef build_load_with_alignment(LLVMBuilderRef B, LLVMTypeRef Ty, LLVMValueRef PointerVal, const char *Name, unsigned Bytes) {
    LLVMValueRef LD = LLVMBuildLoad2(B, Ty, PointerVal, Name);
    LLVMSetAlignment(LD, Bytes);
    return LD;
}

LLVMValueRef get_env() {
    LLVMTypeRef empty[] = {};
    LLVMTypeRef asm_function_type = LLVMFunctionType(get_llvm_type(LLVMInt64), empty, 0, 0);
    char asm_string[128];
#if defined(__aarch64__)
    sprintf(asm_string, "mov $0, x25");
#elif (defined(__riscv) && __riscv_xlen == 64)
    sprintf(asm_string, "mv $0, x25");
#endif
    const char *constraint_string = "=r";
    LLVMValueRef inline_asm = LLVMConstInlineAsm(asm_function_type, asm_string, constraint_string, /* has_side_effects */ 1, /* is_align_stack */ 0);
    return LLVMBuildCall2(g_builder, asm_function_type, inline_asm, NULL, 0, "env");
}

static StackAlloca *setup_stack(TcgContext *ctx, LLVMValueRef F) {
    StackAlloca *stack = (StackAlloca *)calloc(1, sizeof(StackAlloca));
    stack->xreg.ty = (LLVMType *)calloc(XREG_MAX, sizeof(LLVMType));
    stack->xreg.alloca = (LLVMValueRef *)calloc(XREG_MAX, sizeof(LLVMValueRef));
    stack->xreg.copy_valid = (uint64_t *)calloc(1, sizeof(uint64_t));
    stack->xreg.copy_idx = (int *)calloc(XREG_MAX, sizeof(int));
    for (int i = 0; i < XREG_MAX; ++i) {
        if (ctx->xreg_valid & (1 << i)) {
            stack->xreg.alloca[i] = LLVMBuildAlloca(g_builder, get_llvm_type(qemuaot_default_param_type[i]), qemuaot_default_stack_alloca_name[i]);
            LLVMSetAlignment(stack->xreg.alloca[i], 8);
            stack->xreg.ty[i] = qemuaot_default_param_type[i];
            build_store_with_alignment(g_builder, LLVMGetParam(F, i), stack->xreg.alloca[i], 8);
        }
    }
    stack->vector.ty = (LLVMType *)calloc(XREG_MAX, sizeof(LLVMType));
    stack->vector.alloca = (LLVMValueRef *)calloc((2 * XMM_COUNT_MAX), sizeof(LLVMValueRef));
    stack->vector.copy_valid = (uint64_t *)calloc(1, sizeof(uint64_t));
    stack->vector.copy_idx = (int *)calloc((2 * XMM_COUNT_MAX), sizeof(int));
    for (int i = 0; i < (2 * XMM_COUNT_MAX); ++i) {
        if ((ctx->vec_valid & (1 << i)) || (ctx->vec_spare_valid & (1 << i))) {
            stack->vector.alloca[i] = LLVMBuildAlloca(g_builder, get_llvm_type(qemuaot_default_param_type[XREG_MAX + i]), qemuaot_default_stack_alloca_name[XREG_MAX + i]);
            LLVMSetAlignment(stack->vector.alloca[i], 16);
            stack->vector.ty[i] = qemuaot_default_param_type[XREG_MAX + i];
            build_store_with_alignment(g_builder, LLVMGetParam(F, (XREG_MAX + i)), stack->vector.alloca[i], 16);
        }
    }
    stack->tmp.ty = (LLVMType *)calloc(XREG_MAX, sizeof(LLVMType));
    stack->tmp.alloca = (LLVMValueRef *)calloc(ctx->next_tmp_idx, sizeof(LLVMValueRef));
    stack->tmp.copy_valid = (uint64_t *)calloc((ctx->next_tmp_idx + 63) / 64, sizeof(uint64_t));
    stack->tmp.copy_idx = (int *)calloc(ctx->next_tmp_idx, sizeof(int));
    for (int i = 0; i < ctx->next_tmp_idx; ++i) {
        LLVMType stack_ty = (LLVMType)(long)g_hash_table_lookup(ctx->stack_type_map, (gpointer)(long)i);
        assert(stack_ty != LLVMInvalidType);
        char tmp_alloca_name[16] = {0};
        sprintf(&tmp_alloca_name[0], "tmp%d.stack", (i & 0xffff));
        stack->tmp.alloca[i] = LLVMBuildAlloca(g_builder, get_llvm_type(stack_ty), tmp_alloca_name);
        LLVMSetAlignment(stack->tmp.alloca[i], stack_ty <= LLVMInt64 ? 8 : 16);
        stack->tmp.ty[i] = stack_ty;
    }
    if (ctx->carry_on) {
        stack->carry = LLVMBuildAlloca(g_builder, LLVMInt1Type(), "carry.stack");
    }
    if (ctx->borrow_on) {
        stack->borrow = LLVMBuildAlloca(g_builder, LLVMInt1Type(), "borrow.stack");
    }
    if (ctx->env_on) {
        stack->env = get_env();
    }
    return stack;
}

static void release_stack(StackAlloca *stack) {
    free(stack->xreg.ty);
    free(stack->xreg.alloca);
    free(stack->xreg.copy_valid);
    free(stack->xreg.copy_idx);
    free(stack->vector.ty);
    free(stack->vector.alloca);
    free(stack->vector.copy_valid);
    free(stack->vector.copy_idx);
    free(stack->tmp.ty);
    free(stack->tmp.alloca);
    free(stack->tmp.copy_valid);
    free(stack->tmp.copy_idx);
    free(stack);
}

void translate_to_llvm_func(TcgContext *ctx, const char *name, FuncInstrList *f, int is_external) {
    LLVMValueRef F = NULL;
    F = get_or_add_func_with_qemuaot_cc(name, f, 0);
    if (is_external == 0) {
        LLVMSetLinkage(F, LLVMInternalLinkage);
        LLVMAddAttributeAtIndex(F, -1, g_attr_alwaysinline);
    } else {
        LLVMSetLinkage(F, LLVMExternalLinkage);
        LLVMAddAttributeAtIndex(F, -1, g_attr_noinline);
    }
    // Create the entry block, then define/initialize stack alloca
    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(F, "entry");
    LLVMPositionBuilderAtEnd(g_builder, entry);
    StackAlloca *stack = setup_stack(ctx, F);
    // One-to-one mapping from TCG-ops to LLVM-IR
    translate_batch(g_builder, F, stack, f);
    for (const UnifiedInstr *u = f->head; u; u = u->next) {
    }
    release_stack(stack);
}

void handle_func(TcgContext *ctx, int is_external) {
    for (int i = 0; i < ctx->llvm_func_set.num_lists; ++i) {
        char *func_name = NULL;
        char fhex_name[32] = {0};
        if (ctx->llvm_func_set.lists[i].trampoline_name[0]) {
            func_name = &ctx->llvm_func_set.lists[i].trampoline_name[0];
        } else {
            if (i == 0) {
                sprintf(fhex_name, "Fx%lx", ctx->hex_offset);
            } else {
                sprintf(fhex_name, "Fx%lx_%d", ctx->hex_offset, i);
            }
            func_name = &fhex_name[0];
        }
        translate_to_llvm_func(ctx, func_name, &(ctx->llvm_func_set.lists[i]), is_external);
    }
}

void print_usage(const char *progname) {
    fprintf(stderr, "Usage: %s <input.tir>\n", progname);
}

void parse_tcg_instructions(const char *filename) {
    FILE *source_file = fopen(filename, "r");
    if (!source_file) {
        perror("Error opening source file");
        return;
    }
    TcgContext ctx;
    tcg_context_init(&ctx);
    yyscan_t scanner;
    yylex_init(&scanner);
    yyset_in(source_file, scanner);
    yyparse(scanner, &ctx);
    yylex_destroy(scanner);
    free(lineptr);
    fclose(source_file);
    tcg_context_destroy(&ctx);
    return;
}

int init_llvm() {
    char *error_msg = NULL;
    LLVMTargetRef target;
    // Enable AArch64AOTStackSwitchPass/RISCVAOTStackSwitchPass
    int rc = setenv("LLVM_ENABLE_AOT_STACK_SWITCH", "1", 1);
    assert(rc == 0);
#if defined(__aarch64__)
    const char *default_triple = "aarch64-unknown-linux-gnu";
    const char* features = "+neon";
    LLVMInitializeAArch64TargetInfo();
    LLVMInitializeAArch64Target();
    LLVMInitializeAArch64TargetMC();
    LLVMInitializeAArch64AsmPrinter();
    LLVMInitializeAArch64AsmParser();
#elif (defined(__riscv) && __riscv_xlen == 64)
    const char *default_triple = "riscv64-unknown-linux-gnu";
    //const char* features = "+m,+a,+f,+d,+v,+unaligned-scalar-mem,+unaligned-vector-mem";
    const char* features = "+m,+a,+f,+d,+v";
    LLVMInitializeRISCVTargetInfo();
    LLVMInitializeRISCVTarget();
    LLVMInitializeRISCVTargetMC();
    LLVMInitializeRISCVAsmPrinter();
    LLVMInitializeRISCVAsmParser();
#endif
    if (LLVMGetTargetFromTriple(default_triple, &target, &error_msg)) {
        fprintf(stderr, "Failed to get target from triple %s\n", error_msg);
        return -1;
    }
    g_target_machine = LLVMCreateTargetMachine(target, default_triple, "generic", features,
                                             LLVMCodeGenLevelDefault, LLVMRelocPIC, LLVMCodeModelDefault);

    g_context = LLVMGetGlobalContext();
    g_attr_noinline = LLVMCreateEnumAttribute(g_context, LLVMNoInlineAttribute, 0);
    g_attr_alwaysinline = LLVMCreateEnumAttribute(g_context, LLVMAlwaysInlineAttribute, 0);
    g_attr_nounwind = LLVMCreateEnumAttribute(g_context, LLVMGetEnumAttributeKindForName("nounwind", strlen("nounwind")), 0);
    const char *attr_key = "target-features";
#if defined(__aarch64__)
    const char *attr_value = "+neon";
#elif (defined(__riscv) && __riscv_xlen == 64)
    // Unfortunately on Spacemit(R) X60, following instruction requires alignment: vse64.v v30,(a4)
    //const char *attr_value = "+m,+a,+f,+d,+v,+unaligned-scalar-mem,+unaligned-vector-mem";
    const char *attr_value = "+m,+a,+f,+d,+v";
#endif
    size_t attr_key_len = strlen(attr_key);
    size_t attr_value_len = strlen(attr_value);
    g_attr_target_features = LLVMCreateStringAttribute(g_context, attr_key, attr_key_len, attr_value, attr_value_len);
    g_module = LLVMModuleCreateWithNameInContext("qemuaot", g_context);

#if defined(__aarch64__)
    LLVMSetTarget(g_module, "aarch64-unknown-linux-gnu");
#elif (defined(__riscv) && __riscv_xlen == 64)
    LLVMSetTarget(g_module, "riscv64-unknown-linux-gnu");
#endif

    g_builder = LLVMCreateBuilder();
    return 0;
}

static int check_always_inline_status(LLVMValueRef F) {
    LLVMAttributeRef attr = LLVMGetEnumAttributeAtIndex(F, -1, LLVMAlwaysInlineAttribute);
    if (!attr) {
        return 0;
    }
    LLVMUseRef use = LLVMGetFirstUse(F);
    if (!use) {
        printf("Function '%s' with always_inline has no use - likely inlined\n", LLVMGetValueName(F));
        return 1;
    }
    return 0;
}

int fini_llvm(const char *output_file) {
    // FIXME: turn DUMP_IR into argument
#ifdef DUMP_IR
    LLVMDumpModule(g_module);
#endif
    LLVMValueRef F = LLVMGetFirstFunction(g_module);
    while (F != NULL) {
        if (LLVMIsAFunction(F) && LLVMIsDeclaration(F) && strncmp(LLVMGetValueName(F), "Fx", 2) == 0) {
            LLVMSetSection(F, ".text.declare_only");
            LLVMSetLinkage(F, LLVMWeakAnyLinkage);
            LLVMAddAttributeAtIndex(F, -1, g_attr_noinline);
            LLVMAddAttributeAtIndex(F, -1, g_attr_target_features);
            LLVMBasicBlockRef bb_entry = LLVMAppendBasicBlock(F, "entry");
            LLVMPositionBuilderAtEnd(g_builder, bb_entry);
            LLVMBasicBlockRef bb_loop = LLVMAppendBasicBlock(F, "loop");
            LLVMBuildBr(g_builder, bb_loop);
            LLVMPositionBuilderAtEnd(g_builder, bb_loop);
            LLVMBuildBr(g_builder, bb_loop);
            LLVMBasicBlockRef bb_exit = LLVMAppendBasicBlock(F, "exit");
            LLVMPositionBuilderAtEnd(g_builder, bb_exit);
            LLVMBuildRetVoid(g_builder);
        }
        F = LLVMGetNextFunction(F);
    }

    LLVMPassBuilderOptionsRef options = LLVMCreatePassBuilderOptions();
    LLVMErrorRef error = LLVMRunPasses(g_module, "default<O2>", g_target_machine, options);
    if (error) {
        char* error_msg = LLVMGetErrorMessage(error);
        fprintf(stderr, "Optimization failed: %s\n", error_msg);
        LLVMDisposeErrorMessage(error_msg);
        LLVMDisposePassBuilderOptions(options);
        LLVMDisposeTargetMachine(g_target_machine);
        return -1;
    }

    // Remove standalone always_inline functions(helpers)
    F = LLVMGetFirstFunction(g_module);
    while (F != NULL) {
        LLVMValueRef DC = NULL;
        if (check_always_inline_status(F)) {
            DC = F;
        }
        F = LLVMGetNextFunction(F);
        if (DC) {
            LLVMDeleteFunction(DC);
        }
    }

    char *error_msg = NULL;
    if (LLVMTargetMachineEmitToFile(g_target_machine, g_module, output_file, LLVMObjectFile, &error_msg)) {
        fprintf(stderr, "Failed to emit object file: %s", error_msg);
        return -1;
    }
    LLVMDisposeBuilder(g_builder);
    LLVMDisposeModule(g_module);
    LLVMContextDispose(g_context);
    LLVMDisposeTargetMachine(g_target_machine);
    return 0;
}

int main(int argc, const char *argv[]) {
    int rc = 0;
    char *output_file = NULL;
    if (argc < 1) {
        print_usage(argv[0]);
        rc = -1;
        goto exit;
    }
    const char *input_file = argv[1];
    if (!input_file) {
        fprintf(stderr, "Error: no input file specified\n");
        print_usage(argv[0]);
        rc = -1;
        goto exit;
    }
    output_file = (char *)calloc(1, strlen(input_file) + 1 + 2);
    assert(output_file);
    sprintf(output_file, "%s.o", input_file);

    // Get the path for helper_templates
    g_template_path = realpath(argv[0], NULL);
    assert(g_template_path);
    char *p = g_template_path;
    assert(p);
    while (strstr(p, "/") != NULL) {
        p = strstr(p, "/");
        if (*p == '/') {
            p += 1;
        }
    }
    assert((p - g_template_path) < PATH_MAX);
    *p = '\0';

    // Initialize LLVM target machine
    rc = init_llvm();
    if (rc != 0) {
        goto exit;
    }

    // Parse/Expand/Map TCG-ops into LLVM-IR
    parse_tcg_instructions(input_file);

    // Invoke LLVM pipeline to produce object file
    rc = fini_llvm(output_file);
    if (rc != 0) {
        goto exit;
    }

exit:
    if (g_template_path) {
        free(g_template_path);
    }
    if (output_file) {
        free(output_file);
    }
    return rc;
}
