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
    uint32_t xmm_valid;
};

void tcg_context_init(TcgContext *ctx);

#endif /* TCG_CONTEXT_H */
