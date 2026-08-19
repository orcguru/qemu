#include <glib.h>
#include "tcg_context.h"
#include "parser_util.h"
#include "unified_instr.h"
#include "tcg_ast.h"
#include "operand_static_types.h"
#include "mapper_util.h"

static uint16_t xmm_offsets[17] = {0};

uint64_t get_xmm_offset(uint64_t idx) {
    assert(idx <= 16);
    return xmm_offsets[idx];
}

void register_xmm(uint64_t idx, uint64_t offset) {
    assert(idx < 16);
    xmm_offsets[idx] = (uint16_t)offset;
}

void register_xmm_tmp(uint64_t offset) {
    xmm_offsets[XMM_TMP_IDX] = (uint16_t)offset;
}

XMMReg lookup_xmm(uint64_t offset) {
    uint16_t off = (uint16_t)offset;
    XMMReg x;
    x.xmm_idx = NON_XMM;
    x.xmm_offset = 0;
    if (XMM_COUNT > 0 && xmm_offsets[0] <= off && off < (xmm_offsets[XMM_COUNT-1] + 0x20)) {
        uint16_t idx = (off - xmm_offsets[0]) / 0x40;
        uint16_t delta = (off - xmm_offsets[0]) % 0x40;
        if (delta < 0x10) {
            x.xmm_idx = idx * 2;
            x.xmm_offset = delta;
        } else if (delta < 0x20) {
            x.xmm_idx = idx * 2 + 1;
            x.xmm_offset = delta - 0x10;
        }
    }
    return x;
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
        ret.idx = ctx->next_tmp_idx;
        g_hash_table_insert(ctx->slot_map, (gpointer)(long)key_idx, (gpointer)(long)ctx->next_tmp_idx);
        ctx->next_tmp_idx += 1;
    }
    return ret;
}

void reset_slot_map(TcgContext *ctx) {
    GHashTableIter iter;
    gpointer key, value;
    g_hash_table_iter_init(&iter, ctx->slot_map);
    while (g_hash_table_iter_next(&iter, &key, &value)) {
        g_hash_table_iter_remove(&iter);
    }
    ctx->next_tmp_idx = 0;
}

XMMReg lookup_xmm_map(uint64_t offset) {
    uint16_t off = (uint16_t)offset;
    XMMReg x;
    x.xmm_idx = NON_XMM;
    x.xmm_offset = 0;
    if (xmm_offsets[0] <= off && off < (xmm_offsets[XMM_TMP_IDX - 1] + 0x20)) {
        uint16_t idx = (off - xmm_offsets[0]) / 0x40;
        uint16_t delta = (off - xmm_offsets[0]) % 0x40;
        if (delta < 0x10) {
            x.xmm_idx = idx * 2;
            x.xmm_offset = delta;
        } else if (delta < 0x20) {
            x.xmm_idx = idx * 2 + 1;
            x.xmm_offset = delta - 0x10;
        }
    } else if (xmm_offsets[XMM_TMP_IDX] <= off && off < (xmm_offsets[XMM_TMP_IDX] + 0x20)) {
        uint16_t idx = XMM_TMP_IDX;
        uint16_t delta = off - xmm_offsets[XMM_TMP_IDX];
        if (delta < 0x10) {
            x.xmm_idx = idx * 2;
            x.xmm_offset = delta;
        } else if (delta < 0x20) {
            x.xmm_idx = idx * 2 + 1;
            x.xmm_offset = delta - 0x10;
        }
    }
    return x;
}

/* Free a singly-linked list of UnifiedInstr (and their operand data). */
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

/* Append a UnifiedInstr to the context's list (O(1) using tail) */
void append_instr(TcgContext *ctx, UnifiedInstr *u) {
    u->next = NULL;
    if (ctx->instr_tail) {
        ctx->instr_tail->next = u;
        ctx->instr_tail = u;
    } else {
        ctx->instr_head = u;
        ctx->instr_tail = u;
    }
}

/*
 * Reset the instruction list in the context, freeing all allocated
 * UnifiedInstr nodes.  After this call, instr_head and instr_tail
 * are both NULL and the associated memory has been released.
 */
void tcg_context_reset_instrs(TcgContext *ctx) {
    free_instr_list(ctx->instr_head);
    ctx->instr_head = NULL;
    ctx->instr_tail = NULL;
}

/*
 * Logic to handle alias e.g. add_i64 loc6,env,$0x5e0
 */
void init_alias_map(TcgContext *ctx) {
    ctx->plen = 0;
    GHashTableIter iter;
    gpointer key, value;
    g_hash_table_iter_init(&iter, ctx->alias_map);
    while (g_hash_table_iter_next(&iter, &key, &value)) {
        g_hash_table_iter_remove(&iter);
    }
}

void register_alias(TcgContext *ctx, Operand *s, Operand *xmm_env) {
    assert(s->kind == OP_SLOT && s->slot.type == SUB_SLOT_TMP);
    assert(xmm_env->kind == OP_XMM || xmm_env->kind == OP_ENV);
    assert(ctx->plen < ctx->pcap);
    ctx->alias_ops_pool[ctx->plen] = *xmm_env;
    if (g_hash_table_contains(ctx->alias_map, (gconstpointer)(long)s->slot.idx)) {
        g_hash_table_replace(ctx->alias_map, (gpointer)(long)s->slot.idx, &ctx->alias_ops_pool[ctx->plen]);
    } else {
        g_hash_table_insert(ctx->alias_map, (gpointer)(long)s->slot.idx, &ctx->alias_ops_pool[ctx->plen]);
    }
    ctx->plen += 1;
    if (ctx->plen == ctx->pcap) {
        ctx->pcap *= 2;
        ctx->alias_ops_pool = (Operand *)realloc(ctx->alias_ops_pool, ctx->pcap);
        assert(ctx->alias_ops_pool);
    }
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

void set_operand_type(Operand *op, LLVMType ty) {
    if (op->kind == OP_SLOT) {
        op->slot.op_type = ty;
    } else if (op->kind == OP_XMM) {
        op->xmm.op_type = ty;
    } else if (op->kind == OP_ENV) {
        op->env.op_type = ty;
    }
}

void update_slot_types(TcgContext *ctx,
                              uint8_t opc, bool is_helper,
                              uint8_t vs, uint8_t es,
                              Operand *ops, int nops) {
    LLVMType ty = LLVMInvalidType;
    /* Vector */
    if (vs > 0) {
        ty = vec_op_type(vs, es);
        for (int i = 0; i < nops; ++i) {
            set_operand_type(&ops[i], ty);
        }
        return;
    }
    /* Call helper */
    if (is_helper) {
        int first_input_idx = TCG_CALL_PREFIX_COUNT;
        assert(ops[0].kind == OP_SYMBOL);
        assert(ops[2].kind == OP_IMM);
        HelperType h = ops[0].symbol;
        // Handle output
        if (ops[2].imm) {
            first_input_idx += 1;
            assert(ops[TCG_CALL_PREFIX_COUNT].kind == OP_SLOT);
            ops[TCG_CALL_PREFIX_COUNT].slot.op_type = helper_return_type[h];
        }
        int type_lookup_idx = 0;
        for (int i = first_input_idx; i < nops; ++i) {
            if (ops[i].kind == OP_SLOT) {
                assert(helper_collapse_xmm_arg_type[h][type_lookup_idx] != LLVMInvalidType);
                ops[i].slot.op_type = helper_collapse_xmm_arg_type[h][type_lookup_idx];
                type_lookup_idx += 1;
            } else if (ops[i].kind == OP_XMM) {
                ops[i].xmm.op_type = LLVMVector2xi64;
            } else if (ops[i].kind == OP_ENV) {
                ops[i].env.op_type = LLVMVector2xi64;
            }
        }
        return;
    }
    /* Scalar */
    for (int i = 0; i < nops; ++i) {
        if (opcmem_addr_nzidx[opc] > 0) {
            // Memory operations
            if (i < opcmem_addr_nzidx[opc]) {
                assert(ops[i].kind == OP_SLOT);
                // Register-bits
                set_operand_type(&ops[i], opciosz[opc][1]);
            } else {
                // Memory-bits
                set_operand_type(&ops[i], opciosz[opc][0]);
            }
        } else {
            if (i < opcoc[opc]) {
                // Output-bits
                set_operand_type(&ops[i], opciosz[opc][1]);
            } else {
                // Input-bits
                set_operand_type(&ops[i], opciosz[opc][0]);
            }
        }
    }
    return;
}

void type_map_apply(TcgContext *ctx) {
}

void type_map_reset(TcgContext *ctx) {
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

UnifiedInstr *emit_instr(uint8_t opc, bool is_helper,
                                uint8_t vs, uint8_t es,
                                Operand *ops, int nops) {
    size_t sz = sizeof(UnifiedInstr) + nops * sizeof(Operand);
    UnifiedInstr *u = malloc(sz);
    memset(u, 0, sz);
    u->opc = opc;
    u->is_helper = is_helper;
    u->vs = vs;
    u->es = es;
    int skip_cnt = 0;
    int dst_idx = 0;
    for (int i = 0; i < nops; ++i) {
        if (ops[i].kind == OP_ENV && (i + 1) < nops && ops[i + 1].kind == OP_IMM) {
            XMMReg x = lookup_xmm(ops[i + 1].imm);
            if (x.xmm_idx != NON_XMM) {
                u->operands[dst_idx].kind = OP_XMM;
                u->operands[dst_idx].xmm.xmm_idx = x.xmm_idx;
                u->operands[dst_idx].xmm.xmm_offset = x.xmm_offset;
            } else {
                u->operands[dst_idx].kind = OP_ENV;
                u->operands[dst_idx].env.env_offset = (uint16_t)ops[i + 1].imm;
            }
            i += 1;
            skip_cnt += 1;
        } else {
            u->operands[dst_idx] = ops[i];
        }
        dst_idx += 1;
    }
    u->operand_count = nops - skip_cnt;
    u->next = NULL;
    return u;
}
