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
#include "i386_cpu.h"
#include "xymm_def.h"

#define LLVMNoInlineAttribute       32
#define LLVMAlwaysInlineAttribute   3
/*
 * Magic numbers collected by sizeof CPUState/CPUArchState in QEMU
 */
#define QEMU_CPUSTATE_CPUARCHSTATE_TOTAL_SIZE   0x67a0ULL
#define QEMU_CPUARCHSTATE_OFFSET                0x2cd0ULL

extern char *lineptr;
int cfg_xmm_count = XMM_COUNT;
void debug_print_instr(TcgContext *ctx, const char *msg) {}

char *g_template_path = NULL;
char *g_output_path = NULL;

/* Set by '-d': dump the mapped LLVM-IR module and stop before compilation */
int g_dump_ir = 0;
LLVMTargetMachineRef g_target_machine = NULL;
LLVMModuleRef g_module = NULL;
LLVMBuilderRef g_builder = NULL;
LLVMAttributeRef g_attr_target_features = NULL;
LLVMAttributeRef g_attr_noinline = NULL;
LLVMAttributeRef g_attr_alwaysinline = NULL;
LLVMAttributeRef g_attr_nounwind = NULL;
TcgContext *g_ctx = NULL;
TBAA g_tbaa;

static inline void tbaa_tag(LLVMValueRef inst, const TBAA *t, TagType tag_ty) {
    LLVMSetMetadata(inst, t->kind, (tag_ty == CPU_TAG ? t->cpu_tag : (tag_ty == GUEST_TAG ? t->guest_tag : t->spill_tag)));
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
        case LLVMInvalidType:
            ty = LLVMVoidType(); break;
        default: assert(0);
    }
    return ty;
}

LLVMValueRef create_intrinsic_declaration(const char *intrinsic_name, LLVMTypeRef ret_ty, LLVMTypeRef *arg_types, int cnt) {
    LLVMValueRef func = LLVMGetNamedFunction(g_module, intrinsic_name);
    if (!func) {
        LLVMTypeRef fn_type = LLVMFunctionType(ret_ty, arg_types, cnt, 0);
        func = LLVMAddFunction(g_module, intrinsic_name, fn_type);
    }
    return func;
}

LLVMValueRef get_intrinsic_declaration(const char *intrinsic_name, LLVMTypeRef *intrinsic_types, int cnt) {
    unsigned id = LLVMLookupIntrinsicID(intrinsic_name, strlen(intrinsic_name));
    assert(id != 0);
    return LLVMGetIntrinsicDeclaration(g_module, id, intrinsic_types, cnt);
}

LLVMValueRef get_const_vector(unsigned long c, LLVMType ty) {
    LLVMValueRef constants[16];
    int elem_cnt = llvm_vector_elem_bit_counts[ty * 2];
    for (int i = 0; i < elem_cnt; i++) {
        constants[i] = LLVMConstInt(get_llvm_type(OPC_VECTOR_TO_FIXED(ty)), c, 0);
    }
    return LLVMConstVector(constants, elem_cnt);
}

LLVMValueRef load_from_stack_as_type(AllocaWithState *as, int idx, LLVMType ty, const char *prefix, const char *reg_name) {
    char var_name[32] = {0};
    if (as->tcg_ty[idx] == LLVMInvalidType) {
        if (as->f_argument[idx]) {
            return as->f_argument[idx];
        }
    }
    assert((as->tcg_ty[idx] <= LLVMInt64 && ty <= as->tcg_ty[idx]) || (as->tcg_ty[idx] <= LLVMVector1xi64 && ty <= LLVMVector1xi64) || as->tcg_ty[idx] <= LLVMVector2xi64 || as->tcg_ty[idx] == LLVMFuncPtr);
    return build_load_with_alignment(g_builder, get_llvm_type(ty), as->alloca[idx], assemble_name_2(&var_name[0], sizeof(var_name), prefix, reg_name), as->align[idx], SPILL_TAG);
}

static LLVMType get_vector_type_for_elem(int elem_cnt, int elem_bits) {
    for (LLVMType ty = LLVMVector8xi8; ty < LLVMTypeEnd; ++ty) {
        if (llvm_vector_elem_bit_counts[ty * 2] == elem_cnt && llvm_vector_elem_bit_counts[ty * 2 + 1] == elem_bits) {
            return ty;
        }
    }
    return LLVMInvalidType;
}

LLVMValueRef shrink_llvm_value(LLVMValueRef val, LLVMType from, LLVMType to) {
    assert(to < from);
    char var_name[32] = {0};
    if (from <= LLVMInt64) {
        return LLVMBuildTrunc(g_builder, val, get_llvm_type(to), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "trunc"));
    }
    if ((llvm_vector_elem_bit_counts[from * 2] * llvm_vector_elem_bit_counts[from * 2 + 1]) == (llvm_vector_elem_bit_counts[to * 2] * llvm_vector_elem_bit_counts[to * 2 + 1])) {
        return LLVMBuildBitCast(g_builder, val, get_llvm_type(to), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc"));
    }
    assert((llvm_vector_elem_bit_counts[from * 2] * llvm_vector_elem_bit_counts[from * 2 + 1]) % (llvm_vector_elem_bit_counts[to * 2] * llvm_vector_elem_bit_counts[to * 2 + 1]) == 0);
    int elem_cnt = (llvm_vector_elem_bit_counts[from * 2] * llvm_vector_elem_bit_counts[from * 2 + 1]) / (llvm_vector_elem_bit_counts[to * 2] * llvm_vector_elem_bit_counts[to * 2 + 1]);
    int elem_bits = (llvm_vector_elem_bit_counts[to * 2] * llvm_vector_elem_bit_counts[to * 2 + 1]);
    LLVMType bc_ty = LLVMInvalidType;
    LLVMType elem_ty = LLVMInvalidType;
    // FIXME: can this be calculated?
    for (LLVMType ty = LLVMInvalidType; ty < LLVMVector8xi8; ++ty) {
        if (llvm_vector_elem_bit_counts[ty * 2 + 1] == elem_bits) {
            elem_ty = ty;
            break;
        }
    }
    bc_ty = get_vector_type_for_elem(elem_cnt, elem_bits);
    assert(bc_ty != LLVMInvalidType && elem_ty != LLVMInvalidType);
    val = LLVMBuildBitCast(g_builder, val, get_llvm_type(bc_ty), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc"));
    LLVMValueRef index = LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0);
    val = LLVMBuildExtractElement(g_builder, val, index, assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "ee"));
    if (elem_ty != to) {
        val = LLVMBuildBitCast(g_builder, val, get_llvm_type(to), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc"));
    }
    return val;
}

LLVMValueRef get_input_val_for_operand(const Operand *op, StackAlloca *stack, const char *prefix) {
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
        LLVMType op_ty = op->kind == OP_SLOT ? op->slot.op_type : op->env.op_type;
        LLVMValueRef offset = LLVMConstInt(get_llvm_type(LLVMInt64), op->kind == OP_SLOT ? envvar_offsets[op->slot.idx] : op->env.offset, 0);
        LLVMValueRef ptr = LLVMBuildGEP2(g_builder, LLVMInt8Type(), stack->env, &offset, 1, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "envptr"));
        val = build_load_with_alignment(g_builder, get_llvm_type(op_ty), ptr, assemble_name_2(&var_name[0], sizeof(var_name), prefix, op->kind == OP_SLOT ? envvar_type_str[op->slot.idx] : "envval"), GET_ALIGNMENT_FROM_OFFSET(op->kind == OP_SLOT ? envvar_offsets[op->slot.idx] : op->env.offset), CPU_TAG);
        return val;
    } else if (op->kind == OP_VEC) {
        snprintf(&var_name[0], sizeof(var_name), "v%d", op->vec.idx);
        if (op->vec.offset == 0) {
            return load_from_stack_as_type(&stack->vector, op->vec.idx, op->vec.op_type, prefix, &var_name[0]);
        }
        // In case none-zero offset, target should be scalar
        assert(op->vec.op_type <= LLVMInt64);
        if (op->vec.offset % ((llvm_vector_elem_bit_counts[op->vec.op_type * 2 + 1] / 8)) == 0) {
            LLVMValueRef index = LLVMConstInt(get_llvm_type(LLVMInt64), (op->vec.offset / ((llvm_vector_elem_bit_counts[op->vec.op_type * 2 + 1] / 8))), 0);
            LLVMType stack_ty = stack->vector.tcg_ty[op->vec.idx];
            int elem_cnt = (llvm_vector_elem_bit_counts[stack_ty * 2 + 1] * llvm_vector_elem_bit_counts[stack_ty * 2]) / llvm_vector_elem_bit_counts[op->vec.op_type * 2 + 1];
            LLVMType load_ty = get_vector_type_for_elem(elem_cnt, llvm_vector_elem_bit_counts[op->vec.op_type * 2 + 1]);
            val = load_from_stack_as_type(&stack->vector, op->vec.idx, load_ty, prefix, &var_name[0]);
            // FIXME: scalable vector
            val = LLVMBuildExtractElement(g_builder, val, index, assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "ee"));
            return val;
        } else {
            // Store the content of vector into CPUArchState, and then do the load
            Operand op_vec = *op;
            op_vec.vec.offset = 0;
            op_vec.vec.op_type = stack->vector.tcg_ty[op_vec.vec.idx];
            val = get_input_val_for_operand(&op_vec, stack, prefix);
            // Write-back stack alloca
            int env_offset = get_vec_offset(op->vec.idx);
            LLVMValueRef offset = LLVMConstInt(get_llvm_type(LLVMInt64), env_offset, 0);
            LLVMValueRef ptr = LLVMBuildGEP2(g_builder, LLVMInt8Type(), stack->env, &offset, 1, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "envptr"));
            build_store_with_alignment(g_builder, val, ptr, GET_ALIGNMENT_FROM_OFFSET(env_offset), CPU_TAG);

            // Load new data
            Operand op_env_load;
            op_env_load.kind = OP_ENV;
            op_env_load.env.offset = get_vec_offset(op->vec.idx) + op->vec.offset;
            op_env_load.env.op_type = op->vec.op_type;
            return get_input_val_for_operand(&op_env_load, stack, prefix);
        }
    } else if (op->kind == OP_SLOT) {
        assert(op->slot.type == SUB_SLOT_XREG || op->slot.type == SUB_SLOT_TMP);
        const char *p_name = NULL;
        if (op->slot.type == SUB_SLOT_TMP) {
            sprintf(&var_name[0], "tmp%d", (op->slot.idx & 0xffff));
            p_name = &var_name[0];
        } else {
            p_name = qemuaot_default_param_name[op->slot.idx];
        }
        val = load_from_stack_as_type(op->slot.type == SUB_SLOT_TMP ? &stack->tmp : &stack->xreg, op->slot.idx, op->slot.op_type, prefix, p_name);
        return val;
    } else if (op->kind == OP_ARG && op->argidx == -1) {
        return stack->arg_last;
    }
    assert(0);
}

static void create_stack_alloca(AllocaWithState *as, int idx, LLVMType default_ty, const char *default_name) {
    assert(as->tcg_ty[idx] == LLVMInvalidType);
    LLVMBasicBlockRef current = LLVMGetInsertBlock(g_builder);
    LLVMValueRef parent_fn  = LLVMGetBasicBlockParent(current);
    LLVMBasicBlockRef init = LLVMGetFirstBasicBlock(parent_fn);
    LLVMPositionBuilder(g_builder, init, LLVMGetFirstInstruction(init));
    as->tcg_ty[idx] = default_ty;
    as->llvm_ty[idx] = get_llvm_type(as->tcg_ty[idx]);
    as->alloca[idx] = LLVMBuildAlloca(g_builder, as->llvm_ty[idx], default_name);
    as->align[idx] = GET_ALIGNMENT_FROM_TYPE(as->tcg_ty[idx]);
    LLVMSetAlignment(as->alloca[idx], as->align[idx]);
    LLVMPositionBuilderAtEnd(g_builder, current);
}

static void add_stack_alloca_force_writeback(AllocaWithState *as, int idx, LLVMType default_ty, int param_idx, const char *default_name, int env_offset, const Operand *op, StackAlloca *stack, const char *prefix) {
    char var_name[32] = {0};
    if (as->tcg_ty[idx] == LLVMInvalidType) {
        LLVMBasicBlockRef current = LLVMGetInsertBlock(g_builder);
        LLVMValueRef parent_fn  = LLVMGetBasicBlockParent(current);
        LLVMBasicBlockRef init = LLVMGetFirstBasicBlock(parent_fn);
        LLVMPositionBuilder(g_builder, init, LLVMGetFirstInstruction(init));
        as->tcg_ty[idx] = default_ty;
        as->llvm_ty[idx] = get_llvm_type(as->tcg_ty[idx]);
        as->alloca[idx] = LLVMBuildAlloca(g_builder, as->llvm_ty[idx], default_name);
        as->align[idx] = GET_ALIGNMENT_FROM_TYPE(as->tcg_ty[idx]);
        LLVMSetAlignment(as->alloca[idx], as->align[idx]);
        build_store_with_alignment(g_builder, LLVMGetParam(parent_fn, param_idx), as->alloca[idx], as->align[idx], SPILL_TAG);
        LLVMPositionBuilderAtEnd(g_builder, current);
    }
    // Write-back stack alloca
    LLVMValueRef offset = LLVMConstInt(get_llvm_type(LLVMInt64), env_offset, 0);
    LLVMValueRef ptr = LLVMBuildGEP2(g_builder, LLVMInt8Type(), stack->env, &offset, 1, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "envptr"));
    build_store_with_alignment(g_builder, get_input_val_for_operand(op, stack, prefix), ptr, GET_ALIGNMENT_FROM_OFFSET(env_offset), CPU_TAG);
}

static void add_stack_alloca_force_update(AllocaWithState *as, int idx, LLVMType default_ty, int param_idx, const char *default_name, int env_offset, const Operand *op, StackAlloca *stack, const char *prefix) {
    assert(as->tcg_ty[idx] != LLVMInvalidType);
    // Reload/store-update stack alloca
    Operand op_env_load;
    op_env_load.kind = OP_ENV;
    op_env_load.env.offset = env_offset;
    op_env_load.env.op_type = as->tcg_ty[idx];
    do_store(op, get_input_val_for_operand(&op_env_load, stack, prefix), stack, prefix, true);
}

void do_store(const Operand *op, LLVMValueRef val, StackAlloca *stack, const char *prefix, bool skip_env_check) {
    char var_name[32] = {0};
    if ((op->kind == OP_SLOT && op->slot.type == SUB_SLOT_TMP) || op->kind == OP_VEC) {
        LLVMType val_ty = get_operand_type(op);
        if (op->kind == OP_VEC && stack->vector.alloca[op->vec.idx] == NULL) {
            create_stack_alloca(&stack->vector, op->vec.idx, qemuaot_default_param_type[XREG_MAX + op->vec.idx], qemuaot_default_stack_alloca_name[XREG_MAX + op->vec.idx]);
        }
        LLVMType stack_ty = op->kind == OP_SLOT ? stack->tmp.tcg_ty[op->slot.idx] : stack->vector.tcg_ty[op->vec.idx];
        assert(val_ty != LLVMInvalidType && stack_ty != LLVMInvalidType);
        assert((val_ty <= LLVMInt64 && stack_ty <= LLVMInt64 && val_ty <= stack_ty) ||
               (val_ty <= LLVMInt64 && stack_ty > LLVMInt64) ||
               (val_ty > LLVMInt64 && stack_ty > LLVMInt64));
        if (val_ty <= LLVMInt64 && stack_ty <= LLVMInt64 && val_ty < stack_ty) {
        } else if ((val_ty <= LLVMInt64 && stack_ty > LLVMInt64) || (val_ty <= LLVMVector1xi64 && stack_ty > LLVMVector1xi64)) {
            if (op->kind != OP_VEC || op->vec.offset == 0) {
            } else if ((op->vec.offset * 8) % (llvm_vector_elem_bit_counts[val_ty * 2] * llvm_vector_elem_bit_counts[val_ty * 2 + 1]) == 0) {
                // For this case, we can store through vector element
                int elem_cnt = (llvm_vector_elem_bit_counts[stack_ty * 2] * llvm_vector_elem_bit_counts[stack_ty * 2 + 1]) / (llvm_vector_elem_bit_counts[val_ty * 2] * llvm_vector_elem_bit_counts[val_ty * 2 + 1]);
                // Collapse v64 to i64
                if (val_ty > LLVMInt64) {
                    if (val_ty != LLVMVector1xi64) {
                        val = LLVMBuildBitCast(g_builder, val, get_llvm_type(LLVMVector1xi64), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "bc"));
                    }
                    LLVMValueRef index = LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0);
                    val = LLVMBuildExtractElement(g_builder, val, index, assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "ee"));
                    val_ty = LLVMInt64;
                }
                Operand op_vec = *op;
                op_vec.vec.offset = 0;
                op_vec.vec.op_type = get_vector_type_for_elem(elem_cnt, llvm_vector_elem_bit_counts[val_ty * 2 + 1]);
                LLVMValueRef base = get_input_val_for_operand(&op_vec, stack, prefix);
                LLVMValueRef index = LLVMConstInt(get_llvm_type(LLVMInt64), op->kind == OP_SLOT ? 0 : ((op->vec.offset * 8) / llvm_vector_elem_bit_counts[val_ty * 2 + 1]), 0);
                val = LLVMBuildInsertElement(g_builder, base, val, index, assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "ie"));
            } else {
                /*
                 * Partial write vector, rewrite as store through ENV, and then reload vector
                 */
                // Partial store, leaves regions not touched unchanged
                Operand op_env_offset;
                op_env_offset.kind = OP_ENV;
                op_env_offset.env.offset = get_vec_offset(op->vec.idx) + op->vec.offset;
                op_env_offset.env.op_type = op->vec.op_type;
                return do_store(&op_env_offset, val, stack, prefix, false);
            }
        } else if (val_ty > LLVMInt64 && stack_ty > LLVMInt64 && val_ty != stack_ty) {
            assert((llvm_vector_elem_bit_counts[val_ty * 2] * llvm_vector_elem_bit_counts[val_ty * 2 + 1]) ==
                (llvm_vector_elem_bit_counts[stack_ty * 2] * llvm_vector_elem_bit_counts[stack_ty * 2 + 1]));
        } else {
            assert(val_ty == stack_ty);
        }
        build_store_with_alignment(g_builder, val, op->kind == OP_SLOT ? stack->tmp.alloca[op->slot.idx] : stack->vector.alloca[op->vec.idx], op->kind == OP_SLOT ? stack->tmp.align[op->slot.idx] : stack->vector.align[op->vec.idx], SPILL_TAG);
        return;
    }
    if (op->kind == OP_SLOT && op->slot.type == SUB_SLOT_XREG) {
        if (stack->xreg.alloca[op->slot.idx] == NULL) {
            create_stack_alloca(&stack->xreg, op->slot.idx, qemuaot_default_param_type[op->slot.idx], qemuaot_default_stack_alloca_name[op->slot.idx]);
        }
        build_store_with_alignment(g_builder, val, stack->xreg.alloca[op->slot.idx], stack->xreg.align[op->slot.idx], SPILL_TAG);
        return;
    }
    if ((op->kind == OP_SLOT && op->slot.type == SUB_SLOT_ENVVAR) || op->kind == OP_ENV) {
        LLVMValueRef offset = LLVMConstInt(get_llvm_type(LLVMInt64), op->kind == OP_SLOT ? envvar_offsets[op->slot.idx] : op->env.offset, 0);
        LLVMValueRef ptr = LLVMBuildGEP2(g_builder, LLVMInt8Type(), stack->env, &offset, 1, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "envptr"));
        LLVMType op_ty = op->kind == OP_SLOT ? op->slot.op_type : op->env.op_type;

        // Latest copy of xreg/vector need write back before store overwrite xreg/vector states
        if (!skip_env_check && op->kind == OP_ENV) {
            int byte_cnt = (llvm_vector_elem_bit_counts[2 * op_ty] * llvm_vector_elem_bit_counts[2 * op_ty + 1]) / 8;
            int overlap_begin = op->env.offset;
            int overlap_end = overlap_begin + byte_cnt;
            if (overlap_begin < (ENV_OFFSET_rip + 8) ||
                (overlap_begin >= ENV_OFFSET_cc_dst && overlap_begin < (ENV_OFFSET_cc_src + 8)) ||
                (overlap_begin >= ENV_OFFSET_cc_op && overlap_begin < (ENV_OFFSET_cc_op + 4))) {
                for (XRegType x = rax; x < XREG_MAX; ++x) {
                    if ((overlap_begin >= env_regs_offset[x] && overlap_begin < (env_regs_offset[x] + (env_regs_type[x] == LLVMInt64 ? 8 : 4))) ||
                        (overlap_end > env_regs_offset[x] && overlap_end <= (env_regs_offset[x] + (env_regs_type[x] == LLVMInt64 ? 8 : 4)))) {
                        Operand xs;
                        xs.kind = OP_SLOT;
                        xs.slot.type = SUB_SLOT_XREG;
                        xs.slot.idx = x;
                        xs.slot.op_type = qemuaot_default_param_type[x];
                        add_stack_alloca_force_writeback(&stack->xreg, x, qemuaot_default_param_type[x], x, qemuaot_default_stack_alloca_name[x], env_regs_offset[x], &xs, stack, prefix);
                    }
                }
            } else if (overlap_begin >= get_vec_offset(0) && overlap_begin < get_vec_offset(2 * cfg_xmm_count)) {
                for (int i = 0; i < (2 * cfg_xmm_count); ++i) {
                    uint64_t vbegin = get_vec_offset(i);
                    uint64_t vend = vbegin + 0x16;
                    if ((overlap_begin >= vbegin && overlap_begin < vend) ||
                        (overlap_end > vbegin && overlap_end <= vend)) {
                        Operand vs;
                        vs.kind = OP_VEC;
                        vs.vec.idx = i;
                        vs.vec.offset = 0;
                        vs.vec.op_type = qemuaot_default_param_type[XREG_MAX + i];
                        add_stack_alloca_force_writeback(&stack->vector, i, qemuaot_default_param_type[XREG_MAX + i], (XREG_MAX + i), qemuaot_default_stack_alloca_name[XREG_MAX + i], get_vec_offset(i), &vs, stack, prefix);
                    }
                }
            }
        }

        // The potential store clobber
        build_store_with_alignment(g_builder, val, ptr, GET_ALIGNMENT_FROM_OFFSET(op->kind == OP_SLOT ? envvar_offsets[op->slot.idx] : op->env.offset), CPU_TAG);

        // Check possibility of alias with xreg/vector
        if (!skip_env_check && op->kind == OP_ENV) {
            int byte_cnt = (llvm_vector_elem_bit_counts[2 * op_ty] * llvm_vector_elem_bit_counts[2 * op_ty + 1]) / 8;
            int overlap_begin = op->env.offset;
            int overlap_end = overlap_begin + byte_cnt;
            if (overlap_begin < (ENV_OFFSET_rip + 8) ||
                (overlap_begin >= ENV_OFFSET_cc_dst && overlap_begin < (ENV_OFFSET_cc_src + 8)) ||
                (overlap_begin >= ENV_OFFSET_cc_op && overlap_begin < (ENV_OFFSET_cc_op + 4))) {
                for (XRegType x = rax; x < XREG_MAX; ++x) {
                    if ((overlap_begin >= env_regs_offset[x] && overlap_begin < (env_regs_offset[x] + (env_regs_type[x] == LLVMInt64 ? 8 : 4))) ||
                        (overlap_end > env_regs_offset[x] && overlap_end <= (env_regs_offset[x] + (env_regs_type[x] == LLVMInt64 ? 8 : 4)))) {
                        Operand xs;
                        xs.kind = OP_SLOT;
                        xs.slot.type = SUB_SLOT_XREG;
                        xs.slot.idx = x;
                        xs.slot.op_type = qemuaot_default_param_type[x];
                        add_stack_alloca_force_update(&stack->xreg, x, qemuaot_default_param_type[x], x, qemuaot_default_stack_alloca_name[x], env_regs_offset[x], &xs, stack, prefix);
                    }
                }
            } else if (overlap_begin >= get_vec_offset(0) && overlap_begin < get_vec_offset(2 * cfg_xmm_count)) {
                for (int i = 0; i < (2 * cfg_xmm_count); ++i) {
                    uint64_t vbegin = get_vec_offset(i);
                    uint64_t vend = vbegin + 0x16;
                    if ((overlap_begin >= vbegin && overlap_begin < vend) ||
                        (overlap_end > vbegin && overlap_end <= vend)) {
                        Operand vs;
                        vs.kind = OP_VEC;
                        vs.vec.idx = i;
                        vs.vec.offset = 0;
                        vs.vec.op_type = qemuaot_default_param_type[XREG_MAX + i];
                        add_stack_alloca_force_update(&stack->vector, i, qemuaot_default_param_type[XREG_MAX + i], (XREG_MAX + i), qemuaot_default_stack_alloca_name[XREG_MAX + i], get_vec_offset(i), &vs, stack, prefix);
                    }
                }
            }
        }
        return;
    }
    assert(0);
}

LLVMValueRef get_or_add_func_with_qemuaot_cc(const char *name, unsigned long hex_offset, int sub_idx) {
    // Trampoline may have already been defined
    LLVMValueRef F = LLVMGetNamedFunction(g_module, name);
    if (!F) {
        LLVMTypeRef arg_types[XREG_MAX + 2 * XMM_COUNT + 1/*CPU*/ + MAX_ADDED_ARGS] = {NULL};
        int arg_cnt = 0;
        for (int i = 0; i < (XREG_MAX + 2 * XMM_COUNT); ++i) {
            arg_types[arg_cnt++] = get_llvm_type(qemuaot_default_param_type[i]);
        }
        arg_types[arg_cnt++] = LLVMPointerTypeInContext(LLVMGetModuleContext(g_module), 0);
        if (g_ctx != NULL && g_ctx->hex_offset == hex_offset && sub_idx < g_ctx->llvm_func_set.num_lists) {
            for (int i = 0; i < g_ctx->llvm_func_set.lists[sub_idx].added_param_count; ++i) {
                arg_types[arg_cnt++] = get_llvm_type(g_ctx->llvm_func_set.lists[sub_idx].added_param_type[i]);
            }
        }
        LLVMTypeRef f_type = LLVMFunctionType(LLVMVoidType(), arg_types, arg_cnt, 0);
        F = LLVMAddFunction(g_module, name, f_type);
        LLVMAddAttributeAtIndex(F, -1, g_attr_target_features);
        LLVMAddAttributeAtIndex(F, -1, g_attr_nounwind);
        LLVMSetFunctionCallConv(F, QEMUAOT_CC);
        char sec_name[128] = {0};
        sprintf(sec_name, ".text.%s", name);
        LLVMSetSection(F, sec_name);
        for (int i = 0; i < (XREG_MAX + 2 * XMM_COUNT); ++i) {
            LLVMSetValueName(LLVMGetParam(F, i), qemuaot_default_param_name[i]);
        }
        int cpu_pos = (XREG_MAX + 2 * XMM_COUNT);
        LLVMSetValueName(LLVMGetParam(F, cpu_pos), "cpu");
        LLVMSetParamAlignment(LLVMGetParam(F, cpu_pos), 8);
        LLVMAttributeIndex idx = (LLVMAttributeIndex)(cpu_pos + 1);
        LLVMAddAttributeAtIndex(F, idx, LLVMCreateEnumAttribute(LLVMGetModuleContext(g_module), LLVMGetEnumAttributeKindForName("dereferenceable", strlen("dereferenceable")), QEMU_CPUSTATE_CPUARCHSTATE_TOTAL_SIZE));
        if (g_ctx != NULL && g_ctx->hex_offset == hex_offset && sub_idx < g_ctx->llvm_func_set.num_lists) {
            for (int i = 0, arg_idx = (XREG_MAX + 2 * XMM_COUNT + 1); i < g_ctx->llvm_func_set.lists[sub_idx].added_param_count; ++i, ++arg_idx) {
                LLVMSetValueName(LLVMGetParam(F, arg_idx), g_ctx->llvm_func_set.lists[sub_idx].added_param_name[i]);
            }
        }
    }
    return F;
}

static int setup_helper_template_arg_type(LLVMTypeRef *arg_types, int arg_cnt, HelperType h) {
    for (int i = 0; i < MAX_ADDED_ARGS; ++i) {
        if (helper_template_arg_type[h][i] != LLVMInvalidType) {
            arg_types[arg_cnt++] = get_llvm_type(helper_template_arg_type[h][i]);
        }
    }
    if (!(h > NOSPLIT_BEGIN && h < NOSPLIT_END)) {
        // Type for the next call pointer
        arg_types[arg_cnt++] = get_llvm_type(LLVMInt64);
        if (helper_require_exception_path[h]) {
            arg_types[arg_cnt++] = get_llvm_type(LLVMInt64);
        }
    }
    return arg_cnt;
}

LLVMValueRef get_or_add_helper_with_qemuaot_cc(HelperType h, const UnifiedInstr *u) {
    SBuf bh;
    char dump_helper_buf[128] = {0};
    sbuf_init(&bh, &dump_helper_buf[0], sizeof(dump_helper_buf));
    sbuf_printf(&bh, "%s", helper_str[h]);
    for (int i = 2; i < u->operand_count; ++i) {
        assert(u->operands[i].kind == OP_VEC);
        sbuf_printf(&bh, "_V%d", u->operands[i].vec.idx);
    }
    LLVMValueRef F = LLVMGetNamedFunction(g_module, &dump_helper_buf[0]);
    if (!F) {
        if (h == helper_jmp_ind) {
            // helper_jmp_ind is defined in QEMU-runtime
            LLVMTypeRef arg_types[XREG_MAX + 2 * XMM_COUNT + 1/*CPU*/ + MAX_ADDED_ARGS] = {NULL};
            int arg_cnt = 0;
            for (int i = 0; i < (XREG_MAX + 2 * XMM_COUNT); ++i) {
                arg_types[arg_cnt++] = get_llvm_type(qemuaot_default_param_type[i]);
            }
            arg_types[arg_cnt++] = LLVMPointerTypeInContext(LLVMGetModuleContext(g_module), 0);
            arg_cnt = setup_helper_template_arg_type(arg_types, arg_cnt, h);
            LLVMTypeRef f_type = LLVMFunctionType(LLVMVoidType(), arg_types, arg_cnt, 0);
            F = LLVMAddFunction(g_module, helper_str[h], f_type);
            LLVMAddAttributeAtIndex(F, -1, g_attr_target_features);
            LLVMAddAttributeAtIndex(F, -1, g_attr_nounwind);
            LLVMSetFunctionCallConv(F, QEMUAOT_CC);
            return F;
        }
        SBuf bm;
        char dump_macro_buf[128] = {0};
        sbuf_init(&bm, &dump_macro_buf[0], sizeof(dump_macro_buf));
        for (int i = 2; i < u->operand_count; ++i) {
            assert(u->operands[i].kind == OP_VEC);
            sbuf_printf(&bm, " -DVEC%d=%s", (i - 2), qemuaot_default_param_name[XREG_MAX + u->operands[i].vec.idx]);
        }
#if defined(__aarch64__)
        const char *clang_cmd_head = "clang -Wno-incompatible-function-pointer-types -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -c --target=aarch64-unknown-linux-gnu -mcpu=apple-m2 -fPIC -O2 -emit-llvm";
#elif (defined(__riscv) && __riscv_xlen == 64)
        const char *clang_cmd_head = "clang -Wno-incompatible-function-pointer-types -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -c --target=riscv64-unknown-linux-gnu -march=rv64imafdv -fPIC -O2 -emit-llvm";
#endif
        int cmd_sz = strlen(clang_cmd_head) + strlen(XMM_PARAM_DECLARE_COMMON) + strlen(XMM_PARAM_LIST) + 8 * 12 /* -DVEC/XY */ + strlen(g_output_path) + strlen(g_template_path) + strlen(dump_helper_buf) * 2 + strlen(dump_macro_buf) + 256 /*misc*/;
        char *clang_cmd = (char *)malloc(cmd_sz);
        snprintf(clang_cmd, cmd_sz, "%s -DXMM_PARAM_DECLARE_COMMON=\"%s\" -DXMM_PARAM_LIST=\"%s\" -DHELPER_NAME=%s %s %s/helper_templates/%s.c -o %s/%s.bc", clang_cmd_head, XMM_PARAM_DECLARE_COMMON, XMM_PARAM_LIST, &dump_helper_buf[0], &dump_macro_buf[0], g_template_path, helper_str[h], g_output_path, &dump_helper_buf[0]);
        if (system(clang_cmd)) {
            fprintf(stderr, "Command failed:\n%s\n", clang_cmd);
            free(clang_cmd);
            return NULL;
        }
        free(clang_cmd);
        clang_cmd = NULL;

        char* error_msg = NULL;
        LLVMMemoryBufferRef memory_buffer = NULL;
        LLVMModuleRef helper_module = NULL;
        char bc_path[256] = {0};
        snprintf(&bc_path[0], sizeof(bc_path), "%s/%s.bc", g_output_path, &dump_helper_buf[0]);
        if (LLVMCreateMemoryBufferWithContentsOfFile(&bc_path[0], &memory_buffer, &error_msg)) {
            fprintf(stderr, "Failed to create memory buffer: %s\n", error_msg);
            LLVMDisposeMessage(error_msg);
            return NULL;
        }
        if (LLVMParseBitcode2(memory_buffer, &helper_module)) {
            fprintf(stderr, "Failed to parse bitcode\n");
            LLVMDisposeMemoryBuffer(memory_buffer);
            return NULL;
        }
        LLVMLinkModules2(g_module, helper_module);
        LLVMDisposeMemoryBuffer(memory_buffer);
        F = LLVMGetNamedFunction(g_module, &dump_helper_buf[0]);
        assert(F);
    }
    return F;
}

LLVMValueRef get_or_add_func_with_default_cc(HelperType h, const UnifiedInstr *u) {
    LLVMValueRef TF = LLVMGetNamedFunction(g_module, helper_str[h]);
    if (!TF) {
        LLVMTypeRef arg_types[MAX_ADDED_ARGS] = {NULL};
        int arg_cnt = 0;
        assert(u->operands[TCG_CALL_OUT_FLAG_IDX].kind == OP_IMM);
        assert(u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val == 0 || u->operands[TCG_CALL_PREFIX_COUNT].kind == OP_SLOT);
        for (int i = (u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val ? (TCG_CALL_PREFIX_COUNT + 1) : TCG_CALL_PREFIX_COUNT);
             i < u->operand_count; ++i) {
            arg_types[arg_cnt++] = get_llvm_type(LLVMInt64);
        }
        assert(u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val == 0 || u->operands[TCG_CALL_PREFIX_COUNT].slot.op_type == helper_return_type[h]);
        LLVMTypeRef f_type = LLVMFunctionType((helper_return_type[h] ? get_llvm_type(helper_return_type[h]) : LLVMVoidType()), arg_types, arg_cnt, 0);
        TF = LLVMAddFunction(g_module, helper_str[h], f_type);
    }
    return TF;
}

LLVMValueRef build_store_with_alignment(LLVMBuilderRef B, LLVMValueRef Val, LLVMValueRef PointerVal, unsigned Bytes, TagType tag_ty) {
    LLVMValueRef ST = LLVMBuildStore(B, Val, PointerVal);
    LLVMSetAlignment(ST, Bytes);
    tbaa_tag(ST, &g_tbaa, tag_ty);
    return ST;
}

LLVMValueRef build_load_with_alignment(LLVMBuilderRef B, LLVMTypeRef Ty, LLVMValueRef PointerVal, const char *Name, unsigned Bytes, TagType tag_ty) {
    LLVMValueRef LD = LLVMBuildLoad2(B, Ty, PointerVal, Name);
    LLVMSetAlignment(LD, Bytes);
    tbaa_tag(LD, &g_tbaa, tag_ty);
    return LD;
}

LLVMValueRef get_env(LLVMValueRef F) {
    LLVMValueRef env_off = LLVMConstInt(LLVMInt64Type(), QEMU_CPUARCHSTATE_OFFSET, 0);
    return LLVMBuildGEP2(g_builder, LLVMInt8Type(), LLVMGetParam(F, (XREG_MAX + 2 * XMM_COUNT)), &env_off, 1, "env");
}

static StackAlloca *setup_stack(TcgContext *ctx, LLVMValueRef F, FuncInstrList *f) {
    StackAlloca *stack = (StackAlloca *)calloc(1, sizeof(StackAlloca));
    stack->xreg.tcg_ty = (LLVMType *)calloc(XREG_MAX, sizeof(LLVMType));
    stack->xreg.llvm_ty = (LLVMTypeRef *)calloc(XREG_MAX, sizeof(LLVMTypeRef));
    stack->xreg.alloca = (LLVMValueRef *)calloc(XREG_MAX, sizeof(LLVMValueRef));
    stack->xreg.align = (unsigned *)calloc(XREG_MAX, sizeof(unsigned));
    stack->xreg.f_argument = (LLVMValueRef *)calloc(XREG_MAX, sizeof(LLVMValueRef));
    stack->xreg.cnt = XREG_MAX;
    for (int i = 0; i < XREG_MAX; ++i) {
        if (ctx->xreg_valid & (1 << i)) {
            stack->xreg.tcg_ty[i] = qemuaot_default_param_type[i];
            stack->xreg.llvm_ty[i] = get_llvm_type(stack->xreg.tcg_ty[i]);
            stack->xreg.alloca[i] = LLVMBuildAlloca(g_builder, stack->xreg.llvm_ty[i], qemuaot_default_stack_alloca_name[i]);
            stack->xreg.align[i] = GET_ALIGNMENT_FROM_TYPE(stack->xreg.tcg_ty[i]);
            LLVMSetAlignment(stack->xreg.alloca[i], stack->xreg.align[i]);
            build_store_with_alignment(g_builder, LLVMGetParam(F, i), stack->xreg.alloca[i], stack->xreg.align[i], SPILL_TAG);
        }
        stack->xreg.f_argument[i] = LLVMGetParam(F, i);
    }
    stack->vector.tcg_ty = (LLVMType *)calloc((2 * XMM_COUNT), sizeof(LLVMType));
    stack->vector.llvm_ty = (LLVMTypeRef *)calloc((2 * XMM_COUNT), sizeof(LLVMTypeRef));
    stack->vector.alloca = (LLVMValueRef *)calloc((2 * XMM_COUNT), sizeof(LLVMValueRef));
    stack->vector.align = (unsigned *)calloc((2 * XMM_COUNT), sizeof(unsigned));
    stack->vector.f_argument = (LLVMValueRef *)calloc((2 * XMM_COUNT), sizeof(LLVMValueRef));
    stack->vector.cnt = (2 * XMM_COUNT);
    for (int i = 0; i < (2 * XMM_COUNT); ++i) {
        if ((ctx->vec_valid & (1 << i)) || (ctx->vec_spare_valid & (1 << i))) {
            stack->vector.tcg_ty[i] = qemuaot_default_param_type[XREG_MAX + i];
            stack->vector.llvm_ty[i] = get_llvm_type(stack->vector.tcg_ty[i]);
            stack->vector.alloca[i] = LLVMBuildAlloca(g_builder, stack->vector.llvm_ty[i], qemuaot_default_stack_alloca_name[XREG_MAX + i]);
            stack->vector.align[i] = GET_ALIGNMENT_FROM_TYPE(stack->vector.tcg_ty[i]);
            LLVMSetAlignment(stack->vector.alloca[i], stack->vector.align[i]);
            build_store_with_alignment(g_builder, LLVMGetParam(F, (XREG_MAX + i)), stack->vector.alloca[i], stack->vector.align[i], SPILL_TAG);
        }
        stack->vector.f_argument[i] = LLVMGetParam(F, (XREG_MAX + i));
    }
    stack->tmp.tcg_ty = (LLVMType *)calloc(ctx->next_tmp_idx, sizeof(LLVMType));
    stack->tmp.llvm_ty = (LLVMTypeRef *)calloc(ctx->next_tmp_idx, sizeof(LLVMTypeRef));
    stack->tmp.alloca = (LLVMValueRef *)calloc(ctx->next_tmp_idx, sizeof(LLVMValueRef));
    stack->tmp.align = (unsigned *)calloc(ctx->next_tmp_idx, sizeof(unsigned));
    stack->tmp.f_argument = (LLVMValueRef *)calloc(ctx->next_tmp_idx, sizeof(LLVMValueRef));
    stack->tmp.cnt = ctx->next_tmp_idx;
    for (int i = 0; i < ctx->next_tmp_idx; ++i) {
        LLVMType stack_ty = (LLVMType)(long)g_hash_table_lookup(ctx->stack_type_map, (gpointer)(long)i);
        assert(stack_ty != LLVMInvalidType);
        char tmp_alloca_name[16] = {0};
        sprintf(&tmp_alloca_name[0], "tmp%d.stack", (i & 0xffff));
        stack->tmp.tcg_ty[i] = stack_ty;
        if (stack->tmp.tcg_ty[i] > LLVMTypeBegin && stack->tmp.tcg_ty[i] < LLVMTypeEnd) {
            stack->tmp.llvm_ty[i] = get_llvm_type(stack->tmp.tcg_ty[i]);
            stack->tmp.alloca[i] = LLVMBuildAlloca(g_builder, stack->tmp.llvm_ty[i], tmp_alloca_name);
            stack->tmp.align[i] = GET_ALIGNMENT_FROM_TYPE(stack->tmp.tcg_ty[i]);
            LLVMSetAlignment(stack->tmp.alloca[i], stack->tmp.align[i]);
        } else {
            assert(stack->tmp.tcg_ty[i] == LLVMFuncPtr);
            const UnifiedInstr *u = NULL;
            for (u = f->head; u; u = u->next) {
                if (u->opc == func_addr && u->operands[0].kind == OP_SLOT && u->operands[0].slot.type == SUB_SLOT_TMP && u->operands[0].slot.idx == i) {
                    break;
                }
            }
            if (!u) {
                continue;
            }
            LLVMTypeRef arg_types[XREG_MAX + 2 * XMM_COUNT + 1/*CPU*/ + MAX_ADDED_ARGS] = {NULL};
            int arg_cnt = 0;
            for (int j = 0; j < (XREG_MAX + 2 * XMM_COUNT); ++j) {
                arg_types[arg_cnt++] = get_llvm_type(qemuaot_default_param_type[j]);
            }
            arg_types[arg_cnt++] = LLVMPointerTypeInContext(LLVMGetModuleContext(g_module), 0);
            LLVMTypeRef f_type = NULL;
            if (u->operands[1].kind == OP_IMM) {
                assert(u->operands[2].kind == OP_IMM);
                int sub_func_idx = (int)u->operands[2].imm.val;
                if (u->operands[1].imm.val == ctx->hex_offset) {
                    FuncInstrList *sub_f = &(ctx->llvm_func_set.lists[sub_func_idx]);
                    for (int j = 0; j < sub_f->added_param_count; ++j) {
                        arg_types[arg_cnt++] = get_llvm_type(sub_f->added_param_type[j]);
                    }
                }
                f_type = LLVMFunctionType(LLVMVoidType(), arg_types, arg_cnt, 0);
            } else {
                assert(u->operands[1].kind == OP_SYMBOL);
                HelperType h = u->operands[1].symbol;
                arg_cnt = setup_helper_template_arg_type(arg_types, arg_cnt, h);
                f_type = LLVMFunctionType((h > NOSPLIT_BEGIN && h < NOSPLIT_END) ? get_llvm_type(helper_return_type[h]) : LLVMVoidType(), arg_types, arg_cnt, 0);
            }
            stack->tmp.llvm_ty[i] = f_type;
            stack->tmp.alloca[i] = LLVMBuildAlloca(g_builder,
                                  LLVMPointerTypeInContext(LLVMGetModuleContext(g_module), 0), tmp_alloca_name);
            stack->tmp.align[i] = 8;
            LLVMSetAlignment(stack->tmp.alloca[i], stack->tmp.align[i]);
        }
    }
    if (ctx->carry_on) {
        stack->carry = LLVMBuildAlloca(g_builder, LLVMInt1Type(), "carry.stack");
        LLVMSetAlignment(stack->carry, 8);
    }
    if (ctx->borrow_on) {
        stack->borrow = LLVMBuildAlloca(g_builder, LLVMInt1Type(), "borrow.stack");
        LLVMSetAlignment(stack->borrow, 8);
    }
    stack->env = get_env(F);
    stack->arg_last = LLVMGetParam(F, (LLVMCountParams(F) - 1));
    return stack;
}

void start_llvm_bb(LLVMBasicBlockRef bb, StackAlloca *stack) {
    LLVMPositionBuilderAtEnd(g_builder, bb);
}

static void release_stack(StackAlloca *stack) {
    free(stack->xreg.tcg_ty);
    free(stack->xreg.llvm_ty);
    free(stack->xreg.alloca);
    free(stack->xreg.align);
    free(stack->xreg.f_argument);
    free(stack->vector.tcg_ty);
    free(stack->vector.llvm_ty);
    free(stack->vector.alloca);
    free(stack->vector.align);
    free(stack->vector.f_argument);
    free(stack->tmp.tcg_ty);
    free(stack->tmp.llvm_ty);
    free(stack->tmp.alloca);
    free(stack->tmp.align);
    free(stack->tmp.f_argument);
    free(stack);
}

int translate_to_llvm_func(TcgContext *ctx, const char *name, FuncInstrList *f, int is_external) {
    int rc = 0;
    LLVMValueRef F = NULL;
    // FIXME: setup g_ctx for get_func_name/get_or_add_func_with_qemuaot_cc
    g_ctx = ctx;
    F = get_or_add_func_with_qemuaot_cc(name, ctx->hex_offset, 0);
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
    StackAlloca *stack = setup_stack(ctx, F, f);
    // One-to-one mapping from TCG-ops to LLVM-IR
    rc = translate_batch(g_module, g_builder, F, stack, f);
    g_ctx = NULL;
    release_stack(stack);
    return rc;
}

char *get_func_name(unsigned long hex_offset, int sub_idx, char *buf, int buf_size) {
    assert(g_ctx != NULL);
    assert(sub_idx == 0 || (g_ctx->hex_offset == hex_offset && sub_idx < g_ctx->llvm_func_set.num_lists));
    char *fname = NULL;
    if (sub_idx && g_ctx->llvm_func_set.lists[sub_idx].trampoline_name[0]) {
        fname = &g_ctx->llvm_func_set.lists[sub_idx].trampoline_name[0];
    } else {
        if (sub_idx == 0) {
            snprintf(buf, buf_size, "Fx%lx", hex_offset);
        } else {
            snprintf(buf, buf_size, "Fx%lx_%d", hex_offset, sub_idx);
        }
        fname = buf;
    }
    return fname;
}

int handle_func(TcgContext *ctx, int is_external) {
    int rc = 0;
    for (int i = 0; i < ctx->llvm_func_set.num_lists && !rc; ++i) {
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
        rc = translate_to_llvm_func(ctx, func_name, &(ctx->llvm_func_set.lists[i]), is_external);
    }
    return rc;
}

void print_usage(const char *progname) {
    fprintf(stderr, "Usage: %s [-d] [-h] <input.tir>\n", progname);
    fprintf(stderr, "  -d    Dump the mapped LLVM-IR module to stdout and exit without\n");
    fprintf(stderr, "        kicking off compilation (no passes, no object file)\n");
    fprintf(stderr, "  -h    Print this help message\n");
}

int parse_tcg_instructions(const char *filename) {
    int rc = 0;
    FILE *source_file = fopen(filename, "r");
    if (!source_file) {
        perror("Error opening source file");
        return 1;
    }
    TcgContext ctx;
    tcg_context_init(&ctx);
    yyscan_t scanner;
    yylex_init(&scanner);
    yyset_in(source_file, scanner);
    rc = yyparse(scanner, &ctx);
    yylex_destroy(scanner);
    free(lineptr);
    fclose(source_file);
    tcg_context_destroy(&ctx);
    return rc;
}

static void make_tbaa(LLVMContextRef C) {
    LLVMMetadataRef mds[3];
    LLVMValueRef zero = LLVMConstInt(LLVMInt64TypeInContext(C), 0, 0);

    mds[0] = LLVMMDStringInContext2(C, "Root", 4);
    LLVMMetadataRef root = LLVMMDNodeInContext2(C, mds, 1);

    mds[0] = LLVMMDStringInContext2(C, "CPUState", 8); mds[1] = root;
    LLVMMetadataRef cpu_ty = LLVMMDNodeInContext2(C, mds, 2);
    mds[0] = LLVMMDStringInContext2(C, "GuestMem", 8); mds[1] = root;
    LLVMMetadataRef guest_ty = LLVMMDNodeInContext2(C, mds, 2);
    mds[0] = LLVMMDStringInContext2(C, "SpillSlot", 8); mds[1] = root;
    LLVMMetadataRef spill_ty = LLVMMDNodeInContext2(C, mds, 2);

    LLVMMetadataRef tg[3];
    tg[0] = tg[1] = cpu_ty;   tg[2] = LLVMValueAsMetadata(zero);
    LLVMMetadataRef cpu_tag = LLVMMDNodeInContext2(C, tg, 3);
    tg[0] = tg[1] = guest_ty; tg[2] = LLVMValueAsMetadata(zero);
    LLVMMetadataRef guest_tag = LLVMMDNodeInContext2(C, tg, 3);
    tg[0] = tg[1] = spill_ty; tg[2] = LLVMValueAsMetadata(zero);
    LLVMMetadataRef spill_tag = LLVMMDNodeInContext2(C, tg, 3);

    g_tbaa.cpu_tag   = LLVMMetadataAsValue(C, cpu_tag);
    g_tbaa.guest_tag = LLVMMetadataAsValue(C, guest_tag);
    g_tbaa.spill_tag = LLVMMetadataAsValue(C, spill_tag);
    g_tbaa.kind      = LLVMGetMDKindIDInContext(C, "tbaa", 4);   /* cache this */
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

    g_module = LLVMModuleCreateWithName("qemuaot");
    LLVMContextRef context = LLVMGetModuleContext(g_module);
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

#if defined(__aarch64__)
    LLVMSetTarget(g_module, "aarch64-unknown-linux-gnu");
#elif (defined(__riscv) && __riscv_xlen == 64)
    LLVMSetTarget(g_module, "riscv64-unknown-linux-gnu");
#endif

    g_builder = LLVMCreateBuilder();

    make_tbaa(LLVMGetModuleContext(g_module));
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

    // Get the path for intermediate output files
    g_output_path = realpath(input_file, NULL);
    assert(g_output_path);
    p = g_output_path;
    assert(p);
    while (strstr(p, "/") != NULL) {
        p = strstr(p, "/");
        if (*p == '/') {
            p += 1;
        }
    }
    assert((p - g_output_path) < PATH_MAX);
    *p = '\0';

    // Initialize LLVM target machine
    rc = init_llvm();
    if (rc != 0) {
        goto exit;
    }

    // Parse/Expand/Map TCG-ops into LLVM-IR
    rc = parse_tcg_instructions(input_file);
    if (rc != 0) {
        goto exit;
    }

    // Invoke LLVM pipeline to produce object file
    rc = fini_llvm(output_file);
    if (rc != 0) {
        goto exit;
    }

exit:
    if (g_template_path) {
        free(g_template_path);
    }
    if (g_output_path) {
        free(g_output_path);
    }
    if (output_file) {
        free(output_file);
    }
    return rc;
}
