

%union {
  char* str;
}

%{
#ifndef YYSTYPE
#define YYSTYPE union YYSTYPE
#include "instr_def_lexer.yy.h"
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

%token TYPEDEF STRUCT ATTR LEFTPAREN RIGHTPAREN LEFTBRACKET RIGHTBRACKET SEMI SYMBOL COLON NUM PACKED

%%
top: instr_def_list;

instr_def_list: instr_def
| instr_def_list instr_def;

instr_def:
TYPEDEF STRUCT ATTR LEFTPAREN LEFTPAREN PACKED RIGHTPAREN RIGHTPAREN LEFTBRACKET field_list RIGHTBRACKET SYMBOL SEMI;

field_list: field
| field_list field;

field:
SYMBOL SYMBOL SEMI
| SYMBOL SYMBOL COLON NUM SEMI;

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
