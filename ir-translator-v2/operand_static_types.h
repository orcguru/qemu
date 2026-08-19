#ifndef __OPERAND_STATIC_TYPES_H
#define __OPERAND_STATIC_TYPES_H

#include "tcg_ast.h"

extern const LLVMType opciosz[OPCODE_MAX][2];
extern const uint8_t opcmem_addr_nzidx[OPCODE_MAX];
extern const LLVMType helper_collapse_xmm_arg_type[HELPER_MAX][MAX_ADDED_ARGS];
extern const LLVMType helper_return_type[HELPER_MAX];

#endif
