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
    ctx->current_func_id = 0;
    ctx->current_is_external = 0;
    ctx->lineno = 1;
    ctx->column = 1;
    ctx->lineptr = NULL;
    ctx->alias_ops_pool = (Operand *)malloc(DEFAULT_ALIAS_OPS_POOL_SIZE * sizeof(Operand));
    assert(ctx->alias_ops_pool);
    ctx->plen = 0;
    ctx->pcap = DEFAULT_ALIAS_OPS_POOL_SIZE;
    ctx->alias_map = g_hash_table_new(NULL, NULL);
    ctx->slot_map = g_hash_table_new(NULL, NULL);
    ctx->next_tmp_idx = 0;
}


