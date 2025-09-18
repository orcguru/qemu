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
#include <llvm-c/Types.h>
#include <llvm-c/Target.h>
#include <llvm-c/TargetMachine.h>
#include <llvm-c/Transforms/PassBuilder.h>
#include <llvm-c/BitReader.h>
#include <llvm-c/Linker.h>
#include <stdbool.h>

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
static LLVMTypeRef fixed_vector_param_types[FIXED_VECTOR_PARAM_COUNT] = {NULL};
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
#define BB_MAX_CNT  8
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
//#define MAX_FUNC_CNT    0x6000000000UL
#define MAX_FUNC_CNT    100
static uint32_t current_func_cnt = 0;
static uint32_t additional_scalar_arg_cnt = 0;
static uint32_t obj_idx = 0;
#define LLVMNoInlineAttribute       32
#define LLVMAlwaysInlineAttribute   3

typedef LLVMValueRef (*LLVM_BIN_API)(LLVMBuilderRef B, LLVMValueRef LHS, LLVMValueRef RHS, const char *Name);
typedef LLVMValueRef (*LLVM_EXT_API)(LLVMBuilderRef B, LLVMValueRef Val, LLVMTypeRef DestTy, const char *Name);

static void do_store(LLVMValueRef val, LLVMType val_tidx, OperandType out);
static LLVMValueRef get_env_ptr_raw();
static OperandType get_env_ptr();
static OperandType get_shadow_stack_pointer();
static void set_shadow_stack_pointer(OperandType val);
static LLVMBasicBlockRef get_bb(const char *name);
static void handle_single_instr(OpCodeType opc, void *ptr);
static uint8_t can_inline_helper(HelperType h, const char *build_macro, const char *bc_name, const char *helper_func_name);
static uint8_t is_dump_call(HelperType h);
static uint8_t is_tail_call(HelperType h);
static uint8_t is_opc_end_of_control_flow(OpCodeType opc);
static LLVMValueRef get_func_param(int i);
void translate_add_i64(OpCodeType opc, void *ptr);
void translate_andc_i64(OpCodeType opc, void *ptr);
void translate_andc_vec(OpCodeType opc, void *ptr);
void translate_bswap32_i64(OpCodeType opc, void *ptr);
void translate_clz_i64(OpCodeType opc, void *ptr);
void translate_cmp_vec(OpCodeType opc, void *ptr);
void translate_ctz_i64(OpCodeType opc, void *ptr);
void translate_dupm_vec(OpCodeType opc, void *ptr);
void translate_extract2_i64(OpCodeType opc, void *ptr);
void translate_extract(OpCodeType opc, void *ptr);
void translate_ld_vec(OpCodeType opc, void *ptr);
void translate_negsetcond_i64(OpCodeType opc, void *ptr);
void translate_not_i64(OpCodeType opc, void *ptr);
void translate_not_vec(OpCodeType opc, void *ptr);
void translate_push_ret_addr(OpCodeType opc, void *ptr);
void translate_qemu_ld2_i128(OpCodeType opc, void *ptr);
void translate_qemu_ld(OpCodeType opc, void *ptr);
void translate_qemu_st2_i128(OpCodeType opc, void *ptr);
void translate_qemu_st(OpCodeType opc, void *ptr);
void translate_ret(OpCodeType opc, void *ptr);
void translate_rotr(OpCodeType opc, void *ptr);
void translate_rotl(OpCodeType opc, void *ptr);
void translate_setcond_i64(OpCodeType opc, void *ptr);
void translate_sextract_i64(OpCodeType opc, void *ptr);
void translate_st(OpCodeType opc, void *ptr);
void translate_bswap64_i64(OpCodeType opc, void *ptr);
void translate_set_label(OpCodeType opc, void *ptr);
void translate_brcond_i64(OpCodeType opc, void *ptr);
void translate_jmp_direct(OpCodeType opc, void *ptr);
void translate_call_direct(OpCodeType opc, void *ptr);
void translate_discard(OpCodeType opc, void *ptr);
void translate_tail_call(OpCodeType opc, void *ptr);
void translate_dump_call(OpCodeType opc, void *ptr, uint32_t is_dump_registers);
void translate_call(OpCodeType opc, void *ptr);
void translate_ld_env_xmm(OpCodeType opc, void *ptr);
void translate_movcond(OpCodeType opc, void *ptr);
void translate_mulxh(OpCodeType opc, void *ptr, LLVM_EXT_API api);

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

#define GET_STORAGE_ATTR()                                      \
    do {                                                        \
        a0.p.storage.attr.atomic = attr.attr_val >> 6;          \
        a1.p.storage.attr.alignment = (attr.attr_val >> 4) & 0x3;   \
        a2.p.storage.attr.ext = (attr.attr_val >> 3) & 0x1;     \
        a2.p.storage.size = attr.attr_val & 0x7;                \
    } while (0)

#define OPC_INPUT_T         opciosz[opc][0]
#define OPC_EFFECTIVE_T     opciosz[opc][1]
#define OPC_OUTPUT_T        opciosz[opc][2]
#define OPC_ADDR_T          LLVMInt64

static uint8_t is_opc_end_of_control_flow(OpCodeType opc) {
    if (opc == jmp_direct || opc == call_direct || opc == ret) {
        return 1;
    }
    return 0;
}

static LLVMValueRef get_func_param(int i) {
    if (i < FIXED_PARAM_COUNT) {
        return LLVMGetParam(llvm_func, i);
    } else {
        return LLVMGetParam(llvm_func, i + additional_scalar_arg_cnt);
    }
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

static const char *get_next_var_name() {
    assert(ir_var_name_idx < sizeof(ir_var_name)/sizeof(const char *));
    return ir_var_name[ir_var_name_idx++];
}

static OperandType get_shadow_stack_pointer() {
    uint8_t buf[16];
    OperandType ptr_addr = get_tmp_and_do_alloc(LLVMInt64);
    OperandType env = get_env_ptr();
    create_scalar_slot2_imm(buf, add_i64, ptr_addr, env, -8UL);
    translate_add_i64(add_i64, buf);
    OperandType ptr_val = get_tmp_and_do_alloc(LLVMInt64);

    AttrSrcInfo a0, a1, a2;
    a0.subt = SUB_ATTR_ATOMIC;
    a0.p.storage.attr.atomic = NONATOMIC;
    a1.subt = SUB_ATTR_ALIGNMENT;
    a1.p.storage.attr.alignment = ALIGN_MEM_SIZE;
    a2.subt = SUB_ATTR_SRCSIZEEXT;
    a2.p.storage.attr.ext = ZERO;
    a2.p.storage.size = SRC8B;

    create_scalar_slot2_attr3_num(buf, qemu_ld_i64, ptr_val, ptr_addr, a0, a1, a2, 2);
    translate_qemu_ld(qemu_ld_i64, buf);
    return ptr_val;
}

static void set_shadow_stack_pointer(OperandType val) {
    uint8_t buf[16];
    OperandType ptr_addr = get_tmp_and_do_alloc(LLVMInt64);
    OperandType env = get_env_ptr();
    create_scalar_slot2_imm(buf, add_i64, ptr_addr, env, -8UL);
    translate_add_i64(add_i64, buf);

    AttrSrcInfo a0, a1, a2;
    a0.subt = SUB_ATTR_ATOMIC;
    a0.p.storage.attr.atomic = NONATOMIC;
    a1.subt = SUB_ATTR_ALIGNMENT;
    a1.p.storage.attr.alignment = ALIGN_MEM_SIZE;
    a2.subt = SUB_ATTR_SRCSIZEEXT;
    a2.p.storage.attr.ext = ZERO;
    a2.p.storage.size = SRC8B;

    create_scalar_slot2_attr3_num(buf, qemu_st_i64, val, ptr_addr, a0, a1, a2, 2);
    translate_qemu_st(qemu_st_i64, buf);
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
    LLVMTypeRef asm_return_type = LLVMInt64Type();
    LLVMTypeRef asm_param_types[] = {};
    LLVMTypeRef asm_function_type = LLVMFunctionType(asm_return_type, asm_param_types, 0, 0);
    //FIXME: handle AArch64 as well
    char asm_string[128];
    sprintf(asm_string, "mv $0, x25");
    const char *constraint_string = "=r";
    LLVMValueRef inline_asm = LLVMConstInlineAsm(asm_function_type, asm_string, constraint_string, /* has_side_effects */ 1, /* is_align_stack */ 0);
    return LLVMBuildCall2(builder, asm_function_type, inline_asm, NULL, 0, get_next_var_name());
}

static OperandType get_env_ptr() {
    OperandType tmp = get_tmp_and_do_alloc(LLVMInt64);
    LLVMValueRef val = get_env_ptr_raw();
    do_store(val, LLVMInt64, tmp);
    return tmp;
}

static void do_store(LLVMValueRef val, LLVMType val_tidx, OperandType out) {
    assert(val_tidx != LLVMInvalidType && val_tidx < LLVMMAXType);
    LLVMTypeRef val_type = llvm_int_types[val_tidx];
    if (out.s.slot_type == SUB_SLOT_ENVVAR) {
        OperandType tmp = get_tmp_and_do_alloc(LLVMInt64);
        OperandType env = get_env_ptr();
        uint8_t buf[16];
        create_scalar_slot2_imm(buf, add_i64, tmp, env, env_var_offset[out.s.slot_idx]);
        translate_add_i64(add_i64, buf);
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
            LLVMValueRef index = LLVMConstInt(LLVMInt64Type(), (out.s.offset * 8) / llvm_vector_elem_bit_counts[val_tidx*2+1], 0);
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

static LLVMValueRef get_source_node_imm_or_stack(uint32_t is_imm, OperandType operand, LLVMType tidx) {
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
        OperandType tmp = get_tmp_and_do_alloc(LLVMInt64);
        OperandType env = get_env_ptr();
        uint8_t buf[16];
        create_scalar_slot2_imm(buf, add_i64, tmp, env, env_var_offset[operand.s.slot_idx]);
        translate_add_i64(add_i64, buf);
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, func_tmp_alloca[tmp.s.slot_idx], LLVMPointerType(type, 0), get_next_var_name());
        ret = LLVMBuildLoad2(builder, type, ptr, get_next_var_name());
    } else if (operand.s.slot_type == SUB_SLOT_ENV) {
        OperandType tmp = get_tmp_and_do_alloc(LLVMInt64);
        OperandType env = get_env_ptr();
        uint8_t buf[16];
        create_scalar_slot2_imm(buf, add_i64, tmp, env, operand.s.offset);
        translate_add_i64(add_i64, buf);
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
            LLVMValueRef index = LLVMConstInt(LLVMInt64Type(), elem_idx, 0);
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
    LLVMValueRef left = get_source_node_imm_or_stack(is_imm_l, operand_l, is_vec ? vtype : OPC_INPUT_T);
    LLVMValueRef right = get_source_node_imm_or_stack(is_imm_r, operand_r, is_vec ? vtype : OPC_INPUT_T);
    LLVMValueRef out_val = api(builder, left, right, get_next_var_name());
    do_store(out_val, OPC_OUTPUT_T, output);
}

void translate_add_i64(OpCodeType opc, void *ptr) {
    uint32_t is_imm_l, is_imm_r, is_imm_out;
    OperandType operand_l, operand_r, output;
    uint32_t idx = opcoc[opc];
    output = get_operand(ptr, 0, &is_imm_out);
    assert(!is_imm_out && output.s.valid);
    operand_l = get_operand(ptr, idx, &is_imm_l);
    assert(!is_imm_l && operand_l.s.valid);
    operand_r = get_operand(ptr, idx + 1, &is_imm_r);
    if (!operand_r.s.valid && !is_imm_r) {
        assert(operand_l.s.slot_type == SUB_SLOT_XMM ||
               operand_l.s.slot_type == SUB_SLOT_ENV);
        register_alias(output, operand_l);
    } else {
        if (is_imm_r && operand_l.s.slot_type == SUB_SLOT_TMP && has_alias(operand_l)) {
            OperandType alias = get_alias(operand_l);
            alias.s.offset += operand_r.i;
            register_alias(output, alias);
        } else {
            LLVMValueRef left = get_source_node_imm_or_stack(is_imm_l, operand_l, OPC_INPUT_T);
            LLVMValueRef right = get_source_node_imm_or_stack(is_imm_r, operand_r, OPC_INPUT_T);
            LLVMValueRef add_val = LLVMBuildAdd(builder, left, right, get_next_var_name());
            do_store(add_val, OPC_OUTPUT_T, output);
        }
    }
}

void translate_andc_i64(OpCodeType opc, void *ptr) {
    OperandType tmp = get_tmp_and_do_alloc(LLVMInt64);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    uint8_t buf[16];
    create_scalar_slot2(buf, not_i64, tmp, operand2);
    translate_not_i64(not_i64, buf);

    create_scalar_slot3(buf, and_i64, operand0, operand1, tmp);
    translate_binary(and_i64, buf, LLVMBuildAnd);
}

void translate_andc_vec(OpCodeType opc, void *ptr) {
    OperandType tmp = get_tmp_and_do_alloc(LLVMVector16xi8);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    AttrSrcInfo ai;
    ai.p.ves = get_llvm_vector_type(ptr) - LLVMVector16xi8;

    uint8_t buf[16];
    create_vector_slot2(buf, not_vec, ai, tmp, operand2);
    translate_not_vec(not_vec, buf);

    create_vector_slot3(buf, and_vec, ai, operand0, operand1, tmp);
    translate_binary(and_vec, buf, LLVMBuildAnd);
}

void translate_bswap32_i64(OpCodeType opc, void *ptr) {
    OperandType tmp0 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType tmp1 = get_tmp_and_do_alloc(LLVMInt64);
    uint32_t constant_t2 = 0x00ff00ff;

    OperandType operand0, operand1;
    GET_2_OPERANDS();

    uint8_t buf[16];
    create_scalar_slot2_imm(buf, shr_i64, tmp0, operand1, 8);
    translate_binary(shr_i64, buf, LLVMBuildLShr);
    create_scalar_slot2_imm(buf, and_i64, tmp1, operand1, constant_t2);
    translate_binary(and_i64, buf, LLVMBuildAnd);
    create_scalar_slot2_imm(buf, and_i64, tmp0, tmp0, constant_t2);
    translate_binary(and_i64, buf, LLVMBuildAnd);
    create_scalar_slot2_imm(buf, shl_i64, tmp1, tmp1, 8);
    translate_binary(shl_i64, buf, LLVMBuildShl);
    create_scalar_slot3(buf, or_i64, operand0, tmp0, tmp1);
    translate_binary(or_i64, buf, LLVMBuildOr);
    create_scalar_slot2_imm(buf, shl_i64, tmp1, operand0, 48);
    translate_binary(shl_i64, buf, LLVMBuildShl);
    create_scalar_slot2_imm(buf, shl_i64, tmp0, operand0, 16);
    translate_binary(shl_i64, buf, LLVMBuildShl);

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_SWAP);
    if (attr.attr_val & OS) {
        create_scalar_slot2_imm(buf, sar_i64, tmp1, tmp1, 32);
        translate_binary(sar_i64, buf, LLVMBuildAShr);
    } else {
        create_scalar_slot2_imm(buf, shr_i64, tmp1, tmp1, 32);
        translate_binary(shr_i64, buf, LLVMBuildLShr);
    }
    create_scalar_slot3(buf, or_i64, operand0, tmp0, tmp1);
    translate_binary(or_i64, buf, LLVMBuildOr);
}

void translate_cmp_vec(OpCodeType opc, void *ptr) {
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();
    LLVMType vtype = get_llvm_vector_type(ptr);

    LLVMValueRef src1 = get_source_node_imm_or_stack(is_imm1, operand1, vtype);
    LLVMValueRef src2 = get_source_node_imm_or_stack(is_imm2, operand2, vtype);

    RelopType r = get_relop(ptr);
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_vec = LLVMBuildICmp(builder, llvm_predicate[r], src1, src2, get_next_var_name());

    OperandType ones, zeros;
    ones.i = 0xffffffffffffffffUL;
    zeros.i = 0;

    LLVMValueRef vec_true = get_source_node_imm_or_stack(1, ones, vtype);
    LLVMValueRef vec_false = get_source_node_imm_or_stack(1, zeros, vtype);

    LLVMValueRef result = LLVMBuildSelect(builder, bool_vec, vec_true, vec_false, get_next_var_name());
    do_store(result, OPC_OUTPUT_T, operand0);
}

void translate_count_zero(OpCodeType opc, void *ptr, const char *intrinsic) {
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef src1 = get_source_node_imm_or_stack(is_imm1, operand1, OPC_INPUT_T);
    LLVMValueRef src2 = get_source_node_imm_or_stack(is_imm2, operand2, OPC_INPUT_T);

    LLVMValueRef bool1 = LLVMBuildICmp(builder, LLVMIntEQ, src1, LLVMConstInt(llvm_int_types[LLVMInt64], 0, 0), get_next_var_name());

    LLVMBasicBlockRef bb_ctz_is_zero = LLVMAppendBasicBlock(llvm_func, get_next_var_name());
    LLVMBasicBlockRef bb_ctz_not_zero = LLVMAppendBasicBlock(llvm_func, get_next_var_name());
    LLVMBasicBlockRef bb_ctz_merge = LLVMAppendBasicBlock(llvm_func, get_next_var_name());

    LLVMBuildCondBr(builder, bool1, bb_ctz_is_zero, bb_ctz_not_zero);
    LLVMPositionBuilderAtEnd(builder, bb_ctz_is_zero);
    LLVMBuildBr(builder, bb_ctz_merge);

    LLVMTypeRef ctz_arg_types[] = {llvm_int_types[LLVMInt64], LLVMInt1Type()};
    LLVMTypeRef ctz_type = LLVMFunctionType(llvm_int_types[LLVMInt64], ctz_arg_types, 2, 0);
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
    LLVMValueRef phi = LLVMBuildPhi(builder, llvm_int_types[LLVMInt64], get_next_var_name());
    LLVMValueRef phi_incoming_values[] = {src2, call_result};
    LLVMBasicBlockRef phi_incoming_blocks[] = {bb_ctz_is_zero, bb_ctz_not_zero};
    LLVMAddIncoming(phi, phi_incoming_values, phi_incoming_blocks, 2);
    do_store(phi, OPC_OUTPUT_T, operand0);
}

void translate_clz_i64(OpCodeType opc, void *ptr) {
    translate_count_zero(opc, ptr, "llvm.ctlz.i64");
}

void translate_ctz_i64(OpCodeType opc, void *ptr) {
    translate_count_zero(opc, ptr, "llvm.cttz.i64");
}

void translate_deposit(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1, operand2, ofs, len;
    GET_3_OPERANDS();
    uint32_t is_imm3, is_imm4;
    ofs = get_operand(ptr, 3, &is_imm3);
    len = get_operand(ptr, 4, &is_imm4);
    assert(is_imm3 && is_imm4);

    uint8_t buf[16];
    OpCodeType tmp_opc;
    // shl
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? shl_i64 : shl_i32;
    OperandType mask1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    create_slot_imm2(buf, tmp_opc, mask1, 1, len.i);
    translate_binary(tmp_opc, buf, LLVMBuildShl);
    // sub
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? sub_i64 : sub_i32;
    OperandType mask_not_shifted = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    create_scalar_slot2_imm(buf, tmp_opc, mask_not_shifted, mask1, 1);
    translate_binary(tmp_opc, buf, LLVMBuildSub);
    // shl
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? shl_i64 : shl_i32;
    OperandType mask_shifted = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    create_scalar_slot2_imm(buf, tmp_opc, mask_shifted, mask_not_shifted, ofs.i);
    translate_binary(tmp_opc, buf, LLVMBuildShl);
    // xor
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? xor_i64 : xor_i32;
    OperandType rev_mask_shifted = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    create_scalar_slot2_imm(buf, tmp_opc, rev_mask_shifted, mask_shifted, -1UL);
    translate_binary(tmp_opc, buf, LLVMBuildXor);
    // and
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? and_i64 : and_i32;
    OperandType part1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    create_scalar_slot3(buf, tmp_opc, part1, operand1, rev_mask_shifted);
    translate_binary(tmp_opc, buf, LLVMBuildAnd);
    // and
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? and_i64 : and_i32;
    OperandType part2_0 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    create_scalar_slot3(buf, tmp_opc, part2_0, operand2, mask_not_shifted);
    translate_binary(tmp_opc, buf, LLVMBuildAnd);
    // shl
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? shl_i64 : shl_i32;
    OperandType part2_1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    create_scalar_slot2_imm(buf, tmp_opc, part2_1, part2_0, ofs.i);
    translate_binary(tmp_opc, buf, LLVMBuildShl);
    // or
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? or_i64 : or_i32;
    create_scalar_slot3(buf, tmp_opc, operand0, part1, part2_1);
    translate_binary(tmp_opc, buf, LLVMBuildOr);
}

void translate_dupm_vec(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    LLVMType vtype = get_llvm_vector_type(ptr);
    LLVMValueRef src = get_source_node_imm_or_stack(0, operand1, vtype);
    LLVMValueRef index = LLVMConstInt(LLVMInt64Type(), 0, 0);
    LLVMValueRef elem = LLVMBuildExtractElement(builder, src, index, get_next_var_name());
    uint8_t full_cnt = llvm_vector_elem_bit_counts[vtype*2];
    uint8_t bit_cnt = llvm_vector_elem_bit_counts[vtype*2+1];
    LLVMValueRef constants[16];
    LLVMValueRef element_value = LLVMConstInt(llvm_int_types[vtype - 4], 0, 0);
    for (int i = 0; i < full_cnt; i++) {
        constants[i] = element_value;
    }
    LLVMValueRef result = LLVMConstVector(constants, full_cnt);
    for (int i = 0; i < full_cnt; i++) {
        index = LLVMConstInt(LLVMInt64Type(), i, 0);
        result = LLVMBuildInsertElement(builder, result, element_value, index, get_next_var_name());
    }
    do_store(result, OPC_OUTPUT_T, operand0);
}

/*
  # INDEX_op_extract2_i64, ret, al, ah, ofs
  # TCGv_i64 t0 = tcg_temp_ebb_new_i64();
  # tcg_gen_shri_i64(t0, al, ofs);
  # tcg_gen_deposit_i64(ret, t0, ah, 64 - ofs, ofs);
*/
void translate_extract2_i64(OpCodeType opc, void *ptr) {
    OperandType tmp = get_tmp_and_do_alloc(LLVMInt64);
    OperandType operand0, operand1, operand2, ofs;
    GET_3_OPERANDS();
    uint32_t is_imm;
    ofs = get_operand(ptr, 3, &is_imm);
    assert(is_imm);

    uint8_t buf[16];
    create_scalar_slot2_imm(buf, shr_i64, tmp, operand1, ofs.i);
    translate_binary(shr_i64, buf, LLVMBuildLShr);
    create_scalar_slot3_imm2(buf, deposit_i64, operand0, tmp, operand2, (64 - ofs.i), ofs.i);
    translate_deposit(deposit_i64, buf);
}

void translate_extract(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1, ofs, len;
    GET_2_OPERANDS();
    uint32_t is_imm2, is_imm3;
    ofs = get_operand(ptr, 2, &is_imm2);
    len = get_operand(ptr, 3, &is_imm3);
    assert(is_imm2 && is_imm3);

    uint8_t buf[16];
    OpCodeType tmp_opc;
    // shl
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? shl_i64 : shl_i32;
    OperandType mask1 = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    create_slot_imm2(buf, tmp_opc, mask1, 1, len.i);
    translate_binary(tmp_opc, buf, LLVMBuildShl);
    // sub
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? sub_i64 : sub_i32;
    OperandType mask_not_shifted = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    create_scalar_slot2_imm(buf, tmp_opc, mask_not_shifted, mask1, 1);
    translate_binary(tmp_opc, buf, LLVMBuildSub);
    // shr
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? shr_i64 : shr_i32;
    OperandType arg_shifted = get_tmp_and_do_alloc(OPC_OUTPUT_T);
    create_scalar_slot2_imm(buf, tmp_opc, arg_shifted, operand1, ofs.i);
    translate_binary(tmp_opc, buf, LLVMBuildLShr);
    // and
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? and_i64 : and_i32;
    create_scalar_slot3(buf, tmp_opc, operand0, arg_shifted, mask_not_shifted);
    translate_binary(tmp_opc, buf, LLVMBuildAnd);
}

void translate_mov(OpCodeType opc, void *ptr) {
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
        LLVMValueRef src = get_source_node_imm_or_stack(is_imm1, operand1, is_vec ? vtype : OPC_INPUT_T);
        if (OPC_EFFECTIVE_T < OPC_INPUT_T) {
            src = LLVMBuildTrunc(builder, src, llvm_int_types[OPC_EFFECTIVE_T], get_next_var_name());
        }
        do_store(src, is_vec ? vtype : OPC_OUTPUT_T, operand0);
    }
}

void translate_ld_env_xmm(OpCodeType opc, void *ptr) {
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
        uint8_t buf[16];
        create_scalar_slot_env_imm(buf, opc, operand0, get_xmm_offset(alias.s.slot_idx/2) + 16*(alias.s.slot_idx%2) + alias.s.offset);
        translate_ld_env_xmm(opc, buf);
    }
}

void translate_ext(OpCodeType opc, void *ptr, LLVM_EXT_API api) {
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();

    LLVMValueRef src = get_source_node_imm_or_stack(is_imm1, operand1, OPC_INPUT_T);
    src = api(builder, src, llvm_int_types[OPC_OUTPUT_T], get_next_var_name());
    do_store(src, OPC_OUTPUT_T, operand0);
}

void translate_ld_vec(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    LLVMType vtype = get_llvm_vector_type(ptr);
    LLVMValueRef src = get_source_node_imm_or_stack(0, operand1, vtype);
    do_store(src, vtype, operand0);
}

void translate_movcond(OpCodeType opc, void *ptr) {
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

    LLVMValueRef c1 = get_source_node_imm_or_stack(is_imm1, operand1, is_vec ? vtype : OPC_INPUT_T);
    LLVMValueRef c2 = get_source_node_imm_or_stack(is_imm2, operand2, is_vec ? vtype : OPC_INPUT_T);
    LLVMValueRef v1 = get_source_node_imm_or_stack(is_imm3, operand3, is_vec ? vtype : OPC_INPUT_T);
    LLVMValueRef v2 = get_source_node_imm_or_stack(is_imm4, operand4, is_vec ? vtype : OPC_INPUT_T);

    RelopType r = get_relop(ptr);
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        OperandType tmp = get_tmp_and_do_alloc(LLVMInt64);
        c1 = LLVMBuildAnd(builder, c1, c2, get_next_var_name());
        c2 = LLVMConstInt(llvm_int_types[is_vec ? vtype : OPC_INPUT_T], 0, 0);
    }
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], c1, c2, get_next_var_name());

    LLVMValueRef result = LLVMBuildSelect(builder, bool_val, v1, v2, get_next_var_name());
    do_store(result, is_vec ? vtype : OPC_OUTPUT_T, operand0);
}

void translate_mulxh(OpCodeType opc, void *ptr, LLVM_EXT_API api) {
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    LLVMTypeRef t128 = LLVMInt128Type();

    LLVMValueRef src1 = get_source_node_imm_or_stack(0, operand1, OPC_INPUT_T);
    LLVMValueRef src2 = get_source_node_imm_or_stack(0, operand2, OPC_INPUT_T);
    src1 = api(builder, src1, t128, get_next_var_name());
    src2 = api(builder, src2, t128, get_next_var_name());
    LLVMValueRef out = LLVMBuildMul(builder, src1, src2, get_next_var_name());
    LLVMValueRef shift = LLVMConstInt(t128, 64, 0);
    out = LLVMBuildLShr(builder, out, shift, get_next_var_name());
    out = LLVMBuildTrunc(builder, out, llvm_int_types[OPC_OUTPUT_T], get_next_var_name());
    do_store(out, OPC_OUTPUT_T, operand0);
}

void translate_neg(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    LLVMValueRef src = get_source_node_imm_or_stack(0, operand1, OPC_INPUT_T);
    LLVMValueRef zero = LLVMConstInt(llvm_int_types[OPC_INPUT_T], 0, 0);
    LLVMValueRef out = LLVMBuildSub(builder, zero, src, get_next_var_name());
    do_store(out, OPC_OUTPUT_T, operand0);
}

void translate_negsetcond_i64(OpCodeType opc, void *ptr) {
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef arg1 = get_source_node_imm_or_stack(is_imm1, operand1, OPC_INPUT_T);
    LLVMValueRef arg2 = get_source_node_imm_or_stack(is_imm2, operand2, OPC_INPUT_T);

    RelopType r = get_relop(ptr);
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], arg1, arg2, get_next_var_name());

    LLVMValueRef result = LLVMBuildSExt(builder, bool_val, llvm_int_types[OPC_OUTPUT_T], get_next_var_name());
    LLVMValueRef neg_one = LLVMConstInt(llvm_int_types[OPC_INPUT_T], -1UL, 0);
    result = LLVMBuildXor(builder, result, neg_one, get_next_var_name());
    do_store(result, OPC_OUTPUT_T, operand0);
}

void translate_not_i64(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    uint8_t buf[16];
    create_scalar_slot2_imm(buf, xor_i64, operand0, operand1, -1UL);
    translate_binary(xor_i64, buf, LLVMBuildXor);
}

void translate_not_vec(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    AttrSrcInfo ai;
    ai.p.ves = get_llvm_vector_type(ptr) - LLVMVector16xi8;
    uint8_t buf[16];
    create_vector_slot2_vimm(buf, xor_vec, ai, operand0, operand1, -1UL);
    translate_binary(xor_vec, buf, LLVMBuildXor);
}

void translate_push_ret_addr(OpCodeType opc, void *ptr) {
    uint32_t is_imm0, is_imm1;
    OperandType operand0, func_hex;
    operand0 = get_operand(ptr, 0, &is_imm0);
    func_hex = get_operand(ptr, 1, &is_imm1);
    assert(is_imm1);

    LLVMValueRef x64_ret_addr = get_source_node_imm_or_stack(is_imm0, operand0, OPC_INPUT_T);
    uint8_t buf[16];
    OperandType ptr_val = get_shadow_stack_pointer();
    create_scalar_slot2_imm(buf, add_i64, ptr_val, ptr_val, -8UL);
    translate_add_i64(add_i64, buf);
    LLVMValueRef shadow_val0 = get_source_node_imm_or_stack(0, ptr_val, OPC_ADDR_T);
    LLVMValueRef shadow_ptr0 = LLVMBuildIntToPtr(builder, shadow_val0, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name());
    LLVMBuildStore(builder, x64_ret_addr, shadow_ptr0);

    char func_name[64] = {0};
    sprintf(func_name, "func_%lx", func_hex.i);
    LLVMValueRef func = LLVMGetNamedFunction(module, func_name);
    if (!func) {
        func = LLVMAddFunction(module, func_name,
                               LLVMFunctionType(LLVMVoidType(), fixed_vector_param_types, FIXED_VECTOR_PARAM_COUNT, 0));
        LLVMAddAttributeAtIndex(func, -1, NoInlineAttr);
        LLVMAddAttributeAtIndex(func, -1, target_features_attr);
    }
    LLVMValueRef func_addr = LLVMBuildPtrToInt(builder, func, LLVMInt64Type(), get_next_var_name());
    create_scalar_slot2_imm(buf, add_i64, ptr_val, ptr_val, -8UL);
    translate_add_i64(add_i64, buf);
    LLVMValueRef shadow_val1 = get_source_node_imm_or_stack(0, ptr_val, OPC_ADDR_T);
    LLVMValueRef shadow_ptr1 = LLVMBuildIntToPtr(builder, shadow_val1, LLVMPointerType(llvm_int_types[OPC_ADDR_T], 0), get_next_var_name());
    LLVMBuildStore(builder, func_addr, shadow_ptr1);

    set_shadow_stack_pointer(ptr_val);
}

void translate_qemu_ld2_i128(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size == SRC16B);
    LLVMType out_type = LLVMVector2xi64;

    LLVMValueRef addr = get_source_node_imm_or_stack(0, operand2, OPC_ADDR_T);
    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[out_type], 0), get_next_var_name());
    LLVMValueRef result = LLVMBuildLoad2(builder, llvm_int_types[out_type], pointer, get_next_var_name());
    if (a1.p.storage.attr.alignment == ALIGN_16 ||
        a1.p.storage.attr.alignment == ALIGN_MEM_SIZE) {
        LLVMSetAlignment(result, 16);
    } else if (a1.p.storage.attr.alignment == ALIGN_32) {
        LLVMSetAlignment(result, 32);
    }
    LLVMValueRef index = LLVMConstInt(LLVMInt64Type(), 0, 0);
    LLVMValueRef elem = LLVMBuildExtractElement(builder, result, index, get_next_var_name());
    do_store(elem, OPC_OUTPUT_T, operand0);
    index = LLVMConstInt(LLVMInt64Type(), 1, 0);
    elem = LLVMBuildExtractElement(builder, result, index, get_next_var_name());
    do_store(elem, OPC_OUTPUT_T, operand1);
}

void translate_qemu_ld(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size <= SRC8B);
    LLVMType out_type = (a2.p.storage.size - SRC1B) + LLVMInt8;
    assert(out_type <= OPC_OUTPUT_T);

    LLVMValueRef addr = get_source_node_imm_or_stack(0, operand1, OPC_ADDR_T);
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
    do_store(result, OPC_OUTPUT_T, operand0);
}

void translate_qemu_st2_i128(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size == SRC16B);
    LLVMType out_type = LLVMVector2xi64;

    LLVMValueRef val0 = get_source_node_imm_or_stack(0, operand0, OPC_INPUT_T);
    LLVMValueRef val1 = get_source_node_imm_or_stack(0, operand1, OPC_INPUT_T);
    LLVMValueRef addr = get_source_node_imm_or_stack(0, operand2, OPC_ADDR_T);
    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(llvm_int_types[out_type], 0), get_next_var_name());

    LLVMValueRef constants[2];
    LLVMValueRef element_value = LLVMConstInt(llvm_int_types[LLVMInt64], 0, 0);
    constants[0] = element_value;
    constants[1] = element_value;
    LLVMValueRef vec = LLVMConstVector(constants, 2);
    LLVMValueRef index = LLVMConstInt(LLVMInt64Type(), 0, 0);
    vec = LLVMBuildInsertElement(builder, vec, val0, index, get_next_var_name());
    index = LLVMConstInt(LLVMInt64Type(), 1, 0);
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
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    AttributeType attr = get_attribute(ptr);
    assert(attr.attr_type == SUB_ATTR_STORAGE);
    AttrSrcInfo a0, a1, a2;
    GET_STORAGE_ATTR();
    assert(a2.p.storage.size <= SRC8B);
    LLVMType out_type = (a2.p.storage.size - SRC1B) + LLVMInt8;
    assert(out_type <= OPC_OUTPUT_T);

    LLVMValueRef val = get_source_node_imm_or_stack(0, operand0, OPC_INPUT_T);
    LLVMValueRef addr = get_source_node_imm_or_stack(0, operand1, OPC_ADDR_T);
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
    uint32_t is_imm;
    OperandType operand0;
    operand0 = get_operand(ptr, 0, &is_imm);
    assert(!is_imm && operand0.s.valid);
    AttrSrcInfo a0, a1, a2;
    a0.subt = SUB_ATTR_ATOMIC;
    a0.p.storage.attr.atomic = NONATOMIC;
    a1.subt = SUB_ATTR_ALIGNMENT;
    a1.p.storage.attr.alignment = ALIGN_MEM_SIZE;
    a2.subt = SUB_ATTR_SRCSIZEEXT;
    a2.p.storage.attr.ext = ZERO;
    a2.p.storage.size = SRC8B;
    OperandType loc606 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType loc607 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType loc608 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType loc609 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType loc610 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType loc611 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType shadow_stack = get_shadow_stack_pointer();
    uint8_t new_label = 42;

    uint8_t buf[16];
    create_scalar_slot2(buf, mov_i64, loc606, shadow_stack);
    translate_mov(mov_i64, buf);
    create_scalar_slot2_imm(buf, add_i64, loc607, loc606, 8);
    translate_add_i64(add_i64, buf);
    create_scalar_slot2_attr3_num(buf, qemu_ld_i64, loc608, loc606, a0, a1, a2, 2);
    translate_qemu_ld(qemu_ld_i64, buf);
    create_scalar_slot2_attr3_num(buf, qemu_ld_i64, loc609, loc607, a0, a1, a2, 2);
    translate_qemu_ld(qemu_ld_i64, buf);
    create_scalar_slot3(buf, sub_i64, loc610, operand0, loc609);
    translate_binary(sub_i64, buf, LLVMBuildSub);
    create_scalar_slot2_imm(buf, add_i64, loc611, loc606, 0x10);
    translate_add_i64(add_i64, buf);
    set_shadow_stack_pointer(loc611);
    create_branch_condition(buf, loc610, 0, ne, new_label);

    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT];
    for (int i = 0; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        if (fixed_vector_param_in_stack[i]) {
            OperandType param_in_stack;
            if (i < FIXED_PARAM_COUNT) {
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XREG;
                param_in_stack.s.slot_idx = i;
                call_args[i] = get_source_node_imm_or_stack(0, param_in_stack, fixed_vector_param_llvmtypes[i]);
            } else {
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XMM;
                param_in_stack.s.slot_idx = i - FIXED_PARAM_COUNT;
                param_in_stack.s.offset = 0;
                LLVMValueRef vec = get_source_node_imm_or_stack(0, param_in_stack, fixed_vector_param_llvmtypes[i]);

                LLVMTypeRef ret_type = LLVMScalableVectorType(LLVMInt64Type(), 1); // <vscale x 1 x i64>
                LLVMTypeRef param_type = LLVMVectorType(LLVMInt64Type(), 2); // <2 x i64>
                LLVMTypeRef intrinsic_types[] = {ret_type, param_type, LLVMInt64Type()};
                LLVMTypeRef intrinsic_func_type = LLVMFunctionType(ret_type, intrinsic_types, 3, 0);
                LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, "llvm.vector.insert.nxv1i64.v2i64");
                if (!intrinsic_func) {
                    intrinsic_func = LLVMAddFunction(module, "llvm.vector.insert.nxv1i64.v2i64", intrinsic_func_type);
                }
                LLVMValueRef index_0 = LLVMConstInt(LLVMInt64Type(), 0, 0);
                LLVMValueRef intrinsic_call_args[] = {LLVMGetPoison(ret_type), vec, index_0};
                call_args[i] = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 3, get_next_var_name());
            }
        } else {
            call_args[i] = get_func_param(i);
        }
    }
    LLVMTypeRef func_type = LLVMFunctionType(LLVMVoidType(), fixed_vector_param_types, FIXED_VECTOR_PARAM_COUNT, 0);
    LLVMValueRef ret_target = get_source_node_imm_or_stack(0, loc608, OPC_ADDR_T);
    LLVMValueRef ret_target_ptr = LLVMBuildIntToPtr(builder, ret_target, LLVMPointerType(func_type, 0), get_next_var_name());
    LLVMValueRef call_inst = LLVMBuildCall2(builder, func_type, ret_target_ptr, call_args, FIXED_VECTOR_PARAM_COUNT, "");
    LLVMSetTailCall(call_inst, 1);

    create_setlabel(buf, set_label, new_label);
    translate_set_label(set_label, buf);

    create_helper_env_slot(buf, ret_ind, 0, 0, operand0);
    translate_call(call, buf);
}

void translate_rotr(OpCodeType opc, void *ptr) {
    OperandType t0 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType t1 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    uint8_t buf[16];
    OpCodeType tmp_opc;
    // shr
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? shr_i64 : shr_i32;
    create_scalar_slot3(buf, tmp_opc, t0, operand1, operand2);
    translate_binary(tmp_opc, buf, LLVMBuildLShr);
    // sub
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? sub_i64 : sub_i32;
    create_scalar_slot_imm_slot(buf, tmp_opc, t1, OPC_OUTPUT_T == LLVMInt64 ? 64 : 32, operand2);
    translate_binary(tmp_opc, buf, LLVMBuildSub);
    // shl
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? shl_i64 : shl_i32;
    create_scalar_slot3(buf, tmp_opc, t1, operand1, t1);
    translate_binary(tmp_opc, buf, LLVMBuildShl);
    // or
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? or_i64 : or_i32;
    create_scalar_slot3(buf, tmp_opc, operand0, t0, t1);
    translate_binary(tmp_opc, buf, LLVMBuildOr);
}

void translate_rotl(OpCodeType opc, void *ptr) {
    OperandType t0 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType t1 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();

    uint8_t buf[16];
    OpCodeType tmp_opc;
    // shl
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? shl_i64 : shl_i32;
    create_scalar_slot3(buf, tmp_opc, t0, operand1, operand2);
    translate_binary(tmp_opc, buf, LLVMBuildShl);
    // sub
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? sub_i64 : sub_i32;
    create_scalar_slot_imm_slot(buf, tmp_opc, t1, OPC_OUTPUT_T == LLVMInt64 ? 64 : 32, operand2);
    translate_binary(tmp_opc, buf, LLVMBuildSub);
    // shr
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? shr_i64 : shr_i32;
    create_scalar_slot3(buf, tmp_opc, t1, operand1, t1);
    translate_binary(tmp_opc, buf, LLVMBuildLShr);
    // or
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? or_i64 : or_i32;
    create_scalar_slot3(buf, tmp_opc, operand0, t0, t1);
    translate_binary(tmp_opc, buf, LLVMBuildOr);
}

void translate_setcond_i64(OpCodeType opc, void *ptr) {
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef c1 = get_source_node_imm_or_stack(is_imm1, operand1, OPC_INPUT_T);
    LLVMValueRef c2 = get_source_node_imm_or_stack(is_imm2, operand2, OPC_INPUT_T);

    RelopType r = get_relop(ptr);
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        OperandType tmp = get_tmp_and_do_alloc(LLVMInt64);
        c1 = LLVMBuildAnd(builder, c1, c2, get_next_var_name());
        c2 = LLVMConstInt(llvm_int_types[OPC_INPUT_T], 0, 0);
    }
    assert(r < RELOPMAX && llvm_predicate[r]);
    LLVMValueRef bool_val = LLVMBuildICmp(builder, llvm_predicate[r], c1, c2, get_next_var_name());
    LLVMValueRef result = LLVMBuildZExt(builder, bool_val, llvm_int_types[OPC_OUTPUT_T], get_next_var_name());
    do_store(result, OPC_OUTPUT_T, operand0);
}

void translate_sextract_i64(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1, ofs, len;
    GET_2_OPERANDS();
    uint32_t is_imm2, is_imm3;
    ofs = get_operand(ptr, 2, &is_imm2);
    len = get_operand(ptr, 3, &is_imm3);
    assert(is_imm2 & is_imm3);
    OperandType t0 = get_tmp_and_do_alloc(LLVMInt64);

    uint8_t buf[16];
    OpCodeType tmp_opc;
    // shl
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? shl_i64 : shl_i32;
    create_scalar_slot2_imm(buf, tmp_opc, t0, operand1, (64 - len.i - ofs.i));
    translate_binary(tmp_opc, buf, LLVMBuildShl);
    // sar
    tmp_opc = OPC_OUTPUT_T == LLVMInt64 ? sar_i64 : sar_i32;
    create_scalar_slot2_imm(buf, tmp_opc, operand0, t0, (64 - len.i));
    translate_binary(tmp_opc, buf, LLVMBuildAShr);
}

void translate_st(OpCodeType opc, void *ptr) {
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();
    assert(!is_imm1 && operand1.s.valid);

    LLVMValueRef val = get_source_node_imm_or_stack(is_imm0, operand0, OPC_INPUT_T);
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
        LLVMValueRef src_val = get_source_node_imm_or_stack(0, src, OPC_OUTPUT_T + 4);
        LLVMValueRef index = LLVMConstInt(LLVMInt64Type(), (alias.s.offset * 8) / llvm_vector_elem_bit_counts[OPC_OUTPUT_T*2+1], 0);
        val = LLVMBuildInsertElement(builder, src_val, val, index, get_next_var_name());
        do_store(val, OPC_OUTPUT_T + 4, src);
    } else {
        addr_val = get_source_node_imm_or_stack(0, operand1, OPC_ADDR_T);
        LLVMValueRef addr_ptr = LLVMBuildIntToPtr(builder, addr_val, LLVMPointerType(llvm_int_types[OPC_OUTPUT_T], 0), get_next_var_name());
        LLVMBuildStore(builder, val, addr_ptr);
    }
}

void translate_maxmin_vec(OpCodeType opc, void *ptr, RelopType r) {
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS();
    AttrSrcInfo ai;
    LLVMType vtype = get_llvm_vector_type(ptr);
    ai.p.ves = vtype - LLVMVector16xi8;
    OperandType tmp1 = get_tmp_and_do_alloc(vtype);
    OperandType tmp2 = get_tmp_and_do_alloc(vtype);

    uint8_t buf[16];
    create_vector_slot2(buf, mov_vec, ai, tmp1, operand1);
    translate_mov(mov_vec, buf);
    create_vector_slot2(buf, mov_vec, ai, tmp2, operand2);
    translate_mov(mov_vec, buf);
    create_vector_slot5_relop(buf, movcond_vec, ai, operand0, operand1, operand2, tmp1, tmp2, r);
    translate_movcond(movcond_vec, buf);
}

void translate_bswap64_i64(OpCodeType opc, void *ptr) {
    OperandType t0 = get_tmp_and_do_alloc(LLVMInt64);
    OperandType t1 = get_tmp_and_do_alloc(LLVMInt64);
    uint64_t t2;

    OperandType operand0, operand1;
    GET_2_OPERANDS();

    uint8_t buf[16];
    t2 = 0x00ff00ff00ff00ffUL;
    create_scalar_slot2_imm(buf, shr_i64, t0, operand1, 8);
    translate_binary(shr_i64, buf, LLVMBuildLShr);
    create_scalar_slot2_immUL(buf, and_i64, t1, operand1, t2);
    translate_binary(and_i64, buf, LLVMBuildAnd);
    create_scalar_slot2_immUL(buf, and_i64, t0, t0, t2);
    translate_binary(and_i64, buf, LLVMBuildAnd);
    create_scalar_slot2_imm(buf, shl_i64, t1, t1, 8);
    translate_binary(shl_i64, buf, LLVMBuildShl);
    create_scalar_slot3(buf, or_i64, operand0, t0, t1);
    translate_binary(or_i64, buf, LLVMBuildOr);

    t2 = 0x0000ffff0000ffffUL;
    create_scalar_slot2_imm(buf, shr_i64, t0, operand0, 16);
    translate_binary(shr_i64, buf, LLVMBuildLShr);
    create_scalar_slot2_immUL(buf, and_i64, t1, operand0, t2);
    translate_binary(and_i64, buf, LLVMBuildAnd);
    create_scalar_slot2_immUL(buf, and_i64, t0, t0, t2);
    translate_binary(and_i64, buf, LLVMBuildAnd);
    create_scalar_slot2_imm(buf, shl_i64, t1, t1, 16);
    translate_binary(shl_i64, buf, LLVMBuildShl);
    create_scalar_slot3(buf, or_i64, operand0, t0, t1);
    translate_binary(or_i64, buf, LLVMBuildOr);

    create_scalar_slot2_imm(buf, shr_i64, t0, operand0, 32);
    translate_binary(shl_i64, buf, LLVMBuildLShr);
    create_scalar_slot2_imm(buf, shl_i64, t1, operand0, 32);
    translate_binary(shl_i64, buf, LLVMBuildShl);
    create_scalar_slot3(buf, or_i64, operand0, t0, t1);
    translate_binary(or_i64, buf, LLVMBuildOr);
}

void translate_set_label(OpCodeType opc, void *ptr) {
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
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();
    LLVMValueRef c1 = get_source_node_imm_or_stack(is_imm0, operand0, OPC_INPUT_T);
    LLVMValueRef c2 = get_source_node_imm_or_stack(is_imm1, operand1, OPC_INPUT_T);

    RelopType r = get_relop(ptr);
    if (r == tsteq || r == tstne) {
        r -= (tsteq - eq);
        OperandType tmp = get_tmp_and_do_alloc(LLVMInt64);
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
    uint32_t is_imm;
    OperandType delta;
    delta = get_operand(ptr, 0, &is_imm);
    assert(is_imm);

    LLVMValueRef call_args[FIXED_VECTOR_PARAM_COUNT];
    for (int i = 0; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        if (fixed_vector_param_in_stack[i]) {
            OperandType param_in_stack;
            if (i < FIXED_PARAM_COUNT) {
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XREG;
                param_in_stack.s.slot_idx = i;
                call_args[i] = get_source_node_imm_or_stack(0, param_in_stack, fixed_vector_param_llvmtypes[i]);
            } else {
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XMM;
                param_in_stack.s.slot_idx = i - FIXED_PARAM_COUNT;
                param_in_stack.s.offset = 0;
                LLVMValueRef vec = get_source_node_imm_or_stack(0, param_in_stack, fixed_vector_param_llvmtypes[i]);

                LLVMTypeRef ret_type = LLVMScalableVectorType(LLVMInt64Type(), 1); // <vscale x 1 x i64>
                LLVMTypeRef param_type = LLVMVectorType(LLVMInt64Type(), 2); // <2 x i64>
                LLVMTypeRef intrinsic_types[] = {ret_type, param_type, LLVMInt64Type()};
                LLVMTypeRef intrinsic_func_type = LLVMFunctionType(ret_type, intrinsic_types, 3, 0);
                LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, "llvm.vector.insert.nxv1i64.v2i64");
                if (!intrinsic_func) {
                    intrinsic_func = LLVMAddFunction(module, "llvm.vector.insert.nxv1i64.v2i64", intrinsic_func_type);
                }
                LLVMValueRef index_0 = LLVMConstInt(LLVMInt64Type(), 0, 0);
                LLVMValueRef intrinsic_call_args[] = {LLVMGetPoison(ret_type), vec, index_0};
                call_args[i] = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 3, get_next_var_name());
            }
        } else {
            call_args[i] = get_func_param(i);
        }
    }
    LLVMTypeRef ret_type = LLVMVoidType();
    LLVMTypeRef func_type = LLVMFunctionType(ret_type, fixed_vector_param_types, FIXED_VECTOR_PARAM_COUNT, 0);

    char func_name[64] = {0};
    sprintf(func_name, "func_%lx", (current_func_offset + delta.i));
    LLVMValueRef func = LLVMGetNamedFunction(module, func_name);
    if (!func) {
        func = LLVMAddFunction(module, func_name, func_type);
        LLVMAddAttributeAtIndex(func, -1, NoInlineAttr);
        LLVMAddAttributeAtIndex(func, -1, target_features_attr);
    }
    LLVMValueRef call_inst = LLVMBuildCall2(builder, func_type, func, call_args, FIXED_VECTOR_PARAM_COUNT, "");
    LLVMSetTailCall(call_inst, 1);
    // FIXME: qemuaot
    LLVMSetInstructionCallConv(call_inst, 124);
    LLVMBuildRetVoid(builder);
}

void translate_call_direct(OpCodeType opc, void *ptr) {
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, ret_delta_hex, call_delta_hex;
    operand0 = get_operand(ptr, 0, &is_imm0);
    assert(!is_imm0 && operand0.s.valid);
    ret_delta_hex = get_operand(ptr, 1, &is_imm1);
    call_delta_hex = get_operand(ptr, 2, &is_imm2);
    assert(is_imm1 && is_imm2);

    uint8_t buf[16];
    create_scalar_slot_imm(buf, push_ret_addr, operand0, ret_delta_hex.i);
    translate_push_ret_addr(push_ret_addr, buf);
    create_jmpdirect(buf, call_delta_hex.i);
    translate_jmp_direct(jmp_direct, buf);
}

void translate_discard(OpCodeType opc, void *ptr) {
    uint32_t is_imm;
    OperandType operand0 = get_operand(ptr, 0, &is_imm);
    assert(!is_imm && operand0.s.valid);
    if (operand0.s.slot_type == SUB_SLOT_XREG) {
        LLVMBuildStore(builder, LLVMGetPoison(llvm_int_types[func_xreg_llvmtype[operand0.s.slot_idx]]), func_xreg_alloca[operand0.s.slot_idx]);
    }
}

static uint8_t can_inline_helper(HelperType h, const char *build_macro, const char *bc_name, const char *helper_func_name) {
    if (helper_vec_type[h] == LLVMInvalidType) {
        return 0;
    }
    if (inline_helper_enabled[h]) {
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
    }
    return 0;
}

static uint8_t is_dump_call(HelperType h) {
    if (h == dump_load || h == dump_store || h == dump_registers) {
        return 1;
    }
    return 0;
}

static uint8_t is_tail_call(HelperType h) {
    if (h == ret_ind || h == call_ind || h == icebp ||
        h == iret_ind || h == jmp_ind || h == ljmp_protected ||
        h == lret_protected || h == helper_pause || h == raise_exception ||
        h == raise_interrupt) {
        return 1;
    }
    return 0;
}

void translate_tail_call(OpCodeType opc, void *ptr) {
    uint8_t op_idx = 0;
    OperandType operands[16] = {0};
    uint32_t is_imm[16] = {0};
    uint8_t op_cnt = 0;
    do {
        operands[op_cnt] = get_operand(ptr, op_idx, &is_imm[op_cnt]);
        if (is_imm[op_cnt] == 0 && operands[op_cnt].s.valid == 0) {
            break;
        }
        op_cnt += 1;
        op_idx += 1;
    } while (1);

    // Build the call
    LLVMTypeRef call_types[FIXED_PARAM_COUNT + 16] = {NULL};
    LLVMValueRef call_args[FIXED_PARAM_COUNT + 16];
    for (int i = 0; i < FIXED_PARAM_COUNT; ++i) {
        call_types[i] = fixed_vector_param_types[i];
        if (fixed_vector_param_in_stack[i]) {
            OperandType param_in_stack;
            param_in_stack.s.valid = 1;
            param_in_stack.s.slot_type = SUB_SLOT_XREG;
            param_in_stack.s.slot_idx = i;
            call_args[i] = get_source_node_imm_or_stack(0, param_in_stack, fixed_vector_param_llvmtypes[i]);
        } else {
            call_args[i] = get_func_param(i);
        }
    }
    call_types[FIXED_PARAM_COUNT] = llvm_int_types[LLVMInt64];
    call_args[FIXED_PARAM_COUNT] = LLVMConstInt(call_types[FIXED_PARAM_COUNT], 0, 0);
    int call_arg_cnts = FIXED_PARAM_COUNT + 1 + op_cnt;
    for (int i = FIXED_PARAM_COUNT + 1, op_idx = 0; i < call_arg_cnts; ++i, ++op_idx) {
        if (is_imm[op_idx]) {
            call_types[i] = llvm_int_types[LLVMInt64];
            call_args[i] = LLVMConstInt(call_types[i], operands[op_idx].i, 0);
        } else {
            assert(operands[op_idx].s.slot_type != SUB_SLOT_XMM);
            if (operands[op_idx].s.slot_type == SUB_SLOT_TMP && has_alias(operands[op_idx])) {
                call_types[i] = llvm_int_types[LLVMInt64];
                OperandType alias = get_alias(operands[op_idx]);
                assert(alias.s.valid);
                if (alias.s.slot_type == SUB_SLOT_XMM) {
                    LLVMValueRef env_raw = get_env_ptr_raw();
                    uint64_t xmm_offset = get_xmm_offset(alias.s.slot_idx/2) + 16*(alias.s.slot_idx%2) + alias.s.offset;
                    LLVMValueRef off = LLVMConstInt(LLVMInt64Type(), xmm_offset, 0);
                    call_args[i] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                } else if (alias.s.slot_type == SUB_SLOT_ENV) {
                    LLVMValueRef env_raw = get_env_ptr_raw();
                    LLVMValueRef off = LLVMConstInt(LLVMInt64Type(), alias.s.offset, 0);
                    call_args[i] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                } else {
                    assert(0);
                }
            } else {
                if (operands[op_idx].s.slot_type == SUB_SLOT_ENVVAR) {
                    call_types[i] = llvm_int_types[LLVMInt64];
                    call_args[i] = get_source_node_imm_or_stack(0, operands[op_idx], LLVMInt64);
                } else if (operands[op_idx].s.slot_type == SUB_SLOT_XREG) {
                    call_types[i] = fixed_vector_param_types[operands[op_idx].s.slot_idx];
                    call_args[i] = get_source_node_imm_or_stack(0, operands[op_idx], fixed_vector_param_llvmtypes[operands[op_idx].s.slot_idx]);
                } else if (operands[op_idx].s.slot_type == SUB_SLOT_TMP) {
                    assert(func_tmp_llvmtype[operands[op_idx].s.slot_idx] <= LLVMInt64);
                    call_types[i] = llvm_int_types[func_tmp_llvmtype[operands[op_idx].s.slot_idx]];
                    call_args[i] = get_source_node_imm_or_stack(0, operands[op_idx], func_tmp_llvmtype[operands[op_idx].s.slot_idx]);
                } else {
                    assert(0);
                }
            }
        }
    }

    LLVMTypeRef helper_type = LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnts, 0);

    char helper_name[64] = {0};
    sprintf(helper_name, "helper_A_%s", helper_str[get_helper(ptr)]);
    LLVMValueRef helper = LLVMGetNamedFunction(module, helper_name);
    if (!helper) {
        helper = LLVMAddFunction(module, helper_name, helper_type);
    }
    LLVMValueRef call_helper_inst = LLVMBuildCall2(builder, helper_type, helper, call_args, call_arg_cnts, "");
    LLVMSetTailCall(call_helper_inst, 1);
    // FIXME: qemuaot
    LLVMSetInstructionCallConv(call_helper_inst, 124);
    LLVMBuildRetVoid(builder);
}

void translate_dump_call(OpCodeType opc, void *ptr, uint32_t is_dump_registers) {
    if (is_dump_registers) {
        // Store all vectors to memory
        LLVMValueRef env_raw = get_env_ptr_raw();
        LLVMTypeRef ret_type = LLVMVectorType(LLVMInt64Type(), 2); // <2 x i64>
        LLVMTypeRef param_type = LLVMScalableVectorType(LLVMInt64Type(), 1); // <vscale x 1 x i64>
        LLVMTypeRef intrinsic_types[] = {param_type, LLVMInt64Type()};
        LLVMTypeRef intrinsic_func_type = LLVMFunctionType(ret_type, intrinsic_types, 2, 0);
        LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, "llvm.vector.extract.v2i64.nxv1i64");
        if (!intrinsic_func) {
            intrinsic_func = LLVMAddFunction(module, "llvm.vector.extract.v2i64.nxv1i64", intrinsic_func_type);
        }
        LLVMValueRef index_0 = LLVMConstInt(LLVMInt64Type(), 0, 0);
        for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
            LLVMValueRef vec_val = NULL;
            if (fixed_vector_param_in_stack[i]) {
                OperandType param_in_stack;
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XMM;
                param_in_stack.s.slot_idx = i - FIXED_PARAM_COUNT;
                param_in_stack.s.offset = 0;
                vec_val = get_source_node_imm_or_stack(0, param_in_stack, fixed_vector_param_llvmtypes[i]);
            } else {
                LLVMValueRef call_args[] = {get_func_param(i), index_0};
                vec_val = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, call_args, 2, get_next_var_name());
            }
            uint64_t xmm_offset = get_xmm_offset((i - FIXED_PARAM_COUNT)/2) + 16 * ((i - FIXED_PARAM_COUNT) % 2);
            LLVMValueRef off = LLVMConstInt(LLVMInt64Type(), xmm_offset, 0);
            LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
            LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(ret_type, 0), get_next_var_name());
            LLVMBuildStore(builder, vec_val, ptr);
        }
    }

    uint8_t op_idx = 0;
    OperandType operands[16] = {0};
    uint32_t is_imm[16] = {0};
    uint8_t op_cnt = 0;
    do {
        operands[op_cnt] = get_operand(ptr, op_idx, &is_imm[op_cnt]);
        if (is_imm[op_cnt] == 0 && operands[op_cnt].s.valid == 0) {
            break;
        }
        op_cnt += 1;
        op_idx += 1;
    } while (1);

    // Build the call
    LLVMTypeRef call_types[FIXED_PARAM_COUNT + 16] = {NULL};
    LLVMValueRef call_args[FIXED_PARAM_COUNT + 16];
    for (int i = 0; i < FIXED_PARAM_COUNT; ++i) {
        call_types[i] = fixed_vector_param_types[i];
        if (fixed_vector_param_in_stack[i]) {
            OperandType param_in_stack;
            param_in_stack.s.valid = 1;
            param_in_stack.s.slot_type = SUB_SLOT_XREG;
            param_in_stack.s.slot_idx = i;
            call_args[i] = get_source_node_imm_or_stack(0, param_in_stack, fixed_vector_param_llvmtypes[i]);
        } else {
            call_args[i] = get_func_param(i);
        }
    }
    call_types[FIXED_PARAM_COUNT] = llvm_int_types[LLVMInt64];
    call_args[FIXED_PARAM_COUNT] = LLVMConstInt(call_types[FIXED_PARAM_COUNT], 0, 0);
    int call_arg_cnts = FIXED_PARAM_COUNT + 1 + op_cnt;
    for (int i = FIXED_PARAM_COUNT + 1, op_idx = 0; i < call_arg_cnts; ++i, ++op_idx) {
        if (is_imm[op_idx]) {
            call_types[i] = llvm_int_types[LLVMInt64];
            call_args[i] = LLVMConstInt(call_types[i], operands[op_idx].i, 0);
        } else {
            if (operands[op_idx].s.slot_type == SUB_SLOT_XREG) {
                call_types[i] = fixed_vector_param_types[operands[op_idx].s.slot_idx];
                call_args[i] = get_source_node_imm_or_stack(0, operands[op_idx], fixed_vector_param_llvmtypes[operands[op_idx].s.slot_idx]);
            } else if (operands[op_idx].s.slot_type == SUB_SLOT_TMP) {
                if (has_alias(operands[op_idx])) {
                    call_types[i] = llvm_int_types[LLVMInt64];
                    OperandType alias = get_alias(operands[op_idx]);
                    assert(alias.s.valid);
                    if (alias.s.slot_type == SUB_SLOT_XMM) {
                        LLVMValueRef env_raw = get_env_ptr_raw();
                        uint64_t xmm_offset = get_xmm_offset(alias.s.slot_idx/2) + 16*(alias.s.slot_idx%2) + alias.s.offset;
                        LLVMValueRef off = LLVMConstInt(LLVMInt64Type(), xmm_offset, 0);
                        call_args[i] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                    } else if (alias.s.slot_type == SUB_SLOT_ENV) {
                        LLVMValueRef env_raw = get_env_ptr_raw();
                        LLVMValueRef off = LLVMConstInt(LLVMInt64Type(), alias.s.offset, 0);
                        call_args[i] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                    } else {
                        assert(0);
                    }
                } else {
                    assert(func_tmp_llvmtype[operands[op_idx].s.slot_idx] <= LLVMInt64);
                    call_types[i] = llvm_int_types[func_tmp_llvmtype[operands[op_idx].s.slot_idx]];
                    call_args[i] = get_source_node_imm_or_stack(0, operands[op_idx], func_tmp_llvmtype[operands[op_idx].s.slot_idx]);
                }
            } else {
                assert(0);
            }
        }
    }

    LLVMTypeRef helper_type = LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnts, 0);

    char helper_name[64] = {0};
    sprintf(helper_name, "helper_A_%s", helper_str[get_helper(ptr)]);
    LLVMValueRef helper = LLVMGetNamedFunction(module, helper_name);
    if (!helper) {
        helper = LLVMAddFunction(module, helper_name, helper_type);
    }
    LLVMValueRef call_helper_inst = LLVMBuildCall2(builder, helper_type, helper, call_args, call_arg_cnts, "");
}

void translate_call(OpCodeType opc, void *ptr) {
    HelperType h = get_helper(ptr);
    if (is_dump_call(h)) {
        return translate_dump_call(opc, ptr, (h == dump_registers));
    } else if (is_tail_call(h)) {
        if (h == raise_exception || h == raise_interrupt) {
            exception_or_interrupt_on = 1;
        }
        return translate_tail_call(opc, ptr);
    }

    static int check_recursive_call = 0;
    assert(check_recursive_call == 0);
    check_recursive_call = 1;

    char second_half_name[64];
    sprintf(second_half_name, "func_%lx_call%d", current_func_offset, current_call_idx);
    // Need check arguments to determine the helper can be inlined
    uint8_t noargs = get_helper_noargs(ptr);
    OperandType oarg;
    oarg.s.valid = 0;
    if (noargs) {
        uint32_t is_imm;
        oarg = get_operand(ptr, 0, &is_imm);
        assert(!is_imm && oarg.s.valid);
    }
    uint8_t op_idx = noargs;
    OperandType operands[16] = {0};
    uint32_t is_imm[16] = {0};
    uint8_t op_cnt = 0;
    uint8_t all_alias = 1;
    char build_macro[512] = {0};
    do {
        operands[op_cnt] = get_operand(ptr, op_idx, &is_imm[op_cnt]);
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
        op_idx += 1;
    } while (1);
    if (!op_cnt) {
        all_alias = 0;
    }
    char helper_func_name[64] = {0};
    char bc_name[64] = {0};
    if (all_alias) {
        char element[128];
        sprintf(element, " -DFUNC_RET=%s -DHELPER_NAME=helper_%s_%s", second_half_name, helper_str[h], second_half_name);
        strcat(build_macro, element);
        sprintf(bc_name, "helper_templates/helper_%s_%s.bc", helper_str[h], second_half_name);
        sprintf(helper_func_name, "helper_%s_%s", helper_str[h], second_half_name);
    }

    LLVMValueRef env_raw = get_env_ptr_raw();
    uint8_t do_inline_helper = all_alias ? can_inline_helper(h, build_macro, bc_name, helper_func_name) : 0;
    if (!do_inline_helper) {
        // Store all vectors to memory
        LLVMTypeRef ret_type = LLVMVectorType(LLVMInt64Type(), 2); // <2 x i64>
        LLVMTypeRef param_type = LLVMScalableVectorType(LLVMInt64Type(), 1); // <vscale x 1 x i64>
        LLVMTypeRef intrinsic_types[] = {param_type, LLVMInt64Type()};
        LLVMTypeRef intrinsic_func_type = LLVMFunctionType(ret_type, intrinsic_types, 2, 0);
        LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, "llvm.vector.extract.v2i64.nxv1i64");
        if (!intrinsic_func) {
            intrinsic_func = LLVMAddFunction(module, "llvm.vector.extract.v2i64.nxv1i64", intrinsic_func_type);
        }
        LLVMValueRef index_0 = LLVMConstInt(LLVMInt64Type(), 0, 0);
        for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
            LLVMValueRef vec_val = NULL;
            if (fixed_vector_param_in_stack[i]) {
                OperandType param_in_stack;
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XMM;
                param_in_stack.s.slot_idx = i - FIXED_PARAM_COUNT;
                param_in_stack.s.offset = 0;
                vec_val = get_source_node_imm_or_stack(0, param_in_stack, fixed_vector_param_llvmtypes[i]);
            } else {
                LLVMValueRef call_args[] = {get_func_param(i), index_0};
                vec_val = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, call_args, 2, get_next_var_name());
            }
            uint64_t xmm_offset = get_xmm_offset((i - FIXED_PARAM_COUNT)/2) + 16 * ((i - FIXED_PARAM_COUNT) % 2);
            LLVMValueRef off = LLVMConstInt(LLVMInt64Type(), xmm_offset, 0);
            LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
            LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(ret_type, 0), get_next_var_name());
            LLVMBuildStore(builder, vec_val, ptr);
        }
        for (int i = 0; i < 2; ++i) {
            if (xmmt_valid[i]) {
                OperandType param_in_stack;
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XMM;
                param_in_stack.s.slot_idx = xmmt + i;
                param_in_stack.s.offset = 0;
                LLVMValueRef vec_val = get_source_node_imm_or_stack(0, param_in_stack, LLVMVector2xi64);
                uint64_t xmm_offset = get_xmm_offset(param_in_stack.s.slot_idx/2) + 16*(param_in_stack.s.slot_idx%2);
                LLVMValueRef off = LLVMConstInt(LLVMInt64Type(), xmm_offset, 0);
                LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(ret_type, 0), get_next_var_name());
                LLVMBuildStore(builder, vec_val, ptr);
            }
        }
    }
    // Store tmp_shadow_offset[this call][non-zero offset] contents to the shadow_stack
    LLVMValueRef off = LLVMConstInt(LLVMInt64Type(), -8UL, 0);
    LLVMValueRef addr = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
    LLVMValueRef pointer = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(LLVMInt64Type(), 0), get_next_var_name());
    LLVMValueRef shadow_pointer = LLVMBuildLoad2(builder, LLVMInt64Type(), pointer, get_next_var_name());
    for (int i = 0; i < (1<<5); ++i) {
        if (tmp_shadow_offset[current_call_idx][i]) {
            printf("i:%d\n", i);
            OperandType op;
            op.s.valid = 1;
            op.s.slot_type = SUB_SLOT_TMP;
            op.s.slot_idx = i;
            LLVMValueRef val = get_source_node_imm_or_stack(0, op, func_tmp_llvmtype[i]);

            LLVMValueRef shadow_off = LLVMConstInt(LLVMInt64Type(), tmp_shadow_offset[current_call_idx][i], 0);
            LLVMValueRef shadow_addr = LLVMBuildAdd(builder, shadow_pointer, shadow_off, get_next_var_name());
            LLVMValueRef shadow_p = LLVMBuildIntToPtr(builder, shadow_addr, LLVMPointerType(llvm_int_types[func_tmp_llvmtype[i]], 0), get_next_var_name());
            LLVMBuildStore(builder, val, shadow_p);
        }
    }

    LLVMValueRef second_half_func = LLVMGetNamedFunction(module, second_half_name);
    int second_half_idx = 0;
    if (!second_half_func) {
        LLVMTypeRef second_half_func_types[FIXED_VECTOR_PARAM_COUNT+1] = {NULL};
        for (; second_half_idx < FIXED_PARAM_COUNT; ++second_half_idx) {
            second_half_func_types[second_half_idx] = fixed_vector_param_types[second_half_idx];
        }
        if (noargs) {
            second_half_func_types[second_half_idx++] = llvm_int_types[helper_output_type[current_call_idx]];
        }
        for (int i = FIXED_PARAM_COUNT; i < FIXED_VECTOR_PARAM_COUNT; ++i, ++second_half_idx) {
            second_half_func_types[second_half_idx] = fixed_vector_param_types[i];
        }
        LLVMTypeRef second_half_func_type = LLVMFunctionType(LLVMVoidType(), second_half_func_types, second_half_idx, 0);
        second_half_func = LLVMAddFunction(module, second_half_name, second_half_func_type);
    } else {
        second_half_idx = FIXED_VECTOR_PARAM_COUNT + noargs;
    }
    LLVMAddAttributeAtIndex(second_half_func, -1, AlwaysInlineAttr);
    LLVMAddAttributeAtIndex(second_half_func, -1, target_features_attr);
    LLVMValueRef second_half_addr = LLVMBuildPtrToInt(builder, second_half_func, LLVMInt64Type(), get_next_var_name());

    // Build the call
    LLVMTypeRef call_types[(do_inline_helper ? FIXED_VECTOR_PARAM_COUNT : FIXED_PARAM_COUNT) + 16];
    LLVMValueRef call_args[(do_inline_helper ? FIXED_VECTOR_PARAM_COUNT : FIXED_PARAM_COUNT) + 16];
    for (int i = 0; i < FIXED_PARAM_COUNT; ++i) {
        call_types[i] = fixed_vector_param_types[i];
        if (fixed_vector_param_in_stack[i]) {
            OperandType param_in_stack;
            param_in_stack.s.valid = 1;
            param_in_stack.s.slot_type = SUB_SLOT_XREG;
            param_in_stack.s.slot_idx = i;
            call_args[i] = get_source_node_imm_or_stack(0, param_in_stack, fixed_vector_param_llvmtypes[i]);
        } else {
            call_args[i] = get_func_param(i);
        }
    }
    call_types[FIXED_PARAM_COUNT] = llvm_int_types[LLVMInt64];
    call_args[FIXED_PARAM_COUNT] = second_half_addr;
    int actual_op_cnt = 0;
    for (int i = FIXED_PARAM_COUNT + 1, op_idx = 0; op_idx < op_cnt; ++op_idx) {
        if (is_imm[op_idx]) {
            call_types[i] = llvm_int_types[LLVMInt64];
            call_args[i] = LLVMConstInt(call_types[i], operands[op_idx].i, 0);
        } else {
            assert(operands[op_idx].s.slot_type != SUB_SLOT_XMM);
            if (operands[op_idx].s.slot_type == SUB_SLOT_TMP && has_alias(operands[op_idx])) {
                if (do_inline_helper) {
                    continue;
                }
                call_types[i] = llvm_int_types[LLVMInt64];
                OperandType alias = get_alias(operands[op_idx]);
                assert(alias.s.valid);
                if (alias.s.slot_type == SUB_SLOT_XMM) {
                    LLVMValueRef env_raw = get_env_ptr_raw();
                    uint64_t xmm_offset = get_xmm_offset(alias.s.slot_idx/2) + 16*(alias.s.slot_idx%2) + alias.s.offset;
                    LLVMValueRef off = LLVMConstInt(LLVMInt64Type(), xmm_offset, 0);
                    call_args[i] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                } else if (alias.s.slot_type == SUB_SLOT_ENV) {
                    LLVMValueRef env_raw = get_env_ptr_raw();
                    LLVMValueRef off = LLVMConstInt(LLVMInt64Type(), alias.s.offset, 0);
                    call_args[i] = LLVMBuildAdd(builder, env_raw, off, get_next_var_name());
                } else {
                    assert(0);
                }
            } else {
                if (operands[op_idx].s.slot_type == SUB_SLOT_ENVVAR) {
                    call_types[i] = llvm_int_types[LLVMInt64];
                    call_args[i] = get_source_node_imm_or_stack(0, operands[op_idx], LLVMInt64);
                } else if (operands[op_idx].s.slot_type == SUB_SLOT_XREG) {
                    call_types[i] = fixed_vector_param_types[operands[op_idx].s.slot_idx];
                    call_args[i] = get_source_node_imm_or_stack(0, operands[op_idx], fixed_vector_param_llvmtypes[operands[op_idx].s.slot_idx]);
                } else if (operands[op_idx].s.slot_type == SUB_SLOT_TMP) {
                    assert(func_tmp_llvmtype[operands[op_idx].s.slot_idx] <= LLVMInt64);
                    call_types[i] = llvm_int_types[func_tmp_llvmtype[operands[op_idx].s.slot_idx]];
                    call_args[i] = get_source_node_imm_or_stack(0, operands[op_idx], func_tmp_llvmtype[operands[op_idx].s.slot_idx]);
                } else {
                    assert(0);
                }
            }
        }
        actual_op_cnt += 1;
        i += 1;
    }
    assert(do_inline_helper == 0 || actual_op_cnt == 0);
    int call_arg_cnts = (do_inline_helper ? FIXED_VECTOR_PARAM_COUNT : FIXED_PARAM_COUNT) + 1 + actual_op_cnt;
    if (do_inline_helper) {
        LLVMTypeRef default_scalable_vec_type = LLVMScalableVectorType(llvm_int_types[LLVMInt64], llvm_vector_elem_bit_counts[LLVMVector2xi64*2]/2);
        LLVMTypeRef scalable_vec_type = LLVMScalableVectorType(llvm_int_types[helper_vec_type[h] - 4], llvm_vector_elem_bit_counts[helper_vec_type[h]*2]/2);
        for (int i = FIXED_PARAM_COUNT + 1 + actual_op_cnt, i_param = FIXED_PARAM_COUNT; i < call_arg_cnts; ++i, ++i_param) {
            if (fixed_vector_param_in_stack[i_param]) {
                OperandType param_in_stack;
                param_in_stack.s.valid = 1;
                param_in_stack.s.slot_type = SUB_SLOT_XMM;
                param_in_stack.s.slot_idx = i_param - FIXED_PARAM_COUNT;
                param_in_stack.s.offset = 0;
                LLVMValueRef vec = get_source_node_imm_or_stack(0, param_in_stack, fixed_vector_param_llvmtypes[i_param]);

                LLVMTypeRef param_type = LLVMVectorType(LLVMInt64Type(), 2);
                LLVMTypeRef intrinsic_types[] = {default_scalable_vec_type, param_type, LLVMInt64Type()};
                LLVMTypeRef intrinsic_func_type = LLVMFunctionType(default_scalable_vec_type, intrinsic_types, 3, 0);
                LLVMValueRef intrinsic_func = LLVMGetNamedFunction(module, "llvm.vector.insert.nxv1i64.v2i64");
                if (!intrinsic_func) {
                    intrinsic_func = LLVMAddFunction(module, "llvm.vector.insert.nxv1i64.v2i64", intrinsic_func_type);
                }
                LLVMValueRef index_0 = LLVMConstInt(LLVMInt64Type(), 0, 0);
                LLVMValueRef intrinsic_call_args[] = {LLVMGetPoison(default_scalable_vec_type), vec, index_0};
                call_args[i] = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, intrinsic_call_args, 3, get_next_var_name());
            } else {
                call_args[i] = get_func_param(i_param);
            }
            if (helper_vec_type[h] != LLVMVector2xi64) {
                call_args[i] = LLVMBuildBitCast(builder, call_args[i], scalable_vec_type, get_next_var_name());
            }
            call_types[i] = scalable_vec_type;
        }
    }
    LLVMTypeRef helper_type = LLVMFunctionType(LLVMVoidType(), call_types, call_arg_cnts, 0);

    LLVMValueRef helper = NULL;
    if (do_inline_helper) {
        helper = LLVMGetNamedFunction(module, helper_func_name);
        assert(helper);
    } else {
        char helper_name[64] = {0};
        sprintf(helper_name, "helper_A_%s", helper_str[get_helper(ptr)]);
        helper = LLVMGetNamedFunction(module, helper_name);
        if (!helper) {
            helper = LLVMAddFunction(module, helper_name, helper_type);
        }
    }
    LLVMValueRef call_helper_inst = LLVMBuildCall2(builder, helper_type, helper, call_args, call_arg_cnts, "");
    LLVMSetTailCall(call_helper_inst, 1);
    // FIXME: qemuaot
    LLVMSetInstructionCallConv(call_helper_inst, 124);
    LLVMBuildRetVoid(builder);

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
        assert(ptr_tmp < ptr_max);
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
    additional_scalar_arg_cnt = noargs;
    for (int j = 0; j < FIXED_VECTOR_PARAM_COUNT; j++) {
        LLVMValueRef param = get_func_param(j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }
    if (second_half_idx != FIXED_VECTOR_PARAM_COUNT) {
        LLVMValueRef param = LLVMGetParam(llvm_func, FIXED_PARAM_COUNT);
        LLVMSetValueName(param, "helper_ret");
    }
    // FIXME: qemuaot
    LLVMSetFunctionCallConv(llvm_func, 124);

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);
    last_active_bb = entry;

    if (xreg_valid) {
        for (XRegType x = 0; x < XREG_MAX; ++x) {
            if (xreg_valid & (1 << x)) {
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, fixed_vector_param_types[x], fixed_vector_stack_names[x]);
                LLVMSetAlignment(alloca_inst, 8);
                func_xreg_alloca[x] = alloca_inst;
                func_xreg_llvmtype[x] = fixed_vector_param_llvmtypes[x];
                LLVMSetAlignment(LLVMBuildStore(builder, get_func_param(x), alloca_inst), 8);
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
                LLVMValueRef index_0 = LLVMConstInt(LLVMInt64Type(), 0, 0);
                LLVMValueRef call_args[] = {get_func_param(FIXED_PARAM_COUNT + i), index_0};
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
    // Get output from helper func
    if (noargs && helper_output_type[current_call_idx] != LLVMInvalidType) {
        LLVMValueRef param = LLVMGetParam(llvm_func, FIXED_PARAM_COUNT);
        if (oarg.s.slot_type == SUB_SLOT_TMP && has_alias(oarg)) {
            unregister_alias(oarg);
        }
        do_store(param, helper_output_type[current_call_idx], oarg);
    } else if (noargs) {
        assert(0);
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
    additional_scalar_arg_cnt = 0;
    memset(fixed_vector_param_in_stack, 0, sizeof(fixed_vector_param_in_stack));
    memset(tmp_shadow_offset, 0, sizeof(tmp_shadow_offset));
    memset(tmp_bits_type, 0, sizeof(tmp_bits_type));
    memset(helper_output_type, 0, sizeof(helper_output_type));
    memset(helper_output_slot, 0, sizeof(helper_output_slot));
    reset_tmp_mapping();
}

void handle_func(uint64_t val) {
    //printf("func %lx\n", val); fflush(NULL);
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
        if (opc == call && !is_dump_call(get_helper(ptr))) {
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
                    if ((opc == call && !is_dump_call(get_helper(ptr)) && slot_idx >= noargs) || (opc != call && slot_idx >= opcoc[opc])) {
                        if (!tmp_has_known_def[operand.s.slot_idx] && tmp_shadow_offset[current_call_idx][operand.s.slot_idx] == 0) {
                            tmp_shadow_offset[current_call_idx][operand.s.slot_idx] = shadow_call_offset;
                            LLVMType t = func_tmp_llvmtype[operand.s.slot_idx];
                            shadow_call_offset += (llvm_vector_elem_bit_counts[t*2] * llvm_vector_elem_bit_counts[t*2+1])/8;
                        }
                    }
                    if ((opc == call && !is_dump_call(get_helper(ptr)) && slot_idx < noargs) || (opc != call && slot_idx < opcoc[opc])) {
                        tmp_has_known_def[operand.s.slot_idx] = 1;
                    }
                }
            }
            slot_idx += 1;
        } while (1);
        if (opc == call && !is_dump_call(get_helper(ptr))) {
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
    llvm_func = LLVMGetNamedFunction(module, func_name);
    if (!llvm_func) {
        llvm_func = LLVMAddFunction(module, func_name,
            LLVMFunctionType(LLVMVoidType(), fixed_vector_param_types, FIXED_VECTOR_PARAM_COUNT, 0));
        LLVMAddAttributeAtIndex(llvm_func, -1, NoInlineAttr);
        LLVMAddAttributeAtIndex(llvm_func, -1, target_features_attr);
    }
    for (int j = 0; j < FIXED_VECTOR_PARAM_COUNT; j++) {
        LLVMValueRef param = get_func_param(j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }
    // FIXME: qemuaot
    LLVMSetFunctionCallConv(llvm_func, 124);

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);
    last_active_bb = entry;

    if (xreg_valid) {
        for (XRegType x = 0; x < XREG_MAX; ++x) {
            if (xreg_valid & (1 << x)) {
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, fixed_vector_param_types[x], fixed_vector_stack_names[x]);
                LLVMSetAlignment(alloca_inst, 8);
                func_xreg_alloca[x] = alloca_inst;
                func_xreg_llvmtype[x] = fixed_vector_param_llvmtypes[x];
                LLVMSetAlignment(LLVMBuildStore(builder, get_func_param(x), alloca_inst), 8);
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
                LLVMValueRef index_0 = LLVMConstInt(LLVMInt64Type(), 0, 0);
                LLVMValueRef call_args[] = {get_func_param(FIXED_PARAM_COUNT + i), index_0};
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

    /*
    /// Add dump_registers
    uint8_t buf[16];
    create_helper_env(buf, dump_registers, 0, 0);
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
        if (opc == call && !is_dump_call(get_helper(ptr))) {
            current_call_idx += 1;
        }
        tmp_var_available = tmp_var_available_backup;
    }

    cleanup_func_resource();

    current_func_cnt += 1;
    if (current_func_cnt >= MAX_FUNC_CNT) {
        module_epilog();
        current_func_cnt = 0;
        module_prolog();
    }
}

static void handle_single_instr(OpCodeType opc, void *ptr) {
    //printf("handle_single_instr: %s\n", opcode_type_str[opc]);
    switch (opc) {
    case add_i64:
        translate_add_i64(opc, ptr);
        break;
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
    case not_i64:
        translate_not_i64(opc, ptr);
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
    char output_file[32] = {0};
    sprintf(output_file, "output/%d.o", obj_idx);
    if (LLVMTargetMachineEmitToFile(target_machine, module, output_file, LLVMObjectFile, &error_msg)) {
        printf("Failed to emit object file: %s", error_msg);
        exit(1);
    }
    printf("Object file %s generated successfully.\n", output_file);
    fflush(NULL);
    LLVMDisposeModule(module);
    obj_idx += 1;
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
