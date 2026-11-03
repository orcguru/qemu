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
	slli	a1, a6, 32
	slli	a2, a7, 32
	mulhu	a1, a2, a1
	li	a2, -1
	slli	a2, a2, 32
	and	a3, a6, a2
	and	a2, s2, a2
	srli	a4, a1, 32
	slli	a1, a1, 32
	srli	a1, a1, 32
	or	a6, a1, a3
	or	s2, a4, a2
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
