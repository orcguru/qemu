LEX = flex
BISON = bison
CFLAGS = -O2 -g -Wall -I/home/felix/Install/llvm_riscv/include
LDFLAGS = -L/home/felix/Install/llvm_riscv/lib -lLLVMCore -lLLVMRemarks -lLLVMBitstreamReader -lLLVMBinaryFormat -lLLVMTargetParser -lLLVMSupport -lLLVMDemangle -lffi -lz -lstdc++ -lm -ltinfo

all: tcg_parser instr_def_parser

tcg_parser: tcg_parser.tab.o tcg_lexer.yy.o tcg_ast.o
	gcc -o $@ $^ $(LDFLAGS) -lfl

instr_def_parser: instr_def_parser.tab.o instr_def_lexer.yy.o instr_def_ast.o
	gcc -o $@ $^ $(LDFLAGS) -lfl

tcg_parser.tab.o: tcg_parser.tab.c tcg_lexer.yy.h
tcg_lexer.yy.o: tcg_lexer.yy.c tcg_lexer.yy.h
tcg_ast.o: tcg_ast.c
instr_def_parser.tab.o: instr_def_parser.tab.c instr_def_lexer.yy.h
instr_def_lexer.yy.o: instr_def_lexer.yy.c instr_def_lexer.yy.h
instr_def_ast.o: instr_def_ast.c

%.o: %.c
	gcc $(CFLAGS) -c $< -o $@

tcg_lexer.yy.c tcg_lexer.yy.h: tcg_lexer.l
	$(LEX) -o tcg_lexer.yy.c --header-file=tcg_lexer.yy.h $^

tcg_parser.tab.c: tcg_parser.y
	$(BISON) -d $^

instr_def_lexer.yy.c instr_def_lexer.yy.h: instr_def_lexer.l
	$(LEX) -o instr_def_lexer.yy.c --header-file=instr_def_lexer.yy.h $^

instr_def_parser.tab.c: instr_def_parser.y
	$(BISON) -d $^

clean:
	rm -f *.o tcg_parser.tab.* tcg_lexer.yy.* tcg_parser instr_def_parser.tab.* instr_def_lexer.yy.* instr_def_parser
