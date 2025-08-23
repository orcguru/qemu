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

TMPLVAR         (loc[0-9]+)
TMPTVAR         (tmp[0-9]+)
IMMX            \$0x[0-9a-fA-F]+
IMMD            \$[0-9]+
NUM             [0-9]+
LABEL           \$L[0-9]+
MEMATTR         (al|leq|lesl|lesw|leul|leuw|noat|sb|ub|un|al16|leo|al32)
HELPER          [a-z][0-9a-zA-Z_]+
COMMA           ,
PLUS            +
cc_src2         cc_src2
es_base         es_base
cs_base         cs_base
ss_base         ss_base
ds_base         ds_base
fs_base         fs_base
gs_base         gs_base
rax             rax
rcx             rcx
rdx             rdx
rbx             rbx
rsp             rsp
rbp             rbp
rsi             rsi
rdi             rdi
r8              r8
r9              r9
r10             r10
r11             r11
r12             r12
r13             r13
r14             r14
r15             r15
rip             rip
cc_src          cc_src
cc_op           cc_op
cc_dst          cc_dst
eq              eq
sge             sge
sgt             sgt
sle             sle
slt             slt
uge             uge
ugt             ugt
ule             ule
ult             ult
ne              ne
leu             leu
gt              gt
lt              lt
tsteq           tsteq
tstne           tstne
BRCOND          brcond_i64
CALL            call
SETLABL         set_label
JMPDIR          jmp_direct
CALLDIR         call_direct
DISCARD         discard
BSWAP64         bswap64_i64
ENV             env
V128            v128
E8              e8
E16             e16
E32             e32
E64             e64
OZ              oz
IZ              iz
add_i64         add_i64
add_vec         add_vec
andc_i64        andc_i64
andc_vec        andc_vec
and_i64         and_i64
and_vec         and_vec
bswap32_i64     bswap32_i64
clz_i64         clz_i64
cmp_vec         cmp_vec
ctz_i64         ctz_i64
deposit_i32     deposit_i32
deposit_i64     deposit_i64
dupm_vec        dupm_vec
extract2_i64    extract2_i64
extract_i32     extract_i32
extract_i64     extract_i64
extrl_i64_i32   extrl_i64_i32
extu_i32_i64    extu_i32_i64
ld32s_i64       ld32s_i64
ld32u_i64       ld32u_i64
ld8u_i64        ld8u_i64
ld_i32          ld_i32
ld_i64          ld_i64
ld_vec          ld_vec
movcond_i32     movcond_i32
movcond_i64     movcond_i64
mov_i32         mov_i32
mov_i64         mov_i64
mov_i64_const   mov_i64_const
mov_vec         mov_vec
mul_i32         mul_i32
mul_i64         mul_i64
mulsh_i64       mulsh_i64
muluh_i64       muluh_i64
neg_i32         neg_i32
neg_i64         neg_i64
negsetcond_i64  negsetcond_i64
not_i64         not_i64
or_i64          or_i64
or_vec          or_vec
push_ret_addr   push_ret_addr
qemu_ld2_i128   qemu_ld2_i128
qemu_ld_i32     qemu_ld_i32
qemu_ld_i64     qemu_ld_i64
qemu_st2_i128   qemu_st2_i128
qemu_st_i32     qemu_st_i32
qemu_st_i64     qemu_st_i64
ret             ret
rotr_i32        rotr_i32
rotr_i64        rotr_i64
sar_i64         sar_i64
setcond_i64     setcond_i64
sextract_i64    sextract_i64
shl_i64         shl_i64
shli_vec        shli_vec
shr_i64         shr_i64
st16_i32        st16_i32
st16_i64        st16_i64
st32_i64        st32_i64
st_i32          st_i32
st_i64          st_i64
st_vec          st_vec
sub_i64         sub_i64
sub_vec         sub_vec
umax_vec        umax_vec
umin_vec        umin_vec
xor_i64         xor_i64
xor_vec         xor_vec

%%

{TMPLVAR}         { HANDLE_COLUMN; yylval->val = atoi(yytext + 3); return TMPLVAR; }
{TMPTVAR}         { HANDLE_COLUMN; yylval->val = atoi(yytext + 3); return TMPTVAR; }
{IMMX}            { HANDLE_COLUMN; yylval->val = strtoll(yytext + 1, NULL, 16); return IMMX; }
{IMMD}            { HANDLE_COLUMN; yylval->val = strtoll(yytext + 1, NULL, 10); return IMMD; }
{NUM}             { HANDLE_COLUMN; yylval->val = atoi(yytext); return NUM; }
{LABEL}           { HANDLE_COLUMN; yylval->str = strdup(yytext); return LABEL; }
{MEMATTR}         { HANDLE_COLUMN; yylval->str = strdup(yytext); return MEMATTR; }
{cc_src2}         { HANDLE_COLUMN; yylval->val = 1; return ENVVAR; }
{es_base}         { HANDLE_COLUMN; yylval->val = 2; return ENVVAR; }
{cs_base}         { HANDLE_COLUMN; yylval->val = 3; return ENVVAR; }
{ss_base}         { HANDLE_COLUMN; yylval->val = 4; return ENVVAR; }
{ds_base}         { HANDLE_COLUMN; yylval->val = 5; return ENVVAR; }
{fs_base}         { HANDLE_COLUMN; yylval->val = 6; return ENVVAR; }
{gs_base}         { HANDLE_COLUMN; yylval->val = 7; return ENVVAR; }
{rax}             { HANDLE_COLUMN; yylval->val = 1; return XREG; }
{rcx}             { HANDLE_COLUMN; yylval->val = 2; return XREG; }
{rdx}             { HANDLE_COLUMN; yylval->val = 3; return XREG; }
{rbx}             { HANDLE_COLUMN; yylval->val = 4; return XREG; }
{rsp}             { HANDLE_COLUMN; yylval->val = 5; return XREG; }
{rbp}             { HANDLE_COLUMN; yylval->val = 6; return XREG; }
{rsi}             { HANDLE_COLUMN; yylval->val = 7; return XREG; }
{rdi}             { HANDLE_COLUMN; yylval->val = 8; return XREG; }
{r8}              { HANDLE_COLUMN; yylval->val = 9; return XREG; }
{r9}              { HANDLE_COLUMN; yylval->val = 10; return XREG; }
{r10}             { HANDLE_COLUMN; yylval->val = 11; return XREG; }
{r11}             { HANDLE_COLUMN; yylval->val = 12; return XREG; }
{r12}             { HANDLE_COLUMN; yylval->val = 13; return XREG; }
{r13}             { HANDLE_COLUMN; yylval->val = 14; return XREG; }
{r14}             { HANDLE_COLUMN; yylval->val = 15; return XREG; }
{r15}             { HANDLE_COLUMN; yylval->val = 16; return XREG; }
{cc_src}          { HANDLE_COLUMN; yylval->val = 17; return XREG; }
{cc_dst}          { HANDLE_COLUMN; yylval->val = 18; return XREG; }
{cc_op}           { HANDLE_COLUMN; yylval->val = 19; return XREG; }
{rip}             { HANDLE_COLUMN; yylval->val = 20; return XREG; }
{eq}              { HANDLE_COLUMN; yylval->val = 1; return RELOP; }
{sge}             { HANDLE_COLUMN; yylval->val = 2; return RELOP; }
{sgt}             { HANDLE_COLUMN; yylval->val = 3; return RELOP; }
{sle}             { HANDLE_COLUMN; yylval->val = 4; return RELOP; }
{slt}             { HANDLE_COLUMN; yylval->val = 5; return RELOP; }
{uge}             { HANDLE_COLUMN; yylval->val = 6; return RELOP; }
{ugt}             { HANDLE_COLUMN; yylval->val = 7; return RELOP; }
{ule}             { HANDLE_COLUMN; yylval->val = 8; return RELOP; }
{ult}             { HANDLE_COLUMN; yylval->val = 9; return RELOP; }
{ne}              { HANDLE_COLUMN; yylval->val = 10; return RELOP; }
{leu}             { HANDLE_COLUMN; yylval->val = 11; return RELOP; }
{gt}              { HANDLE_COLUMN; yylval->val = 12; return RELOP; }
{lt}              { HANDLE_COLUMN; yylval->val = 13; return RELOP; }
{tsteq}           { HANDLE_COLUMN; yylval->val = 1; return TSTREL; }
{tstne}           { HANDLE_COLUMN; yylval->val = 2; return TSTREL; }
{BRCOND}          { HANDLE_COLUMN; return BRCOND; }
{CALL}            { HANDLE_COLUMN; return CALL; }
{SETLABL}         { HANDLE_COLUMN; return SETLABL; }
{JMPDIR}          { HANDLE_COLUMN; return JMPDIR; }
{CALLDIR}         { HANDLE_COLUMN; return CALLDIR; }
{DISCARD}         { HANDLE_COLUMN; return DISCARD; }
{ENV}             { HANDLE_COLUMN; return ENV; }
{V128}            { HANDLE_COLUMN; return V128; }
{E8}              { HANDLE_COLUMN; return E8; }
{E16}             { HANDLE_COLUMN; return E16; }
{E32}             { HANDLE_COLUMN; return E32; }
{E64}             { HANDLE_COLUMN; return E64; }
{OZ}              { HANDLE_COLUMN; return OZ; }
{IZ}              { HANDLE_COLUMN; return IZ; }
{BSWAP64}         { HANDLE_COLUMN; return BSWAP64; }
{add_i64}         { HANDLE_COLUMN; yylval->val = 1; return OPCODE; }
{add_vec}         { HANDLE_COLUMN; yylval->val = 2; return OPCODE; }
{andc_i64}        { HANDLE_COLUMN; yylval->val = 3; return OPCODE; }
{andc_vec}        { HANDLE_COLUMN; yylval->val = 4; return OPCODE; }
{and_i64}         { HANDLE_COLUMN; yylval->val = 5; return OPCODE; }
{and_vec}         { HANDLE_COLUMN; yylval->val = 6; return OPCODE; }
{bswap32_i64}     { HANDLE_COLUMN; yylval->val = 7; return OPCODE; }
{clz_i64}         { HANDLE_COLUMN; yylval->val = 8; return OPCODE; }
{cmp_vec}         { HANDLE_COLUMN; yylval->val = 9; return OPCODE; }
{ctz_i64}         { HANDLE_COLUMN; yylval->val = 10; return OPCODE; }
{deposit_i32}     { HANDLE_COLUMN; yylval->val = 11; return OPCODE; }
{deposit_i64}     { HANDLE_COLUMN; yylval->val = 12; return OPCODE; }
{dupm_vec}        { HANDLE_COLUMN; yylval->val = 13; return OPCODE; }
{extract2_i64}    { HANDLE_COLUMN; yylval->val = 14; return OPCODE; }
{extract_i32}     { HANDLE_COLUMN; yylval->val = 15; return OPCODE; }
{extract_i64}     { HANDLE_COLUMN; yylval->val = 16; return OPCODE; }
{extrl_i64_i32}   { HANDLE_COLUMN; yylval->val = 17; return OPCODE; }
{extu_i32_i64}    { HANDLE_COLUMN; yylval->val = 18; return OPCODE; }
{ld32s_i64}       { HANDLE_COLUMN; yylval->val = 19; return OPCODE; }
{ld32u_i64}       { HANDLE_COLUMN; yylval->val = 20; return OPCODE; }
{ld8u_i64}        { HANDLE_COLUMN; yylval->val = 21; return OPCODE; }
{ld_i32}          { HANDLE_COLUMN; yylval->val = 22; return OPCODE; }
{ld_i64}          { HANDLE_COLUMN; yylval->val = 23; return OPCODE; }
{ld_vec}          { HANDLE_COLUMN; yylval->val = 24; return OPCODE; }
{movcond_i32}     { HANDLE_COLUMN; yylval->val = 25; return OPCODE; }
{movcond_i64}     { HANDLE_COLUMN; yylval->val = 26; return OPCODE; }
{mov_i32}         { HANDLE_COLUMN; yylval->val = 27; return OPCODE; }
{mov_i64}         { HANDLE_COLUMN; yylval->val = 28; return OPCODE; }
{mov_i64_const}   { HANDLE_COLUMN; yylval->val = 29; return OPCODE; }
{mov_vec}         { HANDLE_COLUMN; yylval->val = 30; return OPCODE; }
{mul_i32}         { HANDLE_COLUMN; yylval->val = 31; return OPCODE; }
{mul_i64}         { HANDLE_COLUMN; yylval->val = 32; return OPCODE; }
{mulsh_i64}       { HANDLE_COLUMN; yylval->val = 33; return OPCODE; }
{muluh_i64}       { HANDLE_COLUMN; yylval->val = 34; return OPCODE; }
{neg_i32}         { HANDLE_COLUMN; yylval->val = 35; return OPCODE; }
{neg_i64}         { HANDLE_COLUMN; yylval->val = 36; return OPCODE; }
{negsetcond_i64}  { HANDLE_COLUMN; yylval->val = 37; return OPCODE; }
{not_i64}         { HANDLE_COLUMN; yylval->val = 38; return OPCODE; }
{or_i64}          { HANDLE_COLUMN; yylval->val = 39; return OPCODE; }
{or_vec}          { HANDLE_COLUMN; yylval->val = 40; return OPCODE; }
{push_ret_addr}   { HANDLE_COLUMN; yylval->val = 41; return OPCODE; }
{qemu_ld2_i128}   { HANDLE_COLUMN; yylval->val = 42; return OPCODE; }
{qemu_ld_i32}     { HANDLE_COLUMN; yylval->val = 43; return OPCODE; }
{qemu_ld_i64}     { HANDLE_COLUMN; yylval->val = 44; return OPCODE; }
{qemu_st2_i128}   { HANDLE_COLUMN; yylval->val = 45; return OPCODE; }
{qemu_st_i32}     { HANDLE_COLUMN; yylval->val = 46; return OPCODE; }
{qemu_st_i64}     { HANDLE_COLUMN; yylval->val = 47; return OPCODE; }
{ret}             { HANDLE_COLUMN; yylval->val = 48; return OPCODE; }
{rotr_i32}        { HANDLE_COLUMN; yylval->val = 49; return OPCODE; }
{rotr_i64}        { HANDLE_COLUMN; yylval->val = 50; return OPCODE; }
{sar_i64}         { HANDLE_COLUMN; yylval->val = 51; return OPCODE; }
{setcond_i64}     { HANDLE_COLUMN; yylval->val = 52; return OPCODE; }
{sextract_i64}    { HANDLE_COLUMN; yylval->val = 53; return OPCODE; }
{shl_i64}         { HANDLE_COLUMN; yylval->val = 54; return OPCODE; }
{shli_vec}        { HANDLE_COLUMN; yylval->val = 55; return OPCODE; }
{shr_i64}         { HANDLE_COLUMN; yylval->val = 56; return OPCODE; }
{st16_i32}        { HANDLE_COLUMN; yylval->val = 57; return OPCODE; }
{st16_i64}        { HANDLE_COLUMN; yylval->val = 58; return OPCODE; }
{st32_i64}        { HANDLE_COLUMN; yylval->val = 59; return OPCODE; }
{st_i32}          { HANDLE_COLUMN; yylval->val = 60; return OPCODE; }
{st_i64}          { HANDLE_COLUMN; yylval->val = 61; return OPCODE; }
{st_vec}          { HANDLE_COLUMN; yylval->val = 62; return OPCODE; }
{sub_i64}         { HANDLE_COLUMN; yylval->val = 63; return OPCODE; }
{sub_vec}         { HANDLE_COLUMN; yylval->val = 64; return OPCODE; }
{umax_vec}        { HANDLE_COLUMN; yylval->val = 65; return OPCODE; }
{umin_vec}        { HANDLE_COLUMN; yylval->val = 66; return OPCODE; }
{xor_i64}         { HANDLE_COLUMN; yylval->val = 67; return OPCODE; }
{xor_vec}         { HANDLE_COLUMN; yylval->val = 68; return OPCODE; }
{HELPER}          { HANDLE_COLUMN; yylval->str = strdup(yytext); return HELPER; }
","               { HANDLE_COLUMN; return COMMA; }
":"               { HANDLE_COLUMN; return COLON; }
"+"               { HANDLE_COLUMN; return PLUS; }
\n                { next_column = 1; column = 1; }
[ \t]             ; // Ignore whitespace
%%
size_t min(size_t a, size_t b) {
    return b < a ? b : a;
}
