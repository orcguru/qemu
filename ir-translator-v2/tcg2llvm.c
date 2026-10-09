/*
 * FIXME: copyright
 */
#include <stdio.h>
#include "tcg2llvm.h"
#include "mapper.h"
#include "util.h"
#include "mapper_util.h"
#include <assert.h>
#include "tcg_llvm_tag.h"

typedef LLVMValueRef (*LLVM_BIN_API)(LLVMBuilderRef B, LLVMValueRef LHS, LLVMValueRef RHS, const char *Name);

void translate_common(LLVMBuilderRef builder, LLVM_BIN_API llvm_api, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char name_buf[32] = {0};
    LLVMValueRef in1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef in2 = get_input_val_for_operand(&u->operands[2], stack, prefix);
    LLVMValueRef out = llvm_api(builder, in1, in2, assemble_name_2(&name_buf[0], sizeof(name_buf), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix);
}

void translate_addci(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char name_buf[32] = {0};
    LLVMValueRef in1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    LLVMValueRef in2 = get_input_val_for_operand(&u->operands[2], stack, prefix);
    LLVMValueRef sum = LLVMBuildAdd(builder, in1, in2, assemble_name_2(&name_buf[0], sizeof(name_buf), prefix, "sum"));
    LLVMValueRef ca = build_load_with_alignment(builder, LLVMInt1Type(), stack->carry, assemble_name_2(&name_buf[0], sizeof(name_buf), prefix, "carry"), 8);
    LLVMValueRef ca_ext = LLVMBuildZExt(builder, ca, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&name_buf[0], sizeof(name_buf), LLVMGetValueName(ca), "zext"));
    LLVMValueRef out = LLVMBuildAdd(builder, sum, ca_ext, assemble_name_2(&name_buf[0], sizeof(name_buf), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix);
}

static LLVMBasicBlockRef get_bb(LLVMValueRef F, const char *name) {
    LLVMBasicBlockRef bb = LLVMGetFirstBasicBlock(F);
    while (bb != NULL) {
        const char *block_name = LLVMGetBasicBlockName(bb);
        if (block_name != NULL && strcmp(block_name, name) == 0) {
            return bb;
        }
        bb = LLVMGetNextBasicBlock(bb);
    }
    return NULL;
}

void translate_set_label(LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    assert(u->operands[0].kind == OP_LABEL);
    char label_name[16] = {0};
    sprintf(label_name, "bb_L%d", u->operands[0].label);
    LLVMBasicBlockRef label = get_bb(F, &label_name[0]);
    if (!label) {
        label = LLVMAppendBasicBlock(F, &label_name[0]);
    }
    start_llvm_bb(label, stack);
}

void translate_br(LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    assert(u->operands[0].kind == OP_LABEL);
    char label_name[16] = {0};
    sprintf(label_name, "bb_L%d", u->operands[0].label);
    LLVMBasicBlockRef label = get_bb(F, &label_name[0]);
    if (!label) {
        label = LLVMAppendBasicBlock(F, &label_name[0]);
    }
    LLVMBuildBr(builder, label);
}

void translate_ld_zext(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char name_buf[32] = {0};
    LLVMValueRef in = NULL;
    if (u->operand_count == 2) {
        in = get_input_val_for_operand(&u->operands[1], stack, prefix);
    } else {
        assert(u->operand_count == 3 && u->operands[1].kind == OP_VEC && u->operands[2].kind == OP_IMM);
        Operand op_vec_offset = u->operands[1];
        op_vec_offset.vec.offset = u->operands[2].imm.val;
        in = get_input_val_for_operand(&op_vec_offset, stack, prefix);
    }
    LLVMValueRef out = LLVMBuildZExt(builder, in, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&name_buf[0], sizeof(name_buf), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix);
}

void translate_ld_sext(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char name_buf[32] = {0};
    LLVMValueRef in = NULL;
    if (u->operand_count == 2) {
        in = get_input_val_for_operand(&u->operands[1], stack, prefix);
    } else {
        assert(u->operand_count == 3 && u->operands[1].kind == OP_VEC && u->operands[2].kind == OP_IMM);
        Operand op_vec_offset = u->operands[1];
        op_vec_offset.vec.offset = u->operands[2].imm.val;
        in = get_input_val_for_operand(&op_vec_offset, stack, prefix);
    }
    LLVMValueRef out = LLVMBuildSExt(builder, in, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&name_buf[0], sizeof(name_buf), prefix, "out"));
    do_store(&u->operands[0], out, stack, prefix);
}

void translate_ld(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    LLVMValueRef in = NULL;
    if (u->operand_count == 2) {
        in = get_input_val_for_operand(&u->operands[1], stack, prefix);
    } else {
        assert(u->operand_count == 3 && u->operands[1].kind == OP_VEC && u->operands[2].kind == OP_IMM);
        Operand op_vec_offset = u->operands[1];
        op_vec_offset.vec.offset = u->operands[2].imm.val;
        in = get_input_val_for_operand(&op_vec_offset, stack, prefix);
    }
    do_store(&u->operands[0], in, stack, prefix);
}

void translate_ld_with_attr(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    assert(u->operands[1].kind == OP_SLOT && u->operands[2].kind == OP_ATTR);
    Operand op_addr = u->operands[1];
    assert(op_addr.slot.type == SUB_SLOT_XREG || op_addr.slot.type == SUB_SLOT_TMP);
    // Dirty hack to set address size
    op_addr.slot.op_type = LLVMInt64;
    assert(op_addr.slot.op_type <= (op_addr.slot.type == SUB_SLOT_TMP ? stack->tmp.ty[op_addr.slot.idx] : stack->xreg.ty[op_addr.slot.idx]));
    LLVMValueRef addr = get_input_val_for_operand(&op_addr, stack, prefix);
    LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(get_llvm_type(u->operands[1].slot.op_type), 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(addr), "ptr"));
    LLVMValueRef val = build_load_with_alignment(builder, get_llvm_type(u->operands[1].slot.op_type), ptr, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "ld"), alignment_from_attr(u->operands[2].attr_info, u->operands[1].slot.op_type));
    if (u->operands[1].slot.op_type < get_operand_type(&u->operands[0])) {
        if (u->operands[2].attr_info.p.storage.ext == SIGN) {
            val = LLVMBuildSExt(builder, val, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "sext"));
        } else {
            val = LLVMBuildZExt(builder, val, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "sext"));
        }
    }
    if (u->operands[1].slot.op_type > get_operand_type(&u->operands[0])) {
        val = LLVMBuildTrunc(builder, val, get_llvm_type(get_operand_type(&u->operands[0])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "trunc"));
    }
    do_store(&u->operands[0], val, stack, prefix);
}

void translate_ld2_with_attr(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    assert(u->operands[2].kind == OP_SLOT && u->operands[3].kind == OP_ATTR);
    Operand op_addr = u->operands[2];
    assert(op_addr.slot.type == SUB_SLOT_XREG || op_addr.slot.type == SUB_SLOT_TMP);
    // Dirty hack to set address size
    op_addr.slot.op_type = LLVMInt64;
    assert(op_addr.slot.op_type <= (op_addr.slot.type == SUB_SLOT_TMP ? stack->tmp.ty[op_addr.slot.idx] : stack->xreg.ty[op_addr.slot.idx]));
    LLVMValueRef addr = get_input_val_for_operand(&op_addr, stack, prefix);
    LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(get_llvm_type(LLVMVector2xi64), 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(addr), "ptr"));
    LLVMValueRef val = build_load_with_alignment(builder, get_llvm_type(LLVMVector2xi64), ptr, assemble_name_2(&var_name[0], sizeof(var_name), prefix, "ld"), alignment_from_attr(u->operands[3].attr_info, LLVMVector2xi64));
    LLVMValueRef elem0 = LLVMBuildExtractElement(builder, val, LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "ee"));
    do_store(&u->operands[0], elem0, stack, prefix);
    LLVMValueRef elem1 = LLVMBuildExtractElement(builder, val, LLVMConstInt(get_llvm_type(LLVMInt64), 1, 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "ee"));
    do_store(&u->operands[1], elem1, stack, prefix);
}

void translate_st(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    LLVMValueRef val = get_input_val_for_operand(&u->operands[0], stack, prefix);
    Operand out = u->operands[1];
    if (u->operand_count == 3) {
        assert(u->operands[1].kind == OP_VEC && u->operands[2].kind == OP_IMM);
        out.vec.offset = u->operands[2].imm.val;
    }
    if (get_operand_type(&u->operands[0]) > get_operand_type(&u->operands[1])) {
        val = LLVMBuildTrunc(builder, val, get_llvm_type(get_operand_type(&u->operands[1])), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "trunc"));
    }
    do_store(&out, val, stack, prefix);
}

void translate_st_with_attr(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    assert(u->operands[1].kind == OP_SLOT && u->operands[2].kind == OP_ATTR);
    Operand op_addr = u->operands[1];
    assert(op_addr.slot.type == SUB_SLOT_XREG || op_addr.slot.type == SUB_SLOT_TMP);
    // Dirty hack to set address size
    op_addr.slot.op_type = LLVMInt64;
    assert(op_addr.slot.op_type <= (op_addr.slot.type == SUB_SLOT_TMP ? stack->tmp.ty[op_addr.slot.idx] : stack->xreg.ty[op_addr.slot.idx]));
    LLVMValueRef addr = get_input_val_for_operand(&op_addr, stack, prefix);
    LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(get_llvm_type(u->operands[1].slot.op_type), 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(addr), "ptr"));
    LLVMValueRef val = get_input_val_for_operand(&u->operands[0], stack, prefix);
    if (u->operands[1].slot.op_type < get_operand_type(&u->operands[0])) {
        val = shrink_llvm_value(val, get_operand_type(&u->operands[0]), u->operands[1].slot.op_type);
    }
    build_store_with_alignment(builder, val, ptr, alignment_from_attr(u->operands[2].attr_info, u->operands[1].slot.op_type));
}

void translate_st2_with_attr(LLVMBuilderRef builder, StackAlloca *stack, const UnifiedInstr *u, const char *prefix) {
    char var_name[32] = {0};
    assert(u->operands[2].kind == OP_SLOT && u->operands[3].kind == OP_ATTR);
    Operand op_addr = u->operands[2];
    assert(op_addr.slot.type == SUB_SLOT_XREG || op_addr.slot.type == SUB_SLOT_TMP);
    // Dirty hack to set address size
    op_addr.slot.op_type = LLVMInt64;
    assert(op_addr.slot.op_type <= (op_addr.slot.type == SUB_SLOT_TMP ? stack->tmp.ty[op_addr.slot.idx] : stack->xreg.ty[op_addr.slot.idx]));
    LLVMValueRef addr = get_input_val_for_operand(&op_addr, stack, prefix);
    LLVMValueRef ptr = LLVMBuildIntToPtr(builder, addr, LLVMPointerType(get_llvm_type(LLVMVector2xi64), 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(addr), "ptr"));

    LLVMValueRef elem0 = get_input_val_for_operand(&u->operands[0], stack, prefix);
    LLVMValueRef elem1 = get_input_val_for_operand(&u->operands[1], stack, prefix);
    Operand out;
    out.kind = OP_IMM;
    out.imm.val = 0;
    out.imm.op_type = LLVMVector2xi64;
    LLVMValueRef val = get_input_val_for_operand(&out, stack, prefix);
    val = LLVMBuildInsertElement(builder, val, elem0, LLVMConstInt(get_llvm_type(LLVMInt64), 0, 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "ie"));
    val = LLVMBuildInsertElement(builder, val, elem1, LLVMConstInt(get_llvm_type(LLVMInt64), 1, 0), assemble_name_2(&var_name[0], sizeof(var_name), LLVMGetValueName(val), "ie"));
    build_store_with_alignment(builder, val, ptr, alignment_from_attr(u->operands[3].attr_info, u->operands[2].slot.op_type));
}

static void print_operand(const Operand *op, int is_output, SBuf *b) {
    if (is_output) {
        sbuf_putc(b, '[');
    }
    switch (op->kind) {
    case OP_SLOT:
        switch (op->slot.type) {
        case SUB_SLOT_ENVVAR:
            sbuf_printf(b, "%s(env)", envvar_type_str[op->slot.idx]);
            break;
        case SUB_SLOT_XREG:
            sbuf_printf(b, "%s", xreg_type_str[op->slot.idx]);
            break;
        case SUB_SLOT_TMP:
            sbuf_printf(b, "t%d", op->slot.idx);
            break;
        default:
            assert(0);
        }
        break;
    case OP_IMM:
        sbuf_printf(b, "0x%lx", op->imm.val);
        break;
    case OP_LABEL:
        sbuf_printf(b, "L%d", op->label);
        break;
    case OP_RELOP:
        sbuf_printf(b, "%s", relop_type_str[op->relop]);
        break;
    case OP_ATTR:
        sbuf_printf(b, "attr");
        assert(op->attr_info.subt != SUB_ATTR_INVALID);
        sbuf_printf(b, "-");
        if (op->attr_info.subt == SUB_ATTR_STORAGE) {
            sbuf_printf(b, "stg");
            sbuf_printf(b, ":%s", atomic_type_str[op->attr_info.p.storage.atomic]);
            sbuf_printf(b, ":%s", alignment_type_str[op->attr_info.p.storage.alignment]);
            sbuf_printf(b, ":%s", srcext_type_str[op->attr_info.p.storage.ext]);
            sbuf_printf(b, ":%s", srcsize_type_str[op->attr_info.p.storage.size]);
        } else {
            sbuf_printf(b, "swp");
            sbuf_printf(b, "%s", (op->attr_info.p.swap & (1 << 0)) ? ":iz" : "");
            sbuf_printf(b, "%s", (op->attr_info.p.swap & (1 << 1)) ? ":oz" : "");
            sbuf_printf(b, "%s", (op->attr_info.p.swap & (1 << 2)) ? ":is" : "");
            sbuf_printf(b, "%s", (op->attr_info.p.swap & (1 << 3)) ? ":os" : "");
        }
        break;
    case OP_SYMBOL:
        sbuf_printf(b, "%s", helper_str[op->symbol]);
        break;
    case OP_VEC:
        if (op->vec.offset == 0) {
            sbuf_printf(b, "v%d", op->vec.idx);
        } else {
            sbuf_printf(b, "v%d:o%d", op->vec.idx, op->vec.offset);
        }
        break;
    case OP_ENV:
        if (op->env.offset == 0) {
            sbuf_printf(b, "env");
        } else {
            sbuf_printf(b, "env:0x%x", op->env.offset);
        }
        break;
    case OP_ARG:
        if (op->argidx == -1) {
            sbuf_printf(b, "__last_arg__");
        } else {
            sbuf_printf(b, "arg%d", op->argidx);
        }
        break;
    default:
        assert(0);
    }
    if (is_output) {
        sbuf_putc(b, ']');
    }
}

static void print_instr(const UnifiedInstr *u, SBuf *b) {
    sbuf_printf(b, "%s", opcode_type_str[u->opc]);
    if (u->opc == call) {
        sbuf_printf(b, " %s,", helper_str[u->operands[0].symbol]);
        for (int i = TCG_CALL_PREFIX_COUNT; i < u->operand_count; ++i) {
            print_operand(&u->operands[i], (u->operands[2].imm.val && i == TCG_CALL_PREFIX_COUNT) ? 1 : 0, b);
            if (i < (u->operand_count - 1)) {
                sbuf_putc(b, ',');
            }
        }
        sbuf_putc(b, '\n');
        return;
    } else if (u->opc == tail_call_qemuaot || u->opc == call_qemuaot) {
        sbuf_putc(b, ' ');
        print_operand(&u->operands[0], 0, b);
        for (int i = TCG_CALL_PREFIX_COUNT; i < u->operand_count; ++i) {
            if (u->operands[i].kind != OP_VEC) {
                sbuf_putc(b, ',');
                print_operand(&u->operands[i], (u->operands[2].imm.val && i == TCG_CALL_PREFIX_COUNT) ? 1 : 0, b);
            }
        }
        sbuf_printf(b, " VEC_ARGS:");
        for (int i = TCG_CALL_PREFIX_COUNT; i < u->operand_count; ++i) {
            if (u->operands[i].kind == OP_VEC) {
                print_operand(&u->operands[i], (u->operands[2].imm.val && i == TCG_CALL_PREFIX_COUNT) ? 1 : 0, b);
                sbuf_putc(b, ',');
            }
        }
        sbuf_putc(b, '\n');
        return;
    } else if (u->opc == tail_call_default || u->opc == call_default) {
        sbuf_putc(b, ' ');
        print_operand(&u->operands[0], 0, b);
        for (int i = TCG_CALL_PREFIX_COUNT; i < u->operand_count; ++i) {
            assert(u->operands[i].kind != OP_VEC);
            sbuf_putc(b, ',');
            print_operand(&u->operands[i], (u->operands[2].imm.val && i == TCG_CALL_PREFIX_COUNT) ? 1 : 0, b);
        }
        sbuf_putc(b, '\n');
        return;
    } else if (u->vs != 0) {
        sbuf_printf(b, " v%d,e%d,", u->vs, u->es);
    } else {
        sbuf_putc(b, ' ');
    }
    for (int i = 0; i < u->operand_count; ++i) {
        print_operand(&u->operands[i], i < opcoc[u->opc] ? 1 : 0, b);
        if (i < (u->operand_count - 1)) {
            sbuf_putc(b, ',');
        }
    }
}

#define CASE(opc, entry)                            \
        case opc:                                   \
            entry(builder, stack, u, &prefix[0]);   \
            break

#define CASE_COMMON(opc, llvm_api)                                      \
        case opc:                                                       \
            translate_common(builder, llvm_api, stack, u, &prefix[0]);  \
            break

#define CASE_FUNC(opc, entry)                       \
        case opc:                                   \
            entry(builder, F, stack, u, &prefix[0]);\
            break

void translate_batch(LLVMModuleRef module, LLVMBuilderRef builder, LLVMValueRef F, StackAlloca *stack, FuncInstrList *f) {
    int idx = 0;
    char prefix[32] = {0};

    TcgTag tag;
    tcg_tag_init(&tag, LLVMGetModuleContext(module), builder);

#ifdef USE_TCG_DEBUGINFO
    LLVMDIBuilderRef dib = NULL;
    if (tcg_tag_setup_dbg(&tag, module, F, "tcg.ir", "tb", &dib) != 0)
        fprintf(stderr, "warning: debug info setup failed\n");
#endif

    for (const UnifiedInstr *u = f->head; u; u = u->next, ++idx) {
        snprintf(&prefix[0], sizeof(prefix), "T%d", idx);
        SBuf b;
        char dump_instr_buf[128] = {0};
        sbuf_init(&b, &dump_instr_buf[0], sizeof(dump_instr_buf));
        print_instr(u, &b);
        tcg_tag_begin(&tag, idx, "%s", &dump_instr_buf[0]);
        switch (u->opc) {
            // FIXME: support all TCG-ops
            case addc1o_i32:
            case addc1o_i64:
            case subb1o_i32:
            case subb1o_i64:
            case divs2_i32:
            case divs2_i64:
            case divu2_i32:
            case divu2_i64:
            case dup_vec:
                assert(0);
                break;

            CASE(addci_i32, translate_addci);
            CASE(addci_i64, translate_addci);
#if 0
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
#endif
            CASE_COMMON(add_i32, LLVMBuildAdd);
            CASE_COMMON(add_i64, LLVMBuildAdd);
            CASE_COMMON(add_vec, LLVMBuildAdd);
#if 0
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
#endif
            CASE(ld8u_i32, translate_ld_zext);
            CASE(ld8u_i64, translate_ld_zext);
            CASE(ld16u_i32, translate_ld_zext);
            CASE(ld16u_i64, translate_ld_zext);
            CASE(ld32u_i64, translate_ld_zext);
            CASE(ld8s_i32, translate_ld_sext);
            CASE(ld8s_i64, translate_ld_sext);
            CASE(ld16s_i32, translate_ld_sext);
            CASE(ld16s_i64, translate_ld_sext);
            CASE(ld32s_i64, translate_ld_sext);
            CASE(ld_vec, translate_ld);
            CASE(ld_i32, translate_ld);
            CASE(ld_i64, translate_ld);
            CASE(qemu_ld_i32, translate_ld_with_attr);
            CASE(qemu_ld_i64, translate_ld_with_attr);
            CASE(qemu_ld2_i128, translate_ld2_with_attr);
            CASE(st8_i32, translate_st);
            CASE(st8_i64, translate_st);
            CASE(st16_i32, translate_st);
            CASE(st16_i64, translate_st);
            CASE(st32_i64, translate_st);
            CASE(st_i32, translate_st);
            CASE(st_i64, translate_st);
            CASE(st_vec, translate_st);
            CASE(qemu_st_i32, translate_st_with_attr);
            CASE(qemu_st_i64, translate_st_with_attr);
            CASE(qemu_st2_i128, translate_st2_with_attr);
#if 0
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
#endif
            CASE_FUNC(set_label, translate_set_label);
            CASE_FUNC(br, translate_br);
#if 0
            case brcond_i32:
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
#endif
            default: assert(0);
        }
        tcg_tag_end(&tag);
    }

    //if (tcg_tag_dump_map(&tag, "tb.tcgmap") != 0)
    //    fprintf(stderr, "warning: could not write tb.tcgmap\n");

#ifdef USE_TCG_DEBUGINFO
    if (dib) {
        LLVMDIBuilderFinalize(dib);
        LLVMDisposeDIBuilder(dib);
    }
#endif
    tcg_tag_dispose(&tag);
}
