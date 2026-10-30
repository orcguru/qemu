	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	adrp	x15, :got:Fx0_1
	mov	w14, #11472                     // =0x2cd0
	sub	x5, x11, #320
	ldr	x15, [x15, :got_lo12:Fx0_1]
	ldr	x18, [x25, #11464]
	add	x4, x25, x14
	mov	x14, xzr
	stur	x5, [x18, #-16]
	b	trampoline_helper_fsave
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        // -- End function
	.section	.text.trampoline_helper_fsave,"ax",@progbits
	.globl	trampoline_helper_fsave         // -- Begin function trampoline_helper_fsave
	.p2align	2
	.type	trampoline_helper_fsave,@function
trampoline_helper_fsave:                // @trampoline_helper_fsave
// %bb.0:                               // %entry
	str	x8, [x25, #11488]
	mov	w8, #11472                      // =0x2cd0
	str	x0, [x25, #11624]
	mov	x0, x4
	add	x8, x25, x8
	str	x1, [x25, #11616]
	mov	x1, x5
	//APP
	mov	x16, x8
	//NO_APP
	str	w2, [x25, #11640]
	mov	x2, x14
	str	x15, [sp, #8]                   // 8-byte Folded Spill
	str	x6, [x25, #11472]
	str	x7, [x25, #11480]
	str	x9, [x25, #11496]
	str	x10, [x25, #11504]
	str	x11, [x25, #11512]
	str	x12, [x25, #11520]
	str	x13, [x25, #11528]
	str	x20, [x25, #11536]
	str	x21, [x25, #11544]
	str	x22, [x25, #11552]
	str	x23, [x25, #11560]
	str	x24, [x25, #11568]
	str	x26, [x25, #11576]
	str	x27, [x25, #11584]
	str	x28, [x25, #11592]
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
	mov	x17, sp
	stur	x17, [x16, #-64]
	ldur	x17, [x16, #-56]
	stur	x16, [x17, #-8]
	sub	x17, x17, #16
	mov	sp, x17
	bl	helper_fsave
	add	sp, sp, #16
	ldur	x16, [sp, #-8]
	mov	x17, sp
	stur	x17, [x16, #-56]
	ldur	x17, [x16, #-64]
	mov	sp, x17
	ldr	x6, [x25, #11472]
	ldr	x7, [x25, #11480]
	ldr	x8, [x25, #11488]
	ldr	x9, [x25, #11496]
	ldr	x10, [x25, #11504]
	ldr	x11, [x25, #11512]
	ldr	x12, [x25, #11520]
	ldr	x13, [x25, #11528]
	ldr	x20, [x25, #11536]
	ldr	x21, [x25, #11544]
	ldr	x22, [x25, #11552]
	ldr	x23, [x25, #11560]
	ldr	x24, [x25, #11568]
	ldr	x26, [x25, #11576]
	ldr	x27, [x25, #11584]
	ldr	x28, [x25, #11592]
	ldr	x0, [x25, #11624]
	ldr	x1, [x25, #11616]
	ldr	w2, [x25, #11640]
	ldr	x3, [x25, #11600]
	ldr	q0, [x25, #12336]
	ldr	q1, [x25, #12352]
	ldr	q2, [x25, #12400]
	ldr	q3, [x25, #12416]
	ldr	q4, [x25, #12464]
	ldr	q5, [x25, #12480]
	ldr	q6, [x25, #12528]
	ldr	q7, [x25, #12544]
	ldr	q8, [x25, #12592]
	ldr	q9, [x25, #12608]
	ldr	q10, [x25, #12656]
	ldr	q11, [x25, #12672]
	ldr	q12, [x25, #12720]
	ldr	q13, [x25, #12736]
	ldr	q14, [x25, #12784]
	ldr	q15, [x25, #12800]
	ldr	q16, [x25, #12848]
	ldr	q17, [x25, #12864]
	ldr	q18, [x25, #12912]
	ldr	q19, [x25, #12928]
	ldr	q20, [x25, #12976]
	ldr	q21, [x25, #12992]
	ldr	q22, [x25, #13040]
	ldr	q23, [x25, #13056]
	ldr	q24, [x25, #13104]
	ldr	q25, [x25, #13120]
	ldr	q26, [x25, #13168]
	ldr	q27, [x25, #13184]
	ldr	x4, [sp, #8]                    // 8-byte Folded Reload
	br	x4
.Lfunc_end1:
	.size	trampoline_helper_fsave, .Lfunc_end1-trampoline_helper_fsave
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
