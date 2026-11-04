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
	addi	a1, sp, 32
	addi	a1, a1, 16
	vs1r.v	v6, (a1)
	vsetivli	zero, 4, e16, mf2, ta, ma
	vle16.v	v28, (a1)
	addi	a1, sp, 16
	vs1r.v	v20, (a1)
	vse16.v	v28, (a1)
	vl1re64.v	v20, (a1)
	lui	a1, 4
	addi	a1, a1, -1984
	add	a1, s9, a1
	vse16.v	v28, (a1)
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
