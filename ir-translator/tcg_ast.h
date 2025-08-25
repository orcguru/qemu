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
  SUB_ATTR_ATOMIC,
  SUB_ATTR_ALIGNMENT,
  SUB_ATTR_SRCSIZEEXT,
  SUB_ATTR_ELEMENTSIZE,
  SUB_ATTR_OZ,
  SUB_ATTR_IZ,
} TcgSubType;

typedef struct {
  char *dest;
  char *src;
} MovReg;

typedef struct {
  char *dest;
  char *imm;
} MovImm;

typedef struct {
  TcgOpType op;
  char *dest, *src1, *src2;
} BinOp;

typedef struct {
  char *target;
} JmpDirect;

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
    } data;
  struct TcgAst *next;
} TcgAst;

TcgAst *merge_ast(TcgAst *list, TcgAst *elem);
TcgAst *create_func(uint64_t val, TcgAst *instructions);
void create_program(TcgAst *funcs);
TcgAst *create_attr_elementsize(uint32_t es);
TcgAst *create_branch_condition(TcgAst *s0, uint64_t i0, uint8_t relop, uint8_t label);
TcgAst *create_bswap_attr(uint8_t val);
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
TcgAst *create_scalar_imm_env_imm(uint8_t opc, uint64_t i0, uint64_t i1);
TcgAst *create_scalar_imm_slot_imm(uint8_t opc, uint64_t i0, TcgAst *s0, uint64_t i1);
TcgAst *create_scalar_slot(uint8_t opc, TcgAst *s0);
TcgAst *create_scalar_slot2(uint8_t opc, TcgAst *s0, TcgAst *s1);
TcgAst *create_scalar_slot2_attr(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *a0);
TcgAst *create_scalar_slot2_attr2(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *a0, TcgAst *a1);
TcgAst *create_scalar_slot2_attr_num(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *a0, uint64_t n0);
TcgAst *create_scalar_slot2_info(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2);
TcgAst *create_scalar_slot2_info2(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3);
TcgAst *create_scalar_slot2_info3(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3, TcgAst *s4);
TcgAst *create_scalar_slot2_info3_relop(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3, TcgAst *s4, uint8_t relop);
TcgAst *create_scalar_slot2_info_attr_num(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *a0, uint64_t n0);
TcgAst *create_scalar_slot2_info_relop(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint8_t relop);
TcgAst *create_scalar_slot_env_imm(uint8_t opc, TcgAst *s0, uint64_t i0);
TcgAst *create_scalar_slot_imm(uint8_t opc, TcgAst *s0, uint64_t i0);
TcgAst *create_scalar_slot_imm_slot(uint8_t opc, TcgAst *s0, uint64_t i0, TcgAst *s1);
TcgAst *create_setlabel(uint8_t label);
TcgAst *create_slot_envvar(uint8_t ei);
TcgAst *create_slot_tmpl(uint8_t ti);
TcgAst *create_slot_tmpt(uint8_t ti);
TcgAst *create_slot_xreg(uint8_t ri);
TcgAst *create_storage_attr(uint8_t ai0, uint8_t ai1, uint8_t ai2);
TcgAst *create_vector_slot2(uint8_t opc, TcgAst *es, TcgAst *s0, TcgAst *s1);
TcgAst *create_vector_slot2_imm(uint8_t opc, TcgAst *es, TcgAst *s0, TcgAst *s1, uint64_t i0);
TcgAst *create_vector_slot2_vimm(uint8_t opc, TcgAst *es, TcgAst *s0, TcgAst *s1, uint64_t vi0);
TcgAst *create_vector_slot3(uint8_t opc, TcgAst *es, TcgAst *s0, TcgAst *s1, TcgAst *s2);
TcgAst *create_vector_slot3_relop(uint8_t opc, TcgAst *es, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint8_t relop);
TcgAst *create_vector_slot_env_imm(uint8_t opc, TcgAst *es, TcgAst *s0, uint64_t i0);
TcgAst *create_vector_slot_vimm(uint8_t opc, TcgAst *es, TcgAst *s0, uint64_t vi0);
TcgAst *expand_branch_condition(TcgAst *s0, uint64_t i0, uint8_t relop, uint8_t label);
TcgAst *expand_scalar_slot2_info3_relop(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3, TcgAst *s4, uint8_t relop);
TcgAst *expand_scalar_slot2_info_relop(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint8_t relop);

#endif
