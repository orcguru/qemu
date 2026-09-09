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

# ============================================================================
# QEMU TCG preprocessed-file collection
#
# Required variable:
#   QEMU_TOP   - path to the QEMU source tree (e.g. /path/to/qemu-runtime)
#
# Optional variables:
#   QEMU_BUILD - build directory (default: $(QEMU_TOP)/build)
#   QEMU_CC    - C compiler to use (default: clang)
#   QEMU_TARGET_LIST - target list (default: x86_64-linux-user)
#
# Example:
#   make qemu-preprocess QEMU_TOP=/home/felix/Github/qemu-runtime
# ============================================================================

QEMU_BUILD ?= $(QEMU_TOP)/build
QEMU_CC ?= clang
QEMU_TARGET_LIST ?= x86_64-linux-user

QEMU_FPU_DIR := $(QEMU_TOP)/fpu
QEMU_TCG_DIR := $(QEMU_TOP)/target/i386/tcg
QEMU_FPU_HELPER := $(QEMU_TCG_DIR)/fpu_helper.c

# Files we create / modify (used by clean to undo everything)
COPIED_INC_FILES := $(wildcard $(QEMU_FPU_DIR)/*.inc)
COPIED_INCS := $(foreach f,$(notdir $(COPIED_INC_FILES)),$(QEMU_TCG_DIR)//$f)

# Marker file recording that fpu_helper.c was prepended (for clean restoration)
SOFTFLOAT_MARKER := $(QEMU_TCG_DIR)/.softfloat_prepended

# Final preprocessed output (relative to QEMU_BUILD)
PREPROCESSED_OBJ := libqemu-$(QEMU_TARGET_LIST).a.p/target_i386_tcg_fpu_helper.c.o
PREPROCESSED_OUT := $(QEMU_BUILD)/$(PREPROCESSED_OBJ).E

# Build-log captured from V=1 (contains the full clang command line)
BUILD_LOG := $(QEMU_BUILD)/fpu_helper_build.log

all: tcg_mapper tcg_printer

tcg_mapper: parser.tab.o lexer.yy.o tcg_mapper.o mapper_util.o helper_lookup.o util.o expander.o operand_static_types.o i386_cpu.o
	gcc -o $@ $^ $(LDFLAGS) -lfl

tcg_printer: parser.tab.o lexer.yy.o tcg_printer.o mapper_util.o helper_lookup.o util.o expander.o operand_static_types.o i386_cpu.o
	gcc -o $@ $^ $(LDFLAGS) -lfl

parser.tab.o: parser.tab.c lexer.yy.h
lexer.yy.o: lexer.yy.c lexer.yy.h
tcg_mapper.o: tcg_mapper.c

%.o: %.c
	gcc $(CFLAGS) -c $< -o $@

lexer.yy.c lexer.yy.h: lexer.l
	$(LEX) -o lexer.yy.c --header-file=lexer.yy.h $^

parser.tab.c: parser.y
	$(BISON) -d $^

helper_lookup.c: helpers.gperf
	gperf -t -L ANSI-C -N lookup_helper $^ > helper_lookup.c

# ============================================================================
# QEMU TCG preprocessing targets
# ============================================================================

# Convenience entry point
qemu-preprocess: check-qemu-top $(QEMU_BUILD)/Makefile copy-fpu-files prepend-softfloat capture-command preprocess-extract
	@echo "==================================================================="
	@echo "Preprocessed file ready: $(PREPROCESSED_OUT)"
	@echo "==================================================================="

# --- 1. sanity check ---------------------------------------------------------

check-qemu-top:
	@if [ -z "$(QEMU_TOP)" ]; then \
		echo "ERROR: QEMU_TOP is not set."; \
		echo "Usage: make qemu-preprocess QEMU_TOP=/path/to/qemu-source"; \
		exit 1; \
	fi
	@if [ ! -d "$(QEMU_TOP)" ]; then \
		echo "ERROR: QEMU_TOP directory '$(QEMU_TOP)' does not exist."; \
		exit 1; \
	fi
	@if [ ! -f "$(QEMU_TOP)/configure" ]; then \
		echo "ERROR: '$(QEMU_TOP)/configure' not found; is this a QEMU source tree?"; \
		exit 1; \
	fi
	@if [ ! -f "$(QEMU_FPU_HELPER)" ]; then \
		echo "ERROR: target file '$(QEMU_FPU_HELPER)' not found."; \
		exit 1; \
	fi

# --- 2. copy fpu/*.inc into target/i386/tcg/ --------------------------------

copy-fpu-files: $(COPIED_INCS)

$(QEMU_TCG_DIR)/%.inc: $(QEMU_FPU_DIR)/%.inc | $(QEMU_TCG_DIR)
	cp -f $< $@
	@echo "copied: $< -> $@"

$(QEMU_TCG_DIR):
	@mkdir -p $(QEMU_TCG_DIR)

# --- 3. prepend fpu/softfloat.c to fpu_helper.c ------------------------------

prepend-softfloat: $(SOFTFLOAT_MARKER)

$(SOFTFLOAT_MARKER): $(QEMU_FPU_HELPER) $(QEMU_FPU_DIR)/softfloat.c
	@if [ -f "$(SOFTFLOAT_MARKER)" ]; then \
		echo "softfloat.c already prepended (marker exists): $(SOFTFLOAT_MARKER)"; \
	else \
		echo "Prepending $(QEMU_FPU_DIR)/softfloat.c to $(QEMU_FPU_HELPER) ..."; \
		cp -f $(QEMU_FPU_HELPER) $(QEMU_FPU_HELPER).orig; \
		cat $(QEMU_FPU_DIR)/softfloat.c $(QEMU_FPU_HELPER).orig > $(QEMU_FPU_HELPER); \
		touch $(SOFTFLOAT_MARKER); \
		echo "done (original saved as fpu_helper.c.orig)."; \
	fi

# --- 4. configure + capture the compile command ------------------------------

$(QEMU_BUILD)/Makefile:
	@echo "Creating build directory: $(QEMU_BUILD)"
	@mkdir -p $(QEMU_BUILD)
	@cd $(QEMU_BUILD) && \
		$(QEMU_TOP)/configure \
			--target-list=$(QEMU_TARGET_LIST) \
			--enable-debug \
			--enable-debug-tcg \
			--enable-plugins \
			--cc=$(QEMU_CC)

# Run the requested object build with V=1 and capture ALL output (stdout+stderr)
capture-command: $(QEMU_BUILD)/Makefile
	@echo "Building $(PREPROCESSED_OBJ) with V=1, logging to $(BUILD_LOG)"
	@cd $(QEMU_BUILD) && \
		( make V=1 ./$(PREPROCESSED_OBJ) 2>&1 || true ) | tee $(BUILD_LOG)

# The build log is the (side-effect) output of the capture-command step above.
$(BUILD_LOG): capture-command

# --- 5. transform the captured command:  -c  ->  -E  -------------------------
#     and run it to produce the preprocessed .E file

# Helper script (rendered into the build dir) that:
#   1. finds the last clang compile line in the build log,
#   2. strips any leading "[NN/NN]" ninja-style progress prefix,
#   3. rewrites " -o XXX.o -c " -> " -o XXX.o.E -E ",
#   4. runs the resulting command from the build directory.
#
# Defined as a variable so we can `eval` it with one shell invocation (avoids
# make recursively invoking /bin/sh for every line).
define PREPROCESS_SCRIPT
set -e; \
echo "Extracting clang command from $(BUILD_LOG)"; \
raw=$$(grep -E '\bclang\b' "$(BUILD_LOG)" | grep -E -- '-c[[:space:]]+\S+\.c(\s|$$)' | tail -n 1); \
if [ -z "$$raw" ]; then \
	echo "ERROR: no clang compile command found in $(BUILD_LOG)"; \
	echo "----- last 40 lines of build log -----"; \
	tail -n 40 "$(BUILD_LOG)"; \
	exit 1; \
fi; \
echo "Raw line from log:"; \
echo "$$raw"; \
cmd=$$(echo "$$raw" | sed -E 's#^[[:space:]]*\[[0-9]+/[0-9]+\][[:space:]]*##'); \
echo "Command (prefix stripped):"; \
echo "$$cmd"; \
modified=$$(echo "$$cmd" | sed -E 's#(-o[[:space:]]+[^[:space:]]+\.o)[[:space:]]+-c([[:space:]]+)#\1.E -E\2#'); \
echo "Modified command:"; \
echo "$$modified"; \
if [ "$$cmd" = "$$modified" ]; then \
	echo "ERROR: -o XXX.o -c rewrite did not match; command left unchanged."; \
	exit 1; \
fi; \
eval "$$modified"; \
if [ -f "$(PREPROCESSED_OBJ).E" ]; then \
	echo "SUCCESS: preprocessed file -> $(PREPROCESSED_OUT)"; \
else \
	echo "ERROR: expected output $(PREPROCESSED_OBJ).E was not produced."; \
	exit 1; \
fi
endef
export PREPROCESS_SCRIPT

preprocess-extract: $(BUILD_LOG)
	cd $(QEMU_BUILD) && eval "$$PREPROCESS_SCRIPT"

# ============================================================================
# Clean: undo ALL previous changes to QEMU source + remove intermediate files
# ============================================================================
clean: clean-qemu-source clean-local

# Remove everything we added to the QEMU source tree
clean-qemu-source:
	@if [ -n "$(QEMU_TOP)" ] && [ -d "$(QEMU_TOP)" ]; then \
		echo "Undoing QEMU source modifications in $(QEMU_TOP) ..."; \
		rm -f $(COPIED_INCS); \
		rm -f $(SOFTFLOAT_MARKER); \
		if [ -f "$(QEMU_FPU_HELPER).orig" ]; then \
			echo "Restoring original $(QEMU_FPU_HELPER)"; \
			mv -f $(QEMU_FPU_HELPER).orig $(QEMU_FPU_HELPER); \
		fi; \
		rm -rf $(QEMU_BUILD); \
		echo "QEMU source restored and build directory removed."; \
	else \
		echo "QEMU_TOP not set or not a directory; skipping QEMU cleanup."; \
	fi

# Remove local build artifacts (original Makefile clean)
clean-local:
	rm -f *.o parser.tab.* lexer.yy.* tcg_mapper tcg_printer helper_lookup.c tests/expand_tcg_ir/*.out

# Alias preserved from original Makefile
clean-all: clean

# ============================================================================
# Testing infrastructure (preserved)
# ============================================================================
TEST_DIR := tests/expand_tcg_ir
TIR_FILES := $(wildcard $(TEST_DIR)/*.tir)

ifeq ($(TCG_PRINTER),)
	TCG_PRINTER := ./tcg_printer
endif

# Run tcg_printer over every .tir file, diff the result against .exp, and
# fail the build if any output differs.
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
		$(TCG_PRINTER) $$extra "$$tir" > "$$out" 2>&1; \
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

.PHONY: all test clean clean-all clean-local clean-qemu-source \
	qemu-preprocess check-qemu-top copy-fpu-files prepend-softfloat \
	capture-command preprocess-extract
