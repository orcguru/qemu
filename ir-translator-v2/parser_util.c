#include <glib.h>
#include "tcg_context.h"
#include "parser_util.h"
#include "unified_instr.h"
#include "tcg_ast.h"
#include "operand_static_types.h"
#include "mapper_util.h"
#include "i386_cpu.h"

extern int cfg_xmm_count;

// FIXME: improve const attribute on all code
static uint16_t xmm_offsets[17] = {0};

static uint16_t get_next_tmp_idx(TcgContext *ctx) {
    return ctx->next_tmp_idx++;
}

uint64_t get_vec_offset(uint64_t vec_idx) {
    assert(vec_idx <= 32);
    return (xmm_offsets[vec_idx >> 1] + ((vec_idx & 1) ? 0x10 : 0));
}

void register_xmm(uint64_t idx, uint64_t offset) {
    assert(idx < 16);
    xmm_offsets[idx] = (uint16_t)offset;
}

void register_xmm_tmp(uint64_t offset) {
    xmm_offsets[XMM_TMP_IDX] = (uint16_t)offset;
}

VecInfo lookup_vec(uint64_t offset) {
    uint16_t off = (uint16_t)offset;
    VecInfo v;
    v.idx = NON_XMM;
    v.offset = 0;
    if (cfg_xmm_count > 0 && xmm_offsets[0] <= off && off < (xmm_offsets[cfg_xmm_count-1] + 0x20)) {
        uint16_t idx = (off - xmm_offsets[0]) / 0x40;
        uint16_t delta = (off - xmm_offsets[0]) % 0x40;
        if (delta < 0x10) {
            v.idx = idx * 2;
            v.offset = delta;
        } else if (delta < 0x20) {
            v.idx = idx * 2 + 1;
            v.offset = delta - 0x10;
        }
    }
    return v;
}

VecInfo lookup_vec_map(uint64_t offset) {
    uint16_t off = (uint16_t)offset;
    VecInfo v;
    v.idx = NON_XMM;
    v.offset = 0;
    if (xmm_offsets[0] <= off && off < (xmm_offsets[XMM_TMP_IDX - 1] + 0x20)) {
        uint16_t idx = (off - xmm_offsets[0]) / 0x40;
        uint16_t delta = (off - xmm_offsets[0]) % 0x40;
        if (delta < 0x10) {
            v.idx = idx * 2;
            v.offset = delta;
        } else if (delta < 0x20) {
            v.idx = idx * 2 + 1;
            v.offset = delta - 0x10;
        }
    } else if (xmm_offsets[XMM_TMP_IDX] <= off && off < (xmm_offsets[XMM_TMP_IDX] + 0x20)) {
        uint16_t idx = XMM_TMP_IDX;
        uint16_t delta = off - xmm_offsets[XMM_TMP_IDX];
        if (delta < 0x10) {
            v.idx = idx * 2;
            v.offset = delta;
        } else if (delta < 0x20) {
            v.idx = idx * 2 + 1;
            v.offset = delta - 0x10;
        }
    }
    return v;
}

#define TMP_WORD(idx)  ((idx) / 64)
#define TMP_BIT(idx)   ((idx) % 64)

static inline void set_tmp_bit(uint64_t *base, int tmp_idx) {
    base[TMP_WORD(tmp_idx)] |= (1ULL << TMP_BIT(tmp_idx));
}

static inline bool test_tmp_bit(const uint64_t *base, int tmp_idx) {
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

/*
 * Both loc* and tmp* are mapped to linear tmp space
 */
SlotInfo get_mapped_slot(TcgContext *ctx, SlotType type, uint16_t idx) {
    SlotInfo ret;
    ret.type = SUB_SLOT_TMP;
    uint16_t key_idx = idx;
#define TMPT_OFFSET     (1 << 15);
    if (type == SUB_SLOT_TMPT) {
        key_idx += TMPT_OFFSET;
    }
    if (g_hash_table_contains(ctx->slot_map, (gconstpointer)(long)key_idx)) {
        ret.idx = (uint16_t)(long)g_hash_table_lookup(ctx->slot_map, (gpointer)(long)key_idx);
    } else {
        ret.idx = get_next_tmp_idx(ctx);
        g_hash_table_insert(ctx->slot_map, (gpointer)(long)key_idx, (gpointer)(long)ret.idx);
    }
    return ret;
}

void free_instr_list(UnifiedInstr *head) {
    while (head) {
        UnifiedInstr *next = head->next;
        free(head);
        head = next;
    }
}

void op_list_init(OpList *l) {
    l->data = NULL;
    l->len = 0;
    l->cap = 0;
}

void op_list_add(OpList *l, Operand op) {
    if (l->len >= l->cap) {
        l->cap = l->cap ? l->cap * 2 : 8;
        l->data = realloc(l->data, l->cap * sizeof(Operand));
    }
    l->data[l->len++] = op;
}

void op_list_free(OpList *l) {
    free(l->data);
    l->data = NULL;
    l->len = l->cap = 0;
}

UnifiedInstr *clone_instr(const UnifiedInstr *src) {
    size_t sz = sizeof(UnifiedInstr) + src->operand_count * sizeof(Operand);
    UnifiedInstr *dst = malloc(sz);
    memcpy(dst, src, sz);
    dst->prev = NULL;
    dst->next = NULL;
    return dst;
}

static int get_first_input_idx_on_call(const UnifiedInstr *u) {
    assert(u->operand_count >= TCG_CALL_OUT_FLAG_IDX &&
           u->operands[TCG_CALL_OUT_FLAG_IDX].kind == OP_IMM);
    if (u->operands[TCG_CALL_OUT_FLAG_IDX].imm) {
        return TCG_CALL_PREFIX_COUNT + 1;
    }
    return TCG_CALL_PREFIX_COUNT;
}

/* Insert 'u' right after 'anchor'. If anchor is NULL, prepend at head. */
static void instr_list_insert_after(UnifiedInstr **head_p, UnifiedInstr **tail_p, UnifiedInstr *anchor, UnifiedInstr *u) {
    u->prev = anchor;
    if (!anchor) {
        /* prepend at head */
        u->next = *head_p;
        if (*head_p)
            (*head_p)->prev = u;
        *head_p = u;
        if (!*tail_p)
            *tail_p = u;
    } else {
        u->next = anchor->next;
        if (anchor->next)
            anchor->next->prev = u;
        anchor->next = u;
        if (anchor == *tail_p)
            *tail_p = u;
    }
}

/* Insert 'u' right before 'anchor'. If anchor is NULL, append at tail. */
static void instr_list_insert_before(UnifiedInstr **head_p, UnifiedInstr **tail_p, UnifiedInstr *anchor, UnifiedInstr *u) {
    if (!anchor) {
        u->prev = *tail_p;
        u->next = NULL;
        if (*tail_p) {
            (*tail_p)->next = u;
            *tail_p = u;
        } else {
            *head_p = u;
            *tail_p = u;
        }
        return;
    }
    instr_list_insert_after(head_p, tail_p, anchor->prev, u);
}

static void instr_list_remove_and_free(UnifiedInstr **head_p, UnifiedInstr **tail_p, UnifiedInstr *u) {
    if (u->prev)
        u->prev->next = u->next;
    else
        *head_p = u->next;
    if (u->next)
        u->next->prev = u->prev;
    else
        *tail_p = u->prev;
    free(u);
}

void append_instr(TcgContext *ctx, UnifiedInstr *u) {
    u->prev = ctx->instr_tail;
    u->next = NULL;
    if (ctx->instr_tail) {
        ctx->instr_tail->next = u;
        ctx->instr_tail = u;
    } else {
        ctx->instr_head = u;
        ctx->instr_tail = u;
    }
}

void func_list_init(FuncInstrList *list) {
    list->head_uidx = -1;
    list->head = NULL;
    list->tail = NULL;
    list->count = 0;
    memset(&list->trampoline_name[0], 0, sizeof(list->trampoline_name));
}

void func_list_append(FuncInstrList *list, UnifiedInstr *u) {
    u->prev = list->tail;
    u->next = NULL;
    if (list->tail) {
        list->tail->next = u;
        list->tail = u;
    } else {
        list->head = u;
        list->tail = u;
    }
    list->count++;
}

void func_list_free(FuncInstrList *list) {
    UnifiedInstr *cur = list->head;
    while (cur) {
        UnifiedInstr *next = cur->next;
        free(cur);
        cur = next;
    }
    list->head = NULL;
    list->tail = NULL;
    list->count = 0;
}

int get_next_func_list_idx(TcgContext *ctx) {
    if (ctx->llvm_func_set.num_lists >= ctx->llvm_func_set.capacity) {
        ctx->llvm_func_set.capacity = ctx->llvm_func_set.capacity ? 2 * ctx->llvm_func_set.capacity : 2;
        ctx->llvm_func_set.lists = realloc(ctx->llvm_func_set.lists, ctx->llvm_func_set.capacity * sizeof(FuncInstrList));
    }
    return ctx->llvm_func_set.num_lists++;
}

void func_list_set_free(FuncListSet *set) {
    for (int i = 0; i < set->num_lists; i++) {
        func_list_free(&set->lists[i]);
    }
    free(set->lists);
    set->lists = NULL;
    set->num_lists = 0;
    set->capacity = 0;
}

void tcg_context_reset(TcgContext *ctx) {
    ctx->hex_offset = 0;
    ctx->emit_instr_count = 0;
    free_instr_list(ctx->instr_head);
    ctx->instr_head = NULL;
    ctx->instr_tail = NULL;

    // Data structure to split into llvm funcs
    func_list_set_free(&ctx->llvm_func_set);

    // init_alias_map
    ctx->plen = 0;
    g_hash_table_remove_all(ctx->alias_map);
    g_hash_table_remove_all(ctx->slot_map);
    g_hash_table_remove_all(ctx->stack_type_map);

    // Reset stack alloca bit array
    ctx->xreg_valid = 0;
    ctx->vec_valid = 0;
    ctx->vec_spare_valid = 0;

    free(ctx->def_mask);
    free(ctx->use_mask);
    free(ctx->reaching_def_exclude_self_def);
    free(ctx->forward_use);
    free(ctx->unexpected_branch);
    ctx->def_mask = NULL;
    ctx->use_mask = NULL;
    ctx->reaching_def_exclude_self_def = NULL;
    ctx->forward_use = NULL;
    ctx->unexpected_branch = NULL;
    ctx->num_instrs = 0;
    ctx->words_needed = 0;
}

/*
 * Logic to handle alias e.g. add_i64 loc6,env,$0x5e0
 */
void register_alias(TcgContext *ctx, Operand *s, Operand *vec_env) {
    assert(s->kind == OP_SLOT && s->slot.type == SUB_SLOT_TMP);
    assert(vec_env->kind == OP_VEC || vec_env->kind == OP_ENV);
    if (ctx->plen >= ctx->pcap) {
        ctx->pcap = ctx->pcap ? ctx->pcap * 2 : 8;
        ctx->alias_ops_pool = realloc(ctx->alias_ops_pool, ctx->pcap * sizeof(Operand));
    }
    ctx->alias_ops_pool[ctx->plen] = *vec_env;
    if (g_hash_table_contains(ctx->alias_map, (gconstpointer)(long)s->slot.idx)) {
        g_hash_table_replace(ctx->alias_map, (gpointer)(long)s->slot.idx, &ctx->alias_ops_pool[ctx->plen]);
    } else {
        g_hash_table_insert(ctx->alias_map, (gpointer)(long)s->slot.idx, &ctx->alias_ops_pool[ctx->plen]);
    }
    ctx->plen += 1;
}

void try_unregister_alias(TcgContext *ctx, Operand *op) {
    if (op->kind == OP_SLOT && op->slot.type == SUB_SLOT_TMP) {
        if (g_hash_table_contains(ctx->alias_map, (gconstpointer)(long)op->slot.idx)) {
            g_hash_table_remove(ctx->alias_map, (gpointer)(long)op->slot.idx);
        }
    }
}

void expand_slot_alias(TcgContext *ctx, UnifiedInstr *u) {
    for (int i = get_first_in_op_idx(u); i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_SLOT && u->operands[i].slot.type == SUB_SLOT_TMP && g_hash_table_contains(ctx->alias_map, (gconstpointer)(long)u->operands[i].slot.idx)) {
            const Operand *op = g_hash_table_lookup(ctx->alias_map, (gpointer)(long)u->operands[i].slot.idx);
            u->operands[i] = *op;
        }
    }
}

/*
 * -----------------------------------------------------------------
 *  LLVM‑type inference helpers
 * -----------------------------------------------------------------
 */
LLVMType vec_op_type(uint8_t vs, uint8_t es) {
    if (vs == 64) {
        switch (es) {
        case 8: return LLVMVector8xi8;
        case 16: return LLVMVector4xi16;
        case 32: return LLVMVector2xi32;
        case 64: return LLVMVector1xi64;
        default: return LLVMInvalidType;
        }
    }
    if (vs == 128) {
        switch (es) {
        case 8: return LLVMVector16xi8;
        case 16: return LLVMVector8xi16;
        case 32: return LLVMVector4xi32;
        case 64: return LLVMVector2xi64;
        default: return LLVMInvalidType;
        }
    }
    return LLVMInvalidType;
}

void set_operand_type(TcgContext *ctx, Operand *op, LLVMType ty) {
    if (op->kind == OP_SLOT) {
        op->slot.op_type = ty;
        if (op->slot.type == SUB_SLOT_TMP) {
            LLVMType stack_ty = ty > LLVMInt64 ? LLVMVector2xi64 : ty;
            if (g_hash_table_contains(ctx->stack_type_map, (gconstpointer)(long)op->slot.idx)) {
                LLVMType current_ty = (LLVMType)(long)g_hash_table_lookup(ctx->stack_type_map, (gpointer)(long)op->slot.idx);
                if (stack_ty > current_ty) {
                    g_hash_table_replace(ctx->stack_type_map, (gpointer)(long)op->slot.idx, (gpointer)(long)stack_ty);
                }
            } else {
                g_hash_table_insert(ctx->stack_type_map, (gpointer)(long)op->slot.idx, (gpointer)(long)stack_ty);
            }
        }
    } else if (op->kind == OP_VEC) {
        op->vec.op_type = ty;
    } else if (op->kind == OP_ENV) {
        op->env.op_type = ty;
    }
}

void register_stack_alloca(TcgContext *ctx, UnifiedInstr *u) {
    for (int i = 0; i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_VEC) {
            ctx->vec_valid |= (1 << u->operands[i].vec.idx);
        }
        if (u->operands[i].kind == OP_SLOT && u->operands[i].slot.type == SUB_SLOT_XREG) {
            ctx->xreg_valid |= (1 << u->operands[i].slot.idx);
        }
    }
}

void register_vec_spare_stack_alloca(TcgContext *ctx, UnifiedInstr *u) {
    for (int i = 0; i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_VEC) {
            ctx->vec_spare_valid |= (1 << u->operands[i].vec.idx);
        }
    }
}

void update_slot_types(TcgContext *ctx, UnifiedInstr *u) {
    LLVMType ty = LLVMInvalidType;
    /* Vector */
    if (u->vs > 0) {
        ty = vec_op_type(u->vs, u->es);
        for (int i = 0; i < u->operand_count; ++i) {
            set_operand_type(ctx, &u->operands[i], ty);
        }
        return;
    }
    /* Call helper */
    assert(u->opc != tail_call_default);
    assert(u->opc != call_qemuaot);
    assert(u->opc != call_default);
    if (u->opc == call) {
        int first_input_idx = TCG_CALL_PREFIX_COUNT;
        assert(u->operands[0].kind == OP_SYMBOL);
        assert(u->operands[2].kind == OP_IMM);
        HelperType h = u->operands[0].symbol;
        // Handle output
        if (u->operands[2].imm) {
            first_input_idx += 1;
            assert(u->operands[TCG_CALL_PREFIX_COUNT].kind == OP_SLOT);
            assert(helper_return_type[h] != LLVMInvalidType);
            set_operand_type(ctx, &u->operands[TCG_CALL_PREFIX_COUNT], helper_return_type[h]);
        }
        int type_lookup_idx = 0;
        for (int i = first_input_idx; i < u->operand_count; ++i) {
            if (u->operands[i].kind == OP_SLOT) {
                assert(type_lookup_idx < MAX_ADDED_ARGS);
                if (helper_collapse_xmm_arg_type[h][type_lookup_idx] != LLVMInvalidType) {
                    set_operand_type(ctx, &u->operands[i], helper_collapse_xmm_arg_type[h][type_lookup_idx]);
                } else {
                    set_operand_type(ctx, &u->operands[i], LLVMInt64);
                }
                type_lookup_idx += 1;
            } else if (u->operands[i].kind == OP_VEC) {
                u->operands[i].vec.op_type = LLVMVector2xi64;
            } else if (u->operands[i].kind == OP_ENV) {
                assert(xmm_offsets[XMM_TMP_IDX]);
                if (u->operands[i].env.offset == xmm_offsets[XMM_TMP_IDX]) {
                    u->operands[i].env.op_type = LLVMVector2xi64;
                } else {
                    u->operands[i].env.op_type = LLVMInt64;
                }
            }
        }
        return;
    } else if (u->opc == tail_call_qemuaot) {
        for (int i = 0; i < u->operand_count; ++i) {
            if (u->operands[i].kind == OP_SLOT) {
                set_operand_type(ctx, &u->operands[i], LLVMInt64);
            }
        }
        return;
    }
    /* Scalar */
    for (int i = 0; i < u->operand_count; ++i) {
        if (u->operands[i].kind != OP_SLOT &&
            u->operands[i].kind != OP_VEC &&
            u->operands[i].kind != OP_ENV) {
            continue;
        }
        if (opcmem_addr_nzidx[u->opc] > 0) {
            // Memory operations
            if (i < opcmem_addr_nzidx[u->opc]) {
                assert(u->operands[i].kind == OP_SLOT);
                // Register-bits
                set_operand_type(ctx, &u->operands[i], opciosz[u->opc][1]);
            } else {
                // Memory-bits
                if (opciosz[u->opc][0] == LLVMInvalidType) {
                    const AttrSrcInfo *attr = get_attribute_from_instr(u);
                    assert(attr);
                    assert(attr->subt == SUB_ATTR_STORAGE);
                    assert(attr->p.storage.size != INVALID_SRCSIZE);
                    switch (attr->p.storage.size) {
                    case SRC1B:
                        set_operand_type(ctx, &u->operands[i], LLVMInt8);
                        break;
                    case SRC2B:
                        set_operand_type(ctx, &u->operands[i], LLVMInt16);
                        break;
                    case SRC4B:
                        set_operand_type(ctx, &u->operands[i], LLVMInt32);
                        break;
                    case SRC8B:
                        set_operand_type(ctx, &u->operands[i], LLVMInt64);
                        break;
                    default:
                        assert(0);
                    }
                } else {
                    set_operand_type(ctx, &u->operands[i], opciosz[u->opc][0]);
                }
            }
        } else {
            if (i < opcoc[u->opc]) {
                // Output-bits
                set_operand_type(ctx, &u->operands[i], opciosz[u->opc][1]);
            } else {
                // Input-bits
                if (opciosz[u->opc][0] == LLVMInvalidType) {
                    const AttrSrcInfo *attr = get_attribute_from_instr(u);
                    assert(attr);
                    assert(attr->subt == SUB_ATTR_STORAGE);
                    assert(attr->p.storage.size != INVALID_SRCSIZE);
                    switch (attr->p.storage.size) {
                    case SRC1B:
                        set_operand_type(ctx, &u->operands[i], LLVMInt8);
                        break;
                    case SRC2B:
                        set_operand_type(ctx, &u->operands[i], LLVMInt16);
                        break;
                    case SRC4B:
                        set_operand_type(ctx, &u->operands[i], LLVMInt32);
                        break;
                    case SRC8B:
                        set_operand_type(ctx, &u->operands[i], LLVMInt64);
                        break;
                    default:
                        assert(0);
                    }
                } else {
                    set_operand_type(ctx, &u->operands[i], opciosz[u->opc][0]);
                }
            }
        }
    }
    return;
}

void sanity_check_op_type_solid(TcgContext *ctx) {
    for (const UnifiedInstr *u = ctx->instr_head; u; u = u->next) {
        for (int i = 0; i < u->operand_count; ++i) {
            const Operand *op = &u->operands[i];
            if (op->kind == OP_SLOT) {
                assert(op->slot.op_type);
            } else if (op->kind == OP_VEC) {
                assert(op->vec.op_type);
            } else if (op->kind == OP_ENV) {
                assert(op->env.op_type);
            }       
        }
    }
}

void type_map_apply(TcgContext *ctx) {
    for (int fi = 0; fi < ctx->llvm_func_set.num_lists; ++fi) {
        for (UnifiedInstr *u = ctx->llvm_func_set.lists[fi].head; u; u = u->next) {
            for (int i = 0; i < u->operand_count; ++i) {
                Operand *op = &u->operands[i];
                if (op->kind == OP_SLOT) {
                    if (op->slot.type == SUB_SLOT_TMP) {
                        LLVMType stack_ty = (LLVMType)(long)g_hash_table_lookup(ctx->stack_type_map, (gpointer)(long)op->slot.idx);
                        assert(stack_ty != LLVMInvalidType);
                        op->slot.stack_type = stack_ty;
                    } else {
                        assert(op->slot.stack_type != LLVMInvalidType);
                    }
                } else if (op->kind == OP_VEC) {
                    assert(op->vec.stack_type != LLVMInvalidType);
                }
            }
        }
    }
}

void merge_attr(AttrSrcInfo *dest, const AttrSrcInfo src) {
    if (src.subt == SUB_ATTR_STORAGE) {
        if (src.p.storage.atomic)
            dest->p.storage.atomic = src.p.storage.atomic;
        if (src.p.storage.alignment)
            dest->p.storage.alignment = src.p.storage.alignment;
        if (src.p.storage.ext)
            dest->p.storage.ext = src.p.storage.ext;
        if (src.p.storage.size)
            dest->p.storage.size = src.p.storage.size;
        dest->subt = SUB_ATTR_STORAGE;
    } else if (src.subt == SUB_ATTR_SWAP) {
        dest->p.swap |= src.p.swap;
        dest->subt = SUB_ATTR_SWAP;
    }
}

UnifiedInstr *emit_instr(TcgContext *ctx, uint8_t opc,
                                uint8_t vs, uint8_t es,
                                Operand *ops, int nops) {
    size_t sz = sizeof(UnifiedInstr) + nops * sizeof(Operand);
    UnifiedInstr *u = calloc(1, sz);
    u->opc = opc;
    u->vs = vs;
    u->es = es;
    u->uidx = ctx->emit_instr_count++;
    int skip_cnt = 0;
    int dst_idx = 0;
    if (u->opc == call) {
        memcpy(u->operands, ops, (nops * sizeof(Operand)));
        assert(u->operands[0].kind == OP_SYMBOL && u->operands[0].symbol != not_a_helper);
    } else {
        for (int i = 0; i < nops; ++i) {
            if (ops[i].kind == OP_ENV && (i + 1) < nops && ops[i + 1].kind == OP_IMM) {
                VecInfo v = lookup_vec(ops[i + 1].imm);
                if (v.idx != NON_XMM) {
                    u->operands[dst_idx].kind = OP_VEC;
                    u->operands[dst_idx].vec.idx = v.idx;
                    u->operands[dst_idx].vec.offset = v.offset;
                    u->operands[dst_idx].vec.op_type = LLVMInvalidType;
                    u->operands[dst_idx].vec.stack_type = LLVMVector2xi64;
                } else {
                    u->operands[dst_idx].kind = OP_ENV;
                    u->operands[dst_idx].env.offset = (uint16_t)ops[i + 1].imm;
                    u->operands[dst_idx].env.op_type = LLVMInvalidType;
                    u->operands[dst_idx].env.stack_type = LLVMInvalidType;
                }
                i += 1;
                skip_cnt += 1;
            } else {
                u->operands[dst_idx] = ops[i];
            }
            dst_idx += 1;
        }
    }
    u->operand_count = nops - skip_cnt;
    u->prev = NULL;
    u->next = NULL;
    return u;
}

UnifiedInstr *get_single_target_opc(TcgContext *ctx, OpCodeType opc) {
    UnifiedInstr *u = ctx->instr_head;
    while (u) {
        if (u->opc == opc) {
            return u;
        }
        u = u->next;
    }
    return NULL;
}

#define EMIT_INSTR_BEFORE(ctx, hp, tp, u, opc, vs, es, ...)                 \
    do {                                                                    \
        Operand _ops[] = { __VA_ARGS__ };                                   \
        size_t _cnt = sizeof(_ops) / sizeof(_ops[0]);                       \
        UnifiedInstr *_u = emit_instr(ctx, opc, vs, es, _ops, _cnt);        \
        expand_slot_alias(ctx, _u);                                         \
        update_slot_types(ctx, _u);                                         \
        register_vec_spare_stack_alloca(ctx, _u);                           \
        instr_list_insert_before(hp, tp, u, _u);                            \
    } while (0)

#define EMIT_INSTR_APPEND_LIST(ctx, list, opc, vs, es, ...)                 \
    do {                                                                    \
        Operand _ops[] = { __VA_ARGS__ };                                   \
        size_t _cnt = sizeof(_ops) / sizeof(_ops[0]);                       \
        UnifiedInstr *_u = emit_instr(ctx, opc, vs, es, _ops, _cnt);        \
        expand_slot_alias(ctx, _u);                                         \
        update_slot_types(ctx, _u);                                         \
        func_list_append(list, _u);                                         \
    } while (0)

#define SLOT_OP(ty, index)  ((Operand){ .kind = OP_SLOT, .slot.type = (ty), .slot.idx = (index) })
#define VEC_OP(index, off)   ((Operand){ .kind = OP_VEC, .vec.idx = (index), .vec.offset = (off), .vec.stack_type = LLVMVector2xi64 })
// Use SLOT_OP_EXTRA to copy from existing operand
#define SLOT_OP_EXTRA(ty, index, op_ty, stack_ty)                           \
            ((Operand){ .kind = OP_SLOT, .slot.type = (ty), .slot.idx = (index), .slot.op_type = (op_ty), .slot.stack_type = (stack_ty) })
#define IMM_OP(val)         ((Operand){ .kind = OP_IMM,   .imm = (val) })
#define ENV_OP(off)         ((Operand){ .kind = OP_ENV,   .env.offset = (off) })
#define LABEL_OP(lbl)       ((Operand){ .kind = OP_LABEL, .label = (lbl) })
#define RELOP_OP(r)         ((Operand){ .kind = OP_RELOP, .relop = (r) })
#define SYMBOL_OP(sym)      ((Operand){ .kind = OP_SYMBOL, .symbol = (sym) })
#define LASTARG_OP()        ((Operand){ .kind = OP_LASTARG })
#define ATTR_STORAGE_OP(nonatomic, align, sz)                             \
    ((Operand){ .kind = OP_ATTR, .attr_info = {                            \
        .subt = SUB_ATTR_STORAGE,                                          \
        .p.storage = { .atomic = (nonatomic), .alignment = (align), .size = (sz) } \
    }})

void expand_push_ret_addr(TcgContext *ctx) {
    UnifiedInstr *u = get_single_target_opc(ctx, push_ret_addr);
    if (!u) {
        return;
    }
    int tmp1 = get_next_tmp_idx(ctx);
    int tmp2 = get_next_tmp_idx(ctx);
    int tmp3 = get_next_tmp_idx(ctx);

    // - GET pointer to the shadow stack ptr
    // mov_i64 tmp_N1,env
    // add_i64 tmp_N1,tmp_N1,-8UL
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, mov_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        ENV_OP(0));
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, add_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        IMM_OP(-8ULL));

    // - LOAD the shadow stack ptr
    // qemu_ld_i64 tmp_N2,tmp_N1,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, qemu_ld_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - ALLOCATE an entry on the shadow stack
    // add_i64 tmp_N2,tmp_N2,-8UL
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, add_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        IMM_OP(-8ULL));

    // - STORE x64_ret_addr into the entry
    // qemu_st_i64 op0,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
    assert(u->operands[0].kind == OP_SLOT);
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, qemu_st_i64, 0, 0,
        SLOT_OP_EXTRA(u->operands[0].slot.type, u->operands[0].slot.idx, u->operands[0].slot.op_type, u->operands[0].slot.stack_type),
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - ALLOCATE an entry on the shadow stack
    // add_i64 tmp_N2,tmp_N2,-8UL
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, add_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        IMM_OP(-8ULL));

    // - GET the address of return
    // func_addr tmp_N3,op1,0
    assert(u->operands[1].kind == OP_IMM);
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, func_addr, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp3),
        IMM_OP(u->operands[1].imm),
        IMM_OP(0));

    // - STORE the address of return into the entry
    // qemu_st_i64 tmp_N3,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, qemu_st_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp3),
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - UPDATE the shadow stack ptr
    // qemu_st_i64 tmp_N2,tmp_N1,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, qemu_st_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    instr_list_remove_and_free(&ctx->instr_head, &ctx->instr_tail, u);
}

void expand_ret(TcgContext *ctx) {
    UnifiedInstr *u = get_single_target_opc(ctx, ret);
    if (!u) {
        return;
    }
    int tmp1 = get_next_tmp_idx(ctx);
    int tmp2 = get_next_tmp_idx(ctx);
    int tmp3 = get_next_tmp_idx(ctx);
    int tmp4 = get_next_tmp_idx(ctx);
    // - GET pointer to the shadow stack ptr
    // mov_i64 tmp_N1,env
    // add_i64 tmp_N1,tmp_N1,-8UL
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, mov_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp1), ENV_OP(0));
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, add_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp1), SLOT_OP(SUB_SLOT_TMP, tmp1), IMM_OP(-8ULL));

    // - LOAD the shadow stack ptr
    // qemu_ld_i64 tmp_N2,tmp_N1,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, qemu_ld_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp2), SLOT_OP(SUB_SLOT_TMP, tmp1), ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - LOAD the address of return
    // qemu_ld_i64 tmp_N3,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, qemu_ld_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp3), SLOT_OP(SUB_SLOT_TMP, tmp2), ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - POP the shadow stack
    // add_i64 tmp_N2,tmp_N2,8UL
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, add_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp2), SLOT_OP(SUB_SLOT_TMP, tmp2), IMM_OP(8ULL));

    // - LOAD the x64_ret_addr
    // qemu_ld_i64 tmp_N4,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, qemu_ld_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp4), SLOT_OP(SUB_SLOT_TMP, tmp2), ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - POP the shadow stack
    // add_i64 tmp_N2,tmp_N2,8UL
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, add_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp2), SLOT_OP(SUB_SLOT_TMP, tmp2), IMM_OP(8ULL));

    // - UPDATE the shadow stack ptr
    // qemu_st_i64 tmp_N2,tmp_N1,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, qemu_st_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp2), SLOT_OP(SUB_SLOT_TMP, tmp1), ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - CHECK if lookup is needed
    // brcond_i64 op0,tmp_N4,ne,L0
    assert(u->operands[0].kind == OP_SLOT);
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, brcond_i64, 0, 0, SLOT_OP_EXTRA(u->operands[0].slot.type, u->operands[0].slot.idx, u->operands[0].slot.op_type, u->operands[0].slot.stack_type), SLOT_OP(SUB_SLOT_TMP, tmp4), RELOP_OP(ne), LABEL_OP(0));

    // - TAIL call
    // tail_call_qemuaot tmp_N3,0,0
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, tail_call_qemuaot, 0, 0,
                      SLOT_OP(SUB_SLOT_TMP, tmp3),
                      IMM_OP(0),
                      IMM_OP(0));

    // - LOOKUP return address
    // set_label L0
    // call jmp_ind,0x1,0,op0
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, set_label, 0, 0, LABEL_OP(0));
    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, call, 0, 0, SYMBOL_OP(helper_jmp_ind), IMM_OP(0x1), IMM_OP(0), SLOT_OP_EXTRA(u->operands[0].slot.type, u->operands[0].slot.idx, u->operands[0].slot.op_type, u->operands[0].slot.stack_type));

    instr_list_remove_and_free(&ctx->instr_head, &ctx->instr_tail, u);
}

void expand_jmp_direct(TcgContext *ctx) {
    UnifiedInstr *u = ctx->instr_head;
    while (u) {
        if (u->opc != jmp_direct) {
            u = u->next;
            continue;
        }
        int tmp1 = get_next_tmp_idx(ctx);

        // - GET the address of return
        // func_addr tmp_N1,op0,0
        assert(u->operands[0].kind == OP_IMM);
        EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, func_addr, 0, 0,
            SLOT_OP(SUB_SLOT_TMP, tmp1),
            IMM_OP(u->operands[0].imm),
            IMM_OP(0));

        // - TAIL call
        // tail_call_qemuaot tmp_N1,0,0
        EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, u, tail_call_qemuaot, 0, 0,
                          SLOT_OP(SUB_SLOT_TMP, tmp1),
                          IMM_OP(0),
                          IMM_OP(0));

        UnifiedInstr *next = u->next;
        instr_list_remove_and_free(&ctx->instr_head, &ctx->instr_tail, u);
        u = next;
    }
}

static int get_def_tmp_indices(UnifiedInstr *u, int *out_idx, int out_cnt) {
    int ret_cnt = 0;
    if (u->opc == call &&
        u->operands[TCG_CALL_OUT_FLAG_IDX].kind == OP_IMM && u->operands[TCG_CALL_OUT_FLAG_IDX].imm &&
        u->operands[TCG_CALL_PREFIX_COUNT].kind == OP_SLOT && u->operands[TCG_CALL_PREFIX_COUNT].slot.type == SUB_SLOT_TMP) {
        out_idx[ret_cnt++] = u->operands[TCG_CALL_PREFIX_COUNT].slot.idx;
    } else {
        for (int i = 0; i < opcoc[u->opc]; ++i) {
            if (u->operands[i].kind == OP_SLOT && u->operands[i].slot.type == SUB_SLOT_TMP) {
                out_idx[ret_cnt++] = u->operands[i].slot.idx;
            }
        }
    }
    return ret_cnt;
}

static int get_use_tmp_indices(UnifiedInstr *u, int *out_idx, int out_cnt) {
    int ret_cnt = 0;
    int in_idx = 0;
    if (u->opc == call) {
        in_idx = TCG_CALL_PREFIX_COUNT;
        if (u->operands[TCG_CALL_OUT_FLAG_IDX].kind == OP_IMM && u->operands[TCG_CALL_OUT_FLAG_IDX].imm) {
            in_idx += 1;
        }
    } else {
        in_idx = opcoc[u->opc];
    }
    for (int i = in_idx; i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_SLOT && u->operands[i].slot.type == SUB_SLOT_TMP) {
            out_idx[ret_cnt++] = u->operands[i].slot.idx;
        }
    }
    return ret_cnt;
}

void build_per_instr_masks_collect_use_def(TcgContext *ctx) {
    int n = 0;
    UnifiedInstr *u = ctx->instr_head;
    while (u) { n++; u = u->next; }
    ctx->num_instrs = n;

    int max_tmp = ctx->next_tmp_idx;
    int words = (max_tmp + 63) / 64;
    ctx->words_needed = words;

    ctx->def_mask = calloc(n * words, sizeof(uint64_t));
    ctx->use_mask = calloc(n * words, sizeof(uint64_t));
    ctx->reaching_def_exclude_self_def = calloc(n * words, sizeof(uint64_t));
    ctx->forward_use = calloc(n * words, sizeof(uint64_t));
    ctx->unexpected_branch = calloc(n, sizeof(bool));
    GHashTable *label_tracking = g_hash_table_new(NULL, NULL);

    int idx = 0;
    u = ctx->instr_head;
    while (u) {
        if (u->opc == set_label) {
            assert(u->operands[0].kind == OP_LABEL);
            uint16_t label = u->operands[0].label;
            assert(!g_hash_table_contains(label_tracking, (gconstpointer)(long)label));
            g_hash_table_insert(label_tracking, (gpointer)(long)label, (gpointer)(long)idx);
        } else if (u->opc == br || u->opc == brcond_i32 || u->opc == brcond_i64) {
            assert(u->operands[u->operand_count - 1].kind == OP_LABEL);
            uint16_t label = u->operands[u->operand_count - 1].label;
            if (g_hash_table_contains(label_tracking, (gconstpointer)(long)label)) {
                int label_idx = (int)(long)g_hash_table_lookup(label_tracking, (gpointer)(long)label);
                for (int i = label_idx; i < idx; ++i)
                    ctx->unexpected_branch[i] = true;
            }
        }
        int def_indices[2];
        int def_cnt = get_def_tmp_indices(u, def_indices, sizeof(def_indices)/sizeof(int));
        for (int i = 0; i < def_cnt; i++)
            set_tmp_bit(&ctx->def_mask[idx * words], def_indices[i]);
        int use_indices[16];
        int use_cnt = get_use_tmp_indices(u, use_indices, sizeof(use_indices)/sizeof(int));
        for (int i = 0; i < use_cnt; i++)
            set_tmp_bit(&ctx->use_mask[idx * words], use_indices[i]);

        u = u->next;
        idx++;
    }
    // Setup USE/DEF
    uint64_t *accum = calloc(words, sizeof(uint64_t));
    for (int i = 0; i < n; i++) {
        copy_mask(&ctx->reaching_def_exclude_self_def[i * words], accum, words);
        clear_mask(&ctx->reaching_def_exclude_self_def[i * words], &ctx->def_mask[i * words], words);
        or_mask(accum, &ctx->def_mask[i * words], words);
    }
    memset(accum, 0, (words * sizeof(uint64_t)));
    for (int i = n - 1; i >= 0; i--) {
        copy_mask(&ctx->forward_use[i * words], accum, words);
        or_mask(accum, &ctx->use_mask[i * words], words);
    }
    free(accum);
    g_hash_table_destroy(label_tracking);
}

#define TMP_SLOT_PRESERVE_OFFSET_MAX      (4096 - 32)

/*
 * NOTICE: LLVM IR should store zero into stack alloca to avoid potential
 * poison value in case unexpected branch confused the dummy reaching-def
 * analysis
 */
void expand_tmp_slot_preservation(TcgContext *ctx) {
    uint64_t *buf = calloc(ctx->words_needed, sizeof(uint64_t));
    UnifiedInstr *u = ctx->instr_head;
    int uidx = 0;
    while (u) {
        if (u->opc != call) {
            u = u->next;
            uidx += 1;
            continue;
        }
        UnifiedInstr *c = u;
        u = u->next;

        uint64_t accumulated = 0;
        for (int i = 0; i < ctx->words_needed; ++i) {
            buf[i] = ctx->reaching_def_exclude_self_def[uidx * ctx->words_needed + i] & (ctx->unexpected_branch[uidx] ? -1UL : ctx->forward_use[uidx * ctx->words_needed + i]);
            accumulated |= buf[i];
        }
        // Instructions to backup slot contents
        if (accumulated) {
            uint64_t tmp_slot_preserve_offset = 16;
            int tmp1 = get_next_tmp_idx(ctx);
            int tmp2 = get_next_tmp_idx(ctx);
            int tmp3 = get_next_tmp_idx(ctx);
            // - GET pointer to the shadow stack ptr
            // mov_i64 tmp_N1,env
            // add_i64 tmp_N1,tmp_N1,-8UL
            EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c, mov_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp1), ENV_OP(0));
            EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c, add_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp1), SLOT_OP(SUB_SLOT_TMP, tmp1), IMM_OP(-8ULL));
            // - LOAD the shadow stack ptr
            // qemu_ld_i64 tmp_N2,tmp_N1,attr:NONATOMIC,ALIGN_8,SRC8B
            EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c, qemu_ld_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp2), SLOT_OP(SUB_SLOT_TMP, tmp1), ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

            for (int i = 0; i < ctx->next_tmp_idx; ++i) {
                if (test_tmp_bit(buf, i)) {
                    // - CALCULATE negative offset into the shadow stack
                    // sub_i64 tmp_N3, tmp_N2, $tmp_slot_preserve_offset
                    assert(tmp_slot_preserve_offset < TMP_SLOT_PRESERVE_OFFSET_MAX);
                    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c, sub_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp3), SLOT_OP(SUB_SLOT_TMP, tmp2), IMM_OP(tmp_slot_preserve_offset));
                    tmp_slot_preserve_offset += 16;
                    assert(g_hash_table_contains(ctx->stack_type_map, (gconstpointer)(long)i));
                    LLVMType current_ty = (LLVMType)(long)g_hash_table_lookup(ctx->stack_type_map, (gpointer)(long)i);
                    SrcSizeType src_sz = INVALID_SRCSIZE;
                    switch (current_ty) {
                    case LLVMInt64:
                    case LLVMVector8xi8:
                    case LLVMVector4xi16:
                    case LLVMVector2xi32:
                    case LLVMVector1xi64:
                        src_sz += (SRC8B - SRC4B);
                    case LLVMInt32:
                        src_sz += (SRC4B - SRC2B);
                    case LLVMInt16:
                        src_sz += (SRC2B - SRC1B);
                    case LLVMInt8:
                        src_sz += (SRC1B - INVALID_SRCSIZE);
                        // - BACKUP tmp slot
                        // qemu_st_i64 i,tmp_N3,attr:NONATOMIC,ALIGN_16,$src_sz
                        EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c, qemu_st_i64, 0, 0,
                            SLOT_OP(SUB_SLOT_TMP, i),
                            SLOT_OP(SUB_SLOT_TMP, tmp3),
                            ATTR_STORAGE_OP(NONATOMIC, ALIGN_16, src_sz));
                        break;
                    case LLVMVector16xi8:
                    case LLVMVector8xi16:
                    case LLVMVector4xi32:
                    case LLVMVector2xi64:
                    case LLVMInt128:
                        // - BACKUP tmp slot
                        // st_vec v128,e8,tmp_i,tmp_N3
                        EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c, st_vec, 128, 8,
                            SLOT_OP(SUB_SLOT_TMP, i),
                            SLOT_OP(SUB_SLOT_TMP, tmp3));
                        break;
                    default:
                        assert(0);
                    }
                }
            }
        }
        // Instructions to restore slot contents
        if (accumulated) {
            UnifiedInstr *c_next = c->next;
            uint64_t tmp_slot_preserve_offset = 16;
            int tmp1 = get_next_tmp_idx(ctx);
            int tmp2 = get_next_tmp_idx(ctx);
            int tmp3 = get_next_tmp_idx(ctx);
            // - GET pointer to the shadow stack ptr
            // mov_i64 tmp_N1,env
            // add_i64 tmp_N1,tmp_N1,-8UL
            EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c_next, mov_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp1), ENV_OP(0));
            EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c_next, add_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp1), SLOT_OP(SUB_SLOT_TMP, tmp1), IMM_OP(-8ULL));
            // - LOAD the shadow stack ptr
            // qemu_ld_i64 tmp_N2,tmp_N1,attr:NONATOMIC,ALIGN_8,SRC8B
            EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c_next, qemu_ld_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp2), SLOT_OP(SUB_SLOT_TMP, tmp1), ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

            for (int i = 0; i < ctx->next_tmp_idx; ++i) {
                if (test_tmp_bit(buf, i)) {
                    // - CALCULATE negative offset into the shadow stack
                    // sub_i64 tmp_N3, tmp_N2, $tmp_slot_preserve_offset
                    assert(tmp_slot_preserve_offset < TMP_SLOT_PRESERVE_OFFSET_MAX);
                    EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c_next, sub_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp3), SLOT_OP(SUB_SLOT_TMP, tmp2), IMM_OP(tmp_slot_preserve_offset));
                    tmp_slot_preserve_offset += 16;
                    assert(g_hash_table_contains(ctx->stack_type_map, (gconstpointer)(long)i));
                    LLVMType current_ty = (LLVMType)(long)g_hash_table_lookup(ctx->stack_type_map, (gpointer)(long)i);
                    SrcSizeType src_sz = INVALID_SRCSIZE;
                    switch (current_ty) {
                    case LLVMInt64:
                    case LLVMVector8xi8:
                    case LLVMVector4xi16:
                    case LLVMVector2xi32:
                    case LLVMVector1xi64:
                        src_sz += (SRC8B - SRC4B);
                    case LLVMInt32:
                        src_sz += (SRC4B - SRC2B);
                    case LLVMInt16:
                        src_sz += (SRC2B - SRC1B);
                    case LLVMInt8:
                        src_sz += (SRC1B - INVALID_SRCSIZE);
                        // - RESTORE tmp slot
                        // qemu_ld_i64 i,tmp_N3,attr:NONATOMIC,ALIGN_16,$src_sz
                        EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c_next, qemu_ld_i64, 0, 0,
                            SLOT_OP(SUB_SLOT_TMP, i),
                            SLOT_OP(SUB_SLOT_TMP, tmp3),
                            ATTR_STORAGE_OP(NONATOMIC, ALIGN_16, src_sz));
                        break;
                    case LLVMVector16xi8:
                    case LLVMVector8xi16:
                    case LLVMVector4xi32:
                    case LLVMVector2xi64:
                    case LLVMInt128:
                        // - RESTORE tmp slot
                        // ld_vec v128,e8,tmp_i,tmp_N3
                        EMIT_INSTR_BEFORE(ctx, &ctx->instr_head, &ctx->instr_tail, c_next, ld_vec, 128, 8,
                            SLOT_OP(SUB_SLOT_TMP, i),
                            SLOT_OP(SUB_SLOT_TMP, tmp3));
                        break;
                    default:
                        assert(0);
                    }
                }
            }
        }
        uidx += 1;
    }
    free(buf);
}

/*
 * -----------------------------------------------------------------
 *  Label tracker: dynamic array (replaces GHashTable)
 * -----------------------------------------------------------------
 *
 * Each entry tracks a label number and its "seen" status (0 or 1).
 * The array is kept sorted by label so that lookup/insert are O(log n)
 * and iteration is trivially ordered.
 */
typedef struct {
    uint16_t label;
    uint8_t  value;
} LabelTrackerEntry;

typedef struct {
    LabelTrackerEntry *data;
    int len;
    int cap;
} LabelTracker;

static void label_tracker_init(LabelTracker *lt) {
    lt->data = NULL;
    lt->len = 0;
    lt->cap = 0;
}

static void label_tracker_free(LabelTracker *lt) {
    free(lt->data);
    lt->data = NULL;
    lt->len = 0;
    lt->cap = 0;
}

static int label_tracker_find(const LabelTracker *lt, uint16_t label) {
    for (int i = 0; i < lt->len; i++) {
        if (lt->data[i].label == label)
            return i;
    }
    return -1;
}

static bool label_tracker_contains(const LabelTracker *lt, uint16_t label) {
    return label_tracker_find(lt, label) >= 0;
}

static void label_tracker_insert(LabelTracker *lt, uint16_t label, uint8_t value) {
    assert(!label_tracker_contains(lt, label));
    if (lt->len >= lt->cap) {
        lt->cap = lt->cap ? lt->cap * 2 : 8;
        lt->data = realloc(lt->data, lt->cap * sizeof(LabelTrackerEntry));
    }
    lt->data[lt->len].label = label;
    lt->data[lt->len].value = value;
    lt->len++;
}

/* Find the first entry whose value is 0. Returns -1 if none. */
static int label_tracker_find_zero(const LabelTracker *lt) {
    for (int i = 0; i < lt->len; i++) {
        if (lt->data[i].value == 0)
            return i;
    }
    return -1;
}

#define IS_YMM_HELPER(h)            (h > ABOVE_HELPER_IS_YMM)
#define HELPER_TEMPLATE_ENABLED(h)  (h > ABOVE_HELPER_ENABLED_TEMPLATE)
#define HELPER_TEMPLATE_NOINLINE(h) (NOINLINE_BEGIN < h && h < NOINLINE_END)

static inline bool is_instr_end_of_control_flow(const UnifiedInstr *u) {
    if (u->opc == tail_call_qemuaot)
        return true;
    if (u->opc == call) {
        assert(u->operands[0].kind == OP_SYMBOL);
        HelperType h = u->operands[0].symbol;
        if (HELPER_TEMPLATE_NOINLINE(h))
            return true;
        if (HELPER_TEMPLATE_ENABLED(h) && !helper_require_exception_path[h])
            return false;
        else
            return true;
    }
    return false;
}

/*
 * Locate the instruction of the first still-unprocessed label (value == 0).
 * Returns the corresponding set_label instruction from the original list,
 * or NULL if every label has been processed.
 */
static const UnifiedInstr *get_next_missing_label_instr(TcgContext *ctx,
                                                        const LabelTracker *lt) {
    int idx = label_tracker_find_zero(lt);
    if (idx < 0)
        return NULL;
    uint16_t label = lt->data[idx].label;
    for (const UnifiedInstr *u = ctx->instr_head; u; u = u->next) {
        if (u->opc == set_label) {
            assert(u->operands[0].kind == OP_LABEL);
            if (u->operands[0].label == label)
                return u;
        }
    }
    assert(0);
    return NULL;
}

static void emulate_control_flow(TcgContext *ctx,
                         const UnifiedInstr *cur,
                         FuncInstrList *list,
                         LabelTracker *lt);

static void collect_func_instr_list_for_llvm(TcgContext *ctx,
                                             const UnifiedInstr *next);

static void emulate_control_flow(TcgContext *ctx,
                         const UnifiedInstr *cur,
                         FuncInstrList *list,
                         LabelTracker *lt) {
    while (cur) {
        /*
         * For set_label, it is possible that the label has been emitted
         * due to fall-through path. In that case, we simply branch to it
         */
        if (cur->opc == set_label) {
            assert(cur->operands[cur->operand_count - 1].kind == OP_LABEL);
            uint16_t label = cur->operands[cur->operand_count - 1].label;
            if (label_tracker_contains(lt, label)) {
                int idx = label_tracker_find(lt, label);
                if (lt->data[idx].value == 1) {
                    // Label already exists, add br label
                    UnifiedInstr *u = clone_instr(cur);
                    u->opc = br;
                    func_list_append(list, u);
                    break;
                }
            }
            // If the last instruction is not end of control flow, add br
            if (list->tail && !is_instr_end_of_control_flow(list->tail)) {
                UnifiedInstr *u = clone_instr(cur);
                u->opc = br;
                func_list_append(list, u);
            }
        }
        UnifiedInstr *copy = clone_instr(cur);
        func_list_append(list, copy);
        if (is_instr_end_of_control_flow(cur)) {
            const UnifiedInstr *label_u;
            while ((label_u = get_next_missing_label_instr(ctx, lt))) {
                emulate_control_flow(ctx, label_u, list, lt);
            }
            if (cur->opc == call && !helper_runtime_does_not_return[cur->operands[0].symbol]) {
                collect_func_instr_list_for_llvm(ctx, cur->next);
            }
            return;
        } else if (cur->opc == br || cur->opc == brcond_i32 || cur->opc == brcond_i64) {
            assert(cur->operands[cur->operand_count - 1].kind == OP_LABEL);
            uint16_t label = cur->operands[cur->operand_count - 1].label;
            if (!label_tracker_contains(lt, label)) {
                label_tracker_insert(lt, label, 0);
            }
        } else if (cur->opc == set_label) {
            assert(cur->operands[cur->operand_count - 1].kind == OP_LABEL);
            uint16_t label = cur->operands[cur->operand_count - 1].label;
            if (label_tracker_contains(lt, label)) {
                int idx = label_tracker_find(lt, label);
                assert(lt->data[idx].value == 0);
                lt->data[idx].value = 1;
            } else {
                label_tracker_insert(lt, label, 1);
            }
        }
        cur = cur->next;
    }
    return;
}

/* Recursively collect LLVM functions */
static void collect_func_instr_list_for_llvm(TcgContext *ctx,
                                             const UnifiedInstr *next) {
    if (!next)
        return;

    for (int i = 0; i < ctx->llvm_func_set.num_lists; ++i) {
        if (ctx->llvm_func_set.lists[i].head_uidx == next->uidx) {
            return;
        }
    }

    FuncInstrList result;
    func_list_init(&result);
    int func_idx = get_next_func_list_idx(ctx);
    const UnifiedInstr *cur = next;
    // Early info for dedup
    ctx->llvm_func_set.lists[func_idx].head_uidx = cur->uidx;
    LabelTracker lt;
    label_tracker_init(&lt);
    emulate_control_flow(ctx, cur, &result, &lt);
    label_tracker_free(&lt);
    // LLVM function is setup lazily
    ctx->llvm_func_set.lists[func_idx] = result;
}

void expand_llvm_func(TcgContext *ctx) {
    collect_func_instr_list_for_llvm(ctx, ctx->instr_head);
}

int lookup_next_func_idx(TcgContext *ctx,
                         const UnifiedInstr *u) {
    // Lookup the index of the next instruction from instr_head list
    uint32_t next_idx = -1;
    for (const UnifiedInstr *ui = ctx->instr_head; ui; ui = ui->next) {
        if (ui->uidx == u->uidx && ui->next) {
            next_idx = ui->next->uidx;
            break;
        }
    }
    assert(next_idx != -1);
    for (int i = 0; i < ctx->llvm_func_set.num_lists; ++i) {
        if (ctx->llvm_func_set.lists[i].head->uidx == next_idx)
            return i;
    }
    assert(0);
    return -1;
}

int get_vector_spill_info(const UnifiedInstr *u,
                          Operand *env_vecs,
                          Operand *spare_vecs,
                          int cnt) {
    assert(u->opc == call && u->operands[0].kind == OP_SYMBOL);
    bool is_ymm = IS_YMM_HELPER(u->operands[0].symbol);
    int rc = 0;
    uint32_t vec_valid = 0;
    // Collect all vectors being used in current instruction
    for (int i = 0; i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_VEC) {
            vec_valid |= (1 << u->operands[i].vec.idx);
        }
    }
    // Allocate spare vector for ENV pointers
    for (int i = 0; i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_ENV) {
            VecInfo vinfo = lookup_vec_map(u->operands[i].env.offset);
            if (vinfo.idx != NON_XMM) {
                bool dup = false;
                for (int j = 0; j < rc; ++j) {
                    if (env_vecs[j].env.offset == u->operands[i].env.offset) {
                        dup = true;
                        break;
                    }
                }
                if (dup)
                    continue;

                // pcmpistrm implicitly writes to xmm0, skip the first pair of vectors
                int spare_idx = 2;
                for (; spare_idx < (cfg_xmm_count * 2); spare_idx += (is_ymm ? 1 : 2)) {
                    if ((vec_valid & (1 << spare_idx)) == 0) {
                        break;
                    }
                }
                assert(spare_idx < (cfg_xmm_count * 2));
                vec_valid |= (1 << spare_idx);

                // Do update mapping info
                env_vecs[rc] = u->operands[i];
                spare_vecs[rc].kind = OP_VEC;
                spare_vecs[rc].vec.idx = spare_idx;
                spare_vecs[rc].vec.offset = 0;
                spare_vecs[rc].vec.stack_type = LLVMVector2xi64;
                rc += 1;
                assert(rc <= cnt);
            }
        }
    }
    return rc;
}

void add_spill_load_vector(TcgContext *ctx,
                              UnifiedInstr **head_p,
                              UnifiedInstr **tail_p,
                              UnifiedInstr *u,
                              const Operand *env_vecs,
                              const Operand *spare_vecs,
                              int cnt,
                              bool before_call) {
    for (int i = 0; i < cnt; ++i) {
        int tmp1 = get_next_tmp_idx(ctx);
        // - SPILL
        // mov_i64 tmp_N1,env
        // (bc)add_i64 tmp_N1,tmp_N1,get_vec_offset()
        // (ac)add_i64 tmp_N1,tmp_N1,env_vecs[i]
        // st_vec v128,e8,spare_vecs[i],tmp_N1
        EMIT_INSTR_BEFORE(ctx, head_p, tail_p, u, mov_i64, 0, 0,
            SLOT_OP(SUB_SLOT_TMP, tmp1),
            ENV_OP(0));
        if (before_call) {
            EMIT_INSTR_BEFORE(ctx, head_p, tail_p, u, add_i64, 0, 0,
                SLOT_OP(SUB_SLOT_TMP, tmp1),
                SLOT_OP(SUB_SLOT_TMP, tmp1),
                IMM_OP(get_vec_offset(spare_vecs[i].vec.idx)));
        } else {
            EMIT_INSTR_BEFORE(ctx, head_p, tail_p, u, add_i64, 0, 0,
                SLOT_OP(SUB_SLOT_TMP, tmp1),
                SLOT_OP(SUB_SLOT_TMP, tmp1),
                IMM_OP(env_vecs[i].env.offset));
        }
        EMIT_INSTR_BEFORE(ctx, head_p, tail_p, u, st_vec, 128, 8,
            VEC_OP(spare_vecs[i].vec.idx, spare_vecs[i].vec.offset),
            SLOT_OP(SUB_SLOT_TMP, tmp1));
        // - LOAD
        // mov_i64 tmp_N1,env
        // (bc)add_i64 tmp_N1,tmp_N1,env_vecs[i]
        // (ac)add_i64 tmp_N1,tmp_N1,get_vec_offset()
        // ld_vec v128,e8,spare_vecs[i],tmp_N1
        EMIT_INSTR_BEFORE(ctx, head_p, tail_p, u, mov_i64, 0, 0,
            SLOT_OP(SUB_SLOT_TMP, tmp1),
            ENV_OP(0));
        if (before_call) {
            EMIT_INSTR_BEFORE(ctx, head_p, tail_p, u, add_i64, 0, 0,
                SLOT_OP(SUB_SLOT_TMP, tmp1),
                SLOT_OP(SUB_SLOT_TMP, tmp1),
                IMM_OP(env_vecs[i].env.offset));
        } else {
            EMIT_INSTR_BEFORE(ctx, head_p, tail_p, u, add_i64, 0, 0,
                SLOT_OP(SUB_SLOT_TMP, tmp1),
                SLOT_OP(SUB_SLOT_TMP, tmp1),
                IMM_OP(get_vec_offset(spare_vecs[i].vec.idx)));
        }
        EMIT_INSTR_BEFORE(ctx, head_p, tail_p, u, ld_vec, 128, 8,
            VEC_OP(spare_vecs[i].vec.idx, spare_vecs[i].vec.offset),
            SLOT_OP(SUB_SLOT_TMP, tmp1));
    }
}

void expand_call_template_wo_exception(TcgContext *ctx) {
    for (int fi = 0; fi < ctx->llvm_func_set.num_lists; ++fi) {
        for (UnifiedInstr *u = ctx->llvm_func_set.lists[fi].head; u; u = u->next) {
            if (u->opc != call)
                continue;
            assert(u->operands[0].kind == OP_SYMBOL);
            if (!HELPER_TEMPLATE_ENABLED(u->operands[0].symbol))
                continue;
            if (helper_require_exception_path[u->operands[0].symbol])
                continue;

            // Need double size for ymm
            Operand env_vecs[MAX_INLINE_VEC_ARG_CNT * 2] = {0};
            Operand spare_vecs[MAX_INLINE_VEC_ARG_CNT * 2] = {0};
            int spill_cnt = get_vector_spill_info(u, env_vecs, spare_vecs, (MAX_INLINE_VEC_ARG_CNT * 2));

            /*
             * Update call opc and remove head ENV
             * Inlined helper functions do not need the initial ENV argument,
             * drop it saves one argument slot
             */
            int first_input_idx = get_first_input_idx_on_call(u);
            u->opc = call_qemuaot;
            if (u->operands[first_input_idx].kind == OP_ENV && u->operands[first_input_idx].env.offset == 0) {
                memcpy(&u->operands[first_input_idx], &u->operands[first_input_idx + 1],
                       ((u->operand_count - (first_input_idx + 1)) * sizeof(Operand)));
                u->operand_count -= 1;
            }

            // Check if require vector register spill/reload
            if (!spill_cnt)
                continue;

            add_spill_load_vector(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail),
                                     u, env_vecs, spare_vecs, spill_cnt, true /*before call*/);

            for (int i = 0; i < u->operand_count; ++i) {
                if (u->operands[i].kind == OP_ENV) {
                    for (int j = 0; j < spill_cnt; ++j) {
                        if (u->operands[i].env.offset == env_vecs[j].env.offset) {
                            u->operands[i] = spare_vecs[j];
                            break;
                        }
                    }
                }
            }

            assert(u->next);
            add_spill_load_vector(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail),
                                     u->next, env_vecs, spare_vecs, spill_cnt, false /*after call*/);
        }
    }
}

int create_trampoline_for_inline_exception(TcgContext *ctx,
                                           const UnifiedInstr *u,
                                           const Operand *env_vecs,
                                           const Operand *spare_vecs,
                                           int cnt) {
    assert(u->opc == call && u->operands[0].kind == OP_SYMBOL);
    FuncInstrList result;
    func_list_init(&result);
    // Setup func name
    sprintf(&result.trampoline_name[0], "trampoline_exception_%s", helper_str[u->operands[0].symbol]);
    for (int i = 0; i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_VEC) {
            char vec_name[7] = {0};
            sprintf(&vec_name[0], "_V%02x", u->operands[i].vec.idx & 0xff);
            strcat(&result.trampoline_name[0], &vec_name[0]);
        } else if (u->operands[i].kind == OP_ENV) {
            int idx = 0;
            for (; idx < cnt; ++idx) {
                if (env_vecs[idx].env.offset == u->operands[i].env.offset) {
                    break;
                }
            }
            if (idx < cnt) {
                char vec_name[9] = {0};
                sprintf(&vec_name[0], "_S%02x", spare_vecs[idx].vec.idx & 0xff);
                strcat(&result.trampoline_name[0], &vec_name[0]);
            }
        }
    }
    int func_idx = get_next_func_list_idx(ctx);

    // Store all GP registers to ENV
    int tmp1 = get_next_tmp_idx(ctx);
    // - GET env pointer
    // mov_i64 tmp_N1,env
    EMIT_INSTR_APPEND_LIST(ctx, &result, mov_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        ENV_OP(0));
    for (int r = rax; r < XREG_MAX; ++r) {
        int tmp2 = get_next_tmp_idx(ctx);
        uint64_t off = env_regs_offset[r];
        LLVMType ty = env_regs_type[r];
        // - CALCULATE offset to CPUArchState field
        // add_i64 tmp_N2,tmp_N1,offset
        EMIT_INSTR_APPEND_LIST(ctx, &result, add_i64, 0, 0,
            SLOT_OP(SUB_SLOT_TMP, tmp2),
            SLOT_OP(SUB_SLOT_TMP, tmp1),
            IMM_OP(off));
        if (ty == LLVMInt64) {
            // qemu_st_i64 r,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
            EMIT_INSTR_APPEND_LIST(ctx, &result, qemu_st_i64, 0, 0,
                SLOT_OP_EXTRA(SUB_SLOT_XREG, r, ty, ty),
                SLOT_OP(SUB_SLOT_TMP, tmp2),
                ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));
        } else {
            // qemu_st_i32 r,tmp_N2,attr:NONATOMIC,ALIGN_4,SRC4B
            EMIT_INSTR_APPEND_LIST(ctx, &result, qemu_st_i32, 0, 0,
                SLOT_OP_EXTRA(SUB_SLOT_XREG, r, ty, ty),
                SLOT_OP(SUB_SLOT_TMP, tmp2),
                ATTR_STORAGE_OP(NONATOMIC, ALIGN_4, SRC4B));
        }
    }

    // Add SPILL/RELOAD to revert vector reuse at the beginning
    add_spill_load_vector(ctx, &result.head, &result.tail,
                          result.head, env_vecs, spare_vecs, cnt, false /*after call*/);

    // Store all Vector registers to ENV
    for (int i = 0; i < (cfg_xmm_count * 2); ++i) {
        int tmp2 = get_next_tmp_idx(ctx);
        uint64_t off = get_vec_offset(i);
        // - CALCULATE offset to CPUArchState field
        // add_i64 tmp_N2,tmp_N1,offset
        EMIT_INSTR_APPEND_LIST(ctx, &result, add_i64, 0, 0,
            SLOT_OP(SUB_SLOT_TMP, tmp2),
            SLOT_OP(SUB_SLOT_TMP, tmp1),
            IMM_OP(off));
        EMIT_INSTR_APPEND_LIST(ctx, &result, st_vec, 128, 8,
            VEC_OP(i, 0),
            SLOT_OP(SUB_SLOT_TMP, tmp2));
    }

    // Setup native call arguments
    UnifiedInstr *nc = clone_instr(u);
    nc->opc = call_default;
    // Fold vector operands for YMM
    int fold_idx = 0;
    for (int i = 0; i < nc->operand_count; ++i) {
        if (nc->operands[i].kind == OP_VEC && (nc->operands[i].vec.idx % 2 == 1))
            continue;
        if (nc->operands[i].kind == OP_ENV) {
            VecInfo vinfo = lookup_vec_map(u->operands[i].env.offset);
            if (vinfo.idx % 2 == 1)
                continue;
        }
        nc->operands[fold_idx++] = nc->operands[i];
    }
    nc->operand_count = fold_idx;
    for (int i = 0; i < nc->operand_count; ++i) {
        if (nc->operands[i].kind == OP_VEC) {
            int tmp2 = get_next_tmp_idx(ctx);
            uint64_t off = get_vec_offset(nc->operands[i].vec.idx);
            // - CALCULATE offset to CPUArchState xmm
            // add_i64 tmp_N2,tmp_N1,offset
            EMIT_INSTR_APPEND_LIST(ctx, &result, add_i64, 0, 0,
                SLOT_OP(SUB_SLOT_TMP, tmp2),
                SLOT_OP(SUB_SLOT_TMP, tmp1),
                IMM_OP(off));
            nc->operands[i].kind = OP_SLOT;
            nc->operands[i].slot.type = SUB_SLOT_TMP;
            nc->operands[i].slot.idx = tmp2;
            nc->operands[i].slot.op_type = LLVMInt64;
        }
    }

    // Emit call fixed native helper
    func_list_append(&result, nc);

    // Load all GP registers from ENV
    for (int r = rax; r < XREG_MAX; ++r) {
        int tmp2 = get_next_tmp_idx(ctx);
        uint64_t off = env_regs_offset[r];
        LLVMType ty = env_regs_type[r];
        // - CALCULATE offset to CPUArchState field
        // add_i64 tmp_N2,tmp_N1,offset
        EMIT_INSTR_APPEND_LIST(ctx, &result, add_i64, 0, 0,
            SLOT_OP(SUB_SLOT_TMP, tmp2),
            SLOT_OP(SUB_SLOT_TMP, tmp1),
            IMM_OP(off));
        if (ty == LLVMInt64) {
            // qemu_st_i64 r,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
            EMIT_INSTR_APPEND_LIST(ctx, &result, qemu_ld_i64, 0, 0,
                SLOT_OP_EXTRA(SUB_SLOT_XREG, r, ty, ty),
                SLOT_OP(SUB_SLOT_TMP, tmp2),
                ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));
        } else {
            // qemu_st_i32 r,tmp_N2,attr:NONATOMIC,ALIGN_4,SRC4B
            EMIT_INSTR_APPEND_LIST(ctx, &result, qemu_ld_i32, 0, 0,
                SLOT_OP_EXTRA(SUB_SLOT_XREG, r, ty, ty),
                SLOT_OP(SUB_SLOT_TMP, tmp2),
                ATTR_STORAGE_OP(NONATOMIC, ALIGN_4, SRC4B));
        }
    }

    // Load all Vector registers from ENV
    for (int i = 0; i < (cfg_xmm_count * 2); ++i) {
        int tmp2 = get_next_tmp_idx(ctx);
        uint64_t off = get_vec_offset(i);
        // - CALCULATE offset to CPUArchState field
        // add_i64 tmp_N2,tmp_N1,offset
        EMIT_INSTR_APPEND_LIST(ctx, &result, add_i64, 0, 0,
            SLOT_OP(SUB_SLOT_TMP, tmp2),
            SLOT_OP(SUB_SLOT_TMP, tmp1),
            IMM_OP(off));
        EMIT_INSTR_APPEND_LIST(ctx, &result, ld_vec, 128, 8,
            VEC_OP(i, 0),
            SLOT_OP(SUB_SLOT_TMP, tmp2));
    }

    // Get the next call from argument (the last argument implicitly is the next call target), and do tail_call_qemuaot
    if (u->operands[TCG_CALL_OUT_FLAG_IDX].imm) {
        // - tail_call_qemuaot next,helper_out
        // tail_call_qemuaot OP_LASTARG,helper_out
        EMIT_INSTR_APPEND_LIST(ctx, &result, tail_call_qemuaot, 0, 0,
            LASTARG_OP(),
            IMM_OP(0),
            IMM_OP(0),
            SLOT_OP_EXTRA(u->operands[TCG_CALL_PREFIX_COUNT].slot.type, u->operands[TCG_CALL_PREFIX_COUNT].slot.idx, u->operands[TCG_CALL_PREFIX_COUNT].slot.op_type, u->operands[TCG_CALL_PREFIX_COUNT].slot.stack_type));
    } else {
        // - tail_call_qemuaot next
        // tail_call_qemuaot OP_LASTARG
        EMIT_INSTR_APPEND_LIST(ctx, &result, tail_call_qemuaot, 0, 0,
            LASTARG_OP(),
            IMM_OP(0),
            IMM_OP(0));
    }

    // Add SPILL/LOAD to apply vector reuse before the next step
    add_spill_load_vector(ctx, &result.head, &result.tail,
                          result.tail, env_vecs, spare_vecs, cnt, true /*before call*/);

    ctx->llvm_func_set.lists[func_idx] = result;
    return func_idx;
}

/*
 * Create trampoline to handle inline exception path
 * Insert vector register spill logic in case vector reuse happens before original call
 * Insert vector register reload logic in case reuse at the beginning of the next
 */
void expand_call_template_wi_exception(TcgContext *ctx) {
    for (int fi = 0; fi < ctx->llvm_func_set.num_lists; ++fi) {
        for (UnifiedInstr *u = ctx->llvm_func_set.lists[fi].head; u; u = u->next) {
            if (u->opc != call)
                continue;
            assert(u->operands[0].kind == OP_SYMBOL);
            if (!HELPER_TEMPLATE_ENABLED(u->operands[0].symbol))
                continue;
            if (!helper_require_exception_path[u->operands[0].symbol])
                continue;

            // Need double size for ymm
            Operand env_vecs[MAX_INLINE_VEC_ARG_CNT * 2] = {0};
            Operand spare_vecs[MAX_INLINE_VEC_ARG_CNT * 2] = {0};
            int spill_cnt = get_vector_spill_info(u, env_vecs, spare_vecs, (MAX_INLINE_VEC_ARG_CNT * 2));

            // Create trampoline
            int tfidx = create_trampoline_for_inline_exception(ctx, u, &env_vecs[0], &spare_vecs[0], spill_cnt);
            int nfidx = lookup_next_func_idx(ctx, u);

            // - GET the address of trampoline
            // func_addr tmp_t,hex_offset,tfidx
            int tmp_t = get_next_tmp_idx(ctx);
            EMIT_INSTR_BEFORE(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, func_addr, 0, 0,
                SLOT_OP(SUB_SLOT_TMP, tmp_t),
                IMM_OP(ctx->hex_offset),
                IMM_OP(tfidx));

            // - GET the address of next
            // func_addr tmp_n,hex_offset,nfidx
            int tmp_n = get_next_tmp_idx(ctx);
            EMIT_INSTR_BEFORE(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, func_addr, 0, 0,
                SLOT_OP(SUB_SLOT_TMP, tmp_n),
                IMM_OP(ctx->hex_offset),
                IMM_OP(nfidx));

            // - GET the address of helper_template
            // func_addr tmp_entry,helper,...(OP_VEC)
            int tmp_entry = get_next_tmp_idx(ctx);
            UnifiedInstr *entry = clone_instr(u);
            entry->opc = func_addr;
            Operand op_entry;
            op_entry.kind = OP_SLOT;
            op_entry.slot.type = SUB_SLOT_TMP;
            op_entry.slot.idx = tmp_entry;
            op_entry.slot.op_type = LLVMInt64;
            entry->operands[0] = op_entry;
            entry->operands[1] = u->operands[0];
            entry->operand_count = 2;
            for (int i = 0; i < u->operand_count; ++i) {
                if (u->operands[i].kind == OP_ENV) {
                    for (int j = 0; j < spill_cnt; ++j) {
                        if (u->operands[i].env.offset == env_vecs[j].env.offset) {
                            entry->operands[entry->operand_count++] = spare_vecs[j];
                            break;
                        }
                    }
                } else if (u->operands[i].kind == OP_VEC) {
                    entry->operands[entry->operand_count++] = u->operands[i];
                }
            }
            update_slot_types(ctx, entry);
            instr_list_insert_before(&(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, entry);

            size_t sz = sizeof(UnifiedInstr) + (u->operand_count + 2) * sizeof(Operand);
            UnifiedInstr *uu = calloc(1, sz);
            uu->opc = tail_call_qemuaot;
            memcpy(&uu->operands[0], &u->operands[0], (u->operand_count * sizeof(Operand)));
            uu->operand_count = u->operand_count;
            uu->operands[0] = op_entry;
            Operand tf;
            tf.kind = OP_SLOT;
            tf.slot.type = SUB_SLOT_TMP;
            tf.slot.idx = tmp_t;
            uu->operands[uu->operand_count++] = tf;
            Operand nf;
            nf.kind = OP_SLOT;
            nf.slot.type = SUB_SLOT_TMP;
            nf.slot.idx = tmp_n;
            uu->operands[uu->operand_count++] = nf;

            // Move the output from the call to the beginning of the next step
            assert(uu->operands[TCG_CALL_OUT_FLAG_IDX].kind == OP_IMM);
            if (uu->operands[TCG_CALL_OUT_FLAG_IDX].imm) {
                int nfidx = lookup_next_func_idx(ctx, u);
                EMIT_INSTR_BEFORE(ctx, &(ctx->llvm_func_set.lists[nfidx].head), &(ctx->llvm_func_set.lists[nfidx].tail), ctx->llvm_func_set.lists[nfidx].head, mov_i64, 0, 0,
                    SLOT_OP_EXTRA(uu->operands[TCG_CALL_PREFIX_COUNT].slot.type, uu->operands[TCG_CALL_PREFIX_COUNT].slot.idx, uu->operands[TCG_CALL_PREFIX_COUNT].slot.op_type, uu->operands[TCG_CALL_PREFIX_COUNT].slot.stack_type),
                    LASTARG_OP());
                memcpy(&uu->operands[TCG_CALL_PREFIX_COUNT], &uu->operands[TCG_CALL_PREFIX_COUNT + 1],
                       (uu->operand_count - TCG_CALL_PREFIX_COUNT - 1) * sizeof(Operand));
                uu->operands[TCG_CALL_OUT_FLAG_IDX].imm = 0;
                uu->operand_count -= 1;
            }

            instr_list_insert_before(&(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, uu);
            instr_list_remove_and_free(&(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u);
            u = uu;

            /*
             * Remove head ENV
             * Inlined helper functions do not need the initial ENV argument,
             * drop it saves one argument slot
             */
            int first_input_idx = get_first_input_idx_on_call(u);
            if (u->operands[first_input_idx].kind == OP_ENV && u->operands[first_input_idx].env.offset == 0) {
                memcpy(&u->operands[first_input_idx], &u->operands[first_input_idx + 1],
                       ((u->operand_count - (first_input_idx + 1)) * sizeof(Operand)));
                u->operand_count -= 1;
            }

            // Check if require vector register spill/reload
            if (!spill_cnt)
                continue;

            add_spill_load_vector(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail),
                                     u, env_vecs, spare_vecs, spill_cnt, true /*before call*/);

            for (int i = 0; i < u->operand_count; ++i) {
                if (u->operands[i].kind == OP_ENV) {
                    for (int j = 0; j < spill_cnt; ++j) {
                        if (u->operands[i].env.offset == env_vecs[j].env.offset) {
                            u->operands[i] = spare_vecs[j];
                            break;
                        }
                    }
                }
            }

            // Add SPILL/RELOAD to the beginning of the next call
            UnifiedInstr *next_u = ctx->llvm_func_set.lists[nfidx].head;
            assert(next_u);
            add_spill_load_vector(ctx, &(ctx->llvm_func_set.lists[nfidx].head), &(ctx->llvm_func_set.lists[nfidx].tail),
                                     next_u, env_vecs, spare_vecs, spill_cnt, false /*after call*/);
        }
    }
}

int create_trampoline_for_runtime(TcgContext *ctx,
                                  const UnifiedInstr *u,
                                  bool will_return_back) {
    assert(u->opc == call && u->operands[0].kind == OP_SYMBOL);
    HelperType h = u->operands[0].symbol;
    if (h == helper_jmp_ind) {
        h = helper_jit;
    }
    FuncInstrList result;
    func_list_init(&result);
    // Setup func name
    sprintf(&result.trampoline_name[0], "trampoline_%s", helper_str[h]);
    int func_idx = get_next_func_list_idx(ctx);

    // Store all GP registers to ENV
    int tmp1 = get_next_tmp_idx(ctx);
    // - GET env pointer
    // mov_i64 tmp_N1,env
    EMIT_INSTR_APPEND_LIST(ctx, &result, mov_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        ENV_OP(0));
    for (int r = rax; r < XREG_MAX; ++r) {
        int tmp2 = get_next_tmp_idx(ctx);
        uint64_t off = env_regs_offset[r];
        LLVMType ty = env_regs_type[r];
        // - CALCULATE offset to CPUArchState field
        // add_i64 tmp_N2,tmp_N1,offset
        EMIT_INSTR_APPEND_LIST(ctx, &result, add_i64, 0, 0,
            SLOT_OP(SUB_SLOT_TMP, tmp2),
            SLOT_OP(SUB_SLOT_TMP, tmp1),
            IMM_OP(off));
        if (ty == LLVMInt64) {
            // qemu_st_i64 r,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
            EMIT_INSTR_APPEND_LIST(ctx, &result, qemu_st_i64, 0, 0,
                SLOT_OP_EXTRA(SUB_SLOT_XREG, r, ty, ty),
                SLOT_OP(SUB_SLOT_TMP, tmp2),
                ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));
        } else {
            // qemu_st_i32 r,tmp_N2,attr:NONATOMIC,ALIGN_4,SRC4B
            EMIT_INSTR_APPEND_LIST(ctx, &result, qemu_st_i32, 0, 0,
                SLOT_OP_EXTRA(SUB_SLOT_XREG, r, ty, ty),
                SLOT_OP(SUB_SLOT_TMP, tmp2),
                ATTR_STORAGE_OP(NONATOMIC, ALIGN_4, SRC4B));
        }
    }

    // Store all Vector registers to ENV
    for (int i = 0; i < (cfg_xmm_count * 2); ++i) {
        int tmp2 = get_next_tmp_idx(ctx);
        uint64_t off = get_vec_offset(i);
        // - CALCULATE offset to CPUArchState field
        // add_i64 tmp_N2,tmp_N1,offset
        EMIT_INSTR_APPEND_LIST(ctx, &result, add_i64, 0, 0,
            SLOT_OP(SUB_SLOT_TMP, tmp2),
            SLOT_OP(SUB_SLOT_TMP, tmp1),
            IMM_OP(off));
        EMIT_INSTR_APPEND_LIST(ctx, &result, st_vec, 128, 8,
            VEC_OP(i, 0),
            SLOT_OP(SUB_SLOT_TMP, tmp2));
    }

    // Setup native call arguments
    UnifiedInstr *nc = clone_instr(u);
    if (will_return_back) {
        nc->opc = call_default;
    } else {
        nc->opc = tail_call_default;
    }
    if (u->operands[0].symbol == helper_jmp_ind) {
        free(nc);
        size_t sz = sizeof(UnifiedInstr) + (u->operand_count + 1) * sizeof(Operand);
        nc = calloc(1, sz);
        nc->opc = tail_call_default;
        nc->operand_count = u->operand_count + 1;
        for (int i = 0; i < TCG_CALL_PREFIX_COUNT; ++i) {
            nc->operands[i] = u->operands[i];
        }
        nc->operands[TCG_CALL_PREFIX_COUNT].kind = OP_ENV;
        nc->operands[TCG_CALL_PREFIX_COUNT].env.offset = 0;
        nc->operands[TCG_CALL_PREFIX_COUNT + 1] = u->operands[TCG_CALL_PREFIX_COUNT];
        nc->operands[0].symbol = helper_jit;
    }
    for (int i = 0; i < nc->operand_count; ++i) {
        if (nc->operands[i].kind == OP_VEC) {
            int tmp2 = get_next_tmp_idx(ctx);
            uint64_t off = get_vec_offset(nc->operands[i].vec.idx);
            // - CALCULATE offset to CPUArchState xmm
            // add_i64 tmp_N2,tmp_N1,offset
            EMIT_INSTR_APPEND_LIST(ctx, &result, add_i64, 0, 0,
                SLOT_OP(SUB_SLOT_TMP, tmp2),
                SLOT_OP(SUB_SLOT_TMP, tmp1),
                IMM_OP(off));
            nc->operands[i].kind = OP_SLOT;
            nc->operands[i].slot.type = SUB_SLOT_TMP;
            nc->operands[i].slot.idx = tmp2;
            nc->operands[i].slot.op_type = LLVMInt64;
        }
    }

    // Emit call fixed native helper
    func_list_append(&result, nc);

    if (!will_return_back) {
        ctx->llvm_func_set.lists[func_idx] = result;
        return func_idx;
    }

    // Load all GP registers from ENV
    for (int r = rax; r < XREG_MAX; ++r) {
        int tmp2 = get_next_tmp_idx(ctx);
        uint64_t off = env_regs_offset[r];
        LLVMType ty = env_regs_type[r];
        // - CALCULATE offset to CPUArchState field
        // add_i64 tmp_N2,tmp_N1,offset
        EMIT_INSTR_APPEND_LIST(ctx, &result, add_i64, 0, 0,
            SLOT_OP(SUB_SLOT_TMP, tmp2),
            SLOT_OP(SUB_SLOT_TMP, tmp1),
            IMM_OP(off));
        if (ty == LLVMInt64) {
            // qemu_st_i64 r,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
            EMIT_INSTR_APPEND_LIST(ctx, &result, qemu_ld_i64, 0, 0,
                SLOT_OP_EXTRA(SUB_SLOT_XREG, r, ty, ty),
                SLOT_OP(SUB_SLOT_TMP, tmp2),
                ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));
        } else {
            // qemu_st_i32 r,tmp_N2,attr:NONATOMIC,ALIGN_4,SRC4B
            EMIT_INSTR_APPEND_LIST(ctx, &result, qemu_ld_i32, 0, 0,
                SLOT_OP_EXTRA(SUB_SLOT_XREG, r, ty, ty),
                SLOT_OP(SUB_SLOT_TMP, tmp2),
                ATTR_STORAGE_OP(NONATOMIC, ALIGN_4, SRC4B));
        }
    }

    // Load all Vector registers from ENV
    for (int i = 0; i < (cfg_xmm_count * 2); ++i) {
        int tmp2 = get_next_tmp_idx(ctx);
        uint64_t off = get_vec_offset(i);
        // - CALCULATE offset to CPUArchState field
        // add_i64 tmp_N2,tmp_N1,offset
        EMIT_INSTR_APPEND_LIST(ctx, &result, add_i64, 0, 0,
            SLOT_OP(SUB_SLOT_TMP, tmp2),
            SLOT_OP(SUB_SLOT_TMP, tmp1),
            IMM_OP(off));
        EMIT_INSTR_APPEND_LIST(ctx, &result, ld_vec, 128, 8,
            VEC_OP(i, 0),
            SLOT_OP(SUB_SLOT_TMP, tmp2));
    }

    // Get the next call from argument (the last argument implicitly is the next call target), and do tail_call_qemuaot
    if (u->operands[TCG_CALL_OUT_FLAG_IDX].imm) {
        // - tail_call_qemuaot next,helper_out
        // tail_call_qemuaot OP_LASTARG,helper_out
        EMIT_INSTR_APPEND_LIST(ctx, &result, tail_call_qemuaot, 0, 0,
            LASTARG_OP(),
            IMM_OP(0),
            IMM_OP(0),
            SLOT_OP_EXTRA(u->operands[TCG_CALL_PREFIX_COUNT].slot.type, u->operands[TCG_CALL_PREFIX_COUNT].slot.idx, u->operands[TCG_CALL_PREFIX_COUNT].slot.op_type, u->operands[TCG_CALL_PREFIX_COUNT].slot.stack_type));
    } else {
        // - tail_call_qemuaot next
        // tail_call_qemuaot OP_LASTARG
        EMIT_INSTR_APPEND_LIST(ctx, &result, tail_call_qemuaot, 0, 0,
            LASTARG_OP(),
            IMM_OP(0),
            IMM_OP(0));
    }

    ctx->llvm_func_set.lists[func_idx] = result;
    return func_idx;
}

void expand_call_runtime(TcgContext *ctx) {
    for (int fi = 0; fi < ctx->llvm_func_set.num_lists; ++fi) {
        for (UnifiedInstr *u = ctx->llvm_func_set.lists[fi].head; u; u = u->next) {
            if (u->opc != call)
                continue;
            assert(u->operands[0].kind == OP_SYMBOL);
            HelperType h = u->operands[0].symbol;
            if (HELPER_TEMPLATE_ENABLED(h))
                continue;

            // Create entry
            // - GET the address of trampoline
            // func_addr tmp_entry,(hex_offset,tfidx/helper_jmp_ind)
            int tmp_entry = get_next_tmp_idx(ctx);
            if (h != helper_jmp_ind) {
                EMIT_INSTR_BEFORE(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, func_addr, 0, 0,
                    SLOT_OP(SUB_SLOT_TMP, tmp_entry),
                    IMM_OP(ctx->hex_offset),
                    IMM_OP(create_trampoline_for_runtime(ctx, u, !helper_runtime_does_not_return[h])));
            } else {
                EMIT_INSTR_BEFORE(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, func_addr, 0, 0,
                    SLOT_OP(SUB_SLOT_TMP, tmp_entry),
                    SYMBOL_OP(helper_jmp_ind));
            }

            // Next step in case runtime returns/helper_jmp_ind
            int tmp_n = get_next_tmp_idx(ctx);
            if (!helper_runtime_does_not_return[h]) {
                // - GET the address of next
                // func_addr tmp_n,hex_offset,nfidx
                EMIT_INSTR_BEFORE(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, func_addr, 0, 0,
                    SLOT_OP(SUB_SLOT_TMP, tmp_n),
                    IMM_OP(ctx->hex_offset),
                    IMM_OP(lookup_next_func_idx(ctx, u)));
            } else if (h == helper_jmp_ind) {
                // - GET the address of next
                // func_addr tmp_n,jmp_ind_callback
                EMIT_INSTR_BEFORE(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, func_addr, 0, 0,
                    SLOT_OP(SUB_SLOT_TMP, tmp_n),
                    SYMBOL_OP(jmp_ind_callback));
            }

            // Create tail_call_qemuaot instruction
            size_t sz = sizeof(UnifiedInstr) + (u->operand_count + 2) * sizeof(Operand);
            UnifiedInstr *uu = calloc(1, sz);
            uu->opc = tail_call_qemuaot;
            for (int i = 0; i < u->operand_count; ++i) {
                if (u->operands[i].kind == OP_VEC) {
                    int tmp1 = get_next_tmp_idx(ctx);
                    int tmp2 = get_next_tmp_idx(ctx);
                    // - GET env pointer
                    // mov_i64 tmp_N1,env
                    EMIT_INSTR_BEFORE(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, mov_i64, 0, 0,
                        SLOT_OP(SUB_SLOT_TMP, tmp1),
                        ENV_OP(0));

                    uint64_t off = get_vec_offset(u->operands[i].vec.idx);
                    // - CALCULATE offset to CPUArchState xmm
                    // add_i64 tmp_N2,tmp_N1,offset
                    EMIT_INSTR_BEFORE(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, add_i64, 0, 0,
                        SLOT_OP(SUB_SLOT_TMP, tmp2),
                        SLOT_OP(SUB_SLOT_TMP, tmp1),
                        IMM_OP(off));
                    uu->operands[i].kind = OP_SLOT;
                    uu->operands[i].slot.type = SUB_SLOT_TMP;
                    uu->operands[i].slot.idx = tmp2;
                    uu->operands[i].slot.op_type = LLVMInt64;
                } else {
                    uu->operands[i] = u->operands[i];
                }
            }
            uu->operand_count = u->operand_count;
            Operand ec;
            ec.kind = OP_SLOT;
            ec.slot.type = SUB_SLOT_TMP;
            ec.slot.idx = tmp_entry;
            ec.slot.op_type = LLVMInt64;
            uu->operands[0] = ec;

            // Create failure case trampoline into helper_jit
            if (h == helper_jmp_ind) {
                int tmp_t = get_next_tmp_idx(ctx);
                EMIT_INSTR_BEFORE(ctx, &(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, func_addr, 0, 0,
                    SLOT_OP(SUB_SLOT_TMP, tmp_t),
                    IMM_OP(ctx->hex_offset),
                    IMM_OP(create_trampoline_for_runtime(ctx, u, !helper_runtime_does_not_return[h])));
                Operand tf;
                tf.kind = OP_SLOT;
                tf.slot.type = SUB_SLOT_TMP;
                tf.slot.idx = tmp_t;
                tf.slot.op_type = LLVMInt64;
                uu->operands[uu->operand_count++] = tf;
            }

            // Setup the next step
            if (!helper_runtime_does_not_return[h] || h == helper_jmp_ind) {
                Operand nf;
                nf.kind = OP_SLOT;
                nf.slot.type = SUB_SLOT_TMP;
                nf.slot.idx = tmp_n;
                nf.slot.op_type = LLVMInt64;
                uu->operands[uu->operand_count++] = nf;
            }

            // Move the output from the call to the beginning of the next step
            assert(uu->operands[TCG_CALL_OUT_FLAG_IDX].kind == OP_IMM);
            if (uu->operands[TCG_CALL_OUT_FLAG_IDX].imm) {
                int nfidx = lookup_next_func_idx(ctx, u);
                EMIT_INSTR_BEFORE(ctx, &(ctx->llvm_func_set.lists[nfidx].head), &(ctx->llvm_func_set.lists[nfidx].tail), ctx->llvm_func_set.lists[nfidx].head, mov_i64, 0, 0,
                    SLOT_OP_EXTRA(uu->operands[TCG_CALL_PREFIX_COUNT].slot.type, uu->operands[TCG_CALL_PREFIX_COUNT].slot.idx, uu->operands[TCG_CALL_PREFIX_COUNT].slot.op_type, uu->operands[TCG_CALL_PREFIX_COUNT].slot.stack_type),
                    LASTARG_OP());
                memcpy(&uu->operands[TCG_CALL_PREFIX_COUNT], &uu->operands[TCG_CALL_PREFIX_COUNT + 1],
                       (uu->operand_count - TCG_CALL_PREFIX_COUNT - 1) * sizeof(Operand));
                uu->operands[TCG_CALL_OUT_FLAG_IDX].imm = 0;
                uu->operand_count -= 1;
            }

            instr_list_insert_before(&(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u, uu);
            instr_list_remove_and_free(&(ctx->llvm_func_set.lists[fi].head), &(ctx->llvm_func_set.lists[fi].tail), u);
            u = uu;
        }
    }
}
