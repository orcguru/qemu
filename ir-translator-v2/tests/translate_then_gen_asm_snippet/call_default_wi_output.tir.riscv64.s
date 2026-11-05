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
	sd	a4, 184(sp)                     # 8-byte Folded Spill
	sd	a3, 176(sp)                     # 8-byte Folded Spill
	sd	a2, 168(sp)                     # 8-byte Folded Spill
	mv	a3, a1
	mv	a2, s9
	vsetivli	zero, 1, e8, m1, ta, ma
	vmv1r.v	v28, v27
	csrr	a1, vlenb
	li	a4, 10
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v28, (a1)                       # vscale x 16-byte Folded Spill
	csrr	a1, vlenb
	slli	a1, a1, 4
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v26, (a1)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v26, v25
	csrr	a1, vlenb
	slli	a1, a1, 3
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v26, (a1)                       # vscale x 16-byte Folded Spill
	csrr	a1, vlenb
	li	a4, 12
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v24, (a1)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v30, v23
	csrr	a1, vlenb
	li	a4, 6
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v22, (a1)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v28, v21
	csrr	a1, vlenb
	slli	a1, a1, 2
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v20, (a1)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v26, v19
	csrr	a1, vlenb
	slli	a1, a1, 1
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v18, (a1)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v24, v17
	addi	a1, sp, 192
	vs2r.v	v16, (a1)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v22, v15
	csrr	a1, vlenb
	li	a4, 14
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v14, (a1)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v20, v13
	csrr	a1, vlenb
	li	a4, 22
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v12, (a1)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v18, v11
	csrr	a1, vlenb
	li	a4, 20
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v10, (a1)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v16, v9
	csrr	a1, vlenb
	li	a4, 18
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v8, (a1)                        # vscale x 16-byte Folded Spill
	vmv1r.v	v14, v7
	vmv1r.v	v12, v5
	vmv1r.v	v10, v3
	vmv1r.v	v8, v1
	li	a4, 32
	vsetvli	zero, a4, e8, m2, ta, ma
	vslideup.vi	v0, v8, 16
	vslideup.vi	v2, v10, 16
	vslideup.vi	v4, v12, 16
	vslideup.vi	v6, v14, 16
	csrr	a1, vlenb
	li	a4, 18
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vl2r.v	v8, (a1)                        # vscale x 16-byte Folded Reload
	vslideup.vi	v8, v16, 16
	csrr	a1, vlenb
	li	a4, 18
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v8, (a1)                        # vscale x 16-byte Folded Spill
	csrr	a1, vlenb
	li	a4, 20
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vl2r.v	v8, (a1)                        # vscale x 16-byte Folded Reload
	vslideup.vi	v8, v18, 16
	csrr	a1, vlenb
	li	a4, 20
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v8, (a1)                        # vscale x 16-byte Folded Spill
	csrr	a1, vlenb
	li	a4, 22
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vl2r.v	v8, (a1)                        # vscale x 16-byte Folded Reload
	vslideup.vi	v8, v20, 16
	csrr	a1, vlenb
	li	a4, 22
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vs2r.v	v8, (a1)                        # vscale x 16-byte Folded Spill
	csrr	a1, vlenb
	li	a4, 14
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vl2r.v	v8, (a1)                        # vscale x 16-byte Folded Reload
	vslideup.vi	v8, v22, 16
	vmv.v.v	v22, v8
	addi	a1, sp, 192
	vl2r.v	v20, (a1)                       # vscale x 16-byte Folded Reload
	vslideup.vi	v20, v24, 16
	csrr	a1, vlenb
	slli	a1, a1, 1
	add	a1, sp, a1
	addi	a1, a1, 192
	vl2r.v	v16, (a1)                       # vscale x 16-byte Folded Reload
	vslideup.vi	v16, v26, 16
	csrr	a1, vlenb
	slli	a1, a1, 2
	add	a1, sp, a1
	addi	a1, a1, 192
	vl2r.v	v14, (a1)                       # vscale x 16-byte Folded Reload
	vslideup.vi	v14, v28, 16
	csrr	a1, vlenb
	li	a4, 6
	mul	a1, a1, a4
	add	a1, sp, a1
	addi	a1, a1, 192
	vl2r.v	v12, (a1)                       # vscale x 16-byte Folded Reload
	vslideup.vi	v12, v30, 16
	lui	a4, 3
	addi	s9, a4, -800
	add	s9, a2, s9
	sd	a6, 0(s9)
	sd	a7, 8(s9)
	li	ra, 25
	sd	s2, 16(s9)
	addi	s2, a4, 64
	sd	s3, 24(s9)
	addi	a6, a4, 80
	sd	s4, 32(s9)
	addi	s3, a4, 128
	sd	s5, 40(s9)
	addi	a7, a4, 144
	sd	s6, 48(s9)
	addi	s4, a4, 192
	sd	s7, 56(s9)
	addi	t3, a4, 208
	sd	s8, 64(s9)
	addi	s5, a4, 256
	sd	s10, 72(s9)
	addi	a1, a4, 272
	sd	s11, 80(s9)
	addi	s8, a4, 320
	sd	s1, 88(s9)
	addi	s1, a4, 384
	sd	t4, 96(s9)
	addi	t4, a4, 448
	slli	ra, ra, 9
	sd	t5, 104(s9)
	addi	t5, a4, 576
	sd	t6, 112(s9)
	addi	t6, a4, 640
	sd	a0, 128(s9)
	addi	a0, a4, 704
	sd	t0, 144(s9)
	addi	t0, a4, 768
	sd	a5, 152(s9)
	addi	a5, a4, 832
	csrr	s6, vlenb
	slli	s6, s6, 3
	add	s6, sp, s6
	addi	s6, s6, 192
	vl2r.v	v8, (s6)                        # vscale x 16-byte Folded Reload
	sw	t1, 168(s9)
	addi	t1, a4, 896
	csrr	s6, vlenb
	li	s7, 10
	mul	s6, s6, s7
	add	s6, sp, s6
	addi	s6, s6, 192
	vl2r.v	v18, (s6)                       # vscale x 16-byte Folded Reload
	add	s11, a2, s2
	add	s10, a2, s3
	add	s7, a2, s4
	add	s5, a2, s5
	sd	s5, 80(sp)                      # 8-byte Folded Spill
	add	s8, a2, s8
	sd	s8, 72(sp)                      # 8-byte Folded Spill
	add	s1, a2, s1
	sd	s1, 96(sp)                      # 8-byte Folded Spill
	add	t4, a2, t4
	sd	t4, 88(sp)                      # 8-byte Folded Spill
	add	ra, a2, ra
	sd	ra, 104(sp)                     # 8-byte Folded Spill
	add	t5, a2, t5
	sd	t5, 112(sp)                     # 8-byte Folded Spill
	add	t6, a2, t6
	sd	t6, 120(sp)                     # 8-byte Folded Spill
	add	a0, a2, a0
	sd	a0, 128(sp)                     # 8-byte Folded Spill
	add	t0, a2, t0
	sd	t0, 136(sp)                     # 8-byte Folded Spill
	add	a5, a2, a5
	sd	a5, 144(sp)                     # 8-byte Folded Spill
	csrr	s2, vlenb
	li	s3, 12
	mul	s2, s2, s3
	add	s2, sp, s2
	addi	s2, s2, 192
	vl2r.v	v10, (s2)                       # vscale x 16-byte Folded Reload
	vslideup.vi	v10, v8, 16
	add	t1, a2, t1
	sd	t1, 152(sp)                     # 8-byte Folded Spill
	csrr	s2, vlenb
	slli	s2, s2, 4
	add	s2, sp, s2
	addi	s2, s2, 192
	vl2r.v	v8, (s2)                        # vscale x 16-byte Folded Reload
	vslideup.vi	v8, v18, 16
	vse8.v	v0, (s11)
	vse8.v	v2, (s10)
	vse8.v	v4, (s7)
	vse8.v	v6, (s5)
	csrr	s2, vlenb
	li	s3, 18
	mul	s2, s2, s3
	add	s2, sp, s2
	addi	s2, s2, 192
	vl2r.v	v18, (s2)                       # vscale x 16-byte Folded Reload
	vse8.v	v18, (s8)
	csrr	s2, vlenb
	li	s3, 20
	mul	s2, s2, s3
	add	s2, sp, s2
	addi	s2, s2, 192
	vl2r.v	v18, (s2)                       # vscale x 16-byte Folded Reload
	vse8.v	v18, (s1)
	csrr	s1, vlenb
	li	s2, 22
	mul	s1, s1, s2
	add	s1, sp, s1
	addi	s1, s1, 192
	vl2r.v	v18, (s1)                       # vscale x 16-byte Folded Reload
	vse8.v	v18, (t4)
	vse8.v	v22, (ra)
	vse8.v	v20, (t5)
	vse8.v	v16, (t6)
	vse8.v	v14, (a0)
	vse8.v	v12, (t0)
	vse8.v	v10, (a5)
	vse8.v	v8, (t1)
	addi	s1, a4, 336
	addi	s4, a4, 400
	addi	s5, a4, 464
	addi	s8, a4, 528
	addi	a0, a4, 592
	addi	a5, a4, 656
	addi	t0, a4, 720
	addi	t1, a4, 784
	addi	t4, a4, 848
	addi	a4, a4, 912
	sd	a2, 160(sp)                     # 8-byte Folded Spill
	add	s2, a2, a6
	add	s3, a2, a7
	add	s6, a2, t3
	add	a1, a2, a1
	sd	a1, 16(sp)                      # 8-byte Folded Spill
	add	s1, a2, s1
	add	s4, a2, s4
	add	s5, a2, s5
	add	s8, a2, s8
	add	a0, a2, a0
	sd	a0, 24(sp)                      # 8-byte Folded Spill
	add	a5, a2, a5
	sd	a5, 32(sp)                      # 8-byte Folded Spill
	add	t0, a2, t0
	sd	t0, 40(sp)                      # 8-byte Folded Spill
	add	t1, a2, t1
	sd	t1, 48(sp)                      # 8-byte Folded Spill
	add	t4, a2, t4
	sd	t4, 56(sp)                      # 8-byte Folded Spill
	add	a2, a2, a4
	sd	a2, 64(sp)                      # 8-byte Folded Spill
	sd	gp, 120(s9)
	#APP
	mv	t2, s9
	#NO_APP
	mv	a0, a3
	ld	a1, 168(sp)                     # 8-byte Folded Reload
	ld	a2, 176(sp)                     # 8-byte Folded Reload
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
	vsetivli	zero, 2, e64, m1, ta, ma
	vle64.v	v0, (s11)
	vle64.v	v1, (s2)
	vle64.v	v2, (s10)
	vle64.v	v3, (s3)
	vle64.v	v4, (s7)
	vle64.v	v5, (s6)
	ld	a1, 80(sp)                      # 8-byte Folded Reload
	vle64.v	v6, (a1)
	ld	a1, 16(sp)                      # 8-byte Folded Reload
	vle64.v	v7, (a1)
	ld	a1, 72(sp)                      # 8-byte Folded Reload
	vle64.v	v8, (a1)
	vle64.v	v9, (s1)
	ld	a6, 0(s9)
	ld	a7, 8(s9)
	ld	s2, 16(s9)
	ld	s3, 24(s9)
	ld	a1, 96(sp)                      # 8-byte Folded Reload
	vle64.v	v10, (a1)
	vle64.v	v11, (s4)
	ld	a1, 88(sp)                      # 8-byte Folded Reload
	vle64.v	v12, (a1)
	vle64.v	v13, (s5)
	ld	s4, 32(s9)
	ld	s5, 40(s9)
	ld	s6, 48(s9)
	ld	s7, 56(s9)
	ld	a1, 104(sp)                     # 8-byte Folded Reload
	vle64.v	v14, (a1)
	vle64.v	v15, (s8)
	ld	a1, 112(sp)                     # 8-byte Folded Reload
	vle64.v	v16, (a1)
	ld	a1, 24(sp)                      # 8-byte Folded Reload
	vle64.v	v17, (a1)
	ld	s8, 64(s9)
	ld	s10, 72(s9)
	ld	s11, 80(s9)
	ld	s1, 88(s9)
	ld	a1, 120(sp)                     # 8-byte Folded Reload
	vle64.v	v18, (a1)
	ld	a1, 32(sp)                      # 8-byte Folded Reload
	vle64.v	v19, (a1)
	ld	a1, 128(sp)                     # 8-byte Folded Reload
	vle64.v	v20, (a1)
	ld	t4, 96(s9)
	ld	t5, 104(s9)
	ld	t6, 112(s9)
	ld	gp, 120(s9)
	ld	a1, 40(sp)                      # 8-byte Folded Reload
	vle64.v	v21, (a1)
	ld	a1, 136(sp)                     # 8-byte Folded Reload
	vle64.v	v22, (a1)
	ld	a1, 48(sp)                      # 8-byte Folded Reload
	vle64.v	v23, (a1)
	ld	a1, 144(sp)                     # 8-byte Folded Reload
	vle64.v	v24, (a1)
	ld	a1, 56(sp)                      # 8-byte Folded Reload
	vle64.v	v25, (a1)
	ld	a1, 152(sp)                     # 8-byte Folded Reload
	vle64.v	v26, (a1)
	ld	a1, 64(sp)                      # 8-byte Folded Reload
	vle64.v	v27, (a1)
	ld	a1, 128(s9)
	ld	t0, 144(s9)
	ld	a5, 152(s9)
	lw	t1, 168(s9)
	mv	a2, a0
	mv	a0, a1
	ld	s9, 160(sp)                     # 8-byte Folded Reload
	mv	a1, a2
	ld	a2, 184(sp)                     # 8-byte Folded Reload
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
