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

all: tcg_mapper tcg_printer

tcg_mapper: parser.tab.o lexer.yy.o mapper.o mapper_util.o helper_lookup.o util.o expander.o operand_static_types.o i386_cpu.o
	gcc -o $@ $^ $(LDFLAGS) -lfl

tcg_printer: parser.tab.o lexer.yy.o tcg_printer.o mapper_util.o helper_lookup.o util.o expander.o operand_static_types.o i386_cpu.o
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
