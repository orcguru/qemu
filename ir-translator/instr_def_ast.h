#ifndef __INSTR_AST_DEF
#define __INSTR_AST_DEF

void handle_def(const char *instr);
void insert_field(const char *type, const char *name);
void gen_prolog(void);
void gen_epilog(void);

#endif
