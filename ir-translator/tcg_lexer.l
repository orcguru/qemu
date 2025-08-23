%{
#include "tcg_ast.h"
#include "tcg_parser.tab.h"
#include <stdlib.h>
#include <stdio.h>
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
                    printf("EOF reached\n");                  \
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
%option header-file="lex.yy.h"

ENVVAR  (cc_src2|es_base|cs_base|ss_base|ds_base|fs_base|gs_base)
XREG    (r[acdb]x|r[sb]p|r[sd]i|r[0-9]+|rip|cc_src|cc_op|cc_dst)
TMPVAR  (loc[0-9]+|tmp[0-9]+)
IMMX    \$0x[0-9a-fA-F]+
IMMD    \$[0-9]+
NUM     [0-9]+
LABEL   \$L[0-9]+
RELOP   (eq|[su][gl][et]|ne|leu|gt|lt)
TSTREL  (tsteq|tstne)
MEMATTR (al|leq|lesl|lesw|leul|leuw|noat|sb|ub|un|al16|leo|al32)
OPCODE  [a-z][0-9a-zA-Z_]+
COMMA   ,
PLUS    +
BRCOND  brcond_i64
CALL    call
SETLABL set_label
JMPDIR  jmp_direct
CALLDIR call_direct
DISCARD discard
ENV     env
V128    v128
E8      e8
E16     e16
E32     e32
E64     e64
OZ      oz
IZ      iz
BSWAP64 bswap64_i64

%%
{ENVVAR}    { HANDLE_COLUMN; yylval->str = strdup(yytext); return ENVVAR; }
{XREG}      { HANDLE_COLUMN; yylval->str = strdup(yytext); return XREG; }
{TMPVAR}    { HANDLE_COLUMN; yylval->str = strdup(yytext); return TMPVAR; }
{IMMX}      { HANDLE_COLUMN; yylval->val = strtoll(yytext + 1, NULL, 16); return IMMX; }
{IMMD}      { HANDLE_COLUMN; yylval->val = strtoll(yytext + 1, NULL, 10); return IMMD; }
{NUM}       { HANDLE_COLUMN; yylval->str = strdup(yytext); return NUM; }
{LABEL}     { HANDLE_COLUMN; yylval->str = strdup(yytext); return LABEL; }
{RELOP}     { HANDLE_COLUMN; yylval->str = strdup(yytext); return RELOP; }
{TSTREL}    { HANDLE_COLUMN; yylval->str = strdup(yytext); return TSTREL; }
{MEMATTR}   { HANDLE_COLUMN; yylval->str = strdup(yytext); return MEMATTR; }
{BRCOND}    { HANDLE_COLUMN; return BRCOND; }
{CALL}      { HANDLE_COLUMN; return CALL; }
{SETLABL}   { HANDLE_COLUMN; return SETLABL; }
{JMPDIR}    { HANDLE_COLUMN; return JMPDIR; }
{CALLDIR}   { HANDLE_COLUMN; return CALLDIR; }
{DISCARD}   { HANDLE_COLUMN; return DISCARD; }
{ENV}       { HANDLE_COLUMN; return ENV; }
{V128}      { HANDLE_COLUMN; return V128; }
{E8}        { HANDLE_COLUMN; return E8; }
{E16}       { HANDLE_COLUMN; return E16; }
{E32}       { HANDLE_COLUMN; return E32; }
{E64}       { HANDLE_COLUMN; return E64; }
{OZ}        { HANDLE_COLUMN; return OZ; }
{IZ}        { HANDLE_COLUMN; return IZ; }
{BSWAP64}   { HANDLE_COLUMN; return BSWAP64; }
{OPCODE}    { HANDLE_COLUMN; yylval->str = strdup(yytext); return OPCODE; }
","         { HANDLE_COLUMN; return COMMA; }
":"         { HANDLE_COLUMN; return COLON; }
"+"         { HANDLE_COLUMN; return PLUS; }
\n          { next_column = 1; column = 1; }
[ \t]       ; // Ignore whitespace
%%
size_t min(size_t a, size_t b) {
    return b < a ? b : a;
}
