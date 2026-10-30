	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	subs	x14, x6, x7
	cset	w15, lo
	sub	w16, w14, w9
	and	x14, x14, #0xffffffff00000000
	sub	w15, w16, w15
	orr	x6, x15, x14
	b	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
