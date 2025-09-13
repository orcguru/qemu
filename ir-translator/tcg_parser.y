

%union {
  char* str;
  uint64_t val;
  AttrSrcInfo ai;
  OperandType si;
  RelopType r;
  HelperType h;
  OpCodeType op;
}

%{
#ifndef YYSTYPE
#define YYSTYPE union YYSTYPE
#include "tcg_lexer.yy.h"
#endif
%}

%code requires {
  typedef struct TcgContext TcgContext;
  typedef void* yyscan_t;
#include "tcg_ast.h"
}

%code {
  extern int yylex(YYSTYPE *, yyscan_t);
}

%define parse.error verbose
%define api.pure full
%parse-param { yyscan_t scanner }
%parse-param { TcgContext *ctx }
%lex-param { yyscan_t scanner }

%{
#include "tcg_context.h"
#include <stdio.h>
void yyerror(yyscan_t scanner, TcgContext *ctx, const char *s);
extern int column;
extern char *lineptr;
extern uint8_t instr_buf[64];
#define YYERROR_VERBOSE 1
%}

%token <h> HELPER
%token <val> NUM IMMX IMMD E8 E16 E32 E64 LABEL XMMVAR
%token <ai> MEMATTR SWAPATTR ELEMENTSIZEATTR
%token <si> SLOT
%token <r> RELOP TSTREL
%token <op> OPCODE BSWAP64 SETLABL BRCOND CALL JMPDIR CALLDIR DISCARD
%token COMMA COLON PLUS ENV V128 XMMTMP

%%
top: xmm_def_list program;

xmm_def_list: xmm_def
| xmm_def_list xmm_def;

xmm_def:
XMMVAR COLON IMMX     { register_xmm($1, $3); }
| XMMTMP COLON IMMX   { register_xmm_tmp($3); };

program: func_list;

func_list: func
| func_list func;

func: IMMX COLON instruction_list { handle_func($1); };

instruction_list: instruction
| instruction_list instruction;

instruction:
scalar
| vector
| call_helper
| branch;

scalar:
OPCODE SLOT                                                             { insert_instr(instr_buf, create_scalar_slot(instr_buf, $1, $2)); }
| OPCODE SLOT COMMA SLOT                                                { insert_instr(instr_buf, create_scalar_slot2(instr_buf, $1, $2, $4)); }
| BSWAP64 SLOT COMMA SLOT COMMA                                         { insert_instr(instr_buf, create_scalar_slot2(instr_buf, $1, $2, $4)); }
| OPCODE SLOT COMMA SLOT COMMA SWAPATTR                                 { insert_instr(instr_buf, create_scalar_slot2_attr(instr_buf, $1, $2, $4, $6)); }
| OPCODE SLOT COMMA SLOT COMMA SWAPATTR COMMA SWAPATTR                  { insert_instr(instr_buf, create_scalar_slot2_attr2(instr_buf, $1, $2, $4, $6, $8)); }
| OPCODE SLOT COMMA IMMX                                                { insert_instr(instr_buf, create_scalar_slot_imm(instr_buf, $1, $2, $4)); }
| OPCODE SLOT COMMA IMMX COMMA SLOT                                     { insert_instr(instr_buf, create_scalar_slot_imm_slot(instr_buf, $1, $2, $4, $6)); }
| OPCODE SLOT COMMA ENV COMMA IMMX                                      { insert_instr(instr_buf, create_scalar_slot_env_imm(instr_buf, $1, $2, $6)); }
| OPCODE SLOT COMMA SLOT COMMA MEMATTR PLUS MEMATTR PLUS MEMATTR COMMA NUM                      { insert_instr(instr_buf, create_scalar_slot2_attr3_num(instr_buf, $1, $2, $4, $6, $8, $10, $12)); }
| OPCODE IMMX COMMA ENV COMMA IMMX                                      { insert_instr(instr_buf, create_scalar_imm_env_imm(instr_buf, $1, $2, $6)); }
| OPCODE IMMX COMMA SLOT COMMA IMMX                                     { insert_instr(instr_buf, create_scalar_imm_slot_imm(instr_buf, $1, $2, $4, $6)); }
| OPCODE SLOT COMMA SLOT COMMA SLOT COMMA MEMATTR PLUS MEMATTR PLUS MEMATTR COMMA NUM           { insert_instr(instr_buf, create_scalar_slot3_attr3_num(instr_buf, $1, $2, $4, $6, $8, $10, $12, $14)); }
| OPCODE SLOT COMMA SLOT COMMA SLOT                                     { insert_instr(instr_buf, create_scalar_slot3(instr_buf, $1, $2, $4, $6)); }
| OPCODE SLOT COMMA SLOT COMMA IMMX                                     { insert_instr(instr_buf, create_scalar_slot2_imm(instr_buf, $1, $2, $4, $6)); }
| OPCODE SLOT COMMA SLOT COMMA IMMX COMMA RELOP                         { insert_instr(instr_buf, create_scalar_slot2_imm_relop(instr_buf, $1, $2, $4, $6, $8)); }
| OPCODE SLOT COMMA SLOT COMMA SLOT COMMA TSTREL                        { insert_instr(instr_buf, create_scalar_slot3_relop(instr_buf, $1, $2, $4, $6, $8)); }
| OPCODE SLOT COMMA SLOT COMMA IMMX COMMA TSTREL                        { insert_instr(instr_buf, create_scalar_slot2_imm_relop(instr_buf, $1, $2, $4, $6, $8)); }
| OPCODE SLOT COMMA SLOT COMMA SLOT COMMA IMMX                          { insert_instr(instr_buf, create_scalar_slot3_imm(instr_buf, $1, $2, $4, $6, $8)); }
| OPCODE SLOT COMMA SLOT COMMA IMMX COMMA IMMX                          { insert_instr(instr_buf, create_scalar_slot2_imm2(instr_buf, $1, $2, $4, $6, $8)); }
| OPCODE SLOT COMMA SLOT COMMA SLOT COMMA IMMX COMMA IMMX               { insert_instr(instr_buf, create_scalar_slot3_imm2(instr_buf, $1, $2, $4, $6, $8, $10)); }
| OPCODE SLOT COMMA SLOT COMMA SLOT COMMA SLOT COMMA SLOT COMMA RELOP               { insert_instr(instr_buf, create_scalar_slot5_relop(instr_buf, $1, $2, $4, $6, $8, $10, $12)); }
| OPCODE SLOT COMMA SLOT COMMA IMMX COMMA SLOT COMMA SLOT COMMA RELOP               { insert_instr(instr_buf, create_scalar_slot2_imm_slot2_relop(instr_buf, $1, $2, $4, $6, $8, $10, $12)); }
| OPCODE SLOT COMMA SLOT COMMA IMMX COMMA SLOT COMMA IMMX COMMA RELOP               { insert_instr(instr_buf, create_scalar_slot2_imm_slot_imm_relop(instr_buf, $1, $2, $4, $6, $8, $10, $12)); }
| OPCODE SLOT COMMA SLOT COMMA IMMX COMMA IMMX COMMA SLOT COMMA RELOP               { insert_instr(instr_buf, create_scalar_slot2_imm2_slot_relop(instr_buf, $1, $2, $4, $6, $8, $10, $12)); }
| OPCODE SLOT COMMA SLOT COMMA IMMX COMMA SLOT COMMA SLOT COMMA TSTREL              { insert_instr(instr_buf, create_scalar_slot2_imm_slot2_relop(instr_buf, $1, $2, $4, $6, $8, $10, $12)); }
| DISCARD SLOT                                                                      { insert_instr(instr_buf, create_scalar_slot(instr_buf, $1, $2)); };

vector:
OPCODE V128 COMMA ELEMENTSIZEATTR COMMA SLOT COMMA SLOT                             { insert_instr(instr_buf, create_vector_slot2(instr_buf, $1, $4, $6, $8)); }
| OPCODE V128 COMMA ELEMENTSIZEATTR COMMA SLOT COMMA SLOT COMMA SLOT                { insert_instr(instr_buf, create_vector_slot3(instr_buf, $1, $4, $6, $8, $10)); }
| OPCODE V128 COMMA ELEMENTSIZEATTR COMMA SLOT COMMA SLOT COMMA SLOT COMMA RELOP    { insert_instr(instr_buf, create_vector_slot3_relop(instr_buf, $1, $4, $6, $8, $10, $12)); }
| OPCODE V128 COMMA ELEMENTSIZEATTR COMMA SLOT COMMA V128 IMMX                      { insert_instr(instr_buf, create_vector_slot_vimm(instr_buf, $1, $4, $6, $9)); }
| OPCODE V128 COMMA ELEMENTSIZEATTR COMMA SLOT COMMA SLOT COMMA IMMX                { insert_instr(instr_buf, create_vector_slot2_imm(instr_buf, $1, $4, $6, $8, $10)); }
| OPCODE V128 COMMA ELEMENTSIZEATTR COMMA SLOT COMMA SLOT COMMA V128 IMMX           { insert_instr(instr_buf, create_vector_slot2_vimm(instr_buf, $1, $4, $6, $8, $11)); }
| OPCODE V128 COMMA ELEMENTSIZEATTR COMMA SLOT COMMA ENV COMMA IMMX                 { insert_instr(instr_buf, create_vector_slot_env_imm(instr_buf, $1, $4, $6, $10)); };

call_helper:
CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA SLOT COMMA SLOT                                     { insert_instr(instr_buf, create_helper_env_slot2(instr_buf, $2, $4, $6, $10, $12)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA SLOT COMMA SLOT COMMA SLOT                        { insert_instr(instr_buf, create_helper_slot3(instr_buf, $2, $4, $6, $8, $10, $12)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA SLOT COMMA SLOT COMMA IMMX                        { insert_instr(instr_buf, create_helper_slot2_imm(instr_buf, $2, $4, $6, $8, $10, $12)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA SLOT COMMA SLOT COMMA SLOT COMMA SLOT             { insert_instr(instr_buf, create_helper_slot4(instr_buf, $2, $4, $6, $8, $10, $12, $14)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA SLOT COMMA SLOT COMMA SLOT COMMA SLOT COMMA SLOT  { insert_instr(instr_buf, create_helper_slot5(instr_buf, $2, $4, $6, $8, $10, $12, $14, $16)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA SLOT COMMA SLOT COMMA SLOT COMMA IMMX             { insert_instr(instr_buf, create_helper_env_slot3_imm(instr_buf, $2, $4, $6, $8, $10, $12, $14)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA IMMX COMMA IMMX                         { insert_instr(instr_buf, create_helper_env_imm2(instr_buf, $2, $4, $6, $10, $12)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA SLOT COMMA SLOT COMMA SLOT COMMA IMMX   { insert_instr(instr_buf, create_helper_env_slot3_imm(instr_buf, $2, $4, $6, $10, $12, $14, $16)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA SLOT COMMA SLOT COMMA IMMX COMMA IMMX             { insert_instr(instr_buf, create_helper_slot2_imm2(instr_buf, $2, $4, $6, $8, $10, $12, $14)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA SLOT COMMA ENV COMMA SLOT                         { insert_instr(instr_buf, create_helper_env_slot2(instr_buf, $2, $4, $6, $8, $12)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA SLOT COMMA ENV                                    { insert_instr(instr_buf, create_helper_env_slot(instr_buf, $2, $4, $6, $8)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV                                               { insert_instr(instr_buf, create_helper_env(instr_buf, $2, $4, $6)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA SLOT                                    { insert_instr(instr_buf, create_helper_env_slot(instr_buf, $2, $4, $6, $10)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA SLOT COMMA SLOT                         { insert_instr(instr_buf, create_helper_env_slot2(instr_buf, $2, $4, $6, $10, $12)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA SLOT COMMA IMMX                         { insert_instr(instr_buf, create_helper_env_slot_imm(instr_buf, $2, $4, $6, $10, $12)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA SLOT COMMA SLOT COMMA SLOT              { insert_instr(instr_buf, create_helper_slot3(instr_buf, $2, $4, $6, $10, $12, $14)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA SLOT COMMA SLOT COMMA IMMX              { insert_instr(instr_buf, create_helper_slot2_imm(instr_buf, $2, $4, $6, $10, $12, $14)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA IMMX                                    { insert_instr(instr_buf, create_helper_env_imm(instr_buf, $2, $4, $6, $10)); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA IMMX COMMA SLOT                         { insert_instr(instr_buf, create_helper_env_imm_slot(instr_buf, $2, $4, $6, $10, $12)); };

branch:
BRCOND SLOT COMMA IMMX COMMA RELOP COMMA LABEL      { insert_instr(instr_buf, create_branch_condition(instr_buf, $2, $4, $6, $8)); }
| BRCOND SLOT COMMA IMMX COMMA TSTREL COMMA LABEL   { insert_instr(instr_buf, create_branch_condition(instr_buf, $2, $4, $6, $8)); }
| CALLDIR SLOT COMMA IMMX COMMA IMMX                { insert_instr(instr_buf, create_slot_imm2(instr_buf, $1, $2, $4, $6)); }
| JMPDIR IMMX                                       { insert_instr(instr_buf, create_jmpdirect(instr_buf, $2)); }
| SETLABL LABEL                                     { insert_instr(instr_buf, create_setlabel(instr_buf, $1, $2)); };

%%
void yyerror(yyscan_t scanner, TcgContext *ctx, const char *s) {
    int line = yyget_lineno(scanner);
    fprintf(stderr, "error: %s in line %d, column %d\n", s, line, column);
    if (lineptr) {
        fprintf(stderr, "%s\n", lineptr);
    }
    for(int i = 0; i < column - 1; i++) {
        fprintf(stderr, "_");
    }
    fprintf(stderr, "^\n");
}
