#ifndef TCG_AST_H
#define TCG_AST_H

#include <stddef.h>
#include <llvm-c/Types.h>

#define MAX_ADDED_ARGS              6
#define LLVMMAXType                 LLVMInt128
#define AOT_LEVEL_0                 0
#define AOT_LEVEL_MAX               3
#define AOT_LEVEL                   AOT_LEVEL_0
#define XMM_COUNT                   0

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long uint64_t;

typedef signed char int8_t;
typedef signed short int16_t;
typedef signed int int32_t;
typedef signed long int64_t;

typedef enum {
    OP_FUNC,
    OP_INST,
    OP_OPC,
    OP_SLOT,
    OP_IMM,
    OP_REL,
    OP_ATTR,
} TcgOpType;

#if AOT_LEVEL == AOT_LEVEL_MAX
#define ENVVAR_TYPE_LIST \
    X(cc_src2) \
    X(es_base) \
    X(cs_base) \
    X(ss_base) \
    X(ds_base) \
    X(fs_base) \
    X(gs_base) \
    X(ENVVarMAX)
#elif AOT_LEVEL == AOT_LEVEL_0
#define ENVVAR_TYPE_LIST \
    X(cc_src) \
    X(cc_dst) \
    X(cc_op) \
    X(cc_src2) \
    X(es_base) \
    X(cs_base) \
    X(ss_base) \
    X(ds_base) \
    X(fs_base) \
    X(gs_base) \
    X(ENVVarMAX)
#endif

typedef enum {
    #define X(name) name,
    ENVVAR_TYPE_LIST
    #undef X
} EnvVarType;

#if AOT_LEVEL == AOT_LEVEL_MAX
#define XREG_TYPE_LIST \
    X(rax) \
    X(rcx) \
    X(rdx) \
    X(rbx) \
    X(rsp) \
    X(rbp) \
    X(rsi) \
    X(rdi) \
    X(r8) \
    X(r9) \
    X(r10) \
    X(r11) \
    X(r12) \
    X(r13) \
    X(r14) \
    X(r15) \
    X(cc_src) \
    X(cc_dst) \
    X(cc_op) \
    X(rip) \
    X(XREG_MAX)
#elif AOT_LEVEL == AOT_LEVEL_0
#define XREG_TYPE_LIST \
    X(rax) \
    X(rcx) \
    X(rdx) \
    X(rbx) \
    X(rsp) \
    X(rbp) \
    X(rsi) \
    X(rdi) \
    X(r8) \
    X(r9) \
    X(r10) \
    X(r11) \
    X(r12) \
    X(r13) \
    X(r14) \
    X(r15) \
    X(rip) \
    X(XREG_MAX)
#endif

typedef enum {
    #define X(name) name,
    XREG_TYPE_LIST
    #undef X
} XRegType;

#define ENV_OFFSET_rax  0x0
#define ENV_OFFSET_rcx  0x8
#define ENV_OFFSET_rdx  0x10
#define ENV_OFFSET_rbx  0x18
#define ENV_OFFSET_rsp  0x20
#define ENV_OFFSET_rbp  0x28
#define ENV_OFFSET_rsi  0x30
#define ENV_OFFSET_rdi  0x38
#define ENV_OFFSET_r8   0x40
#define ENV_OFFSET_r9   0x48
#define ENV_OFFSET_r10  0x50
#define ENV_OFFSET_r11  0x58
#define ENV_OFFSET_r12  0x60
#define ENV_OFFSET_r13  0x68
#define ENV_OFFSET_r14  0x70
#define ENV_OFFSET_r15  0x78
#define ENV_OFFSET_cc_src   0x98
#define ENV_OFFSET_cc_dst   0x90
#define ENV_OFFSET_cc_op    0xa8
#define ENV_OFFSET_rip  0x80
#define ENV_OFFSET_cc_src2  160
#define ENV_OFFSET_es_base  192
#define ENV_OFFSET_cs_base  216
#define ENV_OFFSET_ss_base  240
#define ENV_OFFSET_ds_base  264
#define ENV_OFFSET_fs_base  288
#define ENV_OFFSET_gs_base  312

#define RELOP_TYPE_LIST \
    X(eq) \
    X(ne) \
    X(ge) \
    X(gt) \
    X(le) \
    X(lt) \
    X(geu) \
    X(gtu) \
    X(leu) \
    X(ltu) \
    X(tsteq) \
    X(tstne) \
    X(RELOPMAX)

typedef enum {
    #define X(name) name,
    RELOP_TYPE_LIST
    #undef X
} RelopType;

#define HELPER_LIST \
    X(not_a_helper) /* Used to collect arguments for the fast path tailcall */ \
    X(helper_aaa) \
    X(helper_aad) \
    X(helper_aam) \
    X(helper_aas) \
    X(helper_addsd) \
    X(helper_addss) \
    X(helper_atomic_add_fetchb) \
    X(helper_atomic_add_fetchl_be) \
    X(helper_atomic_add_fetchl_le) \
    X(helper_atomic_add_fetchq_be) \
    X(helper_atomic_add_fetchq_le) \
    X(helper_atomic_add_fetchw_be) \
    X(helper_atomic_add_fetchw_le) \
    X(helper_atomic_and_fetchb) \
    X(helper_atomic_and_fetchl_be) \
    X(helper_atomic_and_fetchl_le) \
    X(helper_atomic_and_fetchq_be) \
    X(helper_atomic_and_fetchq_le) \
    X(helper_atomic_and_fetchw_be) \
    X(helper_atomic_and_fetchw_le) \
    X(helper_atomic_cmpxchgb) \
    X(helper_atomic_cmpxchgl_be) \
    X(helper_atomic_cmpxchgl_le) \
    X(helper_atomic_cmpxchgo_be) \
    X(helper_atomic_cmpxchgo_le) \
    X(helper_atomic_cmpxchgq_be) \
    X(helper_atomic_cmpxchgq_le) \
    X(helper_atomic_cmpxchgw_be) \
    X(helper_atomic_cmpxchgw_le) \
    X(helper_atomic_fetch_addb) \
    X(helper_atomic_fetch_addl_be) \
    X(helper_atomic_fetch_addl_le) \
    X(helper_atomic_fetch_addq_be) \
    X(helper_atomic_fetch_addq_le) \
    X(helper_atomic_fetch_addw_be) \
    X(helper_atomic_fetch_addw_le) \
    X(helper_atomic_fetch_andb) \
    X(helper_atomic_fetch_andl_be) \
    X(helper_atomic_fetch_andl_le) \
    X(helper_atomic_fetch_andq_be) \
    X(helper_atomic_fetch_andq_le) \
    X(helper_atomic_fetch_andw_be) \
    X(helper_atomic_fetch_andw_le) \
    X(helper_atomic_fetch_orb) \
    X(helper_atomic_fetch_orl_be) \
    X(helper_atomic_fetch_orl_le) \
    X(helper_atomic_fetch_orq_be) \
    X(helper_atomic_fetch_orq_le) \
    X(helper_atomic_fetch_orw_be) \
    X(helper_atomic_fetch_orw_le) \
    X(helper_atomic_fetch_smaxb) \
    X(helper_atomic_fetch_smaxl_be) \
    X(helper_atomic_fetch_smaxl_le) \
    X(helper_atomic_fetch_smaxq_be) \
    X(helper_atomic_fetch_smaxq_le) \
    X(helper_atomic_fetch_smaxw_be) \
    X(helper_atomic_fetch_smaxw_le) \
    X(helper_atomic_fetch_sminb) \
    X(helper_atomic_fetch_sminl_be) \
    X(helper_atomic_fetch_sminl_le) \
    X(helper_atomic_fetch_sminq_be) \
    X(helper_atomic_fetch_sminq_le) \
    X(helper_atomic_fetch_sminw_be) \
    X(helper_atomic_fetch_sminw_le) \
    X(helper_atomic_fetch_umaxb) \
    X(helper_atomic_fetch_umaxl_be) \
    X(helper_atomic_fetch_umaxl_le) \
    X(helper_atomic_fetch_umaxq_be) \
    X(helper_atomic_fetch_umaxq_le) \
    X(helper_atomic_fetch_umaxw_be) \
    X(helper_atomic_fetch_umaxw_le) \
    X(helper_atomic_fetch_uminb) \
    X(helper_atomic_fetch_uminl_be) \
    X(helper_atomic_fetch_uminl_le) \
    X(helper_atomic_fetch_uminq_be) \
    X(helper_atomic_fetch_uminq_le) \
    X(helper_atomic_fetch_uminw_be) \
    X(helper_atomic_fetch_uminw_le) \
    X(helper_atomic_fetch_xorb) \
    X(helper_atomic_fetch_xorl_be) \
    X(helper_atomic_fetch_xorl_le) \
    X(helper_atomic_fetch_xorq_be) \
    X(helper_atomic_fetch_xorq_le) \
    X(helper_atomic_fetch_xorw_be) \
    X(helper_atomic_fetch_xorw_le) \
    X(helper_atomic_or_fetchb) \
    X(helper_atomic_or_fetchl_be) \
    X(helper_atomic_or_fetchl_le) \
    X(helper_atomic_or_fetchq_be) \
    X(helper_atomic_or_fetchq_le) \
    X(helper_atomic_or_fetchw_be) \
    X(helper_atomic_or_fetchw_le) \
    X(helper_atomic_smax_fetchb) \
    X(helper_atomic_smax_fetchl_be) \
    X(helper_atomic_smax_fetchl_le) \
    X(helper_atomic_smax_fetchq_be) \
    X(helper_atomic_smax_fetchq_le) \
    X(helper_atomic_smax_fetchw_be) \
    X(helper_atomic_smax_fetchw_le) \
    X(helper_atomic_smin_fetchb) \
    X(helper_atomic_smin_fetchl_be) \
    X(helper_atomic_smin_fetchl_le) \
    X(helper_atomic_smin_fetchq_be) \
    X(helper_atomic_smin_fetchq_le) \
    X(helper_atomic_smin_fetchw_be) \
    X(helper_atomic_smin_fetchw_le) \
    X(helper_atomic_umax_fetchb) \
    X(helper_atomic_umax_fetchl_be) \
    X(helper_atomic_umax_fetchl_le) \
    X(helper_atomic_umax_fetchq_be) \
    X(helper_atomic_umax_fetchq_le) \
    X(helper_atomic_umax_fetchw_be) \
    X(helper_atomic_umax_fetchw_le) \
    X(helper_atomic_umin_fetchb) \
    X(helper_atomic_umin_fetchl_be) \
    X(helper_atomic_umin_fetchl_le) \
    X(helper_atomic_umin_fetchq_be) \
    X(helper_atomic_umin_fetchq_le) \
    X(helper_atomic_umin_fetchw_be) \
    X(helper_atomic_umin_fetchw_le) \
    X(helper_atomic_xchgb) \
    X(helper_atomic_xchgl_be) \
    X(helper_atomic_xchgl_le) \
    X(helper_atomic_xchgq_be) \
    X(helper_atomic_xchgq_le) \
    X(helper_atomic_xchgw_be) \
    X(helper_atomic_xchgw_le) \
    X(helper_atomic_xor_fetchb) \
    X(helper_atomic_xor_fetchl_be) \
    X(helper_atomic_xor_fetchl_le) \
    X(helper_atomic_xor_fetchq_be) \
    X(helper_atomic_xor_fetchq_le) \
    X(helper_atomic_xor_fetchw_be) \
    X(helper_atomic_xor_fetchw_le) \
    X(helper_bndck) \
    X(helper_bnd_jmp) \
    X(helper_bndldx32) \
    X(helper_bndldx64) \
    X(helper_bndstx32) \
    X(helper_bndstx64) \
    X(helper_boundl) \
    X(helper_boundw) \
    X(helper_cc_compute_all) \
    X(helper_cc_compute_c) \
    X(helper_cc_compute_nz) \
    X(helper_clrsb_i32) \
    X(helper_clrsb_i64) \
    X(helper_clts) \
    X(helper_clz_i32) \
    X(helper_clz_i64) \
    X(helper_cmpeqsd) \
    X(helper_cmpeqss) \
    X(helper_cmpeqssd) \
    X(helper_cmpeqsss) \
    X(helper_cmpequsd) \
    X(helper_cmpequss) \
    X(helper_cmpequssd) \
    X(helper_cmpequsss) \
    X(helper_cmpfalsesd) \
    X(helper_cmpfalsess) \
    X(helper_cmpfalsessd) \
    X(helper_cmpfalsesss) \
    X(helper_cmpgeqsd) \
    X(helper_cmpgeqss) \
    X(helper_cmpgesd) \
    X(helper_cmpgess) \
    X(helper_cmpgtqsd) \
    X(helper_cmpgtqss) \
    X(helper_cmpgtsd) \
    X(helper_cmpgtss) \
    X(helper_cmpleqsd) \
    X(helper_cmpleqss) \
    X(helper_cmplesd) \
    X(helper_cmpless) \
    X(helper_cmpltqsd) \
    X(helper_cmpltqss) \
    X(helper_cmpltsd) \
    X(helper_cmpltss) \
    X(helper_cmpneqqsd) \
    X(helper_cmpneqqss) \
    X(helper_cmpneqsd) \
    X(helper_cmpneqss) \
    X(helper_cmpnequsd) \
    X(helper_cmpnequss) \
    X(helper_cmpnequssd) \
    X(helper_cmpnequsss) \
    X(helper_cmpngeqsd) \
    X(helper_cmpngeqss) \
    X(helper_cmpngesd) \
    X(helper_cmpngess) \
    X(helper_cmpngtqsd) \
    X(helper_cmpngtqss) \
    X(helper_cmpngtsd) \
    X(helper_cmpngtss) \
    X(helper_cmpnleqsd) \
    X(helper_cmpnleqss) \
    X(helper_cmpnlesd) \
    X(helper_cmpnless) \
    X(helper_cmpnltqsd) \
    X(helper_cmpnltqss) \
    X(helper_cmpnltsd) \
    X(helper_cmpnltss) \
    X(helper_cmpordsd) \
    X(helper_cmpordss) \
    X(helper_cmpordssd) \
    X(helper_cmpordsss) \
    X(helper_cmptruesd) \
    X(helper_cmptruess) \
    X(helper_cmptruessd) \
    X(helper_cmptruesss) \
    X(helper_cmpunordsd) \
    X(helper_cmpunordss) \
    X(helper_cmpunordssd) \
    X(helper_cmpunordsss) \
    X(helper_comisd) \
    X(helper_comiss) \
    X(helper_cpuid) \
    X(helper_cr4_testbit) \
    X(helper_crc32) \
    X(helper_ctpop_i32) \
    X(helper_ctpop_i64) \
    X(helper_ctz_i32) \
    X(helper_ctz_i64) \
    X(helper_cvtpd2pi) \
    X(helper_cvtpi2pd) \
    X(helper_cvtpi2ps) \
    X(helper_cvtps2pi) \
    X(helper_cvtsd2si) \
    X(helper_cvtsd2sq) \
    X(helper_cvtsd2ss) \
    X(helper_cvtsi2sd) \
    X(helper_cvtsi2ss) \
    X(helper_cvtsq2sd) \
    X(helper_cvtsq2ss) \
    X(helper_cvtss2sd) \
    X(helper_cvtss2si) \
    X(helper_cvtss2sq) \
    X(helper_cvttpd2pi) \
    X(helper_cvttps2pi) \
    X(helper_cvttsd2si) \
    X(helper_cvttsd2sq) \
    X(helper_cvttss2si) \
    X(helper_cvttss2sq) \
    X(helper_daa) \
    X(helper_das) \
    X(helper_divb_AL) \
    X(helper_div_i32) \
    X(helper_div_i64) \
    X(helper_divl_EAX) \
    X(helper_divq_EAX) \
    X(helper_divsd) \
    X(helper_divss) \
    X(helper_divu_i32) \
    X(helper_divu_i64) \
    X(helper_divw_AX) \
    X(helper_emms) \
    X(helper_enter_mmx) \
    X(helper_exit_atomic) \
    X(helper_extrq_i) \
    X(helper_extrq_r) \
    X(helper_f2xm1) \
    X(helper_fabs_ST0) \
    X(helper_fadd_ST0_FT0) \
    X(helper_fadd_STN_ST0) \
    X(helper_fbld_ST0) \
    X(helper_fbst_ST0) \
    X(helper_fchs_ST0) \
    X(helper_fclex) \
    X(helper_fcomi_ST0_FT0) \
    X(helper_fcom_ST0_FT0) \
    X(helper_fcos) \
    X(helper_fdecstp) \
    X(helper_fdivr_ST0_FT0) \
    X(helper_fdivr_STN_ST0) \
    X(helper_fdiv_ST0_FT0) \
    X(helper_fdiv_STN_ST0) \
    X(helper_ffree_STN) \
    X(helper_fildl_FT0) \
    X(helper_fildll_ST0) \
    X(helper_fildl_ST0) \
    X(helper_fincstp) \
    X(helper_fistll_ST0) \
    X(helper_fistl_ST0) \
    X(helper_fist_ST0) \
    X(helper_fisttll_ST0) \
    X(helper_fisttl_ST0) \
    X(helper_fistt_ST0) \
    X(helper_fld1_ST0) \
    X(helper_fldcw) \
    X(helper_fldenv) \
    X(helper_fldl2e_ST0) \
    X(helper_fldl2t_ST0) \
    X(helper_fldl_FT0) \
    X(helper_fldlg2_ST0) \
    X(helper_fldln2_ST0) \
    X(helper_fldl_ST0) \
    X(helper_fldpi_ST0) \
    X(helper_flds_FT0) \
    X(helper_flds_ST0) \
    X(helper_fldt_ST0) \
    X(helper_fldz_FT0) \
    X(helper_fldz_ST0) \
    X(helper_fma4sd) \
    X(helper_fma4ss) \
    X(helper_fmov_FT0_STN) \
    X(helper_fmov_ST0_FT0) \
    X(helper_fmov_ST0_STN) \
    X(helper_fmov_STN_ST0) \
    X(helper_fmul_ST0_FT0) \
    X(helper_fmul_STN_ST0) \
    X(helper_fninit) \
    X(helper_fnstcw) \
    X(helper_fnstsw) \
    X(helper_fpatan) \
    X(helper_fpop) \
    X(helper_fprem) \
    X(helper_fprem1) \
    X(helper_fptan) \
    X(helper_fpush) \
    X(helper_frndint) \
    X(helper_frstor) \
    X(helper_fsave) \
    X(helper_fscale) \
    X(helper_fsin) \
    X(helper_fsincos) \
    X(helper_fsqrt) \
    X(helper_fstenv) \
    X(helper_fstl_ST0) \
    X(helper_fsts_ST0) \
    X(helper_fstt_ST0) \
    X(helper_fsubr_ST0_FT0) \
    X(helper_fsubr_STN_ST0) \
    X(helper_fsub_ST0_FT0) \
    X(helper_fsub_STN_ST0) \
    X(helper_fucomi_ST0_FT0) \
    X(helper_fucom_ST0_FT0) \
    X(helper_fwait) \
    X(helper_fxam_ST0) \
    X(helper_fxchg_ST0_STN) \
    X(helper_fxrstor) \
    X(helper_fxsave) \
    X(helper_fxtract) \
    X(helper_fyl2x) \
    X(helper_fyl2xp1) \
    X(helper_gvec_abs16) \
    X(helper_gvec_abs32) \
    X(helper_gvec_abs64) \
    X(helper_gvec_abs8) \
    X(helper_gvec_add16) \
    X(helper_gvec_add32) \
    X(helper_gvec_add64) \
    X(helper_gvec_add8) \
    X(helper_gvec_adds16) \
    X(helper_gvec_adds32) \
    X(helper_gvec_adds64) \
    X(helper_gvec_adds8) \
    X(helper_gvec_and) \
    X(helper_gvec_andc) \
    X(helper_gvec_andcs) \
    X(helper_gvec_ands) \
    X(helper_gvec_bitsel) \
    X(helper_gvec_dup16) \
    X(helper_gvec_dup32) \
    X(helper_gvec_dup64) \
    X(helper_gvec_dup8) \
    X(helper_gvec_eq16) \
    X(helper_gvec_eq32) \
    X(helper_gvec_eq64) \
    X(helper_gvec_eq8) \
    X(helper_gvec_eqs16) \
    X(helper_gvec_eqs32) \
    X(helper_gvec_eqs64) \
    X(helper_gvec_eqs8) \
    X(helper_gvec_eqv) \
    X(helper_gvec_le16) \
    X(helper_gvec_le32) \
    X(helper_gvec_le64) \
    X(helper_gvec_le8) \
    X(helper_gvec_les16) \
    X(helper_gvec_les32) \
    X(helper_gvec_les64) \
    X(helper_gvec_les8) \
    X(helper_gvec_leu16) \
    X(helper_gvec_leu32) \
    X(helper_gvec_leu64) \
    X(helper_gvec_leu8) \
    X(helper_gvec_leus16) \
    X(helper_gvec_leus32) \
    X(helper_gvec_leus64) \
    X(helper_gvec_leus8) \
    X(helper_gvec_lt16) \
    X(helper_gvec_lt32) \
    X(helper_gvec_lt64) \
    X(helper_gvec_lt8) \
    X(helper_gvec_lts16) \
    X(helper_gvec_lts32) \
    X(helper_gvec_lts64) \
    X(helper_gvec_lts8) \
    X(helper_gvec_ltu16) \
    X(helper_gvec_ltu32) \
    X(helper_gvec_ltu64) \
    X(helper_gvec_ltu8) \
    X(helper_gvec_ltus16) \
    X(helper_gvec_ltus32) \
    X(helper_gvec_ltus64) \
    X(helper_gvec_ltus8) \
    X(helper_gvec_mov) \
    X(helper_gvec_mul16) \
    X(helper_gvec_mul32) \
    X(helper_gvec_mul64) \
    X(helper_gvec_mul8) \
    X(helper_gvec_muls16) \
    X(helper_gvec_muls32) \
    X(helper_gvec_muls64) \
    X(helper_gvec_muls8) \
    X(helper_gvec_nand) \
    X(helper_gvec_ne16) \
    X(helper_gvec_ne32) \
    X(helper_gvec_ne64) \
    X(helper_gvec_ne8) \
    X(helper_gvec_neg16) \
    X(helper_gvec_neg32) \
    X(helper_gvec_neg64) \
    X(helper_gvec_neg8) \
    X(helper_gvec_nor) \
    X(helper_gvec_not) \
    X(helper_gvec_or) \
    X(helper_gvec_orc) \
    X(helper_gvec_ors) \
    X(helper_gvec_rotl16i) \
    X(helper_gvec_rotl16v) \
    X(helper_gvec_rotl32i) \
    X(helper_gvec_rotl32v) \
    X(helper_gvec_rotl64i) \
    X(helper_gvec_rotl64v) \
    X(helper_gvec_rotl8i) \
    X(helper_gvec_rotl8v) \
    X(helper_gvec_rotr16v) \
    X(helper_gvec_rotr32v) \
    X(helper_gvec_rotr64v) \
    X(helper_gvec_rotr8v) \
    X(helper_gvec_sar16i) \
    X(helper_gvec_sar16v) \
    X(helper_gvec_sar32i) \
    X(helper_gvec_sar32v) \
    X(helper_gvec_sar64i) \
    X(helper_gvec_sar64v) \
    X(helper_gvec_sar8i) \
    X(helper_gvec_sar8v) \
    X(helper_gvec_shl16i) \
    X(helper_gvec_shl16v) \
    X(helper_gvec_shl32i) \
    X(helper_gvec_shl32v) \
    X(helper_gvec_shl64i) \
    X(helper_gvec_shl64v) \
    X(helper_gvec_shl8i) \
    X(helper_gvec_shl8v) \
    X(helper_gvec_shr16i) \
    X(helper_gvec_shr16v) \
    X(helper_gvec_shr32i) \
    X(helper_gvec_shr32v) \
    X(helper_gvec_shr64i) \
    X(helper_gvec_shr64v) \
    X(helper_gvec_shr8i) \
    X(helper_gvec_shr8v) \
    X(helper_gvec_smax16) \
    X(helper_gvec_smax32) \
    X(helper_gvec_smax64) \
    X(helper_gvec_smax8) \
    X(helper_gvec_smin16) \
    X(helper_gvec_smin32) \
    X(helper_gvec_smin64) \
    X(helper_gvec_smin8) \
    X(helper_gvec_ssadd16) \
    X(helper_gvec_ssadd32) \
    X(helper_gvec_ssadd64) \
    X(helper_gvec_ssadd8) \
    X(helper_gvec_sssub16) \
    X(helper_gvec_sssub32) \
    X(helper_gvec_sssub64) \
    X(helper_gvec_sssub8) \
    X(helper_gvec_sub16) \
    X(helper_gvec_sub32) \
    X(helper_gvec_sub64) \
    X(helper_gvec_sub8) \
    X(helper_gvec_subs16) \
    X(helper_gvec_subs32) \
    X(helper_gvec_subs64) \
    X(helper_gvec_subs8) \
    X(helper_gvec_umax16) \
    X(helper_gvec_umax32) \
    X(helper_gvec_umax64) \
    X(helper_gvec_umax8) \
    X(helper_gvec_umin16) \
    X(helper_gvec_umin32) \
    X(helper_gvec_umin64) \
    X(helper_gvec_umin8) \
    X(helper_gvec_usadd16) \
    X(helper_gvec_usadd32) \
    X(helper_gvec_usadd64) \
    X(helper_gvec_usadd8) \
    X(helper_gvec_ussub16) \
    X(helper_gvec_ussub32) \
    X(helper_gvec_ussub64) \
    X(helper_gvec_ussub8) \
    X(helper_gvec_xor) \
    X(helper_gvec_xors) \
    X(helper_icebp) \
    X(helper_idivb_AL) \
    X(helper_idivl_EAX) \
    X(helper_idivq_EAX) \
    X(helper_idivw_AX) \
    X(helper_insertq_i) \
    X(helper_insertq_r) \
    X(helper_into) \
    X(helper_iret_protected) \
    X(helper_iret_real) \
    X(helper_lar) \
    X(helper_lcall_protected) \
    X(helper_lcall_real) \
    X(helper_ld_i128) \
    X(helper_ldmxcsr) \
    X(helper_ljmp_protected) \
    X(helper_lldt) \
    X(helper_load_seg) \
    X(helper_lookup_tb_ptr) \
    X(helper_lret_protected) \
    X(helper_lsl) \
    X(helper_ltr) \
    X(helper_maskmov_mmx) \
    X(helper_maxsd) \
    X(helper_maxss) \
    X(helper_memset) \
    X(helper_minsd) \
    X(helper_minss) \
    X(helper_mulsd) \
    X(helper_mulsh_i64) \
    X(helper_mulss) \
    X(helper_muluh_i64) \
    X(helper_nonatomic_cmpxchgo) \
    X(helper_packssdw_mmx) \
    X(helper_packsswb_mmx) \
    X(helper_packuswb_mmx) \
    X(helper_palignr_mmx) \
    X(helper_pause) \
    X(helper_pavgb_mmx) \
    X(helper_pavgw_mmx) \
    X(helper_pdep) \
    X(helper_pext) \
    X(helper_pf2id) \
    X(helper_pf2iw) \
    X(helper_pfacc) \
    X(helper_pfadd) \
    X(helper_pfcmpeq) \
    X(helper_pfcmpge) \
    X(helper_pfcmpgt) \
    X(helper_pfmax) \
    X(helper_pfmin) \
    X(helper_pfmul) \
    X(helper_pfnacc) \
    X(helper_pfpnacc) \
    X(helper_pfrcp) \
    X(helper_pfrsqrt) \
    X(helper_pfsub) \
    X(helper_pfsubr) \
    X(helper_phaddd_mmx) \
    X(helper_phaddsw_mmx) \
    X(helper_phaddw_mmx) \
    X(helper_phsubd_mmx) \
    X(helper_phsubsw_mmx) \
    X(helper_phsubw_mmx) \
    X(helper_pi2fd) \
    X(helper_pi2fw) \
    X(helper_pmaddubsw_mmx) \
    X(helper_pmaddwd_mmx) \
    X(helper_pmulhrsw_mmx) \
    X(helper_pmulhrw_mmx) \
    X(helper_pmulhuw_mmx) \
    X(helper_pmulhw_mmx) \
    X(helper_pmuludq_mmx) \
    X(helper_psadbw_mmx) \
    X(helper_pshufb_mmx) \
    X(helper_pshufw_mmx) \
    X(helper_psignb_mmx) \
    X(helper_psignd_mmx) \
    X(helper_psignw_mmx) \
    X(helper_pslld_mmx) \
    X(helper_psllq_mmx) \
    X(helper_psllw_mmx) \
    X(helper_psrad_mmx) \
    X(helper_psraw_mmx) \
    X(helper_psrld_mmx) \
    X(helper_psrlq_mmx) \
    X(helper_psrlw_mmx) \
    X(helper_pswapd) \
    X(helper_punpckhbw_mmx) \
    X(helper_punpckhdq_mmx) \
    X(helper_punpckhwd_mmx) \
    X(helper_punpcklbw_mmx) \
    X(helper_punpckldq_mmx) \
    X(helper_punpcklwd_mmx) \
    X(helper_raise_exception) \
    X(helper_raise_interrupt) \
    X(helper_rcpss) \
    X(helper_rdpid) \
    X(helper_rdpkru) \
    X(helper_rdpmc) \
    X(helper_rdrand) \
    X(helper_rdtsc) \
    X(helper_read_eflags) \
    X(helper_rechecking_single_step) \
    X(helper_rem_i32) \
    X(helper_rem_i64) \
    X(helper_remu_i32) \
    X(helper_remu_i64) \
    X(helper_rsqrtss) \
    X(helper_sar_i64) \
    X(helper_sha1msg1) \
    X(helper_sha1msg2) \
    X(helper_sha1nexte) \
    X(helper_sha1rnds4_f0) \
    X(helper_sha1rnds4_f1) \
    X(helper_sha1rnds4_f2) \
    X(helper_sha1rnds4_f3) \
    X(helper_sha256msg1) \
    X(helper_sha256msg2) \
    X(helper_sha256rnds2) \
    X(helper_shl_i64) \
    X(helper_shr_i64) \
    X(helper_single_step) \
    X(helper_sqrtsd) \
    X(helper_sqrtss) \
    X(helper_st_i128) \
    X(helper_subsd) \
    X(helper_subss) \
    X(helper_syscall) \
    X(helper_sysenter) \
    X(helper_sysexit) \
    X(helper_sysret) \
    X(helper_ucomisd) \
    X(helper_ucomiss) \
    X(helper_update_mxcsr) \
    X(helper_verr) \
    X(helper_verw) \
    X(helper_write_eflags) \
    X(helper_wrpkru) \
    X(helper_xgetbv) \
    X(helper_xrstor) \
    X(helper_xsave) \
    X(helper_xsaveopt) \
    X(helper_xsetbv) \
    X(helper_jmp_ind) \
    X(helper_iret_ind) \
    X(helper_dump_load) \
    X(helper_dump_store) \
    X(helper_dump_registers) \
    X(helper_jit) \
    X(jmp_ind_callback) \
    X(xmm_helper_begin) \
    X(helper_addpd_xmm) \
    X(helper_addps_xmm) \
    X(helper_addsubpd_xmm) \
    X(helper_addsubps_xmm) \
    X(helper_aesdeclast_xmm) \
    X(helper_aesdec_xmm) \
    X(helper_aesenclast_xmm) \
    X(helper_aesenc_xmm) \
    X(helper_aesimc_xmm) \
    X(helper_aeskeygenassist_xmm) \
    X(helper_blendpd_xmm) \
    X(helper_blendps_xmm) \
    X(helper_blendvpd_xmm) \
    X(helper_blendvps_xmm) \
    X(helper_cmpeqpd_xmm) \
    X(helper_cmpeqps_xmm) \
    X(helper_cmpeqspd_xmm) \
    X(helper_cmpeqsps_xmm) \
    X(helper_cmpequpd_xmm) \
    X(helper_cmpequps_xmm) \
    X(helper_cmpequspd_xmm) \
    X(helper_cmpequsps_xmm) \
    X(helper_cmpfalsepd_xmm) \
    X(helper_cmpfalseps_xmm) \
    X(helper_cmpfalsespd_xmm) \
    X(helper_cmpfalsesps_xmm) \
    X(helper_cmpgepd_xmm) \
    X(helper_cmpgeps_xmm) \
    X(helper_cmpgeqpd_xmm) \
    X(helper_cmpgeqps_xmm) \
    X(helper_cmpgtpd_xmm) \
    X(helper_cmpgtps_xmm) \
    X(helper_cmpgtqpd_xmm) \
    X(helper_cmpgtqps_xmm) \
    X(helper_cmplepd_xmm) \
    X(helper_cmpleps_xmm) \
    X(helper_cmpleqpd_xmm) \
    X(helper_cmpleqps_xmm) \
    X(helper_cmpltpd_xmm) \
    X(helper_cmpltps_xmm) \
    X(helper_cmpltqpd_xmm) \
    X(helper_cmpltqps_xmm) \
    X(helper_cmpneqpd_xmm) \
    X(helper_cmpneqps_xmm) \
    X(helper_cmpneqqpd_xmm) \
    X(helper_cmpneqqps_xmm) \
    X(helper_cmpnequpd_xmm) \
    X(helper_cmpnequps_xmm) \
    X(helper_cmpnequspd_xmm) \
    X(helper_cmpnequsps_xmm) \
    X(helper_cmpngepd_xmm) \
    X(helper_cmpngeps_xmm) \
    X(helper_cmpngeqpd_xmm) \
    X(helper_cmpngeqps_xmm) \
    X(helper_cmpngtpd_xmm) \
    X(helper_cmpngtps_xmm) \
    X(helper_cmpngtqpd_xmm) \
    X(helper_cmpngtqps_xmm) \
    X(helper_cmpnlepd_xmm) \
    X(helper_cmpnleps_xmm) \
    X(helper_cmpnleqpd_xmm) \
    X(helper_cmpnleqps_xmm) \
    X(helper_cmpnltpd_xmm) \
    X(helper_cmpnltps_xmm) \
    X(helper_cmpnltqpd_xmm) \
    X(helper_cmpnltqps_xmm) \
    X(helper_cmpordpd_xmm) \
    X(helper_cmpordps_xmm) \
    X(helper_cmpordspd_xmm) \
    X(helper_cmpordsps_xmm) \
    X(helper_cmptruepd_xmm) \
    X(helper_cmptrueps_xmm) \
    X(helper_cmptruespd_xmm) \
    X(helper_cmptruesps_xmm) \
    X(helper_cmpunordpd_xmm) \
    X(helper_cmpunordps_xmm) \
    X(helper_cmpunordspd_xmm) \
    X(helper_cmpunordsps_xmm) \
    X(helper_cvtdq2pd_xmm) \
    X(helper_cvtdq2ps_xmm) \
    X(helper_cvtpd2dq_xmm) \
    X(helper_cvtpd2ps_xmm) \
    X(helper_cvtph2ps_xmm) \
    X(helper_cvtps2dq_xmm) \
    X(helper_cvtps2pd_xmm) \
    X(helper_cvtps2ph_xmm) \
    X(helper_cvttpd2dq_xmm) \
    X(helper_cvttps2dq_xmm) \
    X(helper_divpd_xmm) \
    X(helper_divps_xmm) \
    X(helper_dppd_xmm) \
    X(helper_dpps_xmm) \
    X(helper_fma4pd_xmm) \
    X(helper_fma4ps_xmm) \
    X(helper_haddpd_xmm) \
    X(helper_haddps_xmm) \
    X(helper_hsubpd_xmm) \
    X(helper_hsubps_xmm) \
    X(helper_maskmov_xmm) \
    X(helper_maxpd_xmm) \
    X(helper_maxps_xmm) \
    X(helper_minpd_xmm) \
    X(helper_minps_xmm) \
    X(helper_movmskpd_xmm) \
    X(helper_movmskps_xmm) \
    X(helper_mpsadbw_xmm) \
    X(helper_mulpd_xmm) \
    X(helper_mulps_xmm) \
    X(helper_packssdw_xmm) \
    X(helper_packsswb_xmm) \
    X(helper_packusdw_xmm) \
    X(helper_packuswb_xmm) \
    X(helper_palignr_xmm) \
    X(helper_pavgb_xmm) \
    X(helper_pavgw_xmm) \
    X(helper_pblendvb_xmm) \
    X(helper_pblendw_xmm) \
    X(helper_pclmulqdq_xmm) \
    X(helper_pcmpestri_xmm) \
    X(helper_pcmpestrm_xmm) \
    X(helper_pcmpistri_xmm) \
    X(helper_pcmpistrm_xmm) \
    X(helper_phaddd_xmm) \
    X(helper_phaddsw_xmm) \
    X(helper_phaddw_xmm) \
    X(helper_phminposuw_xmm) \
    X(helper_phsubd_xmm) \
    X(helper_phsubsw_xmm) \
    X(helper_phsubw_xmm) \
    X(helper_pmaddubsw_xmm) \
    X(helper_pmaddwd_xmm) \
    X(helper_pmovdldup_xmm) \
    X(helper_pmovshdup_xmm) \
    X(helper_pmovsldup_xmm) \
    X(helper_pmovsxbd_xmm) \
    X(helper_pmovsxbq_xmm) \
    X(helper_pmovsxbw_xmm) \
    X(helper_pmovsxdq_xmm) \
    X(helper_pmovsxwd_xmm) \
    X(helper_pmovsxwq_xmm) \
    X(helper_pmovzxbd_xmm) \
    X(helper_pmovzxbq_xmm) \
    X(helper_pmovzxbw_xmm) \
    X(helper_pmovzxdq_xmm) \
    X(helper_pmovzxwd_xmm) \
    X(helper_pmovzxwq_xmm) \
    X(helper_pmuldq_xmm) \
    X(helper_pmulhrsw_xmm) \
    X(helper_pmulhuw_xmm) \
    X(helper_pmulhw_xmm) \
    X(helper_pmuludq_xmm) \
    X(helper_psadbw_xmm) \
    X(helper_pshufb_xmm) \
    X(helper_pshufd_xmm) \
    X(helper_pshufhw_xmm) \
    X(helper_pshuflw_xmm) \
    X(helper_psignb_xmm) \
    X(helper_psignd_xmm) \
    X(helper_psignw_xmm) \
    X(helper_pslldq_xmm) \
    X(helper_pslld_xmm) \
    X(helper_psllq_xmm) \
    X(helper_psllw_xmm) \
    X(helper_psrad_xmm) \
    X(helper_psraw_xmm) \
    X(helper_psrldq_xmm) \
    X(helper_psrld_xmm) \
    X(helper_psrlq_xmm) \
    X(helper_psrlw_xmm) \
    X(helper_ptest_xmm) \
    X(helper_punpckhbw_xmm) \
    X(helper_punpckhdq_xmm) \
    X(helper_punpckhqdq_xmm) \
    X(helper_punpckhwd_xmm) \
    X(helper_punpcklbw_xmm) \
    X(helper_punpckldq_xmm) \
    X(helper_punpcklqdq_xmm) \
    X(helper_punpcklwd_xmm) \
    X(helper_rcpps_xmm) \
    X(helper_roundpd_xmm) \
    X(helper_roundps_xmm) \
    X(helper_roundsd_xmm) \
    X(helper_roundss_xmm) \
    X(helper_rsqrtps_xmm) \
    X(helper_shufpd_xmm) \
    X(helper_shufps_xmm) \
    X(helper_sqrtpd_xmm) \
    X(helper_sqrtps_xmm) \
    X(helper_subpd_xmm) \
    X(helper_subps_xmm) \
    X(helper_vpermilpd_imm_xmm) \
    X(helper_vpermilpd_xmm) \
    X(helper_vpermilps_imm_xmm) \
    X(helper_vpermilps_xmm) \
    X(helper_vpgatherdd_xmm) \
    X(helper_vpgatherdq_xmm) \
    X(helper_vpgatherqd_xmm) \
    X(helper_vpgatherqq_xmm) \
    X(helper_vpmaskmovd_st_xmm) \
    X(helper_vpmaskmovd_xmm) \
    X(helper_vpmaskmovq_st_xmm) \
    X(helper_vpmaskmovq_xmm) \
    X(helper_vpsllvd_xmm) \
    X(helper_vpsllvq_xmm) \
    X(helper_vpsravd_xmm) \
    X(helper_vpsravq_xmm) \
    X(helper_vpsrlvd_xmm) \
    X(helper_vpsrlvq_xmm) \
    X(helper_vtestpd_xmm) \
    X(helper_vtestps_xmm) \
    X(ymm_helper_begin) \
    X(helper_addpd_ymm) \
    X(helper_addps_ymm) \
    X(helper_addsubpd_ymm) \
    X(helper_addsubps_ymm) \
    X(helper_aesdeclast_ymm) \
    X(helper_aesdec_ymm) \
    X(helper_aesenclast_ymm) \
    X(helper_aesenc_ymm) \
    X(helper_blendpd_ymm) \
    X(helper_blendps_ymm) \
    X(helper_blendvpd_ymm) \
    X(helper_blendvps_ymm) \
    X(helper_cmpeqpd_ymm) \
    X(helper_cmpeqps_ymm) \
    X(helper_cmpeqspd_ymm) \
    X(helper_cmpeqsps_ymm) \
    X(helper_cmpequpd_ymm) \
    X(helper_cmpequps_ymm) \
    X(helper_cmpequspd_ymm) \
    X(helper_cmpequsps_ymm) \
    X(helper_cmpfalsepd_ymm) \
    X(helper_cmpfalseps_ymm) \
    X(helper_cmpfalsespd_ymm) \
    X(helper_cmpfalsesps_ymm) \
    X(helper_cmpgepd_ymm) \
    X(helper_cmpgeps_ymm) \
    X(helper_cmpgeqpd_ymm) \
    X(helper_cmpgeqps_ymm) \
    X(helper_cmpgtpd_ymm) \
    X(helper_cmpgtps_ymm) \
    X(helper_cmpgtqpd_ymm) \
    X(helper_cmpgtqps_ymm) \
    X(helper_cmplepd_ymm) \
    X(helper_cmpleps_ymm) \
    X(helper_cmpleqpd_ymm) \
    X(helper_cmpleqps_ymm) \
    X(helper_cmpltpd_ymm) \
    X(helper_cmpltps_ymm) \
    X(helper_cmpltqpd_ymm) \
    X(helper_cmpltqps_ymm) \
    X(helper_cmpneqpd_ymm) \
    X(helper_cmpneqps_ymm) \
    X(helper_cmpneqqpd_ymm) \
    X(helper_cmpneqqps_ymm) \
    X(helper_cmpnequpd_ymm) \
    X(helper_cmpnequps_ymm) \
    X(helper_cmpnequspd_ymm) \
    X(helper_cmpnequsps_ymm) \
    X(helper_cmpngepd_ymm) \
    X(helper_cmpngeps_ymm) \
    X(helper_cmpngeqpd_ymm) \
    X(helper_cmpngeqps_ymm) \
    X(helper_cmpngtpd_ymm) \
    X(helper_cmpngtps_ymm) \
    X(helper_cmpngtqpd_ymm) \
    X(helper_cmpngtqps_ymm) \
    X(helper_cmpnlepd_ymm) \
    X(helper_cmpnleps_ymm) \
    X(helper_cmpnleqpd_ymm) \
    X(helper_cmpnleqps_ymm) \
    X(helper_cmpnltpd_ymm) \
    X(helper_cmpnltps_ymm) \
    X(helper_cmpnltqpd_ymm) \
    X(helper_cmpnltqps_ymm) \
    X(helper_cmpordpd_ymm) \
    X(helper_cmpordps_ymm) \
    X(helper_cmpordspd_ymm) \
    X(helper_cmpordsps_ymm) \
    X(helper_cmptruepd_ymm) \
    X(helper_cmptrueps_ymm) \
    X(helper_cmptruespd_ymm) \
    X(helper_cmptruesps_ymm) \
    X(helper_cmpunordpd_ymm) \
    X(helper_cmpunordps_ymm) \
    X(helper_cmpunordspd_ymm) \
    X(helper_cmpunordsps_ymm) \
    X(helper_cvtdq2pd_ymm) \
    X(helper_cvtdq2ps_ymm) \
    X(helper_cvtpd2dq_ymm) \
    X(helper_cvtpd2ps_ymm) \
    X(helper_cvtph2ps_ymm) \
    X(helper_cvtps2dq_ymm) \
    X(helper_cvtps2pd_ymm) \
    X(helper_cvtps2ph_ymm) \
    X(helper_cvttpd2dq_ymm) \
    X(helper_cvttps2dq_ymm) \
    X(helper_divpd_ymm) \
    X(helper_divps_ymm) \
    X(helper_dpps_ymm) \
    X(helper_fma4pd_ymm) \
    X(helper_fma4ps_ymm) \
    X(helper_haddpd_ymm) \
    X(helper_haddps_ymm) \
    X(helper_hsubpd_ymm) \
    X(helper_hsubps_ymm) \
    X(helper_maxpd_ymm) \
    X(helper_maxps_ymm) \
    X(helper_minpd_ymm) \
    X(helper_minps_ymm) \
    X(helper_movmskpd_ymm) \
    X(helper_movmskps_ymm) \
    X(helper_mpsadbw_ymm) \
    X(helper_mulpd_ymm) \
    X(helper_mulps_ymm) \
    X(helper_packssdw_ymm) \
    X(helper_packsswb_ymm) \
    X(helper_packusdw_ymm) \
    X(helper_packuswb_ymm) \
    X(helper_palignr_ymm) \
    X(helper_pavgb_ymm) \
    X(helper_pavgw_ymm) \
    X(helper_pblendvb_ymm) \
    X(helper_pblendw_ymm) \
    X(helper_pclmulqdq_ymm) \
    X(helper_phaddd_ymm) \
    X(helper_phaddsw_ymm) \
    X(helper_phaddw_ymm) \
    X(helper_phsubd_ymm) \
    X(helper_phsubsw_ymm) \
    X(helper_phsubw_ymm) \
    X(helper_pmaddubsw_ymm) \
    X(helper_pmaddwd_ymm) \
    X(helper_pmovdldup_ymm) \
    X(helper_pmovshdup_ymm) \
    X(helper_pmovsldup_ymm) \
    X(helper_pmovsxbd_ymm) \
    X(helper_pmovsxbq_ymm) \
    X(helper_pmovsxbw_ymm) \
    X(helper_pmovsxdq_ymm) \
    X(helper_pmovsxwd_ymm) \
    X(helper_pmovsxwq_ymm) \
    X(helper_pmovzxbd_ymm) \
    X(helper_pmovzxbq_ymm) \
    X(helper_pmovzxbw_ymm) \
    X(helper_pmovzxdq_ymm) \
    X(helper_pmovzxwd_ymm) \
    X(helper_pmovzxwq_ymm) \
    X(helper_pmuldq_ymm) \
    X(helper_pmulhrsw_ymm) \
    X(helper_pmulhuw_ymm) \
    X(helper_pmulhw_ymm) \
    X(helper_pmuludq_ymm) \
    X(helper_psadbw_ymm) \
    X(helper_pshufb_ymm) \
    X(helper_pshufd_ymm) \
    X(helper_pshufhw_ymm) \
    X(helper_pshuflw_ymm) \
    X(helper_psignb_ymm) \
    X(helper_psignd_ymm) \
    X(helper_psignw_ymm) \
    X(helper_pslldq_ymm) \
    X(helper_pslld_ymm) \
    X(helper_psllq_ymm) \
    X(helper_psllw_ymm) \
    X(helper_psrad_ymm) \
    X(helper_psraw_ymm) \
    X(helper_psrldq_ymm) \
    X(helper_psrld_ymm) \
    X(helper_psrlq_ymm) \
    X(helper_psrlw_ymm) \
    X(helper_ptest_ymm) \
    X(helper_punpckhbw_ymm) \
    X(helper_punpckhdq_ymm) \
    X(helper_punpckhqdq_ymm) \
    X(helper_punpckhwd_ymm) \
    X(helper_punpcklbw_ymm) \
    X(helper_punpckldq_ymm) \
    X(helper_punpcklqdq_ymm) \
    X(helper_punpcklwd_ymm) \
    X(helper_rcpps_ymm) \
    X(helper_roundpd_ymm) \
    X(helper_roundps_ymm) \
    X(helper_rsqrtps_ymm) \
    X(helper_shufpd_ymm) \
    X(helper_shufps_ymm) \
    X(helper_sqrtpd_ymm) \
    X(helper_sqrtps_ymm) \
    X(helper_subpd_ymm) \
    X(helper_subps_ymm) \
    X(helper_vpermdq_ymm) \
    X(helper_vpermd_ymm) \
    X(helper_vpermilpd_imm_ymm) \
    X(helper_vpermilpd_ymm) \
    X(helper_vpermilps_imm_ymm) \
    X(helper_vpermilps_ymm) \
    X(helper_vpermq_ymm) \
    X(helper_vpgatherdd_ymm) \
    X(helper_vpgatherdq_ymm) \
    X(helper_vpgatherqd_ymm) \
    X(helper_vpgatherqq_ymm) \
    X(helper_vpmaskmovd_st_ymm) \
    X(helper_vpmaskmovd_ymm) \
    X(helper_vpmaskmovq_st_ymm) \
    X(helper_vpmaskmovq_ymm) \
    X(helper_vpsllvd_ymm) \
    X(helper_vpsllvq_ymm) \
    X(helper_vpsravd_ymm) \
    X(helper_vpsravq_ymm) \
    X(helper_vpsrlvd_ymm) \
    X(helper_vpsrlvq_ymm) \
    X(helper_vtestpd_ymm) \
    X(helper_vtestps_ymm) \
    X(HELPER_MAX)

typedef enum {
    #define X(name) name,
    HELPER_LIST
    #undef X
} HelperType;

#define OPCODE_TYPE_LIST \
    X(abs_vec)           \
    X(addc1o_i32)        \
    X(addc1o_i64)        \
    X(addci_i32)         \
    X(addci_i64)         \
    X(addcio_i32)        \
    X(addcio_i64)        \
    X(addco_i32)         \
    X(addco_i64)         \
    X(add_i32)           \
    X(add_i64)           \
    X(add_vec)           \
    X(andc_i32)          \
    X(andc_i64)          \
    X(andc_vec)          \
    X(and_i32)           \
    X(and_i64)           \
    X(and_vec)           \
    X(bitsel_vec)        \
    X(br)                \
    X(brcond_i32)        \
    X(brcond_i64)        \
    X(bswap16_i32)       \
    X(bswap16_i64)       \
    X(bswap32_i32)       \
    X(bswap32_i64)       \
    X(bswap64_i64)       \
    X(call)              \
    X(clz_i32)           \
    X(clz_i64)           \
    X(cmpsel_vec)        \
    X(cmp_vec)           \
    X(ctpop_i32)         \
    X(ctpop_i64)         \
    X(ctz_i32)           \
    X(ctz_i64)           \
    X(deposit_i32)       \
    X(deposit_i64)       \
    X(discard)           \
    X(divs2_i32)         \
    X(divs2_i64)         \
    X(divs_i32)          \
    X(divs_i64)          \
    X(divu2_i32)         \
    X(divu2_i64)         \
    X(divu_i32)          \
    X(divu_i64)          \
    X(dupm_vec)          \
    X(dup_vec)           \
    X(eqv_i32)           \
    X(eqv_i64)           \
    X(eqv_vec)           \
    X(ext_i32_i64)       \
    X(extract2_i32)      \
    X(extract2_i64)      \
    X(extract_i32)       \
    X(extract_i64)       \
    X(extrh_i64_i32)     \
    X(extrl_i64_i32)     \
    X(extu_i32_i64)      \
    X(jmp_direct)        \
    X(ld16s_i32)         \
    X(ld16s_i64)         \
    X(ld16u_i32)         \
    X(ld16u_i64)         \
    X(ld32s_i64)         \
    X(ld32u_i64)         \
    X(ld8s_i32)          \
    X(ld8s_i64)          \
    X(ld8u_i32)          \
    X(ld8u_i64)          \
    X(ld_i32)            \
    X(ld_i64)            \
    X(ld_vec)            \
    X(movcond_i32)       \
    X(movcond_i64)       \
    X(movcond_vec)       \
    X(mov_i32)           \
    X(mov_i64)           \
    X(mov_vec)           \
    X(mul_i32)           \
    X(mul_i64)           \
    X(muls2_i32)         \
    X(muls2_i64)         \
    X(mulsh_i32)         \
    X(mulsh_i64)         \
    X(mulu2_i32)         \
    X(mulu2_i64)         \
    X(muluh_i32)         \
    X(muluh_i64)         \
    X(mul_vec)           \
    X(nand_i32)          \
    X(nand_i64)          \
    X(nand_vec)          \
    X(neg_i32)           \
    X(neg_i64)           \
    X(negsetcond_i32)    \
    X(negsetcond_i64)    \
    X(neg_vec)           \
    X(nor_i32)           \
    X(nor_i64)           \
    X(nor_vec)           \
    X(not_i32)           \
    X(not_i64)           \
    X(not_vec)           \
    X(orc_i32)           \
    X(orc_i64)           \
    X(orc_vec)           \
    X(or_i32)            \
    X(or_i64)            \
    X(or_vec)            \
    X(push_ret_addr)     \
    X(qemu_ld2_i128)     \
    X(qemu_ld_i32)       \
    X(qemu_ld_i64)       \
    X(qemu_st2_i128)     \
    X(qemu_st_i32)       \
    X(qemu_st_i64)       \
    X(rems_i32)          \
    X(rems_i64)          \
    X(remu_i32)          \
    X(remu_i64)          \
    X(ret)               \
    X(rotl_i32)          \
    X(rotl_i64)          \
    X(rotli_vec)         \
    X(rotls_vec)         \
    X(rotlv_vec)         \
    X(rotr_i32)          \
    X(rotr_i64)          \
    X(rotrv_vec)         \
    X(sar_i32)           \
    X(sar_i64)           \
    X(sari_vec)          \
    X(sars_vec)          \
    X(sarv_vec)          \
    X(setcond_i32)       \
    X(setcond_i64)       \
    X(set_label)         \
    X(sextract_i32)      \
    X(sextract_i64)      \
    X(shl_i32)           \
    X(shl_i64)           \
    X(shli_vec)          \
    X(shls_vec)          \
    X(shlv_vec)          \
    X(shr_i32)           \
    X(shr_i64)           \
    X(shri_vec)          \
    X(shrs_vec)          \
    X(shrv_vec)          \
    X(smax_vec)          \
    X(smin_vec)          \
    X(ssadd_vec)         \
    X(sssub_vec)         \
    X(st16_i32)          \
    X(st16_i64)          \
    X(st32_i64)          \
    X(st8_i32)           \
    X(st8_i64)           \
    X(st_i32)            \
    X(st_i64)            \
    X(st_vec)            \
    X(subb1o_i32)        \
    X(subb1o_i64)        \
    X(subbi_i32)         \
    X(subbi_i64)         \
    X(subbio_i32)        \
    X(subbio_i64)        \
    X(subbo_i32)         \
    X(subbo_i64)         \
    X(sub_i32)           \
    X(sub_i64)           \
    X(sub_vec)           \
    X(umax_vec)          \
    X(umin_vec)          \
    X(usadd_vec)         \
    X(ussub_vec)         \
    X(xor_i32)           \
    X(xor_i64)           \
    X(xor_vec)           \
    X(OPCODE_MAX)

typedef enum {
    #define X(name) name,
    OPCODE_TYPE_LIST
    #undef X
} OpCodeType;

typedef struct {
    OpCodeType o;
    HelperType h;
} OHType;

#define ALIGNMENT_TYPE_LIST \
    X(UNALIGN) \
    X(ALIGN_MEM_SIZE) \
    X(ALIGN_16) \
    X(ALIGN_32)

typedef enum {
    #define X(name) name,
    ALIGNMENT_TYPE_LIST
    #undef X
} AlignmentType;

typedef enum {
    NONATOMIC = 0,
} AtomicType;

#define SRCEXT_TYPE_LIST \
    X(ZERO) \
    X(SIGN)

typedef enum {
    #define X(name) name,
    SRCEXT_TYPE_LIST
    #undef X
} SrcExtType;

#define SRCSIZE_TYPE_LIST \
    X(SRC1B) \
    X(SRC2B) \
    X(SRC4B) \
    X(SRC8B) \
    X(SRC16B)

typedef enum {
    #define X(name) name,
    SRCSIZE_TYPE_LIST
    #undef X
} SrcSizeType;

typedef enum {
    IZ = (1 << 0),
    OZ = (1 << 1),
    IS = (1 << 2),
    OS = (1 << 3),
} SwapAttrType;

#define ATTR_TYPE_LIST \
    X(SUB_ATTR_STORAGE) \
    X(SUB_ATTR_VECTORSIZE) \
    X(SUB_ATTR_ELEMENTSIZE) \
    X(SUB_ATTR_SWAP) \
    X(SUB_ATTR_INVALID) \
    X(SUB_ATTR_ATOMIC) \
    X(SUB_ATTR_ALIGNMENT) \
    X(SUB_ATTR_SRCSIZEEXT)

typedef enum {
    #define X(name) name,
    ATTR_TYPE_LIST
    #undef X
} AttrType;

#define VECTOR_SIZE_LIST \
    X(VS_INVALID) \
    X(VS64) \
    X(VS128) \
    X(VS256)

typedef enum {
    #define X(name) name,
    VECTOR_SIZE_LIST
    #undef X
} VectorSizeType;

#define VECTOR_ELEMSIZE_LIST \
    X(VES8) \
    X(VES16) \
    X(VES32) \
    X(VES64)

typedef enum {
    #define X(name) name,
    VECTOR_ELEMSIZE_LIST
    #undef X
} VectorElemSizeType;

typedef struct {
    AttrType subt;
    union {
        VectorSizeType vs;
        VectorElemSizeType ves;
        struct {
            union {
                AtomicType atomic;
                AlignmentType alignment;
                SrcExtType ext;
            } attr;
            SrcSizeType size;
        } storage;
        SwapAttrType swap;
    } p;
} AttrSrcInfo;

#define SLOT_TYPE_LIST \
    X(SUB_SLOT_ENVVAR) \
    X(SUB_SLOT_XREG) \
    X(SUB_SLOT_TMP) \
    X(SUB_SLOT_XMM) \
    X(SUB_SLOT_ENV) \
    X(SUB_SLOT_TMPL) \
    X(SUB_SLOT_TMPT)

typedef enum {
    #define X(name) name,
    SLOT_TYPE_LIST
    #undef X
} SlotType;

#define XMM_REG_LIST \
    X(xmm0) \
    X(ymm0_h) \
    X(xmm1) \
    X(ymm1_h) \
    X(xmm2) \
    X(ymm2_h) \
    X(xmm3) \
    X(ymm3_h) \
    X(xmm4) \
    X(ymm4_h) \
    X(xmm5) \
    X(ymm5_h) \
    X(xmm6) \
    X(ymm6_h) \
    X(xmm7) \
    X(ymm7_h) \
    X(xmm8) \
    X(ymm8_h) \
    X(xmm9) \
    X(ymm9_h) \
    X(xmm10) \
    X(ymm10_h) \
    X(xmm11) \
    X(ymm11_h) \
    X(xmm12) \
    X(ymm12_h) \
    X(xmm13) \
    X(ymm13_h) \
    X(xmm14) \
    X(ymm14_h) \
    X(xmm15) \
    X(ymm15_h) \
    X(xmm_tmp) \
    X(ymm_tmp_h) \
    X(NON_XMM)

typedef enum {
    #define X(name) name,
    XMM_REG_LIST
    #undef X
} XMMRegType;

typedef struct {
    uint16_t xmm_idx    :7;
    uint16_t xmm_offset :4;
} XMMReg;

#define INSTR_TYPE_LIST \
    X(SIZE2B) \
    X(SIZEXB)

typedef enum {
    #define X(name) name,
    INSTR_TYPE_LIST
    #undef X
} InstrType;

#define INSTR_EXT_TYPE_LIST \
    X(Instr1B14_ext) \
    X(Instr1B28_ext) \
    X(Instr1B44_ext) \
    X(Instr1B48_ext) \
    X(Instr1B4_ext) \
    X(Instr1BV4X_ext) \
    X(Instr1BV4XE_ext) \
    X(Instr1B41I2_ext) \
    X(Instr1B4X_ext) \
    X(Instr1B22_ext) \
    X(Instr1B21_ext) \
    X(Instr1B2_ext) \
    X(Instr1BH4_ext) \
    X(Instr1BV4_ext) \
    X(Instr1BV42_ext) \
    X(Instr1BV8_ext) \
    X(Instr1BH141_ext) \
    X(Instr1BV21_ext) \
    X(Instr1B41_ext) \
    X(Instr1BV4I_ext) \
    X(Instr1B24_ext) \
    X(Instr1BV4S2_ext) \
    X(Instr1BV41_ext) \
    X(Instr1BH24I_ENV0_ext) \
    X(Instr1B2S_ext) \
    X(Instr1B41I_ext) \
    X(Instr1B422_ext) \
    X(Instr1B411_ext) \
    X(Instr1B142_ext) \
    X(Instr1B142E_ext) \
    X(Instr1BH21_ENV0_ext) \
    X(Instr1BH21_ENV1_ext) \
    X(Instr1B4111_ext) \
    X(Instr1B8_ext) \
    X(Instr1BH4I_ext) \
    X(Instr1BH4I_ENV0_ext) \
    X(Instr1BH5I_ENV0_ext) \
    X(Instr1BH5I2_ENV0_ext) \
    X(Instr1B42_ext) \
    X(Instr1BH2_ENV0_ext) \
    X(Instr1BH21S_ENV0_ext) \
    X(Instr1B281_ext) \
    X(Instr1BH4S2_ext) \
    X(Instr1BH4S3_ext) \
    X(Instr1BH4S3_ENV0_ext) \
    X(Instr1B4112_ext) \
    X(Instr1BH412_ext) \
    X(Instr1BH41_ext) \
    X(Instr1BH41_ENV0_ext) \
    X(Instr1BH42_ENV0_ext) \
    X(Instr1B41R_ext) \
    X(Instr1BH24_ENV0_ext) \
    X(Instr1BH211_ENV0_ext) \
    X(Instr1B1111_ext) \
    X(Instr1BH4S_ENV0_ext) \
    X(Instr1BH4S_ENV1_ext) \
    X(Instr4B_ext) \
    X(Instr1B143_ext) \
    X(Instr1BH4I1_ext) \
    X(Instr1B41122_ext) \
    X(Instr1BH4I11_ext) \
    X(Instr1BH42_ext)

typedef enum {
    #define X(name) name,
    INSTR_EXT_TYPE_LIST
    #undef X
} InstrExtType;

#define LLVM_TYPE_LIST \
    X(LLVMInvalidType) \
    X(LLVMInt8) \
    X(LLVMInt16) \
    X(LLVMInt32) \
    X(LLVMInt64) \
    X(LLVMVector8xi8) \
    X(LLVMVector4xi16) \
    X(LLVMVector2xi32) \
    X(LLVMVector1xi64) \
    X(LLVMVector16xi8) \
    X(LLVMVector8xi16) \
    X(LLVMVector4xi32) \
    X(LLVMVector2xi64) \
    X(LLVMVector32xi8) \
    X(LLVMVector16xi16) \
    X(LLVMVector8xi32) \
    X(LLVMVector4xi64) \
    X(LLVMInt128)

typedef enum {
    #define X(name) name,
    LLVM_TYPE_LIST
    #undef X
} LLVMType;

#define C_VECTOR_TYPE \
    X(vinvalid) \
    X(v2ulong) \
    X(v4uint) \
    X(v8ushort) \
    X(v16uchar) \
    X(v4ulong) \
    X(v8uint) \
    X(v16ushort) \
    X(v32uchar)

typedef enum {
    #define X(name) name,
    C_VECTOR_TYPE
    #undef X
} CVectorType;

#include "instr_def.h"

typedef struct {
    uint16_t valid     :1;
    uint16_t slot_type :3;
    uint16_t slot_idx  :10;
    uint16_t offset;
} SlotT;

typedef union {
    uint64_t i;
    SlotT s;
} OperandType;

typedef struct {
    uint16_t attr_type  :4;
    /*
    union {
        struct {
            uint32_t atomic :1;
            uint32_t alignment :2;
            uint32_t sign_ext :1;
            uint32_t src_size :3;
        } storage_attr;
        uint32_t attr_val :7;
    } p;
    */
    uint16_t attr_val   :7;
} AttributeType;

#ifdef __GNUC__
#define likely(x)    __builtin_expect(!!(x), 1)  // True with high probability
#define unlikely(x)  __builtin_expect(!!(x), 0)  // False with high probability
#else
#define likely(x)    (x)  // Fallback for non-GCC compilers
#define unlikely(x)  (x)
#endif

void register_xmm(uint64_t idx, uint64_t offset);
void register_xmm_tmp(uint64_t offset);
void reset_tmp_mapping();
XMMReg lookup_xmm_map(uint64_t offset);

size_t create_scalar_slot(void *ptr, OHType op, OperandType s0);
size_t create_scalar_slot2(void *ptr, OHType op, OperandType s0, OperandType s1);
size_t create_scalar_slot2_attr(void *ptr, OHType op, OperandType s0, OperandType s1, AttrSrcInfo a0);
size_t create_scalar_slot2_attr2(void *ptr, OHType op, OperandType s0, OperandType s1, AttrSrcInfo a0, AttrSrcInfo a1);
size_t create_scalar_slot_imm(void *ptr, OHType op, OperandType s0, uint64_t i0);
size_t create_scalar_slot_imm_slot(void *ptr, OHType op, OperandType s0, uint64_t i0, OperandType s1);
size_t create_scalar_slot_env_imm(void *ptr, OHType op, OperandType s0, uint64_t i0);
size_t create_scalar_slot2_attr3_num(void *ptr, OHType op, OperandType s0, OperandType s1, AttrSrcInfo a0, AttrSrcInfo a1, AttrSrcInfo a2, uint64_t n0);
size_t create_scalar_imm_env_imm(void *ptr, OHType op, uint64_t i0, uint64_t i1);
size_t create_scalar_imm_slot_imm(void *ptr, OHType op, uint64_t i0, OperandType s0, uint64_t i1);
size_t create_scalar_slot3_attr3_num(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2, AttrSrcInfo a0, AttrSrcInfo a1, AttrSrcInfo a2, uint64_t n0);
size_t create_scalar_slot3(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2);
size_t create_scalar_slot2_imm(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0);
size_t create_scalar_slot2_imm_relop(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, RelopType r);
size_t create_scalar_slot3_relop(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2, RelopType r);
size_t create_scalar_slot3_imm(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2, uint64_t i0);
size_t create_scalar_slot2_imm2(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, uint64_t i1);
size_t create_scalar_slot3_imm2(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2, uint64_t i0, uint64_t i1);
size_t create_scalar_slot5_relop(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2, OperandType s3, OperandType s4, RelopType r);
size_t create_scalar_slot2_imm_slot2_relop(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, OperandType s2, OperandType s3, RelopType r);
size_t create_scalar_slot2_imm_slot_imm_relop(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, OperandType s2, uint64_t i1, RelopType r);
size_t create_scalar_slot2_imm2_slot_relop(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, uint64_t i1, OperandType s2, RelopType r);
size_t create_scalar_slot2_imm3_relop(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, uint64_t i1, uint64_t i2, RelopType r);

size_t create_vector_slot2(void *ptr, OHType op, AttrSrcInfo vs, AttrSrcInfo ves, OperandType s0, OperandType s1);
size_t create_vector_slot3(void *ptr, OHType op, AttrSrcInfo vs, AttrSrcInfo ves, OperandType s0, OperandType s1, OperandType s2);
size_t create_vector_slot3_relop(void *ptr, OHType op, AttrSrcInfo vs, AttrSrcInfo ves, OperandType s0, OperandType s1, OperandType s2, uint8_t relop);
size_t create_vector_slot4(void *ptr, OHType op, AttrSrcInfo vs, AttrSrcInfo ves, OperandType s0, OperandType s1, OperandType s2, OperandType s3);
size_t create_vector_slot_vimm(void *ptr, OHType op, AttrSrcInfo vs, AttrSrcInfo ves, OperandType s0, uint64_t vi0);
size_t create_vector_slot2_imm(void *ptr, OHType op, AttrSrcInfo vs, AttrSrcInfo ves, OperandType s0, OperandType s1, uint64_t i0);
size_t create_vector_slot_env_imm(void *ptr, OHType op, AttrSrcInfo vs, AttrSrcInfo ves, OperandType s0, uint64_t i0);
size_t create_vector_slot5_relop(void *ptr, OHType op, AttrSrcInfo vs, AttrSrcInfo ves, OperandType s0, OperandType s1, OperandType s2, OperandType s3, OperandType s4, uint8_t relop);

size_t create_helper_slot2(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1);
size_t create_helper_slot3(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2);
size_t create_helper_slot2_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, uint32_t i0);
size_t create_helper_slot4(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, OperandType s3);
size_t create_helper_slot5(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, OperandType s3, OperandType s4);
size_t create_helper_slot4_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, OperandType s3, uint32_t i0);
size_t create_helper_env_imm2(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, uint32_t i0, uint32_t i1);
size_t create_helper_env_slot3_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, uint32_t i0);
size_t create_helper_env_slot4_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, OperandType s3, uint32_t i0);
size_t create_helper_env_slot4_imm2(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, OperandType s3, uint32_t i0, uint32_t i1);
size_t create_helper_env_slot2_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, uint32_t i0);
size_t create_helper_env_slot2_imm_slot(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, uint32_t i0, OperandType s2);
size_t create_helper_env_slot3(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2);
size_t create_helper_slot3_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, uint32_t i0);
size_t create_helper_slot3_imm2(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, uint32_t i0, uint32_t i1);
size_t create_helper_slot2_imm3(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, uint32_t i0, uint32_t i1, uint32_t i2);
size_t create_helper_slot2_imm2(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, uint32_t i0, uint32_t i1);
size_t create_helper_env(void *ptr, OHType h, uint16_t cflags, uint8_t noargs);
size_t create_helper_env_slot(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0);
size_t create_helper_slot_env(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0);
size_t create_helper_env_slot2(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1);
size_t create_helper_slot_env_slot(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1);
size_t create_helper_env_slot_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, uint32_t i0);
size_t create_helper_env_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, uint32_t i0);
size_t create_helper_env_imm_slot(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, uint32_t i0, OperandType s0);

size_t create_branch_condition(void *ptr, OperandType s0, uint64_t i0, uint8_t relop, uint8_t label);
size_t create_branch_condition_slot(void *ptr, OperandType s0, OperandType s1, uint8_t relop, uint8_t label);
size_t create_slot_imm2(void *ptr, OHType op, OperandType s0, uint64_t i0, uint64_t i1);
size_t create_jmpdirect(void *ptr, uint64_t val);
size_t create_setlabel(void *ptr, OHType op, uint8_t label);
size_t create_br_label(void *ptr, OHType op, uint8_t label);
void *get_instr_buffer();
size_t get_instr_buffer_size();
void reset_instr_buffer(void);
void handle_func(uint64_t val);
void module_prolog(void);
void module_epilog(void);
void insert_instr(void *ptr_src, size_t sz);
uint64_t get_xmm_offset(uint64_t idx);
OperandType get_original_slot_for_debug(OperandType tmp);

typedef LLVMValueRef (*LLVM_BIN_API)(LLVMBuilderRef B, LLVMValueRef LHS, LLVMValueRef RHS, const char *Name);
typedef LLVMValueRef (*LLVM_EXT_API)(LLVMBuilderRef B, LLVMValueRef Val, LLVMTypeRef DestTy, const char *Name);

void translate_add_i64(OpCodeType opc, void *ptr);
void translate_andc_i64(OpCodeType opc, void *ptr);
void translate_andc_vec(OpCodeType opc, void *ptr);
void translate_bswap32_i64(OpCodeType opc, void *ptr);
void translate_clz_i64(OpCodeType opc, void *ptr);
void translate_cmp_vec(OpCodeType opc, void *ptr);
void translate_ctz_i64(OpCodeType opc, void *ptr);
void translate_dupm_vec(OpCodeType opc, void *ptr);
void translate_extract2_i64(OpCodeType opc, void *ptr);
void translate_extract(OpCodeType opc, void *ptr);
void translate_ld_vec(OpCodeType opc, void *ptr);
void translate_negsetcond_i64(OpCodeType opc, void *ptr);
void translate_not(OpCodeType opc, void *ptr);
void translate_push_ret_addr(OpCodeType opc, void *ptr);
void translate_qemu_ld2_i128(OpCodeType opc, void *ptr);
void translate_qemu_ld(OpCodeType opc, void *ptr);
void translate_qemu_st2_i128(OpCodeType opc, void *ptr);
void translate_qemu_st(OpCodeType opc, void *ptr);
void translate_ret(OpCodeType opc, void *ptr);
void translate_rotr(OpCodeType opc, void *ptr);
void translate_rotl(OpCodeType opc, void *ptr);
void translate_setcond_i64(OpCodeType opc, void *ptr);
void translate_sextract_i64(OpCodeType opc, void *ptr);
void translate_st(OpCodeType opc, void *ptr);
void translate_bswap64_i64(OpCodeType opc, void *ptr);
void translate_set_label(OpCodeType opc, void *ptr);
void translate_brcond_i64(OpCodeType opc, void *ptr);
void translate_jmp_direct(OpCodeType opc, void *ptr);
void translate_discard(OpCodeType opc, void *ptr);
void translate_tail_call(OpCodeType opc, void *ptr);
void translate_dump_call(OpCodeType opc, void *ptr, uint32_t is_dump_registers);
void translate_call(OpCodeType opc, void *ptr);
void translate_ld_env_xmm(OpCodeType opc, void *ptr);
void translate_movcond(OpCodeType opc, void *ptr);
void translate_mulxh(OpCodeType opc, void *ptr, LLVM_EXT_API api);
void translate_binary(OpCodeType opc, void *ptr, LLVM_BIN_API api);
void translate_binary_splat_immediate(OpCodeType opc, void *ptr, LLVM_BIN_API api);

#endif
