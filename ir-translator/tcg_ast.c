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
#define FIXED_PARAM_COUNT           20
static LLVMTypeRef fixed_param_types[FIXED_PARAM_COUNT] = {NULL};
static const char *fixed_arg_names[FIXED_PARAM_COUNT] = {NULL};
#define FIXED_VECTOR_PARAM_COUNT   (20 + 15 * 2)
static LLVMTypeRef fixed_vector_param_types[FIXED_VECTOR_PARAM_COUNT] = {NULL};
static const char *fixed_vector_arg_names[FIXED_VECTOR_PARAM_COUNT] = {NULL};
static const char *fixed_vector_stack_names[FIXED_VECTOR_PARAM_COUNT] = {NULL};
static const char *tmpl_stack_names[1<<5] = {NULL};
static const char *tmpt_stack_names[1<<5] = {NULL};
static const char *ir_var_name[('z'-'a'+1)*('z'-'a'+1)] = {NULL};
static int ir_var_name_idx = 0;
static LLVMTypeRef llvm_int_types[LLVMMAXType] = {NULL};
static uint8_t llvm_vector_elem_bit_counts[LLVMMAXType * 2] = {0};
static LLVMValueRef func_xreg_alloca[1 << 5] = {NULL};
static LLVMValueRef func_tmpl_alloca[1 << 5] = {NULL};
static LLVMValueRef func_tmpt_alloca[1 << 5] = {NULL};
static uint32_t env_var_offset[ENVVarMAX] = {0};
static OperandType alias_tmpl[1<<5] = {0};
static OperandType alias_tmpt[1<<5] = {0};
static uint32_t tmp_var_available = 0;

void translate_xor_i64(OpCodeType opc, void *ptr);
void translate_not_i64(OpCodeType opc, void *ptr);
void translate_and_i64(OpCodeType opc, void *ptr);

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
    } else {
        assert(0);
    }
    return alloca;
}

static LLVMValueRef get_source_node_imm_or_stack(uint32_t is_imm, OperandType operand, LLVMTypeRef type, LLVMType tidx) {
    assert(type);
    assert(tidx != LLVMInvalidType && tidx < LLVMMAXType);
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
        LLVMTypeRef asm_return_type = LLVMInt64Type();
        LLVMTypeRef asm_param_types[] = {};
        LLVMTypeRef asm_function_type = LLVMFunctionType(asm_return_type, asm_param_types, 0, 0);
        //FIXME: AArch64
        char asm_string[128];
        sprintf(asm_string, "ldr $0, [x25, #%d]", env_var_offset[operand.s.slot_idx]);
        const char *constraint_string = "=r";
        LLVMValueRef inline_asm = LLVMConstInlineAsm(asm_function_type, asm_string, constraint_string, /* has_side_effects */ 1, /* is_align_stack */ 0);
        ret = LLVMBuildCall2(builder, asm_function_type, inline_asm, NULL, 0, ir_var_name[ir_var_name_idx]);
        ir_var_name_idx += 1;
    } else {
        ret = LLVMBuildLoad2(builder, type, get_stack_alloca(operand), ir_var_name[ir_var_name_idx]);
        ir_var_name_idx += 1;
    }
    return ret;
}

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

typedef LLVMValueRef (*LLVM_BIN_API)(LLVMBuilderRef B, LLVMValueRef LHS, LLVMValueRef RHS, const char *Name);

void translate_binary(OpCodeType opc, void *ptr, LLVM_BIN_API api) {
    uint32_t is_imm_l, is_imm_r, is_imm_out;
    OperandType operand_l, operand_r, output;
    uint32_t idx = opcoc[opc];
    output = get_operand(ptr, 0, &is_imm_out);
    operand_l = get_operand(ptr, idx, &is_imm_l);
    operand_r = get_operand(ptr, idx + 1, &is_imm_r);
    uint8_t is_vec = is_vector(ptr);
    LLVMValueRef left = get_source_node_imm_or_stack(is_imm_l, operand_l, is_vec ? llvm_int_types[get_llvm_vector_type(ptr)] : llvm_int_types[opciosz[opc][0]], is_vec ? get_llvm_vector_type(ptr) : opciosz[opc][0]);
    LLVMValueRef right = get_source_node_imm_or_stack(is_imm_r, operand_r, is_vec ? llvm_int_types[get_llvm_vector_type(ptr)] : llvm_int_types[opciosz[opc][0]], is_vec ? get_llvm_vector_type(ptr) : opciosz[opc][0]);
    LLVMValueRef out_val = api(builder, left, right, ir_var_name[ir_var_name_idx]);
    ir_var_name_idx += 1;
    LLVMBuildStore(builder, out_val, get_stack_alloca(output));
}

static void translate_add_i64(OpCodeType opc, void *ptr) {
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
        LLVMValueRef left = get_source_node_imm_or_stack(is_imm_l, operand_l, llvm_int_types[opciosz[opc][0]], opciosz[opc][0]);
        LLVMValueRef right = get_source_node_imm_or_stack(is_imm_r, operand_r, llvm_int_types[opciosz[opc][0]], opciosz[opc][0]);
        LLVMValueRef add_val = LLVMBuildAdd(builder, left, right, ir_var_name[ir_var_name_idx]);
        ir_var_name_idx += 1;
        LLVMBuildStore(builder, add_val, get_stack_alloca(output));
    }
}

void translate_add_vec(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildAdd);
}

void translate_andc_i64(OpCodeType opc, void *ptr) {
    uint8_t tmp_idx = get_next_spare_tmp_var();
    LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[LLVMInt64], tmpt_stack_names[tmp_idx]);
    func_tmpt_alloca[tmp_idx] = alloca_inst;

    uint32_t is_imm0, is_imm1, is_imm2;
    OperandType operand0, operand1, operand2;
    operand0 = get_operand(ptr, 0, &is_imm0);
    operand1 = get_operand(ptr, 1, &is_imm1);
    operand2 = get_operand(ptr, 2, &is_imm2);

    assert(is_imm2 == 0);
    Instr4B i_not;
    i_not.instr_type = SIZE4B;
    i_not.opc = not_i64;
    i_not.slot0_type = SUB_SLOT_TMPT;
    i_not.slot0_idx = tmp_idx;
    i_not.slot1_type = operand2.s.slot_type;
    i_not.slot1_idx = operand2.s.slot_idx;
    i_not.attr_type = SUB_ATTR_INVALID;
    translate_not_i64(not_i64, &i_not);

    assert(is_imm1 == 0);
    Instr1B4 i_and;
    i_and.instr_type = SIZEXB;
    i_and.instr_type_ext = Instr1B4_ext;
    i_and.opc = and_i64;
    i_and.slot0_type = operand0.s.slot_type;
    i_and.slot0_idx = operand0.s.slot_idx;
    i_and.slot1_type = operand1.s.slot_type;
    i_and.slot1_idx = operand1.s.slot_idx;
    i_and.slot2_type = SUB_SLOT_TMPT;
    i_and.slot2_idx = tmp_idx;
    translate_and_i64(and_i64, &i_and);
}

void translate_andc_vec(OpCodeType opc, void *ptr) {
}

void translate_and_i64(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildAnd);
}

void translate_and_vec(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildAnd);
}

void translate_bswap32_i64(OpCodeType opc, void *ptr) {
}

void translate_clz_i64(OpCodeType opc, void *ptr) {
}

void translate_cmp_vec(OpCodeType opc, void *ptr) {
}

void translate_ctz_i64(OpCodeType opc, void *ptr) {
}

void translate_deposit_i32(OpCodeType opc, void *ptr) {
}

void translate_deposit_i64(OpCodeType opc, void *ptr) {
}

void translate_dupm_vec(OpCodeType opc, void *ptr) {
}

void translate_extract2_i64(OpCodeType opc, void *ptr) {
}

void translate_extract_i32(OpCodeType opc, void *ptr) {
}

void translate_extract_i64(OpCodeType opc, void *ptr) {
}

void translate_extrl_i64_i32(OpCodeType opc, void *ptr) {
}

void translate_extu_i32_i64(OpCodeType opc, void *ptr) {
}

void translate_ld32s_i64(OpCodeType opc, void *ptr) {
}

void translate_ld32u_i64(OpCodeType opc, void *ptr) {
}

void translate_ld8u_i64(OpCodeType opc, void *ptr) {
}

void translate_ld_i32(OpCodeType opc, void *ptr) {
}

void translate_ld_i64(OpCodeType opc, void *ptr) {
}

void translate_ld_vec(OpCodeType opc, void *ptr) {
}

void translate_movcond_i32(OpCodeType opc, void *ptr) {
}

void translate_movcond_i64(OpCodeType opc, void *ptr) {
}

void translate_mov_i32(OpCodeType opc, void *ptr) {
}

void translate_mov_i64(OpCodeType opc, void *ptr) {
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
    assert(is_imm1 == 0);
    Instr1B44 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B44_ext;
    i.opc = xor_i64;
    i.slot0_type = operand0.s.slot_type;
    i.slot0_idx = operand0.s.slot_idx;
    i.slot1_type = operand1.s.slot_type;
    i.slot1_idx = operand1.s.slot_idx;
    i.imm = -1;
    translate_xor_i64(xor_i64, (void *)&i);
}

void translate_or_i64(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildOr);
}

void translate_or_vec(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildOr);
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

void translate_sar_i64(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildAShr);
}

void translate_setcond_i64(OpCodeType opc, void *ptr) {
}

void translate_sextract_i64(OpCodeType opc, void *ptr) {
}

void translate_shl_i64(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildShl);
}

void translate_shli_vec(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildShl);
}

void translate_shr_i64(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildLShr);
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

void translate_sub_i64(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildSub);
}

void translate_sub_vec(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildSub);
}

void translate_umax_vec(OpCodeType opc, void *ptr) {
}

void translate_umin_vec(OpCodeType opc, void *ptr) {
}

void translate_xor_i64(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildXor);
}

void translate_xor_vec(OpCodeType opc, void *ptr) {
    translate_binary(opc, ptr, LLVMBuildXor);
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
}

void handle_func(uint64_t val) {
    printf("func %lx\n", val);
    tmp_var_available = 0xffffffff;
    void *ptr_init = get_instr_buffer();
    void *ptr_max = ptr_init + get_instr_buffer_size();
    void *ptr;
    /// Loop through all xreg/slot/xmm, handle arguments, stack alloc/store etc.
    int tmpl_dirty = 0, tmpt_dirty = 0;
    uint32_t xreg_valid = 0, tmpl_valid = 0, tmpt_valid = 0, is_imm = 0;
    uint8_t tmpl_bits_type[1<<5] = {0};
    uint8_t tmpt_bits_type[1<<5] = {0};
    uint64_t xmm_valid = 0;
    int instr_idx = 0;
    for (ptr = ptr_init; ptr < ptr_max; ptr = move_to_next(ptr), instr_idx += 1) {
        uint32_t slot_idx = 0;
        OperandType operand;
        OpCodeType opc = get_opcode(ptr);
        do {
            operand = get_operand(ptr, slot_idx, &is_imm);
            if (is_imm == 0 && operand.s.valid == 0) {
                break;
            }
            if (is_imm == 0) {
                if (operand.s.slot_type == SUB_SLOT_XREG) {
                    xreg_valid |= (1 << operand.s.slot_idx);
                } else if (operand.s.slot_type == SUB_SLOT_TMPL) {
                    tmpl_dirty = 1;
                    tmpl_valid |= (1 << operand.s.slot_idx);
                    if (tmpl_bits_type[operand.s.slot_idx] < opciosz[opc][slot_idx < opcoc[opc] ? 2 : 0]) {
                        tmpl_bits_type[operand.s.slot_idx] = opciosz[opc][slot_idx < opcoc[opc] ? 2 : 0];
                    }
                } else if (operand.s.slot_type == SUB_SLOT_TMPT) {
                    tmpt_dirty = 1;
                    tmpt_valid |= (1 << operand.s.slot_idx);
                    tmp_var_available &= ~(1 << operand.s.slot_idx);
                    if (tmpt_bits_type[operand.s.slot_idx] < opciosz[opc][slot_idx < opcoc[opc] ? 2 : 0]) {
                        tmpt_bits_type[operand.s.slot_idx] = opciosz[opc][slot_idx < opcoc[opc] ? 2 : 0];
                    }
                    assert(tmpt_bits_type[operand.s.slot_idx]);
                } else if (operand.s.slot_type == SUB_SLOT_XMM) {
                    xmm_valid |= (1UL << operand.s.slot_idx);
                }
            }
            slot_idx += 1;
        } while (1);
    }

    char func_name[64];
    sprintf(func_name, "func_%lx", val);
    int total_cnt = xmm_valid == 0 ? FIXED_PARAM_COUNT : FIXED_VECTOR_PARAM_COUNT;
    LLVMValueRef llvm_func = LLVMAddFunction(module, func_name,
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
            LLVMSetAlignment(LLVMBuildStore(builder, LLVMGetParam(llvm_func, x), alloca_inst), 8);
        }
    }

    if (tmpl_dirty) {
        for (int i = 0; i < (1<<5); ++i) {
            if (tmpl_valid & (1 << i)) {
                assert(tmpl_bits_type[i]);
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[tmpl_bits_type[i]], tmpl_stack_names[i]);
                func_tmpl_alloca[i] = alloca_inst;
                LLVMSetAlignment(alloca_inst, tmpl_bits_type[i] <= LLVMInt64 ? 8 : 16);
            }
        }
    }
    if (tmpt_dirty) {
        for (int i = 0; i < (1<<5); ++i) {
            if (tmpt_valid & (1 << i)) {
                assert(tmpt_bits_type[i]);
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, llvm_int_types[tmpt_bits_type[i]], tmpt_stack_names[i]);
                func_tmpt_alloca[i] = alloca_inst;
                LLVMSetAlignment(alloca_inst, tmpt_bits_type[i] <= LLVMInt64 ? 8 : 16);
            }
        }
    }

    // Handle each IR translation
    ir_var_name_idx = 0;
    for (ptr = ptr_init; ptr < ptr_max; ptr = move_to_next(ptr), instr_idx += 1) {
        OpCodeType opc = get_opcode(ptr);
        switch (opc) {
        case add_i64:
            translate_add_i64(opc, ptr);
            break;
        case add_vec:
            translate_add_vec(opc, ptr);
            break;
        case andc_i64:
            translate_andc_i64(opc, ptr);
            break;
        case andc_vec:
            translate_andc_vec(opc, ptr);
            break;
        case and_i64:
            translate_and_i64(opc, ptr);
            break;
        case and_vec:
            translate_and_vec(opc, ptr);
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
            translate_deposit_i32(opc, ptr);
            break;
        case deposit_i64:
            translate_deposit_i64(opc, ptr);
            break;
        case dupm_vec:
            translate_dupm_vec(opc, ptr);
            break;
        case extract2_i64:
            translate_extract2_i64(opc, ptr);
            break;
        case extract_i32:
            translate_extract_i32(opc, ptr);
            break;
        case extract_i64:
            translate_extract_i64(opc, ptr);
            break;
        case extrl_i64_i32:
            translate_extrl_i64_i32(opc, ptr);
            break;
        case extu_i32_i64:
            translate_extu_i32_i64(opc, ptr);
            break;
        case ld32s_i64:
            translate_ld32s_i64(opc, ptr);
            break;
        case ld32u_i64:
            translate_ld32u_i64(opc, ptr);
            break;
        case ld8u_i64:
            translate_ld8u_i64(opc, ptr);
            break;
        case ld_i32:
            translate_ld_i32(opc, ptr);
            break;
        case ld_i64:
            translate_ld_i64(opc, ptr);
            break;
        case ld_vec:
            translate_ld_vec(opc, ptr);
            break;
        case movcond_i32:
            translate_movcond_i32(opc, ptr);
            break;
        case movcond_i64:
            translate_movcond_i64(opc, ptr);
            break;
        case mov_i32:
            translate_mov_i32(opc, ptr);
            break;
        case mov_i64:
            translate_mov_i64(opc, ptr);
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
        case or_i64:
            translate_or_i64(opc, ptr);
            break;
        case or_vec:
            translate_or_vec(opc, ptr);
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
            translate_sar_i64(opc, ptr);
            break;
        case setcond_i64:
            translate_setcond_i64(opc, ptr);
            break;
        case sextract_i64:
            translate_sextract_i64(opc, ptr);
            break;
        case shl_i64:
            translate_shl_i64(opc, ptr);
            break;
        case shli_vec:
            translate_shli_vec(opc, ptr);
            break;
        case shr_i64:
            translate_shr_i64(opc, ptr);
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
        case sub_i64:
            translate_sub_i64(opc, ptr);
            break;
        case sub_vec:
            translate_sub_vec(opc, ptr);
            break;
        case umax_vec:
            translate_umax_vec(opc, ptr);
            break;
        case umin_vec:
            translate_umin_vec(opc, ptr);
            break;
        case xor_i64:
            translate_xor_i64(opc, ptr);
            break;
        case xor_vec:
            translate_xor_vec(opc, ptr);
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
        } else if (i == 16 || i == 17 || i == 19) {
            fixed_param_types[i] = LLVMInt64Type();
            fixed_vector_param_types[i] = LLVMInt64Type();
        } else if (i == 18) {
            fixed_param_types[i] = LLVMInt32Type();
            fixed_vector_param_types[i] = LLVMInt32Type();
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
        snprintf(extra_name_buf[i * 2], sizeof(extra_name_buf[i * 2]), "xmm%d", i);
        snprintf(extra_name_buf[i * 2 + 1], sizeof(extra_name_buf[i * 2 + 1]), "ymm%d_h", i);
        fixed_vector_arg_names[idx] = extra_name_buf[i * 2];
        fixed_vector_arg_names[idx + 1] = extra_name_buf[i * 2 + 1];
    }
    for (int i = 0; i < FIXED_VECTOR_PARAM_COUNT; ++i) {
        snprintf(stack_name_buf[i], sizeof(stack_name_buf[i]), "%s.stack", fixed_vector_arg_names[i]);
        fixed_vector_stack_names[i] = stack_name_buf[i];
    }
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
