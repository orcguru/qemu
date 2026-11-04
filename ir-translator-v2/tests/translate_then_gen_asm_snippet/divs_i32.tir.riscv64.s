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
	sext.w	a1, a7
	beqz	a1, .LBB0_3
# %bb.1:                                # %bb_false
	sext.w	a2, a6
	lui	a3, 524288
	bne	a2, a3, .LBB0_4
# %bb.2:                                # %bb_false
	li	a2, -1
	bne	a1, a2, .LBB0_4
.LBB0_3:                                # %bb_L0
	lui	a1, 3
	addi	a1, a1, -800
	add	a1, s9, a1
	li	a2, 0
	tail	trampoline_helper_raise_exception
.LBB0_4:                                # %bb_false1
	divw	a1, a6, a7
	srli	a2, a6, 32
	slli	a2, a2, 32
	slli	a1, a1, 32
	srli	a1, a1, 32
	or	a6, a2, a1
	tail	Fx55aa
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.option	push
	.option	arch, +a, +d, +f, +m, +v, +zaamo, +zalrsc, +zicsr, +zmmul, +zve32f, +zve32x, +zve64d, +zve64f, +zve64x, +zvl128b, +zvl32b, +zvl64b
	.section	.text.trampoline_helper_raise_exception,"ax",@progbits
	.globl	trampoline_helper_raise_exception # -- Begin function trampoline_helper_raise_exception
	.p2align	2
	.type	trampoline_helper_raise_exception,@function
	.variant_cc	trampoline_helper_raise_exception
trampoline_helper_raise_exception:      # @trampoline_helper_raise_exception
# %bb.0:                                # %entry
	sd	a2, 88(sp)                      # 8-byte Folded Spill
	sd	a1, 80(sp)                      # 8-byte Folded Spill
	sd	a0, 64(sp)                      # 8-byte Folded Spill
	sd	t1, 72(sp)                      # 8-byte Folded Spill
	sd	t0, 48(sp)                      # 8-byte Folded Spill
	sd	a5, 56(sp)                      # 8-byte Folded Spill
	sd	t6, 40(sp)                      # 8-byte Folded Spill
	sd	t5, 32(sp)                      # 8-byte Folded Spill
	sd	t4, 24(sp)                      # 8-byte Folded Spill
	sd	s1, 16(sp)                      # 8-byte Folded Spill
	sd	s11, 8(sp)                      # 8-byte Folded Spill
	sd	s10, 0(sp)                      # 8-byte Folded Spill
	mv	s11, s8
	mv	s10, s7
	mv	s8, s6
	mv	s7, s5
	mv	s6, s4
	mv	s5, s3
	mv	s4, s2
	mv	s3, a7
	mv	s2, a6
	lui	a3, 3
	li	a4, 25
	addi	t6, a3, -800
	addi	ra, a3, 64
	slli	s1, a4, 9
	addi	a7, a3, 128
	addi	t0, a3, 192
	addi	t1, a3, 256
	addi	t3, a3, 320
	addi	t4, a3, 384
	addi	t5, a3, 448
	addi	a6, a3, 576
	addi	a5, a3, 640
	addi	a4, a3, 704
	addi	a2, a3, 768
	addi	a1, a3, 832
	addi	a0, a3, 896
	add	a3, s9, t6
	add	ra, s9, ra
	add	a7, s9, a7
	add	t0, s9, t0
	add	t1, s9, t1
	add	t3, s9, t3
	add	t4, s9, t4
	add	t5, s9, t5
	add	s1, s9, s1
	add	a6, s9, a6
	add	a5, s9, a5
	add	a4, s9, a4
	add	a2, s9, a2
	add	a1, s9, a1
	add	a0, s9, a0
	sd	s2, 0(a3)
	sd	s3, 8(a3)
	sd	s4, 16(a3)
	sd	s5, 24(a3)
	sd	s6, 32(a3)
	sd	s7, 40(a3)
	sd	s8, 48(a3)
	sd	s10, 56(a3)
	sd	s11, 64(a3)
	ld	t6, 0(sp)                       # 8-byte Folded Reload
	sd	t6, 72(a3)
	ld	t6, 8(sp)                       # 8-byte Folded Reload
	sd	t6, 80(a3)
	ld	t6, 16(sp)                      # 8-byte Folded Reload
	sd	t6, 88(a3)
	ld	t6, 24(sp)                      # 8-byte Folded Reload
	sd	t6, 96(a3)
	ld	t6, 32(sp)                      # 8-byte Folded Reload
	sd	t6, 104(a3)
	ld	t6, 40(sp)                      # 8-byte Folded Reload
	sd	t6, 112(a3)
	sd	gp, 120(a3)
	ld	t6, 64(sp)                      # 8-byte Folded Reload
	sd	t6, 128(a3)
	ld	t6, 48(sp)                      # 8-byte Folded Reload
	sd	t6, 144(a3)
	ld	t6, 56(sp)                      # 8-byte Folded Reload
	sd	t6, 152(a3)
	ld	t6, 72(sp)                      # 8-byte Folded Reload
	sw	t6, 168(a3)
	vs2r.v	v0, (ra)
	vs2r.v	v2, (a7)
	vs2r.v	v4, (t0)
	vs2r.v	v6, (t1)
	vs2r.v	v8, (t3)
	vs2r.v	v10, (t4)
	vs2r.v	v12, (t5)
	vs2r.v	v14, (s1)
	vs2r.v	v16, (a6)
	vs2r.v	v18, (a5)
	vs2r.v	v20, (a4)
	vs2r.v	v22, (a2)
	vs2r.v	v24, (a1)
	vs2r.v	v26, (a0)
	#APP
	mv	t2, a3
	#NO_APP
	ld	a0, 80(sp)                      # 8-byte Folded Reload
	ld	a1, 88(sp)                      # 8-byte Folded Reload
	sd	sp, -64(t2)
	ld	sp, -56(t2)
	ld	tp, -80(t2)
	sd	t2, -8(sp)
	addi	sp, sp, -16
	tail	helper_raise_exception
.Lfunc_end1:
	.size	trampoline_helper_raise_exception, .Lfunc_end1-trampoline_helper_raise_exception
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
