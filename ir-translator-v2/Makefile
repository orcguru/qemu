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
	rm -f *.o tcg_parser.tab.* tcg_lexer.yy.* tcg_mapper tcg_printer helper_lookup.c tests/expand_tcg_ir/*.out

# ===================================================================
# Test target
#
# For every *.tir file under tests/expand_tcg_ir/ :
#   - read its first line
#   - if the first line starts with ';', take the text after ';'
#     as an extra argument to prepend
#   - run:  ../../tcg_printer [extra-arg] [.tir file] > [.tir file].out
#   - diff  [.tir file].out against [.tir file].exp
#   - fail (non-zero exit) if they differ
# ===================================================================
TEST_DIR := tests/expand_tcg_ir
TIR_FILES := $(wildcard $(TEST_DIR)/*.tir)

# The actual tcg_printer binary is built two directories up, matching the
# original (relative) invocation. Allow overriding with TCG_PRINTER=.
ifeq ($(TCG_PRINTER),)
TCG_PRINTER := ./tcg_printer
endif

# Run tcg_printer over every .tir file, diff the result against .exp, and
# fail the build if any output differs. Uses an explicit ordered shell loop
# (instead of a pattern rule) because target names like "foo.tir_out" make
# Make mis-parse the stem ("foo.tir"), breaking the pattern rule.
test:
	@rc=0; \
	for tir in $(TIR_FILES); do \
		case "$$tir" in \
			*/*) dir=$(dir $$tir); base=$(notdir $$tir);; \
			*)   dir="";       base=$$tir;; \
		esac; \
		exp="$${tir%.tir}.exp"; \
		out="$${tir%.tir}.out"; \
		extra=""; \
		fline=$$(head -n 1 "$$tir"); \
		case "$$fline" in \
			';'*) extra=$${fline#';'} ;; \
		esac; \
		echo "==> $$tir $$extra"; \
		$(TCG_PRINTER) $$extra "$$tir" > "$$out"; \
		if [ -f "$$exp" ]; then \
			if diff -u "$$exp" "$$out"; then \
				echo "PASS: $$tir"; \
			else \
				echo "FAIL: $$tir (see diff above)"; \
				rc=1; \
			fi; \
		else \
			echo "WARNING: no .exp for $$tir (wrote .out only)"; \
		fi; \
	done; \
	exit $$rc

.PHONY: test
