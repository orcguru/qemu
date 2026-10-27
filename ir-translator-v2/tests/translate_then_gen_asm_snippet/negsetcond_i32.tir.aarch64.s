	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	mov	w14, #-1                        // =0xffffffff
	cmp	w6, w7
	and	x15, x6, #0xffffffff00000000
	csel	x14, x14, xzr, lt
	orr	x6, x14, x15
	b	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
