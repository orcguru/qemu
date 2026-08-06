#ifndef OPERAND_H
#define OPERAND_H

#include <stdint.h>
#include <stdbool.h>

typedef enum {
    OP_SLOT,
    OP_IMM,
    OP_IMMD,
    OP_LABEL,
    OP_RELOP,
    OP_ATTR,
    OP_SYMBOL,
    OP_XMM,
    OP_ENV,
} OperandKind;

typedef struct {
    uint8_t type;   /* 2 bits */
    uint16_t idx;   /* 10 bits */
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
        uint8_t    relop;
        uint8_t    attr;
        char      *symbol;
        XmmInfo    xmm;
        uint16_t   env_offset;
    };
} Operand;

#endif
