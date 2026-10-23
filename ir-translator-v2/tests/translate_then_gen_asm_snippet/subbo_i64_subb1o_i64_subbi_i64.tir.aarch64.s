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
	.section	".note.GNU-stack","",@progbits
