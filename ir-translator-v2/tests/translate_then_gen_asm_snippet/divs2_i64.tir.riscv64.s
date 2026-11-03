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
	mv	a3, a0
	mv	a4, gp
	lui	a0, 3
	addi	a0, a0, -800
	add	t3, s9, a0
	beqz	s2, .LBB0_6
# %bb.1:                                # %bb_false
	li	a0, -1
	bne	s2, a0, .LBB0_4
# %bb.2:                                # %bb_false
	bnez	a6, .LBB0_4
# %bb.3:                                # %bb_false
	li	a0, -1
	slli	a0, a0, 63
	beq	a7, a0, .LBB0_6
.LBB0_4:                                # %bb_false1
	sd	a3, 104(sp)                     # 8-byte Folded Spill
	srai	a3, s2, 63
	#APP
	mv	t2, t3
	#NO_APP
	mv	a0, a6
	mv	a1, a7
	mv	a2, s2
	sd	a4, 8(sp)                       # 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 27
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v27, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 26
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v26, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 25
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v25, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 24
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v24, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 23
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v23, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 22
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v22, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 21
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v21, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 20
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v20, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 19
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v19, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 18
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v18, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	slli	ra, a4, 4
	add	a4, ra, a4
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v17, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	slli	a4, a4, 4
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v16, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	slli	ra, a4, 4
	sub	a4, ra, a4
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v15, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 14
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v14, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 13
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v13, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 12
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v12, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 11
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v11, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 10
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v10, (a4)                       # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	slli	ra, a4, 3
	add	a4, ra, a4
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v9, (a4)                        # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	slli	a4, a4, 3
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v8, (a4)                        # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	slli	ra, a4, 3
	sub	a4, ra, a4
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v7, (a4)                        # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	li	ra, 6
	mul	a4, a4, ra
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v6, (a4)                        # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	slli	ra, a4, 2
	add	a4, ra, a4
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v5, (a4)                        # vscale x 8-byte Folded Spill
	csrr	a4, vlenb
	slli	a4, a4, 2
	add	a4, sp, a4
	addi	a4, a4, 112
	vs1r.v	v4, (a4)                        # vscale x 8-byte Folded Spill
	csrr	ra, vlenb
	slli	a4, ra, 1
	add	ra, a4, ra
	ld	a4, 8(sp)                       # 8-byte Folded Reload
	add	ra, sp, ra
	addi	ra, ra, 112
	vs1r.v	v3, (ra)                        # vscale x 8-byte Folded Spill
	csrr	ra, vlenb
	slli	ra, ra, 1
	add	ra, sp, ra
	addi	ra, ra, 112
	vs1r.v	v2, (ra)                        # vscale x 8-byte Folded Spill
	csrr	ra, vlenb
	add	ra, sp, ra
	addi	ra, ra, 112
	vs1r.v	v1, (ra)                        # vscale x 8-byte Folded Spill
	addi	ra, sp, 112
	vs1r.v	v0, (ra)                        # vscale x 8-byte Folded Spill
	sd	s1, 96(sp)                      # 8-byte Folded Spill
	sd	s9, 24(sp)                      # 8-byte Folded Spill
	mv	s9, a7
	sd	s11, 88(sp)                     # 8-byte Folded Spill
	mv	s11, t1
	sd	s10, 80(sp)                     # 8-byte Folded Spill
	mv	s10, t0
	sd	s8, 72(sp)                      # 8-byte Folded Spill
	mv	s8, a5
	sd	s7, 64(sp)                      # 8-byte Folded Spill
	mv	s7, a4
	sd	s6, 56(sp)                      # 8-byte Folded Spill
	mv	s6, t6
	sd	s5, 48(sp)                      # 8-byte Folded Spill
	mv	s5, t3
	sd	s4, 40(sp)                      # 8-byte Folded Spill
	mv	s4, t5
	sd	s3, 32(sp)                      # 8-byte Folded Spill
	mv	s3, t4
	mv	s1, a6
	sd	sp, -64(t2)
	ld	sp, -56(t2)
	ld	tp, -80(t2)
	sd	t2, -8(sp)
	addi	sp, sp, -16
	call	__divti3
	addi	sp, sp, 16
	ld	t2, -8(sp)
	sd	sp, -56(t2)
	ld	sp, -64(t2)
	mv	a6, s1
	mv	t4, s3
	ld	s3, 32(sp)                      # 8-byte Folded Reload
	mv	t5, s4
	ld	s4, 40(sp)                      # 8-byte Folded Reload
	mv	t3, s5
	ld	s5, 48(sp)                      # 8-byte Folded Reload
	mv	t6, s6
	ld	s6, 56(sp)                      # 8-byte Folded Reload
	mv	a4, s7
	ld	s7, 64(sp)                      # 8-byte Folded Reload
	mv	a5, s8
	ld	s8, 72(sp)                      # 8-byte Folded Reload
	mv	t0, s10
	ld	s10, 80(sp)                     # 8-byte Folded Reload
	mv	t1, s11
	ld	s11, 88(sp)                     # 8-byte Folded Reload
	ld	a3, 104(sp)                     # 8-byte Folded Reload
	mv	a7, s9
	ld	s9, 24(sp)                      # 8-byte Folded Reload
	ld	s1, 96(sp)                      # 8-byte Folded Reload
	addi	a2, sp, 112
	vl1r.v	v0, (a2)                        # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v1, (a2)                        # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	slli	a2, a2, 1
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v2, (a2)                        # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	slli	ra, a2, 1
	add	a2, ra, a2
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v3, (a2)                        # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	slli	a2, a2, 2
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v4, (a2)                        # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	slli	ra, a2, 2
	add	a2, ra, a2
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v5, (a2)                        # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 6
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v6, (a2)                        # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	slli	ra, a2, 3
	sub	a2, ra, a2
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v7, (a2)                        # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	slli	a2, a2, 3
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v8, (a2)                        # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	slli	ra, a2, 3
	add	a2, ra, a2
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v9, (a2)                        # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 10
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v10, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 11
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v11, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 12
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v12, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 13
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v13, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 14
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v14, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	slli	ra, a2, 4
	sub	a2, ra, a2
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v15, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	slli	a2, a2, 4
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v16, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	slli	ra, a2, 4
	add	a2, ra, a2
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v17, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 18
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v18, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 19
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v19, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 20
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v20, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 21
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v21, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 22
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v22, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 23
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v23, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 24
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v24, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 25
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v25, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 26
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v26, (a2)                       # vscale x 8-byte Folded Reload
	csrr	a2, vlenb
	li	ra, 27
	mul	a2, a2, ra
	add	a2, sp, a2
	addi	a2, a2, 112
	vl1r.v	v27, (a2)                       # vscale x 8-byte Folded Reload
	srai	a2, a0, 63
	bne	a1, a2, .LBB0_6
# %bb.5:                                # %divs2.done
	mul	a1, a0, s2
	sub	s2, a6, a1
	mv	a6, a0
	mv	gp, a4
	mv	a0, a3
	tail	Fx55aa
.LBB0_6:                                # %bb_L0
	mv	gp, a4
	mv	a0, a3
	mv	a1, t3
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
