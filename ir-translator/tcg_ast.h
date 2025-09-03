#ifndef TCG_AST_H
#define TCG_AST_H

#include <stddef.h>

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

#define ENVVAR_TYPE_LIST \
    X(cc_src2) \
    X(es_base) \
    X(cs_base) \
    X(ss_base) \
    X(ds_base) \
    X(fs_base) \
    X(gs_base) \
    X(ENVVarMAX)

typedef enum {
    #define X(name) name,
    ENVVAR_TYPE_LIST
    #undef X
} EnvVarType;

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

typedef enum {
    #define X(name) name,
    XREG_TYPE_LIST
    #undef X
} XRegType;

#define RELOP_TYPE_LIST \
    X(eq) \
    X(sge) \
    X(sgt) \
    X(sle) \
    X(slt) \
    X(uge) \
    X(ugt) \
    X(ule) \
    X(ult) \
    X(ne) \
    X(leu) \
    X(gt) \
    X(lt) \
    X(tsteq) \
    X(tstne)

typedef enum {
    #define X(name) name,
    RELOP_TYPE_LIST
    #undef X
} RelopType;

#define HELPER_LIST \
    X(aad) \
    X(aam) \
    X(call_ind) \
    X(cc_compute_all) \
    X(cc_compute_c) \
    X(cc_compute_nz) \
    X(cpuid) \
    X(divl_EAX) \
    X(divq_EAX) \
    X(divss) \
    X(emms) \
    X(enter_mmx) \
    X(fabs_ST0) \
    X(fadd_ST0_FT0) \
    X(fildl_FT0) \
    X(fldenv) \
    X(fldl_FT0) \
    X(flds_FT0) \
    X(fldt_ST0) \
    X(fmov_FT0_STN) \
    X(fmov_ST0_STN) \
    X(fmov_STN_ST0) \
    X(fnstcw) \
    X(fnstsw) \
    X(fpop) \
    X(fpush) \
    X(frstor) \
    X(fstenv) \
    X(fstt_ST0) \
    X(fsub_ST0_FT0) \
    X(fucomi_ST0_FT0) \
    X(fwait) \
    X(fxam_ST0) \
    X(fxchg_ST0_STN) \
    X(fxrstor) \
    X(fxsave) \
    X(icebp) \
    X(idivl_EAX) \
    X(idivq_EAX) \
    X(iret_ind) \
    X(iret_protected) \
    X(jmp_ind) \
    X(ljmp_protected) \
    X(load_seg) \
    X(lret_protected) \
    X(helper_memset) \
    X(movmskpd_xmm) \
    X(movmskps_xmm) \
    X(palignr_xmm) \
    X(helper_pause) \
    X(pcmpistri_xmm) \
    X(pshufb_xmm) \
    X(pshufd_xmm) \
    X(pslldq_xmm) \
    X(psrldq_xmm) \
    X(punpckhdq_xmm) \
    X(punpckhqdq_xmm) \
    X(punpcklbw_xmm) \
    X(punpckldq_mmx) \
    X(punpckldq_xmm) \
    X(punpcklqdq_xmm) \
    X(punpcklwd_mmx) \
    X(punpcklwd_xmm) \
    X(raise_exception) \
    X(raise_interrupt) \
    X(rdtsc) \
    X(shufpd_xmm) \
    X(shufps_xmm) \
    X(helper_syscall) \
    X(ucomisd) \
    X(update_mxcsr) \
    X(xgetbv) \
    X(xrstor) \
    X(xsave)

typedef enum {
    #define X(name) name,
    HELPER_LIST
    #undef X
} HelperType;

#define OPCODE_TYPE_LIST \
    X(add_i64) \
    X(add_vec) \
    X(andc_i64) \
    X(andc_vec) \
    X(and_i64) \
    X(and_vec) \
    X(bswap32_i64) \
    X(clz_i64) \
    X(cmp_vec) \
    X(ctz_i64) \
    X(deposit_i32) \
    X(deposit_i64) \
    X(dupm_vec) \
    X(extract2_i64) \
    X(extract_i32) \
    X(extract_i64) \
    X(extrl_i64_i32) \
    X(extu_i32_i64) \
    X(ld32s_i64) \
    X(ld32u_i64) \
    X(ld8u_i64) \
    X(ld_i32) \
    X(ld_i64) \
    X(ld_vec) \
    X(movcond_i32) \
    X(movcond_i64) \
    X(mov_i32) \
    X(mov_i64) \
    X(mov_i64_const) \
    X(mov_vec) \
    X(mul_i32) \
    X(mul_i64) \
    X(mulsh_i64) \
    X(muluh_i64) \
    X(neg_i32) \
    X(neg_i64) \
    X(negsetcond_i64) \
    X(not_i64) \
    X(or_i64) \
    X(or_vec) \
    X(push_ret_addr) \
    X(qemu_ld2_i128) \
    X(qemu_ld_i32) \
    X(qemu_ld_i64) \
    X(qemu_st2_i128) \
    X(qemu_st_i32) \
    X(qemu_st_i64) \
    X(ret) \
    X(rotr_i32) \
    X(rotr_i64) \
    X(sar_i64) \
    X(setcond_i64) \
    X(sextract_i64) \
    X(shl_i64) \
    X(shli_vec) \
    X(shr_i64) \
    X(st16_i32) \
    X(st16_i64) \
    X(st32_i64) \
    X(st_i32) \
    X(st_i64) \
    X(st_vec) \
    X(sub_i64) \
    X(sub_vec) \
    X(umax_vec) \
    X(umin_vec) \
    X(xor_i64) \
    X(xor_vec) \
    X(bswap64_i64) \
    X(set_label) \
    X(brcond_i64) \
    X(jmp_direct) \
    X(call_direct) \
    X(discard) \
    X(call) \
    X(OPCODE_MAX)

typedef enum {
    #define X(name) name,
    OPCODE_TYPE_LIST
    #undef X
} OpCodeType;

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
    X(SUB_SLOT_TMPL) \
    X(SUB_SLOT_TMPT) \
    X(SUB_SLOT_XMM) \
    X(SUB_SLOT_ENV)

typedef enum {
    #define X(name) name,
    SLOT_TYPE_LIST
    #undef X
} SlotType;

typedef struct {
    SlotType subt;
    union {
        EnvVarType env;
        XRegType x;
        uint8_t idx;
    } p;
} SlotInfo;

#define XMM_REG_LIST \
    X(XMM0) \
    X(YMM0_H) \
    X(XMM1) \
    X(YMM1_H) \
    X(XMM2) \
    X(YMM2_H) \
    X(XMM3) \
    X(YMM3_H) \
    X(XMM4) \
    X(YMM4_H) \
    X(XMM5) \
    X(YMM5_H) \
    X(XMM6) \
    X(YMM6_H) \
    X(XMM7) \
    X(YMM7_H) \
    X(XMM8) \
    X(YMM8_H) \
    X(XMM9) \
    X(YMM9_H) \
    X(XMM10) \
    X(YMM10_H) \
    X(XMM11) \
    X(YMM11_H) \
    X(XMM12) \
    X(YMM12_H) \
    X(XMM13) \
    X(YMM13_H) \
    X(XMM14) \
    X(YMM14_H) \
    X(XMM15) \
    X(YMM15_H) \
    X(XMMT) \
    X(YMMT_H) \
    X(NON_XMM)

typedef enum {
    #define X(name) name,
    XMM_REG_LIST
    #undef X
} XMMRegType;

typedef struct {
    uint16_t xmm_idx    :6;
    uint16_t xmm_offset :4;
} XMMReg;

#define INSTR_TYPE_LIST \
    X(SIZE2B) \
    X(SIZE4B) \
    X(SIZE6B) \
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
    X(Instr1B4_ext) \
    X(Instr1BV4X_ext) \
    X(Instr1B41I2_ext) \
    X(Instr1B4X_ext) \
    X(Instr1B22_ext) \
    X(Instr1B21_ext) \
    X(Instr1B2_ext) \
    X(Instr1BH4_ext) \
    X(Instr1BV4_ext) \
    X(Instr1BH141_ext) \
    X(Instr1BV21_ext) \
    X(Instr1B41_ext) \
    X(Instr1BV4I_ext) \
    X(Instr1B24_ext) \
    X(Instr1BV4S2_ext) \
    X(Instr1BV41_ext) \
    X(Instr1BH24I_ext) \
    X(Instr1B2S_ext) \
    X(Instr1B41I_ext) \
    X(Instr1BV48_ext) \
    X(Instr1B422_ext) \
    X(Instr1B411_ext) \
    X(Instr1B142_ext) \
    X(Instr1B142E_ext) \
    X(Instr1BH21_ext) \
    X(Instr1B4111_ext) \
    X(Instr1B8_ext) \
    X(Instr1BH4I_ext) \
    X(Instr1B42_ext) \
    X(Instr1BH2_ext) \
    X(Instr1BH21S_ext) \
    X(Instr1B281_ext) \
    X(Instr1BH4S3_ext) \
    X(Instr1B4112_ext) \
    X(Instr1BH412_ext) \
    X(Instr1BH41_ext) \
    X(Instr1B41R_ext) \
    X(Instr1BH24_ext) \
    X(Instr1BH211_ext) \
    X(Instr1B1111_ext) \
    X(Instr1BH4S_ext)

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
    X(LLVMVector16xi8) \
    X(LLVMVector8xi16) \
    X(LLVMVector4xi32) \
    X(LLVMVector2xi64) \
    X(LLVMMAXType)

typedef enum {
    #define X(name) name,
    LLVM_TYPE_LIST
    #undef X
} LLVMType;

/// NOTICE: all immediate fields with signed type are signed-ext,
/// otherwise zero-ext.
typedef struct __attribute__((packed)) {
    uint16_t instr_type   :2;
    uint16_t opc          :7;
    uint16_t imm          :7;
} Instr2B;

typedef struct __attribute__((packed)) {
    uint16_t instr_type   :2;
    uint16_t opc          :7;
    uint16_t slot0_type   :2;
    uint16_t slot0_idx    :5;
    int32_t imm;
} Instr2B4;

typedef struct __attribute__((packed)) {
    uint32_t instr_type :2;
    uint32_t opc        :7;
    uint32_t slot0_type :2;
    uint32_t slot0_idx  :5;
    uint32_t slot1_type :2;
    uint32_t slot1_idx  :5;
    uint32_t attr_type  :2;
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
    uint32_t attr_val   :7;
} Instr4B;

#include "instr_def.h"

typedef struct {
    uint16_t valid     :1;
    uint16_t slot_type :3;
    uint16_t slot_idx  :6;
    uint16_t offset;
} SlotT;

typedef union {
    uint64_t i;
    SlotT s;
} OperandType;

typedef struct {
    uint8_t attr_type  :2;
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
    uint8_t attr_val   :7;
} AttributeType;

typedef struct TcgAst {
    TcgOpType type;
    union {
        struct {
            struct TcgAst *instructions;
            uint32_t label;
            uint32_t gpr_bits;
            uint32_t vec_bits;
            uint32_t loc_bits;
            uint32_t tmp_bits;
        } func;
        SlotInfo slot;
        RelopType relop;
        OpCodeType op;
    } data;
    struct TcgAst *next;
} TcgAst;

#ifdef __GNUC__
#define likely(x)    __builtin_expect(!!(x), 1)  // True with high probability
#define unlikely(x)  __builtin_expect(!!(x), 0)  // False with high probability
#else
#define likely(x)    (x)  // Fallback for non-GCC compilers
#define unlikely(x)  (x)
#endif

void register_xmm(uint64_t idx, uint64_t offset);
void register_xmm_tmp(uint64_t offset);

void create_scalar_slot(OpCodeType op, SlotInfo s0);
void create_scalar_slot2(OpCodeType op, SlotInfo s0, SlotInfo s1);
void create_scalar_slot2_attr(OpCodeType op, SlotInfo s0, SlotInfo s1, AttrSrcInfo a0);
void create_scalar_slot2_attr2(OpCodeType op, SlotInfo s0, SlotInfo s1, AttrSrcInfo a0, AttrSrcInfo a1);
void create_scalar_slot_imm(OpCodeType op, SlotInfo s0, uint64_t i0);
void create_scalar_slot_imm_slot(OpCodeType op, SlotInfo s0, uint64_t i0, SlotInfo s1);
void create_scalar_slot_env_imm(OpCodeType op, SlotInfo s0, uint64_t i0);
void create_scalar_slot2_attr3_num(OpCodeType op, SlotInfo s0, SlotInfo s1, AttrSrcInfo a0, AttrSrcInfo a1, AttrSrcInfo a2, uint64_t n0);
void create_scalar_imm_env_imm(OpCodeType op, uint64_t i0, uint64_t i1);
void create_scalar_imm_slot_imm(OpCodeType op, uint64_t i0, SlotInfo s0, uint64_t i1);
void create_scalar_slot3_attr3_num(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2, AttrSrcInfo a0, AttrSrcInfo a1, AttrSrcInfo a2, uint64_t n0);
void create_scalar_slot3(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2);
void create_scalar_slot2_imm(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0);
void create_scalar_slot2_imm_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0, RelopType r);
void create_scalar_slot3_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2, RelopType r);
void create_scalar_slot3_imm(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2, uint64_t i0);
void create_scalar_slot2_imm2(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0, uint64_t i1);
void create_scalar_slot3_imm2(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2, uint64_t i0, uint64_t i1);
void create_scalar_slot5_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2, SlotInfo s3, SlotInfo s4, RelopType r);
void create_scalar_slot2_imm_slot2_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0, SlotInfo s2, SlotInfo s3, RelopType r);
void create_scalar_slot2_imm_slot_imm_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0, SlotInfo s2, uint64_t i1, RelopType r);
void create_scalar_slot2_imm2_slot_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0, uint64_t i1, SlotInfo s2, RelopType r);
void create_discard(SlotInfo s0);

void create_vector_slot2(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, SlotInfo s1);
void create_vector_slot3(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, SlotInfo s1, SlotInfo s2);
void create_vector_slot3_relop(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, SlotInfo s1, SlotInfo s2, uint8_t relop);
void create_vector_slot_vimm(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, uint64_t vi0);
void create_vector_slot2_imm(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, SlotInfo s1, uint64_t i0);
void create_vector_slot2_vimm(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, SlotInfo s1, uint64_t vi0);
void create_vector_slot_env_imm(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, uint64_t i0);

void create_helper_slot3(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, SlotInfo s2);
void create_helper_slot2_imm(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, uint32_t i0);
void create_helper_slot4(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, SlotInfo s2, SlotInfo s3);
void create_helper_slot5(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, SlotInfo s2, SlotInfo s3, SlotInfo s4);
void create_helper_env_imm2(HelperType h, uint16_t cflags, uint8_t noargs, uint32_t i0, uint32_t i1);
void create_helper_env_slot3_imm(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, SlotInfo s2, uint32_t i0);
void create_helper_slot2_imm2(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, uint32_t i0, uint32_t i1);
void create_helper_env(HelperType h, uint16_t cflags, uint8_t noargs);
void create_helper_env_slot(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0);
void create_helper_env_slot2(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1);
void create_helper_env_slot_imm(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, uint32_t i0);
void create_helper_env_imm(HelperType h, uint16_t cflags, uint8_t noargs, uint32_t i0);
void create_helper_env_imm_slot(HelperType h, uint16_t cflags, uint8_t noargs, uint32_t i0, SlotInfo s0);

void create_branch_condition(SlotInfo s0, uint64_t i0, uint8_t relop, uint8_t label);
void create_calldirect(SlotInfo s0, uint64_t i0, uint64_t i1);
void create_jmpdirect(uint64_t val);
void create_setlabel(OpCodeType op, uint8_t label);
void *get_instr_buffer();
size_t get_instr_buffer_size();
void reset_instr_buffer(void);
void handle_func(uint64_t val);
void module_prolog(void);
void module_epilog(void);

#endif
