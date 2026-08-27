#include "tcg_context.h"
#include "operand.h"
#include "tcg_ast.h"
#include <stdlib.h>
#include <assert.h>
#include <glib.h>

/* Initialize a TcgContext */
void tcg_context_init(TcgContext *ctx) {
    ctx->instr_head = NULL;
    ctx->instr_tail = NULL;
    ctx->llvm_func_set.lists = NULL;
    ctx->llvm_func_set.num_lists = 0;
    ctx->llvm_func_set.capacity = 0;
    ctx->current_func_id = 0;
    ctx->current_is_external = 0;
    ctx->lineno = 1;
    ctx->column = 1;
    ctx->lineptr = NULL;
    ctx->alias_ops_pool = NULL;
    ctx->plen = 0;
    ctx->pcap = 0;
    ctx->alias_map = g_hash_table_new(NULL, NULL);
    ctx->slot_map = g_hash_table_new(NULL, NULL);
    ctx->stack_type_map = g_hash_table_new(NULL, NULL);
    ctx->next_tmp_idx = 0;
}
