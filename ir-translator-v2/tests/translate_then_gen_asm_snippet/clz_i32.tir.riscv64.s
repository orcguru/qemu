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
	slli	a1, a1, 32
	mv	a2, a7
	beqz	a3, .LBB0_2
# %bb.1:                                # %entry
	srliw	a2, a6, 1
	lui	a3, 349525
	or	a2, a6, a2
	addi	a3, a3, 1365
	srliw	a4, a2, 2
	or	a2, a2, a4
	srliw	a4, a2, 4
	or	a2, a2, a4
	srliw	a4, a2, 8
	or	a2, a2, a4
	srliw	a4, a2, 16
	or	a2, a2, a4
	not	a2, a2
	srli	a4, a2, 1
	and	a3, a4, a3
	lui	a4, 209715
	addi	a4, a4, 819
	sub	a2, a2, a3
	and	a3, a2, a4
	srli	a2, a2, 2
	and	a2, a2, a4
	lui	a4, 61681
	add	a2, a3, a2
	srli	a3, a2, 4
	add	a2, a2, a3
	lui	a3, 4112
	addi	a4, a4, -241
	and	a2, a2, a4
	addi	a3, a3, 257
	mul	a2, a2, a3
	srliw	a2, a2, 24
.LBB0_2:                                # %entry
	slli	a2, a2, 32
	srli	a2, a2, 32
	or	a6, a1, a2
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
