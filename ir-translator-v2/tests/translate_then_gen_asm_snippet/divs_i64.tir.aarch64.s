	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	cbz	x7, .LBB0_3
// %bb.1:                               // %bb_false
	mov	x14, #-9223372036854775808      // =0x8000000000000000
	cmp	x6, x14
	b.ne	.LBB0_4
// %bb.2:                               // %bb_false
	cmn	x7, #1
	b.ne	.LBB0_4
.LBB0_3:                                // %bb_L0
	mov	w14, #11472                     // =0x2cd0
	add	x5, x4, x14
	mov	x14, xzr
	b	trampoline_helper_raise_exception
.LBB0_4:                                // %bb_false1
	sdiv	x6, x6, x7
	b	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        // -- End function
	.section	.text.trampoline_helper_raise_exception,"ax",@progbits
	.globl	trampoline_helper_raise_exception // -- Begin function trampoline_helper_raise_exception
	.p2align	2
	.type	trampoline_helper_raise_exception,@function
trampoline_helper_raise_exception:      // @trampoline_helper_raise_exception
// %bb.0:                               // %entry
	str	x0, [x4, #11624]
	mov	x0, x5
	str	x1, [x4, #11616]
	mov	x1, x14
	str	x8, [x4, #11488]
	str	x6, [x4, #11472]
	str	x7, [x4, #11480]
	str	x9, [x4, #11496]
	str	x10, [x4, #11504]
	str	x11, [x4, #11512]
	str	x12, [x4, #11520]
	str	x13, [x4, #11528]
	str	x20, [x4, #11536]
	str	x21, [x4, #11544]
	str	x22, [x4, #11552]
	str	x23, [x4, #11560]
	str	x24, [x4, #11568]
	str	x26, [x4, #11576]
	str	x27, [x4, #11584]
	str	x28, [x4, #11592]
	str	w2, [x4, #11640]
	str	x3, [x4, #11600]
	str	q0, [x4, #12336]
	str	q1, [x4, #12352]
	str	q2, [x4, #12400]
	str	q3, [x4, #12416]
	str	q4, [x4, #12464]
	str	q5, [x4, #12480]
	str	q6, [x4, #12528]
	str	q7, [x4, #12544]
	str	q8, [x4, #12592]
	str	q9, [x4, #12608]
	str	q10, [x4, #12656]
	str	q11, [x4, #12672]
	str	q12, [x4, #12720]
	str	q13, [x4, #12736]
	str	q14, [x4, #12784]
	str	q15, [x4, #12800]
	str	q16, [x4, #12848]
	str	q17, [x4, #12864]
	str	q18, [x4, #12912]
	str	q19, [x4, #12928]
	str	q20, [x4, #12976]
	str	q21, [x4, #12992]
	str	q22, [x4, #13040]
	str	q23, [x4, #13056]
	str	q24, [x4, #13104]
	str	q25, [x4, #13120]
	str	q26, [x4, #13168]
	str	q27, [x4, #13184]
	str	q28, [x4, #13232]
	str	q29, [x4, #13248]
	b	helper_raise_exception
.Lfunc_end1:
	.size	trampoline_helper_raise_exception, .Lfunc_end1-trampoline_helper_raise_exception
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
