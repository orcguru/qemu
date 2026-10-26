	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	movi	v28.16b, #7
	neg	v29.16b, v14.16b
	and	v30.16b, v14.16b, v28.16b
	and	v28.16b, v29.16b, v28.16b
	neg	v29.16b, v30.16b
	ushl	v28.16b, v12.16b, v28.16b
	ushl	v12.16b, v12.16b, v29.16b
	orr	v12.16b, v12.16b, v28.16b
	b	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
