	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	subs	x14, x6, x7
	cmp	x14, x8
	cset	w14, eq
	subs	x15, x6, x7
	cset	w16, lo
	csel	w14, wzr, w14, hs
	subs	x15, x15, x8
	sbfx	x16, x16, #0, #1
	csinc	w14, w14, wzr, hs
	sub	x16, x16, x9
	add	x15, x16, x15
	sub	x6, x15, x14
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
