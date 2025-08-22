#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tcg_ast.h"
#include "tcg_context.h"
#include "tcg_parser.tab.h"
#include "lex.yy.h"
#include <llvm-c/Core.h>
#include <llvm-c/Types.h>
#include <stdio.h>

extern char *lineptr;

LLVMModuleRef create_module(const char* module_name) {
    LLVMContextRef context = LLVMGetGlobalContext();
    LLVMModuleRef module = LLVMModuleCreateWithNameInContext(module_name, context);

    LLVMSetTarget(module, "riscv64-unknown-linux-gnu");
    return module;
}

TcgAst* create_func(char* label, TcgAst* instructions) {
    TcgAst* func = malloc(sizeof(TcgAst));
    func->type = OP_BLOCK;
    func->data.func.label = strdup(label);
    func->data.func.instructions = instructions;
    return func;
}

void parse_tcg_instructions(const char *filename) {
    FILE* source_file = fopen(filename, "r");
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
