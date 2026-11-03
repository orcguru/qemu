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
	addi	a2, a1, -800
	add	a1, s9, a1
	ld	a3, -808(a1)
	add	a1, s9, a2
	addi	a2, s5, -320
	lui	a4, %hi(Fx0_1)
	addi	a4, a4, %lo(Fx0_1)
	sd	a2, -16(a3)
	li	a3, 0
	tail	trampoline_helper_fsave
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.option	push
	.option	arch, +a, +d, +f, +m, +v, +zaamo, +zalrsc, +zicsr, +zmmul, +zve32f, +zve32x, +zve64d, +zve64f, +zve64x, +zvl128b, +zvl32b, +zvl64b
	.section	.text.trampoline_helper_fsave,"ax",@progbits
	.globl	trampoline_helper_fsave         # -- Begin function trampoline_helper_fsave
	.p2align	2
	.type	trampoline_helper_fsave,@function
	.variant_cc	trampoline_helper_fsave
trampoline_helper_fsave:                # @trampoline_helper_fsave
# %bb.0:                                # %entry
	sd	a4, 208(sp)                     # 8-byte Folded Spill
	sd	a3, 200(sp)                     # 8-byte Folded Spill
	sd	a2, 192(sp)                     # 8-byte Folded Spill
	sd	a1, 184(sp)                     # 8-byte Folded Spill
	sd	s9, 216(sp)                     # 8-byte Folded Spill
	sd	a0, 176(sp)                     # 8-byte Folded Spill
	mv	ra, s1
	mv	a3, s11
	mv	a2, s10
	mv	s1, s6
	lui	a4, 3
	addi	a0, a4, -800
	add	s9, s9, a0
	sd	a6, 0(s9)
	li	a0, 25
	sd	a7, 8(s9)
	addi	s10, a4, 64
	sd	s2, 16(s9)
	addi	s11, a4, 80
	sd	s3, 24(s9)
	addi	s6, a4, 128
	sd	s4, 32(s9)
	addi	a6, a4, 144
	sd	a6, 168(sp)                     # 8-byte Folded Spill
	sd	s5, 40(s9)
	addi	s5, a4, 192
	sd	s1, 48(s9)
	addi	s4, a4, 208
	sd	s7, 56(s9)
	addi	s3, a4, 256
	sd	s8, 64(s9)
	addi	s1, a4, 272
	sd	a2, 72(s9)
	addi	s7, a4, 320
	sd	a3, 80(s9)
	addi	a1, a4, 336
	sd	a1, 160(sp)                     # 8-byte Folded Spill
	sd	ra, 88(s9)
	addi	a1, a4, 384
	sd	a1, 152(sp)                     # 8-byte Folded Spill
	sd	t4, 96(s9)
	addi	a1, a4, 400
	sd	a1, 144(sp)                     # 8-byte Folded Spill
	sd	t5, 104(s9)
	addi	a1, a4, 448
	sd	a1, 136(sp)                     # 8-byte Folded Spill
	sd	t6, 112(s9)
	addi	t6, a4, 464
	slli	ra, a0, 9
	ld	a0, 176(sp)                     # 8-byte Folded Reload
	sd	a0, 128(s9)
	addi	t5, a4, 528
	sd	t0, 144(s9)
	addi	t4, a4, 576
	sd	a5, 152(s9)
	addi	t3, a4, 592
	sw	t1, 168(s9)
	addi	t1, a4, 640
	addi	t0, a4, 656
	addi	a7, a4, 704
	addi	a6, a4, 720
	addi	a5, a4, 768
	addi	a3, a4, 784
	addi	a2, a4, 832
	addi	a1, a4, 848
	addi	a0, a4, 896
	addi	a4, a4, 912
	ld	s2, 216(sp)                     # 8-byte Folded Reload
	add	s10, s2, s10
	sd	s10, 40(sp)                     # 8-byte Folded Spill
	add	s11, s2, s11
	add	s8, s2, s6
	sd	s8, 32(sp)                      # 8-byte Folded Spill
	ld	s6, 168(sp)                     # 8-byte Folded Reload
	add	s6, s2, s6
	sd	s6, 16(sp)                      # 8-byte Folded Spill
	add	s5, s2, s5
	sd	s5, 0(sp)                       # 8-byte Folded Spill
	add	s4, s2, s4
	sd	s4, 8(sp)                       # 8-byte Folded Spill
	add	s5, s2, s3
	add	s6, s2, s1
	add	s7, s2, s7
	ld	s1, 160(sp)                     # 8-byte Folded Reload
	add	s1, s2, s1
	sd	s1, 56(sp)                      # 8-byte Folded Spill
	ld	s3, 152(sp)                     # 8-byte Folded Reload
	add	s3, s2, s3
	sd	s3, 24(sp)                      # 8-byte Folded Spill
	ld	s3, 144(sp)                     # 8-byte Folded Reload
	add	s3, s2, s3
	sd	s3, 48(sp)                      # 8-byte Folded Spill
	ld	s4, 136(sp)                     # 8-byte Folded Reload
	add	s4, s2, s4
	add	t6, s2, t6
	sd	t6, 64(sp)                      # 8-byte Folded Spill
	add	ra, s2, ra
	sd	ra, 72(sp)                      # 8-byte Folded Spill
	add	t5, s2, t5
	sd	t5, 88(sp)                      # 8-byte Folded Spill
	add	t4, s2, t4
	sd	t4, 80(sp)                      # 8-byte Folded Spill
	add	t3, s2, t3
	sd	t3, 112(sp)                     # 8-byte Folded Spill
	add	t1, s2, t1
	sd	t1, 104(sp)                     # 8-byte Folded Spill
	add	t0, s2, t0
	sd	t0, 96(sp)                      # 8-byte Folded Spill
	add	a7, s2, a7
	sd	a7, 176(sp)                     # 8-byte Folded Spill
	add	a6, s2, a6
	sd	a6, 168(sp)                     # 8-byte Folded Spill
	add	a5, s2, a5
	sd	a5, 160(sp)                     # 8-byte Folded Spill
	add	a3, s2, a3
	sd	a3, 152(sp)                     # 8-byte Folded Spill
	add	a2, s2, a2
	sd	a2, 144(sp)                     # 8-byte Folded Spill
	add	a1, s2, a1
	sd	a1, 136(sp)                     # 8-byte Folded Spill
	add	a0, s2, a0
	sd	a0, 128(sp)                     # 8-byte Folded Spill
	add	a4, s2, a4
	sd	a4, 120(sp)                     # 8-byte Folded Spill
	sd	gp, 120(s9)
	vs1r.v	v0, (s10)
	vs1r.v	v1, (s11)
	vs1r.v	v2, (s8)
	ld	s2, 16(sp)                      # 8-byte Folded Reload
	vs1r.v	v3, (s2)
	ld	s8, 0(sp)                       # 8-byte Folded Reload
	vs1r.v	v4, (s8)
	ld	s10, 8(sp)                      # 8-byte Folded Reload
	vs1r.v	v5, (s10)
	vs1r.v	v6, (s5)
	vs1r.v	v7, (s6)
	vs1r.v	v8, (s7)
	vs1r.v	v9, (s1)
	ld	s1, 24(sp)                      # 8-byte Folded Reload
	vs1r.v	v10, (s1)
	vs1r.v	v11, (s3)
	vs1r.v	v12, (s4)
	vs1r.v	v13, (t6)
	vs1r.v	v14, (ra)
	vs1r.v	v15, (t5)
	vs1r.v	v16, (t4)
	vs1r.v	v17, (t3)
	vs1r.v	v18, (t1)
	vs1r.v	v19, (t0)
	vs1r.v	v20, (a7)
	vs1r.v	v21, (a6)
	vs1r.v	v22, (a5)
	vs1r.v	v23, (a3)
	vs1r.v	v24, (a2)
	vs1r.v	v25, (a1)
	vs1r.v	v26, (a0)
	vs1r.v	v27, (a4)
	#APP
	mv	t2, s9
	#NO_APP
	ld	a0, 184(sp)                     # 8-byte Folded Reload
	ld	a1, 192(sp)                     # 8-byte Folded Reload
	ld	a2, 200(sp)                     # 8-byte Folded Reload
	sd	sp, -64(t2)
	ld	sp, -56(t2)
	ld	tp, -80(t2)
	sd	t2, -8(sp)
	addi	sp, sp, -16
	call	helper_fsave
	addi	sp, sp, 16
	ld	t2, -8(sp)
	sd	sp, -56(t2)
	ld	sp, -64(t2)
	ld	a0, 40(sp)                      # 8-byte Folded Reload
	vl1re64.v	v0, (a0)
	vl1re64.v	v1, (s11)
	ld	a0, 32(sp)                      # 8-byte Folded Reload
	vl1re64.v	v2, (a0)
	vl1re64.v	v3, (s2)
	vl1re64.v	v4, (s8)
	vl1re64.v	v5, (s10)
	vl1re64.v	v6, (s5)
	vl1re64.v	v7, (s6)
	vl1re64.v	v8, (s7)
	ld	a6, 0(s9)
	ld	a7, 8(s9)
	ld	s2, 16(s9)
	ld	s3, 24(s9)
	ld	a0, 56(sp)                      # 8-byte Folded Reload
	vl1re64.v	v9, (a0)
	vl1re64.v	v10, (s1)
	ld	a0, 48(sp)                      # 8-byte Folded Reload
	vl1re64.v	v11, (a0)
	vl1re64.v	v12, (s4)
	ld	s4, 32(s9)
	ld	s5, 40(s9)
	ld	s6, 48(s9)
	ld	s7, 56(s9)
	ld	a0, 64(sp)                      # 8-byte Folded Reload
	vl1re64.v	v13, (a0)
	ld	a0, 72(sp)                      # 8-byte Folded Reload
	vl1re64.v	v14, (a0)
	ld	a0, 88(sp)                      # 8-byte Folded Reload
	vl1re64.v	v15, (a0)
	ld	a0, 80(sp)                      # 8-byte Folded Reload
	vl1re64.v	v16, (a0)
	ld	s8, 64(s9)
	ld	s10, 72(s9)
	ld	s11, 80(s9)
	ld	s1, 88(s9)
	ld	a0, 112(sp)                     # 8-byte Folded Reload
	vl1re64.v	v17, (a0)
	ld	a0, 104(sp)                     # 8-byte Folded Reload
	vl1re64.v	v18, (a0)
	ld	a0, 96(sp)                      # 8-byte Folded Reload
	vl1re64.v	v19, (a0)
	ld	t4, 96(s9)
	ld	t5, 104(s9)
	ld	t6, 112(s9)
	ld	gp, 120(s9)
	ld	a0, 176(sp)                     # 8-byte Folded Reload
	vl1re64.v	v20, (a0)
	ld	a0, 168(sp)                     # 8-byte Folded Reload
	vl1re64.v	v21, (a0)
	ld	a0, 160(sp)                     # 8-byte Folded Reload
	vl1re64.v	v22, (a0)
	ld	a0, 152(sp)                     # 8-byte Folded Reload
	vl1re64.v	v23, (a0)
	ld	a0, 144(sp)                     # 8-byte Folded Reload
	vl1re64.v	v24, (a0)
	ld	a0, 136(sp)                     # 8-byte Folded Reload
	vl1re64.v	v25, (a0)
	ld	a0, 128(sp)                     # 8-byte Folded Reload
	vl1re64.v	v26, (a0)
	ld	a0, 120(sp)                     # 8-byte Folded Reload
	vl1re64.v	v27, (a0)
	ld	a0, 128(s9)
	ld	t0, 144(s9)
	ld	a5, 152(s9)
	lw	t1, 168(s9)
	ld	s9, 216(sp)                     # 8-byte Folded Reload
	ld	a1, 208(sp)                     # 8-byte Folded Reload
	jr	a1
.Lfunc_end1:
	.size	trampoline_helper_fsave, .Lfunc_end1-trampoline_helper_fsave
                                        # -- End function
	.option	pop
	.option	push
	.option	arch, +a, +d, +f, +m, +v, +zaamo, +zalrsc, +zicsr, +zmmul, +zve32f, +zve32x, +zve64d, +zve64f, +zve64x, +zvl128b, +zvl32b, +zvl64b
	.section	.text.Fx0_1,"ax",@progbits
	.globl	Fx0_1                           # -- Begin function Fx0_1
	.p2align	2
	.type	Fx0_1,@function
	.variant_cc	Fx0_1
Fx0_1:                                  # @Fx0_1
# %bb.0:                                # %entry
	tail	Fx55aa
.Lfunc_end2:
	.size	Fx0_1, .Lfunc_end2-Fx0_1
                                        # -- End function
	.option	pop
	.section	".note.GNU-stack","",@progbits
