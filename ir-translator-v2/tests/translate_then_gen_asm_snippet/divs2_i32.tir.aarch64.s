	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	cbz	w8, .LBB0_6
// %bb.1:                               // %bb_false
	cmn	w8, #1
	mov	w14, w6
	b.ne	.LBB0_4
// %bb.2:                               // %bb_false
	cbnz	x14, .LBB0_4
// %bb.3:                               // %bb_false
	mov	w15, w7
	mov	w16, #-2147483648               // =0x80000000
	cmp	x15, x16
	b.eq	.LBB0_6
.LBB0_4:                                // %bb_false1
	orr	x15, x14, x7, lsl #32
	sxtw	x16, w8
	sdiv	x14, x15, x16
	cmp	x14, w14, sxtw
	b.ne	.LBB0_6
// %bb.5:                               // %divs2.done
	msub	w15, w14, w16, w15
	and	x8, x8, #0xffffffff00000000
	bfxil	x6, x14, #0, #32
	orr	x8, x15, x8
	b	Fx55aa
.LBB0_6:                                // %bb_L0
	mov	w14, #11472                     // =0x2cd0
	mov	x5, xzr
	add	x4, x25, x14
	b	trampoline_helper_raise_exception
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        // -- End function
	.section	.text.trampoline_helper_raise_exception,"ax",@progbits
	.globl	trampoline_helper_raise_exception // -- Begin function trampoline_helper_raise_exception
	.p2align	2
	.type	trampoline_helper_raise_exception,@function
trampoline_helper_raise_exception:      // @trampoline_helper_raise_exception
// %bb.0:                               // %entry
	str	x6, [x25, #11472]
	mov	x19, x5
	mov	x29, x4
	str	x7, [x25, #11480]
	str	x8, [x25, #11488]
	mov	w8, #11472                      // =0x2cd0
	str	x9, [x25, #11496]
	str	x10, [x25, #11504]
	str	x11, [x25, #11512]
	str	x12, [x25, #11520]
	str	x13, [x25, #11528]
	str	x20, [x25, #11536]
	add	x20, x25, x8
	str	x21, [x25, #11544]
	str	x22, [x25, #11552]
	str	x23, [x25, #11560]
	str	x24, [x25, #11568]
	str	x26, [x25, #11576]
	str	x27, [x25, #11584]
	str	x28, [x25, #11592]
	str	x0, [x25, #11624]
	str	x1, [x25, #11616]
	str	w2, [x25, #11640]
	str	x3, [x25, #11600]
	str	q0, [x25, #12336]
	str	q1, [x25, #12352]
	str	q2, [x25, #12400]
	str	q3, [x25, #12416]
	str	q4, [x25, #12464]
	str	q5, [x25, #12480]
	str	q6, [x25, #12528]
	str	q7, [x25, #12544]
	str	q8, [x25, #12592]
	str	q9, [x25, #12608]
	str	q10, [x25, #12656]
	str	q11, [x25, #12672]
	str	q12, [x25, #12720]
	str	q13, [x25, #12736]
	str	q14, [x25, #12784]
	str	q15, [x25, #12800]
	str	q16, [x25, #12848]
	str	q17, [x25, #12864]
	str	q18, [x25, #12912]
	str	q19, [x25, #12928]
	str	q20, [x25, #12976]
	str	q21, [x25, #12992]
	str	q22, [x25, #13040]
	str	q23, [x25, #13056]
	str	q24, [x25, #13104]
	str	q25, [x25, #13120]
	str	q26, [x25, #13168]
	str	q27, [x25, #13184]
	mov	x26, sp
	stur	x26, [x20, #-64]
	ldur	x26, [x20, #-56]
	stur	x20, [x26, #-8]
	sub	x26, x26, #16
	mov	sp, x26
	//APP
	mov	x25, x20
	mov	x0, x29
	mov	x1, x19
	b	helper_raise_exception
	//NO_APP
	add	sp, sp, #16
	ldur	x25, [sp, #-8]
	mov	x26, sp
	stur	x26, [x25, #-56]
	ldur	x26, [x25, #-64]
	mov	sp, x26
	ret
.Lfunc_end1:
	.size	trampoline_helper_raise_exception, .Lfunc_end1-trampoline_helper_raise_exception
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
