#ifndef __OPERAND_STATIC_TYPES_H
#define __OPERAND_STATIC_TYPES_H

#include "tcg_ast.h"

extern const LLVMType opciosz[OPCODE_MAX][2];
extern const uint8_t opcmem_addr_nzidx[OPCODE_MAX];
extern const LLVMType helper_template_arg_type[HELPER_MAX][MAX_ADDED_ARGS];
extern const char *helper_template_arg_name[HELPER_MAX][MAX_ADDED_ARGS];
extern const char *helper_runtime_arg_name[MAX_ADDED_ARGS];
extern const char *qemuaot_default_param_name[XREG_MAX + 2 * XMM_COUNT_MAX];
extern const char *qemuaot_default_stack_alloca_name[XREG_MAX + 2 * XMM_COUNT_MAX];
extern const LLVMType qemuaot_default_param_type[XREG_MAX + 2 * XMM_COUNT_MAX];
extern const LLVMType helper_return_type[HELPER_MAX];

#endif
