#ifndef __MAPPER_H__
#define __MAPPER_H__

#include <llvm-c/Core.h>
#include "operand.h"

typedef struct AllocaWithState {
    LLVMType *ty;
    LLVMValueRef *alloca;
    uint64_t *copy_valid;
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

LLVMValueRef get_input_val_for_operand(const Operand *op);

LLVMTypeRef get_llvm_type(LLVMType type);
LLVMValueRef build_store_with_alignment(LLVMBuilderRef B, LLVMValueRef Val, LLVMValueRef PointerVal, unsigned Bytes);
LLVMValueRef build_load_with_alignment(LLVMBuilderRef B, LLVMTypeRef Ty, LLVMValueRef PointerVal, const char *Name, unsigned Bytes);
void do_store(const Operand *op, LLVMValueRef val, StackAlloca *stack, OpCodeType opc, int cnt);

#define GET_ALIGNMENT_FROM_CONSTANT(c)      ((c) % 8 == 0 ? 8 : ((c) % 4 == 0 ? 4 : ((c) % 2 == 0 ? 2 : 1)))

#endif
