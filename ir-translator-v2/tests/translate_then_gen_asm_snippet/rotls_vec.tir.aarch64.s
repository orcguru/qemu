	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	dup	v28.16b, w6
	movi	v29.16b, #7
	neg	v30.16b, v28.16b
	and	v28.16b, v28.16b, v29.16b
	and	v30.16b, v30.16b, v29.16b
	ushl	v28.16b, v12.16b, v28.16b
	neg	v29.16b, v30.16b
	ushl	v12.16b, v12.16b, v29.16b
	orr	v12.16b, v28.16b, v12.16b
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
