%{
#include "tcg_ast.h"
#include "i386_cpu.h"
#include "tcg_parser.tab.h"
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
void yyerror(yyscan_t scanner, TcgContext *ctx, const char *s);
extern HelperType lookup_helper_enum(const char *str, size_t len);
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

#define SET_XREG(reg)                                          \
    do {                                                       \
        HANDLE_COLUMN;                                         \
        yylval->si.type       = SUB_SLOT_XREG;                 \
        yylval->si.idx        = (reg);                         \
        yylval->si.op_type    = env_regs_type[yylval->si.idx]; \
        yylval->si.stack_type = env_regs_type[yylval->si.idx]; \
        return SLOT;                                           \
    } while (0)
%}

%option nounput noinput noyywrap bison-bridge reentrant yylineno
%x CALL_STATE

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
unal            unal
al              al
al2             al2
al4             al4
al8             al8
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
ENV             env
V64             v64
V128            v128
E8              e8
E16             e16
E32             e32
E64             e64
OZ              oz
IZ              iz
OS              os
IS              is
INTERNAL        INTERNAL
EXTERNAL        EXTERNAL

aaa                             aaa
aad                             aad
aam                             aam
aas                             aas
abs_vec                         abs_vec
addc1o_i32                      addc1o_i32
addc1o_i64                      addc1o_i64
addci_i32                       addci_i32
addci_i64                       addci_i64
addcio_i32                      addcio_i32
addcio_i64                      addcio_i64
addco_i32                       addco_i32
addco_i64                       addco_i64
add_i32                         add_i32
add_i64                         add_i64
addpd_xmm                       addpd_xmm
addpd_ymm                       addpd_ymm
addps_xmm                       addps_xmm
addps_ymm                       addps_ymm
addsd                           addsd
addss                           addss
addsubpd_xmm                    addsubpd_xmm
addsubpd_ymm                    addsubpd_ymm
addsubps_xmm                    addsubps_xmm
addsubps_ymm                    addsubps_ymm
add_vec                         add_vec
aesdeclast_xmm                  aesdeclast_xmm
aesdeclast_ymm                  aesdeclast_ymm
aesdec_xmm                      aesdec_xmm
aesdec_ymm                      aesdec_ymm
aesenclast_xmm                  aesenclast_xmm
aesenclast_ymm                  aesenclast_ymm
aesenc_xmm                      aesenc_xmm
aesenc_ymm                      aesenc_ymm
aesimc_xmm                      aesimc_xmm
aeskeygenassist_xmm             aeskeygenassist_xmm
andc_i32                        andc_i32
andc_i64                        andc_i64
andc_vec                        andc_vec
and_i32                         and_i32
and_i64                         and_i64
and_vec                         and_vec
atomic_add_fetchb               atomic_add_fetchb
atomic_add_fetchl_be            atomic_add_fetchl_be
atomic_add_fetchl_le            atomic_add_fetchl_le
atomic_add_fetchq_be            atomic_add_fetchq_be
atomic_add_fetchq_le            atomic_add_fetchq_le
atomic_add_fetchw_be            atomic_add_fetchw_be
atomic_add_fetchw_le            atomic_add_fetchw_le
atomic_and_fetchb               atomic_and_fetchb
atomic_and_fetchl_be            atomic_and_fetchl_be
atomic_and_fetchl_le            atomic_and_fetchl_le
atomic_and_fetchq_be            atomic_and_fetchq_be
atomic_and_fetchq_le            atomic_and_fetchq_le
atomic_and_fetchw_be            atomic_and_fetchw_be
atomic_and_fetchw_le            atomic_and_fetchw_le
atomic_cmpxchgb                 atomic_cmpxchgb
atomic_cmpxchgl_be              atomic_cmpxchgl_be
atomic_cmpxchgl_le              atomic_cmpxchgl_le
atomic_cmpxchgo_be              atomic_cmpxchgo_be
atomic_cmpxchgo_le              atomic_cmpxchgo_le
atomic_cmpxchgq_be              atomic_cmpxchgq_be
atomic_cmpxchgq_le              atomic_cmpxchgq_le
atomic_cmpxchgw_be              atomic_cmpxchgw_be
atomic_cmpxchgw_le              atomic_cmpxchgw_le
atomic_fetch_addb               atomic_fetch_addb
atomic_fetch_addl_be            atomic_fetch_addl_be
atomic_fetch_addl_le            atomic_fetch_addl_le
atomic_fetch_addq_be            atomic_fetch_addq_be
atomic_fetch_addq_le            atomic_fetch_addq_le
atomic_fetch_addw_be            atomic_fetch_addw_be
atomic_fetch_addw_le            atomic_fetch_addw_le
atomic_fetch_andb               atomic_fetch_andb
atomic_fetch_andl_be            atomic_fetch_andl_be
atomic_fetch_andl_le            atomic_fetch_andl_le
atomic_fetch_andq_be            atomic_fetch_andq_be
atomic_fetch_andq_le            atomic_fetch_andq_le
atomic_fetch_andw_be            atomic_fetch_andw_be
atomic_fetch_andw_le            atomic_fetch_andw_le
atomic_fetch_orb                atomic_fetch_orb
atomic_fetch_orl_be             atomic_fetch_orl_be
atomic_fetch_orl_le             atomic_fetch_orl_le
atomic_fetch_orq_be             atomic_fetch_orq_be
atomic_fetch_orq_le             atomic_fetch_orq_le
atomic_fetch_orw_be             atomic_fetch_orw_be
atomic_fetch_orw_le             atomic_fetch_orw_le
atomic_fetch_smaxb              atomic_fetch_smaxb
atomic_fetch_smaxl_be           atomic_fetch_smaxl_be
atomic_fetch_smaxl_le           atomic_fetch_smaxl_le
atomic_fetch_smaxq_be           atomic_fetch_smaxq_be
atomic_fetch_smaxq_le           atomic_fetch_smaxq_le
atomic_fetch_smaxw_be           atomic_fetch_smaxw_be
atomic_fetch_smaxw_le           atomic_fetch_smaxw_le
atomic_fetch_sminb              atomic_fetch_sminb
atomic_fetch_sminl_be           atomic_fetch_sminl_be
atomic_fetch_sminl_le           atomic_fetch_sminl_le
atomic_fetch_sminq_be           atomic_fetch_sminq_be
atomic_fetch_sminq_le           atomic_fetch_sminq_le
atomic_fetch_sminw_be           atomic_fetch_sminw_be
atomic_fetch_sminw_le           atomic_fetch_sminw_le
atomic_fetch_umaxb              atomic_fetch_umaxb
atomic_fetch_umaxl_be           atomic_fetch_umaxl_be
atomic_fetch_umaxl_le           atomic_fetch_umaxl_le
atomic_fetch_umaxq_be           atomic_fetch_umaxq_be
atomic_fetch_umaxq_le           atomic_fetch_umaxq_le
atomic_fetch_umaxw_be           atomic_fetch_umaxw_be
atomic_fetch_umaxw_le           atomic_fetch_umaxw_le
atomic_fetch_uminb              atomic_fetch_uminb
atomic_fetch_uminl_be           atomic_fetch_uminl_be
atomic_fetch_uminl_le           atomic_fetch_uminl_le
atomic_fetch_uminq_be           atomic_fetch_uminq_be
atomic_fetch_uminq_le           atomic_fetch_uminq_le
atomic_fetch_uminw_be           atomic_fetch_uminw_be
atomic_fetch_uminw_le           atomic_fetch_uminw_le
atomic_fetch_xorb               atomic_fetch_xorb
atomic_fetch_xorl_be            atomic_fetch_xorl_be
atomic_fetch_xorl_le            atomic_fetch_xorl_le
atomic_fetch_xorq_be            atomic_fetch_xorq_be
atomic_fetch_xorq_le            atomic_fetch_xorq_le
atomic_fetch_xorw_be            atomic_fetch_xorw_be
atomic_fetch_xorw_le            atomic_fetch_xorw_le
atomic_or_fetchb                atomic_or_fetchb
atomic_or_fetchl_be             atomic_or_fetchl_be
atomic_or_fetchl_le             atomic_or_fetchl_le
atomic_or_fetchq_be             atomic_or_fetchq_be
atomic_or_fetchq_le             atomic_or_fetchq_le
atomic_or_fetchw_be             atomic_or_fetchw_be
atomic_or_fetchw_le             atomic_or_fetchw_le
atomic_smax_fetchb              atomic_smax_fetchb
atomic_smax_fetchl_be           atomic_smax_fetchl_be
atomic_smax_fetchl_le           atomic_smax_fetchl_le
atomic_smax_fetchq_be           atomic_smax_fetchq_be
atomic_smax_fetchq_le           atomic_smax_fetchq_le
atomic_smax_fetchw_be           atomic_smax_fetchw_be
atomic_smax_fetchw_le           atomic_smax_fetchw_le
atomic_smin_fetchb              atomic_smin_fetchb
atomic_smin_fetchl_be           atomic_smin_fetchl_be
atomic_smin_fetchl_le           atomic_smin_fetchl_le
atomic_smin_fetchq_be           atomic_smin_fetchq_be
atomic_smin_fetchq_le           atomic_smin_fetchq_le
atomic_smin_fetchw_be           atomic_smin_fetchw_be
atomic_smin_fetchw_le           atomic_smin_fetchw_le
atomic_umax_fetchb              atomic_umax_fetchb
atomic_umax_fetchl_be           atomic_umax_fetchl_be
atomic_umax_fetchl_le           atomic_umax_fetchl_le
atomic_umax_fetchq_be           atomic_umax_fetchq_be
atomic_umax_fetchq_le           atomic_umax_fetchq_le
atomic_umax_fetchw_be           atomic_umax_fetchw_be
atomic_umax_fetchw_le           atomic_umax_fetchw_le
atomic_umin_fetchb              atomic_umin_fetchb
atomic_umin_fetchl_be           atomic_umin_fetchl_be
atomic_umin_fetchl_le           atomic_umin_fetchl_le
atomic_umin_fetchq_be           atomic_umin_fetchq_be
atomic_umin_fetchq_le           atomic_umin_fetchq_le
atomic_umin_fetchw_be           atomic_umin_fetchw_be
atomic_umin_fetchw_le           atomic_umin_fetchw_le
atomic_xchgb                    atomic_xchgb
atomic_xchgl_be                 atomic_xchgl_be
atomic_xchgl_le                 atomic_xchgl_le
atomic_xchgq_be                 atomic_xchgq_be
atomic_xchgq_le                 atomic_xchgq_le
atomic_xchgw_be                 atomic_xchgw_be
atomic_xchgw_le                 atomic_xchgw_le
atomic_xor_fetchb               atomic_xor_fetchb
atomic_xor_fetchl_be            atomic_xor_fetchl_be
atomic_xor_fetchl_le            atomic_xor_fetchl_le
atomic_xor_fetchq_be            atomic_xor_fetchq_be
atomic_xor_fetchq_le            atomic_xor_fetchq_le
atomic_xor_fetchw_be            atomic_xor_fetchw_be
atomic_xor_fetchw_le            atomic_xor_fetchw_le
bitsel_vec                      bitsel_vec
blendpd_xmm                     blendpd_xmm
blendpd_ymm                     blendpd_ymm
blendps_xmm                     blendps_xmm
blendps_ymm                     blendps_ymm
blendvpd_xmm                    blendvpd_xmm
blendvpd_ymm                    blendvpd_ymm
blendvps_xmm                    blendvps_xmm
blendvps_ymm                    blendvps_ymm
bndck                           bndck
bnd_jmp                         bnd_jmp
bndldx32                        bndldx32
bndldx64                        bndldx64
bndstx32                        bndstx32
bndstx64                        bndstx64
boundl                          boundl
boundw                          boundw
br                              br
brcond_i32                      brcond_i32
brcond_i64                      brcond_i64
bswap16_i32                     bswap16_i32
bswap16_i64                     bswap16_i64
bswap32_i32                     bswap32_i32
bswap32_i64                     bswap32_i64
bswap64_i64                     bswap64_i64
call                            call
cc_compute_all                  cc_compute_all
cc_compute_c                    cc_compute_c
cc_compute_nz                   cc_compute_nz
clrsb_i32                       clrsb_i32
clrsb_i64                       clrsb_i64
clts                            clts
clz_i32                         clz_i32
clz_i64                         clz_i64
cmpeqpd_xmm                     cmpeqpd_xmm
cmpeqpd_ymm                     cmpeqpd_ymm
cmpeqps_xmm                     cmpeqps_xmm
cmpeqps_ymm                     cmpeqps_ymm
cmpeqsd                         cmpeqsd
cmpeqspd_xmm                    cmpeqspd_xmm
cmpeqspd_ymm                    cmpeqspd_ymm
cmpeqsps_xmm                    cmpeqsps_xmm
cmpeqsps_ymm                    cmpeqsps_ymm
cmpeqss                         cmpeqss
cmpeqssd                        cmpeqssd
cmpeqsss                        cmpeqsss
cmpequpd_xmm                    cmpequpd_xmm
cmpequpd_ymm                    cmpequpd_ymm
cmpequps_xmm                    cmpequps_xmm
cmpequps_ymm                    cmpequps_ymm
cmpequsd                        cmpequsd
cmpequspd_xmm                   cmpequspd_xmm
cmpequspd_ymm                   cmpequspd_ymm
cmpequsps_xmm                   cmpequsps_xmm
cmpequsps_ymm                   cmpequsps_ymm
cmpequss                        cmpequss
cmpequssd                       cmpequssd
cmpequsss                       cmpequsss
cmpfalsepd_xmm                  cmpfalsepd_xmm
cmpfalsepd_ymm                  cmpfalsepd_ymm
cmpfalseps_xmm                  cmpfalseps_xmm
cmpfalseps_ymm                  cmpfalseps_ymm
cmpfalsesd                      cmpfalsesd
cmpfalsespd_xmm                 cmpfalsespd_xmm
cmpfalsespd_ymm                 cmpfalsespd_ymm
cmpfalsesps_xmm                 cmpfalsesps_xmm
cmpfalsesps_ymm                 cmpfalsesps_ymm
cmpfalsess                      cmpfalsess
cmpfalsessd                     cmpfalsessd
cmpfalsesss                     cmpfalsesss
cmpgepd_xmm                     cmpgepd_xmm
cmpgepd_ymm                     cmpgepd_ymm
cmpgeps_xmm                     cmpgeps_xmm
cmpgeps_ymm                     cmpgeps_ymm
cmpgeqpd_xmm                    cmpgeqpd_xmm
cmpgeqpd_ymm                    cmpgeqpd_ymm
cmpgeqps_xmm                    cmpgeqps_xmm
cmpgeqps_ymm                    cmpgeqps_ymm
cmpgeqsd                        cmpgeqsd
cmpgeqss                        cmpgeqss
cmpgesd                         cmpgesd
cmpgess                         cmpgess
cmpgtpd_xmm                     cmpgtpd_xmm
cmpgtpd_ymm                     cmpgtpd_ymm
cmpgtps_xmm                     cmpgtps_xmm
cmpgtps_ymm                     cmpgtps_ymm
cmpgtqpd_xmm                    cmpgtqpd_xmm
cmpgtqpd_ymm                    cmpgtqpd_ymm
cmpgtqps_xmm                    cmpgtqps_xmm
cmpgtqps_ymm                    cmpgtqps_ymm
cmpgtqsd                        cmpgtqsd
cmpgtqss                        cmpgtqss
cmpgtsd                         cmpgtsd
cmpgtss                         cmpgtss
cmplepd_xmm                     cmplepd_xmm
cmplepd_ymm                     cmplepd_ymm
cmpleps_xmm                     cmpleps_xmm
cmpleps_ymm                     cmpleps_ymm
cmpleqpd_xmm                    cmpleqpd_xmm
cmpleqpd_ymm                    cmpleqpd_ymm
cmpleqps_xmm                    cmpleqps_xmm
cmpleqps_ymm                    cmpleqps_ymm
cmpleqsd                        cmpleqsd
cmpleqss                        cmpleqss
cmplesd                         cmplesd
cmpless                         cmpless
cmpltpd_xmm                     cmpltpd_xmm
cmpltpd_ymm                     cmpltpd_ymm
cmpltps_xmm                     cmpltps_xmm
cmpltps_ymm                     cmpltps_ymm
cmpltqpd_xmm                    cmpltqpd_xmm
cmpltqpd_ymm                    cmpltqpd_ymm
cmpltqps_xmm                    cmpltqps_xmm
cmpltqps_ymm                    cmpltqps_ymm
cmpltqsd                        cmpltqsd
cmpltqss                        cmpltqss
cmpltsd                         cmpltsd
cmpltss                         cmpltss
cmpneqpd_xmm                    cmpneqpd_xmm
cmpneqpd_ymm                    cmpneqpd_ymm
cmpneqps_xmm                    cmpneqps_xmm
cmpneqps_ymm                    cmpneqps_ymm
cmpneqqpd_xmm                   cmpneqqpd_xmm
cmpneqqpd_ymm                   cmpneqqpd_ymm
cmpneqqps_xmm                   cmpneqqps_xmm
cmpneqqps_ymm                   cmpneqqps_ymm
cmpneqqsd                       cmpneqqsd
cmpneqqss                       cmpneqqss
cmpneqsd                        cmpneqsd
cmpneqss                        cmpneqss
cmpnequpd_xmm                   cmpnequpd_xmm
cmpnequpd_ymm                   cmpnequpd_ymm
cmpnequps_xmm                   cmpnequps_xmm
cmpnequps_ymm                   cmpnequps_ymm
cmpnequsd                       cmpnequsd
cmpnequspd_xmm                  cmpnequspd_xmm
cmpnequspd_ymm                  cmpnequspd_ymm
cmpnequsps_xmm                  cmpnequsps_xmm
cmpnequsps_ymm                  cmpnequsps_ymm
cmpnequss                       cmpnequss
cmpnequssd                      cmpnequssd
cmpnequsss                      cmpnequsss
cmpngepd_xmm                    cmpngepd_xmm
cmpngepd_ymm                    cmpngepd_ymm
cmpngeps_xmm                    cmpngeps_xmm
cmpngeps_ymm                    cmpngeps_ymm
cmpngeqpd_xmm                   cmpngeqpd_xmm
cmpngeqpd_ymm                   cmpngeqpd_ymm
cmpngeqps_xmm                   cmpngeqps_xmm
cmpngeqps_ymm                   cmpngeqps_ymm
cmpngeqsd                       cmpngeqsd
cmpngeqss                       cmpngeqss
cmpngesd                        cmpngesd
cmpngess                        cmpngess
cmpngtpd_xmm                    cmpngtpd_xmm
cmpngtpd_ymm                    cmpngtpd_ymm
cmpngtps_xmm                    cmpngtps_xmm
cmpngtps_ymm                    cmpngtps_ymm
cmpngtqpd_xmm                   cmpngtqpd_xmm
cmpngtqpd_ymm                   cmpngtqpd_ymm
cmpngtqps_xmm                   cmpngtqps_xmm
cmpngtqps_ymm                   cmpngtqps_ymm
cmpngtqsd                       cmpngtqsd
cmpngtqss                       cmpngtqss
cmpngtsd                        cmpngtsd
cmpngtss                        cmpngtss
cmpnlepd_xmm                    cmpnlepd_xmm
cmpnlepd_ymm                    cmpnlepd_ymm
cmpnleps_xmm                    cmpnleps_xmm
cmpnleps_ymm                    cmpnleps_ymm
cmpnleqpd_xmm                   cmpnleqpd_xmm
cmpnleqpd_ymm                   cmpnleqpd_ymm
cmpnleqps_xmm                   cmpnleqps_xmm
cmpnleqps_ymm                   cmpnleqps_ymm
cmpnleqsd                       cmpnleqsd
cmpnleqss                       cmpnleqss
cmpnlesd                        cmpnlesd
cmpnless                        cmpnless
cmpnltpd_xmm                    cmpnltpd_xmm
cmpnltpd_ymm                    cmpnltpd_ymm
cmpnltps_xmm                    cmpnltps_xmm
cmpnltps_ymm                    cmpnltps_ymm
cmpnltqpd_xmm                   cmpnltqpd_xmm
cmpnltqpd_ymm                   cmpnltqpd_ymm
cmpnltqps_xmm                   cmpnltqps_xmm
cmpnltqps_ymm                   cmpnltqps_ymm
cmpnltqsd                       cmpnltqsd
cmpnltqss                       cmpnltqss
cmpnltsd                        cmpnltsd
cmpnltss                        cmpnltss
cmpordpd_xmm                    cmpordpd_xmm
cmpordpd_ymm                    cmpordpd_ymm
cmpordps_xmm                    cmpordps_xmm
cmpordps_ymm                    cmpordps_ymm
cmpordsd                        cmpordsd
cmpordspd_xmm                   cmpordspd_xmm
cmpordspd_ymm                   cmpordspd_ymm
cmpordsps_xmm                   cmpordsps_xmm
cmpordsps_ymm                   cmpordsps_ymm
cmpordss                        cmpordss
cmpordssd                       cmpordssd
cmpordsss                       cmpordsss
cmpsel_vec                      cmpsel_vec
cmptruepd_xmm                   cmptruepd_xmm
cmptruepd_ymm                   cmptruepd_ymm
cmptrueps_xmm                   cmptrueps_xmm
cmptrueps_ymm                   cmptrueps_ymm
cmptruesd                       cmptruesd
cmptruespd_xmm                  cmptruespd_xmm
cmptruespd_ymm                  cmptruespd_ymm
cmptruesps_xmm                  cmptruesps_xmm
cmptruesps_ymm                  cmptruesps_ymm
cmptruess                       cmptruess
cmptruessd                      cmptruessd
cmptruesss                      cmptruesss
cmpunordpd_xmm                  cmpunordpd_xmm
cmpunordpd_ymm                  cmpunordpd_ymm
cmpunordps_xmm                  cmpunordps_xmm
cmpunordps_ymm                  cmpunordps_ymm
cmpunordsd                      cmpunordsd
cmpunordspd_xmm                 cmpunordspd_xmm
cmpunordspd_ymm                 cmpunordspd_ymm
cmpunordsps_xmm                 cmpunordsps_xmm
cmpunordsps_ymm                 cmpunordsps_ymm
cmpunordss                      cmpunordss
cmpunordssd                     cmpunordssd
cmpunordsss                     cmpunordsss
cmp_vec                         cmp_vec
comisd                          comisd
comiss                          comiss
cpuid                           cpuid
cr4_testbit                     cr4_testbit
crc32                           crc32
ctpop_i32                       ctpop_i32
ctpop_i64                       ctpop_i64
ctz_i32                         ctz_i32
ctz_i64                         ctz_i64
cvtdq2pd_xmm                    cvtdq2pd_xmm
cvtdq2pd_ymm                    cvtdq2pd_ymm
cvtdq2ps_xmm                    cvtdq2ps_xmm
cvtdq2ps_ymm                    cvtdq2ps_ymm
cvtpd2dq_xmm                    cvtpd2dq_xmm
cvtpd2dq_ymm                    cvtpd2dq_ymm
cvtpd2pi                        cvtpd2pi
cvtpd2ps_xmm                    cvtpd2ps_xmm
cvtpd2ps_ymm                    cvtpd2ps_ymm
cvtph2ps_xmm                    cvtph2ps_xmm
cvtph2ps_ymm                    cvtph2ps_ymm
cvtpi2pd                        cvtpi2pd
cvtpi2ps                        cvtpi2ps
cvtps2dq_xmm                    cvtps2dq_xmm
cvtps2dq_ymm                    cvtps2dq_ymm
cvtps2pd_xmm                    cvtps2pd_xmm
cvtps2pd_ymm                    cvtps2pd_ymm
cvtps2ph_xmm                    cvtps2ph_xmm
cvtps2ph_ymm                    cvtps2ph_ymm
cvtps2pi                        cvtps2pi
cvtsd2si                        cvtsd2si
cvtsd2sq                        cvtsd2sq
cvtsd2ss                        cvtsd2ss
cvtsi2sd                        cvtsi2sd
cvtsi2ss                        cvtsi2ss
cvtsq2sd                        cvtsq2sd
cvtsq2ss                        cvtsq2ss
cvtss2sd                        cvtss2sd
cvtss2si                        cvtss2si
cvtss2sq                        cvtss2sq
cvttpd2dq_xmm                   cvttpd2dq_xmm
cvttpd2dq_ymm                   cvttpd2dq_ymm
cvttpd2pi                       cvttpd2pi
cvttps2dq_xmm                   cvttps2dq_xmm
cvttps2dq_ymm                   cvttps2dq_ymm
cvttps2pi                       cvttps2pi
cvttsd2si                       cvttsd2si
cvttsd2sq                       cvttsd2sq
cvttss2si                       cvttss2si
cvttss2sq                       cvttss2sq
daa                             daa
das                             das
deposit_i32                     deposit_i32
deposit_i64                     deposit_i64
discard                         discard
divb_AL                         divb_AL
div_i32                         div_i32
div_i64                         div_i64
divl_EAX                        divl_EAX
divpd_xmm                       divpd_xmm
divpd_ymm                       divpd_ymm
divps_xmm                       divps_xmm
divps_ymm                       divps_ymm
divq_EAX                        divq_EAX
divs2_i32                       divs2_i32
divs2_i64                       divs2_i64
divsd                           divsd
divs_i32                        divs_i32
divs_i64                        divs_i64
divss                           divss
divu2_i32                       divu2_i32
divu2_i64                       divu2_i64
divu_i32                        divu_i32
divu_i64                        divu_i64
divw_AX                         divw_AX
dppd_xmm                        dppd_xmm
dpps_xmm                        dpps_xmm
dpps_ymm                        dpps_ymm
dump_registers                  dump_registers
dump_load                       dump_load
dump_store                      dump_store
dupm_vec                        dupm_vec
dup_vec                         dup_vec
emms                            emms
enter_mmx                       enter_mmx
eqv_i32                         eqv_i32
eqv_i64                         eqv_i64
eqv_vec                         eqv_vec
exit_atomic                     exit_atomic
ext_i32_i64                     ext_i32_i64
extract2_i32                    extract2_i32
extract2_i64                    extract2_i64
extract_i32                     extract_i32
extract_i64                     extract_i64
extrh_i64_i32                   extrh_i64_i32
extrl_i64_i32                   extrl_i64_i32
extrq_i                         extrq_i
extrq_r                         extrq_r
extu_i32_i64                    extu_i32_i64
f2xm1                           f2xm1
fabs_ST0                        fabs_ST0
fadd_ST0_FT0                    fadd_ST0_FT0
fadd_STN_ST0                    fadd_STN_ST0
fbld_ST0                        fbld_ST0
fbst_ST0                        fbst_ST0
fchs_ST0                        fchs_ST0
fclex                           fclex
fcomi_ST0_FT0                   fcomi_ST0_FT0
fcom_ST0_FT0                    fcom_ST0_FT0
fcos                            fcos
fdecstp                         fdecstp
fdivr_ST0_FT0                   fdivr_ST0_FT0
fdivr_STN_ST0                   fdivr_STN_ST0
fdiv_ST0_FT0                    fdiv_ST0_FT0
fdiv_STN_ST0                    fdiv_STN_ST0
ffree_STN                       ffree_STN
fildl_FT0                       fildl_FT0
fildll_ST0                      fildll_ST0
fildl_ST0                       fildl_ST0
fincstp                         fincstp
fistll_ST0                      fistll_ST0
fistl_ST0                       fistl_ST0
fist_ST0                        fist_ST0
fisttll_ST0                     fisttll_ST0
fisttl_ST0                      fisttl_ST0
fistt_ST0                       fistt_ST0
fld1_ST0                        fld1_ST0
fldcw                           fldcw
fldenv                          fldenv
fldl2e_ST0                      fldl2e_ST0
fldl2t_ST0                      fldl2t_ST0
fldl_FT0                        fldl_FT0
fldlg2_ST0                      fldlg2_ST0
fldln2_ST0                      fldln2_ST0
fldl_ST0                        fldl_ST0
fldpi_ST0                       fldpi_ST0
flds_FT0                        flds_FT0
flds_ST0                        flds_ST0
fldt_ST0                        fldt_ST0
fldz_FT0                        fldz_FT0
fldz_ST0                        fldz_ST0
fma4pd_xmm                      fma4pd_xmm
fma4pd_ymm                      fma4pd_ymm
fma4ps_xmm                      fma4ps_xmm
fma4ps_ymm                      fma4ps_ymm
fma4sd                          fma4sd
fma4ss                          fma4ss
fmov_FT0_STN                    fmov_FT0_STN
fmov_ST0_FT0                    fmov_ST0_FT0
fmov_ST0_STN                    fmov_ST0_STN
fmov_STN_ST0                    fmov_STN_ST0
fmul_ST0_FT0                    fmul_ST0_FT0
fmul_STN_ST0                    fmul_STN_ST0
fninit                          fninit
fnstcw                          fnstcw
fnstsw                          fnstsw
fpatan                          fpatan
fpop                            fpop
fprem                           fprem
fprem1                          fprem1
fptan                           fptan
fpush                           fpush
frndint                         frndint
frstor                          frstor
fsave                           fsave
fscale                          fscale
fsin                            fsin
fsincos                         fsincos
fsqrt                           fsqrt
fstenv                          fstenv
fstl_ST0                        fstl_ST0
fsts_ST0                        fsts_ST0
fstt_ST0                        fstt_ST0
fsubr_ST0_FT0                   fsubr_ST0_FT0
fsubr_STN_ST0                   fsubr_STN_ST0
fsub_ST0_FT0                    fsub_ST0_FT0
fsub_STN_ST0                    fsub_STN_ST0
fucomi_ST0_FT0                  fucomi_ST0_FT0
fucom_ST0_FT0                   fucom_ST0_FT0
fwait                           fwait
fxam_ST0                        fxam_ST0
fxchg_ST0_STN                   fxchg_ST0_STN
fxrstor                         fxrstor
fxsave                          fxsave
fxtract                         fxtract
fyl2x                           fyl2x
fyl2xp1                         fyl2xp1
gvec_abs16                      gvec_abs16
gvec_abs32                      gvec_abs32
gvec_abs64                      gvec_abs64
gvec_abs8                       gvec_abs8
gvec_add16                      gvec_add16
gvec_add32                      gvec_add32
gvec_add64                      gvec_add64
gvec_add8                       gvec_add8
gvec_adds16                     gvec_adds16
gvec_adds32                     gvec_adds32
gvec_adds64                     gvec_adds64
gvec_adds8                      gvec_adds8
gvec_and                        gvec_and
gvec_andc                       gvec_andc
gvec_andcs                      gvec_andcs
gvec_ands                       gvec_ands
gvec_bitsel                     gvec_bitsel
gvec_dup16                      gvec_dup16
gvec_dup32                      gvec_dup32
gvec_dup64                      gvec_dup64
gvec_dup8                       gvec_dup8
gvec_eq16                       gvec_eq16
gvec_eq32                       gvec_eq32
gvec_eq64                       gvec_eq64
gvec_eq8                        gvec_eq8
gvec_eqs16                      gvec_eqs16
gvec_eqs32                      gvec_eqs32
gvec_eqs64                      gvec_eqs64
gvec_eqs8                       gvec_eqs8
gvec_eqv                        gvec_eqv
gvec_le16                       gvec_le16
gvec_le32                       gvec_le32
gvec_le64                       gvec_le64
gvec_le8                        gvec_le8
gvec_les16                      gvec_les16
gvec_les32                      gvec_les32
gvec_les64                      gvec_les64
gvec_les8                       gvec_les8
gvec_leu16                      gvec_leu16
gvec_leu32                      gvec_leu32
gvec_leu64                      gvec_leu64
gvec_leu8                       gvec_leu8
gvec_leus16                     gvec_leus16
gvec_leus32                     gvec_leus32
gvec_leus64                     gvec_leus64
gvec_leus8                      gvec_leus8
gvec_lt16                       gvec_lt16
gvec_lt32                       gvec_lt32
gvec_lt64                       gvec_lt64
gvec_lt8                        gvec_lt8
gvec_lts16                      gvec_lts16
gvec_lts32                      gvec_lts32
gvec_lts64                      gvec_lts64
gvec_lts8                       gvec_lts8
gvec_ltu16                      gvec_ltu16
gvec_ltu32                      gvec_ltu32
gvec_ltu64                      gvec_ltu64
gvec_ltu8                       gvec_ltu8
gvec_ltus16                     gvec_ltus16
gvec_ltus32                     gvec_ltus32
gvec_ltus64                     gvec_ltus64
gvec_ltus8                      gvec_ltus8
gvec_mov                        gvec_mov
gvec_mul16                      gvec_mul16
gvec_mul32                      gvec_mul32
gvec_mul64                      gvec_mul64
gvec_mul8                       gvec_mul8
gvec_muls16                     gvec_muls16
gvec_muls32                     gvec_muls32
gvec_muls64                     gvec_muls64
gvec_muls8                      gvec_muls8
gvec_nand                       gvec_nand
gvec_ne16                       gvec_ne16
gvec_ne32                       gvec_ne32
gvec_ne64                       gvec_ne64
gvec_ne8                        gvec_ne8
gvec_neg16                      gvec_neg16
gvec_neg32                      gvec_neg32
gvec_neg64                      gvec_neg64
gvec_neg8                       gvec_neg8
gvec_nor                        gvec_nor
gvec_not                        gvec_not
gvec_or                         gvec_or
gvec_orc                        gvec_orc
gvec_ors                        gvec_ors
gvec_rotl16i                    gvec_rotl16i
gvec_rotl16v                    gvec_rotl16v
gvec_rotl32i                    gvec_rotl32i
gvec_rotl32v                    gvec_rotl32v
gvec_rotl64i                    gvec_rotl64i
gvec_rotl64v                    gvec_rotl64v
gvec_rotl8i                     gvec_rotl8i
gvec_rotl8v                     gvec_rotl8v
gvec_rotr16v                    gvec_rotr16v
gvec_rotr32v                    gvec_rotr32v
gvec_rotr64v                    gvec_rotr64v
gvec_rotr8v                     gvec_rotr8v
gvec_sar16i                     gvec_sar16i
gvec_sar16v                     gvec_sar16v
gvec_sar32i                     gvec_sar32i
gvec_sar32v                     gvec_sar32v
gvec_sar64i                     gvec_sar64i
gvec_sar64v                     gvec_sar64v
gvec_sar8i                      gvec_sar8i
gvec_sar8v                      gvec_sar8v
gvec_shl16i                     gvec_shl16i
gvec_shl16v                     gvec_shl16v
gvec_shl32i                     gvec_shl32i
gvec_shl32v                     gvec_shl32v
gvec_shl64i                     gvec_shl64i
gvec_shl64v                     gvec_shl64v
gvec_shl8i                      gvec_shl8i
gvec_shl8v                      gvec_shl8v
gvec_shr16i                     gvec_shr16i
gvec_shr16v                     gvec_shr16v
gvec_shr32i                     gvec_shr32i
gvec_shr32v                     gvec_shr32v
gvec_shr64i                     gvec_shr64i
gvec_shr64v                     gvec_shr64v
gvec_shr8i                      gvec_shr8i
gvec_shr8v                      gvec_shr8v
gvec_smax16                     gvec_smax16
gvec_smax32                     gvec_smax32
gvec_smax64                     gvec_smax64
gvec_smax8                      gvec_smax8
gvec_smin16                     gvec_smin16
gvec_smin32                     gvec_smin32
gvec_smin64                     gvec_smin64
gvec_smin8                      gvec_smin8
gvec_ssadd16                    gvec_ssadd16
gvec_ssadd32                    gvec_ssadd32
gvec_ssadd64                    gvec_ssadd64
gvec_ssadd8                     gvec_ssadd8
gvec_sssub16                    gvec_sssub16
gvec_sssub32                    gvec_sssub32
gvec_sssub64                    gvec_sssub64
gvec_sssub8                     gvec_sssub8
gvec_sub16                      gvec_sub16
gvec_sub32                      gvec_sub32
gvec_sub64                      gvec_sub64
gvec_sub8                       gvec_sub8
gvec_subs16                     gvec_subs16
gvec_subs32                     gvec_subs32
gvec_subs64                     gvec_subs64
gvec_subs8                      gvec_subs8
gvec_umax16                     gvec_umax16
gvec_umax32                     gvec_umax32
gvec_umax64                     gvec_umax64
gvec_umax8                      gvec_umax8
gvec_umin16                     gvec_umin16
gvec_umin32                     gvec_umin32
gvec_umin64                     gvec_umin64
gvec_umin8                      gvec_umin8
gvec_usadd16                    gvec_usadd16
gvec_usadd32                    gvec_usadd32
gvec_usadd64                    gvec_usadd64
gvec_usadd8                     gvec_usadd8
gvec_ussub16                    gvec_ussub16
gvec_ussub32                    gvec_ussub32
gvec_ussub64                    gvec_ussub64
gvec_ussub8                     gvec_ussub8
gvec_xor                        gvec_xor
gvec_xors                       gvec_xors
haddpd_xmm                      haddpd_xmm
haddpd_ymm                      haddpd_ymm
haddps_xmm                      haddps_xmm
haddps_ymm                      haddps_ymm
hsubpd_xmm                      hsubpd_xmm
hsubpd_ymm                      hsubpd_ymm
hsubps_xmm                      hsubps_xmm
hsubps_ymm                      hsubps_ymm
icebp                           icebp
idivb_AL                        idivb_AL
idivl_EAX                       idivl_EAX
idivq_EAX                       idivq_EAX
idivw_AX                        idivw_AX
insertq_i                       insertq_i
insertq_r                       insertq_r
into                            into
iret_ind                        iret_ind
iret_protected                  iret_protected
iret_real                       iret_real
jmp_direct                      jmp_direct
jmp_ind                         jmp_ind
jumptable                       jumptable
lar                             lar
lcall_protected                 lcall_protected
lcall_real                      lcall_real
ld16s_i32                       ld16s_i32
ld16s_i64                       ld16s_i64
ld16u_i32                       ld16u_i32
ld16u_i64                       ld16u_i64
ld32s_i64                       ld32s_i64
ld32u_i64                       ld32u_i64
ld8s_i32                        ld8s_i32
ld8s_i64                        ld8s_i64
ld8u_i32                        ld8u_i32
ld8u_i64                        ld8u_i64
ld_i128                         ld_i128
ld_i32                          ld_i32
ld_i64                          ld_i64
ldmxcsr                         ldmxcsr
ld_vec                          ld_vec
ljmp_protected                  ljmp_protected
lldt                            lldt
load_seg                        load_seg
lookup_tb_ptr                   lookup_tb_ptr
lret_protected                  lret_protected
lsl                             lsl
ltr                             ltr
maskmov_mmx                     maskmov_mmx
maskmov_xmm                     maskmov_xmm
maxpd_xmm                       maxpd_xmm
maxpd_ymm                       maxpd_ymm
maxps_xmm                       maxps_xmm
maxps_ymm                       maxps_ymm
maxsd                           maxsd
maxss                           maxss
memset                          memset
minpd_xmm                       minpd_xmm
minpd_ymm                       minpd_ymm
minps_xmm                       minps_xmm
minps_ymm                       minps_ymm
minsd                           minsd
minss                           minss
movcond_i32                     movcond_i32
movcond_i64                     movcond_i64
movcond_vec                     movcond_vec
mov_i32                         mov_i32
mov_i64                         mov_i64
movmskpd_xmm                    movmskpd_xmm
movmskpd_ymm                    movmskpd_ymm
movmskps_xmm                    movmskps_xmm
movmskps_ymm                    movmskps_ymm
mov_vec                         mov_vec
mpsadbw_xmm                     mpsadbw_xmm
mpsadbw_ymm                     mpsadbw_ymm
mul_i32                         mul_i32
mul_i64                         mul_i64
mulpd_xmm                       mulpd_xmm
mulpd_ymm                       mulpd_ymm
mulps_xmm                       mulps_xmm
mulps_ymm                       mulps_ymm
muls2_i32                       muls2_i32
muls2_i64                       muls2_i64
mulsd                           mulsd
mulsh_i32                       mulsh_i32
mulsh_i64                       mulsh_i64
mulss                           mulss
mulu2_i32                       mulu2_i32
mulu2_i64                       mulu2_i64
muluh_i32                       muluh_i32
muluh_i64                       muluh_i64
mul_vec                         mul_vec
nand_i32                        nand_i32
nand_i64                        nand_i64
nand_vec                        nand_vec
neg_i32                         neg_i32
neg_i64                         neg_i64
negsetcond_i32                  negsetcond_i32
negsetcond_i64                  negsetcond_i64
neg_vec                         neg_vec
nonatomic_cmpxchgo              nonatomic_cmpxchgo
nor_i32                         nor_i32
nor_i64                         nor_i64
nor_vec                         nor_vec
not_i32                         not_i32
not_i64                         not_i64
not_vec                         not_vec
orc_i32                         orc_i32
orc_i64                         orc_i64
orc_vec                         orc_vec
or_i32                          or_i32
or_i64                          or_i64
or_vec                          or_vec
packssdw_mmx                    packssdw_mmx
packssdw_xmm                    packssdw_xmm
packssdw_ymm                    packssdw_ymm
packsswb_mmx                    packsswb_mmx
packsswb_xmm                    packsswb_xmm
packsswb_ymm                    packsswb_ymm
packusdw_xmm                    packusdw_xmm
packusdw_ymm                    packusdw_ymm
packuswb_mmx                    packuswb_mmx
packuswb_xmm                    packuswb_xmm
packuswb_ymm                    packuswb_ymm
palignr_mmx                     palignr_mmx
palignr_xmm                     palignr_xmm
palignr_ymm                     palignr_ymm
pause                           pause
pavgb_mmx                       pavgb_mmx
pavgb_xmm                       pavgb_xmm
pavgb_ymm                       pavgb_ymm
pavgw_mmx                       pavgw_mmx
pavgw_xmm                       pavgw_xmm
pavgw_ymm                       pavgw_ymm
pblendvb_xmm                    pblendvb_xmm
pblendvb_ymm                    pblendvb_ymm
pblendw_xmm                     pblendw_xmm
pblendw_ymm                     pblendw_ymm
pclmulqdq_xmm                   pclmulqdq_xmm
pclmulqdq_ymm                   pclmulqdq_ymm
pcmpestri_xmm                   pcmpestri_xmm
pcmpestrm_xmm                   pcmpestrm_xmm
pcmpistri_xmm                   pcmpistri_xmm
pcmpistrm_xmm                   pcmpistrm_xmm
pdep                            pdep
pext                            pext
pf2id                           pf2id
pf2iw                           pf2iw
pfacc                           pfacc
pfadd                           pfadd
pfcmpeq                         pfcmpeq
pfcmpge                         pfcmpge
pfcmpgt                         pfcmpgt
pfmax                           pfmax
pfmin                           pfmin
pfmul                           pfmul
pfnacc                          pfnacc
pfpnacc                         pfpnacc
pfrcp                           pfrcp
pfrsqrt                         pfrsqrt
pfsub                           pfsub
pfsubr                          pfsubr
phaddd_mmx                      phaddd_mmx
phaddd_xmm                      phaddd_xmm
phaddd_ymm                      phaddd_ymm
phaddsw_mmx                     phaddsw_mmx
phaddsw_xmm                     phaddsw_xmm
phaddsw_ymm                     phaddsw_ymm
phaddw_mmx                      phaddw_mmx
phaddw_xmm                      phaddw_xmm
phaddw_ymm                      phaddw_ymm
phminposuw_xmm                  phminposuw_xmm
phsubd_mmx                      phsubd_mmx
phsubd_xmm                      phsubd_xmm
phsubd_ymm                      phsubd_ymm
phsubsw_mmx                     phsubsw_mmx
phsubsw_xmm                     phsubsw_xmm
phsubsw_ymm                     phsubsw_ymm
phsubw_mmx                      phsubw_mmx
phsubw_xmm                      phsubw_xmm
phsubw_ymm                      phsubw_ymm
pi2fd                           pi2fd
pi2fw                           pi2fw
pmaddubsw_mmx                   pmaddubsw_mmx
pmaddubsw_xmm                   pmaddubsw_xmm
pmaddubsw_ymm                   pmaddubsw_ymm
pmaddwd_mmx                     pmaddwd_mmx
pmaddwd_xmm                     pmaddwd_xmm
pmaddwd_ymm                     pmaddwd_ymm
pmovdldup_xmm                   pmovdldup_xmm
pmovdldup_ymm                   pmovdldup_ymm
pmovshdup_xmm                   pmovshdup_xmm
pmovshdup_ymm                   pmovshdup_ymm
pmovsldup_xmm                   pmovsldup_xmm
pmovsldup_ymm                   pmovsldup_ymm
pmovsxbd_xmm                    pmovsxbd_xmm
pmovsxbd_ymm                    pmovsxbd_ymm
pmovsxbq_xmm                    pmovsxbq_xmm
pmovsxbq_ymm                    pmovsxbq_ymm
pmovsxbw_xmm                    pmovsxbw_xmm
pmovsxbw_ymm                    pmovsxbw_ymm
pmovsxdq_xmm                    pmovsxdq_xmm
pmovsxdq_ymm                    pmovsxdq_ymm
pmovsxwd_xmm                    pmovsxwd_xmm
pmovsxwd_ymm                    pmovsxwd_ymm
pmovsxwq_xmm                    pmovsxwq_xmm
pmovsxwq_ymm                    pmovsxwq_ymm
pmovzxbd_xmm                    pmovzxbd_xmm
pmovzxbd_ymm                    pmovzxbd_ymm
pmovzxbq_xmm                    pmovzxbq_xmm
pmovzxbq_ymm                    pmovzxbq_ymm
pmovzxbw_xmm                    pmovzxbw_xmm
pmovzxbw_ymm                    pmovzxbw_ymm
pmovzxdq_xmm                    pmovzxdq_xmm
pmovzxdq_ymm                    pmovzxdq_ymm
pmovzxwd_xmm                    pmovzxwd_xmm
pmovzxwd_ymm                    pmovzxwd_ymm
pmovzxwq_xmm                    pmovzxwq_xmm
pmovzxwq_ymm                    pmovzxwq_ymm
pmuldq_xmm                      pmuldq_xmm
pmuldq_ymm                      pmuldq_ymm
pmulhrsw_mmx                    pmulhrsw_mmx
pmulhrsw_xmm                    pmulhrsw_xmm
pmulhrsw_ymm                    pmulhrsw_ymm
pmulhrw_mmx                     pmulhrw_mmx
pmulhuw_mmx                     pmulhuw_mmx
pmulhuw_xmm                     pmulhuw_xmm
pmulhuw_ymm                     pmulhuw_ymm
pmulhw_mmx                      pmulhw_mmx
pmulhw_xmm                      pmulhw_xmm
pmulhw_ymm                      pmulhw_ymm
pmuludq_mmx                     pmuludq_mmx
pmuludq_xmm                     pmuludq_xmm
pmuludq_ymm                     pmuludq_ymm
psadbw_mmx                      psadbw_mmx
psadbw_xmm                      psadbw_xmm
psadbw_ymm                      psadbw_ymm
pshufb_mmx                      pshufb_mmx
pshufb_xmm                      pshufb_xmm
pshufb_ymm                      pshufb_ymm
pshufd_xmm                      pshufd_xmm
pshufd_ymm                      pshufd_ymm
pshufhw_xmm                     pshufhw_xmm
pshufhw_ymm                     pshufhw_ymm
pshuflw_xmm                     pshuflw_xmm
pshuflw_ymm                     pshuflw_ymm
pshufw_mmx                      pshufw_mmx
psignb_mmx                      psignb_mmx
psignb_xmm                      psignb_xmm
psignb_ymm                      psignb_ymm
psignd_mmx                      psignd_mmx
psignd_xmm                      psignd_xmm
psignd_ymm                      psignd_ymm
psignw_mmx                      psignw_mmx
psignw_xmm                      psignw_xmm
psignw_ymm                      psignw_ymm
pslld_mmx                       pslld_mmx
pslldq_xmm                      pslldq_xmm
pslldq_ymm                      pslldq_ymm
pslld_xmm                       pslld_xmm
pslld_ymm                       pslld_ymm
psllq_mmx                       psllq_mmx
psllq_xmm                       psllq_xmm
psllq_ymm                       psllq_ymm
psllw_mmx                       psllw_mmx
psllw_xmm                       psllw_xmm
psllw_ymm                       psllw_ymm
psrad_mmx                       psrad_mmx
psrad_xmm                       psrad_xmm
psrad_ymm                       psrad_ymm
psraw_mmx                       psraw_mmx
psraw_xmm                       psraw_xmm
psraw_ymm                       psraw_ymm
psrld_mmx                       psrld_mmx
psrldq_xmm                      psrldq_xmm
psrldq_ymm                      psrldq_ymm
psrld_xmm                       psrld_xmm
psrld_ymm                       psrld_ymm
psrlq_mmx                       psrlq_mmx
psrlq_xmm                       psrlq_xmm
psrlq_ymm                       psrlq_ymm
psrlw_mmx                       psrlw_mmx
psrlw_xmm                       psrlw_xmm
psrlw_ymm                       psrlw_ymm
pswapd                          pswapd
ptest_xmm                       ptest_xmm
ptest_ymm                       ptest_ymm
punpckhbw_mmx                   punpckhbw_mmx
punpckhbw_xmm                   punpckhbw_xmm
punpckhbw_ymm                   punpckhbw_ymm
punpckhdq_mmx                   punpckhdq_mmx
punpckhdq_xmm                   punpckhdq_xmm
punpckhdq_ymm                   punpckhdq_ymm
punpckhqdq_xmm                  punpckhqdq_xmm
punpckhqdq_ymm                  punpckhqdq_ymm
punpckhwd_mmx                   punpckhwd_mmx
punpckhwd_xmm                   punpckhwd_xmm
punpckhwd_ymm                   punpckhwd_ymm
punpcklbw_mmx                   punpcklbw_mmx
punpcklbw_xmm                   punpcklbw_xmm
punpcklbw_ymm                   punpcklbw_ymm
punpckldq_mmx                   punpckldq_mmx
punpckldq_xmm                   punpckldq_xmm
punpckldq_ymm                   punpckldq_ymm
punpcklqdq_xmm                  punpcklqdq_xmm
punpcklqdq_ymm                  punpcklqdq_ymm
punpcklwd_mmx                   punpcklwd_mmx
punpcklwd_xmm                   punpcklwd_xmm
punpcklwd_ymm                   punpcklwd_ymm
push_ret_addr                   push_ret_addr
qemu_ld2_i128                   qemu_ld2_i128
qemu_ld_i32                     qemu_ld_i32
qemu_ld_i64                     qemu_ld_i64
qemu_st2_i128                   qemu_st2_i128
qemu_st_i32                     qemu_st_i32
qemu_st_i64                     qemu_st_i64
raise_exception                 raise_exception
raise_interrupt                 raise_interrupt
rcpps_xmm                       rcpps_xmm
rcpps_ymm                       rcpps_ymm
rcpss                           rcpss
rdpid                           rdpid
rdpkru                          rdpkru
rdpmc                           rdpmc
rdrand                          rdrand
rdtsc                           rdtsc
read_eflags                     read_eflags
rechecking_single_step          rechecking_single_step
rem_i32                         rem_i32
rem_i64                         rem_i64
rems_i32                        rems_i32
rems_i64                        rems_i64
remu_i32                        remu_i32
remu_i64                        remu_i64
ret                             ret
rotl_i32                        rotl_i32
rotl_i64                        rotl_i64
rotli_vec                       rotli_vec
rotls_vec                       rotls_vec
rotlv_vec                       rotlv_vec
rotr_i32                        rotr_i32
rotr_i64                        rotr_i64
rotrv_vec                       rotrv_vec
roundpd_xmm                     roundpd_xmm
roundpd_ymm                     roundpd_ymm
roundps_xmm                     roundps_xmm
roundps_ymm                     roundps_ymm
roundsd_xmm                     roundsd_xmm
roundss_xmm                     roundss_xmm
rsqrtps_xmm                     rsqrtps_xmm
rsqrtps_ymm                     rsqrtps_ymm
rsqrtss                         rsqrtss
sar_i32                         sar_i32
sar_i64                         sar_i64
sari_vec                        sari_vec
sars_vec                        sars_vec
sarv_vec                        sarv_vec
setcond_i32                     setcond_i32
setcond_i64                     setcond_i64
set_label                       set_label
sextract_i32                    sextract_i32
sextract_i64                    sextract_i64
sha1msg1                        sha1msg1
sha1msg2                        sha1msg2
sha1nexte                       sha1nexte
sha1rnds4_f0                    sha1rnds4_f0
sha1rnds4_f1                    sha1rnds4_f1
sha1rnds4_f2                    sha1rnds4_f2
sha1rnds4_f3                    sha1rnds4_f3
sha256msg1                      sha256msg1
sha256msg2                      sha256msg2
sha256rnds2                     sha256rnds2
shl_i32                         shl_i32
shl_i64                         shl_i64
shli_vec                        shli_vec
shls_vec                        shls_vec
shlv_vec                        shlv_vec
shr_i32                         shr_i32
shr_i64                         shr_i64
shri_vec                        shri_vec
shrs_vec                        shrs_vec
shrv_vec                        shrv_vec
shufpd_xmm                      shufpd_xmm
shufpd_ymm                      shufpd_ymm
shufps_xmm                      shufps_xmm
shufps_ymm                      shufps_ymm
single_step                     single_step
smax_vec                        smax_vec
smin_vec                        smin_vec
sqrtpd_xmm                      sqrtpd_xmm
sqrtpd_ymm                      sqrtpd_ymm
sqrtps_xmm                      sqrtps_xmm
sqrtps_ymm                      sqrtps_ymm
sqrtsd                          sqrtsd
sqrtss                          sqrtss
ssadd_vec                       ssadd_vec
sssub_vec                       sssub_vec
st16_i32                        st16_i32
st16_i64                        st16_i64
st32_i64                        st32_i64
st8_i32                         st8_i32
st8_i64                         st8_i64
st_i128                         st_i128
st_i32                          st_i32
st_i64                          st_i64
st_vec                          st_vec
subb1o_i32                      subb1o_i32
subb1o_i64                      subb1o_i64
subbi_i32                       subbi_i32
subbi_i64                       subbi_i64
subbio_i32                      subbio_i32
subbio_i64                      subbio_i64
subbo_i32                       subbo_i32
subbo_i64                       subbo_i64
sub_i32                         sub_i32
sub_i64                         sub_i64
subpd_xmm                       subpd_xmm
subpd_ymm                       subpd_ymm
subps_xmm                       subps_xmm
subps_ymm                       subps_ymm
subsd                           subsd
subss                           subss
sub_vec                         sub_vec
syscall                         syscall
sysenter                        sysenter
sysexit                         sysexit
sysret                          sysret
ucomisd                         ucomisd
ucomiss                         ucomiss
umax_vec                        umax_vec
umin_vec                        umin_vec
update_mxcsr                    update_mxcsr
usadd_vec                       usadd_vec
ussub_vec                       ussub_vec
verr                            verr
verw                            verw
vpermdq_ymm                     vpermdq_ymm
vpermd_ymm                      vpermd_ymm
vpermilpd_imm_xmm               vpermilpd_imm_xmm
vpermilpd_imm_ymm               vpermilpd_imm_ymm
vpermilpd_xmm                   vpermilpd_xmm
vpermilpd_ymm                   vpermilpd_ymm
vpermilps_imm_xmm               vpermilps_imm_xmm
vpermilps_imm_ymm               vpermilps_imm_ymm
vpermilps_xmm                   vpermilps_xmm
vpermilps_ymm                   vpermilps_ymm
vpermq_ymm                      vpermq_ymm
vpgatherdd_xmm                  vpgatherdd_xmm
vpgatherdd_ymm                  vpgatherdd_ymm
vpgatherdq_xmm                  vpgatherdq_xmm
vpgatherdq_ymm                  vpgatherdq_ymm
vpgatherqd_xmm                  vpgatherqd_xmm
vpgatherqd_ymm                  vpgatherqd_ymm
vpgatherqq_xmm                  vpgatherqq_xmm
vpgatherqq_ymm                  vpgatherqq_ymm
vpmaskmovd_st_xmm               vpmaskmovd_st_xmm
vpmaskmovd_st_ymm               vpmaskmovd_st_ymm
vpmaskmovd_xmm                  vpmaskmovd_xmm
vpmaskmovd_ymm                  vpmaskmovd_ymm
vpmaskmovq_st_xmm               vpmaskmovq_st_xmm
vpmaskmovq_st_ymm               vpmaskmovq_st_ymm
vpmaskmovq_xmm                  vpmaskmovq_xmm
vpmaskmovq_ymm                  vpmaskmovq_ymm
vpsllvd_xmm                     vpsllvd_xmm
vpsllvd_ymm                     vpsllvd_ymm
vpsllvq_xmm                     vpsllvq_xmm
vpsllvq_ymm                     vpsllvq_ymm
vpsravd_xmm                     vpsravd_xmm
vpsravd_ymm                     vpsravd_ymm
vpsravq_xmm                     vpsravq_xmm
vpsravq_ymm                     vpsravq_ymm
vpsrlvd_xmm                     vpsrlvd_xmm
vpsrlvd_ymm                     vpsrlvd_ymm
vpsrlvq_xmm                     vpsrlvq_xmm
vpsrlvq_ymm                     vpsrlvq_ymm
vtestpd_xmm                     vtestpd_xmm
vtestpd_ymm                     vtestpd_ymm
vtestps_xmm                     vtestps_xmm
vtestps_ymm                     vtestps_ymm
write_eflags                    write_eflags
wrpkru                          wrpkru
xgetbv                          xgetbv
xor_i32                         xor_i32
xor_i64                         xor_i64
xor_vec                         xor_vec
xrstor                          xrstor
xsave                           xsave
xsaveopt                        xsaveopt
xsetbv                          xsetbv

%%

{XMMVAR}          { HANDLE_COLUMN; yylval->ival = atoi(yytext + 3); return XMMVAR; }
{XMMTMP}          { HANDLE_COLUMN; return XMMTMP; }
{TMPLVAR}         { HANDLE_COLUMN; yylval->si.type = SUB_SLOT_TMPL; yylval->si.idx = atoi(yytext + 3); yylval->si.op_type = LLVMInvalidType; yylval->si.stack_type = LLVMInvalidType; return SLOT; }
{TMPTVAR}         { HANDLE_COLUMN; yylval->si.type = SUB_SLOT_TMPT; yylval->si.idx = atoi(yytext + 3); yylval->si.op_type = LLVMInvalidType; yylval->si.stack_type = LLVMInvalidType; return SLOT; }
{IMMX}            { HANDLE_COLUMN; errno = 0; yylval->ival = strtoll(yytext + 1, NULL, 16); if (errno == ERANGE) { reduce_imm_force(yytext + 1); yylval->ival = strtoll(yytext + 1, NULL, 16); yylval->ival += 0x8000000000000000UL; } return IMMX; }
{IMMD}            { HANDLE_COLUMN; errno = 0; yylval->ival = strtoll(yytext + 1, NULL, 10); assert(!errno); return IMMD; }
{NUM}             { HANDLE_COLUMN; yylval->ival = atoi(yytext); return IMM; }
{LABEL}           { HANDLE_COLUMN; yylval->ival = atoi(yytext + 2); return LABEL; }
{noat}            { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.atomic = NONATOMIC; return MEMATTR; }
{un}              { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.alignment = UNALIGNED; return MEMATTR; }
{unal}            { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.alignment = UNALIGNED; return MEMATTR; }
{al}              { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.alignment = ALIGN_MEM_SIZE; return MEMATTR; }
{al2}             { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.alignment = ALIGN_2; return MEMATTR; }
{al4}             { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.alignment = ALIGN_4; return MEMATTR; }
{al8}             { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.alignment = ALIGN_8; return MEMATTR; }
{al16}            { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.alignment = ALIGN_16; return MEMATTR; }
{al32}            { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.alignment = ALIGN_32; return MEMATTR; }
{sb}              { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.ext = SIGN; yylval->attr_info.p.storage.size = SRC1B; return MEMATTR; }
{lesw}            { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.ext = SIGN; yylval->attr_info.p.storage.size = SRC2B; return MEMATTR; }
{lesl}            { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.ext = SIGN; yylval->attr_info.p.storage.size = SRC4B; return MEMATTR; }
{ub}              { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.ext = ZERO; yylval->attr_info.p.storage.size = SRC1B; return MEMATTR; }
{leuw}            { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.ext = ZERO; yylval->attr_info.p.storage.size = SRC2B; return MEMATTR; }
{leul}            { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.ext = ZERO; yylval->attr_info.p.storage.size = SRC4B; return MEMATTR; }
{leq}             { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.ext = ZERO; yylval->attr_info.p.storage.size = SRC8B; return MEMATTR; }
{leo}             { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_STORAGE; yylval->attr_info.p.storage.ext = ZERO; yylval->attr_info.p.storage.size = SRC16B; return MEMATTR; }
{cc_src2}         { HANDLE_COLUMN; yylval->si.type = SUB_SLOT_ENVVAR; yylval->si.idx = cc_src2; yylval->si.op_type = LLVMInt64; yylval->si.stack_type = LLVMInt64; return SLOT; }
{es_base}         { HANDLE_COLUMN; yylval->si.type = SUB_SLOT_ENVVAR; yylval->si.idx = es_base; yylval->si.op_type = LLVMInt64; yylval->si.stack_type = LLVMInt64; return SLOT; }
{cs_base}         { HANDLE_COLUMN; yylval->si.type = SUB_SLOT_ENVVAR; yylval->si.idx = cs_base; yylval->si.op_type = LLVMInt64; yylval->si.stack_type = LLVMInt64; return SLOT; }
{ss_base}         { HANDLE_COLUMN; yylval->si.type = SUB_SLOT_ENVVAR; yylval->si.idx = ss_base; yylval->si.op_type = LLVMInt64; yylval->si.stack_type = LLVMInt64; return SLOT; }
{ds_base}         { HANDLE_COLUMN; yylval->si.type = SUB_SLOT_ENVVAR; yylval->si.idx = ds_base; yylval->si.op_type = LLVMInt64; yylval->si.stack_type = LLVMInt64; return SLOT; }
{fs_base}         { HANDLE_COLUMN; yylval->si.type = SUB_SLOT_ENVVAR; yylval->si.idx = fs_base; yylval->si.op_type = LLVMInt64; yylval->si.stack_type = LLVMInt64; return SLOT; }
{gs_base}         { HANDLE_COLUMN; yylval->si.type = SUB_SLOT_ENVVAR; yylval->si.idx = gs_base; yylval->si.op_type = LLVMInt64; yylval->si.stack_type = LLVMInt64; return SLOT; }
{rax}             { SET_XREG(rax); }
{rcx}             { SET_XREG(rcx); }
{rdx}             { SET_XREG(rdx); }
{rbx}             { SET_XREG(rbx); }
{rsp}             { SET_XREG(rsp); }
{rbp}             { SET_XREG(rbp); }
{rsi}             { SET_XREG(rsi); }
{rdi}             { SET_XREG(rdi); }
{r8}              { SET_XREG(r8); }
{r9}              { SET_XREG(r9); }
{r10}             { SET_XREG(r10); }
{r11}             { SET_XREG(r11); }
{r12}             { SET_XREG(r12); }
{r13}             { SET_XREG(r13); }
{r14}             { SET_XREG(r14); }
{r15}             { SET_XREG(r15); }
{cc_src}          { SET_XREG(cc_src); }
{cc_dst}          { SET_XREG(cc_dst); }
{cc_op}           { SET_XREG(cc_op); }
{rip}             { SET_XREG(rip); }
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
{tsteq}           { HANDLE_COLUMN; yylval->r = tsteq; return RELOP; }
{tstne}           { HANDLE_COLUMN; yylval->r = tstne; return RELOP; }
{ENV}             { HANDLE_COLUMN; return ENV; }
{INTERNAL}        { HANDLE_COLUMN; yylval->ival = 0; return SCOPE; }
{EXTERNAL}        { HANDLE_COLUMN; yylval->ival = 1; return SCOPE; }
{V64}             { HANDLE_COLUMN; yylval->vecspec.vs = 64; return VS_TOKEN; }
{V128}            { HANDLE_COLUMN; yylval->vecspec.vs = 128; return VS_TOKEN; }
{E8}              { HANDLE_COLUMN; yylval->vecspec.es = 8; return ES_TOKEN; }
{E16}             { HANDLE_COLUMN; yylval->vecspec.es = 16; return ES_TOKEN; }
{E32}             { HANDLE_COLUMN; yylval->vecspec.es = 32; return ES_TOKEN; }
{E64}             { HANDLE_COLUMN; yylval->vecspec.es = 64; return ES_TOKEN; }
{OZ}              { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_SWAP; yylval->attr_info.p.swap = OZ; return SWAPATTR; }
{IZ}              { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_SWAP; yylval->attr_info.p.swap = IZ; return SWAPATTR; }
{OS}              { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_SWAP; yylval->attr_info.p.swap = OS; return SWAPATTR; }
{IS}              { HANDLE_COLUMN; yylval->attr_info.subt = SUB_ATTR_SWAP; yylval->attr_info.p.swap = IS; return SWAPATTR; }
{call}            { HANDLE_COLUMN; BEGIN(CALL_STATE); yylval->opc = call; return CALL; }
<CALL_STATE>[ \t] ; // Ignore whitespace
<CALL_STATE>{HELPER}  {
    HANDLE_COLUMN;
    BEGIN(INITIAL);
    yylval->hlp = lookup_helper_enum(yytext, yyleng);
    return SYMBOL;
}
{br}              { HANDLE_COLUMN; yylval->opc = br; return OPCODE; }
{brcond_i32}    { HANDLE_COLUMN; yylval->opc = brcond_i32; return OPCODE; }
{add_i32}       { HANDLE_COLUMN; yylval->opc = add_i32; return OPCODE; }
{andc_i32}      { HANDLE_COLUMN; yylval->opc = andc_i32; return OPCODE; }
{bswap16_i32}   { HANDLE_COLUMN; yylval->opc = bswap16_i32; return OPCODE; }
{bswap32_i32}   { HANDLE_COLUMN; yylval->opc = bswap32_i32; return OPCODE; }
{clz_i32}       { HANDLE_COLUMN; yylval->opc = clz_i32; return OPCODE; }
{ctpop_i32}     { HANDLE_COLUMN; yylval->opc = ctpop_i32; return OPCODE; }
{ctz_i32}       { HANDLE_COLUMN; yylval->opc = ctz_i32; return OPCODE; }
{divs_i32}      { HANDLE_COLUMN; yylval->opc = divs_i32; return OPCODE; }
{divs2_i32}     { HANDLE_COLUMN; yylval->opc = divs2_i32; return OPCODE; }
{divu_i32}      { HANDLE_COLUMN; yylval->opc = divu_i32; return OPCODE; }
{divu2_i32}     { HANDLE_COLUMN; yylval->opc = divu2_i32; return OPCODE; }
{eqv_i32}       { HANDLE_COLUMN; yylval->opc = eqv_i32; return OPCODE; }
{extract2_i32}  { HANDLE_COLUMN; yylval->opc = extract2_i32; return OPCODE; }
{ld8u_i32}      { HANDLE_COLUMN; yylval->opc = ld8u_i32; return OPCODE; }
{ld8s_i32}      { HANDLE_COLUMN; yylval->opc = ld8s_i32; return OPCODE; }
{ld16u_i32}     { HANDLE_COLUMN; yylval->opc = ld16u_i32; return OPCODE; }
{ld16s_i32}     { HANDLE_COLUMN; yylval->opc = ld16s_i32; return OPCODE; }
{muls2_i32}     { HANDLE_COLUMN; yylval->opc = muls2_i32; return OPCODE; }
{mulsh_i32}     { HANDLE_COLUMN; yylval->opc = mulsh_i32; return OPCODE; }
{mulu2_i32}     { HANDLE_COLUMN; yylval->opc = mulu2_i32; return OPCODE; }
{muluh_i32}     { HANDLE_COLUMN; yylval->opc = muluh_i32; return OPCODE; }
{nand_i32}      { HANDLE_COLUMN; yylval->opc = nand_i32; return OPCODE; }
{negsetcond_i32}    { HANDLE_COLUMN; yylval->opc = negsetcond_i32; return OPCODE; }
{nor_i32}       { HANDLE_COLUMN; yylval->opc = nor_i32; return OPCODE; }
{not_i32}       { HANDLE_COLUMN; yylval->opc = not_i32; return OPCODE; }
{orc_i32}       { HANDLE_COLUMN; yylval->opc = orc_i32; return OPCODE; }
{rems_i32}      { HANDLE_COLUMN; yylval->opc = rems_i32; return OPCODE; }
{remu_i32}      { HANDLE_COLUMN; yylval->opc = remu_i32; return OPCODE; }
{setcond_i32}   { HANDLE_COLUMN; yylval->opc = setcond_i32; return OPCODE; }
{sextract_i32}  { HANDLE_COLUMN; yylval->opc = sextract_i32; return OPCODE; }
{st8_i32}       { HANDLE_COLUMN; yylval->opc = st8_i32; return OPCODE; }
{addco_i32}     { HANDLE_COLUMN; yylval->opc = addco_i32; return OPCODE; }
{addc1o_i32}    { HANDLE_COLUMN; yylval->opc = addc1o_i32; return OPCODE; }
{addci_i32}     { HANDLE_COLUMN; yylval->opc = addci_i32; return OPCODE; }
{addcio_i32}    { HANDLE_COLUMN; yylval->opc = addcio_i32; return OPCODE; }
{subbo_i32}     { HANDLE_COLUMN; yylval->opc = subbo_i32; return OPCODE; }
{subb1o_i32}    { HANDLE_COLUMN; yylval->opc = subb1o_i32; return OPCODE; }
{subbi_i32}     { HANDLE_COLUMN; yylval->opc = subbi_i32; return OPCODE; }
{subbio_i32}    { HANDLE_COLUMN; yylval->opc = subbio_i32; return OPCODE; }
{bswap16_i64}   { HANDLE_COLUMN; yylval->opc = bswap16_i64; return OPCODE; }
{ctpop_i64}     { HANDLE_COLUMN; yylval->opc = ctpop_i64; return OPCODE; }
{divs_i64}      { HANDLE_COLUMN; yylval->opc = divs_i64; return OPCODE; }
{divs2_i64}     { HANDLE_COLUMN; yylval->opc = divs2_i64; return OPCODE; }
{divu_i64}      { HANDLE_COLUMN; yylval->opc = divu_i64; return OPCODE; }
{divu2_i64}     { HANDLE_COLUMN; yylval->opc = divu2_i64; return OPCODE; }
{eqv_i64}       { HANDLE_COLUMN; yylval->opc = eqv_i64; return OPCODE; }
{ld8s_i64}      { HANDLE_COLUMN; yylval->opc = ld8s_i64; return OPCODE; }
{ld16u_i64}     { HANDLE_COLUMN; yylval->opc = ld16u_i64; return OPCODE; }
{ld16s_i64}     { HANDLE_COLUMN; yylval->opc = ld16s_i64; return OPCODE; }
{muls2_i64}     { HANDLE_COLUMN; yylval->opc = muls2_i64; return OPCODE; }
{mulu2_i64}     { HANDLE_COLUMN; yylval->opc = mulu2_i64; return OPCODE; }
{nand_i64}      { HANDLE_COLUMN; yylval->opc = nand_i64; return OPCODE; }
{nor_i64}       { HANDLE_COLUMN; yylval->opc = nor_i64; return OPCODE; }
{orc_i64}       { HANDLE_COLUMN; yylval->opc = orc_i64; return OPCODE; }
{rems_i64}      { HANDLE_COLUMN; yylval->opc = rems_i64; return OPCODE; }
{remu_i64}      { HANDLE_COLUMN; yylval->opc = remu_i64; return OPCODE; }
{st8_i64}       { HANDLE_COLUMN; yylval->opc = st8_i64; return OPCODE; }
{sub_i64}       { HANDLE_COLUMN; yylval->opc = sub_i64; return OPCODE; }
{addco_i64}     { HANDLE_COLUMN; yylval->opc = addco_i64; return OPCODE; }
{addc1o_i64}    { HANDLE_COLUMN; yylval->opc = addc1o_i64; return OPCODE; }
{addci_i64}     { HANDLE_COLUMN; yylval->opc = addci_i64; return OPCODE; }
{addcio_i64}    { HANDLE_COLUMN; yylval->opc = addcio_i64; return OPCODE; }
{subbo_i64}     { HANDLE_COLUMN; yylval->opc = subbo_i64; return OPCODE; }
{subb1o_i64}    { HANDLE_COLUMN; yylval->opc = subb1o_i64; return OPCODE; }
{subbi_i64}     { HANDLE_COLUMN; yylval->opc = subbi_i64; return OPCODE; }
{subbio_i64}    { HANDLE_COLUMN; yylval->opc = subbio_i64; return OPCODE; }
{dup_vec}       { HANDLE_COLUMN; yylval->opc = dup_vec; return OPCODE; }
{mul_vec}       { HANDLE_COLUMN; yylval->opc = mul_vec; return OPCODE; }
{neg_vec}       { HANDLE_COLUMN; yylval->opc = neg_vec; return OPCODE; }
{abs_vec}       { HANDLE_COLUMN; yylval->opc = abs_vec; return OPCODE; }
{ssadd_vec}     { HANDLE_COLUMN; yylval->opc = ssadd_vec; return OPCODE; }
{usadd_vec}     { HANDLE_COLUMN; yylval->opc = usadd_vec; return OPCODE; }
{sssub_vec}     { HANDLE_COLUMN; yylval->opc = sssub_vec; return OPCODE; }
{ussub_vec}     { HANDLE_COLUMN; yylval->opc = ussub_vec; return OPCODE; }
{smin_vec}      { HANDLE_COLUMN; yylval->opc = smin_vec; return OPCODE; }
{smax_vec}      { HANDLE_COLUMN; yylval->opc = smax_vec; return OPCODE; }
{orc_vec}       { HANDLE_COLUMN; yylval->opc = orc_vec; return OPCODE; }
{nand_vec}      { HANDLE_COLUMN; yylval->opc = nand_vec; return OPCODE; }
{nor_vec}       { HANDLE_COLUMN; yylval->opc = nor_vec; return OPCODE; }
{eqv_vec}       { HANDLE_COLUMN; yylval->opc = eqv_vec; return OPCODE; }
{shri_vec}      { HANDLE_COLUMN; yylval->opc = shri_vec; return OPCODE; }
{sari_vec}      { HANDLE_COLUMN; yylval->opc = sari_vec; return OPCODE; }
{rotli_vec}     { HANDLE_COLUMN; yylval->opc = rotli_vec; return OPCODE; }
{shls_vec}      { HANDLE_COLUMN; yylval->opc = shls_vec; return OPCODE; }
{shrs_vec}      { HANDLE_COLUMN; yylval->opc = shrs_vec; return OPCODE; }
{sars_vec}      { HANDLE_COLUMN; yylval->opc = sars_vec; return OPCODE; }
{rotls_vec}     { HANDLE_COLUMN; yylval->opc = rotls_vec; return OPCODE; }
{shlv_vec}      { HANDLE_COLUMN; yylval->opc = shlv_vec; return OPCODE; }
{shrv_vec}      { HANDLE_COLUMN; yylval->opc = shrv_vec; return OPCODE; }
{sarv_vec}      { HANDLE_COLUMN; yylval->opc = sarv_vec; return OPCODE; }
{rotlv_vec}     { HANDLE_COLUMN; yylval->opc = rotlv_vec; return OPCODE; }
{rotrv_vec}     { HANDLE_COLUMN; yylval->opc = rotrv_vec; return OPCODE; }
{bitsel_vec}    { HANDLE_COLUMN; yylval->opc = bitsel_vec; return OPCODE; }
{cmpsel_vec}    { HANDLE_COLUMN; yylval->opc = cmpsel_vec; return OPCODE; }
{ext_i32_i64}   { HANDLE_COLUMN; yylval->opc = ext_i32_i64; return OPCODE; }
{extrh_i64_i32} { HANDLE_COLUMN; yylval->opc = extrh_i64_i32; return OPCODE; }
{add_i64}       { HANDLE_COLUMN; yylval->opc = add_i64; return OPCODE; }
{add_vec}       { HANDLE_COLUMN; yylval->opc = add_vec; return OPCODE; }
{andc_i64}      { HANDLE_COLUMN; yylval->opc = andc_i64; return OPCODE; }
{andc_vec}      { HANDLE_COLUMN; yylval->opc = andc_vec; return OPCODE; }
{and_i64}       { HANDLE_COLUMN; yylval->opc = and_i64; return OPCODE; }
{and_i32}       { HANDLE_COLUMN; yylval->opc = and_i32; return OPCODE; }
{and_vec}       { HANDLE_COLUMN; yylval->opc = and_vec; return OPCODE; }
{bswap32_i64}   { HANDLE_COLUMN; yylval->opc = bswap32_i64; return OPCODE; }
{clz_i64}       { HANDLE_COLUMN; yylval->opc = clz_i64; return OPCODE; }
{cmp_vec}       { HANDLE_COLUMN; yylval->opc = cmp_vec; return OPCODE; }
{ctz_i64}       { HANDLE_COLUMN; yylval->opc = ctz_i64; return OPCODE; }
{deposit_i32}   { HANDLE_COLUMN; yylval->opc = deposit_i32; return OPCODE; }
{deposit_i64}   { HANDLE_COLUMN; yylval->opc = deposit_i64; return OPCODE; }
{dupm_vec}      { HANDLE_COLUMN; yylval->opc = dupm_vec; return OPCODE; }
{extract2_i64}  { HANDLE_COLUMN; yylval->opc = extract2_i64; return OPCODE; }
{extract_i32}   { HANDLE_COLUMN; yylval->opc = extract_i32; return OPCODE; }
{extract_i64}   { HANDLE_COLUMN; yylval->opc = extract_i64; return OPCODE; }
{extrl_i64_i32} { HANDLE_COLUMN; yylval->opc = extrl_i64_i32; return OPCODE; }
{extu_i32_i64}  { HANDLE_COLUMN; yylval->opc = extu_i32_i64; return OPCODE; }
{ld32s_i64}     { HANDLE_COLUMN; yylval->opc = ld32s_i64; return OPCODE; }
{ld32u_i64}     { HANDLE_COLUMN; yylval->opc = ld32u_i64; return OPCODE; }
{ld8u_i64}      { HANDLE_COLUMN; yylval->opc = ld8u_i64; return OPCODE; }
{ld_i32}        { HANDLE_COLUMN; yylval->opc = ld_i32; return OPCODE; }
{ld_i64}        { HANDLE_COLUMN; yylval->opc = ld_i64; return OPCODE; }
{ld_vec}        { HANDLE_COLUMN; yylval->opc = ld_vec; return OPCODE; }
{movcond_i32}   { HANDLE_COLUMN; yylval->opc = movcond_i32; return OPCODE; }
{movcond_i64}   { HANDLE_COLUMN; yylval->opc = movcond_i64; return OPCODE; }
{movcond_vec}   { HANDLE_COLUMN; yylval->opc = movcond_vec; return OPCODE; }
{mov_i32}       { HANDLE_COLUMN; yylval->opc = mov_i32; return OPCODE; }
{mov_i64}       { HANDLE_COLUMN; yylval->opc = mov_i64; return OPCODE; }
{mov_vec}       { HANDLE_COLUMN; yylval->opc = mov_vec; return OPCODE; }
{mul_i32}       { HANDLE_COLUMN; yylval->opc = mul_i32; return OPCODE; }
{mul_i64}       { HANDLE_COLUMN; yylval->opc = mul_i64; return OPCODE; }
{mulsh_i64}     { HANDLE_COLUMN; yylval->opc = mulsh_i64; return OPCODE; }
{muluh_i64}     { HANDLE_COLUMN; yylval->opc = muluh_i64; return OPCODE; }
{neg_i32}       { HANDLE_COLUMN; yylval->opc = neg_i32; return OPCODE; }
{neg_i64}       { HANDLE_COLUMN; yylval->opc = neg_i64; return OPCODE; }
{negsetcond_i64}    { HANDLE_COLUMN; yylval->opc = negsetcond_i64; return OPCODE; }
{not_i64}       { HANDLE_COLUMN; yylval->opc = not_i64; return OPCODE; }
{not_vec}       { HANDLE_COLUMN; yylval->opc = not_vec; return OPCODE; }
{or_i64}        { HANDLE_COLUMN; yylval->opc = or_i64; return OPCODE; }
{or_i32}        { HANDLE_COLUMN; yylval->opc = or_i32; return OPCODE; }
{or_vec}        { HANDLE_COLUMN; yylval->opc = or_vec; return OPCODE; }
{push_ret_addr} { HANDLE_COLUMN; yylval->opc = push_ret_addr; return OPCODE; }
{qemu_ld2_i128} { HANDLE_COLUMN; yylval->opc = qemu_ld2_i128; return OPCODE; }
{qemu_ld_i32}   { HANDLE_COLUMN; yylval->opc = qemu_ld_i32; return OPCODE; }
{qemu_ld_i64}   { HANDLE_COLUMN; yylval->opc = qemu_ld_i64; return OPCODE; }
{qemu_st2_i128} { HANDLE_COLUMN; yylval->opc = qemu_st2_i128; return OPCODE; }
{qemu_st_i32}   { HANDLE_COLUMN; yylval->opc = qemu_st_i32; return OPCODE; }
{qemu_st_i64}   { HANDLE_COLUMN; yylval->opc = qemu_st_i64; return OPCODE; }
{ret}           { HANDLE_COLUMN; yylval->opc = ret; return OPCODE; }
{rotr_i32}      { HANDLE_COLUMN; yylval->opc = rotr_i32; return OPCODE; }
{rotr_i64}      { HANDLE_COLUMN; yylval->opc = rotr_i64; return OPCODE; }
{sar_i32}       { HANDLE_COLUMN; yylval->opc = sar_i32; return OPCODE; }
{sar_i64}       { HANDLE_COLUMN; yylval->opc = sar_i64; return OPCODE; }
{setcond_i64}   { HANDLE_COLUMN; yylval->opc = setcond_i64; return OPCODE; }
{sextract_i64}  { HANDLE_COLUMN; yylval->opc = sextract_i64; return OPCODE; }
{shl_i64}       { HANDLE_COLUMN; yylval->opc = shl_i64; return OPCODE; }
{shl_i32}       { HANDLE_COLUMN; yylval->opc = shl_i32; return OPCODE; }
{shli_vec}      { HANDLE_COLUMN; yylval->opc = shli_vec; return OPCODE; }
{shr_i64}       { HANDLE_COLUMN; yylval->opc = shr_i64; return OPCODE; }
{shr_i32}       { HANDLE_COLUMN; yylval->opc = shr_i32; return OPCODE; }
{st16_i32}      { HANDLE_COLUMN; yylval->opc = st16_i32; return OPCODE; }
{st16_i64}      { HANDLE_COLUMN; yylval->opc = st16_i64; return OPCODE; }
{st32_i64}      { HANDLE_COLUMN; yylval->opc = st32_i64; return OPCODE; }
{st_i32}        { HANDLE_COLUMN; yylval->opc = st_i32; return OPCODE; }
{st_i64}        { HANDLE_COLUMN; yylval->opc = st_i64; return OPCODE; }
{st_vec}        { HANDLE_COLUMN; yylval->opc = st_vec; return OPCODE; }
{sub_i32}       { HANDLE_COLUMN; yylval->opc = sub_i32; return OPCODE; }
{sub_vec}       { HANDLE_COLUMN; yylval->opc = sub_vec; return OPCODE; }
{umax_vec}      { HANDLE_COLUMN; yylval->opc = umax_vec; return OPCODE; }
{umin_vec}      { HANDLE_COLUMN; yylval->opc = umin_vec; return OPCODE; }
{xor_i64}       { HANDLE_COLUMN; yylval->opc = xor_i64; return OPCODE; }
{xor_i32}       { HANDLE_COLUMN; yylval->opc = xor_i32; return OPCODE; }
{xor_vec}       { HANDLE_COLUMN; yylval->opc = xor_vec; return OPCODE; }
{bswap64_i64}   { HANDLE_COLUMN; yylval->opc = bswap64_i64; return OPCODE; }
{set_label}     { HANDLE_COLUMN; yylval->opc = set_label; return OPCODE; }
{brcond_i64}    { HANDLE_COLUMN; yylval->opc = brcond_i64; return OPCODE; }
{jmp_direct}    { HANDLE_COLUMN; yylval->opc = jmp_direct; return OPCODE; }
{discard}       { HANDLE_COLUMN; yylval->opc = discard; return OPCODE; }
{rotl_i32}      { HANDLE_COLUMN; yylval->opc = rotl_i32; return OPCODE; }
{rotl_i64}      { HANDLE_COLUMN; yylval->opc = rotl_i64; return OPCODE; }
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
