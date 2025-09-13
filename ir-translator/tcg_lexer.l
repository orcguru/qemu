%{
#include "tcg_ast.h"
#include "tcg_parser.tab.h"
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
void reduce_imm_force(char *ptr);
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

XMMVAR          (XMM[0-9]+)
XMMTMP          XMM_t0
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
ge              ge
gt              gt
le              le
lt              lt
geu             geu
gtu             gtu
leu             leu
ltu             ltu
ne              ne
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
aad                 aad
aam                 aam
call_ind            call_ind
cc_compute_all      cc_compute_all
cc_compute_c        cc_compute_c
cc_compute_nz       cc_compute_nz
cpuid               cpuid
divl_EAX            divl_EAX
divq_EAX            divq_EAX
divss               divss
emms                emms
enter_mmx           enter_mmx
fabs_ST0            fabs_ST0
fadd_ST0_FT0        fadd_ST0_FT0
fildl_FT0           fildl_FT0
fldenv              fldenv
fldl_FT0            fldl_FT0
flds_FT0            flds_FT0
fldt_ST0            fldt_ST0
fmov_FT0_STN        fmov_FT0_STN
fmov_ST0_STN        fmov_ST0_STN
fmov_STN_ST0        fmov_STN_ST0
fnstcw              fnstcw
fnstsw              fnstsw
fpop                fpop
fpush               fpush
frstor              frstor
fstenv              fstenv
fstt_ST0            fstt_ST0
fsub_ST0_FT0        fsub_ST0_FT0
fucomi_ST0_FT0      fucomi_ST0_FT0
fwait               fwait
fxam_ST0            fxam_ST0
fxchg_ST0_STN       fxchg_ST0_STN
fxrstor             fxrstor
fxsave              fxsave
icebp               icebp
idivl_EAX           idivl_EAX
idivq_EAX           idivq_EAX
iret_ind            iret_ind
iret_protected      iret_protected
jmp_ind             jmp_ind
ljmp_protected      ljmp_protected
load_seg            load_seg
lret_protected      lret_protected
memset              memset
movmskpd_xmm        movmskpd_xmm
movmskps_xmm        movmskps_xmm
palignr_xmm         palignr_xmm
pause               pause
pcmpistri_xmm       pcmpistri_xmm
pshufb_xmm          pshufb_xmm
pshufd_xmm          pshufd_xmm
pslldq_xmm          pslldq_xmm
psrldq_xmm          psrldq_xmm
punpckhdq_xmm       punpckhdq_xmm
punpckhqdq_xmm      punpckhqdq_xmm
punpcklbw_xmm       punpcklbw_xmm
punpckldq_mmx       punpckldq_mmx
punpckldq_xmm       punpckldq_xmm
punpcklqdq_xmm      punpcklqdq_xmm
punpcklwd_mmx       punpcklwd_mmx
punpcklwd_xmm       punpcklwd_xmm
raise_exception     raise_exception
raise_interrupt     raise_interrupt
rdtsc               rdtsc
shufpd_xmm          shufpd_xmm
shufps_xmm          shufps_xmm
syscall             syscall
ucomisd             ucomisd
update_mxcsr        update_mxcsr
xgetbv              xgetbv
xrstor              xrstor
xsave               xsave
dump_load           dump_load
dump_store          dump_store

%%

{XMMVAR}          { HANDLE_COLUMN; yylval->val = atoi(yytext + 3); return XMMVAR; }
{XMMTMP}          { HANDLE_COLUMN; return XMMTMP; }
{TMPLVAR}         { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_TMPL; yylval->si.s.slot_idx = atoi(yytext + 3); return SLOT; }
{TMPTVAR}         { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_TMPT; yylval->si.s.slot_idx = atoi(yytext + 3); return SLOT; }
{IMMX}            { HANDLE_COLUMN; errno = 0; yylval->val = strtoll(yytext + 1, NULL, 16); if (errno == ERANGE) { reduce_imm_force(yytext + 1); yylval->val = strtoll(yytext + 1, NULL, 16); yylval->val += 0x8000000000000000UL; } return IMMX; }
{IMMD}            { HANDLE_COLUMN; errno = 0; yylval->val = strtoll(yytext + 1, NULL, 10); assert(!errno); return IMMD; }
{NUM}             { HANDLE_COLUMN; yylval->val = atoi(yytext); return NUM; }
{LABEL}           { HANDLE_COLUMN; yylval->val = atoi(yytext + 2); return LABEL; }
{noat}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ATOMIC; yylval->ai.p.storage.attr.atomic = NONATOMIC; return MEMATTR; }
{un}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ALIGNMENT; yylval->ai.p.storage.attr.alignment = UNALIGN; return MEMATTR; }
{al}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ALIGNMENT; yylval->ai.p.storage.attr.alignment = ALIGN_MEM_SIZE; return MEMATTR; }
{al16}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ALIGNMENT; yylval->ai.p.storage.attr.alignment = ALIGN_16; return MEMATTR; }
{al32}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ALIGNMENT; yylval->ai.p.storage.attr.alignment = ALIGN_32; return MEMATTR; }
{sb}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = SIGN; yylval->ai.p.storage.size = SRC1B; return MEMATTR; }
{lesw}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = SIGN; yylval->ai.p.storage.size = SRC2B; return MEMATTR; }
{lesl}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = SIGN; yylval->ai.p.storage.size = SRC4B; return MEMATTR; }
{ub}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = ZERO; yylval->ai.p.storage.size = SRC1B; return MEMATTR; }
{leuw}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = ZERO; yylval->ai.p.storage.size = SRC2B; return MEMATTR; }
{leul}            { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = ZERO; yylval->ai.p.storage.size = SRC4B; return MEMATTR; }
{leq}             { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = ZERO; yylval->ai.p.storage.size = SRC8B; return MEMATTR; }
{leo}             { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SRCSIZEEXT; yylval->ai.p.storage.attr.ext = ZERO; yylval->ai.p.storage.size = SRC16B; return MEMATTR; }
{cc_src2}         { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_ENVVAR; yylval->si.s.slot_idx = cc_src2; return SLOT; }
{es_base}         { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_ENVVAR; yylval->si.s.slot_idx = es_base; return SLOT; }
{cs_base}         { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_ENVVAR; yylval->si.s.slot_idx = cs_base; return SLOT; }
{ss_base}         { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_ENVVAR; yylval->si.s.slot_idx = ss_base; return SLOT; }
{ds_base}         { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_ENVVAR; yylval->si.s.slot_idx = ds_base; return SLOT; }
{fs_base}         { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_ENVVAR; yylval->si.s.slot_idx = fs_base; return SLOT; }
{gs_base}         { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_ENVVAR; yylval->si.s.slot_idx = gs_base; return SLOT; }
{rax}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = rax; return SLOT; }
{rcx}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = rcx; return SLOT; }
{rdx}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = rdx; return SLOT; }
{rbx}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = rbx; return SLOT; }
{rsp}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = rsp; return SLOT; }
{rbp}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = rbp; return SLOT; }
{rsi}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = rsi; return SLOT; }
{rdi}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = rdi; return SLOT; }
{r8}              { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = r8; return SLOT; }
{r9}              { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = r9; return SLOT; }
{r10}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = r10; return SLOT; }
{r11}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = r11; return SLOT; }
{r12}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = r12; return SLOT; }
{r13}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = r13; return SLOT; }
{r14}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = r14; return SLOT; }
{r15}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = r15; return SLOT; }
{cc_src}          { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = cc_src; return SLOT; }
{cc_dst}          { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = cc_dst; return SLOT; }
{cc_op}           { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = cc_op; return SLOT; }
{rip}             { HANDLE_COLUMN; yylval->si.s.slot_type = SUB_SLOT_XREG; yylval->si.s.slot_idx = rip; return SLOT; }
{eq}              { HANDLE_COLUMN; yylval->r = eq; return RELOP; }
{ge}              { HANDLE_COLUMN; yylval->r = ge; return RELOP; }
{gt}              { HANDLE_COLUMN; yylval->r = gt; return RELOP; }
{le}              { HANDLE_COLUMN; yylval->r = le; return RELOP; }
{lt}              { HANDLE_COLUMN; yylval->r = lt; return RELOP; }
{geu}             { HANDLE_COLUMN; yylval->r = geu; return RELOP; }
{gtu}             { HANDLE_COLUMN; yylval->r = gtu; return RELOP; }
{leu}             { HANDLE_COLUMN; yylval->r = leu; return RELOP; }
{ltu}             { HANDLE_COLUMN; yylval->r = ltu; return RELOP; }
{ne}              { HANDLE_COLUMN; yylval->r = ne; return RELOP; }
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
{E8}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ELEMENTSIZE; yylval->ai.p.ves = VES8; return ELEMENTSIZEATTR; }
{E16}             { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ELEMENTSIZE; yylval->ai.p.ves = VES16; return ELEMENTSIZEATTR; }
{E32}             { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ELEMENTSIZE; yylval->ai.p.ves = VES32; return ELEMENTSIZEATTR; }
{E64}             { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_ELEMENTSIZE; yylval->ai.p.ves = VES64; return ELEMENTSIZEATTR; }
{OZ}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SWAP; yylval->ai.p.swap = OZ; return SWAPATTR; }
{IZ}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SWAP; yylval->ai.p.swap = IZ; return SWAPATTR; }
{OS}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SWAP; yylval->ai.p.swap = OS; return SWAPATTR; }
{IS}              { HANDLE_COLUMN; yylval->ai.subt = SUB_ATTR_SWAP; yylval->ai.p.swap = IS; return SWAPATTR; }
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

{aad}               { HANDLE_COLUMN; yylval->h = aad; return HELPER; }
{aam}               { HANDLE_COLUMN; yylval->h = aam; return HELPER; }
{call_ind}          { HANDLE_COLUMN; yylval->h = call_ind; return HELPER; }
{cc_compute_all}    { HANDLE_COLUMN; yylval->h = cc_compute_all; return HELPER; }
{cc_compute_c}      { HANDLE_COLUMN; yylval->h = cc_compute_c; return HELPER; }
{cc_compute_nz}     { HANDLE_COLUMN; yylval->h = cc_compute_nz; return HELPER; }
{cpuid}             { HANDLE_COLUMN; yylval->h = cpuid; return HELPER; }
{divl_EAX}          { HANDLE_COLUMN; yylval->h = divl_EAX; return HELPER; }
{divq_EAX}          { HANDLE_COLUMN; yylval->h = divq_EAX; return HELPER; }
{divss}             { HANDLE_COLUMN; yylval->h = divss; return HELPER; }
{emms}              { HANDLE_COLUMN; yylval->h = emms; return HELPER; }
{enter_mmx}         { HANDLE_COLUMN; yylval->h = enter_mmx; return HELPER; }
{fabs_ST0}          { HANDLE_COLUMN; yylval->h = fabs_ST0; return HELPER; }
{fadd_ST0_FT0}      { HANDLE_COLUMN; yylval->h = fadd_ST0_FT0; return HELPER; }
{fildl_FT0}         { HANDLE_COLUMN; yylval->h = fildl_FT0; return HELPER; }
{fldenv}            { HANDLE_COLUMN; yylval->h = fldenv; return HELPER; }
{fldl_FT0}          { HANDLE_COLUMN; yylval->h = fldl_FT0; return HELPER; }
{flds_FT0}          { HANDLE_COLUMN; yylval->h = flds_FT0; return HELPER; }
{fldt_ST0}          { HANDLE_COLUMN; yylval->h = fldt_ST0; return HELPER; }
{fmov_FT0_STN}      { HANDLE_COLUMN; yylval->h = fmov_FT0_STN; return HELPER; }
{fmov_ST0_STN}      { HANDLE_COLUMN; yylval->h = fmov_ST0_STN; return HELPER; }
{fmov_STN_ST0}      { HANDLE_COLUMN; yylval->h = fmov_STN_ST0; return HELPER; }
{fnstcw}            { HANDLE_COLUMN; yylval->h = fnstcw; return HELPER; }
{fnstsw}            { HANDLE_COLUMN; yylval->h = fnstsw; return HELPER; }
{fpop}              { HANDLE_COLUMN; yylval->h = fpop; return HELPER; }
{fpush}             { HANDLE_COLUMN; yylval->h = fpush; return HELPER; }
{frstor}            { HANDLE_COLUMN; yylval->h = frstor; return HELPER; }
{fstenv}            { HANDLE_COLUMN; yylval->h = fstenv; return HELPER; }
{fstt_ST0}          { HANDLE_COLUMN; yylval->h = fstt_ST0; return HELPER; }
{fsub_ST0_FT0}      { HANDLE_COLUMN; yylval->h = fsub_ST0_FT0; return HELPER; }
{fucomi_ST0_FT0}    { HANDLE_COLUMN; yylval->h = fucomi_ST0_FT0; return HELPER; }
{fwait}             { HANDLE_COLUMN; yylval->h = fwait; return HELPER; }
{fxam_ST0}          { HANDLE_COLUMN; yylval->h = fxam_ST0; return HELPER; }
{fxchg_ST0_STN}     { HANDLE_COLUMN; yylval->h = fxchg_ST0_STN; return HELPER; }
{fxrstor}           { HANDLE_COLUMN; yylval->h = fxrstor; return HELPER; }
{fxsave}            { HANDLE_COLUMN; yylval->h = fxsave; return HELPER; }
{icebp}             { HANDLE_COLUMN; yylval->h = icebp; return HELPER; }
{idivl_EAX}         { HANDLE_COLUMN; yylval->h = idivl_EAX; return HELPER; }
{idivq_EAX}         { HANDLE_COLUMN; yylval->h = idivq_EAX; return HELPER; }
{iret_ind}          { HANDLE_COLUMN; yylval->h = iret_ind; return HELPER; }
{iret_protected}    { HANDLE_COLUMN; yylval->h = iret_protected; return HELPER; }
{jmp_ind}           { HANDLE_COLUMN; yylval->h = jmp_ind; return HELPER; }
{ljmp_protected}    { HANDLE_COLUMN; yylval->h = ljmp_protected; return HELPER; }
{load_seg}          { HANDLE_COLUMN; yylval->h = load_seg; return HELPER; }
{lret_protected}    { HANDLE_COLUMN; yylval->h = lret_protected; return HELPER; }
{memset}            { HANDLE_COLUMN; yylval->h = helper_memset; return HELPER; }
{movmskpd_xmm}      { HANDLE_COLUMN; yylval->h = movmskpd_xmm; return HELPER; }
{movmskps_xmm}      { HANDLE_COLUMN; yylval->h = movmskps_xmm; return HELPER; }
{palignr_xmm}       { HANDLE_COLUMN; yylval->h = palignr_xmm; return HELPER; }
{pause}             { HANDLE_COLUMN; yylval->h = helper_pause; return HELPER; }
{pcmpistri_xmm}     { HANDLE_COLUMN; yylval->h = pcmpistri_xmm; return HELPER; }
{pshufb_xmm}        { HANDLE_COLUMN; yylval->h = pshufb_xmm; return HELPER; }
{pshufd_xmm}        { HANDLE_COLUMN; yylval->h = pshufd_xmm; return HELPER; }
{pslldq_xmm}        { HANDLE_COLUMN; yylval->h = pslldq_xmm; return HELPER; }
{psrldq_xmm}        { HANDLE_COLUMN; yylval->h = psrldq_xmm; return HELPER; }
{punpckhdq_xmm}     { HANDLE_COLUMN; yylval->h = punpckhdq_xmm; return HELPER; }
{punpckhqdq_xmm}    { HANDLE_COLUMN; yylval->h = punpckhqdq_xmm; return HELPER; }
{punpcklbw_xmm}     { HANDLE_COLUMN; yylval->h = punpcklbw_xmm; return HELPER; }
{punpckldq_mmx}     { HANDLE_COLUMN; yylval->h = punpckldq_mmx; return HELPER; }
{punpckldq_xmm}     { HANDLE_COLUMN; yylval->h = punpckldq_xmm; return HELPER; }
{punpcklqdq_xmm}    { HANDLE_COLUMN; yylval->h = punpcklqdq_xmm; return HELPER; }
{punpcklwd_mmx}     { HANDLE_COLUMN; yylval->h = punpcklwd_mmx; return HELPER; }
{punpcklwd_xmm}     { HANDLE_COLUMN; yylval->h = punpcklwd_xmm; return HELPER; }
{raise_exception}   { HANDLE_COLUMN; yylval->h = raise_exception; return HELPER; }
{raise_interrupt}   { HANDLE_COLUMN; yylval->h = raise_interrupt; return HELPER; }
{rdtsc}             { HANDLE_COLUMN; yylval->h = rdtsc; return HELPER; }
{shufpd_xmm}        { HANDLE_COLUMN; yylval->h = shufpd_xmm; return HELPER; }
{shufps_xmm}        { HANDLE_COLUMN; yylval->h = shufps_xmm; return HELPER; }
{syscall}           { HANDLE_COLUMN; yylval->h = helper_syscall; return HELPER; }
{ucomisd}           { HANDLE_COLUMN; yylval->h = ucomisd; return HELPER; }
{update_mxcsr}      { HANDLE_COLUMN; yylval->h = update_mxcsr; return HELPER; }
{xgetbv}            { HANDLE_COLUMN; yylval->h = xgetbv; return HELPER; }
{xrstor}            { HANDLE_COLUMN; yylval->h = xrstor; return HELPER; }
{xsave}             { HANDLE_COLUMN; yylval->h = xsave; return HELPER; }
{dump_load}         { HANDLE_COLUMN; yylval->h = dump_load; return HELPER; }
{dump_store}        { HANDLE_COLUMN; yylval->h = dump_store; return HELPER; }
","               { HANDLE_COLUMN; return COMMA; }
":"               { HANDLE_COLUMN; return COLON; }
"+"               { HANDLE_COLUMN; return PLUS; }
\n                { next_column = 1; column = 1; }
[ \t]             ; // Ignore whitespace
%%
size_t min(size_t a, size_t b) {
    return b < a ? b : a;
}
void reduce_imm_force(char *ptr) {
    switch (ptr[2]) {
    case 'f':
    case 'F':
        ptr[2] = '7';
        break;
    case 'e':
    case 'E':
        ptr[2] = '6';
        break;
    case 'd':
    case 'D':
        ptr[2] = '5';
        break;
    case 'c':
    case 'C':
        ptr[2] = '4';
        break;
    case 'b':
    case 'B':
        ptr[2] = '3';
        break;
    case 'a':
    case 'A':
        ptr[2] = '2';
        break;
    case '9':
        ptr[2] = '1';
        break;
    case '8':
        ptr[2] = '0';
        break;
    default:
        assert(0);
    }
}
