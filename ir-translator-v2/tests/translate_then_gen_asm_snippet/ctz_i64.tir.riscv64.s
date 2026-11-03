	.attribute	4, 16
	.attribute	5, "rv64i2p1"
	.file	"qemuaot"
	.option	push
	.option	arch, +a, +d, +f, +m, +v, +zaamo, +zalrsc, +zicsr, +zmmul, +zve32f, +zve32x, +zve64d, +zve64f, +zve64x, +zvl128b, +zvl32b, +zvl64b
	.section	.rodata.cst8,"aM",@progbits,8
	.p2align	3, 0x0                          # -- Begin function Fx0
.LCPI0_0:
	.quad	151050438420815295              # 0x218a392cd3d5dbf
	.section	.rodata,"a",@progbits
.LCPI0_1:
	.ascii	"\000\001\002\007\003\r\b\023\004\031\016\034\t\"\024(\005\021\032&\017.\0350\n\037#6\0252)9?\006\f\022\030\033!'\020%-/\036518>\013\027 $,47=\026+3<*;:"
	.section	.text.Fx0,"ax",@progbits
	.globl	Fx0
	.p2align	2
	.type	Fx0,@function
	.variant_cc	Fx0
Fx0:                                    # @Fx0
# %bb.0:                                # %entry
	mv	a1, a7
	beqz	a6, .LBB0_2
# %bb.1:                                # %entry
	lui	a1, %hi(.LCPI0_0)
	ld	a1, %lo(.LCPI0_0)(a1)
	neg	a2, a6
	and	a2, a6, a2
	mul	a1, a2, a1
	srli	a1, a1, 58
	lui	a2, %hi(.LCPI0_1)
	addi	a2, a2, %lo(.LCPI0_1)
	add	a1, a2, a1
	lbu	a1, 0(a1)
.LBB0_2:                                # %entry
	mv	a6, a1
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
