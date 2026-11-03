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
	vmv.x.s	a1, v12
	vmv.v.i	v28, 0
	vsetvli	zero, zero, e8, m1, tu, ma
	vmv.s.x	v28, a1
	vsetivli	zero, 2, e8, m1, tu, ma
	vslideup.vi	v28, v12, 1
	vsetivli	zero, 3, e8, m1, tu, ma
	vslideup.vi	v28, v12, 2
	vsetivli	zero, 4, e8, m1, tu, ma
	vslideup.vi	v28, v12, 3
	vsetivli	zero, 5, e8, m1, tu, ma
	vslideup.vi	v28, v12, 4
	vsetivli	zero, 6, e8, m1, tu, ma
	vslideup.vi	v28, v12, 5
	vsetivli	zero, 7, e8, m1, tu, ma
	vslideup.vi	v28, v12, 6
	vsetivli	zero, 8, e8, m1, tu, ma
	vslideup.vi	v28, v12, 7
	vsetivli	zero, 9, e8, m1, tu, ma
	vslideup.vi	v28, v12, 8
	vsetivli	zero, 10, e8, m1, tu, ma
	vslideup.vi	v28, v12, 9
	vsetivli	zero, 11, e8, m1, tu, ma
	vslideup.vi	v28, v12, 10
	vsetivli	zero, 12, e8, m1, tu, ma
	vslideup.vi	v28, v12, 11
	vsetivli	zero, 13, e8, m1, tu, ma
	vslideup.vi	v28, v12, 12
	vsetivli	zero, 14, e8, m1, tu, ma
	vslideup.vi	v28, v12, 13
	vsetivli	zero, 15, e8, m1, tu, ma
	vslideup.vi	v28, v12, 14
	vsetivli	zero, 16, e8, m1, tu, ma
	vslideup.vi	v28, v12, 15
	vmv1r.v	v12, v28
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
