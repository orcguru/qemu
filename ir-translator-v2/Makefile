LEX = flex
BISON = bison
ARCH_HOST := $(shell uname -m)
ARCH_TARGET := $(shell uname -m)
ifeq ($(ARCH_TARGET), aarch64)
    LLVM_PATH = /home/felix/Install/llvm
else ifeq ($(ARCH_TARGET), riscv64)
    LLVM_PATH = /home/felix/Install/llvm_riscv
endif
CFLAGS = -O0 -g -Wall -I/usr/include/glib-2.0 -I$(LLVM_PATH)/include
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

all: tcg_mapper tcg_printer

tcg_mapper: tcg_parser.tab.o tcg_lexer.yy.o tcg_mapper.o mapper_util.o helper_lookup.o parser_util.o operand_static_types.o tcg_context.o i386_cpu.o
	gcc -o $@ $^ $(LDFLAGS) -lfl

tcg_printer: tcg_parser.tab.o tcg_lexer.yy.o tcg_printer.o mapper_util.o helper_lookup.o parser_util.o operand_static_types.o tcg_context.o i386_cpu.o
	gcc -o $@ $^ $(LDFLAGS) -lfl

tcg_parser.tab.o: tcg_parser.tab.c tcg_lexer.yy.h
tcg_lexer.yy.o: tcg_lexer.yy.c tcg_lexer.yy.h
tcg_mapper.o: tcg_mapper.c

%.o: %.c
	gcc $(CFLAGS) -c $< -o $@

tcg_lexer.yy.c tcg_lexer.yy.h: tcg_lexer.l
	$(LEX) -o tcg_lexer.yy.c --header-file=tcg_lexer.yy.h $^

tcg_parser.tab.c: tcg_parser.y
	$(BISON) -d $^

helper_lookup.c: helpers.gperf
	gperf -t -L ANSI-C -N lookup_helper $^ > helper_lookup.c
clean:
	rm -f *.o tcg_parser.tab.* tcg_lexer.yy.* tcg_mapper tcg_printer helper_lookup.c
