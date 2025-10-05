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
#include <stdbool.h>

//#define DEBUG                       1
// FIXME: maybe change all uint8_t to int???
#define OPC_INPUT_T         opciosz[opc][0]
#define OPC_EFFECTIVE_T     opciosz[opc][1]
#define OPC_OUTPUT_T        opciosz[opc][2]
#define OPC_ADDR_T          LLVMInt64
#define WITH_FIXED_VEC_CONTEXT      1
#define WITHOUT_FIXED_VEC_CONTEXT   0
#define MAX_OPERANDS_COUNT          16
#define BB_MAX_CNT                  128
#define QEMUAOT_CC                  124

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
        uint8_t is_vec = is_vector(ptr);            \
        if (is_vec) {                               \
            tmp_opc.o = not_vec;                    \
            AttrSrcInfo ai;                         \
            ai.p.ves = get_llvm_vector_type(ptr) - LLVMVector16xi8; \
            create_vector_slot2(buf, tmp_opc, ai, OUT, IN); \
        } else {                                    \
            tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? not_i64 : not_i32;      \
            create_scalar_slot2(buf, tmp_opc, OUT, IN); \
        }                                           \
        translate_not(tmp_opc.o, buf);      \
    } while (0)

#define CREATE_AND(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        uint8_t is_vec = is_vector(ptr);            \
        if (is_vec) {                               \
            tmp_opc.o = and_vec;                    \
            AttrSrcInfo ai;                         \
            ai.p.ves = get_llvm_vector_type(ptr) - LLVMVector16xi8; \
            create_vector_slot3(buf, tmp_opc, ai, OUT, IN0, IN1); \
            translate_binary(tmp_opc.o, buf, LLVMBuildAnd);     \
        } else {                                    \
            tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? not_i64 : not_i32;      \
            create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
            translate_binary(tmp_opc.o, buf, LLVMBuildAnd);     \
        }                                           \
    } while (0)

#define CREATE_XOR(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        uint8_t is_vec = is_vector(ptr);            \
        if (is_vec) {                               \
            tmp_opc.o = and_vec;                    \
            AttrSrcInfo ai;                         \
            ai.p.ves = get_llvm_vector_type(ptr) - LLVMVector16xi8; \
            create_vector_slot2_vimm(buf, tmp_opc, ai, OUT, IN0, IN1); \
        } else {                                    \
            tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? xor_i64 : xor_i32;      \
            create_scalar_slot2_imm(buf, tmp_opc, OUT, IN0, IN1); \
        }                               \
        translate_binary(tmp_opc.o, buf, LLVMBuildXor);     \
    } while (0)

#define CREATE_SHR(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? shr_i64 : shr_i32;      \
        create_scalar_slot2_imm(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildLShr);              \
    } while (0)

#define CREATE_SHR_SLOT(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? shr_i64 : shr_i32;      \
        create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildLShr);              \
    } while (0)

#define CREATE_SHL(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? shl_i64 : shl_i32;      \
        create_scalar_slot2_imm(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildShl);              \
    } while (0)

#define CREATE_SHL_SLOT(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? shl_i64 : shl_i32;      \
        create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildShl);              \
    } while (0)

#define CREATE_OR(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? or_i64 : or_i32;      \
        create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildOr);              \
    } while (0)

#define CREATE_DEPOSIT(OUT, IN0, IN1, OFS, LEN)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? deposit_i64 : deposit_i32;      \
        create_scalar_slot3_imm2(buf, tmp_opc, OUT, IN0, IN1, OFS, LEN); \
        translate_deposit(tmp_opc.o, buf);    \
    } while (0)

#define CREATE_SAR(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? sar_i64 : sar_i32;      \
        create_scalar_slot2_imm(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildAShr);              \
    } while (0)

#define CREATE_ADD(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? add_i64 : add_i32;      \
        create_scalar_slot2_imm(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildAdd);  \
    } while (0)

#define CREATE_SUB(OUT, IN0, IN1)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? sub_i64 : sub_i32;      \
        create_scalar_slot3(buf, tmp_opc, OUT, IN0, IN1); \
        translate_binary(tmp_opc.o, buf, LLVMBuildSub);  \
    } while (0)

#define CREATE_MOV(OUT, IN)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = OPC_OUTPUT_T == LLVMInt64 ? mov_i64 : mov_i32;      \
        create_scalar_slot2(buf, tmp_opc, OUT, IN); \
        translate_mov(tmp_opc.o, buf);  \
    } while (0)

#define CREATE_MOV_VEC(ATTR, OUT, IN)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = mov_vec;      \
        create_vector_slot2(buf, tmp_opc, ATTR, OUT, IN); \
        translate_mov(tmp_opc.o, buf);  \
    } while (0)

#define CREATE_MOVCOND_VEC(ATTR, OUT, IN0, IN1, CMP0, CMP1, ROP)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = movcond_vec;      \
        create_vector_slot5_relop(buf, tmp_opc, ATTR, OUT, IN0, IN1, CMP0, CMP1, ROP); \
        translate_mov(tmp_opc.o, buf);  \
    } while (0)

#define CREATE_LABEL(LABEL)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = set_label;     \
        create_setlabel(buf, tmp_opc, LABEL); \
        translate_set_label(tmp_opc.o, buf);  \
    } while (0)

#define CREATE_PUSH_RET_ADDR(OP, RET)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.o = push_ret_addr;     \
    create_scalar_slot_imm(buf, tmp_opc, OP, RET);  \
    translate_push_ret_addr(tmp_opc.o, buf);    \
    } while (0)

#define CREATE_JMP_DIRECT(ADDR)           \
    do {                                            \
        uint8_t buf[16];                            \
        create_jmpdirect(buf, ADDR);        \
        translate_jmp_direct(jmp_direct, buf);  \
    } while (0)

#define CREATE_BRCOND(SLOT, I, ROP, LABEL)           \
    do {                                            \
        uint8_t buf[16];                            \
        create_branch_condition(buf, SLOT, I, ROP, LABEL); \
        translate_brcond_i64(brcond_i64, buf); \
    } while (0)

#define CREATE_CALL_RET_IND(OP)           \
    do {                                            \
        uint8_t buf[16];                            \
        OHType tmp_opc;                             \
        tmp_opc.h = helper_ret_ind;                 \
        create_helper_env_slot(buf, tmp_opc, 0, 0, OP); \
        translate_call(call, buf);                  \
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
extern LLVMType opciosz[OPCODE_MAX][3];
extern uint8_t opcoc[OPCODE_MAX];
extern uint8_t opcmem_addr_nzidx[OPCODE_MAX];
extern const char *helper_str[];
extern LLVMType helper_vec_type[HELPER_MAX];
extern const char *xmmreg_str[];
extern uint8_t inline_helper_enabled[HELPER_MAX];
extern uint8_t can_do_helper_inline[HELPER_MAX];
extern uint64_t xreg_offsets[XREG_MAX];

static LLVMAttributeRef target_features_attr = NULL;
static LLVMAttributeRef NoInlineAttr = NULL;
static LLVMAttributeRef AlwaysInlineAttr = NULL;
static LLVMTargetMachineRef target_machine = NULL;
static LLVMContextRef context = NULL;
static LLVMModuleRef module = NULL;
static LLVMBuilderRef builder = NULL;
static LLVMValueRef llvm_func = NULL;
static LLVMBasicBlockRef last_active_bb = NULL;
#define FIXED_PARAM_COUNT           20
#define FIXED_VECTOR_PARAM_COUNT   (20 + 15 * 2)
#define TRAMPOLINE_PARAM_COUNT      8
static LLVMTypeRef fixed_vector_param_types[FIXED_VECTOR_PARAM_COUNT + TRAMPOLINE_PARAM_COUNT] = {NULL};
static LLVMTypeRef *llvm_types_for_helpers = &fixed_vector_param_types[FIXED_VECTOR_PARAM_COUNT];
static LLVMType fixed_vector_param_llvmtypes[FIXED_VECTOR_PARAM_COUNT] = {0};
static uint8_t fixed_vector_param_in_stack[FIXED_VECTOR_PARAM_COUNT] = {0};
static const char *fixed_vector_arg_names[FIXED_VECTOR_PARAM_COUNT] = {NULL};
static const char *fixed_vector_stack_names[FIXED_VECTOR_PARAM_COUNT] = {NULL};
static const char *xmm_tmp_stack_names[2] = {NULL};
static const char *tmp_stack_names[1<<5] = {NULL};
static const char *ir_var_name[('z'-'a'+1)*(('z'-'a'+1)+('Z'-'A'+1))] = {NULL};
static int ir_var_name_idx = 0;
static LLVMTypeRef llvm_int_types[LLVMMAXType] = {NULL};
static uint8_t llvm_vector_elem_bit_counts[LLVMMAXType * 2] = {0};
static LLVMValueRef func_xreg_alloca[1 << 5] = {NULL};
static LLVMValueRef func_tmp_alloca[1 << 5] = {NULL};
static LLVMValueRef func_xmm_alloca[1 << 5] = {NULL};
static LLVMType func_xreg_llvmtype[1 << 5] = {0};
static LLVMType func_tmp_llvmtype[1 << 5] = {0};
static LLVMType func_xmm_llvmtype[1 << 5] = {0};
static uint32_t env_var_offset[ENVVarMAX] = {0};
static OperandType alias_tmp[1<<5] = {0};
static uint32_t tmp_var_available = 0, tmp_var_available_backup = 0;
static LLVMIntPredicate llvm_predicate[RELOPMAX] = {0};
static uint32_t br_count = 0;
static uint64_t current_func_offset = 0;
static uint32_t tmp_shadow_offset[BB_MAX_CNT][1<<5] = {0};
static LLVMType helper_output_type[BB_MAX_CNT];
static OperandType helper_output_slot[BB_MAX_CNT];
static uint8_t current_call_idx = 0;
static uint32_t shadow_call_offset = 16;
static uint8_t xmmt_valid[2] = {0};
static uint32_t xreg_valid = 0, tmp_valid = 0, xmm_valid = 0;
static LLVMType tmp_bits_type[1<<5] = {0};
static uint32_t func_instr_cnt_remain = 0;
static uint8_t current_active_labels[BB_MAX_CNT];
static uint8_t current_active_label_cnt = 0;
static uint8_t exception_or_interrupt_on = 0;
static char output_file[128] = {0};
#define LLVMNoInlineAttribute       32
#define LLVMAlwaysInlineAttribute   3

static void do_store(OpCodeType opc, LLVMValueRef val, LLVMType val_tidx, OperandType out);
static LLVMValueRef get_env_ptr_raw();
static OperandType get_env_ptr(OpCodeType opc);
static OperandType get_shadow_stack_pointer(OpCodeType opc);
static void set_shadow_stack_pointer(OpCodeType opc, OperandType val);
static LLVMBasicBlockRef get_bb(const char *name);
static void handle_single_instr(OpCodeType opc, void *ptr);
static uint8_t can_inline_helper(HelperType h, const char *build_macro, const char *bc_name);
static uint8_t is_tail_call(HelperType h);
static uint8_t is_opc_end_of_control_flow(OpCodeType opc);
static int collect_arguments(OpCodeType opc, LLVMValueRef *out_args, int with_fixed_vec_context,
                           OperandType *params, uint32_t *is_imm, uint8_t param_count);
static LLVMValueRef get_or_add_func_with_qemuaot_cc(const char *name, LLVMTypeRef *types, int cnt, int with_ret, LLVMAttributeRef attr_inline_ctrl);
static void setup_func_stack();
static LLVMValueRef get_trampoline(LLVMValueRef helper_func, uint8_t do_return, uint8_t with_ret, uint8_t param_cnt, uint8_t env_idx, OperandType *operands, uint32_t *is_imm, LLVMValueRef next_func);

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

#define GET_STORAGE_ATTR()                                      \
    do {                                                        \
        a0.p.storage.attr.atomic = attr.attr_val >> 6;          \
        a1.p.storage.attr.alignment = (attr.attr_val >> 4) & 0x3;   \
        a2.p.storage.attr.ext = (attr.attr_val >> 3) & 0x1;     \
        a2.p.storage.size = attr.attr_val & 0x7;                \
    } while (0)

static uint8_t is_opc_end_of_control_flow(OpCodeType opc) {
    if (opc == jmp_direct || opc == call_direct || opc == ret) {
        return 1;
    }
    return 0;
}

static uint8_t get_next_spare_tmp_var() {
    uint8_t ret = 0xff;
    for (uint8_t i = 0; i < (1<<5); ++i) {
        if (tmp_var_available & (1<<i)) {
            ret = i;
            tmp_var_available &= ~(1<<i);
            break;
        }
    }
    assert(ret != 0xff);
    return ret;
}

static OperandType get_tmp_and_do_alloc(LLVMType type) {
    OperandType tmp;
    tmp.s.valid = 1;
    tmp.s.slot_type = SUB_SLOT_TMP;
    tmp.s.slot_idx = get_next_spare_tmp_var();
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
    LLVMValueRef constant = LLVMConstInt(llvm_int_types[type], 0x00ff00ff, 0);
    LLVMBuildStore(builder, constant, get_stack_alloca(tmp));
    return tmp;
}

static const char *get_next_var_name() {
    assert(ir_var_name_idx < sizeof(ir_var_name)/sizeof(const char *));
    return ir_var_name[ir_var_name_idx++];
}

static OperandType get_shadow_stack_pointer(OpCodeType opc) {
    OperandType ptr_addr = get_tmp_and_do_alloc(OPC_ADDR_T);
    OperandType env = get_env_ptr(opc);
    CREATE_ADD(ptr_addr, env, -8UL);
    OperandType ptr_val = get_tmp_and_do_alloc(OPC_ADDR_T);
    CREATE_LD(ptr_val, ptr_addr);
    return ptr_val;
}

static void set_shadow_stack_pointer(OpCodeType opc, OperandType val) {
    OperandType ptr_addr = get_tmp_and_do_alloc(OPC_ADDR_T);
    OperandType env = get_env_ptr(opc);
    CREATE_ADD(ptr_addr, env, -8UL);
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

static void create_module(const char *module_name) {
    context = LLVMGetGlobalContext();
    NoInlineAttr = LLVMCreateEnumAttribute(context, LLVMNoInlineAttribute, 0);
    AlwaysInlineAttr = LLVMCreateEnumAttribute(context, LLVMAlwaysInlineAttribute, 0);
    const char *attr_key = "target-features";
    const char *attr_value = "+m,+a,+f,+d,+v";
    size_t attr_key_len = strlen(attr_key);
    size_t attr_value_len = strlen(attr_value);
    target_features_attr = LLVMCreateStringAttribute(context, attr_key, attr_key_len, attr_value, attr_value_len);
    module = LLVMModuleCreateWithNameInContext(module_name, context);

    LLVMSetTarget(module, "riscv64-unknown-linux-gnu");
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
    sprintf(asm_string, "mv $0, x25");
    const char *constraint_string = "=r";
    LLVMValueRef inline_asm = LLVMConstInlineAsm(asm_function_type, asm_string, constraint_string, /* has_side_effects */ 1, /* is_align_stack */ 0);
    return LLVMBuildCall2(builder, asm_function_type, inline_asm, NULL, 0, get_next_var_name());
}

static OperandType get_env_ptr(OpCodeType opc) {
    OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
    LLVMValueRef val = get_env_ptr_raw();
    do_store(opc, val, OPC_ADDR_T, tmp);
    return tmp;
}

static void do_store(OpCodeType opc, LLVMValueRef val, LLVMType val_tidx, OperandType out) {
    assert(val_tidx != LLVMInvalidType && val_tidx < LLVMMAXType);
    LLVMTypeRef val_type = llvm_int_types[val_tidx];
    if (out.s.slot_type == SUB_SLOT_ENVVAR) {
        OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
        OperandType env = get_env_ptr(opc);
        CREATE_ADD(tmp, env, env_var_offset[out.s.slot_idx]);
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, func_tmp_alloca[tmp.s.slot_idx], LLVMPointerType(val_type, 0), get_next_var_name());
        LLVMBuildStore(builder, val, ptr);
    } else {
        LLVMType out_idx = get_stack_llvmtype(out);
        assert((val_tidx <= LLVMInt64 && out_idx <= LLVMInt64 && val_tidx <= out_idx) ||
               (val_tidx <= LLVMInt64 && out_idx > LLVMInt64) ||
               (val_tidx > LLVMInt64 && out_idx > LLVMInt64));
        if (val_tidx <= LLVMInt64 && out_idx <= LLVMInt64 && val_tidx < out_idx) {
            val = LLVMBuildZExt(builder, val, llvm_int_types[out_idx], get_next_var_name());
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
            val = LLVMBuildInsertElement(builder, vec_zero, val, index, get_next_var_name());
            if ((val_tidx + 4) != out_idx) {
                val = LLVMBuildBitCast(builder, val, llvm_int_types[out_idx], get_next_var_name());
            }
        } else if (val_tidx > LLVMInt64 && out_idx > LLVMInt64 && val_tidx != out_idx) {
            val = LLVMBuildBitCast(builder, val, llvm_int_types[out_idx], get_next_var_name());
        }
        LLVMBuildStore(builder, val, get_stack_alloca(out));
    }
}

static LLVMValueRef get_source_node_imm_or_stack(OpCodeType opc, uint32_t is_imm, OperandType operand, LLVMType tidx) {
    assert(tidx != LLVMInvalidType && tidx < LLVMMAXType);
    LLVMTypeRef type = llvm_int_types[tidx];
    LLVMValueRef ret = NULL;
    if (is_imm) {
        if (tidx <= LLVMInt64) {
            ret = LLVMConstInt(type, operand.i, 0);
        } else {
            LLVMValueRef constants[16];
            uint64_t val = operand.i;
            uint8_t full_cnt = llvm_vector_elem_bit_counts[tidx*2], half_cnt = llvm_vector_elem_bit_counts[tidx*2]/2;
            uint8_t bit_cnt = llvm_vector_elem_bit_counts[tidx*2+1];
            for (int i = 0; i < full_cnt; i++) {
                if (i == half_cnt) {
                    val = operand.i;
                }
                LLVMValueRef element_value = LLVMConstInt(llvm_int_types[tidx - 4], val & ((1UL<<bit_cnt)-1), 0);
                constants[i] = element_value;
                val = val >> bit_cnt;
            }
            ret = LLVMConstVector(constants, full_cnt);
        }
    } else if (operand.s.slot_type == SUB_SLOT_ENVVAR) {
        OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
        OperandType env = get_env_ptr(opc);
        CREATE_ADD(tmp, env, env_var_offset[operand.s.slot_idx]);
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, func_tmp_alloca[tmp.s.slot_idx], LLVMPointerType(type, 0), get_next_var_name());
        ret = LLVMBuildLoad2(builder, type, ptr, get_next_var_name());
    } else if (operand.s.slot_type == SUB_SLOT_ENV) {
        OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
        OperandType env = get_env_ptr(opc);
        CREATE_ADD(tmp, env, operand.s.offset);
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, func_tmp_alloca[tmp.s.slot_idx], LLVMPointerType(type, 0), get_next_var_name());
        ret = LLVMBuildLoad2(builder, type, ptr, get_next_var_name());
    } else if (operand.s.slot_type == SUB_SLOT_XMM) {
        if (operand.s.offset) {
            assert(llvm_vector_elem_bit_counts[tidx*2] == 1);
            LLVMTypeRef vtype = NULL;
            int elem_idx = 0;
            vtype = llvm_int_types[tidx+4];
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
            LLVMValueRef vec = LLVMBuildLoad2(builder, vtype, get_stack_alloca(operand), get_next_var_name());
            LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], elem_idx, 0);
            ret = LLVMBuildExtractElement(builder, vec, index, get_next_var_name());
        } else {
            ret = LLVMBuildLoad2(builder, type, get_stack_alloca(operand), get_next_var_name());
        }
    } else {
        ret = LLVMBuildLoad2(builder, type, get_stack_alloca(operand), get_next_var_name());
    }
    return ret;
}

void translate_binary(OpCodeType opc, void *ptr, LLVM_BIN_API api) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm_l, is_imm_r, is_imm_out;
    OperandType operand_l, operand_r, output;
    uint32_t idx = opcoc[opc];
    output = get_operand(ptr, 0, &is_imm_out);
    assert(!is_imm_out && output.s.valid);
    operand_l = get_operand(ptr, idx, &is_imm_l);
    operand_r = get_operand(ptr, idx + 1, &is_imm_r);
    uint8_t is_vec = is_vector(ptr);
    LLVMType vtype = LLVMInvalidType;
    if (is_vec) {
        vtype = get_llvm_vector_type(ptr);
    }
    LLVMValueRef left = get_source_node_imm_or_stack(opc, is_imm_l, operand_l, is_vec ? vtype : OPC_INPUT_T);
    LLVMValueRef right = get_source_node_imm_or_stack(opc, is_imm_r, operand_r, is_vec ? vtype : OPC_INPUT_T);
    LLVMValueRef out_val = api(builder, left, right, get_next_var_name());
    do_store(opc, out_val, OPC_OUTPUT_T, output);
}

void translate_add_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
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
            LLVMValueRef left = get_source_node_imm_or_stack(opc, is_imm1, operand1, OPC_INPUT_T);
            LLVMValueRef right = get_source_node_imm_or_stack(opc, is_imm2, operand2, OPC_INPUT_T);
            LLVMValueRef add_val = LLVMBuildAdd(builder, left, right, get_next_var_name());
            do_store(opc, add_val, OPC_OUTPUT_T, operand0);
        }
    }
}

void translate_andc_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType tmp = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    CREATE_NOT(tmp, operand2);
    CREATE_AND(operand0, operand1, tmp);
}

void translate_andc_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType tmp = get_tmp_and_do_alloc(LLVMVector16xi8);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    CREATE_NOT(tmp, operand2);
    CREATE_AND(operand0, operand1, tmp);
}

void translate_bswap32_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType tmp0 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType tmp1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType tmp2 = get_tmp_and_do_alloc_with_init(OPC_OUTPUT_T, 0x00ff00ff);
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    CREATE_SHR(tmp0, operand1, 8);
    CREATE_AND(tmp1, operand1, tmp2);
    CREATE_AND(tmp0, tmp0, tmp2);
    CREATE_SHL(tmp1, tmp1, 8);
    CREATE_OR(operand0, tmp0, tmp1);
    CREATE_SHL(tmp1, operand0, 48);
    CREATE_SHL(tmp0, operand0, 16);

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_SWAP);
    if (attr.attr_val & OS) {
        CREATE_SAR(tmp1, tmp1, 32);
    } else {
        CREATE_SHR(tmp1, tmp1, 32);
    }

    CREATE_OR(operand0, tmp0, tmp1);
}

void translate_cmp_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();
    LLVMType vtype = get_llvm_vector_type(ptr);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, vtype);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, vtype);

    RelopType r = get_relop(ptr);
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_vec = LLVMBuildICmp(builder, llvm_predicate[r], src1, src2, get_next_var_name());

    OperandType ones, zeros;
    ones.i = 0xffffffffffffffffUL;
    zeros.i = 0;

    LLVMValueRef vec_true = get_source_node_imm_or_stack(opc, 1, ones, vtype);
    LLVMValueRef vec_false = get_source_node_imm_or_stack(opc, 1, zeros, vtype);

    LLVMValueRef result = LLVMBuildSelect(builder, bool_vec, vec_true, vec_false, get_next_var_name());
    do_store(opc, result, OPC_OUTPUT_T, operand0);
}

void translate_count_zero(OpCodeType opc, void *ptr, const char *intrinsic) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, OPC_INPUT_T);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, OPC_INPUT_T);

    LLVMValueRef bool1 = LLVMBuildICmp(builder, LLVMIntEQ, src1, LLVMConstInt(llvm_int_types[OPC_INPUT_T], 0, 0), get_next_var_name());

    LLVMBasicBlockRef bb_ctz_is_zero = LLVMAppendBasicBlock(llvm_func, get_next_var_name());
    LLVMBasicBlockRef bb_ctz_not_zero = LLVMAppendBasicBlock(llvm_func, get_next_var_name());
    LLVMBasicBlockRef bb_ctz_merge = LLVMAppendBasicBlock(llvm_func, get_next_var_name());

    LLVMBuildCondBr(builder, bool1, bb_ctz_is_zero, bb_ctz_not_zero);
    LLVMPositionBuilderAtEnd(builder, bb_ctz_is_zero);
    LLVMBuildBr(builder, bb_ctz_merge);

    LLVMTypeRef ctz_arg_types[] = {llvm_int_types[OPC_INPUT_T], LLVMInt1Type()};
    LLVMTypeRef ctz_type = LLVMFunctionType(llvm_int_types[OPC_OUTPUT_T], ctz_arg_types, 2, 0);
    LLVMValueRef ctz_func = LLVMGetNamedFunction(module, intrinsic);
    if (!ctz_func) {
        ctz_func = LLVMAddFunction(module, intrinsic, ctz_type);
    }
    LLVMSetFunctionCallConv(ctz_func, LLVMCCallConv);

    LLVMPositionBuilderAtEnd(builder, bb_ctz_not_zero);
    LLVMValueRef false_val = LLVMConstInt(LLVMInt1Type(), 0, 0);
    LLVMValueRef call_args[] = {src1, false_val};
    LLVMValueRef call_result = LLVMBuildCall2(builder, ctz_type, ctz_func, call_args, 2, get_next_var_name());
    LLVMBuildBr(builder, bb_ctz_merge);

    LLVMPositionBuilderAtEnd(builder, bb_ctz_merge);
    LLVMValueRef phi = LLVMBuildPhi(builder, llvm_int_types[OPC_OUTPUT_T], get_next_var_name());
    LLVMValueRef phi_incoming_values[] = {src2, call_result};
    LLVMBasicBlockRef phi_incoming_blocks[] = {bb_ctz_is_zero, bb_ctz_not_zero};
    LLVMAddIncoming(phi, phi_incoming_values, phi_incoming_blocks, 2);
    do_store(opc, phi, OPC_OUTPUT_T, operand0);
}

void translate_clz_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    translate_count_zero(opc, ptr, "llvm.ctlz.i64");
}

void translate_ctz_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    translate_count_zero(opc, ptr, "llvm.cttz.i64");
}

void translate_deposit(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1, operand2, ofs, len;
    GET_3_OPERANDS();
    uint32_t is_imm3, is_imm4;
    ofs = get_operand(ptr, 3, &is_imm3);
    len = get_operand(ptr, 4, &is_imm4);
    assert(is_imm3 && is_imm4);

    OperandType tmp_v = get_tmp_and_do_alloc_with_init(OPC_OUTPUT_T, 1);
    OperandType mask1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    CREATE_SHL(mask1, tmp_v, len.i);
    OperandType mask_not_shifted = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    CREATE_SUB(mask_not_shifted, mask1, tmp_v);
    OperandType mask_shifted = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    CREATE_SHL(mask_shifted, mask_not_shifted, ofs.i);
    OperandType rev_mask_shifted = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    CREATE_XOR(rev_mask_shifted, mask_shifted, -1UL);
    OperandType part1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    CREATE_AND(part1, operand1, rev_mask_shifted);
    OperandType part2_0 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    CREATE_AND(part2_0, operand2, mask_not_shifted);
    OperandType part2_1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    CREATE_SHL(part2_1, part2_0, ofs.i);
    CREATE_OR(operand0, part1, part2_1);
}

void translate_dupm_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    LLVMType vtype = get_llvm_vector_type(ptr);
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, operand1, vtype);
    LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
    LLVMValueRef elem = LLVMBuildExtractElement(builder, src, index, get_next_var_name());
    uint8_t full_cnt = llvm_vector_elem_bit_counts[vtype*2];
    LLVMValueRef constants[16];
    LLVMValueRef element_value = LLVMConstInt(llvm_int_types[vtype - 4], 0, 0);
    for (int i = 0; i < full_cnt; i++) {
        constants[i] = element_value;
    }
    LLVMValueRef result = LLVMConstVector(constants, full_cnt);
    for (int i = 0; i < full_cnt; i++) {
        index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], i, 0);
        result = LLVMBuildInsertElement(builder, result, elem, index, get_next_var_name());
    }
    do_store(opc, result, OPC_OUTPUT_T, operand0);
}

/*
  # INDEX_op_extract2_i64, ret, al, ah, ofs
  # TCGv_i64 t0 = tcg_temp_ebb_new_i64();
  # tcg_gen_shri_i64(t0, al, ofs);
  # tcg_gen_deposit_i64(ret, t0, ah, 64 - ofs, ofs);
*/
void translate_extract2_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType tmp = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType operand0, operand1, operand2, ofs;
    GET_3_OPERANDS();
    uint32_t is_imm;
    ofs = get_operand(ptr, 3, &is_imm);
    assert(is_imm);
    CREATE_SHR(tmp, operand1, ofs.i);
    CREATE_DEPOSIT(operand0, tmp, operand2, (64 - ofs.i), ofs.i);
}

void translate_extract(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1, ofs, len;
    GET_2_OPERANDS();
    uint32_t is_imm2, is_imm3;
    ofs = get_operand(ptr, 2, &is_imm2);
    len = get_operand(ptr, 3, &is_imm3);
    assert(is_imm2 && is_imm3);
    OperandType tmp_v = get_tmp_and_do_alloc_with_init(OPC_OUTPUT_T, 1);
    OperandType mask1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    CREATE_SHL(mask1, tmp_v, len.i);
    OperandType mask_not_shifted = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    CREATE_SUB(mask_not_shifted, mask1, tmp_v);
    OperandType arg_shifted = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    CREATE_SHR(arg_shifted, operand1, ofs.i);
    CREATE_AND(operand0, arg_shifted, mask_not_shifted);
}

void translate_mov(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();
    assert(!is_imm0 && operand0.s.valid);

    uint8_t is_vec = is_vector(ptr);
    LLVMType vtype = LLVMInvalidType;
    if (is_vec) {
      vtype = get_llvm_vector_type(ptr);
    }

    if (!is_imm1 && operand1.s.valid && operand1.s.slot_type == SUB_SLOT_TMP && has_alias(operand1)) {
        assert(operand0.s.slot_type == SUB_SLOT_TMP);
        register_alias(operand0, get_alias(operand1));
    } else {
        LLVMValueRef src = get_source_node_imm_or_stack(opc, is_imm1, operand1, is_vec ? vtype : OPC_INPUT_T);
        if (OPC_EFFECTIVE_T < OPC_INPUT_T) {
            src = LLVMBuildTrunc(builder, src, llvm_int_types[OPC_EFFECTIVE_T], get_next_var_name());
        }
        do_store(opc, src, is_vec ? vtype : OPC_OUTPUT_T, operand0);
    }
}

void translate_ld_env_xmm(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1, operand2;
    GET_2_OPERANDS();
    uint32_t is_imm;
    operand2 = get_operand(ptr, 2, &is_imm);

    if (operand1.s.slot_type == SUB_SLOT_ENV ||
        operand1.s.slot_type == SUB_SLOT_XMM) {
        translate_mov(opc, ptr);
    } else if (operand1.s.slot_type == SUB_SLOT_TMP) {
        assert(has_alias(operand1) && is_imm);
        OperandType alias = get_alias(operand1);
        assert(alias.s.valid && alias.s.slot_type == SUB_SLOT_XMM);
        alias.s.offset += operand2.i;
        CREATE_LD_ENV_XMM(opc, operand0, alias);
    }
}

void translate_ext(OpCodeType opc, void *ptr, LLVM_EXT_API api) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();

    LLVMValueRef src = get_source_node_imm_or_stack(opc, is_imm1, operand1, OPC_INPUT_T);
    src = api(builder, src, llvm_int_types[OPC_OUTPUT_T], get_next_var_name());
    do_store(opc, src, OPC_OUTPUT_T, operand0);
}

void translate_ld_vec(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    LLVMType vtype = get_llvm_vector_type(ptr);
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, operand1, vtype);
    do_store(opc, src, vtype, operand0);
}

void translate_movcond(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm0, is_imm1, is_imm2, is_imm3, is_imm4;
    OperandType operand0, operand1, operand2, operand3, operand4;
    GET_3_OPERANDS_NOCHECK();
    operand3 = get_operand(ptr, 3, &is_imm3);
    operand4 = get_operand(ptr, 4, &is_imm4);
    uint8_t is_vec = is_vector(ptr);
    LLVMType vtype = LLVMInvalidType;
    if (is_vec) {
      vtype = get_llvm_vector_type(ptr);
    }

    LLVMValueRef c1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, is_vec ? vtype : OPC_INPUT_T);
    LLVMValueRef c2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, is_vec ? vtype : OPC_INPUT_T);
    LLVMValueRef v1 = get_source_node_imm_or_stack(opc, is_imm3, operand3, is_vec ? vtype : OPC_INPUT_T);
    LLVMValueRef v2 = get_source_node_imm_or_stack(opc, is_imm4, operand4, is_vec ? vtype : OPC_INPUT_T);

    RelopType r = get_relop(ptr);
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        c1 = LLVMBuildAnd(builder, c1, c2, get_next_var_name());
        c2 = LLVMConstInt(llvm_int_types[is_vec ? vtype : OPC_INPUT_T], 0, 0);
    }
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], c1, c2, get_next_var_name());

    LLVMValueRef result = LLVMBuildSelect(builder, bool_val, v1, v2, get_next_var_name());
    do_store(opc, result, is_vec ? vtype : OPC_OUTPUT_T, operand0);
}

void translate_mulxh(OpCodeType opc, void *ptr, LLVM_EXT_API api) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    LLVMTypeRef t128 = LLVMInt128Type();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, 0, operand1, OPC_INPUT_T);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, 0, operand2, OPC_INPUT_T);
    src1 = api(builder, src1, t128, get_next_var_name());
    src2 = api(builder, src2, t128, get_next_var_name());
    LLVMValueRef out = LLVMBuildMul(builder, src1, src2, get_next_var_name());
    LLVMValueRef shift = LLVMConstInt(t128, 64, 0);
    out = LLVMBuildLShr(builder, out, shift, get_next_var_name());
    out = LLVMBuildTrunc(builder, out, llvm_int_types[OPC_OUTPUT_T], get_next_var_name());
    do_store(opc, out, OPC_OUTPUT_T, operand0);
}

void translate_neg(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, operand1, OPC_INPUT_T);
    LLVMValueRef zero = LLVMConstInt(llvm_int_types[OPC_INPUT_T], 0, 0);
    LLVMValueRef out = LLVMBuildSub(builder, zero, src, get_next_var_name());
    do_store(opc, out, OPC_OUTPUT_T, operand0);
}

void translate_negsetcond_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef arg1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, OPC_INPUT_T);
    LLVMValueRef arg2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, OPC_INPUT_T);

    RelopType r = get_relop(ptr);
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], arg1, arg2, get_next_var_name());

    LLVMValueRef result = LLVMBuildSExt(builder, bool_val, llvm_int_types[OPC_OUTPUT_T], get_next_var_name());
    LLVMValueRef neg_one = LLVMConstInt(llvm_int_types[OPC_INPUT_T], -1UL, 0);
    result = LLVMBuildXor(builder, result, neg_one, get_next_var_name());
    do_store(opc, result, OPC_OUTPUT_T, operand0);
}

void translate_not(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    CREATE_XOR(operand0, operand1, -1UL);
}

void translate_push_ret_addr(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm0, is_imm1;
    OperandType operand0, func_hex;
    operand0 = get_operand(ptr, 0, &is_imm0);
    func_hex = get_operand(ptr, 1, &is_imm1);
    assert(is_imm1);

    LLVMValueRef x64_ret_addr = get_source_node_imm_or_stack(opc, is_imm0, operand0, OPC_INPUT_T);
    OperandType ptr_val = get_shadow_stack_pointer(opc);
    CREATE_ADD(ptr_val, ptr_val, -8UL);
    LLVMValueRef shadow_val0 = get_source_node_imm_or_stack(opc, 0, ptr_val, OPC_ADDR_T);
    LLVMValueRef shadow_ptr0 = LLVMBuildIntToPtr(builder, shadow_val0, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name());
    LLVMBuildStore(builder, x64_ret_addr, shadow_ptr0);

    char func_name[64] = {0};
    sprintf(func_name, "func_%lx", func_hex.i);
    LLVMValueRef func_addr = LLVMBuildPtrToInt(builder, get_or_add_func_with_qemuaot_cc(func_name, fixed_vector_param_types, FIXED_VECTOR_PARAM_COUNT, 0, NoInlineAttr), llvm_int_types[OPC_ADDR_T], get_next_var_name());
    CREATE_ADD(ptr_val, ptr_val, -8UL);
    LLVMValueRef shadow_val1 = get_source_node_imm_or_stack(opc, 0, ptr_val, OPC_ADDR_T);
    LLVMValueRef shadow_ptr1 = LLVMBuildIntToPtr(builder, shadow_val1, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name());
    LLVMBuildStore(builder, func_addr, shadow_ptr1);

    set_shadow_stack_pointer(opc, ptr_val);
}

void translate_qemu_ld2_i128(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size == SRC16B);
    LLVMType out_type = LLVMVector2xi64;

    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, operand2, OPC_ADDR_T);
    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[out_type], 0), get_next_var_name());
    LLVMValueRef result = LLVMBuildLoad2(builder, llvm_int_types[out_type], pointer, get_next_var_name());
    if (a1.p.storage.attr.alignment == ALIGN_16 ||
        a1.p.storage.attr.alignment == ALIGN_MEM_SIZE) {
        LLVMSetAlignment(result, 16);
    } else if (a1.p.storage.attr.alignment == ALIGN_32) {
        LLVMSetAlignment(result, 32);
    }
    LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
    LLVMValueRef elem = LLVMBuildExtractElement(builder, result, index, get_next_var_name());
    do_store(opc, elem, OPC_OUTPUT_T, operand0);
    index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 1, 0);
    elem = LLVMBuildExtractElement(builder, result, index, get_next_var_name());
    do_store(opc, elem, OPC_OUTPUT_T, operand1);
}

void translate_qemu_ld(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size <= SRC8B);
    LLVMType out_type = (a2.p.storage.size - SRC1B) + LLVMInt8;
    assert(out_type <= OPC_OUTPUT_T);

    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, operand1, OPC_ADDR_T);
    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[out_type], 0), get_next_var_name());
    LLVMValueRef result = LLVMBuildLoad2(builder, llvm_int_types[out_type], pointer, get_next_var_name());
    if (a1.p.storage.attr.alignment == ALIGN_16) {
        LLVMSetAlignment(result, 16);
    } else if (a1.p.storage.attr.alignment == ALIGN_32) {
        LLVMSetAlignment(result, 32);
    } else if (a1.p.storage.attr.alignment == ALIGN_MEM_SIZE) {
        LLVMSetAlignment(result, llvm_vector_elem_bit_counts[out_type*2+1]/8);
    }
    if (out_type < OPC_OUTPUT_T) {
        if (a2.p.storage.attr.ext == ZERO) {
            result = LLVMBuildZExt(builder, result, llvm_int_types[OPC_OUTPUT_T], get_next_var_name());
        } else {
            result = LLVMBuildSExt(builder, result, llvm_int_types[OPC_OUTPUT_T], get_next_var_name());
        }
    }
    do_store(opc, result, OPC_OUTPUT_T, operand0);
}

void translate_qemu_st2_i128(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size == SRC16B);
    LLVMType out_type = LLVMVector2xi64;

    LLVMValueRef val0 = get_source_node_imm_or_stack(opc, 0, operand0, OPC_INPUT_T);
    LLVMValueRef val1 = get_source_node_imm_or_stack(opc, 0, operand1, OPC_INPUT_T);
    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, operand2, OPC_ADDR_T);
    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[out_type], 0), get_next_var_name());

    LLVMValueRef constants[2];
    LLVMValueRef element_value = LLVMConstInt(llvm_int_types[OPC_OUTPUT_T], 0, 0);
    constants[0] = element_value;
    constants[1] = element_value;
    LLVMValueRef vec = LLVMConstVector(constants, 2);
    LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
    vec = LLVMBuildInsertElement(builder, vec, val0, index, get_next_var_name());
    index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 1, 0);
    vec = LLVMBuildInsertElement(builder, vec, val1, index, get_next_var_name());
    LLVMValueRef result = LLVMBuildStore(builder, vec, pointer);
    if (a1.p.storage.attr.alignment == ALIGN_16 ||
        a1.p.storage.attr.alignment == ALIGN_MEM_SIZE) {
        LLVMSetAlignment(result, 16);
    } else if (a1.p.storage.attr.alignment == ALIGN_32) {
        LLVMSetAlignment(result, 32);
    }
}

void translate_qemu_st(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size <= SRC8B);
    LLVMType out_type = (a2.p.storage.size - SRC1B) + LLVMInt8;
    assert(out_type <= OPC_OUTPUT_T);

    LLVMValueRef val = get_source_node_imm_or_stack(opc, 0, operand0, OPC_INPUT_T);
    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, operand1, OPC_ADDR_T);
    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[out_type], 0), get_next_var_name());
    if (out_type < OPC_OUTPUT_T) {
        val = LLVMBuildTrunc(builder, val, llvm_int_types[out_type], get_next_var_name());
    }
    LLVMValueRef result = LLVMBuildStore(builder, val, pointer);
    if (a1.p.storage.attr.alignment == ALIGN_16) {
        LLVMSetAlignment(result, 16);
    } else if (a1.p.storage.attr.alignment == ALIGN_32) {
        LLVMSetAlignment(result, 32);
    } else if (a1.p.storage.attr.alignment == ALIGN_MEM_SIZE) {
        LLVMSetAlignment(result, llvm_vector_elem_bit_counts[out_type*2+1]/8);
    }
}

void translate_ret(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm;
    OperandType operand0;
    operand0 = get_operand(ptr, 0, &is_imm);
    assert(!is_imm && operand0.s.valid);
    OperandType loc606 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType loc607 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType loc608 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType loc609 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType loc610 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType loc611 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
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

    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT];
    for (int i = 0; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        if (fixed_vector_param_in_stack[i]) {
            OperandType param_in_stack;
            if (i < FIXED_PARAM_COUNT) {
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XREG;
                param_in_stack.s.slot_idx = i;
                call_args[i] = get_source_node_imm_or_stack(opc, 0, param_in_stack, fixed_vector_param_llvmtypes[i]);
            } else {
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XMM;
                param_in_stack.s.slot_idx = i - FIXED_PARAM_COUNT;
                param_in_stack.s.offset = 0;
                LLVMValueRef vec = get_source_node_imm_or_stack(opc, 0, param_in_stack, fixed_vector_param_llvmtypes[i]);

                LLVMTypeRef ret_type = LLVMScalableVectorType(LLVMInt64Type(), 1); // <vscale x 1 x i64>
                LLVMTypeRef param_type = LLVMVectorType(LLVMInt64Type(), 2); // <2 x i64>
                LLVMTypeRef intrinsic_types[] = {ret_type, param_type, LLVMInt64Type()};
                LLVMTypeRef intrinsic_func_type = LLVMFunctionType(ret_type, intrinsic_types, 3, 0);
                LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, "llvm.vector.insert.nxv1i64.v2i64");
                if (!intrinsic_func) {
                    intrinsic_func = LLVMAddFunction(module, "llvm.vector.insert.nxv1i64.v2i64", intrinsic_func_type);
                }
                LLVMValueRef index_0 = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
                LLVMValueRef intrinsic_call_args[] = {LLVMGetPoison(ret_type), vec, index_0};
                call_args[i] = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 3, get_next_var_name());
            }
        } else {
            call_args[i] = LLVMGetParam(llvm_func, i);
        }
    }
    LLVMTypeRef func_type = LLVMFunctionType(LLVMVoidType(), fixed_vector_param_types, FIXED_VECTOR_PARAM_COUNT, 0);
    LLVMValueRef ret_target = get_source_node_imm_or_stack(opc, 0, loc608, OPC_ADDR_T);
    LLVMValueRef ret_target_ptr = LLVMBuildIntToPtr(builder, ret_target, LLVMPointerType(func_type, 0), get_next_var_name());
    LLVMValueRef call_inst = LLVMBuildCall2(builder, func_type, ret_target_ptr, call_args, FIXED_VECTOR_PARAM_COUNT, "");
    LLVMSetTailCall(call_inst, 1);

    CREATE_LABEL(new_label);
    CREATE_CALL_RET_IND(operand0);
}

void translate_rotr(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType t0 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType t1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    CREATE_SHR_SLOT(t0, operand1, operand2);
    OperandType constant = get_tmp_and_do_alloc_with_init(OPC_OUTPUT_T, OPC_OUTPUT_T == LLVMInt64 ? 64 : 32);
    CREATE_SUB(t1, constant, operand2);
    CREATE_SHL_SLOT(t1, operand1, t1);
    CREATE_OR(operand0, t0, t1);
}

void translate_rotl(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType t0 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType t1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    CREATE_SHL_SLOT(t0, operand1, operand2);
    OperandType constant = get_tmp_and_do_alloc_with_init(OPC_OUTPUT_T, OPC_OUTPUT_T == LLVMInt64 ? 64 : 32);
    CREATE_SUB(t1, constant, operand2);
    CREATE_SHR_SLOT(t1, operand1, t1);
    CREATE_OR(operand0, t0, t1);
}

void translate_setcond_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef c1 = get_source_node_imm_or_stack(opc, is_imm1, operand1, OPC_INPUT_T);
    LLVMValueRef c2 = get_source_node_imm_or_stack(opc, is_imm2, operand2, OPC_INPUT_T);

    RelopType r = get_relop(ptr);
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        c1 = LLVMBuildAnd(builder, c1, c2, get_next_var_name());
        c2 = LLVMConstInt(llvm_int_types[OPC_INPUT_T], 0, 0);
    }
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], c1, c2, get_next_var_name());
    LLVMValueRef result = LLVMBuildZExt(builder, bool_val, llvm_int_types[OPC_OUTPUT_T], get_next_var_name());
    do_store(opc, result, OPC_OUTPUT_T, operand0);
}

void translate_sextract_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1, ofs, len;
    GET_2_OPERANDS();
    uint32_t is_imm2, is_imm3;
    ofs = get_operand(ptr, 2, &is_imm2);
    len = get_operand(ptr, 3, &is_imm3);
    assert(is_imm2 & is_imm3);
    OperandType t0 = get_tmp_and_do_alloc(OPC_OUTPUT_T);

    CREATE_SHL(t0, operand1, (64 - len.i - ofs.i));
    CREATE_SAR(operand0, t0, (64 - len.i));
}

void translate_st(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();
    assert(!is_imm1 && operand1.s.valid);

    LLVMValueRef val = get_source_node_imm_or_stack(opc, is_imm0, operand0, OPC_INPUT_T);
    if (OPC_EFFECTIVE_T < OPC_INPUT_T) {
        val = LLVMBuildTrunc(builder, val, llvm_int_types[OPC_EFFECTIVE_T], get_next_var_name());
    }

    LLVMValueRef addr_val = NULL;

    if (operand1.s.slot_type == SUB_SLOT_TMP) {
        assert(has_alias(operand1));
        OperandType alias = get_alias(operand1);
        assert(alias.s.valid && alias.s.slot_type == SUB_SLOT_XMM);
        uint32_t is_imm;
        OperandType offset = get_operand(ptr, 2, &is_imm);
        assert(is_imm);
        alias.s.offset += offset.i;
        assert((alias.s.offset * 8) % llvm_vector_elem_bit_counts[OPC_OUTPUT_T*2+1] == 0);

        OperandType src = alias;
        src.s.offset = 0;
        LLVMValueRef src_val = get_source_node_imm_or_stack(opc, 0, src, OPC_OUTPUT_T + 4);
        LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], (alias.s.offset * 8) / llvm_vector_elem_bit_counts[OPC_OUTPUT_T*2+1], 0);
        val = LLVMBuildInsertElement(builder, src_val, val, index, get_next_var_name());
        do_store(opc, val, OPC_OUTPUT_T + 4, src);
    } else {
        addr_val = get_source_node_imm_or_stack(opc, 0, operand1, OPC_ADDR_T);
        LLVMValueRef addr_ptr = LLVMBuildIntToPtr(builder, addr_val, LLVMPointerType(llvm_int_types[OPC_OUTPUT_T], 0), get_next_var_name());
        LLVMBuildStore(builder, val, addr_ptr);
    }
}

void translate_maxmin_vec(OpCodeType opc, void *ptr, RelopType r) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    AttrSrcInfo ai;
    LLVMType vtype = get_llvm_vector_type(ptr);
    ai.p.ves = vtype - LLVMVector16xi8;
    OperandType tmp1 = get_tmp_and_do_alloc(vtype);
    OperandType tmp2 = get_tmp_and_do_alloc(vtype);

    CREATE_MOV_VEC(ai, tmp1, operand1);
    CREATE_MOV_VEC(ai, tmp2, operand2);
    CREATE_MOVCOND_VEC(ai, operand0, operand1, operand2, tmp1, tmp2, r);
}

void translate_bswap64_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    OperandType t0 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType t1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    CREATE_SHR(t0, operand1, 8);
    OperandType t2 = get_tmp_and_do_alloc_with_init(OPC_OUTPUT_T, 0x00ff00ff00ff00ffUL);
    CREATE_AND(t1, operand1, t2);
    CREATE_AND(t0, t0, t2);
    CREATE_SHL(t1, t1, 8);
    CREATE_OR(operand0, t0, t1);
    t2 = get_tmp_and_do_alloc_with_init(OPC_OUTPUT_T, 0x0000ffff0000ffffUL);
    CREATE_SHR(t0, operand0, 16);
    CREATE_AND(t1, operand0, t2);
    CREATE_AND(t0, t0, t2);
    CREATE_SHL(t1, t1, 16);
    CREATE_OR(operand0, t0, t1);
    CREATE_SHR(t0, operand0, 32);
    CREATE_SHL(t1, operand0, 32);
    CREATE_OR(operand0, t0, t1);
}

void translate_set_label(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
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
    for (int i = 0; i < current_active_label_cnt; ++i) {
        if (do_move) {
            current_active_labels[i-1] = current_active_labels[i];
        }
        if (current_active_labels[i] == l) {
            do_move = 1;
        }
    }
    current_active_label_cnt -= 1;
}

void translate_brcond_i64(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();
    LLVMValueRef c1 = get_source_node_imm_or_stack(opc, is_imm0, operand0, OPC_INPUT_T);
    LLVMValueRef c2 = get_source_node_imm_or_stack(opc, is_imm1, operand1, OPC_INPUT_T);

    RelopType r = get_relop(ptr);
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        c1 = LLVMBuildAnd(builder, c1, c2, get_next_var_name());
        c2 = LLVMConstInt(llvm_int_types[OPC_INPUT_T], 0, 0);
    }
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], c1, c2, get_next_var_name());
    char false_bb_name[16] = {0};
    sprintf(false_bb_name, "bb_false%d", br_count);
    LLVMBasicBlockRef bb_false = LLVMAppendBasicBlock(llvm_func, false_bb_name);
    char true_bb_name[16] = {0};
    uint8_t lbl = get_label(ptr);
    sprintf(true_bb_name, "bb_L%d", lbl);
    LLVMBasicBlockRef bb_true = get_bb(true_bb_name);
    if (!bb_true) {
        bb_true = LLVMAppendBasicBlock(llvm_func, true_bb_name);
        for (int i = 0; i < current_active_label_cnt; ++i) {
            assert(current_active_labels[i] != lbl);
        }
        current_active_labels[current_active_label_cnt] = lbl;
        current_active_label_cnt += 1;
    }
    LLVMPositionBuilderAtEnd(builder, last_active_bb);
    LLVMBuildCondBr(builder, bool_val, bb_true, bb_false);
    LLVMPositionBuilderAtEnd(builder, bb_false);
    last_active_bb = bb_false;
    br_count += 1;
}

void translate_jmp_direct(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm;
    OperandType delta;
    delta = get_operand(ptr, 0, &is_imm);
    assert(is_imm);

    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT];
    collect_arguments(opc, call_args, WITH_FIXED_VEC_CONTEXT, NULL, NULL, 0);
    LLVMTypeRef ret_type = LLVMVoidType();
    LLVMTypeRef func_type = LLVMFunctionType(ret_type, fixed_vector_param_types, FIXED_VECTOR_PARAM_COUNT, 0);

    char func_name[64] = {0};
    sprintf(func_name, "func_%lx", (current_func_offset + delta.i));
    LLVMValueRef call_inst = LLVMBuildCall2(builder, func_type, get_or_add_func_with_qemuaot_cc(func_name, fixed_vector_param_types, FIXED_VECTOR_PARAM_COUNT, 0, NoInlineAttr), call_args, FIXED_VECTOR_PARAM_COUNT, "");
    LLVMSetTailCall(call_inst, 1);
    LLVMSetInstructionCallConv(call_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);
}

void translate_call_direct(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, ret_delta_hex, call_delta_hex;
    operand0 = get_operand(ptr, 0, &is_imm0);
    assert(!is_imm0 && operand0.s.valid);
    ret_delta_hex = get_operand(ptr, 1, &is_imm1);
    call_delta_hex = get_operand(ptr, 2, &is_imm2);
    assert(is_imm1 && is_imm2);

    CREATE_PUSH_RET_ADDR(operand0, ret_delta_hex.i);
    CREATE_JMP_DIRECT(call_delta_hex.i);
}

void translate_discard(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    uint32_t is_imm;
    OperandType operand0 = get_operand(ptr, 0, &is_imm);
    assert(!is_imm && operand0.s.valid);
    if (operand0.s.slot_type == SUB_SLOT_XREG) {
        LLVMBuildStore(builder, LLVMGetPoison(llvm_int_types[func_xreg_llvmtype[operand0.s.slot_idx]]), func_xreg_alloca[operand0.s.slot_idx]);
    }
}

static LLVMValueRef get_trampoline(LLVMValueRef helper_func, uint8_t do_return, uint8_t with_ret, uint8_t param_cnt, uint8_t env_idx, OperandType *operands, uint32_t *is_imm, LLVMValueRef next_func) {
    char trampoline_name[512] = {0};
    if (env_idx == 0xff) {
        sprintf(trampoline_name, "trampoline%s_r%d_param%d_env0", do_return ? "" : "_noreturn", with_ret, param_cnt);
    } else {
        sprintf(trampoline_name, "trampoline%s_r%d_param%d_env1_idx%d", do_return ? "" : "_noreturn", with_ret, param_cnt, env_idx);
    }
    // Collect information for fixed reuse pattern
    int reuse_cnt = 0;
    if (param_cnt) {
        for (int i = 0; i < param_cnt; ++i) {
            if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_XREG) {
                char snippet[16] = {0};
                sprintf(snippet, "_rs%drd%d", operands[i].s.slot_idx, i);
                strcat(trampoline_name, snippet);
                reuse_cnt += 1;
            }
        }
    }
    LLVMValueRef trampoline = LLVMGetNamedFunction(module, trampoline_name);
    if (trampoline) {
        return trampoline;
    }
    int trampoline_arg_count = FIXED_VECTOR_PARAM_COUNT + (param_cnt - reuse_cnt) + 1/*The helper*/ + 1/*The next func after helper returns*/;
    assert(trampoline_arg_count <= (FIXED_VECTOR_PARAM_COUNT + TRAMPOLINE_PARAM_COUNT));
    trampoline = LLVMAddFunction(module, trampoline_name,
        LLVMFunctionType(LLVMVoidType(), fixed_vector_param_types, trampoline_arg_count, 0));
    LLVMAddAttributeAtIndex(trampoline, -1, NoInlineAttr);
    LLVMAddAttributeAtIndex(trampoline, -1, target_features_attr);
    LLVMSetLinkage(trampoline, LLVMWeakAnyLinkage);
    int j = 0;
    LLVMValueRef param = NULL;
    for (j = 0; j < FIXED_VECTOR_PARAM_COUNT; j++) {
        param = LLVMGetParam(trampoline, j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }
    for (j = FIXED_VECTOR_PARAM_COUNT; j < (FIXED_VECTOR_PARAM_COUNT + (param_cnt - reuse_cnt)); j++) {
        param = LLVMGetParam(trampoline, j);
        char var[16] = {0};
        sprintf(var, "param%d", (j - FIXED_VECTOR_PARAM_COUNT));
        LLVMSetValueName(param, var);
    }
    param = LLVMGetParam(trampoline, j++);
    LLVMSetValueName(param, "helper");
    param = LLVMGetParam(trampoline, j);
    LLVMSetValueName(param, "next");
    LLVMSetFunctionCallConv(trampoline, QEMUAOT_CC);

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(trampoline, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);

    // Store all fixed to ENV
    LLVMValueRef env_raw = get_env_ptr_raw();
    for (int i = 0; i < FIXED_PARAM_COUNT; ++i) {
        LLVMValueRef fixed_val = LLVMGetParam(trampoline, i);
        uint64_t env_xreg_offset = xreg_offsets[i];
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xreg_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(fixed_vector_param_types[i], 0), get_next_var_name());
        LLVMBuildStore(builder, fixed_val, ptr);
    }

    // Store all vectors to ENV
    LLVMTypeRef ret_type = LLVMVectorType(LLVMInt64Type(), 2); // <2 x i64>
    LLVMTypeRef param_type = LLVMScalableVectorType(LLVMInt64Type(), 1); // <vscale x 1 x i64>
    LLVMTypeRef intrinsic_types[] = {param_type, LLVMInt64Type()};
    LLVMTypeRef intrinsic_func_type = LLVMFunctionType(ret_type, intrinsic_types, 2, 0);
    LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, "llvm.vector.extract.v2i64.nxv1i64");
    if (!intrinsic_func) {
        intrinsic_func = LLVMAddFunction(module, "llvm.vector.extract.v2i64.nxv1i64", intrinsic_func_type);
    }
    LLVMValueRef index_0 = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
    for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        LLVMValueRef call_args[] = {LLVMGetParam(trampoline, i), index_0};
        LLVMValueRef vec_val = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, call_args, 2, get_next_var_name());
        uint64_t xmm_offset = get_xmm_offset((i - FIXED_PARAM_COUNT)/2) + 16 * ((i - FIXED_PARAM_COUNT) % 2);
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(ret_type, 0), get_next_var_name());
        LLVMBuildStore(builder, vec_val, ptr);
    }

    LLVMValueRef call_args[MAX_OPERANDS_COUNT] = {NULL};
    int idx_with_env = 0;
    if (param_cnt) {
        for (int i = 0; i < param_cnt; ++i) {
            if (i == env_idx) {
                LLVMValueRef env_raw = get_env_ptr_raw();
                LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
                call_args[idx_with_env] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                idx_with_env += 1;
            }
            if (is_imm[i] == 0 && operands[i].s.valid && operands[i].s.slot_type == SUB_SLOT_XREG) {
                call_args[idx_with_env] = LLVMGetParam(trampoline, operands[i].s.slot_idx);
                if (fixed_vector_param_llvmtypes[operands[i].s.slot_idx] != LLVMInt64) {
                    call_args[idx_with_env] = LLVMBuildZExt(builder, call_args[idx_with_env], llvm_int_types[LLVMInt64], get_next_var_name());
                }
                idx_with_env += 1;
            } else {
                call_args[idx_with_env] = LLVMGetParam(trampoline, FIXED_VECTOR_PARAM_COUNT + i);
                idx_with_env += 1;
            }
        }
    } else {
        if (env_idx != 0xff) {
            assert(env_idx == 0);
            LLVMValueRef env_raw = get_env_ptr_raw();
            LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
            call_args[idx_with_env] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
            idx_with_env += 1;
        }
    }
    assert(idx_with_env < MAX_OPERANDS_COUNT);
    LLVMTypeRef helper_type = LLVMGlobalGetValueType(helper_func);
    LLVMValueRef helper_addr = LLVMGetParam(trampoline, (FIXED_VECTOR_PARAM_COUNT + (param_cnt - reuse_cnt)));
    LLVMValueRef the_helper = LLVMBuildIntToPtr(builder, helper_addr, LLVMPointerType(helper_type, 0), get_next_var_name());
    LLVMValueRef call_helper_inst = LLVMBuildCall2(builder, helper_type, the_helper, call_args, idx_with_env, with_ret ? get_next_var_name() : "");
    if (!do_return) {
        LLVMSetTailCall(call_helper_inst, 1);
        LLVMBuildRetVoid(builder);

        assert(last_active_bb);
        LLVMPositionBuilderAtEnd(builder, last_active_bb);
        return trampoline;
    }

    // Load all fixed from ENV
    LLVMValueRef return_args[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    if (with_ret) {
        return_args[FIXED_VECTOR_PARAM_COUNT] = call_helper_inst;
    }
    for (int i = 0; i < FIXED_PARAM_COUNT; ++i) {
        uint64_t env_xreg_offset = xreg_offsets[i];
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xreg_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(fixed_vector_param_types[i], 0), get_next_var_name());
        return_args[i] = LLVMBuildLoad2(builder, fixed_vector_param_types[i], ptr, get_next_var_name());
    }

    // Load all vectors from ENV
    ret_type = LLVMScalableVectorType(LLVMInt64Type(), 1); // <vscale x 1 x i64>
    param_type = LLVMVectorType(LLVMInt64Type(), 2); // <2 x i64>
    LLVMTypeRef intrinsic_types2[] = {ret_type, param_type, LLVMInt64Type()};
    LLVMTypeRef intrinsic_func_type2 = LLVMFunctionType(ret_type, intrinsic_types2, 3, 0);
    intrinsic_func = LLVMGetNamedFunction(module, "llvm.vector.insert.nxv1i64.v2i64");
    if (!intrinsic_func) {
        intrinsic_func = LLVMAddFunction(module, "llvm.vector.insert.nxv1i64.v2i64", intrinsic_func_type2);
    }
    OperandType param_in_env;
    for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        uint64_t env_xmm_offset = get_xmm_offset((i - FIXED_PARAM_COUNT)/2) + 16 * ((i - FIXED_PARAM_COUNT) % 2);
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xmm_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[LLVMVector2xi64], 0), get_next_var_name());
        LLVMValueRef vec_elem = LLVMBuildLoad2(builder, llvm_int_types[LLVMVector2xi64], ptr, get_next_var_name());
        LLVMValueRef intrinsic_call_args[] = {LLVMGetPoison(ret_type), vec_elem, index_0};
        return_args[i] = LLVMBuildCall2(builder, intrinsic_func_type2, intrinsic_func, intrinsic_call_args, 3, get_next_var_name());
    }

    LLVMTypeRef next_type = LLVMGlobalGetValueType(next_func);
    LLVMValueRef next_addr = LLVMGetParam(trampoline, (FIXED_VECTOR_PARAM_COUNT + (param_cnt - reuse_cnt) + 1));
    LLVMValueRef the_next = LLVMBuildIntToPtr(builder, next_addr, LLVMPointerType(next_type, 0), get_next_var_name());
    LLVMValueRef call_next_inst = LLVMBuildCall2(builder, next_type, the_next, return_args, (FIXED_VECTOR_PARAM_COUNT + (with_ret ? 1 : 0)), "");
    LLVMSetTailCall(call_next_inst, 1);
    LLVMSetInstructionCallConv(call_next_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);

    assert(last_active_bb);
    LLVMPositionBuilderAtEnd(builder, last_active_bb);
    return trampoline;
}

static uint8_t can_inline_helper(HelperType h, const char *build_macro, const char *bc_name) {
    if (helper_vec_type[h] == LLVMInvalidType) {
        return 0;
    }
    assert(inline_helper_enabled[h]);
    FILE *check_fp = fopen(bc_name, "r");
    if (!check_fp) {
        char cmd[512] = {0};
        sprintf(cmd, "clang -c %s --target=riscv64-unknown-linux-gnu -march=rv64imafdv -O1 -emit-llvm helper_templates/%s.c -o %s", build_macro, helper_str[h], bc_name);
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
    if (h == helper_ret_ind || h == helper_call_ind || h == helper_icebp ||
        h == helper_iret_ind || h == helper_jmp_ind || h == helper_ljmp_protected ||
        h == helper_lret_protected || h == helper_pause || h == helper_raise_exception ||
        h == helper_raise_interrupt) {
        return 1;
    }
    return 0;
}

static int collect_arguments(OpCodeType opc, LLVMValueRef *out_args, int with_fixed_vec_context,
                           OperandType *params, uint32_t *is_imm, uint8_t param_count) {
    int i = 0;
    if (with_fixed_vec_context) {
        for (i = 0; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
            if (fixed_vector_param_in_stack[i]) {
                OperandType param_in_stack;
                if (i < FIXED_PARAM_COUNT) {
                    param_in_stack.s.valid = 1;
                    param_in_stack.s.slot_type = SUB_SLOT_XREG;
                    param_in_stack.s.slot_idx = i;
                    out_args[i] = get_source_node_imm_or_stack(opc, 0, param_in_stack, fixed_vector_param_llvmtypes[i]);
                } else {
                    param_in_stack.s.valid = 1;
                    param_in_stack.s.slot_type = SUB_SLOT_XMM;
                    param_in_stack.s.slot_idx = i - FIXED_PARAM_COUNT;
                    param_in_stack.s.offset = 0;
                    LLVMValueRef vec = get_source_node_imm_or_stack(opc, 0, param_in_stack, fixed_vector_param_llvmtypes[i]);

                    LLVMTypeRef ret_type = LLVMScalableVectorType(LLVMInt64Type(), 1); // <vscale x 1 x i64>
                    LLVMTypeRef param_type = LLVMVectorType(LLVMInt64Type(), 2); // <2 x i64>
                    LLVMTypeRef intrinsic_types[] = {ret_type, param_type, LLVMInt64Type()};
                    LLVMTypeRef intrinsic_func_type = LLVMFunctionType(ret_type, intrinsic_types, 3, 0);
                    LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, "llvm.vector.insert.nxv1i64.v2i64");
                    if (!intrinsic_func) {
                        intrinsic_func = LLVMAddFunction(module, "llvm.vector.insert.nxv1i64.v2i64", intrinsic_func_type);
                    }
                    LLVMValueRef index_0 = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
                    LLVMValueRef intrinsic_call_args[] = {LLVMGetPoison(ret_type), vec, index_0};
                    out_args[i] = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 3, get_next_var_name());
                }
            } else {
                out_args[i] = LLVMGetParam(llvm_func, i);
            }
        }
    }

    if (param_count) {
        assert(params && is_imm);
        for (int op_idx = 0; op_idx < param_count; ++op_idx) {
            if (is_imm[op_idx]) {
                out_args[i] = LLVMConstInt(llvm_int_types[OPC_ADDR_T], params[op_idx].i, 0);
            } else {
                assert(params[op_idx].s.slot_type != SUB_SLOT_XMM);
                if (params[op_idx].s.slot_type == SUB_SLOT_TMP && has_alias(params[op_idx])) {
                    OperandType alias = get_alias(params[op_idx]);
                    assert(alias.s.valid);
                    if (alias.s.slot_type == SUB_SLOT_XMM) {
                        LLVMValueRef env_raw = get_env_ptr_raw();
                        uint64_t xmm_offset = get_xmm_offset(alias.s.slot_idx/2) + 16*(alias.s.slot_idx%2) + alias.s.offset;
                        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
                        out_args[i] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                    } else if (alias.s.slot_type == SUB_SLOT_ENV) {
                        LLVMValueRef env_raw = get_env_ptr_raw();
                        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], alias.s.offset, 0);
                        out_args[i] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                    } else {
                        assert(0);
                    }
                } else {
                    if (params[op_idx].s.slot_type == SUB_SLOT_ENVVAR) {
                        out_args[i] = get_source_node_imm_or_stack(opc, 0, params[op_idx], OPC_ADDR_T);
                    } else if (params[op_idx].s.slot_type == SUB_SLOT_XREG) {
                        // Skipped, should be handled by trampoline
                        continue;
                    } else if (params[op_idx].s.slot_type == SUB_SLOT_TMP) {
                        assert(func_tmp_llvmtype[params[op_idx].s.slot_idx] <= LLVMInt64);
                        out_args[i] = get_source_node_imm_or_stack(opc, 0, params[op_idx], func_tmp_llvmtype[params[op_idx].s.slot_idx]);
                        if (func_tmp_llvmtype[params[op_idx].s.slot_idx] < LLVMInt64) {
                            out_args[i] = LLVMBuildZExt(builder, out_args[i], llvm_int_types[LLVMInt64], get_next_var_name());
                        }
                    } else {
                        assert(0);
                    }
                }
            }
            i += 1;
        }
    }
    return i;
}

static LLVMValueRef get_or_add_func_with_qemuaot_cc(const char *name, LLVMTypeRef *types, int cnt, int with_ret, LLVMAttributeRef attr_inline_ctrl) {
    LLVMValueRef func = LLVMGetNamedFunction(module, name);
    if (!func) {
        LLVMTypeRef func_type = LLVMFunctionType(with_ret ? LLVMInt64Type() : LLVMVoidType(), types, cnt, 0);
        func = LLVMAddFunction(module, name, func_type);
        LLVMAddAttributeAtIndex(func, -1, attr_inline_ctrl);
        LLVMAddAttributeAtIndex(func, -1, target_features_attr);
        LLVMSetFunctionCallConv(func, QEMUAOT_CC);
    }
    return func;
}

void translate_call(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], ptr);
#endif
    // Store tmp_shadow_offset[this call][non-zero offset] contents to the shadow_stack
    LLVMValueRef shadow_pointer = NULL;
    for (int i = 0; i < (1<<5); ++i) {
        if (tmp_shadow_offset[current_call_idx][i]) {
            OperandType op;
            op.s.valid = 1;
            op.s.slot_type = SUB_SLOT_TMP;
            op.s.slot_idx = i;
            LLVMValueRef val = get_source_node_imm_or_stack(opc, 0, op, func_tmp_llvmtype[i]);
            LLVMValueRef shadow_off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], tmp_shadow_offset[current_call_idx][i], 0);
            if (!shadow_pointer) {
                LLVMValueRef env_raw = get_env_ptr_raw();
                LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], -8UL, 0);
                LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name());
                shadow_pointer = LLVMBuildLoad2(builder, llvm_int_types[OPC_ADDR_T], pointer, get_next_var_name());
            }
            LLVMValueRef shadow_addr = LLVMBuildAdd(builder, shadow_pointer, shadow_off, get_next_var_name());
            LLVMValueRef shadow_p = LLVMBuildIntToPtr(builder, shadow_addr, LLVMPointerType(llvm_int_types[func_tmp_llvmtype[i]], 0), get_next_var_name());
            LLVMBuildStore(builder, val, shadow_p);
        }
    }

    uint8_t env_idx = get_env_idx(ptr);
    static int check_recursive_call = 0;
    assert(check_recursive_call == 0);
    check_recursive_call = 1;

    char second_half_name[64];
    sprintf(second_half_name, "func_%lx_call%d", current_func_offset, current_call_idx);
    uint8_t noargs = get_helper_noargs(ptr);
    OperandType oarg;
    oarg.s.valid = 0;
    if (noargs) {
        uint32_t is_imm;
        oarg = get_operand(ptr, 0, &is_imm);
        assert(!is_imm && oarg.s.valid);
    }
    OperandType operands[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm[MAX_OPERANDS_COUNT] = {0};
    uint8_t op_cnt = 0;
    uint8_t all_alias = 1;
    char build_macro[512] = {0};
    do {
        operands[op_cnt] = get_operand(ptr, (op_cnt + noargs), &is_imm[op_cnt]);
        if (is_imm[op_cnt] == 0 && operands[op_cnt].s.valid == 0) {
            break;
        }
        if (!(is_imm[op_cnt] == 0 && operands[op_cnt].s.slot_type == SUB_SLOT_TMP && has_alias(operands[op_cnt]))) {
            all_alias = 0;
        } else {
            OperandType alias = get_alias(operands[op_cnt]);
            assert(alias.s.valid);
            if (alias.s.slot_type != SUB_SLOT_XMM || alias.s.slot_idx >= xmmt) {
                all_alias = 0;
            } else {
                char element[32];
                sprintf(element, " -DARGUMENT%d=%s", op_cnt, xmmreg_str[alias.s.slot_idx]);
                strcat(build_macro, element);
            }
        }
        op_cnt += 1;
    } while (1);
    assert(op_cnt <= MAX_OPERANDS_COUNT);
    if (!op_cnt) {
        all_alias = 0;
    }
    HelperType h = get_helper(ptr);
    char helper_func_name[64] = {0};
    char bc_name[64] = {0};
    if (all_alias) {
        char element[128];
        sprintf(element, " -DFUNC_RET=%s -DHELPER_NAME=helper_%s_%s", second_half_name, helper_str[h], second_half_name);
        strcat(build_macro, element);
        sprintf(bc_name, "helper_templates/helper_%s_%s.bc", helper_str[h], second_half_name);
        sprintf(helper_func_name, "helper_%s_%s", helper_str[h], second_half_name);
    }

    // Get the second half
    LLVMValueRef second_half_func = get_or_add_func_with_qemuaot_cc(second_half_name, fixed_vector_param_types, FIXED_VECTOR_PARAM_COUNT + noargs, noargs, AlwaysInlineAttr);
    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    int call_arg_cnts = 0;
    uint8_t do_inline_helper = all_alias ? can_inline_helper(h, build_macro, bc_name) : 0;
    if (!do_inline_helper) {
        // TODO: how do we handle xmm_tmp? trampoline does not have enough vector slots, so we have to dump it before hand
        LLVMValueRef env_raw = NULL;
        for (int i = 0; i < 2; ++i) {
            if (xmmt_valid[i]) {
                OperandType param_in_stack;
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XMM;
                param_in_stack.s.slot_idx = xmmt + i;
                param_in_stack.s.offset = 0;
                LLVMValueRef vec_val = get_source_node_imm_or_stack(opc, 0, param_in_stack, LLVMVector2xi64);
                uint64_t xmm_offset = get_xmm_offset(param_in_stack.s.slot_idx/2) + 16*(param_in_stack.s.slot_idx%2);
                LLVMTypeRef ret_type = LLVMVectorType(LLVMInt64Type(), 2); // <2 x i64>
                LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
                if (!env_raw) {
                    env_raw = get_env_ptr_raw();
                }
                LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(ret_type, 0), get_next_var_name());
                LLVMBuildStore(builder, vec_val, ptr);
            }
        }

        // Get the helper
        LLVMValueRef helper_func = LLVMGetNamedFunction(module, helper_str[h]);
        if (!helper_func) {
            LLVMTypeRef helper_type = LLVMFunctionType(noargs ? LLVMInt64Type() : LLVMVoidType(), llvm_types_for_helpers, (op_cnt + (env_idx == 0xff ? 0 : 1)), 0);
            helper_func = LLVMAddFunction(module, helper_str[h], helper_type);
        }
        LLVMValueRef helper_addr = LLVMBuildPtrToInt(builder, helper_func, llvm_int_types[OPC_ADDR_T], get_next_var_name());
        LLVMValueRef second_half_addr = LLVMBuildPtrToInt(builder, second_half_func, llvm_int_types[OPC_ADDR_T], get_next_var_name());

        // Trampoline handles register-context switch
        LLVMValueRef trampoline = get_trampoline(helper_func, (h == helper_call_ind || h == helper_jmp_ind || h == helper_ret_ind) ? 0 : 1, noargs, op_cnt, (env_idx == 0xff ? env_idx : (env_idx - noargs)), operands, is_imm, second_half_func);
        call_arg_cnts = collect_arguments(opc, call_args, WITH_FIXED_VEC_CONTEXT, operands, is_imm, op_cnt);
        call_args[call_arg_cnts] = helper_addr;
        call_arg_cnts += 1;
        call_args[call_arg_cnts] = second_half_addr;
        call_arg_cnts += 1;
        assert(call_arg_cnts <= (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT));
        LLVMTypeRef trampoline_type = LLVMFunctionType(LLVMVoidType(), fixed_vector_param_types, call_arg_cnts, 0);
        LLVMValueRef call_trampoline_inst = LLVMBuildCall2(builder, trampoline_type, trampoline, call_args, call_arg_cnts, "");
        LLVMSetTailCall(call_trampoline_inst, 1);
        LLVMSetInstructionCallConv(call_trampoline_inst, QEMUAOT_CC);
        LLVMBuildRetVoid(builder);
    } else {
        call_arg_cnts = collect_arguments(opc, call_args, WITH_FIXED_VEC_CONTEXT, operands, is_imm, op_cnt);
        assert(call_arg_cnts <= (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT));
        LLVMValueRef helper = LLVMGetNamedFunction(module, helper_func_name);
        assert(helper);
        LLVMTypeRef helper_type = LLVMFunctionType(LLVMVoidType(), fixed_vector_param_types, call_arg_cnts, 0);
        LLVMValueRef call_helper_inst = LLVMBuildCall2(builder, helper_type, helper, call_args, call_arg_cnts, "");
        LLVMSetTailCall(call_helper_inst, 1);
        LLVMSetInstructionCallConv(call_helper_inst, QEMUAOT_CC);
        LLVMBuildRetVoid(builder);
    }

    // Check if we got remaining BBs
    do {
        if (!current_active_label_cnt) {
            break;
        }
        uint8_t tgt_lbl = current_active_labels[0];
        void *ptr_init = get_instr_buffer();
        void *ptr_max = ptr_init + get_instr_buffer_size();
        void *ptr_tmp = NULL;
        for (ptr_tmp = move_to_next(ptr); ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
            OpCodeType opc = get_opcode(ptr_tmp);
            if (opc == set_label && get_label(ptr_tmp) == tgt_lbl) {
                break;
            }
        }
        assert(ptr_tmp <= ptr_max);
        if (ptr_tmp == ptr_max) {
            break;
        }
        for (; ptr_tmp < ptr_max; ptr_tmp = move_to_next(ptr_tmp)) {
            OpCodeType opc = get_opcode(ptr_tmp);
            handle_single_instr(opc, ptr_tmp);
            if (is_opc_end_of_control_flow(opc)) {
                break;
            }
        }
    } while (1);

    /// Setup the second-half function
    llvm_func = second_half_func;
    for (int j = 0; j < FIXED_VECTOR_PARAM_COUNT; j++) {
        LLVMValueRef param = LLVMGetParam(llvm_func, j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }
    if (noargs) {
        LLVMValueRef param = LLVMGetParam(llvm_func, FIXED_VECTOR_PARAM_COUNT);
        LLVMSetValueName(param, "helper_result");
    }

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);
    last_active_bb = entry;

    setup_func_stack();

    // Get output from helper func
    if (noargs && helper_output_type[current_call_idx] != LLVMInvalidType) {
        LLVMValueRef param = LLVMGetParam(llvm_func, FIXED_VECTOR_PARAM_COUNT);
        if (oarg.s.slot_type == SUB_SLOT_TMP && has_alias(oarg)) {
            unregister_alias(oarg);
        }
        if (helper_output_type[current_call_idx] < LLVMInt64) {
            param = LLVMBuildTrunc(builder, param, llvm_int_types[helper_output_type[current_call_idx]], get_next_var_name());
        }
        do_store(opc, param, helper_output_type[current_call_idx], oarg);
    } else {
        assert(!noargs);
    }
    check_recursive_call = 0;
}

static void cleanup_func_resource() {
    reset_instr_buffer();
    for (int i = 0; i < (1<<5); ++i) {
        alias_tmp[i].i = 0;
    }
    tmp_var_available = 0;
    tmp_var_available_backup = 0;
    ir_var_name_idx = 0;
    current_func_offset = 0;
    br_count = 0;
    current_call_idx = 0;
    shadow_call_offset = 16;
    xmmt_valid[0] = 0;
    xmmt_valid[1] = 0;
    xreg_valid = 0;
    tmp_valid = 0;
    xmm_valid = 0;
    func_instr_cnt_remain = 0;
    current_active_label_cnt = 0;
    exception_or_interrupt_on = 0;
    memset(fixed_vector_param_in_stack, 0, sizeof(fixed_vector_param_in_stack));
    memset(tmp_shadow_offset, 0, sizeof(tmp_shadow_offset));
    memset(tmp_bits_type, 0, sizeof(tmp_bits_type));
    memset(helper_output_type, 0, sizeof(helper_output_type));
    memset(helper_output_slot, 0, sizeof(helper_output_slot));
    reset_tmp_mapping();
}

static void setup_func_stack() {
    if (xreg_valid) {
        for (XRegType x = 0; x < XREG_MAX; ++x) {
            if (xreg_valid & (1 << x)) {
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, fixed_vector_param_types[x], fixed_vector_stack_names[x]);
                LLVMSetAlignment(alloca_inst, 8);
                func_xreg_alloca[x] = alloca_inst;
                func_xreg_llvmtype[x] = fixed_vector_param_llvmtypes[x];
                LLVMSetAlignment(LLVMBuildStore(builder, LLVMGetParam(llvm_func, x), alloca_inst), 8);
                fixed_vector_param_in_stack[x] = 1;
            }
        }
    }
    if (tmp_valid) {
        for (int i = 0; i < (1<<5); ++i) {
            if (tmp_valid & (1 << i)) {
                assert(tmp_bits_type[i]);
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[tmp_bits_type[i]], tmp_stack_names[i]);
                func_tmp_alloca[i] = alloca_inst;
                func_tmp_llvmtype[i] = tmp_bits_type[i];
                LLVMSetAlignment(alloca_inst, tmp_bits_type[i] <= LLVMInt64 ? 8 : 16);
            }
        }
    }
    if (xmm_valid) {
        for (int i = 0; i < (1<<5)-2; ++i) {
            if (xmm_valid & (1 << i)) {
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[XREG_MAX + i]], fixed_vector_stack_names[XREG_MAX + i]);
                func_xmm_alloca[i] = alloca_inst;
                func_xmm_llvmtype[i] = fixed_vector_param_llvmtypes[XREG_MAX + i];
                LLVMSetAlignment(alloca_inst, 16);
                LLVMTypeRef ret_type = LLVMVectorType(LLVMInt64Type(), 2); // <2 x i64>
                LLVMTypeRef param_type = LLVMScalableVectorType(LLVMInt64Type(), 1); // <vscale x 1 x i64>
                LLVMTypeRef intrinsic_types[] = {param_type, LLVMInt64Type()};
                LLVMTypeRef intrinsic_func_type = LLVMFunctionType(ret_type, intrinsic_types, 2, 0);
                LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, "llvm.vector.extract.v2i64.nxv1i64");
                if (!intrinsic_func) {
                    intrinsic_func = LLVMAddFunction(module, "llvm.vector.extract.v2i64.nxv1i64", intrinsic_func_type);
                }
                LLVMValueRef index_0 = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
                LLVMValueRef call_args[] = {LLVMGetParam(llvm_func, FIXED_PARAM_COUNT + i), index_0};
                LLVMValueRef call_inst = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, call_args, 2, get_next_var_name());
                LLVMBuildStore(builder, call_inst, func_xmm_alloca[i]);
                fixed_vector_param_in_stack[FIXED_PARAM_COUNT + i] = 1;
            }
        }
        for (int i = (1<<5)-2; i < (1<<5); ++i) {
            if (xmm_valid & (1 << i)) {
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[LLVMVector2xi64], xmm_tmp_stack_names[i-((1<<5)-2)]);
                func_xmm_alloca[i] = alloca_inst;
                func_xmm_llvmtype[i] = LLVMVector2xi64;
                LLVMSetAlignment(alloca_inst, 16);
                xmmt_valid[i%2] = 1;
            }
        }
    }
}

void handle_func(uint64_t val) {
#ifdef DEBUG
    printf("func %lx\n", val); fflush(NULL);
#endif
    current_func_offset = val;
    ir_var_name_idx = 0;
    tmp_var_available = 0xffffffff;
    void *ptr_init = get_instr_buffer();
    void *ptr_max = ptr_init + get_instr_buffer_size();
    void *ptr;
    /// Loop through all xreg/slot/xmm, handle arguments, stack alloc/store etc.
    uint8_t tmp_has_known_def[1<<5] = {0};
    for (ptr = ptr_init; ptr < ptr_max; ptr = move_to_next(ptr), func_instr_cnt_remain += 1) {
        uint32_t slot_idx = 0;
        OperandType operand;
        OpCodeType opc = get_opcode(ptr);
        uint32_t noargs = 0;
        OperandType oarg;
        uint32_t is_immo;
        oarg.s.valid = 0;
        if (opc == call) {
            noargs = get_helper_noargs(ptr);
            if (noargs) {
                oarg = get_operand(ptr, 0, &is_immo);
                assert(!is_immo && oarg.s.valid);
                helper_output_slot[current_call_idx] = oarg;
            }
        }
        uint8_t is_vec = is_vector(ptr);
        LLVMType vtype = LLVMInvalidType;
        if (is_vec) {
          vtype = get_llvm_vector_type(ptr);
        }
        do {
            uint32_t is_imm = 0;
            operand = get_operand(ptr, slot_idx, &is_imm);
            // End-of-operands
            if (!is_imm && !operand.s.valid) {
                break;
            }
            uint32_t shifted_slot_bit = (1 << operand.s.slot_idx);
            LLVMType operand_type = vtype == LLVMInvalidType ?
                                (opcmem_addr_nzidx[opc] > 0 ?
                                 ((slot_idx < opcmem_addr_nzidx[opc]) ? OPC_INPUT_T : OPC_ADDR_T) :
                                 (slot_idx < opcoc[opc] ? OPC_OUTPUT_T : OPC_INPUT_T)) :
                                vtype;
            if (is_imm == 0 && current_call_idx > 0 && helper_output_slot[current_call_idx-1].s.valid) {
                if (((opcmem_addr_nzidx[opc] > 0) && (slot_idx < opcmem_addr_nzidx[opc])) || ((opcmem_addr_nzidx[opc] == 0) && (slot_idx >= opcoc[opc]))) {
                    if (operand.s.slot_type == helper_output_slot[current_call_idx-1].s.slot_type &&
                        operand.s.slot_idx == helper_output_slot[current_call_idx-1].s.slot_idx) {
                        helper_output_type[current_call_idx-1] = operand_type;
                        helper_output_slot[current_call_idx-1].s.valid = 0;
                    }
                }
            }
            if (is_imm == 0) {
                if (operand.s.slot_type == SUB_SLOT_XREG) {
                    xreg_valid |= shifted_slot_bit;
                } else if (operand.s.slot_type == SUB_SLOT_TMP) {
                    tmp_valid |= (1 << operand.s.slot_idx);
                    tmp_var_available &= ~shifted_slot_bit;
                    if (tmp_bits_type[operand.s.slot_idx] < operand_type) {
                        tmp_bits_type[operand.s.slot_idx] = operand_type;
                    }
                } else if (operand.s.slot_type == SUB_SLOT_XMM) {
                    xmm_valid |= shifted_slot_bit;
                }
                if (operand.s.slot_type == SUB_SLOT_TMP) {
                    if ((opc == call && slot_idx >= noargs) || (opc != call && slot_idx >= opcoc[opc])) {
                        if (!tmp_has_known_def[operand.s.slot_idx] && tmp_shadow_offset[current_call_idx][operand.s.slot_idx] == 0) {
                            tmp_shadow_offset[current_call_idx][operand.s.slot_idx] = shadow_call_offset;
                            LLVMType t = func_tmp_llvmtype[operand.s.slot_idx];
                            shadow_call_offset += (llvm_vector_elem_bit_counts[t*2] * llvm_vector_elem_bit_counts[t*2+1])/8;
                        }
                    }
                    if ((opc == call && slot_idx < noargs) || (opc != call && slot_idx < opcoc[opc])) {
                        tmp_has_known_def[operand.s.slot_idx] = 1;
                    }
                }
            }
            slot_idx += 1;
        } while (1);
        if (opc == call) {
            memset(tmp_has_known_def, 0, sizeof(tmp_has_known_def));
            if (!is_immo && oarg.s.valid) {
                tmp_has_known_def[oarg.s.slot_idx] = 1;
            }
            current_call_idx += 1;
            assert(current_call_idx < BB_MAX_CNT);
        }
    }
    tmp_var_available_backup = tmp_var_available;
    // Some helper return type maybe not known to us (for example memset).
    // Try to make a reasonable guess to make translate_call happy.
    if (current_call_idx > 0) {
        for (int i = 0; i < current_call_idx; ++i) {
            if (helper_output_slot[i].s.valid && helper_output_type[i] == LLVMInvalidType) {
                assert(helper_output_slot[i].s.slot_type == SUB_SLOT_TMP);
                if (func_tmp_llvmtype[helper_output_slot[i].s.slot_idx] == LLVMInvalidType) {
                    //FIXME - guess that is i64
                    helper_output_type[i] = LLVMInt64;
                } else {
                    helper_output_type[i] = func_tmp_llvmtype[helper_output_slot[i].s.slot_idx];
                }
                helper_output_slot[i].s.valid = 0;
            }
        }
    }

    char func_name[64];
    sprintf(func_name, "func_%lx", val);
    llvm_func = get_or_add_func_with_qemuaot_cc(func_name, fixed_vector_param_types, FIXED_VECTOR_PARAM_COUNT, 0, NoInlineAttr);
    for (int j = 0; j < FIXED_VECTOR_PARAM_COUNT; j++) {
        LLVMValueRef param = LLVMGetParam(llvm_func, j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);
    last_active_bb = entry;

    setup_func_stack();

    /*
    /// Add helper_dump_registers
    uint8_t buf[16];
    OHType h;
    h.h = helper_dump_registers;
    create_helper_env(buf, h, 0, 0);
    translate_call(call, buf);
    ///
    */

    current_call_idx = 0;
    // Handle each IR translation
    for (ptr = ptr_init; ptr < ptr_max; ptr = move_to_next(ptr), func_instr_cnt_remain -= 1) {
        OpCodeType opc = get_opcode(ptr);
        if (!exception_or_interrupt_on) {
            handle_single_instr(opc, ptr);
        }
        if (opc == call) {
            current_call_idx += 1;
        }
        tmp_var_available = tmp_var_available_backup;
    }

    cleanup_func_resource();
}

static void handle_single_instr(OpCodeType opc, void *ptr) {
#ifdef DEBUG
    printf("handle_single_instr: %s ptr:%lx", opcode_type_str[opc], ptr);
    void *next = move_to_next(ptr);
    unsigned char *byte = (unsigned char *)ptr;
    while (byte != (unsigned char *)next) {
        printf(" %02x", byte[0]);
        byte += 1;
    }
    printf("\n");
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
        assert(0);
        break;

    case abs_vec:
    case andc_i32:
    case bitsel_vec:
    case bswap16_i32:
    case bswap16_i64:
    case bswap32_i32:
    case clz_i32:
    case cmpsel_vec:
    case ctpop_i32:
    case ctpop_i64:
    case ctz_i32:
    case divs2_i32:
    case divs2_i64:
    case divs_i32:
    case divs_i64:
    case divu2_i32:
    case divu2_i64:
    case divu_i32:
    case divu_i64:
    case dup_vec:
    case eqv_i32:
    case eqv_i64:
    case eqv_vec:
    case ext_i32_i64:
    case extract2_i32:
    case extrh_i64_i32:
    case ld16s_i32:
    case ld16s_i64:
    case ld16u_i32:
    case ld16u_i64:
    case ld8s_i32:
    case ld8s_i64:
    case ld8u_i32:
    case muls2_i32:
    case muls2_i64:
    case mulsh_i32:
    case mulu2_i32:
    case mulu2_i64:
    case muluh_i32:
    case mul_vec:
    case nand_i32:
    case nand_i64:
    case nand_vec:
    case negsetcond_i32:
    case neg_vec:
    case nor_i32:
    case nor_i64:
    case nor_vec:
    case orc_i32:
    case orc_i64:
    case orc_vec:
    case rems_i32:
    case rems_i64:
    case remu_i32:
    case remu_i64:
    case rotli_vec:
    case rotls_vec:
    case rotlv_vec:
    case rotrv_vec:
    case sar_i32:
    case sari_vec:
    case sars_vec:
    case sarv_vec:
    case setcond_i32:
    case sextract_i32:
    case shls_vec:
    case shlv_vec:
    case shri_vec:
    case shrs_vec:
    case shrv_vec:
    case smax_vec:
    case smin_vec:
    case ssadd_vec:
    case sssub_vec:
    case st8_i32:
    case st8_i64:
    case usadd_vec:
    case ussub_vec:
        // TODO
        assert(0);

    case add_i64:
        translate_add_i64(opc, ptr);
        break;
    case add_i32:
    case add_vec:
        translate_binary(opc, ptr, LLVMBuildAdd);
        break;
    case andc_i64:
        translate_andc_i64(opc, ptr);
        break;
    case andc_vec:
        translate_andc_vec(opc, ptr);
        break;
    case and_i32:
    case and_i64:
        translate_binary(opc, ptr, LLVMBuildAnd);
        break;
    case and_vec:
        translate_binary(opc, ptr, LLVMBuildAnd);
        break;
    case bswap32_i64:
        translate_bswap32_i64(opc, ptr);
        break;
    case clz_i64:
        translate_clz_i64(opc, ptr);
        break;
    case cmp_vec:
        translate_cmp_vec(opc, ptr);
        break;
    case ctz_i64:
        translate_ctz_i64(opc, ptr);
        break;
    case deposit_i32:
    case deposit_i64:
        translate_deposit(opc, ptr);
        break;
    case dupm_vec:
        translate_dupm_vec(opc, ptr);
        break;
    case extract2_i64:
        translate_extract2_i64(opc, ptr);
        break;
    case extract_i32:
    case extract_i64:
        translate_extract(opc, ptr);
        break;
    case extrl_i64_i32:
    case mov_i32:
    case mov_i64:
    case mov_vec:
        translate_mov(opc, ptr);
        break;
    case ld_vec:
        translate_ld_vec(opc, ptr);
        break;
    case ld_i32:
    case ld_i64:
        translate_ld_env_xmm(opc, ptr);
        break;
    case extu_i32_i64:
    case ld8u_i64:
    case ld32u_i64:
        translate_ext(opc, ptr, LLVMBuildZExt);
        break;
    case ld32s_i64:
        translate_ext(opc, ptr, LLVMBuildSExt);
        break;
    case movcond_i32:
    case movcond_i64:
    case movcond_vec:
        translate_movcond(opc, ptr);
        break;
    case mul_i32:
    case mul_i64:
        translate_binary(opc, ptr, LLVMBuildMul);
        break;
    case mulsh_i64:
        translate_mulxh(opc, ptr, LLVMBuildSExt);
        break;
    case muluh_i64:
        translate_mulxh(opc, ptr, LLVMBuildZExt);
        break;
    case neg_i32:
    case neg_i64:
        translate_neg(opc, ptr);
        break;
    case negsetcond_i64:
        translate_negsetcond_i64(opc, ptr);
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
    case sar_i64:
        translate_binary(opc, ptr, LLVMBuildAShr);
        break;
    case setcond_i64:
        translate_setcond_i64(opc, ptr);
        break;
    case sextract_i64:
        translate_sextract_i64(opc, ptr);
        break;
    case shl_i32:
    case shl_i64:
        translate_binary(opc, ptr, LLVMBuildShl);
        break;
    case shli_vec:
        translate_binary(opc, ptr, LLVMBuildShl);
        break;
    case shr_i32:
    case shr_i64:
        translate_binary(opc, ptr, LLVMBuildLShr);
        break;
    case st16_i32:
    case st16_i64:
    case st32_i64:
    case st_i32:
    case st_i64:
    case st_vec:
        translate_st(opc, ptr);
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
        translate_binary(opc, ptr, LLVMBuildXor);
        break;
    case xor_vec:
        translate_binary(opc, ptr, LLVMBuildXor);
        break;
    case bswap64_i64:
        translate_bswap64_i64(opc, ptr);
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
    case call_direct:
        translate_call_direct(opc, ptr);
        break;
    case discard:
        translate_discard(opc, ptr);
        break;
    case call:
        translate_call(opc, ptr);
        break;
    default: assert(0);
    }
}

void module_prolog() {
    create_module("qemuaot");
    builder = LLVMCreateBuilder();

    // Parameter setup (same for all functions)
    LLVMTypeRef vscale_i64 = LLVMScalableVectorType(LLVMInt64Type(), 1); // <vscale x 1 x i64>
    const char *base_names[20] = {
        "rax", "rcx", "rdx", "rbx",
        "rsp", "rbp", "rsi", "rdi",
        "r8", "r9", "r10", "r11",
        "r12", "r13", "r14", "r15",
        "cc_src", "cc_dst", "cc_op", "rip"
    };
    for (int i = 0; i < FIXED_PARAM_COUNT; i++) {
        if (i < 16) {
            fixed_vector_param_types[i] = LLVMInt64Type();
            fixed_vector_param_llvmtypes[i] = LLVMInt64;
        } else if (i == 16 || i == 17 || i == 19) {
            fixed_vector_param_types[i] = LLVMInt64Type();
            fixed_vector_param_llvmtypes[i] = LLVMInt64;
        } else if (i == 18) {
            fixed_vector_param_types[i] = LLVMInt32Type();
            fixed_vector_param_llvmtypes[i] = LLVMInt32;
        }
        fixed_vector_arg_names[i] = base_names[i];
    }
    static char extra_name_buf[30][16];
    static char stack_name_buf[FIXED_VECTOR_PARAM_COUNT][16];
    static char tmp_name_buf[1<<5][16];
    for (int i = 0; i < (FIXED_VECTOR_PARAM_COUNT - FIXED_PARAM_COUNT)/2; ++i) {
        int idx = FIXED_PARAM_COUNT + i * 2;
        fixed_vector_param_types[idx] = vscale_i64;
        fixed_vector_param_types[idx + 1] = vscale_i64;
        fixed_vector_param_llvmtypes[idx] = LLVMVector2xi64;
        fixed_vector_param_llvmtypes[idx + 1] = LLVMVector2xi64;
        snprintf(extra_name_buf[i * 2], sizeof(extra_name_buf[i * 2]), "xmm%d", i);
        snprintf(extra_name_buf[i * 2 + 1], sizeof(extra_name_buf[i * 2 + 1]), "ymm%d_h", i);
        fixed_vector_arg_names[idx] = extra_name_buf[i * 2];
        fixed_vector_arg_names[idx + 1] = extra_name_buf[i * 2 + 1];
    }
    for (int i = FIXED_VECTOR_PARAM_COUNT; i < (FIXED_VECTOR_PARAM_COUNT + TRAMPOLINE_PARAM_COUNT); ++i) {
        fixed_vector_param_types[i] = LLVMInt64Type();
    }
    for (int i = 0; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        snprintf(stack_name_buf[i], sizeof(stack_name_buf[i]), "%s.stack", fixed_vector_arg_names[i]);
        fixed_vector_stack_names[i] = stack_name_buf[i];
    }
    xmm_tmp_stack_names[0] = "xmmt";
    xmm_tmp_stack_names[1] = "ymmt_h";
    for (int i = 0; i < (1<<5); ++i) {
        snprintf(tmp_name_buf[i], sizeof(tmp_name_buf[i]), "tmp%d.stack", i);
        tmp_stack_names[i] = tmp_name_buf[i];
    }
    static char ir_var_name_buffer[('z'-'a'+1)*(('z'-'a'+1)+('Z'-'A'+1))][3];
    for (char c1 = 'a'; c1 <= 'z'; ++c1) {
        for (char c2 = 'a'; c2 <= 'z'; ++c2) {
            int idx = (c1 - 'a') * (('z' - 'a' + 1) + ('Z' - 'A' + 1)) + (c2 - 'a');
            ir_var_name_buffer[idx][0] = c1;
            ir_var_name_buffer[idx][1] = c2;
            ir_var_name_buffer[idx][2] = 0;
            ir_var_name[idx] = ir_var_name_buffer[idx];
        }
        for (char c2 = 'A'; c2 <= 'Z'; ++c2) {
            int idx = (c1 - 'a') * (('z' - 'a' + 1) + ('Z' - 'A' + 1)) + ('z' - 'a' + 1) + (c2 - 'A');
            ir_var_name_buffer[idx][0] = c1;
            ir_var_name_buffer[idx][1] = c2;
            ir_var_name_buffer[idx][2] = 0;
            ir_var_name[idx] = ir_var_name_buffer[idx];
        }
    }

    llvm_int_types[LLVMInt8] = LLVMInt8Type();
    llvm_int_types[LLVMInt16] = LLVMInt16Type();
    llvm_int_types[LLVMInt32] = LLVMInt32Type();
    llvm_int_types[LLVMInt64] = LLVMInt64Type();
    llvm_int_types[LLVMVector16xi8] = LLVMVectorType(LLVMInt8Type(), 16);
    llvm_int_types[LLVMVector8xi16] = LLVMVectorType(LLVMInt16Type(), 8);
    llvm_int_types[LLVMVector4xi32] = LLVMVectorType(LLVMInt32Type(), 4);
    llvm_int_types[LLVMVector2xi64] = LLVMVectorType(LLVMInt64Type(), 2);

    llvm_vector_elem_bit_counts[LLVMInt8*2] = 1;
    llvm_vector_elem_bit_counts[LLVMInt8*2+1] = 8;
    llvm_vector_elem_bit_counts[LLVMInt16*2] = 1;
    llvm_vector_elem_bit_counts[LLVMInt16*2+1] = 16;
    llvm_vector_elem_bit_counts[LLVMInt32*2] = 1;
    llvm_vector_elem_bit_counts[LLVMInt32*2+1] = 32;
    llvm_vector_elem_bit_counts[LLVMInt64*2] = 1;
    llvm_vector_elem_bit_counts[LLVMInt64*2+1] = 64;
    llvm_vector_elem_bit_counts[LLVMVector16xi8*2] = 16;
    llvm_vector_elem_bit_counts[LLVMVector16xi8*2+1] = 8;
    llvm_vector_elem_bit_counts[LLVMVector8xi16*2] = 8;
    llvm_vector_elem_bit_counts[LLVMVector8xi16*2+1] = 16;
    llvm_vector_elem_bit_counts[LLVMVector4xi32*2] = 4;
    llvm_vector_elem_bit_counts[LLVMVector4xi32*2+1] = 32;
    llvm_vector_elem_bit_counts[LLVMVector2xi64*2] = 2;
    llvm_vector_elem_bit_counts[LLVMVector2xi64*2+1] = 64;

    env_var_offset[cc_src2] = 160;
    env_var_offset[es_base] = 192;
    env_var_offset[cs_base] = 216;
    env_var_offset[ss_base] = 240;
    env_var_offset[ds_base] = 264;
    env_var_offset[fs_base] = 288;
    env_var_offset[gs_base] = 312;

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
}

void module_epilog() {
    LLVMDumpModule(module);
#if 0
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

    TcgContext ctx = {0};
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
        printf("Usage: ./app <tcg-ir>\n");
        return -1;
    }

    sprintf(output_file, "%s.o", argv[1]);
    LLVMInitializeRISCVTargetInfo();
    LLVMInitializeRISCVTarget();
    LLVMInitializeRISCVTargetMC();
    LLVMInitializeRISCVAsmPrinter();
    LLVMInitializeRISCVAsmParser();

    char *error_msg = NULL;
    const char *default_triple = "riscv64-unknown-linux-gnu";
    LLVMTargetRef target;
    if (LLVMGetTargetFromTriple(default_triple, &target, &error_msg)) {
        printf("Failed to get target from triple %s\n", error_msg);
        return -1;
    }
    const char* features = "+m,+a,+f,+d,+v";
    target_machine = LLVMCreateTargetMachine(target, default_triple, "generic", features,
                                             LLVMCodeGenLevelDefault, LLVMRelocDefault, LLVMCodeModelDefault);

    module_prolog();
    parse_tcg_instructions(argv[1]);
    module_epilog();
    return 0;
}
