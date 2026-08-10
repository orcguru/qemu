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

/* External functions */
extern void register_xmm(uint64_t idx, uint64_t offset);
extern void register_xmm_tmp(uint64_t offset);
extern XMMReg lookup_xmm(uint64_t offset);
extern void handle_func(UnifiedInstr *head, int is_external);

static UnifiedInstr *emit_instr(uint8_t opc, bool is_helper,
                                uint8_t vs, uint8_t es,
                                Operand *ops, int nops);
static void merge_attr(AttrSrcInfo *dest, const AttrSrcInfo src);

static void op_list_init(OpList *l) {
    l->data = NULL;
    l->len = 0;
    l->cap = 0;
}

static void op_list_add(OpList *l, Operand op) {
    if (l->len >= l->cap) {
        l->cap = l->cap ? l->cap * 2 : 8;
        l->data = realloc(l->data, l->cap * sizeof(Operand));
    }
    l->data[l->len++] = op;
}

static void op_list_free(OpList *l) {
    free(l->data);
    l->data = NULL;
    l->len = l->cap = 0;
}

/* Append a UnifiedInstr to the context's list (O(1) using tail) */
static void append_instr(TcgContext *ctx, UnifiedInstr *u) {
    u->next = NULL;
    if (ctx->instr_tail) {
        ctx->instr_tail->next = u;
        ctx->instr_tail = u;
    } else {
        ctx->instr_head = u;
        ctx->instr_tail = u;
    }
}

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
#include "tcg_context.h"
#include <stdio.h>
void yyerror(yyscan_t scanner, TcgContext *ctx, const char *s);
extern int column;
extern char *lineptr;
extern uint8_t instr_buf[64];
#define YYERROR_VERBOSE 1
%}

/* Tokens */
%token          COMMA LPAREN RPAREN COLON PLUS ENV INTERNAL EXTERNAL
%token <ival>   IMM IMMD IMMX LABEL
%token <opc>    OPCODE CALL
%token <hlp>    SYMBOL
%token <r>      RELOP
%token <si>     SLOT
%token <ival>   XMMVAR XMMTMP
%token <attr_info> MEMATTR SWAPATTR
%token <vecspec> VS_TOKEN ES_TOKEN

/* Non‑terminal types */
%type <opnd>    slot_op imm_op label_op relop_op attr_op symbol_op
%type <opnd>    env_or_xmm_op
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
    INTERNAL COLON IMMX COLON instr_list
    {
        handle_func(ctx->instr_head, 0);
        ctx->instr_head = NULL;
        ctx->instr_tail = NULL;
    }
  | EXTERNAL COLON IMMX COLON instr_list
    {
        handle_func(ctx->instr_head, 1);
        ctx->instr_head = NULL;
        ctx->instr_tail = NULL;
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
        UnifiedInstr *u = emit_instr($1, false, 0, 0, $2.data, $2.len);
        op_list_free(&$2);
        append_instr(ctx, u);
        $$ = 0;
    }
;

/* -------- Vector instructions -------- */
vector_instr:
    OPCODE VS_TOKEN ES_TOKEN arg_list
    {
        UnifiedInstr *u = emit_instr($1, false, $2.vs, $3.es, $4.data, $4.len);
        op_list_free(&$4);
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

        UnifiedInstr *u = emit_instr($1, true, 0, 0, merged, total);
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
        $$.slot.type = $1.type;
        $$.slot.idx  = $1.idx;
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

/* Combined env + immediate -> either env or xmm */
/* Also handle standalone ENV (last argument in CALL) -> OP_ENV with offset 0 */
env_or_xmm_op:
    ENV
    {
        $$.kind = OP_ENV;
        $$.env_offset = 0;
    }
  | ENV imm_op
    {
        XMMReg x = lookup_xmm($2.imm);
        if (x.xmm_idx != NON_XMM) {
            $$.kind = OP_XMM;
            $$.xmm.xmm_idx = x.xmm_idx;
            $$.xmm.xmm_offset = x.xmm_offset;
        } else {
            $$.kind = OP_ENV;
            $$.env_offset = (uint16_t)$2.imm;
        }
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
;

operand:
    slot_op         { $$ = $1; }
  | imm_op          { $$ = $1; }
  | label_op        { $$ = $1; }
  | relop_op        { $$ = $1; }
  | attr_op         { $$ = $1; }
  | symbol_op       { $$ = $1; }
  | env_or_xmm_op   { $$ = $1; }
;

%%

/* ---- Helper functions ---- */

static void merge_attr(AttrSrcInfo *dest, const AttrSrcInfo src) {
    if (src.subt == SUB_ATTR_STORAGE) {
        if (src.p.storage.atomic)
            dest->p.storage.atomic = src.p.storage.atomic;
        if (src.p.storage.alignment)
            dest->p.storage.alignment = src.p.storage.alignment;
        if (src.p.storage.ext)
            dest->p.storage.ext = src.p.storage.ext;
        if (src.p.storage.size)
            dest->p.storage.size = src.p.storage.size;
        dest->subt = SUB_ATTR_STORAGE;
    } else if (src.subt == SUB_ATTR_SWAP) {
        dest->p.swap |= src.p.swap;
        dest->subt = SUB_ATTR_SWAP;
    }
}

static UnifiedInstr *emit_instr(uint8_t opc, bool is_helper,
                                uint8_t vs, uint8_t es,
                                Operand *ops, int nops)
{
    size_t sz = sizeof(UnifiedInstr) + nops * sizeof(Operand);
    UnifiedInstr *u = malloc(sz);
    memset(u, 0, sz);

    u->opc = opc;
    u->is_helper = is_helper;
    u->noargs = (nops == 0);
    u->vs = vs;
    u->es = es;
    u->operand_count = nops;
    memcpy(u->operands, ops, nops * sizeof(Operand));
    u->next = NULL;

    return u;
}

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
