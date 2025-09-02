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
extern uint8_t opciosz[OPCODE_MAX][3];
extern uint8_t opcoc[OPCODE_MAX];

LLVMModuleRef module;
LLVMBuilderRef builder;
#define FIXED_PARAM_COUNT           20
LLVMTypeRef fixed_param_types[FIXED_PARAM_COUNT] = {NULL};
const char *fixed_arg_names[FIXED_PARAM_COUNT] = {NULL};
#define FIXED_VECTOR_PARAM_COUNT   (20 + 15 * 2)
LLVMTypeRef fixed_vector_param_types[FIXED_VECTOR_PARAM_COUNT] = {NULL};
const char *fixed_vector_arg_names[FIXED_VECTOR_PARAM_COUNT] = {NULL};

static LLVMModuleRef create_module(const char *module_name) {
    LLVMContextRef context = LLVMGetGlobalContext();
    LLVMModuleRef module = LLVMModuleCreateWithNameInContext(module_name, context);

    LLVMSetTarget(module, "riscv64-unknown-linux-gnu");
    return module;
}

void handle_func(uint64_t val) {
    void *ptr_init = get_instr_buffer();
    void *ptr_max = ptr_init + get_instr_buffer_size();
    void *ptr;
    uint32_t xreg_valid = 0, tmpl_valid = 0, tmpt_valid = 0, is_imm = 0;
    uint32_t tmpl_128bit = 0, tmpl_64bit = 0, tmpl_32bit = 0, tmpl_16bit = 0, tmpl_8bit = 0;
    uint32_t tmpt_128bit = 0, tmpt_64bit = 0, tmpt_32bit = 0, tmpt_16bit = 0, tmpt_8bit = 0;
    uint64_t xmm_valid = 0;
    for (ptr = ptr_init; ptr < ptr_max; ptr = move_to_next(ptr)) {
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
                    tmpl_valid |= (1 << operand.s.slot_idx);
                    if (slot_idx < opcoc[opc]) {
                        if (opciosz[opc][2] == 64) {
                            tmpl_64bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][2] == 32) {
                            tmpl_32bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][2] == 16) {
                            tmpl_16bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][2] == 8) {
                            tmpl_8bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][2] == 128) {
                            tmpl_128bit |= (1 << operand.s.slot_idx);
                        }
                    } else {
                        if (opciosz[opc][0] == 64) {
                            tmpl_64bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][0] == 32) {
                            tmpl_32bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][0] == 16) {
                            tmpl_16bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][0] == 8) {
                            tmpl_8bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][0] == 128) {
                            tmpl_128bit |= (1 << operand.s.slot_idx);
                        }
                    }
                } else if (operand.s.slot_type == SUB_SLOT_TMPT) {
                    tmpt_valid |= (1 << operand.s.slot_idx);
                    if (slot_idx < opcoc[opc]) {
                        if (opciosz[opc][2] == 64) {
                            tmpt_64bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][2] == 32) {
                            tmpt_32bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][2] == 16) {
                            tmpt_16bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][2] == 8) {
                            tmpt_8bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][2] == 128) {
                            tmpt_128bit |= (1 << operand.s.slot_idx);
                        }
                    } else {
                        if (opciosz[opc][0] == 64) {
                            tmpt_64bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][0] == 32) {
                            tmpt_32bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][0] == 16) {
                            tmpt_16bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][0] == 8) {
                            tmpt_8bit |= (1 << operand.s.slot_idx);
                        } else if (opciosz[opc][0] == 128) {
                            tmpt_128bit |= (1 << operand.s.slot_idx);
                        }
                    }
                } else if (operand.s.slot_type == SUB_SLOT_XMM) {
                    xmm_valid |= (1UL << operand.s.slot_idx);
                }
            }
            slot_idx += 1;
        } while (1);
    }

    reset_instr_buffer();

    /*
    char func_name[64];
    sprintf(func_name, "func_%x", func->data.func.label);
    LLVMValueRef llvm_func = LLVMAddFunction(module, func_name,
        LLVMFunctionType(LLVMVoidType(), param_types, total_param_count, 0));
    for (int j = 0; j < total_param_count; j++) {
        LLVMValueRef param = LLVMGetParam(llvm_func, j);
        LLVMSetValueName(param, arg_names[j]);
    }
    LLVMSetFunctionCallConv(llvm_func, 124);

    LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
    LLVMPositionBuilderAtEnd(builder, entry);
    LLVMBuildRetVoid(builder);
    */

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
        "cc_src", "cc_dst", "cc_op", "lr_input"
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
    for (int i = 0; i < (FIXED_VECTOR_PARAM_COUNT - FIXED_PARAM_COUNT)/2 ; i++) {
        int idx = FIXED_PARAM_COUNT + i * 2;
        fixed_vector_param_types[idx] = vscale_i64;
        fixed_vector_param_types[idx + 1] = vscale_i64;
        snprintf(extra_name_buf[i * 2], sizeof(extra_name_buf[i * 2]), "xmm%d", i);
        snprintf(extra_name_buf[i * 2 + 1], sizeof(extra_name_buf[i * 2 + 1]), "ymm%d_h", i);
        fixed_vector_arg_names[idx] = extra_name_buf[i * 2];
        fixed_vector_arg_names[idx + 1] = extra_name_buf[i * 2 + 1];
    }
}

void module_epilog() {
    LLVMDumpModule(module);
    LLVMDisposeModule(module);
}

void create_program(TcgAst *funcs) {
#if 0
    LLVMModuleRef module = create_module("qemuaot");
    LLVMBuilderRef builder = LLVMCreateBuilder();

    // Parameter setup (same for all functions)
    LLVMTypeRef vscale_i64 = LLVMScalableVectorType(LLVMInt64Type(), 1); // <1 x i64>
    int base_param_count = 20;
    int extra_param_count = 15 * 2;
    int total_param_count = base_param_count + extra_param_count;
    LLVMTypeRef param_types[base_param_count + extra_param_count];
    const char *base_names[20] = {
        "rax", "rcx", "rdx", "rbx",
        "rsp", "rbp", "rsi", "rdi",
        "r8", "r9", "r10", "r11",
        "r12", "r13", "r14", "r15",
        "cc_src", "cc_dst", "cc_op", "lr_input"
    };
    const char *arg_names[base_param_count + extra_param_count];
    for (int i = 0; i < base_param_count; i++) {
        if (i < 16) param_types[i] = LLVMInt64Type();
        else if (i == 16 || i == 17 || i == 19) param_types[i] = LLVMInt64Type();
        else if (i == 18) param_types[i] = LLVMInt32Type();
        arg_names[i] = base_names[i];
    }
    static char extra_name_buf[30][16];
    for (int i = 0; i < 15; i++) {
        int idx = base_param_count + i * 2;
        param_types[idx] = vscale_i64;
        param_types[idx + 1] = vscale_i64;
        snprintf(extra_name_buf[i * 2], sizeof(extra_name_buf[i * 2]), "xmm%d", i);
        snprintf(extra_name_buf[i * 2 + 1], sizeof(extra_name_buf[i * 2 + 1]), "ymm%d_h", i);
        arg_names[idx] = extra_name_buf[i * 2];
        arg_names[idx + 1] = extra_name_buf[i * 2 + 1];
    }


    // Collect the funcs into an array to reverse the order
    int func_count = 0;
    for (TcgAst *cur = funcs; cur != NULL; cur = cur->next) func_count++;
    TcgAst **func_array = malloc(sizeof(TcgAst *) * func_count);
    int idx = 0;
    for (TcgAst *cur = funcs; cur != NULL; cur = cur->next) func_array[idx++] = cur;

    // Generate functions in reverse order
    for (int i = func_count - 1; i >= 0; i--) {
        TcgAst *func = func_array[i];
        char func_name[64];
        sprintf(func_name, "func_%x", func->data.func.label);
        LLVMValueRef llvm_func = LLVMAddFunction(module, func_name,
            LLVMFunctionType(LLVMVoidType(), param_types, total_param_count, 0));
        for (int j = 0; j < total_param_count; j++) {
            LLVMValueRef param = LLVMGetParam(llvm_func, j);
            LLVMSetValueName(param, arg_names[j]);
        }
        LLVMSetFunctionCallConv(llvm_func, 124);

        LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
        LLVMPositionBuilderAtEnd(builder, entry);
        LLVMBuildRetVoid(builder);
    }
    free(func_array);

    //LLVMDumpModule(module);
    LLVMDisposeModule(module);
#endif
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
