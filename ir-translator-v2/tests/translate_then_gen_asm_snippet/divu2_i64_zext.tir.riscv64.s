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
	lui	a1, 3
	addi	a1, a1, -800
	add	a1, s9, a1
	beqz	s2, .LBB0_2
# %bb.1:                                # %bb_false
	divu	a2, a6, s2
	mul	a3, a2, s2
	sub	s2, a6, a3
	#APP
	mv	t2, a1
	#NO_APP
	mv	a6, a2
	tail	Fx55aa
.LBB0_2:                                # %bb_L0
	li	a2, 0
	tail	trampoline_helper_raise_exception
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
	sd	a2, 216(sp)                     # 8-byte Folded Spill
	sd	a1, 208(sp)                     # 8-byte Folded Spill
	sd	a0, 168(sp)                     # 8-byte Folded Spill
	sd	t1, 176(sp)                     # 8-byte Folded Spill
	sd	t0, 152(sp)                     # 8-byte Folded Spill
	sd	a5, 160(sp)                     # 8-byte Folded Spill
	sd	t6, 200(sp)                     # 8-byte Folded Spill
	sd	t5, 192(sp)                     # 8-byte Folded Spill
	sd	t4, 184(sp)                     # 8-byte Folded Spill
	sd	s1, 144(sp)                     # 8-byte Folded Spill
	sd	s11, 136(sp)                    # 8-byte Folded Spill
	sd	s10, 128(sp)                    # 8-byte Folded Spill
	sd	s8, 120(sp)                     # 8-byte Folded Spill
	sd	s7, 112(sp)                     # 8-byte Folded Spill
	sd	s6, 104(sp)                     # 8-byte Folded Spill
	sd	s5, 96(sp)                      # 8-byte Folded Spill
	sd	s4, 88(sp)                      # 8-byte Folded Spill
	sd	s3, 80(sp)                      # 8-byte Folded Spill
	sd	s2, 72(sp)                      # 8-byte Folded Spill
	sd	a7, 64(sp)                      # 8-byte Folded Spill
	sd	a6, 56(sp)                      # 8-byte Folded Spill
	lui	a3, 3
	li	s3, 25
	addi	t1, a3, -800
	addi	t3, a3, 64
	slli	s3, s3, 9
	sd	s3, 48(sp)                      # 8-byte Folded Spill
	addi	t4, a3, 80
	addi	t5, a3, 128
	addi	t6, a3, 144
	addi	s1, a3, 192
	addi	s2, a3, 208
	addi	s5, a3, 256
	addi	s6, a3, 272
	addi	s7, a3, 320
	addi	s8, a3, 336
	addi	s10, a3, 384
	addi	s11, a3, 400
	addi	ra, a3, 448
	addi	a0, a3, 464
	sd	a0, 40(sp)                      # 8-byte Folded Spill
	addi	a0, a3, 528
	sd	a0, 32(sp)                      # 8-byte Folded Spill
	addi	a0, a3, 576
	sd	a0, 24(sp)                      # 8-byte Folded Spill
	addi	a0, a3, 592
	sd	a0, 16(sp)                      # 8-byte Folded Spill
	addi	s4, a3, 640
	addi	s3, a3, 656
	addi	t0, a3, 704
	addi	a7, a3, 720
	addi	a6, a3, 768
	addi	a5, a3, 784
	addi	a4, a3, 832
	addi	a2, a3, 848
	addi	a1, a3, 896
	addi	a0, a3, 912
	add	a3, s9, t1
	add	t1, s9, t3
	add	t3, s9, t4
	add	t4, s9, t5
	add	t5, s9, t6
	add	t6, s9, s1
	add	s1, s9, s2
	add	s2, s9, s5
	add	s6, s9, s6
	sd	s6, 8(sp)                       # 8-byte Folded Spill
	add	s6, s9, s7
	add	s7, s9, s8
	add	s8, s9, s10
	add	s10, s9, s11
	add	s11, s9, ra
	ld	ra, 40(sp)                      # 8-byte Folded Reload
	add	ra, s9, ra
	ld	s5, 48(sp)                      # 8-byte Folded Reload
	add	s5, s9, s5
	sd	s5, 48(sp)                      # 8-byte Folded Spill
	ld	s5, 32(sp)                      # 8-byte Folded Reload
	add	s5, s9, s5
	sd	s5, 40(sp)                      # 8-byte Folded Spill
	ld	s5, 24(sp)                      # 8-byte Folded Reload
	add	s5, s9, s5
	sd	s5, 32(sp)                      # 8-byte Folded Spill
	ld	s5, 16(sp)                      # 8-byte Folded Reload
	add	s5, s9, s5
	add	s4, s9, s4
	add	s3, s9, s3
	add	t0, s9, t0
	add	a7, s9, a7
	add	a6, s9, a6
	add	a5, s9, a5
	add	a4, s9, a4
	add	a2, s9, a2
	add	a1, s9, a1
	add	a0, s9, a0
	ld	s9, 56(sp)                      # 8-byte Folded Reload
	sd	s9, 0(a3)
	ld	s9, 64(sp)                      # 8-byte Folded Reload
	sd	s9, 8(a3)
	ld	s9, 72(sp)                      # 8-byte Folded Reload
	sd	s9, 16(a3)
	ld	s9, 80(sp)                      # 8-byte Folded Reload
	sd	s9, 24(a3)
	ld	s9, 88(sp)                      # 8-byte Folded Reload
	sd	s9, 32(a3)
	ld	s9, 96(sp)                      # 8-byte Folded Reload
	sd	s9, 40(a3)
	ld	s9, 104(sp)                     # 8-byte Folded Reload
	sd	s9, 48(a3)
	ld	s9, 112(sp)                     # 8-byte Folded Reload
	sd	s9, 56(a3)
	ld	s9, 120(sp)                     # 8-byte Folded Reload
	sd	s9, 64(a3)
	ld	s9, 128(sp)                     # 8-byte Folded Reload
	sd	s9, 72(a3)
	ld	s9, 136(sp)                     # 8-byte Folded Reload
	sd	s9, 80(a3)
	ld	s9, 144(sp)                     # 8-byte Folded Reload
	sd	s9, 88(a3)
	ld	s9, 168(sp)                     # 8-byte Folded Reload
	sd	s9, 128(a3)
	ld	s9, 152(sp)                     # 8-byte Folded Reload
	sd	s9, 144(a3)
	ld	s9, 160(sp)                     # 8-byte Folded Reload
	sd	s9, 152(a3)
	ld	s9, 176(sp)                     # 8-byte Folded Reload
	sw	s9, 168(a3)
	vs1r.v	v0, (t1)
	vs1r.v	v1, (t3)
	vs1r.v	v2, (t4)
	vs1r.v	v3, (t5)
	vs1r.v	v4, (t6)
	vs1r.v	v5, (s1)
	vs1r.v	v6, (s2)
	ld	t1, 184(sp)                     # 8-byte Folded Reload
	sd	t1, 96(a3)
	ld	t1, 192(sp)                     # 8-byte Folded Reload
	sd	t1, 104(a3)
	ld	t1, 200(sp)                     # 8-byte Folded Reload
	sd	t1, 112(a3)
	sd	gp, 120(a3)
	ld	t1, 8(sp)                       # 8-byte Folded Reload
	vs1r.v	v7, (t1)
	vs1r.v	v8, (s6)
	vs1r.v	v9, (s7)
	vs1r.v	v10, (s8)
	vs1r.v	v11, (s10)
	vs1r.v	v12, (s11)
	vs1r.v	v13, (ra)
	ld	t1, 48(sp)                      # 8-byte Folded Reload
	vs1r.v	v14, (t1)
	ld	t1, 40(sp)                      # 8-byte Folded Reload
	vs1r.v	v15, (t1)
	ld	t1, 32(sp)                      # 8-byte Folded Reload
	vs1r.v	v16, (t1)
	vs1r.v	v17, (s5)
	vs1r.v	v18, (s4)
	vs1r.v	v19, (s3)
	vs1r.v	v20, (t0)
	vs1r.v	v21, (a7)
	vs1r.v	v22, (a6)
	vs1r.v	v23, (a5)
	vs1r.v	v24, (a4)
	vs1r.v	v25, (a2)
	vs1r.v	v26, (a1)
	vs1r.v	v27, (a0)
	#APP
	mv	t2, a3
	#NO_APP
	ld	a0, 208(sp)                     # 8-byte Folded Reload
	ld	a1, 216(sp)                     # 8-byte Folded Reload
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
