	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	sub	x14, x6, x7
	mvn	x16, x9
	subs	x14, x14, x8
	cset	w15, lo
	add	x14, x14, x16
	csinc	w15, w15, wzr, ne
	sub	x6, x14, x15
	b	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        // -- End function
	.type	env_offset,@object              // @env_offset
	.section	.rodata,"a",@progbits
	.globl	env_offset
	.p2align	3, 0x0
env_offset:
	.xword	11472                           // 0x2cd0
	.size	env_offset, 8

	.section	".note.GNU-stack","",@progbits
