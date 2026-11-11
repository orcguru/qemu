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
	.section	.text.trampoline,"ax",@progbits
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
