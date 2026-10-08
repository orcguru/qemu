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
LLVM_LDFLAGS := $(shell $(LLVM_PATH)/bin/llvm-config --ldflags --libs all 2>/dev/null | tr -d '\n')
LDFLAGS := $(LLVM_LDFLAGS) -lffi -lz -lstdc++ -lm -ltinfo -lzstd -lglib-2.0
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
# Examples:
#   make qemu-preprocess QEMU_TOP=/home/felix/Github/qemu          # fpu_helper.c
#   make qemu-preprocess-tcg-runtime QEMU_TOP=/home/felix/Github/qemu
# ============================================================================

QEMU_BUILD ?= $(QEMU_TOP)/build
QEMU_CC ?= clang
QEMU_TARGET_LIST ?= x86_64-linux-user

# ---------- fpu_helper.c (target i386) --------------------------------------
QEMU_FPU_DIR := $(QEMU_TOP)/fpu
QEMU_TCG_DIR := $(QEMU_TOP)/target/i386/tcg
QEMU_FPU_HELPER := $(QEMU_TCG_DIR)/fpu_helper.c

# Files we create / modify (used by clean to undo everything).
# Evaluated at recipe time (not parse time) so QEMU_TOP set on the command
# line is honored, and we never match QEMU's own .inc files.
define COPIED_INCS
$(foreach f,$(notdir $(wildcard $(QEMU_FPU_DIR)/*.inc)),$(QEMU_TCG_DIR)/$f)
endef

# Marker file recording that fpu_helper.c was prepended (for clean restoration)
SOFTFLOAT_MARKER := $(QEMU_TCG_DIR)/.softfloat_prepended

# Per-target object paths (relative to QEMU_BUILD)
PREPROCESSED_OBJ_FPU       := libqemu-$(QEMU_TARGET_LIST).a.p/target_i386_tcg_fpu_helper.c.o
PREPROCESSED_OBJ_TCG_RT    := libuser.a.p/accel_tcg_tcg-runtime.c.o
PREPROCESSED_OBJ_CC_HELPER := libqemu-$(QEMU_TARGET_LIST).a.p/target_i386_tcg_cc_helper.c.o
PREPROCESSED_OBJ_INT_HELPER := libqemu-$(QEMU_TARGET_LIST).a.p/target_i386_tcg_int_helper.c.o
PREPROCESSED_OBJ_USER_EXEC  := libuser.a.p/accel_tcg_user-exec.c.o

# Default (backward-compatible) preprocessed output
PREPROCESSED_OBJ := $(PREPROCESSED_OBJ_FPU)
PREPROCESSED_OUT := $(QEMU_BUILD)/$(PREPROCESSED_OBJ).E

# Build-log captured from V=1 (contains the full clang command line)
BUILD_LOG := $(QEMU_BUILD)/fpu_helper_build.log

# Object lists are shared by the native build and the sanitizer build.
COMMON_OBJS  := parser.tab.o lexer.yy.o mapper_util.o helper_lookup.o \
	util.o expander.o operand_static_types.o i386_cpu.o
MAPPER_OBJS  := $(COMMON_OBJS) mapper.o tcg_llvm_tag.o tcg2llvm.o
PRINTER_OBJS := $(COMMON_OBJS) printer.o

all: tcg_mapper tcg_printer

tcg_mapper: $(MAPPER_OBJS)
	gcc -o $@ $^ $(LDFLAGS) -lfl

tcg_printer: $(PRINTER_OBJS)
	gcc -o $@ $^ $(LDFLAGS) -lfl

parser.tab.o: parser.tab.c lexer.yy.h
lexer.yy.o: lexer.yy.c lexer.yy.h

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
HELPER_TMPL_DIR  := collect_helper_templates

# Convenience entry point: fpu_helper.c
qemu-preprocess: check-qemu-top $(QEMU_BUILD)/Makefile copy-fpu-files prepend-softfloat capture-command-fpu preprocess-extract-fpu
	@echo "==================================================================="
	@echo "Preprocessed file ready: $(QEMU_BUILD)/$(PREPROCESSED_OBJ_FPU).E"
	cp $(QEMU_BUILD)/$(PREPROCESSED_OBJ_FPU).E $(HELPER_TMPL_DIR)/
	@echo "==================================================================="

# Convenience entry point: accel/tcg/tcg-runtime.c
# No .inc files copied, no source modification required.
qemu-preprocess-tcg-runtime: check-qemu-top $(QEMU_BUILD)/Makefile capture-command-tcg-runtime preprocess-extract-tcg-runtime
	@echo "==================================================================="
	@echo "Preprocessed file ready: $(QEMU_BUILD)/$(PREPROCESSED_OBJ_TCG_RT).E"
	cp $(QEMU_BUILD)/$(PREPROCESSED_OBJ_TCG_RT).E $(HELPER_TMPL_DIR)/
	@echo "==================================================================="

# Convenience entry point: target/i386/tcg/cc_helper.c
# No .inc files copied, no source modification required.
qemu-preprocess-cc-helper: check-qemu-top $(QEMU_BUILD)/Makefile capture-command-cc-helper preprocess-extract-cc-helper
	@echo "==================================================================="
	@echo "Preprocessed file ready: $(QEMU_BUILD)/$(PREPROCESSED_OBJ_CC_HELPER).E"
	cp $(QEMU_BUILD)/$(PREPROCESSED_OBJ_CC_HELPER).E $(HELPER_TMPL_DIR)/
	@echo "==================================================================="

# Convenience entry point: target/i386/tcg/int_helper.c
# No .inc files copied, no source modification required.
qemu-preprocess-int-helper: check-qemu-top $(QEMU_BUILD)/Makefile capture-command-int-helper preprocess-extract-int-helper
	@echo "==================================================================="
	@echo "Preprocessed file ready: $(QEMU_BUILD)/$(PREPROCESSED_OBJ_INT_HELPER).E"
	cp $(QEMU_BUILD)/$(PREPROCESSED_OBJ_INT_HELPER).E $(HELPER_TMPL_DIR)/
	@echo "==================================================================="

# Convenience entry point: accel/tcg/user-exec.c
# No .inc files copied, no source modification required.
qemu-preprocess-user-exec: check-qemu-top $(QEMU_BUILD)/Makefile capture-command-user-exec preprocess-extract-user-exec
	@echo "==================================================================="
	@echo "Preprocessed file ready: $(QEMU_BUILD)/$(PREPROCESSED_OBJ_USER_EXEC).E"
	cp $(QEMU_BUILD)/$(PREPROCESSED_OBJ_USER_EXEC).E $(HELPER_TMPL_DIR)/
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
	@if [ ! -f "$(QEMU_TOP)/accel/tcg/tcg-runtime.c" ]; then \
		echo "ERROR: target file '$(QEMU_TOP)/accel/tcg/tcg-runtime.c' not found."; \
		exit 1; \
	fi
	@if [ ! -f "$(QEMU_TCG_DIR)/cc_helper.c" ]; then \
		echo "ERROR: target file '$(QEMU_TCG_DIR)/cc_helper.c' not found."; \
		exit 1; \
	fi
	@if [ ! -f "$(QEMU_TCG_DIR)/int_helper.c" ]; then \
		echo "ERROR: target file '$(QEMU_TCG_DIR)/int_helper.c' not found."; \
		exit 1; \
	fi
	@if [ ! -f "$(QEMU_TOP)/accel/tcg/user-exec.c" ]; then \
		echo "ERROR: target file '$(QEMU_TOP)/accel/tcg/user-exec.c' not found."; \
		exit 1; \
	fi

# --- 2. copy fpu/*.inc into target/i386/tcg/ --------------------------------
# (Only used by the fpu_helper.c target.)

copy-fpu-files:
	@mkdir -p $(QEMU_TCG_DIR)
	@for inc in $(call COPIED_INCS); do \
		base=$${inc##*/}; \
		cp -f "$(QEMU_FPU_DIR)/$$base" "$$inc"; \
		echo "copied: $(QEMU_FPU_DIR)/$$base -> $$inc"; \
	done

# --- 3. prepend fpu/softfloat.c to fpu_helper.c ------------------------------
# (Only used by the fpu_helper.c target.)

prepend-softfloat:
	@if [ -f "$(SOFTFLOAT_MARKER)" ]; then \
		echo "softfloat.c already prepended (marker exists): $(SOFTFLOAT_MARKER)"; \
	else \
		echo "Prepending $(QEMU_FPU_DIR)/softfloat.c to $(QEMU_FPU_HELPER) ..."; \
		cp -f $(QEMU_FPU_HELPER) $(QEMU_FPU_HELPER).orig; \
		cat $(QEMU_TOP)/accel/tcg/user-exec.c $(QEMU_FPU_DIR)/softfloat.c $(QEMU_FPU_HELPER).orig > $(QEMU_FPU_HELPER); \
		touch $(SOFTFLOAT_MARKER); \
		echo "done (original saved as fpu_helper.c.orig)."; \
	fi

# --- 4. configure (shared) --------------------------------------------------

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

# --- 4b. capture the compile command (per target) ----------------------------

BUILD_LOG_FPU       := $(QEMU_BUILD)/fpu_helper_build.log
BUILD_LOG_TCG_RT    := $(QEMU_BUILD)/tcg_runtime_build.log
BUILD_LOG_CC        := $(QEMU_BUILD)/cc_helper_build.log
BUILD_LOG_INT       := $(QEMU_BUILD)/int_helper_build.log
BUILD_LOG_USER_EXEC  := $(QEMU_BUILD)/user_exec_build.log

capture-command-fpu: $(QEMU_BUILD)/Makefile
	@echo "Building $(PREPROCESSED_OBJ_FPU) with V=1, logging to $(BUILD_LOG_FPU)"
	@cd $(QEMU_BUILD) && \
		( make V=1 ./$(PREPROCESSED_OBJ_FPU) 2>&1 || true ) | tee $(BUILD_LOG_FPU)

capture-command-tcg-runtime: $(QEMU_BUILD)/Makefile
	@echo "Building $(PREPROCESSED_OBJ_TCG_RT) with V=1, logging to $(BUILD_LOG_TCG_RT)"
	@cd $(QEMU_BUILD) && \
		( make V=1 ./$(PREPROCESSED_OBJ_TCG_RT) 2>&1 || true ) | tee $(BUILD_LOG_TCG_RT)

capture-command-cc-helper: $(QEMU_BUILD)/Makefile
	@echo "Building $(PREPROCESSED_OBJ_CC_HELPER) with V=1, logging to $(BUILD_LOG_CC)"
	@cd $(QEMU_BUILD) && \
		( make V=1 ./$(PREPROCESSED_OBJ_CC_HELPER) 2>&1 || true ) | tee $(BUILD_LOG_CC)

capture-command-int-helper: $(QEMU_BUILD)/Makefile
	@echo "Building $(PREPROCESSED_OBJ_INT_HELPER) with V=1, logging to $(BUILD_LOG_INT)"
	@cd $(QEMU_BUILD) && \
		( make V=1 ./$(PREPROCESSED_OBJ_INT_HELPER) 2>&1 || true ) | tee $(BUILD_LOG_INT)

capture-command-user-exec: $(QEMU_BUILD)/Makefile
	@echo "Building $(PREPROCESSED_OBJ_USER_EXEC) with V=1, logging to $(BUILD_LOG_USER_EXEC)"
	@cd $(QEMU_BUILD) && \
		( make V=1 ./$(PREPROCESSED_OBJ_USER_EXEC) 2>&1 || true ) | tee $(BUILD_LOG_USER_EXEC)

# --- 5. transform the captured command into a clean -E preprocessing command
#
# The original build line ends with something like:
#     -o PATH/foo.c.o -c PATH/foo.c
# (possibly with a leading "[NN/NN]" ninja progress prefix).
#
# We want a *pure* preprocessor invocation:
#     -o PATH/foo.c.o.E -E PATH/foo.c
#
# IMPORTANT: -E and -c are mutually exclusive. clang errors out with
#   "argument unused during compilation: '-c'"
# when both are present. So we must end up with exactly one "-E" and
# NO "-c". The rewrite is intentionally idempotent, so it also handles
# a log line that was already partially rewritten (e.g. "-o ...o.E -E -c").
#
# Three sed expressions, applied in order:
#   1.  -c           -> -E           (pristine case)
#   2.  -E -E        -> -E           (collapse the broken case)
#   3.  -o PATH/.c.o[.E] -> -o PATH/.c.o.E  (rename the output; the leading
#       space before "-o" ensures we only touch the real compile output, not
#       unrelated flags like -MQ / -MF whose values also end in .c.o)
#
# Then run the resulting command from the build directory.

# Base (private) script template. Instantiated per target by setting
# _PP_OBJ and _PP_LOG before calling eval.
define _PREPROCESS_SCRIPT
set -e; \
echo "Extracting clang command from $(_PP_LOG)"; \
raw=$$(grep -E '\bclang\b' "$(_PP_LOG)" | grep -E -- '-c[[:space:]]+\S+\.c(\s|$$)' | tail -n 1); \
if [ -z "$$raw" ]; then \
	echo "ERROR: no clang compile command found in $(_PP_LOG)"; \
	echo "----- last 40 lines of build log -----"; \
	tail -n 40 "$(_PP_LOG)"; \
	exit 1; \
fi; \
echo "Raw line from log:"; \
echo "$$raw"; \
cmd=$$(echo "$$raw" | sed -E 's#^[[:space:]]*\[[0-9]+/[0-9]+\][[:space:]]*##'); \
echo "Command (prefix stripped):"; \
echo "$$cmd"; \
echo "$$cmd" > /tmp/cmd_before.txt; \
modified=$$(echo "$$cmd" | sed -E \
	-e 's#(^| )-c( |$$)#\1-E\2#g' \
	-e 's#(^| )-E -E( |$$)#\1-E\2#g' \
	-e 's#( -o[[:space:]]+[^[:space:]]*)\.c\.o(\.E)?([[:space:]])#\1.c.o.E\3#g'); \
echo "Modified command:"; \
echo "$$modified"; \
if [ "$$cmd" = "$$modified" ]; then \
	echo "ERROR: -c -> -E rewrite did not match; command left unchanged."; \
	exit 1; \
fi; \
eval "$$modified"; \
if [ -f "$(_PP_OBJ).E" ]; then \
	echo "SUCCESS: preprocessed file -> $(QEMU_BUILD)/$(_PP_OBJ).E"; \
else \
	echo "ERROR: expected output $(_PP_OBJ).E was not produced."; \
	exit 1; \
fi
endef

# fpu_helper.c
preprocess-extract-fpu: capture-command-fpu
	@cd $(QEMU_BUILD) && \
		_PP_LOG='$(BUILD_LOG_FPU)' _PP_OBJ='$(PREPROCESSED_OBJ_FPU)' \
		QEMU_TOP='$(QEMU_TOP)' QEMU_BUILD='$(QEMU_BUILD)' \
		sh -c 'set -e; \
echo "Extracting clang command from $$_PP_LOG"; \
raw=$$(grep -E "\bclang\b" "$$_PP_LOG" | grep -E -- "-c[[:space:]]+\S+\.c(\s|$$)" | tail -n 1); \
[ -z "$$raw" ] && { echo "ERROR: no clang command found"; tail -n 40 "$$_PP_LOG"; exit 1; }; \
cmd=$$(echo "$$raw" | sed -E "s#^[[:space:]]*\[[0-9]+/[0-9]+\][[:space:]]*##"); \
echo "$$cmd" > /tmp/cmd_before.txt; \
modified=$$(echo "$$cmd" | sed -E \
  -e "s#(^| )-c( |$$)#\1-E\2#g" \
  -e "s#(^| )-E -E( |$$)#\1-E\2#g" \
  -e "s#( -o[[:space:]]+[^[:space:]]*)\.c\.o(\.E)?([[:space:]])#\1.c.o.E\3#g" \
  -e "s#(-Ilib(qemu-[^[:space:]]+|user)\.a\.p)([[:space:]])#\1\2 -I$$QEMU_TOP/accel/tcg #g"); \
echo "$$modified" > /tmp/cmd_after.txt; \
[ "$$cmd" = "$$modified" ] && { echo "ERROR: rewrite did not match"; exit 1; }; \
eval "$$modified"; \
[ -f "$$_PP_OBJ.E" ] && echo "SUCCESS: $$QEMU_BUILD/$$_PP_OBJ.E" || { echo "ERROR: .E not produced"; exit 1; }'

# tcg-runtime.c
preprocess-extract-tcg-runtime: capture-command-tcg-runtime
	$(eval _PP_OBJ := $(PREPROCESSED_OBJ_TCG_RT))
	$(eval _PP_LOG := $(BUILD_LOG_TCG_RT))
	cd $(QEMU_BUILD) && $(_PREPROCESS_SCRIPT)

# cc_helper.c
preprocess-extract-cc-helper: capture-command-cc-helper
	$(eval _PP_OBJ := $(PREPROCESSED_OBJ_CC_HELPER))
	$(eval _PP_LOG := $(BUILD_LOG_CC))
	cd $(QEMU_BUILD) && $(_PREPROCESS_SCRIPT)

# int_helper.c
preprocess-extract-int-helper: capture-command-int-helper
	$(eval _PP_OBJ := $(PREPROCESSED_OBJ_INT_HELPER))
	$(eval _PP_LOG := $(BUILD_LOG_INT))
	cd $(QEMU_BUILD) && $(_PREPROCESS_SCRIPT)

# user-exec.c
preprocess-extract-user-exec: capture-command-user-exec
	$(eval _PP_OBJ := $(PREPROCESSED_OBJ_USER_EXEC))
	$(eval _PP_LOG := $(BUILD_LOG_USER_EXEC))
	cd $(QEMU_BUILD) && $(_PREPROCESS_SCRIPT)

# Backward-compatible generic targets (default to fpu_helper.c)
$(BUILD_LOG): capture-command-fpu
capture-command: capture-command-fpu
preprocess-extract: preprocess-extract-fpu

# ============================================================================
# helper_templates: post-process every previously generated preprocessed file
#
# Pipeline (run in order, after one or more `qemu-preprocess*` runs):
#   1. ensure ANTLR jar is present (download if missing)
#   2. build the small Java extractor if its class is missing
#   3. for each preprocessed file already in collect_helper_templates/:
#        java Parse <file> > <file>.out 2> <file>.err
#        extract_helper.pl <file> <file>.out
#      (this creates a <file>.helper_templates/ folder per input)
#   4. copy everything out of every *.helper_templates/ folder into helper_templates/
#
# ANTLR is only needed to turn the preprocessed source into parseable form;
# the helper-template extraction itself is driven by extract_helper.pl.
# ============================================================================

HELPER_TMPL_PARSER := $(HELPER_TMPL_DIR)/parser
ANTLR_JAR        := $(HELPER_TMPL_PARSER)/antlr-4.9.3-complete.jar
ANTLR_PARSE_CLASS := $(HELPER_TMPL_PARSER)/LoadCPP.class
HACKER           := $(HELPER_TMPL_DIR)/hack_helper_retaddr.pl
EXTRACTOR        := $(HELPER_TMPL_DIR)/extract_helper.pl
HELPER_DEF       := tcg_ast.h
HELPER_TMPL_OUT  := helper_templates
PP_GLOB          := $(wildcard $(HELPER_TMPL_DIR)/*.o.E)
HT_DIRS          := $(patsubst %.o.E,%.o.E.helper_templates,$(PP_GLOB))

# Step 1: download ANTLR jar (idempotent)
$(ANTLR_JAR):
	@mkdir -p "$(HELPER_TMPL_PARSER)"
	@if [ -f "$(ANTLR_JAR)" ]; then \
		echo "ANTLR jar already present: $(ANTLR_JAR)"; \
	else \
		echo "Downloading ANTLR complete jar ..."; \
		curl -fSL -o "$(ANTLR_JAR)" \
			https://www.antlr.org/download/antlr-4.9.3-complete.jar \
			&& echo "Downloaded $(ANTLR_JAR) ($$(wc -c < $(ANTLR_JAR)) bytes)"; \
	fi

# Step 2: build the Java extractor (LoadCPP.class) if missing
$(ANTLR_PARSE_CLASS): $(ANTLR_JAR)
	@echo "Building Java extractor ($(ANTLR_PARSE_CLASS)) from *.g4 ..."
	@cd "$(HELPER_TMPL_PARSER)" && \
		java -jar "../../$(ANTLR_JAR)" *.g4 && \
		javac -cp ".:../../$(ANTLR_JAR)" *.java && \
		echo "Java extractor built."

# Step 3 + 4: process every preprocessed file, then merge folders into helper_templates/
# Driven by the shell: per-file java parse + extract_helper.pl, then copy-up.
templates: $(ANTLR_PARSE_CLASS) $(HELPER_TMPL_OUT)
	@if [ -z "$(PP_GLOB)" ]; then \
		echo "WARNING: no preprocessed files found under $(HELPER_TMPL_DIR)/"; \
		echo "Run a qemu-preprocess* target first to generate .E files."; \
	else \
		echo "Processing $(words $(PP_GLOB)) preprocessed file(s):"; \
		for pp in $(PP_GLOB); do \
			out="$${pp}.out"; \
			err="$${pp}.err"; \
			echo "  - parse: $$pp"; \
			perl "$(HACKER)" "$$pp"; \
			java -cp "$(HELPER_TMPL_PARSER):$(ANTLR_JAR)" LoadCPP "$$pp" > "$$out" 2> "$$err"; \
			echo "  - extract: $$pp"; \
			perl "$(EXTRACTOR)" "$(HELPER_DEF)" "$$pp" "$$out" >> extract.log 2>&1; \
		done; \
		echo "Copying all *.helper_templates/ folders into $(HELPER_TMPL_OUT)/ ..."; \
		rm -rf "$(HELPER_TMPL_OUT)"; mkdir -p "$(HELPER_TMPL_OUT)"; \
		shopt -s dotglob nullglob; \
		for d in $(HT_DIRS); do \
			[ -d "$$d" ] || continue; \
			cp -f "$$d"/* "$(HELPER_TMPL_OUT)/" 2>/dev/null || true; \
		done; \
		echo "Done. helper_templates ready in $(HELPER_TMPL_OUT)/."; \
	fi

$(HELPER_TMPL_OUT):
	@mkdir -p "$(HELPER_TMPL_OUT)"

# ============================================================================
# Clean: undo ALL previous changes to QEMU source + remove intermediate files
# ============================================================================
clean: clean-qemu-source clean-local

# Remove everything we added to the QEMU source tree.
# IMPORTANT: only remove the .inc files that *we* copied (COPIED_INCS), never
# QEMU's own .inc files that happen to live in the same directory.
clean-qemu-source:
	@if [ -n "$(QEMU_TOP)" ] && [ -d "$(QEMU_TOP)" ]; then \
		echo "Undoing QEMU source modifications in $(QEMU_TOP) ..."; \
		rm -f $(call COPIED_INCS); \
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
	rm -f *.o parser.tab.* lexer.yy.* tcg_mapper tcg_printer helper_lookup.c tests/expand_tcg_ir/*.out collect_helper_templates/*.E collect_helper_templates/*.E.out collect_helper_templates/*.E.err helper_templates/*
	rm -rf collect_helper_templates/*.o.E.helper_templates
	rm -rf tests/translate_to_llvm_ir/out
	rm -rf .san .cov coverage
	rm -f *.gcda *.gcno *.gcov
	rm -f tests/expand_tcg_ir/*.err

# Alias preserved from original Makefile
clean-all: clean

# ============================================================================
# Testing infrastructure
#
# Two suites:
#   1. tests/expand_tcg_ir        -> tcg_printer, compared against .exp
#   2. tests/translate_to_llvm_ir -> tcg_mapper + llvm_annotate.py, compared
#      against a *host-arch specific* golden .ll file
#
# Both suites normally run the plain binaries.  The *-san targets re-run them
# against sanitizer-instrumented copies (see the "sanitizers" section below);
# that is the supported way to hunt memory bugs on this tree.
# ============================================================================

# ----------------------------------------------------------------------------
# Suite 1: tests/expand_tcg_ir (tcg_printer vs .exp)
# ----------------------------------------------------------------------------
TEST_DIR := tests/expand_tcg_ir
TIR_FILES := $(wildcard $(TEST_DIR)/*.tir)

ifeq ($(TCG_PRINTER),)
	TCG_PRINTER := ./tcg_printer
endif

# stderr routing for suite 1.
#   native    -> merged into stdout (historic behaviour; some .exp files may
#                legitimately contain diagnostics)
#   sanitized -> kept apart, otherwise an ASan/MSan report would end up inside
#                the very file that gets diffed against the golden .exp
ifeq ($(EXPAND_STDERR),separate)
EXPAND_ERRDEV = 2>"$$errlog"
else
EXPAND_ERRDEV = 2>&1
endif

# Run tcg_printer over every .tir file and diff against .exp.
# With REPEAT=N each case runs N times and runs 2..N are cross-checked against
# run 1 - that is what catches a memory bug whose effect only shows up
# "sometimes".
test-expand-tcg-ir: $(TCG_PRINTER)
	@rc=0; pass=0; fail=0; skip=0; unstable=0; \
	runs=$(REPEAT); \
	case "$$runs" in ''|*[!0-9]*) runs=1 ;; esac; \
	[ "$$runs" -ge 1 ] || runs=1; \
	for tir in $(TIR_FILES); do \
	dir=$${tir%/*}; \
	base=$${tir##*/}; \
	[ "$$dir" = "$$tir" ] && dir=""; \
	exp="$${tir%.tir}.exp"; \
	out="$${tir%.tir}.out"; \
	out1="$${tir%.tir}.run1.out"; \
	errlog="$${tir%.tir}.err"; \
	extra=""; \
	fline=$$(head -n 1 "$$tir"); \
	case "$$fline" in \
	';'*) extra=$${fline#';'} ;; \
	esac; \
	i=1; \
	while [ $$i -le $$runs ]; do \
	echo "==> $$tir $$extra (run $$i/$$runs)"; \
	st=0; $(TCG_PRINTER) $$extra "$$tir" > "$$out" $(EXPAND_ERRDEV) || st=$$?; \
	if [ "$$st" -eq $(SAN_ERROR_EXIT) ]; then \
	echo "SANITIZER FAIL: $$tir - see $$errlog"; \
	tail -n 25 "$$errlog" 2>/dev/null; \
	fail=$$((fail+1)); rc=1; break; \
	fi; \
	if [ "$$st" -ne 0 ]; then \
	echo "NOTE: $$tir - tcg_printer exited $$st"; \
	fi; \
	[ $$i -eq 1 ] && cp -f "$$out" "$$out1"; \
	if [ ! -f "$$exp" ]; then \
	echo "WARNING: no .exp for $$tir (wrote .out only)"; \
	skip=$$((skip+1)); break; \
	fi; \
	if diff -u "$$exp" "$$out"; then \
	[ $$i -eq 1 ] && pass=$$((pass+1)); \
	echo "PASS: $$tir"; \
	else \
	echo "FAIL: $$tir (see diff above)"; \
	if [ "$(EXPAND_STDERR)" = separate ]; then \
	echo "       NB: this run split stderr into $$errlog."; \
	echo "       If the .exp was recorded with stderr merged, regenerate it"; \
	echo "       or re-run with EXPAND_STDERR=merge."; \
	fi; \
	fail=$$((fail+1)); rc=1; \
	fi; \
	if [ $$i -gt 1 ] && ! diff -q "$$out1" "$$out" > /dev/null; then \
	echo "UNSTABLE: $$tir - run $$i differs from run 1 ($$out1 vs $$out)"; \
	diff -u "$$out1" "$$out" | head -n 40; \
	unstable=$$((unstable+1)); rc=1; \
	fi; \
	i=$$((i+1)); \
	done; \
	done; \
	echo "-------------------------------------------------------------------"; \
	echo "expand_tcg_ir: $$pass passed, $$fail failed, $$unstable unstable, $$skip without .exp (REPEAT=$$runs; fail/unstable counted per run)"; \
	exit $$rc

# ----------------------------------------------------------------------------
# Suite 2: tests/translate_to_llvm_ir
#
# Every case is a <name>.tir file.  The pipeline is:
#
#     ./tcg_mapper -d tests/translate_to_llvm_ir/<name>.tir   >  <name>.ll
#     ./llvm_annotate.py -o <name>.annotate.ll  <name>.ll
#
# and the annotated IR is diffed against the golden file
#
#     tests/translate_to_llvm_ir/<name>.tir.$(TEST_ARCH).ll
#     e.g.  load_store_stack.tir.aarch64.ll   on an aarch64 host
#           load_store_stack.tir.riscv64.ll   on a riscv64  host
#
# The generated IR is host dependent (pointer size, host triplet, host
# registers, ...), so each native machine keeps its own golden copy.  The arch
# suffix defaults to the native architecture reported by `uname -m` and can be
# overridden on the command line, e.g. to re-check a golden set belonging to
# another machine.
#
# Handy invocations:
#   make test                              # both suites
#   make test-llvm-ir                      # only the LLVM-IR suite
#   make test-llvm-ir ONLY=load_store      # subset (substring of case name)
#   make test-llvm-ir TEST_ARCH=riscv64    # compare against another arch's copy
#   make test-llvm-ir-update               # (re)create goldens for THIS host
#   make test-llvm-ir-update ONLY=load_store
#   make test REPEAT=5                     # each case 5x, catch flaky output
#
#   make test-san                          # same, under the sanitizer
#   make test-san SAN=msan REPEAT=3
#
# Artifacts (kept for inspection, cleaned by `make clean`):
#   tests/translate_to_llvm_ir/out/$(TEST_ARCH)/<name>.ll
#   tests/translate_to_llvm_ir/out/$(TEST_ARCH)/<name>.annotate.ll   <- compared
#   tests/translate_to_llvm_ir/out/$(TEST_ARCH)/<name>.run1.annotate.ll
#   tests/translate_to_llvm_ir/out/$(TEST_ARCH)/<name>.diff
#   tests/translate_to_llvm_ir/out/$(TEST_ARCH)/<name>.mapper.err    <- sanitizer report
#   tests/translate_to_llvm_ir/out/$(TEST_ARCH)/<name>.annotate.err
# ----------------------------------------------------------------------------

# Host architecture used to pick the golden file.  Normalise the usual
# aliases so that `arm64` (macOS) and `amd64` also land on a sensible suffix.
# Override with:  make test-llvm-ir TEST_ARCH=riscv64
ifeq ($(TEST_ARCH),)
TEST_ARCH := $(ARCH_HOST)
ifeq ($(TEST_ARCH),arm64)
TEST_ARCH := aarch64
endif
ifeq ($(TEST_ARCH),amd64)
TEST_ARCH := x86_64
endif
endif

LLVM_TIR_DIR    := tests/translate_to_llvm_ir
LLVM_TIR_FILES  := $(sort $(wildcard $(LLVM_TIR_DIR)/*.tir))
LLVM_TIR_OUTDIR := $(LLVM_TIR_DIR)/out/$(TEST_ARCH)

LLVM_ANNOTATE ?= ./llvm_annotate.py
PYTHON        ?= python3
MAPPER_FLAGS  ?= -d

ifeq ($(TCG_MAPPER),)
	TCG_MAPPER := ./tcg_mapper
endif

# Optional subset filter: make test-llvm-ir ONLY=load_store_stack
ifeq ($(ONLY),)
LLVM_TIR_CASES := $(LLVM_TIR_FILES)
else
LLVM_TIR_CASES := $(foreach f,$(LLVM_TIR_FILES),\
	$(if $(findstring $(ONLY),$(basename $(notdir $f))),$f))
endif

# How many times each case is executed (run 2..N are diffed against run 1).
REPEAT ?= 1

# Run every translate_to_llvm_ir case and diff against the per-arch golden.
test-llvm-ir: $(TCG_MAPPER)
	@mkdir -p "$(LLVM_TIR_OUTDIR)"
	@if [ -z "$(LLVM_TIR_CASES)" ]; then \
	echo "No .tir case found under $(LLVM_TIR_DIR)/"; \
	exit 0; \
	fi
	@echo "==================================================================="
	@echo "translate_to_llvm_ir: $(words $(LLVM_TIR_CASES)) case(s), TEST_ARCH=$(TEST_ARCH)"
	@echo "golden file pattern : <name>.tir.$(TEST_ARCH).ll"
	@echo "==================================================================="
	@rc=0; pass=0; fail=0; skip=0; unstable=0; \
	runs=$(REPEAT); \
	case "$$runs" in ''|*[!0-9]*) runs=1 ;; esac; \
	[ "$$runs" -ge 1 ] || runs=1; \
	for tir in $(LLVM_TIR_CASES); do \
	name=$$(basename "$$tir" .tir); \
	ll="$(LLVM_TIR_OUTDIR)/$$name.ll"; \
	ann="$(LLVM_TIR_OUTDIR)/$$name.annotate.ll"; \
	ann1="$(LLVM_TIR_OUTDIR)/$$name.run1.annotate.ll"; \
	diffout="$(LLVM_TIR_OUTDIR)/$$name.diff"; \
	errlog="$(LLVM_TIR_OUTDIR)/$$name.mapper.err"; \
	exp="$${tir}.$(TEST_ARCH).ll"; \
	if [ ! -f "$$exp" ] && [ -f "$${tir}.ll" ]; then \
	exp="$${tir}.ll"; \
	fi; \
	i=1; \
	while [ $$i -le $$runs ]; do \
	echo "==> $$tir (run $$i/$$runs)"; \
	st=0; $(TCG_MAPPER) $(MAPPER_FLAGS) "$$tir" > "$$ll" 2> "$$errlog" || st=$$?; \
	if [ "$$st" -eq $(SAN_ERROR_EXIT) ]; then \
	echo "SANITIZER FAIL: $$tir - see $$errlog"; \
	tail -n 25 "$$errlog"; \
	fail=$$((fail+1)); rc=1; break; \
	fi; \
	if [ "$$st" -ne 0 ]; then \
	echo "FAIL: $$tir (tcg_mapper exit $$st - see $$errlog)"; \
	tail -n 20 "$$errlog"; \
	fail=$$((fail+1)); rc=1; break; \
	fi; \
	if ! $(PYTHON) $(LLVM_ANNOTATE) -o "$$ann" "$$ll" 2> "$(LLVM_TIR_OUTDIR)/$$name.annotate.err"; then \
	echo "FAIL: $$tir (llvm_annotate.py failed - see $(LLVM_TIR_OUTDIR)/$$name.annotate.err)"; \
	tail -n 20 "$(LLVM_TIR_OUTDIR)/$$name.annotate.err"; \
	fail=$$((fail+1)); rc=1; break; \
	fi; \
	if [ ! -s "$$ann" ]; then \
	echo "FAIL: $$tir ($$ann was not produced by llvm_annotate.py)"; \
	fail=$$((fail+1)); rc=1; break; \
	fi; \
	[ $$i -eq 1 ] && cp -f "$$ann" "$$ann1"; \
	if [ ! -f "$$exp" ]; then \
	echo "SKIP: $$tir (no golden $${tir}.$(TEST_ARCH).ll - wrote $$ann)"; \
	skip=$$((skip+1)); break; \
	fi; \
	if diff -u "$$exp" "$$ann" > "$$diffout"; then \
	[ $$i -eq 1 ] && pass=$$((pass+1)); \
	echo "PASS: $$tir"; \
	else \
	echo "FAIL: $$tir (diff vs $$exp)"; \
	cat "$$diffout"; \
	fail=$$((fail+1)); rc=1; \
	fi; \
	if [ $$i -gt 1 ] && ! diff -q "$$ann1" "$$ann" > /dev/null; then \
	echo "UNSTABLE: $$tir - run $$i differs from run 1 ($$ann1 vs $$ann)"; \
	diff -u "$$ann1" "$$ann" | head -n 40; \
	unstable=$$((unstable+1)); rc=1; \
	fi; \
	i=$$((i+1)); \
	done; \
	done; \
	echo "-------------------------------------------------------------------"; \
	echo "translate_to_llvm_ir [$(TEST_ARCH)]: $$pass passed, $$fail failed, $$unstable unstable, $$skip skipped (REPEAT=$$runs; fail/unstable counted per run)"; \
	if [ "$$skip" -gt 0 ]; then \
	echo "hint: run 'make test-llvm-ir-update' to create the missing goldens"; \
	fi; \
	exit $$rc

# (Re)generate the golden files for the *current* host architecture.
# Run this on each native machine once, then commit
# <name>.tir.<arch>.ll next to the .tir file.
test-llvm-ir-update: $(TCG_MAPPER)
	@mkdir -p "$(LLVM_TIR_OUTDIR)"
	@for tir in $(LLVM_TIR_CASES); do \
	name=$$(basename "$$tir" .tir); \
	ll="$(LLVM_TIR_OUTDIR)/$$name.ll"; \
	ann="$(LLVM_TIR_OUTDIR)/$$name.annotate.ll"; \
	gold="$${tir}.$(TEST_ARCH).ll"; \
	echo "==> $$tir"; \
	if $(TCG_MAPPER) $(MAPPER_FLAGS) "$$tir" > "$$ll" && \
	   $(PYTHON) $(LLVM_ANNOTATE) -o "$$ann" "$$ll"; then \
	cp -f "$$ann" "$$gold"; \
	echo "UPDATE: $$gold"; \
	else \
	echo "ERROR: pipeline failed for $$tir (golden left untouched)"; \
	fi; \
	done

# ============================================================================
# Sanitizers
#   make test-san                    # both suites, AddressSanitizer + UBSan
#   make test-llvm-ir-san            # only the LLVM-IR suite
#   make test-expand-tcg-ir-san      # only the expand_tcg_ir suite
#   make test-san SAN=msan           # MemorySanitizer (uninitialised reads)
#   make test-san SAN=ubsan          # undefined behaviour only (fastest)
#   make test-san ONLY=load_store    # filters work as usual
#   make test-san REPEAT=5           # 5 runs per case
#
# The sanitized binaries are built from the same sources into their own
# directory (.san/<san>/) with -O1, so the -O0 objects used by the normal
# build are left untouched.  Sanitizer reports go to stderr, which the test
# recipes already keep out of the file that is diffed against the golden, so
# a report never corrupts a comparison.
#
# Which sanitizer finds what:
#   asan  - out-of-bounds (heap/stack/global), use-after-free, double free,
#           invalid free.  Plus LSan for leaks when SAN_LEAKS=1.
#   ubsan - misaligned/invalid casts, signed overflow, null deref, ...
#   msan  - reads of uninitialised memory.  This is the one that matches
#           "the same input sometimes produces different output": an
#           uninitialised value feeding a branch or an address is the classic
#           cause.  Caveat below.
#
# MSan caveat: MemorySanitizer can only track uninitialised bits through code
# that was itself instrumented.  glibc is intercepted, but libstdc++/libc++
# (this tree links -lstdc++) and any pre-built LLVM libraries are not, so
# expect false positives originating inside them.  Either build those with
# -fsanitize=memory, or filter them with MSAN_OPTIONS / a suppression list.
# ============================================================================

SAN ?= asan
SAN_ERROR_EXIT ?= 99
SAN_OBJDIR := .san/$(SAN)

SAN_MAPPER  := $(SAN_OBJDIR)/tcg_mapper
SAN_PRINTER := $(SAN_OBJDIR)/tcg_printer

SAN_MAPPER_OBJS  := $(addprefix $(SAN_OBJDIR)/,$(MAPPER_OBJS))
SAN_PRINTER_OBJS := $(addprefix $(SAN_OBJDIR)/,$(PRINTER_OBJS))

# MSan is clang-only; ASan/UBSan work with either compiler.
ifeq ($(SAN),msan)
SAN_CC ?= clang
else
SAN_CC ?= gcc
endif

# Per-sanitizer flag sets.  These must be defined *before* SAN_CFLAGS /
# SAN_LDFLAGS below, which expand immediately (":=").
# -fsanitize=undefined is folded into the asan build: it is cheap and catches
# a different bug class.  Override SAN_FLAGS to tune.
SAN_FLAGS_asan    := -fsanitize=address,undefined -fno-omit-frame-pointer -fno-optimize-sibling-calls -fno-common
SAN_FLAGS_ubsan   := -fsanitize=undefined -fno-omit-frame-pointer
SAN_FLAGS_msan    := -fsanitize=memory -fsanitize-memory-track-origins=2 -fno-omit-frame-pointer -fPIE
# MSan additionally needs a PIE link; the others follow the toolchain default.
ifeq ($(SAN),msan)
SAN_LDFLAGS_EXTRA := -pie
else
SAN_LDFLAGS_EXTRA :=
endif
SAN_FLAGS         := $(SAN_FLAGS_$(SAN))

# Sanitized builds want at least -O1 (the manuals recommend -O1 as the
# practical trade-off); everything else from CFLAGS (include paths etc.) is
# kept as-is.
SAN_OPT     ?= -O1
SAN_CFLAGS  := $(subst -O0,$(SAN_OPT),$(CFLAGS)) $(SAN_FLAGS)
SAN_LDFLAGS := $(SAN_FLAGS)

# Leak detection is OFF by default: this tree links all of LLVM and glib, and
# LSan would drown the real findings in third-party "leaks".  Turn it on with
# SAN_LEAKS=1 once the noise is under control (and/or drop an lsan.supp next
# to the Makefile - it is picked up automatically when present).
ASAN_DETECT_LEAKS ?= $(if $(filter 1,$(SAN_LEAKS)),1,0)
LSAN_SUPP         ?= lsan.supp

# Runtime options.  Exported, so they reach the test recipes; harmless when
# running non-instrumented binaries.  Kept on single lines on purpose: a
# backslash-continuation inside a make variable becomes a space, which would
# corrupt the option string.
export ASAN_OPTIONS := detect_leaks=$(ASAN_DETECT_LEAKS):abort_on_error=0:exitcode=$(SAN_ERROR_EXIT):detect_stack_use_after_return=1:check_initialization_order=1:strict_string_checks=1:print_stacktrace=1
export UBSAN_OPTIONS := print_stacktrace=1:report_error_type=1
export MSAN_OPTIONS := exit_code=$(SAN_ERROR_EXIT):halt_on_error=0:print_stacktrace=1:keep_going=1
ifneq ($(wildcard $(LSAN_SUPP)),)
export LSAN_OPTIONS := suppressions=$(LSAN_SUPP):print_suppressions=0
endif

# --- sanitized binaries -----------------------------------------------------
$(SAN_OBJDIR):
	@mkdir -p "$(SAN_OBJDIR)"

$(SAN_OBJDIR)/%.o: %.c | $(SAN_OBJDIR)
	$(SAN_CC) $(SAN_CFLAGS) -c $< -o $@

$(SAN_OBJDIR)/parser.tab.o: parser.tab.c lexer.yy.h
$(SAN_OBJDIR)/lexer.yy.o: lexer.yy.c lexer.yy.h

$(SAN_MAPPER): $(SAN_MAPPER_OBJS)
	$(SAN_CC) -o $@ $^ $(SAN_LDFLAGS) $(SAN_LDFLAGS_EXTRA) $(LDFLAGS) -lfl

$(SAN_PRINTER): $(SAN_PRINTER_OBJS)
	$(SAN_CC) -o $@ $^ $(SAN_LDFLAGS) $(SAN_LDFLAGS_EXTRA) $(LDFLAGS) -lfl

san-build: $(SAN_MAPPER) $(SAN_PRINTER)

# Sanity-check the chosen sanitizer before spending time on a build.
check-san:
	@case "$(SAN)" in \
	asan|ubsan|msan) ;; \
	*) echo "ERROR: SAN='$(SAN)' is not one of asan|ubsan|msan."; exit 1 ;; \
	esac
	@command -v $(SAN_CC) > /dev/null 2>&1 || { \
	echo "ERROR: compiler '$(SAN_CC)' not found (set SAN_CC=...)."; exit 1; \
	}
	@echo "sanitizer       : $(SAN)"
	@echo "compiler        : $(SAN_CC)"
	@echo "compile flags   : $(SAN_FLAGS)"
	@echo "link flags      : $(SAN_LDFLAGS) $(SAN_LDFLAGS_EXTRA)"
	@echo "binaries        : $(SAN_MAPPER) $(SAN_PRINTER)"
	@echo "error exit code : $(SAN_ERROR_EXIT)"
	@if [ "$(SAN)" = msan ]; then \
	echo ""; \
	echo "NOTE: MemorySanitizer needs every linked library instrumented too."; \
	echo "      glibc is intercepted, but libstdc++ and pre-built LLVM are not,"; \
	echo "      so expect false positives from inside them."; \
	fi

# --- sanitizer test entry points -------------------------------------------
# These just re-run the normal targets with the instrumented binaries, so
# ONLY=, TEST_ARCH= and REPEAT= keep working.
test-expand-tcg-ir-san: check-san $(SAN_PRINTER)
	@$(MAKE) --no-print-directory -f $(lastword $(MAKEFILE_LIST)) \
	TCG_PRINTER='$(SAN_PRINTER)' EXPAND_STDERR=separate \
	ONLY='$(ONLY)' REPEAT='$(REPEAT)' \
	test-expand-tcg-ir

test-llvm-ir-san: check-san $(SAN_MAPPER)
	@$(MAKE) --no-print-directory -f $(lastword $(MAKEFILE_LIST)) \
	TCG_MAPPER='$(SAN_MAPPER)' \
	ONLY='$(ONLY)' TEST_ARCH='$(TEST_ARCH)' REPEAT='$(REPEAT)' \
	test-llvm-ir

# Both suites under the sanitizer; -k keeps suite 2 running if suite 1 fails.
test-san: check-san $(SAN_MAPPER) $(SAN_PRINTER)
	@$(MAKE) --no-print-directory -f $(lastword $(MAKEFILE_LIST)) -k \
	TCG_MAPPER='$(SAN_MAPPER)' TCG_PRINTER='$(SAN_PRINTER)' \
	EXPAND_STDERR=separate \
	ONLY='$(ONLY)' TEST_ARCH='$(TEST_ARCH)' REPEAT='$(REPEAT)' \
	test

# Default: run both suites against the plain binaries.
test: test-expand-tcg-ir test-llvm-ir
# ============================================================================
# Source coverage
#
#   make coverage                 # build + run both suites + write report
#   make cov-build                # only build the instrumented binaries
#   make cov-run                  # only run the suites (counts accumulate)
#   make coverage-report          # only (re)generate the report
#   make cov-reset                # drop accumulated counts, keep binaries
#   make coverage COV_RUN=0       # report from existing data, do not re-run
#
# gcc/gcov based.  --coverage makes every object emit a .gcno at compile time
# and a .gcda when the binary exits.  Crucially, counts ACCUMULATE across runs,
# so pushing the whole corpus through both binaries gives one merged picture
# with no extra merge step.  That is why cov-run can simply invoke the normal
# `test` target with the instrumented binaries, and why failures are tolerated
# (-k): a case that crashes or mismatches still contributed its counts.
#
# Reports go to ./coverage/.  Backend is picked in this order:
#   1. gcovr      -> HTML + text summary        (pip install gcovr)
#   2. lcov/genhtml -> HTML                     (dnf install lcov)
#   3. plain gcov -> per-file *.gcov text dumps (always available with gcc)
#
# Generated sources are excluded by default (they are machine written, so their
# coverage is noise): adjust with COV_EXCLUDE.
# ============================================================================

CC ?= gcc

COV_DIR   := .cov
COV_OUT   ?= coverage
COV_TITLE ?= tcg_mapper / tcg_printer coverage

COV_MAPPER       := $(COV_DIR)/tcg_mapper
COV_PRINTER      := $(COV_DIR)/tcg_printer
COV_MAPPER_OBJS  := $(addprefix $(COV_DIR)/,$(MAPPER_OBJS))
COV_PRINTER_OBJS := $(addprefix $(COV_DIR)/,$(PRINTER_OBJS))

# Coverage is most trustworthy at -O0 (with optimisation, lines get merged and
# the mapping back to source becomes fuzzy).  Everything else from CFLAGS -
# include paths in particular - is kept.
COV_CFLAGS  := $(filter-out -O%,$(CFLAGS)) -O0 -g --coverage
COV_LDFLAGS := --coverage

COV_RUN     ?= 1
COV_EXCLUDE ?= tests/ lexer.yy.c parser.tab.c helper_lookup.c

# Sources handed to plain gcov in the fallback path (one per object).
COV_SRC := $(sort $(patsubst $(COV_DIR)/%.o,%.c,$(COV_MAPPER_OBJS) $(COV_PRINTER_OBJS)))

# Which report generators exist on this machine.
GCOVR  := $(shell command -v gcovr 2>/dev/null)
LCOV   := $(shell command -v lcov 2>/dev/null)
GENHTML := $(shell command -v genhtml 2>/dev/null)

# --- instrumented binaries --------------------------------------------------
$(COV_DIR):
	@mkdir -p "$(COV_DIR)"

$(COV_DIR)/%.o: %.c | $(COV_DIR)
	$(CC) $(COV_CFLAGS) -c $< -o $@

$(COV_DIR)/parser.tab.o: parser.tab.c lexer.yy.h
$(COV_DIR)/lexer.yy.o: lexer.yy.c lexer.yy.h

$(COV_MAPPER): $(COV_MAPPER_OBJS)
	$(CC) -o $@ $^ $(COV_LDFLAGS) $(LDFLAGS) -lfl

$(COV_PRINTER): $(COV_PRINTER_OBJS)
	$(CC) -o $@ $^ $(COV_LDFLAGS) $(LDFLAGS) -lfl

cov-build: $(COV_MAPPER) $(COV_PRINTER)

# --- run the suites with the instrumented binaries --------------------------
# -k so one failing suite does not stop the other; failures are expected and
# tolerated here, we want the counts either way.
cov-run: $(COV_MAPPER) $(COV_PRINTER)
	-@$(MAKE) --no-print-directory -f $(lastword $(MAKEFILE_LIST)) -k \
	TCG_MAPPER='$(COV_MAPPER)' TCG_PRINTER='$(COV_PRINTER)' \
	TEST_ARCH='$(TEST_ARCH)' ONLY='$(ONLY)' \
	test

# --- drop accumulated counts (binaries stay) --------------------------------
cov-reset:
	@rm -f $(COV_DIR)/*.gcda
	@echo "coverage counters reset ($(COV_DIR)/*.gcda removed)"

# --- report -----------------------------------------------------------------
coverage-report:
	@mkdir -p "$(COV_OUT)"
	@if [ -n "$(GCOVR)" ]; then \
	echo "generating report with gcovr -> $(COV_OUT)/index.html"; \
	$(GCOVR) --root . --object-directory "$(COV_DIR)" \
	$(foreach p,$(COV_EXCLUDE),--exclude '$(p)') \
	--html-details "$(COV_OUT)/index.html" \
	--html-title "$(COV_TITLE)" \
	--print-summary; \
	elif [ -n "$(LCOV)" ] && [ -n "$(GENHTML)" ]; then \
	echo "generating report with lcov/genhtml -> $(COV_OUT)/"; \
	info="$(COV_OUT)/coverage.info"; \
	$(LCOV) --directory "$(COV_DIR)" --capture --output-file "$$info"; \
	for p in $(COV_EXCLUDE); do \
	$(LCOV) --remove "$$info" "*$$p*" --output-file "$$info"; \
	done; \
	$(GENHTML) "$$info" --output-directory "$(COV_OUT)" --title "$(COV_TITLE)"; \
	else \
	echo "neither gcovr nor lcov/genhtml found - falling back to plain gcov."; \
	echo "  rich HTML:  pip install gcovr   (or)   dnf install lcov"; \
	echo "  text dumps: see $(CURDIR)/*.gcov"; \
	gcov -o "$(COV_DIR)" $(COV_SRC) 2>&1 | grep -E '^(File |Lines executed)' || true; \
	fi
	@echo "-------------------------------------------------------------------"
	@echo "coverage report : $(CURDIR)/$(COV_OUT)"

# --- one-shot ---------------------------------------------------------------
coverage:
	@if [ "$(COV_RUN)" = 1 ]; then \
	$(MAKE) --no-print-directory -f $(lastword $(MAKEFILE_LIST)) cov-run; \
	else \
	echo "COV_RUN=0: reusing existing counters in $(COV_DIR)/"; \
	fi
	@$(MAKE) --no-print-directory -f $(lastword $(MAKEFILE_LIST)) coverage-report

# Convenience: try to open the HTML report in a browser.
coverage-open: coverage-report
	@url="$(CURDIR)/$(COV_OUT)/index.html"; \
	if [ -f "$$url" ]; then \
	echo "$$url"; \
	command -v xdg-open > /dev/null 2>&1 && xdg-open "$$url" || true; \
	else \
	echo "no HTML report at $$url (see *.gcov text dumps)"; \
	fi

.PHONY: all test test-expand-tcg-ir test-llvm-ir test-llvm-ir-update \
	test-san test-expand-tcg-ir-san test-llvm-ir-san san-build check-san \
	coverage cov-build cov-run cov-reset coverage-report coverage-open \
	clean clean-all clean-local clean-qemu-source \
	qemu-preprocess qemu-preprocess-tcg-runtime \
	qemu-preprocess-cc-helper qemu-preprocess-int-helper \
	qemu-preprocess-user-exec \
	templates \
	check-qemu-top copy-fpu-files prepend-softfloat \
	capture-command capture-command-fpu capture-command-tcg-runtime \
	capture-command-cc-helper capture-command-int-helper \
	capture-command-user-exec \
	preprocess-extract preprocess-extract-fpu preprocess-extract-tcg-runtime \
	preprocess-extract-cc-helper preprocess-extract-int-helper \
	preprocess-extract-user-exec
