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
al              al
leq             leq
lesl            lesl
lesw            lesw
leul            leul
leuw            leuw
noat            noat
sb              sb
ub              ub
un              un
al16            al16
leo             leo
al32            al32
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
OS              os
IS              is
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

{TMPLVAR}         { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_TMPL; yylval->si.p.idx = atoi(yytext + 3); return TMPLVAR; }
{TMPTVAR}         { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_TMPT; yylval->si.p.idx = atoi(yytext + 3); return TMPTVAR; }
{IMMX}            { HANDLE_COLUMN; yylval->val = strtoll(yytext + 1, NULL, 16); return IMMX; }
{IMMD}            { HANDLE_COLUMN; yylval->val = strtoll(yytext + 1, NULL, 10); return IMMD; }
{NUM}             { HANDLE_COLUMN; yylval->val = atoi(yytext); return NUM; }
{LABEL}           { HANDLE_COLUMN; yylval->val = atoi(yytext + 2); return LABEL; }
{noat}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ATOMIC; yylval->ai.p.storage.attr.atomic = NONATOMIC; return MEMATTR; }
{un}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ALIGNMENT; yylval->ai.p.storage.attr.alignment = UNALIGN; return MEMATTR; }
{al}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ALIGNMENT; yylval->ai.p.storage.attr.alignment = ALIGN_MEM_SIZE; return MEMATTR; }
{al16}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ALIGNMENT; yylval->ai.p.storage.attr.alignment = ALIGN_16; return MEMATTR; }
{al32}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ALIGNMENT; yylval->ai.p.storage.attr.alignment = ALIGN_32; return MEMATTR; }
{sb}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = SIGN; yylval->ai.p.storage.ui8 = 1; return MEMATTR; }
{lesw}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = SIGN; yylval->ai.p.storage.ui8 = 2; return MEMATTR; }
{lesl}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = SIGN; yylval->ai.p.storage.ui8 = 4; return MEMATTR; }
{ub}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = ZERO; yylval->ai.p.storage.ui8 = 1; return MEMATTR; }
{leuw}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = ZERO; yylval->ai.p.storage.ui8 = 2; return MEMATTR; }
{leul}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = ZERO; yylval->ai.p.storage.ui8 = 4; return MEMATTR; }
{leq}             { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = ZERO; yylval->ai.p.storage.ui8 = 8; return MEMATTR; }
{leo}             { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = ZERO; yylval->ai.p.storage.ui8 = 16; return MEMATTR; }
{cc_src2}         { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_ENVVAR; yylval->si.p.env = cc_src2; return ENVVAR; }
{es_base}         { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_ENVVAR; yylval->si.p.env = es_base; return ENVVAR; }
{cs_base}         { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_ENVVAR; yylval->si.p.env = cs_base; return ENVVAR; }
{ss_base}         { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_ENVVAR; yylval->si.p.env = ss_base; return ENVVAR; }
{ds_base}         { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_ENVVAR; yylval->si.p.env = ds_base; return ENVVAR; }
{fs_base}         { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_ENVVAR; yylval->si.p.env = fs_base; return ENVVAR; }
{gs_base}         { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_ENVVAR; yylval->si.p.env = gs_base; return ENVVAR; }
{rax}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = rax; return XREG; }
{rcx}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = rcx; return XREG; }
{rdx}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = rdx; return XREG; }
{rbx}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = rbx; return XREG; }
{rsp}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = rsp; return XREG; }
{rbp}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = rbp; return XREG; }
{rsi}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = rsi; return XREG; }
{rdi}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = rdi; return XREG; }
{r8}              { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = r8; return XREG; }
{r9}              { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = r9; return XREG; }
{r10}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = r10; return XREG; }
{r11}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = r11; return XREG; }
{r12}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = r12; return XREG; }
{r13}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = r13; return XREG; }
{r14}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = r14; return XREG; }
{r15}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = r15; return XREG; }
{cc_src}          { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = cc_src; return XREG; }
{cc_dst}          { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = cc_dst; return XREG; }
{cc_op}           { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = cc_op; return XREG; }
{rip}             { HANDLE_COLUMN; yylval->si.subt = SUB_SLOT_XREG; yylval->si.p.x = rip; return XREG; }
{eq}              { HANDLE_COLUMN; yylval->r = eq; return RELOP; }
{sge}             { HANDLE_COLUMN; yylval->r = sge; return RELOP; }
{sgt}             { HANDLE_COLUMN; yylval->r = sgt; return RELOP; }
{sle}             { HANDLE_COLUMN; yylval->r = sle; return RELOP; }
{slt}             { HANDLE_COLUMN; yylval->r = slt; return RELOP; }
{uge}             { HANDLE_COLUMN; yylval->r = uge; return RELOP; }
{ugt}             { HANDLE_COLUMN; yylval->r = ugt; return RELOP; }
{ule}             { HANDLE_COLUMN; yylval->r = ule; return RELOP; }
{ult}             { HANDLE_COLUMN; yylval->r = ult; return RELOP; }
{ne}              { HANDLE_COLUMN; yylval->r = ne; return RELOP; }
{leu}             { HANDLE_COLUMN; yylval->r = leu; return RELOP; }
{gt}              { HANDLE_COLUMN; yylval->r = gt; return RELOP; }
{lt}              { HANDLE_COLUMN; yylval->r = lt; return RELOP; }
{tsteq}           { HANDLE_COLUMN; yylval->r = tsteq; return TSTREL; }
{tstne}           { HANDLE_COLUMN; yylval->r = tstne; return TSTREL; }
{BRCOND}          { HANDLE_COLUMN; yylval->op = brcond_i64; return BRCOND; }
{CALL}            { HANDLE_COLUMN; yylval->op = call; return CALL; }
{SETLABL}         { HANDLE_COLUMN; yylval->op = set_label; return SETLABL; }
{JMPDIR}          { HANDLE_COLUMN; yylval->op = jmp_direct; return JMPDIR; }
{CALLDIR}         { HANDLE_COLUMN; yylval->op = call_direct; return CALLDIR; }
{DISCARD}         { HANDLE_COLUMN; yylval->op = discard; return DISCARD; }
{ENV}             { HANDLE_COLUMN; return ENV; }
{V128}            { HANDLE_COLUMN; return V128; }
{E8}              { HANDLE_COLUMN; yylval->val = 8; return E8; }
{E16}             { HANDLE_COLUMN; yylval->val = 16; return E16; }
{E32}             { HANDLE_COLUMN; yylval->val = 32; return E32; }
{E64}             { HANDLE_COLUMN; yylval->val = 64; return E64; }
{OZ}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SWAP; yylval->ai.p.swap = OZ; return SwapAttr; }
{IZ}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SWAP; yylval->ai.p.swap = IZ; return SwapAttr; }
{OS}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SWAP; yylval->ai.p.swap = OS; return SwapAttr; }
{IS}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SWAP; yylval->ai.p.swap = IS; return SwapAttr; }
{add_i64}         { HANDLE_COLUMN; yylval->op = add_i64; return OPCODE; }
{add_vec}         { HANDLE_COLUMN; yylval->op = add_vec; return OPCODE; }
{andc_i64}        { HANDLE_COLUMN; yylval->op = andc_i64; return OPCODE; }
{andc_vec}        { HANDLE_COLUMN; yylval->op = andc_vec; return OPCODE; }
{and_i64}         { HANDLE_COLUMN; yylval->op = and_i64; return OPCODE; }
{and_vec}         { HANDLE_COLUMN; yylval->op = and_vec; return OPCODE; }
{bswap32_i64}     { HANDLE_COLUMN; yylval->op = bswap32_i64; return OPCODE; }
{clz_i64}         { HANDLE_COLUMN; yylval->op = clz_i64; return OPCODE; }
{cmp_vec}         { HANDLE_COLUMN; yylval->op = cmp_vec; return OPCODE; }
{ctz_i64}         { HANDLE_COLUMN; yylval->op = ctz_i64; return OPCODE; }
{deposit_i32}     { HANDLE_COLUMN; yylval->op = deposit_i32; return OPCODE; }
{deposit_i64}     { HANDLE_COLUMN; yylval->op = deposit_i64; return OPCODE; }
{dupm_vec}        { HANDLE_COLUMN; yylval->op = dupm_vec; return OPCODE; }
{extract2_i64}    { HANDLE_COLUMN; yylval->op = extract2_i64; return OPCODE; }
{extract_i32}     { HANDLE_COLUMN; yylval->op = extract_i32; return OPCODE; }
{extract_i64}     { HANDLE_COLUMN; yylval->op = extract_i64; return OPCODE; }
{extrl_i64_i32}   { HANDLE_COLUMN; yylval->op = extrl_i64_i32; return OPCODE; }
{extu_i32_i64}    { HANDLE_COLUMN; yylval->op = extu_i32_i64; return OPCODE; }
{ld32s_i64}       { HANDLE_COLUMN; yylval->op = ld32s_i64; return OPCODE; }
{ld32u_i64}       { HANDLE_COLUMN; yylval->op = ld32u_i64; return OPCODE; }
{ld8u_i64}        { HANDLE_COLUMN; yylval->op = ld8u_i64; return OPCODE; }
{ld_i32}          { HANDLE_COLUMN; yylval->op = ld_i32; return OPCODE; }
{ld_i64}          { HANDLE_COLUMN; yylval->op = ld_i64; return OPCODE; }
{ld_vec}          { HANDLE_COLUMN; yylval->op = ld_vec; return OPCODE; }
{movcond_i32}     { HANDLE_COLUMN; yylval->op = movcond_i32; return OPCODE; }
{movcond_i64}     { HANDLE_COLUMN; yylval->op = movcond_i64; return OPCODE; }
{mov_i32}         { HANDLE_COLUMN; yylval->op = mov_i32; return OPCODE; }
{mov_i64}         { HANDLE_COLUMN; yylval->op = mov_i64; return OPCODE; }
{mov_i64_const}   { HANDLE_COLUMN; yylval->op = mov_i64_const; return OPCODE; }
{mov_vec}         { HANDLE_COLUMN; yylval->op = mov_vec; return OPCODE; }
{mul_i32}         { HANDLE_COLUMN; yylval->op = mul_i32; return OPCODE; }
{mul_i64}         { HANDLE_COLUMN; yylval->op = mul_i64; return OPCODE; }
{mulsh_i64}       { HANDLE_COLUMN; yylval->op = mulsh_i64; return OPCODE; }
{muluh_i64}       { HANDLE_COLUMN; yylval->op = muluh_i64; return OPCODE; }
{neg_i32}         { HANDLE_COLUMN; yylval->op = neg_i32; return OPCODE; }
{neg_i64}         { HANDLE_COLUMN; yylval->op = neg_i64; return OPCODE; }
{negsetcond_i64}  { HANDLE_COLUMN; yylval->op = negsetcond_i64; return OPCODE; }
{not_i64}         { HANDLE_COLUMN; yylval->op = not_i64; return OPCODE; }
{or_i64}          { HANDLE_COLUMN; yylval->op = or_i64; return OPCODE; }
{or_vec}          { HANDLE_COLUMN; yylval->op = or_vec; return OPCODE; }
{push_ret_addr}   { HANDLE_COLUMN; yylval->op = push_ret_addr; return OPCODE; }
{qemu_ld2_i128}   { HANDLE_COLUMN; yylval->op = qemu_ld2_i128; return OPCODE; }
{qemu_ld_i32}     { HANDLE_COLUMN; yylval->op = qemu_ld_i32; return OPCODE; }
{qemu_ld_i64}     { HANDLE_COLUMN; yylval->op = qemu_ld_i64; return OPCODE; }
{qemu_st2_i128}   { HANDLE_COLUMN; yylval->op = qemu_st2_i128; return OPCODE; }
{qemu_st_i32}     { HANDLE_COLUMN; yylval->op = qemu_st_i32; return OPCODE; }
{qemu_st_i64}     { HANDLE_COLUMN; yylval->op = qemu_st_i64; return OPCODE; }
{ret}             { HANDLE_COLUMN; yylval->op = ret; return OPCODE; }
{rotr_i32}        { HANDLE_COLUMN; yylval->op = rotr_i32; return OPCODE; }
{rotr_i64}        { HANDLE_COLUMN; yylval->op = rotr_i64; return OPCODE; }
{sar_i64}         { HANDLE_COLUMN; yylval->op = sar_i64; return OPCODE; }
{setcond_i64}     { HANDLE_COLUMN; yylval->op = setcond_i64; return OPCODE; }
{sextract_i64}    { HANDLE_COLUMN; yylval->op = sextract_i64; return OPCODE; }
{shl_i64}         { HANDLE_COLUMN; yylval->op = shl_i64; return OPCODE; }
{shli_vec}        { HANDLE_COLUMN; yylval->op = shli_vec; return OPCODE; }
{shr_i64}         { HANDLE_COLUMN; yylval->op = shr_i64; return OPCODE; }
{st16_i32}        { HANDLE_COLUMN; yylval->op = st16_i32; return OPCODE; }
{st16_i64}        { HANDLE_COLUMN; yylval->op = st16_i64; return OPCODE; }
{st32_i64}        { HANDLE_COLUMN; yylval->op = st32_i64; return OPCODE; }
{st_i32}          { HANDLE_COLUMN; yylval->op = st_i32; return OPCODE; }
{st_i64}          { HANDLE_COLUMN; yylval->op = st_i64; return OPCODE; }
{st_vec}          { HANDLE_COLUMN; yylval->op = st_vec; return OPCODE; }
{sub_i64}         { HANDLE_COLUMN; yylval->op = sub_i64; return OPCODE; }
{sub_vec}         { HANDLE_COLUMN; yylval->op = sub_vec; return OPCODE; }
{umax_vec}        { HANDLE_COLUMN; yylval->op = umax_vec; return OPCODE; }
{umin_vec}        { HANDLE_COLUMN; yylval->op = umin_vec; return OPCODE; }
{xor_i64}         { HANDLE_COLUMN; yylval->op = xor_i64; return OPCODE; }
{xor_vec}         { HANDLE_COLUMN; yylval->op = xor_vec; return OPCODE; }
{BSWAP64}         { HANDLE_COLUMN; yylval->op = bswap64_i64; return BSWAP64; }
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
