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
	lui	a1, 349525
	lui	a2, 209715
	lui	a3, 61681
	addi	a1, a1, 1365
	addi	a2, a2, 819
	addi	a3, a3, -241
	slli	a4, a1, 32
	add	a1, a1, a4
	slli	a4, a2, 32
	add	a2, a2, a4
	slli	a4, a3, 32
	add	a3, a3, a4
	srli	a4, a6, 1
	and	a1, a4, a1
	sub	a1, a6, a1
	and	a4, a1, a2
	srli	a1, a1, 2
	and	a1, a1, a2
	lui	a2, 4112
	addi	a2, a2, 257
	add	a1, a4, a1
	srli	a4, a1, 4
	add	a1, a1, a4
	slli	a4, a2, 32
	and	a1, a1, a3
	add	a2, a2, a4
	mul	a1, a1, a2
	srli	a6, a1, 56
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
