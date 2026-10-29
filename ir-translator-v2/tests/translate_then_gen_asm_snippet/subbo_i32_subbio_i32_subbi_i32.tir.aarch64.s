	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	subs	w14, w6, w7
	cmp	w14, w8
	cset	w14, eq
	subs	w15, w6, w7
	cset	w16, lo
	csel	w14, wzr, w14, hs
	subs	w15, w15, w8
	sbfx	w16, w16, #0, #1
	csinc	w14, w14, wzr, hs
	sub	w16, w16, w9
	add	w15, w16, w15
	sub	w6, w15, w14
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
