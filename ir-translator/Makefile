LEX = flex
BISON = bison
ARCH_HOST := $(shell uname -m)
ARCH_TARGET := $(shell uname -m)
ifeq ($(ARCH_TARGET), aarch64)
    LLVM_PATH = /home/felix/Install/llvm
else ifeq ($(ARCH_TARGET), riscv64)
    LLVM_PATH = /home/felix/Install/llvm_riscv
endif
CFLAGS = -O2 -g -Wall -I/usr/include/glib-2.0 -I$(LLVM_PATH)/include
ifeq ($(ARCH_HOST), aarch64)
    CFLAGS += -I/usr/lib64/glib-2.0/include
else ifeq ($(ARCH_HOST), riscv64)
    CFLAGS += -I/usr/lib/riscv64-linux-gnu/glib-2.0/include
endif
LDFLAGS := $(shell $(LLVM_PATH)/bin/llvm-config --ldflags --libs all | tr -d '\n')
LDFLAGS += -lffi -lz -lstdc++ -lm -ltinfo -lzstd -lglib-2.0

ifeq ($(ARCH_HOST), aarch64)
    LDFLAGS += -L/usr/lib64
else ifeq ($(ARCH_HOST), riscv64)
    LDFLAGS += -L/usr/lib/riscv64-linux-gnu
endif

all: tcg_parser

tcg_parser: tcg_parser.tab.o tcg_lexer.yy.o tcg_ast.o api.o instr.o
	gcc -o $@ $^ $(LDFLAGS) -lfl

instr_def_parser: instr_def_parser.tab.o instr_def_lexer.yy.o instr_def_ast.o
	gcc -o $@ $^ $(LDFLAGS) -lfl

tcg_parser.tab.o: tcg_parser.tab.c tcg_lexer.yy.h
tcg_lexer.yy.o: tcg_lexer.yy.c tcg_lexer.yy.h
tcg_ast.o: tcg_ast.c
instr_def_parser.tab.o: instr_def_parser.tab.c instr_def_lexer.yy.h
instr_def_lexer.yy.o: instr_def_lexer.yy.c instr_def_lexer.yy.h
instr_def_ast.o: instr_def_ast.c
api.o: api.c
instr.o: instr.c

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

api.c: instr_def.h instr_def_parser
	./instr_def_parser instr_def.h > api.c

clean:
	rm -f *.o tcg_parser.tab.* tcg_lexer.yy.* tcg_parser instr_def_parser.tab.* instr_def_lexer.yy.* instr_def_parser api.c
