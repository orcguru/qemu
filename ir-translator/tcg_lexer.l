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
brcond_i32                      brcond_i32
brcond_i64                      brcond_i64
bswap16_i32                     bswap16_i32
bswap16_i64                     bswap16_i64
bswap32_i32                     bswap32_i32
bswap32_i64                     bswap32_i64
bswap64_i64                     bswap64_i64
call                            call
call_direct                     call_direct
call_ind                        call_ind
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
ret_ind                         ret_ind
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

{brcond_i32}    { HANDLE_COLUMN; yylval->oh.o = brcond_i32; return SYMBOL; }
{add_i32}       { HANDLE_COLUMN; yylval->oh.o = add_i32; return SYMBOL; }
{andc_i32}      { HANDLE_COLUMN; yylval->oh.o = andc_i32; return SYMBOL; }
{bswap16_i32}   { HANDLE_COLUMN; yylval->oh.o = bswap16_i32; return BSWAP; }
{bswap32_i32}   { HANDLE_COLUMN; yylval->oh.o = bswap32_i32; return BSWAP; }
{clz_i32}       { HANDLE_COLUMN; yylval->oh.o = clz_i32; yylval->oh.h = helper_clz_i32; return SYMBOL; }
{ctpop_i32}     { HANDLE_COLUMN; yylval->oh.o = ctpop_i32; yylval->oh.h = helper_ctpop_i32; return SYMBOL; }
{ctz_i32}       { HANDLE_COLUMN; yylval->oh.o = ctz_i32; yylval->oh.h = helper_ctz_i32; return SYMBOL; }
{divs_i32}      { HANDLE_COLUMN; yylval->oh.o = divs_i32; return SYMBOL; }
{divs2_i32}     { HANDLE_COLUMN; yylval->oh.o = divs2_i32; return SYMBOL; }
{divu_i32}      { HANDLE_COLUMN; yylval->oh.o = divu_i32; yylval->oh.h = helper_divu_i32; return SYMBOL; }
{divu2_i32}     { HANDLE_COLUMN; yylval->oh.o = divu2_i32; return SYMBOL; }
{eqv_i32}       { HANDLE_COLUMN; yylval->oh.o = eqv_i32; return SYMBOL; }
{extract2_i32}  { HANDLE_COLUMN; yylval->oh.o = extract2_i32; return SYMBOL; }
{ld8u_i32}      { HANDLE_COLUMN; yylval->oh.o = ld8u_i32; return SYMBOL; }
{ld8s_i32}      { HANDLE_COLUMN; yylval->oh.o = ld8s_i32; return SYMBOL; }
{ld16u_i32}     { HANDLE_COLUMN; yylval->oh.o = ld16u_i32; return SYMBOL; }
{ld16s_i32}     { HANDLE_COLUMN; yylval->oh.o = ld16s_i32; return SYMBOL; }
{muls2_i32}     { HANDLE_COLUMN; yylval->oh.o = muls2_i32; return SYMBOL; }
{mulsh_i32}     { HANDLE_COLUMN; yylval->oh.o = mulsh_i32; return SYMBOL; }
{mulu2_i32}     { HANDLE_COLUMN; yylval->oh.o = mulu2_i32; return SYMBOL; }
{muluh_i32}     { HANDLE_COLUMN; yylval->oh.o = muluh_i32; return SYMBOL; }
{nand_i32}      { HANDLE_COLUMN; yylval->oh.o = nand_i32; return SYMBOL; }
{negsetcond_i32}    { HANDLE_COLUMN; yylval->oh.o = negsetcond_i32; return SYMBOL; }
{nor_i32}       { HANDLE_COLUMN; yylval->oh.o = nor_i32; return SYMBOL; }
{not_i32}       { HANDLE_COLUMN; yylval->oh.o = not_i32; return SYMBOL; }
{orc_i32}       { HANDLE_COLUMN; yylval->oh.o = orc_i32; return SYMBOL; }
{rems_i32}      { HANDLE_COLUMN; yylval->oh.o = rems_i32; return SYMBOL; }
{remu_i32}      { HANDLE_COLUMN; yylval->oh.o = remu_i32; yylval->oh.h = helper_remu_i32; return SYMBOL; }
{setcond_i32}   { HANDLE_COLUMN; yylval->oh.o = setcond_i32; return SYMBOL; }
{sextract_i32}  { HANDLE_COLUMN; yylval->oh.o = sextract_i32; return SYMBOL; }
{st8_i32}       { HANDLE_COLUMN; yylval->oh.o = st8_i32; return SYMBOL; }
{addco_i32}     { HANDLE_COLUMN; yylval->oh.o = addco_i32; return SYMBOL; }
{addc1o_i32}    { HANDLE_COLUMN; yylval->oh.o = addc1o_i32; return SYMBOL; }
{addci_i32}     { HANDLE_COLUMN; yylval->oh.o = addci_i32; return SYMBOL; }
{addcio_i32}    { HANDLE_COLUMN; yylval->oh.o = addcio_i32; return SYMBOL; }
{subbo_i32}     { HANDLE_COLUMN; yylval->oh.o = subbo_i32; return SYMBOL; }
{subb1o_i32}    { HANDLE_COLUMN; yylval->oh.o = subb1o_i32; return SYMBOL; }
{subbi_i32}     { HANDLE_COLUMN; yylval->oh.o = subbi_i32; return SYMBOL; }
{subbio_i32}    { HANDLE_COLUMN; yylval->oh.o = subbio_i32; return SYMBOL; }
{bswap16_i64}   { HANDLE_COLUMN; yylval->oh.o = bswap16_i64; return BSWAP; }
{ctpop_i64}     { HANDLE_COLUMN; yylval->oh.o = ctpop_i64; yylval->oh.h = helper_ctpop_i64; return SYMBOL; }
{divs_i64}      { HANDLE_COLUMN; yylval->oh.o = divs_i64; return SYMBOL; }
{divs2_i64}     { HANDLE_COLUMN; yylval->oh.o = divs2_i64; return SYMBOL; }
{divu_i64}      { HANDLE_COLUMN; yylval->oh.o = divu_i64; yylval->oh.h = helper_divu_i64; return SYMBOL; }
{divu2_i64}     { HANDLE_COLUMN; yylval->oh.o = divu2_i64; return SYMBOL; }
{eqv_i64}       { HANDLE_COLUMN; yylval->oh.o = eqv_i64; return SYMBOL; }
{ld8s_i64}      { HANDLE_COLUMN; yylval->oh.o = ld8s_i64; return SYMBOL; }
{ld16u_i64}     { HANDLE_COLUMN; yylval->oh.o = ld16u_i64; return SYMBOL; }
{ld16s_i64}     { HANDLE_COLUMN; yylval->oh.o = ld16s_i64; return SYMBOL; }
{muls2_i64}     { HANDLE_COLUMN; yylval->oh.o = muls2_i64; return SYMBOL; }
{mulu2_i64}     { HANDLE_COLUMN; yylval->oh.o = mulu2_i64; return SYMBOL; }
{nand_i64}      { HANDLE_COLUMN; yylval->oh.o = nand_i64; return SYMBOL; }
{nor_i64}       { HANDLE_COLUMN; yylval->oh.o = nor_i64; return SYMBOL; }
{orc_i64}       { HANDLE_COLUMN; yylval->oh.o = orc_i64; return SYMBOL; }
{rems_i64}      { HANDLE_COLUMN; yylval->oh.o = rems_i64; return SYMBOL; }
{remu_i64}      { HANDLE_COLUMN; yylval->oh.o = remu_i64; yylval->oh.h = helper_remu_i64; return SYMBOL; }
{st8_i64}       { HANDLE_COLUMN; yylval->oh.o = st8_i64; return SYMBOL; }
{sub_i64}       { HANDLE_COLUMN; yylval->oh.o = sub_i64; return SYMBOL; }
{addco_i64}     { HANDLE_COLUMN; yylval->oh.o = addco_i64; return SYMBOL; }
{addc1o_i64}    { HANDLE_COLUMN; yylval->oh.o = addc1o_i64; return SYMBOL; }
{addci_i64}     { HANDLE_COLUMN; yylval->oh.o = addci_i64; return SYMBOL; }
{addcio_i64}    { HANDLE_COLUMN; yylval->oh.o = addcio_i64; return SYMBOL; }
{subbo_i64}     { HANDLE_COLUMN; yylval->oh.o = subbo_i64; return SYMBOL; }
{subb1o_i64}    { HANDLE_COLUMN; yylval->oh.o = subb1o_i64; return SYMBOL; }
{subbi_i64}     { HANDLE_COLUMN; yylval->oh.o = subbi_i64; return SYMBOL; }
{subbio_i64}    { HANDLE_COLUMN; yylval->oh.o = subbio_i64; return SYMBOL; }
{dup_vec}       { HANDLE_COLUMN; yylval->oh.o = dup_vec; return SYMBOL; }
{mul_vec}       { HANDLE_COLUMN; yylval->oh.o = mul_vec; return SYMBOL; }
{neg_vec}       { HANDLE_COLUMN; yylval->oh.o = neg_vec; return SYMBOL; }
{abs_vec}       { HANDLE_COLUMN; yylval->oh.o = abs_vec; return SYMBOL; }
{ssadd_vec}     { HANDLE_COLUMN; yylval->oh.o = ssadd_vec; return SYMBOL; }
{usadd_vec}     { HANDLE_COLUMN; yylval->oh.o = usadd_vec; return SYMBOL; }
{sssub_vec}     { HANDLE_COLUMN; yylval->oh.o = sssub_vec; return SYMBOL; }
{ussub_vec}     { HANDLE_COLUMN; yylval->oh.o = ussub_vec; return SYMBOL; }
{smin_vec}      { HANDLE_COLUMN; yylval->oh.o = smin_vec; return SYMBOL; }
{smax_vec}      { HANDLE_COLUMN; yylval->oh.o = smax_vec; return SYMBOL; }
{orc_vec}       { HANDLE_COLUMN; yylval->oh.o = orc_vec; return SYMBOL; }
{nand_vec}      { HANDLE_COLUMN; yylval->oh.o = nand_vec; return SYMBOL; }
{nor_vec}       { HANDLE_COLUMN; yylval->oh.o = nor_vec; return SYMBOL; }
{eqv_vec}       { HANDLE_COLUMN; yylval->oh.o = eqv_vec; return SYMBOL; }
{shri_vec}      { HANDLE_COLUMN; yylval->oh.o = shri_vec; return SYMBOL; }
{sari_vec}      { HANDLE_COLUMN; yylval->oh.o = sari_vec; return SYMBOL; }
{rotli_vec}     { HANDLE_COLUMN; yylval->oh.o = rotli_vec; return SYMBOL; }
{shls_vec}      { HANDLE_COLUMN; yylval->oh.o = shls_vec; return SYMBOL; }
{shrs_vec}      { HANDLE_COLUMN; yylval->oh.o = shrs_vec; return SYMBOL; }
{sars_vec}      { HANDLE_COLUMN; yylval->oh.o = sars_vec; return SYMBOL; }
{rotls_vec}     { HANDLE_COLUMN; yylval->oh.o = rotls_vec; return SYMBOL; }
{shlv_vec}      { HANDLE_COLUMN; yylval->oh.o = shlv_vec; return SYMBOL; }
{shrv_vec}      { HANDLE_COLUMN; yylval->oh.o = shrv_vec; return SYMBOL; }
{sarv_vec}      { HANDLE_COLUMN; yylval->oh.o = sarv_vec; return SYMBOL; }
{rotlv_vec}     { HANDLE_COLUMN; yylval->oh.o = rotlv_vec; return SYMBOL; }
{rotrv_vec}     { HANDLE_COLUMN; yylval->oh.o = rotrv_vec; return SYMBOL; }
{bitsel_vec}    { HANDLE_COLUMN; yylval->oh.o = bitsel_vec; return SYMBOL; }
{cmpsel_vec}    { HANDLE_COLUMN; yylval->oh.o = cmpsel_vec; return SYMBOL; }
{ext_i32_i64}   { HANDLE_COLUMN; yylval->oh.o = ext_i32_i64; return SYMBOL; }
{extrh_i64_i32} { HANDLE_COLUMN; yylval->oh.o = extrh_i64_i32; return SYMBOL; }
{add_i64}       { HANDLE_COLUMN; yylval->oh.o = add_i64; return SYMBOL; }
{add_vec}       { HANDLE_COLUMN; yylval->oh.o = add_vec; return SYMBOL; }
{andc_i64}      { HANDLE_COLUMN; yylval->oh.o = andc_i64; return SYMBOL; }
{andc_vec}      { HANDLE_COLUMN; yylval->oh.o = andc_vec; return SYMBOL; }
{and_i64}       { HANDLE_COLUMN; yylval->oh.o = and_i64; return SYMBOL; }
{and_i32}       { HANDLE_COLUMN; yylval->oh.o = and_i32; return SYMBOL; }
{and_vec}       { HANDLE_COLUMN; yylval->oh.o = and_vec; return SYMBOL; }
{bswap32_i64}   { HANDLE_COLUMN; yylval->oh.o = bswap32_i64; return BSWAP; }
{clz_i64}       { HANDLE_COLUMN; yylval->oh.o = clz_i64; yylval->oh.h = helper_clz_i64; return SYMBOL; }
{cmp_vec}       { HANDLE_COLUMN; yylval->oh.o = cmp_vec; return SYMBOL; }
{ctz_i64}       { HANDLE_COLUMN; yylval->oh.o = ctz_i64; yylval->oh.h = helper_ctz_i64; return SYMBOL; }
{deposit_i32}   { HANDLE_COLUMN; yylval->oh.o = deposit_i32; return SYMBOL; }
{deposit_i64}   { HANDLE_COLUMN; yylval->oh.o = deposit_i64; return SYMBOL; }
{dupm_vec}      { HANDLE_COLUMN; yylval->oh.o = dupm_vec; return SYMBOL; }
{extract2_i64}  { HANDLE_COLUMN; yylval->oh.o = extract2_i64; return SYMBOL; }
{extract_i32}   { HANDLE_COLUMN; yylval->oh.o = extract_i32; return SYMBOL; }
{extract_i64}   { HANDLE_COLUMN; yylval->oh.o = extract_i64; return SYMBOL; }
{extrl_i64_i32} { HANDLE_COLUMN; yylval->oh.o = extrl_i64_i32; return SYMBOL; }
{extu_i32_i64}  { HANDLE_COLUMN; yylval->oh.o = extu_i32_i64; return SYMBOL; }
{ld32s_i64}     { HANDLE_COLUMN; yylval->oh.o = ld32s_i64; return SYMBOL; }
{ld32u_i64}     { HANDLE_COLUMN; yylval->oh.o = ld32u_i64; return SYMBOL; }
{ld8u_i64}      { HANDLE_COLUMN; yylval->oh.o = ld8u_i64; return SYMBOL; }
{ld_i32}        { HANDLE_COLUMN; yylval->oh.o = ld_i32; return SYMBOL; }
{ld_i64}        { HANDLE_COLUMN; yylval->oh.o = ld_i64; return SYMBOL; }
{ld_vec}        { HANDLE_COLUMN; yylval->oh.o = ld_vec; return SYMBOL; }
{movcond_i32}   { HANDLE_COLUMN; yylval->oh.o = movcond_i32; return SYMBOL; }
{movcond_i64}   { HANDLE_COLUMN; yylval->oh.o = movcond_i64; return SYMBOL; }
{movcond_vec}   { HANDLE_COLUMN; yylval->oh.o = movcond_vec; return SYMBOL; }
{mov_i32}       { HANDLE_COLUMN; yylval->oh.o = mov_i32; return SYMBOL; }
{mov_i64}       { HANDLE_COLUMN; yylval->oh.o = mov_i64; return SYMBOL; }
{mov_vec}       { HANDLE_COLUMN; yylval->oh.o = mov_vec; return SYMBOL; }
{mul_i32}       { HANDLE_COLUMN; yylval->oh.o = mul_i32; return SYMBOL; }
{mul_i64}       { HANDLE_COLUMN; yylval->oh.o = mul_i64; return SYMBOL; }
{mulsh_i64}     { HANDLE_COLUMN; yylval->oh.o = mulsh_i64; yylval->oh.h = helper_mulsh_i64; return SYMBOL; }
{muluh_i64}     { HANDLE_COLUMN; yylval->oh.o = muluh_i64; yylval->oh.h = helper_muluh_i64; return SYMBOL; }
{neg_i32}       { HANDLE_COLUMN; yylval->oh.o = neg_i32; return SYMBOL; }
{neg_i64}       { HANDLE_COLUMN; yylval->oh.o = neg_i64; return SYMBOL; }
{negsetcond_i64}    { HANDLE_COLUMN; yylval->oh.o = negsetcond_i64; return SYMBOL; }
{not_i64}       { HANDLE_COLUMN; yylval->oh.o = not_i64; return SYMBOL; }
{not_vec}       { HANDLE_COLUMN; yylval->oh.o = not_vec; return SYMBOL; }
{or_i64}        { HANDLE_COLUMN; yylval->oh.o = or_i64; return SYMBOL; }
{or_i32}        { HANDLE_COLUMN; yylval->oh.o = or_i32; return SYMBOL; }
{or_vec}        { HANDLE_COLUMN; yylval->oh.o = or_vec; return SYMBOL; }
{push_ret_addr} { HANDLE_COLUMN; yylval->oh.o = push_ret_addr; return SYMBOL; }
{qemu_ld2_i128} { HANDLE_COLUMN; yylval->oh.o = qemu_ld2_i128; return SYMBOL; }
{qemu_ld_i32}   { HANDLE_COLUMN; yylval->oh.o = qemu_ld_i32; return SYMBOL; }
{qemu_ld_i64}   { HANDLE_COLUMN; yylval->oh.o = qemu_ld_i64; return SYMBOL; }
{qemu_st2_i128} { HANDLE_COLUMN; yylval->oh.o = qemu_st2_i128; return SYMBOL; }
{qemu_st_i32}   { HANDLE_COLUMN; yylval->oh.o = qemu_st_i32; return SYMBOL; }
{qemu_st_i64}   { HANDLE_COLUMN; yylval->oh.o = qemu_st_i64; return SYMBOL; }
{ret}           { HANDLE_COLUMN; yylval->oh.o = ret; return SYMBOL; }
{rotr_i32}      { HANDLE_COLUMN; yylval->oh.o = rotr_i32; return SYMBOL; }
{rotr_i64}      { HANDLE_COLUMN; yylval->oh.o = rotr_i64; return SYMBOL; }
{sar_i32}       { HANDLE_COLUMN; yylval->oh.o = sar_i32; return SYMBOL; }
{sar_i64}       { HANDLE_COLUMN; yylval->oh.o = sar_i64; yylval->oh.h = helper_sar_i64; return SYMBOL; }
{setcond_i64}   { HANDLE_COLUMN; yylval->oh.o = setcond_i64; return SYMBOL; }
{sextract_i64}  { HANDLE_COLUMN; yylval->oh.o = sextract_i64; return SYMBOL; }
{shl_i64}       { HANDLE_COLUMN; yylval->oh.o = shl_i64; yylval->oh.h = helper_shl_i64; return SYMBOL; }
{shl_i32}       { HANDLE_COLUMN; yylval->oh.o = shl_i32; return SYMBOL; }
{shli_vec}      { HANDLE_COLUMN; yylval->oh.o = shli_vec; return SYMBOL; }
{shr_i64}       { HANDLE_COLUMN; yylval->oh.o = shr_i64; yylval->oh.h = helper_shr_i64; return SYMBOL; }
{shr_i32}       { HANDLE_COLUMN; yylval->oh.o = shr_i32; return SYMBOL; }
{st16_i32}      { HANDLE_COLUMN; yylval->oh.o = st16_i32; return SYMBOL; }
{st16_i64}      { HANDLE_COLUMN; yylval->oh.o = st16_i64; return SYMBOL; }
{st32_i64}      { HANDLE_COLUMN; yylval->oh.o = st32_i64; return SYMBOL; }
{st_i32}        { HANDLE_COLUMN; yylval->oh.o = st_i32; return SYMBOL; }
{st_i64}        { HANDLE_COLUMN; yylval->oh.o = st_i64; return SYMBOL; }
{st_vec}        { HANDLE_COLUMN; yylval->oh.o = st_vec; return SYMBOL; }
{sub_i32}       { HANDLE_COLUMN; yylval->oh.o = sub_i32; return SYMBOL; }
{sub_vec}       { HANDLE_COLUMN; yylval->oh.o = sub_vec; return SYMBOL; }
{umax_vec}      { HANDLE_COLUMN; yylval->oh.o = umax_vec; return SYMBOL; }
{umin_vec}      { HANDLE_COLUMN; yylval->oh.o = umin_vec; return SYMBOL; }
{xor_i64}       { HANDLE_COLUMN; yylval->oh.o = xor_i64; return SYMBOL; }
{xor_i32}       { HANDLE_COLUMN; yylval->oh.o = xor_i32; return SYMBOL; }
{xor_vec}       { HANDLE_COLUMN; yylval->oh.o = xor_vec; return SYMBOL; }
{bswap64_i64}   { HANDLE_COLUMN; yylval->oh.o = bswap64_i64; return BSWAP; }
{set_label}     { HANDLE_COLUMN; yylval->oh.o = set_label; return SETLABL; }
{brcond_i64}    { HANDLE_COLUMN; yylval->oh.o = brcond_i64; return BRCOND; }
{jmp_direct}    { HANDLE_COLUMN; yylval->oh.o = jmp_direct; return JMPDIR; }
{call_direct}   { HANDLE_COLUMN; yylval->oh.o = call_direct; return CALLDIR; }
{discard}       { HANDLE_COLUMN; yylval->oh.o = discard; return DISCARD; }
{call}          { HANDLE_COLUMN; yylval->oh.o = call; return CALL; }
{rotl_i32}      { HANDLE_COLUMN; yylval->oh.o = rotl_i32; return SYMBOL; }
{rotl_i64}      { HANDLE_COLUMN; yylval->oh.o = rotl_i64; return SYMBOL; }

{aaa}                           { HANDLE_COLUMN; yylval->oh.h = helper_aaa; return SYMBOL; }
{aad}                           { HANDLE_COLUMN; yylval->oh.h = helper_aad; return SYMBOL; }
{aam}                           { HANDLE_COLUMN; yylval->oh.h = helper_aam; return SYMBOL; }
{aas}                           { HANDLE_COLUMN; yylval->oh.h = helper_aas; return SYMBOL; }
{addpd_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_addpd_xmm; return SYMBOL; }
{addpd_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_addpd_ymm; return SYMBOL; }
{addps_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_addps_xmm; return SYMBOL; }
{addps_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_addps_ymm; return SYMBOL; }
{addsd}                         { HANDLE_COLUMN; yylval->oh.h = helper_addsd; return SYMBOL; }
{addss}                         { HANDLE_COLUMN; yylval->oh.h = helper_addss; return SYMBOL; }
{addsubpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_addsubpd_xmm; return SYMBOL; }
{addsubpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_addsubpd_ymm; return SYMBOL; }
{addsubps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_addsubps_xmm; return SYMBOL; }
{addsubps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_addsubps_ymm; return SYMBOL; }
{aesdeclast_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_aesdeclast_xmm; return SYMBOL; }
{aesdeclast_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_aesdeclast_ymm; return SYMBOL; }
{aesdec_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_aesdec_xmm; return SYMBOL; }
{aesdec_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_aesdec_ymm; return SYMBOL; }
{aesenclast_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_aesenclast_xmm; return SYMBOL; }
{aesenclast_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_aesenclast_ymm; return SYMBOL; }
{aesenc_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_aesenc_xmm; return SYMBOL; }
{aesenc_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_aesenc_ymm; return SYMBOL; }
{aesimc_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_aesimc_xmm; return SYMBOL; }
{aeskeygenassist_xmm}           { HANDLE_COLUMN; yylval->oh.h = helper_aeskeygenassist_xmm; return SYMBOL; }
{atomic_add_fetchb}             { HANDLE_COLUMN; yylval->oh.h = helper_atomic_add_fetchb; return SYMBOL; }
{atomic_add_fetchl_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_add_fetchl_be; return SYMBOL; }
{atomic_add_fetchl_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_add_fetchl_le; return SYMBOL; }
{atomic_add_fetchq_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_add_fetchq_be; return SYMBOL; }
{atomic_add_fetchq_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_add_fetchq_le; return SYMBOL; }
{atomic_add_fetchw_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_add_fetchw_be; return SYMBOL; }
{atomic_add_fetchw_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_add_fetchw_le; return SYMBOL; }
{atomic_and_fetchb}             { HANDLE_COLUMN; yylval->oh.h = helper_atomic_and_fetchb; return SYMBOL; }
{atomic_and_fetchl_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_and_fetchl_be; return SYMBOL; }
{atomic_and_fetchl_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_and_fetchl_le; return SYMBOL; }
{atomic_and_fetchq_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_and_fetchq_be; return SYMBOL; }
{atomic_and_fetchq_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_and_fetchq_le; return SYMBOL; }
{atomic_and_fetchw_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_and_fetchw_be; return SYMBOL; }
{atomic_and_fetchw_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_and_fetchw_le; return SYMBOL; }
{atomic_cmpxchgb}               { HANDLE_COLUMN; yylval->oh.h = helper_atomic_cmpxchgb; return SYMBOL; }
{atomic_cmpxchgl_be}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_cmpxchgl_be; return SYMBOL; }
{atomic_cmpxchgl_le}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_cmpxchgl_le; return SYMBOL; }
{atomic_cmpxchgo_be}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_cmpxchgo_be; return SYMBOL; }
{atomic_cmpxchgo_le}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_cmpxchgo_le; return SYMBOL; }
{atomic_cmpxchgq_be}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_cmpxchgq_be; return SYMBOL; }
{atomic_cmpxchgq_le}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_cmpxchgq_le; return SYMBOL; }
{atomic_cmpxchgw_be}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_cmpxchgw_be; return SYMBOL; }
{atomic_cmpxchgw_le}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_cmpxchgw_le; return SYMBOL; }
{atomic_fetch_addb}             { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_addb; return SYMBOL; }
{atomic_fetch_addl_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_addl_be; return SYMBOL; }
{atomic_fetch_addl_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_addl_le; return SYMBOL; }
{atomic_fetch_addq_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_addq_be; return SYMBOL; }
{atomic_fetch_addq_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_addq_le; return SYMBOL; }
{atomic_fetch_addw_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_addw_be; return SYMBOL; }
{atomic_fetch_addw_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_addw_le; return SYMBOL; }
{atomic_fetch_andb}             { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_andb; return SYMBOL; }
{atomic_fetch_andl_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_andl_be; return SYMBOL; }
{atomic_fetch_andl_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_andl_le; return SYMBOL; }
{atomic_fetch_andq_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_andq_be; return SYMBOL; }
{atomic_fetch_andq_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_andq_le; return SYMBOL; }
{atomic_fetch_andw_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_andw_be; return SYMBOL; }
{atomic_fetch_andw_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_andw_le; return SYMBOL; }
{atomic_fetch_orb}              { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_orb; return SYMBOL; }
{atomic_fetch_orl_be}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_orl_be; return SYMBOL; }
{atomic_fetch_orl_le}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_orl_le; return SYMBOL; }
{atomic_fetch_orq_be}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_orq_be; return SYMBOL; }
{atomic_fetch_orq_le}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_orq_le; return SYMBOL; }
{atomic_fetch_orw_be}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_orw_be; return SYMBOL; }
{atomic_fetch_orw_le}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_orw_le; return SYMBOL; }
{atomic_fetch_smaxb}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_smaxb; return SYMBOL; }
{atomic_fetch_smaxl_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_smaxl_be; return SYMBOL; }
{atomic_fetch_smaxl_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_smaxl_le; return SYMBOL; }
{atomic_fetch_smaxq_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_smaxq_be; return SYMBOL; }
{atomic_fetch_smaxq_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_smaxq_le; return SYMBOL; }
{atomic_fetch_smaxw_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_smaxw_be; return SYMBOL; }
{atomic_fetch_smaxw_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_smaxw_le; return SYMBOL; }
{atomic_fetch_sminb}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_sminb; return SYMBOL; }
{atomic_fetch_sminl_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_sminl_be; return SYMBOL; }
{atomic_fetch_sminl_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_sminl_le; return SYMBOL; }
{atomic_fetch_sminq_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_sminq_be; return SYMBOL; }
{atomic_fetch_sminq_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_sminq_le; return SYMBOL; }
{atomic_fetch_sminw_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_sminw_be; return SYMBOL; }
{atomic_fetch_sminw_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_sminw_le; return SYMBOL; }
{atomic_fetch_umaxb}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_umaxb; return SYMBOL; }
{atomic_fetch_umaxl_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_umaxl_be; return SYMBOL; }
{atomic_fetch_umaxl_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_umaxl_le; return SYMBOL; }
{atomic_fetch_umaxq_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_umaxq_be; return SYMBOL; }
{atomic_fetch_umaxq_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_umaxq_le; return SYMBOL; }
{atomic_fetch_umaxw_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_umaxw_be; return SYMBOL; }
{atomic_fetch_umaxw_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_umaxw_le; return SYMBOL; }
{atomic_fetch_uminb}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_uminb; return SYMBOL; }
{atomic_fetch_uminl_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_uminl_be; return SYMBOL; }
{atomic_fetch_uminl_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_uminl_le; return SYMBOL; }
{atomic_fetch_uminq_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_uminq_be; return SYMBOL; }
{atomic_fetch_uminq_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_uminq_le; return SYMBOL; }
{atomic_fetch_uminw_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_uminw_be; return SYMBOL; }
{atomic_fetch_uminw_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_uminw_le; return SYMBOL; }
{atomic_fetch_xorb}             { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_xorb; return SYMBOL; }
{atomic_fetch_xorl_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_xorl_be; return SYMBOL; }
{atomic_fetch_xorl_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_xorl_le; return SYMBOL; }
{atomic_fetch_xorq_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_xorq_be; return SYMBOL; }
{atomic_fetch_xorq_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_xorq_le; return SYMBOL; }
{atomic_fetch_xorw_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_xorw_be; return SYMBOL; }
{atomic_fetch_xorw_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_fetch_xorw_le; return SYMBOL; }
{atomic_or_fetchb}              { HANDLE_COLUMN; yylval->oh.h = helper_atomic_or_fetchb; return SYMBOL; }
{atomic_or_fetchl_be}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_or_fetchl_be; return SYMBOL; }
{atomic_or_fetchl_le}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_or_fetchl_le; return SYMBOL; }
{atomic_or_fetchq_be}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_or_fetchq_be; return SYMBOL; }
{atomic_or_fetchq_le}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_or_fetchq_le; return SYMBOL; }
{atomic_or_fetchw_be}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_or_fetchw_be; return SYMBOL; }
{atomic_or_fetchw_le}           { HANDLE_COLUMN; yylval->oh.h = helper_atomic_or_fetchw_le; return SYMBOL; }
{atomic_smax_fetchb}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smax_fetchb; return SYMBOL; }
{atomic_smax_fetchl_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smax_fetchl_be; return SYMBOL; }
{atomic_smax_fetchl_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smax_fetchl_le; return SYMBOL; }
{atomic_smax_fetchq_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smax_fetchq_be; return SYMBOL; }
{atomic_smax_fetchq_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smax_fetchq_le; return SYMBOL; }
{atomic_smax_fetchw_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smax_fetchw_be; return SYMBOL; }
{atomic_smax_fetchw_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smax_fetchw_le; return SYMBOL; }
{atomic_smin_fetchb}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smin_fetchb; return SYMBOL; }
{atomic_smin_fetchl_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smin_fetchl_be; return SYMBOL; }
{atomic_smin_fetchl_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smin_fetchl_le; return SYMBOL; }
{atomic_smin_fetchq_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smin_fetchq_be; return SYMBOL; }
{atomic_smin_fetchq_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smin_fetchq_le; return SYMBOL; }
{atomic_smin_fetchw_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smin_fetchw_be; return SYMBOL; }
{atomic_smin_fetchw_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_smin_fetchw_le; return SYMBOL; }
{atomic_umax_fetchb}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umax_fetchb; return SYMBOL; }
{atomic_umax_fetchl_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umax_fetchl_be; return SYMBOL; }
{atomic_umax_fetchl_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umax_fetchl_le; return SYMBOL; }
{atomic_umax_fetchq_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umax_fetchq_be; return SYMBOL; }
{atomic_umax_fetchq_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umax_fetchq_le; return SYMBOL; }
{atomic_umax_fetchw_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umax_fetchw_be; return SYMBOL; }
{atomic_umax_fetchw_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umax_fetchw_le; return SYMBOL; }
{atomic_umin_fetchb}            { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umin_fetchb; return SYMBOL; }
{atomic_umin_fetchl_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umin_fetchl_be; return SYMBOL; }
{atomic_umin_fetchl_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umin_fetchl_le; return SYMBOL; }
{atomic_umin_fetchq_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umin_fetchq_be; return SYMBOL; }
{atomic_umin_fetchq_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umin_fetchq_le; return SYMBOL; }
{atomic_umin_fetchw_be}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umin_fetchw_be; return SYMBOL; }
{atomic_umin_fetchw_le}         { HANDLE_COLUMN; yylval->oh.h = helper_atomic_umin_fetchw_le; return SYMBOL; }
{atomic_xchgb}                  { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xchgb; return SYMBOL; }
{atomic_xchgl_be}               { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xchgl_be; return SYMBOL; }
{atomic_xchgl_le}               { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xchgl_le; return SYMBOL; }
{atomic_xchgq_be}               { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xchgq_be; return SYMBOL; }
{atomic_xchgq_le}               { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xchgq_le; return SYMBOL; }
{atomic_xchgw_be}               { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xchgw_be; return SYMBOL; }
{atomic_xchgw_le}               { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xchgw_le; return SYMBOL; }
{atomic_xor_fetchb}             { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xor_fetchb; return SYMBOL; }
{atomic_xor_fetchl_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xor_fetchl_be; return SYMBOL; }
{atomic_xor_fetchl_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xor_fetchl_le; return SYMBOL; }
{atomic_xor_fetchq_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xor_fetchq_be; return SYMBOL; }
{atomic_xor_fetchq_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xor_fetchq_le; return SYMBOL; }
{atomic_xor_fetchw_be}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xor_fetchw_be; return SYMBOL; }
{atomic_xor_fetchw_le}          { HANDLE_COLUMN; yylval->oh.h = helper_atomic_xor_fetchw_le; return SYMBOL; }
{blendpd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_blendpd_xmm; return SYMBOL; }
{blendpd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_blendpd_ymm; return SYMBOL; }
{blendps_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_blendps_xmm; return SYMBOL; }
{blendps_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_blendps_ymm; return SYMBOL; }
{blendvpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_blendvpd_xmm; return SYMBOL; }
{blendvpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_blendvpd_ymm; return SYMBOL; }
{blendvps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_blendvps_xmm; return SYMBOL; }
{blendvps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_blendvps_ymm; return SYMBOL; }
{bndck}                         { HANDLE_COLUMN; yylval->oh.h = helper_bndck; return SYMBOL; }
{bnd_jmp}                       { HANDLE_COLUMN; yylval->oh.h = helper_bnd_jmp; return SYMBOL; }
{bndldx32}                      { HANDLE_COLUMN; yylval->oh.h = helper_bndldx32; return SYMBOL; }
{bndldx64}                      { HANDLE_COLUMN; yylval->oh.h = helper_bndldx64; return SYMBOL; }
{bndstx32}                      { HANDLE_COLUMN; yylval->oh.h = helper_bndstx32; return SYMBOL; }
{bndstx64}                      { HANDLE_COLUMN; yylval->oh.h = helper_bndstx64; return SYMBOL; }
{boundl}                        { HANDLE_COLUMN; yylval->oh.h = helper_boundl; return SYMBOL; }
{boundw}                        { HANDLE_COLUMN; yylval->oh.h = helper_boundw; return SYMBOL; }
{cc_compute_all}                { HANDLE_COLUMN; yylval->oh.h = helper_cc_compute_all; return SYMBOL; }
{cc_compute_c}                  { HANDLE_COLUMN; yylval->oh.h = helper_cc_compute_c; return SYMBOL; }
{cc_compute_nz}                 { HANDLE_COLUMN; yylval->oh.h = helper_cc_compute_nz; return SYMBOL; }
{clrsb_i32}                     { HANDLE_COLUMN; yylval->oh.h = helper_clrsb_i32; return SYMBOL; }
{clrsb_i64}                     { HANDLE_COLUMN; yylval->oh.h = helper_clrsb_i64; return SYMBOL; }
{clts}                          { HANDLE_COLUMN; yylval->oh.h = helper_clts; return SYMBOL; }
{cmpeqpd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqpd_xmm; return SYMBOL; }
{cmpeqpd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqpd_ymm; return SYMBOL; }
{cmpeqps_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqps_xmm; return SYMBOL; }
{cmpeqps_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqps_ymm; return SYMBOL; }
{cmpeqsd}                       { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqsd; return SYMBOL; }
{cmpeqspd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqspd_xmm; return SYMBOL; }
{cmpeqspd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqspd_ymm; return SYMBOL; }
{cmpeqsps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqsps_xmm; return SYMBOL; }
{cmpeqsps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqsps_ymm; return SYMBOL; }
{cmpeqss}                       { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqss; return SYMBOL; }
{cmpeqssd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqssd; return SYMBOL; }
{cmpeqsss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpeqsss; return SYMBOL; }
{cmpequpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpequpd_xmm; return SYMBOL; }
{cmpequpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpequpd_ymm; return SYMBOL; }
{cmpequps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpequps_xmm; return SYMBOL; }
{cmpequps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpequps_ymm; return SYMBOL; }
{cmpequsd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpequsd; return SYMBOL; }
{cmpequspd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpequspd_xmm; return SYMBOL; }
{cmpequspd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpequspd_ymm; return SYMBOL; }
{cmpequsps_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpequsps_xmm; return SYMBOL; }
{cmpequsps_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpequsps_ymm; return SYMBOL; }
{cmpequss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpequss; return SYMBOL; }
{cmpequssd}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpequssd; return SYMBOL; }
{cmpequsss}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpequsss; return SYMBOL; }
{cmpfalsepd_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalsepd_xmm; return SYMBOL; }
{cmpfalsepd_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalsepd_ymm; return SYMBOL; }
{cmpfalseps_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalseps_xmm; return SYMBOL; }
{cmpfalseps_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalseps_ymm; return SYMBOL; }
{cmpfalsesd}                    { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalsesd; return SYMBOL; }
{cmpfalsespd_xmm}               { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalsespd_xmm; return SYMBOL; }
{cmpfalsespd_ymm}               { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalsespd_ymm; return SYMBOL; }
{cmpfalsesps_xmm}               { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalsesps_xmm; return SYMBOL; }
{cmpfalsesps_ymm}               { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalsesps_ymm; return SYMBOL; }
{cmpfalsess}                    { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalsess; return SYMBOL; }
{cmpfalsessd}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalsessd; return SYMBOL; }
{cmpfalsesss}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpfalsesss; return SYMBOL; }
{cmpgepd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpgepd_xmm; return SYMBOL; }
{cmpgepd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpgepd_ymm; return SYMBOL; }
{cmpgeps_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpgeps_xmm; return SYMBOL; }
{cmpgeps_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpgeps_ymm; return SYMBOL; }
{cmpgeqpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpgeqpd_xmm; return SYMBOL; }
{cmpgeqpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpgeqpd_ymm; return SYMBOL; }
{cmpgeqps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpgeqps_xmm; return SYMBOL; }
{cmpgeqps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpgeqps_ymm; return SYMBOL; }
{cmpgeqsd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpgeqsd; return SYMBOL; }
{cmpgeqss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpgeqss; return SYMBOL; }
{cmpgesd}                       { HANDLE_COLUMN; yylval->oh.h = helper_cmpgesd; return SYMBOL; }
{cmpgess}                       { HANDLE_COLUMN; yylval->oh.h = helper_cmpgess; return SYMBOL; }
{cmpgtpd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtpd_xmm; return SYMBOL; }
{cmpgtpd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtpd_ymm; return SYMBOL; }
{cmpgtps_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtps_xmm; return SYMBOL; }
{cmpgtps_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtps_ymm; return SYMBOL; }
{cmpgtqpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtqpd_xmm; return SYMBOL; }
{cmpgtqpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtqpd_ymm; return SYMBOL; }
{cmpgtqps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtqps_xmm; return SYMBOL; }
{cmpgtqps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtqps_ymm; return SYMBOL; }
{cmpgtqsd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtqsd; return SYMBOL; }
{cmpgtqss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtqss; return SYMBOL; }
{cmpgtsd}                       { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtsd; return SYMBOL; }
{cmpgtss}                       { HANDLE_COLUMN; yylval->oh.h = helper_cmpgtss; return SYMBOL; }
{cmplepd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmplepd_xmm; return SYMBOL; }
{cmplepd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmplepd_ymm; return SYMBOL; }
{cmpleps_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpleps_xmm; return SYMBOL; }
{cmpleps_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpleps_ymm; return SYMBOL; }
{cmpleqpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpleqpd_xmm; return SYMBOL; }
{cmpleqpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpleqpd_ymm; return SYMBOL; }
{cmpleqps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpleqps_xmm; return SYMBOL; }
{cmpleqps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpleqps_ymm; return SYMBOL; }
{cmpleqsd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpleqsd; return SYMBOL; }
{cmpleqss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpleqss; return SYMBOL; }
{cmplesd}                       { HANDLE_COLUMN; yylval->oh.h = helper_cmplesd; return SYMBOL; }
{cmpless}                       { HANDLE_COLUMN; yylval->oh.h = helper_cmpless; return SYMBOL; }
{cmpltpd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpltpd_xmm; return SYMBOL; }
{cmpltpd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpltpd_ymm; return SYMBOL; }
{cmpltps_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpltps_xmm; return SYMBOL; }
{cmpltps_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpltps_ymm; return SYMBOL; }
{cmpltqpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpltqpd_xmm; return SYMBOL; }
{cmpltqpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpltqpd_ymm; return SYMBOL; }
{cmpltqps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpltqps_xmm; return SYMBOL; }
{cmpltqps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpltqps_ymm; return SYMBOL; }
{cmpltqsd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpltqsd; return SYMBOL; }
{cmpltqss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpltqss; return SYMBOL; }
{cmpltsd}                       { HANDLE_COLUMN; yylval->oh.h = helper_cmpltsd; return SYMBOL; }
{cmpltss}                       { HANDLE_COLUMN; yylval->oh.h = helper_cmpltss; return SYMBOL; }
{cmpneqpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqpd_xmm; return SYMBOL; }
{cmpneqpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqpd_ymm; return SYMBOL; }
{cmpneqps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqps_xmm; return SYMBOL; }
{cmpneqps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqps_ymm; return SYMBOL; }
{cmpneqqpd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqqpd_xmm; return SYMBOL; }
{cmpneqqpd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqqpd_ymm; return SYMBOL; }
{cmpneqqps_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqqps_xmm; return SYMBOL; }
{cmpneqqps_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqqps_ymm; return SYMBOL; }
{cmpneqqsd}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqqsd; return SYMBOL; }
{cmpneqqss}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqqss; return SYMBOL; }
{cmpneqsd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqsd; return SYMBOL; }
{cmpneqss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpneqss; return SYMBOL; }
{cmpnequpd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequpd_xmm; return SYMBOL; }
{cmpnequpd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequpd_ymm; return SYMBOL; }
{cmpnequps_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequps_xmm; return SYMBOL; }
{cmpnequps_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequps_ymm; return SYMBOL; }
{cmpnequsd}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequsd; return SYMBOL; }
{cmpnequspd_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequspd_xmm; return SYMBOL; }
{cmpnequspd_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequspd_ymm; return SYMBOL; }
{cmpnequsps_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequsps_xmm; return SYMBOL; }
{cmpnequsps_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequsps_ymm; return SYMBOL; }
{cmpnequss}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequss; return SYMBOL; }
{cmpnequssd}                    { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequssd; return SYMBOL; }
{cmpnequsss}                    { HANDLE_COLUMN; yylval->oh.h = helper_cmpnequsss; return SYMBOL; }
{cmpngepd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpngepd_xmm; return SYMBOL; }
{cmpngepd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpngepd_ymm; return SYMBOL; }
{cmpngeps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpngeps_xmm; return SYMBOL; }
{cmpngeps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpngeps_ymm; return SYMBOL; }
{cmpngeqpd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpngeqpd_xmm; return SYMBOL; }
{cmpngeqpd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpngeqpd_ymm; return SYMBOL; }
{cmpngeqps_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpngeqps_xmm; return SYMBOL; }
{cmpngeqps_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpngeqps_ymm; return SYMBOL; }
{cmpngeqsd}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpngeqsd; return SYMBOL; }
{cmpngeqss}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpngeqss; return SYMBOL; }
{cmpngesd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpngesd; return SYMBOL; }
{cmpngess}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpngess; return SYMBOL; }
{cmpngtpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtpd_xmm; return SYMBOL; }
{cmpngtpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtpd_ymm; return SYMBOL; }
{cmpngtps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtps_xmm; return SYMBOL; }
{cmpngtps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtps_ymm; return SYMBOL; }
{cmpngtqpd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtqpd_xmm; return SYMBOL; }
{cmpngtqpd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtqpd_ymm; return SYMBOL; }
{cmpngtqps_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtqps_xmm; return SYMBOL; }
{cmpngtqps_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtqps_ymm; return SYMBOL; }
{cmpngtqsd}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtqsd; return SYMBOL; }
{cmpngtqss}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtqss; return SYMBOL; }
{cmpngtsd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtsd; return SYMBOL; }
{cmpngtss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpngtss; return SYMBOL; }
{cmpnlepd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpnlepd_xmm; return SYMBOL; }
{cmpnlepd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpnlepd_ymm; return SYMBOL; }
{cmpnleps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpnleps_xmm; return SYMBOL; }
{cmpnleps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpnleps_ymm; return SYMBOL; }
{cmpnleqpd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnleqpd_xmm; return SYMBOL; }
{cmpnleqpd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnleqpd_ymm; return SYMBOL; }
{cmpnleqps_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnleqps_xmm; return SYMBOL; }
{cmpnleqps_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnleqps_ymm; return SYMBOL; }
{cmpnleqsd}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpnleqsd; return SYMBOL; }
{cmpnleqss}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpnleqss; return SYMBOL; }
{cmpnlesd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpnlesd; return SYMBOL; }
{cmpnless}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpnless; return SYMBOL; }
{cmpnltpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltpd_xmm; return SYMBOL; }
{cmpnltpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltpd_ymm; return SYMBOL; }
{cmpnltps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltps_xmm; return SYMBOL; }
{cmpnltps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltps_ymm; return SYMBOL; }
{cmpnltqpd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltqpd_xmm; return SYMBOL; }
{cmpnltqpd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltqpd_ymm; return SYMBOL; }
{cmpnltqps_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltqps_xmm; return SYMBOL; }
{cmpnltqps_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltqps_ymm; return SYMBOL; }
{cmpnltqsd}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltqsd; return SYMBOL; }
{cmpnltqss}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltqss; return SYMBOL; }
{cmpnltsd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltsd; return SYMBOL; }
{cmpnltss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpnltss; return SYMBOL; }
{cmpordpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpordpd_xmm; return SYMBOL; }
{cmpordpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpordpd_ymm; return SYMBOL; }
{cmpordps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpordps_xmm; return SYMBOL; }
{cmpordps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cmpordps_ymm; return SYMBOL; }
{cmpordsd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpordsd; return SYMBOL; }
{cmpordspd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpordspd_xmm; return SYMBOL; }
{cmpordspd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpordspd_ymm; return SYMBOL; }
{cmpordsps_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpordsps_xmm; return SYMBOL; }
{cmpordsps_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmpordsps_ymm; return SYMBOL; }
{cmpordss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cmpordss; return SYMBOL; }
{cmpordssd}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpordssd; return SYMBOL; }
{cmpordsss}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmpordsss; return SYMBOL; }
{cmptruepd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmptruepd_xmm; return SYMBOL; }
{cmptruepd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmptruepd_ymm; return SYMBOL; }
{cmptrueps_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmptrueps_xmm; return SYMBOL; }
{cmptrueps_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cmptrueps_ymm; return SYMBOL; }
{cmptruesd}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmptruesd; return SYMBOL; }
{cmptruespd_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmptruespd_xmm; return SYMBOL; }
{cmptruespd_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmptruespd_ymm; return SYMBOL; }
{cmptruesps_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmptruesps_xmm; return SYMBOL; }
{cmptruesps_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmptruesps_ymm; return SYMBOL; }
{cmptruess}                     { HANDLE_COLUMN; yylval->oh.h = helper_cmptruess; return SYMBOL; }
{cmptruessd}                    { HANDLE_COLUMN; yylval->oh.h = helper_cmptruessd; return SYMBOL; }
{cmptruesss}                    { HANDLE_COLUMN; yylval->oh.h = helper_cmptruesss; return SYMBOL; }
{cmpunordpd_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordpd_xmm; return SYMBOL; }
{cmpunordpd_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordpd_ymm; return SYMBOL; }
{cmpunordps_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordps_xmm; return SYMBOL; }
{cmpunordps_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordps_ymm; return SYMBOL; }
{cmpunordsd}                    { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordsd; return SYMBOL; }
{cmpunordspd_xmm}               { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordspd_xmm; return SYMBOL; }
{cmpunordspd_ymm}               { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordspd_ymm; return SYMBOL; }
{cmpunordsps_xmm}               { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordsps_xmm; return SYMBOL; }
{cmpunordsps_ymm}               { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordsps_ymm; return SYMBOL; }
{cmpunordss}                    { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordss; return SYMBOL; }
{cmpunordssd}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordssd; return SYMBOL; }
{cmpunordsss}                   { HANDLE_COLUMN; yylval->oh.h = helper_cmpunordsss; return SYMBOL; }
{comisd}                        { HANDLE_COLUMN; yylval->oh.h = helper_comisd; return SYMBOL; }
{comiss}                        { HANDLE_COLUMN; yylval->oh.h = helper_comiss; return SYMBOL; }
{cpuid}                         { HANDLE_COLUMN; yylval->oh.h = helper_cpuid; return SYMBOL; }
{cr4_testbit}                   { HANDLE_COLUMN; yylval->oh.h = helper_cr4_testbit; return SYMBOL; }
{crc32}                         { HANDLE_COLUMN; yylval->oh.h = helper_crc32; return SYMBOL; }
{cvtdq2pd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtdq2pd_xmm; return SYMBOL; }
{cvtdq2pd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtdq2pd_ymm; return SYMBOL; }
{cvtdq2ps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtdq2ps_xmm; return SYMBOL; }
{cvtdq2ps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtdq2ps_ymm; return SYMBOL; }
{cvtpd2dq_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtpd2dq_xmm; return SYMBOL; }
{cvtpd2dq_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtpd2dq_ymm; return SYMBOL; }
{cvtpd2pi}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtpd2pi; return SYMBOL; }
{cvtpd2ps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtpd2ps_xmm; return SYMBOL; }
{cvtpd2ps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtpd2ps_ymm; return SYMBOL; }
{cvtph2ps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtph2ps_xmm; return SYMBOL; }
{cvtph2ps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtph2ps_ymm; return SYMBOL; }
{cvtpi2pd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtpi2pd; return SYMBOL; }
{cvtpi2ps}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtpi2ps; return SYMBOL; }
{cvtps2dq_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtps2dq_xmm; return SYMBOL; }
{cvtps2dq_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtps2dq_ymm; return SYMBOL; }
{cvtps2pd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtps2pd_xmm; return SYMBOL; }
{cvtps2pd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtps2pd_ymm; return SYMBOL; }
{cvtps2ph_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtps2ph_xmm; return SYMBOL; }
{cvtps2ph_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_cvtps2ph_ymm; return SYMBOL; }
{cvtps2pi}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtps2pi; return SYMBOL; }
{cvtsd2si}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtsd2si; return SYMBOL; }
{cvtsd2sq}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtsd2sq; return SYMBOL; }
{cvtsd2ss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtsd2ss; return SYMBOL; }
{cvtsi2sd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtsi2sd; return SYMBOL; }
{cvtsi2ss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtsi2ss; return SYMBOL; }
{cvtsq2sd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtsq2sd; return SYMBOL; }
{cvtsq2ss}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtsq2ss; return SYMBOL; }
{cvtss2sd}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtss2sd; return SYMBOL; }
{cvtss2si}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtss2si; return SYMBOL; }
{cvtss2sq}                      { HANDLE_COLUMN; yylval->oh.h = helper_cvtss2sq; return SYMBOL; }
{cvttpd2dq_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cvttpd2dq_xmm; return SYMBOL; }
{cvttpd2dq_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cvttpd2dq_ymm; return SYMBOL; }
{cvttpd2pi}                     { HANDLE_COLUMN; yylval->oh.h = helper_cvttpd2pi; return SYMBOL; }
{cvttps2dq_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cvttps2dq_xmm; return SYMBOL; }
{cvttps2dq_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_cvttps2dq_ymm; return SYMBOL; }
{cvttps2pi}                     { HANDLE_COLUMN; yylval->oh.h = helper_cvttps2pi; return SYMBOL; }
{cvttsd2si}                     { HANDLE_COLUMN; yylval->oh.h = helper_cvttsd2si; return SYMBOL; }
{cvttsd2sq}                     { HANDLE_COLUMN; yylval->oh.h = helper_cvttsd2sq; return SYMBOL; }
{cvttss2si}                     { HANDLE_COLUMN; yylval->oh.h = helper_cvttss2si; return SYMBOL; }
{cvttss2sq}                     { HANDLE_COLUMN; yylval->oh.h = helper_cvttss2sq; return SYMBOL; }
{daa}                           { HANDLE_COLUMN; yylval->oh.h = helper_daa; return SYMBOL; }
{das}                           { HANDLE_COLUMN; yylval->oh.h = helper_das; return SYMBOL; }
{divb_AL}                       { HANDLE_COLUMN; yylval->oh.h = helper_divb_AL; return SYMBOL; }
{div_i32}                       { HANDLE_COLUMN; yylval->oh.h = helper_div_i32; return SYMBOL; }
{div_i64}                       { HANDLE_COLUMN; yylval->oh.h = helper_div_i64; return SYMBOL; }
{divl_EAX}                      { HANDLE_COLUMN; yylval->oh.h = helper_divl_EAX; return SYMBOL; }
{divpd_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_divpd_xmm; return SYMBOL; }
{divpd_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_divpd_ymm; return SYMBOL; }
{divps_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_divps_xmm; return SYMBOL; }
{divps_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_divps_ymm; return SYMBOL; }
{divq_EAX}                      { HANDLE_COLUMN; yylval->oh.h = helper_divq_EAX; return SYMBOL; }
{divsd}                         { HANDLE_COLUMN; yylval->oh.h = helper_divsd; return SYMBOL; }
{divss}                         { HANDLE_COLUMN; yylval->oh.h = helper_divss; return SYMBOL; }
{divw_AX}                       { HANDLE_COLUMN; yylval->oh.h = helper_divw_AX; return SYMBOL; }
{dppd_xmm}                      { HANDLE_COLUMN; yylval->oh.h = helper_dppd_xmm; return SYMBOL; }
{dpps_xmm}                      { HANDLE_COLUMN; yylval->oh.h = helper_dpps_xmm; return SYMBOL; }
{dpps_ymm}                      { HANDLE_COLUMN; yylval->oh.h = helper_dpps_ymm; return SYMBOL; }
{emms}                          { HANDLE_COLUMN; yylval->oh.h = helper_emms; return SYMBOL; }
{enter_mmx}                     { HANDLE_COLUMN; yylval->oh.h = helper_enter_mmx; return SYMBOL; }
{exit_atomic}                   { HANDLE_COLUMN; yylval->oh.h = helper_exit_atomic; return SYMBOL; }
{extrq_i}                       { HANDLE_COLUMN; yylval->oh.h = helper_extrq_i; return SYMBOL; }
{extrq_r}                       { HANDLE_COLUMN; yylval->oh.h = helper_extrq_r; return SYMBOL; }
{f2xm1}                         { HANDLE_COLUMN; yylval->oh.h = helper_f2xm1; return SYMBOL; }
{fabs_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fabs_ST0; return SYMBOL; }
{fadd_ST0_FT0}                  { HANDLE_COLUMN; yylval->oh.h = helper_fadd_ST0_FT0; return SYMBOL; }
{fadd_STN_ST0}                  { HANDLE_COLUMN; yylval->oh.h = helper_fadd_STN_ST0; return SYMBOL; }
{fbld_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fbld_ST0; return SYMBOL; }
{fbst_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fbst_ST0; return SYMBOL; }
{fchs_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fchs_ST0; return SYMBOL; }
{fclex}                         { HANDLE_COLUMN; yylval->oh.h = helper_fclex; return SYMBOL; }
{fcomi_ST0_FT0}                 { HANDLE_COLUMN; yylval->oh.h = helper_fcomi_ST0_FT0; return SYMBOL; }
{fcom_ST0_FT0}                  { HANDLE_COLUMN; yylval->oh.h = helper_fcom_ST0_FT0; return SYMBOL; }
{fcos}                          { HANDLE_COLUMN; yylval->oh.h = helper_fcos; return SYMBOL; }
{fdecstp}                       { HANDLE_COLUMN; yylval->oh.h = helper_fdecstp; return SYMBOL; }
{fdivr_ST0_FT0}                 { HANDLE_COLUMN; yylval->oh.h = helper_fdivr_ST0_FT0; return SYMBOL; }
{fdivr_STN_ST0}                 { HANDLE_COLUMN; yylval->oh.h = helper_fdivr_STN_ST0; return SYMBOL; }
{fdiv_ST0_FT0}                  { HANDLE_COLUMN; yylval->oh.h = helper_fdiv_ST0_FT0; return SYMBOL; }
{fdiv_STN_ST0}                  { HANDLE_COLUMN; yylval->oh.h = helper_fdiv_STN_ST0; return SYMBOL; }
{ffree_STN}                     { HANDLE_COLUMN; yylval->oh.h = helper_ffree_STN; return SYMBOL; }
{fildl_FT0}                     { HANDLE_COLUMN; yylval->oh.h = helper_fildl_FT0; return SYMBOL; }
{fildll_ST0}                    { HANDLE_COLUMN; yylval->oh.h = helper_fildll_ST0; return SYMBOL; }
{fildl_ST0}                     { HANDLE_COLUMN; yylval->oh.h = helper_fildl_ST0; return SYMBOL; }
{fincstp}                       { HANDLE_COLUMN; yylval->oh.h = helper_fincstp; return SYMBOL; }
{fistll_ST0}                    { HANDLE_COLUMN; yylval->oh.h = helper_fistll_ST0; return SYMBOL; }
{fistl_ST0}                     { HANDLE_COLUMN; yylval->oh.h = helper_fistl_ST0; return SYMBOL; }
{fist_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fist_ST0; return SYMBOL; }
{fisttll_ST0}                   { HANDLE_COLUMN; yylval->oh.h = helper_fisttll_ST0; return SYMBOL; }
{fisttl_ST0}                    { HANDLE_COLUMN; yylval->oh.h = helper_fisttl_ST0; return SYMBOL; }
{fistt_ST0}                     { HANDLE_COLUMN; yylval->oh.h = helper_fistt_ST0; return SYMBOL; }
{fld1_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fld1_ST0; return SYMBOL; }
{fldcw}                         { HANDLE_COLUMN; yylval->oh.h = helper_fldcw; return SYMBOL; }
{fldenv}                        { HANDLE_COLUMN; yylval->oh.h = helper_fldenv; return SYMBOL; }
{fldl2e_ST0}                    { HANDLE_COLUMN; yylval->oh.h = helper_fldl2e_ST0; return SYMBOL; }
{fldl2t_ST0}                    { HANDLE_COLUMN; yylval->oh.h = helper_fldl2t_ST0; return SYMBOL; }
{fldl_FT0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fldl_FT0; return SYMBOL; }
{fldlg2_ST0}                    { HANDLE_COLUMN; yylval->oh.h = helper_fldlg2_ST0; return SYMBOL; }
{fldln2_ST0}                    { HANDLE_COLUMN; yylval->oh.h = helper_fldln2_ST0; return SYMBOL; }
{fldl_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fldl_ST0; return SYMBOL; }
{fldpi_ST0}                     { HANDLE_COLUMN; yylval->oh.h = helper_fldpi_ST0; return SYMBOL; }
{flds_FT0}                      { HANDLE_COLUMN; yylval->oh.h = helper_flds_FT0; return SYMBOL; }
{flds_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_flds_ST0; return SYMBOL; }
{fldt_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fldt_ST0; return SYMBOL; }
{fldz_FT0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fldz_FT0; return SYMBOL; }
{fldz_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fldz_ST0; return SYMBOL; }
{fma4pd_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_fma4pd_xmm; return SYMBOL; }
{fma4pd_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_fma4pd_ymm; return SYMBOL; }
{fma4ps_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_fma4ps_xmm; return SYMBOL; }
{fma4ps_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_fma4ps_ymm; return SYMBOL; }
{fma4sd}                        { HANDLE_COLUMN; yylval->oh.h = helper_fma4sd; return SYMBOL; }
{fma4ss}                        { HANDLE_COLUMN; yylval->oh.h = helper_fma4ss; return SYMBOL; }
{fmov_FT0_STN}                  { HANDLE_COLUMN; yylval->oh.h = helper_fmov_FT0_STN; return SYMBOL; }
{fmov_ST0_FT0}                  { HANDLE_COLUMN; yylval->oh.h = helper_fmov_ST0_FT0; return SYMBOL; }
{fmov_ST0_STN}                  { HANDLE_COLUMN; yylval->oh.h = helper_fmov_ST0_STN; return SYMBOL; }
{fmov_STN_ST0}                  { HANDLE_COLUMN; yylval->oh.h = helper_fmov_STN_ST0; return SYMBOL; }
{fmul_ST0_FT0}                  { HANDLE_COLUMN; yylval->oh.h = helper_fmul_ST0_FT0; return SYMBOL; }
{fmul_STN_ST0}                  { HANDLE_COLUMN; yylval->oh.h = helper_fmul_STN_ST0; return SYMBOL; }
{fninit}                        { HANDLE_COLUMN; yylval->oh.h = helper_fninit; return SYMBOL; }
{fnstcw}                        { HANDLE_COLUMN; yylval->oh.h = helper_fnstcw; return SYMBOL; }
{fnstsw}                        { HANDLE_COLUMN; yylval->oh.h = helper_fnstsw; return SYMBOL; }
{fpatan}                        { HANDLE_COLUMN; yylval->oh.h = helper_fpatan; return SYMBOL; }
{fpop}                          { HANDLE_COLUMN; yylval->oh.h = helper_fpop; return SYMBOL; }
{fprem}                         { HANDLE_COLUMN; yylval->oh.h = helper_fprem; return SYMBOL; }
{fprem1}                        { HANDLE_COLUMN; yylval->oh.h = helper_fprem1; return SYMBOL; }
{fptan}                         { HANDLE_COLUMN; yylval->oh.h = helper_fptan; return SYMBOL; }
{fpush}                         { HANDLE_COLUMN; yylval->oh.h = helper_fpush; return SYMBOL; }
{frndint}                       { HANDLE_COLUMN; yylval->oh.h = helper_frndint; return SYMBOL; }
{frstor}                        { HANDLE_COLUMN; yylval->oh.h = helper_frstor; return SYMBOL; }
{fsave}                         { HANDLE_COLUMN; yylval->oh.h = helper_fsave; return SYMBOL; }
{fscale}                        { HANDLE_COLUMN; yylval->oh.h = helper_fscale; return SYMBOL; }
{fsin}                          { HANDLE_COLUMN; yylval->oh.h = helper_fsin; return SYMBOL; }
{fsincos}                       { HANDLE_COLUMN; yylval->oh.h = helper_fsincos; return SYMBOL; }
{fsqrt}                         { HANDLE_COLUMN; yylval->oh.h = helper_fsqrt; return SYMBOL; }
{fstenv}                        { HANDLE_COLUMN; yylval->oh.h = helper_fstenv; return SYMBOL; }
{fstl_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fstl_ST0; return SYMBOL; }
{fsts_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fsts_ST0; return SYMBOL; }
{fstt_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fstt_ST0; return SYMBOL; }
{fsubr_ST0_FT0}                 { HANDLE_COLUMN; yylval->oh.h = helper_fsubr_ST0_FT0; return SYMBOL; }
{fsubr_STN_ST0}                 { HANDLE_COLUMN; yylval->oh.h = helper_fsubr_STN_ST0; return SYMBOL; }
{fsub_ST0_FT0}                  { HANDLE_COLUMN; yylval->oh.h = helper_fsub_ST0_FT0; return SYMBOL; }
{fsub_STN_ST0}                  { HANDLE_COLUMN; yylval->oh.h = helper_fsub_STN_ST0; return SYMBOL; }
{fucomi_ST0_FT0}                { HANDLE_COLUMN; yylval->oh.h = helper_fucomi_ST0_FT0; return SYMBOL; }
{fucom_ST0_FT0}                 { HANDLE_COLUMN; yylval->oh.h = helper_fucom_ST0_FT0; return SYMBOL; }
{fwait}                         { HANDLE_COLUMN; yylval->oh.h = helper_fwait; return SYMBOL; }
{fxam_ST0}                      { HANDLE_COLUMN; yylval->oh.h = helper_fxam_ST0; return SYMBOL; }
{fxchg_ST0_STN}                 { HANDLE_COLUMN; yylval->oh.h = helper_fxchg_ST0_STN; return SYMBOL; }
{fxrstor}                       { HANDLE_COLUMN; yylval->oh.h = helper_fxrstor; return SYMBOL; }
{fxsave}                        { HANDLE_COLUMN; yylval->oh.h = helper_fxsave; return SYMBOL; }
{fxtract}                       { HANDLE_COLUMN; yylval->oh.h = helper_fxtract; return SYMBOL; }
{fyl2x}                         { HANDLE_COLUMN; yylval->oh.h = helper_fyl2x; return SYMBOL; }
{fyl2xp1}                       { HANDLE_COLUMN; yylval->oh.h = helper_fyl2xp1; return SYMBOL; }
{gvec_abs16}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_abs16; return SYMBOL; }
{gvec_abs32}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_abs32; return SYMBOL; }
{gvec_abs64}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_abs64; return SYMBOL; }
{gvec_abs8}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_abs8; return SYMBOL; }
{gvec_add16}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_add16; return SYMBOL; }
{gvec_add32}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_add32; return SYMBOL; }
{gvec_add64}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_add64; return SYMBOL; }
{gvec_add8}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_add8; return SYMBOL; }
{gvec_adds16}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_adds16; return SYMBOL; }
{gvec_adds32}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_adds32; return SYMBOL; }
{gvec_adds64}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_adds64; return SYMBOL; }
{gvec_adds8}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_adds8; return SYMBOL; }
{gvec_and}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_and; return SYMBOL; }
{gvec_andc}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_andc; return SYMBOL; }
{gvec_andcs}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_andcs; return SYMBOL; }
{gvec_ands}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ands; return SYMBOL; }
{gvec_bitsel}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_bitsel; return SYMBOL; }
{gvec_dup16}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_dup16; return SYMBOL; }
{gvec_dup32}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_dup32; return SYMBOL; }
{gvec_dup64}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_dup64; return SYMBOL; }
{gvec_dup8}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_dup8; return SYMBOL; }
{gvec_eq16}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_eq16; return SYMBOL; }
{gvec_eq32}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_eq32; return SYMBOL; }
{gvec_eq64}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_eq64; return SYMBOL; }
{gvec_eq8}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_eq8; return SYMBOL; }
{gvec_eqs16}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_eqs16; return SYMBOL; }
{gvec_eqs32}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_eqs32; return SYMBOL; }
{gvec_eqs64}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_eqs64; return SYMBOL; }
{gvec_eqs8}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_eqs8; return SYMBOL; }
{gvec_eqv}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_eqv; return SYMBOL; }
{gvec_le16}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_le16; return SYMBOL; }
{gvec_le32}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_le32; return SYMBOL; }
{gvec_le64}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_le64; return SYMBOL; }
{gvec_le8}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_le8; return SYMBOL; }
{gvec_les16}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_les16; return SYMBOL; }
{gvec_les32}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_les32; return SYMBOL; }
{gvec_les64}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_les64; return SYMBOL; }
{gvec_les8}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_les8; return SYMBOL; }
{gvec_leu16}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_leu16; return SYMBOL; }
{gvec_leu32}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_leu32; return SYMBOL; }
{gvec_leu64}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_leu64; return SYMBOL; }
{gvec_leu8}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_leu8; return SYMBOL; }
{gvec_leus16}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_leus16; return SYMBOL; }
{gvec_leus32}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_leus32; return SYMBOL; }
{gvec_leus64}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_leus64; return SYMBOL; }
{gvec_leus8}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_leus8; return SYMBOL; }
{gvec_lt16}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_lt16; return SYMBOL; }
{gvec_lt32}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_lt32; return SYMBOL; }
{gvec_lt64}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_lt64; return SYMBOL; }
{gvec_lt8}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_lt8; return SYMBOL; }
{gvec_lts16}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_lts16; return SYMBOL; }
{gvec_lts32}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_lts32; return SYMBOL; }
{gvec_lts64}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_lts64; return SYMBOL; }
{gvec_lts8}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_lts8; return SYMBOL; }
{gvec_ltu16}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ltu16; return SYMBOL; }
{gvec_ltu32}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ltu32; return SYMBOL; }
{gvec_ltu64}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ltu64; return SYMBOL; }
{gvec_ltu8}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ltu8; return SYMBOL; }
{gvec_ltus16}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ltus16; return SYMBOL; }
{gvec_ltus32}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ltus32; return SYMBOL; }
{gvec_ltus64}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ltus64; return SYMBOL; }
{gvec_ltus8}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ltus8; return SYMBOL; }
{gvec_mov}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_mov; return SYMBOL; }
{gvec_mul16}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_mul16; return SYMBOL; }
{gvec_mul32}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_mul32; return SYMBOL; }
{gvec_mul64}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_mul64; return SYMBOL; }
{gvec_mul8}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_mul8; return SYMBOL; }
{gvec_muls16}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_muls16; return SYMBOL; }
{gvec_muls32}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_muls32; return SYMBOL; }
{gvec_muls64}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_muls64; return SYMBOL; }
{gvec_muls8}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_muls8; return SYMBOL; }
{gvec_nand}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_nand; return SYMBOL; }
{gvec_ne16}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ne16; return SYMBOL; }
{gvec_ne32}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ne32; return SYMBOL; }
{gvec_ne64}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ne64; return SYMBOL; }
{gvec_ne8}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ne8; return SYMBOL; }
{gvec_neg16}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_neg16; return SYMBOL; }
{gvec_neg32}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_neg32; return SYMBOL; }
{gvec_neg64}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_neg64; return SYMBOL; }
{gvec_neg8}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_neg8; return SYMBOL; }
{gvec_nor}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_nor; return SYMBOL; }
{gvec_not}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_not; return SYMBOL; }
{gvec_or}                       { HANDLE_COLUMN; yylval->oh.h = helper_gvec_or; return SYMBOL; }
{gvec_orc}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_orc; return SYMBOL; }
{gvec_ors}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ors; return SYMBOL; }
{gvec_rotl16i}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotl16i; return SYMBOL; }
{gvec_rotl16v}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotl16v; return SYMBOL; }
{gvec_rotl32i}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotl32i; return SYMBOL; }
{gvec_rotl32v}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotl32v; return SYMBOL; }
{gvec_rotl64i}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotl64i; return SYMBOL; }
{gvec_rotl64v}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotl64v; return SYMBOL; }
{gvec_rotl8i}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotl8i; return SYMBOL; }
{gvec_rotl8v}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotl8v; return SYMBOL; }
{gvec_rotr16v}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotr16v; return SYMBOL; }
{gvec_rotr32v}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotr32v; return SYMBOL; }
{gvec_rotr64v}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotr64v; return SYMBOL; }
{gvec_rotr8v}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_rotr8v; return SYMBOL; }
{gvec_sar16i}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sar16i; return SYMBOL; }
{gvec_sar16v}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sar16v; return SYMBOL; }
{gvec_sar32i}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sar32i; return SYMBOL; }
{gvec_sar32v}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sar32v; return SYMBOL; }
{gvec_sar64i}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sar64i; return SYMBOL; }
{gvec_sar64v}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sar64v; return SYMBOL; }
{gvec_sar8i}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sar8i; return SYMBOL; }
{gvec_sar8v}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sar8v; return SYMBOL; }
{gvec_shl16i}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shl16i; return SYMBOL; }
{gvec_shl16v}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shl16v; return SYMBOL; }
{gvec_shl32i}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shl32i; return SYMBOL; }
{gvec_shl32v}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shl32v; return SYMBOL; }
{gvec_shl64i}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shl64i; return SYMBOL; }
{gvec_shl64v}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shl64v; return SYMBOL; }
{gvec_shl8i}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shl8i; return SYMBOL; }
{gvec_shl8v}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shl8v; return SYMBOL; }
{gvec_shr16i}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shr16i; return SYMBOL; }
{gvec_shr16v}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shr16v; return SYMBOL; }
{gvec_shr32i}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shr32i; return SYMBOL; }
{gvec_shr32v}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shr32v; return SYMBOL; }
{gvec_shr64i}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shr64i; return SYMBOL; }
{gvec_shr64v}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shr64v; return SYMBOL; }
{gvec_shr8i}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shr8i; return SYMBOL; }
{gvec_shr8v}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_shr8v; return SYMBOL; }
{gvec_smax16}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_smax16; return SYMBOL; }
{gvec_smax32}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_smax32; return SYMBOL; }
{gvec_smax64}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_smax64; return SYMBOL; }
{gvec_smax8}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_smax8; return SYMBOL; }
{gvec_smin16}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_smin16; return SYMBOL; }
{gvec_smin32}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_smin32; return SYMBOL; }
{gvec_smin64}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_smin64; return SYMBOL; }
{gvec_smin8}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_smin8; return SYMBOL; }
{gvec_ssadd16}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ssadd16; return SYMBOL; }
{gvec_ssadd32}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ssadd32; return SYMBOL; }
{gvec_ssadd64}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ssadd64; return SYMBOL; }
{gvec_ssadd8}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ssadd8; return SYMBOL; }
{gvec_sssub16}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sssub16; return SYMBOL; }
{gvec_sssub32}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sssub32; return SYMBOL; }
{gvec_sssub64}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sssub64; return SYMBOL; }
{gvec_sssub8}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sssub8; return SYMBOL; }
{gvec_sub16}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sub16; return SYMBOL; }
{gvec_sub32}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sub32; return SYMBOL; }
{gvec_sub64}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sub64; return SYMBOL; }
{gvec_sub8}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_sub8; return SYMBOL; }
{gvec_subs16}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_subs16; return SYMBOL; }
{gvec_subs32}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_subs32; return SYMBOL; }
{gvec_subs64}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_subs64; return SYMBOL; }
{gvec_subs8}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_subs8; return SYMBOL; }
{gvec_umax16}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_umax16; return SYMBOL; }
{gvec_umax32}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_umax32; return SYMBOL; }
{gvec_umax64}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_umax64; return SYMBOL; }
{gvec_umax8}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_umax8; return SYMBOL; }
{gvec_umin16}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_umin16; return SYMBOL; }
{gvec_umin32}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_umin32; return SYMBOL; }
{gvec_umin64}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_umin64; return SYMBOL; }
{gvec_umin8}                    { HANDLE_COLUMN; yylval->oh.h = helper_gvec_umin8; return SYMBOL; }
{gvec_usadd16}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_usadd16; return SYMBOL; }
{gvec_usadd32}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_usadd32; return SYMBOL; }
{gvec_usadd64}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_usadd64; return SYMBOL; }
{gvec_usadd8}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_usadd8; return SYMBOL; }
{gvec_ussub16}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ussub16; return SYMBOL; }
{gvec_ussub32}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ussub32; return SYMBOL; }
{gvec_ussub64}                  { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ussub64; return SYMBOL; }
{gvec_ussub8}                   { HANDLE_COLUMN; yylval->oh.h = helper_gvec_ussub8; return SYMBOL; }
{gvec_xor}                      { HANDLE_COLUMN; yylval->oh.h = helper_gvec_xor; return SYMBOL; }
{gvec_xors}                     { HANDLE_COLUMN; yylval->oh.h = helper_gvec_xors; return SYMBOL; }
{haddpd_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_haddpd_xmm; return SYMBOL; }
{haddpd_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_haddpd_ymm; return SYMBOL; }
{haddps_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_haddps_xmm; return SYMBOL; }
{haddps_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_haddps_ymm; return SYMBOL; }
{hsubpd_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_hsubpd_xmm; return SYMBOL; }
{hsubpd_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_hsubpd_ymm; return SYMBOL; }
{hsubps_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_hsubps_xmm; return SYMBOL; }
{hsubps_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_hsubps_ymm; return SYMBOL; }
{icebp}                         { HANDLE_COLUMN; yylval->oh.h = helper_icebp; return SYMBOL; }
{idivb_AL}                      { HANDLE_COLUMN; yylval->oh.h = helper_idivb_AL; return SYMBOL; }
{idivl_EAX}                     { HANDLE_COLUMN; yylval->oh.h = helper_idivl_EAX; return SYMBOL; }
{idivq_EAX}                     { HANDLE_COLUMN; yylval->oh.h = helper_idivq_EAX; return SYMBOL; }
{idivw_AX}                      { HANDLE_COLUMN; yylval->oh.h = helper_idivw_AX; return SYMBOL; }
{insertq_i}                     { HANDLE_COLUMN; yylval->oh.h = helper_insertq_i; return SYMBOL; }
{insertq_r}                     { HANDLE_COLUMN; yylval->oh.h = helper_insertq_r; return SYMBOL; }
{into}                          { HANDLE_COLUMN; yylval->oh.h = helper_into; return SYMBOL; }
{iret_protected}                { HANDLE_COLUMN; yylval->oh.h = helper_iret_protected; return SYMBOL; }
{iret_real}                     { HANDLE_COLUMN; yylval->oh.h = helper_iret_real; return SYMBOL; }
{lar}                           { HANDLE_COLUMN; yylval->oh.h = helper_lar; return SYMBOL; }
{lcall_protected}               { HANDLE_COLUMN; yylval->oh.h = helper_lcall_protected; return SYMBOL; }
{lcall_real}                    { HANDLE_COLUMN; yylval->oh.h = helper_lcall_real; return SYMBOL; }
{ld_i128}                       { HANDLE_COLUMN; yylval->oh.h = helper_ld_i128; return SYMBOL; }
{ldmxcsr}                       { HANDLE_COLUMN; yylval->oh.h = helper_ldmxcsr; return SYMBOL; }
{ljmp_protected}                { HANDLE_COLUMN; yylval->oh.h = helper_ljmp_protected; return SYMBOL; }
{lldt}                          { HANDLE_COLUMN; yylval->oh.h = helper_lldt; return SYMBOL; }
{load_seg}                      { HANDLE_COLUMN; yylval->oh.h = helper_load_seg; return SYMBOL; }
{lookup_tb_ptr}                 { HANDLE_COLUMN; yylval->oh.h = helper_lookup_tb_ptr; return SYMBOL; }
{lret_protected}                { HANDLE_COLUMN; yylval->oh.h = helper_lret_protected; return SYMBOL; }
{lsl}                           { HANDLE_COLUMN; yylval->oh.h = helper_lsl; return SYMBOL; }
{ltr}                           { HANDLE_COLUMN; yylval->oh.h = helper_ltr; return SYMBOL; }
{maskmov_mmx}                   { HANDLE_COLUMN; yylval->oh.h = helper_maskmov_mmx; return SYMBOL; }
{maskmov_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_maskmov_xmm; return SYMBOL; }
{maxpd_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_maxpd_xmm; return SYMBOL; }
{maxpd_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_maxpd_ymm; return SYMBOL; }
{maxps_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_maxps_xmm; return SYMBOL; }
{maxps_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_maxps_ymm; return SYMBOL; }
{maxsd}                         { HANDLE_COLUMN; yylval->oh.h = helper_maxsd; return SYMBOL; }
{maxss}                         { HANDLE_COLUMN; yylval->oh.h = helper_maxss; return SYMBOL; }
{memset}                        { HANDLE_COLUMN; yylval->oh.h = helper_memset; return SYMBOL; }
{minpd_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_minpd_xmm; return SYMBOL; }
{minpd_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_minpd_ymm; return SYMBOL; }
{minps_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_minps_xmm; return SYMBOL; }
{minps_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_minps_ymm; return SYMBOL; }
{minsd}                         { HANDLE_COLUMN; yylval->oh.h = helper_minsd; return SYMBOL; }
{minss}                         { HANDLE_COLUMN; yylval->oh.h = helper_minss; return SYMBOL; }
{movmskpd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_movmskpd_xmm; return SYMBOL; }
{movmskpd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_movmskpd_ymm; return SYMBOL; }
{movmskps_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_movmskps_xmm; return SYMBOL; }
{movmskps_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_movmskps_ymm; return SYMBOL; }
{mpsadbw_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_mpsadbw_xmm; return SYMBOL; }
{mpsadbw_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_mpsadbw_ymm; return SYMBOL; }
{mulpd_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_mulpd_xmm; return SYMBOL; }
{mulpd_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_mulpd_ymm; return SYMBOL; }
{mulps_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_mulps_xmm; return SYMBOL; }
{mulps_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_mulps_ymm; return SYMBOL; }
{mulsd}                         { HANDLE_COLUMN; yylval->oh.h = helper_mulsd; return SYMBOL; }
{mulss}                         { HANDLE_COLUMN; yylval->oh.h = helper_mulss; return SYMBOL; }
{nonatomic_cmpxchgo}            { HANDLE_COLUMN; yylval->oh.h = helper_nonatomic_cmpxchgo; return SYMBOL; }
{packssdw_mmx}                  { HANDLE_COLUMN; yylval->oh.h = helper_packssdw_mmx; return SYMBOL; }
{packssdw_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_packssdw_xmm; return SYMBOL; }
{packssdw_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_packssdw_ymm; return SYMBOL; }
{packsswb_mmx}                  { HANDLE_COLUMN; yylval->oh.h = helper_packsswb_mmx; return SYMBOL; }
{packsswb_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_packsswb_xmm; return SYMBOL; }
{packsswb_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_packsswb_ymm; return SYMBOL; }
{packusdw_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_packusdw_xmm; return SYMBOL; }
{packusdw_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_packusdw_ymm; return SYMBOL; }
{packuswb_mmx}                  { HANDLE_COLUMN; yylval->oh.h = helper_packuswb_mmx; return SYMBOL; }
{packuswb_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_packuswb_xmm; return SYMBOL; }
{packuswb_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_packuswb_ymm; return SYMBOL; }
{palignr_mmx}                   { HANDLE_COLUMN; yylval->oh.h = helper_palignr_mmx; return SYMBOL; }
{palignr_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_palignr_xmm; return SYMBOL; }
{palignr_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_palignr_ymm; return SYMBOL; }
{pause}                         { HANDLE_COLUMN; yylval->oh.h = helper_pause; return SYMBOL; }
{pavgb_mmx}                     { HANDLE_COLUMN; yylval->oh.h = helper_pavgb_mmx; return SYMBOL; }
{pavgb_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_pavgb_xmm; return SYMBOL; }
{pavgb_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_pavgb_ymm; return SYMBOL; }
{pavgw_mmx}                     { HANDLE_COLUMN; yylval->oh.h = helper_pavgw_mmx; return SYMBOL; }
{pavgw_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_pavgw_xmm; return SYMBOL; }
{pavgw_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_pavgw_ymm; return SYMBOL; }
{pblendvb_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pblendvb_xmm; return SYMBOL; }
{pblendvb_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pblendvb_ymm; return SYMBOL; }
{pblendw_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pblendw_xmm; return SYMBOL; }
{pblendw_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pblendw_ymm; return SYMBOL; }
{pclmulqdq_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pclmulqdq_xmm; return SYMBOL; }
{pclmulqdq_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pclmulqdq_ymm; return SYMBOL; }
{pcmpestri_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pcmpestri_xmm; return SYMBOL; }
{pcmpestrm_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pcmpestrm_xmm; return SYMBOL; }
{pcmpistri_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pcmpistri_xmm; return SYMBOL; }
{pcmpistrm_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pcmpistrm_xmm; return SYMBOL; }
{pdep}                          { HANDLE_COLUMN; yylval->oh.h = helper_pdep; return SYMBOL; }
{pext}                          { HANDLE_COLUMN; yylval->oh.h = helper_pext; return SYMBOL; }
{pf2id}                         { HANDLE_COLUMN; yylval->oh.h = helper_pf2id; return SYMBOL; }
{pf2iw}                         { HANDLE_COLUMN; yylval->oh.h = helper_pf2iw; return SYMBOL; }
{pfacc}                         { HANDLE_COLUMN; yylval->oh.h = helper_pfacc; return SYMBOL; }
{pfadd}                         { HANDLE_COLUMN; yylval->oh.h = helper_pfadd; return SYMBOL; }
{pfcmpeq}                       { HANDLE_COLUMN; yylval->oh.h = helper_pfcmpeq; return SYMBOL; }
{pfcmpge}                       { HANDLE_COLUMN; yylval->oh.h = helper_pfcmpge; return SYMBOL; }
{pfcmpgt}                       { HANDLE_COLUMN; yylval->oh.h = helper_pfcmpgt; return SYMBOL; }
{pfmax}                         { HANDLE_COLUMN; yylval->oh.h = helper_pfmax; return SYMBOL; }
{pfmin}                         { HANDLE_COLUMN; yylval->oh.h = helper_pfmin; return SYMBOL; }
{pfmul}                         { HANDLE_COLUMN; yylval->oh.h = helper_pfmul; return SYMBOL; }
{pfnacc}                        { HANDLE_COLUMN; yylval->oh.h = helper_pfnacc; return SYMBOL; }
{pfpnacc}                       { HANDLE_COLUMN; yylval->oh.h = helper_pfpnacc; return SYMBOL; }
{pfrcp}                         { HANDLE_COLUMN; yylval->oh.h = helper_pfrcp; return SYMBOL; }
{pfrsqrt}                       { HANDLE_COLUMN; yylval->oh.h = helper_pfrsqrt; return SYMBOL; }
{pfsub}                         { HANDLE_COLUMN; yylval->oh.h = helper_pfsub; return SYMBOL; }
{pfsubr}                        { HANDLE_COLUMN; yylval->oh.h = helper_pfsubr; return SYMBOL; }
{phaddd_mmx}                    { HANDLE_COLUMN; yylval->oh.h = helper_phaddd_mmx; return SYMBOL; }
{phaddd_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_phaddd_xmm; return SYMBOL; }
{phaddd_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_phaddd_ymm; return SYMBOL; }
{phaddsw_mmx}                   { HANDLE_COLUMN; yylval->oh.h = helper_phaddsw_mmx; return SYMBOL; }
{phaddsw_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_phaddsw_xmm; return SYMBOL; }
{phaddsw_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_phaddsw_ymm; return SYMBOL; }
{phaddw_mmx}                    { HANDLE_COLUMN; yylval->oh.h = helper_phaddw_mmx; return SYMBOL; }
{phaddw_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_phaddw_xmm; return SYMBOL; }
{phaddw_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_phaddw_ymm; return SYMBOL; }
{phminposuw_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_phminposuw_xmm; return SYMBOL; }
{phsubd_mmx}                    { HANDLE_COLUMN; yylval->oh.h = helper_phsubd_mmx; return SYMBOL; }
{phsubd_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_phsubd_xmm; return SYMBOL; }
{phsubd_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_phsubd_ymm; return SYMBOL; }
{phsubsw_mmx}                   { HANDLE_COLUMN; yylval->oh.h = helper_phsubsw_mmx; return SYMBOL; }
{phsubsw_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_phsubsw_xmm; return SYMBOL; }
{phsubsw_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_phsubsw_ymm; return SYMBOL; }
{phsubw_mmx}                    { HANDLE_COLUMN; yylval->oh.h = helper_phsubw_mmx; return SYMBOL; }
{phsubw_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_phsubw_xmm; return SYMBOL; }
{phsubw_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_phsubw_ymm; return SYMBOL; }
{pi2fd}                         { HANDLE_COLUMN; yylval->oh.h = helper_pi2fd; return SYMBOL; }
{pi2fw}                         { HANDLE_COLUMN; yylval->oh.h = helper_pi2fw; return SYMBOL; }
{pmaddubsw_mmx}                 { HANDLE_COLUMN; yylval->oh.h = helper_pmaddubsw_mmx; return SYMBOL; }
{pmaddubsw_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pmaddubsw_xmm; return SYMBOL; }
{pmaddubsw_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pmaddubsw_ymm; return SYMBOL; }
{pmaddwd_mmx}                   { HANDLE_COLUMN; yylval->oh.h = helper_pmaddwd_mmx; return SYMBOL; }
{pmaddwd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pmaddwd_xmm; return SYMBOL; }
{pmaddwd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pmaddwd_ymm; return SYMBOL; }
{pmovdldup_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pmovdldup_xmm; return SYMBOL; }
{pmovdldup_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pmovdldup_ymm; return SYMBOL; }
{pmovshdup_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pmovshdup_xmm; return SYMBOL; }
{pmovshdup_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pmovshdup_ymm; return SYMBOL; }
{pmovsldup_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pmovsldup_xmm; return SYMBOL; }
{pmovsldup_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_pmovsldup_ymm; return SYMBOL; }
{pmovsxbd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxbd_xmm; return SYMBOL; }
{pmovsxbd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxbd_ymm; return SYMBOL; }
{pmovsxbq_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxbq_xmm; return SYMBOL; }
{pmovsxbq_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxbq_ymm; return SYMBOL; }
{pmovsxbw_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxbw_xmm; return SYMBOL; }
{pmovsxbw_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxbw_ymm; return SYMBOL; }
{pmovsxdq_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxdq_xmm; return SYMBOL; }
{pmovsxdq_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxdq_ymm; return SYMBOL; }
{pmovsxwd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxwd_xmm; return SYMBOL; }
{pmovsxwd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxwd_ymm; return SYMBOL; }
{pmovsxwq_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxwq_xmm; return SYMBOL; }
{pmovsxwq_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovsxwq_ymm; return SYMBOL; }
{pmovzxbd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxbd_xmm; return SYMBOL; }
{pmovzxbd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxbd_ymm; return SYMBOL; }
{pmovzxbq_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxbq_xmm; return SYMBOL; }
{pmovzxbq_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxbq_ymm; return SYMBOL; }
{pmovzxbw_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxbw_xmm; return SYMBOL; }
{pmovzxbw_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxbw_ymm; return SYMBOL; }
{pmovzxdq_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxdq_xmm; return SYMBOL; }
{pmovzxdq_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxdq_ymm; return SYMBOL; }
{pmovzxwd_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxwd_xmm; return SYMBOL; }
{pmovzxwd_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxwd_ymm; return SYMBOL; }
{pmovzxwq_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxwq_xmm; return SYMBOL; }
{pmovzxwq_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmovzxwq_ymm; return SYMBOL; }
{pmuldq_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_pmuldq_xmm; return SYMBOL; }
{pmuldq_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_pmuldq_ymm; return SYMBOL; }
{pmulhrsw_mmx}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmulhrsw_mmx; return SYMBOL; }
{pmulhrsw_xmm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmulhrsw_xmm; return SYMBOL; }
{pmulhrsw_ymm}                  { HANDLE_COLUMN; yylval->oh.h = helper_pmulhrsw_ymm; return SYMBOL; }
{pmulhrw_mmx}                   { HANDLE_COLUMN; yylval->oh.h = helper_pmulhrw_mmx; return SYMBOL; }
{pmulhuw_mmx}                   { HANDLE_COLUMN; yylval->oh.h = helper_pmulhuw_mmx; return SYMBOL; }
{pmulhuw_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pmulhuw_xmm; return SYMBOL; }
{pmulhuw_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pmulhuw_ymm; return SYMBOL; }
{pmulhw_mmx}                    { HANDLE_COLUMN; yylval->oh.h = helper_pmulhw_mmx; return SYMBOL; }
{pmulhw_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_pmulhw_xmm; return SYMBOL; }
{pmulhw_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_pmulhw_ymm; return SYMBOL; }
{pmuludq_mmx}                   { HANDLE_COLUMN; yylval->oh.h = helper_pmuludq_mmx; return SYMBOL; }
{pmuludq_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pmuludq_xmm; return SYMBOL; }
{pmuludq_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pmuludq_ymm; return SYMBOL; }
{psadbw_mmx}                    { HANDLE_COLUMN; yylval->oh.h = helper_psadbw_mmx; return SYMBOL; }
{psadbw_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_psadbw_xmm; return SYMBOL; }
{psadbw_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_psadbw_ymm; return SYMBOL; }
{pshufb_mmx}                    { HANDLE_COLUMN; yylval->oh.h = helper_pshufb_mmx; return SYMBOL; }
{pshufb_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_pshufb_xmm; return SYMBOL; }
{pshufb_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_pshufb_ymm; return SYMBOL; }
{pshufd_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_pshufd_xmm; return SYMBOL; }
{pshufd_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_pshufd_ymm; return SYMBOL; }
{pshufhw_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pshufhw_xmm; return SYMBOL; }
{pshufhw_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pshufhw_ymm; return SYMBOL; }
{pshuflw_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pshuflw_xmm; return SYMBOL; }
{pshuflw_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_pshuflw_ymm; return SYMBOL; }
{pshufw_mmx}                    { HANDLE_COLUMN; yylval->oh.h = helper_pshufw_mmx; return SYMBOL; }
{psignb_mmx}                    { HANDLE_COLUMN; yylval->oh.h = helper_psignb_mmx; return SYMBOL; }
{psignb_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_psignb_xmm; return SYMBOL; }
{psignb_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_psignb_ymm; return SYMBOL; }
{psignd_mmx}                    { HANDLE_COLUMN; yylval->oh.h = helper_psignd_mmx; return SYMBOL; }
{psignd_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_psignd_xmm; return SYMBOL; }
{psignd_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_psignd_ymm; return SYMBOL; }
{psignw_mmx}                    { HANDLE_COLUMN; yylval->oh.h = helper_psignw_mmx; return SYMBOL; }
{psignw_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_psignw_xmm; return SYMBOL; }
{psignw_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_psignw_ymm; return SYMBOL; }
{pslld_mmx}                     { HANDLE_COLUMN; yylval->oh.h = helper_pslld_mmx; return SYMBOL; }
{pslldq_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_pslldq_xmm; return SYMBOL; }
{pslldq_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_pslldq_ymm; return SYMBOL; }
{pslld_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_pslld_xmm; return SYMBOL; }
{pslld_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_pslld_ymm; return SYMBOL; }
{psllq_mmx}                     { HANDLE_COLUMN; yylval->oh.h = helper_psllq_mmx; return SYMBOL; }
{psllq_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psllq_xmm; return SYMBOL; }
{psllq_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psllq_ymm; return SYMBOL; }
{psllw_mmx}                     { HANDLE_COLUMN; yylval->oh.h = helper_psllw_mmx; return SYMBOL; }
{psllw_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psllw_xmm; return SYMBOL; }
{psllw_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psllw_ymm; return SYMBOL; }
{psrad_mmx}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrad_mmx; return SYMBOL; }
{psrad_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrad_xmm; return SYMBOL; }
{psrad_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrad_ymm; return SYMBOL; }
{psraw_mmx}                     { HANDLE_COLUMN; yylval->oh.h = helper_psraw_mmx; return SYMBOL; }
{psraw_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psraw_xmm; return SYMBOL; }
{psraw_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psraw_ymm; return SYMBOL; }
{psrld_mmx}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrld_mmx; return SYMBOL; }
{psrldq_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_psrldq_xmm; return SYMBOL; }
{psrldq_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_psrldq_ymm; return SYMBOL; }
{psrld_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrld_xmm; return SYMBOL; }
{psrld_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrld_ymm; return SYMBOL; }
{psrlq_mmx}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrlq_mmx; return SYMBOL; }
{psrlq_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrlq_xmm; return SYMBOL; }
{psrlq_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrlq_ymm; return SYMBOL; }
{psrlw_mmx}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrlw_mmx; return SYMBOL; }
{psrlw_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrlw_xmm; return SYMBOL; }
{psrlw_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_psrlw_ymm; return SYMBOL; }
{pswapd}                        { HANDLE_COLUMN; yylval->oh.h = helper_pswapd; return SYMBOL; }
{ptest_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_ptest_xmm; return SYMBOL; }
{ptest_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_ptest_ymm; return SYMBOL; }
{punpckhbw_mmx}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckhbw_mmx; return SYMBOL; }
{punpckhbw_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckhbw_xmm; return SYMBOL; }
{punpckhbw_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckhbw_ymm; return SYMBOL; }
{punpckhdq_mmx}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckhdq_mmx; return SYMBOL; }
{punpckhdq_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckhdq_xmm; return SYMBOL; }
{punpckhdq_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckhdq_ymm; return SYMBOL; }
{punpckhqdq_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_punpckhqdq_xmm; return SYMBOL; }
{punpckhqdq_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_punpckhqdq_ymm; return SYMBOL; }
{punpckhwd_mmx}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckhwd_mmx; return SYMBOL; }
{punpckhwd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckhwd_xmm; return SYMBOL; }
{punpckhwd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckhwd_ymm; return SYMBOL; }
{punpcklbw_mmx}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpcklbw_mmx; return SYMBOL; }
{punpcklbw_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpcklbw_xmm; return SYMBOL; }
{punpcklbw_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpcklbw_ymm; return SYMBOL; }
{punpckldq_mmx}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckldq_mmx; return SYMBOL; }
{punpckldq_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckldq_xmm; return SYMBOL; }
{punpckldq_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpckldq_ymm; return SYMBOL; }
{punpcklqdq_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_punpcklqdq_xmm; return SYMBOL; }
{punpcklqdq_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_punpcklqdq_ymm; return SYMBOL; }
{punpcklwd_mmx}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpcklwd_mmx; return SYMBOL; }
{punpcklwd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpcklwd_xmm; return SYMBOL; }
{punpcklwd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_punpcklwd_ymm; return SYMBOL; }
{raise_exception}               { HANDLE_COLUMN; yylval->oh.h = helper_raise_exception; return SYMBOL; }
{raise_interrupt}               { HANDLE_COLUMN; yylval->oh.h = helper_raise_interrupt; return SYMBOL; }
{rcpps_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_rcpps_xmm; return SYMBOL; }
{rcpps_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_rcpps_ymm; return SYMBOL; }
{rcpss}                         { HANDLE_COLUMN; yylval->oh.h = helper_rcpss; return SYMBOL; }
{rdpid}                         { HANDLE_COLUMN; yylval->oh.h = helper_rdpid; return SYMBOL; }
{rdpkru}                        { HANDLE_COLUMN; yylval->oh.h = helper_rdpkru; return SYMBOL; }
{rdpmc}                         { HANDLE_COLUMN; yylval->oh.h = helper_rdpmc; return SYMBOL; }
{rdrand}                        { HANDLE_COLUMN; yylval->oh.h = helper_rdrand; return SYMBOL; }
{rdtsc}                         { HANDLE_COLUMN; yylval->oh.h = helper_rdtsc; return SYMBOL; }
{read_eflags}                   { HANDLE_COLUMN; yylval->oh.h = helper_read_eflags; return SYMBOL; }
{rechecking_single_step}        { HANDLE_COLUMN; yylval->oh.h = helper_rechecking_single_step; return SYMBOL; }
{rem_i32}                       { HANDLE_COLUMN; yylval->oh.h = helper_rem_i32; return SYMBOL; }
{rem_i64}                       { HANDLE_COLUMN; yylval->oh.h = helper_rem_i64; return SYMBOL; }
{roundpd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_roundpd_xmm; return SYMBOL; }
{roundpd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_roundpd_ymm; return SYMBOL; }
{roundps_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_roundps_xmm; return SYMBOL; }
{roundps_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_roundps_ymm; return SYMBOL; }
{roundsd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_roundsd_xmm; return SYMBOL; }
{roundss_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_roundss_xmm; return SYMBOL; }
{rsqrtps_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_rsqrtps_xmm; return SYMBOL; }
{rsqrtps_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_rsqrtps_ymm; return SYMBOL; }
{rsqrtss}                       { HANDLE_COLUMN; yylval->oh.h = helper_rsqrtss; return SYMBOL; }
{sha1msg1}                      { HANDLE_COLUMN; yylval->oh.h = helper_sha1msg1; return SYMBOL; }
{sha1msg2}                      { HANDLE_COLUMN; yylval->oh.h = helper_sha1msg2; return SYMBOL; }
{sha1nexte}                     { HANDLE_COLUMN; yylval->oh.h = helper_sha1nexte; return SYMBOL; }
{sha1rnds4_f0}                  { HANDLE_COLUMN; yylval->oh.h = helper_sha1rnds4_f0; return SYMBOL; }
{sha1rnds4_f1}                  { HANDLE_COLUMN; yylval->oh.h = helper_sha1rnds4_f1; return SYMBOL; }
{sha1rnds4_f2}                  { HANDLE_COLUMN; yylval->oh.h = helper_sha1rnds4_f2; return SYMBOL; }
{sha1rnds4_f3}                  { HANDLE_COLUMN; yylval->oh.h = helper_sha1rnds4_f3; return SYMBOL; }
{sha256msg1}                    { HANDLE_COLUMN; yylval->oh.h = helper_sha256msg1; return SYMBOL; }
{sha256msg2}                    { HANDLE_COLUMN; yylval->oh.h = helper_sha256msg2; return SYMBOL; }
{sha256rnds2}                   { HANDLE_COLUMN; yylval->oh.h = helper_sha256rnds2; return SYMBOL; }
{shufpd_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_shufpd_xmm; return SYMBOL; }
{shufpd_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_shufpd_ymm; return SYMBOL; }
{shufps_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_shufps_xmm; return SYMBOL; }
{shufps_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_shufps_ymm; return SYMBOL; }
{single_step}                   { HANDLE_COLUMN; yylval->oh.h = helper_single_step; return SYMBOL; }
{sqrtpd_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_sqrtpd_xmm; return SYMBOL; }
{sqrtpd_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_sqrtpd_ymm; return SYMBOL; }
{sqrtps_xmm}                    { HANDLE_COLUMN; yylval->oh.h = helper_sqrtps_xmm; return SYMBOL; }
{sqrtps_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_sqrtps_ymm; return SYMBOL; }
{sqrtsd}                        { HANDLE_COLUMN; yylval->oh.h = helper_sqrtsd; return SYMBOL; }
{sqrtss}                        { HANDLE_COLUMN; yylval->oh.h = helper_sqrtss; return SYMBOL; }
{st_i128}                       { HANDLE_COLUMN; yylval->oh.h = helper_st_i128; return SYMBOL; }
{subpd_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_subpd_xmm; return SYMBOL; }
{subpd_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_subpd_ymm; return SYMBOL; }
{subps_xmm}                     { HANDLE_COLUMN; yylval->oh.h = helper_subps_xmm; return SYMBOL; }
{subps_ymm}                     { HANDLE_COLUMN; yylval->oh.h = helper_subps_ymm; return SYMBOL; }
{subsd}                         { HANDLE_COLUMN; yylval->oh.h = helper_subsd; return SYMBOL; }
{subss}                         { HANDLE_COLUMN; yylval->oh.h = helper_subss; return SYMBOL; }
{syscall}                       { HANDLE_COLUMN; yylval->oh.h = helper_syscall; return SYMBOL; }
{sysenter}                      { HANDLE_COLUMN; yylval->oh.h = helper_sysenter; return SYMBOL; }
{sysexit}                       { HANDLE_COLUMN; yylval->oh.h = helper_sysexit; return SYMBOL; }
{sysret}                        { HANDLE_COLUMN; yylval->oh.h = helper_sysret; return SYMBOL; }
{ucomisd}                       { HANDLE_COLUMN; yylval->oh.h = helper_ucomisd; return SYMBOL; }
{ucomiss}                       { HANDLE_COLUMN; yylval->oh.h = helper_ucomiss; return SYMBOL; }
{update_mxcsr}                  { HANDLE_COLUMN; yylval->oh.h = helper_update_mxcsr; return SYMBOL; }
{verr}                          { HANDLE_COLUMN; yylval->oh.h = helper_verr; return SYMBOL; }
{verw}                          { HANDLE_COLUMN; yylval->oh.h = helper_verw; return SYMBOL; }
{vpermdq_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpermdq_ymm; return SYMBOL; }
{vpermd_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_vpermd_ymm; return SYMBOL; }
{vpermilpd_imm_xmm}             { HANDLE_COLUMN; yylval->oh.h = helper_vpermilpd_imm_xmm; return SYMBOL; }
{vpermilpd_imm_ymm}             { HANDLE_COLUMN; yylval->oh.h = helper_vpermilpd_imm_ymm; return SYMBOL; }
{vpermilpd_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_vpermilpd_xmm; return SYMBOL; }
{vpermilpd_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_vpermilpd_ymm; return SYMBOL; }
{vpermilps_imm_xmm}             { HANDLE_COLUMN; yylval->oh.h = helper_vpermilps_imm_xmm; return SYMBOL; }
{vpermilps_imm_ymm}             { HANDLE_COLUMN; yylval->oh.h = helper_vpermilps_imm_ymm; return SYMBOL; }
{vpermilps_xmm}                 { HANDLE_COLUMN; yylval->oh.h = helper_vpermilps_xmm; return SYMBOL; }
{vpermilps_ymm}                 { HANDLE_COLUMN; yylval->oh.h = helper_vpermilps_ymm; return SYMBOL; }
{vpermq_ymm}                    { HANDLE_COLUMN; yylval->oh.h = helper_vpermq_ymm; return SYMBOL; }
{vpgatherdd_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpgatherdd_xmm; return SYMBOL; }
{vpgatherdd_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpgatherdd_ymm; return SYMBOL; }
{vpgatherdq_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpgatherdq_xmm; return SYMBOL; }
{vpgatherdq_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpgatherdq_ymm; return SYMBOL; }
{vpgatherqd_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpgatherqd_xmm; return SYMBOL; }
{vpgatherqd_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpgatherqd_ymm; return SYMBOL; }
{vpgatherqq_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpgatherqq_xmm; return SYMBOL; }
{vpgatherqq_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpgatherqq_ymm; return SYMBOL; }
{vpmaskmovd_st_xmm}             { HANDLE_COLUMN; yylval->oh.h = helper_vpmaskmovd_st_xmm; return SYMBOL; }
{vpmaskmovd_st_ymm}             { HANDLE_COLUMN; yylval->oh.h = helper_vpmaskmovd_st_ymm; return SYMBOL; }
{vpmaskmovd_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpmaskmovd_xmm; return SYMBOL; }
{vpmaskmovd_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpmaskmovd_ymm; return SYMBOL; }
{vpmaskmovq_st_xmm}             { HANDLE_COLUMN; yylval->oh.h = helper_vpmaskmovq_st_xmm; return SYMBOL; }
{vpmaskmovq_st_ymm}             { HANDLE_COLUMN; yylval->oh.h = helper_vpmaskmovq_st_ymm; return SYMBOL; }
{vpmaskmovq_xmm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpmaskmovq_xmm; return SYMBOL; }
{vpmaskmovq_ymm}                { HANDLE_COLUMN; yylval->oh.h = helper_vpmaskmovq_ymm; return SYMBOL; }
{vpsllvd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsllvd_xmm; return SYMBOL; }
{vpsllvd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsllvd_ymm; return SYMBOL; }
{vpsllvq_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsllvq_xmm; return SYMBOL; }
{vpsllvq_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsllvq_ymm; return SYMBOL; }
{vpsravd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsravd_xmm; return SYMBOL; }
{vpsravd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsravd_ymm; return SYMBOL; }
{vpsravq_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsravq_xmm; return SYMBOL; }
{vpsravq_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsravq_ymm; return SYMBOL; }
{vpsrlvd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsrlvd_xmm; return SYMBOL; }
{vpsrlvd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsrlvd_ymm; return SYMBOL; }
{vpsrlvq_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsrlvq_xmm; return SYMBOL; }
{vpsrlvq_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vpsrlvq_ymm; return SYMBOL; }
{vtestpd_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vtestpd_xmm; return SYMBOL; }
{vtestpd_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vtestpd_ymm; return SYMBOL; }
{vtestps_xmm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vtestps_xmm; return SYMBOL; }
{vtestps_ymm}                   { HANDLE_COLUMN; yylval->oh.h = helper_vtestps_ymm; return SYMBOL; }
{write_eflags}                  { HANDLE_COLUMN; yylval->oh.h = helper_write_eflags; return SYMBOL; }
{wrpkru}                        { HANDLE_COLUMN; yylval->oh.h = helper_wrpkru; return SYMBOL; }
{xgetbv}                        { HANDLE_COLUMN; yylval->oh.h = helper_xgetbv; return SYMBOL; }
{xrstor}                        { HANDLE_COLUMN; yylval->oh.h = helper_xrstor; return SYMBOL; }
{xsave}                         { HANDLE_COLUMN; yylval->oh.h = helper_xsave; return SYMBOL; }
{xsaveopt}                      { HANDLE_COLUMN; yylval->oh.h = helper_xsaveopt; return SYMBOL; }
{xsetbv}                        { HANDLE_COLUMN; yylval->oh.h = helper_xsetbv; return SYMBOL; }
{call_ind}                      { HANDLE_COLUMN; yylval->oh.h = helper_call_ind; return SYMBOL; }
{jmp_ind}                       { HANDLE_COLUMN; yylval->oh.h = helper_jmp_ind; return SYMBOL; }
{ret_ind}                       { HANDLE_COLUMN; yylval->oh.h = helper_ret_ind; return SYMBOL; }
{iret_ind}                      { HANDLE_COLUMN; yylval->oh.h = helper_iret_ind; return SYMBOL; }
{dump_load}                     { HANDLE_COLUMN; yylval->oh.h = helper_dump_load; return SYMBOL; }
{dump_store}                    { HANDLE_COLUMN; yylval->oh.h = helper_dump_store; return SYMBOL; }

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
