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
	beqz	a7, .LBB0_2
# %bb.1:                                # %bb_false
	remu	a6, a6, a7
	tail	Fx55aa
.LBB0_2:                                # %bb_L0
	lui	a1, 3
	addi	a1, a1, -800
	add	a1, s9, a1
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
	sd	a2, 120(sp)                     # 8-byte Folded Spill
	sd	a1, 112(sp)                     # 8-byte Folded Spill
	mv	a1, s9
	sd	a0, 96(sp)                      # 8-byte Folded Spill
	sd	t1, 104(sp)                     # 8-byte Folded Spill
	sd	t0, 80(sp)                      # 8-byte Folded Spill
	sd	a5, 88(sp)                      # 8-byte Folded Spill
	sd	t6, 72(sp)                      # 8-byte Folded Spill
	sd	t5, 64(sp)                      # 8-byte Folded Spill
	sd	t4, 56(sp)                      # 8-byte Folded Spill
	sd	s1, 48(sp)                      # 8-byte Folded Spill
	sd	s11, 40(sp)                     # 8-byte Folded Spill
	sd	s10, 32(sp)                     # 8-byte Folded Spill
	sd	s8, 24(sp)                      # 8-byte Folded Spill
	mv	s11, s7
	mv	s10, s6
	mv	s8, s5
	mv	s7, s4
	mv	s6, s3
	mv	s5, s2
	mv	s4, a7
	mv	s3, a6
	vsetivli	zero, 1, e8, m1, ta, ma
	vmv1r.v	v28, v27
	csrr	a0, vlenb
	li	a2, 14
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v28, (a0)                       # vscale x 16-byte Folded Spill
	csrr	a0, vlenb
	slli	a0, a0, 4
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v26, (a0)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v26, v25
	csrr	a0, vlenb
	li	a2, 10
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v26, (a0)                       # vscale x 16-byte Folded Spill
	csrr	a0, vlenb
	li	a2, 12
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v24, (a0)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v30, v23
	csrr	a0, vlenb
	slli	a0, a0, 3
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v22, (a0)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v28, v21
	csrr	a0, vlenb
	li	a2, 6
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v20, (a0)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v26, v19
	csrr	a0, vlenb
	slli	a0, a0, 2
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v18, (a0)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v24, v17
	csrr	a0, vlenb
	slli	a0, a0, 1
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v16, (a0)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v22, v15
	addi	a0, sp, 128
	vs2r.v	v14, (a0)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v20, v13
	csrr	a0, vlenb
	li	a2, 22
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v12, (a0)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v18, v11
	csrr	a0, vlenb
	li	a2, 20
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v10, (a0)                       # vscale x 16-byte Folded Spill
	vmv1r.v	v16, v9
	csrr	a0, vlenb
	li	a2, 18
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v8, (a0)                        # vscale x 16-byte Folded Spill
	vmv1r.v	v14, v7
	vmv1r.v	v12, v5
	vmv1r.v	v10, v3
	vmv1r.v	v8, v1
	li	a0, 32
	vsetvli	zero, a0, e8, m2, ta, ma
	vslideup.vi	v0, v8, 16
	vslideup.vi	v2, v10, 16
	vslideup.vi	v4, v12, 16
	vslideup.vi	v6, v14, 16
	csrr	a0, vlenb
	li	a2, 18
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vl2r.v	v8, (a0)                        # vscale x 16-byte Folded Reload
	vslideup.vi	v8, v16, 16
	csrr	a0, vlenb
	li	a2, 18
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v8, (a0)                        # vscale x 16-byte Folded Spill
	csrr	a0, vlenb
	li	a2, 20
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vl2r.v	v8, (a0)                        # vscale x 16-byte Folded Reload
	vslideup.vi	v8, v18, 16
	csrr	a0, vlenb
	li	a2, 20
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v8, (a0)                        # vscale x 16-byte Folded Spill
	csrr	a0, vlenb
	li	a2, 22
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vl2r.v	v8, (a0)                        # vscale x 16-byte Folded Reload
	vslideup.vi	v8, v20, 16
	csrr	a0, vlenb
	li	a2, 22
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vs2r.v	v8, (a0)                        # vscale x 16-byte Folded Spill
	addi	a0, sp, 128
	vl2r.v	v20, (a0)                       # vscale x 16-byte Folded Reload
	vslideup.vi	v20, v22, 16
	csrr	a0, vlenb
	slli	a0, a0, 1
	add	a0, sp, a0
	addi	a0, a0, 128
	vl2r.v	v18, (a0)                       # vscale x 16-byte Folded Reload
	vslideup.vi	v18, v24, 16
	csrr	a0, vlenb
	slli	a0, a0, 2
	add	a0, sp, a0
	addi	a0, a0, 128
	vl2r.v	v16, (a0)                       # vscale x 16-byte Folded Reload
	vslideup.vi	v16, v26, 16
	csrr	a0, vlenb
	li	a2, 6
	mul	a0, a0, a2
	add	a0, sp, a0
	addi	a0, a0, 128
	vl2r.v	v14, (a0)                       # vscale x 16-byte Folded Reload
	vslideup.vi	v14, v28, 16
	csrr	a0, vlenb
	slli	a0, a0, 3
	add	a0, sp, a0
	addi	a0, a0, 128
	vl2r.v	v12, (a0)                       # vscale x 16-byte Folded Reload
	vslideup.vi	v12, v30, 16
	lui	a0, 3
	li	t6, 25
	addi	a3, a0, -800
	slli	s1, t6, 9
	addi	t1, a0, 64
	addi	a2, a0, 128
	addi	a4, a0, 192
	addi	a5, a0, 256
	addi	a6, a0, 320
	addi	a7, a0, 384
	addi	ra, a0, 448
	addi	t5, a0, 576
	addi	t6, a0, 640
	addi	t3, a0, 704
	addi	t4, a0, 768
	addi	t0, a0, 832
	addi	s9, a0, 896
	add	a3, a1, a3
	add	t1, a1, t1
	add	a2, a1, a2
	add	a4, a1, a4
	add	a5, a1, a5
	add	a0, a1, a6
	add	a7, a1, a7
	add	s2, a1, ra
	add	s1, a1, s1
	add	ra, a1, t5
	add	a6, a1, t6
	add	t3, a1, t3
	add	t4, a1, t4
	add	t0, a1, t0
	add	s9, a1, s9
	sd	s3, 0(a3)
	sd	s4, 8(a3)
	sd	s5, 16(a3)
	sd	s6, 24(a3)
	sd	s7, 32(a3)
	sd	s8, 40(a3)
	sd	s10, 48(a3)
	sd	s11, 56(a3)
	ld	a1, 24(sp)                      # 8-byte Folded Reload
	sd	a1, 64(a3)
	ld	a1, 32(sp)                      # 8-byte Folded Reload
	sd	a1, 72(a3)
	ld	a1, 40(sp)                      # 8-byte Folded Reload
	sd	a1, 80(a3)
	ld	a1, 48(sp)                      # 8-byte Folded Reload
	sd	a1, 88(a3)
	csrr	a1, vlenb
	li	t5, 10
	mul	a1, a1, t5
	add	a1, sp, a1
	addi	a1, a1, 128
	vl2r.v	v8, (a1)                        # vscale x 16-byte Folded Reload
	csrr	a1, vlenb
	li	t5, 14
	mul	a1, a1, t5
	add	a1, sp, a1
	addi	a1, a1, 128
	vl2r.v	v22, (a1)                       # vscale x 16-byte Folded Reload
	csrr	a1, vlenb
	li	t5, 12
	mul	a1, a1, t5
	add	a1, sp, a1
	addi	a1, a1, 128
	vl2r.v	v10, (a1)                       # vscale x 16-byte Folded Reload
	vslideup.vi	v10, v8, 16
	csrr	a1, vlenb
	slli	a1, a1, 4
	add	a1, sp, a1
	addi	a1, a1, 128
	vl2r.v	v8, (a1)                        # vscale x 16-byte Folded Reload
	vslideup.vi	v8, v22, 16
	ld	a1, 56(sp)                      # 8-byte Folded Reload
	sd	a1, 96(a3)
	ld	a1, 64(sp)                      # 8-byte Folded Reload
	sd	a1, 104(a3)
	ld	a1, 72(sp)                      # 8-byte Folded Reload
	sd	a1, 112(a3)
	sd	gp, 120(a3)
	ld	a1, 96(sp)                      # 8-byte Folded Reload
	sd	a1, 128(a3)
	ld	a1, 80(sp)                      # 8-byte Folded Reload
	sd	a1, 144(a3)
	ld	a1, 88(sp)                      # 8-byte Folded Reload
	sd	a1, 152(a3)
	ld	a1, 104(sp)                     # 8-byte Folded Reload
	sw	a1, 168(a3)
	vse8.v	v0, (t1)
	vse8.v	v2, (a2)
	vse8.v	v4, (a4)
	vse8.v	v6, (a5)
	csrr	a1, vlenb
	li	a2, 18
	mul	a1, a1, a2
	add	a1, sp, a1
	addi	a1, a1, 128
	vl2r.v	v22, (a1)                       # vscale x 16-byte Folded Reload
	vse8.v	v22, (a0)
	csrr	a0, vlenb
	li	a1, 20
	mul	a0, a0, a1
	add	a0, sp, a0
	addi	a0, a0, 128
	vl2r.v	v22, (a0)                       # vscale x 16-byte Folded Reload
	vse8.v	v22, (a7)
	csrr	a0, vlenb
	li	a1, 22
	mul	a0, a0, a1
	add	a0, sp, a0
	addi	a0, a0, 128
	vl2r.v	v22, (a0)                       # vscale x 16-byte Folded Reload
	vse8.v	v22, (s2)
	vse8.v	v20, (s1)
	vse8.v	v18, (ra)
	vse8.v	v16, (a6)
	vse8.v	v14, (t3)
	vse8.v	v12, (t4)
	vse8.v	v10, (t0)
	vse8.v	v8, (s9)
	#APP
	mv	t2, a3
	#NO_APP
	ld	a0, 112(sp)                     # 8-byte Folded Reload
	ld	a1, 120(sp)                     # 8-byte Folded Reload
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
