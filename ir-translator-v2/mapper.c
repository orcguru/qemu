#include <stdio.h>
#include <limits.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <llvm-c/Core.h>
#include <llvm-c/Target.h>
#include <llvm-c/TargetMachine.h>
#include <llvm-c/Transforms/PassBuilder.h>
#include <llvm-c/BitReader.h>
#include <llvm-c/Linker.h>
#include <llvm-c/Support.h>
#include <stdbool.h>
#include <glib.h>
#include "tcg_ast.h"
#include "tcg_context.h"
#include "tcg_parser.tab.h"
#include "tcg_lexer.yy.h"
#include "tcg_mapper.h"

#define LARGE_SHADOW_MAP              1
//#define COLLECT_TRAMPOLINE_IR       1
//#define HELPER_COUNTERS             1
#define TRAMPOLINE_CNT_OFFSET       104
#define HELPER_COUNTERS_OFFSET      128
//#define BUILD_RISCV_ON_AARCH        1
//#define DUMP_IR                     1
#define DEBUG                       1
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
#define OPC_VECTOR_TO_VES(T)      ((T - OPC_FIRST_SCALAR_TYPE) % 4)
#define OPC_VECTOR_SIZE(T)          (\
  (LLVMVector16xi8 <= T && T <= LLVMVector2xi64) ? VS128 : ( \
    (LLVMVector8xi8 <= T && T <= LLVMVector1xi64) ? VS64 : VS_INVALID \
    ) \
  )
#define OPC_VECTOR_ELEMENT_BYTES(T)     (1 << (T - LLVMInt8))

#define DECLARE_AND_INIT_TYPE_FOR_ALL   \
    uint8_t is_vec = is_vector(u);    \
    LLVMType vtype = is_vec ? get_llvm_vector_type(u) : LLVMInvalidType;      \
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
    LLVMType type_in = get_llvm_vector_type(u);    \
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

/* ============================================================
 * New operand access API (UnifiedInstr-based)
 * ============================================================ */
#include "unified_instr.h"
#include "build_temp_instr.h"
/* New CREATE_* macros – see patch_create_macros.h */
#include "patch_create_macros.h"
#include "mapper_util.h"

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
extern const LLVMType helper_collapse_xmm_arg_type[HELPER_MAX][MAX_ADDED_ARGS];
extern const LLVMType helper_return_type[HELPER_MAX];
extern const int helper_require_exception_path[HELPER_MAX];
extern const int helper_do_not_sync_vector[HELPER_MAX];

#define get_relop(u) get_relop_from_any_operand(u)
#define IS_YMM_HELPER(h)            (h > ymm_helper_begin && h < HELPER_MAX)
#define IS_XMM_HELPER(h)            (h > xmm_helper_begin && h < ymm_helper_begin)
#define IS_FLOATINGPOINT_INLINED_HELPER(h)            (h > floatingpoint_inlined_helper_begin && h < floatingpoint_inlined_helper_end)
#define INLINE_HELPER_ENABLED(h)    (IS_XMM_HELPER(h) || IS_YMM_HELPER(h) || IS_FLOATINGPOINT_INLINED_HELPER(h))

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

#define GET_LLVM_TYPE_ALIGNMENT(type)       (type <= LLVMInt64 ? 8 : 16)

#define GET_ALIGNMENT_FROM_CONSTANT(c)      ((c) % 8 == 0 ? 8 : ((c) % 4 == 0 ? 4 : ((c) % 2 == 0 ? 2 : 1)))

static char func_name_prefix[33] = {0};
static LLVMAttributeRef target_features_attr = NULL;
static LLVMAttributeRef NoInlineAttr = NULL;
static LLVMAttributeRef AlwaysInlineAttr = NULL;
static LLVMAttributeRef NoUnwindAttr = NULL;
static LLVMTargetMachineRef target_machine = NULL;
static LLVMContextRef context = NULL;
static LLVMModuleRef module = NULL;
static LLVMBuilderRef builder = NULL;
static LLVMValueRef llvm_func = NULL;
static LLVMBasicBlockRef last_active_bb = NULL;
static UnifiedInstr *func_head = NULL;
#define FIXED_PARAM_COUNT           XREG_MAX
#define FIXED_VECTOR_PARAM_COUNT   (XREG_MAX + XMM_COUNT * 2)

#define TARGET_QEMUAOT_FASTPATH                                     0
#define TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_DROP_ALIAS_POINTER     1
#define TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_EXPAND_ALIAS_POINTER   2
#define TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER   \
        TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_EXPAND_ALIAS_POINTER
#define TARGET_QEMUAOT_CC_COMPUTE                                   3
#define TARGET_QEMUAOT_HELPER                                       4
#define TARGET_DEFAULT_HELPER_PASSTHROUGH_VECTOR                    5
#define TARGET_DEFAULT_HELPER_CONSTRUCT_VECTOR                      6
#define TARGET_QEMUAOT_HELPER_SECOND_HALF                           7

#define TYPE_AND_VALUE          0
#define TYPE_ONLY               1
#define VALUE_ONLY              2

#define REQUIRES_CARRY_BIT(opc)         (opc == addci_i32 || opc == addci_i64 ||    \
                                         opc == addcio_i32 || opc == addcio_i64 ||  \
                                         opc == addco_i32 || opc == addco_i64)
#define REQUIRES_BORROW_BIT(opc)        (opc == subbi_i32 || opc == subbi_i64 || \
                                         opc == subbio_i32 || opc == subbio_i64 || \
                                         opc == subbo_i32 || opc == subbo_i64)

typedef struct AllocaWithAlignment {
    LLVMValueRef alloca;
    unsigned alignment;
} AllocaWithAlignment;

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
static AllocaWithAlignment func_xreg_alloca[1<<REGISTER_INDEX_SHIFT] = {NULL};
static AllocaWithAlignment func_tmp_alloca[1<<STACK_INDEX_SHIFT] = {NULL};
static AllocaWithAlignment func_xmm_alloca[1<<REGISTER_INDEX_SHIFT] = {NULL};
static LLVMType func_xreg_llvmtype[1<<REGISTER_INDEX_SHIFT] = {0};
static LLVMType func_tmp_llvmtype[1<<STACK_INDEX_SHIFT] = {0};
static LLVMType func_xmm_llvmtype[1<<REGISTER_INDEX_SHIFT] = {0};
static uint32_t env_var_offset[ENVVarMAX] = {0};
static OperandType alias_tmp[1<<STACK_INDEX_SHIFT] = {0};
static LLVMIntPredicate llvm_predicate[RELOPMAX] = {0};
static uint32_t br_cnt = 0;
static uint64_t current_func_offset = 0;
static uint8_t current_call_idx = 0;
#define SHADOW_CALL_OFFSET_MAX      (4096 - 32)
static int32_t shadow_call_offset = 16;
static uint32_t xreg_valid = 0, xmm_valid = 0;
static uint8_t tmp_valid_non_zero = 0;
static LLVMType tmp_bits_type[1<<STACK_INDEX_SHIFT] = {0};
static char output_file[PATH_MAX+2] = {0};
static char list_file[PATH_MAX+10] = {0};
static FILE *list_fp = NULL;
static OperandType dummy_slot_for_debug;
static char template_path[PATH_MAX] = {0};
static char output_path[PATH_MAX] = {0};
static char input_path[PATH_MAX] = {0};
static uint64_t x64_exec_end = 0;
static int tcg_ir_head = 0;
static int carrybit_on = 0;
static int borrowbit_on = 0;
static LLVMValueRef carrybit_alloca = NULL;
static LLVMValueRef borrowbit_alloca = NULL;
#define LLVMNoInlineAttribute       32
#define LLVMAlwaysInlineAttribute   3

typedef struct active_label_info {
    LLVMValueRef llvm_func;
    uint8_t current_active_label_cnt;
    uint8_t current_active_labels[BB_MAX_CNT];
    struct active_label_info *next;
} active_label_info_t;
static GHashTable *current_active_label_info = NULL;

static void do_store(OpCodeType opc, LLVMValueRef val, LLVMType val_tidx, OperandType out);
static LLVMValueRef get_env_ptr_raw();
static OperandType get_env_ptr(OpCodeType opc);
static OperandType get_shadow_stack_pointer(OpCodeType opc);
static void set_shadow_stack_pointer(OpCodeType opc, OperandType val);
static LLVMBasicBlockRef get_bb(const char *name);
static void handle_single_instr(OpCodeType opc, const UnifiedInstr *u);
static uint8_t do_link_helper(HelperType h, const char *build_macro, const char *bc_name, const char *c_file);
static uint8_t is_tail_call(HelperType h);
static uint8_t is_opc_end_of_control_flow(OpCodeType opc, const UnifiedInstr *u);
static LLVMValueRef get_or_add_func_with_qemuaot_cc(const char *name, int with_ret);
static void setup_func_stack();
static LLVMValueRef get_trampoline(HelperType h, LLVMValueRef helper_func, uint8_t do_return, uint8_t with_ret, OperandType *operands, uint32_t *is_imm, uint8_t operands_cnt, LLVMValueRef next_func, int spill_cnt, XMMRegType *spilled_xmm_regs, int fix_second_half_addr, int target_domain, const UnifiedInstr *u);
static LLVMValueRef get_trampoline_do_not_sync_vector(HelperType h, LLVMValueRef helper_func, OperandType *operands, uint32_t *is_imm, uint8_t operands_cnt, LLVMValueRef next_func, int target_domain, const UnifiedInstr *u);
static LLVMValueRef get_exception_handler(HelperType h, LLVMValueRef helper_func, uint8_t with_ret, OperandType *operands, uint32_t *is_imm, uint8_t operands_cnt, LLVMValueRef next_func, int spill_cnt, XMMRegType *spilled_xmm_regs, XMMRegType *passenger_xmm_regs, int fix_second_half_addr, const UnifiedInstr *u);
static void translate_jmp_ind(OpCodeType opc, const UnifiedInstr *u);
static void translate_jumptable(OpCodeType opc, const UnifiedInstr *u);
static void translate_cc_compute_inband(OpCodeType opc, const UnifiedInstr *u);
static void translate_helper_outband(OpCodeType opc, const UnifiedInstr *u);
static void register_labels_for_func(LLVMValueRef func);
static uint8_t *get_current_active_labels(LLVMValueRef func);
static uint8_t get_current_active_label_cnt(LLVMValueRef func);
static void set_current_active_label_cnt(uint8_t current_active_label_cnt);
static LLVMValueRef get_source_node_imm_or_stack(OpCodeType opc, uint32_t is_imm, OperandType operand, LLVMType tidx, int splat);
static LLVMTypeRef get_vector_parameter_type_for_arch();
static LLVMValueRef reload_vector(XMMRegType xmm_reg);
static int collect_arguments_and_types(HelperType h, int target_domain, int gen_flag, OperandType *operands, uint32_t *is_imm, uint8_t operands_cnt, LLVMValueRef appendix1, LLVMValueRef appendix2, LLVMValueRef current_func,
                LLVMTypeRef *out_typeref, int out_typeref_limit, LLVMValueRef *out_valref, const char *func_name);

#define GET_2_OPERANDS()                                \
    do {                                                \
        op0 = get_operand_legacy(u, 0, &is_imm0); \
        op1 = get_operand_legacy(u, 1, &is_imm1); \
        assert(!is_imm0 && op0.s.valid && !is_imm1 && op1.s.valid);  \
    } while (0)

#define GET_2_OPERANDS_NOCHECK()                        \
    do {                                                \
        op0 = get_operand_legacy(u, 0, &is_imm0); \
        op1 = get_operand_legacy(u, 1, &is_imm1); \
    } while (0)

#define GET_3_OPERANDS()                                \
    do {                                                \
        op0 = get_operand_legacy(u, 0, &is_imm0); \
        op1 = get_operand_legacy(u, 1, &is_imm1); \
        op2 = get_operand_legacy(u, 2, &is_imm2); \
        assert(!is_imm0 && op0.s.valid && !is_imm1 && op1.s.valid && !is_imm2 && op2.s.valid);  \
    } while (0)

#define GET_3_OPERANDS_NOCHECK()                        \
    do {                                                \
        op0 = get_operand_legacy(u, 0, &is_imm0); \
        op1 = get_operand_legacy(u, 1, &is_imm1); \
        op2 = get_operand_legacy(u, 2, &is_imm2); \
    } while (0)

#define GET_3_OPERANDS_NOCHECK_DBG()                    \
    do {                                                \
        op0 = get_operand_legacy(u, 0, &is_imm0); \
        op1 = get_operand_legacy(u, 1, &is_imm1); \
        op2 = get_operand_legacy(u, 2, &is_imm2); \
        printf("is_imm0:%d, is_imm1:%d, is_imm2:%d\n", is_imm0, is_imm1, is_imm2);  \
        printf("op0 - slot_type:%d, slot_idx::%d, offset:%d\n", op0.s.slot_type, op0.s.slot_idx, op0.s.offset);    \
        printf("op1 - slot_type:%d, slot_idx::%d, offset:%d\n", op1.s.slot_type, op1.s.slot_idx, op1.s.offset);    \
        printf("op2 - slot_type:%d, slot_idx::%d, offset:%d\n", op2.s.slot_type, op2.s.slot_idx, op2.s.offset);    \
    } while (0)

#define GET_4_OPERANDS()                                \
    do {                                                \
        op0 = get_operand_legacy(u, 0, &is_imm0); \
        op1 = get_operand_legacy(u, 1, &is_imm1); \
        op2 = get_operand_legacy(u, 2, &is_imm2); \
        op3 = get_operand_legacy(u, 3, &is_imm3); \
        assert(!is_imm0 && op0.s.valid && !is_imm1 && op1.s.valid && !is_imm2 && op2.s.valid && !is_imm3 && op3.s.valid);  \
    } while (0)

#define GET_5_OPERANDS()                                \
    do {                                                \
        op0 = get_operand_legacy(u, 0, &is_imm0); \
        op1 = get_operand_legacy(u, 1, &is_imm1); \
        op2 = get_operand_legacy(u, 2, &is_imm2); \
        op3 = get_operand_legacy(u, 3, &is_imm3); \
        op4 = get_operand_legacy(u, 4, &is_imm4); \
        assert(!is_imm0 && op0.s.valid && !is_imm1 && op1.s.valid && !is_imm2 && op2.s.valid && !is_imm3 && op3.s.valid && !is_imm4 && op4.s.valid);  \
    } while (0)

static uint8_t is_opc_end_of_control_flow(OpCodeType opc, const UnifiedInstr *u) {
    if (opc == jmp_direct) {
        return 1;
    } else if (opc == call) {
        HelperType h = get_helper(u);
        if (h == helper_cc_compute_all || h == helper_cc_compute_c) {
            return 0;
        } else {
            return 1;
        }
    }
    return 0;
}

static void init_list_file(const char *name) {
    list_fp = fopen(name, "w");
    assert(list_fp);
}

static void add_list_info(const char *func, const char *type) {
    assert(list_fp);
    fprintf(list_fp, "%s %s\n", func, type);
}

static void fini_list_file() {
    assert(list_fp);
    fclose(list_fp);
}

static LLVMValueRef build_store_with_alignment(LLVMBuilderRef B, LLVMValueRef Val,
                            LLVMValueRef PointerVal, unsigned Bytes) {
    LLVMValueRef ST = LLVMBuildStore(B, Val, PointerVal);
    LLVMSetAlignment(ST, Bytes);
    return ST;
}

static LLVMValueRef build_load_with_alignment(LLVMBuilderRef B, LLVMTypeRef Ty,
                            LLVMValueRef PointerVal, const char *Name, unsigned Bytes) {
    LLVMValueRef LD = LLVMBuildLoad2(B, Ty, PointerVal, Name);
    LLVMSetAlignment(LD, Bytes);
    return LD;
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
    func_tmp_alloca[tmp.s.slot_idx].alloca = alloca_inst;
    func_tmp_alloca[tmp.s.slot_idx].alignment = GET_LLVM_TYPE_ALIGNMENT(type);
    func_tmp_llvmtype[tmp.s.slot_idx] = type;
    return tmp;
}

static AllocaWithAlignment get_stack_alloca(OperandType operand) {
    AllocaWithAlignment alloca_w_align;
    alloca_w_align.alloca = NULL;
    alloca_w_align.alignment = 0;
    if (operand.s.slot_type == SUB_SLOT_XREG) {
        alloca_w_align = func_xreg_alloca[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_TMP) {
        alloca_w_align = func_tmp_alloca[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_XMM) {
        alloca_w_align = func_xmm_alloca[operand.s.slot_idx];
    } else {
        assert(0);
    }
    return alloca_w_align;
}

static LLVMType get_stack_type(OperandType operand) {
    if (operand.s.slot_type == SUB_SLOT_XREG) {
        return func_xreg_llvmtype[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_TMP) {
        if (has_alias(operand) == 0) {
            return func_tmp_llvmtype[operand.s.slot_idx];
        } else {
            OperandType alias = get_alias(operand);
            assert(alias.s.valid && alias.s.slot_type == SUB_SLOT_ENV && alias.s.offset == 0);
            return OPC_ADDR_T;
        }
    }
    assert(0);
}

static OperandType get_tmp_and_do_alloc_with_init(LLVMType type, uint64_t val) {
    OperandType tmp = get_tmp_and_do_alloc(type);
    LLVMValueRef constant = LLVMConstInt(llvm_int_types[type], val, 0);
    build_store_with_alignment(builder, constant, get_stack_alloca(tmp).alloca, get_stack_alloca(tmp).alignment);
    return tmp;
}

static const char *get_next_var_name(const char *tag, OperandType slot_name_for_debug) {
    assert(ir_var_name_idx < sizeof(ir_var_name)/sizeof(const char *));
    return ir_var_name[ir_var_name_idx++];
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
    NoUnwindAttr = LLVMCreateEnumAttribute(context, LLVMGetEnumAttributeKindForName("nounwind", strlen("nounwind")), 0);
    const char *attr_key = "target-features";
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    const char *attr_value = "+neon";
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    // Unfortunately on Spacemit(R) X60, following instruction requires alignment: vse64.v v30,(a4)
    //const char *attr_value = "+m,+a,+f,+d,+v,+unaligned-scalar-mem,+unaligned-vector-mem";
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

static OperandType get_env_ptr(OpCodeType opc) {
    OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
    LLVMValueRef val = get_env_ptr_raw();
    do_store(opc, val, OPC_ADDR_T, tmp);
    return tmp;
}

static LLVMValueRef check_scalable_vector_perform_load(LLVMType val_tidx, LLVMValueRef addr, unsigned align) {
    LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_store_types[val_tidx], 0), get_next_var_name("check_scalable_store", dummy_slot_for_debug));
    LLVMValueRef val = build_load_with_alignment(builder, llvm_int_store_types[val_tidx], ptr, get_next_var_name("check_scalable_load", dummy_slot_for_debug), align);
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

static LLVMValueRef check_scalable_vector_perform_store(LLVMValueRef val, LLVMType val_tidx, LLVMValueRef addr, unsigned align) {
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
    return build_store_with_alignment(builder, val, ptr, align);
}

static void do_store(OpCodeType opc, LLVMValueRef val, LLVMType val_tidx, OperandType out) {
    assert(val_tidx != LLVMInvalidType && val_tidx < LLVMMAXType);
    if (out.s.slot_type == SUB_SLOT_ENVVAR) {
        OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
        OperandType env = get_env_ptr(opc);
        CREATE_ADD64(tmp, env, env_var_offset[out.s.slot_idx]);
        LLVMValueRef tmp_src = get_source_node_imm_or_stack(opc, 0, tmp, OPC_ADDR_T, 0);
        check_scalable_vector_perform_store(val, val_tidx, tmp_src, 8);
    } else if (out.s.slot_type == SUB_SLOT_ENV) {
        OperandType tmp = get_tmp_and_do_alloc(OPC_ADDR_T);
        OperandType env = get_env_ptr(opc);
        // v64 type stores into MMX region
        CREATE_ADD64(tmp, env, out.s.offset);
        LLVMValueRef tmp_src = get_source_node_imm_or_stack(opc, 0, tmp, OPC_ADDR_T, 0);
        check_scalable_vector_perform_store(val, val_tidx, tmp_src, GET_ALIGNMENT_FROM_CONSTANT(out.s.offset));
    } else {
        LLVMType out_idx = get_stack_llvmtype(out);
#ifdef DEBUG
        if (out_idx != val_tidx) {
            printf("%s need to convert type val_tidx:%d out_idx:%d\n", __FUNCTION__, val_tidx, out_idx); fflush(NULL);
        }
#endif
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
        build_store_with_alignment(builder, val, get_stack_alloca(out).alloca, get_stack_alloca(out).alignment);
    }
}

static LLVMValueRef get_source_node_imm_or_stack(OpCodeType opc, uint32_t is_imm, OperandType operand, LLVMType tidx, int splat) {
    assert(tidx != LLVMInvalidType && tidx < LLVMMAXType);
    LLVMTypeRef type = llvm_int_types[tidx];
#ifdef DEBUG
    printf("%s LLVMType:%d\n", __FUNCTION__, tidx); fflush(NULL);
#endif
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
                    LLVMValueRef element_value = LLVMConstInt(llvm_int_types[OPC_VECTOR_TO_FIXED(tidx)], bit_cnt < 64 ? (val & ((1UL<<bit_cnt)-1)) : val, 0);
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
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, tmp_src, LLVMPointerType(val_type, 0), get_next_var_name("source_env_ptr_offset", operand));
        ret = build_load_with_alignment(builder, val_type, ptr, get_next_var_name("source_val", operand), 8);
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
            ret = build_load_with_alignment(builder, type, ptr, get_next_var_name("source_val", operand), GET_ALIGNMENT_FROM_CONSTANT(operand.s.offset));
        }
    } else if (operand.s.slot_type == SUB_SLOT_XMM) {
        if (operand.s.offset) {
            // Vector operations do not have non-zero offset
            assert(tidx <= LLVMInt64);
            assert(llvm_vector_elem_bit_counts[tidx*2] == 1);
            LLVMTypeRef vtype = NULL;
            int elem_idx = 0;
            LLVMType vec_type = OPC_FIXED_TO_VECTOR128(tidx);
            vtype = llvm_int_types[vec_type];
            assert(operand.s.offset % OPC_VECTOR_ELEMENT_BYTES(tidx) == 0);
            elem_idx = operand.s.offset / OPC_VECTOR_ELEMENT_BYTES(tidx);
            LLVMValueRef vec = build_load_with_alignment(builder, vtype, get_stack_alloca(operand).alloca, get_next_var_name("source_vec", operand), get_stack_alloca(operand).alignment);
            LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], elem_idx, 0);
            if (llvm_int_types[vec_type] != llvm_int_store_types[vec_type]) {
                LLVMTypeRef intrinsic_types[] = {llvm_int_types[vec_type], llvm_int_types[OPC_ADDR_T]};
                LLVMTypeRef intrinsic_func_type = LLVMFunctionType(llvm_int_store_types[vec_type], intrinsic_types, 2, 0);
                char intrinsic_func_name[128] = {0};
                sprintf(intrinsic_func_name, "llvm.vector.extract.v%di%d.nxv%di%d", llvm_vector_elem_bit_counts[vec_type*2], llvm_vector_elem_bit_counts[vec_type*2+1], llvm_vector_elem_bit_counts[vec_type*2]/2, llvm_vector_elem_bit_counts[vec_type*2+1]);
                assert(strlen(intrinsic_func_name) < sizeof(intrinsic_func_name));
                LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, intrinsic_func_name);
                if (!intrinsic_func) {
                    intrinsic_func = LLVMAddFunction(module, intrinsic_func_name, intrinsic_func_type);
                }
                LLVMValueRef index_0 = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
                LLVMValueRef intrinsic_call_args[] = {vec, index_0};
                vec = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 2, get_next_var_name("check_scalable_store", dummy_slot_for_debug));
            }
            ret = LLVMBuildExtractElement(builder, vec, index, get_next_var_name("source_val", operand));
        } else {
            ret = build_load_with_alignment(builder, type, get_stack_alloca(operand).alloca, get_next_var_name("source_val", operand), get_stack_alloca(operand).alignment);
        }
    } else {
        LLVMType load_type = get_stack_type(operand);
        if (tidx <= LLVMInt64 && load_type <= LLVMInt64) {
            ret = build_load_with_alignment(builder, llvm_int_types[load_type], get_stack_alloca(operand).alloca, get_next_var_name("source_val", operand), get_stack_alloca(operand).alignment);
            if (tidx < load_type) {
                ret = LLVMBuildTrunc(builder, ret, type, get_next_var_name(opcode_type_str[opc], operand));
            } else if (tidx > load_type) {
                ret = LLVMBuildZExt(builder, ret, type, get_next_var_name(opcode_type_str[opc], operand));
            }
        } else {
            ret = build_load_with_alignment(builder, type, get_stack_alloca(operand).alloca, get_next_var_name("source_val", operand), get_stack_alloca(operand).alignment);
        }
    }
    return ret;
}

void translate_binary(OpCodeType opc, const UnifiedInstr *u, LLVM_BIN_API api) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    uint32_t idx = opcoc[opc];
    op0 = get_operand_legacy(u, 0, &is_imm0);
    assert(!is_imm0 && op0.s.valid);
    op1 = get_operand_legacy(u, idx, &is_imm1);
    op2 = get_operand_legacy(u, idx + 1, &is_imm2);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 0);
    LLVMValueRef out_val = api(builder, src1, src2, get_next_var_name(opcode_type_str[opc], op0));
    do_store(opc, out_val, type_out, op0);
}

void translate_binary_splat_immediate(OpCodeType opc, const UnifiedInstr *u, LLVM_BIN_API api) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    uint32_t idx = opcoc[opc];
    op0 = get_operand_legacy(u, 0, &is_imm0);
    assert(!is_imm0 && op0.s.valid);
    op1 = get_operand_legacy(u, idx, &is_imm1);
    op2 = get_operand_legacy(u, idx + 1, &is_imm2);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 1);
    LLVMValueRef out_val = api(builder, src1, src2, get_next_var_name(opcode_type_str[opc], op0));
    do_store(opc, out_val, type_out, op0);
}

void translate_mulxh(OpCodeType opc, const UnifiedInstr *u, LLVM_EXT_API api) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();
    LLVMTypeRef dtype = (opc == mulsh_i64 || opc == muluh_i64) ? LLVMInt128Type() : LLVMInt64Type();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, 0, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, 0, op2, type_in, 0);
    src1 = api(builder, src1, dtype, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    src2 = api(builder, src2, dtype, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef out = LLVMBuildMul(builder, src1, src2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef shift = LLVMConstInt(dtype, (opc == mulsh_i64 || opc == muluh_i64) ? 64 : 32, 0);
    out = LLVMBuildLShr(builder, out, shift, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    out = LLVMBuildTrunc(builder, out, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], op0));
    do_store(opc, out, type_out, op0);
}

void translate_muls2(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2, is_imm3;
    OperandType op0, op1, op2, op3;
    GET_4_OPERANDS();
    CREATE_MUL(op0, op2, op3);
    CREATE_MULXH(op1, op2, op3, LLVMBuildSExt);
}

void translate_mulu2(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2, is_imm3;
    OperandType op0, op1, op2, op3;
    GET_4_OPERANDS();
    CREATE_MUL(op0, op2, op3);
    CREATE_MULXH(op1, op2, op3, LLVMBuildZExt);
}

void translate_not(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();
    CREATE_XOR_IMM2(op0, op1, -1UL);
}

void translate_andc(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS_NOCHECK();
    assert(!is_imm0 && !is_imm1);
    OperandType in2;
    if (is_imm2) {
        in2 = get_tmp_and_do_alloc_with_init(type_out, op2.i);
    } else {
        in2 = op2;
    }
    CREATE_NOT(tmp, in2);
    CREATE_AND(op0, op1, tmp);
}

void translate_nand(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();
    CREATE_AND(tmp, op1, op2);
    CREATE_NOT(op0, tmp);
}

void translate_eqv(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();
    CREATE_XOR(tmp, op1, op2);
    CREATE_NOT(op0, tmp);
}

void translate_nor(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();
    CREATE_OR(tmp, op1, op2);
    CREATE_NOT(op0, tmp);
}

void translate_orc(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();
    CREATE_NOT(tmp, op2);
    CREATE_OR(op0, op1, tmp);
}

void translate_neg(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();

    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, op1, type_in, 0);
    LLVMValueRef zero = LLVMConstInt(llvm_int_types[type_in], 0, 0);
    LLVMValueRef out = LLVMBuildSub(builder, zero, src, get_next_var_name(opcode_type_str[opc], op0));
    do_store(opc, out, type_out, op0);
}

void translate_mov(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS_NOCHECK();
    assert(!is_imm0 && op0.s.valid);

    LLVMValueRef src = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    if (type_out < type_in) {
        src = LLVMBuildTrunc(builder, src, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    }
    do_store(opc, src, type_out, op0);
}

void translate_rotr(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    OperandType t2 = get_tmp_and_do_alloc(type_out);
    OperandType t3 = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();

    OperandType mask = get_tmp_and_do_alloc_with_init(type_out, type_out == LLVMInt32 ? (32-1) : (64-1));
    CREATE_AND(t2, op2, mask);
    CREATE_SHR_SLOT(t0, op1, t2);
    OperandType constant = get_tmp_and_do_alloc_with_init(type_out, type_out == LLVMInt32 ? 32 : 64);
    CREATE_SUB(t1, constant, op2);
    CREATE_AND(t3, t1, mask);
    CREATE_SHL_SLOT(t1, op1, t3);
    CREATE_OR(op0, t0, t1);
}

void translate_rotl(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    OperandType t2 = get_tmp_and_do_alloc(type_out);
    OperandType t3 = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_2_OPERANDS();
    op2 = get_operand_legacy(u, 2, &is_imm2);

    OperandType mask_slot = get_tmp_and_do_alloc_with_init(type_out, type_out == LLVMInt32 ? (32-1) : (64-1));
    if (is_imm2) {
        uint64_t mask = (type_out == LLVMInt32 ? (32-1) : (64-1));
        CREATE_SHL(t0, op1, (op2.i & mask));
    } else {
        CREATE_AND(t2, op2, mask_slot);
        CREATE_SHL_SLOT(t0, op1, t2);
    }
    if (is_imm2) {
        t1 = get_tmp_and_do_alloc_with_init(type_out, ((type_out == LLVMInt32 ? 32 : 64) - op2.i));
    } else {
        OperandType constant = get_tmp_and_do_alloc_with_init(type_out, type_out == LLVMInt32 ? 32 : 64);
        CREATE_SUB(t1, constant, op2);
    }
    CREATE_AND(t3, t1, mask_slot);
    CREATE_SHR_SLOT(t1, op1, t3);
    CREATE_OR(op0, t0, t1);
}

void translate_deposit(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2, ofs, len;
    GET_3_OPERANDS();
    uint32_t is_imm3, is_imm4;
    ofs = get_operand_legacy(u, 3, &is_imm3);
    len = get_operand_legacy(u, 4, &is_imm4);
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
    CREATE_AND(part1, op1, rev_mask_shifted);
    OperandType part2_0 = get_tmp_and_do_alloc(type_out);
    CREATE_AND(part2_0, op2, mask_not_shifted);
    OperandType part2_1 = get_tmp_and_do_alloc(type_out);
    CREATE_SHL(part2_1, part2_0, ofs.i);
    CREATE_OR(op0, part1, part2_1);
}

void translate_extract(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2, is_imm3;
    OperandType op0, op1, ofs, len;
    GET_2_OPERANDS();
    ofs = get_operand_legacy(u, 2, &is_imm2);
    len = get_operand_legacy(u, 3, &is_imm3);
    assert(is_imm2 && is_imm3);
    OperandType tmp_v = get_tmp_and_do_alloc_with_init(type_out, 1);
    OperandType mask1 = get_tmp_and_do_alloc(type_out);
    CREATE_SHL(mask1, tmp_v, len.i);
    OperandType mask_not_shifted = get_tmp_and_do_alloc(type_out);
    CREATE_SUB(mask_not_shifted, mask1, tmp_v);
    OperandType arg_shifted = get_tmp_and_do_alloc(type_out);
    CREATE_SHR(arg_shifted, op1, ofs.i);
    CREATE_AND(op0, arg_shifted, mask_not_shifted);
}

void translate_sextract(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1, ofs, len;
    GET_2_OPERANDS();
    uint32_t is_imm2, is_imm3;
    ofs = get_operand_legacy(u, 2, &is_imm2);
    len = get_operand_legacy(u, 3, &is_imm3);
    assert(is_imm2 & is_imm3);
    OperandType t0 = get_tmp_and_do_alloc(type_out);

    CREATE_SHL(t0, op1, ((opc == sextract_i64 ? 64 : 32) - len.i - ofs.i));
    CREATE_SAR(op0, t0, ((opc == sextract_i64 ? 64 : 32) - len.i));
}

void translate_extract2(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2, ofs;
    GET_3_OPERANDS();
    uint32_t is_imm;
    ofs = get_operand_legacy(u, 3, &is_imm);
    assert(is_imm);
    CREATE_SHR(tmp, op1, ofs.i);
    CREATE_DEPOSIT(op0, tmp, op2, ((opc == extract2_i64 ? 64 : 32) - ofs.i), ofs.i);
}

void translate_extrh(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();
    OperandType input_shifted = get_tmp_and_do_alloc(type_in);
    CREATE_SHR(input_shifted, op1, 32);
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, input_shifted, type_in, 0);
    src = LLVMBuildTrunc(builder, src, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    do_store(opc, src, type_out, op0);
}

void translate_bswap16_i32(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType tmp0 = get_tmp_and_do_alloc(type_out);
    OperandType tmp1 = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();
    CREATE_SHR(tmp0, op1, 8);
    const AttrSrcInfo *attr = get_attribute_from_instr(u);
    if (attr->subt == SUB_ATTR_SWAP && (attr->p.swap & IZ)) {
        CREATE_EXTRACT(tmp0, tmp0, 0, 8);
    }
    if (attr->subt == SUB_ATTR_SWAP && (attr->p.swap & OS)) {
        CREATE_SHL(tmp1, op1, 24);
        CREATE_SAR(tmp1, tmp1, 16);
    } else if (attr->subt == SUB_ATTR_SWAP && (attr->p.swap & OZ)) {
        CREATE_EXTRACT(tmp1, op1, 0, 8);
        CREATE_SHL(tmp1, tmp1, 8);
    } else {
        CREATE_SHL(tmp1, op1, 8);
    }
    CREATE_OR(op0, tmp0, tmp1);
}

void translate_bswap16_i64(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType tmp0 = get_tmp_and_do_alloc(type_out);
    OperandType tmp1 = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();
    CREATE_SHR(tmp0, op1, 8);
    const AttrSrcInfo *attr = get_attribute_from_instr(u);
    if (attr->subt == SUB_ATTR_SWAP && (attr->p.swap & IZ)) {
        CREATE_EXTRACT(tmp0, tmp0, 0, 8);
    }
    if (attr->subt == SUB_ATTR_SWAP && (attr->p.swap & OS)) {
        CREATE_SHL(tmp1, op1, 56);
        CREATE_SAR(tmp1, tmp1, 48);
    } else if (attr->subt == SUB_ATTR_SWAP && (attr->p.swap & OZ)) {
        CREATE_EXTRACT(tmp1, op1, 0, 8);
        CREATE_SHL(tmp1, tmp1, 8);
    } else {
        CREATE_SHL(tmp1, op1, 8);
    }
    CREATE_OR(op0, tmp0, tmp1);
}

void translate_bswap32_i32(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType tmp0 = get_tmp_and_do_alloc(type_out);
    OperandType tmp1 = get_tmp_and_do_alloc(type_out);
    OperandType tmp2 = get_tmp_and_do_alloc_with_init(type_out, 0x00ff00ff);
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();
    CREATE_SHR(tmp0, op1, 8);
    CREATE_AND(tmp1, op1, tmp2);
    CREATE_AND(tmp0, tmp0, tmp2);
    CREATE_SHL(tmp1, tmp1, 8);
    CREATE_OR(op0, tmp0, tmp1);
    CREATE_SHR(tmp0, op0, 16);
    CREATE_SHL(tmp1, op0, 16);
    CREATE_OR(op0, tmp0, tmp1);
}

void translate_bswap32_i64(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType tmp0 = get_tmp_and_do_alloc(type_out);
    OperandType tmp1 = get_tmp_and_do_alloc(type_out);
    OperandType tmp2 = get_tmp_and_do_alloc_with_init(type_out, 0x00ff00ff);
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();
    CREATE_SHR(tmp0, op1, 8);
    CREATE_AND(tmp1, op1, tmp2);
    CREATE_AND(tmp0, tmp0, tmp2);
    CREATE_SHL(tmp1, tmp1, 8);
    CREATE_OR(op0, tmp0, tmp1);
    CREATE_SHL(tmp1, op0, 48);
    CREATE_SHR(tmp0, op0, 16);

    const AttrSrcInfo *attr = get_attribute_from_instr(u);
    if (attr->subt == SUB_ATTR_SWAP && (attr->p.swap & OS)) {
        CREATE_SAR(tmp1, tmp1, 32);
    } else {
        CREATE_SHR(tmp1, tmp1, 32);
    }
    CREATE_OR(op0, tmp0, tmp1);
}

void translate_bswap64_i64(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();

    CREATE_SHR(t0, op1, 8);
    OperandType t2 = get_tmp_and_do_alloc_with_init(type_out, 0x00ff00ff00ff00ffUL);
    CREATE_AND(t1, op1, t2);
    CREATE_AND(t0, t0, t2);
    CREATE_SHL(t1, t1, 8);
    CREATE_OR(op0, t0, t1);
    t2 = get_tmp_and_do_alloc_with_init(type_out, 0x0000ffff0000ffffUL);
    CREATE_SHR(t0, op0, 16);
    CREATE_AND(t1, op0, t2);
    CREATE_AND(t0, t0, t2);
    CREATE_SHL(t1, t1, 16);
    CREATE_OR(op0, t0, t1);
    CREATE_SHR(t0, op0, 32);
    CREATE_SHL(t1, op0, 32);
    CREATE_OR(op0, t0, t1);
}

void translate_count_zero(OpCodeType opc, const UnifiedInstr *u, const char *intrinsic) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 0);

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
    do_store(opc, phi, type_out, op0);
}

void translate_ctpop(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, 0, op1, type_in, 0);
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
    do_store(opc, ret, type_out, op0);
}

void translate_ext(OpCodeType opc, const UnifiedInstr *u, LLVM_EXT_API api) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS_NOCHECK();

    LLVMValueRef src = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    src = api(builder, src, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], op0));
    do_store(opc, src, type_out, op0);
}

void translate_movcond(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1, is_imm2, is_imm3, is_imm4;
    OperandType op0, op1, op2, op3, op4;
    GET_3_OPERANDS_NOCHECK();
    op3 = get_operand_legacy(u, 3, &is_imm3);
    op4 = get_operand_legacy(u, 4, &is_imm4);

    LLVMValueRef c1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef c2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 0);
    LLVMValueRef v1 = get_source_node_imm_or_stack(opc, is_imm3, op3, type_in, 0);
    LLVMValueRef v2 = get_source_node_imm_or_stack(opc, is_imm4, op4, type_in, 0);

    RelopType r = get_relop(u);
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        c1 = LLVMBuildAnd(builder, c1, c2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        c2 = LLVMConstInt(llvm_int_types[type_in], 0, 0);
    }
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], c1, c2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    LLVMValueRef result = LLVMBuildSelect(builder, bool_val, v1, v2, get_next_var_name(opcode_type_str[opc], op0));
    do_store(opc, result, type_out, op0);
}

void translate_negsetcond(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS_NOCHECK();
    assert(!is_imm0);
    OperandType in0, in1;

    if (is_imm1) {
        in0 = get_tmp_and_do_alloc_with_init(type_out, op1.i);
    } else {
        in0 = op1;
    }
    if (is_imm2) {
        in1 = get_tmp_and_do_alloc_with_init(type_out, op2.i);
    } else {
        in1 = op2;
    }
    RelopType r = get_relop(u);
    OperandType tmp0 = get_tmp_and_do_alloc(type_out);
    CREATE_SETCOND(tmp0, in0, in1, r);
    OperandType z = get_tmp_and_do_alloc_with_init(type_out, 0);
    CREATE_SUB(op0, z, tmp0);
}

void translate_setcond(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef c1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef c2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 0);

    RelopType r = get_relop(u);
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        c1 = LLVMBuildAnd(builder, c1, c2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        c2 = LLVMConstInt(llvm_int_types[type_in], 0, 0);
    }
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], c1, c2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef result = LLVMBuildZExt(builder, bool_val, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], op0));
    do_store(opc, result, type_out, op0);
}

void translate_brcond_i64(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS_NOCHECK();
    LLVMValueRef c1 = get_source_node_imm_or_stack(opc, is_imm0, op0, type_in, 0);
    LLVMValueRef c2 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);

    RelopType r = get_relop(u);
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
    uint8_t lbl = get_label_from_instr(u);
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

void translate_br(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint8_t l = get_label_from_instr(u);
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

void translate_ld_ext(OpCodeType opc, const UnifiedInstr *u, LLVM_EXT_API api) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();

    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, op1, type_mem, 0);
    src = api(builder, src, llvm_int_types[type_reg], get_next_var_name(opcode_type_str[opc], op1));
    do_store(opc, src, type_reg, op0);
}

void translate_ld_env_xmm(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();

    if (op1.s.slot_type == SUB_SLOT_ENV ||
        op1.s.slot_type == SUB_SLOT_XMM) {
        LLVMValueRef val = get_source_node_imm_or_stack(opc, 0, op1, type_mem, 0);
        do_store(opc, val, type_reg, op0);
    } else if (op1.s.slot_type == SUB_SLOT_TMP) {
        OperandType op2;
        uint32_t is_imm2;
        op2 = get_operand_legacy(u, 2, &is_imm2);
        assert(has_alias(op1) && is_imm2);
        OperandType alias = get_alias(op1);
        assert(alias.s.valid);
        alias.s.offset += op2.i;
        CREATE_LD_ENV_XMM(opc, op0, alias);
    } else {
        assert(0);
    }
}

void translate_ld_vec(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, op1, type_in, 0);
    do_store(opc, src, type_out, op0);
}

void translate_qemu_ld2_i128(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();

    const AttrSrcInfo *attr = get_attribute_from_instr(u);
    assert(attr->subt == SUB_ATTR_STORAGE);
    assert(attr->p.storage.size == SRC16B);

    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, op2, OPC_ADDR_T, 0);
    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[type_mem], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    unsigned align = 1;
    if (attr->p.storage.alignment == UNALIGNED) {
        align = 1;
    } else if (attr->p.storage.alignment == ALIGN_2) {
        align = 2;
    } else if (attr->p.storage.alignment == ALIGN_4) {
        align = 4;
    } else if (attr->p.storage.alignment == ALIGN_8) {
        align = 8;
    } else if (attr->p.storage.alignment == ALIGN_16) {
        align = 16;
    } else if (attr->p.storage.alignment == ALIGN_32) {
        align = 32;
    } else if (attr->p.storage.alignment == ALIGN_MEM_SIZE) {
        align = llvm_vector_elem_bit_counts[type_mem*2+1]/8;
    } else {
        assert(0);
    }
    LLVMValueRef result = build_load_with_alignment(builder, llvm_int_types[type_mem], pointer, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug), align);
    do_store(opc, result, type_reg, op0);
    OperandType high_addr = get_tmp_and_do_alloc(OPC_ADDR_T);
    CREATE_ADD(high_addr, op2, 8UL);
    addr = get_source_node_imm_or_stack(opc, 0, high_addr, OPC_ADDR_T, 0);
    pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[type_mem], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    result = build_load_with_alignment(builder, llvm_int_types[type_mem], pointer, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug), align);
    do_store(opc, result, type_reg, op1);
}

void translate_qemu_ld(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();

    const AttrSrcInfo *attr = get_attribute_from_instr(u);
    assert(attr->subt == SUB_ATTR_STORAGE);
    assert(attr->p.storage.size <= SRC8B);
    type_mem = (attr->p.storage.size - SRC1B) + LLVMInt8;
    assert(type_mem <= type_reg);

    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, op1, OPC_ADDR_T, 0);
    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[type_mem], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    unsigned align = 1;
    if (attr->p.storage.alignment == UNALIGNED) {
        align = 1;
    } else if (attr->p.storage.alignment == ALIGN_2) {
        align = 2;
    } else if (attr->p.storage.alignment == ALIGN_4) {
        align = 4;
    } else if (attr->p.storage.alignment == ALIGN_8) {
        align = 8;
    } else if (attr->p.storage.alignment == ALIGN_16) {
        align = 16;
    } else if (attr->p.storage.alignment == ALIGN_32) {
        align = 32;
    } else if (attr->p.storage.alignment == ALIGN_MEM_SIZE) {
        align = llvm_vector_elem_bit_counts[type_mem*2+1]/8;
    } else {
        assert(0);
    }
    LLVMValueRef result = build_load_with_alignment(builder, llvm_int_types[type_mem], pointer, get_next_var_name(opcode_type_str[opc], op0), align);
    if (type_mem < type_reg) {
        if (attr->p.storage.ext == ZERO) {
            result = LLVMBuildZExt(builder, result, llvm_int_types[type_reg], get_next_var_name(opcode_type_str[opc], op0));
        } else {
            result = LLVMBuildSExt(builder, result, llvm_int_types[type_reg], get_next_var_name(opcode_type_str[opc], op0));
        }
    }
    do_store(opc, result, type_reg, op0);
}

void translate_st(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS_NOCHECK();
    assert(!is_imm1 && op1.s.valid);

    LLVMValueRef val = get_source_node_imm_or_stack(opc, is_imm0, op0, type_reg, 0);
    if (type_mem < type_reg) {
        val = LLVMBuildTrunc(builder, val, llvm_int_types[type_mem], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    }
    LLVMValueRef addr_val = NULL;
    if ((op1.s.slot_type == SUB_SLOT_TMP && has_alias_xmm(op1)) || op1.s.slot_type == SUB_SLOT_XMM) {
        OperandType alias = op1;
        if (op1.s.slot_type == SUB_SLOT_TMP) {
            alias = get_alias(op1);
        }
        uint32_t is_imm;
        OperandType offset = get_operand_legacy(u, 2, &is_imm);
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
        if (op1.s.slot_type == SUB_SLOT_TMP && has_alias(op1)) {
            op1 = get_alias(op1);
        }
        LLVMValueRef env_raw = get_env_ptr_raw();
        LLVMValueRef off = NULL;
        if (op1.s.slot_type == SUB_SLOT_ENV) {
            off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], op1.s.offset, 0);
        } else {
            assert(0);
        }
        addr_val = LLVMBuildAdd(builder, env_raw, off, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        check_scalable_vector_perform_store(val, type_mem, addr_val, GET_ALIGNMENT_FROM_CONSTANT(op1.s.offset));
    }
}

void translate_st_vec(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, op0, type_in, 0);
    do_store(opc, src, type_out, op1);
}

void translate_qemu_st2_i128(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();

    const AttrSrcInfo *attr = get_attribute_from_instr(u);
    assert(attr->subt == SUB_ATTR_STORAGE);
    assert(attr->p.storage.size == SRC16B);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, 0, op0, type_reg, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, 0, op1, type_reg, 0);
    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, op2, OPC_ADDR_T, 0);
    unsigned align = 1;
    if (attr->p.storage.alignment == UNALIGNED) {
        align = 1;
    } else if (attr->p.storage.alignment == ALIGN_2) {
        align = 2;
    } else if (attr->p.storage.alignment == ALIGN_4) {
        align = 4;
    } else if (attr->p.storage.alignment == ALIGN_8) {
        align = 8;
    } else if (attr->p.storage.alignment == ALIGN_16) {
        align = 16;
    } else if (attr->p.storage.alignment == ALIGN_32) {
        align = 32;
    } else if (attr->p.storage.alignment == ALIGN_MEM_SIZE) {
        align = llvm_vector_elem_bit_counts[type_mem*2+1]/8;
    } else {
        assert(0);
    }
    check_scalable_vector_perform_store(src1, type_mem, addr, align);
    OperandType high_addr = get_tmp_and_do_alloc(OPC_ADDR_T);
    CREATE_ADD(high_addr, op2, 8UL);
    addr = get_source_node_imm_or_stack(opc, 0, high_addr, OPC_ADDR_T, 0);
    check_scalable_vector_perform_store(src2, type_mem, addr, align);
}

void translate_qemu_st(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_MEM;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();

    const AttrSrcInfo *attr = get_attribute_from_instr(u);
    assert(attr->subt == SUB_ATTR_STORAGE);
    assert(attr->p.storage.size <= SRC8B);
    type_mem = (attr->p.storage.size - SRC1B) + LLVMInt8;
    assert(type_mem <= type_reg);

    LLVMValueRef val = get_source_node_imm_or_stack(opc, 0, op0, type_reg, 0);
    if (type_mem < type_reg) {
        val = LLVMBuildTrunc(builder, val, llvm_int_types[type_mem], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    }
    LLVMValueRef addr = get_source_node_imm_or_stack(opc, 0, op1, OPC_ADDR_T, 0);
    unsigned align = 1;
    if (attr->p.storage.alignment == UNALIGNED) {
        align = 1;
    } else if (attr->p.storage.alignment == ALIGN_2) {
        align = 2;
    } else if (attr->p.storage.alignment == ALIGN_4) {
        align = 4;
    } else if (attr->p.storage.alignment == ALIGN_8) {
        align = 8;
    } else if (attr->p.storage.alignment == ALIGN_16) {
        align = 16;
    } else if (attr->p.storage.alignment == ALIGN_32) {
        align = 32;
    } else if (attr->p.storage.alignment == ALIGN_MEM_SIZE) {
        align = llvm_vector_elem_bit_counts[type_mem*2+1]/8;
    } else {
        assert(0);
    }
    check_scalable_vector_perform_store(val, type_mem, addr, align);
}

void translate_addci(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    uint32_t idx = opcoc[opc];
    op0 = get_operand_legacy(u, 0, &is_imm0);
    assert(!is_imm0 && op0.s.valid);
    op1 = get_operand_legacy(u, idx, &is_imm1);
    op2 = get_operand_legacy(u, idx + 1, &is_imm2);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 0);
    LLVMValueRef sum_val = LLVMBuildAdd(builder, src1, src2, "sumval");
    LLVMValueRef carry = build_load_with_alignment(builder, LLVMInt1Type(), carrybit_alloca, "carrybit", 8);
    LLVMValueRef extended_carry = LLVMBuildZExt(builder, carry, llvm_int_types[type_out], "carrybit_extended");
    LLVMValueRef out_val = LLVMBuildAdd(builder, sum_val, extended_carry, get_next_var_name(opcode_type_str[opc], op0));
    do_store(opc, out_val, type_out, op0);
}

void translate_addcio(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    uint32_t idx = opcoc[opc];
    op0 = get_operand_legacy(u, 0, &is_imm0);
    assert(!is_imm0 && op0.s.valid);
    op1 = get_operand_legacy(u, idx, &is_imm1);
    op2 = get_operand_legacy(u, idx + 1, &is_imm2);

    LLVMTypeRef intrinsic_types[] = {llvm_int_types[type_in], llvm_int_types[type_in]};
    char intrinsic_func_name[128] = {0};
    sprintf(intrinsic_func_name, "llvm.uadd.with.overflow.i%d", llvm_vector_elem_bit_counts[type_in*2+1]);
    unsigned id = LLVMLookupIntrinsicID(intrinsic_func_name, strlen(intrinsic_func_name));
    assert(id != 0);
    LLVMValueRef fn = LLVMGetIntrinsicDeclaration(module, id, intrinsic_types, 2);
    LLVMTypeRef ret_args[] = {llvm_int_types[type_in], LLVMInt1Type()};
    LLVMTypeRef ret_type = LLVMStructType(ret_args, 2, false);
    LLVMTypeRef fn_type  = LLVMFunctionType(ret_type, intrinsic_types, 2, false);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 0);
    LLVMValueRef intrinsic_call1_args[] = {src1, src2};
    LLVMValueRef call1 = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call1_args, 2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef sum1 = LLVMBuildExtractValue(builder, call1, 0, "sum");
    LLVMValueRef carry1 = LLVMBuildExtractValue(builder, call1, 1, "carry");

    LLVMValueRef carry_in = build_load_with_alignment(builder, LLVMInt1Type(), carrybit_alloca, "carrybit", 8);
    LLVMValueRef carry_in_ext = LLVMBuildZExt(builder, carry_in, llvm_int_types[type_out], "carrybit_extended");
    LLVMValueRef intrinsic_call2_args[] = {sum1, carry_in_ext};
    LLVMValueRef call2 = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call2_args, 2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef sum2 = LLVMBuildExtractValue(builder, call2, 0, "sum");
    LLVMValueRef carry2 = LLVMBuildExtractValue(builder, call2, 1, "carry");
    do_store(opc, sum2, type_out, op0);

    LLVMValueRef carry_out = LLVMBuildOr(builder, carry1, carry2, "carryout");
    build_store_with_alignment(builder, carry_out, carrybit_alloca, 8);
}

void translate_addco(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    uint32_t idx = opcoc[opc];
    op0 = get_operand_legacy(u, 0, &is_imm0);
    assert(!is_imm0 && op0.s.valid);
    op1 = get_operand_legacy(u, idx, &is_imm1);
    op2 = get_operand_legacy(u, idx + 1, &is_imm2);

    LLVMTypeRef intrinsic_types[] = {llvm_int_types[type_in], llvm_int_types[type_in]};
    char intrinsic_func_name[128] = {0};
    sprintf(intrinsic_func_name, "llvm.uadd.with.overflow.i%d", llvm_vector_elem_bit_counts[type_in*2+1]);
    unsigned id = LLVMLookupIntrinsicID(intrinsic_func_name, strlen(intrinsic_func_name));
    assert(id != 0);
    LLVMValueRef fn = LLVMGetIntrinsicDeclaration(module, id, intrinsic_types, 2);
    LLVMTypeRef ret_args[] = {llvm_int_types[type_in], LLVMInt1Type()};
    LLVMTypeRef ret_type = LLVMStructType(ret_args, 2, false);
    LLVMTypeRef fn_type  = LLVMFunctionType(ret_type, intrinsic_types, 2, false);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 0);
    LLVMValueRef intrinsic_call1_args[] = {src1, src2};
    LLVMValueRef call1 = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call1_args, 2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef sum1 = LLVMBuildExtractValue(builder, call1, 0, "sum");
    LLVMValueRef carry1 = LLVMBuildExtractValue(builder, call1, 1, "carry");
    do_store(opc, sum1, type_out, op0);
    build_store_with_alignment(builder, carry1, carrybit_alloca, 8);
}

void translate_subbi(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    uint32_t idx = opcoc[opc];
    op0 = get_operand_legacy(u, 0, &is_imm0);
    assert(!is_imm0 && op0.s.valid);
    op1 = get_operand_legacy(u, idx, &is_imm1);
    op2 = get_operand_legacy(u, idx + 1, &is_imm2);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 0);
    LLVMValueRef diff_val = LLVMBuildSub(builder, src1, src2, "diffval");
    LLVMValueRef borrow = build_load_with_alignment(builder, LLVMInt1Type(), borrowbit_alloca, "borrowbit", 8);
    LLVMValueRef extended_borrow = LLVMBuildZExt(builder, borrow, llvm_int_types[type_out], "borrowbit_extended");
    LLVMValueRef out_val = LLVMBuildSub(builder, diff_val, extended_borrow, get_next_var_name(opcode_type_str[opc], op0));
    do_store(opc, out_val, type_out, op0);
}

void translate_subbio(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    uint32_t idx = opcoc[opc];
    op0 = get_operand_legacy(u, 0, &is_imm0);
    assert(!is_imm0 && op0.s.valid);
    op1 = get_operand_legacy(u, idx, &is_imm1);
    op2 = get_operand_legacy(u, idx + 1, &is_imm2);

    LLVMTypeRef intrinsic_types[] = {llvm_int_types[type_in], llvm_int_types[type_in]};
    char intrinsic_func_name[128] = {0};
    sprintf(intrinsic_func_name, "llvm.usub.with.overflow.i%d", llvm_vector_elem_bit_counts[type_in*2+1]);
    unsigned id = LLVMLookupIntrinsicID(intrinsic_func_name, strlen(intrinsic_func_name));
    assert(id != 0);
    LLVMValueRef fn = LLVMGetIntrinsicDeclaration(module, id, intrinsic_types, 2);
    LLVMTypeRef ret_args[] = {llvm_int_types[type_in], LLVMInt1Type()};
    LLVMTypeRef ret_type = LLVMStructType(ret_args, 2, false);
    LLVMTypeRef fn_type  = LLVMFunctionType(ret_type, intrinsic_types, 2, false);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 0);
    LLVMValueRef intrinsic_call1_args[] = {src1, src2};
    LLVMValueRef call1 = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call1_args, 2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef diff1 = LLVMBuildExtractValue(builder, call1, 0, "diff");
    LLVMValueRef borrow1 = LLVMBuildExtractValue(builder, call1, 1, "borrow");

    LLVMValueRef borrow_in = build_load_with_alignment(builder, LLVMInt1Type(), borrowbit_alloca, "borrowbit", 8);
    LLVMValueRef borrow_in_ext = LLVMBuildZExt(builder, borrow_in, llvm_int_types[type_out], "borrowbit_extended");
    LLVMValueRef intrinsic_call2_args[] = {diff1, borrow_in_ext};
    LLVMValueRef call2 = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call2_args, 2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef diff2 = LLVMBuildExtractValue(builder, call2, 0, "diff");
    LLVMValueRef borrow2 = LLVMBuildExtractValue(builder, call2, 1, "borrow");
    do_store(opc, diff2, type_out, op0);

    LLVMValueRef borrow_out = LLVMBuildOr(builder, borrow1, borrow2, "borrowout");
    build_store_with_alignment(builder, borrow_out, borrowbit_alloca, 8);
}

void translate_subbo(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_ALL;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    uint32_t idx = opcoc[opc];
    op0 = get_operand_legacy(u, 0, &is_imm0);
    assert(!is_imm0 && op0.s.valid);
    op1 = get_operand_legacy(u, idx, &is_imm1);
    op2 = get_operand_legacy(u, idx + 1, &is_imm2);

    LLVMTypeRef intrinsic_types[] = {llvm_int_types[type_in], llvm_int_types[type_in]};
    char intrinsic_func_name[128] = {0};
    sprintf(intrinsic_func_name, "llvm.usub.with.overflow.i%d", llvm_vector_elem_bit_counts[type_in*2+1]);
    unsigned id = LLVMLookupIntrinsicID(intrinsic_func_name, strlen(intrinsic_func_name));
    assert(id != 0);
    LLVMValueRef fn = LLVMGetIntrinsicDeclaration(module, id, intrinsic_types, 2);
    LLVMTypeRef ret_args[] = {llvm_int_types[type_in], LLVMInt1Type()};
    LLVMTypeRef ret_type = LLVMStructType(ret_args, 2, false);
    LLVMTypeRef fn_type  = LLVMFunctionType(ret_type, intrinsic_types, 2, false);

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 0);
    LLVMValueRef intrinsic_call1_args[] = {src1, src2};
    LLVMValueRef call1 = LLVMBuildCall2(builder, fn_type, fn, intrinsic_call1_args, 2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef diff1 = LLVMBuildExtractValue(builder, call1, 0, "diff");
    LLVMValueRef borrow1 = LLVMBuildExtractValue(builder, call1, 1, "borrow");
    do_store(opc, diff1, type_out, op0);
    build_store_with_alignment(builder, borrow1, borrowbit_alloca, 8);
}

// Vector
void translate_abs_vec(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, 0, op1, type_in, 0);
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
    do_store(opc, ret, type_out, op0);
}

void translate_binary_intrinsic(OpCodeType opc, const UnifiedInstr *u, const char *intrinsic_prefix) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, 0, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, 0, op2, type_in, 0);
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
    do_store(opc, ret, type_out, op0);
}

void translate_bitsel_vec(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1, is_imm2, is_imm3;
    OperandType op0, op1, op2, op3;
    GET_4_OPERANDS();
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    CREATE_AND(tmp, op1, op2);
    CREATE_ANDC_VEC(op0, op2, op1);
    CREATE_OR(op0, op0, tmp);
}

void translate_cmpsel_vec(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1, is_imm2, is_imm3, is_imm4;
    OperandType op0, op1, op2, op3, op4;
    GET_5_OPERANDS();
    RelopType r = get_relop(u);
    OperandType tmp = get_tmp_and_do_alloc(type_out);
    CREATE_CMP_VEC(tmp, op1, op2, r);
    CREATE_BITSEL_VEC(op0, tmp, op3, op4);
}

void translate_cmp_vec(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm1, op1, type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm2, op2, type_in, 0);

    RelopType r = get_relop(u);
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_vec = LLVMBuildICmp(builder, llvm_predicate[r], src1, src2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    OperandType ones, zeros;
    ones.i = 0xffffffffffffffffUL;
    zeros.i = 0;

    LLVMValueRef vec_true = get_source_node_imm_or_stack(opc, 1, ones, type_in, 0);
    LLVMValueRef vec_false = get_source_node_imm_or_stack(opc, 1, zeros, type_in, 0);

    LLVMValueRef result = LLVMBuildSelect(builder, bool_vec, vec_true, vec_false, get_next_var_name(opcode_type_str[opc], op0));
    do_store(opc, result, type_out, op0);
}

void translate_dupm_vec(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1;
    OperandType op0, op1;
    GET_2_OPERANDS();
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, op1, type_in, 0);
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
    do_store(opc, result, type_out, op0);
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    LLVMValueRef src = get_source_node_imm_or_stack(opc, 0, op1, type_in, 0);
    LLVMValueRef index = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
    if (llvm_int_types[type_in] != llvm_int_store_types[type_in]) {
        LLVMTypeRef intrinsic_types[] = {llvm_int_types[type_in], llvm_int_types[OPC_ADDR_T]};
        LLVMTypeRef intrinsic_func_type = LLVMFunctionType(llvm_int_store_types[type_in], intrinsic_types, 2, 0);
        char intrinsic_func_name[128] = {0};
        sprintf(intrinsic_func_name, "llvm.vector.extract.v%di%d.nxv%di%d", llvm_vector_elem_bit_counts[type_in*2], llvm_vector_elem_bit_counts[type_in*2+1], llvm_vector_elem_bit_counts[type_in*2]/2, llvm_vector_elem_bit_counts[type_in*2+1]);
        assert(strlen(intrinsic_func_name) < sizeof(intrinsic_func_name));
        LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, intrinsic_func_name);
        if (!intrinsic_func) {
            intrinsic_func = LLVMAddFunction(module, intrinsic_func_name, intrinsic_func_type);
        }
        LLVMValueRef index_0 = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 0, 0);
        LLVMValueRef intrinsic_call_args[] = {src, index_0};
        src = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 2, get_next_var_name("check_scalable_store", dummy_slot_for_debug));
    }
    LLVMValueRef first_element = LLVMBuildExtractElement(builder, src, index, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef single_element_vector = LLVMBuildInsertElement(builder, LLVMGetUndef(llvm_int_types[type_in]), first_element, index, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef zero_mask = LLVMConstNull(llvm_int_types[type_in]);
    LLVMValueRef splat_vector = LLVMBuildShuffleVector(builder, single_element_vector, LLVMGetUndef(llvm_int_types[type_in]), zero_mask, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    do_store(opc, splat_vector, type_out, op0);
#endif
}

void translate_rotl_vec(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    OperandType t2 = get_tmp_and_do_alloc(OPC_VECTOR_TO_FIXED(type_out));
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2, operand_shift;
    GET_2_OPERANDS();
    op2 = get_operand_legacy(u, 2, &is_imm2);
    if (is_imm2) {
        operand_shift = get_tmp_and_do_alloc_with_init(OPC_VECTOR_TO_FIXED(type_in), op2.i);
    } else {
        LLVMValueRef tmp_src = get_source_node_imm_or_stack(opc, 0, op2, LLVMInt32/*ref:void tcg_gen_rotls_vec(unsigned vece, TCGv_vec r, TCGv_vec a, TCGv_i32 s);*/, 0);
        do_store(opc, tmp_src, OPC_VECTOR_TO_FIXED(type_out), operand_shift);
    }

    CREATE_SHL_VEC(t0, op1, operand_shift, 1/*DO_SPLAT*/);
    OperandType constant = get_tmp_and_do_alloc_with_init(OPC_VECTOR_TO_FIXED(type_in), llvm_vector_elem_bit_counts[type_in*2+1]);
    CREATE_SUB(t2, constant, operand_shift);
    CREATE_SHR_VEC(t1, op1, t2, 1/*DO_SPLAT*/);
    CREATE_OR(op0, t0, t1);
}

void translate_rotlv_vec(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    OperandType t2 = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();

    CREATE_SHL_VEC(t0, op1, op2, 0/*NO_SPLAT*/);
    OperandType constant_val;
    constant_val.i = llvm_vector_elem_bit_counts[type_in*2+1];
    LLVMValueRef constant_splat_val = get_source_node_imm_or_stack(opc, 1, constant_val, type_in, 1);
    OperandType constant_splat = get_tmp_and_do_alloc(type_in);
    do_store(opc, constant_splat_val, type_in, constant_splat);
    CREATE_SUB(t2, constant_splat, op2);
    CREATE_SHR_VEC(t1, op1, t2, 0/*NO_SPLAT*/);
    CREATE_OR(op0, t0, t1);
}

void translate_rotrv_vec(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    OperandType t0 = get_tmp_and_do_alloc(type_out);
    OperandType t1 = get_tmp_and_do_alloc(type_out);
    OperandType t2 = get_tmp_and_do_alloc(type_out);
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();

    CREATE_SHR_VEC(t0, op1, op2, 0/*NO_SPLAT*/);
    OperandType constant_val;
    constant_val.i = llvm_vector_elem_bit_counts[type_in*2+1];
    LLVMValueRef constant_splat_val = get_source_node_imm_or_stack(opc, 1, constant_val, type_in, 1);
    OperandType constant_splat = get_tmp_and_do_alloc(type_in);
    do_store(opc, constant_splat_val, type_in, constant_splat);
    CREATE_SUB(t2, constant_splat, op2);
    CREATE_SHL_VEC(t1, op1, t2, 0/*NO_SPLAT*/);
    CREATE_OR(op0, t0, t1);
}

void translate_maxmin_vec(OpCodeType opc, const UnifiedInstr *u, RelopType r) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_VECTOR;
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType op0, op1, op2;
    GET_3_OPERANDS();
    OperandType tmp1 = get_tmp_and_do_alloc(type_out);
    OperandType tmp2 = get_tmp_and_do_alloc(type_out);

    CREATE_MOV_VEC(OPC_VECTOR_SIZE(type_out), OPC_VECTOR_TO_VES(type_out), tmp1, op1);
    CREATE_MOV_VEC(OPC_VECTOR_SIZE(type_out), OPC_VECTOR_TO_VES(type_out), tmp2, op2);
    CREATE_MOVCOND_VEC(OPC_VECTOR_SIZE(type_out), OPC_VECTOR_TO_VES(type_out), op0, op1, op2, tmp1, tmp2, r);
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

void translate_set_label(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint8_t l = get_label_from_instr(u);
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

void translate_set_label_fix_branch(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint8_t l = get_label_from_instr(u);
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
}

void translate_jmp_direct(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm;
    OperandType delta;
    delta = get_operand_legacy(u, 0, &is_imm);
    assert(is_imm);

    char func_name[64] = {0};
    sprintf(func_name, "%s%sfunc_%lx", func_name_prefix, func_name_prefix[0] ? "_" : "", delta.i);
    LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT] = {NULL};
    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT] = {NULL};
    int arg_cnt = collect_arguments_and_types(not_a_helper, TARGET_QEMUAOT_FASTPATH, TYPE_AND_VALUE, NULL, NULL, 0, NULL, NULL, llvm_func, call_types, FIXED_VECTOR_PARAM_COUNT, call_args, func_name);
    LLVMTypeRef ret_type = LLVMVoidType();
    LLVMTypeRef func_type = LLVMFunctionType(ret_type, call_types, arg_cnt, 0);
    LLVMValueRef call_inst = LLVMBuildCall2(builder, func_type, get_or_add_func_with_qemuaot_cc(func_name, 0), call_args, arg_cnt, "");
    add_list_info(func_name, "declare");
    LLVMSetTailCall(call_inst, 1);
    LLVMSetInstructionCallConv(call_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);
}

void translate_discard(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf("%s %s %p\n", __FUNCTION__, opcode_type_str[opc], (void*)u); fflush(NULL);
#endif
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    uint32_t is_imm;
    OperandType op0 = get_operand_legacy(u, 0, &is_imm);
    assert(!is_imm && op0.s.valid);
    if (op0.s.slot_type == SUB_SLOT_XREG) {
        build_store_with_alignment(builder, LLVMGetPoison(llvm_int_types[func_xreg_llvmtype[op0.s.slot_idx]]), func_xreg_alloca[op0.s.slot_idx].alloca, func_xreg_alloca[op0.s.slot_idx].alignment);
    }
}

static LLVMValueRef get_trampoline(HelperType h, LLVMValueRef helper_func, uint8_t do_return, uint8_t with_ret, OperandType *operands, uint32_t *is_imm, uint8_t operands_cnt, LLVMValueRef next_func, int spill_cnt, XMMRegType *spilled_xmm_regs, int fix_second_half_addr, int target_domain, const UnifiedInstr *u) {
    char trampoline_name[4096] = {0};
#ifdef COLLECT_TRAMPOLINE_IR
    sprintf(trampoline_name, "trampoline_do_not_sync_vector_param%d%s", operands_cnt, helper_defines_output(u) ? "_with_return" : "");
    int env_cnt = 0;
    for (int i = 0; i < operands_cnt; ++i) {
        if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) {
            char env_part[32] = {0};
            sprintf(env_part, "_env%d", i);
            strcat(trampoline_name, env_part);
            env_cnt += 1;
        }
    }
#else
    sprintf(trampoline_name, "%s%strampoline%s_r%d_param%d", func_name_prefix, func_name_prefix[0] ? "_" : "", do_return ? "" : "_noreturn", helper_defines_output(u), operands_cnt);
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
#endif
    assert(strlen(trampoline_name) < sizeof(trampoline_name));
    LLVMValueRef trampoline = LLVMGetNamedFunction(module, trampoline_name);
    if (trampoline) {
        return trampoline;
    }
    LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS] = {NULL};
    int call_arg_cnt = collect_arguments_and_types(not_a_helper, target_domain, TYPE_ONLY, operands, is_imm, operands_cnt, (do_return && !fix_second_half_addr) ? (LLVMValueRef)1 : NULL, NULL, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS), NULL, trampoline_name);
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS));
#ifdef COLLECT_TRAMPOLINE_IR
    call_types[call_arg_cnt++] = llvm_int_types[OPC_ADDR_T];
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS));
#endif

    trampoline = LLVMAddFunction(module, trampoline_name,
        LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnt, 0));
    LLVMAddAttributeAtIndex(trampoline, -1, NoInlineAttr);
    LLVMAddAttributeAtIndex(trampoline, -1, target_features_attr);
    LLVMAddAttributeAtIndex(trampoline, -1, NoUnwindAttr);
    //LLVMSetLinkage(trampoline, LLVMWeakAnyLinkage);
    LLVMSetSection(trampoline, ".text.trampoline");
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
#ifdef COLLECT_TRAMPOLINE_IR
    j += 1;
    param = LLVMGetParam(trampoline, j);
    LLVMSetValueName(param, "helper");
#endif
    LLVMSetFunctionCallConv(trampoline, QEMUAOT_CC);

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(trampoline, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);

#ifdef HELPER_COUNTERS
    {
        LLVMValueRef env_raw = get_env_ptr_raw();
        uint64_t counter_offset = TRAMPOLINE_CNT_OFFSET;
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], counter_offset, 0);
        LLVMValueRef addr = LLVMBuildSub(builder, env_raw, off, get_next_var_name("trampoline_cnt_addr", dummy_slot_for_debug));
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name("trampoline_cnt_ptr", dummy_slot_for_debug));
        LLVMValueRef val = build_load_with_alignment(builder, llvm_int_types[OPC_ADDR_T], ptr, get_next_var_name("trampoline_cnt_before", dummy_slot_for_debug), 8);
        LLVMValueRef one = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 1, 0);
        val = LLVMBuildAdd(builder, val, one, get_next_var_name("trampoline_cnt_val_updated", dummy_slot_for_debug));
        build_store_with_alignment(builder, val, ptr, 8);
    }
#endif

    // Store all fixed to ENV
    LLVMValueRef env_raw = get_env_ptr_raw();
    for (int i = 0; i < FIXED_PARAM_COUNT; ++i) {
        LLVMValueRef fixed_val = LLVMGetParam(trampoline, i);
        uint64_t env_xreg_offset = xreg_offsets[i];
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xreg_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("spill_fixed_addr", dummy_slot_for_debug));
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[fixed_vector_param_llvmtypes[i]], 0), get_next_var_name("spill_fixed_ptr", dummy_slot_for_debug));
        build_store_with_alignment(builder, fixed_val, ptr, 8);
    }

#ifndef COLLECT_TRAMPOLINE_IR
    // Store all vectors to ENV
    for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        LLVMValueRef vec_val = LLVMGetParam(trampoline, i);
        if (spill_cnt) {
            for (int j = 0; j < spill_cnt; ++j) {
                if (spilled_xmm_regs[j] == (XMMRegType)(i - FIXED_PARAM_COUNT)) {
                    vec_val = reload_vector(spilled_xmm_regs[j]);
                    break;
                }
            }
        }
        uint64_t xmm_offset = get_xmm_offset((i - FIXED_PARAM_COUNT)/2) + 16 * ((i - FIXED_PARAM_COUNT) % 2);
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("spill_vec_addr", dummy_slot_for_debug));
        check_scalable_vector_perform_store(vec_val, LLVMVector2xi64, addr, 16);
    }
#endif

    LLVMValueRef call_args[MAX_OPERANDS_COUNT] = {NULL};
    call_arg_cnt = collect_arguments_and_types(not_a_helper, target_domain == TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_DROP_ALIAS_POINTER ? TARGET_DEFAULT_HELPER_CONSTRUCT_VECTOR : TARGET_DEFAULT_HELPER_PASSTHROUGH_VECTOR, VALUE_ONLY, operands, is_imm, operands_cnt, NULL, NULL, trampoline, NULL, 0, call_args, trampoline_name);
    LLVMTypeRef helper_type = LLVMGlobalGetValueType(helper_func);
#ifdef DEBUG
    printf("BuildCall2:%s\n", LLVMGetValueName(helper_func)); fflush(NULL);
#endif
    // Get the helper call target from argument, since I would like to reuse trampoline for different helper targets
    LLVMValueRef call_helper_inst = NULL;
#ifndef COLLECT_TRAMPOLINE_IR
    call_helper_inst = LLVMBuildCall2(builder, helper_type, helper_func, call_args, call_arg_cnt, helper_defines_output(u) ? get_next_var_name("helper_return", dummy_slot_for_debug) : "");
#else
    LLVMValueRef the_helper = LLVMBuildIntToPtr(builder, LLVMGetParam(trampoline, j), LLVMPointerType(helper_type, 0), get_next_var_name("helper_func", dummy_slot_for_debug));
    call_helper_inst = LLVMBuildCall2(builder, helper_type, the_helper, call_args, call_arg_cnt, helper_defines_output(u) ? get_next_var_name("helper_return", dummy_slot_for_debug) : "");
#endif
    if (!do_return) {
        LLVMSetTailCall(call_helper_inst, 1);
        LLVMBuildRetVoid(builder);

        assert(last_active_bb);
        LLVMPositionBuilderAtEnd(builder, last_active_bb);
        return trampoline;
    }

    // Load all fixed from ENV
    LLVMValueRef return_args[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    if (helper_defines_output(u)) {
        return_args[FIXED_VECTOR_PARAM_COUNT] = call_helper_inst;
    }
    // ENV must be re-initialized after the call
    env_raw = get_env_ptr_raw();
    for (int i = 0; i < FIXED_PARAM_COUNT; ++i) {
        uint64_t env_xreg_offset = xreg_offsets[i];
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xreg_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("reload_fixed_addr", dummy_slot_for_debug));
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[fixed_vector_param_llvmtypes[i]], 0), get_next_var_name("reload_fixed_ptr", dummy_slot_for_debug));
        return_args[i] = build_load_with_alignment(builder, llvm_int_types[fixed_vector_param_llvmtypes[i]], ptr, get_next_var_name("reload_fixed_val", dummy_slot_for_debug), 8);
    }

#ifndef COLLECT_TRAMPOLINE_IR
    // Load all vectors from ENV
    for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        uint64_t env_xmm_offset = get_xmm_offset((i - FIXED_PARAM_COUNT)/2) + 16 * ((i - FIXED_PARAM_COUNT) % 2);
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xmm_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("reload_vec_addr", dummy_slot_for_debug));
        return_args[i] = check_scalable_vector_perform_load(LLVMVector2xi64, addr, 16);
    }
#else
    // Prepare arguments
    for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        return_args[i] = LLVMGetParam(trampoline, i);
    }
#endif

    LLVMTypeRef next_type = LLVMGlobalGetValueType(next_func);
    LLVMValueRef call_next_inst;
    if (!fix_second_half_addr) {
        int next_addr_param_idx = (FIXED_VECTOR_PARAM_COUNT + (operands_cnt - env_cnt));
        if (target_domain == TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_DROP_ALIAS_POINTER) {
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
        call_next_inst = LLVMBuildCall2(builder, next_type, the_next, return_args, (FIXED_VECTOR_PARAM_COUNT + (helper_defines_output(u) ? 1 : 0)), "");
    } else {
        call_next_inst = LLVMBuildCall2(builder, next_type, next_func, return_args, (FIXED_VECTOR_PARAM_COUNT + (helper_defines_output(u) ? 1 : 0)), "");
    }
    LLVMSetTailCall(call_next_inst, 1);
    LLVMSetInstructionCallConv(call_next_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);

    assert(last_active_bb);
    LLVMPositionBuilderAtEnd(builder, last_active_bb);
    return trampoline;
}

static LLVMValueRef get_trampoline_do_not_sync_vector(HelperType h, LLVMValueRef helper_func, OperandType *operands, uint32_t *is_imm, uint8_t operands_cnt, LLVMValueRef next_func, int target_domain, const UnifiedInstr *u) {
    char trampoline_name[256] = {0};
    sprintf(trampoline_name, "trampoline_do_not_sync_vector_param%d%s", operands_cnt, helper_defines_output(u) ? "_with_return" : "");
    int env_cnt = 0;
    for (int i = 0; i < operands_cnt; ++i) {
        if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) {
            char env_part[32] = {0};
            sprintf(env_part, "_env%d", i);
            strcat(trampoline_name, env_part);
            env_cnt += 1;
        }
    }
    assert(strlen(trampoline_name) < sizeof(trampoline_name));
    LLVMValueRef trampoline = LLVMGetNamedFunction(module, trampoline_name);
    if (trampoline) {
        return trampoline;
    }
    LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS] = {NULL};
    int call_arg_cnt = collect_arguments_and_types(not_a_helper, target_domain, TYPE_ONLY, operands, is_imm, operands_cnt, (LLVMValueRef)1, NULL, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS), NULL, trampoline_name);
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS));
    // Append the runtime helper function
    call_types[call_arg_cnt++] = llvm_int_types[OPC_ADDR_T];
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS));

    trampoline = LLVMAddFunction(module, trampoline_name,
        LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnt, 0));
    LLVMAddAttributeAtIndex(trampoline, -1, NoInlineAttr);
    LLVMAddAttributeAtIndex(trampoline, -1, target_features_attr);
    LLVMAddAttributeAtIndex(trampoline, -1, NoUnwindAttr);
    LLVMSetSection(trampoline, ".text.trampoline");
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
    param = LLVMGetParam(trampoline, j++);
    LLVMSetValueName(param, "next");
    param = LLVMGetParam(trampoline, j);
    LLVMSetValueName(param, "helper");
    LLVMSetFunctionCallConv(trampoline, QEMUAOT_CC);
    return trampoline;
}

static LLVMValueRef get_exception_handler(HelperType h, LLVMValueRef helper_func, uint8_t with_ret, OperandType *operands, uint32_t *is_imm, uint8_t operands_cnt, LLVMValueRef next_func, int spill_cnt, XMMRegType *spilled_xmm_regs, XMMRegType *passenger_xmm_regs, int fix_second_half_addr, const UnifiedInstr *u) {
    char handler_name[4096] = {0};
    sprintf(handler_name, "%s%sexception_handler_r%d_param_cnt%d", func_name_prefix, func_name_prefix[0] ? "_" : "", helper_defines_output(u), operands_cnt);
    int env_cnt = 0;
    for (int i = 0; i < operands_cnt; ++i) {
        if (is_imm[i] == 0 && operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) {
            char env_part[32] = {0};
            sprintf(env_part, "_env%d", i);
            strcat(handler_name, env_part);
            env_cnt += 1;
        } else if (is_imm[i] == 0 && operands[i].s.valid && ((operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_xmm(operands[i])) || operands[i].s.slot_type == SUB_SLOT_XMM)) {
            char xmm_part[32] = {0};
            OperandType alias = get_alias(operands[i]);
            sprintf(xmm_part, "_p%dxmm%d", i, alias.s.slot_idx);
            strcat(handler_name, xmm_part);
        } else if (is_imm[i] == 0 && operands[i].s.valid && (operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_env(operands[i]))) {
            char xmm_part[32] = {0};
            OperandType alias = get_alias(operands[i]);
            sprintf(xmm_part, "_p%dxmmenv0x%x", i, alias.s.offset);
            strcat(handler_name, xmm_part);
        }
    }
    char name_tail[128] = {0};
    sprintf(name_tail, "_spill%d", spill_cnt);
    strcat(handler_name, name_tail);
    if (spill_cnt) {
        for (int si = 0; si < spill_cnt; ++si) {
            sprintf(name_tail, "_s%d", spilled_xmm_regs[si]);
            strcat(handler_name, name_tail);
        }
    }
    sprintf(name_tail, "_%s", LLVMGetValueName(helper_func));
    strcat(handler_name, name_tail);
    if (fix_second_half_addr) {
        sprintf(name_tail, "_sec_%s", LLVMGetValueName(next_func));
        strcat(handler_name, name_tail);
    }
    assert(strlen(handler_name) < sizeof(handler_name));
    LLVMValueRef handler = LLVMGetNamedFunction(module, handler_name);
    if (handler) {
        return handler;
    }
    LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS] = {NULL};
    int call_arg_cnt = collect_arguments_and_types(h, TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_DROP_ALIAS_POINTER, TYPE_ONLY, operands, is_imm, operands_cnt, (!fix_second_half_addr) ? (LLVMValueRef)1 : NULL, NULL, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS), NULL, handler_name);
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS));

    handler = LLVMAddFunction(module, handler_name,
        LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnt, 0));
    LLVMAddAttributeAtIndex(handler, -1, NoInlineAttr);
    LLVMAddAttributeAtIndex(handler, -1, target_features_attr);
    LLVMAddAttributeAtIndex(handler, -1, NoUnwindAttr);
    //LLVMSetLinkage(handler, LLVMWeakAnyLinkage);
    LLVMSetSection(handler, ".text.trampoline");
    int j = 0;
    LLVMValueRef param = NULL;
    for (j = 0; j < FIXED_VECTOR_PARAM_COUNT; j++) {
        param = LLVMGetParam(handler, j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }
    int drop_cnt = 0;
    for (int i = 0; i < operands_cnt; ++i) {
        if (is_imm[i] == 0 && operands[i].s.valid && ((operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_env(operands[i])) || (operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_xmm(operands[i])) || operands[i].s.slot_type == SUB_SLOT_XMM)) {
            drop_cnt += 1;
        }
    }
    for (j = FIXED_VECTOR_PARAM_COUNT; j < (FIXED_VECTOR_PARAM_COUNT + operands_cnt - env_cnt - drop_cnt); j++) {
        param = LLVMGetParam(handler, j);
        char var[16] = {0};
        sprintf(var, "param%d", (j - FIXED_VECTOR_PARAM_COUNT));
        LLVMSetValueName(param, var);
    }
    if (!fix_second_half_addr) {
        param = LLVMGetParam(handler, j);
        LLVMSetValueName(param, "next");
    }
    LLVMSetFunctionCallConv(handler, QEMUAOT_CC);

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(handler, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);

#ifdef HELPER_COUNTERS
    {
        LLVMValueRef env_raw = get_env_ptr_raw();
        uint64_t counter_offset = TRAMPOLINE_CNT_OFFSET;
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], counter_offset, 0);
        LLVMValueRef addr = LLVMBuildSub(builder, env_raw, off, get_next_var_name("trampoline_cnt_addr", dummy_slot_for_debug));
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name("trampoline_cnt_ptr", dummy_slot_for_debug));
        LLVMValueRef val = build_load_with_alignment(builder, llvm_int_types[OPC_ADDR_T], ptr, get_next_var_name("trampoline_cnt_before", dummy_slot_for_debug), 8);
        LLVMValueRef one = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 1, 0);
        val = LLVMBuildAdd(builder, val, one, get_next_var_name("trampoline_cnt_val_updated", dummy_slot_for_debug));
        build_store_with_alignment(builder, val, ptr, 8);
    }
#endif

    // Store all fixed to ENV
    LLVMValueRef env_raw = get_env_ptr_raw();
    for (int i = 0; i < FIXED_PARAM_COUNT; ++i) {
        LLVMValueRef fixed_val = LLVMGetParam(handler, i);
        uint64_t env_xreg_offset = xreg_offsets[i];
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xreg_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("spill_fixed_addr", dummy_slot_for_debug));
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[fixed_vector_param_llvmtypes[i]], 0), get_next_var_name("spill_fixed_ptr", dummy_slot_for_debug));
        build_store_with_alignment(builder, fixed_val, ptr, 8);
    }

    // Store all vectors to ENV
    for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        LLVMValueRef vec_val = LLVMGetParam(handler, i);
        if (spill_cnt) {
            for (int j = 0; j < spill_cnt; ++j) {
                if (spilled_xmm_regs[j] == (XMMRegType)(i - FIXED_PARAM_COUNT)) {
                    vec_val = reload_vector(spilled_xmm_regs[j]);
                    break;
                }
                if (IS_YMM_HELPER(h) && ((spilled_xmm_regs[j] + 1) == (XMMRegType)(i - FIXED_PARAM_COUNT))) {
                    vec_val = reload_vector(spilled_xmm_regs[j] + 1);
                    break;
                }
            }
        }
        uint64_t xmm_offset = get_xmm_offset((i - FIXED_PARAM_COUNT)/2) + 16 * ((i - FIXED_PARAM_COUNT) % 2);
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("spill_vec_addr", dummy_slot_for_debug));
        check_scalable_vector_perform_store(vec_val, LLVMVector2xi64, addr, 16);
    }

    LLVMValueRef call_args[MAX_OPERANDS_COUNT] = {NULL};
    call_arg_cnt = collect_arguments_and_types(h, TARGET_DEFAULT_HELPER_CONSTRUCT_VECTOR, VALUE_ONLY, operands, is_imm, operands_cnt, NULL, NULL, handler, NULL, 0, call_args, handler_name);
    LLVMTypeRef helper_type = LLVMGlobalGetValueType(helper_func);
#ifdef DEBUG
    printf("BuildCall2:%s\n", LLVMGetValueName(helper_func)); fflush(NULL);
#endif
    // Get the helper call target from argument, since I would like to reuse handler for different helper targets
    LLVMValueRef call_helper_inst = LLVMBuildCall2(builder, helper_type, helper_func, call_args, call_arg_cnt, helper_defines_output(u) ? get_next_var_name("helper_return", dummy_slot_for_debug) : "");

    // Load all fixed from ENV
    LLVMValueRef return_args[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    if (helper_defines_output(u)) {
        return_args[FIXED_VECTOR_PARAM_COUNT] = call_helper_inst;
    }
    // ENV must be re-initialized after the call
    env_raw = get_env_ptr_raw();
    for (int i = 0; i < FIXED_PARAM_COUNT; ++i) {
        uint64_t env_xreg_offset = xreg_offsets[i];
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xreg_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("reload_fixed_addr", dummy_slot_for_debug));
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[fixed_vector_param_llvmtypes[i]], 0), get_next_var_name("reload_fixed_ptr", dummy_slot_for_debug));
        return_args[i] = build_load_with_alignment(builder, llvm_int_types[fixed_vector_param_llvmtypes[i]], ptr, get_next_var_name("reload_fixed_val", dummy_slot_for_debug), 8);
    }

    // Load all vectors from ENV
    for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        XMMRegType src_xmm = (i - FIXED_PARAM_COUNT);
        if (spill_cnt) {
            for (int j = 0; j < spill_cnt; ++j) {
                if (spilled_xmm_regs[j] == (XMMRegType)(i - FIXED_PARAM_COUNT)) {
                    src_xmm = passenger_xmm_regs[j];
                    break;
                }
                if (IS_YMM_HELPER(h) && ((spilled_xmm_regs[j] + 1) == (XMMRegType)(i - FIXED_PARAM_COUNT))) {
                    src_xmm = passenger_xmm_regs[j] + 1;
                    break;
                }
            }
        }
        uint64_t env_xmm_offset = get_xmm_offset(src_xmm / 2) + 16 * (src_xmm % 2);
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], env_xmm_offset, 0);
        LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("reload_vec_addr", dummy_slot_for_debug));
        return_args[i] = check_scalable_vector_perform_load(LLVMVector2xi64, addr, 16);
    }

    LLVMTypeRef next_type = LLVMGlobalGetValueType(next_func);
    LLVMValueRef call_next_inst;
    if (!fix_second_half_addr) {
        int next_addr_param_idx = (FIXED_VECTOR_PARAM_COUNT + (operands_cnt - env_cnt - drop_cnt));
        assert(next_addr_param_idx < LLVMCountParams(handler));
        LLVMValueRef next_addr = LLVMGetParam(handler, next_addr_param_idx);
        LLVMValueRef the_next = LLVMBuildIntToPtr(builder, next_addr, LLVMPointerType(next_type, 0), get_next_var_name("next", dummy_slot_for_debug));
#ifdef DEBUG
        printf("BuildCall2:%s\n", LLVMGetValueName(next_func)); fflush(NULL);
#endif
        call_next_inst = LLVMBuildCall2(builder, next_type, the_next, return_args, (FIXED_VECTOR_PARAM_COUNT + (helper_defines_output(u) ? 1 : 0)), "");
    } else {
        call_next_inst = LLVMBuildCall2(builder, next_type, next_func, return_args, (FIXED_VECTOR_PARAM_COUNT + (helper_defines_output(u) ? 1 : 0)), "");
    }
    LLVMSetTailCall(call_next_inst, 1);
    LLVMSetInstructionCallConv(call_next_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);

    assert(last_active_bb);
    LLVMPositionBuilderAtEnd(builder, last_active_bb);
    return handler;
}

static uint8_t do_link_helper(HelperType h, const char *build_macro, const char *bc_name, const char *c_file) {
    FILE *check_fp = fopen(bc_name, "r");
    if (!check_fp) {
        char cmd[2048+PATH_MAX] = {0};
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
#ifdef HELPER_COUNTERS
        sprintf(cmd, "clang -Wno-incompatible-function-pointer-types -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -c -DHELPER_COUNTERS=1 %s --target=aarch64-unknown-linux-gnu -mcpu=apple-m2 -fPIC -O1 -emit-llvm helper_templates/%s.c -o %s", build_macro, c_file, bc_name);
#else
        sprintf(cmd, "clang -Wno-incompatible-function-pointer-types -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -c %s --target=aarch64-unknown-linux-gnu -mcpu=apple-m2 -fPIC -O1 -emit-llvm helper_templates/%s.c -o %s", build_macro, c_file, bc_name);
#endif
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
#ifdef HELPER_COUNTERS
        sprintf(cmd, "clang -Wno-incompatible-function-pointer-types -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -c -DHELPER_COUNTERS=1 %s --target=riscv64-unknown-linux-gnu -march=rv64imafdv -fPIC -O1 -emit-llvm helper_templates/%s.c -o %s", build_macro, c_file, bc_name);
#else
        sprintf(cmd, "clang -Wno-incompatible-function-pointer-types -fno-exceptions -fno-unwind-tables -fno-asynchronous-unwind-tables -c %s --target=riscv64-unknown-linux-gnu -march=rv64imafdv -fPIC -O1 -emit-llvm helper_templates/%s.c -o %s", build_macro, c_file, bc_name);
#endif
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
        h == helper_iret_ind || h == helper_jmp_ind || h == helper_jumptable || h == helper_ljmp_protected ||
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
                    } else if (is_imm[i] == 0 && operands[i].s.valid && operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_env(operands[i])) {
                        OperandType alias = get_alias(operands[i]);
                        assert(alias.s.valid);
                        uint64_t xmm_offset = (uint64_t)alias.s.offset;
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
    } else if (target_domain == TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_EXPAND_ALIAS_POINTER) {
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
    } else if (target_domain == TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_DROP_ALIAS_POINTER) {
        if (gen_flag != VALUE_ONLY) {
            int idx = 0;
            for (; idx < FIXED_VECTOR_PARAM_COUNT; ++idx) {
                define_type(out_typeref, idx, fixed_vector_param_llvmtypes[idx], out_typeref_limit);
            }
            for (int i = 0; i < operands_cnt; ++i) {
                if (is_imm[i] == 0 && operands[i].s.valid && ((operands[i].s.slot_type == SUB_SLOT_ENV && operands[i].s.offset == 0) || (operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_env(operands[i])) || (operands[i].s.slot_type == SUB_SLOT_TMP && has_alias_xmm(operands[i])) || operands[i].s.slot_type == SUB_SLOT_XMM)) {
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
                            continue;
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
                        continue;
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

static LLVMValueRef get_or_add_func_with_qemuaot_cc(const char *name, int with_ret) {
#ifdef DEBUG
    printf("%s %s\n", __FUNCTION__, name); fflush(NULL);
#endif
    LLVMValueRef func = LLVMGetNamedFunction(module, name);
    if (!func) {
        LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT] = {NULL};
        int arg_cnt = collect_arguments_and_types(not_a_helper, TARGET_QEMUAOT_FASTPATH, TYPE_ONLY, NULL, NULL, 0, NULL, NULL, llvm_func, call_types, FIXED_VECTOR_PARAM_COUNT, NULL, name);
        LLVMTypeRef func_type = LLVMFunctionType(with_ret ? LLVMInt64Type() : LLVMVoidType(), call_types, arg_cnt, 0);
        func = LLVMAddFunction(module, name, func_type);
        LLVMAddAttributeAtIndex(func, -1, target_features_attr);
        LLVMAddAttributeAtIndex(func, -1, NoUnwindAttr);
        LLVMSetFunctionCallConv(func, QEMUAOT_CC);
        char sec_name[128] = {0};
        sprintf(sec_name, ".text.%s", name);
        LLVMSetSection(func, sec_name);
    }
    return func;
}

static LLVMValueRef create_static_array(LLVMModuleRef module, const char* name, size_t count) {
    LLVMTypeRef i64_type = LLVMInt64Type();
    LLVMTypeRef array_type = LLVMArrayType(i64_type, count);
    LLVMValueRef zero_initializer = LLVMConstNull(array_type);
    LLVMValueRef global_var = LLVMAddGlobal(module, array_type, name);
    LLVMSetInitializer(global_var, zero_initializer);
    LLVMSetSection(global_var, ".data");
    LLVMSetAlignment(global_var, 8);
    LLVMSetLinkage(global_var, LLVMInternalLinkage);
    LLVMValueRef zero = LLVMConstInt(LLVMInt32Type(), 0, 0);
    LLVMValueRef index = LLVMConstInt(LLVMInt32Type(), 0, 0);
    LLVMValueRef indices[] = {zero, index};
    LLVMValueRef elem_ptr = LLVMBuildGEP2(builder, array_type, global_var, indices, 2, "array_elem_ptr");
    return LLVMBuildPtrToInt(builder, elem_ptr, llvm_int_types[OPC_ADDR_T], "array_elem_ptr_val");
}

static LLVMValueRef create_reference_to_external_array(LLVMModuleRef module, const char* name, size_t count) {
    LLVMTypeRef i64_type = LLVMInt64Type();
    LLVMTypeRef array_type = LLVMArrayType(i64_type, count);
    LLVMValueRef global_var = LLVMGetNamedGlobal(module, name);
    if (!global_var) {
        global_var = LLVMAddGlobal(module, array_type, name);
        if (tcg_ir_head) {
            LLVMValueRef zero_initializer = LLVMConstNull(array_type);
            LLVMSetInitializer(global_var, zero_initializer);
            LLVMSetAlignment(global_var, 8);
        }
        LLVMSetLinkage(global_var, LLVMExternalLinkage);
    }
    LLVMValueRef zero = LLVMConstInt(LLVMInt32Type(), 0, 0);
    LLVMValueRef index = LLVMConstInt(LLVMInt32Type(), 0, 0);
    LLVMValueRef indices[] = {zero, index};
    LLVMValueRef elem_ptr = LLVMBuildGEP2(builder, array_type, global_var, indices, 2, "array_elem_ptr");
    return LLVMBuildPtrToInt(builder, elem_ptr, llvm_int_types[OPC_ADDR_T], "array_elem_ptr_val");
}

// FIXME: can this be merged into common logic?
static void translate_jmp_ind(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf(">>>%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], (long)u); fflush(NULL);
#endif
    HelperType h = get_helper(u);
    char *second_half_name = "jmp_ind_callback";
    OperandType operands[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm[MAX_OPERANDS_COUNT] = {0};
    int operands_cnt = 0;
    for (int i = 0; i < MAX_OPERANDS_COUNT; ++i) {
        operands[i] = get_operand_legacy(u, (i + get_first_in_op_idx(u)), &(is_imm[i]));
        if (is_imm[i] == 0 && operands[i].s.valid == 0) {
            break;
        }
        operands_cnt += 1;
    }

    OperandType shadow_map_op = get_tmp_and_do_alloc(OPC_ADDR_T);
    char shadow_map_name[64] = {0};
    sprintf(shadow_map_name, "%s%sshadow_map", func_name_prefix, func_name_prefix[0] ? "_" : "");
    LLVMValueRef shadow_map = create_reference_to_external_array(module, shadow_map_name, 0/*doesn't matter*/);
    do_store(opc, shadow_map, OPC_ADDR_T, shadow_map_op);

    is_imm[operands_cnt] = 1;
    OperandType invalid_array_entry;
    invalid_array_entry.i = 0;
    operands[operands_cnt] = invalid_array_entry;
    operands_cnt += 1;
    is_imm[operands_cnt] = 0;
    operands[operands_cnt] = shadow_map_op;
    operands_cnt += 1;

    // Get the second half - jmp_ind_callback
    char macro_def[4096] = {0};
    sprintf(macro_def, "-DXMM_PARAM_DECLARE_COMMON=\"%s\" -DXMM_PARAM_LIST=\"%s\" ", XMM_PARAM_DECLARE_COMMON, XMM_PARAM_LIST);
    assert(strlen(macro_def) < sizeof(macro_def));
    char bc_path[PATH_MAX+32] = {0};
    sprintf(bc_path, "%s/jmp_ind_callback.bc", output_path);
    uint8_t ret = do_link_helper(jmp_ind_callback, macro_def, bc_path, "jmp_ind_callback");
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
        LLVMAddAttributeAtIndex(helper_func, -1, NoUnwindAttr);
        LLVMSetFunctionCallConv(helper_func, QEMUAOT_CC);
        LLVMSetSection(helper_func, ".text.helper");
    }
    LLVMValueRef second_half_addr = LLVMBuildPtrToInt(builder, second_half_func, llvm_int_types[OPC_ADDR_T], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    // Inside the second_half - jmp_ind_callback logic may decide to invoke
    // runtime translation in case entry not found in AOT
    OperandType operands_for_jit[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm_for_jit[MAX_OPERANDS_COUNT] = {0};
    LLVMValueRef env_raw = get_env_ptr_raw();
    operands_for_jit[0] = get_tmp_and_do_alloc(OPC_ADDR_T);
    do_store(opc, env_raw, OPC_ADDR_T, operands_for_jit[0]);
    operands_for_jit[1] = operands[0];
    is_imm_for_jit[0] = 0;
    is_imm_for_jit[1] = 0;
    LLVMValueRef helper_jit_func = LLVMGetNamedFunction(module, helper_str[helper_jit]);
    if (!helper_jit_func) {
        LLVMTypeRef call_types[MAX_ADDED_ARGS] = {NULL};
        int call_arg_cnt = collect_arguments_and_types(helper_jit, TARGET_DEFAULT_HELPER_PASSTHROUGH_VECTOR, TYPE_ONLY, operands_for_jit, is_imm_for_jit, 2, NULL, NULL, llvm_func, call_types, MAX_ADDED_ARGS, NULL, helper_str[helper_jit]);
        LLVMTypeRef helper_jit_type = LLVMFunctionType(llvm_int_types[helper_return_type[h]], call_types, call_arg_cnt, 0);
        helper_jit_func = LLVMAddFunction(module, helper_str[helper_jit], helper_jit_type);
        LLVMAddAttributeAtIndex(helper_jit_func, -1, NoUnwindAttr);
        LLVMSetSection(helper_jit_func, ".text.helper");
    }

    LLVMValueRef jit_trampoline = get_trampoline(h, helper_jit_func, 0, 0, operands_for_jit, is_imm_for_jit, 2, NULL, 0, NULL, 0, TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER, u);
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
    // Check if we got remaining BBs
    do {
        llvm_func = llvm_func_backup;
        uint8_t current_active_label_cnt = get_current_active_label_cnt(llvm_func);
        if (!current_active_label_cnt) {
            break;
        }
        uint8_t *current_active_labels = get_current_active_labels(llvm_func);
        uint8_t tgt_lbl = current_active_labels[0];
        UnifiedInstr *u_tmp = NULL;
        for (u_tmp = func_head; u_tmp; u_tmp = u_tmp->next) {
            OpCodeType opc = get_opcode(u_tmp);
            if (opc == set_label && get_label_from_instr(u_tmp) == tgt_lbl) {
                break;
            }
        }
        assert(u_tmp);
        for (; u_tmp; u_tmp = u_tmp->next) {
            OpCodeType opc = get_opcode(u_tmp);
            handle_single_instr(opc, u_tmp);
            if (is_opc_end_of_control_flow(opc, u_tmp)) {
                break;
            }
        }
    } while (1);
#ifdef DEBUG
    printf("<<<%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], (long)u); fflush(NULL);
#endif
}

static void translate_jumptable(OpCodeType opc, const UnifiedInstr *u) {
#ifdef DEBUG
    printf(">>>%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], (long)u); fflush(NULL);
#endif
    HelperType h = get_helper(u);
    char *second_half_name = "jmp_ind_callback";
    OperandType operands[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm[MAX_OPERANDS_COUNT] = {0};
    int operands_cnt = 0;
    for (int i = 0; i < MAX_OPERANDS_COUNT; ++i) {
        operands[i] = get_operand_legacy(u, (i + get_first_in_op_idx(u)), &(is_imm[i]));
        if (is_imm[i] == 0 && operands[i].s.valid == 0) {
            break;
        }
        operands_cnt += 1;
    }

    /*
     * TCG IR looks like:
       mov_i64 loc643,rax
       shl_i64 loc2,rax,$0x2
       add_i64 loc2,loc2,rsi
       qemu_ld_i64 loc0,loc2,noat+al+lesl,2
       ...
       call jmp_ind,$0x1,$0,rip,loc643,$0x15

     * In above example, "loc643" is the index of current jump-table entry, and 0x15 is the jump-table size
       identified by script identify_jump_table_by_AI.pl
     */
    int tgt_idx = 0;
    int jt_entry_idx = operands_cnt-2;
    int jt_size_idx = operands_cnt-1;
    assert(is_imm[jt_size_idx]);
    OperandType shadow_array_op = get_tmp_and_do_alloc(OPC_ADDR_T);
    LLVMType type_in = OPC_ADDR_T;
    LLVMType type_out = OPC_ADDR_T;
    LLVMValueRef src1 = get_source_node_imm_or_stack(opc, is_imm[jt_entry_idx], operands[jt_entry_idx], type_in, 0);
    LLVMValueRef src2 = get_source_node_imm_or_stack(opc, is_imm[jt_size_idx], operands[jt_size_idx], type_in, 0);

    LLVMValueRef bool1 = LLVMBuildICmp(builder, LLVMIntULT, src1, src2, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    LLVMBasicBlockRef bb_inside_jt = LLVMAppendBasicBlock(llvm_func, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMBasicBlockRef bb_outof_jt = LLVMAppendBasicBlock(llvm_func, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMBasicBlockRef bb_ctz_merge = LLVMAppendBasicBlock(llvm_func, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    LLVMBuildCondBr(builder, bool1, bb_inside_jt, bb_outof_jt);
    LLVMPositionBuilderAtEnd(builder, bb_inside_jt);

    char shadow_array_name[64] = {0};
    sprintf(shadow_array_name, "%s%sshadow_array_%lx", func_name_prefix, func_name_prefix[0] ? "_" : "", current_func_offset);
    LLVMValueRef shadow_array = create_static_array(module, shadow_array_name, 2 * operands[jt_size_idx].i);
    LLVMValueRef offset_cnt = LLVMConstInt(LLVMInt64Type(), 4, 0);
    LLVMValueRef offset_val = LLVMBuildShl(builder, src1, offset_cnt, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef shadow_pointer = LLVMBuildAdd(builder, shadow_array, offset_val, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    LLVMValueRef target_pointer = LLVMBuildIntToPtr(builder, shadow_pointer, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef target_validate_val = build_load_with_alignment(builder, llvm_int_types[OPC_ADDR_T], target_pointer, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug), 8);

    LLVMValueRef tgt = get_source_node_imm_or_stack(opc, is_imm[tgt_idx], operands[tgt_idx], type_in, 0);
    LLVMValueRef bool2 = LLVMBuildICmp(builder, LLVMIntEQ, tgt, target_validate_val, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    LLVMBasicBlockRef bb_hit_shadow_array = LLVMAppendBasicBlock(llvm_func, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMBasicBlockRef bb_miss_shadow_array = LLVMAppendBasicBlock(llvm_func, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMBuildCondBr(builder, bool2, bb_hit_shadow_array, bb_miss_shadow_array);
    LLVMPositionBuilderAtEnd(builder, bb_hit_shadow_array);

    LLVMValueRef shadow_dest_offset = LLVMConstInt(LLVMInt64Type(), 8, 0);
    LLVMValueRef shadow_dest = LLVMBuildAdd(builder, shadow_pointer, shadow_dest_offset, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef shadow_dest_pointer = LLVMBuildIntToPtr(builder, shadow_dest, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef dest_val = build_load_with_alignment(builder, llvm_int_types[OPC_ADDR_T], shadow_dest_pointer, get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug), 8);
    LLVMTypeRef call_types_for_jt[FIXED_VECTOR_PARAM_COUNT] = {NULL};
    LLVMValueRef call_args_for_jt[FIXED_VECTOR_PARAM_COUNT] = {NULL};
    int arg_cnt = collect_arguments_and_types(not_a_helper, TARGET_QEMUAOT_FASTPATH, TYPE_AND_VALUE, NULL, NULL, 0, NULL, NULL, llvm_func, call_types_for_jt, FIXED_VECTOR_PARAM_COUNT, call_args_for_jt, "jumptable_target");
    LLVMTypeRef ret_type = LLVMVoidType();
    LLVMTypeRef func_type = LLVMFunctionType(ret_type, call_types_for_jt, arg_cnt, 0);
    LLVMValueRef the_dest = LLVMBuildIntToPtr(builder, dest_val, LLVMPointerType(func_type, 0), get_next_var_name("helper_func", dummy_slot_for_debug));
    LLVMValueRef call_inst = LLVMBuildCall2(builder, func_type, the_dest, call_args_for_jt, arg_cnt, "");
    LLVMSetTailCall(call_inst, 1);
    LLVMSetInstructionCallConv(call_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);

    LLVMPositionBuilderAtEnd(builder, bb_miss_shadow_array);
    LLVMBuildBr(builder, bb_ctz_merge);

    LLVMPositionBuilderAtEnd(builder, bb_outof_jt);
    LLVMValueRef invalid_pointer = LLVMConstInt(LLVMInt64Type(), 0, 0);
    LLVMBuildBr(builder, bb_ctz_merge);

    LLVMPositionBuilderAtEnd(builder, bb_ctz_merge);
    last_active_bb = bb_ctz_merge;
    LLVMValueRef phi = LLVMBuildPhi(builder, llvm_int_types[type_out], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
    LLVMValueRef phi_incoming_values[] = {shadow_pointer, invalid_pointer, shadow_pointer};
    LLVMBasicBlockRef phi_incoming_blocks[] = {bb_inside_jt, bb_outof_jt, bb_miss_shadow_array};
    LLVMAddIncoming(phi, phi_incoming_values, phi_incoming_blocks, 3);
    do_store(opc, phi, OPC_ADDR_T, shadow_array_op);

    OperandType shadow_map_op = get_tmp_and_do_alloc(OPC_ADDR_T);
    char shadow_map_name[64] = {0};
    sprintf(shadow_map_name, "%s%sshadow_map", func_name_prefix, func_name_prefix[0] ? "_" : "");
    LLVMValueRef shadow_map = create_reference_to_external_array(module, shadow_map_name, 0/*doesn't matter*/);
    do_store(opc, shadow_map, OPC_ADDR_T, shadow_map_op);

    operands_cnt -= 2;
    is_imm[operands_cnt] = 0;
    operands[operands_cnt] = shadow_array_op;
    operands_cnt += 1;
    is_imm[operands_cnt] = 0;
    operands[operands_cnt] = shadow_map_op;
    operands_cnt += 1;

    // Get the second half - jmp_ind_callback
    char macro_def[4096] = {0};
    sprintf(macro_def, "-DXMM_PARAM_DECLARE_COMMON=\"%s\" -DXMM_PARAM_LIST=\"%s\" ", XMM_PARAM_DECLARE_COMMON, XMM_PARAM_LIST);
    assert(strlen(macro_def) < sizeof(macro_def));
    char bc_path[PATH_MAX+32] = {0};
    sprintf(bc_path, "%s/jmp_ind_callback.bc", output_path);
    uint8_t ret = do_link_helper(jmp_ind_callback, macro_def, bc_path, "jmp_ind_callback");
    assert(ret);
    LLVMValueRef second_half_func = LLVMGetNamedFunction(module, second_half_name);
    assert(second_half_func);

    // Get the helper
    h = helper_jmp_ind;
    LLVMValueRef helper_func = LLVMGetNamedFunction(module, helper_str[h]);
    if (!helper_func) {
        LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS] = {NULL};
        int arg_cnt = collect_arguments_and_types(h, TARGET_QEMUAOT_HELPER, TYPE_ONLY, operands, is_imm, operands_cnt, (LLVMValueRef)1, (LLVMValueRef)1, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_ADDED_ARGS), NULL, helper_str[h]);
        LLVMTypeRef helper_type = LLVMFunctionType(LLVMVoidType(), call_types, arg_cnt, 0);
        helper_func = LLVMAddFunction(module, helper_str[h], helper_type);
        LLVMAddAttributeAtIndex(helper_func, -1, NoUnwindAttr);
        LLVMSetFunctionCallConv(helper_func, QEMUAOT_CC);
        LLVMSetSection(helper_func, ".text.helper");
    }
    LLVMValueRef second_half_addr = LLVMBuildPtrToInt(builder, second_half_func, llvm_int_types[OPC_ADDR_T], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));

    // Inside the second_half - jmp_ind_callback logic may decide to invoke
    // runtime translation in case entry not found in AOT
    OperandType operands_for_jit[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm_for_jit[MAX_OPERANDS_COUNT] = {0};
    LLVMValueRef env_raw = get_env_ptr_raw();
    operands_for_jit[0] = get_tmp_and_do_alloc(OPC_ADDR_T);
    do_store(opc, env_raw, OPC_ADDR_T, operands_for_jit[0]);
    operands_for_jit[1] = operands[0];
    is_imm_for_jit[0] = 0;
    is_imm_for_jit[1] = 0;
    LLVMValueRef helper_jit_func = LLVMGetNamedFunction(module, helper_str[helper_jit]);
    if (!helper_jit_func) {
        LLVMTypeRef call_types[MAX_ADDED_ARGS] = {NULL};
        int call_arg_cnt = collect_arguments_and_types(helper_jit, TARGET_DEFAULT_HELPER_PASSTHROUGH_VECTOR, TYPE_ONLY, operands_for_jit, is_imm_for_jit, 2, NULL, NULL, llvm_func, call_types, MAX_ADDED_ARGS, NULL, helper_str[helper_jit]);
        LLVMTypeRef helper_jit_type = LLVMFunctionType(llvm_int_types[helper_return_type[h]], call_types, call_arg_cnt, 0);
        helper_jit_func = LLVMAddFunction(module, helper_str[helper_jit], helper_jit_type);
        LLVMAddAttributeAtIndex(helper_jit_func, -1, NoUnwindAttr);
        LLVMSetSection(helper_jit_func, ".text.helper");
    }

    LLVMValueRef jit_trampoline = get_trampoline(h, helper_jit_func, 0, 0, operands_for_jit, is_imm_for_jit, 2, NULL, 0, NULL, 0, TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER, u);
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
    // Check if we got remaining BBs
    do {
        llvm_func = llvm_func_backup;
        uint8_t current_active_label_cnt = get_current_active_label_cnt(llvm_func);
        if (!current_active_label_cnt) {
            break;
        }
        uint8_t *current_active_labels = get_current_active_labels(llvm_func);
        uint8_t tgt_lbl = current_active_labels[0];
        UnifiedInstr *u_tmp = NULL;
        for (u_tmp = func_head; u_tmp; u_tmp = u_tmp->next) {
            OpCodeType opc = get_opcode(u_tmp);
            if (opc == set_label && get_label_from_instr(u_tmp) == tgt_lbl) {
                break;
            }
        }
        assert(u_tmp);
        for (; u_tmp; u_tmp = u_tmp->next) {
            OpCodeType opc = get_opcode(u_tmp);
            handle_single_instr(opc, u_tmp);
            if (is_opc_end_of_control_flow(opc, u_tmp)) {
                break;
            }
        }
    } while (1);
#ifdef DEBUG
    printf("<<<%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], (long)u); fflush(NULL);
#endif
}

static void translate_cc_compute_inband(OpCodeType opc, const UnifiedInstr *u) {
    HelperType h = get_helper(u);
#ifdef DEBUG
    printf("%s %s %s %lx\n", __FUNCTION__, opcode_type_str[opc], helper_str[h], (long)u); fflush(NULL);
#endif
    OperandType oarg;
    uint32_t is_imm_dummy;
    oarg = get_operand_legacy(u, get_first_out_op_idx(u), &is_imm_dummy);
    assert(!is_imm_dummy && oarg.s.valid);
    OperandType operands[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm[MAX_OPERANDS_COUNT] = {0};
    int operands_cnt = 0;
    for (int i = 0; i < MAX_OPERANDS_COUNT; ++i) {
        operands[i] = get_operand_legacy(u, (i + get_first_in_op_idx(u)), &(is_imm[i]));
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
        char bc_name[PATH_MAX+64] = {0};
        char element[256] = {0};
        sprintf(build_macro, "-DXMM_PARAM_DECLARE_COMMON=\"%s\" -DXMM_PARAM_LIST=\"%s\"", XMM_PARAM_DECLARE_COMMON, XMM_PARAM_LIST);
        sprintf(element, " -DHELPER_NAME=%s_inband", helper_str[h]);
        strcat(build_macro, element);
        sprintf(bc_name, "%s/%s.bc", output_path, helper_str[h]);
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
    LLVMValueRef env_raw = get_env_ptr_raw();
    uint64_t xmm_offset = get_xmm_offset(xmm_reg/2) + 16*(xmm_reg%2);
    LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
    LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("", dummy_slot_for_debug));
    check_scalable_vector_perform_store(xmm_val, LLVMVector2xi64, addr, 16);
}

static LLVMValueRef reload_vector(XMMRegType xmm_reg) {
    LLVMValueRef env_raw = get_env_ptr_raw();
    uint64_t xmm_offset = get_xmm_offset(xmm_reg/2) + 16*(xmm_reg%2);
    LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
    LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("", dummy_slot_for_debug));
    return check_scalable_vector_perform_load(LLVMVector2xi64, addr, 16);
}

static void translate_helper_outband(OpCodeType opc, const UnifiedInstr *u) {
    HelperType h = get_helper(u);
#ifdef DEBUG
    printf(">>>%s %s %s %lx\n", __FUNCTION__, opcode_type_str[opc], helper_str[h], (long)u); fflush(NULL);
#endif
    
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
      oarg = get_operand_legacy(u, get_first_out_op_idx(u), &is_imm_dummy);
      assert(!is_imm_dummy && oarg.s.valid);
    }
    OperandType operands[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm[MAX_OPERANDS_COUNT] = {0};
    int operands_cnt = 0;
    uint16_t vec_slots[MAX_OPERANDS_COUNT] = {0};
    int vec_cnt = 0;
    for (int i = 0; i < MAX_OPERANDS_COUNT; ++i) {
        operands[i] = get_operand_legacy(u, (i + get_first_in_op_idx(u)), &(is_imm[i]));
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
    OperandType operands_for_eh[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm_for_eh[MAX_OPERANDS_COUNT] = {0};

    // Operands for the exception handler
    int operands_cnt_for_eh = 0;
    do {
        operands_for_eh[operands_cnt_for_eh] = get_operand_legacy(u, (operands_cnt_for_eh + get_first_in_op_idx(u)), &is_imm_for_eh[operands_cnt_for_eh]);
        if (is_imm_for_eh[operands_cnt_for_eh] == 0 && operands_for_eh[operands_cnt_for_eh].s.valid == 0) {
            break;
        }
        operands_cnt_for_eh += 1;
    } while (1);
    assert(operands_cnt_for_eh <= MAX_OPERANDS_COUNT);

    // Do vector register spill/reload if candidate helper can be inlined
    XMMRegType spilled_xmm_regs[MAX_OPERANDS_COUNT];
    XMMRegType passenger_xmm_regs[MAX_OPERANDS_COUNT];
    int passenger_xmm_regs_cnt = 0;
    assert((used_xmm_regs_cnt + touched_effective_xmm_regs_cnt) <= XMM_COUNT);
    if (touched_effective_xmm_regs_cnt) {
        XMMRegType free_xmm_regs[XMM_COUNT];
        XMMRegType tmp = xmm1;  // pcmpistrm writes to xmm0
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
#ifdef DEBUG
            printf("%s passenger_xmm_reg:%s spilled_xmm_reg:%s\n", __FUNCTION__, xmmreg_str[passenger_xmm_regs[passenger_xmm_regs_cnt]], xmmreg_str[spilled_xmm_regs[passenger_xmm_regs_cnt]]); fflush(NULL);
#endif
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
                int spill_idx = -1;
                for (int j = 0; j < passenger_xmm_regs_cnt; ++j) {
                    if (passenger_xmm_regs[j] == equivalent_xmm.xmm_idx) {
                        spill_idx = j;
                        break;
                    }
                }
                assert(spill_idx != -1);
                operands[i].s.slot_type = SUB_SLOT_XMM;
                operands[i].s.slot_idx = spilled_xmm_regs[spill_idx];
                int new_idx = spilled_xmm_regs[spill_idx];

                // Now load passenger into the slot
                if (!fixed_vector_param_in_stack[FIXED_PARAM_COUNT + new_idx]) {
                    LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx]], fixed_vector_stack_names[FIXED_PARAM_COUNT + new_idx]);
                    LLVMSetAlignment(alloca_inst, GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx]));
                    func_xmm_alloca[new_idx].alloca = alloca_inst;
                    func_xmm_alloca[new_idx].alignment = GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx]);
                    func_xmm_llvmtype[new_idx] = fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx];
                    fixed_vector_param_in_stack[FIXED_PARAM_COUNT + new_idx] = 1;
                }
                OperandType op;
                op.s.valid = 1;
                op.s.slot_type = SUB_SLOT_ENV;
                op.s.offset = alias.s.offset;
                LLVMValueRef val = get_source_node_imm_or_stack(opc, 0, op, func_xmm_llvmtype[new_idx], 0);
                build_store_with_alignment(builder, val, func_xmm_alloca[new_idx].alloca, func_xmm_alloca[new_idx].alignment);
                if (IS_YMM_HELPER(h)) {
                    if (!fixed_vector_param_in_stack[FIXED_PARAM_COUNT + new_idx + 1]) {
                        LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx + 1]], fixed_vector_stack_names[FIXED_PARAM_COUNT + new_idx + 1]);
                        LLVMSetAlignment(alloca_inst, GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx + 1]));
                        func_xmm_alloca[new_idx + 1].alloca = alloca_inst;
                        func_xmm_alloca[new_idx + 1].alignment = GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx + 1]);
                        func_xmm_llvmtype[new_idx + 1] = fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx + 1];
                        fixed_vector_param_in_stack[FIXED_PARAM_COUNT + new_idx + 1] = 1;
                    }
                    OperandType op;
                    op.s.valid = 1;
                    op.s.slot_type = SUB_SLOT_ENV;
                    op.s.offset = alias.s.offset + 16;
                    LLVMValueRef val = get_source_node_imm_or_stack(opc, 0, op, func_xmm_llvmtype[new_idx + 1], 0);
                    build_store_with_alignment(builder, val, func_xmm_alloca[new_idx + 1].alloca, func_xmm_alloca[new_idx + 1].alignment);
                }
            }
        }
    }

    ///////////////////////////////////////////////////////////
    /// Collect build macros for xmm helpers, and those marcos define specific version of helpers
    char build_macro[4096] = {0};
    sprintf(build_macro, "-DXMM_PARAM_DECLARE_COMMON=\"%s\" -DXMM_PARAM_LIST=\"%s\"", XMM_PARAM_DECLARE_COMMON, XMM_PARAM_LIST);
    char vector_seq_name[512] = {0};
    printf("vec_cnt:%d\n", vec_cnt);
    for (int i = 0; i < vec_cnt; ++i) {
        uint16_t xmm_idx = vec_slots[i];
        for (int j = 0; j < passenger_xmm_regs_cnt; ++j) {
            if (xmm_idx == passenger_xmm_regs[j]) {
                xmm_idx = spilled_xmm_regs[j];
                break;
            }
        }
        char element1[64];
        char element2[32];
        if (IS_XMM_HELPER(h) || IS_FLOATINGPOINT_INLINED_HELPER(h)) {
            sprintf(element1, " -DVEC%d=%s", i, xmmreg_str[xmm_idx]);
        } else if (IS_YMM_HELPER(h)) {
            sprintf(element1, " -DVEC%dX=%s -DVEC%dY=%s", i, xmmreg_str[xmm_idx], i, xmmreg_str[xmm_idx + 1]);
        }
        sprintf(element2, "_VEC%d_%s", i, xmmreg_str[xmm_idx]);
        strcat(build_macro, element1);
        strcat(vector_seq_name, element2);
    }

    char second_half_name[64];
    uint8_t call_idx = get_idx_for_call_helper(u);
    sprintf(second_half_name, "%s%sfunc_%lx_call%d", func_name_prefix, func_name_prefix[0] ? "_" : "", current_func_offset, call_idx);

    char helper_func_name[1024] = {0};
    char bc_name[PATH_MAX+64] = {0};
    char element[1024] = {0};
    sprintf(element, " -DHELPER_NAME=%s%s_outband", helper_str[h], vector_seq_name);
    strcat(build_macro, element);
    sprintf(bc_name, "%s/%s%s.bc", output_path, helper_str[h], vector_seq_name);
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
        LLVMAddAttributeAtIndex(second_half_func, -1, NoUnwindAttr);
        LLVMSetFunctionCallConv(second_half_func, QEMUAOT_CC);
        char sec_name[128] = {0};
        sprintf(sec_name, ".text.%s", second_half_name);
        LLVMSetSection(second_half_func, sec_name);
        add_list_info(second_half_name, "define");
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
            LLVMAddAttributeAtIndex(helper_func, -1, NoUnwindAttr);
            LLVMSetSection(helper_func, ".text.helper");
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
        exception_path_trampoline = get_exception_handler(h, helper_func, helper_return_type[h] != LLVMInvalidType ? 1 : 0, operands_for_eh, is_imm_for_eh, operands_cnt_for_eh, second_half_func, passenger_xmm_regs_cnt, spilled_xmm_regs, passenger_xmm_regs, param_cnt == MAX_ADDED_ARGS, u);
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
    // Check if we got remaining BBs
    do {
        llvm_func = llvm_func_backup;
        uint8_t current_active_label_cnt = get_current_active_label_cnt(llvm_func);
        if (!current_active_label_cnt) {
            break;
        }
        uint8_t *current_active_labels = get_current_active_labels(llvm_func);
        uint8_t tgt_lbl = current_active_labels[0];
        UnifiedInstr *u_tmp = NULL;
        for (u_tmp = func_head; u_tmp; u_tmp = u_tmp->next) {
            OpCodeType opc = get_opcode(u_tmp);
            if (opc == set_label && get_label_from_instr(u_tmp) == tgt_lbl) {
                break;
            }
        }
        assert(u_tmp);
        for (; u_tmp; u_tmp = u_tmp->next) {
            OpCodeType opc = get_opcode(u_tmp);
            handle_single_instr(opc, u_tmp);
            if (is_opc_end_of_control_flow(opc, u)) {
                break;
            }
        }
    } while (1);

    if (second_half_already_exists) {
#ifdef DEBUG
        printf("<<<%s %s %lx return early\n", __FUNCTION__, opcode_type_str[opc], (long)u); fflush(NULL);
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
            if (!func_xmm_alloca[spilled_xmm_regs[i]].alloca) {
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + spilled_xmm_regs[i]]], fixed_vector_stack_names[FIXED_PARAM_COUNT + spilled_xmm_regs[i]]);
                LLVMSetAlignment(alloca_inst, GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + spilled_xmm_regs[i]]));
                func_xmm_alloca[spilled_xmm_regs[i]].alloca = alloca_inst;
                func_xmm_alloca[spilled_xmm_regs[i]].alignment = GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + spilled_xmm_regs[i]]);
                func_xmm_llvmtype[spilled_xmm_regs[i]] = fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + spilled_xmm_regs[i]];
            }
            build_store_with_alignment(builder, xmm_val, func_xmm_alloca[spilled_xmm_regs[i]].alloca, func_xmm_alloca[spilled_xmm_regs[i]].alignment);
            fixed_vector_param_in_stack[FIXED_PARAM_COUNT + spilled_xmm_regs[i]] = 1;
            if (IS_YMM_HELPER(h)) {
                xmm_val = reload_vector(spilled_xmm_regs[i] + 1);
                if (!func_xmm_alloca[spilled_xmm_regs[i] + 1].alloca) {
                    LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1]], fixed_vector_stack_names[FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1]);
                    LLVMSetAlignment(alloca_inst, GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1]));
                    func_xmm_alloca[spilled_xmm_regs[i] + 1].alloca = alloca_inst;
                    func_xmm_alloca[spilled_xmm_regs[i] + 1].alignment = GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1]);
                    func_xmm_llvmtype[spilled_xmm_regs[i] + 1] = fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1];
                }
                build_store_with_alignment(builder, xmm_val, func_xmm_alloca[spilled_xmm_regs[i] + 1].alloca, func_xmm_alloca[spilled_xmm_regs[i] + 1].alignment);
                fixed_vector_param_in_stack[FIXED_PARAM_COUNT + spilled_xmm_regs[i] + 1] = 1;
            }
        }
    }

    // Start from the one after u
    for (const UnifiedInstr *u_tmp = u->next; u_tmp; u_tmp = u_tmp->next) {
        OpCodeType opc = get_opcode(u_tmp);
        handle_single_instr(opc, u_tmp);
        if (is_opc_end_of_control_flow(opc, u_tmp)) {
            while (get_current_active_label_cnt(second_half_func)) {
                uint8_t *current_active_labels = get_current_active_labels(second_half_func);
                uint8_t tgt_lbl = current_active_labels[0];
                UnifiedInstr *u_tmp = NULL;
                for (u_tmp = func_head; u_tmp; u_tmp = u_tmp->next) {
                    OpCodeType opc = get_opcode(u_tmp);
                    if (opc == set_label && get_label_from_instr(u_tmp) == tgt_lbl) {
                        break;
                    }
                }
                assert(u_tmp);
                for (; u_tmp; u_tmp = u_tmp->next) {
                    OpCodeType opc = get_opcode(u_tmp);
                    handle_single_instr(opc, u_tmp);
                    if (is_opc_end_of_control_flow(opc, u_tmp)) {
                        break;
                    }
                }
            }
            break;
        }
    }
    llvm_func = NULL;
#ifdef DEBUG
    printf("<<<%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], (long)u); fflush(NULL);
#endif
}

void translate_call(OpCodeType opc, const UnifiedInstr *u) {
    DECLARE_AND_INIT_TYPE_FOR_SCALAR;
    HelperType h = get_helper(u);

#ifdef HELPER_COUNTERS
    {
        LLVMValueRef env_raw = get_env_ptr_raw();
        uint64_t counter_offset = HELPER_COUNTERS_OFFSET;
        LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], counter_offset, 0);
        LLVMValueRef addr = LLVMBuildSub(builder, env_raw, off, get_next_var_name("helper_counters_addr", dummy_slot_for_debug));
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name("helper_counters_ptr", dummy_slot_for_debug));
        LLVMValueRef val = build_load_with_alignment(builder, llvm_int_types[OPC_ADDR_T], ptr, get_next_var_name("helper_counters_val", dummy_slot_for_debug), 8);

        off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], h*8, 0);
        addr = LLVMBuildAdd(builder, val, off, get_next_var_name("helper_counter_addr", dummy_slot_for_debug));
        ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name("helper_counter_ptr", dummy_slot_for_debug));
        val = build_load_with_alignment(builder, llvm_int_types[OPC_ADDR_T], ptr, get_next_var_name("helper_counter_val_before", dummy_slot_for_debug), 8);
        LLVMValueRef one = LLVMConstInt(llvm_int_types[OPC_ADDR_T], 1, 0);
        val = LLVMBuildAdd(builder, val, one, get_next_var_name("helper_counter_val_after", dummy_slot_for_debug));
        build_store_with_alignment(builder, val, ptr, 8);
    }
#endif

    if (h == helper_jmp_ind) {
        return translate_jmp_ind(opc, u);
    } else if (h == helper_jumptable) {
        return translate_jumptable(opc, u);
    } else if (h == helper_cc_compute_all || h == helper_cc_compute_c || h == helper_cc_compute_nz) {
        if (helper_require_exception_path[h]) {
            return translate_helper_outband(opc, u);
        } else {
            return translate_cc_compute_inband(opc, u);
        }
    } else if (INLINE_HELPER_ENABLED(h)) {
        return translate_helper_outband(opc, u);
    }
    // We cannot inline below helpers currently, so their invocations incur context backup penalty.
#ifdef DEBUG
    printf(">>>%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], (long)u); fflush(NULL);
#endif

    char second_half_name[64];
    uint8_t call_idx = get_idx_for_call_helper(u);
    sprintf(second_half_name, "%s%sfunc_%lx_call%d", func_name_prefix, func_name_prefix[0] ? "_" : "", current_func_offset, call_idx);
    OperandType operands[MAX_OPERANDS_COUNT] = {0};
    uint32_t is_imm[MAX_OPERANDS_COUNT] = {0};

    int do_not_sync_vector_alias_slot_idx[MAX_OPERANDS_COUNT] = {0};
    int do_not_sync_vector_alias_slot_idx_cnt = 0;
    int operands_cnt = 0;
    do {
        operands[operands_cnt] = get_operand_legacy(u, (operands_cnt + get_first_in_op_idx(u)), &is_imm[operands_cnt]);
        if (is_imm[operands_cnt] == 0 && operands[operands_cnt].s.valid == 0) {
            break;
        }
        // Do active spill since the trampoline handles FIXED registers only!
        if (helper_do_not_sync_vector[h]) {
            if (is_imm[operands_cnt] == 0 && operands[operands_cnt].s.slot_type == SUB_SLOT_TMP && has_alias_xmm(operands[operands_cnt])) {
                OperandType alias = get_alias(operands[operands_cnt]);
                assert(alias.s.valid);
                do_not_sync_vector_alias_slot_idx[do_not_sync_vector_alias_slot_idx_cnt++] = alias.s.slot_idx;
                LLVMValueRef vec_val = LLVMGetParam(llvm_func, FIXED_PARAM_COUNT + alias.s.slot_idx);
                if (fixed_vector_param_in_stack[FIXED_PARAM_COUNT + alias.s.slot_idx]) {
                    vec_val = get_source_node_imm_or_stack(call, 0, alias, fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + alias.s.slot_idx], 0);
                }
                uint64_t xmm_offset = get_xmm_offset(alias.s.slot_idx / 2) + 16 * (alias.s.slot_idx % 2);
                LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
                LLVMValueRef env_raw = get_env_ptr_raw();
                LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("spill_vec_addr", dummy_slot_for_debug));
                check_scalable_vector_perform_store(vec_val, LLVMVector2xi64, addr, 16);
                if (IS_YMM_HELPER(h)) {
                    alias.s.slot_idx += 1;
                    LLVMValueRef vec_val = LLVMGetParam(llvm_func, FIXED_PARAM_COUNT + alias.s.slot_idx);
                    if (fixed_vector_param_in_stack[FIXED_PARAM_COUNT + alias.s.slot_idx]) {
                        vec_val = get_source_node_imm_or_stack(call, 0, alias, fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + alias.s.slot_idx], 0);
                    }
                    uint64_t xmm_offset = get_xmm_offset(alias.s.slot_idx / 2) + 16 * (alias.s.slot_idx % 2);
                    LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
                    LLVMValueRef env_raw = get_env_ptr_raw();
                    LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("spill_vec_addr", dummy_slot_for_debug));
                    check_scalable_vector_perform_store(vec_val, LLVMVector2xi64, addr, 16);
                }
            }
        }
        operands_cnt += 1;
    } while (1);
    assert(operands_cnt <= MAX_OPERANDS_COUNT);
#ifdef DEBUG
    printf("%s_%s defines_output:%d operands_cnt:%d\n", helper_str[h], second_half_name, helper_defines_output(u), operands_cnt); fflush(NULL);
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
        LLVMAddAttributeAtIndex(second_half_func, -1, NoUnwindAttr);
        LLVMSetFunctionCallConv(second_half_func, QEMUAOT_CC);
        char sec_name[128] = {0};
        sprintf(sec_name, ".text.%s", second_half_name);
        LLVMSetSection(second_half_func, sec_name);
        add_list_info(second_half_name, "define");
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
        LLVMAddAttributeAtIndex(helper_func, -1, NoUnwindAttr);
        LLVMSetSection(helper_func, ".text.helper");
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
    LLVMValueRef trampoline = NULL;
#ifndef COLLECT_TRAMPOLINE_IR
    if (helper_do_not_sync_vector[h]) {
        assert(!second_half_disabled);
        assert(param_cnt < MAX_ADDED_ARGS);
        trampoline = get_trampoline_do_not_sync_vector(h, helper_func, operands, is_imm, operands_cnt, second_half_func, TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_EXPAND_ALIAS_POINTER, u);
    } else {
#else
    {
#endif
        trampoline = get_trampoline(h, helper_func, second_half_disabled ? 0 : 1, helper_defines_output(u), operands, is_imm, operands_cnt, second_half_func, 0, NULL, param_cnt == MAX_ADDED_ARGS, TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_EXPAND_ALIAS_POINTER, u);
    }
    LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT] = {NULL};
    int call_arg_cnt = collect_arguments_and_types(h, TARGET_QEMUAOT_TRAMPOLINE_FOR_DEFAULT_HELPER_EXPAND_ALIAS_POINTER, TYPE_AND_VALUE, operands, is_imm, operands_cnt, param_cnt == MAX_ADDED_ARGS ? NULL : second_half_addr, NULL, llvm_func, call_types, (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT), call_args, LLVMGetValueName(trampoline));
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT));
    if (helper_do_not_sync_vector[h]) {
        call_args[call_arg_cnt] = LLVMBuildPtrToInt(builder, helper_func, llvm_int_types[OPC_ADDR_T], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        call_types[call_arg_cnt] = llvm_int_types[OPC_ADDR_T];
        call_arg_cnt += 1;
    }
    assert(call_arg_cnt <= (FIXED_VECTOR_PARAM_COUNT + MAX_OPERANDS_COUNT));
    LLVMTypeRef trampoline_type = LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnt, 0);
    LLVMValueRef call_trampoline_inst = LLVMBuildCall2(builder, trampoline_type, trampoline, call_args, call_arg_cnt, "");
    LLVMSetTailCall(call_trampoline_inst, 1);
    LLVMSetInstructionCallConv(call_trampoline_inst, QEMUAOT_CC);
    LLVMBuildRetVoid(builder);

    LLVMValueRef llvm_func_backup = llvm_func;
    // Check if we got remaining BBs
    do {
        llvm_func = llvm_func_backup;
        uint8_t current_active_label_cnt = get_current_active_label_cnt(llvm_func);
        if (!current_active_label_cnt) {
            break;
        }
        uint8_t *current_active_labels = get_current_active_labels(llvm_func);
        uint8_t tgt_lbl = current_active_labels[0];
        UnifiedInstr *u_tmp = NULL;
        for (u_tmp = func_head; u_tmp; u_tmp = u_tmp->next) {
            OpCodeType opc = get_opcode(u_tmp);
            if (opc == set_label && get_label_from_instr(u_tmp) == tgt_lbl) {
                break;
            }
        }
        assert(u_tmp);
        for (; u_tmp; u_tmp = u_tmp->next) {
            OpCodeType opc = get_opcode(u_tmp);
            handle_single_instr(opc, u_tmp);
            if (is_opc_end_of_control_flow(opc, u_tmp)) {
                break;
            }
        }
    } while (1);

    if (second_half_disabled || second_half_already_exists) {
#ifdef DEBUG
        printf("<<<%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], (long)u); fflush(NULL);
#endif
        return;
    }

    /// Setup and finish the second-half function
    llvm_func = second_half_func;
    for (int j = 0; j < FIXED_VECTOR_PARAM_COUNT; j++) {
        LLVMValueRef param = LLVMGetParam(llvm_func, j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }
    if (helper_defines_output(u)) {
        assert(FIXED_VECTOR_PARAM_COUNT < LLVMCountParams(llvm_func));
        LLVMValueRef param = LLVMGetParam(llvm_func, FIXED_VECTOR_PARAM_COUNT);
        LLVMSetValueName(param, "helper_result");
    }

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);
    last_active_bb = entry;

    setup_func_stack();

    // Get output from helper func
    if (helper_defines_output(u)) {
        uint32_t is_imm;
        OperandType oarg = get_operand_legacy(u, get_first_out_op_idx(u), &is_imm);
        assert(!is_imm && oarg.s.valid);
        assert(FIXED_VECTOR_PARAM_COUNT < LLVMCountParams(llvm_func));
        LLVMValueRef param = LLVMGetParam(llvm_func, FIXED_VECTOR_PARAM_COUNT);
        if (helper_return_type[h] < LLVMInt64) {
            param = LLVMBuildTrunc(builder, param, llvm_int_types[helper_return_type[h]], get_next_var_name(opcode_type_str[opc], dummy_slot_for_debug));
        }
        do_store(opc, param, helper_return_type[h], oarg);
    }

    if (helper_do_not_sync_vector[h]) {
        for (int i = 0; i < do_not_sync_vector_alias_slot_idx_cnt; ++i) {
            int new_idx = do_not_sync_vector_alias_slot_idx[i];
            uint64_t xmm_offset = get_xmm_offset(new_idx / 2) + 16 * (new_idx % 2);
            LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
            LLVMValueRef env_raw = get_env_ptr_raw();
            LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("spill_vec_addr", dummy_slot_for_debug));
            LLVMValueRef val = check_scalable_vector_perform_load(LLVMVector2xi64, addr, 16);
            // Store into the slot
            if (!fixed_vector_param_in_stack[FIXED_PARAM_COUNT + new_idx]) {
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx]], fixed_vector_stack_names[FIXED_PARAM_COUNT + new_idx]);
                LLVMSetAlignment(alloca_inst, GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx]));
                func_xmm_alloca[new_idx].alloca = alloca_inst;
                func_xmm_alloca[new_idx].alignment = GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx]);
                func_xmm_llvmtype[new_idx] = fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx];
                fixed_vector_param_in_stack[FIXED_PARAM_COUNT + new_idx] = 1;
            }
            OperandType op;
            op.s.valid = 1;
            op.s.slot_type = SUB_SLOT_ENV;
            op.s.offset = xmm_offset;
            val = get_source_node_imm_or_stack(opc, 0, op, func_xmm_llvmtype[new_idx], 0);
            build_store_with_alignment(builder, val, func_xmm_alloca[new_idx].alloca, func_xmm_alloca[new_idx].alignment);
            if (IS_YMM_HELPER(h)) {
                new_idx += 1;
                uint64_t xmm_offset = get_xmm_offset(new_idx / 2) + 16 * (new_idx % 2);
                LLVMValueRef off = LLVMConstInt(llvm_int_types[OPC_ADDR_T], xmm_offset, 0);
                LLVMValueRef env_raw = get_env_ptr_raw();
                LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name("spill_vec_addr", dummy_slot_for_debug));
                LLVMValueRef val = check_scalable_vector_perform_load(LLVMVector2xi64, addr, 16);
                // Store into the slot
                if (!fixed_vector_param_in_stack[FIXED_PARAM_COUNT + new_idx]) {
                    LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx]], fixed_vector_stack_names[FIXED_PARAM_COUNT + new_idx]);
                    LLVMSetAlignment(alloca_inst, GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx]));
                    func_xmm_alloca[new_idx].alloca = alloca_inst;
                    func_xmm_alloca[new_idx].alignment = GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx]);
                    func_xmm_llvmtype[new_idx] = fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + new_idx];
                    fixed_vector_param_in_stack[FIXED_PARAM_COUNT + new_idx] = 1;
                }
                OperandType op;
                op.s.valid = 1;
                op.s.slot_type = SUB_SLOT_ENV;
                op.s.offset = xmm_offset;
                val = get_source_node_imm_or_stack(opc, 0, op, func_xmm_llvmtype[new_idx], 0);
                build_store_with_alignment(builder, val, func_xmm_alloca[new_idx].alloca, func_xmm_alloca[new_idx].alignment);
            }
        }
    }

    // Start from the one after u
    for (const UnifiedInstr *u_tmp = u->next; u_tmp; u_tmp = u_tmp->next) {
        OpCodeType opc = get_opcode(u_tmp);
        handle_single_instr(opc, u_tmp);
        if (is_opc_end_of_control_flow(opc, u_tmp)) {
            while (get_current_active_label_cnt(second_half_func)) {
                uint8_t *current_active_labels = get_current_active_labels(second_half_func);
                uint8_t tgt_lbl = current_active_labels[0];
                UnifiedInstr *u_tmp = NULL;
                for (u_tmp = func_head; u_tmp; u_tmp = u_tmp->next) {
                    OpCodeType opc = get_opcode(u_tmp);
                    if (opc == set_label && get_label_from_instr(u_tmp) == tgt_lbl) {
                        break;
                    }
                }
                assert(u_tmp);
                for (; u_tmp; u_tmp = u_tmp->next) {
                    OpCodeType opc = get_opcode(u_tmp);
                    handle_single_instr(opc, u_tmp);
                    if (is_opc_end_of_control_flow(opc, u_tmp)) {
                        break;
                    }
                }
            }
            break;
        }
    }
    llvm_func = NULL;
#ifdef DEBUG
    printf("<<<%s %s %lx\n", __FUNCTION__, opcode_type_str[opc], (long)u); fflush(NULL);
#endif
}

static void cleanup_func_resource() {
#ifdef DEBUG
    printf("%s\n", __FUNCTION__); fflush(NULL);
#endif
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
    carrybit_on = 0;
    borrowbit_on = 0;
    memset(tmp_bits_type, 0, sizeof(tmp_bits_type));

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
}

static void setup_func_stack() {
    memset(fixed_vector_param_in_stack, 0, sizeof(fixed_vector_param_in_stack));
    memset(func_xmm_alloca, 0, sizeof(func_xmm_alloca));

    if (xreg_valid) {
        for (XRegType x = 0; x < XREG_MAX; ++x) {
            if (xreg_valid & (1UL<<x)) {
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[x]], fixed_vector_stack_names[x]);
                LLVMSetAlignment(alloca_inst, GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[x]));
                func_xreg_alloca[x].alloca = alloca_inst;
                func_xreg_alloca[x].alignment = GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[x]);
                func_xreg_llvmtype[x] = fixed_vector_param_llvmtypes[x];
                build_store_with_alignment(builder, LLVMGetParam(llvm_func, x), func_xreg_alloca[x].alloca, func_xreg_alloca[x].alignment);
                fixed_vector_param_in_stack[x] = 1;
            }
        }
    }
    if (tmp_valid_non_zero) {
        for (int i = 0; i < (1<<STACK_INDEX_SHIFT); ++i) {
            if (tmp_available_test(tmp_valid, i)) {
                assert(tmp_bits_type[i]);
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[tmp_bits_type[i]], tmp_stack_names[i]);
                LLVMSetAlignment(alloca_inst, GET_LLVM_TYPE_ALIGNMENT(tmp_bits_type[i]));
                func_tmp_alloca[i].alloca = alloca_inst;
                func_tmp_alloca[i].alignment = GET_LLVM_TYPE_ALIGNMENT(tmp_bits_type[i]);
                func_tmp_llvmtype[i] = tmp_bits_type[i];
            }
        }
    }
    if (xmm_valid) {
        for (int i = 0; i < (1<<REGISTER_INDEX_SHIFT); ++i) {
            if (xmm_valid & (1UL<<i)) {
                assert((FIXED_PARAM_COUNT + i) < FIXED_VECTOR_PARAM_COUNT);
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + i]], fixed_vector_stack_names[FIXED_PARAM_COUNT + i]);
                LLVMSetAlignment(alloca_inst, GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + i]));
                func_xmm_alloca[i].alloca = alloca_inst;
                func_xmm_alloca[i].alignment = GET_LLVM_TYPE_ALIGNMENT(fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + i]);
                func_xmm_llvmtype[i] = fixed_vector_param_llvmtypes[FIXED_PARAM_COUNT + i];
                build_store_with_alignment(builder, LLVMGetParam(llvm_func, FIXED_PARAM_COUNT + i), func_xmm_alloca[i].alloca, func_xmm_alloca[i].alignment);
                fixed_vector_param_in_stack[FIXED_PARAM_COUNT + i] = 1;
            }
        }
    }
    if (carrybit_on) {
        carrybit_alloca = LLVMBuildAlloca(builder, LLVMInt1Type(), "carrybit");
    }
    if (borrowbit_on) {
        borrowbit_alloca = LLVMBuildAlloca(builder, LLVMInt1Type(), "borrowbit");
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

void handle_func(uint64_t off, UnifiedInstr *head, int is_external) {
#ifdef DEBUG
    printf("func %lx\n", off); fflush(NULL);
#endif
    func_head = head;
    current_func_offset = off;
    ir_var_name_idx = 0;
    /// Loop through all xreg/slot/xmm, handle arguments, stack alloc/store etc.
    for (UnifiedInstr *u = head; u; u = u->next) {
        OpCodeType opc = u->opc;
        OperandType oarg;
        uint32_t is_immo = 0;
        oarg.s.valid = 0;
        if (opc == call) {
            if (helper_defines_output(u)) {
                oarg = get_operand_legacy(u, get_first_out_op_idx(u), &is_immo);
                assert(!is_immo && oarg.s.valid);
            }
        }
        uint8_t is_vec = is_vector(u);
        LLVMType vtype = LLVMInvalidType;
        if (is_vec) {
          vtype = get_llvm_vector_type(u);
        }
        if (opc == call) {
            memset(tmp_has_known_def, 0, sizeof(tmp_has_known_def));
            if (!is_immo && oarg.s.valid && oarg.s.slot_type == SUB_SLOT_TMP) {
                tmp_has_known_def[oarg.s.slot_idx] = 1;
            }
            current_call_idx += 1;
            assert(current_call_idx < BB_MAX_CNT);
        }
        if (REQUIRES_CARRY_BIT(opc)) {
            carrybit_on = 1;
        }
        if (REQUIRES_BORROW_BIT(opc)) {
            borrowbit_on = 1;
        }
    }

    char func_name[64];
    sprintf(func_name, "%s%sfunc_%lx", func_name_prefix, func_name_prefix[0] ? "_" : "", off);
    if (is_external == 0) {
        llvm_func = get_or_add_func_with_qemuaot_cc(func_name, 0);
        LLVMSetLinkage(llvm_func, LLVMInternalLinkage);
        LLVMAddAttributeAtIndex(llvm_func, -1, AlwaysInlineAttr);
    } else {
        llvm_func = get_or_add_func_with_qemuaot_cc(func_name, 0);
        LLVMSetLinkage(llvm_func, LLVMExternalLinkage);
        LLVMAddAttributeAtIndex(llvm_func, -1, NoInlineAttr);
    }
    add_list_info(func_name, "define");
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
    for (UnifiedInstr *u = head; u; u = u->next) {
        OpCodeType opc = u->opc;
        handle_single_instr(opc, u);
        if (is_opc_end_of_control_flow(opc, u)) {
            while (get_current_active_label_cnt(llvm_func_backup)) {
                uint8_t *current_active_labels = get_current_active_labels(llvm_func_backup);
                uint8_t tgt_lbl = current_active_labels[0];
                UnifiedInstr *u_tmp = NULL;
                for (u_tmp = head; u_tmp; u_tmp = u_tmp->next) {
                    if (u_tmp->opc == set_label && get_label_from_instr(u_tmp) == tgt_lbl) {
                        break;
                    }
                }
                assert(u_tmp != NULL);
                for (; u_tmp; u_tmp = u_tmp->next) {
                    OpCodeType opc2 = u_tmp->opc;
                    if (opc2 == set_label && get_label_from_instr(u_tmp) != tgt_lbl) {
                        translate_set_label_fix_branch(opc2, u_tmp);
                        break;
                    }
                    handle_single_instr(opc2, u_tmp);
                    if (is_opc_end_of_control_flow(opc2, u_tmp)) {
                        break;
                    }
                }
            }
            break;
        }
    }

    cleanup_func_resource();
}

static void handle_single_instr(OpCodeType opc, const UnifiedInstr *u) {
    switch (opc) {
    case addc1o_i32:
    case addc1o_i64:
    case subb1o_i32:
    case subb1o_i64:
    case brcond_i32:
    case divs2_i32:
    case divs2_i64:
    case divu2_i32:
    case divu2_i64:
    case dup_vec:
        assert(0);
        break;

    case addci_i32:
    case addci_i64:
        translate_addci(opc, u);
        break;
    case addcio_i32:
    case addcio_i64:
        translate_addcio(opc, u);
        break;
    case addco_i32:
    case addco_i64:
        translate_addco(opc, u);
        break;
    case subbi_i32:
    case subbi_i64:
        translate_subbi(opc, u);
        break;
    case subbio_i32:
    case subbio_i64:
        translate_subbio(opc, u);
        break;
    case subbo_i32:
    case subbo_i64:
        translate_subbo(opc, u);
        break;
    case abs_vec:
        translate_abs_vec(opc, u);
        break;
    case bitsel_vec:
        translate_bitsel_vec(opc, u);
        break;
    case cmpsel_vec:
        translate_cmpsel_vec(opc, u);
        break;
    case ctpop_i32:
    case ctpop_i64:
        translate_ctpop(opc, u);
        break;
    case divs_i32:
    case divs_i64:
        translate_binary(opc, u, LLVMBuildSDiv);
        break;
    case divu_i32:
    case divu_i64:
        translate_binary(opc, u, LLVMBuildUDiv);
        break;
    case rems_i32:
    case rems_i64:
        translate_binary(opc, u, LLVMBuildSRem);
        break;
    case remu_i32:
    case remu_i64:
        translate_binary(opc, u, LLVMBuildURem);
        break;
    case rotli_vec:
    case rotls_vec:
        translate_rotl_vec(opc, u);
        break;
    case rotlv_vec:
        translate_rotlv_vec(opc, u);
        break;
    case rotrv_vec:
        translate_rotrv_vec(opc, u);
        break;
    case sari_vec:
    case sars_vec:
        translate_binary_splat_immediate(opc, u, LLVMBuildAShr);
        break;
    case sarv_vec:
        translate_binary(opc, u, LLVMBuildAShr);
        break;
    case shlv_vec:
        translate_binary(opc, u, LLVMBuildShl);
        break;
    case shrv_vec:
        translate_binary(opc, u, LLVMBuildLShr);
        break;
    case smax_vec:
        translate_binary_intrinsic(opc, u, "llvm.smax");
        break;
    case smin_vec:
        translate_binary_intrinsic(opc, u, "llvm.smin");
        break;
    case ssadd_vec:
        translate_binary_intrinsic(opc, u, "llvm.sadd.sat");
        break;
    case sssub_vec:
        translate_binary_intrinsic(opc, u, "llvm.ssub.sat");
        break;
    case usadd_vec:
        translate_binary_intrinsic(opc, u, "llvm.uadd.sat");
        break;
    case ussub_vec:
        translate_binary_intrinsic(opc, u, "llvm.usub.sat");
        break;
    case add_i64:
        translate_binary(opc, u, LLVMBuildAdd);
        break;
    case add_i32:
    case add_vec:
        translate_binary(opc, u, LLVMBuildAdd);
        break;
    case andc_i32:
    case andc_i64:
    case andc_vec:
        translate_andc(opc, u);
        break;
    case and_i32:
    case and_i64:
    case and_vec:
        translate_binary(opc, u, LLVMBuildAnd);
        break;
    case nor_i32:
    case nor_i64:
    case nor_vec:
        translate_nor(opc, u);
        break;
    case orc_i32:
    case orc_i64:
    case orc_vec:
        translate_orc(opc, u);
        break;
    case nand_i32:
    case nand_i64:
    case nand_vec:
        translate_nand(opc, u);
        break;
    case eqv_i32:
    case eqv_i64:
    case eqv_vec:
        translate_eqv(opc, u);
        break;
    case bswap16_i32:
        translate_bswap16_i32(opc, u);
        break;
    case bswap16_i64:
        translate_bswap16_i64(opc, u);
        break;
    case bswap32_i32:
        translate_bswap32_i32(opc, u);
        break;
    case bswap32_i64:
        translate_bswap32_i64(opc, u);
        break;
    case bswap64_i64:
        translate_bswap64_i64(opc, u);
        break;
    case clz_i32:
        translate_count_zero(opc, u, "llvm.ctlz.i32");
        break;
    case clz_i64:
        translate_count_zero(opc, u, "llvm.ctlz.i64");
        break;
    case cmp_vec:
        translate_cmp_vec(opc, u);
        break;
    case ctz_i32:
        translate_count_zero(opc, u, "llvm.cttz.i32");
        break;
    case ctz_i64:
        translate_count_zero(opc, u, "llvm.cttz.i64");
        break;
    case deposit_i32:
    case deposit_i64:
        translate_deposit(opc, u);
        break;
    case dupm_vec:
        translate_dupm_vec(opc, u);
        break;
    case extract2_i32:
    case extract2_i64:
        translate_extract2(opc, u);
        break;
    case extract_i32:
    case extract_i64:
        translate_extract(opc, u);
        break;
    case extrh_i64_i32:
        translate_extrh(opc, u);
        break;
    case extrl_i64_i32:
    case mov_i32:
    case mov_i64:
    case mov_vec:
        translate_mov(opc, u);
        break;
    case ext_i32_i64:
        translate_ext(opc, u, LLVMBuildSExt);
        break;
    case extu_i32_i64:
        translate_ext(opc, u, LLVMBuildZExt);
        break;
    case movcond_i32:
    case movcond_i64:
    case movcond_vec:
        translate_movcond(opc, u);
        break;
    case mul_i32:
    case mul_i64:
    case mul_vec:
        translate_binary(opc, u, LLVMBuildMul);
        break;
    case mulsh_i32:
    case mulsh_i64:
        translate_mulxh(opc, u, LLVMBuildSExt);
        break;
    case muluh_i32:
    case muluh_i64:
        translate_mulxh(opc, u, LLVMBuildZExt);
        break;
    case muls2_i32:
    case muls2_i64:
        translate_muls2(opc, u);
        break;
    case mulu2_i32:
    case mulu2_i64:
        translate_mulu2(opc, u);
        break;
    case neg_i32:
    case neg_i64:
    case neg_vec:
        translate_neg(opc, u);
        break;
    case negsetcond_i32:
    case negsetcond_i64:
        translate_negsetcond(opc, u);
        break;
    case not_i32:
    case not_i64:
    case not_vec:
        translate_not(opc, u);
        break;
    case or_i32:
    case or_i64:
        translate_binary(opc, u, LLVMBuildOr);
        break;
    case or_vec:
        translate_binary(opc, u, LLVMBuildOr);
        break;
    case ld8u_i32:
    case ld8u_i64:
    case ld16u_i32:
    case ld16u_i64:
    case ld32u_i64:
        translate_ld_ext(opc, u, LLVMBuildZExt);
        break;
    case ld8s_i32:
    case ld8s_i64:
    case ld16s_i32:
    case ld16s_i64:
    case ld32s_i64:
        translate_ld_ext(opc, u, LLVMBuildSExt);
        break;
    case ld_vec:
        translate_ld_vec(opc, u);
        break;
    case ld_i32:
    case ld_i64:
        translate_ld_env_xmm(opc, u);
        break;
    case qemu_ld2_i128:
        translate_qemu_ld2_i128(opc, u);
        break;
    case qemu_ld_i32:
    case qemu_ld_i64:
        translate_qemu_ld(opc, u);
        break;
    case qemu_st2_i128:
        translate_qemu_st2_i128(opc, u);
        break;
    case qemu_st_i32:
    case qemu_st_i64:
        translate_qemu_st(opc, u);
        break;
    case st8_i32:
    case st8_i64:
    case st16_i32:
    case st16_i64:
    case st32_i64:
    case st_i32:
    case st_i64:
        translate_st(opc, u);
        break;
    case st_vec:
        translate_st_vec(opc, u);
        break;
    case rotr_i32:
    case rotr_i64:
        translate_rotr(opc, u);
        break;
    case rotl_i32:
    case rotl_i64:
        translate_rotl(opc, u);
        break;
    case sar_i32:
    case sar_i64:
        translate_binary(opc, u, LLVMBuildAShr);
        break;
    case setcond_i32:
    case setcond_i64:
        translate_setcond(opc, u);
        break;
    case sextract_i32:
    case sextract_i64:
        translate_sextract(opc, u);
        break;
    case shl_i32:
    case shl_i64:
        translate_binary(opc, u, LLVMBuildShl);
        break;
    case shli_vec:
    case shls_vec:
        translate_binary_splat_immediate(opc, u, LLVMBuildShl);
        break;
    case shri_vec:
    case shrs_vec:
        translate_binary_splat_immediate(opc, u, LLVMBuildLShr);
        break;
    case shr_i32:
    case shr_i64:
        translate_binary(opc, u, LLVMBuildLShr);
        break;
    case sub_i32:
    case sub_i64:
        translate_binary(opc, u, LLVMBuildSub);
        break;
    case sub_vec:
        translate_binary(opc, u, LLVMBuildSub);
        break;
    case umax_vec:
        translate_maxmin_vec(opc, u, gtu);
        break;
    case umin_vec:
        translate_maxmin_vec(opc, u, ltu);
        break;
    case xor_i32:
    case xor_i64:
    case xor_vec:
        translate_binary(opc, u, LLVMBuildXor);
        break;
    case set_label:
        translate_set_label(opc, u);
        break;
    case brcond_i64:
        translate_brcond_i64(opc, u);
        break;
    case jmp_direct:
        translate_jmp_direct(opc, u);
        break;
    case discard:
        translate_discard(opc, u);
        break;
    case call:
        translate_call(opc, u);
        break;
    case br:
        translate_br(opc, u);
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
        "cc_src", "cc_dst", "cc_op", "rip"
    };
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
    llvm_int_types[LLVMVector8xi8] = LLVMScalableVectorType(LLVMInt8Type(), 8);
    llvm_int_types[LLVMVector4xi16] = LLVMScalableVectorType(LLVMInt16Type(), 4);
    llvm_int_types[LLVMVector2xi32] = LLVMScalableVectorType(LLVMInt32Type(), 2);
    llvm_int_types[LLVMVector1xi64] = LLVMScalableVectorType(LLVMInt64Type(), 1);
    llvm_int_store_types[LLVMVector8xi8] = LLVMVectorType(LLVMInt8Type(), 8);
    llvm_int_store_types[LLVMVector4xi16] = LLVMVectorType(LLVMInt16Type(), 4);
    llvm_int_store_types[LLVMVector2xi32] = LLVMVectorType(LLVMInt32Type(), 2);
    llvm_int_store_types[LLVMVector1xi64] = LLVMVectorType(LLVMInt64Type(), 1);

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

    helper_str[helper_memset] = "memset";
    dummy_slot_for_debug.s.valid = 0;

    /*
     * The purpose of shadow_map is to speedup indirect branch lookup.
     * We will create a large array to cover the x64 ELF text section space, those
     * mapping info will be inserted into this array, and there will be an auxiliary bit
     * array to verify the sanity of those information. The auxiliary bit array will
     * be created by runtime.
     *
     * Structure of shadow_map:
     * x64 ELF exec address start
     * x64 ELF exec address end
     * Host AOT exec start
     * Pointer to the auxiliary bit array
     * Counter for jmp_ind_callback - total
     * Counter for jmp_ind_callback - out-of-range
     * Counter for jmp_ind_callback - invalid_aot1
     * Counter for jmp_ind_callback - invalid_aot2
     * Counter for jmp_ind_callback - collide
     * Counter for jmp_ind_callback - duplicated
     * Counter for jmp_ind_callback - hit
     * Counter for jmp_ind_callback - sample1
     * Counter for jmp_ind_callback - sample2
     * Counter for helper_jmp_ind - total
     * Counter for helper_jmp_ind - out-of-range
     * Counter for helper_jmp_ind - empty
     * Counter for helper_jmp_ind - invalid_aot
     * Counter for helper_jmp_ind - hit
     * Byte array (size: (<x64 ELF exec address end> - <x64 ELF exec address start> + 4) padded to align with 8B)
     */
    if (tcg_ir_head) {
        char shadow_map_name[64] = {0};
        sprintf(shadow_map_name, "%s%sshadow_map", func_name_prefix, func_name_prefix[0] ? "_" : "");
#ifdef LARGE_SHADOW_MAP
        size_t sz = 8 * (4 + 14) + (x64_exec_end * 8);
#else
        size_t sz = 8 * (4 + 14) + (((x64_exec_end + 4) % 8) ? ((((x64_exec_end + 4) >> 3) + 1) << 3) : (x64_exec_end + 4));
#endif
        create_reference_to_external_array(module, shadow_map_name, sz);

        // FIXME: initialize x64_exec_end info properly!
        LLVMValueRef ro_var = LLVMAddGlobal(module, LLVMInt64Type(), "x64_exec_end");
        LLVMSetGlobalConstant(ro_var, 1);
        LLVMSetSection(ro_var, ".rodata");
        LLVMValueRef init = LLVMConstInt(LLVMInt64Type(), x64_exec_end, 0);
        LLVMSetInitializer(ro_var, init);
    }
}

int check_always_inline_status(LLVMModuleRef module, const char *target_func) {
    LLVMValueRef func = LLVMGetNamedFunction(module, target_func);
    if (!func) {
        printf("Function '%s' not found - may be completely inlined\n", target_func);
        return 1;
    }
    LLVMAttributeRef attr = LLVMGetEnumAttributeAtIndex(func, -1, LLVMAlwaysInlineAttribute);
    if (!attr) {
        return 0;
    }
    LLVMUseRef use = LLVMGetFirstUse(func);
    if (!use) {
        printf("Function '%s' with always_inline has no calls - likely inlined\n", target_func);
        return 1;
    } else {
        return 0;
    }
}

void module_epilog() {
#ifdef DUMP_IR
    LLVMDumpModule(module);
#endif
    LLVMValueRef function = LLVMGetFirstFunction(module);
    while (function != NULL) {
        if (LLVMIsAFunction(function)) {
            if (LLVMIsDeclaration(function) && strstr(LLVMGetValueName(function), "func_")) {
                LLVMSetSection(function, ".text.declare_only");
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
    /*
    char search_name[64] = {0};
    sprintf(search_name, "%s%sfunc_", func_name_prefix, func_name_prefix[0] ? "_" : "");
    */
    while (currentFunction != NULL) {
        const char* funcName = LLVMGetValueName(currentFunction);
        LLVMValueRef deleteCandidate = NULL;
        //if (strstr(funcName, "helper_") && (strstr(funcName, "_xmm_") || strstr(funcName, "_inband") || strstr(funcName, "_outband"))) {
        if (strstr(funcName, "helper_") && strstr(funcName, "_inband")) {
            deleteCandidate = currentFunction;
        /*
        } else if (strstr(funcName, search_name)) {
            if (LLVMGetLinkage(currentFunction) == LLVMInternalLinkage) {
                deleteCandidate = currentFunction;
            }
        */
        }
        if (!deleteCandidate) {
            if (check_always_inline_status(module, funcName)) {
                deleteCandidate = currentFunction;
            }
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
    LLVMDisposeModule(module);
}

void parse_tcg_instructions(const char *filename) {
    FILE *source_file = fopen(filename, "r");
    if (!source_file) {
        perror("Error opening source file");
        return;
    }

    TcgContext ctx;
    tcg_context_init(&ctx);
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
    if (argc < 3) {
        printf("Usage: ./app <tcg-ir> <x64 exec END in hex> <func_name_prefix>\n");
        return -1;
    }
    // Get the path for helper_templates
    char *p = realpath(argv[0], template_path);
    assert(p);
    while (strstr(p, "/") != NULL) {
        p = strstr(p, "/");
        if (*p == '/') {
            p += 1;
        }
    }
    assert((p - template_path) < PATH_MAX);
    *p = '\0';

    if (argc >= 4) {
        assert(strlen(argv[3]) <= (sizeof(func_name_prefix)-1));
        strcpy(func_name_prefix, argv[3]);
    }
    if (strstr(argv[1], "0.tcg.ir") == argv[1] ||
        strstr(argv[1], "/0.tcg.ir")) {
        tcg_ir_head = 1;
    }
    p = realpath(argv[1], input_path);
    assert(p);
    sprintf(output_file, "%s.o", input_path);
    sprintf(list_file, "%s.text.list", input_path);
    init_list_file(list_file);
    // Get output path
    p = realpath(argv[1], output_path);
    assert(p);
    while (strstr(p, "/") != NULL) {
        p = strstr(p, "/");
        if (*p == '/') {
            p += 1;
        }
    }
    assert((p - output_path) < PATH_MAX);
    *p = '\0';
    x64_exec_end = strtoll(argv[2], NULL, 16);

    // Now change directory
    chdir(template_path);

    int rc = setenv("LLVM_ENABLE_AOT_STACK_SWITCH", "1", 1);
    assert(rc == 0);
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

    LLVMTargetRef target;
    if (LLVMGetTargetFromTriple(default_triple, &target, &error_msg)) {
        printf("Failed to get target from triple %s\n", error_msg);
        return -1;
    }
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    const char* features = "+neon";
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    //const char* features = "+m,+a,+f,+d,+v,+unaligned-scalar-mem,+unaligned-vector-mem";
    const char* features = "+m,+a,+f,+d,+v";
#endif
    target_machine = LLVMCreateTargetMachine(target, default_triple, "generic", features,
                                             LLVMCodeGenLevelDefault, LLVMRelocPIC, LLVMCodeModelDefault);

    module_prolog();
    parse_tcg_instructions(input_path);
    module_epilog();
    fini_list_file();
    return 0;
}
