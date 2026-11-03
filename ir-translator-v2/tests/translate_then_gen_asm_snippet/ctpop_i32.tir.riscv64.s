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
	srli	a1, a6, 32
	srli	a2, a6, 1
	lui	a3, 349525
	addi	a3, a3, 1365
	and	a2, a2, a3
	lui	a3, 209715
	addi	a3, a3, 819
	sub	a2, a6, a2
	and	a4, a2, a3
	srli	a2, a2, 2
	and	a2, a2, a3
	lui	a3, 61681
	add	a2, a4, a2
	srli	a4, a2, 4
	add	a2, a2, a4
	lui	a4, 4112
	slli	a1, a1, 32
	addi	a3, a3, -241
	and	a2, a2, a3
	addi	a3, a4, 257
	mul	a2, a2, a3
	srliw	a2, a2, 24
	or	a6, a1, a2
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
