	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	cbz	x8, .LBB0_3
// %bb.1:                               // %bb_false
	str	x0, [sp, #568]                  // 8-byte Folded Spill
	mov	x0, x6
	mov	x29, x9
	str	x1, [sp, #560]                  // 8-byte Folded Spill
	mov	x1, x7
	mov	x19, x7
	str	w2, [sp, #556]                  // 4-byte Folded Spill
	mov	x2, x8
	stp	x27, x28, [sp, #48]             // 16-byte Folded Spill
	mov	x28, x3
	mov	x3, xzr
	mov	x27, x4
	stp	x20, x21, [sp]                  // 16-byte Folded Spill
	mov	x21, x13
	stp	x24, x26, [sp, #32]             // 16-byte Folded Spill
	mov	x26, x12
	mov	x20, x11
	mov	x24, x10
	stp	x22, x23, [sp, #16]             // 16-byte Folded Spill
	mov	x23, x8
	mov	x22, x6
	stp	q0, q1, [sp, #64]               // 32-byte Folded Spill
	stp	q2, q3, [sp, #96]               // 32-byte Folded Spill
	stp	q4, q5, [sp, #128]              // 32-byte Folded Spill
	stp	q6, q7, [sp, #160]              // 32-byte Folded Spill
	stp	q8, q9, [sp, #192]              // 32-byte Folded Spill
	stp	q10, q11, [sp, #224]            // 32-byte Folded Spill
	stp	q12, q13, [sp, #256]            // 32-byte Folded Spill
	stp	q14, q15, [sp, #288]            // 32-byte Folded Spill
	stp	q16, q17, [sp, #320]            // 32-byte Folded Spill
	stp	q18, q19, [sp, #352]            // 32-byte Folded Spill
	stp	q20, q21, [sp, #384]            // 32-byte Folded Spill
	stp	q22, q23, [sp, #416]            // 32-byte Folded Spill
	stp	q24, q25, [sp, #448]            // 32-byte Folded Spill
	stp	q26, q27, [sp, #480]            // 32-byte Folded Spill
	stp	q28, q29, [sp, #512]            // 32-byte Folded Spill
	bl	__udivti3
	ldp	q0, q1, [sp, #64]               // 32-byte Folded Reload
	mov	x6, x22
	ldp	q2, q3, [sp, #96]               // 32-byte Folded Reload
	mov	x8, x23
	ldp	q4, q5, [sp, #128]              // 32-byte Folded Reload
	mov	x10, x24
	ldp	q6, q7, [sp, #160]              // 32-byte Folded Reload
	mov	x11, x20
	ldp	q8, q9, [sp, #192]              // 32-byte Folded Reload
	mov	x12, x26
	ldp	q10, q11, [sp, #224]            // 32-byte Folded Reload
	mov	x13, x21
	ldp	q12, q13, [sp, #256]            // 32-byte Folded Reload
	mov	x3, x28
	ldp	q14, q15, [sp, #288]            // 32-byte Folded Reload
	mov	x4, x27
	ldp	q16, q17, [sp, #320]            // 32-byte Folded Reload
	mov	x15, x1
	ldp	q18, q19, [sp, #352]            // 32-byte Folded Reload
	mov	x14, x0
	ldp	q20, q21, [sp, #384]            // 32-byte Folded Reload
	mov	x7, x19
	ldp	q22, q23, [sp, #416]            // 32-byte Folded Reload
	mov	x9, x29
	ldp	q24, q25, [sp, #448]            // 32-byte Folded Reload
	ldr	w2, [sp, #556]                  // 4-byte Folded Reload
	ldp	q26, q27, [sp, #480]            // 32-byte Folded Reload
	ldr	x1, [sp, #560]                  // 8-byte Folded Reload
	ldr	x0, [sp, #568]                  // 8-byte Folded Reload
	ldp	q28, q29, [sp, #512]            // 32-byte Folded Reload
	ldp	x22, x23, [sp, #16]             // 16-byte Folded Reload
	ldp	x24, x26, [sp, #32]             // 16-byte Folded Reload
	ldp	x20, x21, [sp]                  // 16-byte Folded Reload
	ldp	x27, x28, [sp, #48]             // 16-byte Folded Reload
	cbnz	x15, .LBB0_3
// %bb.2:                               // %divs2.done
	msub	x8, x14, x8, x6
	mov	x6, x14
	b	Fx55aa
.LBB0_3:                                // %bb_L0
	mov	w14, #11472                     // =0x2cd0
	add	x5, x4, x14
	mov	x14, xzr
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
