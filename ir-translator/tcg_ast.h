#ifndef TCG_AST_H
#define TCG_AST_H

typedef unsigned char uint8_t;
typedef unsigned short uint16_t;
typedef unsigned int uint32_t;
typedef unsigned long uint64_t;

typedef enum {
    OP_FUNC,
    OP_INST,
    OP_OPC,
    OP_SLOT,
    OP_IMM,
    OP_REL,
    OP_ATTR,
} TcgOpType;

typedef enum {
    SUB_OPC_SCALAR,
    SUB_OPC_VECTOR,
    SUB_OPC_HELPER,
    SUB_OPC_BRANCH,
    SUB_SLOT_ENVVAR,
    SUB_SLOT_XREG,
    SUB_SLOT_TMPL,
    SUB_SLOT_TMPT,
    SUB_ATTR_STORAGE,
    SUB_ATTR_ATOMIC,
    SUB_ATTR_ALIGNMENT,
    SUB_ATTR_SRCSIZEEXT,
    SUB_ATTR_ELEMENTSIZE,
    SUB_ATTR_SWAP,
} TcgSubType;

typedef enum {
    cc_src2,
    es_base,
    cs_base,
    ss_base,
    ds_base,
    fs_base,
    gs_base,
} EnvVarType;

typedef enum {
    rax = 0,
    rcx,
    rdx,
    rbx,
    rsp,
    rbp,
    rsi,
    rdi,
    r8,
    r9,
    r10,
    r11,
    r12,
    r13,
    r14,
    r15,
    cc_src,
    cc_dst,
    cc_op,
    rip,
} XRegType;

typedef enum {
    eq,
    sge,
    sgt,
    sle,
    slt,
    uge,
    ugt,
    ule,
    ult,
    ne,
    leu,
    gt,
    lt,
    tsteq,
    tstne,
} RelopType;

typedef enum {
    add_i64,
    add_vec,
    andc_i64,
    andc_vec,
    and_i64,
    and_vec,
    bswap32_i64,
    clz_i64,
    cmp_vec,
    ctz_i64,
    deposit_i32,
    deposit_i64,
    dupm_vec,
    extract2_i64,
    extract_i32,
    extract_i64,
    extrl_i64_i32,
    extu_i32_i64,
    ld32s_i64,
    ld32u_i64,
    ld8u_i64,
    ld_i32,
    ld_i64,
    ld_vec,
    movcond_i32,
    movcond_i64,
    mov_i32,
    mov_i64,
    mov_i64_const,
    mov_vec,
    mul_i32,
    mul_i64,
    mulsh_i64,
    muluh_i64,
    neg_i32,
    neg_i64,
    negsetcond_i64,
    not_i64,
    or_i64,
    or_vec,
    push_ret_addr,
    qemu_ld2_i128,
    qemu_ld_i32,
    qemu_ld_i64,
    qemu_st2_i128,
    qemu_st_i32,
    qemu_st_i64,
    ret,
    rotr_i32,
    rotr_i64,
    sar_i64,
    setcond_i64,
    sextract_i64,
    shl_i64,
    shli_vec,
    shr_i64,
    st16_i32,
    st16_i64,
    st32_i64,
    st_i32,
    st_i64,
    st_vec,
    sub_i64,
    sub_vec,
    umax_vec,
    umin_vec,
    xor_i64,
    xor_vec,
    bswap64_i64,
    set_label,
    brcond_i64,
    jmp_direct,
    call_direct,
    discard,
    call,
} OpCodeType;

typedef enum {
    UNALIGN,
    ALIGN_MEM_SIZE,
    ALIGN_16,
    ALIGN_32,
} AlignmentType;

typedef enum {
    NONATOMIC,
} AtomicType;

typedef enum {
    SIGN,
    ZERO,
} SrcExtType;

typedef enum {
    IZ = (1 << 0),
    OZ = (1 << 1),
    IS = (1 << 2),
    OS = (1 << 3),
} SwapAttrType;

typedef struct {
    TcgSubType subt;
    union {
        uint8_t ui8;
        uint16_t ui16;
        uint32_t ui32;
        struct {
            union {
                AtomicType atomic;
                AlignmentType alignment;
                SrcExtType ext;
            } attr;
            uint8_t ui8;
        } storage;
        SwapAttrType swap;
    } p;
} AttrInfo;

typedef struct {
    TcgSubType subt;
    union {
        EnvVarType env;
        XRegType x;
        uint8_t idx;
    } p;
} SlotInfo;

typedef struct TcgAst {
    TcgOpType type;
    union {
        struct {
            struct TcgAst *instructions;
            unsigned int label;
            unsigned int gpr_bits;
            unsigned int vec_bits;
            unsigned int loc_bits;
            unsigned int tmp_bits;
        } func;
        AttrInfo attr;
        SlotInfo slot;
        RelopType relop;
        OpCodeType op;
        uint64_t imm;
    } data;
    struct TcgAst *next;
} TcgAst;

TcgAst *merge_ast(TcgAst *list, TcgAst *elem);
TcgAst *create_func(uint64_t val, TcgAst *instructions);
void create_program(TcgAst *funcs);
TcgAst *create_attr_elementsize(uint8_t es);
TcgAst *create_branch_condition(TcgAst *s0, uint64_t i0, uint8_t relop, uint8_t label);
TcgAst *create_bswap_attr(AttrInfo ai);
TcgAst *create_calldirect(TcgAst *s0, uint64_t i0, uint64_t i1);
TcgAst *create_discard(TcgAst *s0);
TcgAst *create_helper_env(const char *h, uint16_t cflags, uint8_t noargs);
TcgAst *create_helper_env_imm(const char *h, uint16_t cflags, uint8_t noargs, uint64_t i0);
TcgAst *create_helper_env_imm2(const char *h, uint16_t cflags, uint8_t noargs, uint64_t i0, uint64_t i1);
TcgAst *create_helper_env_imm_slot(const char *h, uint16_t cflags, uint8_t noargs, uint64_t i0, TcgAst *s0);
TcgAst *create_helper_env_slot(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0);
TcgAst *create_helper_env_slot2(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1);
TcgAst *create_helper_env_slot2_imm(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, uint64_t i0);
TcgAst *create_helper_env_slot3(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2);
TcgAst *create_helper_env_slot3_imm(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint64_t i0);
TcgAst *create_helper_env_slot_imm(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, uint64_t i0);
TcgAst *create_helper_slot2_imm(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, uint64_t i0);
TcgAst *create_helper_slot2_imm2(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, uint64_t i0, uint64_t i1);
TcgAst *create_helper_slot3(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2);
TcgAst *create_helper_slot3_imm(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint64_t i0);
TcgAst *create_helper_slot4(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3);
TcgAst *create_helper_slot5(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3, TcgAst *s4);
TcgAst *create_helper_slot_env(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0);
TcgAst *create_helper_slot_env_slot(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1);
TcgAst *create_imm(uint64_t val);
TcgAst *create_jmpdirect(uint64_t val);
TcgAst *create_scalar_imm_env_imm(OpCodeType op, uint64_t i0, uint64_t i1);
TcgAst *create_scalar_imm_slot_imm(OpCodeType op, uint64_t i0, TcgAst *s0, uint64_t i1);
TcgAst *create_scalar_slot(OpCodeType op, TcgAst *s0);
TcgAst *create_scalar_slot2(OpCodeType op, TcgAst *s0, TcgAst *s1);
TcgAst *create_scalar_slot2_attr(OpCodeType op, TcgAst *s0, TcgAst *s1, TcgAst *a0);
TcgAst *create_scalar_slot2_attr2(OpCodeType op, TcgAst *s0, TcgAst *s1, TcgAst *a0, TcgAst *a1);
TcgAst *create_scalar_slot2_attr_num(OpCodeType op, TcgAst *s0, TcgAst *s1, TcgAst *a0, uint64_t n0);
TcgAst *create_scalar_slot2_info(OpCodeType op, TcgAst *s0, TcgAst *s1, TcgAst *s2);
TcgAst *create_scalar_slot2_info2(OpCodeType op, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3);
TcgAst *create_scalar_slot2_info3(OpCodeType op, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3, TcgAst *s4);
TcgAst *create_scalar_slot2_info3_relop(OpCodeType op, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3, TcgAst *s4, uint8_t relop);
TcgAst *create_scalar_slot2_info_attr_num(OpCodeType op, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *a0, uint64_t n0);
TcgAst *create_scalar_slot2_info_relop(OpCodeType op, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint8_t relop);
TcgAst *create_scalar_slot_env_imm(OpCodeType op, TcgAst *s0, uint64_t i0);
TcgAst *create_scalar_slot_imm(OpCodeType op, TcgAst *s0, uint64_t i0);
TcgAst *create_scalar_slot_imm_slot(OpCodeType op, TcgAst *s0, uint64_t i0, TcgAst *s1);
TcgAst *create_setlabel(OpCodeType op, uint8_t label);
TcgAst *create_slot_envvar(SlotInfo si);
TcgAst *create_slot_tmpl(SlotInfo si);
TcgAst *create_slot_tmpt(SlotInfo si);
TcgAst *create_slot_xreg(SlotInfo si);
TcgAst *create_storage_attr(AttrInfo ai0, AttrInfo ai1, AttrInfo ai2);
TcgAst *create_vector_slot2(OpCodeType op, TcgAst *es, TcgAst *s0, TcgAst *s1);
TcgAst *create_vector_slot2_imm(OpCodeType op, TcgAst *es, TcgAst *s0, TcgAst *s1, uint64_t i0);
TcgAst *create_vector_slot2_vimm(OpCodeType op, TcgAst *es, TcgAst *s0, TcgAst *s1, uint64_t vi0);
TcgAst *create_vector_slot3(OpCodeType op, TcgAst *es, TcgAst *s0, TcgAst *s1, TcgAst *s2);
TcgAst *create_vector_slot3_relop(OpCodeType op, TcgAst *es, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint8_t relop);
TcgAst *create_vector_slot_env_imm(OpCodeType op, TcgAst *es, TcgAst *s0, uint64_t i0);
TcgAst *create_vector_slot_vimm(OpCodeType op, TcgAst *es, TcgAst *s0, uint64_t vi0);
TcgAst *expand_branch_condition(TcgAst *s0, uint64_t i0, uint8_t relop, uint8_t label);
TcgAst *expand_scalar_slot2_info3_relop(OpCodeType op, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3, TcgAst *s4, uint8_t relop);
TcgAst *expand_scalar_slot2_info_relop(OpCodeType op, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint8_t relop);

#endif
