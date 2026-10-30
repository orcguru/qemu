	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	sub	w14, w6, w7
	mvn	w16, w9
	subs	w14, w14, w8
	cset	w15, lo
	add	w14, w14, w16
	csinc	w15, w15, wzr, ne
	sub	w6, w14, w15
	b	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
