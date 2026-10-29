	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	adrp	x15, :got:Fx0_1
	mov	w14, #11472                     // =0x2cd0
	mov	w16, #12656                     // =0x3170
	ldr	x15, [x15, :got_lo12:Fx0_1]
	add	x4, x25, x14
	add	x5, x25, x16
	mov	w14, #66                        // =0x42
	b	trampoline_helper_rdrand
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        // -- End function
	.section	.text.trampoline_helper_rdrand,"ax",@progbits
	.globl	trampoline_helper_rdrand        // -- Begin function trampoline_helper_rdrand
	.p2align	2
	.type	trampoline_helper_rdrand,@function
trampoline_helper_rdrand:               // @trampoline_helper_rdrand
// %bb.0:                               // %entry
	stp	x14, x15, [sp]                  // 16-byte Folded Spill
	mov	x29, x4
	mov	x30, x5
	str	x8, [x25, #11488]
	mov	w8, #11472                      // =0x2cd0
	mov	x19, x25
	str	x6, [x25, #11472]
	str	x7, [x25, #11480]
	str	x9, [x25, #11496]
	str	x10, [x25, #11504]
	str	x11, [x25, #11512]
	str	x12, [x25, #11520]
	str	x13, [x25, #11528]
	str	x20, [x25, #11536]
	add	x20, x25, x8
	str	x21, [x25, #11544]
	ldr	x21, [sp]                       // 8-byte Folded Reload
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
	mov	x1, x30
	mov	x2, x21
	bl	helper_rdrand
	mov	x29, x0
	//NO_APP
	add	sp, sp, #16
	ldur	x25, [sp, #-8]
	mov	x26, sp
	stur	x26, [x25, #-56]
	ldur	x26, [x25, #-64]
	mov	sp, x26
	ldr	x6, [x19, #11472]
	ldr	x7, [x19, #11480]
	ldr	x8, [x19, #11488]
	ldr	x9, [x19, #11496]
	ldr	x10, [x19, #11504]
	ldr	x11, [x19, #11512]
	ldr	x12, [x19, #11520]
	ldr	x13, [x19, #11528]
	ldr	x20, [x19, #11536]
	ldr	x21, [x19, #11544]
	ldr	x22, [x19, #11552]
	ldr	x23, [x19, #11560]
	ldr	x24, [x19, #11568]
	ldr	x26, [x19, #11576]
	ldr	x27, [x19, #11584]
	ldr	x28, [x19, #11592]
	ldr	x0, [x19, #11624]
	ldr	x1, [x19, #11616]
	ldr	w2, [x19, #11640]
	ldr	x3, [x19, #11600]
	ldr	q0, [x19, #12336]
	ldr	q1, [x19, #12352]
	ldr	q2, [x19, #12400]
	ldr	q3, [x19, #12416]
	ldr	q4, [x19, #12464]
	ldr	q5, [x19, #12480]
	ldr	q6, [x19, #12528]
	ldr	q7, [x19, #12544]
	ldr	q8, [x19, #12592]
	ldr	q9, [x19, #12608]
	ldr	q10, [x19, #12656]
	ldr	q11, [x19, #12672]
	ldr	q12, [x19, #12720]
	ldr	q13, [x19, #12736]
	ldr	q14, [x19, #12784]
	ldr	q15, [x19, #12800]
	ldr	q16, [x19, #12848]
	ldr	q17, [x19, #12864]
	ldr	q18, [x19, #12912]
	ldr	q19, [x19, #12928]
	ldr	q20, [x19, #12976]
	ldr	q21, [x19, #12992]
	ldr	q22, [x19, #13040]
	ldr	q23, [x19, #13056]
	ldr	q24, [x19, #13104]
	ldr	q25, [x19, #13120]
	ldr	q26, [x19, #13168]
	ldr	q27, [x19, #13184]
	ldr	x5, [sp, #8]                    // 8-byte Folded Reload
	mov	x25, x19
	mov	x4, x29
	br	x5
.Lfunc_end1:
	.size	trampoline_helper_rdrand, .Lfunc_end1-trampoline_helper_rdrand
                                        // -- End function
	.section	.text.Fx0_1,"ax",@progbits
	.globl	Fx0_1                           // -- Begin function Fx0_1
	.p2align	2
	.type	Fx0_1,@function
Fx0_1:                                  // @Fx0_1
// %bb.0:                               // %entry
	b	Fx55aa
.Lfunc_end2:
	.size	Fx0_1, .Lfunc_end2-Fx0_1
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
