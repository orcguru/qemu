#ifndef TCG_CONTEXT_H
#define TCG_CONTEXT_H

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>

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
};

/* Initialize a TcgContext */
static inline void tcg_context_init(TcgContext *ctx) {
    ctx->instr_head = NULL;
    ctx->instr_tail = NULL;
    ctx->current_func_id = 0;
    ctx->current_is_external = 0;
    ctx->lineno = 1;
    ctx->column = 1;
    ctx->lineptr = NULL;
}

/* Reset the instruction list for the next function block */
static inline void tcg_context_reset_instrs(TcgContext *ctx) {
    /* Note: caller is responsible for freeing the UnifiedInstr nodes
       (e.g., inside handle_func) before resetting the head. */
    ctx->instr_head = NULL;
    ctx->instr_tail = NULL;
}

/* Helper: reverse the instruction list (since we prepend, the list is
   in reverse order of appearance). Returns the new head. */
static inline UnifiedInstr *tcg_context_reverse_instrs(TcgContext *ctx) {
    UnifiedInstr *prev = NULL;
    UnifiedInstr *curr = ctx->instr_head;
    while (curr) {
        UnifiedInstr *next = curr->next;
        curr->next = prev;
        prev = curr;
        curr = next;
    }
    ctx->instr_head = prev;
    return prev;
}

#endif /* TCG_CONTEXT_H */
