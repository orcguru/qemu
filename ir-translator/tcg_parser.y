%union {
  char* str;
  TcgAst* ast;
  long long val;
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

%token <str> LABEL MEMATTR OPCODE HELPER
%token <val> ENVVAR XREG NUM IMMX IMMD TMPLVAR TMPTVAR RELOP TSTREL
%token BRCOND CALL SETLABL JMPDIR CALLDIR COMMA COLON PLUS DISCARD ENV V128 E8 E16 E32 E64 OZ IZ BSWAP64

%type <ast> instruction instruction_list func func_list
%type <str> label discard_operand attribute info

%%
program: func_list { create_program($1); };

func_list: func                   { $$ = $1; }
| func_list func                  { $$ = merge_func($1, $2); };

func: IMMX COLON instruction_list { $$ = create_func($1, $3); };

instruction_list: instruction | instruction_list instruction;

instruction:
OPCODE slot
| OPCODE slot COMMA slot
| BSWAP64 slot COMMA slot COMMA
| OPCODE slot COMMA slot COMMA OZ
| OPCODE slot COMMA slot COMMA IZ COMMA OZ
| OPCODE slot COMMA IMMX
| OPCODE slot COMMA IMMX COMMA slot
| OPCODE slot COMMA ENV COMMA IMMX
| OPCODE slot COMMA slot COMMA attribute COMMA NUM
| OPCODE slot COMMA slot COMMA info COMMA attribute COMMA NUM
| OPCODE slot COMMA slot COMMA info
| OPCODE slot COMMA slot COMMA info COMMA RELOP
| OPCODE slot COMMA slot COMMA info COMMA TSTREL
| OPCODE slot COMMA slot COMMA info COMMA info
| OPCODE slot COMMA slot COMMA info COMMA info COMMA info
| OPCODE slot COMMA slot COMMA info COMMA info COMMA info COMMA RELOP
| OPCODE slot COMMA slot COMMA info COMMA info COMMA info COMMA TSTREL
| OPCODE V128 COMMA element_size COMMA slot COMMA slot
| OPCODE V128 COMMA element_size COMMA slot COMMA slot COMMA slot
| OPCODE V128 COMMA element_size COMMA slot COMMA slot COMMA slot COMMA RELOP
| OPCODE V128 COMMA element_size COMMA slot COMMA V128 IMMX
| OPCODE V128 COMMA element_size COMMA slot COMMA slot COMMA IMMX
| OPCODE V128 COMMA element_size COMMA slot COMMA slot COMMA V128 IMMX
| OPCODE V128 COMMA element_size COMMA slot COMMA ENV COMMA IMMX
| OPCODE IMMX COMMA ENV COMMA IMMX
| OPCODE IMMX COMMA slot COMMA IMMX
| JMPDIR IMMX
| DISCARD discard_operand
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA slot
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA IMMX
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA slot COMMA slot
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA slot COMMA slot COMMA slot
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA slot COMMA IMMX
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA IMMX COMMA IMMX
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot COMMA slot COMMA slot COMMA IMMX
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA slot COMMA IMMX COMMA IMMX
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA ENV COMMA slot
| CALL HELPER COMMA IMMX COMMA IMMD COMMA slot COMMA ENV
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot COMMA slot
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot COMMA IMMX
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot COMMA slot COMMA slot
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA slot COMMA slot COMMA IMMX
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA IMMX
| CALL HELPER COMMA IMMX COMMA IMMD COMMA ENV COMMA IMMX COMMA slot
| BRCOND slot COMMA IMMX COMMA RELOP COMMA LABEL
| BRCOND slot COMMA IMMX COMMA TSTREL COMMA LABEL
| SETLABL LABEL
| CALLDIR slot COMMA IMMX COMMA IMMX

element_size:
E8
| E16
| E32
| E64

slot:
TMPLVAR
| TMPTVAR
| XREG
| ENVVAR

info:
TMPLVAR
| TMPTVAR
| XREG
| ENVVAR
| IMMX

discard_operand:
XREG
| ENVVAR

attribute:
MEMATTR PLUS MEMATTR PLUS MEMATTR
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
