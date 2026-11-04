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
	vsetivli	zero, 16, e8, m1, ta, ma
	vand.vi	v28, v14, 7
	vrsub.vi	v29, v14, 0
	vsrl.vv	v28, v12, v28
	vand.vi	v29, v29, 7
	vsll.vv	v12, v12, v29
	vor.vv	v12, v28, v12
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
