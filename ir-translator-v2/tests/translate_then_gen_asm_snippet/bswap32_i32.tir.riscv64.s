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
	srli	a1, a6, 8
	lui	a2, 16
	srliw	a3, a6, 24
	addi	a2, a2, -256
	and	a1, a1, a2
	and	a2, a6, a2
	or	a1, a1, a3
	slli	a2, a2, 8
	slli	a6, a6, 24
	or	a2, a6, a2
	or	a1, a2, a1
	slli	a1, a1, 32
	srli	a6, a1, 32
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
