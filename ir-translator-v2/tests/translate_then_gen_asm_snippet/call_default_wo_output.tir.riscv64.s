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
	sd	a4, 184(sp)                     # 8-byte Folded Spill
	sd	a3, 176(sp)                     # 8-byte Folded Spill
	sd	a2, 168(sp)                     # 8-byte Folded Spill
	sd	a1, 160(sp)                     # 8-byte Folded Spill
	mv	a2, s9
	mv	a1, s1
	lui	a4, 3
	addi	s9, a4, -800
	add	s9, a2, s9
	mv	s1, a2
	sd	a6, 0(s9)
	li	ra, 25
	sd	a7, 8(s9)
	addi	a2, a4, 64
	sd	a2, 144(sp)                     # 8-byte Folded Spill
	sd	s2, 16(s9)
	addi	s2, a4, 80
	sd	s3, 24(s9)
	addi	s3, a4, 128
	sd	s4, 32(s9)
	addi	a2, a4, 144
	sd	a2, 136(sp)                     # 8-byte Folded Spill
	sd	s5, 40(s9)
	addi	s5, a4, 192
	sd	s6, 48(s9)
	addi	a2, a4, 208
	sd	a2, 128(sp)                     # 8-byte Folded Spill
	sd	s7, 56(s9)
	addi	a2, a4, 256
	sd	a2, 120(sp)                     # 8-byte Folded Spill
	sd	s8, 64(s9)
	addi	a2, a4, 272
	sd	a2, 112(sp)                     # 8-byte Folded Spill
	sd	s10, 72(s9)
	addi	a2, a4, 320
	sd	a2, 104(sp)                     # 8-byte Folded Spill
	sd	s11, 80(s9)
	addi	s8, a4, 336
	sd	a1, 88(s9)
	addi	s6, a4, 384
	sd	t4, 96(s9)
	addi	t4, a4, 400
	sd	t5, 104(s9)
	addi	s10, a4, 448
	sd	t6, 112(s9)
	addi	t5, a4, 464
	slli	t6, ra, 9
	sd	a0, 128(s9)
	addi	t3, a4, 528
	sd	t0, 144(s9)
	addi	s11, a4, 576
	sd	a5, 152(s9)
	addi	a7, a4, 592
	sw	t1, 168(s9)
	addi	t0, a4, 640
	addi	t1, a4, 656
	addi	ra, a4, 704
	addi	a6, a4, 720
	addi	a5, a4, 768
	addi	a3, a4, 784
	addi	a2, a4, 832
	addi	a1, a4, 848
	addi	a0, a4, 896
	addi	a4, a4, 912
	sd	s1, 152(sp)                     # 8-byte Folded Spill
	ld	s4, 144(sp)                     # 8-byte Folded Reload
	add	s4, s1, s4
	add	s2, s1, s2
	sd	s2, 8(sp)                       # 8-byte Folded Spill
	add	s2, s1, s3
	ld	s3, 136(sp)                     # 8-byte Folded Reload
	add	s3, s1, s3
	sd	s3, 0(sp)                       # 8-byte Folded Spill
	add	s3, s1, s5
	ld	s5, 128(sp)                     # 8-byte Folded Reload
	add	s5, s1, s5
	sd	s5, 64(sp)                      # 8-byte Folded Spill
	ld	s5, 120(sp)                     # 8-byte Folded Reload
	add	s5, s1, s5
	ld	s7, 112(sp)                     # 8-byte Folded Reload
	add	s7, s1, s7
	sd	s7, 56(sp)                      # 8-byte Folded Spill
	ld	s7, 104(sp)                     # 8-byte Folded Reload
	add	s7, s1, s7
	add	s8, s1, s8
	sd	s8, 80(sp)                      # 8-byte Folded Spill
	add	s6, s1, s6
	add	t4, s1, t4
	sd	t4, 72(sp)                      # 8-byte Folded Spill
	add	s10, s1, s10
	add	t5, s1, t5
	sd	t5, 96(sp)                      # 8-byte Folded Spill
	add	s8, s1, t6
	add	t3, s1, t3
	sd	t3, 88(sp)                      # 8-byte Folded Spill
	add	s11, s1, s11
	add	a7, s1, a7
	sd	a7, 112(sp)                     # 8-byte Folded Spill
	add	t0, s1, t0
	sd	t0, 16(sp)                      # 8-byte Folded Spill
	add	t1, s1, t1
	sd	t1, 104(sp)                     # 8-byte Folded Spill
	add	ra, s1, ra
	sd	ra, 24(sp)                      # 8-byte Folded Spill
	add	a6, s1, a6
	sd	a6, 144(sp)                     # 8-byte Folded Spill
	add	a5, s1, a5
	sd	a5, 32(sp)                      # 8-byte Folded Spill
	add	a3, s1, a3
	sd	a3, 136(sp)                     # 8-byte Folded Spill
	add	a2, s1, a2
	sd	a2, 40(sp)                      # 8-byte Folded Spill
	add	a1, s1, a1
	sd	a1, 128(sp)                     # 8-byte Folded Spill
	add	a0, s1, a0
	sd	a0, 48(sp)                      # 8-byte Folded Spill
	add	a4, s1, a4
	sd	a4, 120(sp)                     # 8-byte Folded Spill
	sd	gp, 120(s9)
	vs2r.v	v0, (s4)
	vs2r.v	v2, (s2)
	vs2r.v	v4, (s3)
	vs2r.v	v6, (s5)
	vs2r.v	v8, (s7)
	vs2r.v	v10, (s6)
	vs2r.v	v12, (s10)
	vs2r.v	v14, (s8)
	vs2r.v	v16, (s11)
	vs2r.v	v18, (t0)
	vs2r.v	v20, (ra)
	vs2r.v	v22, (a5)
	vs2r.v	v24, (a2)
	vs2r.v	v26, (a0)
	#APP
	mv	t2, s9
	#NO_APP
	ld	a0, 160(sp)                     # 8-byte Folded Reload
	ld	a1, 168(sp)                     # 8-byte Folded Reload
	ld	a2, 176(sp)                     # 8-byte Folded Reload
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
	vl1re64.v	v0, (s4)
	ld	a0, 8(sp)                       # 8-byte Folded Reload
	vl1re64.v	v1, (a0)
	vl1re64.v	v2, (s2)
	ld	a0, 0(sp)                       # 8-byte Folded Reload
	vl1re64.v	v3, (a0)
	vl1re64.v	v4, (s3)
	ld	a0, 64(sp)                      # 8-byte Folded Reload
	vl1re64.v	v5, (a0)
	vl1re64.v	v6, (s5)
	ld	a0, 56(sp)                      # 8-byte Folded Reload
	vl1re64.v	v7, (a0)
	vl1re64.v	v8, (s7)
	ld	a6, 0(s9)
	ld	a7, 8(s9)
	ld	s2, 16(s9)
	ld	s3, 24(s9)
	ld	a0, 80(sp)                      # 8-byte Folded Reload
	vl1re64.v	v9, (a0)
	vl1re64.v	v10, (s6)
	ld	a0, 72(sp)                      # 8-byte Folded Reload
	vl1re64.v	v11, (a0)
	vl1re64.v	v12, (s10)
	ld	s4, 32(s9)
	ld	s5, 40(s9)
	ld	s6, 48(s9)
	ld	s7, 56(s9)
	ld	a0, 96(sp)                      # 8-byte Folded Reload
	vl1re64.v	v13, (a0)
	vl1re64.v	v14, (s8)
	ld	a0, 88(sp)                      # 8-byte Folded Reload
	vl1re64.v	v15, (a0)
	vl1re64.v	v16, (s11)
	ld	s8, 64(s9)
	ld	s10, 72(s9)
	ld	s11, 80(s9)
	ld	s1, 88(s9)
	ld	a0, 112(sp)                     # 8-byte Folded Reload
	vl1re64.v	v17, (a0)
	ld	a0, 16(sp)                      # 8-byte Folded Reload
	vl1re64.v	v18, (a0)
	ld	a0, 104(sp)                     # 8-byte Folded Reload
	vl1re64.v	v19, (a0)
	ld	t4, 96(s9)
	ld	t5, 104(s9)
	ld	t6, 112(s9)
	ld	gp, 120(s9)
	ld	a0, 24(sp)                      # 8-byte Folded Reload
	vl1re64.v	v20, (a0)
	ld	a0, 144(sp)                     # 8-byte Folded Reload
	vl1re64.v	v21, (a0)
	ld	a0, 32(sp)                      # 8-byte Folded Reload
	vl1re64.v	v22, (a0)
	ld	a0, 136(sp)                     # 8-byte Folded Reload
	vl1re64.v	v23, (a0)
	ld	a0, 40(sp)                      # 8-byte Folded Reload
	vl1re64.v	v24, (a0)
	ld	a0, 128(sp)                     # 8-byte Folded Reload
	vl1re64.v	v25, (a0)
	ld	a0, 48(sp)                      # 8-byte Folded Reload
	vl1re64.v	v26, (a0)
	ld	a0, 120(sp)                     # 8-byte Folded Reload
	vl1re64.v	v27, (a0)
	ld	a0, 128(s9)
	ld	t0, 144(s9)
	ld	a5, 152(s9)
	lw	t1, 168(s9)
	ld	s9, 152(sp)                     # 8-byte Folded Reload
	ld	a1, 184(sp)                     # 8-byte Folded Reload
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
