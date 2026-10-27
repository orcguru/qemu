	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	mov	w14, w6
	and	x15, x6, #0xffffffff00000000
	fmov	d28, x14
	cnt	v28.8b, v28.8b
	addv	b28, v28.8b
	fmov	w14, s28
	orr	x6, x15, x14
	b	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
