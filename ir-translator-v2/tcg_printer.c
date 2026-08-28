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
    default:
        printf("\nCheck kind:%d\n", op->kind);
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

void debug_print_instr(uint64_t off, TcgContext *ctx, const char *msg) {
#ifdef DEBUG
    printf("===============================================\n");
    printf("0x%lx %s:\n", off, msg);
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
#endif
}

void handle_func(uint64_t off, TcgContext *ctx, int is_external) {
    printf("0x%lx %s:\n", off, is_external ? "EXT":"INT");
    for (int i = 0; i < ctx->llvm_func_set.num_lists; ++i) {
        for (UnifiedInstr *u = ctx->llvm_func_set.lists[i].head; u; u = u->next) {
            print_instr(u);
        }
        printf("\n");
    }
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
    parse_tcg_instructions(argv[1]);
    return 0;
}
