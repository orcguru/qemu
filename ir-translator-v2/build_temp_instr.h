#ifndef BUILD_TEMP_INSTR_H
#define BUILD_TEMP_INSTR_H

#include <alloca.h>
#include <string.h>
#include <assert.h>
#include "unified_instr.h"
#include "operand.h"
#include "tcg_ast.h"

/*
 * Set the opcode field.
 */
static inline void __bi_set_opcode(UnifiedInstr *u, OpCodeType opc)
{
    u->opc = opc;
}

/*
 * Set the vector size / element size fields.
 */
static inline void __bi_set_vs(UnifiedInstr *u, uint8_t vs)
{
    u->vs = vs;
}

static inline void __bi_set_ves(UnifiedInstr *u, uint8_t ves)
{
    u->es = ves;
}

/*
 * Set operand `idx` to a slot operand (OP_SLOT).
 *   slot_type : e.g. SUB_SLOT_XREG, SUB_SLOT_TMP
 *   slot_idx  : register/tmp index
 *   offset    : byte offset within the slot
 */
static inline void __bi_set_slot(UnifiedInstr *u, int idx,
                                uint16_t slot_type, uint16_t slot_idx)
{
    assert(idx >= 0 && idx < u->operand_count);
    Operand *op = &u->operands[idx];
    op->kind = OP_SLOT;
    op->slot.type = slot_type;
    op->slot.idx  = slot_idx;
}

/*
 * Set operand `idx` to an immediate operand (OP_IMM).
 */
static inline void __bi_set_imm(UnifiedInstr *u, int idx, uint64_t val)
{
    assert(idx >= 0 && idx < u->operand_count);
    Operand *op = &u->operands[idx];
    op->kind = OP_IMM;
    op->imm = val;
}

/*
 * Set operand `idx` to a label operand (OP_LABEL).
 */
static inline void __bi_set_label(UnifiedInstr *u, int idx, uint8_t label)
{
    assert(idx >= 0 && idx < u->operand_count);
    Operand *op = &u->operands[idx];
    op->kind = OP_LABEL;
    op->label = label;
}

/*
 * Set operand `idx` to a relop operand (OP_RELOP).
 */
static inline void __bi_set_relop(UnifiedInstr *u, int idx, RelopType r)
{
    assert(idx >= 0 && idx < u->operand_count);
    Operand *op = &u->operands[idx];
    op->kind = OP_RELOP;
    op->relop = r;
}

/*
 * Set operand `idx` to an attribute operand (OP_ATTR) from AttrSrcInfo.
 */
static inline void __bi_set_attr(UnifiedInstr *u, int idx,
                                const AttrSrcInfo *attr)
{
    assert(idx >= 0 && idx < u->operand_count);
    Operand *op = &u->operands[idx];
    op->kind = OP_ATTR;
    memcpy(&op->attr_info, attr, sizeof(AttrSrcInfo));
}

/*
 * Set operand `idx` to an XMM operand (OP_XMM).
 */
static inline void __bi_set_xmm(UnifiedInstr *u, int idx,
                               uint8_t xmm_idx, uint8_t xmm_offset)
{
    assert(idx >= 0 && idx < u->operand_count);
    Operand *op = &u->operands[idx];
    op->kind = OP_XMM;
    op->xmm.xmm_idx    = xmm_idx;
    op->xmm.xmm_offset = xmm_offset;
}

/*
 * Set operand `idx` to an ENV operand (OP_ENV).
 */
static inline void __bi_set_env(UnifiedInstr *u, int idx, uint16_t offset)
{
    assert(idx >= 0 && idx < u->operand_count);
    Operand *op = &u->operands[idx];
    op->kind = OP_ENV;
    op->env.env_offset = offset;
}

/*
 * Set operand `idx` to a SYMBOL operand (OP_SYMBOL).
 */
static inline void __bi_set_symbol(UnifiedInstr *u, int idx, HelperType h)
{
    assert(idx >= 0 && idx < u->operand_count);
    Operand *op = &u->operands[idx];
    op->kind = OP_SYMBOL;
    op->symbol = h;
}

/* ============================================================ * Macro layer – the user-facing API * ============================================================ */

/*
 * BUILD_INSTR(n) – declare a temporary UnifiedInstr with n operands.
 * Opens a block; must be closed with BI_END or BI_EXEC*.
 */
#define BUILD_INSTR(nops)                                                    \
        size_t __bi_sz = sizeof(UnifiedInstr) + nops * sizeof(Operand);     \
        UnifiedInstr *__bi_u = (UnifiedInstr *)alloca(__bi_sz);             \
        memset(__bi_u, 0, __bi_sz);                                                   \
        __bi_u->operand_count = nops;                                            \
        __bi_u->is_helper = 0;                                                   \
        __bi_u->vs = 0;                                                          \
        __bi_u->es = 0;                                                          \
        __bi_u->next = NULL


/*
 * Convenience: set opcode from an OpCodeType value or a variable.
 */
#define BI_OPCODE(o)         __bi_set_opcode(__bi_u, (o))

/*
 * Vector size / element size (call before BI_EXEC for vector ops).
 */
#define BI_VS(v)            __bi_set_vs(__bi_u, (v))
#define BI_VES(v)           __bi_set_ves(__bi_u, (v))

/*
 * Operand setters.  `idx` is the operand index.
 *
 * BI_SLOT_OUT(idx, op)  – slot operand, used as output
 * BI_SLOT_IN (idx, op)  – slot operand, used as input
 *   (both take an OperandType-compatible value; we extract .s fields)
 *
 * BI_IMM(idx, val)      – immediate
 * BI_LABEL(idx, lbl)     – branch label
 * BI_RELOP(idx, r)      – relop predicate
 * BI_XMM(idx, xmm_idx, xmm_off) – XMM register
 * BI_ENV(idx, off)       – env offset
 * BI_SYMBOL(idx, h)      – helper symbol
 */
#define BI_SLOT_OUT(idx, op)  __bi_set_slot(__bi_u, (idx), (op).s.slot_type, (op).s.slot_idx)
#define BI_SLOT_IN(idx, op)   __bi_set_slot(__bi_u, (idx), (op).s.slot_type, (op).s.slot_idx)
#define BI_IMM(idx, val)      __bi_set_imm(__bi_u, (idx), (uint64_t)(val))
#define BI_LABEL(idx, lbl)    __bi_set_label(__bi_u, (idx), (uint8_t)(lbl))
#define BI_RELOP(idx, r)      __bi_set_relop(__bi_u, (idx), (RelopType)(r))

#define BI_XMM(idx, xi, xo)   __bi_set_xmm(__bi_u, (idx), (uint8_t)(xi), (uint8_t)(xo))
#define BI_ENV(idx, off)      __bi_set_env(__bi_u, (idx), (uint16_t)(off))
#define BI_SYMBOL(idx, h)     __bi_set_symbol(__bi_u, (idx), (HelperType)(h))
#define BI_EXEC(fn, arg)      fn(__bi_u->opc, __bi_u, (arg))
#define BI_EXEC_DIRECT(fn)    fn(__bi_u->opc, __bi_u)
/*
 * BI_ATTR_STORAGE(atomic, align, ext, size)
 *   Builds an AttrSrcInfo of subtype SUB_ATTR_STORAGE and sets the operand.
 *   `atomic` : NONATOMIC or other atomic values
 *   `align`  : ALIGN_MEM_SIZE, ALIGN_8, etc.
 *   `ext`    : ZERO or SIGN
 *   `size`   : SRC1B .. SRC16B
 */
#define BI_ATTR_STORAGE(idx, at, al, et, sz)                      \
    do {                                                                   \
        AttrSrcInfo __bi_attr;                                             \
        __bi_attr.subt           = SUB_ATTR_STORAGE;                        \
        __bi_attr.p.storage.atomic    = (at);                           \
        __bi_attr.p.storage.alignment = (al);                            \
        __bi_attr.p.storage.ext       = (et);                               \
        __bi_attr.p.storage.size      = (sz);                              \
        __bi_set_attr(__bi_u, (idx), &__bi_attr);                         \
    } while (0)

/*
 * BI_ATTR_SWAP(flags)
 *   Builds an AttrSrcInfo of subtype SUB_ATTR_SWAP.
 *   `flags` : combination of IZ, OS, OZ bitmasks
 */
#define BI_ATTR_SWAP(idx, flags)                                            \
    do {                                                                   \
        AttrSrcInfo __bi_attr;                                             \
        __bi_attr.subt      = SUB_ATTR_SWAP;                               \
        __bi_attr.p.swap    = (flags);                                    \
        __bi_set_attr(__bi_u, (idx), &__bi_attr);                         \
    } while (0)

#endif /* BUILD_TEMP_INSTR_H */
