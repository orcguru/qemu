#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include "tcg_ast.h"
#include "tcg_context.h"
#include "tcg_parser.tab.h"
#include "lex.yy.h"
#include <llvm-c/Core.h>
#include <llvm-c/Types.h>

extern char *lineptr;

TcgAst *create_attr_elementsize(uint32_t es) {
    return NULL;
}

TcgAst *create_branch_condition(TcgAst *s0, uint64_t i0, uint8_t relop, uint8_t label) {
    return NULL;
}

TcgAst *create_bswap_attr(uint8_t val) {
    return NULL;
}

TcgAst *create_calldirect(TcgAst *s0, uint64_t i0, uint64_t i1) {
    return NULL;
}

TcgAst *create_discard(TcgAst *s0) {
    return NULL;
}

TcgAst *create_helper_env(const char *h, uint16_t cflags, uint8_t noargs) {
    return NULL;
}

TcgAst *create_helper_env_imm(const char *h, uint16_t cflags, uint8_t noargs, uint64_t i0) {
    return NULL;
}

TcgAst *create_helper_env_imm2(const char *h, uint16_t cflags, uint8_t noargs, uint64_t i0, uint64_t i1) {
    return NULL;
}

TcgAst *create_helper_env_imm_slot(const char *h, uint16_t cflags, uint8_t noargs, uint64_t i0, TcgAst *s0) {
    return NULL;
}

TcgAst *create_helper_env_slot(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0) {
    return NULL;
}

TcgAst *create_helper_env_slot2(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1) {
    return NULL;
}

TcgAst *create_helper_env_slot2_imm(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, uint64_t i0) {
    return NULL;
}

TcgAst *create_helper_env_slot3(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2) {
    return NULL;
}

TcgAst *create_helper_env_slot3_imm(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint64_t i0) {
    return NULL;
}

TcgAst *create_helper_env_slot_imm(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, uint64_t i0) {
    return NULL;
}

TcgAst *create_helper_slot2_imm(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, uint64_t i0) {
    return NULL;
}

TcgAst *create_helper_slot2_imm2(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, uint64_t i0, uint64_t i1) {
    return NULL;
}

TcgAst *create_helper_slot3(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2) {
    return NULL;
}

TcgAst *create_helper_slot3_imm(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint64_t i0) {
    return NULL;
}

TcgAst *create_helper_slot4(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3) {
    return NULL;
}

TcgAst *create_helper_slot5(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3, TcgAst *s4) {
    return NULL;
}

TcgAst *create_helper_slot_env(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0) {
    return NULL;
}

TcgAst *create_helper_slot_env_slot(const char *h, uint16_t cflags, uint8_t noargs, TcgAst *s0, TcgAst *s1) {
    return NULL;
}

TcgAst *create_imm(uint64_t val) {
    return NULL;
}

TcgAst *create_jmpdirect(uint64_t val) {
    return NULL;
}

TcgAst *create_scalar_imm_env_imm(uint8_t opc, uint64_t i0, uint64_t i1) {
    return NULL;
}

TcgAst *create_scalar_imm_slot_imm(uint8_t opc, uint64_t i0, TcgAst *s0, uint64_t i1) {
    return NULL;
}

TcgAst *create_scalar_slot(uint8_t opc, TcgAst *s0) {
    return NULL;
}

TcgAst *create_scalar_slot2(uint8_t opc, TcgAst *s0, TcgAst *s1) {
    return NULL;
}

TcgAst *create_scalar_slot2_attr(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *a0) {
    return NULL;
}

TcgAst *create_scalar_slot2_attr2(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *a0, TcgAst *a1) {
    return NULL;
}

TcgAst *create_scalar_slot2_attr_num(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *a0, uint64_t n0) {
    return NULL;
}

TcgAst *create_scalar_slot2_info(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2) {
    return NULL;
}

TcgAst *create_scalar_slot2_info2(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3) {
    return NULL;
}

TcgAst *create_scalar_slot2_info3(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3, TcgAst *s4) {
    return NULL;
}

TcgAst *create_scalar_slot2_info3_relop(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3, TcgAst *s4, uint8_t relop) {
    return NULL;
}

TcgAst *create_scalar_slot2_info_attr_num(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *a0, uint64_t n0) {
    return NULL;
}

TcgAst *create_scalar_slot2_info_relop(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint8_t relop) {
    return NULL;
}

TcgAst *create_scalar_slot_env_imm(uint8_t opc, TcgAst *s0, uint64_t i0) {
    return NULL;
}

TcgAst *create_scalar_slot_imm(uint8_t opc, TcgAst *s0, uint64_t i0) {
    return NULL;
}

TcgAst *create_scalar_slot_imm_slot(uint8_t opc, TcgAst *s0, uint64_t i0, TcgAst *s1) {
    return NULL;
}

TcgAst *create_setlabel(uint8_t label) {
    return NULL;
}

TcgAst *create_slot_envvar(uint8_t ei) {
    return NULL;
}

TcgAst *create_slot_tmpl(uint8_t ti) {
    return NULL;
}

TcgAst *create_slot_tmpt(uint8_t ti) {
    return NULL;
}

TcgAst *create_slot_xreg(uint8_t ri) {
    return NULL;
}

TcgAst *create_storage_attr(uint8_t ai0, uint8_t ai1, uint8_t ai2) {
    return NULL;
}

TcgAst *create_vector_slot2(uint8_t opc, TcgAst *es, TcgAst *s0, TcgAst *s1) {
    return NULL;
}

TcgAst *create_vector_slot2_imm(uint8_t opc, TcgAst *es, TcgAst *s0, TcgAst *s1, uint64_t i0) {
    return NULL;
}

TcgAst *create_vector_slot2_vimm(uint8_t opc, TcgAst *es, TcgAst *s0, TcgAst *s1, uint64_t vi0) {
    return NULL;
}

TcgAst *create_vector_slot3(uint8_t opc, TcgAst *es, TcgAst *s0, TcgAst *s1, TcgAst *s2) {
    return NULL;
}

TcgAst *create_vector_slot3_relop(uint8_t opc, TcgAst *es, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint8_t relop) {
    return NULL;
}

TcgAst *create_vector_slot_env_imm(uint8_t opc, TcgAst *es, TcgAst *s0, uint64_t i0) {
    return NULL;
}

TcgAst *create_vector_slot_vimm(uint8_t opc, TcgAst *es, TcgAst *s0, uint64_t vi0) {
    return NULL;
}

TcgAst *expand_branch_condition(TcgAst *s0, uint64_t i0, uint8_t relop, uint8_t label) {
    return NULL;
}

TcgAst *expand_scalar_slot2_info3_relop(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, TcgAst *s3, TcgAst *s4, uint8_t relop) {
    return NULL;
}

TcgAst *expand_scalar_slot2_info_relop(uint8_t opc, TcgAst *s0, TcgAst *s1, TcgAst *s2, uint8_t relop) {
    return NULL;
}

static LLVMModuleRef create_module(const char *module_name) {
    LLVMContextRef context = LLVMGetGlobalContext();
    LLVMModuleRef module = LLVMModuleCreateWithNameInContext(module_name, context);

    LLVMSetTarget(module, "riscv64-unknown-linux-gnu");
    return module;
}

TcgAst *merge_ast(TcgAst *list, TcgAst *elem) {
    assert(elem);
    elem->next = list;
    return elem;
}

TcgAst *create_func(uint64_t val, TcgAst *instructions) {
    TcgAst *func = calloc(1, sizeof(TcgAst));
    func->type = OP_FUNC;
    func->data.func.label = (unsigned int)val;
    func->data.func.instructions = instructions;
    return func;
}

void create_program(TcgAst *funcs) {
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
  parse_tcg_instructions(argv[1]);
  return 0;
}
