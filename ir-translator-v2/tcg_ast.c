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

extern char *lineptr;
extern const char *helper_str[];

void handle_func(UnifiedInstr *head, int is_external) {
    /* Optionally reverse to process in original order */
    for (UnifiedInstr *u = head; u; u = u->next) {
        /* Translate u to LLVM IR, etc. */
        /*
        if (u->opc == call) {
            for (uint8_t o = 0; o < u->operand_count; ++o) {
                if (u->operands[o].kind == OP_SYMBOL) {
                    printf("call %s\n", helper_str[u->operands[o].symbol]);
                }
            }
        }
        */
    }
    /* Free the list */
    while (head) {
        UnifiedInstr *next = head->next;
        free(head);
        head = next;
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
