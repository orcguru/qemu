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
	mv	a2, a0
	mv	a3, gp
	lui	a0, 3
	addi	a0, a0, -800
	add	a4, s9, a0
	beqz	s2, .LBB0_3
# %bb.1:                                # %bb_false
	#APP
	mv	t2, a4
	#NO_APP
	mv	a0, a6
	mv	a1, a7
	sd	a2, 96(sp)                      # 8-byte Folded Spill
	mv	a2, s2
	sd	a3, 104(sp)                     # 8-byte Folded Spill
	li	a3, 0
	addi	t3, sp, 544
	vs1r.v	v27, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 528
	vs1r.v	v26, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 512
	vs1r.v	v25, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 496
	vs1r.v	v24, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 480
	vs1r.v	v23, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 464
	vs1r.v	v22, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 448
	vs1r.v	v21, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 432
	vs1r.v	v20, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 416
	vs1r.v	v19, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 400
	vs1r.v	v18, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 384
	vs1r.v	v17, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 368
	vs1r.v	v16, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 352
	vs1r.v	v15, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 336
	vs1r.v	v14, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 320
	vs1r.v	v13, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 304
	vs1r.v	v12, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 288
	vs1r.v	v11, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 272
	vs1r.v	v10, (t3)                       # vscale x 8-byte Folded Spill
	addi	t3, sp, 256
	vs1r.v	v9, (t3)                        # vscale x 8-byte Folded Spill
	addi	t3, sp, 240
	vs1r.v	v8, (t3)                        # vscale x 8-byte Folded Spill
	addi	t3, sp, 224
	vs1r.v	v7, (t3)                        # vscale x 8-byte Folded Spill
	addi	t3, sp, 208
	vs1r.v	v6, (t3)                        # vscale x 8-byte Folded Spill
	addi	t3, sp, 192
	vs1r.v	v5, (t3)                        # vscale x 8-byte Folded Spill
	addi	t3, sp, 176
	vs1r.v	v4, (t3)                        # vscale x 8-byte Folded Spill
	addi	t3, sp, 160
	vs1r.v	v3, (t3)                        # vscale x 8-byte Folded Spill
	addi	t3, sp, 144
	vs1r.v	v2, (t3)                        # vscale x 8-byte Folded Spill
	addi	t3, sp, 128
	vs1r.v	v1, (t3)                        # vscale x 8-byte Folded Spill
	addi	t3, sp, 112
	vs1r.v	v0, (t3)                        # vscale x 8-byte Folded Spill
	sd	s11, 88(sp)                     # 8-byte Folded Spill
	sd	s1, 80(sp)                      # 8-byte Folded Spill
	mv	s1, s9
	mv	s9, a7
	sd	s10, 72(sp)                     # 8-byte Folded Spill
	mv	s10, t1
	sd	s8, 64(sp)                      # 8-byte Folded Spill
	mv	s8, t0
	sd	s7, 56(sp)                      # 8-byte Folded Spill
	mv	s7, a5
	sd	s5, 48(sp)                      # 8-byte Folded Spill
	mv	s5, t6
	sd	s4, 40(sp)                      # 8-byte Folded Spill
	mv	s4, a4
	sd	s2, 32(sp)                      # 8-byte Folded Spill
	sd	s3, 24(sp)                      # 8-byte Folded Spill
	mv	s3, t5
	mv	s11, s6
	mv	s6, t4
	mv	s2, a6
	sd	sp, -64(t2)
	ld	sp, -56(t2)
	ld	tp, -80(t2)
	sd	t2, -8(sp)
	addi	sp, sp, -16
	call	__udivti3
	addi	sp, sp, 16
	ld	t2, -8(sp)
	sd	sp, -56(t2)
	ld	sp, -64(t2)
	mv	a6, s2
	mv	t4, s6
	mv	s6, s11
	mv	t5, s3
	ld	s3, 24(sp)                      # 8-byte Folded Reload
	ld	s2, 32(sp)                      # 8-byte Folded Reload
	mv	a4, s4
	ld	s4, 40(sp)                      # 8-byte Folded Reload
	mv	t6, s5
	ld	s5, 48(sp)                      # 8-byte Folded Reload
	ld	a3, 104(sp)                     # 8-byte Folded Reload
	mv	a5, s7
	ld	s7, 56(sp)                      # 8-byte Folded Reload
	mv	t0, s8
	ld	s8, 64(sp)                      # 8-byte Folded Reload
	mv	t1, s10
	ld	s10, 72(sp)                     # 8-byte Folded Reload
	ld	a2, 96(sp)                      # 8-byte Folded Reload
	mv	a7, s9
	mv	s9, s1
	ld	s1, 80(sp)                      # 8-byte Folded Reload
	ld	s11, 88(sp)                     # 8-byte Folded Reload
	addi	t3, sp, 112
	vl1r.v	v0, (t3)                        # vscale x 8-byte Folded Reload
	addi	t3, sp, 128
	vl1r.v	v1, (t3)                        # vscale x 8-byte Folded Reload
	addi	t3, sp, 144
	vl1r.v	v2, (t3)                        # vscale x 8-byte Folded Reload
	addi	t3, sp, 160
	vl1r.v	v3, (t3)                        # vscale x 8-byte Folded Reload
	addi	t3, sp, 176
	vl1r.v	v4, (t3)                        # vscale x 8-byte Folded Reload
	addi	t3, sp, 192
	vl1r.v	v5, (t3)                        # vscale x 8-byte Folded Reload
	addi	t3, sp, 208
	vl1r.v	v6, (t3)                        # vscale x 8-byte Folded Reload
	addi	t3, sp, 224
	vl1r.v	v7, (t3)                        # vscale x 8-byte Folded Reload
	addi	t3, sp, 240
	vl1r.v	v8, (t3)                        # vscale x 8-byte Folded Reload
	addi	t3, sp, 256
	vl1r.v	v9, (t3)                        # vscale x 8-byte Folded Reload
	addi	t3, sp, 272
	vl1r.v	v10, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 288
	vl1r.v	v11, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 304
	vl1r.v	v12, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 320
	vl1r.v	v13, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 336
	vl1r.v	v14, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 352
	vl1r.v	v15, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 368
	vl1r.v	v16, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 384
	vl1r.v	v17, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 400
	vl1r.v	v18, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 416
	vl1r.v	v19, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 432
	vl1r.v	v20, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 448
	vl1r.v	v21, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 464
	vl1r.v	v22, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 480
	vl1r.v	v23, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 496
	vl1r.v	v24, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 512
	vl1r.v	v25, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 528
	vl1r.v	v26, (t3)                       # vscale x 8-byte Folded Reload
	addi	t3, sp, 544
	vl1r.v	v27, (t3)                       # vscale x 8-byte Folded Reload
	bnez	a1, .LBB0_3
# %bb.2:                                # %divs2.done
	mul	a1, a0, s2
	sub	s2, a6, a1
	mv	a6, a0
	mv	gp, a3
	mv	a0, a2
	tail	Fx55aa
.LBB0_3:                                # %bb_L0
	mv	gp, a3
	mv	a0, a2
	mv	a1, a4
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
