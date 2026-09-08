#ifndef __EXPANDER_H
#define __EXPANDER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include "tcg_ast.h"

void sanity_check_op_type_solid(const TcgContext *ctx);
void expand_push_ret_addr(TcgContext *ctx);
void expand_ret(TcgContext *ctx);
void expand_jmp_direct(TcgContext *ctx);
void expand_tmp_slot_preservation(TcgContext *ctx);
void expand_llvm_func(TcgContext *ctx);
void expand_call_template_wo_exception(TcgContext *ctx);
void expand_call_template_wi_exception(TcgContext *ctx);
void expand_call_runtime(TcgContext *ctx);
void build_per_instr_masks_collect_use_def(TcgContext *ctx);

#endif
