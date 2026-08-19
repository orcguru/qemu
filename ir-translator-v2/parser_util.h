#ifndef __PARSER_UTIL
#define __PARSER_UTIL

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include "tcg_ast.h"

void register_xmm(uint64_t idx, uint64_t offset);
void register_xmm_tmp(uint64_t offset);
XMMReg lookup_xmm(uint64_t offset);
void handle_func(uint64_t off, UnifiedInstr *head, int is_external);
SlotInfo get_mapped_slot(TcgContext *ctx, SlotType type, uint16_t idx);
void reset_slot_map(TcgContext *ctx);

UnifiedInstr *emit_instr(uint8_t opc, bool is_helper,
                                uint8_t vs, uint8_t es,
                                Operand *ops, int nops);
void merge_attr(AttrSrcInfo *dest, const AttrSrcInfo src);

/* Free a singly-linked list of UnifiedInstr (and their operand data). */
void free_instr_list(UnifiedInstr *head);
void op_list_init(OpList *l);
void op_list_add(OpList *l, Operand op);
void op_list_free(OpList *l);

/* Append a UnifiedInstr to the context's list (O(1) using tail) */
void append_instr(TcgContext *ctx, UnifiedInstr *u);

/*
 * Reset the instruction list in the context, freeing all allocated
 * UnifiedInstr nodes.  After this call, instr_head and instr_tail
 * are both NULL and the associated memory has been released.
 */
void tcg_context_reset_instrs(TcgContext *ctx);

/*
 * Logic to handle alias e.g. add_i64 loc6,env,$0x5e0
 */
void init_alias_map(TcgContext *ctx);
void register_alias(TcgContext *ctx, Operand *s, Operand *xmm_env);
void try_unregister_alias(TcgContext *ctx, Operand *op);
void expand_slot_alias(TcgContext *ctx, UnifiedInstr *u);

/*
 * -----------------------------------------------------------------
 *  LLVM‑type inference helpers
 * -----------------------------------------------------------------
 */
LLVMType vec_op_type(uint8_t vs, uint8_t es);
void update_slot_types(TcgContext *ctx,
                              uint8_t opc, bool is_helper,
                              uint8_t vs, uint8_t es,
                              Operand *ops, int nops);
void type_map_apply(TcgContext *ctx);
void type_map_reset(TcgContext *ctx);

#endif
