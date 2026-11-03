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
	mv	a1, a7
	beqz	a6, .LBB0_2
# %bb.1:                                # %entry
	srli	a1, a6, 1
	lui	a2, 349525
	lui	a3, 209715
	lui	a4, 61681
	or	a1, a6, a1
	addi	a2, a2, 1365
	addi	a3, a3, 819
	addi	a4, a4, -241
	srli	a6, a1, 2
	or	a1, a1, a6
	slli	a6, a2, 32
	add	a2, a2, a6
	slli	a6, a3, 32
	add	a3, a3, a6
	slli	a6, a4, 32
	add	a4, a4, a6
	srli	a6, a1, 4
	or	a1, a1, a6
	srli	a6, a1, 8
	or	a1, a1, a6
	srli	a6, a1, 16
	or	a1, a1, a6
	srli	a6, a1, 32
	or	a1, a1, a6
	not	a1, a1
	srli	a6, a1, 1
	and	a2, a6, a2
	sub	a1, a1, a2
	and	a2, a1, a3
	srli	a1, a1, 2
	and	a1, a1, a3
	lui	a3, 4112
	addi	a3, a3, 257
	add	a1, a2, a1
	srli	a2, a1, 4
	add	a1, a1, a2
	slli	a2, a3, 32
	and	a1, a1, a4
	add	a2, a3, a2
	mul	a1, a1, a2
	srli	a1, a1, 56
.LBB0_2:                                # %entry
	mv	a6, a1
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
