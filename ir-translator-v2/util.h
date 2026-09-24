#ifndef __UTIL_H
#define __UTIL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include "tcg_ast.h"

uint64_t get_vec_offset(uint64_t vec_idx);
void register_xmm(uint64_t idx, uint64_t offset);
void register_xmm_tmp(uint64_t offset);
VecInfo lookup_vector(uint64_t offset, bool in_register);
void handle_func(TcgContext *ctx, int is_external);
void debug_print_instr(TcgContext *ctx, const char *msg);
SlotInfo get_slot_for(TcgContext *ctx, SlotType type, uint16_t idx);

UnifiedInstr *new_instr(TcgContext *ctx, uint8_t opc,
                                uint8_t vs, uint8_t es,
                                Operand *ops, int nops);
void tcg_context_reset(TcgContext *ctx);
void register_alias(TcgContext *ctx, const Operand *s, const Operand *vec_env);
void try_unregister_alias(TcgContext *ctx, const Operand *op);
void expand_slot_alias(const TcgContext *ctx, UnifiedInstr *u);

void update_slot_types(TcgContext *ctx, UnifiedInstr *u);
void register_stack_alloca(TcgContext *ctx, const UnifiedInstr *u);
void register_vec_spare_stack_alloca(TcgContext *ctx, const UnifiedInstr *u);
void type_map_apply(const TcgContext *ctx);
void instr_list_insert_before(UnifiedInstr **head_p, UnifiedInstr **tail_p, UnifiedInstr *anchor, UnifiedInstr *u);
void instr_list_insert_after(UnifiedInstr **head_p, UnifiedInstr **tail_p, UnifiedInstr *anchor, UnifiedInstr *u);
void instr_list_remove_and_free(UnifiedInstr **head_p, UnifiedInstr **tail_p, UnifiedInstr *u);
UnifiedInstr *clone_instr_optional_operands(const UnifiedInstr *src, int additional_count, ...);
void func_list_append(FuncInstrList *list, UnifiedInstr *u);
void func_list_init(FuncInstrList *list);
int get_next_func_list_idx(TcgContext *ctx);
LLVMType get_operand_type(const Operand *op);

#define TMP_WORD(idx)  ((idx) / 64)
#define TMP_BIT(idx)   ((idx) % 64)

static inline void set_bit(uint64_t *base, int tmp_idx) {
    base[TMP_WORD(tmp_idx)] |= (1ULL << TMP_BIT(tmp_idx));
}

static inline void clear_bit(uint64_t *base, int tmp_idx) {
    base[TMP_WORD(tmp_idx)] &= ~(1ULL << TMP_BIT(tmp_idx));
}

static inline bool test_bit(const uint64_t *base, int tmp_idx) {
    return (base[TMP_WORD(tmp_idx)] >> TMP_BIT(tmp_idx)) & 1ULL;
}

static inline void copy_mask(uint64_t *dst, const uint64_t *src, int words) {
    memcpy(dst, src, words * sizeof(uint64_t));
}

static inline void or_mask(uint64_t *dst, const uint64_t *src, int words) {
    for (int w = 0; w < words; w++) dst[w] |= src[w];
}

static inline void clear_mask(uint64_t *dst, const uint64_t *src, int words) {
    for (int w = 0; w < words; w++) dst[w] &= ~src[w];
}

static inline int get_first_input_idx_on_call(const UnifiedInstr *u) {
    assert(u->operand_count >= TCG_CALL_OUT_FLAG_IDX &&
           u->operands[TCG_CALL_OUT_FLAG_IDX].kind == OP_IMM);
    return u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val ? (TCG_CALL_PREFIX_COUNT + 1) : TCG_CALL_PREFIX_COUNT;
}

static inline char *assemble_name_1(char *buffer, int size, const char *p1) {
    snprintf(buffer, size, "%s", p1);
    return buffer;
}

static inline char *assemble_name_2(char *buffer, int size, const char *p1, const char *p2) {
    snprintf(buffer, size, "%s.%s", p1, p2);
    return buffer;
}

static inline char *assemble_name_3(char *buffer, int size, const char *p1, const char *p2, const char *p3) {
    snprintf(buffer, size, "%s.%s.%s", p1, p2, p3);
    return buffer;
}

#endif
