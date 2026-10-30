	.file	"qemuaot"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             // -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
Fx0:                                    // @Fx0
// %bb.0:                               // %entry
	mov	x16, x25
	cbz	x8, .LBB0_3
// %bb.1:                               // %bb_false1
	asr	x14, x6, #63
	asr	x15, x8, #63
	str	x0, [sp, #536]                  // 8-byte Folded Spill
	mov	x0, x6
	str	x1, [sp, #528]                  // 8-byte Folded Spill
	mov	x29, x8
	mov	x1, x14
	str	w2, [sp, #524]                  // 4-byte Folded Spill
	mov	x2, x8
	str	x3, [sp, #512]                  // 8-byte Folded Spill
	mov	x3, x15
	mov	x19, x6
	stp	x24, x27, [sp, #40]             // 16-byte Folded Spill
	mov	x27, x13
	mov	x24, x11
	stp	x20, x21, [sp, #8]              // 16-byte Folded Spill
	mov	x21, x12
	mov	x20, x10
	stp	x22, x23, [sp, #24]             // 16-byte Folded Spill
	mov	x23, x9
	mov	x22, x7
	str	x28, [sp, #56]                  // 8-byte Folded Spill
	mov	x28, x16
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
	mov	x26, #11472                     // =0x2cd0
	add	x25, x25, x26, uxtx
	mov	x26, sp
	stur	x26, [x25, #-64]
	ldur	x26, [x25, #-56]
	stur	x25, [x26, #-8]
	sub	x26, x26, #16
	mov	sp, x26
	bl	__divti3
	add	sp, sp, #16
	ldur	x25, [sp, #-8]
	mov	x26, sp
	stur	x26, [x25, #-56]
	ldur	x26, [x25, #-64]
	mov	sp, x26
	mov	x26, #11472                     // =0x2cd0
	sub	x25, x25, x26, uxtx
	ldp	q0, q1, [sp, #64]               // 32-byte Folded Reload
	mov	x16, x28
	ldp	q2, q3, [sp, #96]               // 32-byte Folded Reload
	mov	x7, x22
	ldp	q4, q5, [sp, #128]              // 32-byte Folded Reload
	mov	x9, x23
	ldp	q6, q7, [sp, #160]              // 32-byte Folded Reload
	mov	x10, x20
	ldp	q8, q9, [sp, #192]              // 32-byte Folded Reload
	mov	x12, x21
	ldp	q10, q11, [sp, #224]            // 32-byte Folded Reload
	mov	x13, x27
	ldp	q12, q13, [sp, #256]            // 32-byte Folded Reload
	mov	x14, x0
	ldp	q14, q15, [sp, #288]            // 32-byte Folded Reload
	mov	x15, x1
	ldp	q16, q17, [sp, #320]            // 32-byte Folded Reload
	mov	x11, x24
	ldp	q18, q19, [sp, #352]            // 32-byte Folded Reload
	eor	x15, x15, x14, asr #63
	ldp	q20, q21, [sp, #384]            // 32-byte Folded Reload
	mov	x6, x19
	ldp	q22, q23, [sp, #416]            // 32-byte Folded Reload
	mov	x8, x29
	ldp	q24, q25, [sp, #448]            // 32-byte Folded Reload
	ldr	x24, [sp, #40]                  // 8-byte Folded Reload
	ldp	q26, q27, [sp, #480]            // 32-byte Folded Reload
	ldr	w2, [sp, #524]                  // 4-byte Folded Reload
	ldr	x3, [sp, #512]                  // 8-byte Folded Reload
	ldr	x0, [sp, #536]                  // 8-byte Folded Reload
	ldr	x1, [sp, #528]                  // 8-byte Folded Reload
	ldp	x22, x23, [sp, #24]             // 16-byte Folded Reload
	ldp	x20, x21, [sp, #8]              // 16-byte Folded Reload
	ldp	x27, x28, [sp, #48]             // 16-byte Folded Reload
	cbnz	x15, .LBB0_3
// %bb.2:                               // %divs2.done
	msub	x8, x14, x8, x6
	mov	x6, x14
	mov	x25, x16
	b	Fx55aa
.LBB0_3:                                // %bb_L0
	mov	w14, #11472                     // =0x2cd0
	mov	x25, x16
	mov	x5, xzr
	add	x4, x16, x14
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
	str	x7, [x25, #11480]
	mov	x19, x5
	mov	x29, x4
	str	x6, [x25, #11472]
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
	.type	env_offset,@object              // @env_offset
	.section	.rodata,"a",@progbits
	.globl	env_offset
	.p2align	3, 0x0
env_offset:
	.xword	11472                           // 0x2cd0
	.size	env_offset, 8

	.section	".note.GNU-stack","",@progbits
