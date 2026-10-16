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
  %v4.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm2, ptr %v4.stack, align 16, !tbaa !0
  %v20.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm10, ptr %v20.stack, align 16, !tbaa !0
  %v22.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm11, ptr %v22.stack, align 16, !tbaa !0
  %v24.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm12, ptr %v24.stack, align 16, !tbaa !0
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca <2 x i64>, align 16
  %tmp4.stack = alloca <2 x i64>, align 16
  %tmp5.stack = alloca <2 x i64>, align 16
  %tmp6.stack = alloca <2 x i64>, align 16
  %tmp7.stack = alloca <2 x i64>, align 16
  %tmp8.stack = alloca <2 x i64>, align 16
  %tmp9.stack = alloca ptr, align 8
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
; ======== TCG [20] ld_vec v128,e8,[t3],v4 ========
  %T20.v4 = load <16 x i8>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !23
  store <16 x i8> %T20.v4, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !23
; ======== TCG [21] ld_vec v128,e8,[t4],v0 ========
  %T21.v0 = load <16 x i8>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !24
  store <16 x i8> %T21.v0, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !24
; ======== TCG [22] ld_vec v128,e8,[t5],v20 ========
  %T22.v20 = load <16 x i8>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !25
  store <16 x i8> %T22.v20, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !25
; ======== TCG [23] ld_vec v128,e8,[t6],v22 ========
  %T23.v22 = load <16 x i8>, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !26
  store <16 x i8> %T23.v22, ptr %tmp6.stack, align 16, !tbaa !0, !tcg.op !26
; ======== TCG [24] ld_vec v128,e8,[t7],v24 ========
  %T24.v24 = load <16 x i8>, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !27
  store <16 x i8> %T24.v24, ptr %tmp7.stack, align 16, !tbaa !0, !tcg.op !27
; ======== TCG [25] add_vec v128,e8,[t8],t4,t5 ========
  %T25.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !28
  %T25.tmp5 = load <16 x i8>, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !28
  %T25.out = add <16 x i8> %T25.tmp4, %T25.tmp5, !tcg.op !28
  store <16 x i8> %T25.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !28
; ======== TCG [26] add_vec v128,e32,[t8],t4,t5 ========
  %T26.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !29
  %T26.tmp5 = load <4 x i32>, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !29
  %T26.out = add <4 x i32> %T26.tmp4, %T26.tmp5, !tcg.op !29
  store <4 x i32> %T26.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !29
; ======== TCG [27] sub_i32 [t2],t0,t1 ========
  %T27.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !30
  %T27.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !30
  %T27.out = sub i32 %T27.tmp0, %T27.tmp1, !tcg.op !30
  store i32 %T27.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !30
; ======== TCG [28] sub_i64 [t2],t0,t1 ========
  %T28.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !31
  %T28.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !31
  %T28.out = sub i64 %T28.tmp0, %T28.tmp1, !tcg.op !31
  store i64 %T28.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !31
; ======== TCG [29] sub_vec v128,e8,[t8],t4,t5 ========
  %T29.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !32
  %T29.tmp5 = load <16 x i8>, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !32
  %T29.out = sub <16 x i8> %T29.tmp4, %T29.tmp5, !tcg.op !32
  store <16 x i8> %T29.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !32
; ======== TCG [30] sub_vec v128,e32,[t8],t4,t5 ========
  %T30.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !33
  %T30.tmp5 = load <4 x i32>, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !33
  %T30.out = sub <4 x i32> %T30.tmp4, %T30.tmp5, !tcg.op !33
  store <4 x i32> %T30.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !33
; ======== TCG [31] extrl_i64_i32 [t2],t0 ========
  %T31.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !34
  %T31.tmp0.trunc = trunc i64 %T31.tmp0 to i32, !tcg.op !34
  store i32 %T31.tmp0.trunc, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !34
; ======== TCG [32] mov_i32 [t2],t0 ========
  %T32.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !35
  store i32 %T32.tmp0, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !35
; ======== TCG [33] mov_i64 [t2],t0 ========
  %T33.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !36
  store i64 %T33.tmp0, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !36
; ======== TCG [34] mov_vec v128,e8,[t8],t4 ========
  %T34.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !37
  store <16 x i8> %T34.tmp4, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !37
; ======== TCG [35] mov_vec v128,e32,[t8],t4 ========
  %T35.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !38
  store <4 x i32> %T35.tmp4, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !38
; ======== TCG [36] abs_vec v128,e8,[t8],t4 ========
  %T36.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !39
  %T36.abs = call <16 x i8> @llvm.abs.v16i8.i1(<16 x i8> %T36.tmp4, i1 false), !tcg.op !39
  store <16 x i8> %T36.abs, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !39
; ======== TCG [37] abs_vec v128,e32,[t8],t4 ========
  %T37.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !40
  %T37.abs = call <4 x i32> @llvm.abs.v4i32.i1(<4 x i32> %T37.tmp4, i1 false), !tcg.op !40
  store <4 x i32> %T37.abs, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !40
; ======== TCG [38] bitsel_vec v128,e8,[t8],t3,t4,t5 ========
  %T38.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !41
  %T38.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !41
  %T38.tmp5 = load <16 x i8>, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !41
  %T38.and_a_sel = and <16 x i8> %T38.tmp4, %T38.tmp3, !tcg.op !41
  %T38.nsel = xor <16 x i8> %T38.tmp3, splat (i8 -1), !tcg.op !41
  %T38.and_b_nsel = and <16 x i8> %T38.tmp5, %T38.nsel, !tcg.op !41
  %T38.or = or <16 x i8> %T38.and_a_sel, %T38.and_b_nsel, !tcg.op !41
  store <16 x i8> %T38.or, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !41
; ======== TCG [39] bitsel_vec v128,e32,[t8],t3,t4,t5 ========
  %T39.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !42
  %T39.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !42
  %T39.tmp5 = load <4 x i32>, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !42
  %T39.and_a_sel = and <4 x i32> %T39.tmp4, %T39.tmp3, !tcg.op !42
  %T39.nsel = xor <4 x i32> %T39.tmp3, splat (i32 -1), !tcg.op !42
  %T39.and_b_nsel = and <4 x i32> %T39.tmp5, %T39.nsel, !tcg.op !42
  %T39.or = or <4 x i32> %T39.and_a_sel, %T39.and_b_nsel, !tcg.op !42
  store <4 x i32> %T39.or, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !42
; ======== TCG [40] cmp_vec v128,e8,[t8],t3,t4,gt ========
  %T40.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !43
  %T40.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !43
  %T40.bool = icmp sgt <16 x i8> %T40.tmp3, %T40.tmp4, !tcg.op !43
  %T40.predicate = select <16 x i1> %T40.bool, <16 x i8> splat (i8 -1), <16 x i8> zeroinitializer, !tcg.op !43
  store <16 x i8> %T40.predicate, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !43
; ======== TCG [41] cmp_vec v128,e32,[t8],t3,t4,gt ========
  %T41.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !44
  %T41.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !44
  %T41.bool = icmp sgt <4 x i32> %T41.tmp3, %T41.tmp4, !tcg.op !44
  %T41.predicate = select <4 x i1> %T41.bool, <4 x i32> splat (i32 -1), <4 x i32> zeroinitializer, !tcg.op !44
  store <4 x i32> %T41.predicate, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !44
; ======== TCG [42] cmpsel_vec v128,e8,[t8],t3,t4,t6,t7,gt ========
  %T42.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !45
  %T42.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !45
  %T42.bool = icmp sgt <16 x i8> %T42.tmp3, %T42.tmp4, !tcg.op !45
  %T42.predicate = select <16 x i1> %T42.bool, <16 x i8> splat (i8 -1), <16 x i8> zeroinitializer, !tcg.op !45
  %T42.tmp6 = load <16 x i8>, ptr %tmp6.stack, align 16, !tbaa !0, !tcg.op !45
  %T42.tmp7 = load <16 x i8>, ptr %tmp7.stack, align 16, !tbaa !0, !tcg.op !45
  %T42.and_a_sel = and <16 x i8> %T42.tmp6, %T42.predicate, !tcg.op !45
  %T42.nsel = xor <16 x i8> %T42.predicate, splat (i8 -1), !tcg.op !45
  %T42.and_b_nsel = and <16 x i8> %T42.tmp7, %T42.nsel, !tcg.op !45
  %T42.or = or <16 x i8> %T42.and_a_sel, %T42.and_b_nsel, !tcg.op !45
  store <16 x i8> %T42.or, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !45
; ======== TCG [43] cmpsel_vec v128,e32,[t8],t3,t4,t6,t7,gt ========
  %T43.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !46
  %T43.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !46
  %T43.bool = icmp sgt <4 x i32> %T43.tmp3, %T43.tmp4, !tcg.op !46
  %T43.predicate = select <4 x i1> %T43.bool, <4 x i32> splat (i32 -1), <4 x i32> zeroinitializer, !tcg.op !46
  %T43.tmp6 = load <4 x i32>, ptr %tmp6.stack, align 16, !tbaa !0, !tcg.op !46
  %T43.tmp7 = load <4 x i32>, ptr %tmp7.stack, align 16, !tbaa !0, !tcg.op !46
  %T43.and_a_sel = and <4 x i32> %T43.tmp6, %T43.predicate, !tcg.op !46
  %T43.nsel = xor <4 x i32> %T43.predicate, splat (i32 -1), !tcg.op !46
  %T43.and_b_nsel = and <4 x i32> %T43.tmp7, %T43.nsel, !tcg.op !46
  %T43.or = or <4 x i32> %T43.and_a_sel, %T43.and_b_nsel, !tcg.op !46
  store <4 x i32> %T43.or, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !46
; ======== TCG [44] ctpop_i32 [t2],t2 ========
  %T44.tmp2 = load i32, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !47
  %T44.pop = call i32 @llvm.ctpop.i32(i32 %T44.tmp2), !tcg.op !47
  store i32 %T44.pop, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !47
; ======== TCG [45] ctpop_i64 [t2],t2 ========
  %T45.tmp2 = load i64, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !48
  %T45.pop = call i64 @llvm.ctpop.i64(i64 %T45.tmp2), !tcg.op !48
  store i64 %T45.pop, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !48
; ======== TCG [46] divs_i32 [t2],t0,t1 ========
  %T46.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !49
  %T46.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !49
  %T46.out = sdiv i32 %T46.tmp0, %T46.tmp1, !tcg.op !49
  store i32 %T46.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !49
; ======== TCG [47] divs_i64 [t2],t0,t1 ========
  %T47.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !50
  %T47.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !50
  %T47.out = sdiv i64 %T47.tmp0, %T47.tmp1, !tcg.op !50
  store i64 %T47.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !50
; ======== TCG [48] divu_i32 [t2],t0,t1 ========
  %T48.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !51
  %T48.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !51
  %T48.out = udiv i32 %T48.tmp0, %T48.tmp1, !tcg.op !51
  store i32 %T48.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !51
; ======== TCG [49] divu_i64 [t2],t0,t1 ========
  %T49.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !52
  %T49.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !52
  %T49.out = udiv i64 %T49.tmp0, %T49.tmp1, !tcg.op !52
  store i64 %T49.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !52
; ======== TCG [50] rems_i32 [t2],t0,t1 ========
  %T50.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !53
  %T50.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !53
  %T50.out = srem i32 %T50.tmp0, %T50.tmp1, !tcg.op !53
  store i32 %T50.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !53
; ======== TCG [51] rems_i64 [t2],t0,t1 ========
  %T51.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !54
  %T51.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !54
  %T51.out = srem i64 %T51.tmp0, %T51.tmp1, !tcg.op !54
  store i64 %T51.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !54
; ======== TCG [52] remu_i32 [t2],t0,t1 ========
  %T52.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !55
  %T52.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !55
  %T52.out = urem i32 %T52.tmp0, %T52.tmp1, !tcg.op !55
  store i32 %T52.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !55
; ======== TCG [53] remu_i64 [t2],t0,t1 ========
  %T53.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !56
  %T53.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !56
  %T53.out = urem i64 %T53.tmp0, %T53.tmp1, !tcg.op !56
  store i64 %T53.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !56
; ======== TCG [54] sar_i32 [t2],t0,t1 ========
  %T54.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !57
  %T54.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !57
  %T54.out = ashr i32 %T54.tmp0, %T54.tmp1, !tcg.op !57
  store i32 %T54.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !57
; ======== TCG [55] sar_i64 [t2],t0,t1 ========
  %T55.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !58
  %T55.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !58
  %T55.out = ashr i64 %T55.tmp0, %T55.tmp1, !tcg.op !58
  store i64 %T55.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !58
; ======== TCG [56] and_i32 [t2],t0,t1 ========
  %T56.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !59
  %T56.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !59
  %T56.out = and i32 %T56.tmp0, %T56.tmp1, !tcg.op !59
  store i32 %T56.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !59
; ======== TCG [57] and_i64 [t2],t0,t1 ========
  %T57.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !60
  %T57.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !60
  %T57.out = and i64 %T57.tmp0, %T57.tmp1, !tcg.op !60
  store i64 %T57.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !60
; ======== TCG [58] mul_i32 [t2],t0,t1 ========
  %T58.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !61
  %T58.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !61
  %T58.out = mul i32 %T58.tmp0, %T58.tmp1, !tcg.op !61
  store i32 %T58.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !61
; ======== TCG [59] mul_i64 [t2],t0,t1 ========
  %T59.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !62
  %T59.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !62
  %T59.out = mul i64 %T59.tmp0, %T59.tmp1, !tcg.op !62
  store i64 %T59.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !62
; ======== TCG [60] or_i32 [t2],t0,t1 ========
  %T60.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !63
  %T60.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !63
  %T60.out = or i32 %T60.tmp0, %T60.tmp1, !tcg.op !63
  store i32 %T60.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !63
; ======== TCG [61] or_i64 [t2],t0,t1 ========
  %T61.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !64
  %T61.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !64
  %T61.out = or i64 %T61.tmp0, %T61.tmp1, !tcg.op !64
  store i64 %T61.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !64
; ======== TCG [62] shl_i32 [t2],t0,t1 ========
  %T62.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !65
  %T62.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !65
  %T62.out = shl i32 %T62.tmp0, %T62.tmp1, !tcg.op !65
  store i32 %T62.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !65
; ======== TCG [63] shl_i64 [t2],t0,t1 ========
  %T63.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !66
  %T63.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !66
  %T63.out = shl i64 %T63.tmp0, %T63.tmp1, !tcg.op !66
  store i64 %T63.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !66
; ======== TCG [64] shr_i32 [t2],t0,t1 ========
  %T64.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !67
  %T64.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !67
  %T64.out = lshr i32 %T64.tmp0, %T64.tmp1, !tcg.op !67
  store i32 %T64.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !67
; ======== TCG [65] shr_i64 [t2],t0,t1 ========
  %T65.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !68
  %T65.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !68
  %T65.out = lshr i64 %T65.tmp0, %T65.tmp1, !tcg.op !68
  store i64 %T65.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !68
; ======== TCG [66] xor_i32 [t2],t0,t1 ========
  %T66.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !69
  %T66.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !69
  %T66.out = xor i32 %T66.tmp0, %T66.tmp1, !tcg.op !69
  store i32 %T66.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !69
; ======== TCG [67] xor_i64 [t2],t0,t1 ========
  %T67.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !70
  %T67.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !70
  %T67.out = xor i64 %T67.tmp0, %T67.tmp1, !tcg.op !70
  store i64 %T67.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !70
; ======== TCG [68] sarv_vec v128,e8,[t8],t3,t4 ========
  %T68.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !71
  %T68.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !71
  %T68.out = ashr <16 x i8> %T68.tmp3, %T68.tmp4, !tcg.op !71
  store <16 x i8> %T68.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !71
; ======== TCG [69] sarv_vec v128,e32,[t8],t3,t4 ========
  %T69.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !72
  %T69.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !72
  %T69.out = ashr <4 x i32> %T69.tmp3, %T69.tmp4, !tcg.op !72
  store <4 x i32> %T69.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !72
; ======== TCG [70] shlv_vec v128,e8,[t8],t3,t4 ========
  %T70.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !73
  %T70.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !73
  %T70.out = shl <16 x i8> %T70.tmp3, %T70.tmp4, !tcg.op !73
  store <16 x i8> %T70.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !73
; ======== TCG [71] shlv_vec v128,e32,[t8],t3,t4 ========
  %T71.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !74
  %T71.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !74
  %T71.out = shl <4 x i32> %T71.tmp3, %T71.tmp4, !tcg.op !74
  store <4 x i32> %T71.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !74
; ======== TCG [72] shrv_vec v128,e8,[t8],t3,t4 ========
  %T72.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !75
  %T72.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !75
  %T72.out = lshr <16 x i8> %T72.tmp3, %T72.tmp4, !tcg.op !75
  store <16 x i8> %T72.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !75
; ======== TCG [73] shrv_vec v128,e32,[t8],t3,t4 ========
  %T73.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !76
  %T73.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !76
  %T73.out = lshr <4 x i32> %T73.tmp3, %T73.tmp4, !tcg.op !76
  store <4 x i32> %T73.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !76
; ======== TCG [74] and_vec v128,e8,[t8],t3,t4 ========
  %T74.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !77
  %T74.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !77
  %T74.out = and <16 x i8> %T74.tmp3, %T74.tmp4, !tcg.op !77
  store <16 x i8> %T74.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !77
; ======== TCG [75] and_vec v128,e32,[t8],t3,t4 ========
  %T75.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !78
  %T75.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !78
  %T75.out = and <4 x i32> %T75.tmp3, %T75.tmp4, !tcg.op !78
  store <4 x i32> %T75.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !78
; ======== TCG [76] mul_vec v128,e8,[t8],t3,t4 ========
  %T76.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !79
  %T76.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !79
  %T76.out = mul <16 x i8> %T76.tmp3, %T76.tmp4, !tcg.op !79
  store <16 x i8> %T76.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !79
; ======== TCG [77] mul_vec v128,e32,[t8],t3,t4 ========
  %T77.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !80
  %T77.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !80
  %T77.out = mul <4 x i32> %T77.tmp3, %T77.tmp4, !tcg.op !80
  store <4 x i32> %T77.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !80
; ======== TCG [78] or_vec v128,e8,[t8],t3,t4 ========
  %T78.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !81
  %T78.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !81
  %T78.out = or <16 x i8> %T78.tmp3, %T78.tmp4, !tcg.op !81
  store <16 x i8> %T78.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !81
; ======== TCG [79] or_vec v128,e32,[t8],t3,t4 ========
  %T79.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !82
  %T79.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !82
  %T79.out = or <4 x i32> %T79.tmp3, %T79.tmp4, !tcg.op !82
  store <4 x i32> %T79.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !82
; ======== TCG [80] xor_vec v128,e8,[t8],t3,t4 ========
  %T80.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !83
  %T80.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !83
  %T80.out = xor <16 x i8> %T80.tmp3, %T80.tmp4, !tcg.op !83
  store <16 x i8> %T80.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !83
; ======== TCG [81] xor_vec v128,e32,[t8],t3,t4 ========
  %T81.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !84
  %T81.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !84
  %T81.out = xor <4 x i32> %T81.tmp3, %T81.tmp4, !tcg.op !84
  store <4 x i32> %T81.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !84
; ======== TCG [82] func_addr t9,0x55aa,0x0 ========
  store ptr @Fx55aa, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !85
; ======== TCG [83] tail_call_qemuaot t9 VEC_ARGS: ========
  %T83.rax.stack = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !86
  %T83.rcx.stack = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !86
  %T83.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !86
  %T83.v4.stack = load <2 x i64>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !86
  %T83.v20.stack = load <2 x i64>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !86
  %T83.v22.stack = load <2 x i64>, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !86
  %T83.v24.stack = load <2 x i64>, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !86
  %T83.loaded_fn = load ptr, ptr %tmp9.stack, align 8, !tcg.op !86
  tail call qemuaot void %T83.loaded_fn(i64 %T83.rax.stack, i64 %T83.rcx.stack, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %T83.v0.stack, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %T83.v4.stack, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %T83.v20.stack, <2 x i64> %ymm10_h, <2 x i64> %T83.v22.stack, <2 x i64> %ymm11_h, <2 x i64> %T83.v24.stack, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h, ptr %cpu), !tcg.op !86
  ret void, !tcg.op !86
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

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.abs.v4i32.i1(<4 x i32>, i1 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.ctpop.i32(i32) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.ctpop.i64(i64) #1

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
!23 = !{!"[20] ld_vec v128,e8,[t3],v4"}
!24 = !{!"[21] ld_vec v128,e8,[t4],v0"}
!25 = !{!"[22] ld_vec v128,e8,[t5],v20"}
!26 = !{!"[23] ld_vec v128,e8,[t6],v22"}
!27 = !{!"[24] ld_vec v128,e8,[t7],v24"}
!28 = !{!"[25] add_vec v128,e8,[t8],t4,t5"}
!29 = !{!"[26] add_vec v128,e32,[t8],t4,t5"}
!30 = !{!"[27] sub_i32 [t2],t0,t1"}
!31 = !{!"[28] sub_i64 [t2],t0,t1"}
!32 = !{!"[29] sub_vec v128,e8,[t8],t4,t5"}
!33 = !{!"[30] sub_vec v128,e32,[t8],t4,t5"}
!34 = !{!"[31] extrl_i64_i32 [t2],t0"}
!35 = !{!"[32] mov_i32 [t2],t0"}
!36 = !{!"[33] mov_i64 [t2],t0"}
!37 = !{!"[34] mov_vec v128,e8,[t8],t4"}
!38 = !{!"[35] mov_vec v128,e32,[t8],t4"}
!39 = !{!"[36] abs_vec v128,e8,[t8],t4"}
!40 = !{!"[37] abs_vec v128,e32,[t8],t4"}
!41 = !{!"[38] bitsel_vec v128,e8,[t8],t3,t4,t5"}
!42 = !{!"[39] bitsel_vec v128,e32,[t8],t3,t4,t5"}
!43 = !{!"[40] cmp_vec v128,e8,[t8],t3,t4,gt"}
!44 = !{!"[41] cmp_vec v128,e32,[t8],t3,t4,gt"}
!45 = !{!"[42] cmpsel_vec v128,e8,[t8],t3,t4,t6,t7,gt"}
!46 = !{!"[43] cmpsel_vec v128,e32,[t8],t3,t4,t6,t7,gt"}
!47 = !{!"[44] ctpop_i32 [t2],t2"}
!48 = !{!"[45] ctpop_i64 [t2],t2"}
!49 = !{!"[46] divs_i32 [t2],t0,t1"}
!50 = !{!"[47] divs_i64 [t2],t0,t1"}
!51 = !{!"[48] divu_i32 [t2],t0,t1"}
!52 = !{!"[49] divu_i64 [t2],t0,t1"}
!53 = !{!"[50] rems_i32 [t2],t0,t1"}
!54 = !{!"[51] rems_i64 [t2],t0,t1"}
!55 = !{!"[52] remu_i32 [t2],t0,t1"}
!56 = !{!"[53] remu_i64 [t2],t0,t1"}
!57 = !{!"[54] sar_i32 [t2],t0,t1"}
!58 = !{!"[55] sar_i64 [t2],t0,t1"}
!59 = !{!"[56] and_i32 [t2],t0,t1"}
!60 = !{!"[57] and_i64 [t2],t0,t1"}
!61 = !{!"[58] mul_i32 [t2],t0,t1"}
!62 = !{!"[59] mul_i64 [t2],t0,t1"}
!63 = !{!"[60] or_i32 [t2],t0,t1"}
!64 = !{!"[61] or_i64 [t2],t0,t1"}
!65 = !{!"[62] shl_i32 [t2],t0,t1"}
!66 = !{!"[63] shl_i64 [t2],t0,t1"}
!67 = !{!"[64] shr_i32 [t2],t0,t1"}
!68 = !{!"[65] shr_i64 [t2],t0,t1"}
!69 = !{!"[66] xor_i32 [t2],t0,t1"}
!70 = !{!"[67] xor_i64 [t2],t0,t1"}
!71 = !{!"[68] sarv_vec v128,e8,[t8],t3,t4"}
!72 = !{!"[69] sarv_vec v128,e32,[t8],t3,t4"}
!73 = !{!"[70] shlv_vec v128,e8,[t8],t3,t4"}
!74 = !{!"[71] shlv_vec v128,e32,[t8],t3,t4"}
!75 = !{!"[72] shrv_vec v128,e8,[t8],t3,t4"}
!76 = !{!"[73] shrv_vec v128,e32,[t8],t3,t4"}
!77 = !{!"[74] and_vec v128,e8,[t8],t3,t4"}
!78 = !{!"[75] and_vec v128,e32,[t8],t3,t4"}
!79 = !{!"[76] mul_vec v128,e8,[t8],t3,t4"}
!80 = !{!"[77] mul_vec v128,e32,[t8],t3,t4"}
!81 = !{!"[78] or_vec v128,e8,[t8],t3,t4"}
!82 = !{!"[79] or_vec v128,e32,[t8],t3,t4"}
!83 = !{!"[80] xor_vec v128,e8,[t8],t3,t4"}
!84 = !{!"[81] xor_vec v128,e32,[t8],t3,t4"}
!85 = !{!"[82] func_addr t9,0x55aa,0x0"}
!86 = !{!"[83] tail_call_qemuaot t9 VEC_ARGS:"}
