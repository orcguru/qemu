/*
 * tcg_llvm_tag.h -- provenance tagging for TCG IR -> LLVM IR translators.
 *
 * Problem: one TCG op expands into N LLVM instructions (load / add / store /
 * bitcast / ...).  There is no comment field in LLVM IR, so we carry the
 * mapping on the instructions themselves in three redundant ways:
 *
 *   1. value names get a "t<idx>." prefix      -> survives -O2, greppable
 *   2. !tcg.op metadata on every instruction   -> survives most passes
 *   3. optional !dbg with line == TCG op index -> survives into .s / DWARF
 *
 * Usage pattern (matches the natural translator loop):
 *
 *     TcgTag tag;
 *     tcg_tag_init(&tag, ctx, builder);
 *     tcg_tag_use_dbg(&tag, difile, disubprogram);   // optional
 *
 *     for (i = 0; i < nb_ops; i++) {
 *         tcg_tag_begin(&tag, i, "%s", tcg_disas(op[i]));
 *         ... LLVMBuild*() the whole op ...
 *         tcg_tag_end(&tag);
 *     }
 *
 *     tcg_tag_dump_map(&tag, "tb.tcgmap");
 *     tcg_tag_dispose(&tag);
 *
 * Scope-based: tcg_tag_begin() records a watermark (current block + last
 * instruction); tcg_tag_end() walks every instruction created since then and
 * tags it.  You do NOT need to touch individual LLVMBuild* calls.
 */

#ifndef TCG_LLVM_TAG_H
#define TCG_LLVM_TAG_H

#include <stddef.h>
#include <llvm-c/Core.h>
#include <llvm-c/DebugInfo.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct TcgTag {
    LLVMContextRef ctx;
    LLVMBuilderRef b;

    /* metadata kind ids */
    unsigned md_kind;          /* !tcg.op            */
    unsigned md_line_kind;     /* !tcg.line (i32)    */

    /* ---- current scope ---- */
    int      active;
    unsigned index;            /* TCG op index                          */
    char     text[512];        /* rendered TCG disassembly              */
    char     label[544];       /* "[42] add_i64 rax,rbx,rdx"            */
    char     prefix[24];       /* "t42."                                */

    /* watermark: everything created after this point belongs to this op */
    LLVMBasicBlockRef bb;          /* block the builder sat in at begin  */
    LLVMValueRef      marker;      /* last instr in bb at begin (or NULL)*/
    LLVMBasicBlockRef bb_tail;     /* last BB of fn at begin (or NULL)   */

    /* ---- debug info (optional) ---- */
    int             use_dbg;
    LLVMMetadataRef difile;
    LLVMMetadataRef sp;
    LLVMMetadataRef cur_loc;

    /* ---- side table: op index -> TCG text ---- */
    char  **map;
    size_t  map_cap;
} TcgTag;

/* ------------------------------------------------------------------ */
/* lifecycle                                                           */
/* ------------------------------------------------------------------ */

/* ctx/builder must outlive the TcgTag. */
void tcg_tag_init(TcgTag *t, LLVMContextRef ctx, LLVMBuilderRef b);

/* Enable !dbg emission.  Every instruction gets a DILocation whose line
 * number is (TCG op index + 1).  Pass NULL,NULL to disable.
 * NOTE: once a function has a DISubprogram, inlinable call sites must have
 * a !dbg or the verifier complains -- tcg_tag_begin() covers that for every
 * call you emit inside a scope. */
void tcg_tag_use_dbg(TcgTag *t, LLVMMetadataRef difile, LLVMMetadataRef sp);

/* ---- one-shot debug info setup (recommended) ------------------------
 *
 * Does everything `use_dbg` needs, in the right order:
 *   1. LLVMCreateDIBuilder            (was LLVMNewDIBuilder pre-LLVM-8)
 *   2. DIFile + DICompileUnit         (CU auto-registers !llvm.dbg.cu)
 *   3. module flag "Debug Info Version" = LLVMDebugMetadataVersion()
 *   4. DISubprogram for `fn`, attached via LLVMSetSubprogram
 *
 * You MUST do all of this or the verifier rejects the module:
 *   "subprogram definitions must have a compile unit"
 *
 * `fn` is the LLVMValueRef of the function you are translating into -- spell
 * it exactly as your translator names it (this is the usual source of
 * "undeclared identifier" errors when copy-pasting).
 *
 * Returns 0 on success, -1 if fn/dib are NULL.  Dispose *dib_out yourself
 * with LLVMDIBuilderFinalize() + LLVMDisposeDIBuilder() when done.
 */
int tcg_tag_setup_dbg(TcgTag *t, LLVMModuleRef M, LLVMValueRef fn,
                      const char *source_filename, const char *fn_name,
                      LLVMDIBuilderRef *dib_out);

void tcg_tag_dispose(TcgTag *t);

/* ------------------------------------------------------------------ */
/* scope                                                               */
/* ------------------------------------------------------------------ */

/* Start a TCG op scope.  `index` is your TCG op number, `fmt`/... is the
 * human readable disassembly.  Call before building the op's instructions. */
void tcg_tag_begin(TcgTag *t, unsigned index, const char *fmt, ...);

/* Close the scope and tag everything created since tcg_tag_begin(). */
void tcg_tag_end(TcgTag *t);

/* Convenience: scope as a for-loop.  Do NOT `return`/`goto` out of the body,
 * that would skip tcg_tag_end() and leak the scope. */
#define TCG_SCOPE(t, idx, ...)                                          \
    for (int _tcg_once = (tcg_tag_begin(&(t), (idx), __VA_ARGS__), 1);  \
         _tcg_once;                                                     \
         _tcg_once = (tcg_tag_end(&(t)), 0))

/* ------------------------------------------------------------------ */
/* manual tagging (escape hatch)                                       */
/* ------------------------------------------------------------------ */

/* Tag one instruction explicitly.  Needed for instructions the watermark
 * cannot see, e.g. something built into a block that did not exist yet when
 * tcg_tag_begin() ran.  Harmless to call twice (second call is a no-op). */
void tcg_tag_value(TcgTag *t, LLVMValueRef v);

/* Wrap a build call so the result is tagged immediately:
 *     LLVMValueRef v = TCG_BUILD(tag, LLVMBuildAdd(b, x, y, "add"));
 * Returns the value unchanged; if no scope is active it does nothing. */
LLVMValueRef tcg_tag_autotag(TcgTag *t, LLVMValueRef v);
#define TCG_BUILD(t, call) tcg_tag_autotag(&(t), (call))

/* ------------------------------------------------------------------ */
/* side table                                                          */
/* ------------------------------------------------------------------ */

/* Write "<index>\t<text>\n" for every op seen, so tooling can translate a
 * !dbg line number or a "t<idx>." prefix back to the original TCG op.
 * Returns 0 on success, -1 on I/O failure. */
int tcg_tag_dump_map(TcgTag *t, const char *path);

#ifdef __cplusplus
}
#endif

#endif /* TCG_LLVM_TAG_H */
