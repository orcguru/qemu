#include <stdio.h>
#include <limits.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <llvm-c/Core.h>
#include <llvm-c/Target.h>
#include <llvm-c/TargetMachine.h>
#include <llvm-c/Transforms/PassBuilder.h>
#include <llvm-c/BitReader.h>
#include <llvm-c/Linker.h>
#include <llvm-c/Support.h>
#include <stdbool.h>
#include <glib.h>
#include "tcg_ast.h"
#include "tcg_context.h"
#include "parser.tab.h"
#include "lexer.yy.h"
#include "mapper_util.h"
#include "util.h"
#include "operand_static_types.h"
#include "mapper.h"
#include "tcg2llvm.h"

#define LLVMNoInlineAttribute       32
#define LLVMAlwaysInlineAttribute   3
#define QEMUAOT_CC                  124

extern char *lineptr;
int cfg_xmm_count = XMM_COUNT;
void debug_print_instr(TcgContext *ctx, const char *msg) {}

char *g_template_path = NULL;
/* Set by '-d': dump the mapped LLVM-IR module and stop before compilation */
int g_dump_ir = 0;
LLVMTargetMachineRef g_target_machine = NULL;
LLVMModuleRef g_module = NULL;
LLVMBuilderRef g_builder = NULL;
LLVMAttributeRef g_attr_target_features = NULL;
LLVMAttributeRef g_attr_noinline = NULL;
LLVMAttributeRef g_attr_alwaysinline = NULL;
LLVMAttributeRef g_attr_nounwind = NULL;

LLVMValueRef get_stack_or_copy(AllocaWithState *as, int idx, const char *base_name) {
    LLVMValueRef val = NULL;
    char var_name[32] = {0};
    if (test_bit(as->copy_valid, idx)) {
        val = as->copy[idx];
        assert(val);
    } else {
        val = build_load_with_alignment(g_builder, get_llvm_type(as->ty[idx]), as->alloca[idx], assemble_name_2(&var_name[0], sizeof(var_name), base_name, "val", as->copy_idx[idx]), GET_ALIGNMENT_FROM_TYPE(as->ty[idx]));
        as->copy_idx[idx] += 1;
        as->copy[idx] = val;
        set_bit(as->copy_valid, idx);
    }
    return val;
}

LLVMValueRef shrink_llvm_value(LLVMValueRef val, LLVMType from, LLVMType to) {
    assert(to < from);
    char var_name[32] = {0};
    if (from <= LLVMInt64) {
        return LLVMBuildTrunc(g_builder, val, get_llvm_type(to), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "trunc", 0));
    }
    if ((llvm_vector_elem_bit_counts[from * 2] * llvm_vector_elem_bit_counts[from * 2 + 1]) == (llvm_vector_elem_bit_counts[to * 2] * llvm_vector_elem_bit_counts[to * 2 + 1])) {
        return LLVMBuildBitCast(g_builder, val, get_llvm_type(to), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc", 0));
    }
    assert((llvm_vector_elem_bit_counts[from * 2] * llvm_vector_elem_bit_counts[from * 2 + 1]) % (llvm_vector_elem_bit_counts[to * 2] * llvm_vector_elem_bit_counts[to * 2 + 1]) == 0);
    int elem_cnt = (llvm_vector_elem_bit_counts[from * 2] * llvm_vector_elem_bit_counts[from * 2 + 1]) / (llvm_vector_elem_bit_counts[to * 2] * llvm_vector_elem_bit_counts[to * 2 + 1]);
    int elem_bits = (llvm_vector_elem_bit_counts[to * 2] * llvm_vector_elem_bit_counts[to * 2 + 1]);
    LLVMType bc_ty = LLVMInvalidType;
    LLVMType elem_ty = LLVMInvalidType;
    // FIXME: can this be calculated?
    for (LLVMType ty = LLVMVector8xi8; ty < LLVMMAXType; ++ty) {
        if (llvm_vector_elem_bit_counts[ty * 2] == elem_cnt && llvm_vector_elem_bit_counts[ty * 2 + 1] == elem_bits) {
            bc_ty = ty;
            break;
        }
    }
    for (LLVMType ty = LLVMInvalidType; ty < LLVMVector8xi8; ++ty) {
        if (llvm_vector_elem_bit_counts[ty * 2 + 1] == elem_bits) {
            elem_ty = ty;
            break;
        }
    }
    assert(bc_ty != LLVMInvalidType && elem_ty != LLVMInvalidType);
    val = LLVMBuildBitCast(g_builder, val, get_llvm_type(bc_ty), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc", 0));
    LLVMValueRef index = LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0);
    val = LLVMBuildExtractElement(g_builder, val, index, assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "elem", 0));
    if (elem_ty != to) {
        val = LLVMBuildBitCast(g_builder, val, get_llvm_type(to), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc", 0));
    }
    return val;
}

LLVMValueRef get_input_val_for_operand(const Operand *op, StackAlloca *stack, OpCodeType opc, int cnt) {
    LLVMValueRef val = NULL;
    char var_name[32] = {0};
    if (op->kind == OP_IMM) {
        LLVMType ty = op->imm.op_type;
        assert(ty != LLVMInvalidType);
        if (ty <= LLVMInt64) {
            val = LLVMConstInt(get_llvm_type(ty), op->imm.val, 0);
            return val;
        } else {
            LLVMValueRef constants[16];
            int elem_cnt = llvm_vector_elem_bit_counts[ty * 2];
            uint64_t imm = op->imm.val;
            int elem_half_cnt = llvm_vector_elem_bit_counts[ty * 2] / 2;
            int bit_cnt = llvm_vector_elem_bit_counts[ty * 2 + 1];
            for (int i = 0; i < elem_cnt; i++) {
                if (i == elem_half_cnt) {
                    imm = op->imm.val;
                }
                constants[i] = LLVMConstInt(get_llvm_type(OPC_VECTOR_TO_FIXED(ty)), bit_cnt < 64 ? (imm & ((1UL << bit_cnt) - 1)) : imm, 0);
                imm = imm >> bit_cnt;
            }
            val = LLVMConstVector(constants, elem_cnt);
            return val;
            // FIXME: scalable vector
        }
    } else if ((op->kind == OP_SLOT && op->slot.type == SUB_SLOT_ENVVAR) || op->kind == OP_ENV) {
        assert(op->kind != OP_ENV || op->env.offset != 0);
        LLVMType op_ty = op->kind == OP_SLOT ? op->slot.op_type : op->env.op_type;
        LLVMValueRef offset = LLVMConstInt(get_llvm_type(LLVMInt64), op->kind == OP_SLOT ? envvar_offsets[op->slot.idx] : op->env.offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(g_builder, stack->env, offset, assemble_name_3(&var_name[0], sizeof(var_name), "addr", op->kind == OP_SLOT ? envvar_type_str[op->slot.idx] : "envoff", opcode_type_str[opc], cnt));
        LLVMValueRef ptr = LLVMBuildIntToPtr(g_builder, addr, LLVMPointerType(get_llvm_type(op_ty), 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(addr), "ptr", 0));
        val = build_load_with_alignment(g_builder, get_llvm_type(op_ty), ptr, assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(addr), "val", 0), op->kind == OP_SLOT ? 8 : GET_ALIGNMENT_FROM_OFFSET(op->env.offset));
        return val;
    } else if (op->kind == OP_VEC) {
        val = get_stack_or_copy(&stack->vector, op->vec.idx, qemuaot_default_stack_alloca_name[XREG_MAX + op->vec.idx]);
        if (op->vec.offset == 0) {
            if (op->vec.op_type != stack->vector.ty[op->vec.idx]) {
                val = shrink_llvm_value(val, stack->vector.ty[op->vec.idx], op->vec.op_type);
            }
            return val;
        }
        // Vectors do not have non-zero offset
        assert(op->vec.op_type <= LLVMInt64);
        assert(op->vec.offset % ((llvm_vector_elem_bit_counts[op->vec.op_type * 2 + 1] / 8)) == 0);
        LLVMValueRef index = LLVMConstInt(get_llvm_type(LLVMInt64), (op->vec.offset / ((llvm_vector_elem_bit_counts[op->vec.op_type * 2 + 1] / 8))), 0);
        if (((stack->vector.ty[op->vec.idx] - op->vec.op_type) % 4) != 0) {
            val = LLVMBuildBitCast(g_builder, val, get_llvm_type(op->vec.op_type + LLVMVector16xi8 - LLVMInt8), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc", 0));
        }
        // FIXME: scalable vector
        val = LLVMBuildExtractElement(g_builder, val, index, assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "elem", 0));
        return val;
    } else if (op->kind == OP_SLOT) {
        assert(op->slot.type == SUB_SLOT_XREG || op->slot.type == SUB_SLOT_TMP);
        char *p_name = NULL;
        if (op->slot.type == SUB_SLOT_TMP) {
            sprintf(&var_name[0], "tmp%d.stack", (op->slot.idx & 0xffff));
            p_name = &var_name[0];
        } else {
            p_name = qemuaot_default_stack_alloca_name[op->slot.idx];
        }
        val = get_stack_or_copy(op->slot.type == SUB_SLOT_TMP ? &stack->tmp : &stack->xreg, op->slot.idx, p_name);
        LLVMType stack_ty = op->slot.type == SUB_SLOT_TMP ? stack->tmp.ty[op->slot.idx] : stack->xreg.ty[op->slot.idx];
        assert(op->slot.op_type <= stack_ty);
        if (op->slot.op_type != stack_ty) {
            val = shrink_llvm_value(val, stack_ty, op->slot.op_type);
        }
        return val;
    }
    assert(0);
}

LLVMTypeRef get_llvm_type(LLVMType type) {
    LLVMTypeRef ty = NULL;
    switch (type) {
        case LLVMInt8: ty = LLVMInt8Type(); break;
        case LLVMInt16: ty = LLVMInt16Type(); break;
        case LLVMInt32: ty = LLVMInt32Type(); break;
        case LLVMInt64: ty = LLVMInt64Type(); break;
#if defined(__aarch64__)
        case LLVMVector8xi8: ty = LLVMVectorType(LLVMInt8Type(), 8); break;
        case LLVMVector4xi16: ty = LLVMVectorType(LLVMInt16Type(), 4); break;
        case LLVMVector2xi32: ty = LLVMVectorType(LLVMInt32Type(), 2); break;
        case LLVMVector1xi64: ty = LLVMVectorType(LLVMInt64Type(), 1); break;
        case LLVMVector16xi8: ty = LLVMVectorType(LLVMInt8Type(), 16); break;
        case LLVMVector8xi16: ty = LLVMVectorType(LLVMInt16Type(), 8); break;
        case LLVMVector4xi32: ty = LLVMVectorType(LLVMInt32Type(), 4); break;
        case LLVMVector2xi64: ty = LLVMVectorType(LLVMInt64Type(), 2); break;
#elif (defined(__riscv) && __riscv_xlen == 64)
        case LLVMVector8xi8:
        case LLVMVector16xi8:
            ty = LLVMScalableVectorType(LLVMInt8Type(), 8); break;
        case LLVMVector4xi16:
        case LLVMVector8xi16:
            ty = LLVMScalableVectorType(LLVMInt16Type(), 4); break;
        case LLVMVector2xi32:
        case LLVMVector4xi32:
            ty = LLVMScalableVectorType(LLVMInt32Type(), 2); break;
        case LLVMVector1xi64:
        case LLVMVector2xi64:
            ty = LLVMScalableVectorType(LLVMInt64Type(), 1); break;
#endif
        default: assert(0);
    }
    return ty;
}

/*
 * Notice: LLVMInt128 store not supported
 */
void do_store(const Operand *op, LLVMValueRef val, StackAlloca *stack, OpCodeType opc, int cnt) {
    char var_name[32] = {0};
    if ((op->kind == OP_SLOT && op->slot.type == SUB_SLOT_TMP) || op->kind == OP_VEC) {
        LLVMType val_ty = get_operand_type(op);
        LLVMType stack_ty = op->kind == OP_SLOT ? stack->tmp.ty[op->slot.idx] : stack->vector.ty[op->vec.idx];
        assert(val_ty != LLVMInvalidType && stack_ty != LLVMInvalidType);
        assert((val_ty <= LLVMInt64 && stack_ty <= LLVMInt64 && val_ty <= stack_ty) ||
               (val_ty <= LLVMInt64 && stack_ty > LLVMInt64) ||
               (val_ty > LLVMInt64 && stack_ty > LLVMInt64));
        if (val_ty <= LLVMInt64 && stack_ty <= LLVMInt64 && val_ty < stack_ty) {
            val = LLVMBuildZExt(g_builder, val, get_llvm_type(stack_ty), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "zext", 0));
        } else if ((val_ty <= LLVMInt64 && stack_ty > LLVMInt64) || (val_ty <= LLVMVector1xi64 && stack_ty > LLVMVector1xi64)) {
            // Store overwrite the whole content of vector type with zero background
            assert(op->kind != OP_VEC || (op->vec.offset * 8) % (llvm_vector_elem_bit_counts[val_ty * 2] * llvm_vector_elem_bit_counts[val_ty * 2 + 1]) == 0);
            int elem_cnt = (llvm_vector_elem_bit_counts[stack_ty * 2] * llvm_vector_elem_bit_counts[stack_ty * 2 + 1]) / (llvm_vector_elem_bit_counts[val_ty * 2] * llvm_vector_elem_bit_counts[val_ty * 2 + 1]);
            LLVMValueRef constants[16];
            if (val_ty > LLVMInt64) {
                if (val_ty != LLVMVector1xi64) {
                    val = LLVMBuildBitCast(g_builder, val, get_llvm_type(LLVMVector1xi64), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc", 0));
                }
                LLVMValueRef index = LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0);
                val = LLVMBuildExtractElement(g_builder, val, index, assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "val", 0));
                val_ty = LLVMInt64;
            }
            LLVMValueRef element_value = LLVMConstInt(get_llvm_type(val_ty), 0, 0);
            for (int i = 0; i < elem_cnt; i++) {
                constants[i] = element_value;
            }
            LLVMValueRef vec_zero = LLVMConstVector(constants, elem_cnt);
            LLVMValueRef index = LLVMConstInt(get_llvm_type(LLVMInt64), op->kind == OP_SLOT ? 0 : ((op->vec.offset * 8) / llvm_vector_elem_bit_counts[val_ty * 2 + 1]), 0);
            val = LLVMBuildInsertElement(g_builder, vec_zero, val, index, assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "vec", 0));
            if (((stack_ty - val_ty) % 4) != 0) {
                val = LLVMBuildBitCast(g_builder, val, get_llvm_type(stack_ty), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc", 0));
            }
        } else if (val_ty > LLVMInt64 && stack_ty > LLVMInt64 && val_ty != stack_ty) {
            assert((llvm_vector_elem_bit_counts[val_ty * 2] * llvm_vector_elem_bit_counts[val_ty * 2 + 1]) ==
                (llvm_vector_elem_bit_counts[stack_ty * 2] * llvm_vector_elem_bit_counts[stack_ty * 2 + 1]));
            val = LLVMBuildBitCast(g_builder, val, get_llvm_type(stack_ty), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc", 0));
        } else {
            assert(val_ty == stack_ty);
        }
        build_store_with_alignment(g_builder, val, op->kind == OP_SLOT ? stack->tmp.alloca[op->slot.idx] : stack->vector.alloca[op->vec.idx], GET_ALIGNMENT_FROM_TYPE(stack_ty));
        return;
    }
    if (op->kind == OP_SLOT && op->slot.type == SUB_SLOT_XREG) {
        build_store_with_alignment(g_builder, val, stack->xreg.alloca[op->slot.idx], GET_ALIGNMENT_FROM_TYPE(stack->xreg.ty[op->slot.idx]));
        return;
    }
    if ((op->kind == OP_SLOT && op->slot.type == SUB_SLOT_ENVVAR) || op->kind == OP_ENV) {
        LLVMValueRef offset = LLVMConstInt(get_llvm_type(LLVMInt64), op->kind == OP_SLOT ? envvar_offsets[op->slot.idx] : op->env.offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(g_builder, stack->env, offset, assemble_name_3(&var_name[0], sizeof(var_name), "addr", op->kind == OP_SLOT ? envvar_type_str[op->slot.idx] : "envoff", opcode_type_str[opc], cnt));
        build_store_with_alignment(g_builder, val, addr, op->kind == OP_SLOT ? GET_ALIGNMENT_FROM_TYPE(op->slot.op_type) : GET_ALIGNMENT_FROM_OFFSET(op->env.offset));
        return;
    }
    assert(0);
}

static LLVMValueRef get_or_add_func_with_qemuaot_cc(const char *name, FuncInstrList *f, int with_ret) {
    // Trampoline may have already been defined
    LLVMValueRef F = LLVMGetNamedFunction(g_module, name);
    if (!F) {
        LLVMTypeRef arg_types[XREG_MAX + 2 * XMM_COUNT_MAX + MAX_ADDED_ARGS] = {NULL};
        int arg_cnt = 0;
        for (int i = 0; i < (XREG_MAX + 2 * XMM_COUNT_MAX); ++i) {
            arg_types[arg_cnt++] = get_llvm_type(qemuaot_default_param_type[i]);
        }
        for (int i = 0; i < f->added_param_count; ++i) {
            arg_types[arg_cnt++] = get_llvm_type(f->added_param_type[i]);
        }
        LLVMTypeRef f_type = LLVMFunctionType(LLVMVoidType(), arg_types, arg_cnt, 0);
        F = LLVMAddFunction(g_module, name, f_type);
        LLVMAddAttributeAtIndex(F, -1, g_attr_target_features);
        LLVMAddAttributeAtIndex(F, -1, g_attr_nounwind);
        LLVMSetFunctionCallConv(F, QEMUAOT_CC);
        char sec_name[128] = {0};
        sprintf(sec_name, ".text.%s", name);
        LLVMSetSection(F, sec_name);
        for (int i = 0; i < (XREG_MAX + 2 * XMM_COUNT_MAX); ++i) {
            LLVMSetValueName(LLVMGetParam(F, i), qemuaot_default_param_name[i]);
        }
        for (int i = 0, arg_idx = (XREG_MAX + 2 * XMM_COUNT_MAX); i < f->added_param_count; ++i, ++arg_idx) {
            LLVMSetValueName(LLVMGetParam(F, arg_idx), f->added_param_name[i]);
        }
    }
    return F;
}

LLVMValueRef build_store_with_alignment(LLVMBuilderRef B, LLVMValueRef Val, LLVMValueRef PointerVal, unsigned Bytes) {
    LLVMValueRef ST = LLVMBuildStore(B, Val, PointerVal);
    LLVMSetAlignment(ST, Bytes);
    return ST;
}

LLVMValueRef build_load_with_alignment(LLVMBuilderRef B, LLVMTypeRef Ty, LLVMValueRef PointerVal, const char *Name, unsigned Bytes) {
    LLVMValueRef LD = LLVMBuildLoad2(B, Ty, PointerVal, Name);
    LLVMSetAlignment(LD, Bytes);
    return LD;
}

LLVMValueRef get_env() {
    LLVMTypeRef empty[] = {};
    LLVMTypeRef asm_function_type = LLVMFunctionType(get_llvm_type(LLVMInt64), empty, 0, 0);
    char asm_string[128];
#if defined(__aarch64__)
    sprintf(asm_string, "mov $0, x25");
#elif (defined(__riscv) && __riscv_xlen == 64)
    sprintf(asm_string, "mv $0, x25");
#endif
    const char *constraint_string = "=r";
    LLVMValueRef inline_asm = LLVMConstInlineAsm(asm_function_type, asm_string, constraint_string, /* has_side_effects */ 1, /* is_align_stack */ 0);
    return LLVMBuildCall2(g_builder, asm_function_type, inline_asm, NULL, 0, "env");
}

static StackAlloca *setup_stack(TcgContext *ctx, LLVMValueRef F) {
    StackAlloca *stack = (StackAlloca *)calloc(1, sizeof(StackAlloca));
    stack->xreg.ty = (LLVMType *)calloc(XREG_MAX, sizeof(LLVMType));
    stack->xreg.alloca = (LLVMValueRef *)calloc(XREG_MAX, sizeof(LLVMValueRef));
    stack->xreg.copy_valid = (uint64_t *)calloc(1, sizeof(uint64_t));
    stack->xreg.copy_valid_cnt = 1;
    stack->xreg.copy = (LLVMValueRef *)calloc(XREG_MAX, sizeof(LLVMValueRef));
    stack->xreg.copy_idx = (int *)calloc(XREG_MAX, sizeof(int));
    stack->xreg.cnt = XREG_MAX;
    for (int i = 0; i < XREG_MAX; ++i) {
        if (ctx->xreg_valid & (1 << i)) {
            stack->xreg.ty[i] = qemuaot_default_param_type[i];
            stack->xreg.alloca[i] = LLVMBuildAlloca(g_builder, get_llvm_type(stack->xreg.ty[i]), qemuaot_default_stack_alloca_name[i]);
            LLVMSetAlignment(stack->xreg.alloca[i], GET_ALIGNMENT_FROM_TYPE(stack->xreg.ty[i]));
            build_store_with_alignment(g_builder, LLVMGetParam(F, i), stack->xreg.alloca[i], GET_ALIGNMENT_FROM_TYPE(stack->xreg.ty[i]));
        }
    }
    stack->vector.ty = (LLVMType *)calloc((2 * XMM_COUNT_MAX), sizeof(LLVMType));
    stack->vector.alloca = (LLVMValueRef *)calloc((2 * XMM_COUNT_MAX), sizeof(LLVMValueRef));
    stack->vector.copy_valid = (uint64_t *)calloc(1, sizeof(uint64_t));
    stack->vector.copy_valid_cnt = 1;
    stack->vector.copy = (LLVMValueRef *)calloc((2 * XMM_COUNT_MAX), sizeof(LLVMValueRef));
    stack->vector.copy_idx = (int *)calloc((2 * XMM_COUNT_MAX), sizeof(int));
    stack->vector.cnt = (2 * XMM_COUNT_MAX);
    for (int i = 0; i < (2 * XMM_COUNT_MAX); ++i) {
        if ((ctx->vec_valid & (1 << i)) || (ctx->vec_spare_valid & (1 << i))) {
            stack->vector.ty[i] = qemuaot_default_param_type[XREG_MAX + i];
            stack->vector.alloca[i] = LLVMBuildAlloca(g_builder, get_llvm_type(stack->vector.ty[i]), qemuaot_default_stack_alloca_name[XREG_MAX + i]);
            LLVMSetAlignment(stack->vector.alloca[i], GET_ALIGNMENT_FROM_TYPE(stack->vector.ty[i]));
            build_store_with_alignment(g_builder, LLVMGetParam(F, (XREG_MAX + i)), stack->vector.alloca[i], GET_ALIGNMENT_FROM_TYPE(stack->vector.ty[i]));
        }
    }
    stack->tmp.ty = (LLVMType *)calloc(ctx->next_tmp_idx, sizeof(LLVMType));
    stack->tmp.alloca = (LLVMValueRef *)calloc(ctx->next_tmp_idx, sizeof(LLVMValueRef));
    stack->tmp.copy_valid = (uint64_t *)calloc((ctx->next_tmp_idx + 63) / 64, sizeof(uint64_t));
    stack->tmp.copy_valid_cnt = (ctx->next_tmp_idx + 63) / 64;
    stack->tmp.copy = (LLVMValueRef *)calloc(ctx->next_tmp_idx, sizeof(LLVMValueRef));
    stack->tmp.copy_idx = (int *)calloc(ctx->next_tmp_idx, sizeof(int));
    stack->tmp.cnt = ctx->next_tmp_idx;
    for (int i = 0; i < ctx->next_tmp_idx; ++i) {
        LLVMType stack_ty = (LLVMType)(long)g_hash_table_lookup(ctx->stack_type_map, (gpointer)(long)i);
        assert(stack_ty != LLVMInvalidType);
        char tmp_alloca_name[16] = {0};
        sprintf(&tmp_alloca_name[0], "tmp%d.stack", (i & 0xffff));
        stack->tmp.ty[i] = stack_ty;
        stack->tmp.alloca[i] = LLVMBuildAlloca(g_builder, get_llvm_type(stack->tmp.ty[i]), tmp_alloca_name);
        LLVMSetAlignment(stack->tmp.alloca[i], GET_ALIGNMENT_FROM_TYPE(stack->tmp.ty[i]));
    }
    if (ctx->carry_on) {
        stack->carry = LLVMBuildAlloca(g_builder, LLVMInt1Type(), "carry.stack");
        LLVMSetAlignment(stack->carry, 8);
    }
    if (ctx->borrow_on) {
        stack->borrow = LLVMBuildAlloca(g_builder, LLVMInt1Type(), "borrow.stack");
        LLVMSetAlignment(stack->borrow, 8);
    }
    if (ctx->env_on) {
        stack->env = get_env();
    }
    return stack;
}

void start_llvm_bb(LLVMBasicBlockRef bb, StackAlloca *stack) {
    LLVMPositionBuilderAtEnd(g_builder, bb);
    memset(stack->xreg.copy_valid, 0, stack->xreg.copy_valid_cnt * sizeof(uint64_t));
    memset(stack->xreg.copy, 0, stack->xreg.cnt * sizeof(LLVMValueRef));
    memset(stack->vector.copy_valid, 0, stack->vector.copy_valid_cnt * sizeof(uint64_t));
    memset(stack->vector.copy, 0, stack->vector.cnt * sizeof(LLVMValueRef));
    memset(stack->tmp.copy_valid, 0, stack->tmp.copy_valid_cnt * sizeof(uint64_t));
    memset(stack->tmp.copy, 0, stack->tmp.cnt * sizeof(LLVMValueRef));
}

static void release_stack(StackAlloca *stack) {
    free(stack->xreg.ty);
    free(stack->xreg.alloca);
    free(stack->xreg.copy_valid);
    free(stack->xreg.copy);
    free(stack->xreg.copy_idx);
    free(stack->vector.ty);
    free(stack->vector.alloca);
    free(stack->vector.copy_valid);
    free(stack->vector.copy);
    free(stack->vector.copy_idx);
    free(stack->tmp.ty);
    free(stack->tmp.alloca);
    free(stack->tmp.copy_valid);
    free(stack->tmp.copy);
    free(stack->tmp.copy_idx);
    free(stack);
}

void translate_to_llvm_func(TcgContext *ctx, const char *name, FuncInstrList *f, int is_external) {
    LLVMValueRef F = NULL;
    F = get_or_add_func_with_qemuaot_cc(name, f, 0);
    if (is_external == 0) {
        LLVMSetLinkage(F, LLVMInternalLinkage);
        LLVMAddAttributeAtIndex(F, -1, g_attr_alwaysinline);
    } else {
        LLVMSetLinkage(F, LLVMExternalLinkage);
        LLVMAddAttributeAtIndex(F, -1, g_attr_noinline);
    }
    // Create the entry block, then define/initialize stack alloca
    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(F, "entry");
    LLVMPositionBuilderAtEnd(g_builder, entry);
    StackAlloca *stack = setup_stack(ctx, F);
    // One-to-one mapping from TCG-ops to LLVM-IR
    translate_batch(g_builder, F, stack, f);
    for (const UnifiedInstr *u = f->head; u; u = u->next) {
    }
    release_stack(stack);
}

void handle_func(TcgContext *ctx, int is_external) {
    for (int i = 0; i < ctx->llvm_func_set.num_lists; ++i) {
        char *func_name = NULL;
        char fhex_name[32] = {0};
        if (ctx->llvm_func_set.lists[i].trampoline_name[0]) {
            func_name = &ctx->llvm_func_set.lists[i].trampoline_name[0];
        } else {
            if (i == 0) {
                sprintf(fhex_name, "Fx%lx", ctx->hex_offset);
            } else {
                sprintf(fhex_name, "Fx%lx_%d", ctx->hex_offset, i);
            }
            func_name = &fhex_name[0];
        }
        translate_to_llvm_func(ctx, func_name, &(ctx->llvm_func_set.lists[i]), is_external);
    }
}

void print_usage(const char *progname) {
    fprintf(stderr, "Usage: %s [-d] [-h] <input.tir>\n", progname);
    fprintf(stderr, "  -d    Dump the mapped LLVM-IR module to stdout and exit without\n");
    fprintf(stderr, "        kicking off compilation (no passes, no object file)\n");
    fprintf(stderr, "  -h    Print this help message\n");
}

void parse_tcg_instructions(const char *filename) {
    FILE *source_file = fopen(filename, "r");
    if (!source_file) {
        perror("Error opening source file");
        return;
    }
    TcgContext ctx;
    tcg_context_init(&ctx);
    yyscan_t scanner;
    yylex_init(&scanner);
    yyset_in(source_file, scanner);
    yyparse(scanner, &ctx);
    yylex_destroy(scanner);
    free(lineptr);
    fclose(source_file);
    tcg_context_destroy(&ctx);
    return;
}

int init_llvm() {
    char *error_msg = NULL;
    LLVMTargetRef target;
    // Enable AArch64AOTStackSwitchPass/RISCVAOTStackSwitchPass
    int rc = setenv("LLVM_ENABLE_AOT_STACK_SWITCH", "1", 1);
    assert(rc == 0);
#if defined(__aarch64__)
    const char *default_triple = "aarch64-unknown-linux-gnu";
    const char* features = "+neon";
    LLVMInitializeAArch64TargetInfo();
    LLVMInitializeAArch64Target();
    LLVMInitializeAArch64TargetMC();
    LLVMInitializeAArch64AsmPrinter();
    LLVMInitializeAArch64AsmParser();
#elif (defined(__riscv) && __riscv_xlen == 64)
    const char *default_triple = "riscv64-unknown-linux-gnu";
    //const char* features = "+m,+a,+f,+d,+v,+unaligned-scalar-mem,+unaligned-vector-mem";
    const char* features = "+m,+a,+f,+d,+v";
    LLVMInitializeRISCVTargetInfo();
    LLVMInitializeRISCVTarget();
    LLVMInitializeRISCVTargetMC();
    LLVMInitializeRISCVAsmPrinter();
    LLVMInitializeRISCVAsmParser();
#endif
    if (LLVMGetTargetFromTriple(default_triple, &target, &error_msg)) {
        fprintf(stderr, "Failed to get target from triple %s\n", error_msg);
        return -1;
    }
    g_target_machine = LLVMCreateTargetMachine(target, default_triple, "generic", features,
                                             LLVMCodeGenLevelDefault, LLVMRelocPIC, LLVMCodeModelDefault);

    LLVMContextRef context = LLVMGetGlobalContext();
    g_attr_noinline = LLVMCreateEnumAttribute(context, LLVMNoInlineAttribute, 0);
    g_attr_alwaysinline = LLVMCreateEnumAttribute(context, LLVMAlwaysInlineAttribute, 0);
    g_attr_nounwind = LLVMCreateEnumAttribute(context, LLVMGetEnumAttributeKindForName("nounwind", strlen("nounwind")), 0);
    const char *attr_key = "target-features";
#if defined(__aarch64__)
    const char *attr_value = "+neon";
#elif (defined(__riscv) && __riscv_xlen == 64)
    // Unfortunately on Spacemit(R) X60, following instruction requires alignment: vse64.v v30,(a4)
    //const char *attr_value = "+m,+a,+f,+d,+v,+unaligned-scalar-mem,+unaligned-vector-mem";
    const char *attr_value = "+m,+a,+f,+d,+v";
#endif
    size_t attr_key_len = strlen(attr_key);
    size_t attr_value_len = strlen(attr_value);
    g_attr_target_features = LLVMCreateStringAttribute(context, attr_key, attr_key_len, attr_value, attr_value_len);
    g_module = LLVMModuleCreateWithNameInContext("qemuaot", context);

#if defined(__aarch64__)
    LLVMSetTarget(g_module, "aarch64-unknown-linux-gnu");
#elif (defined(__riscv) && __riscv_xlen == 64)
    LLVMSetTarget(g_module, "riscv64-unknown-linux-gnu");
#endif

    g_builder = LLVMCreateBuilder();
    return 0;
}

static int check_always_inline_status(LLVMValueRef F) {
    LLVMAttributeRef attr = LLVMGetEnumAttributeAtIndex(F, -1, LLVMAlwaysInlineAttribute);
    if (!attr) {
        return 0;
    }
    LLVMUseRef use = LLVMGetFirstUse(F);
    if (!use) {
        printf("Function '%s' with always_inline has no use - likely inlined\n", LLVMGetValueName(F));
        return 1;
    }
    return 0;
}

int fini_llvm(const char *output_file) {
    int rc = 0;
    LLVMPassBuilderOptionsRef options = NULL;

    /*
     * '-d': dump the mapped LLVM-IR module and bail out before kicking off
     * the compilation pipeline (optimization passes + object emission).
     */
    if (g_dump_ir) {
        char *ir = LLVMPrintModuleToString(g_module);
        if (!ir) {
            fprintf(stderr, "Failed to dump LLVM module\n");
            rc = -1;
            goto cleanup;
        }
        fputs(ir, stdout);
        fflush(stdout);
        LLVMDisposeMessage(ir);
        goto cleanup;
    }

    LLVMValueRef F = LLVMGetFirstFunction(g_module);
    while (F != NULL) {
        if (LLVMIsAFunction(F) && LLVMIsDeclaration(F) && strncmp(LLVMGetValueName(F), "Fx", 2) == 0) {
            LLVMSetSection(F, ".text.declare_only");
            LLVMSetLinkage(F, LLVMWeakAnyLinkage);
            LLVMAddAttributeAtIndex(F, -1, g_attr_noinline);
            LLVMAddAttributeAtIndex(F, -1, g_attr_target_features);
            LLVMBasicBlockRef bb_entry = LLVMAppendBasicBlock(F, "entry");
            LLVMPositionBuilderAtEnd(g_builder, bb_entry);
            LLVMBasicBlockRef bb_loop = LLVMAppendBasicBlock(F, "loop");
            LLVMBuildBr(g_builder, bb_loop);
            LLVMPositionBuilderAtEnd(g_builder, bb_loop);
            LLVMBuildBr(g_builder, bb_loop);
            LLVMBasicBlockRef bb_exit = LLVMAppendBasicBlock(F, "exit");
            LLVMPositionBuilderAtEnd(g_builder, bb_exit);
            LLVMBuildRetVoid(g_builder);
        }
        F = LLVMGetNextFunction(F);
    }

    options = LLVMCreatePassBuilderOptions();
    LLVMErrorRef error = LLVMRunPasses(g_module, "default<O2>", g_target_machine, options);
    LLVMDisposePassBuilderOptions(options);
    options = NULL;
    if (error) {
        char* error_msg = LLVMGetErrorMessage(error);
        fprintf(stderr, "Optimization failed: %s\n", error_msg);
        LLVMDisposeErrorMessage(error_msg);
        rc = -1;
        goto cleanup;
    }

    // Remove standalone always_inline functions(helpers)
    F = LLVMGetFirstFunction(g_module);
    while (F != NULL) {
        LLVMValueRef DC = NULL;
        if (check_always_inline_status(F)) {
            DC = F;
        }
        F = LLVMGetNextFunction(F);
        if (DC) {
            LLVMDeleteFunction(DC);
        }
    }

    char *error_msg = NULL;
    if (LLVMTargetMachineEmitToFile(g_target_machine, g_module, output_file, LLVMObjectFile, &error_msg)) {
        fprintf(stderr, "Failed to emit object file: %s", error_msg);
        rc = -1;
        goto cleanup;
    }

cleanup:
    if (options) {
        LLVMDisposePassBuilderOptions(options);
    }
    if (g_builder) {
        LLVMDisposeBuilder(g_builder);
    }
    if (g_module) {
        LLVMDisposeModule(g_module);
    }
    if (g_target_machine) {
        LLVMDisposeTargetMachine(g_target_machine);
    }
    return rc;
}

int main(int argc, char *argv[]) {
    int rc = 0;
    char *output_file = NULL;
    int opt = 0;
    if (argc < 1) {
        print_usage(argv[0]);
        rc = -1;
        goto exit;
    }
    while ((opt = getopt(argc, argv, "dh")) != -1) {
        switch (opt) {
            case 'd':
                /* Dump the mapped LLVM-IR module, skip compilation */
                g_dump_ir = 1;
                break;
            case 'h':
                print_usage(argv[0]);
                rc = 0;
                goto exit;
            default:
                print_usage(argv[0]);
                rc = -1;
                goto exit;
        }
    }
    if (optind >= argc) {
        fprintf(stderr, "Error: no input file specified\n");
        print_usage(argv[0]);
        rc = -1;
        goto exit;
    }
    const char *input_file = argv[optind];
    if (!input_file) {
        fprintf(stderr, "Error: no input file specified\n");
        print_usage(argv[0]);
        rc = -1;
        goto exit;
    }
    output_file = (char *)calloc(1, strlen(input_file) + 1 + 2);
    assert(output_file);
    sprintf(output_file, "%s.o", input_file);

    // Get the path for helper_templates
    g_template_path = realpath(argv[0], NULL);
    assert(g_template_path);
    char *p = g_template_path;
    assert(p);
    while (strstr(p, "/") != NULL) {
        p = strstr(p, "/");
        if (*p == '/') {
            p += 1;
        }
    }
    assert((p - g_template_path) < PATH_MAX);
    *p = '\0';

    // Initialize LLVM target machine
    rc = init_llvm();
    if (rc != 0) {
        goto exit;
    }

    // Parse/Expand/Map TCG-ops into LLVM-IR
    parse_tcg_instructions(input_file);

    // Invoke LLVM pipeline to produce object file
    rc = fini_llvm(output_file);
    if (rc != 0) {
        goto exit;
    }

exit:
    if (g_template_path) {
        free(g_template_path);
    }
    if (output_file) {
        free(output_file);
    }
    return rc;
}
