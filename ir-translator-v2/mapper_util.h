#ifndef __MAPPER_UTIL_H
#define __MAPPER_UTIL_H

#include "tcg_ast.h"

extern const char *opcode_type_str[];
extern const char *attr_type_str[];
extern const char *envvar_type_str[];
extern const char *xreg_type_str[];
extern const char *relop_type_str[];
extern const char *helper_str[];
extern const char *alignment_type_str[];
extern const char *srcext_type_str[];
extern const char *slot_type_str[];
extern const char *llvm_type_str[];
extern const char *xmmreg_str[];
extern const char *cvector_str[];
extern const uint8_t opcoc[OPCODE_MAX];

static inline const Operand *get_operand(const UnifiedInstr *u, int idx) {
    assert(idx >= 0 && idx < u->operand_count);
    return &u->operands[idx];
}

static inline int helper_defines_output(const UnifiedInstr *u) {
    assert(u->is_helper);
    const Operand *op = get_operand(u, 2);
    assert(op->kind == OP_IMM);
    return op->imm;
}

static inline int get_first_in_op_idx(const UnifiedInstr *u) {
    return u->opc == call ? (helper_defines_output(u) + TCG_CALL_PREFIX_COUNT) : opcoc[u->opc];
}

static inline int get_first_out_op_idx(const UnifiedInstr *u) {
    if (u->opc == call) {
        if (helper_defines_output(u)) {
            return TCG_CALL_PREFIX_COUNT;
        }
    } else if (opcoc[u->opc]) {
        return 0;
    }
    // does not define output, return invalid index
    return u->operand_count;
}

static inline OpCodeType get_opcode(const UnifiedInstr *u) {
    return u->opc;
}

static inline HelperType get_helper(const UnifiedInstr *u) {
    assert(u->is_helper);
    const Operand *op0 = get_operand(u, 0);
    assert(op0->kind == OP_SYMBOL);
    return op0->symbol;
}

static inline bool is_vector(const UnifiedInstr *u) {
    return u->vs != 0;
}

static inline LLVMType get_llvm_vector_type(const UnifiedInstr *u) {
    if (u->vs == 64) {
      switch (u->es) {
      case 8: return LLVMVector8xi8;
      case 16: return LLVMVector4xi16;
      case 32: return LLVMVector2xi32;
      case 64: return LLVMVector1xi64;
      default: assert(0);
      }
    }
    if (u->vs == 128) {
      switch (u->es) {
      case 8: return LLVMVector16xi8;
      case 16: return LLVMVector8xi16;
      case 32: return LLVMVector4xi32;
      case 64: return LLVMVector2xi64;
      default: assert(0);
      }
    }
    assert(0);
}

static inline uint8_t get_label_from_instr(const UnifiedInstr *u) {
    assert(u->operand_count > 0);
    const Operand *op = get_operand(u, (u->operand_count - 1));
    assert(op->kind == OP_LABEL);
    return op->label;
}

static inline const AttrSrcInfo *get_attribute_from_instr(const UnifiedInstr *u) {
    for (int i = 0; i < u->operand_count; i++) {
        if (u->operands[i].kind == OP_ATTR)
            return &u->operands[i].attr_info;
    }
    return NULL;
}

/* Search for a RELOP operand anywhere in the instruction */
static inline RelopType get_relop_from_any_operand(const UnifiedInstr *u) {
    for (int i = 0; i < u->operand_count; i++) {
        if (u->operands[i].kind == OP_RELOP)
            return u->operands[i].relop;
    }
    assert(0 && "relop not found");
    return 0;
}

static inline OperandType get_operand_legacy(const UnifiedInstr *u, int idx, uint32_t *is_imm) {
    OperandType ret;
    *is_imm = 0;
    ret.s.valid = 0;
    if (idx >= u->operand_count) {
        return ret;
    }
    const Operand *op = get_operand(u, idx);
    if (op->kind == OP_IMM) {
        *is_imm = 1;
        ret.i = op->imm;
    } else {
        *is_imm = 0;
        switch (op->kind) {
        case OP_SLOT:
            ret.s.valid = 1;
            ret.s.slot_type = op->slot.type;
            ret.s.slot_idx = op->slot.idx;
            ret.s.offset = 0;
            break;
        case OP_XMM:
            ret.s.valid = 1;
            ret.s.slot_type = SUB_SLOT_XMM;
            ret.s.slot_idx = op->xmm.xmm_idx;
            ret.s.offset = op->xmm.xmm_offset;
            break;
        case OP_ENV:
            ret.s.valid = 1;
            ret.s.slot_type = SUB_SLOT_ENV;
            ret.s.slot_idx = 0;
            ret.s.offset = op->env.env_offset;
            break;
        default:
            // invalid operand e.g. RELOP,ATTR
            break;
        }
    }
    return ret;
}

#endif
