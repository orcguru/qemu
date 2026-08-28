#ifndef OPERAND_H
#define OPERAND_H

#include <stdint.h>
#include <stdbool.h>
#include "tcg_ast.h"

typedef enum __attribute__((packed)) {
    OP_INVALID,
    OP_SLOT,
    OP_IMM,
    OP_LABEL,
    OP_RELOP,
    OP_ATTR,
    OP_SYMBOL,
    OP_XMM,
    OP_ENV,
    OP_NEXT,
    OP_TRAMPOLINE,
} OperandKind;

typedef struct __attribute__((packed)) {
    SlotType type;
    uint16_t idx;
    LLVMType op_type;
    LLVMType stack_type;
} SlotInfo;

typedef struct __attribute__((packed)) {
    uint8_t xmm_idx;
    uint8_t xmm_offset;
    LLVMType op_type;
    LLVMType stack_type;
} XmmInfo;

typedef struct __attribute__((packed)) {
    uint16_t env_offset;
    LLVMType op_type;
    LLVMType stack_type;
} EnvInfo;

typedef struct __attribute__((packed)) {
    OperandKind kind;
    union {
        SlotInfo   slot;
        XmmInfo    xmm;
        EnvInfo    env;
        uint64_t   imm;
        uint16_t   label;
        RelopType  relop;
        AttrSrcInfo attr_info;
        HelperType symbol;
        // next FuncInstrList index
        uint16_t   nfidx;
        // trampoline FuncInstrList index
        uint16_t   tfidx;
    };
} Operand;

typedef struct {
    Operand *data;
    int      len;
    int      cap;
} OpList;

#endif
