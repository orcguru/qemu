%union {
    uint64_t    ival;
    OpCodeType  opc;
    HelperType  hlp;
    Operand     opnd;
    OpList      oplist;
    RelopType   r;
    SlotInfo    si;
    AttrSrcInfo attr_info;
    struct { uint8_t vs; uint8_t es; } vecspec;
}

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include "operand.h"
#include "unified_instr.h"
#include "tcg_ast.h"
#include "tcg_context.h"
#include "parser_util.h"

#ifndef YYSTYPE
#define YYSTYPE union YYSTYPE
#include "tcg_lexer.yy.h"
#endif
%}

%code requires {
    typedef struct TcgContext TcgContext;
    typedef void* yyscan_t;
    #include "tcg_ast.h"
    #include "operand.h"
}

%code {
    extern int yylex(YYSTYPE *, yyscan_t);
}

%define parse.error verbose
%define api.pure full
%parse-param { yyscan_t scanner }
%parse-param { TcgContext *ctx }
%lex-param { yyscan_t scanner }

%{
#include <stdio.h>
#include "tcg_context.h"
#include "mapper_util.h"

void yyerror(yyscan_t scanner, TcgContext *ctx, const char *s);
extern int column;
extern char *lineptr;
extern uint8_t instr_buf[64];
#define YYERROR_VERBOSE 1
%}

/* Tokens */
%token          COMMA COLON PLUS ENV
%token <ival>   IMM IMMD IMMX LABEL SCOPE
%token <opc>    OPCODE CALL
%token <hlp>    SYMBOL
%token <r>      RELOP
%token <si>     SLOT
%token <ival>   XMMVAR XMMTMP
%token <attr_info> MEMATTR SWAPATTR
%token <vecspec> VS_TOKEN ES_TOKEN

/* Non‑terminal types */
%type <opnd>    slot_op imm_op label_op relop_op attr_op symbol_op
%type <opnd>    env
%type <opnd>    operand
%type <oplist>  arg_list
%type <ival>    scalar_instr vector_instr call_instr
%type <attr_info> attrs attr

%start program
%%

program:
    xmm_def_list func_list
;

xmm_def_list:
    /* empty */
    | xmm_def_list xmm_def
;

xmm_def:
    XMMVAR COLON IMMX
    {
        register_xmm($1, $3);
    }
    | XMMTMP COLON IMMX
    {
        register_xmm_tmp($3);
    }
;

func_list:
    func
    | func_list func
;

func:
    SCOPE COLON IMMX COLON instr_list
    {
        /* Expand macro instructions */
        ctx->hex_offset = $3;
        debug_print_instr(ctx, "ORIG");
        build_per_instr_masks_collect_use_def(ctx);
        expand_tmp_slot_preservation(ctx);
        debug_print_instr(ctx, "after expand_tmp_slot_preservation");
        expand_push_ret_addr(ctx);
        debug_print_instr(ctx, "after expand_push_ret_addr");
        expand_ret(ctx);
        debug_print_instr(ctx, "after expand_ret");
        expand_jmp_direct(ctx);
        debug_print_instr(ctx, "after expand_jmp_direct");
        expand_llvm_func(ctx);
        debug_print_instr(ctx, "after expand_llvm_func");
        expand_call_inline(ctx);
        debug_print_instr(ctx, "after call_inline");
        expand_call_inline_exception(ctx);
        debug_print_instr(ctx, "after call_inline_exception");
        /* End of function – apply final slot types */
        sanity_check_op_type_solid(ctx);
        type_map_apply(ctx);
        handle_func(ctx, $1);
        tcg_context_reset(ctx);
    }
;

instr_list:
    /* empty */
    | instr_list instr
;

instr:
    scalar_instr
    | vector_instr
    | call_instr
;

/* -------- Scalar instructions -------- */
scalar_instr:
    OPCODE arg_list
    {
        UnifiedInstr *u = emit_instr(ctx, $1, 0, 0, $2.data, $2.len);
        expand_slot_alias(ctx, u);
        update_slot_types(ctx, u);
        register_stack_alloca(ctx, u);
        int skip_alias_instr = 0;
        if (u->opc == add_i64 && u->operand_count == 2) {
            register_alias(ctx, &u->operands[0], &u->operands[1]);
            skip_alias_instr = 1;
        } else if (u->opc == mov_i64 && (u->operands[1].kind == OP_VEC || u->operands[1].kind == OP_ENV)) {
            register_alias(ctx, &u->operands[0], &u->operands[1]);
            skip_alias_instr = 1;
        } else if (u->opc == call && u->operands[2].kind == OP_IMM && u->operands[2].imm) {
            try_unregister_alias(ctx, &u->operands[3]);
        } else if (opcoc[u->opc] > 0) {
            for (int i = 0; i < opcoc[u->opc]; ++i) {
                try_unregister_alias(ctx, &u->operands[i]);
            }
        }
        if (skip_alias_instr == 0) {
            op_list_free(&$2);
            append_instr(ctx, u);
        } else {
            free(u);
        }
        $$ = 0;
    }
;

/* -------- Vector instructions -------- */
vector_instr:
    OPCODE VS_TOKEN COMMA ES_TOKEN COMMA arg_list
    {
        UnifiedInstr *u = emit_instr(ctx, $1, $2.vs, $4.es, $6.data, $6.len);
        expand_slot_alias(ctx, u);
        update_slot_types(ctx, u);
        register_stack_alloca(ctx, u);
        op_list_free(&$6);
        append_instr(ctx, u);
        $$ = 0;
    }
;

/* -------- Call instructions -------- */
call_instr:
    CALL SYMBOL COMMA IMMX COMMA IMMD COMMA arg_list
    {
        OpList pre;
        op_list_init(&pre);
        Operand sym_op = { .kind = OP_SYMBOL, .symbol = $2 };
        op_list_add(&pre, sym_op);
        Operand immx_op = { .kind = OP_IMM, .imm = $4 };
        op_list_add(&pre, immx_op);
        Operand immd_op = { .kind = OP_IMM, .imm = $6 };
        op_list_add(&pre, immd_op);
        int total = pre.len + $8.len;
        Operand *merged = malloc(total * sizeof(Operand));
        memcpy(merged, pre.data, pre.len * sizeof(Operand));
        memcpy(merged + pre.len, $8.data, $8.len * sizeof(Operand));
        free(pre.data);
        UnifiedInstr *u = emit_instr(ctx, $1, 0, 0, merged, total);
        expand_slot_alias(ctx, u);
        update_slot_types(ctx, u);
        register_stack_alloca(ctx, u);
        free(merged);
        op_list_free(&$8);
        append_instr(ctx, u);
        $$ = 0;
    }
;

/* -------- Operand building rules -------- */
slot_op:
    SLOT
    {
        $$.kind = OP_SLOT;
        if ($1.type == SUB_SLOT_TMPL || $1.type == SUB_SLOT_TMPT) {
            $$.slot = get_mapped_slot(ctx, $1.type, $1.idx);
        } else {
            $$.slot = $1;
        }
    }
;

imm_op:
    IMM
    {
        $$.kind = OP_IMM;
        $$.imm = $1;
    }
    | IMMD
    {
        $$.kind = OP_IMM;
        $$.imm = $1;
    }
    | IMMX
    {
        $$.kind = OP_IMM;
        $$.imm = $1;
    }
    | VS_TOKEN IMMX
    {
        $$.kind = OP_IMM;
        $$.imm = $2;
    }
;

label_op:
    LABEL
    {
        $$.kind = OP_LABEL;
        $$.label = (uint16_t)$1;
    }
;

relop_op:
    RELOP
    {
        $$.kind = OP_RELOP;
        $$.relop = (uint8_t)$1;
    }
;

attr_op:
    attrs
    {
        $$.kind = OP_ATTR;
        merge_attr(&$$.attr_info, $1);
    }
;

attrs:
    attr
    {
        $$ = $1;
    }
    | attrs PLUS attr
    {
        $$ = $1;
        merge_attr(&$$, $3);
    }
;

attr:
    SWAPATTR
    {
        $$ = $1;
    }
    | MEMATTR
    {
        $$ = $1;
    }
;

symbol_op:
    SYMBOL
    {
        $$.kind = OP_SYMBOL;
        $$.symbol = $1;
    }
;

env:
    ENV
    {
        $$.kind = OP_ENV;
        $$.env.offset = 0;
    }
;

/* -------- Argument list -------- */
arg_list:
    /* empty */
    {
        op_list_init(&$$);
    }
    | operand
    {
        op_list_init(&$$);
        op_list_add(&$$, $1);
    }
    | arg_list COMMA operand
    {
        $$ = $1;
        op_list_add(&$$, $3);
    }
    | arg_list COMMA
    {
        $$ = $1;
    }
;

operand:
    slot_op   { $$ = $1; }
    | imm_op  { $$ = $1; }
    | label_op { $$ = $1; }
    | relop_op { $$ = $1; }
    | attr_op  { $$ = $1; }
    | symbol_op { $$ = $1; }
    | env      { $$ = $1; }
;

%%

/* ---- Helper functions ---- */
void yyerror(yyscan_t scanner, TcgContext *ctx, const char *s) {
    int line = yyget_lineno(scanner);
    fprintf(stderr, "error: %s in line %d, column %d\n", s, line, column);
    if (lineptr) {
        fprintf(stderr, "%s\n", lineptr);
    }
    for (int i = 0; i < column - 1; i++) {
        fprintf(stderr, "_");
    }
    fprintf(stderr, "^\n");
}
