#ifndef UNIFIED_INSTR_H
#define UNIFIED_INSTR_H

#include <stdint.h>
#include <stdbool.h>
#include "operand.h"

typedef struct {
    OpCodeType  opc;
    bool        is_helper;
    bool        noargs;
    uint8_t     vs;             // 0 = scalar
    uint8_t     es;             // ignored if vs == 0

    uint8_t     operand_count;
    Operand     operands[];     // flexible array member
} UnifiedInstr;

#endif
