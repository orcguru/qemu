#include "tcg_context.h"
#include "operand.h"
#include "tcg_ast.h"
#include <stdlib.h>
#include <assert.h>
#include <glib.h>

/* Initialize a TcgContext */
void tcg_context_init(TcgContext *ctx) {
    ctx->hex_offset = 0;
    ctx->emit_instr_count = 0;
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
    ctx->next_helper_idx = 0;
    ctx->xreg_valid = 0;
    ctx->vec_valid = 0;
    ctx->vec_spare_valid = 0;
    ctx->def_mask = NULL;
    ctx->use_mask = NULL;
    ctx->reaching_def_exclude_self_def = NULL;
    ctx->forward_use = NULL;
    ctx->num_instrs = 0;
    ctx->words_needed = 0;
}
