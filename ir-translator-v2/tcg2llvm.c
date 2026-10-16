/*
 * FIXME: copyright
 */
#include <stdio.h>
#include "tcg2llvm.h"
#include "mapper.h"
#include "util.h"
#include "mapper_util.h"
#include <assert.h>
#include "tcg_llvm_tag.h"
#include "operand_static_types.h"
#include "i386_cpu.h"

typedef LLVMValueRef (*LLVM_BIN_API)(LLVMBuilderRef B, LLVMValueRef LHS, LLVMValueRef RHS, const char *Name);

void translate_common(LLVMBuilderRef builder, LLVM_BIN_API llvm_api, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    assert(u->operand_count == 3);
    LLVMValueRef in1 = NULL;
    if (u->operands[1].kind == OP_ENV && u->operands[1].env.offset == 0) {
        in1 = LLVMBuildPtrToInt(builder, stack->env, get_llvm_type(u->operands[1].env.op_type), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "env"));
    } else {
        in1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    }
    LLVMValueRef in2 = NULL;
    if (u->operands[2].kind == OP_ENV && u->operands[2].env.offset == 0) {
        in2 = LLVMBuildPtrToInt(builder, stack->env, get_llvm_type(u->operands[1].env.op_type), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "env"));
    } else {
        in2 = get_input_val_for_operand(&u->operands[2], stack, prefix);
    }
    LLVMValueRef out = llvm_api(builder, in1, in2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_mov(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef in = get_input_val_for_operand(&u->operands[1], stack, prefix);
    if (get_operand_type(&u->operands[1]) > get_operand_type(&u->operands[0])) {
        in = LLVMBuildTrunc(builder, in, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(in), "trunc"));
    }
    do_store(&u->operands[0], in, stack, prefix, false);
}

void translate_addc_subb(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    bool is_add = (u->opc == addci_i32 || u->opc == addci_i64 ||
                  u->opc == addco_i32 || u->opc == addco_i64 ||
                  u->opc == addcio_i32 || u->opc == addcio_i64 ||
                  u->opc == addc1o_i32 || u->opc == addc1o_i64);
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    LLVMTypeRef llvm_ty = get_llvm_type(tcg_ty);
    LLVMTypeRef intrinsic_types[] = {llvm_ty, llvm_ty};
    char intrinsic_func[128] = {0};
    sprintf(intrinsic_func, "llvm.%s.with.overflow.i%d", is_add ? "uadd" : "usub", llvm_vector_elem_bit_counts[tcg_ty * 2 + 1]);
    LLVMValueRef fn = get_intrinsic_declaration(intrinsic_func, intrinsic_types, 2);
    LLVMTypeRef ret_args[] = {llvm_ty, LLVMInt1Type()};
    LLVMTypeRef ret_type = LLVMStructType(ret_args, 2, false);
    LLVMTypeRef fn_type  = LLVMFunctionType(ret_type, intrinsic_types, 2, false);

    LLVMValueRef in1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef in2 = get_input_val_for_operand(&u->operands[2], stack, prefix);
    LLVMValueRef intrinsic_call1_args[] = {in1, in2};
    LLVMValueRef call1 = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call1_args, 2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "r1"));
    LLVMValueRef s1 = LLVMBuildExtractValue(builder, call1, 0, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "s1"));
    LLVMValueRef c1 = LLVMBuildExtractValue(builder, call1, 1, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "c1"));
    if (u->opc == addco_i32 || u->opc == addco_i64 ||
        u->opc == subbo_i32 || u->opc == subbo_i64) {
        do_store(&u->operands[0], s1, stack, prefix, false);
        build_store_with_alignment(builder, c1, is_add ? stack->carry : stack->borrow, 8, SPILL_TAG);
        return;
    }
    LLVMValueRef ci = (u->opc == addc1o_i32 || u->opc == addc1o_i64 ||
                      u->opc == subb1o_i32 || u->opc == subb1o_i64) ?
                    LLVMConstInt(LLVMInt1Type(), 1, 0) :
                    build_load_with_alignment(builder, LLVMInt1Type(), is_add ? stack->carry : stack->borrow, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "ci"), 8, SPILL_TAG);
    LLVMValueRef ci_ext = LLVMBuildZExt(builder, ci, llvm_ty, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "ci_ext"));
    LLVMValueRef intrinsic_call2_args[] = {s1, ci_ext};
    LLVMValueRef call2 = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call2_args, 2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "r2"));
    LLVMValueRef s2 = LLVMBuildExtractValue(builder, call2, 0, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "s2"));
    do_store(&u->operands[0], s2, stack, prefix, false);
    if (u->opc == addci_i32 || u->opc == addci_i64 ||
        u->opc == subbi_i32 || u->opc == subbi_i64) {
        return;
    }
    LLVMValueRef c2 = LLVMBuildExtractValue(builder, call2, 1, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "c2"));
    LLVMValueRef co = LLVMBuildOr(builder, c1, c2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "co"));
    build_store_with_alignment(builder, co, is_add ? stack->carry : stack->borrow, 8, SPILL_TAG);
}

void translate_abs_vec(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    LLVMTypeRef llvm_ty = get_llvm_type(tcg_ty);
    LLVMTypeRef intrinsic_types[] = {llvm_ty, LLVMInt1Type()};
    char intrinsic_func[128] = {0};
    sprintf(intrinsic_func, "llvm.abs.v%di%d", llvm_vector_elem_bit_counts[tcg_ty * 2], llvm_vector_elem_bit_counts[tcg_ty * 2 + 1]);
    LLVMValueRef fn = get_intrinsic_declaration(intrinsic_func, intrinsic_types, 2);
    LLVMTypeRef fn_type  = LLVMFunctionType(llvm_ty, intrinsic_types, 2, 0);
    LLVMValueRef in = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef is_int_min_poison = LLVMConstInt(LLVMInt1Type(), 0, 0);
    LLVMValueRef intrinsic_call_args[] = {in, is_int_min_poison};
    LLVMValueRef abs = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call_args, 2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "abs"));
    do_store(&u->operands[0], abs, stack, prefix, false);
}

static LLVMValueRef do_bitsel_vec(LLVMBuilderRef builder, LLVMValueRef sel, LLVMValueRef a, LLVMValueRef b, const char *prefix) {
    char var_name[32] = {0};
    return LLVMBuildOr(builder,
                          LLVMBuildAnd(builder, a, sel, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "and_a_sel")),
                          LLVMBuildAnd(builder, b,
                              LLVMBuildNot(builder, sel, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "nsel")),
                                          assemble_name_2(&var_name[0], sizeof(var_name), prefix, "and_b_nsel")),
                          assemble_name_2(&var_name[0], sizeof(var_name), prefix, "or"));
}

void translate_bitsel_vec(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    LLVMValueRef out = do_bitsel_vec(builder, get_input_val_for_operand(&u->operands[1], stack, prefix),
                                    get_input_val_for_operand(&u->operands[2], stack, prefix),
                                    get_input_val_for_operand(&u->operands[3], stack, prefix), prefix);
    do_store(&u->operands[0], out, stack, prefix, false);
}

static LLVMValueRef do_cond(LLVMBuilderRef builder, LLVMValueRef in1, LLVMValueRef in2, RelopType r, LLVMType ty, const char *prefix) {
    char var_name[32] = {0};
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        in1 = LLVMBuildAnd(builder, in1, in2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "tst"));
        in2 = LLVMConstInt(get_llvm_type(ty), 0, 0);
    }
    assert(r < RELOP_MAX && llvm_predicate[r]);
    return LLVMBuildICmp(builder, llvm_predicate[r], in1, in2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "bool"));
}

static LLVMValueRef do_cmp_vec(LLVMBuilderRef builder, LLVMValueRef in1, LLVMValueRef in2, RelopType r, LLVMType ty, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef bv = do_cond(builder, in1, in2, r, ty, prefix);
    LLVMValueRef v_one = get_const_vector(-1UL, ty);
    LLVMValueRef v_zero = get_const_vector(0, ty);
    return LLVMBuildSelect(builder, bv, v_one, v_zero, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "predicate"));
}

void translate_cmp_vec(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    assert(u->operands[3].kind == OP_RELOP);
    LLVMValueRef out = do_cmp_vec(builder, get_input_val_for_operand(&u->operands[1], stack, prefix),
                        get_input_val_for_operand(&u->operands[2], stack, prefix),
                        u->operands[3].relop, get_operand_type(&u->operands[0]), prefix);
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_cmpsel_vec(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    assert(u->operands[5].kind == OP_RELOP);
    LLVMValueRef select = do_cmp_vec(builder, get_input_val_for_operand(&u->operands[1], stack, prefix),
                        get_input_val_for_operand(&u->operands[2], stack, prefix),
                        u->operands[5].relop, get_operand_type(&u->operands[0]), prefix);
    LLVMValueRef out = do_bitsel_vec(builder, select,
                                    get_input_val_for_operand(&u->operands[3], stack, prefix),
                                    get_input_val_for_operand(&u->operands[4], stack, prefix), prefix);
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_ctpop(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    LLVMTypeRef llvm_ty = get_llvm_type(tcg_ty);
    LLVMTypeRef intrinsic_types[] = {llvm_ty};
    char intrinsic_func[128] = {0};
    if (tcg_ty <= LLVMInt64) {
        sprintf(intrinsic_func, "llvm.ctpop.i%d", llvm_vector_elem_bit_counts[tcg_ty * 2 + 1]);
    } else {
        sprintf(intrinsic_func, "llvm.ctpop.v%di%d", llvm_vector_elem_bit_counts[tcg_ty * 2], llvm_vector_elem_bit_counts[tcg_ty * 2 + 1]);
    }
    LLVMValueRef fn = get_intrinsic_declaration(intrinsic_func, intrinsic_types, 1);
    LLVMTypeRef fn_type  = LLVMFunctionType(llvm_ty, intrinsic_types, 1, 0);
    LLVMValueRef in = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef intrinsic_call_args[] = {in};
    LLVMValueRef pop = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call_args, 1, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "pop"));
    do_store(&u->operands[0], pop, stack, prefix, false);
}

static LLVMBasicBlockRef get_bb(LLVMValueRef F, const char *name) {
    LLVMBasicBlockRef bb = LLVMGetFirstBasicBlock(F);
    while (bb != NULL) {
        const char *block_name = LLVMGetBasicBlockName(bb);
        if (block_name != NULL && strcmp(block_name, name) == 0) {
            return bb;
        }
        bb = LLVMGetNextBasicBlock(bb);
    }
    return NULL;
}

void translate_set_label(LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    assert(u->operands[0].kind == OP_LABEL);
    char label_name[16] = {0};
    sprintf(label_name, "bb_L%d", u->operands[0].label);
    LLVMBasicBlockRef label = get_bb(F, &label_name[0]);
    if (!label) {
        label = LLVMAppendBasicBlock(F, &label_name[0]);
    }
    start_llvm_bb(label, stack);
}

void translate_br(LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    assert(u->operands[0].kind == OP_LABEL);
    char label_name[16] = {0};
    sprintf(label_name, "bb_L%d", u->operands[0].label);
    LLVMBasicBlockRef label = get_bb(F, &label_name[0]);
    if (!label) {
        label = LLVMAppendBasicBlock(F, &label_name[0]);
    }
    LLVMBuildBr(builder, label);
}

void translate_ld_zext(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef in = NULL;
    if (u->operand_count == 2) {
        in = get_input_val_for_operand(&u->operands[1], stack, prefix);
    } else {
        assert(u->operand_count == 3 && u->operands[1].kind == OP_VEC && u->operands[2].kind == OP_IMM);
        assert(u->operands[2].imm.val < 0x10);
        Operand op_vec_offset = u->operands[1];
        op_vec_offset.vec.offset = u->operands[2].imm.val;
        in = get_input_val_for_operand(&op_vec_offset, stack, prefix);
    }
    LLVMValueRef out = LLVMBuildZExt(builder, in, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_ld_sext(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef in = NULL;
    if (u->operand_count == 2) {
        in = get_input_val_for_operand(&u->operands[1], stack, prefix);
    } else {
        assert(u->operand_count == 3 && u->operands[1].kind == OP_VEC && u->operands[2].kind == OP_IMM);
        assert(u->operands[2].imm.val < 0x10);
        Operand op_vec_offset = u->operands[1];
        op_vec_offset.vec.offset = u->operands[2].imm.val;
        in = get_input_val_for_operand(&op_vec_offset, stack, prefix);
    }
    LLVMValueRef out = LLVMBuildSExt(builder, in, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_ld(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    LLVMValueRef in = NULL;
    if (u->operand_count == 2) {
        in = get_input_val_for_operand(&u->operands[1], stack, prefix);
    } else {
        assert(u->operand_count == 3 && u->operands[1].kind == OP_VEC && u->operands[2].kind == OP_IMM);
        assert(u->operands[2].imm.val < 0x10);
        Operand op_vec_offset = u->operands[1];
        op_vec_offset.vec.offset = u->operands[2].imm.val;
        in = get_input_val_for_operand(&op_vec_offset, stack, prefix);
    }
    do_store(&u->operands[0], in, stack, prefix, false);
}

void translate_ld_with_attr(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    assert(u->operands[1].kind == OP_SLOT && u->operands[2].kind == OP_ATTR);
    Operand op_addr = u->operands[1];
    assert(op_addr.slot.type == SUB_SLOT_XREG || op_addr.slot.type == SUB_SLOT_TMP);
    // Dirty hack to set address size
    op_addr.slot.op_type = LLVMInt64;
    assert(op_addr.slot.op_type <= (op_addr.slot.type == SUB_SLOT_TMP ? stack->tmp.tcg_ty[op_addr.slot.idx] : stack->xreg.tcg_ty[op_addr.slot.idx]));
    LLVMValueRef addr = get_input_val_for_operand(&op_addr, stack, prefix);
    LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(get_llvm_type(u->operands[1].slot.op_type), 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(addr), "ptr"));
    LLVMValueRef val = build_load_with_alignment(builder, get_llvm_type(u->operands[1].slot.op_type), ptr, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "ld"), alignment_from_attr(u->operands[2].attr_info, u->operands[1].slot.op_type), GUEST_TAG);
    if (u->operands[1].slot.op_type < get_operand_type(&u->operands[0])) {
        if (u->operands[2].attr_info.p.storage.ext == SIGN) {
            val = LLVMBuildSExt(builder, val, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "sext"));
        } else {
            val = LLVMBuildZExt(builder, val, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "zext"));
        }
    }
    if (get_operand_type(&u->operands[1]) > get_operand_type(&u->operands[0])) {
        val = LLVMBuildTrunc(builder, val, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "trunc"));
    }
    do_store(&u->operands[0], val, stack, prefix, false);
}

void translate_ld2_with_attr(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    assert(u->operands[2].kind == OP_SLOT && u->operands[3].kind == OP_ATTR);
    Operand op_addr = u->operands[2];
    assert(op_addr.slot.type == SUB_SLOT_XREG || op_addr.slot.type == SUB_SLOT_TMP);
    // Dirty hack to set address size
    op_addr.slot.op_type = LLVMInt64;
    assert(op_addr.slot.op_type <= (op_addr.slot.type == SUB_SLOT_TMP ? stack->tmp.tcg_ty[op_addr.slot.idx] : stack->xreg.tcg_ty[op_addr.slot.idx]));
    LLVMValueRef addr = get_input_val_for_operand(&op_addr, stack, prefix);
    LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(get_llvm_type(LLVMVector2xi64), 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(addr), "ptr"));
    LLVMValueRef val = build_load_with_alignment(builder, get_llvm_type(LLVMVector2xi64), ptr, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "ld"), alignment_from_attr(u->operands[3].attr_info, LLVMVector2xi64), GUEST_TAG);
    LLVMValueRef elem0 = LLVMBuildExtractElement(builder, val, LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "ee"));
    do_store(&u->operands[0], elem0, stack, prefix, false);
    LLVMValueRef elem1 = LLVMBuildExtractElement(builder, val, LLVMConstInt(get_llvm_type(LLVMInt64), 1, 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "ee"));
    do_store(&u->operands[1], elem1, stack, prefix, false);
}

void translate_st(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef val = get_input_val_for_operand(&u->operands[0], stack, prefix);
    Operand out = u->operands[1];
    if (u->operand_count == 3) {
        assert(u->operands[1].kind == OP_VEC && u->operands[2].kind == OP_IMM);
        assert(u->operands[2].imm.val < 0x10);
        out.vec.offset = u->operands[2].imm.val;
    }
    if (get_operand_type(&u->operands[0]) > get_operand_type(&u->operands[1])) {
        val = LLVMBuildTrunc(builder, val, get_llvm_type(get_operand_type(&u->operands[1])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "trunc"));
    }
    bool skip_env_check = false;
    if (u->operands[0].kind == OP_SLOT && u->operands[0].slot.type == SUB_SLOT_XREG && u->operands[1].kind == OP_ENV && env_regs_offset[u->operands[0].slot.idx] == u->operands[1].env.offset) {
        skip_env_check = true;
    } else if (u->operands[0].kind == OP_VEC && u->operands[1].kind == OP_ENV && get_vec_offset(u->operands[0].vec.idx) == u->operands[1].env.offset) {
        skip_env_check = true;
    }
    do_store(&out, val, stack, prefix, skip_env_check);
}

void translate_st_with_attr(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    assert(u->operands[1].kind == OP_SLOT && u->operands[2].kind == OP_ATTR);
    Operand op_addr = u->operands[1];
    assert(op_addr.slot.type == SUB_SLOT_XREG || op_addr.slot.type == SUB_SLOT_TMP);
    // Dirty hack to set address size
    op_addr.slot.op_type = LLVMInt64;
    assert(op_addr.slot.op_type <= (op_addr.slot.type == SUB_SLOT_TMP ? stack->tmp.tcg_ty[op_addr.slot.idx] : stack->xreg.tcg_ty[op_addr.slot.idx]));
    LLVMValueRef addr = get_input_val_for_operand(&op_addr, stack, prefix);
    LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(get_llvm_type(u->operands[1].slot.op_type), 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(addr), "ptr"));
    LLVMValueRef val = get_input_val_for_operand(&u->operands[0], stack, prefix);
    LLVMType src_ty = get_operand_type(&u->operands[0]);
    if (u->operands[1].slot.op_type < src_ty) {
        val = shrink_llvm_value(val, src_ty, u->operands[1].slot.op_type);
    } else if (u->operands[1].slot.op_type > src_ty) {
        if (u->operands[2].attr_info.p.storage.ext == SIGN) {
            val = LLVMBuildSExt(builder, val, get_llvm_type(u->operands[1].slot.op_type), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "sext"));
        } else {
            val = LLVMBuildZExt(builder, val, get_llvm_type(u->operands[1].slot.op_type), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "zext"));
        }
    }
    build_store_with_alignment(builder, val, ptr, alignment_from_attr(u->operands[2].attr_info, u->operands[1].slot.op_type), GUEST_TAG);
}

void translate_st2_with_attr(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    assert(u->operands[2].kind == OP_SLOT && u->operands[3].kind == OP_ATTR);
    Operand op_addr = u->operands[2];
    assert(op_addr.slot.type == SUB_SLOT_XREG || op_addr.slot.type == SUB_SLOT_TMP);
    // Dirty hack to set address size
    op_addr.slot.op_type = LLVMInt64;
    assert(op_addr.slot.op_type <= (op_addr.slot.type == SUB_SLOT_TMP ? stack->tmp.tcg_ty[op_addr.slot.idx] : stack->xreg.tcg_ty[op_addr.slot.idx]));
    LLVMValueRef addr = get_input_val_for_operand(&op_addr, stack, prefix);
    LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(get_llvm_type(LLVMVector2xi64), 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(addr), "ptr"));

    LLVMValueRef elem0 = get_input_val_for_operand(&u->operands[0], stack, prefix);
    LLVMValueRef elem1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    Operand out;
    out.kind = OP_IMM;
    out.imm.val = 0;
    out.imm.op_type = LLVMVector2xi64;
    LLVMValueRef val = get_input_val_for_operand(&out, stack, prefix);
    val = LLVMBuildInsertElement(builder, val, elem0, LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0), assemble_name_3(&var_name[0], sizeof(var_name), prefix, "st2", "ie"));
    val = LLVMBuildInsertElement(builder, val, elem1, LLVMConstInt(get_llvm_type(LLVMInt64), 1, 0), assemble_name_3(&var_name[0], sizeof(var_name), prefix, "st2", "ie"));
    build_store_with_alignment(builder, val, ptr, alignment_from_attr(u->operands[3].attr_info, u->operands[2].slot.op_type), GUEST_TAG);
}

int translate_func_addr(LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char fname[32] = {0};
    LLVMValueRef TF = NULL;
    if (u->operands[1].kind == OP_IMM) {
        assert(u->operands[2].kind == OP_IMM);
        TF = get_or_add_func_with_qemuaot_cc(get_func_name(u->operands[1].imm.val, (int)u->operands[2].imm.val, &fname[0], sizeof(fname)), u->operands[1].imm.val, (int)u->operands[2].imm.val);
    } else {
        assert(u->operands[1].kind == OP_SYMBOL);
        TF = get_or_add_helper_with_qemuaot_cc(u->operands[1].symbol, u);
        if (!TF) {
            return 1;
        }
    }
    assert(u->operands[0].kind == OP_SLOT && u->operands[0].slot.type == SUB_SLOT_TMP);
    int tmp_slot = u->operands[0].slot.idx;
    build_store_with_alignment(builder, TF, stack->tmp.alloca[tmp_slot], stack->tmp.align[tmp_slot], SPILL_TAG);
    return 0;
}

void translate_call_qemuaot(LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, bool is_tail) {
    char var_name[32] = {0};
    LLVMValueRef call_args[XREG_MAX + 2 * XMM_COUNT + 1/*CPU*/ + MAX_ADDED_ARGS] = {NULL};
    int arg_cnt = 0;
    for (int i = 0; i < XREG_MAX; ++i) {
        if (stack->xreg.alloca[i]) {
            call_args[arg_cnt++] = load_from_stack_as_type(&stack->xreg, i, stack->xreg.tcg_ty[i], prefix, qemuaot_default_stack_alloca_name[i]);
        } else {
            call_args[arg_cnt++] = LLVMGetParam(F, i);
        }
    }
    for (int i = 0; i < (2 * XMM_COUNT); ++i) {
        if (stack->vector.alloca[i]) {
            call_args[arg_cnt++] = load_from_stack_as_type(&stack->vector, i, stack->vector.tcg_ty[i], prefix, qemuaot_default_stack_alloca_name[XREG_MAX + i]);
        } else {
            call_args[arg_cnt++] = LLVMGetParam(F, (XREG_MAX + i));
        }
    }
    call_args[arg_cnt++] = LLVMGetParam(F, (XREG_MAX + 2 * XMM_COUNT));
    assert(u->operands[TCG_CALL_OUT_FLAG_IDX].kind == OP_IMM);
    for (int i = (u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val ? (TCG_CALL_PREFIX_COUNT + 1) : TCG_CALL_PREFIX_COUNT);
         i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_ENV && u->operands[i].env.offset == 0) {
            call_args[arg_cnt++] = LLVMBuildPtrToInt(builder, stack->env, get_llvm_type(LLVMInt64), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "env"));
        } else if (u->operands[i].kind == OP_ARG) {
            if (u->operands[i].argidx == -1) {
                call_args[arg_cnt++] = LLVMGetParam(F, (LLVMCountParams(F) - 1));
            } else {
                call_args[arg_cnt++] = LLVMGetParam(F, (XREG_MAX + 2 * XMM_COUNT + 1 + u->operands[i].argidx));
            }
        } else if (u->operands[i].kind != OP_VEC) {
            call_args[arg_cnt++] = get_input_val_for_operand(&u->operands[i], stack, prefix);
        }
    }
    LLVMTypeRef f_type = NULL;
    LLVMValueRef loaded_fn = NULL;
    if (u->operands[0].kind == OP_SLOT && u->operands[0].slot.type == SUB_SLOT_TMP) {
        int func_slot = u->operands[0].slot.idx;
        assert(stack->tmp.alloca[func_slot] != NULL);
        f_type = stack->tmp.llvm_ty[func_slot];
        if (stack->tmp.tcg_ty[func_slot] != LLVMFuncPtr) {
            LLVMTypeRef arg_types[XREG_MAX + 2 * XMM_COUNT + 1/*CPU*/ + MAX_ADDED_ARGS] = {NULL};
            int arg_cnt = 0;
            for (int i = 0; i < (XREG_MAX + 2 * XMM_COUNT); ++i) {
                arg_types[arg_cnt++] = get_llvm_type(qemuaot_default_param_type[i]);
            }
            arg_types[arg_cnt++] = LLVMPointerType(get_llvm_type(LLVMInt64), 0);
            // This is the shadow stack slot
            f_type = LLVMFunctionType(LLVMVoidType(), arg_types, arg_cnt, 0);
        }
        loaded_fn = LLVMBuildLoad2(builder, LLVMPointerType(f_type, 0), stack->tmp.alloca[func_slot], assemble_name_2(&var_name[0], sizeof(var_name), prefix, "loaded_fn"));
    } else {
        assert(u->operands[0].kind == OP_ARG && u->operands[0].argidx == -1);
        LLVMTypeRef arg_types[XREG_MAX + 2 * XMM_COUNT + 1/*CPU*/ + MAX_ADDED_ARGS] = {NULL};
        int arg_cnt = 0;
        for (int i = 0; i < (XREG_MAX + 2 * XMM_COUNT); ++i) {
            arg_types[arg_cnt++] = get_llvm_type(qemuaot_default_param_type[i]);
        }
        arg_types[arg_cnt++] = LLVMPointerType(get_llvm_type(LLVMInt64), 0);
        for (int i = (u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val ? (TCG_CALL_PREFIX_COUNT + 1) : TCG_CALL_PREFIX_COUNT);
             i < u->operand_count; ++i) {
            assert(u->operands[i].kind == OP_SLOT);
            arg_types[arg_cnt++] = get_llvm_type(u->operands[i].slot.op_type);
        }
        // This is the tail call to the next call pointer
        f_type = LLVMFunctionType(LLVMVoidType(), arg_types, arg_cnt, 0);
        loaded_fn = LLVMBuildIntToPtr(builder, LLVMGetParam(F, (LLVMCountParams(F) - 1)), LLVMPointerType(f_type, 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "loaded_fn"));
    }
    LLVMValueRef call_inst = LLVMBuildCall2(builder, f_type, loaded_fn, call_args, arg_cnt, u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val ? assemble_name_2(&var_name[0], sizeof(var_name), prefix, "cr") : "");
    if (is_tail) {
        LLVMSetTailCall(call_inst, 1);
    }
    LLVMSetInstructionCallConv(call_inst, QEMUAOT_CC);
    if (is_tail) {
        LLVMBuildRetVoid(builder);
    }
    if (u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val) {
        assert(u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val);
        do_store(&u->operands[TCG_CALL_PREFIX_COUNT], call_inst, stack, prefix, false);
    }
}

void translate_call_default(LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, bool is_tail) {
    char var_name[32] = {0};
    assert(u->operands[0].kind == OP_SYMBOL);
    HelperType h = u->operands[0].symbol;
    LLVMValueRef TF = get_or_add_func_with_default_cc(h, u);
    LLVMValueRef call_args[MAX_ADDED_ARGS] = {NULL};
    int arg_cnt = 0;
    assert(u->operands[TCG_CALL_OUT_FLAG_IDX].kind == OP_IMM);
    for (int i = (u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val ? (TCG_CALL_PREFIX_COUNT + 1) : TCG_CALL_PREFIX_COUNT);
         i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_ENV && u->operands[i].env.offset == 0) {
            call_args[arg_cnt++] = LLVMBuildPtrToInt(builder, stack->env, get_llvm_type(LLVMInt64), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "env"));
        } else if (u->operands[i].kind == OP_ARG) {
            if (u->operands[i].argidx == -1) {
                assert(LLVMCountParams(F) > (XREG_MAX + 2 * XMM_COUNT + 1));
                call_args[arg_cnt++] = LLVMGetParam(F, (LLVMCountParams(F) - 1));
            } else {
                assert((XREG_MAX + 2 * XMM_COUNT + 1 + u->operands[i].argidx) < LLVMCountParams(F));
                call_args[arg_cnt++] = LLVMGetParam(F, (XREG_MAX + 2 * XMM_COUNT + 1 + u->operands[i].argidx));
            }
        } else {
            call_args[arg_cnt++] = get_input_val_for_operand(&u->operands[i], stack, prefix);
        }
    }
    LLVMValueRef call_inst = LLVMBuildCall2(builder, LLVMGlobalGetValueType(TF), TF, call_args, arg_cnt, u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val ? assemble_name_2(&var_name[0], sizeof(var_name), prefix, "cr") : "");
    if (is_tail) {
        LLVMSetTailCall(call_inst, 1);
        LLVMBuildRetVoid(builder);
    }
    if (u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val) {
        assert(u->operands[TCG_CALL_OUT_FLAG_IDX].imm.val);
        do_store(&u->operands[TCG_CALL_PREFIX_COUNT], call_inst, stack, prefix, false);
    }
}

void translate_brcond(LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    assert(u->operands[2].kind == OP_RELOP);
    LLVMValueRef bv = do_cond(builder, get_input_val_for_operand(&u->operands[0], stack, prefix),
                              get_input_val_for_operand(&u->operands[1], stack, prefix),
                              u->operands[2].relop, (u->opc == brcond_i64 ? LLVMInt64 : LLVMInt32), prefix);
    //LLVMBasicBlockRef cur = LLVMGetInsertBlock(builder);
    LLVMBasicBlockRef bb_false = LLVMAppendBasicBlock(F, "bb_false");
    assert(u->operands[3].kind == OP_LABEL);
    char true_bb_name[16] = {0};
    snprintf(true_bb_name, sizeof(true_bb_name), "bb_L%d", u->operands[3].label);
    LLVMBasicBlockRef bb_true = get_bb(F, &true_bb_name[0]);
    if (!bb_true) {
        bb_true = LLVMAppendBasicBlock(F, &true_bb_name[0]);
    }
    //LLVMPositionBuilderAtEnd(builder, cur);
    LLVMBuildCondBr(builder, bv, bb_true, bb_false);
    LLVMPositionBuilderAtEnd(builder, bb_false);
}

static void print_operand(const Operand *op, int is_output, SBuf *b) {
    if (is_output) {
        sbuf_putc(b, '[');
    }
    switch (op->kind) {
    case OP_SLOT:
        switch (op->slot.type) {
        case SUB_SLOT_ENVVAR:
            sbuf_printf(b, "%s(env)", envvar_type_str[op->slot.idx]);
            break;
        case SUB_SLOT_XREG:
            sbuf_printf(b, "%s", xreg_type_str[op->slot.idx]);
            break;
        case SUB_SLOT_TMP:
            sbuf_printf(b, "t%d", op->slot.idx);
            break;
        default:
            assert(0);
        }
        break;
    case OP_IMM:
        sbuf_printf(b, "0x%lx", op->imm.val);
        break;
    case OP_LABEL:
        sbuf_printf(b, "L%d", op->label);
        break;
    case OP_RELOP:
        sbuf_printf(b, "%s", relop_type_str[op->relop]);
        break;
    case OP_ATTR:
        sbuf_printf(b, "attr");
        assert(op->attr_info.subt != SUB_ATTR_INVALID);
        sbuf_printf(b, "-");
        if (op->attr_info.subt == SUB_ATTR_STORAGE) {
            sbuf_printf(b, "stg");
            sbuf_printf(b, ":%s", atomic_type_str[op->attr_info.p.storage.atomic]);
            sbuf_printf(b, ":%s", alignment_type_str[op->attr_info.p.storage.alignment]);
            sbuf_printf(b, ":%s", srcext_type_str[op->attr_info.p.storage.ext]);
            sbuf_printf(b, ":%s", srcsize_type_str[op->attr_info.p.storage.size]);
        } else {
            sbuf_printf(b, "swp");
            sbuf_printf(b, "%s", (op->attr_info.p.swap & (1 << 0)) ? ":iz" : "");
            sbuf_printf(b, "%s", (op->attr_info.p.swap & (1 << 1)) ? ":oz" : "");
            sbuf_printf(b, "%s", (op->attr_info.p.swap & (1 << 2)) ? ":is" : "");
            sbuf_printf(b, "%s", (op->attr_info.p.swap & (1 << 3)) ? ":os" : "");
        }
        break;
    case OP_SYMBOL:
        sbuf_printf(b, "%s", helper_str[op->symbol]);
        break;
    case OP_VEC:
        if (op->vec.offset == 0) {
            sbuf_printf(b, "v%d", op->vec.idx);
        } else {
            sbuf_printf(b, "v%d:o%d", op->vec.idx, op->vec.offset);
        }
        break;
    case OP_ENV:
        if (op->env.offset == 0) {
            sbuf_printf(b, "env");
        } else {
            sbuf_printf(b, "env:0x%lx", op->env.offset);
        }
        break;
    case OP_ARG:
        if (op->argidx == -1) {
            sbuf_printf(b, "__last_arg__");
        } else {
            sbuf_printf(b, "arg%d", op->argidx);
        }
        break;
    default:
        assert(0);
    }
    if (is_output) {
        sbuf_putc(b, ']');
    }
}

static void print_instr(const UnifiedInstr *u, SBuf *b) {
    sbuf_printf(b, "%s", opcode_type_str[u->opc]);
    if (u->opc == call) {
        sbuf_printf(b, " %s,", helper_str[u->operands[0].symbol]);
        for (int i = TCG_CALL_PREFIX_COUNT; i < u->operand_count; ++i) {
            print_operand(&u->operands[i], (u->operands[2].imm.val && i == TCG_CALL_PREFIX_COUNT) ? 1 : 0, b);
            if (i < (u->operand_count - 1)) {
                sbuf_putc(b, ',');
            }
        }
        return;
    } else if (u->opc == tail_call_qemuaot || u->opc == call_qemuaot) {
        sbuf_putc(b, ' ');
        print_operand(&u->operands[0], 0, b);
        for (int i = TCG_CALL_PREFIX_COUNT; i < u->operand_count; ++i) {
            if (u->operands[i].kind != OP_VEC) {
                sbuf_putc(b, ',');
                print_operand(&u->operands[i], (u->operands[2].imm.val && i == TCG_CALL_PREFIX_COUNT) ? 1 : 0, b);
            }
        }
        sbuf_printf(b, " VEC_ARGS:");
        for (int i = TCG_CALL_PREFIX_COUNT; i < u->operand_count; ++i) {
            if (u->operands[i].kind == OP_VEC) {
                print_operand(&u->operands[i], (u->operands[2].imm.val && i == TCG_CALL_PREFIX_COUNT) ? 1 : 0, b);
                sbuf_putc(b, ',');
            }
        }
        return;
    } else if (u->opc == tail_call_default || u->opc == call_default) {
        sbuf_putc(b, ' ');
        print_operand(&u->operands[0], 0, b);
        for (int i = TCG_CALL_PREFIX_COUNT; i < u->operand_count; ++i) {
            assert(u->operands[i].kind != OP_VEC);
            sbuf_putc(b, ',');
            print_operand(&u->operands[i], (u->operands[2].imm.val && i == TCG_CALL_PREFIX_COUNT) ? 1 : 0, b);
        }
        return;
    } else if (u->vs != 0) {
        sbuf_printf(b, " v%d,e%d,", u->vs, u->es);
    } else {
        sbuf_putc(b, ' ');
    }
    for (int i = 0; i < u->operand_count; ++i) {
        print_operand(&u->operands[i], i < opcoc[u->opc] ? 1 : 0, b);
        if (i < (u->operand_count - 1)) {
            sbuf_putc(b, ',');
        }
    }
}

#define CASE(opc, entry)                            \
        case opc:                                   \
            entry(builder, stack, u, &prefix[0]);   \
            break

#define CASE_COMMON(opc, llvm_api)                                      \
        case opc:                                                       \
            translate_common(builder, llvm_api, stack, u, &prefix[0]);  \
            break

#define CASE_FUNC(opc, entry)                       \
        case opc:                                   \
            entry(builder, F, stack, u, &prefix[0]);\
            break

#define CASE_FUNC_WITH_RC(opc, entry)               \
        case opc:                                   \
            rc = entry(builder, F, stack, u, &prefix[0]);\
            break

int translate_batch(LLVMModuleRef module, LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, FuncInstrList *f) {
    int rc = 0;
    int idx = 0;
    char prefix[32] = {0};

    TcgTag tag;
    tcg_tag_init(&tag, LLVMGetModuleContext(module), builder);

#ifdef USE_TCG_DEBUGINFO
    LLVMDIBuilderRef dib = NULL;
    if (tcg_tag_setup_dbg(&tag, module, F, "tcg.ir", "tb", &dib) != 0)
        fprintf(stderr, "warning: debug info setup failed\n");
#endif

    for (const UnifiedInstr *u = f->head; u && !rc; u = u->next, ++idx) {
        snprintf(&prefix[0], sizeof(prefix), "T%d", idx);
        SBuf b;
        char dump_instr_buf[128] = {0};
        sbuf_init(&b, &dump_instr_buf[0], sizeof(dump_instr_buf));
        print_instr(u, &b);
        tcg_tag_begin(&tag, idx, "%s", &dump_instr_buf[0]);
        switch (u->opc) {
            // FIXME: support all TCG-ops
            case divs2_i32:
            case divs2_i64:
            case divu2_i32:
            case divu2_i64:
            case dup_vec:
                assert(0);
                break;

            CASE(addci_i32, translate_addc_subb);
            CASE(addci_i64, translate_addc_subb);
            CASE(addco_i32, translate_addc_subb);
            CASE(addco_i64, translate_addc_subb);
            CASE(addcio_i32, translate_addc_subb);
            CASE(addcio_i64, translate_addc_subb);
            CASE(subbi_i32, translate_addc_subb);
            CASE(subbi_i64, translate_addc_subb);
            CASE(subbo_i32, translate_addc_subb);
            CASE(subbo_i64, translate_addc_subb);
            CASE(subbio_i32, translate_addc_subb);
            CASE(subbio_i64, translate_addc_subb);
            CASE(addc1o_i32, translate_addc_subb);
            CASE(addc1o_i64, translate_addc_subb);
            CASE(subb1o_i32, translate_addc_subb);
            CASE(subb1o_i64, translate_addc_subb);
            CASE_COMMON(add_i32, LLVMBuildAdd);
            CASE_COMMON(add_i64, LLVMBuildAdd);
            CASE_COMMON(add_vec, LLVMBuildAdd);
            CASE_COMMON(sub_i32, LLVMBuildSub);
            CASE_COMMON(sub_i64, LLVMBuildSub);
            CASE_COMMON(sub_vec, LLVMBuildSub);
            CASE(extrl_i64_i32, translate_mov);
            CASE(mov_i32, translate_mov);
            CASE(mov_i64, translate_mov);
            CASE(mov_vec, translate_mov);
            CASE(abs_vec, translate_abs_vec);
            CASE(bitsel_vec, translate_bitsel_vec);
            CASE(cmp_vec, translate_cmp_vec);
            CASE(cmpsel_vec, translate_cmpsel_vec);
            CASE(ctpop_i32, translate_ctpop);
            CASE(ctpop_i64, translate_ctpop);
            CASE_COMMON(divs_i32, LLVMBuildSDiv);
            CASE_COMMON(divs_i64, LLVMBuildSDiv);
            CASE_COMMON(divu_i32, LLVMBuildUDiv);
            CASE_COMMON(divu_i64, LLVMBuildUDiv);
            CASE_COMMON(rems_i32, LLVMBuildSRem);
            CASE_COMMON(rems_i64, LLVMBuildSRem);
            CASE_COMMON(remu_i32, LLVMBuildURem);
            CASE_COMMON(remu_i64, LLVMBuildURem);
            CASE_COMMON(sarv_vec, LLVMBuildAShr);
            CASE_COMMON(shlv_vec, LLVMBuildShl);
            CASE_COMMON(shrv_vec, LLVMBuildLShr);
            CASE_COMMON(sar_i32, LLVMBuildAShr);
            CASE_COMMON(sar_i64, LLVMBuildAShr);
            CASE_COMMON(and_i32, LLVMBuildAnd);
            CASE_COMMON(and_i64, LLVMBuildAnd);
            CASE_COMMON(and_vec, LLVMBuildAnd);
            CASE_COMMON(mul_i32, LLVMBuildMul);
            CASE_COMMON(mul_i64, LLVMBuildMul);
            CASE_COMMON(mul_vec, LLVMBuildMul);
            CASE_COMMON(or_i32, LLVMBuildOr);
            CASE_COMMON(or_i64, LLVMBuildOr);
            CASE_COMMON(or_vec, LLVMBuildOr);
            CASE_COMMON(shl_i32, LLVMBuildShl);
            CASE_COMMON(shl_i64, LLVMBuildShl);
            CASE_COMMON(shr_i32, LLVMBuildLShr);
            CASE_COMMON(shr_i64, LLVMBuildLShr);
            CASE_COMMON(xor_i32, LLVMBuildXor);
            CASE_COMMON(xor_i64, LLVMBuildXor);
            CASE_COMMON(xor_vec, LLVMBuildXor);

#if 0
            case rotl_i32:
            case rotl_i64:
                translate_rotl(opc, u);
                break;
            case rotli_vec:
            case rotls_vec:
                translate_rotl_vec(opc, u);
                break;
            case rotlv_vec:
                translate_rotlv_vec(opc, u);
                break;

            case rotr_i32:
            case rotr_i64:
                translate_rotr(opc, u);
                break;
            case rotrv_vec:
                translate_rotrv_vec(opc, u);
                break;

            case sari_vec:
            case sars_vec:
                translate_binary_splat_immediate(opc, u, LLVMBuildAShr);
                break;

            case smax_vec:
                translate_binary_intrinsic(opc, u, "llvm.smax");
                break;
            case smin_vec:
                translate_binary_intrinsic(opc, u, "llvm.smin");
                break;
            case ssadd_vec:
                translate_binary_intrinsic(opc, u, "llvm.sadd.sat");
                break;
            case sssub_vec:
                translate_binary_intrinsic(opc, u, "llvm.ssub.sat");
                break;
            case usadd_vec:
                translate_binary_intrinsic(opc, u, "llvm.uadd.sat");
                break;
            case ussub_vec:
                translate_binary_intrinsic(opc, u, "llvm.usub.sat");
                break;
#endif
#if 0
            case andc_i32:
            case andc_i64:
            case andc_vec:
                translate_andc(opc, u);
                break;
            case nor_i32:
            case nor_i64:
            case nor_vec:
                translate_nor(opc, u);
                break;
            case orc_i32:
            case orc_i64:
            case orc_vec:
                translate_orc(opc, u);
                break;
            case nand_i32:
            case nand_i64:
            case nand_vec:
                translate_nand(opc, u);
                break;
            case eqv_i32:
            case eqv_i64:
            case eqv_vec:
                translate_eqv(opc, u);
                break;
            case bswap16_i32:
                translate_bswap16_i32(opc, u);
                break;
            case bswap16_i64:
                translate_bswap16_i64(opc, u);
                break;
            case bswap32_i32:
                translate_bswap32_i32(opc, u);
                break;
            case bswap32_i64:
                translate_bswap32_i64(opc, u);
                break;
            case bswap64_i64:
                translate_bswap64_i64(opc, u);
                break;
            case clz_i32:
                translate_count_zero(opc, u, "llvm.ctlz.i32");
                break;
            case clz_i64:
                translate_count_zero(opc, u, "llvm.ctlz.i64");
                break;
            case ctz_i32:
                translate_count_zero(opc, u, "llvm.cttz.i32");
                break;
            case ctz_i64:
                translate_count_zero(opc, u, "llvm.cttz.i64");
                break;
            case deposit_i32:
            case deposit_i64:
                translate_deposit(opc, u);
                break;
            case dupm_vec:
                translate_dupm_vec(opc, u);
                break;
            case extract2_i32:
            case extract2_i64:
                translate_extract2(opc, u);
                break;
            case extract_i32:
            case extract_i64:
                translate_extract(opc, u);
                break;
            case extrh_i64_i32:
                translate_extrh(opc, u);
                break;
            case ext_i32_i64:
                translate_ext(opc, u, LLVMBuildSExt);
                break;
            case extu_i32_i64:
                translate_ext(opc, u, LLVMBuildZExt);
                break;
            case movcond_i32:
            case movcond_i64:
            case movcond_vec:
                translate_movcond(opc, u);
                break;
            case mulsh_i32:
            case mulsh_i64:
                translate_mulxh(opc, u, LLVMBuildSExt);
                break;
            case muluh_i32:
            case muluh_i64:
                translate_mulxh(opc, u, LLVMBuildZExt);
                break;
            case muls2_i32:
            case muls2_i64:
                translate_muls2(opc, u);
                break;
            case mulu2_i32:
            case mulu2_i64:
                translate_mulu2(opc, u);
                break;
            case neg_i32:
            case neg_i64:
            case neg_vec:
                translate_neg(opc, u);
                break;
            case negsetcond_i32:
            case negsetcond_i64:
                translate_negsetcond(opc, u);
                break;
            case not_i32:
            case not_i64:
            case not_vec:
                translate_not(opc, u);
                break;
#endif
            CASE(ld8u_i32, translate_ld_zext);
            CASE(ld8u_i64, translate_ld_zext);
            CASE(ld16u_i32, translate_ld_zext);
            CASE(ld16u_i64, translate_ld_zext);
            CASE(ld32u_i64, translate_ld_zext);
            CASE(ld8s_i32, translate_ld_sext);
            CASE(ld8s_i64, translate_ld_sext);
            CASE(ld16s_i32, translate_ld_sext);
            CASE(ld16s_i64, translate_ld_sext);
            CASE(ld32s_i64, translate_ld_sext);
            CASE(ld_vec, translate_ld);
            CASE(ld_i32, translate_ld);
            CASE(ld_i64, translate_ld);
            CASE(qemu_ld_i32, translate_ld_with_attr);
            CASE(qemu_ld_i64, translate_ld_with_attr);
            CASE(qemu_ld2_i128, translate_ld2_with_attr);
            CASE(st8_i32, translate_st);
            CASE(st8_i64, translate_st);
            CASE(st16_i32, translate_st);
            CASE(st16_i64, translate_st);
            CASE(st32_i64, translate_st);
            CASE(st_i32, translate_st);
            CASE(st_i64, translate_st);
            CASE(st_vec, translate_st);
            CASE(qemu_st_i32, translate_st_with_attr);
            CASE(qemu_st_i64, translate_st_with_attr);
            CASE(qemu_st2_i128, translate_st2_with_attr);
#if 0
            case setcond_i32:
            case setcond_i64:
                translate_setcond(opc, u);
                break;
            case sextract_i32:
            case sextract_i64:
                translate_sextract(opc, u);
                break;
            case shli_vec:
            case shls_vec:
                translate_binary_splat_immediate(opc, u, LLVMBuildShl);
                break;
            case shri_vec:
            case shrs_vec:
                translate_binary_splat_immediate(opc, u, LLVMBuildLShr);
                break;
            case umax_vec:
                translate_maxmin_vec(opc, u, gtu);
                break;
            case umin_vec:
                translate_maxmin_vec(opc, u, ltu);
                break;
#endif
            CASE_FUNC(set_label, translate_set_label);
            CASE_FUNC(br, translate_br);
            CASE_FUNC_WITH_RC(func_addr, translate_func_addr);
            CASE_FUNC(brcond_i32, translate_brcond);
            CASE_FUNC(brcond_i64, translate_brcond);
            case tail_call_qemuaot:
                translate_call_qemuaot(builder, F, stack, u, &prefix[0], true);
                break;
            case call_qemuaot:
                translate_call_qemuaot(builder, F, stack, u, &prefix[0], false);
                break;
            case tail_call_default:
                translate_call_default(builder, F, stack, u, &prefix[0], true);
                break;
            case call_default:
                translate_call_default(builder, F, stack, u, &prefix[0], false);
                break;
#if 0
            case discard:
                translate_discard(opc, u);
                break;
#endif
            default: assert(0);
        }
        tcg_tag_end(&tag);
    }

    //if (tcg_tag_dump_map(&tag, "tb.tcgmap") != 0)
    //    fprintf(stderr, "warning: could not write tb.tcgmap\n");

#ifdef USE_TCG_DEBUGINFO
    if (dib) {
        LLVMDIBuilderFinalize(dib);
        LLVMDisposeDIBuilder(dib);
    }
#endif
    tcg_tag_dispose(&tag);
    return rc;
}
