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
const char *fixed_vector_stack_names[FIXED_VECTOR_PARAM_COUNT] = {NULL};
const char *tmpl_stack_names[1<<5] = {NULL};
const char *tmpt_stack_names[1<<5] = {NULL};

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
    int tmpl_dirty = 0, tmpt_dirty = 0;
    uint32_t xreg_valid = 0, tmpl_valid = 0, tmpt_valid = 0, is_imm = 0;
    uint32_t tmpl_128bit = 0, tmpl_64bit = 0, tmpl_32bit = 0, tmpl_16bit = 0, tmpl_8bit = 0;
    uint32_t tmpt_128bit = 0, tmpt_64bit = 0, tmpt_32bit = 0, tmpt_16bit = 0, tmpt_8bit = 0;
    uint8_t tmpl_bits_type[1<<5];
    uint8_t tmpt_bits_type[1<<5];
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
                    uint32_t slot_bit = (1 << operand.s.slot_idx);
                    tmpl_valid |= slot_bit;
                    if (slot_idx < opcoc[opc]) {
                        if (opciosz[opc][2] == 64) {
                            tmpl_64bit |= slot_bit;
                        } else if (opciosz[opc][2] == 32) {
                            tmpl_32bit |= slot_bit;
                        } else if (opciosz[opc][2] == 16) {
                            tmpl_16bit |= slot_bit;
                        } else if (opciosz[opc][2] == 8) {
                            tmpl_8bit |= slot_bit;
                        } else if (opciosz[opc][2] == 128) {
                            tmpl_128bit |= slot_bit;
                        }
                    } else {
                        if (opciosz[opc][0] == 64) {
                            tmpl_64bit |= slot_bit;
                        } else if (opciosz[opc][0] == 32) {
                            tmpl_32bit |= slot_bit;
                        } else if (opciosz[opc][0] == 16) {
                            tmpl_16bit |= slot_bit;
                        } else if (opciosz[opc][0] == 8) {
                            tmpl_8bit |= slot_bit;
                        } else if (opciosz[opc][0] == 128) {
                            tmpl_128bit |= slot_bit;
                        }
                    }
                } else if (operand.s.slot_type == SUB_SLOT_TMPT) {
                    tmpt_dirty = 1;
                    uint32_t slot_bit = (1 << operand.s.slot_idx);
                    tmpt_valid |= slot_bit;
                    if (slot_idx < opcoc[opc]) {
                        if (opciosz[opc][2] == 64) {
                            tmpt_64bit |= slot_bit;
                        } else if (opciosz[opc][2] == 32) {
                            tmpt_32bit |= slot_bit;
                        } else if (opciosz[opc][2] == 16) {
                            tmpt_16bit |= slot_bit;
                        } else if (opciosz[opc][2] == 8) {
                            tmpt_8bit |= slot_bit;
                        } else if (opciosz[opc][2] == 128) {
                            tmpt_128bit |= slot_bit;
                        }
                    } else {
                        if (opciosz[opc][0] == 64) {
                            tmpt_64bit |= slot_bit;
                        } else if (opciosz[opc][0] == 32) {
                            tmpt_32bit |= slot_bit;
                        } else if (opciosz[opc][0] == 16) {
                            tmpt_16bit |= slot_bit;
                        } else if (opciosz[opc][0] == 8) {
                            tmpt_8bit |= slot_bit;
                        } else if (opciosz[opc][0] == 128) {
                            tmpt_128bit |= slot_bit;
                        }
                    }
                } else if (operand.s.slot_type == SUB_SLOT_XMM) {
                    xmm_valid |= (1UL << operand.s.slot_idx);
                }
            }
            slot_idx += 1;
        } while (1);
    }
    if (tmpl_dirty) {
        for (int i = 0; i < (1<<5); ++i) {
            uint32_t slot_bit = (1 << i);
            if (tmpl_valid & slot_bit) {
                if (tmpl_128bit & slot_bit) {
                    tmpl_bits_type[i] = 4;
                } else if (tmpl_64bit & slot_bit) {
                    tmpl_bits_type[i] = 3;
                } else if (tmpl_32bit & slot_bit) {
                    tmpl_bits_type[i] = 2;
                } else if (tmpl_16bit & slot_bit) {
                    tmpl_bits_type[i] = 1;
                } else if (tmpl_8bit & slot_bit) {
                    tmpl_bits_type[i] = 0;
                }
            }
        }
    }
    if (tmpt_dirty) {
        for (int i = 0; i < (1<<5); ++i) {
            uint32_t slot_bit = (1 << i);
            if (tmpt_valid & slot_bit) {
                if (tmpt_128bit & slot_bit) {
                    tmpt_bits_type[i] = 4;
                } else if (tmpt_64bit & slot_bit) {
                    tmpt_bits_type[i] = 3;
                } else if (tmpt_32bit & slot_bit) {
                    tmpt_bits_type[i] = 2;
                } else if (tmpt_16bit & slot_bit) {
                    tmpt_bits_type[i] = 1;
                } else if (tmpt_8bit & slot_bit) {
                    tmpt_bits_type[i] = 0;
                }
            }
        }
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
            LLVMSetAlignment(LLVMBuildStore(builder, LLVMGetParam(llvm_func, x), alloca_inst), 8);
        }
    }

    LLVMTypeRef tmp_types[5] = {NULL, NULL, NULL, NULL, NULL};
    if (tmpl_dirty) {
        for (int i = 0; i < (1<<5); ++i) {
            if (tmpl_valid & (1 << i)) {
                int type_idx = tmpl_bits_type[i];
                if (tmp_types[type_idx] == NULL) {
                    if (type_idx == 0) {
                        tmp_types[type_idx] = LLVMInt8Type();
                    } else if (type_idx == 1) {
                        tmp_types[type_idx] = LLVMInt16Type();
                    } else if (type_idx == 2) {
                        tmp_types[type_idx] = LLVMInt32Type();
                    } else if (type_idx == 3) {
                        tmp_types[type_idx] = LLVMInt64Type();
                    } else if (type_idx == 4) {
                        tmp_types[type_idx] = LLVMVectorType(LLVMInt8Type(), 16);
                    } else {
                        assert(0);
                    }
                }
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, tmp_types[type_idx], tmpl_stack_names[i]);
                LLVMSetAlignment(alloca_inst, type_idx <= 3 ? 8 : 16);
            }
        }
    }
    if (tmpt_dirty) {
        for (int i = 0; i < (1<<5); ++i) {
            if (tmpt_valid & (1 << i)) {
                int type_idx = tmpt_bits_type[i];
                if (tmp_types[type_idx] == NULL) {
                    if (type_idx == 0) {
                        tmp_types[type_idx] = LLVMInt8Type();
                    } else if (type_idx == 1) {
                        tmp_types[type_idx] = LLVMInt16Type();
                    } else if (type_idx == 2) {
                        tmp_types[type_idx] = LLVMInt32Type();
                    } else if (type_idx == 3) {
                        tmp_types[type_idx] = LLVMInt64Type();
                    } else if (type_idx == 4) {
                        tmp_types[type_idx] = LLVMVectorType(LLVMInt8Type(), 16);
                    } else {
                        assert(0);
                    }
                }
                LLVMValueRef alloca_inst = LLVMBuildAlloca(builder, tmp_types[type_idx], tmpt_stack_names[i]);
                LLVMSetAlignment(alloca_inst, type_idx <= 3 ? 8 : 16);
            }
        }
    }

    LLVMBuildRetVoid(builder);

    reset_instr_buffer();
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
}

void module_epilog() {
    LLVMDumpModule(module);
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
