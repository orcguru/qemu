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
  %tmp2.stack = alloca <2 x i64>, align 16
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
  store i32 %T2.s1, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !5
  store i1 %T2.c1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !5
; ======== TCG [3] addco_i64 [t2],t0,t1 ========
  %T3.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !6
  %T3.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !6
  %T3.r1 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T3.tmp0, i64 %T3.tmp1), !tcg.op !6
  %T3.s1 = extractvalue { i64, i1 } %T3.r1, 0, !tcg.op !6
  %T3.c1 = extractvalue { i64, i1 } %T3.r1, 1, !tcg.op !6
  store i64 %T3.s1, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !6
  store i1 %T3.c1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !6
; ======== TCG [4] addci_i32 [t2],t0,t1 ========
  %T4.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !7
  %T4.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !7
  %T4.r1 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T4.tmp0, i32 %T4.tmp1), !tcg.op !7
  %T4.s1 = extractvalue { i32, i1 } %T4.r1, 0, !tcg.op !7
  %T4.c1 = extractvalue { i32, i1 } %T4.r1, 1, !tcg.op !7
  %T4.ci = load i1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !7
  %T4.ze_ci = zext i1 %T4.ci to i32, !tcg.op !7
  %T4.r2 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T4.s1, i32 %T4.ze_ci), !tcg.op !7
  %T4.s2 = extractvalue { i32, i1 } %T4.r2, 0, !tcg.op !7
  store i32 %T4.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !7
; ======== TCG [5] addci_i64 [t2],t0,t1 ========
  %T5.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !8
  %T5.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !8
  %T5.r1 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T5.tmp0, i64 %T5.tmp1), !tcg.op !8
  %T5.s1 = extractvalue { i64, i1 } %T5.r1, 0, !tcg.op !8
  %T5.c1 = extractvalue { i64, i1 } %T5.r1, 1, !tcg.op !8
  %T5.ci = load i1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !8
  %T5.ze_ci = zext i1 %T5.ci to i64, !tcg.op !8
  %T5.r2 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T5.s1, i64 %T5.ze_ci), !tcg.op !8
  %T5.s2 = extractvalue { i64, i1 } %T5.r2, 0, !tcg.op !8
  store i64 %T5.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !8
; ======== TCG [6] addcio_i32 [t2],t0,t1 ========
  %T6.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !9
  %T6.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !9
  %T6.r1 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T6.tmp0, i32 %T6.tmp1), !tcg.op !9
  %T6.s1 = extractvalue { i32, i1 } %T6.r1, 0, !tcg.op !9
  %T6.c1 = extractvalue { i32, i1 } %T6.r1, 1, !tcg.op !9
  %T6.ci = load i1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !9
  %T6.ze_ci = zext i1 %T6.ci to i32, !tcg.op !9
  %T6.r2 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T6.s1, i32 %T6.ze_ci), !tcg.op !9
  %T6.s2 = extractvalue { i32, i1 } %T6.r2, 0, !tcg.op !9
  store i32 %T6.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !9
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
  %T7.ze_ci = zext i1 %T7.ci to i64, !tcg.op !10
  %T7.r2 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T7.s1, i64 %T7.ze_ci), !tcg.op !10
  %T7.s2 = extractvalue { i64, i1 } %T7.r2, 0, !tcg.op !10
  store i64 %T7.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !10
  %T7.c2 = extractvalue { i64, i1 } %T7.r2, 1, !tcg.op !10
  %T7.co = or i1 %T7.c1, %T7.c2, !tcg.op !10
  store i1 %T7.co, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !10
; ======== TCG [8] subbo_i32 [t2],t0,t1 ========
  %T8.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !11
  %T8.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !11
  %T8.r1 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T8.tmp0, i32 %T8.tmp1), !tcg.op !11
  %T8.s1 = extractvalue { i32, i1 } %T8.r1, 0, !tcg.op !11
  %T8.c1 = extractvalue { i32, i1 } %T8.r1, 1, !tcg.op !11
  store i32 %T8.s1, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !11
  store i1 %T8.c1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !11
; ======== TCG [9] subbo_i64 [t2],t0,t1 ========
  %T9.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !12
  %T9.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !12
  %T9.r1 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T9.tmp0, i64 %T9.tmp1), !tcg.op !12
  %T9.s1 = extractvalue { i64, i1 } %T9.r1, 0, !tcg.op !12
  %T9.c1 = extractvalue { i64, i1 } %T9.r1, 1, !tcg.op !12
  store i64 %T9.s1, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !12
  store i1 %T9.c1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !12
; ======== TCG [10] subbi_i32 [t2],t0,t1 ========
  %T10.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !13
  %T10.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !13
  %T10.r1 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T10.tmp0, i32 %T10.tmp1), !tcg.op !13
  %T10.s1 = extractvalue { i32, i1 } %T10.r1, 0, !tcg.op !13
  %T10.c1 = extractvalue { i32, i1 } %T10.r1, 1, !tcg.op !13
  %T10.ci = load i1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !13
  %T10.ze_ci = zext i1 %T10.ci to i32, !tcg.op !13
  %T10.r2 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T10.s1, i32 %T10.ze_ci), !tcg.op !13
  %T10.s2 = extractvalue { i32, i1 } %T10.r2, 0, !tcg.op !13
  store i32 %T10.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !13
; ======== TCG [11] subbi_i64 [t2],t0,t1 ========
  %T11.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !14
  %T11.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !14
  %T11.r1 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T11.tmp0, i64 %T11.tmp1), !tcg.op !14
  %T11.s1 = extractvalue { i64, i1 } %T11.r1, 0, !tcg.op !14
  %T11.c1 = extractvalue { i64, i1 } %T11.r1, 1, !tcg.op !14
  %T11.ci = load i1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !14
  %T11.ze_ci = zext i1 %T11.ci to i64, !tcg.op !14
  %T11.r2 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T11.s1, i64 %T11.ze_ci), !tcg.op !14
  %T11.s2 = extractvalue { i64, i1 } %T11.r2, 0, !tcg.op !14
  store i64 %T11.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !14
; ======== TCG [12] subbio_i32 [t2],t0,t1 ========
  %T12.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !15
  %T12.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !15
  %T12.r1 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T12.tmp0, i32 %T12.tmp1), !tcg.op !15
  %T12.s1 = extractvalue { i32, i1 } %T12.r1, 0, !tcg.op !15
  %T12.c1 = extractvalue { i32, i1 } %T12.r1, 1, !tcg.op !15
  %T12.ci = load i1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !15
  %T12.ze_ci = zext i1 %T12.ci to i32, !tcg.op !15
  %T12.r2 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T12.s1, i32 %T12.ze_ci), !tcg.op !15
  %T12.s2 = extractvalue { i32, i1 } %T12.r2, 0, !tcg.op !15
  store i32 %T12.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !15
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
  %T13.ze_ci = zext i1 %T13.ci to i64, !tcg.op !16
  %T13.r2 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T13.s1, i64 %T13.ze_ci), !tcg.op !16
  %T13.s2 = extractvalue { i64, i1 } %T13.r2, 0, !tcg.op !16
  store i64 %T13.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !16
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
  store i32 %T14.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !17
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
  store i64 %T15.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !18
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
  store i32 %T16.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !19
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
  store i64 %T17.s2, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !20
  %T17.c2 = extractvalue { i64, i1 } %T17.r2, 1, !tcg.op !20
  %T17.co = or i1 %T17.c1, %T17.c2, !tcg.op !20
  store i1 %T17.co, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !20
; ======== TCG [18] add_i32 [t2],t0,t1 ========
  %T18.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !21
  %T18.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !21
  %T18.out = add i32 %T18.tmp0, %T18.tmp1, !tcg.op !21
  store i32 %T18.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !21
; ======== TCG [19] add_i64 [t2],t0,t1 ========
  %T19.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !22
  %T19.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !22
  %T19.out = add i64 %T19.tmp0, %T19.tmp1, !tcg.op !22
  store i64 %T19.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !22
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
  store i32 %T27.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !30
; ======== TCG [28] sub_i64 [t2],t0,t1 ========
  %T28.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !31
  %T28.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !31
  %T28.out = sub i64 %T28.tmp0, %T28.tmp1, !tcg.op !31
  store i64 %T28.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !31
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
  %T31.tmp0.tr = trunc i64 %T31.tmp0 to i32, !tcg.op !34
  store i32 %T31.tmp0.tr, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !34
; ======== TCG [32] mov_i32 [t2],t0 ========
  %T32.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !35
  store i32 %T32.tmp0, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !35
; ======== TCG [33] mov_i64 [t2],t0 ========
  %T33.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !36
  store i64 %T33.tmp0, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !36
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
  %T38.not_sel = xor <16 x i8> %T38.tmp3, splat (i8 -1), !tcg.op !41
  %T38.and_b_not_sel = and <16 x i8> %T38.tmp5, %T38.not_sel, !tcg.op !41
  %T38.or = or <16 x i8> %T38.and_a_sel, %T38.and_b_not_sel, !tcg.op !41
  store <16 x i8> %T38.or, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !41
; ======== TCG [39] bitsel_vec v128,e32,[t8],t3,t4,t5 ========
  %T39.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !42
  %T39.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !42
  %T39.tmp5 = load <4 x i32>, ptr %tmp5.stack, align 16, !tbaa !0, !tcg.op !42
  %T39.and_a_sel = and <4 x i32> %T39.tmp4, %T39.tmp3, !tcg.op !42
  %T39.not_sel = xor <4 x i32> %T39.tmp3, splat (i32 -1), !tcg.op !42
  %T39.and_b_not_sel = and <4 x i32> %T39.tmp5, %T39.not_sel, !tcg.op !42
  %T39.or = or <4 x i32> %T39.and_a_sel, %T39.and_b_not_sel, !tcg.op !42
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
  %T42.not_sel = xor <16 x i8> %T42.predicate, splat (i8 -1), !tcg.op !45
  %T42.and_b_not_sel = and <16 x i8> %T42.tmp7, %T42.not_sel, !tcg.op !45
  %T42.or = or <16 x i8> %T42.and_a_sel, %T42.and_b_not_sel, !tcg.op !45
  store <16 x i8> %T42.or, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !45
; ======== TCG [43] cmpsel_vec v128,e32,[t8],t3,t4,t6,t7,gt ========
  %T43.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !46
  %T43.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !46
  %T43.bool = icmp sgt <4 x i32> %T43.tmp3, %T43.tmp4, !tcg.op !46
  %T43.predicate = select <4 x i1> %T43.bool, <4 x i32> splat (i32 -1), <4 x i32> zeroinitializer, !tcg.op !46
  %T43.tmp6 = load <4 x i32>, ptr %tmp6.stack, align 16, !tbaa !0, !tcg.op !46
  %T43.tmp7 = load <4 x i32>, ptr %tmp7.stack, align 16, !tbaa !0, !tcg.op !46
  %T43.and_a_sel = and <4 x i32> %T43.tmp6, %T43.predicate, !tcg.op !46
  %T43.not_sel = xor <4 x i32> %T43.predicate, splat (i32 -1), !tcg.op !46
  %T43.and_b_not_sel = and <4 x i32> %T43.tmp7, %T43.not_sel, !tcg.op !46
  %T43.or = or <4 x i32> %T43.and_a_sel, %T43.and_b_not_sel, !tcg.op !46
  store <4 x i32> %T43.or, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !46
; ======== TCG [44] ctpop_i32 [t2],t2 ========
  %T44.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !47
  %T44.pop = call i32 @llvm.ctpop.i32(i32 %T44.tmp2), !tcg.op !47
  store i32 %T44.pop, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !47
; ======== TCG [45] ctpop_i64 [t2],t2 ========
  %T45.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !48
  %T45.pop = call i64 @llvm.ctpop.i64(i64 %T45.tmp2), !tcg.op !48
  store i64 %T45.pop, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !48
; ======== TCG [46] divs_i32 [t2],t0,t1 ========
  %T46.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !49
  %T46.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !49
  %T46.out = sdiv i32 %T46.tmp0, %T46.tmp1, !tcg.op !49
  store i32 %T46.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !49
; ======== TCG [47] divs_i64 [t2],t0,t1 ========
  %T47.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !50
  %T47.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !50
  %T47.out = sdiv i64 %T47.tmp0, %T47.tmp1, !tcg.op !50
  store i64 %T47.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !50
; ======== TCG [48] divu_i32 [t2],t0,t1 ========
  %T48.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !51
  %T48.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !51
  %T48.out = udiv i32 %T48.tmp0, %T48.tmp1, !tcg.op !51
  store i32 %T48.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !51
; ======== TCG [49] divu_i64 [t2],t0,t1 ========
  %T49.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !52
  %T49.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !52
  %T49.out = udiv i64 %T49.tmp0, %T49.tmp1, !tcg.op !52
  store i64 %T49.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !52
; ======== TCG [50] rems_i32 [t2],t0,t1 ========
  %T50.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !53
  %T50.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !53
  %T50.out = srem i32 %T50.tmp0, %T50.tmp1, !tcg.op !53
  store i32 %T50.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !53
; ======== TCG [51] rems_i64 [t2],t0,t1 ========
  %T51.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !54
  %T51.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !54
  %T51.out = srem i64 %T51.tmp0, %T51.tmp1, !tcg.op !54
  store i64 %T51.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !54
; ======== TCG [52] remu_i32 [t2],t0,t1 ========
  %T52.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !55
  %T52.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !55
  %T52.out = urem i32 %T52.tmp0, %T52.tmp1, !tcg.op !55
  store i32 %T52.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !55
; ======== TCG [53] remu_i64 [t2],t0,t1 ========
  %T53.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !56
  %T53.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !56
  %T53.out = urem i64 %T53.tmp0, %T53.tmp1, !tcg.op !56
  store i64 %T53.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !56
; ======== TCG [54] sar_i32 [t2],t0,t1 ========
  %T54.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !57
  %T54.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !57
  %T54.out = ashr i32 %T54.tmp0, %T54.tmp1, !tcg.op !57
  store i32 %T54.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !57
; ======== TCG [55] sar_i64 [t2],t0,t1 ========
  %T55.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !58
  %T55.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !58
  %T55.out = ashr i64 %T55.tmp0, %T55.tmp1, !tcg.op !58
  store i64 %T55.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !58
; ======== TCG [56] and_i32 [t2],t0,t1 ========
  %T56.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !59
  %T56.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !59
  %T56.out = and i32 %T56.tmp0, %T56.tmp1, !tcg.op !59
  store i32 %T56.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !59
; ======== TCG [57] and_i64 [t2],t0,t1 ========
  %T57.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !60
  %T57.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !60
  %T57.out = and i64 %T57.tmp0, %T57.tmp1, !tcg.op !60
  store i64 %T57.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !60
; ======== TCG [58] mul_i32 [t2],t0,t1 ========
  %T58.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !61
  %T58.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !61
  %T58.out = mul i32 %T58.tmp0, %T58.tmp1, !tcg.op !61
  store i32 %T58.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !61
; ======== TCG [59] mul_i64 [t2],t0,t1 ========
  %T59.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !62
  %T59.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !62
  %T59.out = mul i64 %T59.tmp0, %T59.tmp1, !tcg.op !62
  store i64 %T59.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !62
; ======== TCG [60] or_i32 [t2],t0,t1 ========
  %T60.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !63
  %T60.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !63
  %T60.out = or i32 %T60.tmp0, %T60.tmp1, !tcg.op !63
  store i32 %T60.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !63
; ======== TCG [61] or_i64 [t2],t0,t1 ========
  %T61.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !64
  %T61.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !64
  %T61.out = or i64 %T61.tmp0, %T61.tmp1, !tcg.op !64
  store i64 %T61.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !64
; ======== TCG [62] shl_i32 [t2],t0,t1 ========
  %T62.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !65
  %T62.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !65
  %T62.out = shl i32 %T62.tmp0, %T62.tmp1, !tcg.op !65
  store i32 %T62.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !65
; ======== TCG [63] shl_i64 [t2],t0,t1 ========
  %T63.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !66
  %T63.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !66
  %T63.out = shl i64 %T63.tmp0, %T63.tmp1, !tcg.op !66
  store i64 %T63.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !66
; ======== TCG [64] shr_i32 [t2],t0,t1 ========
  %T64.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !67
  %T64.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !67
  %T64.out = lshr i32 %T64.tmp0, %T64.tmp1, !tcg.op !67
  store i32 %T64.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !67
; ======== TCG [65] shr_i64 [t2],t0,t1 ========
  %T65.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !68
  %T65.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !68
  %T65.out = lshr i64 %T65.tmp0, %T65.tmp1, !tcg.op !68
  store i64 %T65.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !68
; ======== TCG [66] xor_i32 [t2],t0,t1 ========
  %T66.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !69
  %T66.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !69
  %T66.out = xor i32 %T66.tmp0, %T66.tmp1, !tcg.op !69
  store i32 %T66.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !69
; ======== TCG [67] xor_i64 [t2],t0,t1 ========
  %T67.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !70
  %T67.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !70
  %T67.out = xor i64 %T67.tmp0, %T67.tmp1, !tcg.op !70
  store i64 %T67.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !70
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
; ======== TCG [82] clz_i32 [t2],t2,t0 ========
  %T82.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !85
  %T82.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !85
  %T82.icmp_eq_zero = icmp eq i32 %T82.tmp2, 0, !tcg.op !85
  br i1 %T82.icmp_eq_zero, label %T82.z, label %T82.nz, !tcg.op !85

T82.z:                                            ; preds = %entry
  br label %T82.merge, !tcg.op !85

T82.nz:                                           ; preds = %entry
  %T82.ct_result = call i32 @llvm.ctlz.i32.i32(i32 %T82.tmp2), !tcg.op !85
  br label %T82.merge, !tcg.op !85

T82.merge:                                        ; preds = %T82.nz, %T82.z
  %T82.phi = phi i32 [ %T82.tmp0, %T82.z ], [ %T82.ct_result, %T82.nz ], !tcg.op !85
  store i32 %T82.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !85
; ======== TCG [83] clz_i64 [t2],t2,t0 ========
  %T83.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !86
  %T83.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !86
  %T83.icmp_eq_zero = icmp eq i64 %T83.tmp2, 0, !tcg.op !86
  br i1 %T83.icmp_eq_zero, label %T83.z, label %T83.nz, !tcg.op !86

T83.z:                                            ; preds = %T82.merge
  br label %T83.merge, !tcg.op !86

T83.nz:                                           ; preds = %T82.merge
  %T83.ct_result = call i64 @llvm.ctlz.i64.i64(i64 %T83.tmp2), !tcg.op !86
  br label %T83.merge, !tcg.op !86

T83.merge:                                        ; preds = %T83.nz, %T83.z
  %T83.phi = phi i64 [ %T83.tmp0, %T83.z ], [ %T83.ct_result, %T83.nz ], !tcg.op !86
  store i64 %T83.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !86
; ======== TCG [84] ctz_i32 [t2],t2,t0 ========
  %T84.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !87
  %T84.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !87
  %T84.icmp_eq_zero = icmp eq i32 %T84.tmp2, 0, !tcg.op !87
  br i1 %T84.icmp_eq_zero, label %T84.z, label %T84.nz, !tcg.op !87

T84.z:                                            ; preds = %T83.merge
  br label %T84.merge, !tcg.op !87

T84.nz:                                           ; preds = %T83.merge
  %T84.ct_result = call i32 @llvm.cttz.i32.i32(i32 %T84.tmp2), !tcg.op !87
  br label %T84.merge, !tcg.op !87

T84.merge:                                        ; preds = %T84.nz, %T84.z
  %T84.phi = phi i32 [ %T84.tmp0, %T84.z ], [ %T84.ct_result, %T84.nz ], !tcg.op !87
  store i32 %T84.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !87
; ======== TCG [85] ctz_i64 [t2],t2,t0 ========
  %T85.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !88
  %T85.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !88
  %T85.icmp_eq_zero = icmp eq i64 %T85.tmp2, 0, !tcg.op !88
  br i1 %T85.icmp_eq_zero, label %T85.z, label %T85.nz, !tcg.op !88

T85.z:                                            ; preds = %T84.merge
  br label %T85.merge, !tcg.op !88

T85.nz:                                           ; preds = %T84.merge
  %T85.ct_result = call i64 @llvm.cttz.i64.i64(i64 %T85.tmp2), !tcg.op !88
  br label %T85.merge, !tcg.op !88

T85.merge:                                        ; preds = %T85.nz, %T85.z
  %T85.phi = phi i64 [ %T85.tmp0, %T85.z ], [ %T85.ct_result, %T85.nz ], !tcg.op !88
  store i64 %T85.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !88
; ======== TCG [86] smax_vec v128,e8,[t8],t3,t4 ========
  %T86.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !89
  %T86.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !89
  %T86.out = call <16 x i8> @llvm.smax.v16i8.v16i8(<16 x i8> %T86.tmp3, <16 x i8> %T86.tmp4), !tcg.op !89
  store <16 x i8> %T86.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !89
; ======== TCG [87] smax_vec v128,e32,[t8],t3,t4 ========
  %T87.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !90
  %T87.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !90
  %T87.out = call <4 x i32> @llvm.smax.v4i32.v4i32(<4 x i32> %T87.tmp3, <4 x i32> %T87.tmp4), !tcg.op !90
  store <4 x i32> %T87.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !90
; ======== TCG [88] smin_vec v128,e8,[t8],t3,t4 ========
  %T88.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !91
  %T88.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !91
  %T88.out = call <16 x i8> @llvm.smin.v16i8.v16i8(<16 x i8> %T88.tmp3, <16 x i8> %T88.tmp4), !tcg.op !91
  store <16 x i8> %T88.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !91
; ======== TCG [89] smin_vec v128,e32,[t8],t3,t4 ========
  %T89.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !92
  %T89.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !92
  %T89.out = call <4 x i32> @llvm.smin.v4i32.v4i32(<4 x i32> %T89.tmp3, <4 x i32> %T89.tmp4), !tcg.op !92
  store <4 x i32> %T89.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !92
; ======== TCG [90] ssadd_vec v128,e8,[t8],t3,t4 ========
  %T90.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !93
  %T90.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !93
  %T90.out = call <16 x i8> @llvm.sadd.sat.v16i8.v16i8(<16 x i8> %T90.tmp3, <16 x i8> %T90.tmp4), !tcg.op !93
  store <16 x i8> %T90.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !93
; ======== TCG [91] ssadd_vec v128,e32,[t8],t3,t4 ========
  %T91.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !94
  %T91.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !94
  %T91.out = call <4 x i32> @llvm.sadd.sat.v4i32.v4i32(<4 x i32> %T91.tmp3, <4 x i32> %T91.tmp4), !tcg.op !94
  store <4 x i32> %T91.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !94
; ======== TCG [92] sssub_vec v128,e8,[t8],t3,t4 ========
  %T92.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !95
  %T92.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !95
  %T92.out = call <16 x i8> @llvm.ssub.sat.v16i8.v16i8(<16 x i8> %T92.tmp3, <16 x i8> %T92.tmp4), !tcg.op !95
  store <16 x i8> %T92.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !95
; ======== TCG [93] sssub_vec v128,e32,[t8],t3,t4 ========
  %T93.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !96
  %T93.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !96
  %T93.out = call <4 x i32> @llvm.ssub.sat.v4i32.v4i32(<4 x i32> %T93.tmp3, <4 x i32> %T93.tmp4), !tcg.op !96
  store <4 x i32> %T93.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !96
; ======== TCG [94] usadd_vec v128,e8,[t8],t3,t4 ========
  %T94.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !97
  %T94.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !97
  %T94.out = call <16 x i8> @llvm.uadd.sat.v16i8.v16i8(<16 x i8> %T94.tmp3, <16 x i8> %T94.tmp4), !tcg.op !97
  store <16 x i8> %T94.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !97
; ======== TCG [95] usadd_vec v128,e32,[t8],t3,t4 ========
  %T95.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !98
  %T95.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !98
  %T95.out = call <4 x i32> @llvm.uadd.sat.v4i32.v4i32(<4 x i32> %T95.tmp3, <4 x i32> %T95.tmp4), !tcg.op !98
  store <4 x i32> %T95.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !98
; ======== TCG [96] ussub_vec v128,e8,[t8],t3,t4 ========
  %T96.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !99
  %T96.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !99
  %T96.out = call <16 x i8> @llvm.usub.sat.v16i8.v16i8(<16 x i8> %T96.tmp3, <16 x i8> %T96.tmp4), !tcg.op !99
  store <16 x i8> %T96.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !99
; ======== TCG [97] ussub_vec v128,e32,[t8],t3,t4 ========
  %T97.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !100
  %T97.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !100
  %T97.out = call <4 x i32> @llvm.usub.sat.v4i32.v4i32(<4 x i32> %T97.tmp3, <4 x i32> %T97.tmp4), !tcg.op !100
  store <4 x i32> %T97.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !100
; ======== TCG [98] rotl_i32 [t2],t2,t0 ========
  %T98.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !101
  %T98.shift_value_masked = and i32 %T98.tmp0, 31, !tcg.op !101
  %T98.shift_l = and i32 %T98.tmp0, 31, !tcg.op !101
  %T98.shift_r = sub i32 32, %T98.shift_l, !tcg.op !101
  %T98.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !101
  %T98.shl = shl i32 %T98.tmp2, %T98.shift_l, !tcg.op !101
  %T98.lshr = lshr i32 %T98.tmp2, %T98.shift_r, !tcg.op !101
  %T98.or = or i32 %T98.shl, %T98.lshr, !tcg.op !101
  %T98.bool = icmp eq i32 %T98.shift_value_masked, 0, !tcg.op !101
  %T98.tmp21 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !101
  %T98.avoid_poison = select i1 %T98.bool, i32 %T98.tmp21, i32 %T98.or, !tcg.op !101
  store i32 %T98.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !101
; ======== TCG [99] rotl_i64 [t2],t2,t0 ========
  %T99.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !102
  %T99.shift_value_masked = and i64 %T99.tmp0, 63, !tcg.op !102
  %T99.shift_l = and i64 %T99.tmp0, 63, !tcg.op !102
  %T99.shift_r = sub i64 64, %T99.shift_l, !tcg.op !102
  %T99.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !102
  %T99.shl = shl i64 %T99.tmp2, %T99.shift_l, !tcg.op !102
  %T99.lshr = lshr i64 %T99.tmp2, %T99.shift_r, !tcg.op !102
  %T99.or = or i64 %T99.shl, %T99.lshr, !tcg.op !102
  %T99.bool = icmp eq i64 %T99.shift_value_masked, 0, !tcg.op !102
  %T99.tmp22 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !102
  %T99.avoid_poison = select i1 %T99.bool, i64 %T99.tmp22, i64 %T99.or, !tcg.op !102
  store i64 %T99.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !102
; ======== TCG [100] rotl_i32 [t2],t2,0x4 ========
  %T100.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !103
  %T100.shl = shl i32 %T100.tmp2, 4, !tcg.op !103
  %T100.lshr = lshr i32 %T100.tmp2, 28, !tcg.op !103
  %T100.or = or i32 %T100.shl, %T100.lshr, !tcg.op !103
  %T100.tmp23 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !103
  %T100.avoid_poison = select i1 false, i32 %T100.tmp23, i32 %T100.or, !tcg.op !103
  store i32 %T100.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !103
; ======== TCG [101] rotl_i64 [t2],t2,0x100 ========
  %T101.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !104
  %T101.shl = shl i64 %T101.tmp2, 0, !tcg.op !104
  %T101.lshr = lshr i64 %T101.tmp2, 64, !tcg.op !104
  %T101.or = or i64 %T101.shl, %T101.lshr, !tcg.op !104
  %T101.tmp24 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !104
  %T101.avoid_poison = select i1 true, i64 %T101.tmp24, i64 %T101.or, !tcg.op !104
  store i64 %T101.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !104
; ======== TCG [102] rotli_vec v128,e8,[t8],t3,0x2 ========
  %T102.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !105
  %T102.shl = shl <16 x i8> %T102.tmp3, splat (i8 2), !tcg.op !105
  %T102.lshr = lshr <16 x i8> %T102.tmp3, splat (i8 6), !tcg.op !105
  %T102.or = or <16 x i8> %T102.shl, %T102.lshr, !tcg.op !105
  %T102.tmp35 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !105
  %T102.avoid_poison = select i1 false, <16 x i8> %T102.tmp35, <16 x i8> %T102.or, !tcg.op !105
  store <16 x i8> %T102.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !105
; ======== TCG [103] rotli_vec v128,e8,[t8],t3,0x8 ========
  %T103.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !106
  %T103.shl = shl <16 x i8> %T103.tmp3, zeroinitializer, !tcg.op !106
  %T103.lshr = lshr <16 x i8> %T103.tmp3, splat (i8 8), !tcg.op !106
  %T103.or = or <16 x i8> %T103.shl, %T103.lshr, !tcg.op !106
  %T103.tmp36 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !106
  %T103.avoid_poison = select i1 true, <16 x i8> %T103.tmp36, <16 x i8> %T103.or, !tcg.op !106
  store <16 x i8> %T103.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !106
; ======== TCG [104] rotli_vec v128,e8,[t8],t3,0x9 ========
  %T104.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !107
  %T104.shl = shl <16 x i8> %T104.tmp3, splat (i8 1), !tcg.op !107
  %T104.lshr = lshr <16 x i8> %T104.tmp3, splat (i8 7), !tcg.op !107
  %T104.or = or <16 x i8> %T104.shl, %T104.lshr, !tcg.op !107
  %T104.tmp37 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !107
  %T104.avoid_poison = select i1 false, <16 x i8> %T104.tmp37, <16 x i8> %T104.or, !tcg.op !107
  store <16 x i8> %T104.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !107
; ======== TCG [105] rotli_vec v128,e16,[t8],t3,0x12 ========
  %T105.tmp3 = load <8 x i16>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !108
  %T105.shl = shl <8 x i16> %T105.tmp3, splat (i16 2), !tcg.op !108
  %T105.lshr = lshr <8 x i16> %T105.tmp3, splat (i16 14), !tcg.op !108
  %T105.or = or <8 x i16> %T105.shl, %T105.lshr, !tcg.op !108
  %T105.tmp38 = load <8 x i16>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !108
  %T105.avoid_poison = select i1 false, <8 x i16> %T105.tmp38, <8 x i16> %T105.or, !tcg.op !108
  store <8 x i16> %T105.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !108
; ======== TCG [106] rotli_vec v128,e32,[t8],t3,0x21 ========
  %T106.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !109
  %T106.shl = shl <4 x i32> %T106.tmp3, splat (i32 1), !tcg.op !109
  %T106.lshr = lshr <4 x i32> %T106.tmp3, splat (i32 31), !tcg.op !109
  %T106.or = or <4 x i32> %T106.shl, %T106.lshr, !tcg.op !109
  %T106.tmp39 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !109
  %T106.avoid_poison = select i1 false, <4 x i32> %T106.tmp39, <4 x i32> %T106.or, !tcg.op !109
  store <4 x i32> %T106.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !109
; ======== TCG [107] rotli_vec v128,e64,[t8],t3,0x42 ========
  %T107.tmp3 = load <2 x i64>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !110
  %T107.shl = shl <2 x i64> %T107.tmp3, splat (i64 2), !tcg.op !110
  %T107.lshr = lshr <2 x i64> %T107.tmp3, splat (i64 62), !tcg.op !110
  %T107.or = or <2 x i64> %T107.shl, %T107.lshr, !tcg.op !110
  %T107.tmp310 = load <2 x i64>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !110
  %T107.avoid_poison = select i1 false, <2 x i64> %T107.tmp310, <2 x i64> %T107.or, !tcg.op !110
  store <2 x i64> %T107.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !110
; ======== TCG [108] rotls_vec v128,e32,[t8],t3,t2 ========
  %T108.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !111
  %T108.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T108.s, i64 0, !tcg.op !111
  %T108.shift.ie11 = insertelement <4 x i32> %T108.shift.ie, i32 %T108.s, i64 1, !tcg.op !111
  %T108.shift.ie12 = insertelement <4 x i32> %T108.shift.ie11, i32 %T108.s, i64 2, !tcg.op !111
  %T108.shift.ie13 = insertelement <4 x i32> %T108.shift.ie12, i32 %T108.s, i64 3, !tcg.op !111
  %T108.shift_value_masked = and i32 %T108.s, 31, !tcg.op !111
  %T108.shift_l = and <4 x i32> %T108.shift.ie13, splat (i32 31), !tcg.op !111
  %T108.shift_r = sub <4 x i32> splat (i32 32), %T108.shift_l, !tcg.op !111
  %T108.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !111
  %T108.shl = shl <4 x i32> %T108.tmp3, %T108.shift_l, !tcg.op !111
  %T108.lshr = lshr <4 x i32> %T108.tmp3, %T108.shift_r, !tcg.op !111
  %T108.or = or <4 x i32> %T108.shl, %T108.lshr, !tcg.op !111
  %T108.bool = icmp eq i32 %T108.shift_value_masked, 0, !tcg.op !111
  %T108.tmp314 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !111
  %T108.avoid_poison = select i1 %T108.bool, <4 x i32> %T108.tmp314, <4 x i32> %T108.or, !tcg.op !111
  store <4 x i32> %T108.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !111
; ======== TCG [109] rotlv_vec v128,e32,[t8],t3,t4 ========
  %T109.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !112
  %T109.shift_l = and <4 x i32> %T109.tmp4, splat (i32 31), !tcg.op !112
  %T109.shift_r = sub <4 x i32> splat (i32 32), %T109.shift_l, !tcg.op !112
  %T109.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !112
  %T109.shl = shl <4 x i32> %T109.tmp3, %T109.shift_l, !tcg.op !112
  %T109.lshr = lshr <4 x i32> %T109.tmp3, %T109.shift_r, !tcg.op !112
  %T109.or = or <4 x i32> %T109.shl, %T109.lshr, !tcg.op !112
  store <4 x i32> %T109.or, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !112
; ======== TCG [110] rotr_i32 [t2],t2,t0 ========
  %T110.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !113
  %T110.shift_value_masked = and i32 %T110.tmp0, 31, !tcg.op !113
  %T110.shift_r = and i32 %T110.tmp0, 31, !tcg.op !113
  %T110.shift_l = sub i32 32, %T110.shift_r, !tcg.op !113
  %T110.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !113
  %T110.shl = shl i32 %T110.tmp2, %T110.shift_l, !tcg.op !113
  %T110.lshr = lshr i32 %T110.tmp2, %T110.shift_r, !tcg.op !113
  %T110.or = or i32 %T110.shl, %T110.lshr, !tcg.op !113
  %T110.bool = icmp eq i32 %T110.shift_value_masked, 0, !tcg.op !113
  %T110.tmp215 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !113
  %T110.avoid_poison = select i1 %T110.bool, i32 %T110.tmp215, i32 %T110.or, !tcg.op !113
  store i32 %T110.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !113
; ======== TCG [111] rotr_i64 [t2],t2,t0 ========
  %T111.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !114
  %T111.shift_value_masked = and i64 %T111.tmp0, 63, !tcg.op !114
  %T111.shift_r = and i64 %T111.tmp0, 63, !tcg.op !114
  %T111.shift_l = sub i64 64, %T111.shift_r, !tcg.op !114
  %T111.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !114
  %T111.shl = shl i64 %T111.tmp2, %T111.shift_l, !tcg.op !114
  %T111.lshr = lshr i64 %T111.tmp2, %T111.shift_r, !tcg.op !114
  %T111.or = or i64 %T111.shl, %T111.lshr, !tcg.op !114
  %T111.bool = icmp eq i64 %T111.shift_value_masked, 0, !tcg.op !114
  %T111.tmp216 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !114
  %T111.avoid_poison = select i1 %T111.bool, i64 %T111.tmp216, i64 %T111.or, !tcg.op !114
  store i64 %T111.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !114
; ======== TCG [112] rotr_i32 [t2],t2,0x4 ========
  %T112.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !115
  %T112.shl = shl i32 %T112.tmp2, 28, !tcg.op !115
  %T112.lshr = lshr i32 %T112.tmp2, 4, !tcg.op !115
  %T112.or = or i32 %T112.shl, %T112.lshr, !tcg.op !115
  %T112.tmp217 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !115
  %T112.avoid_poison = select i1 false, i32 %T112.tmp217, i32 %T112.or, !tcg.op !115
  store i32 %T112.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !115
; ======== TCG [113] rotr_i64 [t2],t2,0x100 ========
  %T113.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !116
  %T113.shl = shl i64 %T113.tmp2, 64, !tcg.op !116
  %T113.lshr = lshr i64 %T113.tmp2, 0, !tcg.op !116
  %T113.or = or i64 %T113.shl, %T113.lshr, !tcg.op !116
  %T113.tmp218 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !116
  %T113.avoid_poison = select i1 true, i64 %T113.tmp218, i64 %T113.or, !tcg.op !116
  store i64 %T113.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !116
; ======== TCG [114] rotrv_vec v128,e32,[t8],t3,t4 ========
  %T114.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !117
  %T114.shift_r = and <4 x i32> %T114.tmp4, splat (i32 31), !tcg.op !117
  %T114.shift_l = sub <4 x i32> splat (i32 32), %T114.shift_r, !tcg.op !117
  %T114.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !117
  %T114.shl = shl <4 x i32> %T114.tmp3, %T114.shift_l, !tcg.op !117
  %T114.lshr = lshr <4 x i32> %T114.tmp3, %T114.shift_r, !tcg.op !117
  %T114.or = or <4 x i32> %T114.shl, %T114.lshr, !tcg.op !117
  store <4 x i32> %T114.or, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !117
; ======== TCG [115] shli_vec v128,e8,[t8],t3,0x2 ========
  %T115.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !118
  %T115.out = shl <16 x i8> %T115.tmp3, splat (i8 2), !tcg.op !118
  store <16 x i8> %T115.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !118
; ======== TCG [116] shli_vec v128,e8,[t8],t3,0x9 ========
  %T116.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !119
  %T116.out = shl <16 x i8> %T116.tmp3, splat (i8 1), !tcg.op !119
  store <16 x i8> %T116.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !119
; ======== TCG [117] shli_vec v128,e16,[t8],t3,0x11 ========
  %T117.tmp3 = load <8 x i16>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !120
  %T117.out = shl <8 x i16> %T117.tmp3, splat (i16 1), !tcg.op !120
  store <8 x i16> %T117.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !120
; ======== TCG [118] shli_vec v128,e32,[t8],t3,0x21 ========
  %T118.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !121
  %T118.out = shl <4 x i32> %T118.tmp3, splat (i32 1), !tcg.op !121
  store <4 x i32> %T118.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !121
; ======== TCG [119] shli_vec v128,e64,[t8],t3,0x42 ========
  %T119.tmp3 = load <2 x i64>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !122
  %T119.out = shl <2 x i64> %T119.tmp3, splat (i64 2), !tcg.op !122
  store <2 x i64> %T119.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !122
; ======== TCG [120] shls_vec v128,e32,[t8],t3,t2 ========
  %T120.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !123
  %T120.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T120.s, i64 0, !tcg.op !123
  %T120.shift.ie19 = insertelement <4 x i32> %T120.shift.ie, i32 %T120.s, i64 1, !tcg.op !123
  %T120.shift.ie20 = insertelement <4 x i32> %T120.shift.ie19, i32 %T120.s, i64 2, !tcg.op !123
  %T120.shift.ie21 = insertelement <4 x i32> %T120.shift.ie20, i32 %T120.s, i64 3, !tcg.op !123
  %T120.shift = and <4 x i32> %T120.shift.ie21, splat (i32 31), !tcg.op !123
  %T120.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !123
  %T120.out = shl <4 x i32> %T120.tmp3, %T120.shift, !tcg.op !123
  store <4 x i32> %T120.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !123
; ======== TCG [121] shri_vec v128,e32,[t8],t3,0x2 ========
  %T121.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !124
  %T121.out = lshr <4 x i32> %T121.tmp3, splat (i32 2), !tcg.op !124
  store <4 x i32> %T121.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !124
; ======== TCG [122] shrs_vec v128,e32,[t8],t3,t2 ========
  %T122.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !125
  %T122.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T122.s, i64 0, !tcg.op !125
  %T122.shift.ie22 = insertelement <4 x i32> %T122.shift.ie, i32 %T122.s, i64 1, !tcg.op !125
  %T122.shift.ie23 = insertelement <4 x i32> %T122.shift.ie22, i32 %T122.s, i64 2, !tcg.op !125
  %T122.shift.ie24 = insertelement <4 x i32> %T122.shift.ie23, i32 %T122.s, i64 3, !tcg.op !125
  %T122.shift = and <4 x i32> %T122.shift.ie24, splat (i32 31), !tcg.op !125
  %T122.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !125
  %T122.out = lshr <4 x i32> %T122.tmp3, %T122.shift, !tcg.op !125
  store <4 x i32> %T122.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !125
; ======== TCG [123] sari_vec v128,e32,[t8],t3,0x2 ========
  %T123.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !126
  %T123.out = ashr <4 x i32> %T123.tmp3, splat (i32 2), !tcg.op !126
  store <4 x i32> %T123.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !126
; ======== TCG [124] sars_vec v128,e32,[t8],t3,t2 ========
  %T124.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !127
  %T124.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T124.s, i64 0, !tcg.op !127
  %T124.shift.ie25 = insertelement <4 x i32> %T124.shift.ie, i32 %T124.s, i64 1, !tcg.op !127
  %T124.shift.ie26 = insertelement <4 x i32> %T124.shift.ie25, i32 %T124.s, i64 2, !tcg.op !127
  %T124.shift.ie27 = insertelement <4 x i32> %T124.shift.ie26, i32 %T124.s, i64 3, !tcg.op !127
  %T124.shift = and <4 x i32> %T124.shift.ie27, splat (i32 31), !tcg.op !127
  %T124.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !127
  %T124.out = ashr <4 x i32> %T124.tmp3, %T124.shift, !tcg.op !127
  store <4 x i32> %T124.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !127
; ======== TCG [125] andc_i32 [t2],t2,t0 ========
  %T125.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !128
  %T125.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !128
  %T125.not = xor i32 %T125.tmp0, -1, !tcg.op !128
  %T125.and_a_not_b = and i32 %T125.tmp2, %T125.not, !tcg.op !128
  store i32 %T125.and_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !128
; ======== TCG [126] andc_i64 [t2],t2,t0 ========
  %T126.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !129
  %T126.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !129
  %T126.not = xor i64 %T126.tmp0, -1, !tcg.op !129
  %T126.and_a_not_b = and i64 %T126.tmp2, %T126.not, !tcg.op !129
  store i64 %T126.and_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !129
; ======== TCG [127] andc_vec v128,e32,[t8],t3,t4 ========
  %T127.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !130
  %T127.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !130
  %T127.not = xor <4 x i32> %T127.tmp4, splat (i32 -1), !tcg.op !130
  %T127.and_a_not_b = and <4 x i32> %T127.tmp3, %T127.not, !tcg.op !130
  store <4 x i32> %T127.and_a_not_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !130
; ======== TCG [128] nor_i32 [t2],t2,t0 ========
  %T128.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !131
  %T128.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !131
  %T128.or = or i32 %T128.tmp2, %T128.tmp0, !tcg.op !131
  %T128.not_or_a_b = xor i32 %T128.or, -1, !tcg.op !131
  store i32 %T128.not_or_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !131
; ======== TCG [129] nor_i64 [t2],t2,t0 ========
  %T129.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !132
  %T129.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !132
  %T129.or = or i64 %T129.tmp2, %T129.tmp0, !tcg.op !132
  %T129.not_or_a_b = xor i64 %T129.or, -1, !tcg.op !132
  store i64 %T129.not_or_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !132
; ======== TCG [130] nor_vec v128,e32,[t8],t3,t4 ========
  %T130.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !133
  %T130.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !133
  %T130.or = or <4 x i32> %T130.tmp3, %T130.tmp4, !tcg.op !133
  %T130.not_or_a_b = xor <4 x i32> %T130.or, splat (i32 -1), !tcg.op !133
  store <4 x i32> %T130.not_or_a_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !133
; ======== TCG [131] orc_i32 [t2],t2,t0 ========
  %T131.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !134
  %T131.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !134
  %T131.not = xor i32 %T131.tmp0, -1, !tcg.op !134
  %T131.or_a_not_b = or i32 %T131.tmp2, %T131.not, !tcg.op !134
  store i32 %T131.or_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !134
; ======== TCG [132] orc_i64 [t2],t2,t0 ========
  %T132.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !135
  %T132.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !135
  %T132.not = xor i64 %T132.tmp0, -1, !tcg.op !135
  %T132.or_a_not_b = or i64 %T132.tmp2, %T132.not, !tcg.op !135
  store i64 %T132.or_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !135
; ======== TCG [133] orc_vec v128,e32,[t8],t3,t4 ========
  %T133.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !136
  %T133.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !136
  %T133.not = xor <4 x i32> %T133.tmp4, splat (i32 -1), !tcg.op !136
  %T133.or_a_not_b = or <4 x i32> %T133.tmp3, %T133.not, !tcg.op !136
  store <4 x i32> %T133.or_a_not_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !136
; ======== TCG [134] nand_i32 [t2],t2,t0 ========
  %T134.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !137
  %T134.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !137
  %T134.and = and i32 %T134.tmp2, %T134.tmp0, !tcg.op !137
  %T134.not_and_a_b = xor i32 %T134.and, -1, !tcg.op !137
  store i32 %T134.not_and_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !137
; ======== TCG [135] nand_i64 [t2],t2,t0 ========
  %T135.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !138
  %T135.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !138
  %T135.and = and i64 %T135.tmp2, %T135.tmp0, !tcg.op !138
  %T135.not_and_a_b = xor i64 %T135.and, -1, !tcg.op !138
  store i64 %T135.not_and_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !138
; ======== TCG [136] nand_vec v128,e32,[t8],t3,t4 ========
  %T136.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !139
  %T136.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !139
  %T136.and = and <4 x i32> %T136.tmp3, %T136.tmp4, !tcg.op !139
  %T136.not_and_a_b = xor <4 x i32> %T136.and, splat (i32 -1), !tcg.op !139
  store <4 x i32> %T136.not_and_a_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !139
; ======== TCG [137] eqv_i32 [t2],t2,t0 ========
  %T137.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !140
  %T137.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !140
  %T137.xor = xor i32 %T137.tmp2, %T137.tmp0, !tcg.op !140
  %T137.not_xor_a_b = xor i32 %T137.xor, -1, !tcg.op !140
  store i32 %T137.not_xor_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !140
; ======== TCG [138] eqv_i64 [t2],t2,t0 ========
  %T138.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !141
  %T138.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !141
  %T138.xor = xor i64 %T138.tmp2, %T138.tmp0, !tcg.op !141
  %T138.not_xor_a_b = xor i64 %T138.xor, -1, !tcg.op !141
  store i64 %T138.not_xor_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !141
; ======== TCG [139] eqv_vec v128,e32,[t8],t3,t4 ========
  %T139.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !142
  %T139.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !142
  %T139.xor = xor <4 x i32> %T139.tmp3, %T139.tmp4, !tcg.op !142
  %T139.not_xor_a_b = xor <4 x i32> %T139.xor, splat (i32 -1), !tcg.op !142
  store <4 x i32> %T139.not_xor_a_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !142
; ======== TCG [140] func_addr t9,0x55aa,0x0 ========
  store ptr @Fx55aa, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !143
; ======== TCG [141] tail_call_qemuaot t9 VEC_ARGS: ========
  %T141.rax.stack = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !144
  %T141.rcx.stack = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !144
  %T141.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !144
  %T141.v4.stack = load <2 x i64>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !144
  %T141.v20.stack = load <2 x i64>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !144
  %T141.v22.stack = load <2 x i64>, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !144
  %T141.v24.stack = load <2 x i64>, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !144
  %T141.loaded_fn = load ptr, ptr %tmp9.stack, align 8, !tcg.op !144
  tail call qemuaot void %T141.loaded_fn(i64 %T141.rax.stack, i64 %T141.rcx.stack, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %T141.v0.stack, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %T141.v4.stack, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %T141.v20.stack, <2 x i64> %ymm10_h, <2 x i64> %T141.v22.stack, <2 x i64> %ymm11_h, <2 x i64> %T141.v24.stack, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h, ptr %cpu), !tcg.op !144
  ret void, !tcg.op !144
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

declare i32 @llvm.ctlz.i32.i32(i32)

declare i64 @llvm.ctlz.i64.i64(i64)

declare i32 @llvm.cttz.i32.i32(i32)

declare i64 @llvm.cttz.i64.i64(i64)

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.smax.v16i8.v16i8(<16 x i8>, <16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.smax.v4i32.v4i32(<4 x i32>, <4 x i32>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.smin.v16i8.v16i8(<16 x i8>, <16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.smin.v4i32.v4i32(<4 x i32>, <4 x i32>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.sadd.sat.v16i8.v16i8(<16 x i8>, <16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.sadd.sat.v4i32.v4i32(<4 x i32>, <4 x i32>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.ssub.sat.v16i8.v16i8(<16 x i8>, <16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.ssub.sat.v4i32.v4i32(<4 x i32>, <4 x i32>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.uadd.sat.v16i8.v16i8(<16 x i8>, <16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.uadd.sat.v4i32.v4i32(<4 x i32>, <4 x i32>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.usub.sat.v16i8.v16i8(<16 x i8>, <16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.usub.sat.v4i32.v4i32(<4 x i32>, <4 x i32>) #1

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
!85 = !{!"[82] clz_i32 [t2],t2,t0"}
!86 = !{!"[83] clz_i64 [t2],t2,t0"}
!87 = !{!"[84] ctz_i32 [t2],t2,t0"}
!88 = !{!"[85] ctz_i64 [t2],t2,t0"}
!89 = !{!"[86] smax_vec v128,e8,[t8],t3,t4"}
!90 = !{!"[87] smax_vec v128,e32,[t8],t3,t4"}
!91 = !{!"[88] smin_vec v128,e8,[t8],t3,t4"}
!92 = !{!"[89] smin_vec v128,e32,[t8],t3,t4"}
!93 = !{!"[90] ssadd_vec v128,e8,[t8],t3,t4"}
!94 = !{!"[91] ssadd_vec v128,e32,[t8],t3,t4"}
!95 = !{!"[92] sssub_vec v128,e8,[t8],t3,t4"}
!96 = !{!"[93] sssub_vec v128,e32,[t8],t3,t4"}
!97 = !{!"[94] usadd_vec v128,e8,[t8],t3,t4"}
!98 = !{!"[95] usadd_vec v128,e32,[t8],t3,t4"}
!99 = !{!"[96] ussub_vec v128,e8,[t8],t3,t4"}
!100 = !{!"[97] ussub_vec v128,e32,[t8],t3,t4"}
!101 = !{!"[98] rotl_i32 [t2],t2,t0"}
!102 = !{!"[99] rotl_i64 [t2],t2,t0"}
!103 = !{!"[100] rotl_i32 [t2],t2,0x4"}
!104 = !{!"[101] rotl_i64 [t2],t2,0x100"}
!105 = !{!"[102] rotli_vec v128,e8,[t8],t3,0x2"}
!106 = !{!"[103] rotli_vec v128,e8,[t8],t3,0x8"}
!107 = !{!"[104] rotli_vec v128,e8,[t8],t3,0x9"}
!108 = !{!"[105] rotli_vec v128,e16,[t8],t3,0x12"}
!109 = !{!"[106] rotli_vec v128,e32,[t8],t3,0x21"}
!110 = !{!"[107] rotli_vec v128,e64,[t8],t3,0x42"}
!111 = !{!"[108] rotls_vec v128,e32,[t8],t3,t2"}
!112 = !{!"[109] rotlv_vec v128,e32,[t8],t3,t4"}
!113 = !{!"[110] rotr_i32 [t2],t2,t0"}
!114 = !{!"[111] rotr_i64 [t2],t2,t0"}
!115 = !{!"[112] rotr_i32 [t2],t2,0x4"}
!116 = !{!"[113] rotr_i64 [t2],t2,0x100"}
!117 = !{!"[114] rotrv_vec v128,e32,[t8],t3,t4"}
!118 = !{!"[115] shli_vec v128,e8,[t8],t3,0x2"}
!119 = !{!"[116] shli_vec v128,e8,[t8],t3,0x9"}
!120 = !{!"[117] shli_vec v128,e16,[t8],t3,0x11"}
!121 = !{!"[118] shli_vec v128,e32,[t8],t3,0x21"}
!122 = !{!"[119] shli_vec v128,e64,[t8],t3,0x42"}
!123 = !{!"[120] shls_vec v128,e32,[t8],t3,t2"}
!124 = !{!"[121] shri_vec v128,e32,[t8],t3,0x2"}
!125 = !{!"[122] shrs_vec v128,e32,[t8],t3,t2"}
!126 = !{!"[123] sari_vec v128,e32,[t8],t3,0x2"}
!127 = !{!"[124] sars_vec v128,e32,[t8],t3,t2"}
!128 = !{!"[125] andc_i32 [t2],t2,t0"}
!129 = !{!"[126] andc_i64 [t2],t2,t0"}
!130 = !{!"[127] andc_vec v128,e32,[t8],t3,t4"}
!131 = !{!"[128] nor_i32 [t2],t2,t0"}
!132 = !{!"[129] nor_i64 [t2],t2,t0"}
!133 = !{!"[130] nor_vec v128,e32,[t8],t3,t4"}
!134 = !{!"[131] orc_i32 [t2],t2,t0"}
!135 = !{!"[132] orc_i64 [t2],t2,t0"}
!136 = !{!"[133] orc_vec v128,e32,[t8],t3,t4"}
!137 = !{!"[134] nand_i32 [t2],t2,t0"}
!138 = !{!"[135] nand_i64 [t2],t2,t0"}
!139 = !{!"[136] nand_vec v128,e32,[t8],t3,t4"}
!140 = !{!"[137] eqv_i32 [t2],t2,t0"}
!141 = !{!"[138] eqv_i64 [t2],t2,t0"}
!142 = !{!"[139] eqv_vec v128,e32,[t8],t3,t4"}
!143 = !{!"[140] func_addr t9,0x55aa,0x0"}
!144 = !{!"[141] tail_call_qemuaot t9 VEC_ARGS:"}
