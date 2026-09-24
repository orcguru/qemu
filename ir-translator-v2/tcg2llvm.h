#ifndef __TCG2LLVM_H__
#define __TCG2LLVM_H__

#include "tcg_ast.h"
#include <llvm-c/Core.h>
#include "mapper.h"
#include "tcg_context.h"

void translate_batch(LLVMModuleRef module, LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, FuncInstrList *f);

#endif
