; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h, ptr align 8 dereferenceable(26528) %cpu) #0 section ".text.Fx0" {
entry:
  %rax.stack = alloca i64, align 8
  store i64 %rax, ptr %rax.stack, align 8, !tbaa !0
  %rcx.stack = alloca i64, align 8
  store i64 %rcx, ptr %rcx.stack, align 8, !tbaa !0
  %v0.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm0, ptr %v0.stack, align 16, !tbaa !0
  %v20.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm10, ptr %v20.stack, align 16, !tbaa !0
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca <2 x i64>, align 16
  %tmp4.stack = alloca <2 x i64>, align 16
  %tmp5.stack = alloca <2 x i64>, align 16
  %tmp6.stack = alloca ptr, align 8
  %carry.stack = alloca i1, align 8
  %borrow.stack = alloca i1, align 8
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] mov_i64 [t0],rax ========
  %T0.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !3
  store i64 %T0.rax, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !3
; ======== TCG [1] mov_i64 [t1],rcx ========
  %T1.rcx = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !4
  store i64 %T1.rcx, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !4
; ======== TCG [2] addco_i32 [t2],t0,t1 ========
  %T2.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !5
  %T2.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !5
  %T2.r1 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T2.tmp0, i32 %T2.tmp1), !tcg.op !5
  %T2.s1 = extractvalue { i32, i1 } %T2.r1, 0, !tcg.op !5
  %T2.c1 = extractvalue { i32, i1 } %T2.r1, 1, !tcg.op !5
  store i32 %T2.s1, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !5
  store i1 %T2.c1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !5
; ======== TCG [3] addco_i64 [t2],t0,t1 ========
  %T3.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !6
  %T3.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !6
  %T3.r1 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T3.tmp0, i64 %T3.tmp1), !tcg.op !6
  %T3.s1 = extractvalue { i64, i1 } %T3.r1, 0, !tcg.op !6
  %T3.c1 = extractvalue { i64, i1 } %T3.r1, 1, !tcg.op !6
  store i64 %T3.s1, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !6
  store i1 %T3.c1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !6
; ======== TCG [4] addci_i32 [t2],t0,t1 ========
  %T4.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !7
  %T4.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !7
  %T4.r1 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T4.tmp0, i32 %T4.tmp1), !tcg.op !7
  %T4.s1 = extractvalue { i32, i1 } %T4.r1, 0, !tcg.op !7
  %T4.c1 = extractvalue { i32, i1 } %T4.r1, 1, !tcg.op !7
  %T4.ci = load i1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !7
  %T4.ci_ext = zext i1 %T4.ci to i32, !tcg.op !7
  %T4.r2 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T4.s1, i32 %T4.ci_ext), !tcg.op !7
  %T4.s2 = extractvalue { i32, i1 } %T4.r2, 0, !tcg.op !7
  store i32 %T4.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !7
; ======== TCG [5] addci_i64 [t2],t0,t1 ========
  %T5.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !8
  %T5.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !8
  %T5.r1 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T5.tmp0, i64 %T5.tmp1), !tcg.op !8
  %T5.s1 = extractvalue { i64, i1 } %T5.r1, 0, !tcg.op !8
  %T5.c1 = extractvalue { i64, i1 } %T5.r1, 1, !tcg.op !8
  %T5.ci = load i1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !8
  %T5.ci_ext = zext i1 %T5.ci to i64, !tcg.op !8
  %T5.r2 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T5.s1, i64 %T5.ci_ext), !tcg.op !8
  %T5.s2 = extractvalue { i64, i1 } %T5.r2, 0, !tcg.op !8
  store i64 %T5.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !8
; ======== TCG [6] addcio_i32 [t2],t0,t1 ========
  %T6.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !9
  %T6.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !9
  %T6.r1 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T6.tmp0, i32 %T6.tmp1), !tcg.op !9
  %T6.s1 = extractvalue { i32, i1 } %T6.r1, 0, !tcg.op !9
  %T6.c1 = extractvalue { i32, i1 } %T6.r1, 1, !tcg.op !9
  %T6.ci = load i1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !9
  %T6.ci_ext = zext i1 %T6.ci to i32, !tcg.op !9
  %T6.r2 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T6.s1, i32 %T6.ci_ext), !tcg.op !9
  %T6.s2 = extractvalue { i32, i1 } %T6.r2, 0, !tcg.op !9
  store i32 %T6.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !9
  %T6.c2 = extractvalue { i32, i1 } %T6.r2, 1, !tcg.op !9
  %T6.co = or i1 %T6.c1, %T6.c2, !tcg.op !9
  store i1 %T6.co, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !9
; ======== TCG [7] addcio_i64 [t2],t0,t1 ========
  %T7.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !10
  %T7.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !10
  %T7.r1 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T7.tmp0, i64 %T7.tmp1), !tcg.op !10
  %T7.s1 = extractvalue { i64, i1 } %T7.r1, 0, !tcg.op !10
  %T7.c1 = extractvalue { i64, i1 } %T7.r1, 1, !tcg.op !10
  %T7.ci = load i1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !10
  %T7.ci_ext = zext i1 %T7.ci to i64, !tcg.op !10
  %T7.r2 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T7.s1, i64 %T7.ci_ext), !tcg.op !10
  %T7.s2 = extractvalue { i64, i1 } %T7.r2, 0, !tcg.op !10
  store i64 %T7.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !10
  %T7.c2 = extractvalue { i64, i1 } %T7.r2, 1, !tcg.op !10
  %T7.co = or i1 %T7.c1, %T7.c2, !tcg.op !10
  store i1 %T7.co, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !10
; ======== TCG [8] subbo_i32 [t2],t0,t1 ========
  %T8.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !11
  %T8.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !11
  %T8.r1 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T8.tmp0, i32 %T8.tmp1), !tcg.op !11
  %T8.s1 = extractvalue { i32, i1 } %T8.r1, 0, !tcg.op !11
  %T8.c1 = extractvalue { i32, i1 } %T8.r1, 1, !tcg.op !11
  store i32 %T8.s1, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !11
  store i1 %T8.c1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !11
; ======== TCG [9] subbo_i64 [t2],t0,t1 ========
  %T9.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !12
  %T9.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !12
  %T9.r1 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T9.tmp0, i64 %T9.tmp1), !tcg.op !12
  %T9.s1 = extractvalue { i64, i1 } %T9.r1, 0, !tcg.op !12
  %T9.c1 = extractvalue { i64, i1 } %T9.r1, 1, !tcg.op !12
  store i64 %T9.s1, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !12
  store i1 %T9.c1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !12
; ======== TCG [10] subbi_i32 [t2],t0,t1 ========
  %T10.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !13
  %T10.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !13
  %T10.r1 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T10.tmp0, i32 %T10.tmp1), !tcg.op !13
  %T10.s1 = extractvalue { i32, i1 } %T10.r1, 0, !tcg.op !13
  %T10.c1 = extractvalue { i32, i1 } %T10.r1, 1, !tcg.op !13
  %T10.ci = load i1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !13
  %T10.ci_ext = zext i1 %T10.ci to i32, !tcg.op !13
  %T10.r2 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T10.s1, i32 %T10.ci_ext), !tcg.op !13
  %T10.s2 = extractvalue { i32, i1 } %T10.r2, 0, !tcg.op !13
  store i32 %T10.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !13
; ======== TCG [11] subbi_i64 [t2],t0,t1 ========
  %T11.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !14
  %T11.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !14
  %T11.r1 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T11.tmp0, i64 %T11.tmp1), !tcg.op !14
  %T11.s1 = extractvalue { i64, i1 } %T11.r1, 0, !tcg.op !14
  %T11.c1 = extractvalue { i64, i1 } %T11.r1, 1, !tcg.op !14
  %T11.ci = load i1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !14
  %T11.ci_ext = zext i1 %T11.ci to i64, !tcg.op !14
  %T11.r2 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T11.s1, i64 %T11.ci_ext), !tcg.op !14
  %T11.s2 = extractvalue { i64, i1 } %T11.r2, 0, !tcg.op !14
  store i64 %T11.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !14
; ======== TCG [12] subbio_i32 [t2],t0,t1 ========
  %T12.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !15
  %T12.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !15
  %T12.r1 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T12.tmp0, i32 %T12.tmp1), !tcg.op !15
  %T12.s1 = extractvalue { i32, i1 } %T12.r1, 0, !tcg.op !15
  %T12.c1 = extractvalue { i32, i1 } %T12.r1, 1, !tcg.op !15
  %T12.ci = load i1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !15
  %T12.ci_ext = zext i1 %T12.ci to i32, !tcg.op !15
  %T12.r2 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T12.s1, i32 %T12.ci_ext), !tcg.op !15
  %T12.s2 = extractvalue { i32, i1 } %T12.r2, 0, !tcg.op !15
  store i32 %T12.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !15
  %T12.c2 = extractvalue { i32, i1 } %T12.r2, 1, !tcg.op !15
  %T12.co = or i1 %T12.c1, %T12.c2, !tcg.op !15
  store i1 %T12.co, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !15
; ======== TCG [13] subbio_i64 [t2],t0,t1 ========
  %T13.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !16
  %T13.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !16
  %T13.r1 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T13.tmp0, i64 %T13.tmp1), !tcg.op !16
  %T13.s1 = extractvalue { i64, i1 } %T13.r1, 0, !tcg.op !16
  %T13.c1 = extractvalue { i64, i1 } %T13.r1, 1, !tcg.op !16
  %T13.ci = load i1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !16
  %T13.ci_ext = zext i1 %T13.ci to i64, !tcg.op !16
  %T13.r2 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T13.s1, i64 %T13.ci_ext), !tcg.op !16
  %T13.s2 = extractvalue { i64, i1 } %T13.r2, 0, !tcg.op !16
  store i64 %T13.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !16
  %T13.c2 = extractvalue { i64, i1 } %T13.r2, 1, !tcg.op !16
  %T13.co = or i1 %T13.c1, %T13.c2, !tcg.op !16
  store i1 %T13.co, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !16
; ======== TCG [14] addc1o_i32 t2,t0,t1 ========
  %T14.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !17
  %T14.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !17
  %T14.r1 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T14.tmp0, i32 %T14.tmp1), !tcg.op !17
  %T14.s1 = extractvalue { i32, i1 } %T14.r1, 0, !tcg.op !17
  %T14.c1 = extractvalue { i32, i1 } %T14.r1, 1, !tcg.op !17
  %T14.r2 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T14.s1, i32 1), !tcg.op !17
  %T14.s2 = extractvalue { i32, i1 } %T14.r2, 0, !tcg.op !17
  store i32 %T14.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !17
  %T14.c2 = extractvalue { i32, i1 } %T14.r2, 1, !tcg.op !17
  %T14.co = or i1 %T14.c1, %T14.c2, !tcg.op !17
  store i1 %T14.co, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !17
; ======== TCG [15] addc1o_i64 t2,t0,t1 ========
  %T15.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !18
  %T15.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !18
  %T15.r1 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T15.tmp0, i64 %T15.tmp1), !tcg.op !18
  %T15.s1 = extractvalue { i64, i1 } %T15.r1, 0, !tcg.op !18
  %T15.c1 = extractvalue { i64, i1 } %T15.r1, 1, !tcg.op !18
  %T15.r2 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T15.s1, i64 1), !tcg.op !18
  %T15.s2 = extractvalue { i64, i1 } %T15.r2, 0, !tcg.op !18
  store i64 %T15.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !18
  %T15.c2 = extractvalue { i64, i1 } %T15.r2, 1, !tcg.op !18
  %T15.co = or i1 %T15.c1, %T15.c2, !tcg.op !18
  store i1 %T15.co, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !18
; ======== TCG [16] subb1o_i32 t2,t0,t1 ========
  %T16.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !19
  %T16.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !19
  %T16.r1 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T16.tmp0, i32 %T16.tmp1), !tcg.op !19
  %T16.s1 = extractvalue { i32, i1 } %T16.r1, 0, !tcg.op !19
  %T16.c1 = extractvalue { i32, i1 } %T16.r1, 1, !tcg.op !19
  %T16.r2 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T16.s1, i32 1), !tcg.op !19
  %T16.s2 = extractvalue { i32, i1 } %T16.r2, 0, !tcg.op !19
  store i32 %T16.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !19
  %T16.c2 = extractvalue { i32, i1 } %T16.r2, 1, !tcg.op !19
  %T16.co = or i1 %T16.c1, %T16.c2, !tcg.op !19
  store i1 %T16.co, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !19
; ======== TCG [17] subb1o_i64 t2,t0,t1 ========
  %T17.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !20
  %T17.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !20
  %T17.r1 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T17.tmp0, i64 %T17.tmp1), !tcg.op !20
  %T17.s1 = extractvalue { i64, i1 } %T17.r1, 0, !tcg.op !20
  %T17.c1 = extractvalue { i64, i1 } %T17.r1, 1, !tcg.op !20
  %T17.r2 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T17.s1, i64 1), !tcg.op !20
  %T17.s2 = extractvalue { i64, i1 } %T17.r2, 0, !tcg.op !20
  store i64 %T17.s2, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !20
  %T17.c2 = extractvalue { i64, i1 } %T17.r2, 1, !tcg.op !20
  %T17.co = or i1 %T17.c1, %T17.c2, !tcg.op !20
  store i1 %T17.co, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !20
; ======== TCG [18] add_i32 [t2],t0,t1 ========
  %T18.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !21
  %T18.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !21
  %T18.out = add i32 %T18.tmp0, %T18.tmp1, !tcg.op !21
  store i32 %T18.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !21
; ======== TCG [19] add_i64 [t2],t0,t1 ========
  %T19.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !22
  %T19.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !22
  %T19.out = add i64 %T19.tmp0, %T19.tmp1, !tcg.op !22
  store i64 %T19.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !22
; ======== TCG [20] ld_vec v128,e8,[t3],v0 ========
  %T20.v0 = load <16 x i8>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !23
  store <16 x i8> %T20.v0, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !23
; ======== TCG [21] ld_vec v128,e8,[t4],v20 ========
  %T21.v20 = load <16 x i8>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !24
  store <16 x i8> %T21.v20, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !24
; ======== TCG [22] add_vec v128,e8,[t5],t3,t4 ========
  %T22.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !25
  %T22.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !25
  %T22.out = add <16 x i8> %T22.tmp3, %T22.tmp4, !tcg.op !25
  store <16 x i8> %T22.out, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !25
; ======== TCG [23] add_vec v128,e32,[t5],t3,t4 ========
  %T23.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !26
  %T23.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !26
  %T23.out = add <4 x i32> %T23.tmp3, %T23.tmp4, !tcg.op !26
  store <4 x i32> %T23.out, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !26
; ======== TCG [24] sub_i32 [t2],t0,t1 ========
  %T24.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !27
  %T24.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !27
  %T24.out = sub i32 %T24.tmp0, %T24.tmp1, !tcg.op !27
  store i32 %T24.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !27
; ======== TCG [25] sub_i64 [t2],t0,t1 ========
  %T25.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !28
  %T25.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !28
  %T25.out = sub i64 %T25.tmp0, %T25.tmp1, !tcg.op !28
  store i64 %T25.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !28
; ======== TCG [26] sub_vec v128,e8,[t5],t3,t4 ========
  %T26.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !29
  %T26.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !29
  %T26.out = sub <16 x i8> %T26.tmp3, %T26.tmp4, !tcg.op !29
  store <16 x i8> %T26.out, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !29
; ======== TCG [27] sub_vec v128,e32,[t5],t3,t4 ========
  %T27.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !30
  %T27.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !30
  %T27.out = sub <4 x i32> %T27.tmp3, %T27.tmp4, !tcg.op !30
  store <4 x i32> %T27.out, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !30
; ======== TCG [28] extrl_i64_i32 [t2],t0 ========
  %T28.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !31
  %T28.tmp0.trunc = trunc i64 %T28.tmp0 to i32, !tcg.op !31
  store i32 %T28.tmp0.trunc, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !31
; ======== TCG [29] mov_i32 [t2],t0 ========
  %T29.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !32
  store i32 %T29.tmp0, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !32
; ======== TCG [30] mov_i64 [t2],t0 ========
  %T30.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !33
  store i64 %T30.tmp0, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !33
; ======== TCG [31] mov_vec v128,e8,[t5],t3 ========
  %T31.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !34
  store <16 x i8> %T31.tmp3, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !34
; ======== TCG [32] abs_vec v128,e8,[t5],t3 ========
  %T32.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !35
  %T32.abs = call <16 x i8> @llvm.abs.v16i8.i1(<16 x i8> %T32.tmp3, i1 false), !tcg.op !35
  store <16 x i8> %T32.abs, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !35
; ======== TCG [33] func_addr t6,0x55aa,0x0 ========
  store ptr @Fx55aa, ptr %tmp6.stack, align 8, !tbaa !0, !tcg.op !36
; ======== TCG [34] tail_call_qemuaot t6 VEC_ARGS: ========
  %T34.rax.stack = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !37
  %T34.rcx.stack = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !37
  %T34.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !37
  %T34.v20.stack = load <2 x i64>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !37
  %T34.loaded_fn = load ptr, ptr %tmp6.stack, align 8, !tcg.op !37
  tail call qemuaot void %T34.loaded_fn(i64 %T34.rax.stack, i64 %T34.rcx.stack, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %T34.v0.stack, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %T34.v20.stack, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h, ptr %cpu), !tcg.op !37
  ret void, !tcg.op !37
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32, i32) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64, i64) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32, i32) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64, i64) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.abs.v16i8.i1(<16 x i8>, i1 immarg) #1

; Function Attrs: nounwind
declare qemuaot void @Fx55aa(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, ptr align 8 dereferenceable(26528)) #2 section ".text.Fx55aa"

attributes #0 = { noinline nounwind "target-features"="+neon" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { nounwind "target-features"="+neon" }

!0 = !{!1, !1, i64 0}
!1 = !{!"SpillSlo", !2}
!2 = !{!"Root"}
!3 = !{!"[0] mov_i64 [t0],rax"}
!4 = !{!"[1] mov_i64 [t1],rcx"}
!5 = !{!"[2] addco_i32 [t2],t0,t1"}
!6 = !{!"[3] addco_i64 [t2],t0,t1"}
!7 = !{!"[4] addci_i32 [t2],t0,t1"}
!8 = !{!"[5] addci_i64 [t2],t0,t1"}
!9 = !{!"[6] addcio_i32 [t2],t0,t1"}
!10 = !{!"[7] addcio_i64 [t2],t0,t1"}
!11 = !{!"[8] subbo_i32 [t2],t0,t1"}
!12 = !{!"[9] subbo_i64 [t2],t0,t1"}
!13 = !{!"[10] subbi_i32 [t2],t0,t1"}
!14 = !{!"[11] subbi_i64 [t2],t0,t1"}
!15 = !{!"[12] subbio_i32 [t2],t0,t1"}
!16 = !{!"[13] subbio_i64 [t2],t0,t1"}
!17 = !{!"[14] addc1o_i32 t2,t0,t1"}
!18 = !{!"[15] addc1o_i64 t2,t0,t1"}
!19 = !{!"[16] subb1o_i32 t2,t0,t1"}
!20 = !{!"[17] subb1o_i64 t2,t0,t1"}
!21 = !{!"[18] add_i32 [t2],t0,t1"}
!22 = !{!"[19] add_i64 [t2],t0,t1"}
!23 = !{!"[20] ld_vec v128,e8,[t3],v0"}
!24 = !{!"[21] ld_vec v128,e8,[t4],v20"}
!25 = !{!"[22] add_vec v128,e8,[t5],t3,t4"}
!26 = !{!"[23] add_vec v128,e32,[t5],t3,t4"}
!27 = !{!"[24] sub_i32 [t2],t0,t1"}
!28 = !{!"[25] sub_i64 [t2],t0,t1"}
!29 = !{!"[26] sub_vec v128,e8,[t5],t3,t4"}
!30 = !{!"[27] sub_vec v128,e32,[t5],t3,t4"}
!31 = !{!"[28] extrl_i64_i32 [t2],t0"}
!32 = !{!"[29] mov_i32 [t2],t0"}
!33 = !{!"[30] mov_i64 [t2],t0"}
!34 = !{!"[31] mov_vec v128,e8,[t5],t3"}
!35 = !{!"[32] abs_vec v128,e8,[t5],t3"}
!36 = !{!"[33] func_addr t6,0x55aa,0x0"}
!37 = !{!"[34] tail_call_qemuaot t6 VEC_ARGS:"}
