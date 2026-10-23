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
typedef LLVMValueRef (*LLVM_EXT_API)(LLVMBuilderRef B, LLVMValueRef Val, LLVMTypeRef DestTy, const char *Name);

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
        in = LLVMBuildTrunc(builder, in, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(in), "tr"));
    }
    do_store(&u->operands[0], in, stack, prefix, false);
}

void translate_addco_subbo(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    bool is_add = (u->opc == addco_i32 || u->opc == addco_i64);
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
    do_store(&u->operands[0], s1, stack, prefix, false);
    build_store_with_alignment(builder, c1, is_add ? stack->carry : stack->borrow, 8, SPILL_TAG);
}

void translate_addci_subbi(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    bool is_add = (u->opc == addci_i32 || u->opc == addci_i64);
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    LLVMValueRef in1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef in2 = get_input_val_for_operand(&u->operands[2], stack, prefix);
    LLVMValueRef sum = is_add ? LLVMBuildAdd(builder, in1, in2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "add")) : LLVMBuildSub(builder, in1, in2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "sub"));
    LLVMValueRef cin = LLVMBuildZExt(builder, build_load_with_alignment(builder, LLVMInt1Type(), is_add ? stack->carry : stack->borrow, assemble_name_2(&var_name[0], sizeof(var_name), prefix, is_add ? "ci" : "bi"), 8, SPILL_TAG), get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, is_add ? "ci_zext" : "bi_zext"));
    sum = is_add ? LLVMBuildAdd(builder, sum, cin, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "addc")) : LLVMBuildSub(builder, sum, cin, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "subb"));
    do_store(&u->operands[0], sum, stack, prefix, false);
}

void translate_addcio_subbio(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    bool is_add = (u->opc == addcio_i32 || u->opc == addcio_i64 ||
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
    LLVMValueRef ci = (u->opc == addc1o_i32 || u->opc == addc1o_i64 ||
                      u->opc == subb1o_i32 || u->opc == subb1o_i64) ?
                    LLVMConstInt(LLVMInt1Type(), 1, 0) :
                    build_load_with_alignment(builder, LLVMInt1Type(), is_add ? stack->carry : stack->borrow, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "ci"), 8, SPILL_TAG);
    LLVMValueRef ci_ext = LLVMBuildZExt(builder, ci, get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, is_add ? "ci_zext" : "bi_zext"));
    LLVMValueRef out = is_add ? LLVMBuildAdd(builder, s1, ci_ext, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "addc")) : LLVMBuildSub(builder, s1, ci_ext, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "subb"));
    do_store(&u->operands[0], out, stack, prefix, false);
    LLVMValueRef wrap = LLVMBuildICmp(builder, LLVMIntULT, is_add ? out : s1, ci_ext, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "wrap"));
    LLVMValueRef co = LLVMBuildOr(builder, c1, wrap, assemble_name_2(&var_name[0], sizeof(var_name), prefix, is_add ? "cout" : "bout"));
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
                              LLVMBuildNot(builder, sel, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "not_sel")),
                                          assemble_name_2(&var_name[0], sizeof(var_name), prefix, "and_b_not_sel")),
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
        in1 = LLVMBuildAnd(builder, in1, in2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "and_a_b"));
        if (ty <= LLVMInt64) {
            in2 = LLVMConstInt(get_llvm_type(ty), 0, 0);
        } else {
            in2 = get_const_vector(0, ty);
        }
    }
    assert(r < RELOP_MAX && llvm_predicate[r]);
    return LLVMBuildICmp(builder, llvm_predicate[r], in1, in2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "bool"));
}

static LLVMValueRef do_cmp_vec(LLVMBuilderRef builder, LLVMValueRef in1, LLVMValueRef in2, RelopType r, LLVMType ty, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef bv = do_cond(builder, in1, in2, r, ty, prefix);
    LLVMValueRef v_one = get_const_vector(-1ULL, ty);
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
    LLVMValueRef fn = get_intrinsic_declaration("llvm.ctpop", intrinsic_types, 1);
    LLVMTypeRef fn_type  = LLVMFunctionType(llvm_ty, intrinsic_types, 1, 0);
    LLVMValueRef in = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef intrinsic_call_args[] = {in};
    LLVMValueRef pop = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call_args, 1, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "pop"));
    do_store(&u->operands[0], pop, stack, prefix, false);
}

void translate_ct_intrinsic(LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, const char *intrinsic) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    LLVMTypeRef llvm_ty = get_llvm_type(tcg_ty);
    LLVMValueRef in1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef in2 = get_input_val_for_operand(&u->operands[2], stack, prefix);
    LLVMValueRef b = LLVMBuildICmp(builder, LLVMIntEQ, in1, LLVMConstInt(get_llvm_type(tcg_ty), 0, 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "icmp_eq_zero"));
    LLVMBasicBlockRef bb_ctz_is_zero = LLVMAppendBasicBlock(F, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "z"));
    LLVMBasicBlockRef bb_ctz_not_zero = LLVMAppendBasicBlock(F, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "nz"));
    LLVMBasicBlockRef bb_ctz_merge = LLVMAppendBasicBlock(F, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "merge"));
    LLVMBuildCondBr(builder, b, bb_ctz_is_zero, bb_ctz_not_zero);
    LLVMPositionBuilderAtEnd(builder, bb_ctz_is_zero);
    LLVMBuildBr(builder, bb_ctz_merge);
    // NOTICE: aarch64 requires single argument
    //LLVMTypeRef intrinsic_types[] = {llvm_ty, LLVMInt1Type()};
    LLVMTypeRef intrinsic_types[] = {llvm_ty};
    char intrinsic_func[128] = {0};
    if (tcg_ty <= LLVMInt64) {
        snprintf(intrinsic_func, sizeof(intrinsic_func), "%s.i%d", intrinsic, llvm_vector_elem_bit_counts[tcg_ty * 2 + 1]);
    } else {
        snprintf(intrinsic_func, sizeof(intrinsic_func), "%s.v%di%d", intrinsic, llvm_vector_elem_bit_counts[tcg_ty * 2], llvm_vector_elem_bit_counts[tcg_ty * 2 + 1]);
    }
    LLVMValueRef fn = create_intrinsic_declaration(intrinsic_func, llvm_ty, intrinsic_types, 1);
    LLVMTypeRef fn_type  = LLVMFunctionType(llvm_ty, intrinsic_types, 1, 0);

    LLVMPositionBuilderAtEnd(builder, bb_ctz_not_zero);
    // NOTICE: aarch64 requires single argument
    //LLVMValueRef false_val = LLVMConstInt(LLVMInt1Type(), 0, 0);
    //LLVMValueRef call_args[] = {in1, false_val};
    LLVMValueRef call_args[] = {in1};
    LLVMValueRef call_result = LLVMBuildCall2(builder, fn_type, fn, call_args, 1, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "ct_result"));
    LLVMBuildBr(builder, bb_ctz_merge);

    LLVMPositionBuilderAtEnd(builder, bb_ctz_merge);
    LLVMValueRef phi = LLVMBuildPhi(builder, llvm_ty, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "phi"));
    LLVMValueRef phi_incoming_values[] = {in2, call_result};
    LLVMBasicBlockRef phi_incoming_blocks[] = {bb_ctz_is_zero, bb_ctz_not_zero};
    LLVMAddIncoming(phi, phi_incoming_values, phi_incoming_blocks, 2);
    do_store(&u->operands[0], phi, stack, prefix, false);
}

void translate_binary_intrinsic(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, const char *intrinsic_func) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    LLVMTypeRef llvm_ty = get_llvm_type(tcg_ty);
    LLVMTypeRef intrinsic_types[] = {llvm_ty, llvm_ty};
    LLVMValueRef fn = get_intrinsic_declaration(intrinsic_func, intrinsic_types, 2);
    LLVMTypeRef fn_type  = LLVMFunctionType(llvm_ty, intrinsic_types, 2, 0);
    LLVMValueRef in1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef in2 = get_input_val_for_operand(&u->operands[2], stack, prefix);
    LLVMValueRef intrinsic_call_args[] = {in1, in2};
    LLVMValueRef out = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call_args, 2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

static LLVMValueRef do_rotate(LLVMBuilderRef builder, LLVMValueRef a, LLVMValueRef shift_l, LLVMValueRef shift_r, const char *prefix) {
    char var_name[32] = {0};
    return LLVMBuildOr(builder,
                          LLVMBuildShl(builder, a, shift_l, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "shl")),
                          LLVMBuildLShr(builder, a, shift_r, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "lshr")),
                          assemble_name_2(&var_name[0], sizeof(var_name), prefix, "or"));
}

void translate_rotate(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, bool left) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    bool is_vec = tcg_ty > LLVMInt64;
    LLVMTypeRef llvm_ty = get_llvm_type(tcg_ty);
    LLVMValueRef shift_amount = NULL;
    LLVMValueRef shift_value = NULL;
    if (!is_vec) {
        shift_amount = get_input_val_for_operand(&u->operands[2], stack, prefix);
        shift_value = shift_amount;
    } else {
        // Hack op_type for rotli/s_vec
        if (u->operands[2].kind == OP_SLOT) {
            assert(u->operands[2].slot.type == SUB_SLOT_TMP);
            int tidx = u->operands[2].slot.idx;
            assert(stack->tmp.alloca[tidx]);
            LLVMValueRef elem = build_load_with_alignment(builder, get_llvm_type(OPC_VECTOR_TO_FIXED(tcg_ty)), stack->tmp.alloca[tidx], assemble_name_2(&var_name[0], sizeof(var_name), prefix, "s"), stack->tmp.align[tidx], SPILL_TAG);
            shift_value = elem;
            shift_amount = get_const_vector(0, tcg_ty);
            int elem_cnt = llvm_vector_elem_bit_counts[tcg_ty * 2];
            for (int i = 0; i < elem_cnt; ++i) {
                shift_amount = LLVMBuildInsertElement(builder, shift_amount, elem, LLVMConstInt(get_llvm_type(LLVMInt64), i, 0), assemble_name_3(&var_name[0], sizeof(var_name), prefix, "shift", "ie"));
            }
        } else {
            assert(u->operands[2].kind == OP_IMM);
            shift_amount = get_const_vector(u->operands[2].imm.val, tcg_ty);
            shift_value = LLVMConstInt(get_llvm_type(OPC_VECTOR_TO_FIXED(tcg_ty)), u->operands[2].imm.val, 0);
        }
    }
    int bc = llvm_vector_elem_bit_counts[2 * OPC_VECTOR_TO_FIXED(tcg_ty) + 1];
    // Need to do compare against zero in order to avoid LLVM poison value
    LLVMValueRef shift_value_masked = LLVMBuildAnd(builder, shift_value, LLVMConstInt(get_llvm_type(OPC_VECTOR_TO_FIXED(tcg_ty)), (bc - 1), 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "shift_value_masked"));
    LLVMValueRef bit_count = is_vec ? get_const_vector(bc, tcg_ty) : LLVMConstInt(llvm_ty, bc, 0);
    LLVMValueRef shift_mask = is_vec ? get_const_vector((bc - 1), tcg_ty) : LLVMConstInt(llvm_ty, (bc - 1), 0);
    LLVMValueRef shift_a = LLVMBuildAnd(builder, shift_amount, shift_mask, assemble_name_2(&var_name[0], sizeof(var_name), prefix, left ? "shift_l" : "shift_r"));
    LLVMValueRef shift_b = LLVMBuildSub(builder, bit_count, shift_a, assemble_name_2(&var_name[0], sizeof(var_name), prefix, left ? "shift_r" : "shift_l"));
    LLVMValueRef out = do_rotate(builder, get_input_val_for_operand(&u->operands[1], stack, prefix), (left ? shift_a : shift_b), (left ? shift_b : shift_a), prefix);
    LLVMValueRef bv = do_cond(builder, shift_value_masked, LLVMConstInt(get_llvm_type(OPC_VECTOR_TO_FIXED(tcg_ty)), 0, 0), eq, OPC_VECTOR_TO_FIXED(tcg_ty), prefix);
    out = LLVMBuildSelect(builder, bv, get_input_val_for_operand(&u->operands[1], stack, prefix), out, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "avoid_poison"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_rotate_nocheck(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, bool left) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    bool is_vec = tcg_ty > LLVMInt64;
    LLVMTypeRef llvm_ty = get_llvm_type(tcg_ty);
    LLVMValueRef shift_amount = get_input_val_for_operand(&u->operands[2], stack, prefix);
    int bc = llvm_vector_elem_bit_counts[2 * OPC_VECTOR_TO_FIXED(tcg_ty) + 1];
    LLVMValueRef bit_count = is_vec ? get_const_vector(bc, tcg_ty) : LLVMConstInt(llvm_ty, bc, 0);
    LLVMValueRef shift_mask = is_vec ? get_const_vector((bc - 1), tcg_ty) : LLVMConstInt(llvm_ty, (bc - 1), 0);
    LLVMValueRef shift_a = LLVMBuildAnd(builder, shift_amount, shift_mask, assemble_name_2(&var_name[0], sizeof(var_name), prefix, left ? "shift_l" : "shift_r"));
    LLVMValueRef shift_b = LLVMBuildSub(builder, bit_count, shift_a, assemble_name_2(&var_name[0], sizeof(var_name), prefix, left ? "shift_r" : "shift_l"));
    LLVMValueRef out = do_rotate(builder, get_input_val_for_operand(&u->operands[1], stack, prefix), (left ? shift_a : shift_b), (left ? shift_b : shift_a), prefix);
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_shift(LLVMBuilderRef builder, LLVM_BIN_API llvm_api, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    LLVMValueRef shift_amount = NULL;
    // Hack op_type for rotli/s_vec
    if (u->operands[2].kind == OP_SLOT) {
        assert(u->operands[2].slot.type == SUB_SLOT_TMP);
        int tidx = u->operands[2].slot.idx;
        assert(stack->tmp.alloca[tidx]);
        LLVMValueRef elem = build_load_with_alignment(builder, get_llvm_type(OPC_VECTOR_TO_FIXED(tcg_ty)), stack->tmp.alloca[tidx], assemble_name_2(&var_name[0], sizeof(var_name), prefix, "s"), stack->tmp.align[tidx], SPILL_TAG);
        shift_amount = get_const_vector(0, tcg_ty);
        int elem_cnt = llvm_vector_elem_bit_counts[tcg_ty * 2];
        for (int i = 0; i < elem_cnt; ++i) {
            shift_amount = LLVMBuildInsertElement(builder, shift_amount, elem, LLVMConstInt(get_llvm_type(LLVMInt64), i, 0), assemble_name_3(&var_name[0], sizeof(var_name), prefix, "shift", "ie"));
        }
    } else {
        assert(u->operands[2].kind == OP_IMM);
        shift_amount = get_const_vector(u->operands[2].imm.val, tcg_ty);
    }
    int bc = llvm_vector_elem_bit_counts[2 * OPC_VECTOR_TO_FIXED(tcg_ty) + 1];
    LLVMValueRef shift_mask = get_const_vector((bc - 1), tcg_ty);
    shift_amount = LLVMBuildAnd(builder, shift_amount, shift_mask, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "shift"));
    LLVMValueRef out = llvm_api(builder, get_input_val_for_operand(&u->operands[1], stack, prefix), shift_amount, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_andc(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef out = LLVMBuildAnd(builder, get_input_val_for_operand(&u->operands[1], stack, prefix),
                              LLVMBuildNot(builder, get_input_val_for_operand(&u->operands[2], stack, prefix),
                                           assemble_name_2(&var_name[0], sizeof(var_name), prefix, "not")),
                              assemble_name_2(&var_name[0], sizeof(var_name), prefix, "and_a_not_b"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_nor(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef out = LLVMBuildNot(builder,
                                    LLVMBuildOr(builder, get_input_val_for_operand(&u->operands[1], stack, prefix),
                                                get_input_val_for_operand(&u->operands[2], stack, prefix),
                                                assemble_name_2(&var_name[0], sizeof(var_name), prefix, "or")),
                                    assemble_name_2(&var_name[0], sizeof(var_name), prefix, "not_or_a_b"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_orc(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef out = LLVMBuildOr(builder, get_input_val_for_operand(&u->operands[1], stack, prefix),
                              LLVMBuildNot(builder, get_input_val_for_operand(&u->operands[2], stack, prefix),
                                           assemble_name_2(&var_name[0], sizeof(var_name), prefix, "not")),
                              assemble_name_2(&var_name[0], sizeof(var_name), prefix, "or_a_not_b"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_nand(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef out = LLVMBuildNot(builder,
                                    LLVMBuildAnd(builder, get_input_val_for_operand(&u->operands[1], stack, prefix),
                                                get_input_val_for_operand(&u->operands[2], stack, prefix),
                                                assemble_name_2(&var_name[0], sizeof(var_name), prefix, "and")),
                                    assemble_name_2(&var_name[0], sizeof(var_name), prefix, "not_and_a_b"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_eqv(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef out = LLVMBuildNot(builder,
                                    LLVMBuildXor(builder, get_input_val_for_operand(&u->operands[1], stack, prefix),
                                                get_input_val_for_operand(&u->operands[2], stack, prefix),
                                                assemble_name_2(&var_name[0], sizeof(var_name), prefix, "xor")),
                                    assemble_name_2(&var_name[0], sizeof(var_name), prefix, "not_xor_a_b"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_neg(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    bool is_vec = tcg_ty > LLVMInt64;
    LLVMValueRef out = LLVMBuildSub(builder, (is_vec ? get_const_vector(0, tcg_ty) : LLVMConstInt(get_llvm_type(tcg_ty), 0, 0)),
                                    get_input_val_for_operand(&u->operands[1], stack, prefix),
                                    assemble_name_2(&var_name[0], sizeof(var_name), prefix, "sub_zero_a"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_not(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef out = LLVMBuildNot(builder, get_input_val_for_operand(&u->operands[1], stack, prefix),
                                    assemble_name_2(&var_name[0], sizeof(var_name), prefix, "not"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_bswap(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, LLVMType effective_ty) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    int total_bit_cnt = llvm_vector_elem_bit_counts[tcg_ty * 2 + 1];
    int effective_bit_cnt = llvm_vector_elem_bit_counts[effective_ty * 2 + 1];
    SwapAttrType swap_flag = 0;
    for (int i = 2; i < u->operand_count; ++i) {
        if (u->operands[i].kind == OP_ATTR && u->operands[i].attr_info.subt == SUB_ATTR_SWAP) {
            swap_flag |= u->operands[i].attr_info.p.swap;
        }
    }
    LLVMValueRef in = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef effective_in = NULL;
    LLVMValueRef in_bc = NULL;
    if (total_bit_cnt != effective_bit_cnt) {
        assert(total_bit_cnt % effective_bit_cnt == 0);
        in_bc = LLVMBuildBitCast(builder, in, LLVMVectorType(get_llvm_type(effective_ty), (total_bit_cnt / effective_bit_cnt)), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(in), "bc"));
        effective_in = LLVMBuildExtractElement(builder, in_bc, LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(in_bc), "ee"));
    } else {
        effective_in = in;
    }
    effective_in = LLVMBuildBitCast(builder, effective_in, LLVMVectorType(get_llvm_type(LLVMInt8), (effective_bit_cnt / 8)), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(effective_in), "swap_vec"));
    LLVMValueRef constants[16];
    int elem_cnt = (effective_bit_cnt / 8);
    for (int i = 0; i < elem_cnt; i++) {
        constants[i] = LLVMConstInt(get_llvm_type(LLVMInt8), 0, 0);
    }
    LLVMValueRef swap_out = LLVMConstVector(constants, elem_cnt);
    for (int i = 0; i < effective_bit_cnt / 8; ++i) {
        LLVMValueRef elem = LLVMBuildExtractElement(builder, effective_in, LLVMConstInt(get_llvm_type(LLVMInt64), i, 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(effective_in), "ee"));
        swap_out = LLVMBuildInsertElement(builder, swap_out, elem, LLVMConstInt(get_llvm_type(LLVMInt64), ((effective_bit_cnt / 8) - 1 - i), 0), assemble_name_3(&var_name[0], sizeof(var_name), prefix, "swap_out", "ie"));
    }
    swap_out = LLVMBuildBitCast(builder, swap_out, get_llvm_type(effective_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "swap_out"));
    if (tcg_ty == effective_ty) {
        do_store(&u->operands[0], swap_out, stack, prefix, false);
        return;
    }
    LLVMValueRef out = NULL;
    if (swap_flag == 0 || (((swap_flag & OZ) && (swap_flag & IZ)) ||
                          !((swap_flag & OS) || (swap_flag & OZ)))) {
        out = LLVMBuildInsertElement(builder, in_bc, swap_out, LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
    } else {
        if (swap_flag & OS) {
            out = LLVMBuildSExt(builder, swap_out, get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
        } else if (swap_flag & OZ) {
            out = LLVMBuildZExt(builder, swap_out, get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
        }
    }
    do_store(&u->operands[0], out, stack, prefix, false);
    return;
}

static LLVMValueRef do_deposit(LLVMBuilderRef builder, LLVMValueRef in1, LLVMValueRef in2, int pos, int len, LLVMType tcg_ty, const char *prefix) {
    char var_name[32] = {0};
    in1 = LLVMBuildAnd(builder, in1, LLVMBuildNot(builder, LLVMBuildShl(builder, LLVMConstInt(get_llvm_type(tcg_ty), ((1ULL << len) - 1), 0), LLVMConstInt(get_llvm_type(tcg_ty), pos, 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "bits")), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "mask")), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "t1"));
    in2 = LLVMBuildShl(builder, LLVMBuildZExt(builder, LLVMBuildTrunc(builder, in2, LLVMIntType(len), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "tr")), get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "zext")), LLVMConstInt(get_llvm_type(tcg_ty), pos, 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "t2"));
    return LLVMBuildOr(builder, in1, in2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
}

void translate_deposit(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    int total_bit_cnt = llvm_vector_elem_bit_counts[tcg_ty * 2 + 1];
    LLVMValueRef in1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef in2 = get_input_val_for_operand(&u->operands[2], stack, prefix);
    assert(u->operands[3].kind == OP_IMM);
    int pos = (u->operands[3].imm.val & (total_bit_cnt - 1));
    assert(u->operands[4].kind == OP_IMM);
    int len = (u->operands[4].imm.val & (total_bit_cnt - 1));
    if (len == 0) {
        do_store(&u->operands[0], in1, stack, prefix, false);
        return;
    }
    LLVMValueRef out = do_deposit(builder, in1, in2, pos, len, tcg_ty, prefix);
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_dup_vec(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    LLVMValueRef elem = NULL;
    if (u->operands[1].kind == OP_SLOT) {
        LLVMType elem_ty = OPC_VECTOR_TO_FIXED(tcg_ty);
        if (u->operands[1].slot.type == SUB_SLOT_XREG) {
            elem = build_load_with_alignment(builder, get_llvm_type(elem_ty), stack->xreg.alloca[u->operands[1].slot.idx], assemble_name_2(&var_name[0], sizeof(var_name), prefix, "ld_element"), stack->xreg.align[u->operands[1].slot.idx], SPILL_TAG);
        } else if (u->operands[1].slot.type == SUB_SLOT_TMP) {
            elem = build_load_with_alignment(builder, get_llvm_type(elem_ty), stack->tmp.alloca[u->operands[1].slot.idx], assemble_name_2(&var_name[0], sizeof(var_name), prefix, "ld_element"), stack->tmp.align[u->operands[1].slot.idx], SPILL_TAG);
        } else {
            assert(0);
        }
    } else {
        elem = LLVMBuildExtractElement(builder, get_input_val_for_operand(&u->operands[1], stack, prefix), LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "elem"));
    }
    uint8_t elem_cnt = llvm_vector_elem_bit_counts[tcg_ty * 2];
    LLVMValueRef out = get_const_vector(0, tcg_ty);
    for (int i = 0; i < elem_cnt; i++) {
        out = LLVMBuildInsertElement(builder, out, elem, LLVMConstInt(get_llvm_type(LLVMInt64), i, 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "ie"));
    }
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_extract2(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    int total_bit_cnt = llvm_vector_elem_bit_counts[tcg_ty * 2 + 1];
    LLVMValueRef in1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef in2 = get_input_val_for_operand(&u->operands[2], stack, prefix);
    assert(u->operands[3].kind == OP_IMM);
    int pos = (u->operands[3].imm.val & (total_bit_cnt - 1));
    in1 = LLVMBuildLShr(builder, in1, LLVMConstInt(get_llvm_type(tcg_ty), pos, 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "lshr"));
    LLVMValueRef out = do_deposit(builder, in1, in2, (total_bit_cnt - pos), pos, tcg_ty, prefix);
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_extract(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, bool sext) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    int total_bit_cnt = llvm_vector_elem_bit_counts[tcg_ty * 2 + 1];
    LLVMValueRef in1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    assert(u->operands[2].kind == OP_IMM);
    int pos = (u->operands[2].imm.val & (total_bit_cnt - 1));
    assert(u->operands[3].kind == OP_IMM);
    int len = (u->operands[3].imm.val & (total_bit_cnt - 1));
    if (len == 0) {
        do_store(&u->operands[0], in1, stack, prefix, false);
        return;
    }
    LLVMValueRef shifted = LLVMBuildShl(builder, in1, LLVMConstInt(get_llvm_type(tcg_ty), (total_bit_cnt - pos - len), 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "shl"));
    LLVMValueRef out = NULL;
    if (sext) {
        out = LLVMBuildAShr(builder, shifted, LLVMConstInt(get_llvm_type(tcg_ty), (total_bit_cnt - len), 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
    } else {
        out = LLVMBuildLShr(builder, shifted, LLVMConstInt(get_llvm_type(tcg_ty), (total_bit_cnt - len), 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
    }
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_extrh(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMType tcg_in_ty = get_operand_type(&u->operands[1]);
    LLVMType tcg_out_ty = get_operand_type(&u->operands[0]);
    LLVMValueRef out = LLVMBuildTrunc(builder, LLVMBuildLShr(builder, get_input_val_for_operand(&u->operands[1], stack, prefix), LLVMConstInt(get_llvm_type(tcg_in_ty), (llvm_vector_elem_bit_counts[tcg_in_ty * 2 + 1] - llvm_vector_elem_bit_counts[tcg_out_ty * 2 + 1]), 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "lshr")), get_llvm_type(tcg_out_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_sext(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    do_store(&u->operands[0], LLVMBuildSExt(builder, get_input_val_for_operand(&u->operands[1], stack, prefix), get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "sext")), stack, prefix, false);
}

void translate_zext(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    do_store(&u->operands[0], LLVMBuildZExt(builder, get_input_val_for_operand(&u->operands[1], stack, prefix), get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "sext")), stack, prefix, false);
}

void translate_movcond(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    assert(u->operands[5].kind == OP_RELOP);
    LLVMValueRef bv = do_cond(builder, get_input_val_for_operand(&u->operands[1], stack, prefix),
                              get_input_val_for_operand(&u->operands[2], stack, prefix),
                              u->operands[5].relop, tcg_ty, prefix);
    LLVMValueRef out = LLVMBuildSelect(builder, bv, get_input_val_for_operand(&u->operands[3], stack, prefix), get_input_val_for_operand(&u->operands[4], stack, prefix), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

static LLVMValueRef do_mulxh(LLVMBuilderRef builder, LLVMValueRef in1, LLVMValueRef in2, LLVMType tcg_ty, const char *prefix, LLVM_EXT_API llvm_api) {
    char var_name[32] = {0};
    int total_bit_cnt = llvm_vector_elem_bit_counts[tcg_ty * 2 + 1];
    LLVMTypeRef llvm_double_ty = (tcg_ty == LLVMInt64) ? LLVMInt128Type() : LLVMInt64Type();
    in1 = llvm_api(builder, in1, llvm_double_ty, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "double_ty"));
    in2 = llvm_api(builder, in2, llvm_double_ty, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "double_ty"));
    LLVMValueRef out = LLVMBuildMul(builder, in1, in2, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "mul"));
    out = LLVMBuildLShr(builder, out, LLVMConstInt(llvm_double_ty, total_bit_cnt, 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "lshr"));
    return LLVMBuildTrunc(builder, out, get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "tr"));
}

void translate_mulxh(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, LLVM_EXT_API llvm_api) {
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    LLVMValueRef out = do_mulxh(builder, get_input_val_for_operand(&u->operands[1], stack, prefix), get_input_val_for_operand(&u->operands[2], stack, prefix), tcg_ty, prefix, llvm_api);
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_mulx2(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, LLVM_EXT_API llvm_api) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    LLVMValueRef high = do_mulxh(builder, get_input_val_for_operand(&u->operands[2], stack, prefix), get_input_val_for_operand(&u->operands[3], stack, prefix), tcg_ty, prefix, llvm_api);
    do_store(&u->operands[1], high, stack, prefix, false);
    LLVMValueRef low = LLVMBuildMul(builder, get_input_val_for_operand(&u->operands[2], stack, prefix), get_input_val_for_operand(&u->operands[3], stack, prefix), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "mul_low"));
    do_store(&u->operands[0], low, stack, prefix, false);
}

void translate_setcond(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, LLVM_EXT_API llvm_api) {
    char var_name[32] = {0};
    assert(u->operands[3].kind == OP_RELOP);
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    LLVMValueRef bv = do_cond(builder, get_input_val_for_operand(&u->operands[1], stack, prefix),
                              get_input_val_for_operand(&u->operands[2], stack, prefix),
                              u->operands[3].relop, tcg_ty, prefix);
    LLVMValueRef out = llvm_api(builder, bv, get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix, false);
}

void translate_div2(LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, const UnifiedInstr *u, const char *prefix, LLVM_EXT_API ext_api, LLVM_BIN_API div_api, LLVM_BIN_API rem_api) {
    char var_name[32] = {0};
    LLVMType tcg_ty = get_operand_type(&u->operands[0]);
    int total_bit_cnt = llvm_vector_elem_bit_counts[tcg_ty * 2 + 1];
    LLVMTypeRef llvm_double_ty = (tcg_ty == LLVMInt64) ? LLVMInt128Type() : LLVMInt64Type();

    LLVMValueRef nl = get_input_val_for_operand(&u->operands[2], stack, prefix);
    LLVMValueRef nh = get_input_val_for_operand(&u->operands[3], stack, prefix);
    LLVMValueRef d = get_input_val_for_operand(&u->operands[4], stack, prefix);

    LLVMBasicBlockRef bb_chk  = LLVMAppendBasicBlock(F, "divs2.chk");
    LLVMBasicBlockRef bb_do   = LLVMAppendBasicBlock(F, "divs2.do");
    LLVMBasicBlockRef bb_trap = LLVMAppendBasicBlock(F, "divs2.trap");
    LLVMBasicBlockRef bb_done = LLVMAppendBasicBlock(F, "divs2.done");

    /* ---- guard 1: divide by zero ---- */
    LLVMValueRef is0 = LLVMBuildICmp(builder, LLVMIntEQ, d,
                                     LLVMConstInt(get_llvm_type(tcg_ty), 0, 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "d_is0"));
    LLVMBuildCondBr(builder, is0, bb_trap, bb_chk);

    LLVMPositionBuilderAtEnd(builder, bb_chk);
    LLVMValueRef hi  = LLVMBuildShl(builder, LLVMBuildSExt(builder, nh, llvm_double_ty, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "nh_double")),
                                    LLVMConstInt(llvm_double_ty, total_bit_cnt, 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "num_hi"));
    LLVMValueRef num = LLVMBuildOr(builder, hi, LLVMBuildZExt(builder, nl, llvm_double_ty, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "nl_double")),
                                   assemble_name_2(&var_name[0], sizeof(var_name), prefix, "num"));

    /* ---- guard 2: INT128_MIN / -1  (poison in LLVM, #DE on x86) ---- */
    LLVMValueRef min128 = LLVMBuildShl(builder, LLVMConstInt(llvm_double_ty, 1, 0),
                                       LLVMConstInt(llvm_double_ty, (2 * total_bit_cnt - 1), 0), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "int_min"));
    LLVMValueRef ismin = LLVMBuildICmp(builder, LLVMIntEQ, num, min128, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "num_ismin"));
    LLVMValueRef ism1  = LLVMBuildICmp(builder, LLVMIntEQ, d,
                                       LLVMConstInt(get_llvm_type(tcg_ty), (unsigned long long)-1LL, 1),
                                       assemble_name_2(&var_name[0], sizeof(var_name), prefix, "d_ism1"));
    LLVMBuildCondBr(builder, LLVMBuildAnd(builder, ismin, ism1, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "i128_ovf")), bb_trap, bb_do);

    /* ---- the divide ---- */
    LLVMPositionBuilderAtEnd(builder, bb_do);
    LLVMValueRef den = ext_api(builder, d, llvm_double_ty, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "d_128"));
    LLVMValueRef q128 = div_api(builder, num, den, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "q_128"));
    LLVMValueRef r128 = rem_api(builder, num, den, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "r_128"));
    LLVMValueRef q64  = LLVMBuildTrunc(builder, q128, get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "q"));
    LLVMValueRef r64  = LLVMBuildTrunc(builder, r128, get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "r"));

    /* ---- guard 3: quotient must fit in i64 ---- */
    LLVMValueRef fits = LLVMBuildICmp(builder, LLVMIntEQ,
                                      ext_api(builder, q64, llvm_double_ty, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "q_back")),
                                      q128, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "q_fits"));
    LLVMBuildCondBr(builder, fits, bb_done, bb_trap);

    /* ---- noreturn trap: makes bb_done single-predecessor, so no phi ---- */
    LLVMPositionBuilderAtEnd(builder, bb_trap);
    LLVMBuildBr(builder, bb_done);

    LLVMPositionBuilderAtEnd(builder, bb_done);

    LLVMValueRef phi_q = LLVMBuildPhi(builder, get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "phi_q"));
    LLVMValueRef phi_r = LLVMBuildPhi(builder, get_llvm_type(tcg_ty), assemble_name_2(&var_name[0], sizeof(var_name), prefix, "phi_r"));
    LLVMBasicBlockRef phi_incoming_blocks[] = {bb_do, bb_trap};
    LLVMValueRef phi_q_incoming_values[] = {q64, LLVMConstInt(get_llvm_type(tcg_ty), 0, 0)};
    LLVMValueRef phi_r_incoming_values[] = {r64, LLVMConstInt(get_llvm_type(tcg_ty), 0, 0)};
    LLVMAddIncoming(phi_q, phi_q_incoming_values, phi_incoming_blocks, 2);
    LLVMAddIncoming(phi_r, phi_r_incoming_values, phi_incoming_blocks, 2);
    do_store(&u->operands[0], phi_q, stack, prefix, false);
    do_store(&u->operands[1], phi_r, stack, prefix, false);
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
        val = LLVMBuildTrunc(builder, val, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "tr"));
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
        val = LLVMBuildTrunc(builder, val, get_llvm_type(get_operand_type(&u->operands[1])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "tr"));
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

void translate_discard(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    if (u->operands[0].kind == OP_SLOT) {
        if (u->operands[0].slot.type == SUB_SLOT_XREG) {
            build_store_with_alignment(builder, LLVMGetPoison(stack->xreg.llvm_ty[u->operands[0].slot.idx]), stack->xreg.alloca[u->operands[0].slot.idx], stack->xreg.align[u->operands[0].slot.idx], SPILL_TAG);
        } else if (u->operands[0].slot.type == SUB_SLOT_TMP) {
            build_store_with_alignment(builder, LLVMGetPoison(stack->tmp.llvm_ty[u->operands[0].slot.idx]), stack->tmp.alloca[u->operands[0].slot.idx], stack->tmp.align[u->operands[0].slot.idx], SPILL_TAG);
        }
    }
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

#define CASE_BOOL(opc, entry, b)                    \
        case opc:                                   \
            entry(builder, stack, u, &prefix[0], b);\
            break

#define CASE_BSWAP(opc, ty)                                     \
        case opc:                                               \
            translate_bswap(builder, stack, u, &prefix[0], ty); \
            break

#define CASE_EXTRACT(opc, sext)                                     \
        case opc:                                                   \
            translate_extract(builder, stack, u, &prefix[0], sext); \
            break

#define CASE_MULXH(opc, llvm_api)                                       \
        case opc:                                                       \
            translate_mulxh(builder, stack, u, &prefix[0], llvm_api);   \
            break

#define CASE_MULX2(opc, llvm_api)                                       \
        case opc:                                                       \
            translate_mulx2(builder, stack, u, &prefix[0], llvm_api);   \
            break

#define CASE_SETCOND(opc, llvm_api)                                     \
        case opc:                                                       \
            translate_setcond(builder, stack, u, &prefix[0], llvm_api); \
            break

#define CASE_DIV2(opc, ext_api, div_api, rem_api)                       \
        case opc:                                                       \
            translate_div2(builder, F, stack, u, &prefix[0], ext_api, div_api, rem_api);    \
            break

#define CASE_COMMON(opc, llvm_api)                                      \
        case opc:                                                       \
            translate_common(builder, llvm_api, stack, u, &prefix[0]);  \
            break

#define CASE_SHIFT(opc, llvm_api)                                       \
        case opc:                                                       \
            translate_shift(builder, llvm_api, stack, u, &prefix[0]);   \
            break

#define CASE_FUNC(opc, entry)                       \
        case opc:                                   \
            entry(builder, F, stack, u, &prefix[0]);\
            break

#define CASE_FUNC_WITH_RC(opc, entry)               \
        case opc:                                   \
            rc = entry(builder, F, stack, u, &prefix[0]);\
            break

#define CASE_CT_INTRINSIC(opc, intrinsic)           \
        case opc:                                   \
            translate_ct_intrinsic(builder, F, stack, u, &prefix[0], intrinsic);   \
            break

#define CASE_BINARY_INTRINSIC(opc, intrinsic)        \
        case opc:                                   \
            translate_binary_intrinsic(builder, stack, u, &prefix[0], intrinsic);   \
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
            CASE(addco_i32, translate_addco_subbo);
            CASE(addco_i64, translate_addco_subbo);
            CASE(addci_i32, translate_addci_subbi);
            CASE(addci_i64, translate_addci_subbi);
            CASE(addcio_i32, translate_addcio_subbio);
            CASE(addcio_i64, translate_addcio_subbio);
            CASE(subbo_i32, translate_addco_subbo);
            CASE(subbo_i64, translate_addco_subbo);
            CASE(subbi_i32, translate_addci_subbi);
            CASE(subbi_i64, translate_addci_subbi);
            CASE(subbio_i32, translate_addcio_subbio);
            CASE(subbio_i64, translate_addcio_subbio);
            CASE(addc1o_i32, translate_addcio_subbio);
            CASE(addc1o_i64, translate_addcio_subbio);
            CASE(subb1o_i32, translate_addcio_subbio);
            CASE(subb1o_i64, translate_addcio_subbio);
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
            CASE_CT_INTRINSIC(clz_i32, "llvm.ctlz.i32");
            CASE_CT_INTRINSIC(clz_i64, "llvm.ctlz.i64");
            CASE_CT_INTRINSIC(ctz_i32, "llvm.cttz.i32");
            CASE_CT_INTRINSIC(ctz_i64, "llvm.cttz.i64");
            CASE_BINARY_INTRINSIC(smax_vec, "llvm.smax");
            CASE_BINARY_INTRINSIC(smin_vec, "llvm.smin");
            CASE_BINARY_INTRINSIC(umax_vec, "llvm.umax");
            CASE_BINARY_INTRINSIC(umin_vec, "llvm.umin");
            CASE_BINARY_INTRINSIC(ssadd_vec, "llvm.sadd.sat");
            CASE_BINARY_INTRINSIC(sssub_vec, "llvm.ssub.sat");
            CASE_BINARY_INTRINSIC(usadd_vec, "llvm.uadd.sat");
            CASE_BINARY_INTRINSIC(ussub_vec, "llvm.usub.sat");
            CASE_BOOL(rotl_i32, translate_rotate, true);
            CASE_BOOL(rotl_i64, translate_rotate, true);
            CASE_BOOL(rotli_vec, translate_rotate, true);
            CASE_BOOL(rotls_vec, translate_rotate, true);
            CASE_BOOL(rotlv_vec, translate_rotate_nocheck, true);
            CASE_BOOL(rotr_i32, translate_rotate, false);
            CASE_BOOL(rotr_i64, translate_rotate, false);
            CASE_BOOL(rotrv_vec, translate_rotate_nocheck, false);
            CASE_SHIFT(shli_vec, LLVMBuildShl);
            CASE_SHIFT(shls_vec, LLVMBuildShl);
            CASE_SHIFT(shri_vec, LLVMBuildLShr);
            CASE_SHIFT(shrs_vec, LLVMBuildLShr);
            CASE_SHIFT(sari_vec, LLVMBuildAShr);
            CASE_SHIFT(sars_vec, LLVMBuildAShr);
            CASE(andc_i32, translate_andc);
            CASE(andc_i64, translate_andc);
            CASE(andc_vec, translate_andc);
            CASE(nor_i32, translate_nor);
            CASE(nor_i64, translate_nor);
            CASE(nor_vec, translate_nor);
            CASE(orc_i32, translate_orc);
            CASE(orc_i64, translate_orc);
            CASE(orc_vec, translate_orc);
            CASE(nand_i32, translate_nand);
            CASE(nand_i64, translate_nand);
            CASE(nand_vec, translate_nand);
            CASE(eqv_i32, translate_eqv);
            CASE(eqv_i64, translate_eqv);
            CASE(eqv_vec, translate_eqv);
            CASE(neg_i32, translate_neg);
            CASE(neg_i64, translate_neg);
            CASE(neg_vec, translate_neg);
            CASE(not_i32, translate_not);
            CASE(not_i64, translate_not);
            CASE(not_vec, translate_not);
            CASE_BSWAP(bswap16_i32, LLVMInt16);
            CASE_BSWAP(bswap16_i64, LLVMInt16);
            CASE_BSWAP(bswap32_i32, LLVMInt32);
            CASE_BSWAP(bswap32_i64, LLVMInt32);
            CASE_BSWAP(bswap64_i64, LLVMInt64);
            CASE(deposit_i32, translate_deposit);
            CASE(deposit_i64, translate_deposit);
            CASE(dupm_vec, translate_dup_vec);
            CASE(dup_vec, translate_dup_vec);
            CASE(extract2_i32, translate_extract2);
            CASE(extract2_i64, translate_extract2);
            CASE_EXTRACT(extract_i32, false);
            CASE_EXTRACT(extract_i64, false);
            CASE_EXTRACT(sextract_i32, true);
            CASE_EXTRACT(sextract_i64, true);
            CASE(extrh_i64_i32, translate_extrh);
            CASE(ext_i32_i64, translate_sext);
            CASE(extu_i32_i64, translate_zext);
            CASE(movcond_i32, translate_movcond);
            CASE(movcond_i64, translate_movcond);
            CASE(movcond_vec, translate_movcond);
            CASE_MULXH(mulsh_i32, LLVMBuildSExt);
            CASE_MULXH(mulsh_i64, LLVMBuildSExt);
            CASE_MULXH(muluh_i32, LLVMBuildZExt);
            CASE_MULXH(muluh_i64, LLVMBuildZExt);
            CASE_MULX2(muls2_i32, LLVMBuildSExt);
            CASE_MULX2(muls2_i64, LLVMBuildSExt);
            CASE_MULX2(mulu2_i32, LLVMBuildZExt);
            CASE_MULX2(mulu2_i64, LLVMBuildZExt);
            CASE_SETCOND(setcond_i32, LLVMBuildZExt);
            CASE_SETCOND(setcond_i64, LLVMBuildZExt);
            CASE_SETCOND(negsetcond_i32, LLVMBuildSExt);
            CASE_SETCOND(negsetcond_i64, LLVMBuildSExt);
            CASE_DIV2(divs2_i32, LLVMBuildSExt, LLVMBuildSDiv, LLVMBuildSRem);
            CASE_DIV2(divs2_i64, LLVMBuildSExt, LLVMBuildSDiv, LLVMBuildSRem);
            CASE_DIV2(divu2_i32, LLVMBuildZExt, LLVMBuildUDiv, LLVMBuildURem);
            CASE_DIV2(divu2_i64, LLVMBuildZExt, LLVMBuildUDiv, LLVMBuildURem);
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
            CASE(discard, translate_discard);
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
