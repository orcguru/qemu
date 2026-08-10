#ifndef UNIFIED_INSTR_H
#define UNIFIED_INSTR_H

#include <stdint.h>
#include <stdbool.h>
#include "operand.h"

typedef struct UnifiedInstr {
    uint8_t  opc;
    bool     is_helper;
    bool     noargs;
    uint8_t  vs;
    uint8_t  es;
    struct UnifiedInstr *next;
    uint8_t  operand_count;
    Operand  operands[];
} UnifiedInstr;

#endif
