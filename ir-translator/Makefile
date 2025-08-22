LEX = flex
BISON = bison
CFLAGS = -O2 -g -Wall -I/home/felix/Install/llvm_riscv/include
LDFLAGS = -L/home/felix/Install/llvm_riscv/lib -lLLVMCore -lLLVMRemarks -lLLVMBitstreamReader -lLLVMBinaryFormat -lLLVMTargetParser -lLLVMSupport -lLLVMDemangle -lffi -lz -lstdc++ -lm -ltinfo

all: tcg_parser

tcg_parser: tcg_parser.tab.o lex.yy.o tcg_ast.o
	gcc -o $@ $^ $(LDFLAGS) -lfl

tcg_parser.tab.o: tcg_parser.tab.c lex.yy.h
lex.yy.o: lex.yy.c lex.yy.h
tcg_ast.o: tcg_ast.c

%.o: %.c
	gcc $(CFLAGS) -c $< -o $@

lex.yy.c lex.yy.h: tcg_lexer.l
	$(LEX) --header-file=lex.yy.h $^

tcg_parser.tab.c: tcg_parser.y
	$(BISON) -d $^

clean:
	rm -f *.o tcg_parser.tab.* lex.yy.* tcg_parser
