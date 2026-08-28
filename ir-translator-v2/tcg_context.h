#ifndef TCG_CONTEXT_H
#define TCG_CONTEXT_H

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <glib.h>

#include "operand.h"
#include "unified_instr.h"
#include "tcg_ast.h"

/* Forward declarations */
struct TcgContext;
typedef struct TcgContext TcgContext;
typedef void* yyscan_t;

typedef struct FuncInstrList {
    UnifiedInstr *head;
    UnifiedInstr *tail;
    int           count;
    /*
     * Function name for trampolines into runtime:
     * call_inline_exception - helper(max_length:30) + arguments (max_count:4)
     * call_runtime_wi/wo_next - helper
     *
     * Reuse function by names
     */
    char          trampoline_name[64];
} FuncInstrList;

typedef struct FuncListSet {
    FuncInstrList *lists;
    int            num_lists;
    int            capacity;
} FuncListSet;

/*
 * TcgContext – parsing context for the TCG‑IR parser.
 *
 * Holds the accumulated instruction list for the current function block,
 * as well as any other parser‑wide state you may need.
 */
struct TcgContext {
    /* Head of the linked list of UnifiedInstr for the current function.
       New instructions are prepended (O(1)). When the function block
       ends, handle_func() is called with this pointer. */
    UnifiedInstr *instr_head;
    UnifiedInstr *instr_tail;

    /* Set of llvm functions formed by one TCG IR block */
    FuncListSet llvm_func_set;

    /* Optional: track the current function ID and external flag
       (populated by the INTERNAL/EXTERNAL rules) */
    uint64_t current_func_id;
    int      current_is_external;

    /* Lexer location info (if needed by error reporting) */
    int      lineno;
    int      column;
    char    *lineptr;   /* current line text for error display */

    /* Alias map and it's Operand pool */
    Operand *alias_ops_pool;
    int plen;
    int pcap;
    GHashTable *alias_map;

    /* Slot name map */
    GHashTable *slot_map;
    uint16_t next_tmp_idx;

    /* Stack type for slot operand */
    GHashTable *stack_type_map;

    /* Next helper index */
    uint16_t next_helper_idx;

    /* Bit array for stack alloca */
    uint32_t xreg_valid;
    uint32_t vec_valid;

    /* TMP slot DEF/USE tracking */
    /*
     * This is a hack preserve stack slots during call
     */
    int words_needed;
    int num_instrs;
    uint64_t *def_mask;
    uint64_t *use_mask;
    uint64_t *reaching_def_exclude_self_def;
    uint64_t *forward_use;
};

void tcg_context_init(TcgContext *ctx);

#endif /* TCG_CONTEXT_H */
