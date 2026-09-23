#ifndef __MAPPER_H__
#define __MAPPER_H__

#include <llvm-c/Core.h>
#include "operand.h"

typedef struct AllocaWithState {
    LLVMType *ty;
    LLVMValueRef *alloca;
    uint64_t *copy_valid;
    LLVMValueRef *copy;
    int *copy_idx;
} AllocaWithState;

typedef struct StackAlloca {
    AllocaWithState xreg;
    AllocaWithState vector;
    AllocaWithState tmp;
    LLVMValueRef carry;
    LLVMValueRef borrow;
    LLVMValueRef env;
} StackAlloca;

LLVMTypeRef get_llvm_type(LLVMType type);
LLVMValueRef build_store_with_alignment(LLVMBuilderRef B, LLVMValueRef Val, LLVMValueRef PointerVal, unsigned Bytes);
LLVMValueRef build_load_with_alignment(LLVMBuilderRef B, LLVMTypeRef Ty, LLVMValueRef PointerVal, const char *Name, unsigned Bytes);
LLVMValueRef get_input_val_for_operand(const Operand *op, StackAlloca *stack, OpCodeType opc, int cnt);
void do_store(const Operand *op, LLVMValueRef val, StackAlloca *stack, OpCodeType opc, int cnt);

#define GET_ALIGNMENT_FROM_TYPE(type)       (type <= LLVMInt64 ? 8 : 16)

#define GET_ALIGNMENT_FROM_OFFSET(off)      ((off) % 8 == 0 ? 8 : ((off) % 4 == 0 ? 4 : ((off) % 2 == 0 ? 2 : 1)))

#define OPC_FIRST_SCALAR_TYPE   LLVMInt8
#define OPC_VECTOR_TO_FIXED(T)      (((T - OPC_FIRST_SCALAR_TYPE) % 4) + OPC_FIRST_SCALAR_TYPE)

#endif
