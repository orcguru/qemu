%{
#include "tcg_ast.h"
#include "instr_def_parser.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
void yyerror(yyscan_t scanner, TcgContext *ctx, const char *s);
%}

%{
extern int yylval;
static int next_column = 1;
int column = 1;

#define HANDLE_COLUMN column = next_column; next_column += strlen(yytext)

char *lineptr = NULL;
size_t n = 0;
size_t consumed = 0;
size_t available = 0;
int eof_reached = 0;

size_t min(size_t a, size_t b);
#define YY_INPUT(buf, result, max_size)                       \
    {                                                         \
        if (eof_reached) {                                    \
            result = 0;                                       \
            number_to_move = YY_MORE_ADJ;                     \
        } else if (available <= 0) {                          \
            consumed = 0;                                     \
            ssize_t bytes_read = getline(&lineptr, &n, yyin); \
            if (bytes_read < 0) {                             \
                if (ferror(yyin)) {                           \
                    perror("read error:");                    \
                    exit(EXIT_FAILURE);                       \
                } else {                                      \
                    eof_reached = 1;                          \
                    result = 0;                               \
                    number_to_move = YY_MORE_ADJ;             \
                }                                             \
            } else {                                          \
                available = bytes_read;                       \
                result = min(available, max_size);            \
                if (result > 0) {                             \
                    strncpy(buf, lineptr + consumed, result); \
                    consumed += result;                       \
                    available -= result;                      \
                }                                             \
            }                                                 \
        } else {                                              \
            result = min(available, max_size);                \
            strncpy(buf, lineptr + consumed, result);         \
            consumed += result;                               \
            available -= result;                              \
        }                                                     \
    }
%}

%option nounput noinput noyywrap bison-bridge reentrant yylineno

TYPEDEF         typedef
STRUCT          struct
ATTR            __attribute__
PACKED          packed
SYMBOL          [a-zA-Z][0-9a-zA-Z_]+
NUM             [0-9]+
%x COMMENT

%%

{TYPEDEF}         { HANDLE_COLUMN; return TYPEDEF; }
{STRUCT}          { HANDLE_COLUMN; return STRUCT; }
{ATTR}            { HANDLE_COLUMN; return ATTR; }
{PACKED}          { HANDLE_COLUMN; return PACKED; }
{SYMBOL}          { HANDLE_COLUMN; return SYMBOL; }
{NUM}             { HANDLE_COLUMN; return NUM; }
";"               { HANDLE_COLUMN; return SEMI; }
":"               { HANDLE_COLUMN; return COLON; }
"("               { HANDLE_COLUMN; return LEFTPAREN; }
")"               { HANDLE_COLUMN; return RIGHTPAREN; }
"{"               { HANDLE_COLUMN; return LEFTBRACKET; }
"}"               { HANDLE_COLUMN; return RIGHTBRACKET; }
\n                { next_column = 1; column = 1; }
[ \t]             ; // Ignore whitespace
"/*" { BEGIN(COMMENT); }   /* Enter comment state */
<COMMENT>{
    "*/" { BEGIN(INITIAL); }   /* Exit comment state */
    .    /* Ignore any character */
    \n   /* Optional: Track line numbers if needed */
}
%%
size_t min(size_t a, size_t b) {
    return b < a ? b : a;
}
