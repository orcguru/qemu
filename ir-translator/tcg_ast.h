#ifndef TCG_AST_H
#define TCG_AST_H

typedef enum {
  OP_MOV_REG,
  OP_MOV_IMM,
  OP_BIN_OP,
  OP_JMP_DIRECT,
  OP_DISCARD,
  OP_SUB,
  OP_FUNC
} TcgOpType;

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
            unsigned long label;
            struct TcgAst *instructions;
        } func;
        struct {
            char *dest;
            char *imm;
        } mov_imm;
        struct {
            char *reg;
        } discard;
        struct {
            char *dest;
            char *src;
        } mov_reg;
        struct {
            TcgOpType op;
            char *dest, *src1, *src2;
        } bin_op;
        struct {
            char *target;
        } jmp;
    } data;
  struct TcgAst *next;
} TcgAst;

TcgAst *merge_func(TcgAst *funcs, TcgAst *func);
TcgAst *create_func(long long val, TcgAst *instructions);
void create_program(TcgAst *funcs);

#endif
