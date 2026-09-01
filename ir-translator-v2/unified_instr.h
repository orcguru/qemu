#ifndef UNIFIED_INSTR_H
#define UNIFIED_INSTR_H

#include <stdint.h>
#include <stdbool.h>
#include "operand.h"

typedef struct __attribute__((packed)) UnifiedInstr {
    uint8_t  opc;
    bool     is_helper;
    union {
        struct {
            uint8_t  vs;
            uint8_t  es;
        };
        uint16_t helper_index;
    };
    uint32_t uidx;
    struct UnifiedInstr *prev;
    struct UnifiedInstr *next;
    uint8_t  operand_count;
    Operand  operands[];
} UnifiedInstr;

#endif
