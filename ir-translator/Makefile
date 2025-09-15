LEX = flex
BISON = bison
CFLAGS = -O2 -g -Wall -I/home/felix/Install/llvm_riscv/include
# from ~/Install/llvm_riscv/bin/llvm-config --ldflags --libs all
LDFLAGS = -L/home/felix/Install/llvm_riscv/lib -lLLVMWindowsManifest -lLLVMXRay -lLLVMLibDriver -lLLVMDlltoolDriver -lLLVMTelemetry -lLLVMTextAPIBinaryReader -lLLVMCoverage -lLLVMLineEditor -lLLVMRISCVTargetMCA -lLLVMRISCVDisassembler -lLLVMRISCVAsmParser -lLLVMRISCVCodeGen -lLLVMRISCVDesc -lLLVMRISCVInfo -lLLVMOrcDebugging -lLLVMOrcJIT -lLLVMWindowsDriver -lLLVMMCJIT -lLLVMJITLink -lLLVMInterpreter -lLLVMExecutionEngine -lLLVMRuntimeDyld -lLLVMOrcTargetProcess -lLLVMOrcShared -lLLVMDWP -lLLVMDWARFCFIChecker -lLLVMDebugInfoLogicalView -lLLVMOption -lLLVMObjCopy -lLLVMMCA -lLLVMMCDisassembler -lLLVMLTO -lLLVMPasses -lLLVMHipStdPar -lLLVMCFGuard -lLLVMCoroutines -lLLVMipo -lLLVMVectorize -lLLVMSandboxIR -lLLVMLinker -lLLVMFrontendOpenMP -lLLVMFrontendOffloading -lLLVMObjectYAML -lLLVMFrontendOpenACC -lLLVMFrontendHLSL -lLLVMFrontendDriver -lLLVMInstrumentation -lLLVMFrontendDirective -lLLVMFrontendAtomic -lLLVMExtensions -lLLVMDWARFLinkerParallel -lLLVMDWARFLinkerClassic -lLLVMDWARFLinker -lLLVMGlobalISel -lLLVMMIRParser -lLLVMAsmPrinter -lLLVMSelectionDAG -lLLVMCodeGen -lLLVMTarget -lLLVMObjCARCOpts -lLLVMCodeGenTypes -lLLVMCGData -lLLVMIRPrinter -lLLVMInterfaceStub -lLLVMFileCheck -lLLVMFuzzMutate -lLLVMScalarOpts -lLLVMInstCombine -lLLVMAggressiveInstCombine -lLLVMTransformUtils -lLLVMBitWriter -lLLVMAnalysis -lLLVMProfileData -lLLVMSymbolize -lLLVMDebugInfoBTF -lLLVMDebugInfoPDB -lLLVMDebugInfoMSF -lLLVMDebugInfoCodeView -lLLVMDebugInfoGSYM -lLLVMDebugInfoDWARF -lLLVMDebugInfoDWARFLowLevel -lLLVMObject -lLLVMTextAPI -lLLVMMCParser -lLLVMIRReader -lLLVMAsmParser -lLLVMMC -lLLVMBitReader -lLLVMFuzzerCLI -lLLVMCore -lLLVMRemarks -lLLVMBitstreamReader -lLLVMBinaryFormat -lLLVMTargetParser -lLLVMTableGen -lLLVMSupport -lLLVMDemangle -lffi -lz -lstdc++ -lm -ltinfo -lzstd

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
