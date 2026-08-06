#ifndef OPERAND_H
#define OPERAND_H

#include <stdint.h>
#include <stdbool.h>
#include "tcg_ast.h"

typedef enum {
    OP_SLOT,
    OP_IMM,
    OP_LABEL,
    OP_RELOP,
    OP_ATTR,
    OP_SYMBOL,
    OP_XMM,
    OP_ENV,
} OperandKind;

typedef struct {
    SlotType type;
    uint16_t idx;
} SlotInfo;

typedef struct {
    uint8_t xmm_idx;
    uint8_t xmm_offset;
} XmmInfo;

typedef struct {
    OperandKind kind;
    union {
        SlotInfo   slot;
        uint64_t   imm;
        uint16_t   label;
        RelopType  relop;
        AttrSrcInfo attr_info;
        HelperType symbol;
        XmmInfo    xmm;
        uint16_t   env_offset;
    };
} Operand;

typedef struct {
    Operand *data;
    int      len;
    int      cap;
} OpList;

#endif
