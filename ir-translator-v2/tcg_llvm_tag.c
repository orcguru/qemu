/*
 * tcg_llvm_tag.c -- implementation.  See tcg_llvm_tag.h.
 *
 * Build:  cc -c tcg_llvm_tag.c $(llvm-config --cflags)
 */

#include "tcg_llvm_tag.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

/* ------------------------------------------------------------------ */
/* LLVM version handling                                               */
/* ------------------------------------------------------------------ */
/*
 * Pinned for LLVM 21 (verified against llvm-c/Core.h + llvm-c/DebugInfo.h).
 *
 * LLVM_VERSION_MAJOR is NOT defined by llvm-c headers themselves; you get it
 * from llvm/Config/llvm-config.h or your build system.  Rather than fail when
 * it is missing, we default to the MODERN path -- which is correct for LLVM
 * >= 15, i.e. everything anyone realistically builds today.
 *
 * To compile against LLVM < 15, pass -DTCG_LLVM_LEGACY=1.
 */
#if defined(__has_include)
#  if __has_include(<llvm-c/Version.h>)
#    include <llvm-c/Version.h>
#  endif
#endif

#if defined(TCG_LLVM_LEGACY)
#  define TCG_MODERN 0
#elif defined(LLVM_VERSION_MAJOR) && LLVM_VERSION_MAJOR != 0 && LLVM_VERSION_MAJOR < 15
#  define TCG_MODERN 0
#else
#  define TCG_MODERN 1
#endif

/* LLVMGetValueName2/LLVMSetValueName2 exist since LLVM 7.  The old 1-arg
 * forms are LLVM_ATTRIBUTE_C_DEPRECATED in LLVM 21 and will trip -Werror. */
#if defined(TCG_NO_VALUE_NAME2)
#  define TCG_HAS_VALUE_NAME2 0
#else
#  define TCG_HAS_VALUE_NAME2 1
#endif

/* ------------------------------------------------------------------ */
/* small helpers                                                       */
/* ------------------------------------------------------------------ */

static void *tcg_xrealloc(void *p, size_t n)
{
    void *q = realloc(p, n);
    if (!q) {
        fprintf(stderr, "tcg_tag: out of memory\n");
        abort();
    }
    return q;
}

static char *tcg_xstrdup(const char *s)
{
    size_t n = strlen(s) + 1;
    char *p = (char *)tcg_xrealloc(NULL, n);
    memcpy(p, s, n);
    return p;
}

/* ------------------------------------------------------------------ */
/* metadata construction                                               */
/* ------------------------------------------------------------------ */

#if TCG_MODERN
static LLVMValueRef tcg_make_mdval(LLVMContextRef ctx, const char *text)
{
    LLVMMetadataRef str  = LLVMMDStringInContext2(ctx, text, strlen(text));
    LLVMMetadataRef node = LLVMMDNodeInContext2(ctx, &str, 1);
    return LLVMMetadataAsValue(ctx, node);
}
#else
static LLVMValueRef tcg_make_mdval(LLVMContextRef ctx, const char *text)
{
    LLVMValueRef str  = LLVMMDStringInContext(ctx, text, (unsigned)strlen(text));
    LLVMValueRef ops[1];
    ops[0] = str;
    return LLVMMDNodeInContext(ctx, ops, 1);
}
#endif

/* LLVM 21 deprecates LLVMSetCurrentDebugLocation() outright -- "Passing the
 * NULL location will crash".  The 2-suffixed form takes an LLVMMetadataRef
 * and handles NULL, so it is the only one we call. */
static void tcg_set_cur_loc(LLVMBuilderRef b, LLVMContextRef ctx, LLVMMetadataRef loc)
{
#if TCG_MODERN
    (void)ctx;
    LLVMSetCurrentDebugLocation2(b, loc);
#else
    LLVMSetCurrentDebugLocation(b, LLVMMetadataAsValue(ctx, loc));
#endif
}

/* ------------------------------------------------------------------ */
/* lifecycle                                                           */
/* ------------------------------------------------------------------ */

void tcg_tag_init(TcgTag *t, LLVMContextRef ctx, LLVMBuilderRef b)
{
    memset(t, 0, sizeof *t);
    t->ctx = ctx;
    t->b   = b;

    /* Unknown metadata kinds are legal; the verifier accepts them. */
    t->md_kind      = LLVMGetMDKindIDInContext(ctx, "tcg.op", 6);
    t->md_line_kind = LLVMGetMDKindIDInContext(ctx, "tcg.line", 8);

    t->use_dbg = 0;
    t->active  = 0;
}

void tcg_tag_use_dbg(TcgTag *t, LLVMMetadataRef difile, LLVMMetadataRef sp)
{
    if (!difile || !sp) {
        t->use_dbg = 0;
        t->difile  = NULL;
        t->sp      = NULL;
        return;
    }
    t->use_dbg = 1;
    t->difile  = difile;
    t->sp      = sp;

    /* Baseline location so that no instruction is ever emitted with a NULL
     * !dbg inside a function that carries a DISubprogram. */
    t->cur_loc = LLVMDIBuilderCreateDebugLocation(t->ctx, 0, 0, sp, NULL);
    if (t->b) tcg_set_cur_loc(t->b, t->ctx, t->cur_loc);
}

/* LLVM 21: LLVMCreateDIBuilder() (LLVMNewDIBuilder is long gone). */
#if TCG_MODERN
#  define TCG_CREATE_DIBUILDER(m) LLVMCreateDIBuilder(m)
#else
#  define TCG_CREATE_DIBUILDER(m) LLVMNewDIBuilder(m)
#endif

/* LLVM 21: 19 parameters -- SysRoot/SysRootLen/SDK/SDKLen were appended in
 * LLVM 11.  LLVMDIBuilderCreateSubroutineType() likewise takes a trailing
 * LLVMDIFlags since LLVM 8.
 *
 * WATCH OUT: the emission-kind constants are LLVMDWARFEmissionNone /
 * LLVMDWARFEmissionFull / LLVMDWARFEmissionLineTablesOnly.  The *type* is
 * LLVMDWARFEmissionKind -- there is no "LLVMDWARFEmissionKindFull". */
#if TCG_MODERN
#  define TCG_CREATE_CU(dib, lang, file, prod, prodlen, opt, flags, flagslen,    \
                        rtver, split, splitlen, kind, dwoid, splitinl, dbgprof)  \
      LLVMDIBuilderCreateCompileUnit(dib, lang, file, prod, prodlen, opt,        \
                                     flags, flagslen, rtver, split, splitlen,    \
                                     kind, dwoid, splitinl, dbgprof,             \
                                     "", 0, "", 0)
#else
#  define TCG_CREATE_CU(dib, lang, file, prod, prodlen, opt, flags, flagslen,    \
                        rtver, split, splitlen, kind, dwoid, splitinl, dbgprof)  \
      LLVMDIBuilderCreateCompileUnit(dib, lang, file, prod, prodlen, opt,        \
                                     flags, flagslen, rtver, split, splitlen,    \
                                     kind, dwoid, splitinl, dbgprof)
#endif

/* LLVM 21 has LLVMValueAsMetadata() in llvm-c/Core.h, so LLVMAddModuleFlag()
 * is the natural way to set "Debug Info Version".  For old releases that lack
 * it we fall back to the raw named-metadata form llvm-c-test uses:
 *     !llvm.module.flags = !{!{i32 2, !"Debug Info Version", i32 3}}
 * (i32 2 == LLVMModuleFlagBehaviorWarning).  -DTCG_NO_VALUE_AS_MD=1 forces it. */
#ifndef TCG_NO_VALUE_AS_MD
#  define TCG_HAS_VALUE_AS_MD TCG_MODERN
#else
#  define TCG_HAS_VALUE_AS_MD 0
#endif

static void tcg_set_debug_info_version_flag(LLVMModuleRef M, LLVMContextRef ctx,
                                            unsigned version)
{
    LLVMTypeRef  i32 = LLVMInt32TypeInContext(ctx);
    LLVMValueRef ver = LLVMConstInt(i32, version, 0);

#if TCG_HAS_VALUE_AS_MD
    LLVMAddModuleFlag(M, LLVMModuleFlagBehaviorWarning,
                      "Debug Info Version", 17, LLVMValueAsMetadata(ver));
#else
    {
        LLVMValueRef ops[3];
        ops[0] = LLVMConstInt(i32, LLVMModuleFlagBehaviorWarning, 0);
        ops[1] = LLVMMDStringInContext(ctx, "Debug Info Version", 18);
        ops[2] = ver;
        LLVMAddNamedMetadataOperand(M, "llvm.module.flags",
                                    LLVMMDNodeInContext(ctx, ops, 3));
    }
#endif
}

int tcg_tag_setup_dbg(TcgTag *t, LLVMModuleRef M, LLVMValueRef fn,
                      const char *source_filename, const char *fn_name,
                      LLVMDIBuilderRef *dib_out)
{
    LLVMDIBuilderRef dib;
    LLVMMetadataRef  file, cu, sty, sp;

    if (!t || !M || !fn) return -1;

    dib = TCG_CREATE_DIBUILDER(M);
    if (dib_out) *dib_out = dib;
    if (!dib) return -1;

    file = LLVMDIBuilderCreateFile(dib, source_filename, strlen(source_filename),
                                   "", 0);

    /* NOTE: createCompileUnit() itself appends the CU to !llvm.dbg.cu, so
     * there is no need to call LLVMAddNamedMetadataOperand() afterwards. */
    cu = TCG_CREATE_CU(dib, LLVMDWARFSourceLanguageC99, file,
                       "tcg2llvm", 8,
                       0,            /* isOptimized  */
                       "", 0,        /* Flags        */
                       0,            /* RuntimeVer   */
                       "", 0,        /* SplitName    */
                       LLVMDWARFEmissionFull,
                       0,            /* DWOId        */
                       0,            /* SplitDebugInlining  */
                       0);           /* DebugInfoForProfiling */

    /* Required, else verifier: "invalid debug info version" */
    tcg_set_debug_info_version_flag(M, t->ctx, LLVMDebugMetadataVersion());

    /* DISubprogram.  Ty may be NULL; an empty subroutine type is accepted. */
    sty = LLVMDIBuilderCreateSubroutineType(dib, file, NULL, 0, 0);
    sp  = LLVMDIBuilderCreateFunction(dib, cu,
                                      fn_name, strlen(fn_name),
                                      fn_name, strlen(fn_name),
                                      file, 1, sty,
                                      0,   /* IsLocalToUnit */
                                      1,   /* IsDefinition  */
                                      1,   /* ScopeLine     */
                                      LLVMDIFlagZero,
                                      0);  /* IsOptimized   */
    LLVMDIBuilderFinalizeSubprogram(dib, sp);
    LLVMSetSubprogram(fn, sp);

    tcg_tag_use_dbg(t, file, sp);
    return 0;
}

void tcg_tag_dispose(TcgTag *t)
{
    size_t i;
    if (!t) return;
    if (t->map) {
        for (i = 0; i < t->map_cap; i++) free(t->map[i]);
        free(t->map);
    }
    memset(t, 0, sizeof *t);
}

/* ------------------------------------------------------------------ */
/* side table                                                          */
/* ------------------------------------------------------------------ */

static void tcg_map_put(TcgTag *t, unsigned index, const char *text)
{
    if (index >= t->map_cap) {
        size_t ncap = t->map_cap ? t->map_cap * 2 : 256;
        while (index >= ncap) ncap *= 2;
        t->map = (char **)tcg_xrealloc(t->map, ncap * sizeof(char *));
        memset(t->map + t->map_cap, 0, (ncap - t->map_cap) * sizeof(char *));
        t->map_cap = ncap;
    }
    free(t->map[index]);
    t->map[index] = tcg_xstrdup(text);
}

int tcg_tag_dump_map(TcgTag *t, const char *path)
{
    FILE *f;
    size_t i;

    if (!t || !path) return -1;
    f = fopen(path, "w");
    if (!f) return -1;
    for (i = 0; i < t->map_cap; i++) {
        if (t->map[i]) fprintf(f, "%zu\t%s\n", i, t->map[i]);
    }
    fclose(f);
    return 0;
}

/* ------------------------------------------------------------------ */
/* scope begin / end                                                   */
/* ------------------------------------------------------------------ */

void tcg_tag_begin(TcgTag *t, unsigned index, const char *fmt, ...)
{
    va_list ap;
    LLVMBasicBlockRef bb;
    LLVMValueRef fn;

    if (!t) return;

    /* Nested begin without end: close the outer scope defensively. */
    if (t->active) tcg_tag_end(t);

    t->active = 1;
    t->index  = index;

    va_start(ap, fmt);
    vsnprintf(t->text, sizeof t->text, fmt, ap);
    va_end(ap);

    snprintf(t->prefix, sizeof t->prefix, "t%u.", index);
    snprintf(t->label,  sizeof t->label,  "[%u] %s", index, t->text);

    tcg_map_put(t, index, t->text);

    /* ---- watermark ---- */
    bb = t->b ? LLVMGetInsertBlock(t->b) : NULL;
    t->bb      = bb;
    t->marker  = bb ? LLVMGetLastInstruction(bb) : NULL;
    t->bb_tail = NULL;

    fn = NULL;
    if (bb) {
        fn = LLVMGetBasicBlockParent(bb);
        if (fn) t->bb_tail = LLVMGetLastBasicBlock(fn);
    }

    /* ---- debug location: line == op index (0 is "compiler generated") ---- */
    if (t->use_dbg) {
        t->cur_loc = LLVMDIBuilderCreateDebugLocation(t->ctx, index + 1, 0,
                                                      t->sp, NULL);
        tcg_set_cur_loc(t->b, t->ctx, t->cur_loc);
    }
    (void)fn;
}

/* Tag one instruction.  Only touches instructions, and keeps an existing
 * tag so nested/duplicate scopes do not fight over the same value. */
void tcg_tag_value(TcgTag *t, LLVMValueRef v)
{
    LLVMValueRef md;
    const char *nm;
    size_t      nlen = 0;
    size_t      plen;

    if (!t || !v) return;

    md = tcg_make_mdval(t->ctx, t->label);
    if (!LLVMGetMetadata(v, t->md_kind))
        LLVMSetMetadata(v, t->md_kind, md);

    /* Prefix the value name, e.g. "add_i64.out" -> "t42.add_i64.out".
     * Instructions with no name (store, br, ret) are covered by metadata. */
#if TCG_HAS_VALUE_NAME2
    nm = LLVMGetValueName2(v, &nlen);
#else
    nm = LLVMGetValueName(v);
    nlen = nm ? strlen(nm) : 0;
#endif

    plen = strlen(t->prefix);
    if (nm && nlen > 0 && !(nlen >= plen && memcmp(nm, t->prefix, plen) == 0)) {
        char buf[512];
        snprintf(buf, sizeof buf, "%s%s", t->prefix, nm);
#if TCG_HAS_VALUE_NAME2
        LLVMSetValueName2(v, buf, strlen(buf));
#else
        LLVMSetValueName(v, buf);
#endif
    }
}

LLVMValueRef tcg_tag_autotag(TcgTag *t, LLVMValueRef v)
{
    if (t && t->active) tcg_tag_value(t, v);
    return v;
}

/* Walk [first .. end of block) and tag each instruction. */
static void tcg_tag_range(TcgTag *t, LLVMBasicBlockRef bb, LLVMValueRef first)
{
    LLVMValueRef inst, next;

    if (!bb) return;
    for (inst = first ? LLVMGetNextInstruction(first) : LLVMGetFirstInstruction(bb);
         inst != NULL;
         inst = next) {
        next = LLVMGetNextInstruction(inst);   /* fetch before any mutation */
        tcg_tag_value(t, inst);
    }
}

/* Tag every instruction in a whole block (used for freshly created blocks). */
static void tcg_tag_block(TcgTag *t, LLVMBasicBlockRef bb)
{
    tcg_tag_range(t, bb, NULL);
}

void tcg_tag_end(TcgTag *t)
{
    LLVMBasicBlockRef tail, nb;
    LLVMValueRef fn;

    if (!t || !t->active) return;

    /* 1. instructions appended to the watermark block */
    if (t->bb) tcg_tag_range(t, t->bb, t->marker);

    /* 2. instructions in blocks created during this op
     *    (e.g. the target of a brcond).  New blocks are appended at the end
     *    of the function by LLVMAppendBasicBlock/LLVMInsertBasicBlock. */
    if (t->bb) {
        fn = LLVMGetBasicBlockParent(t->bb);
        if (fn) {
            tail = t->bb_tail;
            for (nb = tail ? LLVMGetNextBasicBlock(tail)
                           : LLVMGetFirstBasicBlock(fn);
                 nb != NULL;
                 nb = LLVMGetNextBasicBlock(nb)) {
                if (nb == t->bb) continue;   /* already handled above */
                tcg_tag_block(t, nb);
            }
        }
    }

    t->active  = 0;
    t->bb      = NULL;
    t->marker  = NULL;
    t->bb_tail = NULL;
    t->text[0] = '\0';
    t->prefix[0] = '\0';

    /* Leave the !dbg location in place on purpose: instructions emitted
     * outside any scope then inherit the previous op's line instead of
     * getting a NULL location (which upsets the verifier for call sites). */
}
