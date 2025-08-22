#ifndef TCG_CONTEXT_H
#define TCG_CONTEXT_H

#include "tcg_ast.h"

typedef struct TcgContext {
  TcgAst *root;     // AST root node
  TcgAst *current;  // Current instruction pointer
} TcgContext;

#endif
