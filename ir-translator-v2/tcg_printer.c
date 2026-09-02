#include <stdio.h>
#include <limits.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include <fcntl.h>
#include <sys/stat.h>
#include "tcg_ast.h"
#include "tcg_context.h"
#include "tcg_parser.tab.h"
#include "tcg_lexer.yy.h"
#include "mapper_util.h"
#include "parser_util.h"

extern char *lineptr;
extern const char *helper_str[];

static int debug_enabled = 0;
int cfg_xmm_count = XMM_COUNT;

void print_operand(Operand *op, int is_output) {
    switch (op->kind) {
    case OP_SLOT:
        switch (op->slot.type) {
        case SUB_SLOT_ENVVAR:
            printf("%s", envvar_type_str[op->slot.idx]);
            break;
        case SUB_SLOT_XREG:
            printf("%s", xreg_type_str[op->slot.idx]);
            break;
        case SUB_SLOT_TMP:
            printf("t%d", op->slot.idx);
            break;
        default:
            assert(0);
        }
        break;
    case OP_IMM:
        printf("0x%lx", op->imm);
        break;
    case OP_LABEL:
        printf("L%d", op->label);
        break;
    case OP_RELOP:
        printf("%s", relop_type_str[op->relop]);
        break;
    case OP_ATTR:
        printf("attr");
        break;
    case OP_SYMBOL:
        printf("%s", helper_str[op->symbol]);
        break;
    case OP_VEC:
        if (op->vec.offset == 0) {
            printf("v%d", op->vec.idx);
        } else {
            printf("v%d:o%d", op->vec.idx, op->vec.offset);
        }
        break;
    case OP_ENV:
        if (op->env.offset == 0) {
            printf("env");
        } else {
            printf("env:0x%x", op->env.offset);
        }
        break;
    case OP_LASTARG:
        printf("__last_arg__");
        break;
    default:
        printf("\nCheck kind:%d\n", op->kind);
        fflush(NULL);
        assert(0);
    }
}

void print_instr(UnifiedInstr *u) {
    printf("%s", opcode_type_str[u->opc]);
    if (is_call(u)) {
        printf(" %s,", helper_str[u->operands[0].symbol]);
        for (int i = TCG_CALL_PREFIX_COUNT; i < u->operand_count; ++i) {
            print_operand(&u->operands[i], (u->operands[2].imm && i == TCG_CALL_PREFIX_COUNT) ? 1 : 0);
            if (i < (u->operand_count - 1)) {
                printf(",");
            }
        }
        printf("\n");
        return;
    } else if (u->vs != 0) {
        printf(" v%d,e%d,", u->vs, u->es);
    } else {
        printf(" ");
    }
    for (int i = 0; i < u->operand_count; ++i) {
        print_operand(&u->operands[i], i < opcoc[u->opc] ? 1 : 0);
        if (i < (u->operand_count - 1)) {
            printf(",");
        }
    }
    printf("\n");
}

void debug_print_instr(TcgContext *ctx, const char *msg) {
    if (!debug_enabled) {
        return;
    }

    printf("===============================================\n");
    printf("0x%lx %s:\n", ctx->hex_offset, msg);
    if (ctx->llvm_func_set.num_lists) {
        for (int i = 0; i < ctx->llvm_func_set.num_lists; ++i) {
            for (UnifiedInstr *u = ctx->llvm_func_set.lists[i].head; u; u = u->next) {
                print_instr(u);
            }
            printf("\n");
        }
    } else {
        for (UnifiedInstr *u = ctx->instr_head; u; u = u->next) {
            print_instr(u);
        }
        printf("\n");
    }
}

void handle_func(TcgContext *ctx, int is_external) {
    printf("FINAL:0x%lx %s:\n", ctx->hex_offset, is_external ? "EXT":"INT");
    for (int i = 0; i < ctx->llvm_func_set.num_lists; ++i) {
        if (ctx->llvm_func_set.lists[i].trampoline_name[0]) {
            printf("FUNC:%s N%d\n", ctx->llvm_func_set.lists[i].trampoline_name, i);
        } else {
            printf("FUNC:%lx N%d\n", ctx->hex_offset, i);
        }
        for (UnifiedInstr *u = ctx->llvm_func_set.lists[i].head; u; u = u->next) {
            print_instr(u);
        }
        printf("\n");
    }
}

void print_usage(const char *progname) {
    printf("Usage: %s [options] <input.tcg>\n", progname);
    printf("\n");
    printf("Parse and print TCG intermediate representation.\n");
    printf("\n");
    printf("Options:\n");
    printf("  -d            Enable debug printing of instruction lists\n");
    printf("                  (shows intermediate per-function lists when set).\n");
    printf("                  By default debug output is suppressed.\n");
    printf("  -x <count>    Override the number of XMM registers (cfg_xmm_count).\n");
    printf("                  Must be a non-negative integer. Default is %d\n", XMM_COUNT);
    printf("                  (the value of the XMM_COUNT compile-time macro).\n");
    printf("  -h, --help    Show this help message and exit\n");
    printf("\n");
    printf("Arguments:\n");
    printf("  <input.tcg>   Path to the TCG IR text file to parse (required)\n");
    printf("\n");
    printf("Examples:\n");
    printf("  %s code.tir              # normal output only\n", progname);
    printf("  %s -d code.tir           # enable debug instruction dump\n", progname);
    printf("  %s -x 16 code.tir        # use 16 XMM registers\n", progname);
    printf("  %s -x 8 -d code.tir      # combine options\n", progname);
    printf("  %s -h                    # show help\n", progname);
    printf("\n");
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

int main(int argc, const char *argv[]) {
    const char *input_file = NULL;

    for (int i = 1; i < argc; ++i) {
        if (strcmp(argv[i], "-d") == 0) {
            debug_enabled = 1;
        } else if (strcmp(argv[i], "-x") == 0) {
            if (i + 1 >= argc) {
                fprintf(stderr, "Error: option '%s' requires an argument\n\n", argv[i]);
                print_usage(argv[0]);
                return 1;
            }
            char *end = NULL;
            long val = strtol(argv[i + 1], &end, 0);
            if (*end != '\0' || val < 0 || val > XMM_COUNT) {
                fprintf(stderr, "Error: invalid value '%s' for -x (expected 0..%d)\n\n",
                        argv[i + 1]);
                print_usage(argv[0]);
                return 1;
            }
            cfg_xmm_count = (int)val;
            i++;
        } else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        } else if (argv[i][0] == '-') {
            fprintf(stderr, "Error: unknown option '%s'\n\n", argv[i]);
            print_usage(argv[0]);
            return 1;
        } else {
            if (input_file) {
                fprintf(stderr, "Error: multiple input files given ('%s' and '%s')\n\n",
                        input_file, argv[i]);
                print_usage(argv[0]);
                return 1;
            }
            input_file = argv[i];
        }
    }

    if (!input_file) {
        fprintf(stderr, "Error: no input file specified\n\n");
        print_usage(argv[0]);
        return 1;
    }

    parse_tcg_instructions(input_file);
    return 0;
}
