/*
 * FIXME Copyright
 */
#include <glib.h>
#include "tcg_context.h"
#include "util.h"
#include "unified_instr.h"
#include "tcg_ast.h"
#include "operand_static_types.h"
#include "mapper_util.h"
#include "i386_cpu.h"

/*
 * Static misc functions
 */
static void free_instr_list(UnifiedInstr *head) {
    while (head) {
        UnifiedInstr *next = head->next;
        free(head);
        head = next;
    }
}

static void func_list_free(FuncInstrList *list) {
    free_instr_list(list->head);
    list->head = NULL;
    list->tail = NULL;
    list->count = 0;
    if (list->added_param_count) {
        free(list->added_param_type);
        free(list->added_param_name);
    }
}

static void func_list_set_free(FuncListSet *set) {
    for (int i = 0; i < set->num_lists; i++) {
        func_list_free(&set->lists[i]);
    }
    free(set->lists);
    set->lists = NULL;
    set->num_lists = 0;
    set->capacity = 0;
}

static LLVMType vec_op_type(uint8_t vs, uint8_t es) {
    if (vs == 64) {
        switch (es) {
        case 8:  return LLVMVector8xi8;
        case 16: return LLVMVector4xi16;
        case 32: return LLVMVector2xi32;
        case 64: return LLVMVector1xi64;
        default: return LLVMInvalidType;
        }
    }
    if (vs == 128) {
        switch (es) {
        case 8:  return LLVMVector16xi8;
        case 16: return LLVMVector8xi16;
        case 32: return LLVMVector4xi32;
        case 64: return LLVMVector2xi64;
        default: return LLVMInvalidType;
        }
    }
    return LLVMInvalidType;
}

static LLVMType storage_size_to_type(SrcSizeType sz) {
    switch (sz) {
    case SRC1B: return LLVMInt8;
    case SRC2B: return LLVMInt16;
    case SRC4B: return LLVMInt32;
    case SRC8B: return LLVMInt64;
    default:    return LLVMInvalidType;
    }
}

/*
 * X/YMM-Vector mapping related
 * QEMU TCG emulates X/Y/ZMM registers by array of 0x40 bytes: XMM occupies the
 * initial 0x10 bytes, YMM covers XMM and extends to additional 0x10 bytes
 * after that.
 *
 * Current implementation emulates XMM in even-indexed vector register, and YMM
 * in odd-indexed vector register.
 *
 * Initial XMM_COUNT X/YMM pairs are emulated in vector registers, remainings
 * including xmm_t0 are still emulated in memory (CPUX86State/xmm_regs)
 */
extern int cfg_xmm_count;
static uint16_t xmm_offsets[17] = {0};

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

VecInfo lookup_vector(uint64_t offset, bool in_register) {
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
    if (in_register) {
        if (cfg_xmm_count <= 0 || off >= (xmm_offsets[cfg_xmm_count-1] + 0x20)) {
            v.idx = NON_XMM;
            v.offset = 0;
        }
    }
    return v;
}

/*
 * Linear mapping for locN/tmpN symbols from TCG IR into tN in the scope of one
 * QEMU TCG translation block
 */
SlotInfo get_slot_for(TcgContext *ctx, SlotType type, uint16_t idx) {
    SlotInfo ret;
    ret.type = SUB_SLOT_TMP;
    uint16_t key_idx = idx;
#define TMPT_OFFSET     (1 << 15)
    if (type == SUB_SLOT_TMPT) {
        key_idx += TMPT_OFFSET;
    }
    if (g_hash_table_contains(ctx->slot_map, (gconstpointer)(long)key_idx)) {
        ret.idx = (uint16_t)(long)g_hash_table_lookup(ctx->slot_map, (gpointer)(long)key_idx);
    } else {
        ret.idx = get_next_tmp_idx(ctx);
        g_hash_table_insert(ctx->slot_map, (gpointer)(long)key_idx, (gpointer)(long)ret.idx);
    }
#undef TMPT_OFFSET
    return ret;
}

/*
 * Manipulate instruction list
 */
// Insert 'u' right after 'anchor'. If anchor is NULL, prepend at head.
void instr_list_insert_after(UnifiedInstr **head_p, UnifiedInstr **tail_p, UnifiedInstr *anchor, UnifiedInstr *u) {
    u->prev = anchor;
    if (!anchor) {
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

// Insert 'u' right before 'anchor'. If anchor is NULL, append at tail.
void instr_list_insert_before(UnifiedInstr **head_p, UnifiedInstr **tail_p, UnifiedInstr *anchor, UnifiedInstr *u) {
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

void instr_list_remove_and_free(UnifiedInstr **head_p, UnifiedInstr **tail_p, UnifiedInstr *u) {
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

/*
 * Function list related
 * Initially instructions are chained on TcgContext instr_head/tail, then after
 * expand_llvm_func(), multiple threads of instructions are formed as function
 * lists, each function list maps to one LLVM IR function
 */
void func_list_init(FuncInstrList *list) {
    list->head_uidx = -1;
    list->head = NULL;
    list->tail = NULL;
    list->count = 0;
    memset(&list->trampoline_name[0], 0, sizeof(list->trampoline_name));
    list->added_param_count = 0;
    list->added_param_type = NULL;
    list->added_param_name = NULL;
}

void func_list_append(FuncInstrList *list, UnifiedInstr *u) {
    instr_list_insert_before(&list->head, &list->tail, NULL, u);
    list->count++;
}

int get_next_func_list_idx(TcgContext *ctx) {
    if (ctx->llvm_func_set.num_lists >= ctx->llvm_func_set.capacity) {
        ctx->llvm_func_set.capacity = ctx->llvm_func_set.capacity ? 2 * ctx->llvm_func_set.capacity : 2;
        ctx->llvm_func_set.lists = realloc(ctx->llvm_func_set.lists, ctx->llvm_func_set.capacity * sizeof(FuncInstrList));
    }
    return ctx->llvm_func_set.num_lists++;
}

/*
 * Utility functions to transform TCG IR implicit X/YMM operands into explicit
 * vector operands
 *
 * For example below TCG IR first create an implicit X/YMM operand, and then
 * duplicate to create another implicit X/YMM operand. Two mappings should be
 * created to refer to x/ymm0
 * add_i64 loc1,env,$0x360
 * mov_i64 loc2,loc1
 *
 * Any assignment to the implicit X/YMM operand invalidates the mapping
 *
 * While the mapping is valid, all implicit X/YMM operands should be rewrite
 * as explicit vector operands.
 */
void register_alias(TcgContext *ctx, const Operand *s, const Operand *vec_env) {
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

void try_unregister_alias(TcgContext *ctx, const Operand *op) {
    if (op->kind == OP_SLOT && op->slot.type == SUB_SLOT_TMP) {
        if (g_hash_table_contains(ctx->alias_map, (gconstpointer)(long)op->slot.idx)) {
            g_hash_table_remove(ctx->alias_map, (gpointer)(long)op->slot.idx);
        }
    }
}

void expand_slot_alias(const TcgContext *ctx, UnifiedInstr *u) {
    for (int i = get_first_in_op_idx(u); i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_SLOT && u->operands[i].slot.type == SUB_SLOT_TMP && g_hash_table_contains(ctx->alias_map, (gconstpointer)(long)u->operands[i].slot.idx)) {
            const Operand *op = g_hash_table_lookup(ctx->alias_map, (gpointer)(long)u->operands[i].slot.idx);
            u->operands[i] = *op;
        }
    }
}

/*
 * Keep track of referenced emulated registers throughout the translation block
 */
void register_stack_alloca(TcgContext *ctx, const UnifiedInstr *u) {
    for (int i = 0; i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_VEC) {
            ctx->vec_valid |= (1 << u->operands[i].vec.idx);
        }
        if (u->operands[i].kind == OP_SLOT && u->operands[i].slot.type == SUB_SLOT_XREG) {
            ctx->xreg_valid |= (1 << u->operands[i].slot.idx);
        }
    }
}

void register_vec_spare_stack_alloca(TcgContext *ctx, const UnifiedInstr *u) {
    for (int i = 0; i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_VEC) {
            ctx->vec_spare_valid |= (1 << u->operands[i].vec.idx);
        }
    }
}

/*
 * Static types for operands
 * FIXME:
 */
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
    } else if (op->kind == OP_IMM) {
        op->imm.op_type = ty;
    }
}

LLVMType get_operand_type(const Operand *op) {
    LLVMType ty = LLVMInvalidType;
    if (op->kind == OP_SLOT) {
        ty = op->slot.op_type;
    } else if (op->kind == OP_VEC) {
        ty = op->vec.op_type;
    } else if (op->kind == OP_ENV) {
        ty = op->env.op_type;
    }
    return ty;
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
        if (u->operands[2].imm.val) {
            first_input_idx += 1;
            assert(u->operands[TCG_CALL_PREFIX_COUNT].kind == OP_SLOT);
            assert(helper_return_type[h] != LLVMInvalidType);
            set_operand_type(ctx, &u->operands[TCG_CALL_PREFIX_COUNT], helper_return_type[h]);
        }
        int type_lookup_idx = 0;
        for (int i = first_input_idx; i < u->operand_count; ++i) {
            if (u->operands[i].kind == OP_SLOT || u->operands[i].kind == OP_IMM) {
                assert(type_lookup_idx < MAX_ADDED_ARGS);
                if (helper_template_arg_type[h][type_lookup_idx] != LLVMInvalidType) {
                    set_operand_type(ctx, &u->operands[i], helper_template_arg_type[h][type_lookup_idx]);
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
            } else {
                assert(0);
            }
        }
        return;
    } else if (u->opc == tail_call_qemuaot) {
        // tail_call_qemuaot clone operands from the original call, only the
        // target operand need set type
        for (int i = 0; i < u->operand_count; ++i) {
            if (u->operands[i].kind == OP_SLOT && u->operands[i].slot.op_type == LLVMInvalidType) {
                set_operand_type(ctx, &u->operands[i], LLVMInt64);
            }
        }
        return;
    }
    /* Scalar */
    for (int i = 0; i < u->operand_count; ++i) {
        if (u->operands[i].kind != OP_SLOT &&
            u->operands[i].kind != OP_VEC &&
            u->operands[i].kind != OP_ENV &&
            u->operands[i].kind != OP_IMM) {
            continue;
        }
        if (opcmem_addr_nzidx[u->opc] > 0) {
            // Memory operations
            if (i < opcmem_addr_nzidx[u->opc]) {
                assert(u->operands[i].kind == OP_SLOT || u->operands[i].kind == OP_IMM);
                // Register-bits
                set_operand_type(ctx, &u->operands[i], opciosz[u->opc][1]);
            } else {
                // Memory-bits
                LLVMType ty = opciosz[u->opc][0];
                if (ty == LLVMInvalidType) {
                    const AttrSrcInfo *attr = get_attribute_from_instr(u);
                    assert(attr && attr->subt == SUB_ATTR_STORAGE);
                    assert(attr->p.storage.size != INVALID_SRCSIZE);
                    ty = storage_size_to_type(attr->p.storage.size);
                }
                assert(ty != LLVMInvalidType);
                set_operand_type(ctx, &u->operands[i], ty);
            }
        } else {
            if (i < opcoc[u->opc]) {
                // Output-bits
                set_operand_type(ctx, &u->operands[i], opciosz[u->opc][1]);
            } else {
                // Input-bits
                LLVMType ty = opciosz[u->opc][0];
                if (ty == LLVMInvalidType) {
                    const AttrSrcInfo *attr = get_attribute_from_instr(u);
                    assert(attr && attr->subt == SUB_ATTR_STORAGE);
                    assert(attr->p.storage.size != INVALID_SRCSIZE);
                    ty = storage_size_to_type(attr->p.storage.size);
                }
                assert(ty != LLVMInvalidType);
                set_operand_type(ctx, &u->operands[i], ty);
            }
        }
    }
    return;
}

void type_map_apply(const TcgContext *ctx) {
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

/*
 * Instruction related
 */
// Build a new UnifiedInstr from operands: handles OP_ENV+OP_IMM ->
// OP_VEC/OP_ENV conversion
UnifiedInstr *new_instr(TcgContext *ctx, uint8_t opc,
                                uint8_t vs, uint8_t es,
                                Operand *ops, int nops) {
    UnifiedInstr *u = calloc(1, sizeof(UnifiedInstr) + (size_t)nops * sizeof(Operand));
    u->opc = opc;
    u->vs = vs;
    u->es = es;
    u->uidx = ctx->emit_instr_count++;
    int skip_cnt = 0;
    int dst_idx = 0;
    if (u->opc != call) {
        /*
         * For arithmetic operations, ENV is acting as a base pointer into
         * the meta space in case an immediate value is followed
         */
        for (int i = 0; i < nops; ++i) {
            if (ops[i].kind == OP_ENV && (i + 1) < nops && ops[i + 1].kind == OP_IMM) {
                VecInfo v = lookup_vector(ops[i + 1].imm.val, true);
                if (v.idx != NON_XMM) {
                    u->operands[dst_idx].kind = OP_VEC;
                    u->operands[dst_idx].vec.idx = v.idx;
                    u->operands[dst_idx].vec.offset = v.offset;
                    u->operands[dst_idx].vec.op_type = LLVMInvalidType;
                    u->operands[dst_idx].vec.stack_type = LLVMVector2xi64;
                } else {
                    u->operands[dst_idx].kind = OP_ENV;
                    u->operands[dst_idx].env.offset = (uint16_t)ops[i + 1].imm.val;
                    u->operands[dst_idx].env.op_type = LLVMInvalidType;
                    u->operands[dst_idx].env.stack_type = LLVMInvalidType;
                    ctx->env_on = true;
                }
                i += 1;
                skip_cnt += 1;
            } else {
                if (ops[i].kind == OP_ENV) {
                    ctx->env_on = true;
                }
                u->operands[dst_idx] = ops[i];
            }
            dst_idx += 1;
        }
    } else {
        /*
         * For calls, ENV + IMM should not be folded
         */
        memcpy(u->operands, ops, (nops * sizeof(Operand)));
        assert(u->operands[0].kind == OP_SYMBOL && u->operands[0].symbol != not_a_helper);
    }
    u->operand_count = nops - skip_cnt;
    u->prev = NULL;
    u->next = NULL;
    return u;
}

UnifiedInstr *clone_instr_optional_operands(const UnifiedInstr *src, int additional_count, ...) {
    size_t sz = sizeof(UnifiedInstr) + (src->operand_count + additional_count) * sizeof(Operand);
    UnifiedInstr *dst = malloc(sz);
    memcpy(dst, src, sizeof(UnifiedInstr));
    memcpy(&dst->operands[0], &src->operands[0], src->operand_count * sizeof(Operand));
    dst->operand_count = src->operand_count;
    va_list args;
    va_start(args, additional_count);
    for (int i = 0; i < additional_count; i++) {
        dst->operands[dst->operand_count++] = va_arg(args, Operand);
    }
    va_end(args);
    dst->prev = NULL;
    dst->next = NULL;
    return dst;
}

/*
 * TcgContext related
 */
void tcg_context_init(TcgContext *ctx) {
    memset(ctx, 0, sizeof(TcgContext));
    ctx->alias_map = g_hash_table_new(NULL, NULL);
    ctx->slot_map = g_hash_table_new(NULL, NULL);
    ctx->stack_type_map = g_hash_table_new(NULL, NULL);
}

void tcg_context_destroy(TcgContext *ctx) {
    g_hash_table_destroy(ctx->alias_map);
    g_hash_table_destroy(ctx->slot_map);
    g_hash_table_destroy(ctx->stack_type_map);
}

void tcg_context_reset(TcgContext *ctx) {
    free_instr_list(ctx->instr_head);
    func_list_set_free(&ctx->llvm_func_set);
    g_hash_table_destroy(ctx->alias_map);
    g_hash_table_destroy(ctx->slot_map);
    g_hash_table_destroy(ctx->stack_type_map);
    free(ctx->def_mask);
    free(ctx->use_mask);
    free(ctx->reaching_def_exclude_self_def);
    free(ctx->forward_use);
    free(ctx->unexpected_branch);
    free(ctx->alias_ops_pool);

    tcg_context_init(ctx);
}
