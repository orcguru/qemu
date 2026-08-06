%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#include "operand.h"
#include "unified_instr.h"

static UnifiedInstr *emit_instr(uint8_t opc, bool is_helper,
                                uint8_t vs, uint8_t es,
                                Operand *ops, int nops);

/* Dynamic operand list builder */
typedef struct {
    Operand *data;
    int      len;
    int      cap;
} OpList;

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

#define YYSTYPE YYSTYPE
%}

%union {
    uint64_t    ival;
    char       *sval;
    Operand     opnd;
    OpList      oplist;
    uint8_t     u8;
    uint16_t    u16;
    struct { uint8_t vs; uint8_t es; } vecspec;
}

/* Tokens */
%token <ival>   IMM IMMD IMMX LABEL RELOP ATTR SLOT ENV
%token <ival>   XMM
%token <sval>   SYMBOL
%token <vecspec> VS_TOKEN ES_TOKEN
%token          COMMA LPAREN RPAREN
%token <ival>   OPCODE CALL BRCOND SETLABL JMPDIR CALLDIR BR

/* Non‑terminal types */
%type <opnd>    slot_op imm_op immd_op label_op relop_op attr_op symbol_op
%type <opnd>    xmm_op env_op
%type <opnd>    operand
%type <oplist>  arg_list
%type <ival>    instr scalar_instr vector_instr call_instr branch_instr

%start program

%%

program:
    /* empty */
  | program instr
  ;

instr:
    scalar_instr
  | vector_instr
  | call_instr
  | branch_instr
  ;

/* -------- Scalar instructions -------- */
scalar_instr:
    OPCODE arg_list
    {
        UnifiedInstr *u = emit_instr($1, false, 0, 0, $2.data, $2.len);
        op_list_free(&$2);
        $$ = 0;
    }
  ;

/* -------- Vector instructions -------- */
vector_instr:
    OPCODE VS_TOKEN ES_TOKEN arg_list
    {
        UnifiedInstr *u = emit_instr($1, false, $2.vs, $3.es, $4.data, $4.len);
        op_list_free(&$4);
        $$ = 0;
    }
  ;

/* -------- Call instructions -------- */
call_instr:
    CALL SYMBOL IMMX IMMD arg_list
    {
        OpList pre;
        op_list_init(&pre);
        Operand sym_op = { .kind = OP_SYMBOL, .symbol = strdup($2) };
        op_list_add(&pre, sym_op);
        Operand immx_op = { .kind = OP_IMM, .imm = $3 };
        op_list_add(&pre, immx_op);
        Operand immd_op = { .kind = OP_IMMD, .imm = $4 };
        op_list_add(&pre, immd_op);

        int total = pre.len + $5.len;
        Operand *merged = malloc(total * sizeof(Operand));
        memcpy(merged, pre.data, pre.len * sizeof(Operand));
        memcpy(merged + pre.len, $5.data, $5.len * sizeof(Operand));
        free(pre.data);

        UnifiedInstr *u = emit_instr(0, true, 0, 0, merged, total);
        free(merged);
        op_list_free(&$5);
        $$ = 0;
    }
  ;

/* -------- Branch / label instructions -------- */
branch_instr:
    BRCOND slot_op COMMA slot_op COMMA relop_op COMMA label_op
    {
        OpList l;
        op_list_init(&l);
        op_list_add(&l, $2);
        op_list_add(&l, $4);
        op_list_add(&l, $6);
        op_list_add(&l, $8);
        UnifiedInstr *u = emit_instr(BRCOND, false, 0, 0, l.data, l.len);
        op_list_free(&l);
        $$ = 0;
    }
  | SETLABL label_op
    {
        OpList l;
        op_list_init(&l);
        op_list_add(&l, $2);
        UnifiedInstr *u = emit_instr(SETLABL, false, 0, 0, l.data, l.len);
        op_list_free(&l);
        $$ = 0;
    }
  | JMPDIR label_op
    {
        OpList l;
        op_list_init(&l);
        op_list_add(&l, $2);
        UnifiedInstr *u = emit_instr(JMPDIR, false, 0, 0, l.data, l.len);
        op_list_free(&l);
        $$ = 0;
    }
  | CALLDIR label_op
    {
        OpList l;
        op_list_init(&l);
        op_list_add(&l, $2);
        UnifiedInstr *u = emit_instr(CALLDIR, false, 0, 0, l.data, l.len);
        op_list_free(&l);
        $$ = 0;
    }
  | BR label_op
    {
        OpList l;
        op_list_init(&l);
        op_list_add(&l, $2);
        UnifiedInstr *u = emit_instr(BR, false, 0, 0, l.data, l.len);
        op_list_free(&l);
        $$ = 0;
    }
  ;

/* -------- Operand building rules -------- */
slot_op:
    SLOT
    {
        $$.kind = OP_SLOT;
        $$.slot.type = ($1 >> 10) & 0x3;
        $$.slot.idx  = $1 & 0x3FF;
    }
  ;

imm_op:
    IMM
    {
        $$.kind = OP_IMM;
        $$.imm = $1;
    }
  ;

immd_op:
    IMMD
    {
        $$.kind = OP_IMMD;
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
    ATTR
    {
        $$.kind = OP_ATTR;
        $$.attr = (uint8_t)$1;
    }
  ;

symbol_op:
    SYMBOL
    {
        $$.kind = OP_SYMBOL;
        $$.symbol = strdup($1);
    }
  ;

xmm_op:
    XMM
    {
        $$.kind = OP_XMM;
        $$.xmm.xmm_idx = ($1 >> 4) & 0x7F;
        $$.xmm.xmm_offset = $1 & 0xF;
    }
  ;

env_op:
    ENV
    {
        $$.kind = OP_ENV;
        $$.env_offset = (uint16_t)$1;
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
    slot_op     { $$ = $1; }
  | imm_op      { $$ = $1; }
  | immd_op     { $$ = $1; }
  | label_op    { $$ = $1; }
  | relop_op    { $$ = $1; }
  | attr_op     { $$ = $1; }
  | symbol_op   { $$ = $1; }
  | xmm_op      { $$ = $1; }
  | env_op      { $$ = $1; }
  ;

%%

/* ---- emit_instr implementation ---- */
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

    return u;
}

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

int main(void) {
    yyparse();
    return 0;
}
