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
	sb	zero, 4(a6)
	sb	zero, 5(a6)
	sb	zero, 6(a6)
	sb	zero, 7(a6)
	srli	a1, a7, 24
	srli	a2, a7, 16
	srli	a3, a7, 8
	sb	a7, 0(a6)
	sb	a3, 1(a6)
	sb	a2, 2(a6)
	sb	a1, 3(a6)
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
