#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include "tcg_ast.h"
#include "tcg_context.h"
#include "tcg_parser.tab.h"
#include "tcg_lexer.yy.h"
#include "api.h"
#include <llvm-c/Core.h>
#include <llvm-c/Types.h>
#include <stdbool.h>

extern char *lineptr;
extern const char *opcode_type_str[];
extern LLVMType opciosz[OPCODE_MAX][3];
extern uint8_t opcoc[OPCODE_MAX];

static LLVMModuleRef module;
static LLVMBuilderRef builder;
static LLVMValueRef llvm_func;
#define FIXED_PARAM_COUNT           20
static LLVMTypeRef fixed_param_types[FIXED_PARAM_COUNT] = {NULL};
static const char *fixed_arg_names[FIXED_PARAM_COUNT] = {NULL};
#define FIXED_VECTOR_PARAM_COUNT   (20 + 15 * 2)
static LLVMTypeRef fixed_vector_param_types[FIXED_VECTOR_PARAM_COUNT] = {NULL};
static LLVMType fixed_vector_param_llvmtypes[FIXED_VECTOR_PARAM_COUNT] = {0};
static const char *fixed_vector_arg_names[FIXED_VECTOR_PARAM_COUNT] = {NULL};
static const char *fixed_vector_stack_names[FIXED_VECTOR_PARAM_COUNT] = {NULL};
static const char *xmm_tmp_stack_names[2] = {NULL};
static const char *tmpl_stack_names[1<<5] = {NULL};
static const char *tmpt_stack_names[1<<5] = {NULL};
static const char *ir_var_name[('z'-'a'+1)*('z'-'a'+1)] = {NULL};
static int ir_var_name_idx = 0;
static LLVMTypeRef llvm_int_types[LLVMMAXType] = {NULL};
static uint8_t llvm_vector_elem_bit_counts[LLVMMAXType * 2] = {0};
static LLVMValueRef func_xreg_alloca[1 << 5] = {NULL};
static LLVMValueRef func_tmpl_alloca[1 << 5] = {NULL};
static LLVMValueRef func_tmpt_alloca[1 << 5] = {NULL};
static LLVMValueRef func_xmm_alloca[1 << 5] = {NULL};
static LLVMType func_xreg_llvmtype[1 << 5] = {0};
static LLVMType func_tmpl_llvmtype[1 << 5] = {0};
static LLVMType func_tmpt_llvmtype[1 << 5] = {0};
static LLVMType func_xmm_llvmtype[1 << 5] = {0};
static uint32_t env_var_offset[ENVVarMAX] = {0};
static OperandType alias_tmpl[1<<5] = {0};
static OperandType alias_tmpt[1<<5] = {0};
static uint32_t tmp_var_available = 0;
static LLVMIntPredicate llvm_predicate[RELOPMAX] = {0};

static void do_store(LLVMValueRef val, LLVMType val_tidx, OperandType out);
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
void translate_movcond_i32(OpCodeType opc, void *ptr);
void translate_movcond_i64(OpCodeType opc, void *ptr);
void translate_mov_i64_const(OpCodeType opc, void *ptr);
void translate_mov_vec(OpCodeType opc, void *ptr);
void translate_mul_i32(OpCodeType opc, void *ptr);
void translate_mul_i64(OpCodeType opc, void *ptr);
void translate_mulsh_i64(OpCodeType opc, void *ptr);
void translate_muluh_i64(OpCodeType opc, void *ptr);
void translate_neg_i32(OpCodeType opc, void *ptr);
void translate_neg_i64(OpCodeType opc, void *ptr);
void translate_negsetcond_i64(OpCodeType opc, void *ptr);
void translate_not_i64(OpCodeType opc, void *ptr);
void translate_not_vec(OpCodeType opc, void *ptr);
void translate_push_ret_addr(OpCodeType opc, void *ptr);
void translate_qemu_ld2_i128(OpCodeType opc, void *ptr);
void translate_qemu_ld_i32(OpCodeType opc, void *ptr);
void translate_qemu_ld_i64(OpCodeType opc, void *ptr);
void translate_qemu_st2_i128(OpCodeType opc, void *ptr);
void translate_qemu_st_i32(OpCodeType opc, void *ptr);
void translate_qemu_st_i64(OpCodeType opc, void *ptr);
void translate_ret(OpCodeType opc, void *ptr);
void translate_rotr_i32(OpCodeType opc, void *ptr);
void translate_rotr_i64(OpCodeType opc, void *ptr);
void translate_setcond_i64(OpCodeType opc, void *ptr);
void translate_sextract_i64(OpCodeType opc, void *ptr);
void translate_st16_i32(OpCodeType opc, void *ptr);
void translate_st16_i64(OpCodeType opc, void *ptr);
void translate_st32_i64(OpCodeType opc, void *ptr);
void translate_st_i32(OpCodeType opc, void *ptr);
void translate_st_i64(OpCodeType opc, void *ptr);
void translate_st_vec(OpCodeType opc, void *ptr);
void translate_umax_vec(OpCodeType opc, void *ptr);
void translate_umin_vec(OpCodeType opc, void *ptr);
void translate_bswap64_i64(OpCodeType opc, void *ptr);
void translate_set_label(OpCodeType opc, void *ptr);
void translate_brcond_i64(OpCodeType opc, void *ptr);
void translate_jmp_direct(OpCodeType opc, void *ptr);
void translate_call_direct(OpCodeType opc, void *ptr);
void translate_discard(OpCodeType opc, void *ptr);
void translate_call(OpCodeType opc, void *ptr);
void translate_ld_env_xmm(OpCodeType opc, void *ptr);

#define GET_2_OPERANDS()                                \
    do {                                                \
        uint32_t is_imm0, is_imm1;                      \
        operand0 = get_operand(ptr, 0, &is_imm0);       \
        operand1 = get_operand(ptr, 1, &is_imm1);       \
        assert(operand0.s.valid && operand1.s.valid);   \
    } while (0);

#define GET_2_OPERANDS_NOCHECK()                        \
    do {                                                \
        operand0 = get_operand(ptr, 0, &is_imm0);       \
        operand1 = get_operand(ptr, 1, &is_imm1);       \
    } while (0);

#define GET_3_OPERANDS()                                \
    do {                                                \
        uint32_t is_imm0, is_imm1, is_imm2;             \
        operand0 = get_operand(ptr, 0, &is_imm0);       \
        operand1 = get_operand(ptr, 1, &is_imm1);       \
        operand2 = get_operand(ptr, 2, &is_imm2);       \
        assert(operand0.s.valid && operand1.s.valid && operand2.s.valid);   \
    } while (0);

#define GET_3_OPERANDS_NOCHECK()                        \
    do {                                                \
        operand0 = get_operand(ptr, 0, &is_imm0);       \
        operand1 = get_operand(ptr, 1, &is_imm1);       \
        operand2 = get_operand(ptr, 2, &is_imm2);       \
    } while (0);

static uint8_t get_next_spare_tmp_var() {
    uint8_t ret = -1;
    for (uint8_t i = 0; i < (1<<5); ++i) {
        if (tmp_var_available & (1<<i)) {
            ret = i;
            tmp_var_available &= ~(1<<i);
            break;
        }
    }
    assert(ret != -1);
    return ret;
}

static OperandType get_tmp_and_do_alloc(LLVMType type) {
    OperandType tmp;
    tmp.s.valid = 1;
    tmp.s.slot_type = SUB_SLOT_TMPT;
    tmp.s.slot_idx = get_next_spare_tmp_var();
    LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[type], tmpt_stack_names[tmp.s.slot_idx]);
    func_tmpt_alloca[tmp.s.slot_idx] = alloca_inst;
    func_tmpt_llvmtype[tmp.s.slot_idx] = type;
    return tmp;
}

static const char *get_next_var_name() {
    assert(ir_var_name_idx < sizeof(ir_var_name)/sizeof(const char *));
    return ir_var_name[ir_var_name_idx++];
}

static LLVMModuleRef create_module(const char *module_name) {
    LLVMContextRef context = LLVMGetGlobalContext();
    LLVMModuleRef module = LLVMModuleCreateWithNameInContext(module_name, context);

    LLVMSetTarget(module, "riscv64-unknown-linux-gnu");
    return module;
}

static void register_alias(OperandType lval, OperandType rval) {
    if (lval.s.slot_type == SUB_SLOT_TMPL) {
        alias_tmpl[lval.s.slot_idx] = rval;
    } else if (lval.s.slot_type == SUB_SLOT_TMPT) {
        alias_tmpt[lval.s.slot_idx] = rval;
    } else {
        assert(0);
    }
}

static void unregister_alias(OperandType operand) {
    if (operand.s.slot_type == SUB_SLOT_TMPL) {
        alias_tmpl[operand.s.slot_idx].i = 0;
    } else if (operand.s.slot_type == SUB_SLOT_TMPT) {
        alias_tmpt[operand.s.slot_idx].i = 0;
    } else {
        assert(0);
    }
}

static OperandType get_alias(OperandType operand) {
    if (operand.s.slot_type == SUB_SLOT_TMPL) {
        return alias_tmpl[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_TMPT) {
        return alias_tmpt[operand.s.slot_idx];
    } else {
        assert(0);
    }
}

static uint32_t has_alias(OperandType operand) {
    if (operand.s.slot_type == SUB_SLOT_TMPL) {
        return alias_tmpl[operand.s.slot_idx].s.valid;
    } else if (operand.s.slot_type == SUB_SLOT_TMPT) {
        return alias_tmpt[operand.s.slot_idx].s.valid;
    } else {
        assert(0);
    }
}

static LLVMValueRef get_stack_alloca(OperandType operand) {
    assert(operand.s.valid);
    LLVMValueRef alloca = NULL;
    if (operand.s.slot_type == SUB_SLOT_XREG) {
        alloca = func_xreg_alloca[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_TMPL) {
        assert(has_alias(operand) == 0);
        alloca = func_tmpl_alloca[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_TMPT) {
        assert(has_alias(operand) == 0);
        alloca = func_tmpt_alloca[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_XMM) {
        alloca = func_xmm_alloca[operand.s.slot_idx];
    } else {
        assert(0);
    }
    return alloca;
}

static LLVMType get_stack_llvmtype(OperandType operand) {
    assert(operand.s.valid);
    if (operand.s.slot_type == SUB_SLOT_XREG) {
        return func_xreg_llvmtype[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_TMPL) {
        return func_tmpl_llvmtype[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_TMPT) {
        return func_tmpt_llvmtype[operand.s.slot_idx];
    } else if (operand.s.slot_type == SUB_SLOT_XMM) {
        return func_xmm_llvmtype[operand.s.slot_idx];
    }
    assert(0);
}

static OperandType get_env_ptr() {
    OperandType tmp = get_tmp_and_do_alloc(LLVMInt64);
    LLVMTypeRef asm_return_type = LLVMInt64Type();
    LLVMTypeRef asm_param_types[] = {};
    LLVMTypeRef asm_function_type = LLVMFunctionType(asm_return_type, asm_param_types, 0, 0);
    //FIXME: handle AArch64 as well
    char asm_string[128];
    sprintf(asm_string, "mv $0, x25");
    const char *constraint_string = "=r";
    LLVMValueRef inline_asm = LLVMConstInlineAsm(asm_function_type, asm_string, constraint_string, /* has_side_effects */ 1, /* is_align_stack */ 0);
    LLVMValueRef val = LLVMBuildCall2(builder, asm_function_type, inline_asm, NULL, 0, get_next_var_name());
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
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, func_tmpt_alloca[tmp.s.slot_idx], LLVMPointerType(val_type, 0), get_next_var_name());
        LLVMBuildStore(builder, val, ptr);
    } else {
        LLVMType out_idx = get_stack_llvmtype(out);
        assert((val_tidx <= LLVMInt64 && out_idx <= LLVMInt64 && val_tidx <= out_idx) ||
               (val_tidx <= LLVMInt64 && out_idx > LLVMInt64) ||
               (val_tidx > LLVMInt64 && out_idx > LLVMInt64));
        if (val_tidx <= LLVMInt64 && out_idx <= LLVMInt64 && val_tidx < out_idx) {
            val = LLVMBuildZExt(builder, val, llvm_int_types[out_idx], get_next_var_name());
        } else if (val_tidx <= LLVMInt64 && out_idx > LLVMInt64) {
            uint8_t full_cnt = 128/llvm_vector_elem_bit_counts[val_tidx*2];
            LLVMValueRef constants[16];
            LLVMValueRef element_value = LLVMConstInt(llvm_int_types[val_tidx], 0, 0);
            for (int i = 0; i < full_cnt; i++) {
                constants[i] = element_value;
            }
            LLVMValueRef vec_zero = LLVMConstVector(constants, full_cnt);
            LLVMValueRef index = LLVMConstInt(LLVMInt64Type(), 0, 0);
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
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, func_tmpt_alloca[tmp.s.slot_idx], LLVMPointerType(type, 0), get_next_var_name());
        ret = LLVMBuildLoad2(builder, type, ptr, get_next_var_name());
    } else if (operand.s.slot_type == SUB_SLOT_ENV) {
        OperandType tmp = get_tmp_and_do_alloc(LLVMInt64);
        OperandType env = get_env_ptr();
        uint8_t buf[16];
        create_scalar_slot2_imm(buf, add_i64, tmp, env, operand.s.offset);
        translate_add_i64(add_i64, buf);
        LLVMValueRef ptr = LLVMBuildIntToPtr(builder, func_tmpt_alloca[tmp.s.slot_idx], LLVMPointerType(type, 0), get_next_var_name());
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

typedef LLVMValueRef (*LLVM_BIN_API)(LLVMBuilderRef B, LLVMValueRef LHS, LLVMValueRef RHS, const char *Name);

void translate_binary(OpCodeType opc, void *ptr, LLVM_BIN_API api) {
    uint32_t is_imm_l, is_imm_r, is_imm_out;
    OperandType operand_l, operand_r, output;
    uint32_t idx = opcoc[opc];
    output = get_operand(ptr, 0, &is_imm_out);
    operand_l = get_operand(ptr, idx, &is_imm_l);
    operand_r = get_operand(ptr, idx + 1, &is_imm_r);
    uint8_t is_vec = is_vector(ptr);
    LLVMType vtype = LLVMInvalidType;
    if (is_vec) {
        vtype = get_llvm_vector_type(ptr);
    }
    LLVMValueRef left = get_source_node_imm_or_stack(is_imm_l, operand_l, is_vec ? vtype : opciosz[opc][0]);
    LLVMValueRef right = get_source_node_imm_or_stack(is_imm_r, operand_r, is_vec ? vtype : opciosz[opc][0]);
    LLVMValueRef out_val = api(builder, left, right, get_next_var_name());
    do_store(out_val, opciosz[opc][2], output);
}

void translate_add_i64(OpCodeType opc, void *ptr) {
    uint32_t is_imm_l, is_imm_r, is_imm_out;
    OperandType operand_l, operand_r, output;
    uint32_t idx = opcoc[opc];
    output = get_operand(ptr, 0, &is_imm_out);
    operand_l = get_operand(ptr, idx, &is_imm_l);
    operand_r = get_operand(ptr, idx + 1, &is_imm_r);
    if (operand_r.s.valid == 0 && is_imm_r == 0) {
        assert(operand_l.s.slot_type == SUB_SLOT_XMM ||
               operand_l.s.slot_type == SUB_SLOT_ENV);
        register_alias(output, operand_l);
    } else {
        LLVMValueRef left = get_source_node_imm_or_stack(is_imm_l, operand_l, opciosz[opc][0]);
        LLVMValueRef right = get_source_node_imm_or_stack(is_imm_r, operand_r, opciosz[opc][0]);
        LLVMValueRef add_val = LLVMBuildAdd(builder, left, right, get_next_var_name());
        do_store(add_val, opciosz[opc][2], output);
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
    do_store(result, opciosz[opc][2], operand0);
}

void translate_count_zero(OpCodeType opc, void *ptr, const char *intrinsic) {
    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    GET_3_OPERANDS_NOCHECK();

    LLVMValueRef src1 = get_source_node_imm_or_stack(is_imm1, operand1, opciosz[opc][0]);
    LLVMValueRef src2 = get_source_node_imm_or_stack(is_imm2, operand2, opciosz[opc][0]);

    LLVMValueRef bool1 = LLVMBuildICmp(builder, LLVMIntEQ, src1, LLVMConstInt(llvm_int_types[LLVMInt64], 0, 0), get_next_var_name());

    LLVMBasicBlockRef bb_ctz_is_zero = LLVMAppendBasicBlock(llvm_func, get_next_var_name());
    LLVMBasicBlockRef bb_ctz_not_zero = LLVMAppendBasicBlock(llvm_func, get_next_var_name());
    LLVMBasicBlockRef bb_ctz_merge = LLVMAppendBasicBlock(llvm_func, get_next_var_name());

    LLVMBuildCondBr(builder, bool1, bb_ctz_is_zero, bb_ctz_not_zero);
    LLVMPositionBuilderAtEnd(builder, bb_ctz_is_zero);
    LLVMBuildBr(builder, bb_ctz_merge);

    LLVMTypeRef ctz_arg_types[] = {llvm_int_types[LLVMInt64], LLVMInt1Type()};
    LLVMTypeRef ctz_type = LLVMFunctionType(llvm_int_types[LLVMInt64], ctz_arg_types, 2, 0);
    LLVMValueRef ctz_func = LLVMAddFunction(module, intrinsic, ctz_type);
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
    do_store(phi, opciosz[opc][2], operand0);
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
    // shl
    OpCodeType tmp_opc = opciosz[opc][2] == LLVMInt64 ? shl_i64 : shl_i32;
    OperandType mask1 = get_tmp_and_do_alloc(opciosz[opc][2]);
    create_slot_imm2(buf, tmp_opc, mask1, 1, len.i);
    translate_binary(tmp_opc, buf, LLVMBuildShl);
    // sub
    tmp_opc = opciosz[opc][2] == LLVMInt64 ? sub_i64 : sub_i32;
    OperandType mask_not_shifted = get_tmp_and_do_alloc(opciosz[opc][2]);
    create_scalar_slot2_imm(buf, tmp_opc, mask_not_shifted, mask1, 1);
    translate_binary(tmp_opc, buf, LLVMBuildSub);
    // shl
    tmp_opc = opciosz[opc][2] == LLVMInt64 ? shl_i64 : shl_i32;
    OperandType mask_shifted = get_tmp_and_do_alloc(opciosz[opc][2]);
    create_scalar_slot2_imm(buf, tmp_opc, mask_shifted, mask_not_shifted, ofs.i);
    translate_binary(tmp_opc, buf, LLVMBuildShl);
    // xor
    tmp_opc = opciosz[opc][2] == LLVMInt64 ? xor_i64 : xor_i32;
    OperandType rev_mask_shifted = get_tmp_and_do_alloc(opciosz[opc][2]);
    create_scalar_slot2_imm(buf, tmp_opc, rev_mask_shifted, mask_shifted, -1UL);
    translate_binary(tmp_opc, buf, LLVMBuildXor);
    // and
    tmp_opc = opciosz[opc][2] == LLVMInt64 ? and_i64 : and_i32;
    OperandType part1 = get_tmp_and_do_alloc(opciosz[opc][2]);
    create_scalar_slot3(buf, tmp_opc, part1, operand1, rev_mask_shifted);
    translate_binary(tmp_opc, buf, LLVMBuildAnd);
    // and
    tmp_opc = opciosz[opc][2] == LLVMInt64 ? and_i64 : and_i32;
    OperandType part2_0 = get_tmp_and_do_alloc(opciosz[opc][2]);
    create_scalar_slot3(buf, tmp_opc, part2_0, operand2, mask_not_shifted);
    translate_binary(tmp_opc, buf, LLVMBuildAnd);
    // shl
    tmp_opc = opciosz[opc][2] == LLVMInt64 ? shl_i64 : shl_i32;
    OperandType part2_1 = get_tmp_and_do_alloc(opciosz[opc][2]);
    create_scalar_slot2_imm(buf, tmp_opc, part2_1, part2_0, ofs.i);
    translate_binary(tmp_opc, buf, LLVMBuildShl);
    // or
    tmp_opc = opciosz[opc][2] == LLVMInt64 ? or_i64 : or_i32;
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
    do_store(result, opciosz[opc][2], operand0);
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
    // shl
    OpCodeType tmp_opc = opciosz[opc][2] == LLVMInt64 ? shl_i64 : shl_i32;
    OperandType mask1 = get_tmp_and_do_alloc(opciosz[opc][2]);
    create_slot_imm2(buf, tmp_opc, mask1, 1, len.i);
    translate_binary(tmp_opc, buf, LLVMBuildShl);
    // sub
    tmp_opc = opciosz[opc][2] == LLVMInt64 ? sub_i64 : sub_i32;
    OperandType mask_not_shifted = get_tmp_and_do_alloc(opciosz[opc][2]);
    create_scalar_slot2_imm(buf, tmp_opc, mask_not_shifted, mask1, 1);
    translate_binary(tmp_opc, buf, LLVMBuildSub);
    // shr
    tmp_opc = opciosz[opc][2] == LLVMInt64 ? shr_i64 : shr_i32;
    OperandType arg_shifted = get_tmp_and_do_alloc(opciosz[opc][2]);
    create_scalar_slot2_imm(buf, tmp_opc, arg_shifted, operand1, ofs.i);
    translate_binary(tmp_opc, buf, LLVMBuildLShr);
    // and
    tmp_opc = opciosz[opc][2] == LLVMInt64 ? and_i64 : and_i32;
    create_scalar_slot3(buf, tmp_opc, operand0, arg_shifted, mask_not_shifted);
    translate_binary(tmp_opc, buf, LLVMBuildAnd);
}

void translate_mov(OpCodeType opc, void *ptr) {
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    GET_2_OPERANDS_NOCHECK();
    assert(opciosz[opc][1] <= opciosz[opc][0]);

    LLVMValueRef src = get_source_node_imm_or_stack(is_imm1, operand1, opciosz[opc][0]);
    if (opciosz[opc][1] < opciosz[opc][0]) {
        src = LLVMBuildTrunc(builder, src, llvm_int_types[opciosz[opc][1]], get_next_var_name());
    }
    do_store(src, opciosz[opc][2], operand0);
}

void translate_ld_env_xmm(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1, operand2;
    GET_2_OPERANDS();
    uint32_t is_imm;
    operand2 = get_operand(ptr, 2, &is_imm);

    if (operand1.s.slot_type == SUB_SLOT_ENV ||
        operand1.s.slot_type == SUB_SLOT_XMM) {
        translate_mov(opc, ptr);
    } else if (operand1.s.slot_type == SUB_SLOT_TMPL ||
               operand1.s.slot_type == SUB_SLOT_TMPT) {
        assert(has_alias(operand1) && is_imm);
        OperandType alias = get_alias(operand1);
        assert(alias.s.valid && alias.s.slot_type == SUB_SLOT_XMM);
        alias.s.offset += operand2.i;
        uint8_t buf[16];
        create_scalar_slot_env_imm(buf, opc, operand0, get_xmm_offset(alias.s.slot_idx) + alias.s.offset);
        translate_ld_env_xmm(opc, buf);
    }
}

typedef LLVMValueRef (*LLVM_EXT_API)(LLVMBuilderRef B, LLVMValueRef Val, LLVMTypeRef DestTy, const char *Name);

void translate_ext(OpCodeType opc, void *ptr, LLVM_EXT_API api) {
    OperandType operand0, operand1;
    GET_2_OPERANDS();

    LLVMValueRef src = get_source_node_imm_or_stack(0, operand1, opciosz[opc][0]);
    src = api(builder, src, llvm_int_types[opciosz[opc][2]], get_next_var_name());
    do_store(src, opciosz[opc][2], operand0);
}

void translate_ld_vec(OpCodeType opc, void *ptr) {
    OperandType operand0, operand1;
    GET_2_OPERANDS();
    LLVMType vtype = get_llvm_vector_type(ptr);
    LLVMValueRef src = get_source_node_imm_or_stack(0, operand1, vtype);
    do_store(src, vtype, operand0);
}

void translate_movcond_i32(OpCodeType opc, void *ptr) {
}

void translate_movcond_i64(OpCodeType opc, void *ptr) {
}

void translate_mov_i64_const(OpCodeType opc, void *ptr) {
}

void translate_mov_vec(OpCodeType opc, void *ptr) {
}

void translate_mul_i32(OpCodeType opc, void *ptr) {
}

void translate_mul_i64(OpCodeType opc, void *ptr) {
}

void translate_mulsh_i64(OpCodeType opc, void *ptr) {
}

void translate_muluh_i64(OpCodeType opc, void *ptr) {
}

void translate_neg_i32(OpCodeType opc, void *ptr) {
}

void translate_neg_i64(OpCodeType opc, void *ptr) {
}

void translate_negsetcond_i64(OpCodeType opc, void *ptr) {
}

void translate_not_i64(OpCodeType opc, void *ptr) {
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    operand0 = get_operand(ptr, 0, &is_imm0);
    operand1 = get_operand(ptr, 1, &is_imm1);
    assert(operand1.s.valid);

    uint8_t buf[16];
    create_scalar_slot2_imm(buf, xor_i64, operand0, operand1, -1UL);
    translate_binary(xor_i64, buf, LLVMBuildXor);
}

void translate_not_vec(OpCodeType opc, void *ptr) {
    uint32_t is_imm0, is_imm1;
    OperandType operand0, operand1;
    operand0 = get_operand(ptr, 0, &is_imm0);
    operand1 = get_operand(ptr, 1, &is_imm1);
    assert(operand1.s.valid);
    AttrSrcInfo ai;
    ai.p.ves = get_llvm_vector_type(ptr) - LLVMVector16xi8;

    uint8_t buf[16];
    create_vector_slot2_vimm(buf, xor_vec, ai, operand0, operand1, -1UL);
    translate_binary(xor_vec, buf, LLVMBuildXor);
}

void translate_push_ret_addr(OpCodeType opc, void *ptr) {
}

void translate_qemu_ld2_i128(OpCodeType opc, void *ptr) {
}

void translate_qemu_ld_i32(OpCodeType opc, void *ptr) {
}

void translate_qemu_ld_i64(OpCodeType opc, void *ptr) {
}

void translate_qemu_st2_i128(OpCodeType opc, void *ptr) {
}

void translate_qemu_st_i32(OpCodeType opc, void *ptr) {
}

void translate_qemu_st_i64(OpCodeType opc, void *ptr) {
}

void translate_ret(OpCodeType opc, void *ptr) {
}

void translate_rotr_i32(OpCodeType opc, void *ptr) {
}

void translate_rotr_i64(OpCodeType opc, void *ptr) {
}

void translate_setcond_i64(OpCodeType opc, void *ptr) {
}

void translate_sextract_i64(OpCodeType opc, void *ptr) {
}

void translate_st16_i32(OpCodeType opc, void *ptr) {
}

void translate_st16_i64(OpCodeType opc, void *ptr) {
}

void translate_st32_i64(OpCodeType opc, void *ptr) {
}

void translate_st_i32(OpCodeType opc, void *ptr) {
}

void translate_st_i64(OpCodeType opc, void *ptr) {
}

void translate_st_vec(OpCodeType opc, void *ptr) {
}

void translate_umax_vec(OpCodeType opc, void *ptr) {
}

void translate_umin_vec(OpCodeType opc, void *ptr) {
}

void translate_bswap64_i64(OpCodeType opc, void *ptr) {
}

void translate_set_label(OpCodeType opc, void *ptr) {
}

void translate_brcond_i64(OpCodeType opc, void *ptr) {
}

void translate_jmp_direct(OpCodeType opc, void *ptr) {
}

void translate_call_direct(OpCodeType opc, void *ptr) {
}

void translate_discard(OpCodeType opc, void *ptr) {
}

void translate_call(OpCodeType opc, void *ptr) {
}

static void cleanup_func_resource() {
    reset_instr_buffer();
    for (int i = 0; i < (1<<5); ++i) {
        alias_tmpl[i].i = 0;
        alias_tmpt[i].i = 0;
    }
    tmp_var_available = 0;
    ir_var_name_idx = 0;
}

void handle_func(uint64_t val) {
    printf("func %lx\n", val);
    ir_var_name_idx = 0;
    tmp_var_available = 0xffffffff;
    void *ptr_init = get_instr_buffer();
    void *ptr_max = ptr_init + get_instr_buffer_size();
    void *ptr;
    /// Loop through all xreg/slot/xmm, handle arguments, stack alloc/store etc.
    uint32_t xreg_valid = 0, tmpl_valid = 0, tmpt_valid = 0, xmm_valid = 0, is_imm = 0;
    LLVMType tmpl_bits_type[1<<5] = {0};
    LLVMType tmpt_bits_type[1<<5] = {0};
    int instr_idx = 0;
    for (ptr = ptr_init; ptr < ptr_max; ptr = move_to_next(ptr), instr_idx += 1) {
        uint32_t slot_idx = 0;
        OperandType operand;
        OpCodeType opc = get_opcode(ptr);
        uint8_t is_vec = is_vector(ptr);
        LLVMType vtype = LLVMInvalidType;
        if (is_vec) {
          vtype = get_llvm_vector_type(ptr);
        }
        do {
            operand = get_operand(ptr, slot_idx, &is_imm);
            // End-of-operands
            if (is_imm == 0 && operand.s.valid == 0) {
                break;
            }
            uint32_t shifted_slot_bit = (1 << operand.s.slot_idx);
            LLVMType operand_type = vtype == LLVMInvalidType ?
                                 opciosz[opc][slot_idx < opcoc[opc] ? 2 : 0] : vtype;
            if (is_imm == 0) {
                if (operand.s.slot_type == SUB_SLOT_XREG) {
                    xreg_valid |= shifted_slot_bit;
                } else if (operand.s.slot_type == SUB_SLOT_TMPL) {
                    tmpl_valid |= (1 << operand.s.slot_idx);
                    if (tmpl_bits_type[operand.s.slot_idx] < operand_type) {
                        tmpl_bits_type[operand.s.slot_idx] = operand_type;
                    }
                } else if (operand.s.slot_type == SUB_SLOT_TMPT) {
                    tmpt_valid |= shifted_slot_bit;
                    tmp_var_available &= ~shifted_slot_bit;
                    if (tmpt_bits_type[operand.s.slot_idx] < operand_type) {
                        tmpt_bits_type[operand.s.slot_idx] = operand_type;
                    }
                } else if (operand.s.slot_type == SUB_SLOT_XMM) {
                    xmm_valid |= shifted_slot_bit;
                }
            }
            slot_idx += 1;
        } while (1);
    }

    char func_name[64];
    sprintf(func_name, "func_%lx", val);
    int total_cnt = xmm_valid == 0 ? FIXED_PARAM_COUNT : FIXED_VECTOR_PARAM_COUNT;
    llvm_func = LLVMAddFunction(module, func_name,
        LLVMFunctionType(LLVMVoidType(), xmm_valid == 0 ? fixed_param_types : fixed_vector_param_types,
                         total_cnt, 0));
    for (int j = 0; j < total_cnt; j++) {
        LLVMValueRef param = LLVMGetParam(llvm_func, j);
        LLVMSetValueName(param, fixed_vector_arg_names[j]);
    }
    // FIXME: qemuaot
    LLVMSetFunctionCallConv(llvm_func, 124);

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);

    for (XRegType x = 0; x < XREG_MAX; ++x) {
        if (xreg_valid & (1 << x)) {
            LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, fixed_vector_param_types[x], fixed_vector_stack_names[x]);
            LLVMSetAlignment(alloca_inst, 8);
            func_xreg_alloca[x] = alloca_inst;
            func_xreg_llvmtype[x] = fixed_vector_param_llvmtypes[x];
            LLVMSetAlignment(LLVMBuildStore(builder, LLVMGetParam(llvm_func, x), alloca_inst), 8);
        }
    }

    if (tmpl_valid) {
        for (int i = 0; i < (1<<5); ++i) {
            if (tmpl_valid & (1 << i)) {
                assert(tmpl_bits_type[i]);
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[tmpl_bits_type[i]], tmpl_stack_names[i]);
                func_tmpl_alloca[i] = alloca_inst;
                func_tmpl_llvmtype[i] = tmpl_bits_type[i];
                LLVMSetAlignment(alloca_inst, tmpl_bits_type[i] <= LLVMInt64 ? 8 : 16);
            }
        }
    }
    if (tmpt_valid) {
        for (int i = 0; i < (1<<5); ++i) {
            if (tmpt_valid & (1 << i)) {
                assert(tmpt_bits_type[i]);
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[tmpt_bits_type[i]], tmpt_stack_names[i]);
                func_tmpt_alloca[i] = alloca_inst;
                func_tmpt_llvmtype[i] = tmpt_bits_type[i];
                LLVMSetAlignment(alloca_inst, tmpt_bits_type[i] <= LLVMInt64 ? 8 : 16);
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
                LLVMValueRef intrinsic_func = LLVMAddFunction(module, "llvm.vector.extract.v2i64.nxv1i64", intrinsic_func_type);
                LLVMValueRef index_0 = LLVMConstInt(LLVMInt64Type(), 0, 0);
                LLVMValueRef call_args[] = {LLVMGetParam(llvm_func, (FIXED_PARAM_COUNT + i)), index_0};
                LLVMValueRef call_inst = LLVMBuildCall2(builder, intrinsic_func_type, intrinsic_func, call_args, 2, get_next_var_name());
                LLVMSetTailCall(call_inst, 1);
                LLVMBuildStore(builder, call_inst, func_xmm_alloca[i]);
            }
        }
        for (int i = (1<<5)-2; i < (1<<5); ++i) {
            if (xmm_valid & (1 << i)) {
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[LLVMVector2xi64], xmm_tmp_stack_names[i-((1<<5)-2)]);
                func_xmm_alloca[i] = alloca_inst;
                func_xmm_llvmtype[i] = LLVMVector2xi64;
                LLVMSetAlignment(alloca_inst, 16);
            }
        }
    }

    // Handle each IR translation
    for (ptr = ptr_init; ptr < ptr_max; ptr = move_to_next(ptr), instr_idx += 1) {
        OpCodeType opc = get_opcode(ptr);
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
            translate_movcond_i32(opc, ptr);
            break;
        case movcond_i64:
            translate_movcond_i64(opc, ptr);
            break;
        case mov_i64_const:
            translate_mov_i64_const(opc, ptr);
            break;
        case mov_vec:
            translate_mov_vec(opc, ptr);
            break;
        case mul_i32:
            translate_mul_i32(opc, ptr);
            break;
        case mul_i64:
            translate_mul_i64(opc, ptr);
            break;
        case mulsh_i64:
            translate_mulsh_i64(opc, ptr);
            break;
        case muluh_i64:
            translate_muluh_i64(opc, ptr);
            break;
        case neg_i32:
            translate_neg_i32(opc, ptr);
            break;
        case neg_i64:
            translate_neg_i64(opc, ptr);
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
            translate_qemu_ld_i32(opc, ptr);
            break;
        case qemu_ld_i64:
            translate_qemu_ld_i64(opc, ptr);
            break;
        case qemu_st2_i128:
            translate_qemu_st2_i128(opc, ptr);
            break;
        case qemu_st_i32:
            translate_qemu_st_i32(opc, ptr);
            break;
        case qemu_st_i64:
            translate_qemu_st_i64(opc, ptr);
            break;
        case ret:
            translate_ret(opc, ptr);
            break;
        case rotr_i32:
            translate_rotr_i32(opc, ptr);
            break;
        case rotr_i64:
            translate_rotr_i64(opc, ptr);
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
            translate_st16_i32(opc, ptr);
            break;
        case st16_i64:
            translate_st16_i64(opc, ptr);
            break;
        case st32_i64:
            translate_st32_i64(opc, ptr);
            break;
        case st_i32:
            translate_st_i32(opc, ptr);
            break;
        case st_i64:
            translate_st_i64(opc, ptr);
            break;
        case st_vec:
            translate_st_vec(opc, ptr);
            break;
        case sub_i32:
        case sub_i64:
            translate_binary(opc, ptr, LLVMBuildSub);
            break;
        case sub_vec:
            translate_binary(opc, ptr, LLVMBuildSub);
            break;
        case umax_vec:
            translate_umax_vec(opc, ptr);
            break;
        case umin_vec:
            translate_umin_vec(opc, ptr);
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

    LLVMBuildRetVoid(builder);

    cleanup_func_resource();
}

void module_prolog() {
    module = create_module("qemuaot");
    builder = LLVMCreateBuilder();

    // Parameter setup (same for all functions)
    LLVMTypeRef vscale_i64 = LLVMScalableVectorType(LLVMInt64Type(), 1); // <1 x i64>
    const char *base_names[20] = {
        "rax", "rcx", "rdx", "rbx",
        "rsp", "rbp", "rsi", "rdi",
        "r8", "r9", "r10", "r11",
        "r12", "r13", "r14", "r15",
        "cc_src", "cc_dst", "cc_op", "rip"
    };
    for (int i = 0; i < FIXED_PARAM_COUNT; i++) {
        if (i < 16) {
            fixed_param_types[i] = LLVMInt64Type();
            fixed_vector_param_types[i] = LLVMInt64Type();
            fixed_vector_param_llvmtypes[i] = LLVMInt64;
        } else if (i == 16 || i == 17 || i == 19) {
            fixed_param_types[i] = LLVMInt64Type();
            fixed_vector_param_types[i] = LLVMInt64Type();
            fixed_vector_param_llvmtypes[i] = LLVMInt64;
        } else if (i == 18) {
            fixed_param_types[i] = LLVMInt32Type();
            fixed_vector_param_types[i] = LLVMInt32Type();
            fixed_vector_param_llvmtypes[i] = LLVMInt32;
        }
        fixed_arg_names[i] = base_names[i];
        fixed_vector_arg_names[i] = base_names[i];
    }
    static char extra_name_buf[30][16];
    static char stack_name_buf[FIXED_VECTOR_PARAM_COUNT][16];
    static char tmpl_name_buf[1<<5][16];
    static char tmpt_name_buf[1<<5][16];
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
        snprintf(tmpl_name_buf[i], sizeof(tmpl_name_buf[i]), "loc%d.stack", i);
        tmpl_stack_names[i] = tmpl_name_buf[i];
        snprintf(tmpt_name_buf[i], sizeof(tmpt_name_buf[i]), "tmp%d.stack", i);
        tmpt_stack_names[i] = tmpt_name_buf[i];
    }
    static char ir_var_name_buffer[('z'-'a'+1)*('z'-'a'+1)][3];
    for (char c1 = 'a'; c1 <= 'z'; ++c1) {
        for (char c2 = 'a'; c2 <= 'z'; ++c2) {
            int idx = (c1 - 'a') * ('z' - 'a' + 1) + (c2 - 'a');
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
  module_prolog();
  parse_tcg_instructions(argv[1]);
  module_epilog();
  return 0;
}
