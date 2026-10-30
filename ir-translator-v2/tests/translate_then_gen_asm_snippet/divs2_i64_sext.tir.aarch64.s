	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	mov	w14, #11472                     // =0x2cd0
	add	x29, x25, x14
	cbz	x8, .LBB0_3
// %bb.1:                               // %bb_false1
	asr	x14, x6, #63
	asr	x15, x8, #63
	str	x0, [sp, #536]                  // 8-byte Folded Spill
	mov	x0, x6
	stp	x28, x1, [sp, #64]              // 16-byte Folded Spill
	mov	w19, w2
	mov	x1, x14
	mov	x2, x8
	str	x25, [sp, #528]                 // 8-byte Folded Spill
	mov	x25, x3
	mov	x3, x15
	//APP
	mov	x16, x29
	//NO_APP
	mov	x28, x13
	stp	x22, x23, [sp, #24]             // 16-byte Folded Spill
	mov	x23, x12
	stp	x26, x27, [sp, #48]             // 16-byte Folded Spill
	mov	x27, x11
	mov	x22, x10
	mov	x26, x9
	stp	x20, x21, [sp, #8]              // 16-byte Folded Spill
	mov	x21, x8
	str	x24, [sp, #40]                  // 8-byte Folded Spill
	mov	x24, x7
	mov	x20, x6
	stp	q0, q1, [sp, #80]               // 32-byte Folded Spill
	stp	q2, q3, [sp, #112]              // 32-byte Folded Spill
	stp	q4, q5, [sp, #144]              // 32-byte Folded Spill
	stp	q6, q7, [sp, #176]              // 32-byte Folded Spill
	stp	q8, q9, [sp, #208]              // 32-byte Folded Spill
	stp	q10, q11, [sp, #240]            // 32-byte Folded Spill
	stp	q12, q13, [sp, #272]            // 32-byte Folded Spill
	stp	q14, q15, [sp, #304]            // 32-byte Folded Spill
	stp	q16, q17, [sp, #336]            // 32-byte Folded Spill
	stp	q18, q19, [sp, #368]            // 32-byte Folded Spill
	stp	q20, q21, [sp, #400]            // 32-byte Folded Spill
	stp	q22, q23, [sp, #432]            // 32-byte Folded Spill
	stp	q24, q25, [sp, #464]            // 32-byte Folded Spill
	stp	q26, q27, [sp, #496]            // 32-byte Folded Spill
	mov	x17, sp
	stur	x17, [x16, #-64]
	ldur	x17, [x16, #-56]
	stur	x16, [x17, #-8]
	sub	x17, x17, #16
	mov	sp, x17
	bl	__divti3
	add	sp, sp, #16
	ldur	x16, [sp, #-8]
	mov	x17, sp
	stur	x17, [x16, #-56]
	ldur	x17, [x16, #-64]
	mov	sp, x17
	ldp	q0, q1, [sp, #80]               // 32-byte Folded Reload
	mov	x6, x20
	ldp	q2, q3, [sp, #112]              // 32-byte Folded Reload
	mov	x7, x24
	ldp	q4, q5, [sp, #144]              // 32-byte Folded Reload
	mov	x8, x21
	ldp	q6, q7, [sp, #176]              // 32-byte Folded Reload
	mov	x9, x26
	ldp	q8, q9, [sp, #208]              // 32-byte Folded Reload
	mov	x10, x22
	ldp	q10, q11, [sp, #240]            // 32-byte Folded Reload
	mov	x11, x27
	ldp	q12, q13, [sp, #272]            // 32-byte Folded Reload
	mov	x12, x23
	ldp	q14, q15, [sp, #304]            // 32-byte Folded Reload
	mov	x13, x28
	ldp	q16, q17, [sp, #336]            // 32-byte Folded Reload
	mov	x14, x0
	ldp	q18, q19, [sp, #368]            // 32-byte Folded Reload
	mov	x15, x1
	ldp	q20, q21, [sp, #400]            // 32-byte Folded Reload
	mov	x3, x25
	ldp	q22, q23, [sp, #432]            // 32-byte Folded Reload
	eor	x15, x15, x14, asr #63
	ldp	q24, q25, [sp, #464]            // 32-byte Folded Reload
	mov	w2, w19
	ldp	q26, q27, [sp, #496]            // 32-byte Folded Reload
	ldr	x25, [sp, #528]                 // 8-byte Folded Reload
	ldp	x20, x21, [sp, #8]              // 16-byte Folded Reload
	ldr	x0, [sp, #536]                  // 8-byte Folded Reload
	ldr	x1, [sp, #72]                   // 8-byte Folded Reload
	ldp	x24, x26, [sp, #40]             // 16-byte Folded Reload
	ldp	x22, x23, [sp, #24]             // 16-byte Folded Reload
	ldp	x27, x28, [sp, #56]             // 16-byte Folded Reload
	cbnz	x15, .LBB0_3
// %bb.2:                               // %divs2.done
	msub	x8, x14, x8, x6
	mov	x6, x14
	b	Fx55aa
.LBB0_3:                                // %bb_L0
	mov	x4, x29
	mov	x5, xzr
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
	mov	x17, sp
	stur	x17, [x16, #-64]
	ldur	x17, [x16, #-56]
	stur	x16, [x17, #-8]
	sub	x17, x17, #16
	mov	sp, x17
	b	helper_raise_exception
.Lfunc_end1:
	.size	trampoline_helper_raise_exception, .Lfunc_end1-trampoline_helper_raise_exception
                                        // -- End function
	.section	".note.GNU-stack","",@progbits
