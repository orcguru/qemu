#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include "tcg_ast.h"
#include "tcg_context.h"
#include "tcg_parser.tab.h"
#include "tcg_lexer.yy.h"
#include "api.h"
#include <llvm-c/Core.h>
#include <llvm-c/Target.h>
#include <llvm-c/TargetMachine.h>
#include <llvm-c/Transforms/PassBuilder.h>
#include <llvm-c/BitReader.h>
#include <llvm-c/Linker.h>
#include <llvm-c/Support.h>
#include <stdbool.h>
#include <glib.h>

//#define BUILD_RISCV_ON_AARCH        1
//#define VERBOSE_VAR                 1
//#define DEBUG                       1
// FIXME: maybe change all uint8_t to int???
#define OPC_INPUT_T         opciosz[opc][0]
#define OPC_OUTPUT_T        opciosz[opc][1]
#define OPC_MEM_T           opciosz[opc][0]
#define OPC_REG_T           opciosz[opc][1]
#define OPC_ADDR_T          LLVMInt64
#define OPC_FIRST_SCALAR_TYPE   LLVMInt8
#define OPC_FIRST_VECTOR_TYPE   LLVMVector8xi8
#define OPC_SCALAR_TYPE_CNT     4
#define OPC_FIXED_TO_VECTOR128(T)   (OPC_FIRST_VECTOR_TYPE + (VS128 - VS64) * OPC_SCALAR_TYPE_CNT + (T - OPC_FIRST_SCALAR_TYPE))
#define OPC_VECTOR_TO_FIXED(T)      (((T - OPC_FIRST_SCALAR_TYPE) % 4) + OPC_FIRST_SCALAR_TYPE)
#define OPC_VECTOR_SIZE(T)          (\
  (LLVMVector16xi8 <= T && T <= LLVMVector2xi64) ? VS128 : ( \
    (LLVMVector32xi8 <= T && T <= LLVMVector4xi64) ? VS256 : (  \
      (LLVMVector8xi8 <= T && T <= LLVMVector1xi64) ? VS64 : VS_INVALID \
      ) \
    ) \
  )

#define DECLARE_AND_INIT_TYPE_FOR_ALL   \
    uint8_t is_vec = is_vector(ptr);    \
    LLVMType vtype = is_vec ? get_llvm_vector_type(ptr) : LLVMInvalidType;      \
    LLVMType type_in = is_vec ? vtype : OPC_INPUT_T;    \
    LLVMType type_out = is_vec ? vtype : OPC_OUTPUT_T;  \
    (void)type_in;  \
    (void)type_out;

#define DECLARE_AND_INIT_TYPE_FOR_SCALAR \
    uint8_t is_vec = 0;    \
    (void)is_vec;           \
    LLVMType type_in = OPC_INPUT_T;    \
    LLVMType type_out = OPC_OUTPUT_T;   \
    (void)type_in;  \
    (void)type_out;

#define DECLARE_AND_INIT_TYPE_FOR_MEM \
    uint8_t is_vec = 0;    \
    (void)is_vec;           \
    LLVMType type_mem = OPC_MEM_T;    \
    LLVMType type_reg = OPC_REG_T;      \
    (void)type_mem;                 \
    (void)type_reg;

#define DECLARE_AND_INIT_TYPE_FOR_VECTOR   \
    uint8_t is_vec = 1;    \
    (void)is_vec;           \
    LLVMType type_in = get_llvm_vector_type(ptr);    \
    LLVMType type_out = type_in;            \
    (void)type_in;  \
    (void)type_out;

#define WITH_FIXED_VEC_CONTEXT      1
#define MAX_OPERANDS_COUNT          16
#define BB_MAX_CNT                  256
#define QEMUAOT_CC                  124
#define REGISTER_INDEX_SHIFT        5 
#define STACK_INDEX_SHIFT           10
#include "xymm_def.h"
#define IS_YMM_HELPER(h)            (h > ymm_helper_begin && h < HELPER_MAX)
#define IS_XMM_HELPER(h)            (h > xmm_helper_begin && h < ymm_helper_begin)
#define INLINE_HELPER_ENABLED(h)    IS_XMM_HELPER(h)

#define DEBUG_VALUE_TYPE(v)                                     \
    do {                                                        \
        LLVMTypeRef v_type = LLVMTypeOf(v);                     \
        char *type_str = LLVMPrintTypeToString(v_type);         \
        printf("DEBUG_VALUE_TYPE:%s\n", type_str);              \
    } while (0)

#define DEBUG_FUNCTION_TYPE(ft)                                 \
    do {                                                        \
        char *type_str = LLVMPrintTypeToString(ft);             \
        printf("DEBUG_FUNCTION_TYPE:%s\n", type_str);           \
    } while (0)

#define CREATE_NOT(OUT, IN)                         \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        if (is_vec) {                               \
            tmp_opc.o = not_vec;                    \
            AttrSrcInfo vs;                         \
            vs.p.vs = OPC_VECTOR_SIZE(type_out);    \
            AttrSrcInfo ves;                        \
            ves.p.ves = OPC_VECTOR_TO_FIXED(type_out); \
            create_vector_slot2(buf, tmp_opc, vs, ves, OUT, IN); \
        } else {                                    \
            tmp_opc.o = type_out == LLVMInt32 ? not_i32 : not_i64;      \
            create_scalar_slot2(buf, tmp_opc, OUT, IN); \
        }                                           \
        translate_not(tmp_opc.o, buf);      \
    } while (0)

#define CREATE_AND(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        if (is_vec) {                               \
            tmp_opc.o = and_vec;                    \
            AttrSrcInfo vs;                         \
            vs.p.vs = OPC_VECTOR_SIZE(type_out);    \
            AttrSrcInfo ves;                        \
            ves.p.ves = OPC_VECTOR_TO_FIXED(type_out); \
            create_vector_slot3(buf, tmp_opc, vs, ves, OUT, IN0, IN1); \
        } else {                                    \
            assert(OPC_OUTPUT_T != LLVMInvalidType);  \
            tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? not_i32 : not_i64;      \
            create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
        }                                           \
        translate_binary(tmp_opc.o, buf, LLVMBuildAnd);     \
    } while (0)

#define CREATE_ANDC_VEC(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(is_vec);                             \
        tmp_opc.o = andc_vec;                    \
        AttrSrcInfo vs;                         \
        vs.p.vs = OPC_VECTOR_SIZE(type_out);    \
        AttrSrcInfo ves;                         \
        ves.p.ves = OPC_VECTOR_TO_FIXED(type_out); \
        create_vector_slot3(buf, tmp_opc, vs, ves, OUT, IN0, IN1); \
        translate_andc(tmp_opc.o, buf);     \
    } while (0)

#define CREATE_XOR(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        if (is_vec) {                               \
            tmp_opc.o = xor_vec;                    \
            AttrSrcInfo vs;                         \
            vs.p.vs = OPC_VECTOR_SIZE(type_out);    \
            AttrSrcInfo ves;                         \
            ves.p.ves = OPC_VECTOR_TO_FIXED(type_out); \
            create_vector_slot3(buf, tmp_opc, vs, ves, OUT, IN0, IN1); \
        } else {                                    \
            assert(OPC_OUTPUT_T != LLVMInvalidType);  \
            tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? xor_i32 : xor_i64;      \
            create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
        }                               \
        translate_binary(tmp_opc.o, buf, LLVMBuildXor);     \
    } while (0)

#define CREATE_XOR_IMM2(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        if (is_vec) {                               \
            tmp_opc.o = xor_vec;                    \
            AttrSrcInfo vs;                         \
            vs.p.vs = OPC_VECTOR_SIZE(type_out);    \
            AttrSrcInfo ves;                         \
            ves.p.ves = OPC_VECTOR_TO_FIXED(type_out); \
            create_vector_slot2_imm(buf, tmp_opc, vs, ves, OUT, IN0, IN1); \
        } else {                                    \
            assert(OPC_OUTPUT_T != LLVMInvalidType);  \
            tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? xor_i32 : xor_i64;      \
            create_scalar_slot2_imm(buf, tmp_opc, OUT, IN0, IN1); \
        }                               \
        translate_binary(tmp_opc.o, buf, LLVMBuildXor);     \
    } while (0)

#define CREATE_EXTRACT(OUT, IN0, IN1, IN2)          \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(OPC_OUTPUT_T != LLVMInvalidType);    \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? extract_i32 : extract_i64;      \
        create_scalar_slot2_imm2(buf, tmp_opc, OUT, IN0, IN1, IN2); \
        translate_extract(tmp_opc.o, buf);              \
    } while (0)

#define CREATE_SHR(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(OPC_OUTPUT_T != LLVMInvalidType);    \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? shr_i32 : shr_i64;      \
        create_scalar_slot2_imm(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildLShr);              \
    } while (0)

#define CREATE_SHR_SLOT(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(OPC_OUTPUT_T != LLVMInvalidType);    \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? shr_i32 : shr_i64;      \
        create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildLShr);              \
    } while (0)

#define CREATE_SHR_VEC(OUT, IN0, IN1, SPLAT)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(is_vec);                             \
        tmp_opc.o = shri_vec;                    \
        AttrSrcInfo vs;                         \
        vs.p.vs = OPC_VECTOR_SIZE(type_out);    \
        AttrSrcInfo ves;                         \
        ves.p.ves = OPC_VECTOR_TO_FIXED(type_out); \
        if (SPLAT) {                            \
            create_vector_slot2_imm(buf, tmp_opc, vs, ves, OUT, IN0, IN1.i); \
            translate_binary_splat_immediate(tmp_opc.o, buf, LLVMBuildLShr);   \
        } else {                                \
            create_vector_slot3(buf, tmp_opc, vs, ves, OUT, IN0, IN1); \
            translate_binary(tmp_opc.o, buf, LLVMBuildLShr);   \
        }                                       \
    } while (0)

#define CREATE_SHL(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(OPC_OUTPUT_T != LLVMInvalidType);    \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? shl_i32 : shl_i64;      \
        create_scalar_slot2_imm(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildShl);              \
    } while (0)

#define CREATE_SHL_SLOT(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(OPC_OUTPUT_T != LLVMInvalidType);    \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? shl_i32 : shl_i64;      \
        create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildShl);              \
    } while (0)

#define CREATE_SHL_VEC(OUT, IN0, IN1, SPLAT)        \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(is_vec);                             \
        tmp_opc.o = shli_vec;                    \
        AttrSrcInfo vs;                         \
        vs.p.vs = OPC_VECTOR_SIZE(type_out);    \
        AttrSrcInfo ves;                         \
        ves.p.ves = OPC_VECTOR_TO_FIXED(type_out); \
        if (SPLAT) {                                \
            create_vector_slot2_imm(buf, tmp_opc, vs, ves, OUT, IN0, IN1.i); \
            translate_binary_splat_immediate(tmp_opc.o, buf, LLVMBuildShl);   \
        } else {                                    \
            create_vector_slot3(buf, tmp_opc, vs, ves, OUT, IN0, IN1); \
            translate_binary(tmp_opc.o, buf, LLVMBuildShl);   \
        }                                           \
    } while (0)

#define CREATE_OR(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        if (is_vec) {                               \
            tmp_opc.o = or_vec;                     \
            AttrSrcInfo vs;                         \
            vs.p.vs = OPC_VECTOR_SIZE(type_out);    \
            AttrSrcInfo ves;                         \
            ves.p.ves = OPC_VECTOR_TO_FIXED(type_out); \
            create_vector_slot3(buf, tmp_opc, vs, ves, OUT, IN0, IN1); \
            translate_binary(tmp_opc.o, buf, LLVMBuildOr);     \
        } else {                                        \
            assert(OPC_OUTPUT_T != LLVMInvalidType);    \
            tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? or_i32 : or_i64;      \
            create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
            translate_binary(tmp_opc.o, buf, LLVMBuildOr);    \
        }                                           \
    } while (0)

#define CREATE_DEPOSIT(OUT, IN0, IN1, OFS, LEN)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(OPC_OUTPUT_T != LLVMInvalidType);    \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? deposit_i32 : deposit_i64;      \
        create_scalar_slot3_imm2(buf, tmp_opc, OUT, IN0, IN1, OFS, LEN); \
        translate_deposit(tmp_opc.o, buf);    \
    } while (0)

#define CREATE_SAR(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(OPC_OUTPUT_T != LLVMInvalidType);    \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? sar_i32 : sar_i64;      \
        create_scalar_slot2_imm(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildAShr);              \
    } while (0)

#define CREATE_ADD(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(OPC_OUTPUT_T != LLVMInvalidType);    \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? add_i32 : add_i64;      \
        create_scalar_slot2_imm(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildAdd);  \
    } while (0)

#define CREATE_ADD64(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = add_i64;      \
        create_scalar_slot2_imm(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildAdd);  \
    } while (0)

#define CREATE_SUB(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        if (is_vec) {                               \
            tmp_opc.o = sub_vec;                     \
            AttrSrcInfo vs;                         \
            vs.p.vs = OPC_VECTOR_SIZE(type_out);    \
            AttrSrcInfo ves;                         \
            ves.p.ves = OPC_VECTOR_TO_FIXED(type_out); \
            create_vector_slot3(buf, tmp_opc, vs, ves, OUT, IN0, IN1); \
        } else {                                        \
            assert(OPC_OUTPUT_T != LLVMInvalidType);    \
            tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? sub_i32 : sub_i64;      \
            create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
        }                                               \
        translate_binary(tmp_opc.o, buf, LLVMBuildSub);  \
    } while (0)

#define CREATE_MOV(OUT, IN)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(OPC_OUTPUT_T != LLVMInvalidType);    \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? mov_i32 : mov_i64;      \
        create_scalar_slot2(buf, tmp_opc, OUT, IN); \
        translate_mov(tmp_opc.o, buf);  \
    } while (0)

#define CREATE_MOV_VEC(VS, VES, OUT, IN)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = mov_vec;      \
        create_vector_slot2(buf, tmp_opc, VS, VES, OUT, IN); \
        translate_mov(tmp_opc.o, buf);  \
    } while (0)

#define CREATE_MOVCOND_VEC(VS, VES, OUT, IN0, IN1, CMP0, CMP1, ROP)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = movcond_vec;      \
        create_vector_slot5_relop(buf, tmp_opc, VS, VES, OUT, IN0, IN1, CMP0, CMP1, ROP); \
        translate_mov(tmp_opc.o, buf);  \
    } while (0)

#define CREATE_CMP_VEC(OUT, IN0, IN1, ROP)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = cmp_vec;      \
        AttrSrcInfo vs;                         \
        vs.p.vs = OPC_VECTOR_SIZE(type_out);    \
        AttrSrcInfo ves;                         \
        ves.p.ves = OPC_VECTOR_TO_FIXED(type_out); \
        create_vector_slot3_relop(buf, tmp_opc, vs, ves, OUT, IN0, IN1, ROP); \
        translate_cmp_vec(tmp_opc.o, buf);  \
    } while (0)

#define CREATE_BITSEL_VEC(OUT, IN0, IN1, IN2)       \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = cmp_vec;      \
        AttrSrcInfo vs;                         \
        vs.p.vs = OPC_VECTOR_SIZE(type_out);    \
        AttrSrcInfo ves;                         \
        ves.p.ves = OPC_VECTOR_TO_FIXED(type_out); \
        create_vector_slot4(buf, tmp_opc, vs, ves, OUT, IN0, IN1, IN2); \
        translate_bitsel_vec(tmp_opc.o, buf);  \
    } while (0)

#define CREATE_MUL(OUT, IN0, IN1)          \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(OPC_OUTPUT_T != LLVMInvalidType);    \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? mul_i32 : mul_i64;      \
        create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildMul);       \
    } while (0)

#define CREATE_MULXH(OUT, IN0, IN1, EXT)          \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        assert(OPC_OUTPUT_T != LLVMInvalidType);    \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt32 ? mulsh_i32 : mulsh_i64;      \
        create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildMul);       \
        translate_mulxh(tmp_opc.o, buf, EXT);       \
    } while (0)

#define CREATE_LABEL(LABEL)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = set_label;     \
        create_setlabel(buf, tmp_opc, LABEL); \
        translate_set_label(tmp_opc.o, buf);  \
    } while (0)

#define CREATE_BRCOND(SLOT, I, ROP, LABEL)           \
    do {                                            \
        uint8_t buf[16];                            \
        create_branch_condition(buf, SLOT, I, ROP, LABEL); \
        translate_brcond_i64(brcond_i64, buf); \
    } while (0)

#define CREATE_LD_ENV_XMM(OPC, OUT, ALIAS)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = OPC;                 \
        create_scalar_slot_env_imm(buf, tmp_opc, OUT, get_xmm_offset(ALIAS.s.slot_idx/2) + 16*(ALIAS.s.slot_idx%2) + ALIAS.s.offset);    \
        translate_ld_env_xmm(tmp_opc.o, buf); \
    } while (0)

#define CREATE_LD(L, ADDR)                \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = qemu_ld_i64;                    \
        AttrSrcInfo a0, a1, a2;                     \
        a0.subt = SUB_ATTR_ATOMIC;                  \
        a0.p.storage.attr.atomic = NONATOMIC;       \
        a1.subt = SUB_ATTR_ALIGNMENT;               \
        a1.p.storage.attr.alignment = ALIGN_MEM_SIZE;   \
        a2.subt = SUB_ATTR_SRCSIZEEXT;              \
        a2.p.storage.attr.ext = ZERO;               \
        a2.p.storage.size = SRC8B;                  \
        create_scalar_slot2_attr3_num(buf, tmp_opc, L, ADDR, a0, a1, a2, 2);      \
        translate_qemu_ld(tmp_opc.o, buf);        \
    } while (0)

#define CREATE_ST(R, ADDR)                \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = qemu_st_i64;                    \
        AttrSrcInfo a0, a1, a2;                     \
        a0.subt = SUB_ATTR_ATOMIC;                  \
        a0.p.storage.attr.atomic = NONATOMIC;       \
        a1.subt = SUB_ATTR_ALIGNMENT;               \
        a1.p.storage.attr.alignment = ALIGN_MEM_SIZE;   \
        a2.subt = SUB_ATTR_SRCSIZEEXT;              \
        a2.p.storage.attr.ext = ZERO;               \
        a2.p.storage.size = SRC8B;                  \
        create_scalar_slot2_attr3_num(buf, tmp_opc, R, ADDR, a0, a1, a2, 2);      \
        translate_qemu_st(tmp_opc.o, buf);        \
    } while (0)

extern char *lineptr;
extern const char *opcode_type_str[];
extern const char *llvm_type_str[];
extern const char *cvector_str[];
extern const LLVMType opciosz[OPCODE_MAX][2];
extern const uint8_t opcoc[OPCODE_MAX];
extern const uint8_t opcmem_addr_nzidx[OPCODE_MAX];
extern const char *helper_str[];
extern const char *xmmreg_str[];
extern const uint64_t xreg_offsets[XREG_MAX];
extern const CVectorType cvector_type_for_llvm_type[LLVMMAXType];
extern const char *ymm_str[NON_XMM];
extern const int helper_qemuaot_with_env[HELPER_MAX];
extern const LLVMType helper_collapse_xmm_arg_type[HELPER_MAX][MAX_ADDED_ARGS];
extern const LLVMType helper_return_type[HELPER_MAX];
extern const int helper_require_exception_path[HELPER_MAX];

static char func_name_prefix[33] = {0};
static LLVMAttributeRef target_features_attr = NULL;
static LLVMAttributeRef NoInlineAttr = NULL;
static LLVMAttributeRef AlwaysInlineAttr = NULL;
static LLVMTargetMachineRef target_machine = NULL;
static LLVMContextRef context = NULL;
static LLVMModuleRef module = NULL;
static LLVMBuilderRef builder = NULL;
static LLVMValueRef llvm_func = NULL;
static LLVMBasicBlockRef last_active_bb = NULL;
#define FIXED_PARAM_COUNT           XREG_MAX
#define FIXED_VECTOR_PARAM_COUNT   (XREG_MAX + XMM_COUNT * 2)

#define TARGET_QEMUAOT_FASTPATH                                     0
#define TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_WO_VECTOR      1
#define TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_WI_VECTOR      2
#define TARGET_QEMUAOT_CC_COMPUTE                                   3
#define TARGET_QEMUAOT_HELPER                                       4
#define TARGET_DEFAULT_HELPER_PASSTHROUGH_VECTOR                    5
#define TARGET_DEFAULT_HELPER_CONSTRUCT_VECTOR                      6
#define TARGET_QEMUAOT_HELPER_SECOND_HALF                           7

#define TYPE_AND_VALUE          0
#define TYPE_ONLY               1
#define VALUE_ONLY              2

#define HELPER_DEFINES_OUTPUT(h)        (helper_return_type[h] != LLVMInvalidType)

static LLVMTypeRef fixed_llvmtyperef[FIXED_VECTOR_PARAM_COUNT] = {NULL};
static LLVMType fixed_vector_param_llvmtypes[FIXED_VECTOR_PARAM_COUNT] = {0};
static uint8_t fixed_vector_param_in_stack[FIXED_VECTOR_PARAM_COUNT] = {0};
static const char *fixed_vector_arg_names[FIXED_VECTOR_PARAM_COUNT] = {NULL};
static const char *fixed_vector_stack_names[FIXED_VECTOR_PARAM_COUNT] = {NULL};
static const char *tmp_stack_names[1<<STACK_INDEX_SHIFT] = {NULL};
static const char *ir_var_name[('z'-'a'+1)*('z'-'a'+1)*('z'-'a'+1)*('z'-'a'+1)] = {NULL};
static int ir_var_name_idx = 0;
static LLVMTypeRef llvm_int_types[LLVMMAXType] = {0};
static LLVMTypeRef llvm_int_store_types[LLVMMAXType] = {0};
static uint8_t llvm_vector_elem_bit_counts[LLVMMAXType * 2] = {0};
static LLVMValueRef func_xreg_alloca[1<<REGISTER_INDEX_SHIFT] = {NULL};
static LLVMValueRef func_tmp_alloca[1<<STACK_INDEX_SHIFT] = {NULL};
static LLVMValueRef func_xmm_alloca[1<<REGISTER_INDEX_SHIFT] = {NULL};
static LLVMType func_xreg_llvmtype[1<<REGISTER_INDEX_SHIFT] = {0};
static LLVMType func_tmp_llvmtype[1<<STACK_INDEX_SHIFT] = {0};
static LLVMType func_xmm_llvmtype[1<<REGISTER_INDEX_SHIFT] = {0};
static uint32_t env_var_offset[ENVVarMAX] = {0};
static OperandType alias_tmp[1<<STACK_INDEX_SHIFT] = {0};
static LLVMIntPredicate llvm_predicate[RELOPMAX] = {0};
static uint32_t br_cnt = 0;
static uint64_t current_func_offset = 0;
static uint8_t current_call_idx = 0;
static int32_t shadow_call_offset = 16;
static uint32_t xreg_valid = 0, xmm_valid = 0;
static uint8_t tmp_valid_non_zero = 0;
static uint64_t tmp_valid[(1<<STACK_INDEX_SHIFT)/(8*sizeof(uint64_t))] = {0};
static uint64_t tmp_var_available[(1<<STACK_INDEX_SHIFT)/(8*sizeof(uint64_t))] = {0};
static uint64_t tmp_var_available_backup[(1<<STACK_INDEX_SHIFT)/(8*sizeof(uint64_t))] = {0};
static LLVMType tmp_bits_type[1<<STACK_INDEX_SHIFT] = {0};
static char output_file[4096] = {0};
static OperandType dummy_slot_for_debug;
static int32_t tmp_shadow_offset[1<<STACK_INDEX_SHIFT] = {0};
#define LLVMNoInlineAttribute       32
#define LLVMAlwaysInlineAttribute   3

typedef struct active_label_info {
    LLVMValueRef llvm_func;
    uint8_t current_active_label_cnt;
    uint8_t current_active_labels[BB_MAX_CNT];
    struct active_label_info *next;
} active_label_info_t;
static GHashTable *current_active_label_info = NULL;

typedef struct helper_aux_info {
    void *ptr;
    uint8_t idx;
    struct helper_aux_info *next;
} helper_aux_info_t;
static GHashTable *current_helper_aux_info = NULL;

static void do_store(OpCodeType opc, LLVMValueRef val, LLVMType val_tidx, OperandType out);
static LLVMValueRef get_env_ptr_raw();
static void set_env_ptr_raw(LLVMValueRef env_stack);
static OperandType get_env_ptr(OpCodeType opc);
static OperandType get_shadow_stack_pointer(OpCodeType opc);
static void set_shadow_stack_pointer(OpCodeType opc, OperandType val);
static LLVMBasicBlockRef get_bb(const char *name);
static void handle_single_instr(OpCodeType opc, void *ptr);
static uint8_t do_link_helper(HelperType h, const char *build_macro, const char *bc_name, const char *c_file);
static uint8_t is_tail_call(HelperType h);
static uint8_t is_opc_end_of_control_flow(OpCodeType opc, void *ptr);
static LLVMValueRef get_or_add_func_with_qemuaot_cc(const char *name, int with_ret, LLVMAttributeRef attr_inline_ctrl);
static void setup_func_stack();
static LLVMValueRef get_trampoline(LLVMValueRef helper_func, uint8_t do_return, uint8_t with_ret, OperandType *operands, uint32_t *is_imm, uint8_t operands_cnt, LLVMValueRef next_func, int spill_cnt, XMMRegType *spilled_xmm_regs, int fix_second_half_addr, int target_domain);
static void translate_short_circuit_jmp_ind(OpCodeType opc, void *ptr);
static void translate_cc_compute_inband(OpCodeType opc, void *ptr);
static void translate_helper_outband(OpCodeType opc, void *ptr);
static void register_labels_for_func(LLVMValueRef func);
static uint8_t *get_current_active_labels(LLVMValueRef func);
static uint8_t get_current_active_label_cnt(LLVMValueRef func);
static void set_current_active_label_cnt(uint8_t current_active_label_cnt);
static void register_idx_for_call_helper(void *ptr, uint8_t call_idx);
static uint8_t get_idx_for_call_helper(void *ptr);
static LLVMValueRef get_source_node_imm_or_stack(OpCodeType opc, uint32_t is_imm, OperandType operand, LLVMType tidx, int splat);
static LLVMTypeRef get_vector_parameter_type_for_arch();
static LLVMValueRef reload_vector(XMMRegType xmm_reg);
static int collect_arguments_and_types(HelperType h, int target_domain, int gen_flag, OperandType *operands, uint32_t *is_imm, uint8_t operands_cnt, LLVMValueRef appendix1, LLVMValueRef appendix2, LLVMValueRef current_func,
                LLVMTypeRef *out_typeref, int out_typeref_limit, LLVMValueRef *out_valref, const char *func_name);

#define GET_2_OPERANDS()                                \
    do {                                                \
        uint32_t is_imm0, is_imm1;                      \
        operand0 = get_operand(ptr, 0, &is_imm0);       \
        operand1 = get_operand(ptr, 1, &is_imm1);       \
        assert(!is_imm0 && operand0.s.valid && !is_imm1 && operand1.s.valid);   \
    } while (0)

#define GET_2_OPERANDS_NOCHECK()                        \
    do {                                                \
        operand0 = get_operand(ptr, 0, &is_imm0);       \
        operand1 = get_operand(ptr, 1, &is_imm1);       \
    } while (0)

#define GET_3_OPERANDS()                                \
    do {                                                \
        uint32_t is_imm0, is_imm1, is_imm2;             \
        operand0 = get_operand(ptr, 0, &is_imm0);       \
        operand1 = get_operand(ptr, 1, &is_imm1);       \
        operand2 = get_operand(ptr, 2, &is_imm2);       \
        assert(!is_imm0 && operand0.s.valid && !is_imm1 && operand1.s.valid && !is_imm2 && operand2.s.valid);   \
    } while (0)

#define GET_3_OPERANDS_NOCHECK()                        \
    do {                                                \
        operand0 = get_operand(ptr, 0, &is_imm0);       \
        operand1 = get_operand(ptr, 1, &is_imm1);       \
        operand2 = get_operand(ptr, 2, &is_imm2);       \
    } while (0)

#define GET_3_OPERANDS_NOCHECK_DBG()                    \
    do {                                                \
        operand0 = get_operand(ptr, 0, &is_imm0);       \
        operand1 = get_operand(ptr, 1, &is_imm1);       \
        operand2 = get_operand(ptr, 2, &is_imm2);       \
        printf("is_imm0:%d, is_imm1:%d, is_imm2:%d\n", is_imm0, is_imm1, is_imm2);  \
        printf("operand0 - slot_type:%d, slot_idx::%d, offset:%d\n", operand0.s.slot_type, operand0.s.slot_idx, operand0.s.offset);    \
        printf("operand1 - slot_type:%d, slot_idx::%d, offset:%d\n", operand1.s.slot_type, operand1.s.slot_idx, operand1.s.offset);    \
        printf("operand2 - slot_type:%d, slot_idx::%d, offset:%d\n", operand2.s.slot_type, operand2.s.slot_idx, operand2.s.offset);    \
    } while (0)

#define GET_4_OPERANDS()                                \
    do {                                                \
        uint32_t is_imm0, is_imm1, is_imm2, is_imm3;             \
        operand0 = get_operand(ptr, 0, &is_imm0);       \
        operand1 = get_operand(ptr, 1, &is_imm1);       \
        operand2 = get_operand(ptr, 2, &is_imm2);       \
        operand3 = get_operand(ptr, 3, &is_imm3);       \
        assert(!is_imm0 && operand0.s.valid && !is_imm1 && operand1.s.valid && !is_imm2 && operand2.s.valid && !is_imm3 && operand3.s.valid);   \
    } while (0)

#define GET_5_OPERANDS()                                \
    do {                                                \
        uint32_t is_imm0, is_imm1, is_imm2, is_imm3, is_imm4;             \
        operand0 = get_operand(ptr, 0, &is_imm0);       \
        operand1 = get_operand(ptr, 1, &is_imm1);       \
        operand2 = get_operand(ptr, 2, &is_imm2);       \
        operand3 = get_operand(ptr, 3, &is_imm3);       \
        operand4 = get_operand(ptr, 4, &is_imm4);       \
        assert(!is_imm0 && operand0.s.valid && !is_imm1 && operand1.s.valid && !is_imm2 && operand2.s.valid && !is_imm3 && operand3.s.valid && !is_imm4 && operand4.s.valid);   \
    } while (0)

#define GET_STORAGE_ATTR()                                      \
    do {                                                        \
        a0.p.storage.attr.atomic = attr.attr_val >> 6;          \
        a1.p.storage.attr.alignment = (attr.attr_val >> 4) & 0x3;   \
        a2.p.storage.attr.ext = (attr.attr_val >> 3) & 0x1;     \
        a2.p.storage.size = attr.attr_val & 0x7;                \
    } while (0)

static uint8_t is_opc_end_of_control_flow(OpCodeType opc, void *ptr) {
    if (opc == jmp_direct) {
        return 1;
    } else if (opc == call) {
#if AOT_LEVEL == AOT_LEVEL_MAX
        HelperType h = get_helper(ptr);
        if (h == helper_cc_compute_all || h == helper_cc_compute_c) {
            return 0;
        } else {
            return 1;
        }
#elif AOT_LEVEL == AOT_LEVEL_0
        return 1;
#endif
    }
    return 0;
}

static uint8_t tmp_available_test(uint64_t *ptr, uint16_t idx) {
    int group_idx = idx / (8*sizeof(uint64_t));
    int element_idx = idx % (8*sizeof(uint64_t));
    if (ptr[group_idx] & (1UL<<element_idx)) {
        return 1;
    } else {
        return 0;
    }
}

static void tmp_available_clear(uint64_t *ptr, uint16_t idx) {
    int group_idx = idx / (8*sizeof(uint64_t));
    int element_idx = idx % (8*sizeof(uint64_t));
    ptr[group_idx] &= ~(1UL<<element_idx);
}

static void tmp_available_set(uint64_t *ptr, uint16_t idx) {
    int group_idx = idx / (8*sizeof(uint64_t));
    int element_idx = idx % (8*sizeof(uint64_t));
    ptr[group_idx] |= (1UL<<element_idx);
}

static uint16_t get_next_spare_tmp_var() {
    uint16_t ret = 0xffff;
    for (uint16_t i = 0; i < (1<<STACK_INDEX_SHIFT); ++i) {
        if (tmp_available_test(tmp_var_available, i)) {
            ret = i;
            tmp_available_clear(tmp_var_available, i);
            break;
        }
    }
    assert(ret != 0xffff);
    return ret;
}

static OperandType get_tmp_and_do_alloc(LLVMType type) {
    OperandType tmp;
    tmp.s.valid = 1;
    tmp.s.slot_type = SUB_SLOT_TMP;
    tmp.s.slot_idx = get_next_spare_tmp_var();
#ifdef DEBUG
    printf("  allocate tmp%d\n", tmp.s.slot_idx); fflush(NULL);
#endif
    LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[type], tmp_stack_names[tmp.s.slot_idx]);
    func_tmp_alloca[tmp.s.slot_idx] = alloca_inst;
    func_tmp_llvmtype[tmp.s.slot_idx] = type;
    return tmp;
}

static OperandType get_alias(OperandType operand) {
    if (operand.s.slot_type == SUB_SLOT_TMP) {
        return alias_tmp[operand.s.slot_idx];
    } else {
        assert(0);
    }
}

static uint32_t has_alias(OperandType operand) {
    if (operand.s.slot_type == SUB_SLOT_TMP) {
        return alias_tmp[operand.s.slot_idx].s.valid;
    } else {
        assert(0);
    }
}

static uint32_t has_alias_xmm(OperandType operand) {
    if (operand.s.slot_type == SUB_SLOT_TMP) {
        return alias_tmp[operand.s.slot_idx].s.valid &&
            alias_tmp[operand.s.slot_idx].s.slot_type == SUB_SLOT_XMM;
    } else {
        assert(0);
    }
}

static uint32_t has_alias_env(OperandType operand) {
    if (operand.s.slot_type == SUB_SLOT_TMP) {
        return alias_tmp[operand.s.slot_idx].s.valid &&
            alias_tmp[operand.s.slot_idx].s.slot_type == SUB_SLOT_ENV;
    } else {
        assert(0);
    }
}

static LLVMValueRef get_stack_alloca(OperandType operand) {
    LLVMValueRef alloca = NULL;
    if (operand.s.slot_type == SUB_SLOT_XREG) {
        alloca = func_xreg_alloca[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_TMP) {
        assert(has_alias(operand) == 0);
        alloca = func_tmp_alloca[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_XMM) {
        alloca = func_xmm_alloca[operand.s.slot_idx];
    } else {
        assert(0);
    }
    return alloca;
}

static OperandType get_tmp_and_do_alloc_with_init(LLVMType type, uint64_t val) {
    OperandType tmp = get_tmp_and_do_alloc(type);
    LLVMValueRef constant = LLVMConstInt(llvm_int_types[type], val, 0);
    LLVMBuildStore(builder, constant, get_stack_alloca(tmp));
    return tmp;
}

static const char *get_next_var_name(const char *tag, OperandType slot_name_for_debug) {
    assert(ir_var_name_idx < sizeof(ir_var_name)/sizeof(const char *));
#ifndef VERBOSE_VAR
    return ir_var_name[ir_var_name_idx++];
#else
    char *orig_slot_info = "";
    char info[64] = {0};
    if (slot_name_for_debug.s.valid) {
      OperandType orig_slot = get_original_slot_for_debug(slot_name_for_debug);
      if (orig_slot.s.valid) {
        sprintf(info, "%s%d", orig_slot.s.slot_type == SUB_SLOT_TMPL ? "loc" : "tmp", orig_slot.s.slot_idx);
        assert(strlen(info) < sizeof(info));
        orig_slot_info = info;
      }
    }
    static char verbose_name[128] = {0};
    sprintf(verbose_name, "%s_%s_%s", tag, orig_slot_info, ir_var_name[ir_var_name_idx++]);
    assert(strlen(verbose_name) < sizeof(verbose_name));
    return (const char *)verbose_name;
#endif
}

static OperandType get_shadow_stack_pointer(OpCodeType opc) {
    OperandType ptr_addr = get_tmp_and_do_alloc(OPC_ADDR_T);
    OperandType env = get_env_ptr(opc);
    CREATE_ADD64(ptr_addr, env, -8UL);
    OperandType ptr_val = get_tmp_and_do_alloc(OPC_ADDR_T);
    CREATE_LD(ptr_val, ptr_addr);
    return ptr_val;
}

static void set_shadow_stack_pointer(OpCodeType opc, OperandType val) {
    OperandType ptr_addr = get_tmp_and_do_alloc(OPC_ADDR_T);
    OperandType env = get_env_ptr(opc);
    CREATE_ADD64(ptr_addr, env, -8UL);
    CREATE_ST(val, ptr_addr);
}

static LLVMBasicBlockRef get_bb(const char *name) {
    LLVMBasicBlockRef current_block = LLVMGetFirstBasicBlock(llvm_func);
    while (current_block != NULL) {
        const char *block_name = LLVMGetBasicBlockName(current_block);
        if (block_name != NULL && strcmp(block_name, name) == 0) {
            return current_block;
        }
        current_block = LLVMGetNextBasicBlock(current_block);
    }
    return NULL;
}

static LLVMTypeRef get_vector_parameter_type_for_arch() {
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    return LLVMVectorType(LLVMInt64Type(), 2); // <2 x i64>
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    return LLVMScalableVectorType(LLVMInt64Type(), 1); // <vscale x 1 x i64>
#endif
}

static void create_module(const char *module_name) {
    context = LLVMGetGlobalContext();
    NoInlineAttr = LLVMCreateEnumAttribute(context, LLVMNoInlineAttribute, 0);
    AlwaysInlineAttr = LLVMCreateEnumAttribute(context, LLVMAlwaysInlineAttribute, 0);
    const char *attr_key = "target-features";
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    const char *attr_value = "+neon";
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    const char *attr_value = "+m,+a,+f,+d,+v";
#endif
    size_t attr_key_len = strlen(attr_key);
    size_t attr_value_len = strlen(attr_value);
    target_features_attr = LLVMCreateStringAttribute(context, attr_key, attr_key_len, attr_value, attr_value_len);
    module = LLVMModuleCreateWithNameInContext(module_name, context);

#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    LLVMSetTarget(module, "aarch64-unknown-linux-gnu");
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    LLVMSetTarget(module, "riscv64-unknown-linux-gnu");
#endif
}

static void register_alias(OperandType lval, OperandType rval) {
    if (lval.s.slot_type == SUB_SLOT_TMP) {
        alias_tmp[lval.s.slot_idx] = rval;
    } else {
        assert(0);
    }
}

static void unregister_alias(OperandType operand) {
    if (operand.s.slot_type == SUB_SLOT_TMP) {
        alias_tmp[operand.s.slot_idx].i = 0;
    } else {
        assert(0);
    }
}

static LLVMType get_stack_llvmtype(OperandType operand) {
    if (operand.s.slot_type == SUB_SLOT_XREG) {
        return func_xreg_llvmtype[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_TMP) {
        return func_tmp_llvmtype[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_XMM) {
        return func_xmm_llvmtype[operand.s.slot_idx];
    }
    assert(0);
}

static LLVMValueRef get_env_ptr_raw() {
    LLVMTypeRef asm_return_type = llvm_int_types[OPC_ADDR_T];
    LLVMTypeRef asm_param_types[] = {};
    LLVMTypeRef asm_function_type = LLVMFunctionType(asm_return_type, asm_param_types, 0, 0);
    //FIXME: handle AArch64 as well
    char asm_string[128];
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    sprintf(asm_string, "mov $0, x25");
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    sprintf(asm_string, "mv $0, x25");
#endif
    const char *constraint_string = "=r";
    LLVMValueRef inline_asm = LLVMConstInlineAsm(asm_function_type, asm_string, constraint_string, /* has_side_effects */ 1, /* is_align_stack */ 0);
    return LLVMBuildCall2(builder, asm_function_type, inline_asm, NULL, 0, get_next_var_name("env_ptr", dummy_slot_for_debug));
}

static void set_env_ptr_raw(LLVMValueRef env_stack) {
    LLVMTypeRef asm_param_types[] = { llvm_int_types[OPC_ADDR_T] };
    LLVMTypeRef asm_function_type = LLVMFunctionType(LLVMVoidType(), asm_param_types, 1, 0);
    char asm_string[128];
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    sprintf(asm_string, "mov x25, $0");
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    sprintf(asm_string, "mv x25, $0");
#endif
    const char *constraint_string = "r,~{x25}";
    LLVMValueRef inline_asm = LLVMConstInlineAsm(asm_function_type, asm_string, constraint_string, /* has_side_effects */ 1, /* is_align_stack */ 0);
    LLVMValueRef call_args[] = { env_stack };
    LLVMBuildCall2(builder, asm_function_type, inline_asm, call_args, 1, "");
    return;
}

static OperandType get_env_ptr(OpCodeType opc) {
    OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
    LLVMValueRef val = get_env_ptr_raw();
    do_store(opc, val, OPC_ADDR_T, tmp);
    return tmp;
}

static LLVMValueRef check_scalable_vector_perform_load(LLVMType val_tidx, LLVMValueRef addr) {
    LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_store_types[val_tidx], 0), get_next_var_name("check_scalable_store", dummy_slot_for_debug));
    LLVMValueRef val = LLVMBuildLoad2(builder, llvm_int_store_types[val_tidx], ptr, get_next_var_name("check_scalable_load", dummy_slot_for_debug));
    if (llvm_int_types[val_tidx] != llvm_int_store_types[val_tidx]) {
        LLVMTypeRef intrinsic_types[] = {llvm_int_types[val_tidx], llvm_int_store_types[val_tidx], llvm_int_types[OPC_ADDR_T]};
        LLVMTypeRef intrinsic_func_type = LLVMFunctionType(llvm_int_types[val_tidx], intrinsic_types, 3, 0);
        char intrinsic_func_name[128] = {0};
        sprintf(intrinsic_func_name, "llvm.vector.insert.nxv%di%d.v%di%d", llvm_vector_elem_bit_counts[val_tidx*2]/2, llvm_vector_elem_bit_counts[val_tidx*2+1], llvm_vector_elem_bit_counts[val_tidx*2], llvm_vector_elem_bit_counts[val_tidx*2+1]);
        assert(strlen(intrinsic_func_name) < sizeof(intrinsic_func_name));
        LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, intrinsic_func_name);
        if (!intrinsic_func) {
            intrinsic_func = LLVMAddFunction(module, intrinsic_func_name, intrinsic_func_type);
        }
        LLVMValueRef index_0 = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
        LLVMValueRef intrinsic_call_args[] = {LLVMGetPoison(llvm_int_types[val_tidx]), val, index_0};
        val = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 3, get_next_var_name("check_scalable_load", dummy_slot_for_debug));
    }
    return val;
}

static LLVMValueRef check_scalable_vector_perform_store(LLVMValueRef val, LLVMType val_tidx, LLVMValueRef addr) {
    LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_store_types[val_tidx], 0), get_next_var_name("check_scalable_store", dummy_slot_for_debug));
    if (llvm_int_types[val_tidx] != llvm_int_store_types[val_tidx]) {
        LLVMTypeRef intrinsic_types[] = {llvm_int_types[val_tidx], llvm_int_types[OPC_ADDR_T]};
        LLVMTypeRef intrinsic_func_type = LLVMFunctionType(llvm_int_store_types[val_tidx], intrinsic_types, 2, 0);
        char intrinsic_func_name[128] = {0};
        sprintf(intrinsic_func_name, "llvm.vector.extract.v%di%d.nxv%di%d", llvm_vector_elem_bit_counts[val_tidx*2], llvm_vector_elem_bit_counts[val_tidx*2+1], llvm_vector_elem_bit_counts[val_tidx*2]/2, llvm_vector_elem_bit_counts[val_tidx*2+1]);
        assert(strlen(intrinsic_func_name) < sizeof(intrinsic_func_name));
        LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, intrinsic_func_name);
        if (!intrinsic_func) {
            intrinsic_func = LLVMAddFunction(module, intrinsic_func_name, intrinsic_func_type);
        }
        LLVMValueRef index_0 = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
        LLVMValueRef intrinsic_call_args[] = {val, index_0};
        val = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 2, get_next_var_name("check_scalable_store", dummy_slot_for_debug));
    }
    return LLVMBuildStore(builder, val, ptr);
}

static void do_store(OpCodeType opc, LLVMValueRef val, LLVMType val_tidx, OperandType out) {
    assert(val_tidx != LLVMInvalidType && val_tidx < LLVMMAXType);
    if (out.s.slot_type == SUB_SLOT_ENVVAR) {
        OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
        OperandType env = get_env_ptr(opc);
        CREATE_ADD64(tmp, env, env_var_offset[out.s.slot_idx]);
        LLVMValueRef tmp_src = get_source_node_imm_or_stack(opc, 0, tmp, OPC_ADDR_T, 0);
        check_scalable_vector_perform_store(val, val_tidx, tmp_src);
    } else if (out.s.slot_type == SUB_SLOT_ENV) {
        OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
        OperandType env = get_env_ptr(opc);
        // v64 type stores into MMX region
        CREATE_ADD64(tmp, env, out.s.offset);
        LLVMValueRef tmp_src = get_source_node_imm_or_stack(opc, 0, tmp, OPC_ADDR_T, 0);
        check_scalable_vector_perform_store(val, val_tidx, tmp_src);
    } else {
        LLVMType out_idx = get_stack_llvmtype(out);
        assert((val_tidx <= LLVMInt64 && out_idx <= LLVMInt64 && val_tidx <= out_idx) ||
               (val_tidx <= LLVMInt64 && out_idx > LLVMInt64) ||
               (val_tidx > LLVMInt64 && out_idx > LLVMInt64));
        if (val_tidx <= LLVMInt64 && out_idx <= LLVMInt64 && val_tidx < out_idx) {
            val = LLVMBuildZExt(builder, val, llvm_int_types[out_idx], get_next_var_name("store_val_ext", out));
        } else if (val_tidx <= LLVMInt64 && out_idx > LLVMInt64) {
            assert(out.s.slot_type == SUB_SLOT_XMM);
            assert((out.s.offset * 8) % llvm_vector_elem_bit_counts[val_tidx*2+1] == 0);
            uint8_t full_cnt = 128/llvm_vector_elem_bit_counts[val_tidx*2+1];
            LLVMValueRef constants[16];
            LLVMValueRef element_value = LLVMConstInt(llvm_int_types[val_tidx], 0, 0);
            for (int i = 0; i < full_cnt; i++) {
                constants[i] = element_value;
            }
            LLVMValueRef vec_zero = LLVMConstVector(constants, full_cnt);
            LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], (out.s.offset * 8) / llvm_vector_elem_bit_counts[val_tidx*2+1], 0);
            val = LLVMBuildInsertElement(builder, vec_zero, val, index, get_next_var_name("store_val_vec", out));
            if ((val_tidx + 4) != out_idx) {
                val = LLVMBuildBitCast(builder, val, llvm_int_types[out_idx], get_next_var_name("store_val_bitcast", out));
            }
        } else if (val_tidx > LLVMInt64 && out_idx > LLVMInt64 && val_tidx != out_idx) {
            val = LLVMBuildBitCast(builder, val, llvm_int_types[out_idx], get_next_var_name("store_val_bitcast", out));
        }
        LLVMBuildStore(builder, val, get_stack_alloca(out));
    }
}

static LLVMValueRef get_source_node_imm_or_stack(OpCodeType opc, uint32_t is_imm, OperandType operand, LLVMType tidx, int splat) {
    assert(tidx != LLVMInvalidType && tidx < LLVMMAXType);
    LLVMTypeRef type = llvm_int_types[tidx];
    LLVMValueRef ret = NULL;
    if (is_imm) {
        if (tidx <= LLVMInt64) {
            ret = LLVMConstInt(type, operand.i, 0);
        } else {
            LLVMValueRef constants[16];
            uint8_t full_cnt = llvm_vector_elem_bit_counts[tidx*2];
            if (splat) {
                LLVMValueRef element_value = LLVMConstInt(llvm_int_types[OPC_VECTOR_TO_FIXED(tidx)], operand.i, 0);
                for (int i = 0; i < full_cnt; i++) {
                    constants[i] = element_value;
                }
            } else {
                uint64_t val = operand.i;
                uint8_t half_cnt = llvm_vector_elem_bit_counts[tidx*2]/2;
                uint8_t bit_cnt = llvm_vector_elem_bit_counts[tidx*2+1];
                for (int i = 0; i < full_cnt; i++) {
                    if (i == half_cnt) {
                        val = operand.i;
                    }
                    LLVMValueRef element_value = LLVMConstInt(llvm_int_types[OPC_VECTOR_TO_FIXED(tidx)], val & ((1UL<<bit_cnt)-1), 0);
                    constants[i] = element_value;
                    val = val >> bit_cnt;
                }
            }
            ret = LLVMConstVector(constants, full_cnt);
#if defined(__riscv) && __riscv_xlen == 64 || defined(BUILD_RISCV_ON_AARCH)
            LLVMTypeRef ret_type = llvm_int_types[tidx];
            LLVMTypeRef param_type = LLVMVectorType(llvm_int_types[OPC_VECTOR_TO_FIXED(tidx)], llvm_vector_elem_bit_counts[tidx*2]);
            LLVMTypeRef intrinsic_types[] = {ret_type, param_type, llvm_int_types[OPC_ADDR_T]};
            LLVMTypeRef intrinsic_func_type = LLVMFunctionType(ret_type, intrinsic_types, 3, 0);
            char intrinsic_func_name[128] = {0};
            sprintf(intrinsic_func_name, "llvm.vector.insert.nxv%di%d.v%di%d", llvm_vector_elem_bit_counts[tidx*2]/2, llvm_vector_elem_bit_counts[tidx*2+1], llvm_vector_elem_bit_counts[tidx*2], llvm_vector_elem_bit_counts[tidx*2+1]);
            assert(strlen(intrinsic_func_name) < sizeof(intrinsic_func_name));
            LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, intrinsic_func_name);
            if (!intrinsic_func) {
                intrinsic_func = LLVMAddFunction(module, intrinsic_func_name, intrinsic_func_type);
            }
            LLVMValueRef index_0 = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
            LLVMValueRef intrinsic_call_args[] = {LLVMGetPoison(ret_type), ret, index_0};
            ret = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 3, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
#endif
        }
    } else if (operand.s.slot_type == SUB_SLOT_ENVVAR) {
        OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
        OperandType env = get_env_ptr(opc);
        CREATE_ADD64(tmp, env, env_var_offset[operand.s.slot_idx]);
        LLVMValueRef tmp_src = get_source_node_imm_or_stack(opc, 0, tmp, OPC_ADDR_T, 0);
        LLVMTypeRef val_type = type;
#if AOT_LEVEL == AOT_LEVEL_0
        if (operand.s.slot_idx == cc_op) {
            val_type = llvm_int_types[LLVMInt32];
        }
#endif
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, tmp_src, LLVMPointerType(val_type, 0), get_next_var_name("source_env_ptr_offset", operand));
        ret = LLVMBuildLoad2(builder, val_type, ptr, get_next_var_name("source_val", operand));
        if (val_type != type) {
            ret = LLVMBuildZExt(builder, ret, type, get_next_var_name("store_val_ext", operand));
        }
    } else if (operand.s.slot_type == SUB_SLOT_ENV) {
        if (operand.s.offset == 0) {
            ret = get_env_ptr_raw();
        } else {
            OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
            OperandType env = get_env_ptr(opc);
            CREATE_ADD64(tmp, env, operand.s.offset);
            LLVMValueRef tmp_src = get_source_node_imm_or_stack(opc, 0, tmp, OPC_ADDR_T, 0);
            LLVMValueRef ptr = LLVMBuildIntToPtr(builder, tmp_src, LLVMPointerType(type, 0), get_next_var_name("source_env_ptr_offset", operand));
            ret = LLVMBuildLoad2(builder, type, ptr, get_next_var_name("source_val", operand));
        }
    } else if (operand.s.slot_type == SUB_SLOT_XMM) {
        if (operand.s.offset) {
            // Vector operations do not have non-zero offset
            assert(tidx <= LLVMInt64);
            assert(llvm_vector_elem_bit_counts[tidx*2] == 1);
            LLVMTypeRef vtype = NULL;
            int elem_idx = 0;
            vtype = llvm_int_types[OPC_FIXED_TO_VECTOR128(tidx)];
            if (operand.s.offset % 8 == 0) {
                elem_idx = operand.s.offset/8;
            } else if (operand.s.offset % 4 == 0) {
                assert(tidx <= LLVMInt32);
                elem_idx = operand.s.offset/4;
            } else if (operand.s.offset % 2 == 0) {
                assert(tidx <= LLVMInt16);
                elem_idx = operand.s.offset/2;
            } else {
                assert(tidx == LLVMInt8);
                elem_idx = operand.s.offset;
            }
            LLVMValueRef vec = LLVMBuildLoad2(builder, vtype, get_stack_alloca(operand), get_next_var_name("source_vec", operand));
            LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], elem_idx, 0);
            ret = LLVMBuildExtractElement(builder, vec, index, get_next_var_name("source_val", operand));
        } else {
            ret = LLVMBuildLoad2(builder, type, get_stack_alloca(operand), get_next_var_name("source_val", operand));
        }
    } else {
        ret = LLVMBuildLoad2(builder, type, get_stack_alloca(operand), get_next_var_name("source_val", operand));
    }
    return ret;
}

void translate_binary(OpCodeType opc, void *ptr, LLVM_BIN_API api) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    uint32_t idx = opcoc[opc];
    operand0 = get_operand(ptr, 0, &is_imm0);
    assert(!is_imm0 && operand0.s.valid);
    operand1 = get_operand(ptr, idx, &is_imm1);
    operand2 = get_operand(ptr, idx + 1, &is_imm2);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, type_in, 0);
    LLVMValueRef out_val = api(builder, src1, src2, get_next_var_name(opcode_type_str[opc], operand0));
    do_store(opc, out_val, type_out, operand0);
}

void translate_binary_splat_immediate(OpCodeType opc, void *ptr, LLVM_BIN_API api) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    uint32_t idx = opcoc[opc];
    operand0 = get_operand(ptr, 0, &is_imm0);
    assert(!is_imm0 && operand0.s.valid);
    operand1 = get_operand(ptr, idx, &is_imm1);
    operand2 = get_operand(ptr, idx + 1, &is_imm2);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, type_in, 1);
    LLVMValueRef out_val = api(builder, src1, src2, get_next_var_name(opcode_type_str[opc], operand0));
    do_store(opc, out_val, type_out, operand0);
}

void translate_add_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();
    if (!operand2.s.valid && !is_imm2) {
        assert(operand1.s.slot_type == SUB_SLOT_XMM ||
               operand1.s.slot_type == SUB_SLOT_ENV);
        register_alias(operand0, operand1);
    } else {
        if (is_imm2 && operand1.s.slot_type == SUB_SLOT_TMP && has_alias(operand1)) {
            OperandType alias = get_alias(operand1);
            alias.s.offset += operand2.i;
            register_alias(operand0, alias);
        } else {
            LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, type_in, 0);
            LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, type_in, 0);
            LLVMValueRef add_val = LLVMBuildAdd(builder, src1, src2, get_next_var_name(opcode_type_str[opc], operand0));
            do_store(opc, add_val, type_out, operand0);
        }
    }
}

void translate_mulxh(OpCodeType opc, void *ptr, LLVM_EXT_API api) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    LLVMTypeRef dtype = (opc == mulsh_i64 || opc == muluh_i64) ? LLVMInt128Type() : LLVMInt64Type();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, 0, operand1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, 0, operand2, type_in, 0);
    src1 = api(builder, src1, dtype, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    src2 = api(builder, src2, dtype, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef out = LLVMBuildMul(builder, src1, src2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef shift = LLVMConstInt(dtype, (opc == mulsh_i64 || opc == muluh_i64) ? 64 : 32, 0);
    out = LLVMBuildLShr(builder, out, shift, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    out = LLVMBuildTrunc(builder, out, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], operand0));
    do_store(opc, out, type_out, operand0);
}

void translate_muls2(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType operand0, operand1, operand2, operand3;
    GET_4_OPERANDS();
    CREATE_MUL(operand0, operand2, operand3);
    CREATE_MULXH(operand1, operand2, operand3, LLVMBuildSExt);
}

void translate_mulu2(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType operand0, operand1, operand2, operand3;
    GET_4_OPERANDS();
    CREATE_MUL(operand0, operand2, operand3);
    CREATE_MULXH(operand1, operand2, operand3, LLVMBuildZExt);
}

void translate_not(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    CREATE_XOR_IMM2(operand0, operand1, -1UL);
}

void translate_andc(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    CREATE_NOT(tmp, operand2);
    CREATE_AND(operand0, operand1, tmp);
}

void translate_nand(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    CREATE_AND(tmp, operand1, operand2);
    CREATE_NOT(operand0, tmp);
}

void translate_eqv(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    CREATE_XOR(tmp, operand1, operand2);
    CREATE_NOT(operand0, tmp);
}

void translate_nor(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    CREATE_OR(tmp, operand1, operand2);
    CREATE_NOT(operand0, tmp);
}

void translate_orc(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    CREATE_NOT(tmp, operand2);
    CREATE_OR(operand0, operand1, tmp);
}

void translate_neg(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, operand1, type_in, 0);
    LLVMValueRef zero = LLVMConstInt(llvm_int_types[type_in], 0, 0);
    LLVMValueRef out = LLVMBuildSub(builder, zero, src, get_next_var_name(opcode_type_str[opc], operand0));
    do_store(opc, out, type_out, operand0);
}

void translate_mov(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();
    assert(!is_imm0 && operand0.s.valid);

    if (!is_imm1 && operand1.s.valid && operand1.s.slot_type == SUB_SLOT_TMP && has_alias(operand1)) {
        assert(operand0.s.slot_type == SUB_SLOT_TMP);
        register_alias(operand0, get_alias(operand1));
    } else {
        LLVMValueRef src = get_source_node_imm_or_stack(opc, is_imm1, operand1, type_in, 0);
        if (type_out < type_in) {
            src = LLVMBuildTrunc(builder, src, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        }
        do_store(opc, src, type_out, operand0);
    }
}

void translate_rotr(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    CREATE_SHR_SLOT(t0, operand1, operand2);
    OperandType constant = get_tmp_and_do_alloc_with_init(type_out, type_out == LLVMInt32 ? 32 : 64);
    CREATE_SUB(t1, constant, operand2);
    CREATE_SHL_SLOT(t1, operand1, t1);
    CREATE_OR(operand0, t0, t1);
}

void translate_rotl(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    CREATE_SHL_SLOT(t0, operand1, operand2);
    OperandType constant = get_tmp_and_do_alloc_with_init(type_out, type_out == LLVMInt32 ? 32 : 64);
    CREATE_SUB(t1, constant, operand2);
    CREATE_SHR_SLOT(t1, operand1, t1);
    CREATE_OR(operand0, t0, t1);
}

void translate_deposit(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType operand0, operand1, operand2, ofs, len;
    GET_3_OPERANDS();
    uint32_t is_imm3, is_imm4;
    ofs = get_operand(ptr, 3, &is_imm3);
    len = get_operand(ptr, 4, &is_imm4);
    assert(is_imm3 && is_imm4);

    OperandType tmp_v = get_tmp_and_do_alloc_with_init(type_out, 1);
    OperandType mask1 = get_tmp_and_do_alloc(type_out);
    CREATE_SHL(mask1, tmp_v, len.i);
    OperandType mask_not_shifted = get_tmp_and_do_alloc(type_out);
    CREATE_SUB(mask_not_shifted, mask1, tmp_v);
    OperandType mask_shifted = get_tmp_and_do_alloc(type_out);
    CREATE_SHL(mask_shifted, mask_not_shifted, ofs.i);
    OperandType rev_mask_shifted = get_tmp_and_do_alloc(type_out);
    CREATE_XOR_IMM2(rev_mask_shifted, mask_shifted, -1UL);
    OperandType part1 = get_tmp_and_do_alloc(type_out);
    CREATE_AND(part1, operand1, rev_mask_shifted);
    OperandType part2_0 = get_tmp_and_do_alloc(type_out);
    CREATE_AND(part2_0, operand2, mask_not_shifted);
    OperandType part2_1 = get_tmp_and_do_alloc(type_out);
    CREATE_SHL(part2_1, part2_0, ofs.i);
    CREATE_OR(operand0, part1, part2_1);
}

void translate_extract(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType operand0, operand1, ofs, len;
    GET_2_OPERANDS();
    uint32_t is_imm2, is_imm3;
    ofs = get_operand(ptr, 2, &is_imm2);
    len = get_operand(ptr, 3, &is_imm3);
    assert(is_imm2 && is_imm3);
    OperandType tmp_v = get_tmp_and_do_alloc_with_init(type_out, 1);
    OperandType mask1 = get_tmp_and_do_alloc(type_out);
    CREATE_SHL(mask1, tmp_v, len.i);
    OperandType mask_not_shifted = get_tmp_and_do_alloc(type_out);
    CREATE_SUB(mask_not_shifted, mask1, tmp_v);
    OperandType arg_shifted = get_tmp_and_do_alloc(type_out);
    CREATE_SHR(arg_shifted, operand1, ofs.i);
    CREATE_AND(operand0, arg_shifted, mask_not_shifted);
}

void translate_sextract(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType operand0, operand1, ofs, len;
    GET_2_OPERANDS();
    uint32_t is_imm2, is_imm3;
    ofs = get_operand(ptr, 2, &is_imm2);
    len = get_operand(ptr, 3, &is_imm3);
    assert(is_imm2 & is_imm3);
    OperandType t0 = get_tmp_and_do_alloc(type_out);

    CREATE_SHL(t0, operand1, ((opc == sextract_i64 ? 64 : 32) - len.i - ofs.i));
    CREATE_SAR(operand0, t0, ((opc == sextract_i64 ? 64 : 32) - len.i));
}

void translate_extract2(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1, operand2, ofs;
    GET_3_OPERANDS();
    uint32_t is_imm;
    ofs = get_operand(ptr, 3, &is_imm);
    assert(is_imm);
    CREATE_SHR(tmp, operand1, ofs.i);
    CREATE_DEPOSIT(operand0, tmp, operand2, ((opc == extract2_i64 ? 64 : 32) - ofs.i), ofs.i);
}

void translate_extrh(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    OperandType input_shifted = get_tmp_and_do_alloc(type_in);
    CREATE_SHR(input_shifted, operand1, 32);
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, input_shifted, type_in, 0);
    src = LLVMBuildTrunc(builder, src, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    do_store(opc, src, type_out, operand0);
}

void translate_bswap16_i32(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType tmp0 = get_tmp_and_do_alloc(type_out);
    OperandType tmp1 = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    CREATE_SHR(tmp0, operand1, 8);
    AttributeType attr = get_attribute(ptr);
    if (attr.attr_type == SUB_ATTR_SWAP && (attr.attr_val & IZ)) {
        CREATE_EXTRACT(tmp0, tmp0, 0, 8);
    }
    if (attr.attr_type == SUB_ATTR_SWAP && (attr.attr_val & OS)) {
        CREATE_SHL(tmp1, operand1, 24);
        CREATE_SAR(tmp1, tmp1, 16);
    } else if (attr.attr_type == SUB_ATTR_SWAP && (attr.attr_val & OZ)) {
        CREATE_EXTRACT(tmp1, operand1, 0, 8);
        CREATE_SHL(tmp1, tmp1, 8);
    } else {
        CREATE_SHL(tmp1, operand1, 8);
    }
    CREATE_OR(operand0, tmp0, tmp1);
}

void translate_bswap16_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType tmp0 = get_tmp_and_do_alloc(type_out);
    OperandType tmp1 = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    CREATE_SHR(tmp0, operand1, 8);
    AttributeType attr = get_attribute(ptr);
    if (attr.attr_type == SUB_ATTR_SWAP && (attr.attr_val & IZ)) {
        CREATE_EXTRACT(tmp0, tmp0, 0, 8);
    }
    if (attr.attr_type == SUB_ATTR_SWAP && (attr.attr_val & OS)) {
        CREATE_SHL(tmp1, operand1, 56);
        CREATE_SAR(tmp1, tmp1, 48);
    } else if (attr.attr_type == SUB_ATTR_SWAP && (attr.attr_val & OZ)) {
        CREATE_EXTRACT(tmp1, operand1, 0, 8);
        CREATE_SHL(tmp1, tmp1, 8);
    } else {
        CREATE_SHL(tmp1, operand1, 8);
    }
    CREATE_OR(operand0, tmp0, tmp1);
}

void translate_bswap32_i32(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType tmp0 = get_tmp_and_do_alloc(type_out);
    OperandType tmp1 = get_tmp_and_do_alloc(type_out);
    OperandType tmp2 = get_tmp_and_do_alloc_with_init(type_out, 0x00ff00ff);
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    CREATE_SHR(tmp0, operand1, 8);
    CREATE_AND(tmp1, operand1, tmp2);
    CREATE_AND(tmp0, tmp0, tmp2);
    CREATE_SHL(tmp1, tmp1, 8);
    CREATE_OR(operand0, tmp0, tmp1);
    CREATE_SHR(tmp0, operand0, 16);
    CREATE_SHL(tmp1, operand0, 16);
    CREATE_OR(operand0, tmp0, tmp1);
}

void translate_bswap32_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType tmp0 = get_tmp_and_do_alloc(type_out);
    OperandType tmp1 = get_tmp_and_do_alloc(type_out);
    OperandType tmp2 = get_tmp_and_do_alloc_with_init(type_out, 0x00ff00ff);
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    CREATE_SHR(tmp0, operand1, 8);
    CREATE_AND(tmp1, operand1, tmp2);
    CREATE_AND(tmp0, tmp0, tmp2);
    CREATE_SHL(tmp1, tmp1, 8);
    CREATE_OR(operand0, tmp0, tmp1);
    CREATE_SHL(tmp1, operand0, 48);
    CREATE_SHR(tmp0, operand0, 16);

    AttributeType attr = get_attribute(ptr);
    if (attr.attr_type == SUB_ATTR_SWAP && (attr.attr_val & OS)) {
        CREATE_SAR(tmp1, tmp1, 32);
    } else {
        CREATE_SHR(tmp1, tmp1, 32);
    }
    CREATE_OR(operand0, tmp0, tmp1);
}

void translate_bswap64_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    CREATE_SHR(t0, operand1, 8);
    OperandType t2 = get_tmp_and_do_alloc_with_init(type_out, 0x00ff00ff00ff00ffUL);
    CREATE_AND(t1, operand1, t2);
    CREATE_AND(t0, t0, t2);
    CREATE_SHL(t1, t1, 8);
    CREATE_OR(operand0, t0, t1);
    t2 = get_tmp_and_do_alloc_with_init(type_out, 0x0000ffff0000ffffUL);
    CREATE_SHR(t0, operand0, 16);
    CREATE_AND(t1, operand0, t2);
    CREATE_AND(t0, t0, t2);
    CREATE_SHL(t1, t1, 16);
    CREATE_OR(operand0, t0, t1);
    CREATE_SHR(t0, operand0, 32);
    CREATE_SHL(t1, operand0, 32);
    CREATE_OR(operand0, t0, t1);
}

void translate_count_zero(OpCodeType opc, void *ptr, const char *intrinsic) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, type_in, 0);

    LLVMValueRef bool1 = LLVMBuildICmp(builder, LLVMIntEQ, src1, LLVMConstInt(llvm_int_types[type_in], 0, 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    LLVMBasicBlockRef bb_ctz_is_zero = LLVMAppendBasicBlock(llvm_func, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMBasicBlockRef bb_ctz_not_zero = LLVMAppendBasicBlock(llvm_func, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMBasicBlockRef bb_ctz_merge = LLVMAppendBasicBlock(llvm_func, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    LLVMBuildCondBr(builder, bool1, bb_ctz_is_zero, bb_ctz_not_zero);
    LLVMPositionBuilderAtEnd(builder, bb_ctz_is_zero);
    LLVMBuildBr(builder, bb_ctz_merge);

    LLVMTypeRef ctz_arg_types[] = {llvm_int_types[type_in], LLVMInt1Type()};
    LLVMTypeRef ctz_type = LLVMFunctionType(llvm_int_types[type_out], ctz_arg_types, 2, 0);
    LLVMValueRef ctz_func = LLVMGetNamedFunction(module, intrinsic);
    if (!ctz_func) {
        ctz_func = LLVMAddFunction(module, intrinsic, ctz_type);
    }
    LLVMSetFunctionCallConv(ctz_func, LLVMCCallConv);

    LLVMPositionBuilderAtEnd(builder, bb_ctz_not_zero);
    LLVMValueRef false_val = LLVMConstInt(LLVMInt1Type(), 0, 0);
    LLVMValueRef call_args[] = {src1, false_val};
    LLVMValueRef call_result = LLVMBuildCall2(builder, ctz_type, ctz_func, call_args, 2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMBuildBr(builder, bb_ctz_merge);

    LLVMPositionBuilderAtEnd(builder, bb_ctz_merge);
    last_active_bb = bb_ctz_merge;
    LLVMValueRef phi = LLVMBuildPhi(builder, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef phi_incoming_values[] = {src2, call_result};
    LLVMBasicBlockRef phi_incoming_blocks[] = {bb_ctz_is_zero, bb_ctz_not_zero};
    LLVMAddIncoming(phi, phi_incoming_values, phi_incoming_blocks, 2);
    do_store(opc, phi, type_out, operand0);
}

void translate_ctpop(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, 0, operand1, type_in, 0);
    LLVMTypeRef intrinsic_types[] = {llvm_int_types[type_in]};
    LLVMTypeRef intrinsic_func_type = LLVMFunctionType(llvm_int_types[type_out], intrinsic_types, 1, 0);
    char intrinsic_func_name[128] = {0};
    sprintf(intrinsic_func_name, "llvm.ctpop.v%di%d", llvm_vector_elem_bit_counts[type_in*2], llvm_vector_elem_bit_counts[type_in*2+1]);
    assert(strlen(intrinsic_func_name) < sizeof(intrinsic_func_name));
    LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, intrinsic_func_name);
    if (!intrinsic_func) {
        intrinsic_func = LLVMAddFunction(module, intrinsic_func_name, intrinsic_func_type);
    }
    LLVMValueRef intrinsic_call_args[] = {src1};
    LLVMValueRef ret = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 1, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    do_store(opc, ret, type_out, operand0);
}

void translate_ext(OpCodeType opc, void *ptr, LLVM_EXT_API api) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();

    LLVMValueRef src = get_source_node_imm_or_stack(opc, is_imm1, operand1, type_in, 0);
    src = api(builder, src, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], operand0));
    do_store(opc, src, type_out, operand0);
}

void translate_movcond(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1, is_imm2, is_imm3, is_imm4;
    OperandType operand0, operand1, operand2, operand3, operand4;
    GET_3_OPERANDS_NOCHECK();
    operand3 = get_operand(ptr, 3, &is_imm3);
    operand4 = get_operand(ptr, 4, &is_imm4);

    LLVMValueRef c1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, type_in, 0);
    LLVMValueRef c2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, type_in, 0);
    LLVMValueRef v1 = get_source_node_imm_or_stack(opc, is_imm3, operand3, type_in, 0);
    LLVMValueRef v2 = get_source_node_imm_or_stack(opc, is_imm4, operand4, type_in, 0);

    RelopType r = get_relop(ptr);
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        c1 = LLVMBuildAnd(builder, c1, c2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        c2 = LLVMConstInt(llvm_int_types[type_in], 0, 0);
    }
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], c1, c2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    LLVMValueRef result = LLVMBuildSelect(builder, bool_val, v1, v2, get_next_var_name(opcode_type_str[opc], operand0));
    do_store(opc, result, type_out, operand0);
}

void translate_negsetcond(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef arg1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, type_in, 0);
    LLVMValueRef arg2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, type_in, 0);

    RelopType r = get_relop(ptr);
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], arg1, arg2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    LLVMValueRef result = LLVMBuildSExt(builder, bool_val, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef neg_one = LLVMConstInt(llvm_int_types[type_in], -1UL, 0);
    result = LLVMBuildXor(builder, result, neg_one, get_next_var_name(opcode_type_str[opc], operand0));
    do_store(opc, result, type_out, operand0);
}

void translate_setcond(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef c1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, type_in, 0);
    LLVMValueRef c2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, type_in, 0);

    RelopType r = get_relop(ptr);
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        c1 = LLVMBuildAnd(builder, c1, c2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        c2 = LLVMConstInt(llvm_int_types[type_in], 0, 0);
    }
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], c1, c2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef result = LLVMBuildZExt(builder, bool_val, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], operand0));
    do_store(opc, result, type_out, operand0);
}

void translate_brcond_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();
    LLVMValueRef c1 = get_source_node_imm_or_stack(opc, is_imm0, operand0, type_in, 0);
    LLVMValueRef c2 = get_source_node_imm_or_stack(opc, is_imm1, operand1, type_in, 0);

    RelopType r = get_relop(ptr);
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        c1 = LLVMBuildAnd(builder, c1, c2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        c2 = LLVMConstInt(llvm_int_types[type_in], 0, 0);
    }
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], c1, c2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    char false_bb_name[16] = {0};
    sprintf(false_bb_name, "bb_false%d", br_cnt);
    LLVMBasicBlockRef bb_false = LLVMAppendBasicBlock(llvm_func, false_bb_name);
    char true_bb_name[16] = {0};
    uint8_t lbl = get_label(ptr);
    sprintf(true_bb_name, "bb_L%d", lbl);
    LLVMBasicBlockRef bb_true = get_bb(true_bb_name);
    if (!bb_true) {
        uint8_t current_active_label_cnt = get_current_active_label_cnt(llvm_func);
        uint8_t *current_active_labels = get_current_active_labels(llvm_func);
        bb_true = LLVMAppendBasicBlock(llvm_func, true_bb_name);
        for (int i = 0; i < current_active_label_cnt; ++i) {
            assert(current_active_labels[i] != lbl);
        }
        current_active_labels[current_active_label_cnt] = lbl;
        current_active_label_cnt += 1;
        set_current_active_label_cnt(current_active_label_cnt);
    }
    LLVMPositionBuilderAtEnd(builder, last_active_bb);
    LLVMBuildCondBr(builder, bool_val, bb_true, bb_false);
    LLVMPositionBuilderAtEnd(builder, bb_false);
    last_active_bb = bb_false;
    br_cnt += 1;
}

void translate_br(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint8_t l = get_label(ptr);
    char lstr[16];
    sprintf(lstr, "bb_L%d", l);
    LLVMBasicBlockRef label = get_bb(lstr);
    if (!label) {
        uint8_t current_active_label_cnt = get_current_active_label_cnt(llvm_func);
        uint8_t *current_active_labels = get_current_active_labels(llvm_func);
        label = LLVMAppendBasicBlock(llvm_func, lstr);
        for (int i = 0; i < current_active_label_cnt; ++i) {
            assert(current_active_labels[i] != l);
        }
        current_active_labels[current_active_label_cnt] = l;
        current_active_label_cnt += 1;
        set_current_active_label_cnt(current_active_label_cnt);
    }
    assert(last_active_bb);
    LLVMBuildBr(builder, label);

    char false_bb_name[16] = {0};
    sprintf(false_bb_name, "bb_false%d", br_cnt);
    LLVMBasicBlockRef bb_false = LLVMAppendBasicBlock(llvm_func, false_bb_name);
    LLVMPositionBuilderAtEnd(builder, bb_false);
    last_active_bb = bb_false;
    br_cnt += 1;
}

void translate_push_ret_addr(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1;
    OperandType operand0, func_hex;
    operand0 = get_operand(ptr, 0, &is_imm0);
    func_hex = get_operand(ptr, 1, &is_imm1);
    assert(is_imm1);

    LLVMValueRef x64_ret_addr = get_source_node_imm_or_stack(opc, is_imm0, operand0, type_in, 0);
    OperandType ptr_val = get_shadow_stack_pointer(opc);
    CREATE_ADD(ptr_val, ptr_val, -8UL);
    LLVMValueRef shadow_val0 = get_source_node_imm_or_stack(opc, 0, ptr_val, OPC_ADDR_T, 0);
    LLVMValueRef shadow_ptr0 = LLVMBuildIntToPtr(builder, shadow_val0, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMBuildStore(builder, x64_ret_addr, shadow_ptr0);

    char func_name[64] = {0};
    sprintf(func_name, "%s%sfunc_%lx", func_name_prefix, func_name_prefix[0] ? "_" : "", func_hex.i);
    assert(strlen(func_name) < sizeof(func_name));
    LLVMValueRef func_addr = LLVMBuildPtrToInt(builder, get_or_add_func_with_qemuaot_cc(func_name, 0, NoInlineAttr), llvm_int_types[OPC_ADDR_T], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    CREATE_ADD(ptr_val, ptr_val, -8UL);
    LLVMValueRef shadow_val1 = get_source_node_imm_or_stack(opc, 0, ptr_val, OPC_ADDR_T, 0);
    LLVMValueRef shadow_ptr1 = LLVMBuildIntToPtr(builder, shadow_val1, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMBuildStore(builder, func_addr, shadow_ptr1);

    set_shadow_stack_pointer(opc, ptr_val);
}

void translate_ret(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm;
    OperandType operand0;
    operand0 = get_operand(ptr, 0, &is_imm);
    assert(!is_imm && operand0.s.valid);
    OperandType loc606 = get_tmp_and_do_alloc(type_out);
    OperandType loc607 = get_tmp_and_do_alloc(type_out);
    OperandType loc608 = get_tmp_and_do_alloc(type_out);
    OperandType loc609 = get_tmp_and_do_alloc(type_out);
    OperandType loc610 = get_tmp_and_do_alloc(type_out);
    OperandType loc611 = get_tmp_and_do_alloc(type_out);
    OperandType shadow_stack = get_shadow_stack_pointer(opc);
    uint8_t new_label = 42;

    CREATE_MOV(loc606, shadow_stack);
    CREATE_ADD(loc607, loc606, 8);
    CREATE_LD(loc608, loc606);
    CREATE_LD(loc609, loc607);
    CREATE_SUB(loc610, operand0, loc609);
    CREATE_ADD(loc611, loc606, 0x10);
    set_shadow_stack_pointer(opc, loc611);
    CREATE_BRCOND(loc610, 0, ne, new_label);

    // The fast path: branch to the next translated qemuaot CC func
    LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT] = {NULL};
    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT] = {NULL};
    int arg_cnt = collect_arguments_and_types(not_a_helper, TARGET_QEMUAOT_FASTPATH, TYPE_AND_VALUE, NULL, NULL, 0, NULL, NULL, llvm_func, call_types, FIXED_VECTOR_PARAM_COUNT, call_args, "FASTPATH_RET");
    LLVMTypeRef func_type = LLVMFunctionType(LLVMVoidType(), call_types, arg_cnt, 0);
    LLVMValueRef ret_target = get_source_node_imm_or_stack(opc, 0, loc608, OPC_ADDR_T, 0);
    LLVMValueRef ret_target_ptr = LLVMBuildIntToPtr(builder, ret_target, LLVMPointerType(func_type, 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef call_inst = LLVMBuildCall2(builder, func_type, ret_target_ptr, call_args, arg_cnt, "");
    LLVMSetTailCall(call_inst, 1);
    LLVMSetInstructionCallConv(call_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);

    CREATE_LABEL(new_label);
}

void translate_ld_ext(OpCodeType opc, void *ptr, LLVM_EXT_API api) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, operand1, type_mem, 0);
    src = api(builder, src, llvm_int_types[type_reg], get_next_var_name(opcode_type_str[opc], operand1));
    do_store(opc, src, type_reg, operand0);
}

void translate_ld_env_xmm(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    OperandType operand0, operand1, operand2;
    GET_2_OPERANDS();
    uint32_t is_imm;
    operand2 = get_operand(ptr, 2, &is_imm);

    if (operand1.s.slot_type == SUB_SLOT_ENV ||
        operand1.s.slot_type == SUB_SLOT_XMM) {
        LLVMValueRef val = get_source_node_imm_or_stack(opc, 0, operand1, type_mem, 0);
        do_store(opc, val, type_reg, operand0);
    } else if (operand1.s.slot_type == SUB_SLOT_TMP) {
        assert(has_alias(operand1) && is_imm);
        OperandType alias = get_alias(operand1);
        assert(alias.s.valid);
        alias.s.offset += operand2.i;
        CREATE_LD_ENV_XMM(opc, operand0, alias);
    } else {
        assert(0);
    }
}

void translate_ld_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, operand1, type_in, 0);
    do_store(opc, src, type_out, operand0);
}

void translate_qemu_ld2_i128(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    (void)a0;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size == SRC16B);

    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, operand2, OPC_ADDR_T, 0);
    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[type_mem], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef result = LLVMBuildLoad2(builder, llvm_int_types[type_mem], pointer, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    if (a1.p.storage.attr.alignment == UNALIGN) {
        LLVMSetAlignment(result, 1);
    } else if (a1.p.storage.attr.alignment == ALIGN_16) {
        LLVMSetAlignment(result, 16);
    } else if (a1.p.storage.attr.alignment == ALIGN_32) {
        LLVMSetAlignment(result, 32);
    } else if (a1.p.storage.attr.alignment == ALIGN_MEM_SIZE) {
        LLVMSetAlignment(result, llvm_vector_elem_bit_counts[type_mem*2+1]/8);
    }
    do_store(opc, result, type_reg, operand0);
    OperandType high_addr = get_tmp_and_do_alloc(OPC_ADDR_T);
    CREATE_ADD(high_addr, operand2, 8UL);
    addr = get_source_node_imm_or_stack(opc, 0, high_addr, OPC_ADDR_T, 0);
    pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[type_mem], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    result = LLVMBuildLoad2(builder, llvm_int_types[type_mem], pointer, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    if (a1.p.storage.attr.alignment == UNALIGN) {
        LLVMSetAlignment(result, 1);
    } else if (a1.p.storage.attr.alignment == ALIGN_16) {
        LLVMSetAlignment(result, 16);
    } else if (a1.p.storage.attr.alignment == ALIGN_32) {
        LLVMSetAlignment(result, 32);
    } else if (a1.p.storage.attr.alignment == ALIGN_MEM_SIZE) {
        LLVMSetAlignment(result, llvm_vector_elem_bit_counts[type_mem*2+1]/8);
    }
    do_store(opc, result, type_reg, operand1);
}

void translate_qemu_ld(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    (void)a0;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size <= SRC8B);
    type_mem = (a2.p.storage.size - SRC1B) + LLVMInt8;
    assert(type_mem <= type_reg);

    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, operand1, OPC_ADDR_T, 0);
    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[type_mem], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef result = LLVMBuildLoad2(builder, llvm_int_types[type_mem], pointer, get_next_var_name(opcode_type_str[opc], operand0));
    if (a1.p.storage.attr.alignment == UNALIGN) {
        LLVMSetAlignment(result, 1);
    } else if (a1.p.storage.attr.alignment == ALIGN_16) {
        LLVMSetAlignment(result, 16);
    } else if (a1.p.storage.attr.alignment == ALIGN_32) {
        LLVMSetAlignment(result, 32);
    } else if (a1.p.storage.attr.alignment == ALIGN_MEM_SIZE) {
        LLVMSetAlignment(result, llvm_vector_elem_bit_counts[type_mem*2+1]/8);
    }
    if (type_mem < type_reg) {
        if (a2.p.storage.attr.ext == ZERO) {
            result = LLVMBuildZExt(builder, result, llvm_int_types[type_reg], get_next_var_name(opcode_type_str[opc], operand0));
        } else {
            result = LLVMBuildSExt(builder, result, llvm_int_types[type_reg], get_next_var_name(opcode_type_str[opc], operand0));
        }
    }
    do_store(opc, result, type_reg, operand0);
}

void translate_st(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();
    assert(!is_imm1 && operand1.s.valid);

    LLVMValueRef val = get_source_node_imm_or_stack(opc, is_imm0, operand0, type_reg, 0);
    if (type_mem < type_reg) {
        val = LLVMBuildTrunc(builder, val, llvm_int_types[type_mem], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    }
    LLVMValueRef addr_val = NULL;
    if ((operand1.s.slot_type == SUB_SLOT_TMP && has_alias_xmm(operand1)) || operand1.s.slot_type == SUB_SLOT_XMM) {
        OperandType alias = operand1;
        if (operand1.s.slot_type == SUB_SLOT_TMP) {
            alias = get_alias(operand1);
        }
        uint32_t is_imm;
        OperandType offset = get_operand(ptr, 2, &is_imm);
        if (is_imm) {
            alias.s.offset += offset.i;
        }
        assert((alias.s.offset * 8) % llvm_vector_elem_bit_counts[type_mem*2+1] == 0);
        OperandType out = alias;
        out.s.offset = 0;
        LLVMValueRef src_val = get_source_node_imm_or_stack(opc, 0, out, OPC_FIXED_TO_VECTOR128(type_mem), 0);
        LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], (alias.s.offset * 8) / llvm_vector_elem_bit_counts[type_mem*2+1], 0);
        val = LLVMBuildInsertElement(builder, src_val, val, index, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        do_store(opc, val, OPC_FIXED_TO_VECTOR128(type_mem), out);
    } else {
        if (operand1.s.slot_type == SUB_SLOT_TMP && has_alias(operand1)) {
            operand1 = get_alias(operand1);
        }
        LLVMValueRef env_raw = get_env_ptr_raw();
        LLVMValueRef off = NULL;
        if (operand1.s.slot_type == SUB_SLOT_ENV) {
            off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], operand1.s.offset, 0);
        } else {
            assert(0);
        }
        addr_val = LLVMBuildAdd(builder, env_raw, off, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        check_scalable_vector_perform_store(val, type_mem, addr_val);
    }
}

void translate_st_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, operand0, type_in, 0);
    do_store(opc, src, type_out, operand1);
}

void translate_qemu_st2_i128(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    (void)a0;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size == SRC16B);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, 0, operand0, type_reg, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, 0, operand1, type_reg, 0);
    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, operand2, OPC_ADDR_T, 0);
    LLVMValueRef result = check_scalable_vector_perform_store(src1, type_mem, addr);
    if (a1.p.storage.attr.alignment == UNALIGN) {
        LLVMSetAlignment(result, 1);
    } else if (a1.p.storage.attr.alignment == ALIGN_16) {
        LLVMSetAlignment(result, 16);
    } else if (a1.p.storage.attr.alignment == ALIGN_32) {
        LLVMSetAlignment(result, 32);
    } else if (a1.p.storage.attr.alignment == ALIGN_MEM_SIZE) {
        LLVMSetAlignment(result, llvm_vector_elem_bit_counts[type_mem*2+1]/8);
    }
    OperandType high_addr = get_tmp_and_do_alloc(OPC_ADDR_T);
    CREATE_ADD(high_addr, operand2, 8UL);
    addr = get_source_node_imm_or_stack(opc, 0, high_addr, OPC_ADDR_T, 0);
    result = check_scalable_vector_perform_store(src2, type_mem, addr);
    if (a1.p.storage.attr.alignment == UNALIGN) {
        LLVMSetAlignment(result, 1);
    } else if (a1.p.storage.attr.alignment == ALIGN_16) {
        LLVMSetAlignment(result, 16);
    } else if (a1.p.storage.attr.alignment == ALIGN_32) {
        LLVMSetAlignment(result, 32);
    } else if (a1.p.storage.attr.alignment == ALIGN_MEM_SIZE) {
        LLVMSetAlignment(result, llvm_vector_elem_bit_counts[type_mem*2+1]/8);
    }
}

void translate_qemu_st(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    (void)a0;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size <= SRC8B);
    type_mem = (a2.p.storage.size - SRC1B) + LLVMInt8;
    assert(type_mem <= type_reg);

    LLVMValueRef val = get_source_node_imm_or_stack(opc, 0, operand0, type_reg, 0);
    if (type_mem < type_reg) {
        val = LLVMBuildTrunc(builder, val, llvm_int_types[type_mem], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    }
    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, operand1, OPC_ADDR_T, 0);
    LLVMValueRef result = check_scalable_vector_perform_store(val, type_mem, addr);
    if (a1.p.storage.attr.alignment == UNALIGN) {
        LLVMSetAlignment(result, 1);
    } else if (a1.p.storage.attr.alignment == ALIGN_16) {
        LLVMSetAlignment(result, 16);
    } else if (a1.p.storage.attr.alignment == ALIGN_32) {
        LLVMSetAlignment(result, 32);
    } else if (a1.p.storage.attr.alignment == ALIGN_MEM_SIZE) {
        LLVMSetAlignment(result, llvm_vector_elem_bit_counts[type_mem*2+1]/8);
    }
}

// Vector
void translate_abs_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, 0, operand1, type_in, 0);
    LLVMTypeRef intrinsic_types[] = {llvm_int_types[type_in], LLVMInt1Type()};
    LLVMTypeRef intrinsic_func_type = LLVMFunctionType(llvm_int_types[type_out], intrinsic_types, 2, 0);
    char intrinsic_func_name[128] = {0};
#if defined(__riscv) && __riscv_xlen == 64 || defined(BUILD_RISCV_ON_AARCH)
    sprintf(intrinsic_func_name, "llvm.abs.nxv%di%d", llvm_vector_elem_bit_counts[type_in*2]/2, llvm_vector_elem_bit_counts[type_in*2+1]);
#else
    sprintf(intrinsic_func_name, "llvm.abs.v%di%d", llvm_vector_elem_bit_counts[type_in*2], llvm_vector_elem_bit_counts[type_in*2+1]);
#endif
    assert(strlen(intrinsic_func_name) < sizeof(intrinsic_func_name));
    LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, intrinsic_func_name);
    if (!intrinsic_func) {
        intrinsic_func = LLVMAddFunction(module, intrinsic_func_name, intrinsic_func_type);
    }
    LLVMValueRef is_int_min_poison = LLVMConstInt(LLVMInt1Type(), 0, 0);
    LLVMValueRef intrinsic_call_args[] = {src1, is_int_min_poison};
    LLVMValueRef ret = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    do_store(opc, ret, type_out, operand0);
}

void translate_binary_intrinsic(OpCodeType opc, void *ptr, const char *intrinsic_prefix) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, 0, operand1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, 0, operand2, type_in, 0);
    LLVMTypeRef intrinsic_types[] = {llvm_int_types[type_in], llvm_int_types[type_in]};
    LLVMTypeRef intrinsic_func_type = LLVMFunctionType(llvm_int_types[type_out], intrinsic_types, 2, 0);
    char intrinsic_func_name[128] = {0};
#if defined(__riscv) && __riscv_xlen == 64 || defined(BUILD_RISCV_ON_AARCH)
    sprintf(intrinsic_func_name, "%s.nxv%di%d", intrinsic_prefix, llvm_vector_elem_bit_counts[type_in*2]/2, llvm_vector_elem_bit_counts[type_in*2+1]);
#else
    sprintf(intrinsic_func_name, "%s.v%di%d", intrinsic_prefix, llvm_vector_elem_bit_counts[type_in*2], llvm_vector_elem_bit_counts[type_in*2+1]);
#endif
    assert(strlen(intrinsic_func_name) < sizeof(intrinsic_func_name));
    LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, intrinsic_func_name);
    if (!intrinsic_func) {
        intrinsic_func = LLVMAddFunction(module, intrinsic_func_name, intrinsic_func_type);
    }
    LLVMValueRef intrinsic_call_args[] = {src1, src2};
    LLVMValueRef ret = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    do_store(opc, ret, type_out, operand0);
}

void translate_bitsel_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType operand0, operand1, operand2, operand3;
    GET_4_OPERANDS();
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    CREATE_AND(tmp, operand1, operand2);
    CREATE_ANDC_VEC(operand0, operand2, operand1);
    CREATE_OR(operand0, operand0, tmp);
}

void translate_cmpsel_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType operand0, operand1, operand2, operand3, operand4;
    GET_5_OPERANDS();
    RelopType r = get_relop(ptr);
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    CREATE_CMP_VEC(tmp, operand1, operand2, r);
    CREATE_BITSEL_VEC(operand0, tmp, operand3, operand4);
}

void translate_cmp_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, type_in, 0);

    RelopType r = get_relop(ptr);
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_vec = LLVMBuildICmp(builder, llvm_predicate[r], src1, src2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    OperandType ones, zeros;
    ones.i = 0xffffffffffffffffUL;
    zeros.i = 0;

    LLVMValueRef vec_true = get_source_node_imm_or_stack(opc, 1, ones, type_in, 0);
    LLVMValueRef vec_false = get_source_node_imm_or_stack(opc, 1, zeros, type_in, 0);

    LLVMValueRef result = LLVMBuildSelect(builder, bool_vec, vec_true, vec_false, get_next_var_name(opcode_type_str[opc], operand0));
    do_store(opc, result, type_out, operand0);
}

void translate_dupm_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType operand0, operand1;
    GET_2_OPERANDS();
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, operand1, type_in, 0);
    LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
    LLVMValueRef elem = LLVMBuildExtractElement(builder, src, index, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    uint8_t full_cnt = llvm_vector_elem_bit_counts[type_in*2];
    LLVMValueRef constants[16];
    LLVMValueRef element_value = LLVMConstInt(llvm_int_types[OPC_VECTOR_TO_FIXED(type_in)], 0, 0);
    for (int i = 0; i < full_cnt; i++) {
        constants[i] = element_value;
    }
    LLVMValueRef result = LLVMConstVector(constants, full_cnt);
    for (int i = 0; i < full_cnt; i++) {
        index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], i, 0);
        result = LLVMBuildInsertElement(builder, result, elem, index, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    }
    do_store(opc, result, type_out, operand0);
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, operand1, type_in, 0);
    LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
    LLVMValueRef first_element = LLVMBuildExtractElement(builder, src, index, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef single_element_vector = LLVMBuildInsertElement(builder, LLVMGetUndef(llvm_int_types[type_in]), first_element, index, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef zero_mask = LLVMGetUndef(llvm_int_types[type_in]);
    LLVMValueRef splat_vector = LLVMBuildShuffleVector(builder, single_element_vector, LLVMGetUndef(llvm_int_types[type_in]), zero_mask, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    do_store(opc, splat_vector, type_out, operand0);
#endif
}

void translate_rotl_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    OperandType t2 = get_tmp_and_do_alloc(OPC_VECTOR_TO_FIXED(type_out));
    OperandType operand0, operand1, operand2, operand_shift;
    GET_2_OPERANDS();
    uint32_t is_imm2;
    operand2 = get_operand(ptr, 2, &is_imm2);
    if (is_imm2) {
        operand_shift = get_tmp_and_do_alloc_with_init(OPC_VECTOR_TO_FIXED(type_in), operand2.i);
    } else {
        LLVMValueRef tmp_src = get_source_node_imm_or_stack(opc, 0, operand2, LLVMInt32/*ref:void tcg_gen_rotls_vec(unsigned vece, TCGv_vec r, TCGv_vec a, TCGv_i32 s);*/, 0);
        do_store(opc, tmp_src, OPC_VECTOR_TO_FIXED(type_out), operand_shift);
    }

    CREATE_SHL_VEC(t0, operand1, operand_shift, 1/*DO_SPLAT*/);
    OperandType constant = get_tmp_and_do_alloc_with_init(OPC_VECTOR_TO_FIXED(type_in), llvm_vector_elem_bit_counts[type_in*2+1]);
    CREATE_SUB(t2, constant, operand_shift);
    CREATE_SHR_VEC(t1, operand1, t2, 1/*DO_SPLAT*/);
    CREATE_OR(operand0, t0, t1);
}

void translate_rotlv_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    OperandType t2 = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    CREATE_SHL_VEC(t0, operand1, operand2, 0/*NO_SPLAT*/);
    OperandType constant_val;
    constant_val.i = llvm_vector_elem_bit_counts[type_in*2+1];
    LLVMValueRef constant_splat_val = get_source_node_imm_or_stack(opc, 1, constant_val, type_in, 1);
    OperandType constant_splat;
    do_store(opc, constant_splat_val, type_in, constant_splat);
    CREATE_SUB(t2, constant_splat, operand2);
    CREATE_SHR_VEC(t1, operand1, t2, 0/*NO_SPLAT*/);
    CREATE_OR(operand0, t0, t1);
}

void translate_rotrv_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    OperandType t2 = get_tmp_and_do_alloc(type_out);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    CREATE_SHR_VEC(t0, operand1, operand2, 0/*NO_SPLAT*/);
    OperandType constant_val;
    constant_val.i = llvm_vector_elem_bit_counts[type_in*2+1];
    LLVMValueRef constant_splat_val = get_source_node_imm_or_stack(opc, 1, constant_val, type_in, 1);
    OperandType constant_splat;
    do_store(opc, constant_splat_val, type_in, constant_splat);
    CREATE_SUB(t2, constant_splat, operand2);
    CREATE_SHL_VEC(t1, operand1, t2, 0/*NO_SPLAT*/);
    CREATE_OR(operand0, t0, t1);
}

void translate_maxmin_vec(OpCodeType opc, void *ptr, RelopType r) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    AttrSrcInfo vs;
    vs.p.vs = OPC_VECTOR_SIZE(type_out);
    AttrSrcInfo ves;
    ves.p.ves = OPC_VECTOR_TO_FIXED(type_out);
    OperandType tmp1 = get_tmp_and_do_alloc(type_out);
    OperandType tmp2 = get_tmp_and_do_alloc(type_out);

    CREATE_MOV_VEC(vs, ves, tmp1, operand1);
    CREATE_MOV_VEC(vs, ves, tmp2, operand2);
    CREATE_MOVCOND_VEC(vs, ves, operand0, operand1, operand2, tmp1, tmp2, r);
}

static uint8_t *get_current_active_labels(LLVMValueRef func) {
    active_label_info_t *info = g_hash_table_lookup(current_active_label_info, func);
    assert(info);
    while (info) {
        if (info->llvm_func == func) {
            return info->current_active_labels;
        }
        info = info->next;
    }
    assert(0);
    return NULL;
}

static uint8_t get_current_active_label_cnt(LLVMValueRef func) {
    active_label_info_t *info = g_hash_table_lookup(current_active_label_info, func);
    assert(info);
    while (info) {
        if (info->llvm_func == func) {
            return info->current_active_label_cnt;
        }
        info = info->next;
    }
    assert(0);
    return 0;
}

static void set_current_active_label_cnt(uint8_t current_active_label_cnt) {
    active_label_info_t *info = g_hash_table_lookup(current_active_label_info, llvm_func);
    assert(info);
    while (info) {
        if (info->llvm_func == llvm_func) {
            info->current_active_label_cnt = current_active_label_cnt;
        }
        info = info->next;
    }
}

static void register_idx_for_call_helper(void *ptr, uint8_t call_idx) {
#ifdef DEBUG
    printf("%s %lx call%d\n", __FUNCTION__, ptr, call_idx); fflush(NULL);
#endif
    helper_aux_info_t *call_info = (helper_aux_info_t *)calloc(1, sizeof(helper_aux_info_t));
    call_info->ptr = ptr;
    call_info->idx = call_idx;
    helper_aux_info_t *info = g_hash_table_lookup(current_helper_aux_info, ptr);
    if (!info) {
        g_hash_table_insert(current_helper_aux_info, ptr, call_info);
    } else {
        while (info->next) {
            assert(info->ptr != ptr);
            info = info->next;
        }
        assert(info->ptr != ptr);
        info->next = call_info;
    }
}

static uint8_t get_idx_for_call_helper(void *ptr) {
    helper_aux_info_t *info = g_hash_table_lookup(current_helper_aux_info, ptr);
    while (info) {
        if (info->ptr == ptr) {
            return info->idx;
        }
        info = info->next;
    }
    return current_call_idx++;
}

void translate_set_label(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint8_t l = get_label(ptr);
    char lstr[16];
    sprintf(lstr, "bb_L%d", l);
    LLVMBasicBlockRef label = get_bb(lstr);
    if (!label) {
        label = LLVMAppendBasicBlock(llvm_func, lstr);
    }
    assert(last_active_bb);
    LLVMValueRef instr = LLVMGetLastInstruction(last_active_bb);
    if (instr) {
        LLVMOpcode opc_llvm = LLVMGetInstructionOpcode(instr);
        if (opc_llvm != LLVMRet && opc_llvm != LLVMBr) {
            LLVMBuildBr(builder, label);
        }
    } else {
        LLVMBuildBr(builder, label);
    }
    LLVMPositionBuilderAtEnd(builder, label);
    last_active_bb = label;

    int do_move = 0;
    uint8_t current_active_label_cnt = get_current_active_label_cnt(llvm_func);
    uint8_t *current_active_labels = get_current_active_labels(llvm_func);
    for (int i = 0; i < current_active_label_cnt; ++i) {
        if (do_move) {
            current_active_labels[i-1] = current_active_labels[i];
        }
        if (current_active_labels[i] == l) {
            do_move = 1;
        }
    }
    if (do_move) {
        current_active_label_cnt -= 1;
        set_current_active_label_cnt(current_active_label_cnt);
    }
}

void translate_jmp_direct(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm;
    OperandType delta;
    delta = get_operand(ptr, 0, &is_imm);
    assert(is_imm);

    char func_name[64] = {0};
    sprintf(func_name, "%s%sfunc_%lx", func_name_prefix, func_name_prefix[0] ? "_" : "", (current_func_offset + delta.i));
    LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT] = {NULL};
    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT] = {NULL};
    int arg_cnt = collect_arguments_and_types(not_a_helper, TARGET_QEMUAOT_FASTPATH, TYPE_AND_VALUE, NULL, NULL, 0, NULL, NULL, llvm_func, call_types, FIXED_VECTOR_PARAM_COUNT, call_args, func_name);
    LLVMTypeRef ret_type = LLVMVoidType();
    LLVMTypeRef func_type = LLVMFunctionType(ret_type, call_types, arg_cnt, 0);
    LLVMValueRef call_inst = LLVMBuildCall2(builder, func_type, get_or_add_func_with_qemuaot_cc(func_name, 0, NoInlineAttr), call_args, arg_cnt, "");
    LLVMSetTailCall(call_inst, 1);
    LLVMSetInstructionCallConv(call_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);
}

void translate_discard(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm;
    OperandType operand0 = get_operand(ptr, 0, &is_imm);
    assert(!is_imm && operand0.s.valid);
    if (operand0.s.slot_type == SUB_SLOT_XREG) {
        LLVMBuildStore(builder, LLVMGetPoison(llvm_int_types[func_xreg_llvmtype[operand0.s.slot_idx]]), func_xreg_alloca[operand0.s.slot_idx]);
    }
}

static LLVMValueRef get_trampoline(LLVMValueRef helper_func, uint8_t do_return, uint8_t with_ret, OperandType *operands, uint32_t *is_imm, uint8_t operands_cnt, LLVMValueRef next_func, int spill_cnt, XMMRegType *spilled_xmm_regs, int fix_second_half_addr, int target_domain) {
    char trampoline_name[4096] = {0};
    sprintf(trampoline_name, "trampoline%s_r%d_param%d", do_return ? "" : "_noreturn", with_ret, operands_cnt);
    int env_cnt = 0;
    for (int i = 0; i < operands_cnt; ++i) {
        if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) {
            char env_part[32] = {0};
            sprintf(env_part, "_env%d", i);
            strcat(trampoline_name, env_part);
            env_cnt += 1;
        }
    }
    char name_tail[128] = {0};
    sprintf(name_tail, "_spill%d_%s", spill_cnt, LLVMGetValueName(helper_func));
    strcat(trampoline_name, name_tail);
    if (fix_second_half_addr) {
        sprintf(name_tail, "_sec_%s", LLVMGetValueName(next_func));
        strcat(trampoline_name, name_tail);
    }
    assert(strlen(trampoline_name) < sizeof(trampoline_name));
    LLVMValueRef trampoline = LLVMGetNamedFunction(module, trampoline_name);
    if (trampoline) {
        return trampoline;
    }
    LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS] = {NULL};
    int call_arg_cnt = collect_arguments_and_types(not_a_helper, target_domain, TYPE_ONLY, operands, is_imm, operands_cnt, (do_return && !fix_second_half_addr) ? (LLVMValueRef)1 : NULL, NULL, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS), NULL, trampoline_name);
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS));

    trampoline = LLVMAddFunction(module, trampoline_name,
        LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnt, 0));
    LLVMAddAttributeAtIndex(trampoline, -1, NoInlineAttr);
    LLVMAddAttributeAtIndex(trampoline, -1, target_features_attr);
    LLVMSetLinkage(trampoline, LLVMWeakAnyLinkage);
    int j = 0;
    LLVMValueRef param = NULL;
    for (j = 0; j < FIXED_VECTOR_PARAM_COUNT; j++) {
        param = LLVMGetParam(trampoline, j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }
    for (j = FIXED_VECTOR_PARAM_COUNT; j < (FIXED_VECTOR_PARAM_COUNT + operands_cnt - env_cnt); j++) {
        param = LLVMGetParam(trampoline, j);
        char var[16] = {0};
        sprintf(var, "param%d", (j - FIXED_VECTOR_PARAM_COUNT));
        LLVMSetValueName(param, var);
    }
    if (do_return && !fix_second_half_addr) {
        param = LLVMGetParam(trampoline, j);
        LLVMSetValueName(param, "next");
    }
    LLVMSetFunctionCallConv(trampoline, QEMUAOT_CC);

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(trampoline, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);

    // Store all fixed to ENV
    LLVMValueRef env_raw = get_env_ptr_raw();
    for (int i = 0; i < FIXED_PARAM_COUNT; ++i) {
        LLVMValueRef fixed_val = LLVMGetParam(trampoline, i);
        uint64_t env_xreg_offset = xreg_offsets[i];
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xreg_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("spill_fixed_addr", dummy_slot_for_debug));
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[fixed_vector_param_llvmtypes[i]], 0), get_next_var_name("spill_fixed_ptr", dummy_slot_for_debug));
        LLVMBuildStore(builder, fixed_val, ptr);
    }

    // Store all vectors to ENV
    for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        LLVMValueRef vec_val = LLVMGetParam(trampoline, i);
        if (spill_cnt) {
            for (int j = 0; j < spill_cnt; ++j) {
                if (spilled_xmm_regs[j] == (XMMRegType)i) {
                    vec_val = reload_vector(spilled_xmm_regs[j]);
                    break;
                }
            }
        }
        uint64_t xmm_offset = get_xmm_offset((i - FIXED_PARAM_COUNT)/2) + 16 * ((i - FIXED_PARAM_COUNT) % 2);
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("spill_vec_addr", dummy_slot_for_debug));
        check_scalable_vector_perform_store(vec_val, LLVMVector2xi64, addr);
    }

    LLVMValueRef call_args[MAX_OPERANDS_COUNT] = {NULL};
    call_arg_cnt = collect_arguments_and_types(not_a_helper, target_domain == TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_WO_VECTOR ? TARGET_DEFAULT_HELPER_CONSTRUCT_VECTOR : TARGET_DEFAULT_HELPER_PASSTHROUGH_VECTOR, VALUE_ONLY, operands, is_imm, operands_cnt, NULL, NULL, trampoline, NULL, 0, call_args, trampoline_name);
    LLVMTypeRef helper_type = LLVMGlobalGetValueType(helper_func);
    LLVMValueRef env_alloca = NULL;
    if (do_return) {
        env_alloca = LLVMBuildAlloca(builder, llvm_int_types[OPC_ADDR_T], "env_alloca");
        LLVMSetAlignment(env_alloca, 8);
        LLVMBuildStore(builder, env_raw, env_alloca);
    }
#ifdef DEBUG
    printf("BuildCall2:%s\n", LLVMGetValueName(helper_func)); fflush(NULL);
#endif
    // Get the helper call target from argument, since I would like to reuse trampoline for different helper targets
    LLVMValueRef call_helper_inst = LLVMBuildCall2(builder, helper_type, helper_func, call_args, call_arg_cnt, with_ret ? get_next_var_name("helper_return", dummy_slot_for_debug) : "");
    if (!do_return) {
        LLVMSetTailCall(call_helper_inst, 1);
        LLVMBuildRetVoid(builder);

        assert(last_active_bb);
        LLVMPositionBuilderAtEnd(builder, last_active_bb);
        return trampoline;
    } else {
        env_raw = LLVMBuildLoad2(builder, llvm_int_types[OPC_ADDR_T], env_alloca, get_next_var_name("env_ptr", dummy_slot_for_debug));
        set_env_ptr_raw(env_raw);
    }

    // Load all fixed from ENV
    LLVMValueRef return_args[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    if (with_ret) {
        return_args[FIXED_VECTOR_PARAM_COUNT] = call_helper_inst;
    }
    for (int i = 0; i < FIXED_PARAM_COUNT; ++i) {
        uint64_t env_xreg_offset = xreg_offsets[i];
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xreg_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("reload_fixed_addr", dummy_slot_for_debug));
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[fixed_vector_param_llvmtypes[i]], 0), get_next_var_name("reload_fixed_ptr", dummy_slot_for_debug));
        return_args[i] = LLVMBuildLoad2(builder, llvm_int_types[fixed_vector_param_llvmtypes[i]], ptr, get_next_var_name("reload_fixed_val", dummy_slot_for_debug));
    }

    // Load all vectors from ENV
    for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        uint64_t env_xmm_offset = get_xmm_offset((i - FIXED_PARAM_COUNT)/2) + 16 * ((i - FIXED_PARAM_COUNT) % 2);
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xmm_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("reload_vec_addr", dummy_slot_for_debug));
        return_args[i] = check_scalable_vector_perform_load(LLVMVector2xi64, addr);
    }

    LLVMTypeRef next_type = LLVMGlobalGetValueType(next_func);
    LLVMValueRef call_next_inst;
    if (!fix_second_half_addr) {
        int next_addr_param_idx = (FIXED_VECTOR_PARAM_COUNT + (operands_cnt - env_cnt));
        if (target_domain == TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_WO_VECTOR) {
            for (int k = 0; k < operands_cnt; ++k) {
                if (is_imm[k] == 0 && operands[k].s.valid && ((operands[k].s.slot_type == SUB_SLOT_TMP && has_alias_xmm(operands[k])) || operands[k].s.slot_type == SUB_SLOT_XMM)) {
                    next_addr_param_idx -= 1;
                }
            }
        }
        assert(next_addr_param_idx < LLVMCountParams(trampoline));
        LLVMValueRef next_addr = LLVMGetParam(trampoline, next_addr_param_idx);
        LLVMValueRef the_next = LLVMBuildIntToPtr(builder, next_addr, LLVMPointerType(next_type, 0), get_next_var_name("next", dummy_slot_for_debug));
#ifdef DEBUG
        printf("BuildCall2:%s\n", LLVMGetValueName(next_func)); fflush(NULL);
#endif
        call_next_inst = LLVMBuildCall2(builder, next_type, the_next, return_args, (FIXED_VECTOR_PARAM_COUNT + (with_ret ? 1 : 0)), "");
    } else {
        call_next_inst = LLVMBuildCall2(builder, next_type, next_func, return_args, (FIXED_VECTOR_PARAM_COUNT + (with_ret ? 1 : 0)), "");
    }
    LLVMSetTailCall(call_next_inst, 1);
    LLVMSetInstructionCallConv(call_next_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);

    assert(last_active_bb);
    LLVMPositionBuilderAtEnd(builder, last_active_bb);
    return trampoline;
}

static uint8_t do_link_helper(HelperType h, const char *build_macro, const char *bc_name, const char *c_file) {
    FILE *check_fp = fopen(bc_name, "r");
    if (!check_fp) {
        char cmd[4096] = {0};
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
        sprintf(cmd, "clang -c %s --target=aarch64-unknown-linux-gnu -mcpu=apple-m2 -O1 -emit-llvm helper_templates/%s.c -o %s", build_macro, c_file, bc_name);
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
        sprintf(cmd, "clang -c %s --target=riscv64-unknown-linux-gnu -march=rv64imafdv -O1 -emit-llvm helper_templates/%s.c -o %s", build_macro, c_file, bc_name);
#endif
#ifdef DEBUG
        printf("%s\n", cmd); fflush(NULL);
#endif
        assert(strlen(cmd) < sizeof(cmd));
        int rc = system(cmd);
        if (rc) {
            printf("Build command %s failed\n", cmd);
        }
        check_fp = fopen(bc_name, "r");
    }
    if (check_fp) {
        fclose(check_fp);
        char* error_msg = NULL;
        LLVMMemoryBufferRef memory_buffer = NULL;
        LLVMModuleRef helper_module = NULL;
        if (LLVMCreateMemoryBufferWithContentsOfFile(bc_name, &memory_buffer, &error_msg)) {
            fprintf(stderr, "Failed to create memory buffer: %s\n", error_msg);
            LLVMDisposeMessage(error_msg);
            return 0;
        }
        if (LLVMParseBitcode2(memory_buffer, &helper_module)) {
            fprintf(stderr, "Failed to parse bitcode\n");
            LLVMDisposeMemoryBuffer(memory_buffer);
            return 0;
        }
        LLVMLinkModules2(module, helper_module);
        LLVMDisposeMemoryBuffer(memory_buffer);
        return 1;
    }
    return 0;
}

static uint8_t is_tail_call(HelperType h) {
    if (h == helper_syscall || h == helper_icebp || h == helper_raise_interrupt ||
        h == helper_iret_ind || h == helper_jmp_ind || h == helper_ljmp_protected ||
        h == helper_lret_protected || h == helper_pause || h == helper_raise_exception) {
        return 1;
    }
    return 0;
}

static void define_type(LLVMTypeRef *typeref, int idx, LLVMType t, int out_typeref_limit) {
    assert(idx < out_typeref_limit);
    assert(t < LLVMMAXType);
    typeref[idx] = llvm_int_types[t];
#ifdef DEBUG
    printf(" %d:%s", idx, llvm_type_str[t]); fflush(NULL);
#endif
}

// Need to add the gen_flag since in the case when execution goes to the
// QEMU runtime, data type in register can be LLVMInt64; otherwise data type need be correctly
// set in order for compiler to do inline.
static int collect_arguments_and_types(HelperType h, int target_domain, int gen_flag, OperandType *operands, uint32_t *is_imm, uint8_t operands_cnt, LLVMValueRef appendix1, LLVMValueRef appendix2, LLVMValueRef current_func,
                LLVMTypeRef *out_typeref, int out_typeref_limit, LLVMValueRef *out_valref, const char *func_name) {
#ifdef DEBUG
    if (gen_flag != VALUE_ONLY) {
        printf("Define parameters for %s:", func_name); fflush(NULL);
    }
#endif
    if (target_domain == TARGET_DEFAULT_HELPER_PASSTHROUGH_VECTOR) {
        if (gen_flag != VALUE_ONLY) {
            for (int i = 0; i < operands_cnt; ++i) {
                define_type(out_typeref, i, OPC_ADDR_T, out_typeref_limit);
            }
#ifdef DEBUG
            printf("\n"); fflush(NULL);
#endif
            if (gen_flag == TYPE_ONLY) {
                return operands_cnt;
            }
        }
        if (operands_cnt) {
            // current_func must be trampoline, get copy from argument, and handle the missing env
            int param_idx = FIXED_VECTOR_PARAM_COUNT;
            for (int i = 0; i < operands_cnt; ++i) {
                if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) {
                    out_valref[i] = get_env_ptr_raw();
                } else {
                    assert(current_func);
                    assert(param_idx < LLVMCountParams(current_func));
                    out_valref[i] = LLVMGetParam(current_func, param_idx);
                    param_idx += 1;
                }
            }
        }
        return operands_cnt;
    } else if (target_domain == TARGET_DEFAULT_HELPER_CONSTRUCT_VECTOR) {
        if (gen_flag != VALUE_ONLY) {
            for (int i = 0; i < operands_cnt; ++i) {
                define_type(out_typeref, i, OPC_ADDR_T, out_typeref_limit);
            }
#ifdef DEBUG
            printf("\n"); fflush(NULL);
#endif
            if (gen_flag == TYPE_ONLY) {
                return operands_cnt;
            }
        }
        if (operands_cnt) {
            // current_func must be trampoline, get copy from argument, and handle the missing env
            int param_idx = FIXED_VECTOR_PARAM_COUNT;
            for (int i = 0; i < operands_cnt; ++i) {
                if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) {
                    out_valref[i] = get_env_ptr_raw();
                } else {
                    if (is_imm[i] == 0 && operands[i].s.valid && operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_xmm(operands[i])) {
                        OperandType alias = get_alias(operands[i]);
                        assert(alias.s.valid);
                        uint64_t xmm_offset = get_xmm_offset(alias.s.slot_idx/2) + 16*(alias.s.slot_idx%2) + alias.s.offset;
                        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
                        LLVMValueRef env_raw = get_env_ptr_raw();
                        out_valref[i] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("env_ptr_offset", dummy_slot_for_debug));
                    } else if (is_imm[i] == 0 && operands[i].s.valid && operands[i].s.slot_type == SUB_SLOT_XMM) {
                        uint64_t xmm_offset = get_xmm_offset(operands[i].s.slot_idx/2) + 16*(operands[i].s.slot_idx%2) + operands[i].s.offset;
                        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
                        LLVMValueRef env_raw = get_env_ptr_raw();
                        out_valref[i] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("env_ptr_offset", dummy_slot_for_debug));
                    } else {
                        assert(current_func);
                        assert(param_idx < LLVMCountParams(current_func));
                        out_valref[i] = LLVMGetParam(current_func, param_idx);
                        param_idx += 1;
                    }
                }
            }
        }
        return operands_cnt;
    } else if (target_domain == TARGET_QEMUAOT_FASTPATH) {
        if (gen_flag != VALUE_ONLY) {
            for (int i = 0; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
                define_type(out_typeref, i, fixed_vector_param_llvmtypes[i], out_typeref_limit);
            }
#ifdef DEBUG
            printf("\n"); fflush(NULL);
#endif
            if (gen_flag == TYPE_ONLY) {
                return FIXED_VECTOR_PARAM_COUNT;
            }
        }
        for (int i = 0; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
            if (fixed_vector_param_in_stack[i]) {
                OperandType param_in_stack;
                if (i < FIXED_PARAM_COUNT) {
                    param_in_stack.s.valid = 1;
                    param_in_stack.s.slot_type = SUB_SLOT_XREG;
                    param_in_stack.s.slot_idx = i;
                    out_valref[i] = get_source_node_imm_or_stack(call, 0, param_in_stack, fixed_vector_param_llvmtypes[i], 0);
                } else {
                    param_in_stack.s.valid = 1;
                    param_in_stack.s.slot_type = SUB_SLOT_XMM;
                    param_in_stack.s.slot_idx = i - FIXED_PARAM_COUNT;
                    param_in_stack.s.offset = 0;
                    out_valref[i] = get_source_node_imm_or_stack(call, 0, param_in_stack, fixed_vector_param_llvmtypes[i], 0);
                }
            } else {
                assert(current_func);
                assert(i < LLVMCountParams(current_func));
                out_valref[i] = LLVMGetParam(current_func, i);
            }
        }
        return FIXED_VECTOR_PARAM_COUNT;
    } else if (target_domain == TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_WI_VECTOR) {
        if (gen_flag != VALUE_ONLY) {
            int idx = 0;
            for (; idx < FIXED_VECTOR_PARAM_COUNT; ++idx) {
                define_type(out_typeref, idx, fixed_vector_param_llvmtypes[idx], out_typeref_limit);
            }
            for (int i = 0; i < operands_cnt; ++i) {
                if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) {
                    continue;
                }
                define_type(out_typeref, idx, LLVMInt64, out_typeref_limit);
                idx += 1;
            }
            if (appendix1) {
                define_type(out_typeref, idx, LLVMInt64, out_typeref_limit);
                idx += 1;
            }
            if (appendix2) {
                define_type(out_typeref, idx, LLVMInt64, out_typeref_limit);
                idx += 1;
            }
            assert(idx <= (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS));
#ifdef DEBUG
            printf("\n"); fflush(NULL);
#endif
            if (gen_flag == TYPE_ONLY) {
                return idx;
            }
        }
        int idx = 0;
        for (; idx < FIXED_VECTOR_PARAM_COUNT; ++idx) {
            if (fixed_vector_param_in_stack[idx]) {
                OperandType param_in_stack;
                if (idx < FIXED_PARAM_COUNT) {
                    param_in_stack.s.valid = 1;
                    param_in_stack.s.slot_type = SUB_SLOT_XREG;
                    param_in_stack.s.slot_idx = idx;
                    out_valref[idx] = get_source_node_imm_or_stack(call, 0, param_in_stack, fixed_vector_param_llvmtypes[idx], 0);
                } else {
                    param_in_stack.s.valid = 1;
                    param_in_stack.s.slot_type = SUB_SLOT_XMM;
                    param_in_stack.s.slot_idx = idx - FIXED_PARAM_COUNT;
                    param_in_stack.s.offset = 0;
                    out_valref[idx] = get_source_node_imm_or_stack(call, 0, param_in_stack, fixed_vector_param_llvmtypes[idx], 0);
                }
            } else {
                assert(current_func);
                assert(idx < LLVMCountParams(current_func));
                out_valref[idx] = LLVMGetParam(current_func, idx);
            }
        }
        for (int i = 0; i < operands_cnt; ++i) {
            if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) {
                continue;
            }
            if (is_imm[i] == 0 && operands[i].s.valid && operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_xmm(operands[i])) {
                OperandType alias = get_alias(operands[i]);
                assert(alias.s.valid);
                uint64_t xmm_offset = get_xmm_offset(alias.s.slot_idx/2) + 16*(alias.s.slot_idx%2) + alias.s.offset;
                LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
                LLVMValueRef env_raw = get_env_ptr_raw();
                out_valref[idx] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("env_ptr_offset", dummy_slot_for_debug));
            } else if (is_imm[i] == 0 && operands[i].s.valid && operands[i].s.slot_type == SUB_SLOT_XMM) {
                uint64_t xmm_offset = get_xmm_offset(operands[i].s.slot_idx/2) + 16*(operands[i].s.slot_idx%2) + operands[i].s.offset;
                LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
                LLVMValueRef env_raw = get_env_ptr_raw();
                out_valref[idx] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("env_ptr_offset", dummy_slot_for_debug));
            } else if (is_imm[i] == 0 && operands[i].s.valid && operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_env(operands[i])) {
                OperandType alias = get_alias(operands[i]);
                assert(alias.s.valid);
                LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], alias.s.offset, 0);
                LLVMValueRef env_raw = get_env_ptr_raw();
                out_valref[idx] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("env_ptr_offset", dummy_slot_for_debug));
            } else {
                out_valref[idx] = get_source_node_imm_or_stack(call, is_imm[i], operands[i], LLVMInt64, 0);
            }
            idx += 1;
        }
        if (appendix1) {
            out_valref[idx++] = appendix1;
        }
        if (appendix2) {
            out_valref[idx++] = appendix2;
        }
        return idx;
    } else if (target_domain == TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_WO_VECTOR) {
        if (gen_flag != VALUE_ONLY) {
            int idx = 0;
            for (; idx < FIXED_VECTOR_PARAM_COUNT; ++idx) {
                define_type(out_typeref, idx, fixed_vector_param_llvmtypes[idx], out_typeref_limit);
            }
            for (int i = 0; i < operands_cnt; ++i) {
                if (is_imm[i] == 0 && operands[i].s.valid && ((operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) || (operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_xmm(operands[i])) || operands[i].s.slot_type == SUB_SLOT_XMM)) {
                    continue;
                }
                define_type(out_typeref, idx, LLVMInt64, out_typeref_limit);
                idx += 1;
            }
            if (appendix1) {
                define_type(out_typeref, idx, LLVMInt64, out_typeref_limit);
                idx += 1;
            }
            if (appendix2) {
                define_type(out_typeref, idx, LLVMInt64, out_typeref_limit);
                idx += 1;
            }
            assert(idx <= (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS));
#ifdef DEBUG
            printf("\n"); fflush(NULL);
#endif
            if (gen_flag == TYPE_ONLY) {
                return idx;
            }
        }
        int idx = 0;
        for (; idx < FIXED_VECTOR_PARAM_COUNT; ++idx) {
            if (fixed_vector_param_in_stack[idx]) {
                OperandType param_in_stack;
                if (idx < FIXED_PARAM_COUNT) {
                    param_in_stack.s.valid = 1;
                    param_in_stack.s.slot_type = SUB_SLOT_XREG;
                    param_in_stack.s.slot_idx = idx;
                    out_valref[idx] = get_source_node_imm_or_stack(call, 0, param_in_stack, fixed_vector_param_llvmtypes[idx], 0);
                } else {
                    param_in_stack.s.valid = 1;
                    param_in_stack.s.slot_type = SUB_SLOT_XMM;
                    param_in_stack.s.slot_idx = idx - FIXED_PARAM_COUNT;
                    param_in_stack.s.offset = 0;
                    out_valref[idx] = get_source_node_imm_or_stack(call, 0, param_in_stack, fixed_vector_param_llvmtypes[idx], 0);
                }
            } else {
                assert(current_func);
                assert(idx < LLVMCountParams(current_func));
                out_valref[idx] = LLVMGetParam(current_func, idx);
            }
        }
        for (int i = 0; i < operands_cnt; ++i) {
            if (is_imm[i] == 0 && operands[i].s.valid && ((operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) || (operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_xmm(operands[i])) || operands[i].s.slot_type == SUB_SLOT_XMM)) {
                continue;
            }
            if (is_imm[i] == 0 && operands[i].s.valid && operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_env(operands[i])) {
                OperandType alias = get_alias(operands[i]);
                assert(alias.s.valid);
                LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], alias.s.offset, 0);
                LLVMValueRef env_raw = get_env_ptr_raw();
                out_valref[idx] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("env_ptr_offset", dummy_slot_for_debug));
            } else {
                out_valref[idx] = get_source_node_imm_or_stack(call, is_imm[i], operands[i], LLVMInt64, 0);
            }
            idx += 1;
        }
        if (appendix1) {
            out_valref[idx++] = appendix1;
        }
        if (appendix2) {
            out_valref[idx++] = appendix2;
        }
        return idx;
    } else if (target_domain == TARGET_QEMUAOT_HELPER || target_domain == TARGET_QEMUAOT_CC_COMPUTE) {
        int idx = 0;
        if (gen_flag != VALUE_ONLY) {
            for (idx = 0; idx < FIXED_VECTOR_PARAM_COUNT; ++idx) {
                define_type(out_typeref, idx, fixed_vector_param_llvmtypes[idx], out_typeref_limit);
            }
            if (operands_cnt) {
                assert(operands && is_imm);
                const LLVMType *helper_param_types = &(helper_collapse_xmm_arg_type[h][0]);
#define APP_PARAM_IDX(i)    (i - FIXED_VECTOR_PARAM_COUNT)
                for (int op_idx = 0; op_idx < operands_cnt; ++op_idx) {
                    if (is_imm[op_idx]) {
                        define_type(out_typeref, idx, helper_param_types[APP_PARAM_IDX(idx)], out_typeref_limit);
                    } else {
                        if (operands[op_idx].s.slot_type == SUB_SLOT_XMM) {
                            continue;
                        } else if (operands[op_idx].s.slot_type == SUB_SLOT_ENV) {
                            if (!helper_qemuaot_with_env[h]) {
                                continue;
                            }
                            define_type(out_typeref, idx, LLVMInt64, out_typeref_limit);
                        } else if (operands[op_idx].s.slot_type == SUB_SLOT_TMP) {
                            if (has_alias_xmm(operands[op_idx])) {
                                continue;
                            }
                            assert(!has_alias_env(operands[op_idx]));
                            define_type(out_typeref, idx, helper_param_types[APP_PARAM_IDX(idx)], out_typeref_limit);
                        } else if (operands[op_idx].s.slot_type == SUB_SLOT_ENVVAR) {
                            define_type(out_typeref, idx, helper_param_types[APP_PARAM_IDX(idx)], out_typeref_limit);
                        } else if (operands[op_idx].s.slot_type == SUB_SLOT_XREG) {
                            define_type(out_typeref, idx, fixed_vector_param_llvmtypes[operands[op_idx].s.slot_idx], out_typeref_limit);
                        } else {
                            assert(0);
                        }
                    }
                    idx += 1;
                }
#undef APP_PARAM_IDX
            }
            if (appendix1) {
                define_type(out_typeref, idx, LLVMInt64, out_typeref_limit);
                idx += 1;
            }
            if (appendix2) {
                define_type(out_typeref, idx, LLVMInt64, out_typeref_limit);
                idx += 1;
            }
            assert(idx <= (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS));
#ifdef DEBUG
            printf("\n"); fflush(NULL);
#endif
            if (gen_flag == TYPE_ONLY) {
                return idx;
            }
        }
        for (idx = 0; idx < FIXED_VECTOR_PARAM_COUNT; ++idx) {
            if (fixed_vector_param_in_stack[idx]) {
                OperandType param_in_stack;
                if (idx < FIXED_PARAM_COUNT) {
                    param_in_stack.s.valid = 1;
                    param_in_stack.s.slot_type = SUB_SLOT_XREG;
                    param_in_stack.s.slot_idx = idx;
                    out_valref[idx] = get_source_node_imm_or_stack(call, 0, param_in_stack, fixed_vector_param_llvmtypes[idx], 0);
                } else {
                    param_in_stack.s.valid = 1;
                    param_in_stack.s.slot_type = SUB_SLOT_XMM;
                    param_in_stack.s.slot_idx = idx - FIXED_PARAM_COUNT;
                    param_in_stack.s.offset = 0;
                    out_valref[idx] = get_source_node_imm_or_stack(call, 0, param_in_stack, fixed_vector_param_llvmtypes[idx], 0);
                }
            } else {
                assert(current_func);
                assert(idx < LLVMCountParams(current_func));
                out_valref[idx] = LLVMGetParam(current_func, idx);
            }
        }
        if (operands_cnt) {
            assert(operands && is_imm);
            const LLVMType *helper_param_types = &(helper_collapse_xmm_arg_type[h][0]);
#define APP_PARAM_IDX(i)    (i - FIXED_VECTOR_PARAM_COUNT)
            for (int op_idx = 0; op_idx < operands_cnt; ++op_idx) {
                if (is_imm[op_idx]) {
                    out_valref[idx] = LLVMConstInt(llvm_int_types[helper_param_types[APP_PARAM_IDX(idx)]], operands[op_idx].i, 0);
                } else {
                    if (operands[op_idx].s.slot_type == SUB_SLOT_XMM) {
                        continue;
                    } else if (operands[op_idx].s.slot_type == SUB_SLOT_ENV) {
                        if (!helper_qemuaot_with_env[h]) {
                            continue;
                        }
                        out_valref[idx] = get_env_ptr_raw();
                    } else if (operands[op_idx].s.slot_type == SUB_SLOT_TMP) {
                        if (has_alias_xmm(operands[op_idx])) {
                            continue;
                        }
                        assert(!has_alias_env(operands[op_idx]));
                        out_valref[idx] = get_source_node_imm_or_stack(call, 0, operands[op_idx], helper_param_types[APP_PARAM_IDX(idx)], 0);
                    } else if (operands[op_idx].s.slot_type == SUB_SLOT_ENVVAR) {
                        out_valref[idx] = get_source_node_imm_or_stack(call, 0, operands[op_idx], helper_param_types[APP_PARAM_IDX(idx)], 0);
                    } else if (operands[op_idx].s.slot_type == SUB_SLOT_XREG) {
                        if (fixed_vector_param_in_stack[operands[op_idx].s.slot_idx]) {
                            out_valref[idx] = get_source_node_imm_or_stack(call, 0, operands[op_idx], fixed_vector_param_llvmtypes[operands[op_idx].s.slot_idx], 0);
                        } else {
                            assert(current_func);
                            assert(idx < LLVMCountParams(current_func));
                            out_valref[idx] = LLVMGetParam(current_func, idx);
                        }
                    } else {
                        assert(0);
                    }
                }
                idx += 1;
            }
#undef APP_PARAM_IDX
        }
        if (appendix1) {
            out_valref[idx++] = appendix1;
        }
        if (appendix2) {
            out_valref[idx++] = appendix2;
        }
        assert(idx <= (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS));
        return idx;
    } else if (target_domain == TARGET_QEMUAOT_HELPER_SECOND_HALF) {
        int idx = 0;
        if (gen_flag != VALUE_ONLY) {
            for (idx = 0; idx < FIXED_VECTOR_PARAM_COUNT; ++idx) {
                define_type(out_typeref, idx, fixed_vector_param_llvmtypes[idx], out_typeref_limit);
            }
            if (helper_return_type[h] != LLVMInvalidType) {
                define_type(out_typeref, idx, helper_return_type[h], out_typeref_limit);
                idx += 1;
            }
#ifdef DEBUG
            printf("\n"); fflush(NULL);
#endif
            if (gen_flag == TYPE_ONLY) {
                return idx;
            }
        }
        assert(0);
    } else {
        assert(0);
    }
}

static LLVMValueRef get_or_add_func_with_qemuaot_cc(const char *name, int with_ret, LLVMAttributeRef attr_inline_ctrl) {
#ifdef DEBUG
    printf("%s %s\n", __FUNCTION__, name); fflush(NULL);
#endif
    LLVMValueRef func = LLVMGetNamedFunction(module, name);
    if (!func) {
        LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT] = {NULL};
        int arg_cnt = collect_arguments_and_types(not_a_helper, TARGET_QEMUAOT_FASTPATH, TYPE_ONLY, NULL, NULL, 0, NULL, NULL, llvm_func, call_types, FIXED_VECTOR_PARAM_COUNT, NULL, name);
        LLVMTypeRef func_type = LLVMFunctionType(with_ret ? LLVMInt64Type() : LLVMVoidType(), call_types, arg_cnt, 0);
        func = LLVMAddFunction(module, name, func_type);
        LLVMAddAttributeAtIndex(func, -1, attr_inline_ctrl);
        LLVMAddAttributeAtIndex(func, -1, target_features_attr);
        LLVMSetFunctionCallConv(func, QEMUAOT_CC);
    }
    return func;
}

// FIXME: can this be merged into common logic?
static void translate_short_circuit_jmp_ind(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf(">>>%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    HelperType h = get_helper(ptr);
    char *second_half_name = "jmp_ind_callback";
    OperandType operands[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm[MAX_OPERANDS_COUNT] = {0};
    int operands_cnt = 0;
    for (int i = 0; i < MAX_OPERANDS_COUNT; ++i) {
        operands[i] = get_operand(ptr, (i + (HELPER_DEFINES_OUTPUT(h) ? 1 : 0)), &(is_imm[i]));
        if (is_imm[i] == 0 && operands[i].s.valid == 0) {
            break;
        }
        operands_cnt += 1;
    }

    // Get the second half - jmp_ind_callback
    char macro_def[4096] = {0};
    sprintf(macro_def, "-DXMM_PARAM_DECLARE_COMMON=\"%s\" -DXMM_PARAM_LIST=\"%s\" ", XMM_PARAM_DECLARE_COMMON, XMM_PARAM_LIST);
    assert(strlen(macro_def) < sizeof(macro_def));
    uint8_t ret = do_link_helper(jmp_ind_callback, macro_def, "helper_templates/jmp_ind_callback.bc", "jmp_ind_callback");
    assert(ret);
    LLVMValueRef second_half_func = LLVMGetNamedFunction(module, second_half_name);
    assert(second_half_func);

    // Get the helper
    LLVMValueRef helper_func = LLVMGetNamedFunction(module, helper_str[h]);
    if (!helper_func) {
        LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS] = {NULL};
        int arg_cnt = collect_arguments_and_types(h, TARGET_QEMUAOT_HELPER, TYPE_ONLY, operands, is_imm, operands_cnt, (LLVMValueRef)1, (LLVMValueRef)1, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS), NULL, helper_str[h]);
        LLVMTypeRef helper_type = LLVMFunctionType(LLVMVoidType(), call_types, arg_cnt, 0);
        helper_func = LLVMAddFunction(module, helper_str[h], helper_type);
    }
    LLVMValueRef second_half_addr = LLVMBuildPtrToInt(builder, second_half_func, llvm_int_types[OPC_ADDR_T], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    // Inside the second_half - jmp_ind_callback logic may decide to invoke
    // runtime translation in case entry not found in AOT
    LLVMValueRef helper_jit_func = LLVMGetNamedFunction(module, helper_str[helper_jit]);
    if (!helper_jit_func) {
        LLVMTypeRef call_types[MAX_ADDED_ARGS] = {NULL};
        int call_arg_cnt = collect_arguments_and_types(helper_jit, TARGET_DEFAULT_HELPER_PASSTHROUGH_VECTOR, TYPE_ONLY, operands, is_imm, operands_cnt, NULL, NULL, llvm_func, call_types, MAX_ADDED_ARGS, NULL, helper_str[helper_jit]);
        LLVMTypeRef helper_jit_type = LLVMFunctionType(llvm_int_types[helper_return_type[h]], call_types, call_arg_cnt, 0);
        helper_jit_func = LLVMAddFunction(module, helper_str[helper_jit], helper_jit_type);
    }

    LLVMValueRef jit_trampoline = get_trampoline(helper_jit_func, 0, 0, operands, is_imm, operands_cnt, NULL, 0, NULL, 0, TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_WI_VECTOR);
    LLVMValueRef jit_trampoline_addr = LLVMBuildPtrToInt(builder, jit_trampoline, llvm_int_types[OPC_ADDR_T], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    int call_arg_cnt = collect_arguments_and_types(h, TARGET_QEMUAOT_HELPER, VALUE_ONLY, operands, is_imm, operands_cnt, second_half_addr, jit_trampoline_addr, llvm_func, NULL, 0, call_args, helper_str[h]);
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT));
    LLVMTypeRef helper_type = LLVMGlobalGetValueType(helper_func);
#ifdef DEBUG
    printf("BuildCall2:%s\n", LLVMGetValueName(helper_func)); fflush(NULL);
#endif
    LLVMValueRef call_helper_inst = LLVMBuildCall2(builder, helper_type, helper_func, call_args, call_arg_cnt, "");
    LLVMSetTailCall(call_helper_inst, 1);
    LLVMSetInstructionCallConv(call_helper_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);

    LLVMValueRef llvm_func_backup = llvm_func;
    void *ptr_init = get_instr_buffer();
    void *ptr_max = ptr_init + get_instr_buffer_size();
    // Check if we got remaining BBs
    do {
        llvm_func = llvm_func_backup;
        uint8_t current_active_label_cnt = get_current_active_label_cnt(llvm_func);
        if (!current_active_label_cnt) {
            break;
        }
        uint8_t *current_active_labels = get_current_active_labels(llvm_func);
        uint8_t tgt_lbl = current_active_labels[0];
        void *ptr_tmp = NULL;
        for (ptr_tmp = ptr_init; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
            OpCodeType opc = get_opcode(ptr_tmp);
            if (opc == set_label && get_label(ptr_tmp) == tgt_lbl) {
                break;
            }
        }
        assert(ptr_tmp < ptr_max);
        for (; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
            OpCodeType opc = get_opcode(ptr_tmp);
            handle_single_instr(opc, ptr_tmp);
            memcpy(tmp_var_available, tmp_var_available_backup, sizeof(tmp_var_available));
            if (is_opc_end_of_control_flow(opc, ptr_tmp)) {
                break;
            }
        }
    } while (1);
#ifdef DEBUG
    printf("<<<%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
}

static void translate_cc_compute_inband(OpCodeType opc, void *ptr) {
    HelperType h = get_helper(ptr);
#ifdef DEBUG
    printf("%s %s %s %lx\n", __FUNCTION__, opcode_type_str[opc], helper_str[h], ptr); fflush(NULL);
#endif
    OperandType oarg;
    uint32_t is_imm_dummy;
    oarg = get_operand(ptr, 0, &is_imm_dummy);
    assert(!is_imm_dummy && oarg.s.valid);
    OperandType operands[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm[MAX_OPERANDS_COUNT] = {0};
    int operands_cnt = 0;
    for (int i = 0; i < MAX_OPERANDS_COUNT; ++i) {
        operands[i] = get_operand(ptr, (i + (helper_return_type[h] != LLVMInvalidType ? 1 : 0)), &(is_imm[i]));
        if (is_imm[i] == 0 && operands[i].s.valid == 0) {
            break;
        }
        operands_cnt += 1;
    }
    char helper_func_name[256] = {0};
    sprintf(helper_func_name, "%s_inband", helper_str[h]);
    LLVMValueRef helper = LLVMGetNamedFunction(module, helper_func_name);
    if (!helper) {
        char build_macro[4096] = {0};
        char bc_name[256] = {0};
        char element[256] = {0};
        sprintf(build_macro, "-DXMM_PARAM_DECLARE_COMMON=\"%s\" -DXMM_PARAM_LIST=\"%s\"", XMM_PARAM_DECLARE_COMMON, XMM_PARAM_LIST);
        sprintf(element, " -DHELPER_NAME=%s_inband", helper_str[h]);
        strcat(build_macro, element);
        sprintf(bc_name, "helper_templates/%s.bc", helper_str[h]);
        assert(strlen(build_macro) < sizeof(build_macro));
        uint8_t do_inline_helper = do_link_helper(h, build_macro, bc_name, helper_str[h]);
        assert(do_inline_helper);
        helper = LLVMGetNamedFunction(module, helper_func_name);
        assert(helper);
    }
    LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    int call_arg_cnt = collect_arguments_and_types(h, TARGET_QEMUAOT_CC_COMPUTE, TYPE_AND_VALUE, operands, is_imm, operands_cnt, NULL, NULL, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT), call_args, helper_func_name);
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT));
    LLVMTypeRef helper_type = LLVMFunctionType(llvm_int_types[helper_return_type[h]], call_types, call_arg_cnt, 0);
    LLVMValueRef call_helper_inst = LLVMBuildCall2(builder, helper_type, helper, call_args, call_arg_cnt, "");
    LLVMSetInstructionCallConv(call_helper_inst, QEMUAOT_CC);
    assert(helper_return_type[h] != LLVMInvalidType);
    do_store(opc, call_helper_inst, helper_return_type[h], oarg);
}

static void spill_vector(LLVMValueRef xmm_val, XMMRegType xmm_reg) {
    char debug_name[64] = {0};
#ifdef VERBOSE_VAR
    sprintf(debug_name, "vector_spill_%s", xmmreg_str[xmm_reg]);
#endif
    LLVMValueRef env_raw = get_env_ptr_raw();
    uint64_t xmm_offset = get_xmm_offset(xmm_reg/2) + 16*(xmm_reg%2);
    LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
    LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name(debug_name, dummy_slot_for_debug));
    check_scalable_vector_perform_store(xmm_val, LLVMVector2xi64, addr);
}

static LLVMValueRef reload_vector(XMMRegType xmm_reg) {
    char debug_name[64] = {0};
#ifdef VERBOSE_VAR
    sprintf(debug_name, "vector_reload_%s", xmmreg_str[xmm_reg]);
#endif
    LLVMValueRef env_raw = get_env_ptr_raw();
    uint64_t xmm_offset = get_xmm_offset(xmm_reg/2) + 16*(xmm_reg%2);
    LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
    LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name(debug_name, dummy_slot_for_debug));
    return check_scalable_vector_perform_load(LLVMVector2xi64, addr);
}

static void translate_helper_outband(OpCodeType opc, void *ptr) {
    HelperType h = get_helper(ptr);
#ifdef DEBUG
    printf(">>>%s %s %s %lx\n", __FUNCTION__, opcode_type_str[opc], helper_str[h], ptr); fflush(NULL);
#endif
    // Store tmp_shadow_offset[this call][non-zero offset] contents to the shadow_stack
    LLVMValueRef shadow_pointer = NULL;
    for (int i = 0; i < (1<<STACK_INDEX_SHIFT); ++i) {
        if (tmp_shadow_offset[i]) {
            OperandType op;
            op.s.valid = 1;
            op.s.slot_type = SUB_SLOT_TMP;
            op.s.slot_idx = i;
            if (!has_alias(op)) {
                LLVMValueRef val = get_source_node_imm_or_stack(opc, 0, op, func_tmp_llvmtype[i], 0);
                LLVMValueRef shadow_off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], tmp_shadow_offset[i], 0);
                if (!shadow_pointer) {
                    LLVMValueRef env_raw = get_env_ptr_raw();
                    LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], -8UL, 0);
                    LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                    shadow_pointer = LLVMBuildLoad2(builder, llvm_int_types[OPC_ADDR_T], pointer, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                }
                char var_name[128] = {0};
                sprintf(var_name, "cross_call_spill_tmp_%d_offset_%d", i, tmp_shadow_offset[i]);
                LLVMValueRef shadow_addr = LLVMBuildAdd(builder, shadow_pointer, shadow_off, get_next_var_name(var_name, dummy_slot_for_debug));
                LLVMValueRef shadow_p = LLVMBuildIntToPtr(builder, shadow_addr, LLVMPointerType(llvm_int_types[func_tmp_llvmtype[i]], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                LLVMBuildStore(builder, val, shadow_p);
            }
        }
    }

    ///////////////////////////////////////////////////
    /// Collect function call arguments: those arguments for inlined helper can be different from runtime helpers
    /// Do vector register spill/reload if necessary
    // Collect used xmm indexes, and xmm indexes that need be put into registers
    XMMRegType used_xmm_regs[MAX_OPERANDS_COUNT];
    int used_xmm_regs_cnt = 0;
    XMMRegType touched_effective_xmm_regs[MAX_OPERANDS_COUNT];
    int touched_effective_xmm_regs_cnt = 0;
    OperandType oarg;
    oarg.s.valid = 0;
    uint32_t is_imm_dummy;
    if (helper_return_type[h] != LLVMInvalidType) {
      oarg = get_operand(ptr, 0, &is_imm_dummy);
      assert(!is_imm_dummy && oarg.s.valid);
    }
    OperandType operands[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm[MAX_OPERANDS_COUNT] = {0};
    int operands_cnt = 0;
    uint16_t vec_slots[MAX_OPERANDS_COUNT] = {0};
    int vec_cnt = 0;
    for (int i = 0; i < MAX_OPERANDS_COUNT; ++i) {
        operands[i] = get_operand(ptr, (i + (helper_return_type[h] != LLVMInvalidType ? 1 : 0)), &(is_imm[i]));
        if (is_imm[i] == 0 && operands[i].s.valid == 0) {
            break;
        }
        if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_xmm(operands[i])) {
            OperandType alias = get_alias(operands[i]);
            assert(alias.s.valid);
            assert(alias.s.slot_idx % 2 == 0);
            int found = 0;
            for (int j = 0; j < used_xmm_regs_cnt; ++j) {
                if (used_xmm_regs[j] == alias.s.slot_idx) {
                    found = 1;
                    break;
                }
            }
            if (!found) {
                used_xmm_regs[used_xmm_regs_cnt] = alias.s.slot_idx;
                used_xmm_regs_cnt += 1;
            }
            vec_slots[vec_cnt] = alias.s.slot_idx;
            vec_cnt += 1;
        } else if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_env(operands[i])) {
            OperandType alias = get_alias(operands[i]);
            assert(alias.s.valid);
            XMMReg equivalent_xmm = lookup_xmm_map(alias.s.offset);
            if (equivalent_xmm.xmm_idx != NON_XMM && equivalent_xmm.xmm_offset == 0) {
                int found = 0;
                for (int j = 0; j < touched_effective_xmm_regs_cnt; ++j) {
                    if (touched_effective_xmm_regs[j] == equivalent_xmm.xmm_idx) {
                        found = 1;
                        break;
                    }
                }
                if (!found) {
                    touched_effective_xmm_regs[touched_effective_xmm_regs_cnt] = equivalent_xmm.xmm_idx;
                    touched_effective_xmm_regs_cnt += 1;
                }
                vec_slots[vec_cnt] = equivalent_xmm.xmm_idx;
                vec_cnt += 1;
            }
        }
        operands_cnt += 1;
    }

    // Do vector register spill/reload if candidate helper can be inlined
    XMMRegType spilled_xmm_regs[MAX_OPERANDS_COUNT];
    XMMRegType passenger_xmm_regs[MAX_OPERANDS_COUNT];
    int passenger_xmm_regs_cnt = 0;
    assert((used_xmm_regs_cnt + touched_effective_xmm_regs_cnt) <= XMM_COUNT);
    if (touched_effective_xmm_regs_cnt) {
        XMMRegType free_xmm_regs[XMM_COUNT];
        XMMRegType tmp = xmm0;
        for (int i = 0; i < XMM_COUNT; ++i) {
            free_xmm_regs[i] = tmp;
            tmp += 2;
        }
        for (int i = 0; i < used_xmm_regs_cnt; ++i) {
            for (int j = 0; j < XMM_COUNT; ++j) {
                if (free_xmm_regs[j] == used_xmm_regs[i]) {
                    free_xmm_regs[j] = NON_XMM;
                    break;
                }
            }
        }
        for (int i = 0; i < touched_effective_xmm_regs_cnt; ++i) {
            passenger_xmm_regs[passenger_xmm_regs_cnt] = touched_effective_xmm_regs[i];
            XMMRegType candidate = NON_XMM;
            for (int j = 0; j < XMM_COUNT; ++j) {
                if (free_xmm_regs[j] != NON_XMM) {
                    candidate = free_xmm_regs[j];
                    free_xmm_regs[j] = NON_XMM;
                    break;
                }
            }
            assert(candidate != NON_XMM);
            spilled_xmm_regs[passenger_xmm_regs_cnt] = candidate;
            passenger_xmm_regs_cnt += 1;
        }
    }
    for (int i = 0; i < passenger_xmm_regs_cnt; ++i) {
        LLVMValueRef xmm_val = NULL;
        if (fixed_vector_param_in_stack[FIXED_PARAM_COUNT + spilled_xmm_regs[i]]) {
            OperandType param_in_stack;
            param_in_stack.s.valid = 1;
            param_in_stack.s.slot_type = SUB_SLOT_XMM;
            param_in_stack.s.slot_idx = spilled_xmm_regs[i];
            param_in_stack.s.offset = 0;
            xmm_val = get_source_node_imm_or_stack(opc, 0, param_in_stack, fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + spilled_xmm_regs[i]], 0);
        } else {
            assert((FIXED_PARAM_COUNT + spilled_xmm_regs[i]) < LLVMCountParams(llvm_func));
            xmm_val = LLVMGetParam(llvm_func, (FIXED_PARAM_COUNT + spilled_xmm_regs[i]));
        }
        spill_vector(xmm_val, spilled_xmm_regs[i]);
        if (IS_YMM_HELPER(h)) {
            if (fixed_vector_param_in_stack[FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1]) {
                OperandType param_in_stack;
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XMM;
                param_in_stack.s.slot_idx = spilled_xmm_regs[i] + 1;
                param_in_stack.s.offset = 0;
                xmm_val = get_source_node_imm_or_stack(opc, 0, param_in_stack, fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1], 0);
            } else {
                assert((FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1) < LLVMCountParams(llvm_func));
                xmm_val = LLVMGetParam(llvm_func, (FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1));
            }
            spill_vector(xmm_val, spilled_xmm_regs[i] + 1);
        }
    }

    // Update operands point to spilled vector slots
    for (int i = 0; i < operands_cnt; ++i) {
        if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_env(operands[i])) {
            OperandType alias = get_alias(operands[i]);
            assert(alias.s.valid);
            XMMReg equivalent_xmm = lookup_xmm_map(alias.s.offset);
            if (equivalent_xmm.xmm_idx != NON_XMM && equivalent_xmm.xmm_offset == 0) {
                int new_idx = -1;
                for (int j = 0; j < passenger_xmm_regs_cnt; ++j) {
                    if (passenger_xmm_regs[j] == equivalent_xmm.xmm_idx) {
                        new_idx = j;
                        break;
                    }
                }
                assert(new_idx != -1);
                operands[i].s.slot_type = SUB_SLOT_XMM;
                operands[i].s.slot_idx = spilled_xmm_regs[new_idx];

                // Now load passenger into the slot
                if (!fixed_vector_param_in_stack[FIXED_PARAM_COUNT + new_idx]) {
                    LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx]], fixed_vector_stack_names[FIXED_PARAM_COUNT + new_idx]);
                    func_xmm_alloca[new_idx] = alloca_inst;
                    func_xmm_llvmtype[new_idx] = fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx];
                    LLVMSetAlignment(alloca_inst, 16);
                    fixed_vector_param_in_stack[FIXED_PARAM_COUNT + new_idx] = 1;
                }
                OperandType op;
                op.s.valid = 1;
                op.s.slot_type = SUB_SLOT_ENV;
                op.s.offset = alias.s.offset;
                LLVMValueRef val = get_source_node_imm_or_stack(opc, 0, op, func_xmm_llvmtype[new_idx], 0);
                LLVMBuildStore(builder, val, func_xmm_alloca[new_idx]);
            }
        }
    }

    ///////////////////////////////////////////////////////////
    /// Collect build macros for xmm helpers, and those marcos define specific version of helpers
    char build_macro[4096] = {0};
    sprintf(build_macro, "-DXMM_PARAM_DECLARE_COMMON=\"%s\" -DXMM_PARAM_LIST=\"%s\"", XMM_PARAM_DECLARE_COMMON, XMM_PARAM_LIST);
    char vector_seq_name[512] = {0};
    for (int i = 0; i < vec_cnt; ++i) {
        uint16_t xmm_idx = vec_slots[i];
        for (int j = 0; j < passenger_xmm_regs_cnt; ++j) {
            if (xmm_idx == passenger_xmm_regs[j]) {
                xmm_idx = spilled_xmm_regs[j];
                break;
            }
        }
        char element1[32];
        char element2[32];
        sprintf(element1, " -DVEC%d=%s", i, xmmreg_str[xmm_idx]);
        sprintf(element2, "_VEC%d_%s", i, xmmreg_str[xmm_idx]);
        strcat(build_macro, element1);
        strcat(vector_seq_name, element2);
    }

    char second_half_name[64];
    uint8_t call_idx = get_idx_for_call_helper(ptr);
    sprintf(second_half_name, "%s%sfunc_%lx_call%d", func_name_prefix, func_name_prefix[0] ? "_" : "", current_func_offset, call_idx);

    char helper_func_name[1024] = {0};
    char bc_name[1024] = {0};
    char element[1024] = {0};
    sprintf(element, " -DHELPER_NAME=%s%s_outband", helper_str[h], vector_seq_name);
    strcat(build_macro, element);
    sprintf(bc_name, "helper_templates/%s%s.bc", helper_str[h], vector_seq_name);
    sprintf(helper_func_name, "%s%s_outband", helper_str[h], vector_seq_name);
    assert(strlen(build_macro) < sizeof(build_macro));

    // Get the second half
    uint8_t second_half_already_exists = 0;
    LLVMValueRef second_half_func = LLVMGetNamedFunction(module, second_half_name);
    if (!second_half_func) {
#ifdef DEBUG
        printf("creating %s\n", second_half_name); fflush(NULL);
#endif
        LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS] = {NULL};
        int call_arg_cnt = collect_arguments_and_types(h, TARGET_QEMUAOT_HELPER_SECOND_HALF, TYPE_ONLY, NULL, NULL, 0, NULL, NULL, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS), NULL, second_half_name);
        LLVMTypeRef func_type = LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnt, 0);
        second_half_func = LLVMAddFunction(module, second_half_name, func_type);
        LLVMAddAttributeAtIndex(second_half_func, -1, AlwaysInlineAttr);
        LLVMAddAttributeAtIndex(second_half_func, -1, target_features_attr);
        LLVMSetFunctionCallConv(second_half_func, QEMUAOT_CC);
        register_labels_for_func(second_half_func);
    } else {
        second_half_already_exists = 1;
    }

    /// Some xmm helpers do not need exception helper
    LLVMValueRef exception_path_trampoline = NULL;
    if (helper_require_exception_path[h]) {
        // Generate exception handler to fallback to QEMU runtime
        // Get the helper
        LLVMValueRef helper_func = LLVMGetNamedFunction(module, helper_str[h]);
        if (!helper_func) {
            LLVMTypeRef call_types[MAX_OPERANDS_COUNT] = {NULL};
            int call_arg_cnt = collect_arguments_and_types(h, TARGET_DEFAULT_HELPER_CONSTRUCT_VECTOR, TYPE_ONLY, operands, is_imm, operands_cnt, NULL, NULL, llvm_func, call_types, MAX_OPERANDS_COUNT, NULL, helper_str[h]);
            LLVMTypeRef helper_type = LLVMFunctionType(llvm_int_types[helper_return_type[h]], call_types, call_arg_cnt, 0);
            helper_func = LLVMAddFunction(module, helper_str[h], helper_type);
        }
        // FIXME: verify that stack point does not need adjustment, since QEMUAOT CC does not have prolog/epilog
        // Trampoline handles register-context switch
        // Check if argument slot is full on DEF_HELPER_FLAGS_7
        int param_cnt = 0;
        for (int i = 0; i < operands_cnt; ++i) {
            if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) {
                continue;
            }
            param_cnt += 1;
        }
        exception_path_trampoline = get_trampoline(helper_func, 1, helper_return_type[h] != LLVMInvalidType ? 1 : 0, operands, is_imm, operands_cnt, second_half_func, passenger_xmm_regs_cnt, spilled_xmm_regs, param_cnt == MAX_ADDED_ARGS, TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_WO_VECTOR);
    }

    // Generate the fast path inlined helper
    uint8_t do_inline_helper = do_link_helper(h, build_macro, bc_name, helper_str[h]);
    assert(do_inline_helper);
    LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    LLVMValueRef second_half_addr = LLVMBuildPtrToInt(builder, second_half_func, llvm_int_types[OPC_ADDR_T], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef trampoline_addr = helper_require_exception_path[h] ? LLVMBuildPtrToInt(builder, exception_path_trampoline, llvm_int_types[OPC_ADDR_T], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug)) : NULL;
    int call_arg_cnt = collect_arguments_and_types(h, TARGET_QEMUAOT_HELPER, TYPE_AND_VALUE, operands, is_imm, operands_cnt, second_half_addr, trampoline_addr, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT), call_args, helper_func_name);
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT));
    LLVMValueRef helper = LLVMGetNamedFunction(module, helper_func_name);
    assert(helper);
    LLVMTypeRef helper_type = LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnt, 0);
    LLVMValueRef call_helper_inst = LLVMBuildCall2(builder, helper_type, helper, call_args, call_arg_cnt, "");
    LLVMSetTailCall(call_helper_inst, 1);
    LLVMSetInstructionCallConv(call_helper_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);

    LLVMValueRef llvm_func_backup = llvm_func;
    void *ptr_init = get_instr_buffer();
    void *ptr_max = ptr_init + get_instr_buffer_size();
    // Check if we got remaining BBs
    do {
        llvm_func = llvm_func_backup;
        uint8_t current_active_label_cnt = get_current_active_label_cnt(llvm_func);
        if (!current_active_label_cnt) {
            break;
        }
        uint8_t *current_active_labels = get_current_active_labels(llvm_func);
        uint8_t tgt_lbl = current_active_labels[0];
        void *ptr_tmp = NULL;
        for (ptr_tmp = ptr_init; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
            OpCodeType opc = get_opcode(ptr_tmp);
            if (opc == set_label && get_label(ptr_tmp) == tgt_lbl) {
                break;
            }
        }
        assert(ptr_tmp < ptr_max);
        for (; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
            OpCodeType opc = get_opcode(ptr_tmp);
            handle_single_instr(opc, ptr_tmp);
            memcpy(tmp_var_available, tmp_var_available_backup, sizeof(tmp_var_available));
            if (is_opc_end_of_control_flow(opc, ptr)) {
                break;
            }
        }
    } while (1);

    if (second_half_already_exists) {
#ifdef DEBUG
        printf("<<<%s %s %lx return early\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
        return;
    }

    /// Setup and finish the second-half function
    llvm_func = second_half_func;
    for (int j = 0; j < FIXED_VECTOR_PARAM_COUNT; j++) {
        LLVMValueRef param = LLVMGetParam(llvm_func, j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }
    if (helper_return_type[h] != LLVMInvalidType) {
        assert(FIXED_VECTOR_PARAM_COUNT < LLVMCountParams(llvm_func));
        LLVMValueRef param = LLVMGetParam(llvm_func, FIXED_VECTOR_PARAM_COUNT);
        LLVMSetValueName(param, "helper_result");
    }

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);
    last_active_bb = entry;

    setup_func_stack();

    // Get output from helper func
    if (helper_return_type[h] != LLVMInvalidType) {
        assert(FIXED_VECTOR_PARAM_COUNT < LLVMCountParams(llvm_func));
        LLVMValueRef param = LLVMGetParam(llvm_func, FIXED_VECTOR_PARAM_COUNT);
        if (oarg.s.slot_type == SUB_SLOT_TMP && has_alias(oarg)) {
            unregister_alias(oarg);
        }
        if (helper_return_type[h] < LLVMInt64) {
            param = LLVMBuildTrunc(builder, param, llvm_int_types[helper_return_type[h]], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        }
        do_store(opc, param, helper_return_type[h], oarg);
    }

    ///////////////////////////////////////////////////////
    /// Do vector registers reload if any spilled previously
    // If did helper inline and we got passenger vectors, then do restore here
    if (passenger_xmm_regs_cnt) {
        for (int i = 0; i < passenger_xmm_regs_cnt; ++i) {
            assert((FIXED_PARAM_COUNT + spilled_xmm_regs[i]) < LLVMCountParams(llvm_func));
            LLVMValueRef xmm_val = LLVMGetParam(llvm_func, (FIXED_PARAM_COUNT + spilled_xmm_regs[i]));
            spill_vector(xmm_val, passenger_xmm_regs[i]);
            if (IS_YMM_HELPER(h)) {
                assert((FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1) < LLVMCountParams(llvm_func));
                xmm_val = LLVMGetParam(llvm_func, (FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1));
                spill_vector(xmm_val, passenger_xmm_regs[i] + 1);
            }

            xmm_val = reload_vector(spilled_xmm_regs[i]);
            if (!func_xmm_alloca[spilled_xmm_regs[i]]) {
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[XREG_MAX + spilled_xmm_regs[i]]], fixed_vector_stack_names[XREG_MAX + spilled_xmm_regs[i]]);
                func_xmm_alloca[spilled_xmm_regs[i]] = alloca_inst;
                func_xmm_llvmtype[spilled_xmm_regs[i]] = fixed_vector_param_llvmtypes[XREG_MAX + spilled_xmm_regs[i]];
                LLVMSetAlignment(alloca_inst, 16);
            }
            LLVMBuildStore(builder, xmm_val, func_xmm_alloca[spilled_xmm_regs[i]]);
            fixed_vector_param_in_stack[FIXED_PARAM_COUNT + spilled_xmm_regs[i]] = 1;
            if (IS_YMM_HELPER(h)) {
                xmm_val = reload_vector(spilled_xmm_regs[i] + 1);
                if (!func_xmm_alloca[spilled_xmm_regs[i] + 1]) {
                    LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[XREG_MAX + spilled_xmm_regs[i] + 1]], fixed_vector_stack_names[XREG_MAX + spilled_xmm_regs[i] + 1]);
                    func_xmm_alloca[spilled_xmm_regs[i] + 1] = alloca_inst;
                    func_xmm_llvmtype[spilled_xmm_regs[i] + 1] = fixed_vector_param_llvmtypes[XREG_MAX + spilled_xmm_regs[i] + 1];
                    LLVMSetAlignment(alloca_inst, 16);
                }
                LLVMBuildStore(builder, xmm_val, func_xmm_alloca[spilled_xmm_regs[i] + 1]);
                fixed_vector_param_in_stack[FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1] = 1;
            }
        }
    }

    // Reload tmp_shadow_offset[this call][non-zero offset] contents
    shadow_pointer = NULL;
    for (int i = 0; i < (1<<STACK_INDEX_SHIFT); ++i) {
        if (tmp_shadow_offset[i]) {
            OperandType op;
            op.s.valid = 1;
            op.s.slot_type = SUB_SLOT_TMP;
            op.s.slot_idx = i;
            if (!has_alias(op)) {
                LLVMValueRef shadow_off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], tmp_shadow_offset[i], 0);
                if (!shadow_pointer) {
                    LLVMValueRef env_raw = get_env_ptr_raw();
                    LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], -8UL, 0);
                    LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                    shadow_pointer = LLVMBuildLoad2(builder, llvm_int_types[OPC_ADDR_T], pointer, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                }
                char var_name[128] = {0};
                sprintf(var_name, "cross_call_reload_tmp_%d_offset_%d", i, tmp_shadow_offset[i]);
                LLVMValueRef shadow_addr = LLVMBuildAdd(builder, shadow_pointer, shadow_off, get_next_var_name(var_name, dummy_slot_for_debug));
                LLVMValueRef shadow_p = LLVMBuildIntToPtr(builder, shadow_addr, LLVMPointerType(llvm_int_types[func_tmp_llvmtype[i]], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                LLVMValueRef val = LLVMBuildLoad2(builder, llvm_int_types[func_tmp_llvmtype[i]], shadow_p, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                LLVMBuildStore(builder, val, get_stack_alloca(op));
            }
        }
    }

    // Start from the one after ptr
    for (void *ptr_tmp = move_to_next(ptr); ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
        OpCodeType opc = get_opcode(ptr_tmp);
        handle_single_instr(opc, ptr_tmp);
        memcpy(tmp_var_available, tmp_var_available_backup, sizeof(tmp_var_available));
        if (is_opc_end_of_control_flow(opc, ptr_tmp)) {
            while (get_current_active_label_cnt(second_half_func)) {
                uint8_t *current_active_labels = get_current_active_labels(second_half_func);
                uint8_t tgt_lbl = current_active_labels[0];
                void *ptr_tmp = NULL;
                for (ptr_tmp = ptr_init; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
                    OpCodeType opc = get_opcode(ptr_tmp);
                    if (opc == set_label && get_label(ptr_tmp) == tgt_lbl) {
                        break;
                    }
                }
                assert(ptr_tmp < ptr_max);
                for (; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
                    OpCodeType opc = get_opcode(ptr_tmp);
                    handle_single_instr(opc, ptr_tmp);
                    memcpy(tmp_var_available, tmp_var_available_backup, sizeof(tmp_var_available));
                    if (is_opc_end_of_control_flow(opc, ptr_tmp)) {
                        break;
                    }
                }
            }
            break;
        }
    }
    llvm_func = NULL;
#ifdef DEBUG
    printf("<<<%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
}

void translate_call(OpCodeType opc, void *ptr) {
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    HelperType h = get_helper(ptr);
    if (h == helper_jmp_ind) {
        return translate_short_circuit_jmp_ind(opc, ptr);
#if AOT_LEVEL == AOT_LEVEL_MAX
    } else if (h == helper_cc_compute_all || h == helper_cc_compute_c || h == helper_cc_compute_nz) {
        if (helper_require_exception_path[h]) {
            return translate_helper_outband(opc, ptr);
        } else {
            return translate_cc_compute_inband(opc, ptr);
        }
    } else if (IS_XMM_HELPER(h)) {
        return translate_helper_outband(opc, ptr);
#endif
    }
#ifdef DEBUG
    printf(">>>%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
    // Store tmp_shadow_offset[this call][non-zero offset] contents to the shadow_stack
    LLVMValueRef shadow_pointer = NULL;
    for (int i = 0; i < (1<<STACK_INDEX_SHIFT); ++i) {
        if (tmp_shadow_offset[i]) {
            OperandType op;
            op.s.valid = 1;
            op.s.slot_type = SUB_SLOT_TMP;
            op.s.slot_idx = i;
            if (!has_alias(op)) {
                LLVMValueRef val = get_source_node_imm_or_stack(opc, 0, op, func_tmp_llvmtype[i], 0);
                LLVMValueRef shadow_off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], tmp_shadow_offset[i], 0);
                if (!shadow_pointer) {
                    LLVMValueRef env_raw = get_env_ptr_raw();
                    LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], -8UL, 0);
                    LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                    shadow_pointer = LLVMBuildLoad2(builder, llvm_int_types[OPC_ADDR_T], pointer, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                }
                char var_name[128] = {0};
                sprintf(var_name, "cross_call_spill_tmp_%d_offset_%d", i, tmp_shadow_offset[i]);
                LLVMValueRef shadow_addr = LLVMBuildAdd(builder, shadow_pointer, shadow_off, get_next_var_name(var_name, dummy_slot_for_debug));
                LLVMValueRef shadow_p = LLVMBuildIntToPtr(builder, shadow_addr, LLVMPointerType(llvm_int_types[func_tmp_llvmtype[i]], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                LLVMBuildStore(builder, val, shadow_p);
            }
        }
    }

    char second_half_name[64];
    uint8_t call_idx = get_idx_for_call_helper(ptr);
    sprintf(second_half_name, "%s%sfunc_%lx_call%d", func_name_prefix, func_name_prefix[0] ? "_" : "", current_func_offset, call_idx);
    OperandType operands[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm[MAX_OPERANDS_COUNT] = {0};

    int operands_cnt = 0;
    do {
        operands[operands_cnt] = get_operand(ptr, (operands_cnt + (HELPER_DEFINES_OUTPUT(h) ? 1 : 0)), &is_imm[operands_cnt]);
        if (is_imm[operands_cnt] == 0 && operands[operands_cnt].s.valid == 0) {
            break;
        }
        operands_cnt += 1;
    } while (1);
    assert(operands_cnt <= MAX_OPERANDS_COUNT);
#ifdef DEBUG
    printf("%s_%s defines_output:%d operands_cnt:%d\n", helper_str[h], second_half_name, HELPER_DEFINES_OUTPUT(h), operands_cnt); fflush(NULL);
#endif
    // Get the second half
    uint8_t second_half_disabled = is_tail_call(h);
    uint8_t second_half_already_exists = 0;
    LLVMValueRef second_half_func = LLVMGetNamedFunction(module, second_half_name);
    if (!second_half_func) {
#ifdef DEBUG
        printf("creating %s\n", second_half_name); fflush(NULL);
#endif
        LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS] = {NULL};
        int call_arg_cnt = collect_arguments_and_types(h, TARGET_QEMUAOT_HELPER_SECOND_HALF, TYPE_ONLY, NULL, NULL, 0, NULL, NULL, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS), NULL, second_half_name);
        LLVMTypeRef func_type = LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnt, 0);
        second_half_func = LLVMAddFunction(module, second_half_name, func_type);
        LLVMAddAttributeAtIndex(second_half_func, -1, AlwaysInlineAttr);
        LLVMAddAttributeAtIndex(second_half_func, -1, target_features_attr);
        LLVMSetFunctionCallConv(second_half_func, QEMUAOT_CC);
        register_labels_for_func(second_half_func);
    } else {
        second_half_already_exists = 1;
    }

    // Get the helper
    LLVMValueRef helper_func = LLVMGetNamedFunction(module, helper_str[h]);
    if (!helper_func) {
        LLVMTypeRef call_types[MAX_ADDED_ARGS] = {NULL};
        int call_arg_cnt = collect_arguments_and_types(h, TARGET_DEFAULT_HELPER_PASSTHROUGH_VECTOR, TYPE_ONLY, operands, is_imm, operands_cnt, NULL, NULL, llvm_func, call_types, MAX_ADDED_ARGS, NULL, helper_str[h]);
        LLVMTypeRef helper_type = LLVMFunctionType(llvm_int_types[helper_return_type[h]], call_types, call_arg_cnt, 0);
        helper_func = LLVMAddFunction(module, helper_str[h], helper_type);
    }
    LLVMValueRef second_half_addr = LLVMBuildPtrToInt(builder, second_half_func, llvm_int_types[OPC_ADDR_T], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    // Trampoline handles register-context switch
    // Check if argument slot is full on DEF_HELPER_FLAGS_7
    int param_cnt = 0;
    for (int i = 0; i < operands_cnt; ++i) {
        if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) {
            continue;
        }
        param_cnt += 1;
    }
    LLVMValueRef trampoline = get_trampoline(helper_func, second_half_disabled ? 0 : 1, HELPER_DEFINES_OUTPUT(h), operands, is_imm, operands_cnt, second_half_func, 0, NULL, param_cnt == MAX_ADDED_ARGS, TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_WI_VECTOR);
    LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    int call_arg_cnt = collect_arguments_and_types(h, TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_WI_VECTOR, TYPE_AND_VALUE, operands, is_imm, operands_cnt, param_cnt == MAX_ADDED_ARGS ? NULL : second_half_addr, NULL, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT), call_args, LLVMGetValueName(trampoline));
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT));
    LLVMTypeRef trampoline_type = LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnt, 0);
    LLVMValueRef call_trampoline_inst = LLVMBuildCall2(builder, trampoline_type, trampoline, call_args, call_arg_cnt, "");
    LLVMSetTailCall(call_trampoline_inst, 1);
    LLVMSetInstructionCallConv(call_trampoline_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);

    LLVMValueRef llvm_func_backup = llvm_func;
    void *ptr_init = get_instr_buffer();
    void *ptr_max = ptr_init + get_instr_buffer_size();
    // Check if we got remaining BBs
    do {
        llvm_func = llvm_func_backup;
        uint8_t current_active_label_cnt = get_current_active_label_cnt(llvm_func);
        if (!current_active_label_cnt) {
            break;
        }
        uint8_t *current_active_labels = get_current_active_labels(llvm_func);
        uint8_t tgt_lbl = current_active_labels[0];
        void *ptr_tmp = NULL;
        for (ptr_tmp = ptr_init; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
            OpCodeType opc = get_opcode(ptr_tmp);
            if (opc == set_label && get_label(ptr_tmp) == tgt_lbl) {
                break;
            }
        }
        assert(ptr_tmp < ptr_max);
        for (; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
            OpCodeType opc = get_opcode(ptr_tmp);
            handle_single_instr(opc, ptr_tmp);
            memcpy(tmp_var_available, tmp_var_available_backup, sizeof(tmp_var_available));
            if (is_opc_end_of_control_flow(opc, ptr_tmp)) {
                break;
            }
        }
    } while (1);

    if (second_half_disabled || second_half_already_exists) {
#ifdef DEBUG
        printf("<<<%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
        return;
    }

    /// Setup and finish the second-half function
    llvm_func = second_half_func;
    for (int j = 0; j < FIXED_VECTOR_PARAM_COUNT; j++) {
        LLVMValueRef param = LLVMGetParam(llvm_func, j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }
    if (HELPER_DEFINES_OUTPUT(h)) {
        assert(FIXED_VECTOR_PARAM_COUNT < LLVMCountParams(llvm_func));
        LLVMValueRef param = LLVMGetParam(llvm_func, FIXED_VECTOR_PARAM_COUNT);
        LLVMSetValueName(param, "helper_result");
    }

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);
    last_active_bb = entry;

    setup_func_stack();

    // Get output from helper func
    if (HELPER_DEFINES_OUTPUT(h)) {
        uint32_t is_imm;
        OperandType oarg = get_operand(ptr, 0, &is_imm);
        assert(!is_imm && oarg.s.valid);
        assert(FIXED_VECTOR_PARAM_COUNT < LLVMCountParams(llvm_func));
        LLVMValueRef param = LLVMGetParam(llvm_func, FIXED_VECTOR_PARAM_COUNT);
        if (oarg.s.slot_type == SUB_SLOT_TMP && has_alias(oarg)) {
            unregister_alias(oarg);
        }
        if (helper_return_type[h] < LLVMInt64) {
            param = LLVMBuildTrunc(builder, param, llvm_int_types[helper_return_type[h]], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        }
        do_store(opc, param, helper_return_type[h], oarg);
    }

    // Reload tmp_shadow_offset[this call][non-zero offset] contents
    shadow_pointer = NULL;
    for (int i = 0; i < (1<<STACK_INDEX_SHIFT); ++i) {
        if (tmp_shadow_offset[i]) {
            OperandType op;
            op.s.valid = 1;
            op.s.slot_type = SUB_SLOT_TMP;
            op.s.slot_idx = i;
            if (!has_alias(op)) {
                LLVMValueRef shadow_off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], tmp_shadow_offset[i], 0);
                if (!shadow_pointer) {
                    LLVMValueRef env_raw = get_env_ptr_raw();
                    LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], -8UL, 0);
                    LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                    shadow_pointer = LLVMBuildLoad2(builder, llvm_int_types[OPC_ADDR_T], pointer, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                }
                char var_name[128] = {0};
                sprintf(var_name, "cross_call_reload_tmp_%d_offset_%d", i, tmp_shadow_offset[i]);
                LLVMValueRef shadow_addr = LLVMBuildAdd(builder, shadow_pointer, shadow_off, get_next_var_name(var_name, dummy_slot_for_debug));
                LLVMValueRef shadow_p = LLVMBuildIntToPtr(builder, shadow_addr, LLVMPointerType(llvm_int_types[func_tmp_llvmtype[i]], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                LLVMValueRef val = LLVMBuildLoad2(builder, llvm_int_types[func_tmp_llvmtype[i]], shadow_p, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
                LLVMBuildStore(builder, val, get_stack_alloca(op));
            }
        }
    }

    // Start from the one after ptr
    for (void *ptr_tmp = move_to_next(ptr); ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
        OpCodeType opc = get_opcode(ptr_tmp);
        handle_single_instr(opc, ptr_tmp);
        memcpy(tmp_var_available, tmp_var_available_backup, sizeof(tmp_var_available));
        if (is_opc_end_of_control_flow(opc, ptr_tmp)) {
            while (get_current_active_label_cnt(second_half_func)) {
                uint8_t *current_active_labels = get_current_active_labels(second_half_func);
                uint8_t tgt_lbl = current_active_labels[0];
                void *ptr_tmp = NULL;
                for (ptr_tmp = ptr_init; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
                    OpCodeType opc = get_opcode(ptr_tmp);
                    if (opc == set_label && get_label(ptr_tmp) == tgt_lbl) {
                        break;
                    }
                }
                assert(ptr_tmp < ptr_max);
                for (; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
                    OpCodeType opc = get_opcode(ptr_tmp);
                    handle_single_instr(opc, ptr_tmp);
                    memcpy(tmp_var_available, tmp_var_available_backup, sizeof(tmp_var_available));
                    if (is_opc_end_of_control_flow(opc, ptr_tmp)) {
                        break;
                    }
                }
            }
            break;
        }
    }
    llvm_func = NULL;
#ifdef DEBUG
    printf("<<<%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr); fflush(NULL);
#endif
}

static void cleanup_func_resource() {
#ifdef DEBUG
    printf("%s\n", __FUNCTION__); fflush(NULL);
#endif
    reset_instr_buffer();
    for (int i = 0; i < (1<<STACK_INDEX_SHIFT); ++i) {
        alias_tmp[i].i = 0;
    }
    ir_var_name_idx = 0;
    current_func_offset = 0;
    br_cnt = 0;
    current_call_idx = 0;
    shadow_call_offset = 16;
    xreg_valid = 0;
    xmm_valid = 0;
    tmp_valid_non_zero = 0;
    memset(tmp_valid, 0, sizeof(tmp_valid));;
    memset(tmp_var_available, 0, sizeof(tmp_var_available));
    memset(tmp_var_available_backup, 0, sizeof(tmp_var_available_backup));
    memset(tmp_bits_type, 0, sizeof(tmp_bits_type));
    memset(tmp_shadow_offset, 0, sizeof(tmp_shadow_offset));
    reset_tmp_mapping();

    // Cleanup hash-tables
    GHashTableIter iter;
    gpointer key, value;

#define FREE_HASH_TABLE(TABEL, ENTRY_TYPE)                              \
    do {                                                                \
        g_hash_table_iter_init(&iter, TABEL);                           \
        while (g_hash_table_iter_next(&iter, &key, &value)) {           \
            ENTRY_TYPE *info = (ENTRY_TYPE *)value;                     \
            while (info) {                                              \
                ENTRY_TYPE *next = info->next;                          \
                free(info);                                             \
                info = next;                                            \
            }                                                           \
            g_hash_table_iter_remove(&iter);                            \
        }                                                               \
    } while (0)

    FREE_HASH_TABLE(current_active_label_info, active_label_info_t);
    FREE_HASH_TABLE(current_helper_aux_info, helper_aux_info_t);
}

static void setup_func_stack() {
    memset(fixed_vector_param_in_stack, 0, sizeof(fixed_vector_param_in_stack));
    memset(func_xmm_alloca, 0, sizeof(func_xmm_alloca));

    if (xreg_valid) {
        for (XRegType x = 0; x < XREG_MAX; ++x) {
            if (xreg_valid & (1UL<<x)) {
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[x]], fixed_vector_stack_names[x]);
                LLVMSetAlignment(alloca_inst, 8);
                func_xreg_alloca[x] = alloca_inst;
                func_xreg_llvmtype[x] = fixed_vector_param_llvmtypes[x];
                LLVMBuildStore(builder, LLVMGetParam(llvm_func, x), alloca_inst);
                fixed_vector_param_in_stack[x] = 1;
            }
        }
    }
#ifdef VERBOSE_VAR
    static char tmp_name_buf[1<<STACK_INDEX_SHIFT][64];
#endif
    if (tmp_valid_non_zero) {
        for (int i = 0; i < (1<<STACK_INDEX_SHIFT); ++i) {
            if (tmp_available_test(tmp_valid, i)) {
                assert(tmp_bits_type[i]);
#ifdef VERBOSE_VAR
                OperandType slot_name_for_debug;
                slot_name_for_debug.s.valid = 1;
                slot_name_for_debug.s.slot_type = SUB_SLOT_TMP;
                slot_name_for_debug.s.slot_idx = i;
                OperandType orig_slot = get_original_slot_for_debug(slot_name_for_debug);
                if (orig_slot.s.valid) {
                    snprintf(tmp_name_buf[i], sizeof(tmp_name_buf[i]), "tmp%d_%s%d.stack", i, orig_slot.s.slot_type == SUB_SLOT_TMPL ? "loc" : "tmp", orig_slot.s.slot_idx);
                    tmp_stack_names[i] = tmp_name_buf[i];
                }
#endif
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[tmp_bits_type[i]], tmp_stack_names[i]);
                func_tmp_alloca[i] = alloca_inst;
                func_tmp_llvmtype[i] = tmp_bits_type[i];
                LLVMSetAlignment(alloca_inst, tmp_bits_type[i] <= LLVMInt64 ? 8 : 16);
            }
        }
    }
    if (xmm_valid) {
        for (int i = 0; i < (1<<REGISTER_INDEX_SHIFT); ++i) {
            if (xmm_valid & (1UL<<i)) {
                assert((XREG_MAX + i) < FIXED_VECTOR_PARAM_COUNT);
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[XREG_MAX + i]], fixed_vector_stack_names[XREG_MAX + i]);
                func_xmm_alloca[i] = alloca_inst;
                func_xmm_llvmtype[i] = fixed_vector_param_llvmtypes[XREG_MAX + i];
                LLVMSetAlignment(alloca_inst, 16);
                LLVMBuildStore(builder, LLVMGetParam(llvm_func, FIXED_PARAM_COUNT + i), func_xmm_alloca[i]);
                fixed_vector_param_in_stack[FIXED_PARAM_COUNT + i] = 1;
            }
        }
    }
}

static void register_labels_for_func(LLVMValueRef func) {
    active_label_info_t *label_info = (active_label_info_t *)calloc(1, sizeof(active_label_info_t));
    label_info->llvm_func = func;
    active_label_info_t *info = g_hash_table_lookup(current_active_label_info, func);
    if (!info) {
        g_hash_table_insert(current_active_label_info, func, label_info);
    } else {
        while (info->next) {
            assert(info->llvm_func != func);
            info = info->next;
        }
        assert(info->llvm_func != func);
        info->next = label_info;
    }
}

static int process_op_type(uint32_t slot_idx, void *ptr, OpCodeType opc, LLVMType vtype, uint32_t noargs, uint8_t *tmp_has_known_def) {
    uint32_t is_imm = 0;
    OperandType operand = get_operand(ptr, slot_idx, &is_imm);
    // End-of-operands
    if (!is_imm && !operand.s.valid) {
        return 0;
    }
    LLVMType operand_type = vtype == LLVMInvalidType ?
                        (opcmem_addr_nzidx[opc] > 0 ?
                         ((slot_idx < opcmem_addr_nzidx[opc]) ? OPC_REG_T : OPC_ADDR_T) :
                         (slot_idx < opcoc[opc] ? OPC_OUTPUT_T : OPC_INPUT_T)) :
                        vtype;
    if (slot_idx == 0 && opc == call) {
        HelperType h = get_helper(ptr);
        if (helper_return_type[h] != LLVMInvalidType) {
            operand_type = helper_return_type[h];
        }
    }
    if (is_imm == 0) {
        if (operand.s.slot_type == SUB_SLOT_XREG) {
            xreg_valid |= (1UL<<operand.s.slot_idx);
        } else if (operand.s.slot_type == SUB_SLOT_TMP) {
            tmp_valid_non_zero = 1;
            tmp_available_set(tmp_valid, operand.s.slot_idx);
            tmp_available_clear(tmp_var_available, operand.s.slot_idx);
            if (tmp_bits_type[operand.s.slot_idx] < operand_type) {
                tmp_bits_type[operand.s.slot_idx] = operand_type;
            }
        } else if (operand.s.slot_type == SUB_SLOT_XMM) {
            xmm_valid |= (1UL<<operand.s.slot_idx);
        }
        if (operand.s.slot_type == SUB_SLOT_TMP) {
            if ((opc == call && slot_idx >= noargs) || (opc != call && slot_idx >= opcoc[opc])) {
                if (!tmp_has_known_def[operand.s.slot_idx]) {
                    // At this stage, we do not have alias information yet, so we need to check later
#ifdef DEBUG
                    OperandType orig_slot = get_original_slot_for_debug(operand);
                    printf("  register cross_call tmp:%d orig:%s%d\n", operand.s.slot_idx, orig_slot.s.valid ? (orig_slot.s.slot_type == SUB_SLOT_TMPL ? "loc" : "tmp") : "NA", orig_slot.s.valid ? orig_slot.s.slot_idx : 0); fflush(NULL);
#endif
                    if (tmp_shadow_offset[operand.s.slot_idx] == 0) {
                        tmp_shadow_offset[operand.s.slot_idx] = (0 - shadow_call_offset);
                        shadow_call_offset += 16;
                    }
                }
            }
            if ((opc == call && slot_idx < noargs) || (opc != call && slot_idx < opcoc[opc])) {
                tmp_has_known_def[operand.s.slot_idx] = 1;
            }
        }
    }
    return 1;
}

void handle_func(uint64_t val) {
#ifdef DEBUG
    printf("func %lx\n", val); fflush(NULL);
#endif
    current_func_offset = val;
    ir_var_name_idx = 0;
    memset(tmp_var_available, 0xff, sizeof(tmp_var_available));
    void *ptr_init = get_instr_buffer();
    void *ptr_max = ptr_init + get_instr_buffer_size();
    void *ptr;
    /// Loop through all xreg/slot/xmm, handle arguments, stack alloc/store etc.
    uint8_t tmp_has_known_def[1<<STACK_INDEX_SHIFT] = {0};
    for (ptr = ptr_init; ptr < ptr_max; ptr = move_to_next(ptr)) {
        OpCodeType opc = get_opcode(ptr);
        uint32_t noargs = 0;
        OperandType oarg;
        uint32_t is_immo;
        oarg.s.valid = 0;
        if (opc == call) {
            noargs = HELPER_DEFINES_OUTPUT(get_helper(ptr));
            if (noargs) {
                oarg = get_operand(ptr, 0, &is_immo);
                assert(!is_immo && oarg.s.valid);
            }
            register_idx_for_call_helper(ptr, current_call_idx);
        }
        uint8_t is_vec = is_vector(ptr);
        LLVMType vtype = LLVMInvalidType;
        if (is_vec) {
          vtype = get_llvm_vector_type(ptr);
        }
        // Input arguments first
        uint32_t slot_idx = opc == call ? noargs : opcoc[opc];
        do {
            if (!process_op_type(slot_idx, ptr, opc, vtype, noargs, tmp_has_known_def)) {
                break;
            }
            slot_idx += 1;
        } while (1);

        // Output argument
        if (opc == call ? noargs : opcoc[opc]) {
            process_op_type(0, ptr, opc, vtype, noargs, tmp_has_known_def);
        }

        if (opc == call) {
            memset(tmp_has_known_def, 0, sizeof(tmp_has_known_def));
            if (!is_immo && oarg.s.valid && oarg.s.slot_type == SUB_SLOT_TMP) {
                tmp_has_known_def[oarg.s.slot_idx] = 1;
            }
            current_call_idx += 1;
            assert(current_call_idx < BB_MAX_CNT);
        }
    }
    memcpy(tmp_var_available_backup, tmp_var_available, sizeof(tmp_var_available_backup));

    char func_name[64];
    sprintf(func_name, "%s%sfunc_%lx", func_name_prefix, func_name_prefix[0] ? "_" : "", val);
    llvm_func = get_or_add_func_with_qemuaot_cc(func_name, 0, NoInlineAttr);
    for (int j = 0; j < FIXED_VECTOR_PARAM_COUNT; j++) {
        LLVMValueRef param = LLVMGetParam(llvm_func, j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }
    register_labels_for_func(llvm_func);
    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);
    last_active_bb = entry;

    setup_func_stack();

    // Handle each IR translation
    LLVMValueRef llvm_func_backup = llvm_func;
    for (ptr = ptr_init; ptr < ptr_max; ptr = move_to_next(ptr)) {
        OpCodeType opc = get_opcode(ptr);
        handle_single_instr(opc, ptr);
        memcpy(tmp_var_available, tmp_var_available_backup, sizeof(tmp_var_available));
        if (is_opc_end_of_control_flow(opc, ptr)) {
            while (get_current_active_label_cnt(llvm_func_backup)) {
                uint8_t *current_active_labels = get_current_active_labels(llvm_func_backup);
                uint8_t tgt_lbl = current_active_labels[0];
                void *ptr_tmp = NULL;
                for (ptr_tmp = ptr_init; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
                    OpCodeType opc = get_opcode(ptr_tmp);
                    if (opc == set_label && get_label(ptr_tmp) == tgt_lbl) {
                        break;
                    }
                }
                assert(ptr_tmp < ptr_max);
                for (; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
                    OpCodeType opc = get_opcode(ptr_tmp);
                    handle_single_instr(opc, ptr_tmp);
                    memcpy(tmp_var_available, tmp_var_available_backup, sizeof(tmp_var_available));
                    if (is_opc_end_of_control_flow(opc, ptr_tmp)) {
                        break;
                    }
                }
            }
            break;
        }
    }

    cleanup_func_resource();
}

static void handle_single_instr(OpCodeType opc, void *ptr) {
#if 0
    printf("handle_single_instr: %s ptr:%lx", opcode_type_str[opc], ptr); fflush(NULL);
    void *next = move_to_next(ptr);
    unsigned char *byte = (unsigned char *)ptr;
    while (byte != (unsigned char *)next) {
        printf(" %02x", byte[0]);
        byte += 1;
    }
    printf("\n"); fflush(NULL);
#endif
    switch (opc) {
    case addc1o_i32:
    case addc1o_i64:
    case addci_i32:
    case addci_i64:
    case addcio_i32:
    case addcio_i64:
    case addco_i32:
    case addco_i64:
    case subb1o_i32:
    case subb1o_i64:
    case subbi_i32:
    case subbi_i64:
    case subbio_i32:
    case subbio_i64:
    case subbo_i32:
    case subbo_i64:
    case brcond_i32:
    case divs2_i32:
    case divs2_i64:
    case divu2_i32:
    case divu2_i64:
    case dup_vec:
        assert(0);
        break;

    case abs_vec:
        translate_abs_vec(opc, ptr);
        break;
    case bitsel_vec:
        translate_bitsel_vec(opc, ptr);
        break;
    case cmpsel_vec:
        translate_cmpsel_vec(opc, ptr);
        break;
    case ctpop_i32:
    case ctpop_i64:
        translate_ctpop(opc, ptr);
        break;
    case divs_i32:
    case divs_i64:
        translate_binary(opc, ptr, LLVMBuildSDiv);
        break;
    case divu_i32:
    case divu_i64:
        translate_binary(opc, ptr, LLVMBuildUDiv);
        break;
    case rems_i32:
    case rems_i64:
        translate_binary(opc, ptr, LLVMBuildSRem);
        break;
    case remu_i32:
    case remu_i64:
        translate_binary(opc, ptr, LLVMBuildURem);
        break;
    case rotli_vec:
    case rotls_vec:
        translate_rotl_vec(opc, ptr);
        break;
    case rotlv_vec:
        translate_rotlv_vec(opc, ptr);
        break;
    case rotrv_vec:
        translate_rotrv_vec(opc, ptr);
        break;
    case sari_vec:
    case sars_vec:
        translate_binary_splat_immediate(opc, ptr, LLVMBuildAShr);
        break;
    case sarv_vec:
        translate_binary(opc, ptr, LLVMBuildAShr);
        break;
    case shlv_vec:
        translate_binary(opc, ptr, LLVMBuildShl);
        break;
    case shrv_vec:
        translate_binary(opc, ptr, LLVMBuildLShr);
        break;
    case smax_vec:
        translate_binary_intrinsic(opc, ptr, "llvm.smax");
        break;
    case smin_vec:
        translate_binary_intrinsic(opc, ptr, "llvm.smin");
        break;
    case ssadd_vec:
        translate_binary_intrinsic(opc, ptr, "llvm.sadd.sat");
        break;
    case sssub_vec:
        translate_binary_intrinsic(opc, ptr, "llvm.ssub.sat");
        break;
    case usadd_vec:
        translate_binary_intrinsic(opc, ptr, "llvm.uadd.sat");
        break;
    case ussub_vec:
        translate_binary_intrinsic(opc, ptr, "llvm.usub.sat");
        break;
    case add_i64:
        translate_add_i64(opc, ptr);
        break;
    case add_i32:
    case add_vec:
        translate_binary(opc, ptr, LLVMBuildAdd);
        break;
    case andc_i32:
    case andc_i64:
    case andc_vec:
        translate_andc(opc, ptr);
        break;
    case and_i32:
    case and_i64:
    case and_vec:
        translate_binary(opc, ptr, LLVMBuildAnd);
        break;
    case nor_i32:
    case nor_i64:
    case nor_vec:
        translate_nor(opc, ptr);
        break;
    case orc_i32:
    case orc_i64:
    case orc_vec:
        translate_orc(opc, ptr);
        break;
    case nand_i32:
    case nand_i64:
    case nand_vec:
        translate_nand(opc, ptr);
        break;
    case eqv_i32:
    case eqv_i64:
    case eqv_vec:
        translate_eqv(opc, ptr);
        break;
    case bswap16_i32:
        translate_bswap16_i32(opc, ptr);
        break;
    case bswap16_i64:
        translate_bswap16_i64(opc, ptr);
        break;
    case bswap32_i32:
        translate_bswap32_i32(opc, ptr);
        break;
    case bswap32_i64:
        translate_bswap32_i64(opc, ptr);
        break;
    case bswap64_i64:
        translate_bswap64_i64(opc, ptr);
        break;
    case clz_i32:
        translate_count_zero(opc, ptr, "llvm.ctlz.i32");
        break;
    case clz_i64:
        translate_count_zero(opc, ptr, "llvm.ctlz.i64");
        break;
    case cmp_vec:
        translate_cmp_vec(opc, ptr);
        break;
    case ctz_i32:
        translate_count_zero(opc, ptr, "llvm.cttz.i32");
        break;
    case ctz_i64:
        translate_count_zero(opc, ptr, "llvm.cttz.i64");
        break;
    case deposit_i32:
    case deposit_i64:
        translate_deposit(opc, ptr);
        break;
    case dupm_vec:
        translate_dupm_vec(opc, ptr);
        break;
    case extract2_i32:
    case extract2_i64:
        translate_extract2(opc, ptr);
        break;
    case extract_i32:
    case extract_i64:
        translate_extract(opc, ptr);
        break;
    case extrh_i64_i32:
        translate_extrh(opc, ptr);
        break;
    case extrl_i64_i32:
    case mov_i32:
    case mov_i64:
    case mov_vec:
        translate_mov(opc, ptr);
        break;
    case ext_i32_i64:
        translate_ext(opc, ptr, LLVMBuildSExt);
        break;
    case extu_i32_i64:
        translate_ext(opc, ptr, LLVMBuildZExt);
        break;
    case movcond_i32:
    case movcond_i64:
    case movcond_vec:
        translate_movcond(opc, ptr);
        break;
    case mul_i32:
    case mul_i64:
    case mul_vec:
        translate_binary(opc, ptr, LLVMBuildMul);
        break;
    case mulsh_i32:
    case mulsh_i64:
        translate_mulxh(opc, ptr, LLVMBuildSExt);
        break;
    case muluh_i32:
    case muluh_i64:
        translate_mulxh(opc, ptr, LLVMBuildZExt);
        break;
    case muls2_i32:
    case muls2_i64:
        translate_muls2(opc, ptr);
        break;
    case mulu2_i32:
    case mulu2_i64:
        translate_mulu2(opc, ptr);
        break;
    case neg_i32:
    case neg_i64:
    case neg_vec:
        translate_neg(opc, ptr);
        break;
    case negsetcond_i32:
    case negsetcond_i64:
        translate_negsetcond(opc, ptr);
        break;
    case not_i32:
    case not_i64:
    case not_vec:
        translate_not(opc, ptr);
        break;
    case or_i32:
    case or_i64:
        translate_binary(opc, ptr, LLVMBuildOr);
        break;
    case or_vec:
        translate_binary(opc, ptr, LLVMBuildOr);
        break;
    case push_ret_addr:
        translate_push_ret_addr(opc, ptr);
        break;
    case ld8u_i32:
    case ld8u_i64:
    case ld16u_i32:
    case ld16u_i64:
    case ld32u_i64:
        translate_ld_ext(opc, ptr, LLVMBuildZExt);
        break;
    case ld8s_i32:
    case ld8s_i64:
    case ld16s_i32:
    case ld16s_i64:
    case ld32s_i64:
        translate_ld_ext(opc, ptr, LLVMBuildSExt);
        break;
    case ld_vec:
        translate_ld_vec(opc, ptr);
        break;
    case ld_i32:
    case ld_i64:
        translate_ld_env_xmm(opc, ptr);
        break;
    case qemu_ld2_i128:
        translate_qemu_ld2_i128(opc, ptr);
        break;
    case qemu_ld_i32:
    case qemu_ld_i64:
        translate_qemu_ld(opc, ptr);
        break;
    case qemu_st2_i128:
        translate_qemu_st2_i128(opc, ptr);
        break;
    case qemu_st_i32:
    case qemu_st_i64:
        translate_qemu_st(opc, ptr);
        break;
    case st8_i32:
    case st8_i64:
    case st16_i32:
    case st16_i64:
    case st32_i64:
    case st_i32:
    case st_i64:
        translate_st(opc, ptr);
        break;
    case st_vec:
        translate_st_vec(opc, ptr);
        break;
    case ret:
        translate_ret(opc, ptr);
        break;
    case rotr_i32:
    case rotr_i64:
        translate_rotr(opc, ptr);
        break;
    case rotl_i32:
    case rotl_i64:
        translate_rotl(opc, ptr);
        break;
    case sar_i32:
    case sar_i64:
        translate_binary(opc, ptr, LLVMBuildAShr);
        break;
    case setcond_i32:
    case setcond_i64:
        translate_setcond(opc, ptr);
        break;
    case sextract_i32:
    case sextract_i64:
        translate_sextract(opc, ptr);
        break;
    case shl_i32:
    case shl_i64:
        translate_binary(opc, ptr, LLVMBuildShl);
        break;
    case shli_vec:
    case shls_vec:
        translate_binary_splat_immediate(opc, ptr, LLVMBuildShl);
        break;
    case shri_vec:
    case shrs_vec:
        translate_binary_splat_immediate(opc, ptr, LLVMBuildLShr);
        break;
    case shr_i32:
    case shr_i64:
        translate_binary(opc, ptr, LLVMBuildLShr);
        break;
    case sub_i32:
    case sub_i64:
        translate_binary(opc, ptr, LLVMBuildSub);
        break;
    case sub_vec:
        translate_binary(opc, ptr, LLVMBuildSub);
        break;
    case umax_vec:
        translate_maxmin_vec(opc, ptr, gtu);
        break;
    case umin_vec:
        translate_maxmin_vec(opc, ptr, ltu);
        break;
    case xor_i32:
    case xor_i64:
    case xor_vec:
        translate_binary(opc, ptr, LLVMBuildXor);
        break;
    case set_label:
        translate_set_label(opc, ptr);
        break;
    case brcond_i64:
        translate_brcond_i64(opc, ptr);
        break;
    case jmp_direct:
        translate_jmp_direct(opc, ptr);
        break;
    case discard:
        translate_discard(opc, ptr);
        break;
    case call:
        translate_call(opc, ptr);
        break;
    case br:
        translate_br(opc, ptr);
        break;
    default: assert(0);
    }
}

void module_prolog() {
    create_module("qemuaot");
    builder = LLVMCreateBuilder();

    // Parameter setup (same for all functions)
    LLVMTypeRef vscale_i64 = get_vector_parameter_type_for_arch();
    const char *base_names[XREG_MAX] = {
        "rax", "rcx", "rdx", "rbx",
        "rsp", "rbp", "rsi", "rdi",
        "r8", "r9", "r10", "r11",
        "r12", "r13", "r14", "r15",
#if AOT_LEVEL == AOT_LEVEL_MAX
        "cc_src", "cc_dst", "cc_op", "rip"
#elif AOT_LEVEL == AOT_LEVEL_0
        "rip"
#endif
    };
#if AOT_LEVEL == AOT_LEVEL_MAX
    for (int i = 0; i < FIXED_PARAM_COUNT; i++) {
        if (i < 16) {
            fixed_llvmtyperef[i] = LLVMInt64Type();
            fixed_vector_param_llvmtypes[i] = LLVMInt64;
        } else if (i == 16 || i == 17 || i == 19) {
            fixed_llvmtyperef[i] = LLVMInt64Type();
            fixed_vector_param_llvmtypes[i] = LLVMInt64;
        } else if (i == 18) {
            fixed_llvmtyperef[i] = LLVMInt32Type();
            fixed_vector_param_llvmtypes[i] = LLVMInt32;
        }
        fixed_vector_arg_names[i] = base_names[i];
    }
#elif AOT_LEVEL == AOT_LEVEL_0
    for (int i = 0; i < FIXED_PARAM_COUNT; i++) {
        fixed_llvmtyperef[i] = LLVMInt64Type();
        fixed_vector_param_llvmtypes[i] = LLVMInt64;
        fixed_vector_arg_names[i] = base_names[i];
    }
#endif
    static char extra_name_buf[32][16];
    static char stack_name_buf[FIXED_VECTOR_PARAM_COUNT][16];
    static char tmp_name_buf[1<<STACK_INDEX_SHIFT][16];
    for (int i = 0; i < (FIXED_VECTOR_PARAM_COUNT - FIXED_PARAM_COUNT)/2; ++i) {
        int idx = FIXED_PARAM_COUNT + i * 2;
        fixed_llvmtyperef[idx] = vscale_i64;
        fixed_llvmtyperef[idx + 1] = vscale_i64;
        fixed_vector_param_llvmtypes[idx] = LLVMVector2xi64;
        fixed_vector_param_llvmtypes[idx + 1] = LLVMVector2xi64;
        snprintf(extra_name_buf[i * 2], sizeof(extra_name_buf[i * 2]), "xmm%d", i);
        snprintf(extra_name_buf[i * 2 + 1], sizeof(extra_name_buf[i * 2 + 1]), "ymm%d_h", i);
        fixed_vector_arg_names[idx] = extra_name_buf[i * 2];
        fixed_vector_arg_names[idx + 1] = extra_name_buf[i * 2 + 1];
    }
    for (int i = 0; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        snprintf(stack_name_buf[i], sizeof(stack_name_buf[i]), "%s.stack", fixed_vector_arg_names[i]);
        fixed_vector_stack_names[i] = stack_name_buf[i];
    }
    for (int i = 0; i < (1<<STACK_INDEX_SHIFT); ++i) {
        snprintf(tmp_name_buf[i], sizeof(tmp_name_buf[i]), "tmp%d.stack", i);
        tmp_stack_names[i] = tmp_name_buf[i];
    }
    static char ir_var_name_buffer[('z'-'a'+1)*('z'-'a'+1)*('z'-'a'+1)*('z'-'a'+1)][5];
    for (char c1 = 'a'; c1 <= 'z'; ++c1) {
        for (char c2 = 'a'; c2 <= 'z'; ++c2) {
            for (char c3 = 'a'; c3 <= 'z'; ++c3) {
                for (char c4 = 'a'; c4 <= 'z'; ++c4) {
                    int idx = (c1 - 'a') * ('z' - 'a' + 1) * ('z' - 'a' + 1) * ('z' - 'a' + 1) + (c2 - 'a') * ('z' - 'a' + 1) * ('z' - 'a' + 1) + (c3 - 'a') * ('z' - 'a' + 1) + (c4 - 'a');
                    ir_var_name_buffer[idx][0] = c1;
                    ir_var_name_buffer[idx][1] = c2;
                    ir_var_name_buffer[idx][2] = c3;
                    ir_var_name_buffer[idx][3] = c4;
                    ir_var_name_buffer[idx][4] = 0;
                    ir_var_name[idx] = ir_var_name_buffer[idx];
                }
            }
        }
    }

    llvm_int_types[LLVMInvalidType] = LLVMVoidType();
    llvm_int_types[LLVMInt8] = LLVMInt8Type();
    llvm_int_types[LLVMInt16] = LLVMInt16Type();
    llvm_int_types[LLVMInt32] = LLVMInt32Type();
    llvm_int_types[LLVMInt64] = LLVMInt64Type();

    llvm_int_store_types[LLVMInvalidType] = llvm_int_types[LLVMInvalidType];
    llvm_int_store_types[LLVMInt8] = llvm_int_types[LLVMInt8];
    llvm_int_store_types[LLVMInt16] = llvm_int_types[LLVMInt16];
    llvm_int_store_types[LLVMInt32] = llvm_int_types[LLVMInt32];
    llvm_int_store_types[LLVMInt64] = llvm_int_types[LLVMInt64];

#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    llvm_int_types[LLVMVector8xi8] = LLVMVectorType(LLVMInt8Type(), 8);
    llvm_int_types[LLVMVector4xi16] = LLVMVectorType(LLVMInt16Type(), 4);
    llvm_int_types[LLVMVector2xi32] = LLVMVectorType(LLVMInt32Type(), 2);
    llvm_int_types[LLVMVector1xi64] = LLVMVectorType(LLVMInt64Type(), 1);
    llvm_int_types[LLVMVector16xi8] = LLVMVectorType(LLVMInt8Type(), 16);
    llvm_int_types[LLVMVector8xi16] = LLVMVectorType(LLVMInt16Type(), 8);
    llvm_int_types[LLVMVector4xi32] = LLVMVectorType(LLVMInt32Type(), 4);
    llvm_int_types[LLVMVector2xi64] = LLVMVectorType(LLVMInt64Type(), 2);

    llvm_int_store_types[LLVMVector8xi8] = llvm_int_types[LLVMVector8xi8];
    llvm_int_store_types[LLVMVector4xi16] = llvm_int_types[LLVMVector4xi16];
    llvm_int_store_types[LLVMVector2xi32] = llvm_int_types[LLVMVector2xi32];
    llvm_int_store_types[LLVMVector1xi64] = llvm_int_types[LLVMVector1xi64];
    llvm_int_store_types[LLVMVector16xi8] = llvm_int_types[LLVMVector16xi8];
    llvm_int_store_types[LLVMVector8xi16] = llvm_int_types[LLVMVector8xi16];
    llvm_int_store_types[LLVMVector4xi32] = llvm_int_types[LLVMVector4xi32];
    llvm_int_store_types[LLVMVector2xi64] = llvm_int_types[LLVMVector2xi64];
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    // FIXME: v64
    llvm_int_types[LLVMVector16xi8] = LLVMScalableVectorType(LLVMInt8Type(), 8);
    llvm_int_types[LLVMVector8xi16] = LLVMScalableVectorType(LLVMInt16Type(), 4);
    llvm_int_types[LLVMVector4xi32] = LLVMScalableVectorType(LLVMInt32Type(), 2);
    llvm_int_types[LLVMVector2xi64] = LLVMScalableVectorType(LLVMInt64Type(), 1);
    llvm_int_types[LLVMVector32xi8] = LLVMScalableVectorType(LLVMInt8Type(), 16);
    llvm_int_types[LLVMVector16xi16] = LLVMScalableVectorType(LLVMInt16Type(), 8);
    llvm_int_types[LLVMVector8xi32] = LLVMScalableVectorType(LLVMInt32Type(), 4);
    llvm_int_types[LLVMVector4xi64] = LLVMScalableVectorType(LLVMInt64Type(), 2);

    llvm_int_store_types[LLVMVector16xi8] = LLVMVectorType(LLVMInt8Type(), 16);
    llvm_int_store_types[LLVMVector8xi16] = LLVMVectorType(LLVMInt16Type(), 8);
    llvm_int_store_types[LLVMVector4xi32] = LLVMVectorType(LLVMInt32Type(), 4);
    llvm_int_store_types[LLVMVector2xi64] = LLVMVectorType(LLVMInt64Type(), 2);
    llvm_int_store_types[LLVMVector32xi8] = LLVMVectorType(LLVMInt8Type(), 32);
    llvm_int_store_types[LLVMVector16xi16] = LLVMVectorType(LLVMInt16Type(), 16);
    llvm_int_store_types[LLVMVector8xi32] = LLVMVectorType(LLVMInt32Type(), 8);
    llvm_int_store_types[LLVMVector4xi64] = LLVMVectorType(LLVMInt64Type(), 4);
#endif

    llvm_vector_elem_bit_counts[LLVMInt8*2] = 1;
    llvm_vector_elem_bit_counts[LLVMInt8*2+1] = 8;
    llvm_vector_elem_bit_counts[LLVMInt16*2] = 1;
    llvm_vector_elem_bit_counts[LLVMInt16*2+1] = 16;
    llvm_vector_elem_bit_counts[LLVMInt32*2] = 1;
    llvm_vector_elem_bit_counts[LLVMInt32*2+1] = 32;
    llvm_vector_elem_bit_counts[LLVMInt64*2] = 1;
    llvm_vector_elem_bit_counts[LLVMInt64*2+1] = 64;
    llvm_vector_elem_bit_counts[LLVMVector8xi8*2] = 8;
    llvm_vector_elem_bit_counts[LLVMVector8xi8*2+1] = 8;
    llvm_vector_elem_bit_counts[LLVMVector4xi16*2] = 4;
    llvm_vector_elem_bit_counts[LLVMVector4xi16*2+1] = 16;
    llvm_vector_elem_bit_counts[LLVMVector2xi32*2] = 2;
    llvm_vector_elem_bit_counts[LLVMVector2xi32*2+1] = 32;
    llvm_vector_elem_bit_counts[LLVMVector1xi64*2] = 1;
    llvm_vector_elem_bit_counts[LLVMVector1xi64*2+1] = 64;
    llvm_vector_elem_bit_counts[LLVMVector16xi8*2] = 16;
    llvm_vector_elem_bit_counts[LLVMVector16xi8*2+1] = 8;
    llvm_vector_elem_bit_counts[LLVMVector8xi16*2] = 8;
    llvm_vector_elem_bit_counts[LLVMVector8xi16*2+1] = 16;
    llvm_vector_elem_bit_counts[LLVMVector4xi32*2] = 4;
    llvm_vector_elem_bit_counts[LLVMVector4xi32*2+1] = 32;
    llvm_vector_elem_bit_counts[LLVMVector2xi64*2] = 2;
    llvm_vector_elem_bit_counts[LLVMVector2xi64*2+1] = 64;
#if (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    llvm_vector_elem_bit_counts[LLVMVector32xi8*2] = 32;
    llvm_vector_elem_bit_counts[LLVMVector32xi8*2+1] = 8;
    llvm_vector_elem_bit_counts[LLVMVector16xi16*2] = 16;
    llvm_vector_elem_bit_counts[LLVMVector16xi16*2+1] = 16;
    llvm_vector_elem_bit_counts[LLVMVector8xi32*2] = 8;
    llvm_vector_elem_bit_counts[LLVMVector8xi32*2+1] = 32;
    llvm_vector_elem_bit_counts[LLVMVector4xi64*2] = 4;
    llvm_vector_elem_bit_counts[LLVMVector4xi64*2+1] = 64;
#endif

#if AOT_LEVEL == AOT_LEVEL_0
    env_var_offset[cc_src] = ENV_OFFSET_cc_src;
    env_var_offset[cc_dst] = ENV_OFFSET_cc_dst;
    env_var_offset[cc_op] = ENV_OFFSET_cc_op;
#endif
    env_var_offset[cc_src2] = ENV_OFFSET_cc_src2;
    env_var_offset[es_base] = ENV_OFFSET_es_base;
    env_var_offset[cs_base] = ENV_OFFSET_cs_base;
    env_var_offset[ss_base] = ENV_OFFSET_ss_base;
    env_var_offset[ds_base] = ENV_OFFSET_ds_base;
    env_var_offset[fs_base] = ENV_OFFSET_fs_base;
    env_var_offset[gs_base] = ENV_OFFSET_gs_base;

    llvm_predicate[eq] = LLVMIntEQ;
    llvm_predicate[ge] = LLVMIntSGE;
    llvm_predicate[geu] = LLVMIntUGE;
    llvm_predicate[gt] = LLVMIntSGT;
    llvm_predicate[gtu] = LLVMIntUGT;
    llvm_predicate[le] = LLVMIntSLE;
    llvm_predicate[leu] = LLVMIntULE;
    llvm_predicate[lt] = LLVMIntSLT;
    llvm_predicate[ltu] = LLVMIntULT;
    llvm_predicate[ne] = LLVMIntNE;

    current_active_label_info = g_hash_table_new(NULL, NULL);
    assert(current_active_label_info);
    current_helper_aux_info = g_hash_table_new(NULL, NULL);
    assert(current_helper_aux_info);

    helper_str[helper_memset] = "memset";
    dummy_slot_for_debug.s.valid = 0;
}

void module_epilog() {
    //LLVMDumpModule(module);
#if 1
    LLVMValueRef function = LLVMGetFirstFunction(module);
    while (function != NULL) {
        if (LLVMIsAFunction(function)) {
            if (LLVMIsDeclaration(function) && strstr(LLVMGetValueName(function), "func_")) {
                LLVMSetLinkage(function, LLVMWeakAnyLinkage);
                LLVMAddAttributeAtIndex(function, -1, NoInlineAttr);
                LLVMAddAttributeAtIndex(function, -1, target_features_attr);
                LLVMBasicBlockRef entry = LLVMAppendBasicBlock(function, "entry");
                LLVMPositionBuilderAtEnd(builder, entry);
                LLVMBasicBlockRef bb_loop = LLVMAppendBasicBlock(function, "loop");
                LLVMBuildBr(builder, bb_loop);
                LLVMPositionBuilderAtEnd(builder, bb_loop);
                LLVMBuildBr(builder, bb_loop);
                LLVMBasicBlockRef bb_exit = LLVMAppendBasicBlock(function, "exit");
                LLVMPositionBuilderAtEnd(builder, bb_exit);
                LLVMBuildRetVoid(builder);
            }
        }
        function = LLVMGetNextFunction(function);
    }

    //LLVMDumpModule(module);
    LLVMPassBuilderOptionsRef options = LLVMCreatePassBuilderOptions();
    //LLVMPassBuilderOptionsSetDebugLogging(options, 1);
    LLVMErrorRef error = LLVMRunPasses(module, "default<O1>", target_machine, options);

    if (error) {
        char* error_msg = LLVMGetErrorMessage(error);
        fprintf(stderr, "Optimization failed: %s\n", error_msg);
        LLVMDisposeErrorMessage(error_msg);
        LLVMDisposePassBuilderOptions(options);
        LLVMDisposeTargetMachine(target_machine);
        exit(1);
    }

    // Remove helper_cc_compute_*, helper_*_xmm_*
    LLVMValueRef currentFunction = LLVMGetFirstFunction(module);
    while (currentFunction != NULL) {
        const char* funcName = LLVMGetValueName(currentFunction);
        LLVMValueRef deleteCandidate = NULL;
        //if (strstr(funcName, "helper_") && (strstr(funcName, "_xmm_") || strstr(funcName, "_inband") || strstr(funcName, "_outband"))) {
        if (strstr(funcName, "helper_") && strstr(funcName, "_inband")) {
            deleteCandidate = currentFunction;
        }
        currentFunction = LLVMGetNextFunction(currentFunction);
        if (deleteCandidate) {
            LLVMDeleteFunction(deleteCandidate);
        }
    }

    //LLVMDumpModule(module);
    char *error_msg = NULL;
    if (LLVMTargetMachineEmitToFile(target_machine, module, output_file, LLVMObjectFile, &error_msg)) {
        printf("Failed to emit object file: %s", error_msg);
        exit(1);
    }
    printf("Object file %s generated successfully.\n", output_file);
    fflush(NULL);
#endif
    LLVMDisposeModule(module);
}

void parse_tcg_instructions(const char *filename) {
    FILE *source_file = fopen(filename, "r");
    if (!source_file) {
        perror("Error opening source file");
        return;
    }

    TcgContext ctx;
    yyscan_t scanner;
    yylex_init(&scanner);
    yyset_in(source_file, scanner);

    yyparse(scanner, &ctx);
    yylex_destroy(scanner);
    free(lineptr);
    fclose(source_file);
    return;
}

int main(int argc, const char *argv[]) {
    if (argc < 2) {
        printf("Usage: ./app <tcg-ir> <func_name_prefix>\n");
        return -1;
    }

    if (argc >= 3) {
        assert(strlen(argv[2]) <= (sizeof(func_name_prefix)-1));
        strcpy(func_name_prefix, argv[2]);
    }
    sprintf(output_file, "%s.o", argv[1]);
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    LLVMInitializeAArch64TargetInfo();
    LLVMInitializeAArch64Target();
    LLVMInitializeAArch64TargetMC();
    LLVMInitializeAArch64AsmPrinter();
    LLVMInitializeAArch64AsmParser();
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    LLVMInitializeRISCVTargetInfo();
    LLVMInitializeRISCVTarget();
    LLVMInitializeRISCVTargetMC();
    LLVMInitializeRISCVAsmPrinter();
    LLVMInitializeRISCVAsmParser();
#endif

    char *error_msg = NULL;
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    const char *default_triple = "aarch64-unknown-linux-gnu";
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    const char *default_triple = "riscv64-unknown-linux-gnu";
#endif

#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    /*
    const char *global_isel_args[] = {
        "program_name",
        "-global-isel",
        "-aarch64-enable-global-isel-at-O=1",
        NULL
    };
    LLVMParseCommandLineOptions(3, global_isel_args, "Enable GlobalISel at O1 for AArch64");
    */
#endif

    LLVMTargetRef target;
    if (LLVMGetTargetFromTriple(default_triple, &target, &error_msg)) {
        printf("Failed to get target from triple %s\n", error_msg);
        return -1;
    }
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    const char* features = "+neon";
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    const char* features = "+m,+a,+f,+d,+v";
#endif
    target_machine = LLVMCreateTargetMachine(target, default_triple, "generic", features,
                                             LLVMCodeGenLevelDefault, LLVMRelocPIC, LLVMCodeModelDefault);

    module_prolog();
    parse_tcg_instructions(argv[1]);
    module_epilog();
    return 0;
}
