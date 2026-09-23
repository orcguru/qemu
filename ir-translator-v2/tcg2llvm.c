/*
 * FIXME: copyright
 */
#include <stdio.h>
#include "tcg2llvm.h"
#include "mapper.h"
#include "util.h"
#include "mapper_util.h"
#include <assert.h>

void translate_addci(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, int *cnt_ptr) {
    char name_buf[32] = {0};
    LLVMValueRef in1 = get_input_val_for_operand(&u->operands[1], stack, u->opc, *cnt_ptr);
    LLVMValueRef in2 = get_input_val_for_operand(&u->operands[2], stack, u->opc, *cnt_ptr);
    LLVMValueRef sum = LLVMBuildAdd(builder, in1, in2, assemble_name_2(&name_buf[0], sizeof(name_buf), opcode_type_str[u->opc], "sum", *cnt_ptr));
    LLVMValueRef ca = build_load_with_alignment(builder, LLVMInt1Type(), stack->carry, assemble_name_1(&name_buf[0], sizeof(name_buf), "carry", *cnt_ptr), 8);
    LLVMValueRef ca_ext = LLVMBuildZExt(builder, ca, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_1(&name_buf[0], sizeof(name_buf), "carry_ext", *cnt_ptr));
    LLVMValueRef out = LLVMBuildAdd(builder, sum, ca_ext, assemble_name_2(&name_buf[0], sizeof(name_buf), opcode_type_str[u->opc], "out", *cnt_ptr));
    do_store(&u->operands[0], out, stack, u->opc, *cnt_ptr);
    *cnt_ptr += 1;
}

#define CASE(opc, entry)                    \
        case opc:                           \
            int cnt_##opc = 0;              \
            entry(builder, stack, u, &cnt_##opc);  \
            break

void translate_batch(LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, FuncInstrList *f) {
    for (const UnifiedInstr *u = f->head; u; u = u->next) {
        switch (u->opc) {
            // FIXME: support all TCG-ops
            case addc1o_i32:
            case addc1o_i64:
            case subb1o_i32:
            case subb1o_i64:
            case divs2_i32:
            case divs2_i64:
            case divu2_i32:
            case divu2_i64:
            case dup_vec:
                int cnt0 = 0;
                assert(0);
                break;

            CASE(addci_i32, translate_addci);
            CASE(addci_i64, translate_addci);
#if 0
            case addcio_i32:
            case addcio_i64:
                translate_addcio(opc, u);
                break;
            case addco_i32:
            case addco_i64:
                translate_addco(opc, u);
                break;
            case subbi_i32:
            case subbi_i64:
                translate_subbi(opc, u);
                break;
            case subbio_i32:
            case subbio_i64:
                translate_subbio(opc, u);
                break;
            case subbo_i32:
            case subbo_i64:
                translate_subbo(opc, u);
                break;
            case abs_vec:
                translate_abs_vec(opc, u);
                break;
            case bitsel_vec:
                translate_bitsel_vec(opc, u);
                break;
            case cmpsel_vec:
                translate_cmpsel_vec(opc, u);
                break;
            case ctpop_i32:
            case ctpop_i64:
                translate_ctpop(opc, u);
                break;
            case divs_i32:
            case divs_i64:
                translate_binary(opc, u, LLVMBuildSDiv);
                break;
            case divu_i32:
            case divu_i64:
                translate_binary(opc, u, LLVMBuildUDiv);
                break;
            case rems_i32:
            case rems_i64:
                translate_binary(opc, u, LLVMBuildSRem);
                break;
            case remu_i32:
            case remu_i64:
                translate_binary(opc, u, LLVMBuildURem);
                break;
            case rotli_vec:
            case rotls_vec:
                translate_rotl_vec(opc, u);
                break;
            case rotlv_vec:
                translate_rotlv_vec(opc, u);
                break;
            case rotrv_vec:
                translate_rotrv_vec(opc, u);
                break;
            case sari_vec:
            case sars_vec:
                translate_binary_splat_immediate(opc, u, LLVMBuildAShr);
                break;
            case sarv_vec:
                translate_binary(opc, u, LLVMBuildAShr);
                break;
            case shlv_vec:
                translate_binary(opc, u, LLVMBuildShl);
                break;
            case shrv_vec:
                translate_binary(opc, u, LLVMBuildLShr);
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
            case add_i64:
                translate_binary(opc, u, LLVMBuildAdd);
                break;
            case add_i32:
            case add_vec:
                translate_binary(opc, u, LLVMBuildAdd);
                break;
            case andc_i32:
            case andc_i64:
            case andc_vec:
                translate_andc(opc, u);
                break;
            case and_i32:
            case and_i64:
            case and_vec:
                translate_binary(opc, u, LLVMBuildAnd);
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
            case cmp_vec:
                translate_cmp_vec(opc, u);
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
            case extrl_i64_i32:
            case mov_i32:
            case mov_i64:
            case mov_vec:
                translate_mov(opc, u);
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
            case mul_i32:
            case mul_i64:
            case mul_vec:
                translate_binary(opc, u, LLVMBuildMul);
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
            case or_i32:
            case or_i64:
                translate_binary(opc, u, LLVMBuildOr);
                break;
            case or_vec:
                translate_binary(opc, u, LLVMBuildOr);
                break;
            case ld8u_i32:
            case ld8u_i64:
            case ld16u_i32:
            case ld16u_i64:
            case ld32u_i64:
                translate_ld_ext(opc, u, LLVMBuildZExt);
                break;
            case ld8s_i32:
            case ld8s_i64:
            case ld16s_i32:
            case ld16s_i64:
            case ld32s_i64:
                translate_ld_ext(opc, u, LLVMBuildSExt);
                break;
            case ld_vec:
                translate_ld_vec(opc, u);
                break;
            case ld_i32:
            case ld_i64:
                translate_ld_env_xmm(opc, u);
                break;
            case qemu_ld2_i128:
                translate_qemu_ld2_i128(opc, u);
                break;
            case qemu_ld_i32:
            case qemu_ld_i64:
                translate_qemu_ld(opc, u);
                break;
            case qemu_st2_i128:
                translate_qemu_st2_i128(opc, u);
                break;
            case qemu_st_i32:
            case qemu_st_i64:
                translate_qemu_st(opc, u);
                break;
            case st8_i32:
            case st8_i64:
            case st16_i32:
            case st16_i64:
            case st32_i64:
            case st_i32:
            case st_i64:
                translate_st(opc, u);
                break;
            case st_vec:
                translate_st_vec(opc, u);
                break;
            case rotr_i32:
            case rotr_i64:
                translate_rotr(opc, u);
                break;
            case rotl_i32:
            case rotl_i64:
                translate_rotl(opc, u);
                break;
            case sar_i32:
            case sar_i64:
                translate_binary(opc, u, LLVMBuildAShr);
                break;
            case setcond_i32:
            case setcond_i64:
                translate_setcond(opc, u);
                break;
            case sextract_i32:
            case sextract_i64:
                translate_sextract(opc, u);
                break;
            case shl_i32:
            case shl_i64:
                translate_binary(opc, u, LLVMBuildShl);
                break;
            case shli_vec:
            case shls_vec:
                translate_binary_splat_immediate(opc, u, LLVMBuildShl);
                break;
            case shri_vec:
            case shrs_vec:
                translate_binary_splat_immediate(opc, u, LLVMBuildLShr);
                break;
            case shr_i32:
            case shr_i64:
                translate_binary(opc, u, LLVMBuildLShr);
                break;
            case sub_i32:
            case sub_i64:
                translate_binary(opc, u, LLVMBuildSub);
                break;
            case sub_vec:
                translate_binary(opc, u, LLVMBuildSub);
                break;
            case umax_vec:
                translate_maxmin_vec(opc, u, gtu);
                break;
            case umin_vec:
                translate_maxmin_vec(opc, u, ltu);
                break;
            case xor_i32:
            case xor_i64:
            case xor_vec:
                translate_binary(opc, u, LLVMBuildXor);
                break;
            case set_label:
                translate_set_label(opc, u);
                break;
            case brcond_i32:
            case brcond_i64:
                translate_brcond_i64(opc, u);
                break;
            case jmp_direct:
                translate_jmp_direct(opc, u);
                break;
            case discard:
                translate_discard(opc, u);
                break;
            case call:
                translate_call(opc, u);
                break;
            case br:
                translate_br(opc, u);
                break;
#endif
            default: assert(0);
        }
    }
}
