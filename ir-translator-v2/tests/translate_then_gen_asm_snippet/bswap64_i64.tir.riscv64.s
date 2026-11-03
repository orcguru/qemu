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
	srli	a1, a6, 40
	lui	a2, 16
	srli	a3, a6, 56
	srli	a4, a6, 24
	lui	t2, 4080
	addi	a2, a2, -256
	and	a1, a1, a2
	or	a1, a1, a3
	srli	a3, a6, 8
	and	a4, a4, t2
	srliw	a3, a3, 24
	slli	a3, a3, 24
	or	a3, a3, a4
	srliw	a4, a6, 24
	and	t2, a6, t2
	and	a2, a6, a2
	slli	a6, a6, 56
	slli	a4, a4, 32
	slli	t2, t2, 24
	or	a4, t2, a4
	slli	a2, a2, 40
	or	a1, a3, a1
	or	a2, a6, a2
	or	a2, a2, a4
	or	a6, a2, a1
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
