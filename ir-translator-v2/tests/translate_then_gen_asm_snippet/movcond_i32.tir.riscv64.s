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
	sext.w	a3, a6
	srli	a1, a6, 32
	sext.w	a4, a7
	slli	a1, a1, 32
	mv	a2, s2
	blt	a3, a4, .LBB0_2
# %bb.1:                                # %entry
	mv	a2, s6
.LBB0_2:                                # %entry
	slli	a2, a2, 32
	srli	a2, a2, 32
	or	a6, a2, a1
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
