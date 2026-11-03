	.attribute	4, 16
	.attribute	5, "rv64i2p1"
	.file	"qemuaot"
	.option	push
	.option	arch, +a, +d, +f, +m, +v, +zaamo, +zalrsc, +zicsr, +zmmul, +zve32f, +zve32x, +zve64d, +zve64f, +zve64x, +zvl128b, +zvl32b, +zvl64b
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0                             # -- Begin function Fx0
	.p2align	2
	.type	Fx0,@function
	.variant_cc	Fx0
Fx0:                                    # @Fx0
# %bb.0:                                # %entry
	lbu	a1, 1(a6)
	lbu	a2, 2(a6)
	lbu	a3, 3(a6)
	lbu	a4, 0(a6)
	slli	a1, a1, 8
	slli	a2, a2, 16
	slli	a3, a3, 24
	or	a1, a1, a4
	or	a2, a3, a2
	lbu	a3, 5(a6)
	lbu	a4, 4(a6)
	lbu	t2, 6(a6)
	lbu	t3, 7(a6)
	slli	a3, a3, 8
	or	a3, a3, a4
	slli	t2, t2, 16
	slli	t3, t3, 24
	or	a4, t3, t2
	ld	s2, 8(a6)
	or	a1, a2, a1
	or	a3, a4, a3
	slli	a3, a3, 32
	or	a6, a3, a1
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
