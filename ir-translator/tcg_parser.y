

%union {
  char* str;
  TcgAst* ast;
  uint64_t val;
  AttrInfo ai;
  SlotInfo si;
  RelopType r;
  OpCodeType op;
}

%{
#ifndef YYSTYPE
#define YYSTYPE union YYSTYPE
#include "lex.yy.h"
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
#define YYERROR_VERBOSE 1
%}

%token <str> HELPER
%token <val> NUM IMMX IMMD E8 E16 E32 E64 LABEL
%token <ai> MEMATTR SwapAttr
%token <si> ENVVAR XREG TMPLVAR TMPTVAR
%token <r> RELOP TSTREL
%token <op> OPCODE BSWAP64 SETLABL BRCOND CALL JMPDIR CALLDIR DISCARD
%token COMMA COLON PLUS ENV V128
%type <ast> instruction instruction_list func func_list scalar vector call_helper branch slot info element_size bswap_attribute attribute discard_operand

%%
program: func_list { create_program($1); };

func_list: func                   { $$ = $1; }
| func_list func                  { $$ = merge_ast($1, $2); };

func: IMMX COLON instruction_list { $$ = create_func($1, $3); };

instruction_list: instruction     { $$ = $1; }
| instruction_list instruction    { $$ = merge_ast($1, $2); };

instruction:
scalar          { $$ = $1; }
| vector        { $$ = $1; }
| call_helper   { $$ = $1; }
| branch        { $$ = $1; }

scalar:
OPCODE slot                                                             { $$ = create_scalar_slot($1, $2); }
| OPCODE slot COMMA slot                                                { $$ = create_scalar_slot2($1, $2, $4); }
| BSWAP64 slot COMMA slot COMMA                                         { $$ = create_scalar_slot2($1, $2, $4); }
| OPCODE slot COMMA slot COMMA bswap_attribute                                       { $$ = create_scalar_slot2_attr($1, $2, $4, $6); }
| OPCODE slot COMMA slot COMMA bswap_attribute COMMA bswap_attribute                              { $$ = create_scalar_slot2_attr2($1, $2, $4, $6, $8); }
| OPCODE slot COMMA IMMX                                                { $$ = create_scalar_slot_imm($1, $2, $4); }
| OPCODE slot COMMA IMMX COMMA slot                                     { $$ = create_scalar_slot_imm_slot($1, $2, $4, $6); }
| OPCODE slot COMMA ENV COMMA IMMX                                      { $$ = create_scalar_slot_env_imm($1, $2, $6); }
| OPCODE slot COMMA slot COMMA attribute COMMA NUM                      { $$ = create_scalar_slot2_attr_num($1, $2, $4, $6, $8); }
| OPCODE slot COMMA slot COMMA info COMMA attribute COMMA NUM           { $$ = create_scalar_slot2_info_attr_num($1, $2, $4, $6, $8, $10); }
| OPCODE slot COMMA slot COMMA info                                     { $$ = create_scalar_slot2_info($1, $2, $4, $6); }
| OPCODE slot COMMA slot COMMA info COMMA RELOP                         { $$ = create_scalar_slot2_info_relop($1, $2, $4, $6, $8); }
| OPCODE slot COMMA slot COMMA info COMMA TSTREL                        { $$ = expand_scalar_slot2_info_relop($1, $2, $4, $6, $8); }
| OPCODE slot COMMA slot COMMA info COMMA info                          { $$ = create_scalar_slot2_info2($1, $2, $4, $6, $8); }
| OPCODE slot COMMA slot COMMA info COMMA info COMMA info               { $$ = create_scalar_slot2_info3($1, $2, $4, $6, $8, $10); }
| OPCODE slot COMMA slot COMMA info COMMA info COMMA info COMMA RELOP   { $$ = create_scalar_slot2_info3_relop($1, $2, $4, $6, $8, $10, $12); }
| OPCODE slot COMMA slot COMMA info COMMA info COMMA info COMMA TSTREL  { $$ = expand_scalar_slot2_info3_relop($1, $2, $4, $6, $8, $10, $12); }
| OPCODE IMMX COMMA ENV COMMA IMMX                                      { $$ = create_scalar_imm_env_imm($1, $2, $6); }
| OPCODE IMMX COMMA slot COMMA IMMX                                     { $$ = create_scalar_imm_slot_imm($1, $2, $4, $6); }
| DISCARD discard_operand                                               { $$ = create_discard($2); };

vector:
OPCODE V128 COMMA element_size COMMA slot COMMA slot                            { $$ = create_vector_slot2($1, $4, $6, $8); }
| OPCODE V128 COMMA element_size COMMA slot COMMA slot COMMA slot               { $$ = create_vector_slot3($1, $4, $6, $8, $10); }
| OPCODE V128 COMMA element_size COMMA slot COMMA slot COMMA slot COMMA RELOP   { $$ = create_vector_slot3_relop($1, $4, $6, $8, $10, $12); }
| OPCODE V128 COMMA element_size COMMA slot COMMA V128 IMMX                     { $$ = create_vector_slot_vimm($1, $4, $6, $9); }
| OPCODE V128 COMMA element_size COMMA slot COMMA slot COMMA IMMX               { $$ = create_vector_slot2_imm($1, $4, $6, $8, $10); }
| OPCODE V128 COMMA element_size COMMA slot COMMA slot COMMA V128 IMMX          { $$ = create_vector_slot2_vimm($1, $4, $6, $8, $11); }
| OPCODE V128 COMMA element_size COMMA slot COMMA ENV COMMA IMMX                { $$ = create_vector_slot_env_imm($1, $4, $6, $10); };

call_helper:
CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA slot                          { $$ = create_helper_slot3($2, $4, $6, $8, $10, $12); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA IMMX                        { $$ = create_helper_slot2_imm($2, $4, $6, $8, $10, $12); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA slot COMMA slot             { $$ = create_helper_slot4($2, $4, $6, $8, $10, $12, $14); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA slot COMMA slot COMMA slot  { $$ = create_helper_slot5($2, $4, $6, $8, $10, $12, $14, $16); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA slot COMMA IMMX             { $$ = create_helper_slot3_imm($2, $4, $6, $8, $10, $12, $14); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA IMMX COMMA IMMX                         { $$ = create_helper_env_imm2($2, $4, $6, $10, $12); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot COMMA slot COMMA slot COMMA IMMX   { $$ = create_helper_env_slot3_imm($2, $4, $6, $10, $12, $14, $16); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA IMMX COMMA IMMX             { $$ = create_helper_slot2_imm2($2, $4, $6, $8, $10, $12, $14); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA ENV COMMA slot                         { $$ = create_helper_slot_env_slot($2, $4, $6, $8, $12); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA ENV                                    { $$ = create_helper_slot_env($2, $4, $6, $8); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV                                               { $$ = create_helper_env($2, $4, $6); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot                                    { $$ = create_helper_env_slot($2, $4, $6, $10); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot COMMA slot                         { $$ = create_helper_env_slot2($2, $4, $6, $10, $12); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot COMMA IMMX                         { $$ = create_helper_env_slot_imm($2, $4, $6, $10, $12); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot COMMA slot COMMA slot              { $$ = create_helper_env_slot3($2, $4, $6, $10, $12, $14); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot COMMA slot COMMA IMMX              { $$ = create_helper_env_slot2_imm($2, $4, $6, $10, $12, $14); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA IMMX                                    { $$ = create_helper_env_imm($2, $4, $6, $10); }
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA IMMX COMMA slot                         { $$ = create_helper_env_imm_slot($2, $4, $6, $10, $12); };

branch:
BRCOND slot COMMA IMMX COMMA RELOP COMMA LABEL      { $$ = create_branch_condition($2, $4, $6, $8); }
| BRCOND slot COMMA IMMX COMMA TSTREL COMMA LABEL   { $$ = expand_branch_condition($2, $4, $6, $8); }
| CALLDIR slot COMMA IMMX COMMA IMMX                { $$ = create_calldirect($2, $4, $6); }
| JMPDIR IMMX                                       { $$ = create_jmpdirect($2); }
| SETLABL LABEL                                     { $$ = create_setlabel($1, $2); };

element_size:
E8            { $$ = create_attr_elementsize($1); }
| E16         { $$ = create_attr_elementsize($1); }
| E32         { $$ = create_attr_elementsize($1); }
| E64         { $$ = create_attr_elementsize($1); };

slot:
TMPLVAR       { $$ = create_slot_tmpl($1); }
| TMPTVAR     { $$ = create_slot_tmpt($1); }
| XREG        { $$ = create_slot_xreg($1); }
| ENVVAR      { $$ = create_slot_envvar($1); };

info:
TMPLVAR       { $$ = create_slot_tmpl($1); }
| TMPTVAR     { $$ = create_slot_tmpt($1); }
| XREG        { $$ = create_slot_xreg($1); }
| ENVVAR      { $$ = create_slot_envvar($1); }
| IMMX        { $$ = create_imm($1); };

discard_operand:
XREG          { $$ = create_slot_xreg($1); }
| ENVVAR      { $$ = create_slot_envvar($1); };

attribute:
MEMATTR PLUS MEMATTR PLUS MEMATTR   { $$ = create_storage_attr($1, $3, $5); };

bswap_attribute:
SwapAttr          { $$ = create_bswap_attr($1); };

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
