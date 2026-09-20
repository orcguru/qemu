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
#include "parser.tab.h"
#include "lexer.yy.h"
#include "mapper_util.h"
#include "util.h"

#define LLVMNoInlineAttribute       32
#define LLVMAlwaysInlineAttribute   3

extern char *lineptr;
int cfg_xmm_count = XMM_COUNT;
void debug_print_instr(TcgContext *ctx, const char *msg) {}

char *g_template_path = NULL;
LLVMTargetMachineRef g_target_machine = NULL;
LLVMModuleRef g_module = NULL;
LLVMContextRef g_context = NULL;
LLVMBuilderRef g_builder = NULL;
LLVMAttributeRef g_attr_target_features = NULL;
LLVMAttributeRef g_attr_noinline = NULL;
LLVMAttributeRef g_attr_alwaysinline = NULL;
LLVMAttributeRef g_attr_nounwind = NULL;

static LLVMValueRef get_or_add_func_with_qemuaot_cc(const char *name, int with_ret) {
    // Trampoline may have already been defined
    LLVMValueRef F = LLVMGetNamedFunction(g_module, name);
    if (!F) {
        LLVMTypeRef call_types[FIXED_VECTOR_PARAM_COUNT] = {NULL};
        int arg_cnt = collect_arguments_and_types(not_a_helper, TARGET_QEMUAOT_FASTPATH, TYPE_ONLY, NULL, NULL, 0, NULL, NULL, llvm_func, call_types, FIXED_VECTOR_PARAM_COUNT, NULL, name);
        LLVMTypeRef func_type = LLVMFunctionType(LLVMVoidType(), call_types, arg_cnt, 0);
        func = LLVMAddFunction(module, name, func_type);
        LLVMAddAttributeAtIndex(func, -1, target_features_attr);
        LLVMAddAttributeAtIndex(func, -1, NoUnwindAttr);
        LLVMSetFunctionCallConv(func, QEMUAOT_CC);
        char sec_name[128] = {0};
        sprintf(sec_name, ".text.%s", name);
        LLVMSetSection(func, sec_name);
    }
    return F;
}

void translate_to_llvm_func(const char *name, FuncInstrList *ilist, int is_external) {
    LLVMValueRef F = NULL;
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

void handle_func(TcgContext *ctx, int is_external) {
    for (int i = 0; i < ctx->llvm_func_set.num_lists; ++i) {
        char *func_name = NULL;
        char fhex_name[32] = {0};
        if (ctx->llvm_func_set.lists[i].trampoline_name[0]) {
            func_name = &ctx->llvm_func_set.lists[i].trampoline_name[0];
        } else {
            sprintf(fhex_name, "Fx%lx", ctx->hex_offset);
            if (i != 0) {
                sprintf(fhex_name, "%s_%d", fhex_name, i);
            }
            func_name = &fhex_name[0];
        }
        translate_to_llvm_func(func_name, &(ctx->llvm_func_set.lists[i]), is_external);
    }
}

void print_usage(const char *progname) {
    fprintf(stderr, "Usage: %s <input.tir>\n", progname);
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
    tcg_context_destroy(&ctx);
    return;
}

int init_llvm() {
    char *error_msg = NULL;
    LLVMTargetRef target;
    // Enable AArch64AOTStackSwitchPass/RISCVAOTStackSwitchPass
    int rc = setenv("LLVM_ENABLE_AOT_STACK_SWITCH", "1", 1);
    assert(rc == 0);
#if defined(__aarch64__)
    const char *default_triple = "aarch64-unknown-linux-gnu";
    const char* features = "+neon";
    LLVMInitializeAArch64TargetInfo();
    LLVMInitializeAArch64Target();
    LLVMInitializeAArch64TargetMC();
    LLVMInitializeAArch64AsmPrinter();
    LLVMInitializeAArch64AsmParser();
#elif (defined(__riscv) && __riscv_xlen == 64)
    const char *default_triple = "riscv64-unknown-linux-gnu";
    //const char* features = "+m,+a,+f,+d,+v,+unaligned-scalar-mem,+unaligned-vector-mem";
    const char* features = "+m,+a,+f,+d,+v";
    LLVMInitializeRISCVTargetInfo();
    LLVMInitializeRISCVTarget();
    LLVMInitializeRISCVTargetMC();
    LLVMInitializeRISCVAsmPrinter();
    LLVMInitializeRISCVAsmParser();
#endif
    if (LLVMGetTargetFromTriple(default_triple, &target, &error_msg)) {
        fprintf(stderr, "Failed to get target from triple %s\n", error_msg);
        return -1;
    }
    g_target_machine = LLVMCreateTargetMachine(target, default_triple, "generic", features,
                                             LLVMCodeGenLevelDefault, LLVMRelocPIC, LLVMCodeModelDefault);

    g_context = LLVMGetGlobalContext();
    g_attr_noinline = LLVMCreateEnumAttribute(g_context, LLVMNoInlineAttribute, 0);
    g_attr_alwaysinline = LLVMCreateEnumAttribute(g_context, LLVMAlwaysInlineAttribute, 0);
    g_attr_nounwind = LLVMCreateEnumAttribute(g_context, LLVMGetEnumAttributeKindForName("nounwind", strlen("nounwind")), 0);
    const char *attr_key = "target-features";
#if defined(__aarch64__)
    const char *attr_value = "+neon";
#elif (defined(__riscv) && __riscv_xlen == 64)
    // Unfortunately on Spacemit(R) X60, following instruction requires alignment: vse64.v v30,(a4)
    //const char *attr_value = "+m,+a,+f,+d,+v,+unaligned-scalar-mem,+unaligned-vector-mem";
    const char *attr_value = "+m,+a,+f,+d,+v";
#endif
    size_t attr_key_len = strlen(attr_key);
    size_t attr_value_len = strlen(attr_value);
    g_attr_target_features = LLVMCreateStringAttribute(g_context, attr_key, attr_key_len, attr_value, attr_value_len);
    g_module = LLVMModuleCreateWithNameInContext("qemuaot", g_context);

#if defined(__aarch64__)
    LLVMSetTarget(g_module, "aarch64-unknown-linux-gnu");
#elif (defined(__riscv) && __riscv_xlen == 64)
    LLVMSetTarget(g_module, "riscv64-unknown-linux-gnu");
#endif

    g_builder = LLVMCreateBuilder();
    return 0;
}

static int check_always_inline_status(LLVMValueRef F) {
    LLVMAttributeRef attr = LLVMGetEnumAttributeAtIndex(F, -1, LLVMAlwaysInlineAttribute);
    if (!attr) {
        return 0;
    }
    LLVMUseRef use = LLVMGetFirstUse(F);
    if (!use) {
        printf("Function '%s' with always_inline has no use - likely inlined\n", LLVMGetValueName(F));
        return 1;
    }
    return 0;
}

int fini_llvm(const char *output_file) {
    // FIXME: turn DUMP_IR into argument
#ifdef DUMP_IR
    LLVMDumpModule(g_module);
#endif
    LLVMValueRef F = LLVMGetFirstFunction(g_module);
    while (F != NULL) {
        if (LLVMIsAFunction(F) && LLVMIsDeclaration(F) && strncmp(LLVMGetValueName(F), "Fx", 2) == 0) {
            LLVMSetSection(F, ".text.declare_only");
            LLVMSetLinkage(F, LLVMWeakAnyLinkage);
            LLVMAddAttributeAtIndex(F, -1, g_attr_noinline);
            LLVMAddAttributeAtIndex(F, -1, g_attr_target_features);
            LLVMBasicBlockRef bb_entry = LLVMAppendBasicBlock(F, "entry");
            LLVMPositionBuilderAtEnd(g_builder, bb_entry);
            LLVMBasicBlockRef bb_loop = LLVMAppendBasicBlock(F, "loop");
            LLVMBuildBr(g_builder, bb_loop);
            LLVMPositionBuilderAtEnd(g_builder, bb_loop);
            LLVMBuildBr(g_builder, bb_loop);
            LLVMBasicBlockRef bb_exit = LLVMAppendBasicBlock(F, "exit");
            LLVMPositionBuilderAtEnd(g_builder, bb_exit);
            LLVMBuildRetVoid(g_builder);
        }
        F = LLVMGetNextFunction(F);
    }

    LLVMPassBuilderOptionsRef options = LLVMCreatePassBuilderOptions();
    LLVMErrorRef error = LLVMRunPasses(g_module, "default<O2>", g_target_machine, options);
    if (error) {
        char* error_msg = LLVMGetErrorMessage(error);
        fprintf(stderr, "Optimization failed: %s\n", error_msg);
        LLVMDisposeErrorMessage(error_msg);
        LLVMDisposePassBuilderOptions(options);
        LLVMDisposeTargetMachine(g_target_machine);
        return -1;
    }

    // Remove standalone always_inline functions(helpers)
    F = LLVMGetFirstFunction(g_module);
    while (F != NULL) {
        LLVMValueRef DC = NULL;
        if (check_always_inline_status(F)) {
            DC = F;
        }
        F = LLVMGetNextFunction(F);
        if (DC) {
            LLVMDeleteFunction(DC);
        }
    }

    char *error_msg = NULL;
    if (LLVMTargetMachineEmitToFile(g_target_machine, g_module, output_file, LLVMObjectFile, &error_msg)) {
        fprintf(stderr, "Failed to emit object file: %s", error_msg);
        return -1;
    }
    LLVMDisposeBuilder(g_builder);
    LLVMDisposeModule(g_module);
    LLVMContextDispose(g_context);
    LLVMDisposeTargetMachine(g_target_machine);
    return 0;
}

int main(int argc, const char *argv[]) {
    int rc = 0;
    char *output_file = NULL;
    if (argc < 1) {
        print_usage(argv[0]);
        rc = -1;
        goto exit;
    }
    const char *input_file = argv[1];
    if (!input_file) {
        fprintf(stderr, "Error: no input file specified\n");
        print_usage(argv[0]);
        rc = -1;
        goto exit;
    }
    output_file = (char *)calloc(1, strlen(input_file) + 1 + 2);
    assert(output_file);
    sprintf(output_file, "%s.o", input_file);

    // Get the path for helper_templates
    g_template_path = realpath(argv[0], NULL);
    assert(g_template_path);
    char *p = g_template_path;
    assert(p);
    while (strstr(p, "/") != NULL) {
        p = strstr(p, "/");
        if (*p == '/') {
            p += 1;
        }
    }
    assert((p - g_template_path) < PATH_MAX);
    *p = '\0';

    // Initialize LLVM target machine
    rc = init_llvm();
    if (rc != 0) {
        goto exit;
    }

    // Parse/Expand/Map TCG-ops into LLVM-IR
    parse_tcg_instructions(input_file);

    // Invoke LLVM pipeline to produce object file
    rc = fini_llvm(output_file);
    if (rc != 0) {
        goto exit;
    }

exit:
    if (g_template_path) {
        free(g_template_path);
    }
    if (output_file) {
        free(output_file);
    }
    return rc;
}
