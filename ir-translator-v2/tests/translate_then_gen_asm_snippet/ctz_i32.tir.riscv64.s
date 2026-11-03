	.attribute	4, 16
	.attribute	5, "rv64i2p1"
	.file	"qemuaot"
	.option	push
	.option	arch, +a, +d, +f, +m, +v, +zaamo, +zalrsc, +zicsr, +zmmul, +zve32f, +zve32x, +zve64d, +zve64f, +zve64x, +zvl128b, +zvl32b, +zvl64b
	.section	.rodata.cst32,"aM",@progbits,32
.LCPI0_0:                               # -- Begin function Fx0
	.ascii	"\000\001\034\002\035\016\030\003\036\026\024\017\031\021\004\b\037\033\r\027\025\023\020\007\032\f\022\006\013\005\n\t"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0
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
	negw	a2, a6
	and	a2, a6, a2
	lui	a3, 30667
	addi	a3, a3, 1329
	mul	a2, a2, a3
	srliw	a2, a2, 27
	lui	a3, %hi(.LCPI0_0)
	addi	a3, a3, %lo(.LCPI0_0)
	add	a2, a3, a2
	lbu	a2, 0(a2)
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
