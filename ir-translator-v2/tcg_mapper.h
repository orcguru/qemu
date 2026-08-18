#ifndef __TCG_MAPPER_H
#define __TCG_MAPPER_H

#include "tcg_ast.h"
#include "unified_instr.h"

void reset_tmp_mapping();
XMMReg lookup_xmm_map(uint64_t offset);

void *get_instr_buffer();
size_t get_instr_buffer_size();
void reset_instr_buffer(void);
void module_prolog(void);
void module_epilog(void);
void insert_instr(void *ptr_src, size_t sz);
uint64_t get_xmm_offset(uint64_t idx);

typedef LLVMValueRef (*LLVM_BIN_API)(LLVMBuilderRef B, LLVMValueRef LHS, LLVMValueRef RHS, const char *Name);
typedef LLVMValueRef (*LLVM_EXT_API)(LLVMBuilderRef B, LLVMValueRef Val, LLVMTypeRef DestTy, const char *Name);

void translate_add_i64(OpCodeType opc, const UnifiedInstr *u);
void translate_andc_i64(OpCodeType opc, const UnifiedInstr *u);
void translate_andc_vec(OpCodeType opc, const UnifiedInstr *u);
void translate_bswap32_i64(OpCodeType opc, const UnifiedInstr *u);
void translate_clz_i64(OpCodeType opc, const UnifiedInstr *u);
void translate_cmp_vec(OpCodeType opc, const UnifiedInstr *u);
void translate_ctz_i64(OpCodeType opc, const UnifiedInstr *u);
void translate_dupm_vec(OpCodeType opc, const UnifiedInstr *u);
void translate_extract2_i64(OpCodeType opc, const UnifiedInstr *u);
void translate_extract(OpCodeType opc, const UnifiedInstr *u);
void translate_ld_vec(OpCodeType opc, const UnifiedInstr *u);
void translate_negsetcond_i64(OpCodeType opc, const UnifiedInstr *u);
void translate_not(OpCodeType opc, const UnifiedInstr *u);
void translate_push_ret_addr(OpCodeType opc, const UnifiedInstr *u);
void translate_qemu_ld2_i128(OpCodeType opc, const UnifiedInstr *u);
void translate_qemu_ld(OpCodeType opc, const UnifiedInstr *u);
void translate_qemu_st2_i128(OpCodeType opc, const UnifiedInstr *u);
void translate_qemu_st(OpCodeType opc, const UnifiedInstr *u);
void translate_ret(OpCodeType opc, const UnifiedInstr *u);
void translate_rotr(OpCodeType opc, const UnifiedInstr *u);
void translate_rotl(OpCodeType opc, const UnifiedInstr *u);
void translate_setcond_i64(OpCodeType opc, const UnifiedInstr *u);
void translate_sextract_i64(OpCodeType opc, const UnifiedInstr *u);
void translate_st(OpCodeType opc, const UnifiedInstr *u);
void translate_bswap64_i64(OpCodeType opc, const UnifiedInstr *u);
void translate_set_label(OpCodeType opc, const UnifiedInstr *u);
void translate_set_label_fix_branch(OpCodeType opc, const UnifiedInstr *u);
void translate_brcond_i64(OpCodeType opc, const UnifiedInstr *u);
void translate_jmp_direct(OpCodeType opc, const UnifiedInstr *u);
void translate_discard(OpCodeType opc, const UnifiedInstr *u);
void translate_tail_call(OpCodeType opc, const UnifiedInstr *u);
void translate_dump_call(OpCodeType opc, const UnifiedInstr *u, uint32_t is_dump_registers);
void translate_call(OpCodeType opc, const UnifiedInstr *u);
void translate_ld_env_xmm(OpCodeType opc, const UnifiedInstr *u);
void translate_movcond(OpCodeType opc, const UnifiedInstr *u);
void translate_mulxh(OpCodeType opc, const UnifiedInstr *u, LLVM_EXT_API api);
void translate_binary(OpCodeType opc, const UnifiedInstr *u, LLVM_BIN_API api);
void translate_binary_splat_immediate(OpCodeType opc, const UnifiedInstr *u, LLVM_BIN_API api);
void translate_setcond(OpCodeType opc, const UnifiedInstr *u);
extern OperandType get_original_slot_for_debug(OperandType tmp);

#endif
