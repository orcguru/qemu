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
	lui	a4, %hi(Fx0_1)
	addi	a4, a4, %lo(Fx0_1)
	addi	a2, a1, -800
	addi	a3, a1, 384
	add	a1, s9, a2
	add	a2, s9, a3
	li	a3, 66
	tail	trampoline_helper_rdrand
.Lfunc_end0:
	.size	Fx0, .Lfunc_end0-Fx0
                                        # -- End function
	.option	pop
	.option	push
	.option	arch, +a, +d, +f, +m, +v, +zaamo, +zalrsc, +zicsr, +zmmul, +zve32f, +zve32x, +zve64d, +zve64f, +zve64x, +zvl128b, +zvl32b, +zvl64b
	.section	.text.trampoline_helper_rdrand,"ax",@progbits
	.globl	trampoline_helper_rdrand        # -- Begin function trampoline_helper_rdrand
	.p2align	2
	.type	trampoline_helper_rdrand,@function
	.variant_cc	trampoline_helper_rdrand
trampoline_helper_rdrand:               # @trampoline_helper_rdrand
# %bb.0:                                # %entry
	sd	a4, 208(sp)                     # 8-byte Folded Spill
	sd	a3, 200(sp)                     # 8-byte Folded Spill
	sd	a2, 192(sp)                     # 8-byte Folded Spill
	sd	a1, 184(sp)                     # 8-byte Folded Spill
	sd	s9, 216(sp)                     # 8-byte Folded Spill
	sd	a0, 176(sp)                     # 8-byte Folded Spill
	mv	ra, t6
	mv	a2, s1
	mv	a3, s11
	mv	t6, s7
	mv	s1, s6
	mv	t3, s4
	lui	a4, 3
	addi	a0, a4, -800
	add	s9, s9, a0
	sd	a6, 0(s9)
	li	a0, 25
	sd	a7, 8(s9)
	addi	s7, a4, 64
	sd	s2, 16(s9)
	addi	s11, a4, 80
	sd	s3, 24(s9)
	addi	s4, a4, 128
	sd	t3, 32(s9)
	addi	a6, a4, 144
	sd	a6, 168(sp)                     # 8-byte Folded Spill
	sd	s5, 40(s9)
	addi	s6, a4, 192
	sd	s1, 48(s9)
	addi	s5, a4, 208
	sd	t6, 56(s9)
	addi	s3, a4, 256
	sd	s8, 64(s9)
	addi	s1, a4, 272
	sd	s10, 72(s9)
	addi	a1, a4, 320
	sd	a1, 160(sp)                     # 8-byte Folded Spill
	sd	a3, 80(s9)
	addi	t6, a4, 336
	sd	a2, 88(s9)
	addi	a1, a4, 384
	sd	a1, 152(sp)                     # 8-byte Folded Spill
	sd	t4, 96(s9)
	addi	a1, a4, 400
	sd	a1, 144(sp)                     # 8-byte Folded Spill
	sd	t5, 104(s9)
	addi	a1, a4, 448
	sd	a1, 136(sp)                     # 8-byte Folded Spill
	sd	ra, 112(s9)
	addi	a1, a4, 464
	sd	a1, 128(sp)                     # 8-byte Folded Spill
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
	add	s8, s2, s7
	sd	s8, 32(sp)                      # 8-byte Folded Spill
	add	s11, s2, s11
	add	s7, s2, s4
	sd	s7, 40(sp)                      # 8-byte Folded Spill
	ld	s4, 168(sp)                     # 8-byte Folded Reload
	add	s10, s2, s4
	add	s6, s2, s6
	sd	s6, 16(sp)                      # 8-byte Folded Spill
	add	s5, s2, s5
	sd	s5, 0(sp)                       # 8-byte Folded Spill
	add	s3, s2, s3
	sd	s3, 8(sp)                       # 8-byte Folded Spill
	add	s4, s2, s1
	ld	s5, 160(sp)                     # 8-byte Folded Reload
	add	s5, s2, s5
	add	s6, s2, t6
	ld	t6, 152(sp)                     # 8-byte Folded Reload
	add	t6, s2, t6
	sd	t6, 56(sp)                      # 8-byte Folded Spill
	ld	s1, 144(sp)                     # 8-byte Folded Reload
	add	s1, s2, s1
	sd	s1, 72(sp)                      # 8-byte Folded Spill
	ld	s3, 136(sp)                     # 8-byte Folded Reload
	add	s3, s2, s3
	sd	s3, 24(sp)                      # 8-byte Folded Spill
	ld	s3, 128(sp)                     # 8-byte Folded Reload
	add	s3, s2, s3
	sd	s3, 64(sp)                      # 8-byte Folded Spill
	add	ra, s2, ra
	sd	ra, 48(sp)                      # 8-byte Folded Spill
	add	t5, s2, t5
	sd	t5, 96(sp)                      # 8-byte Folded Spill
	add	t4, s2, t4
	sd	t4, 88(sp)                      # 8-byte Folded Spill
	add	t3, s2, t3
	sd	t3, 80(sp)                      # 8-byte Folded Spill
	add	t1, s2, t1
	sd	t1, 120(sp)                     # 8-byte Folded Spill
	add	t0, s2, t0
	sd	t0, 112(sp)                     # 8-byte Folded Spill
	add	a7, s2, a7
	sd	a7, 104(sp)                     # 8-byte Folded Spill
	add	a6, s2, a6
	sd	a6, 176(sp)                     # 8-byte Folded Spill
	add	a5, s2, a5
	sd	a5, 168(sp)                     # 8-byte Folded Spill
	add	a3, s2, a3
	sd	a3, 160(sp)                     # 8-byte Folded Spill
	add	a2, s2, a2
	sd	a2, 152(sp)                     # 8-byte Folded Spill
	add	a1, s2, a1
	sd	a1, 144(sp)                     # 8-byte Folded Spill
	add	a0, s2, a0
	sd	a0, 136(sp)                     # 8-byte Folded Spill
	add	a4, s2, a4
	sd	a4, 128(sp)                     # 8-byte Folded Spill
	sd	gp, 120(s9)
	vs1r.v	v0, (s8)
	vs1r.v	v1, (s11)
	vs1r.v	v2, (s7)
	vs1r.v	v3, (s10)
	ld	s2, 16(sp)                      # 8-byte Folded Reload
	vs1r.v	v4, (s2)
	ld	s7, 0(sp)                       # 8-byte Folded Reload
	vs1r.v	v5, (s7)
	ld	s8, 8(sp)                       # 8-byte Folded Reload
	vs1r.v	v6, (s8)
	vs1r.v	v7, (s4)
	vs1r.v	v8, (s5)
	vs1r.v	v9, (s6)
	vs1r.v	v10, (t6)
	vs1r.v	v11, (s1)
	ld	s1, 24(sp)                      # 8-byte Folded Reload
	vs1r.v	v12, (s1)
	vs1r.v	v13, (s3)
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
	call	helper_rdrand
	addi	sp, sp, 16
	ld	t2, -8(sp)
	sd	sp, -56(t2)
	ld	sp, -64(t2)
	ld	a1, 32(sp)                      # 8-byte Folded Reload
	vl1re64.v	v0, (a1)
	vl1re64.v	v1, (s11)
	ld	a1, 40(sp)                      # 8-byte Folded Reload
	vl1re64.v	v2, (a1)
	vl1re64.v	v3, (s10)
	vl1re64.v	v4, (s2)
	vl1re64.v	v5, (s7)
	vl1re64.v	v6, (s8)
	vl1re64.v	v7, (s4)
	vl1re64.v	v8, (s5)
	vl1re64.v	v9, (s6)
	ld	a6, 0(s9)
	ld	a7, 8(s9)
	ld	s2, 16(s9)
	ld	s3, 24(s9)
	ld	a1, 56(sp)                      # 8-byte Folded Reload
	vl1re64.v	v10, (a1)
	ld	a1, 72(sp)                      # 8-byte Folded Reload
	vl1re64.v	v11, (a1)
	vl1re64.v	v12, (s1)
	ld	a1, 64(sp)                      # 8-byte Folded Reload
	vl1re64.v	v13, (a1)
	ld	s4, 32(s9)
	ld	s5, 40(s9)
	ld	s6, 48(s9)
	ld	s7, 56(s9)
	ld	a1, 48(sp)                      # 8-byte Folded Reload
	vl1re64.v	v14, (a1)
	ld	a1, 96(sp)                      # 8-byte Folded Reload
	vl1re64.v	v15, (a1)
	ld	a1, 88(sp)                      # 8-byte Folded Reload
	vl1re64.v	v16, (a1)
	ld	a1, 80(sp)                      # 8-byte Folded Reload
	vl1re64.v	v17, (a1)
	ld	s8, 64(s9)
	ld	s10, 72(s9)
	ld	s11, 80(s9)
	ld	s1, 88(s9)
	ld	a1, 120(sp)                     # 8-byte Folded Reload
	vl1re64.v	v18, (a1)
	ld	a1, 112(sp)                     # 8-byte Folded Reload
	vl1re64.v	v19, (a1)
	ld	a1, 104(sp)                     # 8-byte Folded Reload
	vl1re64.v	v20, (a1)
	ld	t4, 96(s9)
	ld	t5, 104(s9)
	ld	t6, 112(s9)
	ld	gp, 120(s9)
	ld	a1, 176(sp)                     # 8-byte Folded Reload
	vl1re64.v	v21, (a1)
	ld	a1, 168(sp)                     # 8-byte Folded Reload
	vl1re64.v	v22, (a1)
	ld	a1, 160(sp)                     # 8-byte Folded Reload
	vl1re64.v	v23, (a1)
	ld	a1, 152(sp)                     # 8-byte Folded Reload
	vl1re64.v	v24, (a1)
	ld	a1, 144(sp)                     # 8-byte Folded Reload
	vl1re64.v	v25, (a1)
	ld	a1, 136(sp)                     # 8-byte Folded Reload
	vl1re64.v	v26, (a1)
	ld	a1, 128(sp)                     # 8-byte Folded Reload
	vl1re64.v	v27, (a1)
	ld	a1, 128(s9)
	ld	t0, 144(s9)
	ld	a5, 152(s9)
	lw	t1, 168(s9)
	mv	a2, a0
	mv	a0, a1
	ld	s9, 216(sp)                     # 8-byte Folded Reload
	mv	a1, a2
	ld	a2, 208(sp)                     # 8-byte Folded Reload
	jr	a2
.Lfunc_end1:
	.size	trampoline_helper_rdrand, .Lfunc_end1-trampoline_helper_rdrand
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
