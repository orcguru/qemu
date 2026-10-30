	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	and	x14, x6, #0xffffffff00000000
	and	w15, w6, w7
	orr	x14, x15, x14
	eor	x6, x14, #0xffffffff
	b	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
