#include <glib.h>
#include "tcg_context.h"
#include "parser_util.h"
#include "unified_instr.h"
#include "tcg_ast.h"
#include "operand_static_types.h"
#include "mapper_util.h"

static uint16_t xmm_offsets[17] = {0};

static uint16_t get_next_tmp_idx(TcgContext *ctx) {
    return ctx->next_tmp_idx++;
}

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
        ret.idx = get_next_tmp_idx(ctx);
        g_hash_table_insert(ctx->slot_map, (gpointer)(long)key_idx, (gpointer)(long)ret.idx);
    }
    return ret;
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

void tcg_context_reset(TcgContext *ctx) {
    free_instr_list(ctx->instr_head);
    ctx->instr_head = NULL;
    ctx->instr_tail = NULL;

    // init_alias_map
    ctx->plen = 0;
    GHashTableIter iter;
    gpointer key, value;
    g_hash_table_iter_init(&iter, ctx->alias_map);
    while (g_hash_table_iter_next(&iter, &key, &value)) {
        g_hash_table_iter_remove(&iter);
    }

    // reset_slot_map
    g_hash_table_iter_init(&iter, ctx->slot_map);
    while (g_hash_table_iter_next(&iter, &key, &value)) {
        g_hash_table_iter_remove(&iter);
    }
    ctx->next_tmp_idx = 0;

    // type_map_reset
    g_hash_table_iter_init(&iter, ctx->stack_type_map);
    while (g_hash_table_iter_next(&iter, &key, &value)) {
        g_hash_table_iter_remove(&iter);
    }

    // Reset the next helper index
    ctx->next_helper_idx = 0;

    // Reset stack alloca bit array
    ctx->xreg_valid = 0;
    ctx->xmm_valid = 0;
}

/*
 * Logic to handle alias e.g. add_i64 loc6,env,$0x5e0
 */
void register_alias(TcgContext *ctx, Operand *s, Operand *xmm_env) {
    assert(s->kind == OP_SLOT && s->slot.type == SUB_SLOT_TMP);
    assert(xmm_env->kind == OP_XMM || xmm_env->kind == OP_ENV);
    if (ctx->plen >= ctx->pcap) {
        ctx->pcap = ctx->pcap ? ctx->pcap * 2 : 8;
        ctx->alias_ops_pool = realloc(ctx->alias_ops_pool, ctx->pcap * sizeof(Operand));
    }
    ctx->alias_ops_pool[ctx->plen] = *xmm_env;
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
    } else if (op->kind == OP_XMM) {
        op->xmm.op_type = ty;
    } else if (op->kind == OP_ENV) {
        op->env.op_type = ty;
    }
}

void register_stack_alloca(TcgContext *ctx, UnifiedInstr *u) {
    for (int i = 0; i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_XMM) {
            ctx->xmm_valid |= (1 << u->operands[i].xmm.xmm_idx);
        }
        if (u->operands[i].kind == OP_SLOT && u->operands[i].slot.type == SUB_SLOT_XREG) {
            ctx->xreg_valid |= (1 << u->operands[i].slot.idx);
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
    if (u->is_helper) {
        int first_input_idx = TCG_CALL_PREFIX_COUNT;
        assert(u->operands[0].kind == OP_SYMBOL);
        assert(u->operands[2].kind == OP_IMM);
        HelperType h = u->operands[0].symbol;
        // Handle output
        if (u->operands[2].imm) {
            first_input_idx += 1;
            assert(u->operands[TCG_CALL_PREFIX_COUNT].kind == OP_SLOT);
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
            } else if (u->operands[i].kind == OP_XMM) {
                u->operands[i].xmm.op_type = LLVMVector2xi64;
            } else if (u->operands[i].kind == OP_ENV) {
                assert(xmm_offsets[XMM_TMP_IDX]);
                if (u->operands[i].env.env_offset == xmm_offsets[XMM_TMP_IDX]) {
                    u->operands[i].env.op_type = LLVMVector2xi64;
                } else {
                    u->operands[i].env.op_type = LLVMInt64;
                }
            }
        }
        return;
    }
    /* Scalar */
    for (int i = 0; i < u->operand_count; ++i) {
        if (u->operands[i].kind != OP_SLOT &&
            u->operands[i].kind != OP_XMM &&
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
            } else if (op->kind == OP_XMM) {
                assert(op->xmm.op_type);
            } else if (op->kind == OP_ENV) {
                assert(op->env.op_type);
            }       
        }
    }
}

void type_map_apply(TcgContext *ctx) {
    for (UnifiedInstr *u = ctx->instr_head; u; u = u->next) {
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
            } else if (op->kind == OP_XMM) {
                assert(op->xmm.stack_type != LLVMInvalidType);
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
    UnifiedInstr *u = malloc(sz);
    memset(u, 0, sz);
    u->opc = opc;
    if (opc == call) {
        u->is_helper = true;
        u->helper_index = ctx->next_helper_idx++;
    } else {
        u->is_helper = false;
    }
    u->vs = vs;
    u->es = es;
    int skip_cnt = 0;
    int dst_idx = 0;
    if (u->is_helper) {
        memcpy(u->operands, ops, (nops * sizeof(Operand)));
    } else {
        for (int i = 0; i < nops; ++i) {
            if (ops[i].kind == OP_ENV && (i + 1) < nops && ops[i + 1].kind == OP_IMM) {
                XMMReg x = lookup_xmm(ops[i + 1].imm);
                if (x.xmm_idx != NON_XMM) {
                    u->operands[dst_idx].kind = OP_XMM;
                    u->operands[dst_idx].xmm.xmm_idx = x.xmm_idx;
                    u->operands[dst_idx].xmm.xmm_offset = x.xmm_offset;
                    u->operands[dst_idx].xmm.op_type = LLVMInvalidType;
                    u->operands[dst_idx].xmm.stack_type = LLVMVector2xi64;
                } else {
                    u->operands[dst_idx].kind = OP_ENV;
                    u->operands[dst_idx].env.env_offset = (uint16_t)ops[i + 1].imm;
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
    u->next = NULL;
    return u;
}

void replace_and_release_macro_by_instr_list(TcgContext *ctx, UnifiedInstr *tgt,
                                UnifiedInstr *new_head, UnifiedInstr *new_tail) {
    UnifiedInstr *prev = NULL;
    UnifiedInstr *u = ctx->instr_head;
    while (u) {
        if (u->opc == tgt->opc) {
            break;
        }
        prev = u;
        u = u->next;
    }
    if (!prev) {
        ctx->instr_head = new_head;
    } else {
        prev->next = new_head;
    }
    new_tail->next = tgt->next;
    tgt->next = NULL;
    free(tgt);
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

#define EMIT_INSTR_LIST(ctx, nh, nt, opc, vs, es, ...)           \
    do {                                                                    \
        Operand _ops[] = { __VA_ARGS__ };                                   \
        size_t _cnt = sizeof(_ops) / sizeof(_ops[0]);                       \
        UnifiedInstr *_u = emit_instr(ctx, opc, vs, es, _ops, _cnt);  \
        expand_slot_alias(ctx, _u);                                         \
        update_slot_types(ctx, _u);                                         \
        register_stack_alloca(ctx, _u);                                         \
        if (!(nh)) (nh) = _u;                                               \
        if (nt) (nt)->next = _u;                                            \
        (nt) = _u;                                                          \
    } while (0)

#define SLOT_OP(ty, index)  ((Operand){ .kind = OP_SLOT, .slot.type = (ty), .slot.idx = (index) })
#define SLOT_OP_EXTRA(ty, index, op_ty, stack_ty)                           \
            ((Operand){ .kind = OP_SLOT, .slot.type = (ty), .slot.idx = (index), .slot.op_type = (op_ty), .slot.stack_type = (stack_ty) })
#define IMM_OP(val)         ((Operand){ .kind = OP_IMM,   .imm = (val) })
#define ENV_OP(off)         ((Operand){ .kind = OP_ENV,   .env.env_offset = (off) })
#define LABEL_OP(lbl)       ((Operand){ .kind = OP_LABEL, .label = (lbl) })
#define RELOP_OP(r)         ((Operand){ .kind = OP_RELOP, .relop = (r) })
#define SYMBOL_OP(sym)      ((Operand){ .kind = OP_SYMBOL, .symbol = (sym) })
#define ATTR_STORAGE_OP(nonatomic, align, sz)                             \
    ((Operand){ .kind = OP_ATTR, .attr_info = {                            \
        .subt = SUB_ATTR_STORAGE,                                          \
        .p.storage = { .atomic = (nonatomic), .alignment = (align), .size = (sz) } \
    }})

void expand_push_ret_addr(TcgContext *ctx) {
    UnifiedInstr *tgt = get_single_target_opc(ctx, push_ret_addr);
    if (!tgt) {
        return;
    }
    UnifiedInstr *nh = NULL, *nt = NULL;
    int tmp1 = get_next_tmp_idx(ctx);
    int tmp2 = get_next_tmp_idx(ctx);
    int tmp3 = get_next_tmp_idx(ctx);

    // - GET pointer to the shadow stack ptr
    // mov_i64 tmp_N1,env
    // add_i64 tmp_N1,tmp_N1,-8UL
    EMIT_INSTR_LIST(ctx, nh, nt, mov_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        ENV_OP(0));
    EMIT_INSTR_LIST(ctx, nh, nt, add_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        IMM_OP(-8ULL));

    // - LOAD the shadow stack ptr
    // qemu_ld_i64 tmp_N2,tmp_N1,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_LIST(ctx, nh, nt, qemu_ld_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - ALLOCATE an entry on the shadow stack
    // add_i64 tmp_N2,tmp_N2,-8UL
    EMIT_INSTR_LIST(ctx, nh, nt, add_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        IMM_OP(-8ULL));

    // - STORE x64_ret_addr into the entry
    // qemu_st_i64 op0,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
    assert(tgt->operands[0].kind == OP_SLOT);
    EMIT_INSTR_LIST(ctx, nh, nt, qemu_st_i64, 0, 0,
        SLOT_OP_EXTRA(tgt->operands[0].slot.type, tgt->operands[0].slot.idx, tgt->operands[0].slot.op_type, tgt->operands[0].slot.stack_type),
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - ALLOCATE an entry on the shadow stack
    // add_i64 tmp_N2,tmp_N2,-8UL
    EMIT_INSTR_LIST(ctx, nh, nt, add_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        IMM_OP(-8ULL));

    // - GET the address of return
    // func_addr tmp_N3,op2
    assert(tgt->operands[1].kind == OP_IMM);
    EMIT_INSTR_LIST(ctx, nh, nt, func_addr, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp3),
        IMM_OP(tgt->operands[1].imm));

    // - STORE the address of return into the entry
    // qemu_st_i64 tmp_N3,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_LIST(ctx, nh, nt, qemu_st_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp3),
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - UPDATE the shadow stack ptr
    // qemu_st_i64 tmp_N2,tmp_N1,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_LIST(ctx, nh, nt, qemu_st_i64, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp2),
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    replace_and_release_macro_by_instr_list(ctx, tgt, nh, nt);
}

void expand_ret(TcgContext *ctx) {
    UnifiedInstr *tgt = get_single_target_opc(ctx, ret);
    if (!tgt) {
        return;
    }
    UnifiedInstr *nh = NULL, *nt = NULL;
    int tmp1 = get_next_tmp_idx(ctx);
    int tmp2 = get_next_tmp_idx(ctx);
    int tmp3 = get_next_tmp_idx(ctx);
    int tmp4 = get_next_tmp_idx(ctx);
    // - GET pointer to the shadow stack ptr
    // mov_i64 tmp_N1,env
    // add_i64 tmp_N1,tmp_N1,-8UL
    EMIT_INSTR_LIST(ctx, nh, nt, mov_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp1), ENV_OP(0));
    EMIT_INSTR_LIST(ctx, nh, nt, add_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp1), SLOT_OP(SUB_SLOT_TMP, tmp1), IMM_OP(-8ULL));

    // - LOAD the shadow stack ptr
    // qemu_ld_i64 tmp_N2,tmp_N1,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_LIST(ctx, nh, nt, qemu_ld_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp2), SLOT_OP(SUB_SLOT_TMP, tmp1), ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - LOAD the address of return
    // qemu_ld_i64 tmp_N3,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_LIST(ctx, nh, nt, qemu_ld_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp3), SLOT_OP(SUB_SLOT_TMP, tmp2), ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - POP the shadow stack
    // add_i64 tmp_N2,tmp_N2,8UL
    EMIT_INSTR_LIST(ctx, nh, nt, add_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp2), SLOT_OP(SUB_SLOT_TMP, tmp2), IMM_OP(8ULL));

    // - LOAD the x64_ret_addr
    // qemu_ld_i64 tmp_N4,tmp_N2,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_LIST(ctx, nh, nt, qemu_ld_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp4), SLOT_OP(SUB_SLOT_TMP, tmp2), ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - POP the shadow stack
    // add_i64 tmp_N2,tmp_N2,8UL
    EMIT_INSTR_LIST(ctx, nh, nt, add_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp2), SLOT_OP(SUB_SLOT_TMP, tmp2), IMM_OP(8ULL));

    // - UPDATE the shadow stack ptr
    // qemu_st_i64 tmp_N2,tmp_N1,attr:NONATOMIC,ALIGN_8,SRC8B
    EMIT_INSTR_LIST(ctx, nh, nt, qemu_st_i64, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp2), SLOT_OP(SUB_SLOT_TMP, tmp1), ATTR_STORAGE_OP(NONATOMIC, ALIGN_8, SRC8B));

    // - CHECK if lookup is needed
    // brcond_i64 op0,tmp_N4,ne,L0
    assert(tgt->operands[0].kind == OP_SLOT);
    EMIT_INSTR_LIST(ctx, nh, nt, brcond_i64, 0, 0, SLOT_OP_EXTRA(tgt->operands[0].slot.type, tgt->operands[0].slot.idx, tgt->operands[0].slot.op_type, tgt->operands[0].slot.stack_type), SLOT_OP(SUB_SLOT_TMP, tmp4), RELOP_OP(ne), LABEL_OP(0));

    // - TAIL call
    // tail_call tmp_N3
    EMIT_INSTR_LIST(ctx, nh, nt, tail_call, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp3));

    // - LOOKUP return address
    // set_label L0
    // call jmp_ind,0x1,0,op0
    EMIT_INSTR_LIST(ctx, nh, nt, set_label, 0, 0, LABEL_OP(0));
    EMIT_INSTR_LIST(ctx, nh, nt, call, 0, 0, SYMBOL_OP(helper_jmp_ind), IMM_OP(0x1), IMM_OP(0), SLOT_OP_EXTRA(tgt->operands[0].slot.type, tgt->operands[0].slot.idx, tgt->operands[0].slot.op_type, tgt->operands[0].slot.stack_type));

    replace_and_release_macro_by_instr_list(ctx, tgt, nh, nt);
}

void expand_jmp_direct(TcgContext *ctx) {
    UnifiedInstr *tgt = get_single_target_opc(ctx, jmp_direct);
    if (!tgt) {
        return;
    }
    UnifiedInstr *nh = NULL, *nt = NULL;
    int tmp1 = get_next_tmp_idx(ctx);

    // - GET the address of return
    // func_addr tmp_N1,op0
    assert(tgt->operands[0].kind == OP_IMM);
    EMIT_INSTR_LIST(ctx, nh, nt, func_addr, 0, 0,
        SLOT_OP(SUB_SLOT_TMP, tmp1),
        IMM_OP(tgt->operands[0].imm));

    // - TAIL call
    // tail_call tmp_N1
    EMIT_INSTR_LIST(ctx, nh, nt, tail_call, 0, 0, SLOT_OP(SUB_SLOT_TMP, tmp1));

    replace_and_release_macro_by_instr_list(ctx, tgt, nh, nt);
}
