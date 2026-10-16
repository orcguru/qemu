#ifndef __MAPPER_H__
#define __MAPPER_H__

#include <llvm-c/Core.h>
#include "operand.h"
#include "tcg_context.h"

typedef struct AllocaWithState {
    LLVMValueRef    *alloca;
    LLVMType        *tcg_ty;
    LLVMTypeRef     *llvm_ty;
    unsigned        *align;
    LLVMValueRef    *f_argument;
    int             cnt;
} AllocaWithState;

typedef struct StackAlloca {
    AllocaWithState xreg;
    AllocaWithState vector;
    AllocaWithState tmp;
    LLVMValueRef carry;
    LLVMValueRef borrow;
    LLVMValueRef env;
    LLVMValueRef arg_last;
} StackAlloca;

typedef enum TagType {
    CPU_TAG,
    GUEST_TAG,
    SPILL_TAG
} TagType;

typedef struct {
    LLVMValueRef cpu_tag;
    LLVMValueRef guest_tag;
    LLVMValueRef spill_tag;
    unsigned     kind;          /* MDKindID of "tbaa" */
} TBAA;

LLVMTypeRef get_llvm_type(LLVMType type);
LLVMValueRef get_intrinsic_declaration(const char *intrinsic_name, LLVMTypeRef *intrinsic_types, int cnt);
LLVMValueRef get_const_vector(unsigned long c, LLVMType ty);
LLVMValueRef build_store_with_alignment(LLVMBuilderRef B, LLVMValueRef Val, LLVMValueRef PointerVal, unsigned Bytes, TagType tag_ty);
LLVMValueRef build_load_with_alignment(LLVMBuilderRef B, LLVMTypeRef Ty, LLVMValueRef PointerVal, const char *Name, unsigned Bytes, TagType tag_ty);
LLVMValueRef get_input_val_for_operand(const Operand *op, StackAlloca *stack, const char *prefix);
void do_store(const Operand *op, LLVMValueRef val, StackAlloca *stack, const char *prefix, bool skip_env_check);
void start_llvm_bb(LLVMBasicBlockRef bb, StackAlloca *stack);
LLVMValueRef get_env();
LLVMValueRef shrink_llvm_value(LLVMValueRef val, LLVMType from, LLVMType to);
LLVMValueRef get_or_add_func_with_qemuaot_cc(const char *name, unsigned long hex_offset, int sub_idx);
LLVMValueRef get_or_add_helper_with_qemuaot_cc(HelperType h, const UnifiedInstr *u);
LLVMValueRef get_or_add_func_with_default_cc(HelperType h, const UnifiedInstr *u);
LLVMValueRef load_from_stack_as_type(AllocaWithState *as, int idx, LLVMType ty, const char *prefix, const char *reg_name);
char *get_func_name(unsigned long hex_offset, int sub_idx, char *buf, int buf_size);

#define GET_ALIGNMENT_FROM_TYPE(type)       (type <= LLVMInt64 ? 8 : 16)

#define GET_ALIGNMENT_FROM_OFFSET(off)      ((off) % 16 == 0 ? 16 : ((off) % 8 == 0 ? 8 : ((off) % 4 == 0 ? 4 : ((off) % 2 == 0 ? 2 : 1))))

#define OPC_FIRST_SCALAR_TYPE   LLVMInt8
#define OPC_VECTOR_TO_FIXED(T)      (((T - OPC_FIRST_SCALAR_TYPE) % 4) + OPC_FIRST_SCALAR_TYPE)

#endif
