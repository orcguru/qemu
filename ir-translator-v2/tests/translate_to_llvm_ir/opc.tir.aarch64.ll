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
  %cc_dst.stack = alloca i64, align 8
  store i64 %cc_dst, ptr %cc_dst.stack, align 8, !tbaa !0
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
  %tmp9.stack = alloca <2 x i64>, align 16
  %tmp10.stack = alloca i32, align 8
  %tmp11.stack = alloca i32, align 8
  %tmp12.stack = alloca i64, align 8
  %tmp13.stack = alloca i64, align 8
  %tmp14.stack = alloca i32, align 8
  %tmp15.stack = alloca i32, align 8
  %tmp16.stack = alloca i32, align 8
  %tmp17.stack = alloca i64, align 8
  %tmp18.stack = alloca i64, align 8
  %tmp19.stack = alloca i64, align 8
  %tmp20.stack = alloca ptr, align 8
  %tmp21.stack = alloca ptr, align 8
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
  %T4.add = add i32 %T4.tmp0, %T4.tmp1, !tcg.op !7
  %T4.ci = load i1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !7
  %T4.ci_zext = zext i1 %T4.ci to i32, !tcg.op !7
  %T4.addc = add i32 %T4.add, %T4.ci_zext, !tcg.op !7
  store i32 %T4.addc, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !7
; ======== TCG [5] addci_i64 [t2],t0,t1 ========
  %T5.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !8
  %T5.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !8
  %T5.add = add i64 %T5.tmp0, %T5.tmp1, !tcg.op !8
  %T5.ci = load i1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !8
  %T5.ci_zext = zext i1 %T5.ci to i64, !tcg.op !8
  %T5.addc = add i64 %T5.add, %T5.ci_zext, !tcg.op !8
  store i64 %T5.addc, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !8
; ======== TCG [6] addcio_i32 [t2],t0,t1 ========
  %T6.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !9
  %T6.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !9
  %T6.r1 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T6.tmp0, i32 %T6.tmp1), !tcg.op !9
  %T6.s1 = extractvalue { i32, i1 } %T6.r1, 0, !tcg.op !9
  %T6.c1 = extractvalue { i32, i1 } %T6.r1, 1, !tcg.op !9
  %T6.ci = load i1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !9
  %T6.ci_zext = zext i1 %T6.ci to i32, !tcg.op !9
  %T6.addc = add i32 %T6.s1, %T6.ci_zext, !tcg.op !9
  store i32 %T6.addc, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !9
  %T6.wrap = icmp ult i32 %T6.addc, %T6.ci_zext, !tcg.op !9
  %T6.cout = or i1 %T6.c1, %T6.wrap, !tcg.op !9
  store i1 %T6.cout, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !9
; ======== TCG [7] addcio_i64 [t2],t0,t1 ========
  %T7.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !10
  %T7.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !10
  %T7.r1 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T7.tmp0, i64 %T7.tmp1), !tcg.op !10
  %T7.s1 = extractvalue { i64, i1 } %T7.r1, 0, !tcg.op !10
  %T7.c1 = extractvalue { i64, i1 } %T7.r1, 1, !tcg.op !10
  %T7.ci = load i1, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !10
  %T7.ci_zext = zext i1 %T7.ci to i64, !tcg.op !10
  %T7.addc = add i64 %T7.s1, %T7.ci_zext, !tcg.op !10
  store i64 %T7.addc, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !10
  %T7.wrap = icmp ult i64 %T7.addc, %T7.ci_zext, !tcg.op !10
  %T7.cout = or i1 %T7.c1, %T7.wrap, !tcg.op !10
  store i1 %T7.cout, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !10
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
  %T10.sub = sub i32 %T10.tmp0, %T10.tmp1, !tcg.op !13
  %T10.bi = load i1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !13
  %T10.bi_zext = zext i1 %T10.bi to i32, !tcg.op !13
  %T10.subb = sub i32 %T10.sub, %T10.bi_zext, !tcg.op !13
  store i32 %T10.subb, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !13
; ======== TCG [11] subbi_i64 [t2],t0,t1 ========
  %T11.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !14
  %T11.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !14
  %T11.sub = sub i64 %T11.tmp0, %T11.tmp1, !tcg.op !14
  %T11.bi = load i1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !14
  %T11.bi_zext = zext i1 %T11.bi to i64, !tcg.op !14
  %T11.subb = sub i64 %T11.sub, %T11.bi_zext, !tcg.op !14
  store i64 %T11.subb, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !14
; ======== TCG [12] subbio_i32 [t2],t0,t1 ========
  %T12.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !15
  %T12.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !15
  %T12.r1 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T12.tmp0, i32 %T12.tmp1), !tcg.op !15
  %T12.s1 = extractvalue { i32, i1 } %T12.r1, 0, !tcg.op !15
  %T12.c1 = extractvalue { i32, i1 } %T12.r1, 1, !tcg.op !15
  %T12.ci = load i1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !15
  %T12.bi_zext = zext i1 %T12.ci to i32, !tcg.op !15
  %T12.subb = sub i32 %T12.s1, %T12.bi_zext, !tcg.op !15
  store i32 %T12.subb, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !15
  %T12.wrap = icmp ult i32 %T12.s1, %T12.bi_zext, !tcg.op !15
  %T12.bout = or i1 %T12.c1, %T12.wrap, !tcg.op !15
  store i1 %T12.bout, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !15
; ======== TCG [13] subbio_i64 [t2],t0,t1 ========
  %T13.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !16
  %T13.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !16
  %T13.r1 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T13.tmp0, i64 %T13.tmp1), !tcg.op !16
  %T13.s1 = extractvalue { i64, i1 } %T13.r1, 0, !tcg.op !16
  %T13.c1 = extractvalue { i64, i1 } %T13.r1, 1, !tcg.op !16
  %T13.ci = load i1, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !16
  %T13.bi_zext = zext i1 %T13.ci to i64, !tcg.op !16
  %T13.subb = sub i64 %T13.s1, %T13.bi_zext, !tcg.op !16
  store i64 %T13.subb, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !16
  %T13.wrap = icmp ult i64 %T13.s1, %T13.bi_zext, !tcg.op !16
  %T13.bout = or i1 %T13.c1, %T13.wrap, !tcg.op !16
  store i1 %T13.bout, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !16
; ======== TCG [14] addc1o_i32 t2,t0,t1 ========
  %T14.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !17
  %T14.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !17
  %T14.r1 = call { i32, i1 } @llvm.uadd.with.overflow.i32.i32(i32 %T14.tmp0, i32 %T14.tmp1), !tcg.op !17
  %T14.s1 = extractvalue { i32, i1 } %T14.r1, 0, !tcg.op !17
  %T14.c1 = extractvalue { i32, i1 } %T14.r1, 1, !tcg.op !17
  %T14.addc = add i32 %T14.s1, 1, !tcg.op !17
  store i32 %T14.addc, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !17
  %T14.wrap = icmp ult i32 %T14.addc, 1, !tcg.op !17
  %T14.cout = or i1 %T14.c1, %T14.wrap, !tcg.op !17
  store i1 %T14.cout, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !17
; ======== TCG [15] addc1o_i64 t2,t0,t1 ========
  %T15.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !18
  %T15.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !18
  %T15.r1 = call { i64, i1 } @llvm.uadd.with.overflow.i64.i64(i64 %T15.tmp0, i64 %T15.tmp1), !tcg.op !18
  %T15.s1 = extractvalue { i64, i1 } %T15.r1, 0, !tcg.op !18
  %T15.c1 = extractvalue { i64, i1 } %T15.r1, 1, !tcg.op !18
  %T15.addc = add i64 %T15.s1, 1, !tcg.op !18
  store i64 %T15.addc, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !18
  %T15.wrap = icmp ult i64 %T15.addc, 1, !tcg.op !18
  %T15.cout = or i1 %T15.c1, %T15.wrap, !tcg.op !18
  store i1 %T15.cout, ptr %carry.stack, align 8, !tbaa !0, !tcg.op !18
; ======== TCG [16] subb1o_i32 t2,t0,t1 ========
  %T16.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !19
  %T16.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !19
  %T16.r1 = call { i32, i1 } @llvm.usub.with.overflow.i32.i32(i32 %T16.tmp0, i32 %T16.tmp1), !tcg.op !19
  %T16.s1 = extractvalue { i32, i1 } %T16.r1, 0, !tcg.op !19
  %T16.c1 = extractvalue { i32, i1 } %T16.r1, 1, !tcg.op !19
  %T16.subb = sub i32 %T16.s1, 1, !tcg.op !19
  store i32 %T16.subb, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !19
  %T16.wrap = icmp ult i32 %T16.s1, 1, !tcg.op !19
  %T16.bout = or i1 %T16.c1, %T16.wrap, !tcg.op !19
  store i1 %T16.bout, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !19
; ======== TCG [17] subb1o_i64 t2,t0,t1 ========
  %T17.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !20
  %T17.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !20
  %T17.r1 = call { i64, i1 } @llvm.usub.with.overflow.i64.i64(i64 %T17.tmp0, i64 %T17.tmp1), !tcg.op !20
  %T17.s1 = extractvalue { i64, i1 } %T17.r1, 0, !tcg.op !20
  %T17.c1 = extractvalue { i64, i1 } %T17.r1, 1, !tcg.op !20
  %T17.subb = sub i64 %T17.s1, 1, !tcg.op !20
  store i64 %T17.subb, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !20
  %T17.wrap = icmp ult i64 %T17.s1, 1, !tcg.op !20
  %T17.bout = or i1 %T17.c1, %T17.wrap, !tcg.op !20
  store i1 %T17.bout, ptr %borrow.stack, align 8, !tbaa !0, !tcg.op !20
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
; ======== TCG [46] brcond_i32 t1,0x0,eq,L0 ========
  %T46.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !49
  %T46.bool = icmp eq i32 %T46.tmp1, 0, !tcg.op !49
  br i1 %T46.bool, label %bb_L0, label %bb_false, !tcg.op !49

bb_false:                                         ; preds = %entry
; ======== TCG [47] setcond_i32 [t10],t1,0xffffffffffffffff,eq ========
  %T47.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !50
  %T47.bool = icmp eq i32 %T47.tmp1, -1, !tcg.op !50
  %T47.out = zext i1 %T47.bool to i32, !tcg.op !50
  store i32 %T47.out, ptr %tmp10.stack, align 8, !tbaa !0, !tcg.op !50
; ======== TCG [48] setcond_i32 [t11],t0,0x80000000,eq ========
  %T48.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !51
  %T48.bool = icmp eq i32 %T48.tmp0, -2147483648, !tcg.op !51
  %T48.out = zext i1 %T48.bool to i32, !tcg.op !51
  store i32 %T48.out, ptr %tmp11.stack, align 8, !tbaa !0, !tcg.op !51
; ======== TCG [49] and_i32 [t10],t10,t11 ========
  %T49.tmp10 = load i32, ptr %tmp10.stack, align 8, !tbaa !0, !tcg.op !52
  %T49.tmp11 = load i32, ptr %tmp11.stack, align 8, !tbaa !0, !tcg.op !52
  %T49.out = and i32 %T49.tmp10, %T49.tmp11, !tcg.op !52
  store i32 %T49.out, ptr %tmp10.stack, align 8, !tbaa !0, !tcg.op !52
; ======== TCG [50] brcond_i32 t10,0x1,eq,L0 ========
  %T50.tmp10 = load i32, ptr %tmp10.stack, align 8, !tbaa !0, !tcg.op !53
  %T50.bool = icmp eq i32 %T50.tmp10, 1, !tcg.op !53
  br i1 %T50.bool, label %bb_L0, label %bb_false1, !tcg.op !53

bb_L0:                                            ; preds = %bb_false414, %divs2.done413, %bb_false412, %divs2.done411, %bb_false410, %bb_false409, %divs2.done, %bb_false408, %bb_false407, %T97.merge, %bb_false4, %bb_false3, %bb_false2, %bb_false1, %bb_false, %entry
; ======== TCG [252] func_addr t21,0x0,0x1 ========
  store ptr @trampoline_helper_raise_exception, ptr %tmp21.stack, align 8, !tbaa !0, !tcg.op !54
; ======== TCG [253] tail_call_qemuaot t21,env,0x0 VEC_ARGS: ========
  %T253.rax.stack = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !55
  %T253.rcx.stack = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !55
  %T253.cc_dst.stack = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !55
  %T253.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !55
  %T253.v4.stack = load <2 x i64>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !55
  %T253.v20.stack = load <2 x i64>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !55
  %T253.v22.stack = load <2 x i64>, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !55
  %T253.v24.stack = load <2 x i64>, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !55
  %T253.env = ptrtoint ptr %env to i64, !tcg.op !55
  %T253.loaded_fn = load ptr, ptr %tmp21.stack, align 8, !tcg.op !55
  tail call qemuaot void %T253.loaded_fn(i64 %T253.rax.stack, i64 %T253.rcx.stack, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %T253.cc_dst.stack, i32 %cc_op, i64 %rip, <2 x i64> %T253.v0.stack, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %T253.v4.stack, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %T253.v20.stack, <2 x i64> %ymm10_h, <2 x i64> %T253.v22.stack, <2 x i64> %ymm11_h, <2 x i64> %T253.v24.stack, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h, ptr %cpu, i64 %T253.env, i64 0), !tcg.op !55
  ret void, !tcg.op !55

bb_false1:                                        ; preds = %bb_false
; ======== TCG [51] divs_i32 [t2],t0,t1 ========
  %T51.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !56
  %T51.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !56
  %T51.out = sdiv i32 %T51.tmp0, %T51.tmp1, !tcg.op !56
  store i32 %T51.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !56
; ======== TCG [52] brcond_i64 t1,0x0,eq,L0 ========
  %T52.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !57
  %T52.bool = icmp eq i64 %T52.tmp1, 0, !tcg.op !57
  br i1 %T52.bool, label %bb_L0, label %bb_false2, !tcg.op !57

bb_false2:                                        ; preds = %bb_false1
; ======== TCG [53] setcond_i64 [t12],t1,0xffffffffffffffff,eq ========
  %T53.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !58
  %T53.bool = icmp eq i64 %T53.tmp1, -1, !tcg.op !58
  %T53.out = zext i1 %T53.bool to i64, !tcg.op !58
  store i64 %T53.out, ptr %tmp12.stack, align 8, !tbaa !0, !tcg.op !58
; ======== TCG [54] setcond_i64 [t13],t0,0x8000000000000000,eq ========
  %T54.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !59
  %T54.bool = icmp eq i64 %T54.tmp0, -9223372036854775808, !tcg.op !59
  %T54.out = zext i1 %T54.bool to i64, !tcg.op !59
  store i64 %T54.out, ptr %tmp13.stack, align 8, !tbaa !0, !tcg.op !59
; ======== TCG [55] and_i64 [t12],t12,t13 ========
  %T55.tmp12 = load i64, ptr %tmp12.stack, align 8, !tbaa !0, !tcg.op !60
  %T55.tmp13 = load i64, ptr %tmp13.stack, align 8, !tbaa !0, !tcg.op !60
  %T55.out = and i64 %T55.tmp12, %T55.tmp13, !tcg.op !60
  store i64 %T55.out, ptr %tmp12.stack, align 8, !tbaa !0, !tcg.op !60
; ======== TCG [56] brcond_i64 t12,0x1,eq,L0 ========
  %T56.tmp12 = load i64, ptr %tmp12.stack, align 8, !tbaa !0, !tcg.op !61
  %T56.bool = icmp eq i64 %T56.tmp12, 1, !tcg.op !61
  br i1 %T56.bool, label %bb_L0, label %bb_false3, !tcg.op !61

bb_false3:                                        ; preds = %bb_false2
; ======== TCG [57] divs_i64 [t2],t0,t1 ========
  %T57.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !62
  %T57.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !62
  %T57.out = sdiv i64 %T57.tmp0, %T57.tmp1, !tcg.op !62
  store i64 %T57.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !62
; ======== TCG [58] brcond_i32 t1,0x0,eq,L0 ========
  %T58.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !63
  %T58.bool = icmp eq i32 %T58.tmp1, 0, !tcg.op !63
  br i1 %T58.bool, label %bb_L0, label %bb_false4, !tcg.op !63

bb_false4:                                        ; preds = %bb_false3
; ======== TCG [59] divu_i32 [t2],t0,t1 ========
  %T59.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !64
  %T59.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !64
  %T59.out = udiv i32 %T59.tmp0, %T59.tmp1, !tcg.op !64
  store i32 %T59.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !64
; ======== TCG [60] brcond_i64 t1,0x0,eq,L0 ========
  %T60.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !65
  %T60.bool = icmp eq i64 %T60.tmp1, 0, !tcg.op !65
  br i1 %T60.bool, label %bb_L0, label %bb_false5, !tcg.op !65

bb_false5:                                        ; preds = %bb_false4
; ======== TCG [61] divu_i64 [t2],t0,t1 ========
  %T61.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !66
  %T61.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !66
  %T61.out = udiv i64 %T61.tmp0, %T61.tmp1, !tcg.op !66
  store i64 %T61.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !66
; ======== TCG [62] rems_i32 [t2],t0,t1 ========
  %T62.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !67
  %T62.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !67
  %T62.out = srem i32 %T62.tmp0, %T62.tmp1, !tcg.op !67
  store i32 %T62.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !67
; ======== TCG [63] rems_i64 [t2],t0,t1 ========
  %T63.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !68
  %T63.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !68
  %T63.out = srem i64 %T63.tmp0, %T63.tmp1, !tcg.op !68
  store i64 %T63.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !68
; ======== TCG [64] remu_i32 [t2],t0,t1 ========
  %T64.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !69
  %T64.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !69
  %T64.out = urem i32 %T64.tmp0, %T64.tmp1, !tcg.op !69
  store i32 %T64.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !69
; ======== TCG [65] remu_i64 [t2],t0,t1 ========
  %T65.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !70
  %T65.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !70
  %T65.out = urem i64 %T65.tmp0, %T65.tmp1, !tcg.op !70
  store i64 %T65.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !70
; ======== TCG [66] sar_i32 [t2],t0,t1 ========
  %T66.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !71
  %T66.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !71
  %T66.out = ashr i32 %T66.tmp0, %T66.tmp1, !tcg.op !71
  store i32 %T66.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !71
; ======== TCG [67] sar_i64 [t2],t0,t1 ========
  %T67.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !72
  %T67.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !72
  %T67.out = ashr i64 %T67.tmp0, %T67.tmp1, !tcg.op !72
  store i64 %T67.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !72
; ======== TCG [68] and_i32 [t2],t0,t1 ========
  %T68.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !73
  %T68.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !73
  %T68.out = and i32 %T68.tmp0, %T68.tmp1, !tcg.op !73
  store i32 %T68.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !73
; ======== TCG [69] and_i64 [t2],t0,t1 ========
  %T69.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !74
  %T69.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !74
  %T69.out = and i64 %T69.tmp0, %T69.tmp1, !tcg.op !74
  store i64 %T69.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !74
; ======== TCG [70] mul_i32 [t2],t0,t1 ========
  %T70.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !75
  %T70.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !75
  %T70.out = mul i32 %T70.tmp0, %T70.tmp1, !tcg.op !75
  store i32 %T70.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !75
; ======== TCG [71] mul_i64 [t2],t0,t1 ========
  %T71.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !76
  %T71.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !76
  %T71.out = mul i64 %T71.tmp0, %T71.tmp1, !tcg.op !76
  store i64 %T71.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !76
; ======== TCG [72] or_i32 [t2],t0,t1 ========
  %T72.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !77
  %T72.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !77
  %T72.out = or i32 %T72.tmp0, %T72.tmp1, !tcg.op !77
  store i32 %T72.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !77
; ======== TCG [73] or_i64 [t2],t0,t1 ========
  %T73.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !78
  %T73.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !78
  %T73.out = or i64 %T73.tmp0, %T73.tmp1, !tcg.op !78
  store i64 %T73.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !78
; ======== TCG [74] shl_i32 [t2],t0,t1 ========
  %T74.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !79
  %T74.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !79
  %T74.out = shl i32 %T74.tmp0, %T74.tmp1, !tcg.op !79
  store i32 %T74.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !79
; ======== TCG [75] shl_i64 [t2],t0,t1 ========
  %T75.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !80
  %T75.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !80
  %T75.out = shl i64 %T75.tmp0, %T75.tmp1, !tcg.op !80
  store i64 %T75.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !80
; ======== TCG [76] shr_i32 [t2],t0,t1 ========
  %T76.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !81
  %T76.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !81
  %T76.out = lshr i32 %T76.tmp0, %T76.tmp1, !tcg.op !81
  store i32 %T76.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !81
; ======== TCG [77] shr_i64 [t2],t0,t1 ========
  %T77.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !82
  %T77.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !82
  %T77.out = lshr i64 %T77.tmp0, %T77.tmp1, !tcg.op !82
  store i64 %T77.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !82
; ======== TCG [78] xor_i32 [t2],t0,t1 ========
  %T78.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !83
  %T78.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !83
  %T78.out = xor i32 %T78.tmp0, %T78.tmp1, !tcg.op !83
  store i32 %T78.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !83
; ======== TCG [79] xor_i64 [t2],t0,t1 ========
  %T79.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !84
  %T79.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !84
  %T79.out = xor i64 %T79.tmp0, %T79.tmp1, !tcg.op !84
  store i64 %T79.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !84
; ======== TCG [80] sarv_vec v128,e8,[t8],t3,t4 ========
  %T80.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !85
  %T80.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !85
  %T80.out = ashr <16 x i8> %T80.tmp3, %T80.tmp4, !tcg.op !85
  store <16 x i8> %T80.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !85
; ======== TCG [81] sarv_vec v128,e32,[t8],t3,t4 ========
  %T81.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !86
  %T81.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !86
  %T81.out = ashr <4 x i32> %T81.tmp3, %T81.tmp4, !tcg.op !86
  store <4 x i32> %T81.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !86
; ======== TCG [82] shlv_vec v128,e8,[t8],t3,t4 ========
  %T82.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !87
  %T82.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !87
  %T82.out = shl <16 x i8> %T82.tmp3, %T82.tmp4, !tcg.op !87
  store <16 x i8> %T82.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !87
; ======== TCG [83] shlv_vec v128,e32,[t8],t3,t4 ========
  %T83.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !88
  %T83.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !88
  %T83.out = shl <4 x i32> %T83.tmp3, %T83.tmp4, !tcg.op !88
  store <4 x i32> %T83.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !88
; ======== TCG [84] shrv_vec v128,e8,[t8],t3,t4 ========
  %T84.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !89
  %T84.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !89
  %T84.out = lshr <16 x i8> %T84.tmp3, %T84.tmp4, !tcg.op !89
  store <16 x i8> %T84.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !89
; ======== TCG [85] shrv_vec v128,e32,[t8],t3,t4 ========
  %T85.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !90
  %T85.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !90
  %T85.out = lshr <4 x i32> %T85.tmp3, %T85.tmp4, !tcg.op !90
  store <4 x i32> %T85.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !90
; ======== TCG [86] and_vec v128,e8,[t8],t3,t4 ========
  %T86.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !91
  %T86.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !91
  %T86.out = and <16 x i8> %T86.tmp3, %T86.tmp4, !tcg.op !91
  store <16 x i8> %T86.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !91
; ======== TCG [87] and_vec v128,e32,[t8],t3,t4 ========
  %T87.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !92
  %T87.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !92
  %T87.out = and <4 x i32> %T87.tmp3, %T87.tmp4, !tcg.op !92
  store <4 x i32> %T87.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !92
; ======== TCG [88] mul_vec v128,e8,[t8],t3,t4 ========
  %T88.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !93
  %T88.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !93
  %T88.out = mul <16 x i8> %T88.tmp3, %T88.tmp4, !tcg.op !93
  store <16 x i8> %T88.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !93
; ======== TCG [89] mul_vec v128,e32,[t8],t3,t4 ========
  %T89.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !94
  %T89.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !94
  %T89.out = mul <4 x i32> %T89.tmp3, %T89.tmp4, !tcg.op !94
  store <4 x i32> %T89.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !94
; ======== TCG [90] or_vec v128,e8,[t8],t3,t4 ========
  %T90.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !95
  %T90.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !95
  %T90.out = or <16 x i8> %T90.tmp3, %T90.tmp4, !tcg.op !95
  store <16 x i8> %T90.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !95
; ======== TCG [91] or_vec v128,e32,[t8],t3,t4 ========
  %T91.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !96
  %T91.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !96
  %T91.out = or <4 x i32> %T91.tmp3, %T91.tmp4, !tcg.op !96
  store <4 x i32> %T91.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !96
; ======== TCG [92] xor_vec v128,e8,[t8],t3,t4 ========
  %T92.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !97
  %T92.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !97
  %T92.out = xor <16 x i8> %T92.tmp3, %T92.tmp4, !tcg.op !97
  store <16 x i8> %T92.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !97
; ======== TCG [93] xor_vec v128,e32,[t8],t3,t4 ========
  %T93.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !98
  %T93.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !98
  %T93.out = xor <4 x i32> %T93.tmp3, %T93.tmp4, !tcg.op !98
  store <4 x i32> %T93.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !98
; ======== TCG [94] clz_i32 [t2],t2,t0 ========
  %T94.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !99
  %T94.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !99
  %T94.icmp_eq_zero = icmp eq i32 %T94.tmp2, 0, !tcg.op !99
  br i1 %T94.icmp_eq_zero, label %T94.z, label %T94.nz, !tcg.op !99

T94.z:                                            ; preds = %bb_false5
  br label %T94.merge, !tcg.op !99

T94.nz:                                           ; preds = %bb_false5
  %T94.ct_result = call i32 @llvm.ctlz.i32.i32(i32 %T94.tmp2), !tcg.op !99
  br label %T94.merge, !tcg.op !99

T94.merge:                                        ; preds = %T94.nz, %T94.z
  %T94.phi = phi i32 [ %T94.tmp0, %T94.z ], [ %T94.ct_result, %T94.nz ], !tcg.op !99
  store i32 %T94.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !99
; ======== TCG [95] clz_i64 [t2],t2,t0 ========
  %T95.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !100
  %T95.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !100
  %T95.icmp_eq_zero = icmp eq i64 %T95.tmp2, 0, !tcg.op !100
  br i1 %T95.icmp_eq_zero, label %T95.z, label %T95.nz, !tcg.op !100

T95.z:                                            ; preds = %T94.merge
  br label %T95.merge, !tcg.op !100

T95.nz:                                           ; preds = %T94.merge
  %T95.ct_result = call i64 @llvm.ctlz.i64.i64(i64 %T95.tmp2), !tcg.op !100
  br label %T95.merge, !tcg.op !100

T95.merge:                                        ; preds = %T95.nz, %T95.z
  %T95.phi = phi i64 [ %T95.tmp0, %T95.z ], [ %T95.ct_result, %T95.nz ], !tcg.op !100
  store i64 %T95.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !100
; ======== TCG [96] ctz_i32 [t2],t2,t0 ========
  %T96.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !101
  %T96.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !101
  %T96.icmp_eq_zero = icmp eq i32 %T96.tmp2, 0, !tcg.op !101
  br i1 %T96.icmp_eq_zero, label %T96.z, label %T96.nz, !tcg.op !101

T96.z:                                            ; preds = %T95.merge
  br label %T96.merge, !tcg.op !101

T96.nz:                                           ; preds = %T95.merge
  %T96.ct_result = call i32 @llvm.cttz.i32.i32(i32 %T96.tmp2), !tcg.op !101
  br label %T96.merge, !tcg.op !101

T96.merge:                                        ; preds = %T96.nz, %T96.z
  %T96.phi = phi i32 [ %T96.tmp0, %T96.z ], [ %T96.ct_result, %T96.nz ], !tcg.op !101
  store i32 %T96.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !101
; ======== TCG [97] ctz_i64 [t2],t2,t0 ========
  %T97.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !102
  %T97.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !102
  %T97.icmp_eq_zero = icmp eq i64 %T97.tmp2, 0, !tcg.op !102
  br i1 %T97.icmp_eq_zero, label %T97.z, label %T97.nz, !tcg.op !102

T97.z:                                            ; preds = %T96.merge
  br label %T97.merge, !tcg.op !102

T97.nz:                                           ; preds = %T96.merge
  %T97.ct_result = call i64 @llvm.cttz.i64.i64(i64 %T97.tmp2), !tcg.op !102
  br label %T97.merge, !tcg.op !102

T97.merge:                                        ; preds = %T97.nz, %T97.z
  %T97.phi = phi i64 [ %T97.tmp0, %T97.z ], [ %T97.ct_result, %T97.nz ], !tcg.op !102
  store i64 %T97.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !102
; ======== TCG [98] smax_vec v128,e8,[t8],t3,t4 ========
  %T98.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !103
  %T98.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !103
  %T98.out = call <16 x i8> @llvm.smax.v16i8.v16i8(<16 x i8> %T98.tmp3, <16 x i8> %T98.tmp4), !tcg.op !103
  store <16 x i8> %T98.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !103
; ======== TCG [99] smax_vec v128,e32,[t8],t3,t4 ========
  %T99.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !104
  %T99.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !104
  %T99.out = call <4 x i32> @llvm.smax.v4i32.v4i32(<4 x i32> %T99.tmp3, <4 x i32> %T99.tmp4), !tcg.op !104
  store <4 x i32> %T99.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !104
; ======== TCG [100] smin_vec v128,e8,[t8],t3,t4 ========
  %T100.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !105
  %T100.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !105
  %T100.out = call <16 x i8> @llvm.smin.v16i8.v16i8(<16 x i8> %T100.tmp3, <16 x i8> %T100.tmp4), !tcg.op !105
  store <16 x i8> %T100.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !105
; ======== TCG [101] smin_vec v128,e32,[t8],t3,t4 ========
  %T101.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !106
  %T101.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !106
  %T101.out = call <4 x i32> @llvm.smin.v4i32.v4i32(<4 x i32> %T101.tmp3, <4 x i32> %T101.tmp4), !tcg.op !106
  store <4 x i32> %T101.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !106
; ======== TCG [102] ssadd_vec v128,e8,[t8],t3,t4 ========
  %T102.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !107
  %T102.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !107
  %T102.out = call <16 x i8> @llvm.sadd.sat.v16i8.v16i8(<16 x i8> %T102.tmp3, <16 x i8> %T102.tmp4), !tcg.op !107
  store <16 x i8> %T102.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !107
; ======== TCG [103] ssadd_vec v128,e32,[t8],t3,t4 ========
  %T103.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !108
  %T103.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !108
  %T103.out = call <4 x i32> @llvm.sadd.sat.v4i32.v4i32(<4 x i32> %T103.tmp3, <4 x i32> %T103.tmp4), !tcg.op !108
  store <4 x i32> %T103.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !108
; ======== TCG [104] sssub_vec v128,e8,[t8],t3,t4 ========
  %T104.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !109
  %T104.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !109
  %T104.out = call <16 x i8> @llvm.ssub.sat.v16i8.v16i8(<16 x i8> %T104.tmp3, <16 x i8> %T104.tmp4), !tcg.op !109
  store <16 x i8> %T104.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !109
; ======== TCG [105] sssub_vec v128,e32,[t8],t3,t4 ========
  %T105.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !110
  %T105.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !110
  %T105.out = call <4 x i32> @llvm.ssub.sat.v4i32.v4i32(<4 x i32> %T105.tmp3, <4 x i32> %T105.tmp4), !tcg.op !110
  store <4 x i32> %T105.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !110
; ======== TCG [106] usadd_vec v128,e8,[t8],t3,t4 ========
  %T106.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !111
  %T106.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !111
  %T106.out = call <16 x i8> @llvm.uadd.sat.v16i8.v16i8(<16 x i8> %T106.tmp3, <16 x i8> %T106.tmp4), !tcg.op !111
  store <16 x i8> %T106.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !111
; ======== TCG [107] usadd_vec v128,e32,[t8],t3,t4 ========
  %T107.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !112
  %T107.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !112
  %T107.out = call <4 x i32> @llvm.uadd.sat.v4i32.v4i32(<4 x i32> %T107.tmp3, <4 x i32> %T107.tmp4), !tcg.op !112
  store <4 x i32> %T107.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !112
; ======== TCG [108] ussub_vec v128,e8,[t8],t3,t4 ========
  %T108.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !113
  %T108.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !113
  %T108.out = call <16 x i8> @llvm.usub.sat.v16i8.v16i8(<16 x i8> %T108.tmp3, <16 x i8> %T108.tmp4), !tcg.op !113
  store <16 x i8> %T108.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !113
; ======== TCG [109] ussub_vec v128,e32,[t8],t3,t4 ========
  %T109.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !114
  %T109.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !114
  %T109.out = call <4 x i32> @llvm.usub.sat.v4i32.v4i32(<4 x i32> %T109.tmp3, <4 x i32> %T109.tmp4), !tcg.op !114
  store <4 x i32> %T109.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !114
; ======== TCG [110] rotl_i32 [t2],t2,t0 ========
  %T110.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !115
  %T110.shift_value_masked = and i32 %T110.tmp0, 31, !tcg.op !115
  %T110.shift_l = and i32 %T110.tmp0, 31, !tcg.op !115
  %T110.shift_r = sub i32 32, %T110.shift_l, !tcg.op !115
  %T110.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !115
  %T110.shl = shl i32 %T110.tmp2, %T110.shift_l, !tcg.op !115
  %T110.lshr = lshr i32 %T110.tmp2, %T110.shift_r, !tcg.op !115
  %T110.or = or i32 %T110.shl, %T110.lshr, !tcg.op !115
  %T110.bool = icmp eq i32 %T110.shift_value_masked, 0, !tcg.op !115
  %T110.tmp26 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !115
  %T110.avoid_poison = select i1 %T110.bool, i32 %T110.tmp26, i32 %T110.or, !tcg.op !115
  store i32 %T110.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !115
; ======== TCG [111] rotl_i64 [t2],t2,t0 ========
  %T111.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !116
  %T111.shift_value_masked = and i64 %T111.tmp0, 63, !tcg.op !116
  %T111.shift_l = and i64 %T111.tmp0, 63, !tcg.op !116
  %T111.shift_r = sub i64 64, %T111.shift_l, !tcg.op !116
  %T111.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !116
  %T111.shl = shl i64 %T111.tmp2, %T111.shift_l, !tcg.op !116
  %T111.lshr = lshr i64 %T111.tmp2, %T111.shift_r, !tcg.op !116
  %T111.or = or i64 %T111.shl, %T111.lshr, !tcg.op !116
  %T111.bool = icmp eq i64 %T111.shift_value_masked, 0, !tcg.op !116
  %T111.tmp27 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !116
  %T111.avoid_poison = select i1 %T111.bool, i64 %T111.tmp27, i64 %T111.or, !tcg.op !116
  store i64 %T111.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !116
; ======== TCG [112] rotl_i32 [t2],t2,0x4 ========
  %T112.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !117
  %T112.shl = shl i32 %T112.tmp2, 4, !tcg.op !117
  %T112.lshr = lshr i32 %T112.tmp2, 28, !tcg.op !117
  %T112.or = or i32 %T112.shl, %T112.lshr, !tcg.op !117
  %T112.tmp28 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !117
  %T112.avoid_poison = select i1 false, i32 %T112.tmp28, i32 %T112.or, !tcg.op !117
  store i32 %T112.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !117
; ======== TCG [113] rotl_i64 [t2],t2,0x100 ========
  %T113.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !118
  %T113.shl = shl i64 %T113.tmp2, 0, !tcg.op !118
  %T113.lshr = lshr i64 %T113.tmp2, 64, !tcg.op !118
  %T113.or = or i64 %T113.shl, %T113.lshr, !tcg.op !118
  %T113.tmp29 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !118
  %T113.avoid_poison = select i1 true, i64 %T113.tmp29, i64 %T113.or, !tcg.op !118
  store i64 %T113.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !118
; ======== TCG [114] rotli_vec v128,e8,[t8],t3,0x2 ========
  %T114.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !119
  %T114.shl = shl <16 x i8> %T114.tmp3, splat (i8 2), !tcg.op !119
  %T114.lshr = lshr <16 x i8> %T114.tmp3, splat (i8 6), !tcg.op !119
  %T114.or = or <16 x i8> %T114.shl, %T114.lshr, !tcg.op !119
  %T114.tmp310 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !119
  %T114.avoid_poison = select i1 false, <16 x i8> %T114.tmp310, <16 x i8> %T114.or, !tcg.op !119
  store <16 x i8> %T114.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !119
; ======== TCG [115] rotli_vec v128,e8,[t8],t3,0x8 ========
  %T115.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !120
  %T115.shl = shl <16 x i8> %T115.tmp3, zeroinitializer, !tcg.op !120
  %T115.lshr = lshr <16 x i8> %T115.tmp3, splat (i8 8), !tcg.op !120
  %T115.or = or <16 x i8> %T115.shl, %T115.lshr, !tcg.op !120
  %T115.tmp311 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !120
  %T115.avoid_poison = select i1 true, <16 x i8> %T115.tmp311, <16 x i8> %T115.or, !tcg.op !120
  store <16 x i8> %T115.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !120
; ======== TCG [116] rotli_vec v128,e8,[t8],t3,0x9 ========
  %T116.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !121
  %T116.shl = shl <16 x i8> %T116.tmp3, splat (i8 1), !tcg.op !121
  %T116.lshr = lshr <16 x i8> %T116.tmp3, splat (i8 7), !tcg.op !121
  %T116.or = or <16 x i8> %T116.shl, %T116.lshr, !tcg.op !121
  %T116.tmp312 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !121
  %T116.avoid_poison = select i1 false, <16 x i8> %T116.tmp312, <16 x i8> %T116.or, !tcg.op !121
  store <16 x i8> %T116.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !121
; ======== TCG [117] rotli_vec v128,e16,[t8],t3,0x12 ========
  %T117.tmp3 = load <8 x i16>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !122
  %T117.shl = shl <8 x i16> %T117.tmp3, splat (i16 2), !tcg.op !122
  %T117.lshr = lshr <8 x i16> %T117.tmp3, splat (i16 14), !tcg.op !122
  %T117.or = or <8 x i16> %T117.shl, %T117.lshr, !tcg.op !122
  %T117.tmp313 = load <8 x i16>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !122
  %T117.avoid_poison = select i1 false, <8 x i16> %T117.tmp313, <8 x i16> %T117.or, !tcg.op !122
  store <8 x i16> %T117.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !122
; ======== TCG [118] rotli_vec v128,e32,[t8],t3,0x21 ========
  %T118.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !123
  %T118.shl = shl <4 x i32> %T118.tmp3, splat (i32 1), !tcg.op !123
  %T118.lshr = lshr <4 x i32> %T118.tmp3, splat (i32 31), !tcg.op !123
  %T118.or = or <4 x i32> %T118.shl, %T118.lshr, !tcg.op !123
  %T118.tmp314 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !123
  %T118.avoid_poison = select i1 false, <4 x i32> %T118.tmp314, <4 x i32> %T118.or, !tcg.op !123
  store <4 x i32> %T118.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !123
; ======== TCG [119] rotli_vec v128,e64,[t8],t3,0x42 ========
  %T119.tmp3 = load <2 x i64>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !124
  %T119.shl = shl <2 x i64> %T119.tmp3, splat (i64 2), !tcg.op !124
  %T119.lshr = lshr <2 x i64> %T119.tmp3, splat (i64 62), !tcg.op !124
  %T119.or = or <2 x i64> %T119.shl, %T119.lshr, !tcg.op !124
  %T119.tmp315 = load <2 x i64>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !124
  %T119.avoid_poison = select i1 false, <2 x i64> %T119.tmp315, <2 x i64> %T119.or, !tcg.op !124
  store <2 x i64> %T119.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !124
; ======== TCG [120] rotls_vec v128,e32,[t8],t3,t2 ========
  %T120.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !125
  %T120.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T120.s, i64 0, !tcg.op !125
  %T120.shift.ie16 = insertelement <4 x i32> %T120.shift.ie, i32 %T120.s, i64 1, !tcg.op !125
  %T120.shift.ie17 = insertelement <4 x i32> %T120.shift.ie16, i32 %T120.s, i64 2, !tcg.op !125
  %T120.shift.ie18 = insertelement <4 x i32> %T120.shift.ie17, i32 %T120.s, i64 3, !tcg.op !125
  %T120.shift_value_masked = and i32 %T120.s, 31, !tcg.op !125
  %T120.shift_l = and <4 x i32> %T120.shift.ie18, splat (i32 31), !tcg.op !125
  %T120.shift_r = sub <4 x i32> splat (i32 32), %T120.shift_l, !tcg.op !125
  %T120.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !125
  %T120.shl = shl <4 x i32> %T120.tmp3, %T120.shift_l, !tcg.op !125
  %T120.lshr = lshr <4 x i32> %T120.tmp3, %T120.shift_r, !tcg.op !125
  %T120.or = or <4 x i32> %T120.shl, %T120.lshr, !tcg.op !125
  %T120.bool = icmp eq i32 %T120.shift_value_masked, 0, !tcg.op !125
  %T120.tmp319 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !125
  %T120.avoid_poison = select i1 %T120.bool, <4 x i32> %T120.tmp319, <4 x i32> %T120.or, !tcg.op !125
  store <4 x i32> %T120.avoid_poison, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !125
; ======== TCG [121] rotlv_vec v128,e32,[t8],t3,t4 ========
  %T121.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !126
  %T121.shift_l = and <4 x i32> %T121.tmp4, splat (i32 31), !tcg.op !126
  %T121.shift_r = sub <4 x i32> splat (i32 32), %T121.shift_l, !tcg.op !126
  %T121.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !126
  %T121.shl = shl <4 x i32> %T121.tmp3, %T121.shift_l, !tcg.op !126
  %T121.lshr = lshr <4 x i32> %T121.tmp3, %T121.shift_r, !tcg.op !126
  %T121.or = or <4 x i32> %T121.shl, %T121.lshr, !tcg.op !126
  store <4 x i32> %T121.or, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !126
; ======== TCG [122] rotr_i32 [t2],t2,t0 ========
  %T122.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !127
  %T122.shift_value_masked = and i32 %T122.tmp0, 31, !tcg.op !127
  %T122.shift_r = and i32 %T122.tmp0, 31, !tcg.op !127
  %T122.shift_l = sub i32 32, %T122.shift_r, !tcg.op !127
  %T122.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !127
  %T122.shl = shl i32 %T122.tmp2, %T122.shift_l, !tcg.op !127
  %T122.lshr = lshr i32 %T122.tmp2, %T122.shift_r, !tcg.op !127
  %T122.or = or i32 %T122.shl, %T122.lshr, !tcg.op !127
  %T122.bool = icmp eq i32 %T122.shift_value_masked, 0, !tcg.op !127
  %T122.tmp220 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !127
  %T122.avoid_poison = select i1 %T122.bool, i32 %T122.tmp220, i32 %T122.or, !tcg.op !127
  store i32 %T122.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !127
; ======== TCG [123] rotr_i64 [t2],t2,t0 ========
  %T123.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !128
  %T123.shift_value_masked = and i64 %T123.tmp0, 63, !tcg.op !128
  %T123.shift_r = and i64 %T123.tmp0, 63, !tcg.op !128
  %T123.shift_l = sub i64 64, %T123.shift_r, !tcg.op !128
  %T123.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !128
  %T123.shl = shl i64 %T123.tmp2, %T123.shift_l, !tcg.op !128
  %T123.lshr = lshr i64 %T123.tmp2, %T123.shift_r, !tcg.op !128
  %T123.or = or i64 %T123.shl, %T123.lshr, !tcg.op !128
  %T123.bool = icmp eq i64 %T123.shift_value_masked, 0, !tcg.op !128
  %T123.tmp221 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !128
  %T123.avoid_poison = select i1 %T123.bool, i64 %T123.tmp221, i64 %T123.or, !tcg.op !128
  store i64 %T123.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !128
; ======== TCG [124] rotr_i32 [t2],t2,0x4 ========
  %T124.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !129
  %T124.shl = shl i32 %T124.tmp2, 28, !tcg.op !129
  %T124.lshr = lshr i32 %T124.tmp2, 4, !tcg.op !129
  %T124.or = or i32 %T124.shl, %T124.lshr, !tcg.op !129
  %T124.tmp222 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !129
  %T124.avoid_poison = select i1 false, i32 %T124.tmp222, i32 %T124.or, !tcg.op !129
  store i32 %T124.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !129
; ======== TCG [125] rotr_i64 [t2],t2,0x100 ========
  %T125.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !130
  %T125.shl = shl i64 %T125.tmp2, 64, !tcg.op !130
  %T125.lshr = lshr i64 %T125.tmp2, 0, !tcg.op !130
  %T125.or = or i64 %T125.shl, %T125.lshr, !tcg.op !130
  %T125.tmp223 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !130
  %T125.avoid_poison = select i1 true, i64 %T125.tmp223, i64 %T125.or, !tcg.op !130
  store i64 %T125.avoid_poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !130
; ======== TCG [126] rotrv_vec v128,e32,[t8],t3,t4 ========
  %T126.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !131
  %T126.shift_r = and <4 x i32> %T126.tmp4, splat (i32 31), !tcg.op !131
  %T126.shift_l = sub <4 x i32> splat (i32 32), %T126.shift_r, !tcg.op !131
  %T126.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !131
  %T126.shl = shl <4 x i32> %T126.tmp3, %T126.shift_l, !tcg.op !131
  %T126.lshr = lshr <4 x i32> %T126.tmp3, %T126.shift_r, !tcg.op !131
  %T126.or = or <4 x i32> %T126.shl, %T126.lshr, !tcg.op !131
  store <4 x i32> %T126.or, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !131
; ======== TCG [127] shli_vec v128,e8,[t8],t3,0x2 ========
  %T127.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !132
  %T127.out = shl <16 x i8> %T127.tmp3, splat (i8 2), !tcg.op !132
  store <16 x i8> %T127.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !132
; ======== TCG [128] shli_vec v128,e8,[t8],t3,0x9 ========
  %T128.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !133
  %T128.out = shl <16 x i8> %T128.tmp3, splat (i8 1), !tcg.op !133
  store <16 x i8> %T128.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !133
; ======== TCG [129] shli_vec v128,e16,[t8],t3,0x11 ========
  %T129.tmp3 = load <8 x i16>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !134
  %T129.out = shl <8 x i16> %T129.tmp3, splat (i16 1), !tcg.op !134
  store <8 x i16> %T129.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !134
; ======== TCG [130] shli_vec v128,e32,[t8],t3,0x21 ========
  %T130.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !135
  %T130.out = shl <4 x i32> %T130.tmp3, splat (i32 1), !tcg.op !135
  store <4 x i32> %T130.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !135
; ======== TCG [131] shli_vec v128,e64,[t8],t3,0x42 ========
  %T131.tmp3 = load <2 x i64>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !136
  %T131.out = shl <2 x i64> %T131.tmp3, splat (i64 2), !tcg.op !136
  store <2 x i64> %T131.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !136
; ======== TCG [132] shls_vec v128,e32,[t8],t3,t2 ========
  %T132.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !137
  %T132.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T132.s, i64 0, !tcg.op !137
  %T132.shift.ie24 = insertelement <4 x i32> %T132.shift.ie, i32 %T132.s, i64 1, !tcg.op !137
  %T132.shift.ie25 = insertelement <4 x i32> %T132.shift.ie24, i32 %T132.s, i64 2, !tcg.op !137
  %T132.shift.ie26 = insertelement <4 x i32> %T132.shift.ie25, i32 %T132.s, i64 3, !tcg.op !137
  %T132.shift = and <4 x i32> %T132.shift.ie26, splat (i32 31), !tcg.op !137
  %T132.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !137
  %T132.out = shl <4 x i32> %T132.tmp3, %T132.shift, !tcg.op !137
  store <4 x i32> %T132.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !137
; ======== TCG [133] shri_vec v128,e32,[t8],t3,0x2 ========
  %T133.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !138
  %T133.out = lshr <4 x i32> %T133.tmp3, splat (i32 2), !tcg.op !138
  store <4 x i32> %T133.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !138
; ======== TCG [134] shrs_vec v128,e32,[t8],t3,t2 ========
  %T134.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !139
  %T134.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T134.s, i64 0, !tcg.op !139
  %T134.shift.ie27 = insertelement <4 x i32> %T134.shift.ie, i32 %T134.s, i64 1, !tcg.op !139
  %T134.shift.ie28 = insertelement <4 x i32> %T134.shift.ie27, i32 %T134.s, i64 2, !tcg.op !139
  %T134.shift.ie29 = insertelement <4 x i32> %T134.shift.ie28, i32 %T134.s, i64 3, !tcg.op !139
  %T134.shift = and <4 x i32> %T134.shift.ie29, splat (i32 31), !tcg.op !139
  %T134.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !139
  %T134.out = lshr <4 x i32> %T134.tmp3, %T134.shift, !tcg.op !139
  store <4 x i32> %T134.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !139
; ======== TCG [135] sari_vec v128,e32,[t8],t3,0x2 ========
  %T135.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !140
  %T135.out = ashr <4 x i32> %T135.tmp3, splat (i32 2), !tcg.op !140
  store <4 x i32> %T135.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !140
; ======== TCG [136] sars_vec v128,e32,[t8],t3,t2 ========
  %T136.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !141
  %T136.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T136.s, i64 0, !tcg.op !141
  %T136.shift.ie30 = insertelement <4 x i32> %T136.shift.ie, i32 %T136.s, i64 1, !tcg.op !141
  %T136.shift.ie31 = insertelement <4 x i32> %T136.shift.ie30, i32 %T136.s, i64 2, !tcg.op !141
  %T136.shift.ie32 = insertelement <4 x i32> %T136.shift.ie31, i32 %T136.s, i64 3, !tcg.op !141
  %T136.shift = and <4 x i32> %T136.shift.ie32, splat (i32 31), !tcg.op !141
  %T136.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !141
  %T136.out = ashr <4 x i32> %T136.tmp3, %T136.shift, !tcg.op !141
  store <4 x i32> %T136.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !141
; ======== TCG [137] andc_i32 [t2],t2,t0 ========
  %T137.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !142
  %T137.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !142
  %T137.not = xor i32 %T137.tmp0, -1, !tcg.op !142
  %T137.and_a_not_b = and i32 %T137.tmp2, %T137.not, !tcg.op !142
  store i32 %T137.and_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !142
; ======== TCG [138] andc_i64 [t2],t2,t0 ========
  %T138.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !143
  %T138.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !143
  %T138.not = xor i64 %T138.tmp0, -1, !tcg.op !143
  %T138.and_a_not_b = and i64 %T138.tmp2, %T138.not, !tcg.op !143
  store i64 %T138.and_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !143
; ======== TCG [139] andc_vec v128,e32,[t8],t3,t4 ========
  %T139.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !144
  %T139.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !144
  %T139.not = xor <4 x i32> %T139.tmp4, splat (i32 -1), !tcg.op !144
  %T139.and_a_not_b = and <4 x i32> %T139.tmp3, %T139.not, !tcg.op !144
  store <4 x i32> %T139.and_a_not_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !144
; ======== TCG [140] nor_i32 [t2],t2,t0 ========
  %T140.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !145
  %T140.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !145
  %T140.or = or i32 %T140.tmp2, %T140.tmp0, !tcg.op !145
  %T140.not_or_a_b = xor i32 %T140.or, -1, !tcg.op !145
  store i32 %T140.not_or_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !145
; ======== TCG [141] nor_i64 [t2],t2,t0 ========
  %T141.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !146
  %T141.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !146
  %T141.or = or i64 %T141.tmp2, %T141.tmp0, !tcg.op !146
  %T141.not_or_a_b = xor i64 %T141.or, -1, !tcg.op !146
  store i64 %T141.not_or_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !146
; ======== TCG [142] nor_vec v128,e32,[t8],t3,t4 ========
  %T142.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !147
  %T142.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !147
  %T142.or = or <4 x i32> %T142.tmp3, %T142.tmp4, !tcg.op !147
  %T142.not_or_a_b = xor <4 x i32> %T142.or, splat (i32 -1), !tcg.op !147
  store <4 x i32> %T142.not_or_a_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !147
; ======== TCG [143] orc_i32 [t2],t2,t0 ========
  %T143.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !148
  %T143.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !148
  %T143.not = xor i32 %T143.tmp0, -1, !tcg.op !148
  %T143.or_a_not_b = or i32 %T143.tmp2, %T143.not, !tcg.op !148
  store i32 %T143.or_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !148
; ======== TCG [144] orc_i64 [t2],t2,t0 ========
  %T144.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !149
  %T144.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !149
  %T144.not = xor i64 %T144.tmp0, -1, !tcg.op !149
  %T144.or_a_not_b = or i64 %T144.tmp2, %T144.not, !tcg.op !149
  store i64 %T144.or_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !149
; ======== TCG [145] orc_vec v128,e32,[t8],t3,t4 ========
  %T145.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !150
  %T145.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !150
  %T145.not = xor <4 x i32> %T145.tmp4, splat (i32 -1), !tcg.op !150
  %T145.or_a_not_b = or <4 x i32> %T145.tmp3, %T145.not, !tcg.op !150
  store <4 x i32> %T145.or_a_not_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !150
; ======== TCG [146] nand_i32 [t2],t2,t0 ========
  %T146.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !151
  %T146.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !151
  %T146.and = and i32 %T146.tmp2, %T146.tmp0, !tcg.op !151
  %T146.not_and_a_b = xor i32 %T146.and, -1, !tcg.op !151
  store i32 %T146.not_and_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !151
; ======== TCG [147] nand_i64 [t2],t2,t0 ========
  %T147.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !152
  %T147.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !152
  %T147.and = and i64 %T147.tmp2, %T147.tmp0, !tcg.op !152
  %T147.not_and_a_b = xor i64 %T147.and, -1, !tcg.op !152
  store i64 %T147.not_and_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !152
; ======== TCG [148] nand_vec v128,e32,[t8],t3,t4 ========
  %T148.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !153
  %T148.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !153
  %T148.and = and <4 x i32> %T148.tmp3, %T148.tmp4, !tcg.op !153
  %T148.not_and_a_b = xor <4 x i32> %T148.and, splat (i32 -1), !tcg.op !153
  store <4 x i32> %T148.not_and_a_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !153
; ======== TCG [149] eqv_i32 [t2],t2,t0 ========
  %T149.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !154
  %T149.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !154
  %T149.xor = xor i32 %T149.tmp2, %T149.tmp0, !tcg.op !154
  %T149.not_xor_a_b = xor i32 %T149.xor, -1, !tcg.op !154
  store i32 %T149.not_xor_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !154
; ======== TCG [150] eqv_i64 [t2],t2,t0 ========
  %T150.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !155
  %T150.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !155
  %T150.xor = xor i64 %T150.tmp2, %T150.tmp0, !tcg.op !155
  %T150.not_xor_a_b = xor i64 %T150.xor, -1, !tcg.op !155
  store i64 %T150.not_xor_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !155
; ======== TCG [151] eqv_vec v128,e32,[t8],t3,t4 ========
  %T151.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !156
  %T151.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !156
  %T151.xor = xor <4 x i32> %T151.tmp3, %T151.tmp4, !tcg.op !156
  %T151.not_xor_a_b = xor <4 x i32> %T151.xor, splat (i32 -1), !tcg.op !156
  store <4 x i32> %T151.not_xor_a_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !156
; ======== TCG [152] neg_i32 [t2],t2 ========
  %T152.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !157
  %T152.sub_zero_a = sub i32 0, %T152.tmp2, !tcg.op !157
  store i32 %T152.sub_zero_a, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !157
; ======== TCG [153] neg_i64 [t2],t2 ========
  %T153.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !158
  %T153.sub_zero_a = sub i64 0, %T153.tmp2, !tcg.op !158
  store i64 %T153.sub_zero_a, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !158
; ======== TCG [154] neg_vec v128,e32,[t8],t3 ========
  %T154.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !159
  %T154.sub_zero_a = sub <4 x i32> zeroinitializer, %T154.tmp3, !tcg.op !159
  store <4 x i32> %T154.sub_zero_a, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !159
; ======== TCG [155] not_i32 [t2],t2 ========
  %T155.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !160
  %T155.not = xor i32 %T155.tmp2, -1, !tcg.op !160
  store i32 %T155.not, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !160
; ======== TCG [156] not_i64 [t2],t2 ========
  %T156.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !161
  %T156.not = xor i64 %T156.tmp2, -1, !tcg.op !161
  store i64 %T156.not, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !161
; ======== TCG [157] not_vec v128,e32,[t8],t3 ========
  %T157.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !162
  %T157.not = xor <4 x i32> %T157.tmp3, splat (i32 -1), !tcg.op !162
  store <4 x i32> %T157.not, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !162
; ======== TCG [158] bswap16_i32 [t2],t2,attr-swp:oz ========
  %T158.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !163
  %T158.vec = bitcast i32 %T158.tmp2 to <4 x i8>, !tcg.op !163
  %T158.vec.ee = extractelement <4 x i8> %T158.vec, i64 0, !tcg.op !163
  %T158.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T158.vec.ee, i64 3, !tcg.op !163
  %T158.vec.ee33 = extractelement <4 x i8> %T158.vec, i64 1, !tcg.op !163
  %T158.vec_swap.ie34 = insertelement <4 x i8> %T158.vec_swap.ie, i8 %T158.vec.ee33, i64 2, !tcg.op !163
  %T158.vec.ee35 = extractelement <4 x i8> %T158.vec, i64 2, !tcg.op !163
  %T158.vec_swap.ie36 = insertelement <4 x i8> %T158.vec_swap.ie34, i8 %T158.vec.ee35, i64 1, !tcg.op !163
  %T158.vec.ee37 = extractelement <4 x i8> %T158.vec, i64 3, !tcg.op !163
  %T158.vec_swap.ie38 = insertelement <4 x i8> %T158.vec_swap.ie36, i8 %T158.vec.ee37, i64 0, !tcg.op !163
  %T158.swap_out = bitcast <4 x i8> %T158.vec_swap.ie38 to i32, !tcg.op !163
  %T158.out = lshr i32 %T158.swap_out, 16, !tcg.op !163
  store i32 %T158.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !163
; ======== TCG [159] bswap16_i32 [t2],t2,attr-swp:os ========
  %T159.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !164
  %T159.vec = bitcast i32 %T159.tmp2 to <4 x i8>, !tcg.op !164
  %T159.vec.ee = extractelement <4 x i8> %T159.vec, i64 0, !tcg.op !164
  %T159.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T159.vec.ee, i64 3, !tcg.op !164
  %T159.vec.ee39 = extractelement <4 x i8> %T159.vec, i64 1, !tcg.op !164
  %T159.vec_swap.ie40 = insertelement <4 x i8> %T159.vec_swap.ie, i8 %T159.vec.ee39, i64 2, !tcg.op !164
  %T159.vec.ee41 = extractelement <4 x i8> %T159.vec, i64 2, !tcg.op !164
  %T159.vec_swap.ie42 = insertelement <4 x i8> %T159.vec_swap.ie40, i8 %T159.vec.ee41, i64 1, !tcg.op !164
  %T159.vec.ee43 = extractelement <4 x i8> %T159.vec, i64 3, !tcg.op !164
  %T159.vec_swap.ie44 = insertelement <4 x i8> %T159.vec_swap.ie42, i8 %T159.vec.ee43, i64 0, !tcg.op !164
  %T159.swap_out = bitcast <4 x i8> %T159.vec_swap.ie44 to i32, !tcg.op !164
  %T159.out = ashr i32 %T159.swap_out, 16, !tcg.op !164
  store i32 %T159.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !164
; ======== TCG [160] bswap16_i32 [t2],t2,attr-swp:iz ========
  %T160.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !165
  %T160.vec = bitcast i32 %T160.tmp2 to <4 x i8>, !tcg.op !165
  %T160.vec.ee = extractelement <4 x i8> %T160.vec, i64 0, !tcg.op !165
  %T160.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T160.vec.ee, i64 3, !tcg.op !165
  %T160.vec.ee45 = extractelement <4 x i8> %T160.vec, i64 1, !tcg.op !165
  %T160.vec_swap.ie46 = insertelement <4 x i8> %T160.vec_swap.ie, i8 %T160.vec.ee45, i64 2, !tcg.op !165
  %T160.vec.ee47 = extractelement <4 x i8> %T160.vec, i64 2, !tcg.op !165
  %T160.vec_swap.ie48 = insertelement <4 x i8> %T160.vec_swap.ie46, i8 %T160.vec.ee47, i64 1, !tcg.op !165
  %T160.vec.ee49 = extractelement <4 x i8> %T160.vec, i64 3, !tcg.op !165
  %T160.vec_swap.ie50 = insertelement <4 x i8> %T160.vec_swap.ie48, i8 %T160.vec.ee49, i64 0, !tcg.op !165
  %T160.swap_out = bitcast <4 x i8> %T160.vec_swap.ie50 to i32, !tcg.op !165
  %T160.out = lshr i32 %T160.swap_out, 16, !tcg.op !165
  store i32 %T160.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !165
; ======== TCG [161] bswap16_i32 [t2],t2,attr-swp:iz,attr-swp:oz ========
  %T161.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !166
  %T161.vec = bitcast i32 %T161.tmp2 to <4 x i8>, !tcg.op !166
  %T161.vec.ee = extractelement <4 x i8> %T161.vec, i64 0, !tcg.op !166
  %T161.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T161.vec.ee, i64 3, !tcg.op !166
  %T161.vec.ee51 = extractelement <4 x i8> %T161.vec, i64 1, !tcg.op !166
  %T161.vec_swap.ie52 = insertelement <4 x i8> %T161.vec_swap.ie, i8 %T161.vec.ee51, i64 2, !tcg.op !166
  %T161.vec.ee53 = extractelement <4 x i8> %T161.vec, i64 2, !tcg.op !166
  %T161.vec_swap.ie54 = insertelement <4 x i8> %T161.vec_swap.ie52, i8 %T161.vec.ee53, i64 1, !tcg.op !166
  %T161.vec.ee55 = extractelement <4 x i8> %T161.vec, i64 3, !tcg.op !166
  %T161.vec_swap.ie56 = insertelement <4 x i8> %T161.vec_swap.ie54, i8 %T161.vec.ee55, i64 0, !tcg.op !166
  %T161.swap_out = bitcast <4 x i8> %T161.vec_swap.ie56 to i32, !tcg.op !166
  %T161.out = lshr i32 %T161.swap_out, 16, !tcg.op !166
  store i32 %T161.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !166
; ======== TCG [162] bswap16_i32 [t2],t2,attr-swp:iz,attr-swp:os ========
  %T162.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !167
  %T162.vec = bitcast i32 %T162.tmp2 to <4 x i8>, !tcg.op !167
  %T162.vec.ee = extractelement <4 x i8> %T162.vec, i64 0, !tcg.op !167
  %T162.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T162.vec.ee, i64 3, !tcg.op !167
  %T162.vec.ee57 = extractelement <4 x i8> %T162.vec, i64 1, !tcg.op !167
  %T162.vec_swap.ie58 = insertelement <4 x i8> %T162.vec_swap.ie, i8 %T162.vec.ee57, i64 2, !tcg.op !167
  %T162.vec.ee59 = extractelement <4 x i8> %T162.vec, i64 2, !tcg.op !167
  %T162.vec_swap.ie60 = insertelement <4 x i8> %T162.vec_swap.ie58, i8 %T162.vec.ee59, i64 1, !tcg.op !167
  %T162.vec.ee61 = extractelement <4 x i8> %T162.vec, i64 3, !tcg.op !167
  %T162.vec_swap.ie62 = insertelement <4 x i8> %T162.vec_swap.ie60, i8 %T162.vec.ee61, i64 0, !tcg.op !167
  %T162.swap_out = bitcast <4 x i8> %T162.vec_swap.ie62 to i32, !tcg.op !167
  %T162.out = ashr i32 %T162.swap_out, 16, !tcg.op !167
  store i32 %T162.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !167
; ======== TCG [163] bswap16_i32 [t2],t2 ========
  %T163.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !168
  %T163.vec = bitcast i32 %T163.tmp2 to <4 x i8>, !tcg.op !168
  %T163.vec.ee = extractelement <4 x i8> %T163.vec, i64 0, !tcg.op !168
  %T163.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T163.vec.ee, i64 3, !tcg.op !168
  %T163.vec.ee63 = extractelement <4 x i8> %T163.vec, i64 1, !tcg.op !168
  %T163.vec_swap.ie64 = insertelement <4 x i8> %T163.vec_swap.ie, i8 %T163.vec.ee63, i64 2, !tcg.op !168
  %T163.vec.ee65 = extractelement <4 x i8> %T163.vec, i64 2, !tcg.op !168
  %T163.vec_swap.ie66 = insertelement <4 x i8> %T163.vec_swap.ie64, i8 %T163.vec.ee65, i64 1, !tcg.op !168
  %T163.vec.ee67 = extractelement <4 x i8> %T163.vec, i64 3, !tcg.op !168
  %T163.vec_swap.ie68 = insertelement <4 x i8> %T163.vec_swap.ie66, i8 %T163.vec.ee67, i64 0, !tcg.op !168
  %T163.swap_out = bitcast <4 x i8> %T163.vec_swap.ie68 to i32, !tcg.op !168
  %T163.out = lshr i32 %T163.swap_out, 16, !tcg.op !168
  store i32 %T163.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !168
; ======== TCG [164] bswap16_i64 [t2],t2,attr-swp:oz ========
  %T164.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !169
  %T164.vec = bitcast i64 %T164.tmp2 to <8 x i8>, !tcg.op !169
  %T164.vec.ee = extractelement <8 x i8> %T164.vec, i64 0, !tcg.op !169
  %T164.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T164.vec.ee, i64 7, !tcg.op !169
  %T164.vec.ee69 = extractelement <8 x i8> %T164.vec, i64 1, !tcg.op !169
  %T164.vec_swap.ie70 = insertelement <8 x i8> %T164.vec_swap.ie, i8 %T164.vec.ee69, i64 6, !tcg.op !169
  %T164.vec.ee71 = extractelement <8 x i8> %T164.vec, i64 2, !tcg.op !169
  %T164.vec_swap.ie72 = insertelement <8 x i8> %T164.vec_swap.ie70, i8 %T164.vec.ee71, i64 5, !tcg.op !169
  %T164.vec.ee73 = extractelement <8 x i8> %T164.vec, i64 3, !tcg.op !169
  %T164.vec_swap.ie74 = insertelement <8 x i8> %T164.vec_swap.ie72, i8 %T164.vec.ee73, i64 4, !tcg.op !169
  %T164.vec.ee75 = extractelement <8 x i8> %T164.vec, i64 4, !tcg.op !169
  %T164.vec_swap.ie76 = insertelement <8 x i8> %T164.vec_swap.ie74, i8 %T164.vec.ee75, i64 3, !tcg.op !169
  %T164.vec.ee77 = extractelement <8 x i8> %T164.vec, i64 5, !tcg.op !169
  %T164.vec_swap.ie78 = insertelement <8 x i8> %T164.vec_swap.ie76, i8 %T164.vec.ee77, i64 2, !tcg.op !169
  %T164.vec.ee79 = extractelement <8 x i8> %T164.vec, i64 6, !tcg.op !169
  %T164.vec_swap.ie80 = insertelement <8 x i8> %T164.vec_swap.ie78, i8 %T164.vec.ee79, i64 1, !tcg.op !169
  %T164.vec.ee81 = extractelement <8 x i8> %T164.vec, i64 7, !tcg.op !169
  %T164.vec_swap.ie82 = insertelement <8 x i8> %T164.vec_swap.ie80, i8 %T164.vec.ee81, i64 0, !tcg.op !169
  %T164.swap_out = bitcast <8 x i8> %T164.vec_swap.ie82 to i64, !tcg.op !169
  %T164.out = lshr i64 %T164.swap_out, 48, !tcg.op !169
  store i64 %T164.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !169
; ======== TCG [165] bswap16_i64 [t2],t2,attr-swp:os ========
  %T165.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !170
  %T165.vec = bitcast i64 %T165.tmp2 to <8 x i8>, !tcg.op !170
  %T165.vec.ee = extractelement <8 x i8> %T165.vec, i64 0, !tcg.op !170
  %T165.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T165.vec.ee, i64 7, !tcg.op !170
  %T165.vec.ee83 = extractelement <8 x i8> %T165.vec, i64 1, !tcg.op !170
  %T165.vec_swap.ie84 = insertelement <8 x i8> %T165.vec_swap.ie, i8 %T165.vec.ee83, i64 6, !tcg.op !170
  %T165.vec.ee85 = extractelement <8 x i8> %T165.vec, i64 2, !tcg.op !170
  %T165.vec_swap.ie86 = insertelement <8 x i8> %T165.vec_swap.ie84, i8 %T165.vec.ee85, i64 5, !tcg.op !170
  %T165.vec.ee87 = extractelement <8 x i8> %T165.vec, i64 3, !tcg.op !170
  %T165.vec_swap.ie88 = insertelement <8 x i8> %T165.vec_swap.ie86, i8 %T165.vec.ee87, i64 4, !tcg.op !170
  %T165.vec.ee89 = extractelement <8 x i8> %T165.vec, i64 4, !tcg.op !170
  %T165.vec_swap.ie90 = insertelement <8 x i8> %T165.vec_swap.ie88, i8 %T165.vec.ee89, i64 3, !tcg.op !170
  %T165.vec.ee91 = extractelement <8 x i8> %T165.vec, i64 5, !tcg.op !170
  %T165.vec_swap.ie92 = insertelement <8 x i8> %T165.vec_swap.ie90, i8 %T165.vec.ee91, i64 2, !tcg.op !170
  %T165.vec.ee93 = extractelement <8 x i8> %T165.vec, i64 6, !tcg.op !170
  %T165.vec_swap.ie94 = insertelement <8 x i8> %T165.vec_swap.ie92, i8 %T165.vec.ee93, i64 1, !tcg.op !170
  %T165.vec.ee95 = extractelement <8 x i8> %T165.vec, i64 7, !tcg.op !170
  %T165.vec_swap.ie96 = insertelement <8 x i8> %T165.vec_swap.ie94, i8 %T165.vec.ee95, i64 0, !tcg.op !170
  %T165.swap_out = bitcast <8 x i8> %T165.vec_swap.ie96 to i64, !tcg.op !170
  %T165.out = ashr i64 %T165.swap_out, 48, !tcg.op !170
  store i64 %T165.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !170
; ======== TCG [166] bswap16_i64 [t2],t2,attr-swp:iz ========
  %T166.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !171
  %T166.vec = bitcast i64 %T166.tmp2 to <8 x i8>, !tcg.op !171
  %T166.vec.ee = extractelement <8 x i8> %T166.vec, i64 0, !tcg.op !171
  %T166.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T166.vec.ee, i64 7, !tcg.op !171
  %T166.vec.ee97 = extractelement <8 x i8> %T166.vec, i64 1, !tcg.op !171
  %T166.vec_swap.ie98 = insertelement <8 x i8> %T166.vec_swap.ie, i8 %T166.vec.ee97, i64 6, !tcg.op !171
  %T166.vec.ee99 = extractelement <8 x i8> %T166.vec, i64 2, !tcg.op !171
  %T166.vec_swap.ie100 = insertelement <8 x i8> %T166.vec_swap.ie98, i8 %T166.vec.ee99, i64 5, !tcg.op !171
  %T166.vec.ee101 = extractelement <8 x i8> %T166.vec, i64 3, !tcg.op !171
  %T166.vec_swap.ie102 = insertelement <8 x i8> %T166.vec_swap.ie100, i8 %T166.vec.ee101, i64 4, !tcg.op !171
  %T166.vec.ee103 = extractelement <8 x i8> %T166.vec, i64 4, !tcg.op !171
  %T166.vec_swap.ie104 = insertelement <8 x i8> %T166.vec_swap.ie102, i8 %T166.vec.ee103, i64 3, !tcg.op !171
  %T166.vec.ee105 = extractelement <8 x i8> %T166.vec, i64 5, !tcg.op !171
  %T166.vec_swap.ie106 = insertelement <8 x i8> %T166.vec_swap.ie104, i8 %T166.vec.ee105, i64 2, !tcg.op !171
  %T166.vec.ee107 = extractelement <8 x i8> %T166.vec, i64 6, !tcg.op !171
  %T166.vec_swap.ie108 = insertelement <8 x i8> %T166.vec_swap.ie106, i8 %T166.vec.ee107, i64 1, !tcg.op !171
  %T166.vec.ee109 = extractelement <8 x i8> %T166.vec, i64 7, !tcg.op !171
  %T166.vec_swap.ie110 = insertelement <8 x i8> %T166.vec_swap.ie108, i8 %T166.vec.ee109, i64 0, !tcg.op !171
  %T166.swap_out = bitcast <8 x i8> %T166.vec_swap.ie110 to i64, !tcg.op !171
  %T166.out = lshr i64 %T166.swap_out, 48, !tcg.op !171
  store i64 %T166.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !171
; ======== TCG [167] bswap16_i64 [t2],t2,attr-swp:iz,attr-swp:oz ========
  %T167.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !172
  %T167.vec = bitcast i64 %T167.tmp2 to <8 x i8>, !tcg.op !172
  %T167.vec.ee = extractelement <8 x i8> %T167.vec, i64 0, !tcg.op !172
  %T167.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T167.vec.ee, i64 7, !tcg.op !172
  %T167.vec.ee111 = extractelement <8 x i8> %T167.vec, i64 1, !tcg.op !172
  %T167.vec_swap.ie112 = insertelement <8 x i8> %T167.vec_swap.ie, i8 %T167.vec.ee111, i64 6, !tcg.op !172
  %T167.vec.ee113 = extractelement <8 x i8> %T167.vec, i64 2, !tcg.op !172
  %T167.vec_swap.ie114 = insertelement <8 x i8> %T167.vec_swap.ie112, i8 %T167.vec.ee113, i64 5, !tcg.op !172
  %T167.vec.ee115 = extractelement <8 x i8> %T167.vec, i64 3, !tcg.op !172
  %T167.vec_swap.ie116 = insertelement <8 x i8> %T167.vec_swap.ie114, i8 %T167.vec.ee115, i64 4, !tcg.op !172
  %T167.vec.ee117 = extractelement <8 x i8> %T167.vec, i64 4, !tcg.op !172
  %T167.vec_swap.ie118 = insertelement <8 x i8> %T167.vec_swap.ie116, i8 %T167.vec.ee117, i64 3, !tcg.op !172
  %T167.vec.ee119 = extractelement <8 x i8> %T167.vec, i64 5, !tcg.op !172
  %T167.vec_swap.ie120 = insertelement <8 x i8> %T167.vec_swap.ie118, i8 %T167.vec.ee119, i64 2, !tcg.op !172
  %T167.vec.ee121 = extractelement <8 x i8> %T167.vec, i64 6, !tcg.op !172
  %T167.vec_swap.ie122 = insertelement <8 x i8> %T167.vec_swap.ie120, i8 %T167.vec.ee121, i64 1, !tcg.op !172
  %T167.vec.ee123 = extractelement <8 x i8> %T167.vec, i64 7, !tcg.op !172
  %T167.vec_swap.ie124 = insertelement <8 x i8> %T167.vec_swap.ie122, i8 %T167.vec.ee123, i64 0, !tcg.op !172
  %T167.swap_out = bitcast <8 x i8> %T167.vec_swap.ie124 to i64, !tcg.op !172
  %T167.out = lshr i64 %T167.swap_out, 48, !tcg.op !172
  store i64 %T167.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !172
; ======== TCG [168] bswap16_i64 [t2],t2,attr-swp:iz,attr-swp:os ========
  %T168.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !173
  %T168.vec = bitcast i64 %T168.tmp2 to <8 x i8>, !tcg.op !173
  %T168.vec.ee = extractelement <8 x i8> %T168.vec, i64 0, !tcg.op !173
  %T168.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T168.vec.ee, i64 7, !tcg.op !173
  %T168.vec.ee125 = extractelement <8 x i8> %T168.vec, i64 1, !tcg.op !173
  %T168.vec_swap.ie126 = insertelement <8 x i8> %T168.vec_swap.ie, i8 %T168.vec.ee125, i64 6, !tcg.op !173
  %T168.vec.ee127 = extractelement <8 x i8> %T168.vec, i64 2, !tcg.op !173
  %T168.vec_swap.ie128 = insertelement <8 x i8> %T168.vec_swap.ie126, i8 %T168.vec.ee127, i64 5, !tcg.op !173
  %T168.vec.ee129 = extractelement <8 x i8> %T168.vec, i64 3, !tcg.op !173
  %T168.vec_swap.ie130 = insertelement <8 x i8> %T168.vec_swap.ie128, i8 %T168.vec.ee129, i64 4, !tcg.op !173
  %T168.vec.ee131 = extractelement <8 x i8> %T168.vec, i64 4, !tcg.op !173
  %T168.vec_swap.ie132 = insertelement <8 x i8> %T168.vec_swap.ie130, i8 %T168.vec.ee131, i64 3, !tcg.op !173
  %T168.vec.ee133 = extractelement <8 x i8> %T168.vec, i64 5, !tcg.op !173
  %T168.vec_swap.ie134 = insertelement <8 x i8> %T168.vec_swap.ie132, i8 %T168.vec.ee133, i64 2, !tcg.op !173
  %T168.vec.ee135 = extractelement <8 x i8> %T168.vec, i64 6, !tcg.op !173
  %T168.vec_swap.ie136 = insertelement <8 x i8> %T168.vec_swap.ie134, i8 %T168.vec.ee135, i64 1, !tcg.op !173
  %T168.vec.ee137 = extractelement <8 x i8> %T168.vec, i64 7, !tcg.op !173
  %T168.vec_swap.ie138 = insertelement <8 x i8> %T168.vec_swap.ie136, i8 %T168.vec.ee137, i64 0, !tcg.op !173
  %T168.swap_out = bitcast <8 x i8> %T168.vec_swap.ie138 to i64, !tcg.op !173
  %T168.out = ashr i64 %T168.swap_out, 48, !tcg.op !173
  store i64 %T168.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !173
; ======== TCG [169] bswap16_i64 [t2],t2 ========
  %T169.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !174
  %T169.vec = bitcast i64 %T169.tmp2 to <8 x i8>, !tcg.op !174
  %T169.vec.ee = extractelement <8 x i8> %T169.vec, i64 0, !tcg.op !174
  %T169.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T169.vec.ee, i64 7, !tcg.op !174
  %T169.vec.ee139 = extractelement <8 x i8> %T169.vec, i64 1, !tcg.op !174
  %T169.vec_swap.ie140 = insertelement <8 x i8> %T169.vec_swap.ie, i8 %T169.vec.ee139, i64 6, !tcg.op !174
  %T169.vec.ee141 = extractelement <8 x i8> %T169.vec, i64 2, !tcg.op !174
  %T169.vec_swap.ie142 = insertelement <8 x i8> %T169.vec_swap.ie140, i8 %T169.vec.ee141, i64 5, !tcg.op !174
  %T169.vec.ee143 = extractelement <8 x i8> %T169.vec, i64 3, !tcg.op !174
  %T169.vec_swap.ie144 = insertelement <8 x i8> %T169.vec_swap.ie142, i8 %T169.vec.ee143, i64 4, !tcg.op !174
  %T169.vec.ee145 = extractelement <8 x i8> %T169.vec, i64 4, !tcg.op !174
  %T169.vec_swap.ie146 = insertelement <8 x i8> %T169.vec_swap.ie144, i8 %T169.vec.ee145, i64 3, !tcg.op !174
  %T169.vec.ee147 = extractelement <8 x i8> %T169.vec, i64 5, !tcg.op !174
  %T169.vec_swap.ie148 = insertelement <8 x i8> %T169.vec_swap.ie146, i8 %T169.vec.ee147, i64 2, !tcg.op !174
  %T169.vec.ee149 = extractelement <8 x i8> %T169.vec, i64 6, !tcg.op !174
  %T169.vec_swap.ie150 = insertelement <8 x i8> %T169.vec_swap.ie148, i8 %T169.vec.ee149, i64 1, !tcg.op !174
  %T169.vec.ee151 = extractelement <8 x i8> %T169.vec, i64 7, !tcg.op !174
  %T169.vec_swap.ie152 = insertelement <8 x i8> %T169.vec_swap.ie150, i8 %T169.vec.ee151, i64 0, !tcg.op !174
  %T169.swap_out = bitcast <8 x i8> %T169.vec_swap.ie152 to i64, !tcg.op !174
  %T169.out = lshr i64 %T169.swap_out, 48, !tcg.op !174
  store i64 %T169.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !174
; ======== TCG [170] bswap32_i32 [t2],t2,attr-swp:oz ========
  %T170.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !175
  %T170.vec = bitcast i32 %T170.tmp2 to <4 x i8>, !tcg.op !175
  %T170.vec.ee = extractelement <4 x i8> %T170.vec, i64 0, !tcg.op !175
  %T170.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T170.vec.ee, i64 3, !tcg.op !175
  %T170.vec.ee153 = extractelement <4 x i8> %T170.vec, i64 1, !tcg.op !175
  %T170.vec_swap.ie154 = insertelement <4 x i8> %T170.vec_swap.ie, i8 %T170.vec.ee153, i64 2, !tcg.op !175
  %T170.vec.ee155 = extractelement <4 x i8> %T170.vec, i64 2, !tcg.op !175
  %T170.vec_swap.ie156 = insertelement <4 x i8> %T170.vec_swap.ie154, i8 %T170.vec.ee155, i64 1, !tcg.op !175
  %T170.vec.ee157 = extractelement <4 x i8> %T170.vec, i64 3, !tcg.op !175
  %T170.vec_swap.ie158 = insertelement <4 x i8> %T170.vec_swap.ie156, i8 %T170.vec.ee157, i64 0, !tcg.op !175
  %T170.swap_out = bitcast <4 x i8> %T170.vec_swap.ie158 to i32, !tcg.op !175
  %T170.out = lshr i32 %T170.swap_out, 0, !tcg.op !175
  store i32 %T170.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !175
; ======== TCG [171] bswap32_i32 [t2],t2,attr-swp:os ========
  %T171.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !176
  %T171.vec = bitcast i32 %T171.tmp2 to <4 x i8>, !tcg.op !176
  %T171.vec.ee = extractelement <4 x i8> %T171.vec, i64 0, !tcg.op !176
  %T171.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T171.vec.ee, i64 3, !tcg.op !176
  %T171.vec.ee159 = extractelement <4 x i8> %T171.vec, i64 1, !tcg.op !176
  %T171.vec_swap.ie160 = insertelement <4 x i8> %T171.vec_swap.ie, i8 %T171.vec.ee159, i64 2, !tcg.op !176
  %T171.vec.ee161 = extractelement <4 x i8> %T171.vec, i64 2, !tcg.op !176
  %T171.vec_swap.ie162 = insertelement <4 x i8> %T171.vec_swap.ie160, i8 %T171.vec.ee161, i64 1, !tcg.op !176
  %T171.vec.ee163 = extractelement <4 x i8> %T171.vec, i64 3, !tcg.op !176
  %T171.vec_swap.ie164 = insertelement <4 x i8> %T171.vec_swap.ie162, i8 %T171.vec.ee163, i64 0, !tcg.op !176
  %T171.swap_out = bitcast <4 x i8> %T171.vec_swap.ie164 to i32, !tcg.op !176
  %T171.out = ashr i32 %T171.swap_out, 0, !tcg.op !176
  store i32 %T171.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !176
; ======== TCG [172] bswap32_i32 [t2],t2,attr-swp:iz ========
  %T172.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !177
  %T172.vec = bitcast i32 %T172.tmp2 to <4 x i8>, !tcg.op !177
  %T172.vec.ee = extractelement <4 x i8> %T172.vec, i64 0, !tcg.op !177
  %T172.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T172.vec.ee, i64 3, !tcg.op !177
  %T172.vec.ee165 = extractelement <4 x i8> %T172.vec, i64 1, !tcg.op !177
  %T172.vec_swap.ie166 = insertelement <4 x i8> %T172.vec_swap.ie, i8 %T172.vec.ee165, i64 2, !tcg.op !177
  %T172.vec.ee167 = extractelement <4 x i8> %T172.vec, i64 2, !tcg.op !177
  %T172.vec_swap.ie168 = insertelement <4 x i8> %T172.vec_swap.ie166, i8 %T172.vec.ee167, i64 1, !tcg.op !177
  %T172.vec.ee169 = extractelement <4 x i8> %T172.vec, i64 3, !tcg.op !177
  %T172.vec_swap.ie170 = insertelement <4 x i8> %T172.vec_swap.ie168, i8 %T172.vec.ee169, i64 0, !tcg.op !177
  %T172.swap_out = bitcast <4 x i8> %T172.vec_swap.ie170 to i32, !tcg.op !177
  %T172.out = lshr i32 %T172.swap_out, 0, !tcg.op !177
  store i32 %T172.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !177
; ======== TCG [173] bswap32_i32 [t2],t2,attr-swp:iz,attr-swp:oz ========
  %T173.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !178
  %T173.vec = bitcast i32 %T173.tmp2 to <4 x i8>, !tcg.op !178
  %T173.vec.ee = extractelement <4 x i8> %T173.vec, i64 0, !tcg.op !178
  %T173.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T173.vec.ee, i64 3, !tcg.op !178
  %T173.vec.ee171 = extractelement <4 x i8> %T173.vec, i64 1, !tcg.op !178
  %T173.vec_swap.ie172 = insertelement <4 x i8> %T173.vec_swap.ie, i8 %T173.vec.ee171, i64 2, !tcg.op !178
  %T173.vec.ee173 = extractelement <4 x i8> %T173.vec, i64 2, !tcg.op !178
  %T173.vec_swap.ie174 = insertelement <4 x i8> %T173.vec_swap.ie172, i8 %T173.vec.ee173, i64 1, !tcg.op !178
  %T173.vec.ee175 = extractelement <4 x i8> %T173.vec, i64 3, !tcg.op !178
  %T173.vec_swap.ie176 = insertelement <4 x i8> %T173.vec_swap.ie174, i8 %T173.vec.ee175, i64 0, !tcg.op !178
  %T173.swap_out = bitcast <4 x i8> %T173.vec_swap.ie176 to i32, !tcg.op !178
  %T173.out = lshr i32 %T173.swap_out, 0, !tcg.op !178
  store i32 %T173.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !178
; ======== TCG [174] bswap32_i32 [t2],t2,attr-swp:iz,attr-swp:os ========
  %T174.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !179
  %T174.vec = bitcast i32 %T174.tmp2 to <4 x i8>, !tcg.op !179
  %T174.vec.ee = extractelement <4 x i8> %T174.vec, i64 0, !tcg.op !179
  %T174.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T174.vec.ee, i64 3, !tcg.op !179
  %T174.vec.ee177 = extractelement <4 x i8> %T174.vec, i64 1, !tcg.op !179
  %T174.vec_swap.ie178 = insertelement <4 x i8> %T174.vec_swap.ie, i8 %T174.vec.ee177, i64 2, !tcg.op !179
  %T174.vec.ee179 = extractelement <4 x i8> %T174.vec, i64 2, !tcg.op !179
  %T174.vec_swap.ie180 = insertelement <4 x i8> %T174.vec_swap.ie178, i8 %T174.vec.ee179, i64 1, !tcg.op !179
  %T174.vec.ee181 = extractelement <4 x i8> %T174.vec, i64 3, !tcg.op !179
  %T174.vec_swap.ie182 = insertelement <4 x i8> %T174.vec_swap.ie180, i8 %T174.vec.ee181, i64 0, !tcg.op !179
  %T174.swap_out = bitcast <4 x i8> %T174.vec_swap.ie182 to i32, !tcg.op !179
  %T174.out = ashr i32 %T174.swap_out, 0, !tcg.op !179
  store i32 %T174.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !179
; ======== TCG [175] bswap32_i32 [t2],t2 ========
  %T175.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !180
  %T175.vec = bitcast i32 %T175.tmp2 to <4 x i8>, !tcg.op !180
  %T175.vec.ee = extractelement <4 x i8> %T175.vec, i64 0, !tcg.op !180
  %T175.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T175.vec.ee, i64 3, !tcg.op !180
  %T175.vec.ee183 = extractelement <4 x i8> %T175.vec, i64 1, !tcg.op !180
  %T175.vec_swap.ie184 = insertelement <4 x i8> %T175.vec_swap.ie, i8 %T175.vec.ee183, i64 2, !tcg.op !180
  %T175.vec.ee185 = extractelement <4 x i8> %T175.vec, i64 2, !tcg.op !180
  %T175.vec_swap.ie186 = insertelement <4 x i8> %T175.vec_swap.ie184, i8 %T175.vec.ee185, i64 1, !tcg.op !180
  %T175.vec.ee187 = extractelement <4 x i8> %T175.vec, i64 3, !tcg.op !180
  %T175.vec_swap.ie188 = insertelement <4 x i8> %T175.vec_swap.ie186, i8 %T175.vec.ee187, i64 0, !tcg.op !180
  %T175.swap_out = bitcast <4 x i8> %T175.vec_swap.ie188 to i32, !tcg.op !180
  %T175.out = lshr i32 %T175.swap_out, 0, !tcg.op !180
  store i32 %T175.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !180
; ======== TCG [176] bswap32_i64 [t2],t2,attr-swp:oz ========
  %T176.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !181
  %T176.vec = bitcast i64 %T176.tmp2 to <8 x i8>, !tcg.op !181
  %T176.vec.ee = extractelement <8 x i8> %T176.vec, i64 0, !tcg.op !181
  %T176.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T176.vec.ee, i64 7, !tcg.op !181
  %T176.vec.ee189 = extractelement <8 x i8> %T176.vec, i64 1, !tcg.op !181
  %T176.vec_swap.ie190 = insertelement <8 x i8> %T176.vec_swap.ie, i8 %T176.vec.ee189, i64 6, !tcg.op !181
  %T176.vec.ee191 = extractelement <8 x i8> %T176.vec, i64 2, !tcg.op !181
  %T176.vec_swap.ie192 = insertelement <8 x i8> %T176.vec_swap.ie190, i8 %T176.vec.ee191, i64 5, !tcg.op !181
  %T176.vec.ee193 = extractelement <8 x i8> %T176.vec, i64 3, !tcg.op !181
  %T176.vec_swap.ie194 = insertelement <8 x i8> %T176.vec_swap.ie192, i8 %T176.vec.ee193, i64 4, !tcg.op !181
  %T176.vec.ee195 = extractelement <8 x i8> %T176.vec, i64 4, !tcg.op !181
  %T176.vec_swap.ie196 = insertelement <8 x i8> %T176.vec_swap.ie194, i8 %T176.vec.ee195, i64 3, !tcg.op !181
  %T176.vec.ee197 = extractelement <8 x i8> %T176.vec, i64 5, !tcg.op !181
  %T176.vec_swap.ie198 = insertelement <8 x i8> %T176.vec_swap.ie196, i8 %T176.vec.ee197, i64 2, !tcg.op !181
  %T176.vec.ee199 = extractelement <8 x i8> %T176.vec, i64 6, !tcg.op !181
  %T176.vec_swap.ie200 = insertelement <8 x i8> %T176.vec_swap.ie198, i8 %T176.vec.ee199, i64 1, !tcg.op !181
  %T176.vec.ee201 = extractelement <8 x i8> %T176.vec, i64 7, !tcg.op !181
  %T176.vec_swap.ie202 = insertelement <8 x i8> %T176.vec_swap.ie200, i8 %T176.vec.ee201, i64 0, !tcg.op !181
  %T176.swap_out = bitcast <8 x i8> %T176.vec_swap.ie202 to i64, !tcg.op !181
  %T176.out = lshr i64 %T176.swap_out, 32, !tcg.op !181
  store i64 %T176.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !181
; ======== TCG [177] bswap32_i64 [t2],t2,attr-swp:os ========
  %T177.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !182
  %T177.vec = bitcast i64 %T177.tmp2 to <8 x i8>, !tcg.op !182
  %T177.vec.ee = extractelement <8 x i8> %T177.vec, i64 0, !tcg.op !182
  %T177.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T177.vec.ee, i64 7, !tcg.op !182
  %T177.vec.ee203 = extractelement <8 x i8> %T177.vec, i64 1, !tcg.op !182
  %T177.vec_swap.ie204 = insertelement <8 x i8> %T177.vec_swap.ie, i8 %T177.vec.ee203, i64 6, !tcg.op !182
  %T177.vec.ee205 = extractelement <8 x i8> %T177.vec, i64 2, !tcg.op !182
  %T177.vec_swap.ie206 = insertelement <8 x i8> %T177.vec_swap.ie204, i8 %T177.vec.ee205, i64 5, !tcg.op !182
  %T177.vec.ee207 = extractelement <8 x i8> %T177.vec, i64 3, !tcg.op !182
  %T177.vec_swap.ie208 = insertelement <8 x i8> %T177.vec_swap.ie206, i8 %T177.vec.ee207, i64 4, !tcg.op !182
  %T177.vec.ee209 = extractelement <8 x i8> %T177.vec, i64 4, !tcg.op !182
  %T177.vec_swap.ie210 = insertelement <8 x i8> %T177.vec_swap.ie208, i8 %T177.vec.ee209, i64 3, !tcg.op !182
  %T177.vec.ee211 = extractelement <8 x i8> %T177.vec, i64 5, !tcg.op !182
  %T177.vec_swap.ie212 = insertelement <8 x i8> %T177.vec_swap.ie210, i8 %T177.vec.ee211, i64 2, !tcg.op !182
  %T177.vec.ee213 = extractelement <8 x i8> %T177.vec, i64 6, !tcg.op !182
  %T177.vec_swap.ie214 = insertelement <8 x i8> %T177.vec_swap.ie212, i8 %T177.vec.ee213, i64 1, !tcg.op !182
  %T177.vec.ee215 = extractelement <8 x i8> %T177.vec, i64 7, !tcg.op !182
  %T177.vec_swap.ie216 = insertelement <8 x i8> %T177.vec_swap.ie214, i8 %T177.vec.ee215, i64 0, !tcg.op !182
  %T177.swap_out = bitcast <8 x i8> %T177.vec_swap.ie216 to i64, !tcg.op !182
  %T177.out = ashr i64 %T177.swap_out, 32, !tcg.op !182
  store i64 %T177.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !182
; ======== TCG [178] bswap32_i64 [t2],t2,attr-swp:iz ========
  %T178.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !183
  %T178.vec = bitcast i64 %T178.tmp2 to <8 x i8>, !tcg.op !183
  %T178.vec.ee = extractelement <8 x i8> %T178.vec, i64 0, !tcg.op !183
  %T178.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T178.vec.ee, i64 7, !tcg.op !183
  %T178.vec.ee217 = extractelement <8 x i8> %T178.vec, i64 1, !tcg.op !183
  %T178.vec_swap.ie218 = insertelement <8 x i8> %T178.vec_swap.ie, i8 %T178.vec.ee217, i64 6, !tcg.op !183
  %T178.vec.ee219 = extractelement <8 x i8> %T178.vec, i64 2, !tcg.op !183
  %T178.vec_swap.ie220 = insertelement <8 x i8> %T178.vec_swap.ie218, i8 %T178.vec.ee219, i64 5, !tcg.op !183
  %T178.vec.ee221 = extractelement <8 x i8> %T178.vec, i64 3, !tcg.op !183
  %T178.vec_swap.ie222 = insertelement <8 x i8> %T178.vec_swap.ie220, i8 %T178.vec.ee221, i64 4, !tcg.op !183
  %T178.vec.ee223 = extractelement <8 x i8> %T178.vec, i64 4, !tcg.op !183
  %T178.vec_swap.ie224 = insertelement <8 x i8> %T178.vec_swap.ie222, i8 %T178.vec.ee223, i64 3, !tcg.op !183
  %T178.vec.ee225 = extractelement <8 x i8> %T178.vec, i64 5, !tcg.op !183
  %T178.vec_swap.ie226 = insertelement <8 x i8> %T178.vec_swap.ie224, i8 %T178.vec.ee225, i64 2, !tcg.op !183
  %T178.vec.ee227 = extractelement <8 x i8> %T178.vec, i64 6, !tcg.op !183
  %T178.vec_swap.ie228 = insertelement <8 x i8> %T178.vec_swap.ie226, i8 %T178.vec.ee227, i64 1, !tcg.op !183
  %T178.vec.ee229 = extractelement <8 x i8> %T178.vec, i64 7, !tcg.op !183
  %T178.vec_swap.ie230 = insertelement <8 x i8> %T178.vec_swap.ie228, i8 %T178.vec.ee229, i64 0, !tcg.op !183
  %T178.swap_out = bitcast <8 x i8> %T178.vec_swap.ie230 to i64, !tcg.op !183
  %T178.out = lshr i64 %T178.swap_out, 32, !tcg.op !183
  store i64 %T178.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !183
; ======== TCG [179] bswap32_i64 [t2],t2,attr-swp:iz,attr-swp:oz ========
  %T179.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !184
  %T179.vec = bitcast i64 %T179.tmp2 to <8 x i8>, !tcg.op !184
  %T179.vec.ee = extractelement <8 x i8> %T179.vec, i64 0, !tcg.op !184
  %T179.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T179.vec.ee, i64 7, !tcg.op !184
  %T179.vec.ee231 = extractelement <8 x i8> %T179.vec, i64 1, !tcg.op !184
  %T179.vec_swap.ie232 = insertelement <8 x i8> %T179.vec_swap.ie, i8 %T179.vec.ee231, i64 6, !tcg.op !184
  %T179.vec.ee233 = extractelement <8 x i8> %T179.vec, i64 2, !tcg.op !184
  %T179.vec_swap.ie234 = insertelement <8 x i8> %T179.vec_swap.ie232, i8 %T179.vec.ee233, i64 5, !tcg.op !184
  %T179.vec.ee235 = extractelement <8 x i8> %T179.vec, i64 3, !tcg.op !184
  %T179.vec_swap.ie236 = insertelement <8 x i8> %T179.vec_swap.ie234, i8 %T179.vec.ee235, i64 4, !tcg.op !184
  %T179.vec.ee237 = extractelement <8 x i8> %T179.vec, i64 4, !tcg.op !184
  %T179.vec_swap.ie238 = insertelement <8 x i8> %T179.vec_swap.ie236, i8 %T179.vec.ee237, i64 3, !tcg.op !184
  %T179.vec.ee239 = extractelement <8 x i8> %T179.vec, i64 5, !tcg.op !184
  %T179.vec_swap.ie240 = insertelement <8 x i8> %T179.vec_swap.ie238, i8 %T179.vec.ee239, i64 2, !tcg.op !184
  %T179.vec.ee241 = extractelement <8 x i8> %T179.vec, i64 6, !tcg.op !184
  %T179.vec_swap.ie242 = insertelement <8 x i8> %T179.vec_swap.ie240, i8 %T179.vec.ee241, i64 1, !tcg.op !184
  %T179.vec.ee243 = extractelement <8 x i8> %T179.vec, i64 7, !tcg.op !184
  %T179.vec_swap.ie244 = insertelement <8 x i8> %T179.vec_swap.ie242, i8 %T179.vec.ee243, i64 0, !tcg.op !184
  %T179.swap_out = bitcast <8 x i8> %T179.vec_swap.ie244 to i64, !tcg.op !184
  %T179.out = lshr i64 %T179.swap_out, 32, !tcg.op !184
  store i64 %T179.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !184
; ======== TCG [180] bswap32_i64 [t2],t2,attr-swp:iz,attr-swp:os ========
  %T180.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !185
  %T180.vec = bitcast i64 %T180.tmp2 to <8 x i8>, !tcg.op !185
  %T180.vec.ee = extractelement <8 x i8> %T180.vec, i64 0, !tcg.op !185
  %T180.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T180.vec.ee, i64 7, !tcg.op !185
  %T180.vec.ee245 = extractelement <8 x i8> %T180.vec, i64 1, !tcg.op !185
  %T180.vec_swap.ie246 = insertelement <8 x i8> %T180.vec_swap.ie, i8 %T180.vec.ee245, i64 6, !tcg.op !185
  %T180.vec.ee247 = extractelement <8 x i8> %T180.vec, i64 2, !tcg.op !185
  %T180.vec_swap.ie248 = insertelement <8 x i8> %T180.vec_swap.ie246, i8 %T180.vec.ee247, i64 5, !tcg.op !185
  %T180.vec.ee249 = extractelement <8 x i8> %T180.vec, i64 3, !tcg.op !185
  %T180.vec_swap.ie250 = insertelement <8 x i8> %T180.vec_swap.ie248, i8 %T180.vec.ee249, i64 4, !tcg.op !185
  %T180.vec.ee251 = extractelement <8 x i8> %T180.vec, i64 4, !tcg.op !185
  %T180.vec_swap.ie252 = insertelement <8 x i8> %T180.vec_swap.ie250, i8 %T180.vec.ee251, i64 3, !tcg.op !185
  %T180.vec.ee253 = extractelement <8 x i8> %T180.vec, i64 5, !tcg.op !185
  %T180.vec_swap.ie254 = insertelement <8 x i8> %T180.vec_swap.ie252, i8 %T180.vec.ee253, i64 2, !tcg.op !185
  %T180.vec.ee255 = extractelement <8 x i8> %T180.vec, i64 6, !tcg.op !185
  %T180.vec_swap.ie256 = insertelement <8 x i8> %T180.vec_swap.ie254, i8 %T180.vec.ee255, i64 1, !tcg.op !185
  %T180.vec.ee257 = extractelement <8 x i8> %T180.vec, i64 7, !tcg.op !185
  %T180.vec_swap.ie258 = insertelement <8 x i8> %T180.vec_swap.ie256, i8 %T180.vec.ee257, i64 0, !tcg.op !185
  %T180.swap_out = bitcast <8 x i8> %T180.vec_swap.ie258 to i64, !tcg.op !185
  %T180.out = ashr i64 %T180.swap_out, 32, !tcg.op !185
  store i64 %T180.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !185
; ======== TCG [181] bswap32_i64 [t2],t2 ========
  %T181.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !186
  %T181.vec = bitcast i64 %T181.tmp2 to <8 x i8>, !tcg.op !186
  %T181.vec.ee = extractelement <8 x i8> %T181.vec, i64 0, !tcg.op !186
  %T181.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T181.vec.ee, i64 7, !tcg.op !186
  %T181.vec.ee259 = extractelement <8 x i8> %T181.vec, i64 1, !tcg.op !186
  %T181.vec_swap.ie260 = insertelement <8 x i8> %T181.vec_swap.ie, i8 %T181.vec.ee259, i64 6, !tcg.op !186
  %T181.vec.ee261 = extractelement <8 x i8> %T181.vec, i64 2, !tcg.op !186
  %T181.vec_swap.ie262 = insertelement <8 x i8> %T181.vec_swap.ie260, i8 %T181.vec.ee261, i64 5, !tcg.op !186
  %T181.vec.ee263 = extractelement <8 x i8> %T181.vec, i64 3, !tcg.op !186
  %T181.vec_swap.ie264 = insertelement <8 x i8> %T181.vec_swap.ie262, i8 %T181.vec.ee263, i64 4, !tcg.op !186
  %T181.vec.ee265 = extractelement <8 x i8> %T181.vec, i64 4, !tcg.op !186
  %T181.vec_swap.ie266 = insertelement <8 x i8> %T181.vec_swap.ie264, i8 %T181.vec.ee265, i64 3, !tcg.op !186
  %T181.vec.ee267 = extractelement <8 x i8> %T181.vec, i64 5, !tcg.op !186
  %T181.vec_swap.ie268 = insertelement <8 x i8> %T181.vec_swap.ie266, i8 %T181.vec.ee267, i64 2, !tcg.op !186
  %T181.vec.ee269 = extractelement <8 x i8> %T181.vec, i64 6, !tcg.op !186
  %T181.vec_swap.ie270 = insertelement <8 x i8> %T181.vec_swap.ie268, i8 %T181.vec.ee269, i64 1, !tcg.op !186
  %T181.vec.ee271 = extractelement <8 x i8> %T181.vec, i64 7, !tcg.op !186
  %T181.vec_swap.ie272 = insertelement <8 x i8> %T181.vec_swap.ie270, i8 %T181.vec.ee271, i64 0, !tcg.op !186
  %T181.swap_out = bitcast <8 x i8> %T181.vec_swap.ie272 to i64, !tcg.op !186
  %T181.out = lshr i64 %T181.swap_out, 32, !tcg.op !186
  store i64 %T181.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !186
; ======== TCG [182] bswap64_i64 [t2],t2,attr-swp:oz ========
  %T182.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !187
  %T182.vec = bitcast i64 %T182.tmp2 to <8 x i8>, !tcg.op !187
  %T182.vec.ee = extractelement <8 x i8> %T182.vec, i64 0, !tcg.op !187
  %T182.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T182.vec.ee, i64 7, !tcg.op !187
  %T182.vec.ee273 = extractelement <8 x i8> %T182.vec, i64 1, !tcg.op !187
  %T182.vec_swap.ie274 = insertelement <8 x i8> %T182.vec_swap.ie, i8 %T182.vec.ee273, i64 6, !tcg.op !187
  %T182.vec.ee275 = extractelement <8 x i8> %T182.vec, i64 2, !tcg.op !187
  %T182.vec_swap.ie276 = insertelement <8 x i8> %T182.vec_swap.ie274, i8 %T182.vec.ee275, i64 5, !tcg.op !187
  %T182.vec.ee277 = extractelement <8 x i8> %T182.vec, i64 3, !tcg.op !187
  %T182.vec_swap.ie278 = insertelement <8 x i8> %T182.vec_swap.ie276, i8 %T182.vec.ee277, i64 4, !tcg.op !187
  %T182.vec.ee279 = extractelement <8 x i8> %T182.vec, i64 4, !tcg.op !187
  %T182.vec_swap.ie280 = insertelement <8 x i8> %T182.vec_swap.ie278, i8 %T182.vec.ee279, i64 3, !tcg.op !187
  %T182.vec.ee281 = extractelement <8 x i8> %T182.vec, i64 5, !tcg.op !187
  %T182.vec_swap.ie282 = insertelement <8 x i8> %T182.vec_swap.ie280, i8 %T182.vec.ee281, i64 2, !tcg.op !187
  %T182.vec.ee283 = extractelement <8 x i8> %T182.vec, i64 6, !tcg.op !187
  %T182.vec_swap.ie284 = insertelement <8 x i8> %T182.vec_swap.ie282, i8 %T182.vec.ee283, i64 1, !tcg.op !187
  %T182.vec.ee285 = extractelement <8 x i8> %T182.vec, i64 7, !tcg.op !187
  %T182.vec_swap.ie286 = insertelement <8 x i8> %T182.vec_swap.ie284, i8 %T182.vec.ee285, i64 0, !tcg.op !187
  %T182.swap_out = bitcast <8 x i8> %T182.vec_swap.ie286 to i64, !tcg.op !187
  %T182.out = lshr i64 %T182.swap_out, 0, !tcg.op !187
  store i64 %T182.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !187
; ======== TCG [183] bswap64_i64 [t2],t2,attr-swp:os ========
  %T183.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !188
  %T183.vec = bitcast i64 %T183.tmp2 to <8 x i8>, !tcg.op !188
  %T183.vec.ee = extractelement <8 x i8> %T183.vec, i64 0, !tcg.op !188
  %T183.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T183.vec.ee, i64 7, !tcg.op !188
  %T183.vec.ee287 = extractelement <8 x i8> %T183.vec, i64 1, !tcg.op !188
  %T183.vec_swap.ie288 = insertelement <8 x i8> %T183.vec_swap.ie, i8 %T183.vec.ee287, i64 6, !tcg.op !188
  %T183.vec.ee289 = extractelement <8 x i8> %T183.vec, i64 2, !tcg.op !188
  %T183.vec_swap.ie290 = insertelement <8 x i8> %T183.vec_swap.ie288, i8 %T183.vec.ee289, i64 5, !tcg.op !188
  %T183.vec.ee291 = extractelement <8 x i8> %T183.vec, i64 3, !tcg.op !188
  %T183.vec_swap.ie292 = insertelement <8 x i8> %T183.vec_swap.ie290, i8 %T183.vec.ee291, i64 4, !tcg.op !188
  %T183.vec.ee293 = extractelement <8 x i8> %T183.vec, i64 4, !tcg.op !188
  %T183.vec_swap.ie294 = insertelement <8 x i8> %T183.vec_swap.ie292, i8 %T183.vec.ee293, i64 3, !tcg.op !188
  %T183.vec.ee295 = extractelement <8 x i8> %T183.vec, i64 5, !tcg.op !188
  %T183.vec_swap.ie296 = insertelement <8 x i8> %T183.vec_swap.ie294, i8 %T183.vec.ee295, i64 2, !tcg.op !188
  %T183.vec.ee297 = extractelement <8 x i8> %T183.vec, i64 6, !tcg.op !188
  %T183.vec_swap.ie298 = insertelement <8 x i8> %T183.vec_swap.ie296, i8 %T183.vec.ee297, i64 1, !tcg.op !188
  %T183.vec.ee299 = extractelement <8 x i8> %T183.vec, i64 7, !tcg.op !188
  %T183.vec_swap.ie300 = insertelement <8 x i8> %T183.vec_swap.ie298, i8 %T183.vec.ee299, i64 0, !tcg.op !188
  %T183.swap_out = bitcast <8 x i8> %T183.vec_swap.ie300 to i64, !tcg.op !188
  %T183.out = ashr i64 %T183.swap_out, 0, !tcg.op !188
  store i64 %T183.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !188
; ======== TCG [184] bswap64_i64 [t2],t2,attr-swp:iz ========
  %T184.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !189
  %T184.vec = bitcast i64 %T184.tmp2 to <8 x i8>, !tcg.op !189
  %T184.vec.ee = extractelement <8 x i8> %T184.vec, i64 0, !tcg.op !189
  %T184.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T184.vec.ee, i64 7, !tcg.op !189
  %T184.vec.ee301 = extractelement <8 x i8> %T184.vec, i64 1, !tcg.op !189
  %T184.vec_swap.ie302 = insertelement <8 x i8> %T184.vec_swap.ie, i8 %T184.vec.ee301, i64 6, !tcg.op !189
  %T184.vec.ee303 = extractelement <8 x i8> %T184.vec, i64 2, !tcg.op !189
  %T184.vec_swap.ie304 = insertelement <8 x i8> %T184.vec_swap.ie302, i8 %T184.vec.ee303, i64 5, !tcg.op !189
  %T184.vec.ee305 = extractelement <8 x i8> %T184.vec, i64 3, !tcg.op !189
  %T184.vec_swap.ie306 = insertelement <8 x i8> %T184.vec_swap.ie304, i8 %T184.vec.ee305, i64 4, !tcg.op !189
  %T184.vec.ee307 = extractelement <8 x i8> %T184.vec, i64 4, !tcg.op !189
  %T184.vec_swap.ie308 = insertelement <8 x i8> %T184.vec_swap.ie306, i8 %T184.vec.ee307, i64 3, !tcg.op !189
  %T184.vec.ee309 = extractelement <8 x i8> %T184.vec, i64 5, !tcg.op !189
  %T184.vec_swap.ie310 = insertelement <8 x i8> %T184.vec_swap.ie308, i8 %T184.vec.ee309, i64 2, !tcg.op !189
  %T184.vec.ee311 = extractelement <8 x i8> %T184.vec, i64 6, !tcg.op !189
  %T184.vec_swap.ie312 = insertelement <8 x i8> %T184.vec_swap.ie310, i8 %T184.vec.ee311, i64 1, !tcg.op !189
  %T184.vec.ee313 = extractelement <8 x i8> %T184.vec, i64 7, !tcg.op !189
  %T184.vec_swap.ie314 = insertelement <8 x i8> %T184.vec_swap.ie312, i8 %T184.vec.ee313, i64 0, !tcg.op !189
  %T184.swap_out = bitcast <8 x i8> %T184.vec_swap.ie314 to i64, !tcg.op !189
  %T184.out = lshr i64 %T184.swap_out, 0, !tcg.op !189
  store i64 %T184.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !189
; ======== TCG [185] bswap64_i64 [t2],t2,attr-swp:iz,attr-swp:oz ========
  %T185.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !190
  %T185.vec = bitcast i64 %T185.tmp2 to <8 x i8>, !tcg.op !190
  %T185.vec.ee = extractelement <8 x i8> %T185.vec, i64 0, !tcg.op !190
  %T185.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T185.vec.ee, i64 7, !tcg.op !190
  %T185.vec.ee315 = extractelement <8 x i8> %T185.vec, i64 1, !tcg.op !190
  %T185.vec_swap.ie316 = insertelement <8 x i8> %T185.vec_swap.ie, i8 %T185.vec.ee315, i64 6, !tcg.op !190
  %T185.vec.ee317 = extractelement <8 x i8> %T185.vec, i64 2, !tcg.op !190
  %T185.vec_swap.ie318 = insertelement <8 x i8> %T185.vec_swap.ie316, i8 %T185.vec.ee317, i64 5, !tcg.op !190
  %T185.vec.ee319 = extractelement <8 x i8> %T185.vec, i64 3, !tcg.op !190
  %T185.vec_swap.ie320 = insertelement <8 x i8> %T185.vec_swap.ie318, i8 %T185.vec.ee319, i64 4, !tcg.op !190
  %T185.vec.ee321 = extractelement <8 x i8> %T185.vec, i64 4, !tcg.op !190
  %T185.vec_swap.ie322 = insertelement <8 x i8> %T185.vec_swap.ie320, i8 %T185.vec.ee321, i64 3, !tcg.op !190
  %T185.vec.ee323 = extractelement <8 x i8> %T185.vec, i64 5, !tcg.op !190
  %T185.vec_swap.ie324 = insertelement <8 x i8> %T185.vec_swap.ie322, i8 %T185.vec.ee323, i64 2, !tcg.op !190
  %T185.vec.ee325 = extractelement <8 x i8> %T185.vec, i64 6, !tcg.op !190
  %T185.vec_swap.ie326 = insertelement <8 x i8> %T185.vec_swap.ie324, i8 %T185.vec.ee325, i64 1, !tcg.op !190
  %T185.vec.ee327 = extractelement <8 x i8> %T185.vec, i64 7, !tcg.op !190
  %T185.vec_swap.ie328 = insertelement <8 x i8> %T185.vec_swap.ie326, i8 %T185.vec.ee327, i64 0, !tcg.op !190
  %T185.swap_out = bitcast <8 x i8> %T185.vec_swap.ie328 to i64, !tcg.op !190
  %T185.out = lshr i64 %T185.swap_out, 0, !tcg.op !190
  store i64 %T185.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !190
; ======== TCG [186] bswap64_i64 [t2],t2,attr-swp:iz,attr-swp:os ========
  %T186.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !191
  %T186.vec = bitcast i64 %T186.tmp2 to <8 x i8>, !tcg.op !191
  %T186.vec.ee = extractelement <8 x i8> %T186.vec, i64 0, !tcg.op !191
  %T186.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T186.vec.ee, i64 7, !tcg.op !191
  %T186.vec.ee329 = extractelement <8 x i8> %T186.vec, i64 1, !tcg.op !191
  %T186.vec_swap.ie330 = insertelement <8 x i8> %T186.vec_swap.ie, i8 %T186.vec.ee329, i64 6, !tcg.op !191
  %T186.vec.ee331 = extractelement <8 x i8> %T186.vec, i64 2, !tcg.op !191
  %T186.vec_swap.ie332 = insertelement <8 x i8> %T186.vec_swap.ie330, i8 %T186.vec.ee331, i64 5, !tcg.op !191
  %T186.vec.ee333 = extractelement <8 x i8> %T186.vec, i64 3, !tcg.op !191
  %T186.vec_swap.ie334 = insertelement <8 x i8> %T186.vec_swap.ie332, i8 %T186.vec.ee333, i64 4, !tcg.op !191
  %T186.vec.ee335 = extractelement <8 x i8> %T186.vec, i64 4, !tcg.op !191
  %T186.vec_swap.ie336 = insertelement <8 x i8> %T186.vec_swap.ie334, i8 %T186.vec.ee335, i64 3, !tcg.op !191
  %T186.vec.ee337 = extractelement <8 x i8> %T186.vec, i64 5, !tcg.op !191
  %T186.vec_swap.ie338 = insertelement <8 x i8> %T186.vec_swap.ie336, i8 %T186.vec.ee337, i64 2, !tcg.op !191
  %T186.vec.ee339 = extractelement <8 x i8> %T186.vec, i64 6, !tcg.op !191
  %T186.vec_swap.ie340 = insertelement <8 x i8> %T186.vec_swap.ie338, i8 %T186.vec.ee339, i64 1, !tcg.op !191
  %T186.vec.ee341 = extractelement <8 x i8> %T186.vec, i64 7, !tcg.op !191
  %T186.vec_swap.ie342 = insertelement <8 x i8> %T186.vec_swap.ie340, i8 %T186.vec.ee341, i64 0, !tcg.op !191
  %T186.swap_out = bitcast <8 x i8> %T186.vec_swap.ie342 to i64, !tcg.op !191
  %T186.out = ashr i64 %T186.swap_out, 0, !tcg.op !191
  store i64 %T186.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !191
; ======== TCG [187] bswap64_i64 [t2],t2 ========
  %T187.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !192
  %T187.vec = bitcast i64 %T187.tmp2 to <8 x i8>, !tcg.op !192
  %T187.vec.ee = extractelement <8 x i8> %T187.vec, i64 0, !tcg.op !192
  %T187.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T187.vec.ee, i64 7, !tcg.op !192
  %T187.vec.ee343 = extractelement <8 x i8> %T187.vec, i64 1, !tcg.op !192
  %T187.vec_swap.ie344 = insertelement <8 x i8> %T187.vec_swap.ie, i8 %T187.vec.ee343, i64 6, !tcg.op !192
  %T187.vec.ee345 = extractelement <8 x i8> %T187.vec, i64 2, !tcg.op !192
  %T187.vec_swap.ie346 = insertelement <8 x i8> %T187.vec_swap.ie344, i8 %T187.vec.ee345, i64 5, !tcg.op !192
  %T187.vec.ee347 = extractelement <8 x i8> %T187.vec, i64 3, !tcg.op !192
  %T187.vec_swap.ie348 = insertelement <8 x i8> %T187.vec_swap.ie346, i8 %T187.vec.ee347, i64 4, !tcg.op !192
  %T187.vec.ee349 = extractelement <8 x i8> %T187.vec, i64 4, !tcg.op !192
  %T187.vec_swap.ie350 = insertelement <8 x i8> %T187.vec_swap.ie348, i8 %T187.vec.ee349, i64 3, !tcg.op !192
  %T187.vec.ee351 = extractelement <8 x i8> %T187.vec, i64 5, !tcg.op !192
  %T187.vec_swap.ie352 = insertelement <8 x i8> %T187.vec_swap.ie350, i8 %T187.vec.ee351, i64 2, !tcg.op !192
  %T187.vec.ee353 = extractelement <8 x i8> %T187.vec, i64 6, !tcg.op !192
  %T187.vec_swap.ie354 = insertelement <8 x i8> %T187.vec_swap.ie352, i8 %T187.vec.ee353, i64 1, !tcg.op !192
  %T187.vec.ee355 = extractelement <8 x i8> %T187.vec, i64 7, !tcg.op !192
  %T187.vec_swap.ie356 = insertelement <8 x i8> %T187.vec_swap.ie354, i8 %T187.vec.ee355, i64 0, !tcg.op !192
  %T187.swap_out = bitcast <8 x i8> %T187.vec_swap.ie356 to i64, !tcg.op !192
  %T187.out = lshr i64 %T187.swap_out, 0, !tcg.op !192
  store i64 %T187.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !192
; ======== TCG [188] deposit_i32 [t2],t2,t0,0x0,0x8 ========
  %T188.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !193
  %T188.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !193
  %T188.t1 = and i32 %T188.tmp2, -256, !tcg.op !193
  %T188.tr = trunc i32 %T188.tmp0 to i8, !tcg.op !193
  %T188.zext = zext i8 %T188.tr to i32, !tcg.op !193
  %T188.t2 = shl i32 %T188.zext, 0, !tcg.op !193
  %T188.out = or i32 %T188.t1, %T188.t2, !tcg.op !193
  store i32 %T188.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !193
; ======== TCG [189] deposit_i32 [t2],t2,t0,0x10,0x8 ========
  %T189.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !194
  %T189.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !194
  %T189.t1 = and i32 %T189.tmp2, -16711681, !tcg.op !194
  %T189.tr = trunc i32 %T189.tmp0 to i8, !tcg.op !194
  %T189.zext = zext i8 %T189.tr to i32, !tcg.op !194
  %T189.t2 = shl i32 %T189.zext, 16, !tcg.op !194
  %T189.out = or i32 %T189.t1, %T189.t2, !tcg.op !194
  store i32 %T189.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !194
; ======== TCG [190] deposit_i32 [t2],t2,t0,0x18,0x8 ========
  %T190.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !195
  %T190.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !195
  %T190.t1 = and i32 %T190.tmp2, 16777215, !tcg.op !195
  %T190.tr = trunc i32 %T190.tmp0 to i8, !tcg.op !195
  %T190.zext = zext i8 %T190.tr to i32, !tcg.op !195
  %T190.t2 = shl i32 %T190.zext, 24, !tcg.op !195
  %T190.out = or i32 %T190.t1, %T190.t2, !tcg.op !195
  store i32 %T190.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !195
; ======== TCG [191] deposit_i32 [t2],t2,t0,0x18,0x18 ========
  %T191.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !196
  %T191.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !196
  %T191.t1 = and i32 %T191.tmp2, 16777215, !tcg.op !196
  %T191.tr = trunc i32 %T191.tmp0 to i24, !tcg.op !196
  %T191.zext = zext i24 %T191.tr to i32, !tcg.op !196
  %T191.t2 = shl i32 %T191.zext, 24, !tcg.op !196
  %T191.out = or i32 %T191.t1, %T191.t2, !tcg.op !196
  store i32 %T191.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !196
; ======== TCG [192] deposit_i64 [rax],rax,t2,0x0,0x8 ========
  %T192.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !197
  %T192.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !197
  %T192.t1 = and i64 %T192.rax, -256, !tcg.op !197
  %T192.tr = trunc i64 %T192.tmp2 to i8, !tcg.op !197
  %T192.zext = zext i8 %T192.tr to i64, !tcg.op !197
  %T192.t2 = shl i64 %T192.zext, 0, !tcg.op !197
  %T192.out = or i64 %T192.t1, %T192.t2, !tcg.op !197
  store i64 %T192.out, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !197
; ======== TCG [193] deposit_i64 [rax],rax,t2,0x0,0x0 ========
  %T193.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !198
  %T193.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !198
  store i64 %T193.rax, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !198
; ======== TCG [194] deposit_i64 [rax],rax,t2,0x10,0x0 ========
  %T194.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !199
  %T194.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !199
  store i64 %T194.rax, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !199
; ======== TCG [195] dupm_vec v128,e8,[t9],v0 ========
  %T195.v0 = load <16 x i8>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !200
  %T195.elem = extractelement <16 x i8> %T195.v0, i64 0, !tcg.op !200
  %T195.ie = insertelement <16 x i8> zeroinitializer, i8 %T195.elem, i64 0, !tcg.op !200
  %T195.ie357 = insertelement <16 x i8> %T195.ie, i8 %T195.elem, i64 1, !tcg.op !200
  %T195.ie358 = insertelement <16 x i8> %T195.ie357, i8 %T195.elem, i64 2, !tcg.op !200
  %T195.ie359 = insertelement <16 x i8> %T195.ie358, i8 %T195.elem, i64 3, !tcg.op !200
  %T195.ie360 = insertelement <16 x i8> %T195.ie359, i8 %T195.elem, i64 4, !tcg.op !200
  %T195.ie361 = insertelement <16 x i8> %T195.ie360, i8 %T195.elem, i64 5, !tcg.op !200
  %T195.ie362 = insertelement <16 x i8> %T195.ie361, i8 %T195.elem, i64 6, !tcg.op !200
  %T195.ie363 = insertelement <16 x i8> %T195.ie362, i8 %T195.elem, i64 7, !tcg.op !200
  %T195.ie364 = insertelement <16 x i8> %T195.ie363, i8 %T195.elem, i64 8, !tcg.op !200
  %T195.ie365 = insertelement <16 x i8> %T195.ie364, i8 %T195.elem, i64 9, !tcg.op !200
  %T195.ie366 = insertelement <16 x i8> %T195.ie365, i8 %T195.elem, i64 10, !tcg.op !200
  %T195.ie367 = insertelement <16 x i8> %T195.ie366, i8 %T195.elem, i64 11, !tcg.op !200
  %T195.ie368 = insertelement <16 x i8> %T195.ie367, i8 %T195.elem, i64 12, !tcg.op !200
  %T195.ie369 = insertelement <16 x i8> %T195.ie368, i8 %T195.elem, i64 13, !tcg.op !200
  %T195.ie370 = insertelement <16 x i8> %T195.ie369, i8 %T195.elem, i64 14, !tcg.op !200
  %T195.ie371 = insertelement <16 x i8> %T195.ie370, i8 %T195.elem, i64 15, !tcg.op !200
  store <16 x i8> %T195.ie371, ptr %tmp9.stack, align 16, !tbaa !0, !tcg.op !200
; ======== TCG [196] dupm_vec v128,e64,[t9],v0 ========
  %T196.v0 = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !201
  %T196.elem = extractelement <2 x i64> %T196.v0, i64 0, !tcg.op !201
  %T196.ie = insertelement <2 x i64> zeroinitializer, i64 %T196.elem, i64 0, !tcg.op !201
  %T196.ie372 = insertelement <2 x i64> %T196.ie, i64 %T196.elem, i64 1, !tcg.op !201
  store <2 x i64> %T196.ie372, ptr %tmp9.stack, align 16, !tbaa !0, !tcg.op !201
; ======== TCG [197] extract2_i32 [t2],t0,t2,0x8 ========
  %T197.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !202
  %T197.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !202
  %T197.lshr = lshr i32 %T197.tmp0, 8, !tcg.op !202
  %T197.t1 = and i32 %T197.lshr, 16777215, !tcg.op !202
  %T197.tr = trunc i32 %T197.tmp2 to i8, !tcg.op !202
  %T197.zext = zext i8 %T197.tr to i32, !tcg.op !202
  %T197.t2 = shl i32 %T197.zext, 24, !tcg.op !202
  %T197.out = or i32 %T197.t1, %T197.t2, !tcg.op !202
  store i32 %T197.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !202
; ======== TCG [198] extract2_i64 [t2],t0,t2,0x38 ========
  %T198.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !203
  %T198.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !203
  %T198.lshr = lshr i64 %T198.tmp0, 56, !tcg.op !203
  %T198.t1 = and i64 %T198.lshr, 255, !tcg.op !203
  %T198.tr = trunc i64 %T198.tmp2 to i56, !tcg.op !203
  %T198.zext = zext i56 %T198.tr to i64, !tcg.op !203
  %T198.t2 = shl i64 %T198.zext, 8, !tcg.op !203
  %T198.out = or i64 %T198.t1, %T198.t2, !tcg.op !203
  store i64 %T198.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !203
; ======== TCG [199] extract_i32 [t2],t0,0x8,0x4 ========
  %T199.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !204
  %T199.shl = shl i32 %T199.tmp0, 20, !tcg.op !204
  %T199.out = lshr i32 %T199.shl, 28, !tcg.op !204
  store i32 %T199.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !204
; ======== TCG [200] extract_i64 [t2],t0,0x0,0x10 ========
  %T200.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !205
  %T200.shl = shl i64 %T200.tmp0, 48, !tcg.op !205
  %T200.out = lshr i64 %T200.shl, 48, !tcg.op !205
  store i64 %T200.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !205
; ======== TCG [201] sextract_i32 [t2],t0,0x8,0x4 ========
  %T201.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !206
  %T201.shl = shl i32 %T201.tmp0, 20, !tcg.op !206
  %T201.out = ashr i32 %T201.shl, 28, !tcg.op !206
  store i32 %T201.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !206
; ======== TCG [202] sextract_i64 [t2],t0,0x0,0x20 ========
  %T202.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !207
  %T202.shl = shl i64 %T202.tmp0, 32, !tcg.op !207
  %T202.out = ashr i64 %T202.shl, 32, !tcg.op !207
  store i64 %T202.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !207
; ======== TCG [203] extrh_i64_i32 [t2],t0 ========
  %T203.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !208
  %T203.lshr = lshr i64 %T203.tmp0, 32, !tcg.op !208
  %T203.out = trunc i64 %T203.lshr to i32, !tcg.op !208
  store i32 %T203.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !208
; ======== TCG [204] ext_i32_i64 [t2],t0 ========
  %T204.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !209
  %T204.sext = sext i32 %T204.tmp0 to i64, !tcg.op !209
  store i64 %T204.sext, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !209
; ======== TCG [205] extu_i32_i64 [t2],t0 ========
  %T205.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !210
  %T205.sext = zext i32 %T205.tmp0 to i64, !tcg.op !210
  store i64 %T205.sext, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !210
; ======== TCG [206] movcond_i32 [t0],t2,0x0,0x1a,0x26,eq ========
  %T206.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !211
  %T206.bool = icmp eq i32 %T206.tmp2, 0, !tcg.op !211
  %T206.out = select i1 %T206.bool, i32 26, i32 38, !tcg.op !211
  store i32 %T206.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !211
; ======== TCG [207] movcond_i64 [t2],t0,0x0,cc_dst,t2,eq ========
  %T207.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !212
  %T207.bool = icmp eq i64 %T207.tmp0, 0, !tcg.op !212
  %T207.cc_dst = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !212
  %T207.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !212
  %T207.out = select i1 %T207.bool, i64 %T207.cc_dst, i64 %T207.tmp2, !tcg.op !212
  store i64 %T207.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !212
; ======== TCG [208] movcond_vec v128,e8,[t8],t3,t4,t3,t4,ne ========
  %T208.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !213
  %T208.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !213
  %T208.bool = icmp ne <16 x i8> %T208.tmp3, %T208.tmp4, !tcg.op !213
  %T208.tmp3373 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !213
  %T208.tmp4374 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !213
  %T208.out = select <16 x i1> %T208.bool, <16 x i8> %T208.tmp3373, <16 x i8> %T208.tmp4374, !tcg.op !213
  store <16 x i8> %T208.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !213
; ======== TCG [209] mulsh_i32 [t2],t0,t2 ========
  %T209.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !214
  %T209.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !214
  %T209.double_ty = sext i32 %T209.tmp0 to i64, !tcg.op !214
  %T209.double_ty375 = sext i32 %T209.tmp2 to i64, !tcg.op !214
  %T209.mul = mul i64 %T209.double_ty, %T209.double_ty375, !tcg.op !214
  %T209.lshr = lshr i64 %T209.mul, 32, !tcg.op !214
  %T209.tr = trunc i64 %T209.lshr to i32, !tcg.op !214
  store i32 %T209.tr, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !214
; ======== TCG [210] mulsh_i64 [t2],t0,t2 ========
  %T210.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !215
  %T210.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !215
  %T210.double_ty = sext i64 %T210.tmp0 to i128, !tcg.op !215
  %T210.double_ty376 = sext i64 %T210.tmp2 to i128, !tcg.op !215
  %T210.mul = mul i128 %T210.double_ty, %T210.double_ty376, !tcg.op !215
  %T210.lshr = lshr i128 %T210.mul, 64, !tcg.op !215
  %T210.tr = trunc i128 %T210.lshr to i64, !tcg.op !215
  store i64 %T210.tr, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !215
; ======== TCG [211] muluh_i32 [t2],t0,t2 ========
  %T211.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !216
  %T211.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !216
  %T211.double_ty = zext i32 %T211.tmp0 to i64, !tcg.op !216
  %T211.double_ty377 = zext i32 %T211.tmp2 to i64, !tcg.op !216
  %T211.mul = mul i64 %T211.double_ty, %T211.double_ty377, !tcg.op !216
  %T211.lshr = lshr i64 %T211.mul, 32, !tcg.op !216
  %T211.tr = trunc i64 %T211.lshr to i32, !tcg.op !216
  store i32 %T211.tr, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !216
; ======== TCG [212] muluh_i64 [t2],t0,t2 ========
  %T212.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !217
  %T212.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !217
  %T212.double_ty = zext i64 %T212.tmp0 to i128, !tcg.op !217
  %T212.double_ty378 = zext i64 %T212.tmp2 to i128, !tcg.op !217
  %T212.mul = mul i128 %T212.double_ty, %T212.double_ty378, !tcg.op !217
  %T212.lshr = lshr i128 %T212.mul, 64, !tcg.op !217
  %T212.tr = trunc i128 %T212.lshr to i64, !tcg.op !217
  store i64 %T212.tr, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !217
; ======== TCG [213] muls2_i32 [t2],[t0],t2,t2 ========
  %T213.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !218
  %T213.tmp2379 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !218
  %T213.double_ty = sext i32 %T213.tmp2 to i64, !tcg.op !218
  %T213.double_ty380 = sext i32 %T213.tmp2379 to i64, !tcg.op !218
  %T213.mul = mul i64 %T213.double_ty, %T213.double_ty380, !tcg.op !218
  %T213.lshr = lshr i64 %T213.mul, 32, !tcg.op !218
  %T213.tr = trunc i64 %T213.lshr to i32, !tcg.op !218
  store i32 %T213.tr, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !218
  %T213.tr381 = trunc i64 %T213.mul to i32, !tcg.op !218
  store i32 %T213.tr381, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !218
; ======== TCG [214] muls2_i64 [t2],[t0],t2,t2 ========
  %T214.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !219
  %T214.tmp2382 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !219
  %T214.double_ty = sext i64 %T214.tmp2 to i128, !tcg.op !219
  %T214.double_ty383 = sext i64 %T214.tmp2382 to i128, !tcg.op !219
  %T214.mul = mul i128 %T214.double_ty, %T214.double_ty383, !tcg.op !219
  %T214.lshr = lshr i128 %T214.mul, 64, !tcg.op !219
  %T214.tr = trunc i128 %T214.lshr to i64, !tcg.op !219
  store i64 %T214.tr, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !219
  %T214.tr384 = trunc i128 %T214.mul to i64, !tcg.op !219
  store i64 %T214.tr384, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !219
; ======== TCG [215] mulu2_i32 [t2],[t0],t2,t2 ========
  %T215.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !220
  %T215.tmp2385 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !220
  %T215.double_ty = zext i32 %T215.tmp2 to i64, !tcg.op !220
  %T215.double_ty386 = zext i32 %T215.tmp2385 to i64, !tcg.op !220
  %T215.mul = mul i64 %T215.double_ty, %T215.double_ty386, !tcg.op !220
  %T215.lshr = lshr i64 %T215.mul, 32, !tcg.op !220
  %T215.tr = trunc i64 %T215.lshr to i32, !tcg.op !220
  store i32 %T215.tr, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !220
  %T215.tr387 = trunc i64 %T215.mul to i32, !tcg.op !220
  store i32 %T215.tr387, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !220
; ======== TCG [216] mulu2_i64 [t2],[t0],t2,t2 ========
  %T216.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !221
  %T216.tmp2388 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !221
  %T216.double_ty = zext i64 %T216.tmp2 to i128, !tcg.op !221
  %T216.double_ty389 = zext i64 %T216.tmp2388 to i128, !tcg.op !221
  %T216.mul = mul i128 %T216.double_ty, %T216.double_ty389, !tcg.op !221
  %T216.lshr = lshr i128 %T216.mul, 64, !tcg.op !221
  %T216.tr = trunc i128 %T216.lshr to i64, !tcg.op !221
  store i64 %T216.tr, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !221
  %T216.tr390 = trunc i128 %T216.mul to i64, !tcg.op !221
  store i64 %T216.tr390, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !221
; ======== TCG [217] setcond_i32 [t2],cc_dst,0xffffffff,tsteq ========
  %T217.cc_dst = load i32, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !222
  %T217.and_a_b = and i32 %T217.cc_dst, -1, !tcg.op !222
  %T217.bool = icmp eq i32 %T217.and_a_b, 0, !tcg.op !222
  %T217.out = zext i1 %T217.bool to i32, !tcg.op !222
  store i32 %T217.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !222
; ======== TCG [218] setcond_i64 [t2],cc_dst,0xffffffff,tsteq ========
  %T218.cc_dst = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !223
  %T218.and_a_b = and i64 %T218.cc_dst, 4294967295, !tcg.op !223
  %T218.bool = icmp eq i64 %T218.and_a_b, 0, !tcg.op !223
  %T218.out = zext i1 %T218.bool to i64, !tcg.op !223
  store i64 %T218.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !223
; ======== TCG [219] negsetcond_i32 [t2],cc_dst,0xffffffff,tsteq ========
  %T219.cc_dst = load i32, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !224
  %T219.and_a_b = and i32 %T219.cc_dst, -1, !tcg.op !224
  %T219.bool = icmp eq i32 %T219.and_a_b, 0, !tcg.op !224
  %T219.out = sext i1 %T219.bool to i32, !tcg.op !224
  store i32 %T219.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !224
; ======== TCG [220] negsetcond_i64 [t2],cc_dst,0xffffffff,tsteq ========
  %T220.cc_dst = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !225
  %T220.and_a_b = and i64 %T220.cc_dst, 4294967295, !tcg.op !225
  %T220.bool = icmp eq i64 %T220.and_a_b, 0, !tcg.op !225
  %T220.out = sext i1 %T220.bool to i64, !tcg.op !225
  store i64 %T220.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !225
; ======== TCG [221] umax_vec v128,e8,[t8],t3,t4 ========
  %T221.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !226
  %T221.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !226
  %T221.out = call <16 x i8> @llvm.umax.v16i8.v16i8(<16 x i8> %T221.tmp3, <16 x i8> %T221.tmp4), !tcg.op !226
  store <16 x i8> %T221.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !226
; ======== TCG [222] umax_vec v128,e32,[t8],t3,t4 ========
  %T222.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !227
  %T222.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !227
  %T222.out = call <4 x i32> @llvm.umax.v4i32.v4i32(<4 x i32> %T222.tmp3, <4 x i32> %T222.tmp4), !tcg.op !227
  store <4 x i32> %T222.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !227
; ======== TCG [223] umin_vec v128,e8,[t8],t3,t4 ========
  %T223.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !228
  %T223.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !228
  %T223.out = call <16 x i8> @llvm.umin.v16i8.v16i8(<16 x i8> %T223.tmp3, <16 x i8> %T223.tmp4), !tcg.op !228
  store <16 x i8> %T223.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !228
; ======== TCG [224] umin_vec v128,e32,[t8],t3,t4 ========
  %T224.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !229
  %T224.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !229
  %T224.out = call <4 x i32> @llvm.umin.v4i32.v4i32(<4 x i32> %T224.tmp3, <4 x i32> %T224.tmp4), !tcg.op !229
  store <4 x i32> %T224.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !229
; ======== TCG [225] dup_vec v128,e8,[t9],rax ========
  %T225.ld_element = load i8, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !230
  %T225.ie = insertelement <16 x i8> zeroinitializer, i8 %T225.ld_element, i64 0, !tcg.op !230
  %T225.ie391 = insertelement <16 x i8> %T225.ie, i8 %T225.ld_element, i64 1, !tcg.op !230
  %T225.ie392 = insertelement <16 x i8> %T225.ie391, i8 %T225.ld_element, i64 2, !tcg.op !230
  %T225.ie393 = insertelement <16 x i8> %T225.ie392, i8 %T225.ld_element, i64 3, !tcg.op !230
  %T225.ie394 = insertelement <16 x i8> %T225.ie393, i8 %T225.ld_element, i64 4, !tcg.op !230
  %T225.ie395 = insertelement <16 x i8> %T225.ie394, i8 %T225.ld_element, i64 5, !tcg.op !230
  %T225.ie396 = insertelement <16 x i8> %T225.ie395, i8 %T225.ld_element, i64 6, !tcg.op !230
  %T225.ie397 = insertelement <16 x i8> %T225.ie396, i8 %T225.ld_element, i64 7, !tcg.op !230
  %T225.ie398 = insertelement <16 x i8> %T225.ie397, i8 %T225.ld_element, i64 8, !tcg.op !230
  %T225.ie399 = insertelement <16 x i8> %T225.ie398, i8 %T225.ld_element, i64 9, !tcg.op !230
  %T225.ie400 = insertelement <16 x i8> %T225.ie399, i8 %T225.ld_element, i64 10, !tcg.op !230
  %T225.ie401 = insertelement <16 x i8> %T225.ie400, i8 %T225.ld_element, i64 11, !tcg.op !230
  %T225.ie402 = insertelement <16 x i8> %T225.ie401, i8 %T225.ld_element, i64 12, !tcg.op !230
  %T225.ie403 = insertelement <16 x i8> %T225.ie402, i8 %T225.ld_element, i64 13, !tcg.op !230
  %T225.ie404 = insertelement <16 x i8> %T225.ie403, i8 %T225.ld_element, i64 14, !tcg.op !230
  %T225.ie405 = insertelement <16 x i8> %T225.ie404, i8 %T225.ld_element, i64 15, !tcg.op !230
  store <16 x i8> %T225.ie405, ptr %tmp9.stack, align 16, !tbaa !0, !tcg.op !230
; ======== TCG [226] dup_vec v128,e64,[t9],t2 ========
  %T226.ld_element = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !231
  %T226.ie = insertelement <2 x i64> zeroinitializer, i64 %T226.ld_element, i64 0, !tcg.op !231
  %T226.ie406 = insertelement <2 x i64> %T226.ie, i64 %T226.ld_element, i64 1, !tcg.op !231
  store <2 x i64> %T226.ie406, ptr %tmp9.stack, align 16, !tbaa !0, !tcg.op !231
; ======== TCG [227] brcond_i32 t1,0x0,eq,L0 ========
  %T227.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !232
  %T227.bool = icmp eq i32 %T227.tmp1, 0, !tcg.op !232
  br i1 %T227.bool, label %bb_L0, label %bb_false407, !tcg.op !232

bb_false407:                                      ; preds = %T97.merge
; ======== TCG [228] setcond_i32 [t14],t1,0xffffffffffffffff,eq ========
  %T228.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !233
  %T228.bool = icmp eq i32 %T228.tmp1, -1, !tcg.op !233
  %T228.out = zext i1 %T228.bool to i32, !tcg.op !233
  store i32 %T228.out, ptr %tmp14.stack, align 8, !tbaa !0, !tcg.op !233
; ======== TCG [229] setcond_i32 [t15],t0,0x80000000,eq ========
  %T229.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !234
  %T229.bool = icmp eq i32 %T229.tmp0, -2147483648, !tcg.op !234
  %T229.out = zext i1 %T229.bool to i32, !tcg.op !234
  store i32 %T229.out, ptr %tmp15.stack, align 8, !tbaa !0, !tcg.op !234
; ======== TCG [230] setcond_i32 [t16],t2,0x0,eq ========
  %T230.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !235
  %T230.bool = icmp eq i32 %T230.tmp2, 0, !tcg.op !235
  %T230.out = zext i1 %T230.bool to i32, !tcg.op !235
  store i32 %T230.out, ptr %tmp16.stack, align 8, !tbaa !0, !tcg.op !235
; ======== TCG [231] and_i32 [t15],t15,t16 ========
  %T231.tmp15 = load i32, ptr %tmp15.stack, align 8, !tbaa !0, !tcg.op !236
  %T231.tmp16 = load i32, ptr %tmp16.stack, align 8, !tbaa !0, !tcg.op !236
  %T231.out = and i32 %T231.tmp15, %T231.tmp16, !tcg.op !236
  store i32 %T231.out, ptr %tmp15.stack, align 8, !tbaa !0, !tcg.op !236
; ======== TCG [232] and_i32 [t14],t14,t15 ========
  %T232.tmp14 = load i32, ptr %tmp14.stack, align 8, !tbaa !0, !tcg.op !237
  %T232.tmp15 = load i32, ptr %tmp15.stack, align 8, !tbaa !0, !tcg.op !237
  %T232.out = and i32 %T232.tmp14, %T232.tmp15, !tcg.op !237
  store i32 %T232.out, ptr %tmp14.stack, align 8, !tbaa !0, !tcg.op !237
; ======== TCG [233] brcond_i32 t14,0x1,eq,L0 ========
  %T233.tmp14 = load i32, ptr %tmp14.stack, align 8, !tbaa !0, !tcg.op !238
  %T233.bool = icmp eq i32 %T233.tmp14, 1, !tcg.op !238
  br i1 %T233.bool, label %bb_L0, label %bb_false408, !tcg.op !238

bb_false408:                                      ; preds = %bb_false407
; ======== TCG [234] divs2_i32 [t2],[t0],t2,t0,t1,L0 ========
  %T234.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !239
  %T234.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !239
  %T234.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !239
  %T234.nh_double = sext i32 %T234.tmp0 to i64, !tcg.op !239
  %T234.num_hi = shl i64 %T234.nh_double, 32, !tcg.op !239
  %T234.nl_double = zext i32 %T234.tmp2 to i64, !tcg.op !239
  %T234.num = or i64 %T234.num_hi, %T234.nl_double, !tcg.op !239
  %T234.d_128 = sext i32 %T234.tmp1 to i64, !tcg.op !239
  %T234.q_128 = sdiv i64 %T234.num, %T234.d_128, !tcg.op !239
  %T234.r_128 = srem i64 %T234.num, %T234.d_128, !tcg.op !239
  %T234.q = trunc i64 %T234.q_128 to i32, !tcg.op !239
  %T234.r = trunc i64 %T234.r_128 to i32, !tcg.op !239
  %T234.q_back = sext i32 %T234.q to i64, !tcg.op !239
  %T234.q_fits = icmp eq i64 %T234.q_back, %T234.q_128, !tcg.op !239
  br i1 %T234.q_fits, label %divs2.done, label %bb_L0, !tcg.op !239

divs2.done:                                       ; preds = %bb_false408
  store i32 %T234.q, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !239
  store i32 %T234.r, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !239
; ======== TCG [235] brcond_i64 t1,0x0,eq,L0 ========
  %T235.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !240
  %T235.bool = icmp eq i64 %T235.tmp1, 0, !tcg.op !240
  br i1 %T235.bool, label %bb_L0, label %bb_false409, !tcg.op !240

bb_false409:                                      ; preds = %divs2.done
; ======== TCG [236] setcond_i64 [t17],t1,0xffffffffffffffff,eq ========
  %T236.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !241
  %T236.bool = icmp eq i64 %T236.tmp1, -1, !tcg.op !241
  %T236.out = zext i1 %T236.bool to i64, !tcg.op !241
  store i64 %T236.out, ptr %tmp17.stack, align 8, !tbaa !0, !tcg.op !241
; ======== TCG [237] setcond_i64 [t18],t0,0x8000000000000000,eq ========
  %T237.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !242
  %T237.bool = icmp eq i64 %T237.tmp0, -9223372036854775808, !tcg.op !242
  %T237.out = zext i1 %T237.bool to i64, !tcg.op !242
  store i64 %T237.out, ptr %tmp18.stack, align 8, !tbaa !0, !tcg.op !242
; ======== TCG [238] setcond_i64 [t19],t2,0x0,eq ========
  %T238.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !243
  %T238.bool = icmp eq i64 %T238.tmp2, 0, !tcg.op !243
  %T238.out = zext i1 %T238.bool to i64, !tcg.op !243
  store i64 %T238.out, ptr %tmp19.stack, align 8, !tbaa !0, !tcg.op !243
; ======== TCG [239] and_i64 [t18],t18,t19 ========
  %T239.tmp18 = load i64, ptr %tmp18.stack, align 8, !tbaa !0, !tcg.op !244
  %T239.tmp19 = load i64, ptr %tmp19.stack, align 8, !tbaa !0, !tcg.op !244
  %T239.out = and i64 %T239.tmp18, %T239.tmp19, !tcg.op !244
  store i64 %T239.out, ptr %tmp18.stack, align 8, !tbaa !0, !tcg.op !244
; ======== TCG [240] and_i64 [t17],t17,t18 ========
  %T240.tmp17 = load i64, ptr %tmp17.stack, align 8, !tbaa !0, !tcg.op !245
  %T240.tmp18 = load i64, ptr %tmp18.stack, align 8, !tbaa !0, !tcg.op !245
  %T240.out = and i64 %T240.tmp17, %T240.tmp18, !tcg.op !245
  store i64 %T240.out, ptr %tmp17.stack, align 8, !tbaa !0, !tcg.op !245
; ======== TCG [241] brcond_i64 t17,0x1,eq,L0 ========
  %T241.tmp17 = load i64, ptr %tmp17.stack, align 8, !tbaa !0, !tcg.op !246
  %T241.bool = icmp eq i64 %T241.tmp17, 1, !tcg.op !246
  br i1 %T241.bool, label %bb_L0, label %bb_false410, !tcg.op !246

bb_false410:                                      ; preds = %bb_false409
; ======== TCG [242] divs2_i64 [t2],[t0],t2,t0,t1,L0 ========
  %T242.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !247
  %T242.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !247
  %T242.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !247
  %T242.nh_double = sext i64 %T242.tmp0 to i128, !tcg.op !247
  %T242.num_hi = shl i128 %T242.nh_double, 64, !tcg.op !247
  %T242.nl_double = zext i64 %T242.tmp2 to i128, !tcg.op !247
  %T242.num = or i128 %T242.num_hi, %T242.nl_double, !tcg.op !247
  %T242.d_128 = sext i64 %T242.tmp1 to i128, !tcg.op !247
  %T242.q_128 = sdiv i128 %T242.num, %T242.d_128, !tcg.op !247
  %T242.r_128 = srem i128 %T242.num, %T242.d_128, !tcg.op !247
  %T242.q = trunc i128 %T242.q_128 to i64, !tcg.op !247
  %T242.r = trunc i128 %T242.r_128 to i64, !tcg.op !247
  %T242.q_back = sext i64 %T242.q to i128, !tcg.op !247
  %T242.q_fits = icmp eq i128 %T242.q_back, %T242.q_128, !tcg.op !247
  br i1 %T242.q_fits, label %divs2.done411, label %bb_L0, !tcg.op !247

divs2.done411:                                    ; preds = %bb_false410
  store i64 %T242.q, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !247
  store i64 %T242.r, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !247
; ======== TCG [243] brcond_i32 t1,0x0,eq,L0 ========
  %T243.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !248
  %T243.bool = icmp eq i32 %T243.tmp1, 0, !tcg.op !248
  br i1 %T243.bool, label %bb_L0, label %bb_false412, !tcg.op !248

bb_false412:                                      ; preds = %divs2.done411
; ======== TCG [244] divu2_i32 [t2],[t0],t2,t0,t1,L0 ========
  %T244.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !249
  %T244.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !249
  %T244.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !249
  %T244.nh_double = sext i32 %T244.tmp0 to i64, !tcg.op !249
  %T244.num_hi = shl i64 %T244.nh_double, 32, !tcg.op !249
  %T244.nl_double = zext i32 %T244.tmp2 to i64, !tcg.op !249
  %T244.num = or i64 %T244.num_hi, %T244.nl_double, !tcg.op !249
  %T244.d_128 = zext i32 %T244.tmp1 to i64, !tcg.op !249
  %T244.q_128 = udiv i64 %T244.num, %T244.d_128, !tcg.op !249
  %T244.r_128 = urem i64 %T244.num, %T244.d_128, !tcg.op !249
  %T244.q = trunc i64 %T244.q_128 to i32, !tcg.op !249
  %T244.r = trunc i64 %T244.r_128 to i32, !tcg.op !249
  %T244.q_back = zext i32 %T244.q to i64, !tcg.op !249
  %T244.q_fits = icmp eq i64 %T244.q_back, %T244.q_128, !tcg.op !249
  br i1 %T244.q_fits, label %divs2.done413, label %bb_L0, !tcg.op !249

divs2.done413:                                    ; preds = %bb_false412
  store i32 %T244.q, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !249
  store i32 %T244.r, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !249
; ======== TCG [245] brcond_i64 t1,0x0,eq,L0 ========
  %T245.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !250
  %T245.bool = icmp eq i64 %T245.tmp1, 0, !tcg.op !250
  br i1 %T245.bool, label %bb_L0, label %bb_false414, !tcg.op !250

bb_false414:                                      ; preds = %divs2.done413
; ======== TCG [246] divu2_i64 [t2],[t0],t2,t0,t1,L0 ========
  %T246.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !251
  %T246.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !251
  %T246.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !251
  %T246.nh_double = sext i64 %T246.tmp0 to i128, !tcg.op !251
  %T246.num_hi = shl i128 %T246.nh_double, 64, !tcg.op !251
  %T246.nl_double = zext i64 %T246.tmp2 to i128, !tcg.op !251
  %T246.num = or i128 %T246.num_hi, %T246.nl_double, !tcg.op !251
  %T246.d_128 = zext i64 %T246.tmp1 to i128, !tcg.op !251
  %T246.q_128 = udiv i128 %T246.num, %T246.d_128, !tcg.op !251
  %T246.r_128 = urem i128 %T246.num, %T246.d_128, !tcg.op !251
  %T246.q = trunc i128 %T246.q_128 to i64, !tcg.op !251
  %T246.r = trunc i128 %T246.r_128 to i64, !tcg.op !251
  %T246.q_back = zext i64 %T246.q to i128, !tcg.op !251
  %T246.q_fits = icmp eq i128 %T246.q_back, %T246.q_128, !tcg.op !251
  br i1 %T246.q_fits, label %divs2.done415, label %bb_L0, !tcg.op !251

divs2.done415:                                    ; preds = %bb_false414
  store i64 %T246.q, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !251
  store i64 %T246.r, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !251
; ======== TCG [247] discard rax ========
  store i64 poison, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !252
; ======== TCG [248] discard t2 ========
  store <2 x i64> poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !253
; ======== TCG [249] func_addr t20,0x55aa,0x0 ========
  store ptr @Fx55aa, ptr %tmp20.stack, align 8, !tbaa !0, !tcg.op !254
; ======== TCG [250] tail_call_qemuaot t20 VEC_ARGS: ========
  %T250.rax.stack = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !255
  %T250.rcx.stack = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !255
  %T250.cc_dst.stack = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !255
  %T250.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !255
  %T250.v4.stack = load <2 x i64>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !255
  %T250.v20.stack = load <2 x i64>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !255
  %T250.v22.stack = load <2 x i64>, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !255
  %T250.v24.stack = load <2 x i64>, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !255
  %T250.loaded_fn = load ptr, ptr %tmp20.stack, align 8, !tcg.op !255
  tail call qemuaot void %T250.loaded_fn(i64 %T250.rax.stack, i64 %T250.rcx.stack, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %T250.cc_dst.stack, i32 %cc_op, i64 %rip, <2 x i64> %T250.v0.stack, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %T250.v4.stack, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %T250.v20.stack, <2 x i64> %ymm10_h, <2 x i64> %T250.v22.stack, <2 x i64> %ymm11_h, <2 x i64> %T250.v24.stack, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h, ptr %cpu), !tcg.op !255
  ret void, !tcg.op !255
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

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.umax.v16i8.v16i8(<16 x i8>, <16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.umax.v4i32.v4i32(<4 x i32>, <4 x i32>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.umin.v16i8.v16i8(<16 x i8>, <16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.umin.v4i32.v4i32(<4 x i32>, <4 x i32>) #1

; Function Attrs: nounwind
declare qemuaot void @Fx55aa(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, ptr align 8 dereferenceable(26528)) #2 section ".text.Fx55aa"

; Function Attrs: noinline nounwind
define qemuaot void @trampoline_helper_raise_exception(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h, ptr align 8 dereferenceable(26528) %cpu, i64 %arg0, i64 %arg1) #0 section ".text.trampoline_helper_raise_exception" {
entry:
  %rax.stack = alloca i64, align 8
  store i64 %rax, ptr %rax.stack, align 8, !tbaa !0
  %rcx.stack = alloca i64, align 8
  store i64 %rcx, ptr %rcx.stack, align 8, !tbaa !0
  %cc_dst.stack = alloca i64, align 8
  store i64 %cc_dst, ptr %cc_dst.stack, align 8, !tbaa !0
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
  %tmp9.stack = alloca <2 x i64>, align 16
  %tmp10.stack = alloca i32, align 8
  %tmp11.stack = alloca i32, align 8
  %tmp12.stack = alloca i64, align 8
  %tmp13.stack = alloca i64, align 8
  %tmp14.stack = alloca i32, align 8
  %tmp15.stack = alloca i32, align 8
  %tmp16.stack = alloca i32, align 8
  %tmp17.stack = alloca i64, align 8
  %tmp18.stack = alloca i64, align 8
  %tmp19.stack = alloca i64, align 8
  %carry.stack = alloca i1, align 8
  %borrow.stack = alloca i1, align 8
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] st_i64 rax,env ========
  %T0.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !256
  %T0.envptr = getelementptr i8, ptr %env, i64 0, !tcg.op !256
  store i64 %T0.rax, ptr %T0.envptr, align 16, !tbaa !257, !tcg.op !256
; ======== TCG [1] st_i64 rcx,env:0x8 ========
  %T1.rcx = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !259
  %T1.envptr = getelementptr i8, ptr %env, i64 8, !tcg.op !259
  store i64 %T1.rcx, ptr %T1.envptr, align 8, !tbaa !257, !tcg.op !259
; ======== TCG [2] st_i64 rdx,env:0x10 ========
  %T2.envptr = getelementptr i8, ptr %env, i64 16, !tcg.op !260
  store i64 %rdx, ptr %T2.envptr, align 16, !tbaa !257, !tcg.op !260
; ======== TCG [3] st_i64 rbx,env:0x18 ========
  %T3.envptr = getelementptr i8, ptr %env, i64 24, !tcg.op !261
  store i64 %rbx, ptr %T3.envptr, align 8, !tbaa !257, !tcg.op !261
; ======== TCG [4] st_i64 rsp,env:0x20 ========
  %T4.envptr = getelementptr i8, ptr %env, i64 32, !tcg.op !262
  store i64 %rsp, ptr %T4.envptr, align 16, !tbaa !257, !tcg.op !262
; ======== TCG [5] st_i64 rbp,env:0x28 ========
  %T5.envptr = getelementptr i8, ptr %env, i64 40, !tcg.op !263
  store i64 %rbp, ptr %T5.envptr, align 8, !tbaa !257, !tcg.op !263
; ======== TCG [6] st_i64 rsi,env:0x30 ========
  %T6.envptr = getelementptr i8, ptr %env, i64 48, !tcg.op !264
  store i64 %rsi, ptr %T6.envptr, align 16, !tbaa !257, !tcg.op !264
; ======== TCG [7] st_i64 rdi,env:0x38 ========
  %T7.envptr = getelementptr i8, ptr %env, i64 56, !tcg.op !265
  store i64 %rdi, ptr %T7.envptr, align 8, !tbaa !257, !tcg.op !265
; ======== TCG [8] st_i64 r8,env:0x40 ========
  %T8.envptr = getelementptr i8, ptr %env, i64 64, !tcg.op !266
  store i64 %r8, ptr %T8.envptr, align 16, !tbaa !257, !tcg.op !266
; ======== TCG [9] st_i64 r9,env:0x48 ========
  %T9.envptr = getelementptr i8, ptr %env, i64 72, !tcg.op !267
  store i64 %r9, ptr %T9.envptr, align 8, !tbaa !257, !tcg.op !267
; ======== TCG [10] st_i64 r10,env:0x50 ========
  %T10.envptr = getelementptr i8, ptr %env, i64 80, !tcg.op !268
  store i64 %r10, ptr %T10.envptr, align 16, !tbaa !257, !tcg.op !268
; ======== TCG [11] st_i64 r11,env:0x58 ========
  %T11.envptr = getelementptr i8, ptr %env, i64 88, !tcg.op !269
  store i64 %r11, ptr %T11.envptr, align 8, !tbaa !257, !tcg.op !269
; ======== TCG [12] st_i64 r12,env:0x60 ========
  %T12.envptr = getelementptr i8, ptr %env, i64 96, !tcg.op !270
  store i64 %r12, ptr %T12.envptr, align 16, !tbaa !257, !tcg.op !270
; ======== TCG [13] st_i64 r13,env:0x68 ========
  %T13.envptr = getelementptr i8, ptr %env, i64 104, !tcg.op !271
  store i64 %r13, ptr %T13.envptr, align 8, !tbaa !257, !tcg.op !271
; ======== TCG [14] st_i64 r14,env:0x70 ========
  %T14.envptr = getelementptr i8, ptr %env, i64 112, !tcg.op !272
  store i64 %r14, ptr %T14.envptr, align 16, !tbaa !257, !tcg.op !272
; ======== TCG [15] st_i64 r15,env:0x78 ========
  %T15.envptr = getelementptr i8, ptr %env, i64 120, !tcg.op !273
  store i64 %r15, ptr %T15.envptr, align 8, !tbaa !257, !tcg.op !273
; ======== TCG [16] st_i64 cc_src,env:0x98 ========
  %T16.envptr = getelementptr i8, ptr %env, i64 152, !tcg.op !274
  store i64 %cc_src, ptr %T16.envptr, align 8, !tbaa !257, !tcg.op !274
; ======== TCG [17] st_i64 cc_dst,env:0x90 ========
  %T17.cc_dst = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !275
  %T17.envptr = getelementptr i8, ptr %env, i64 144, !tcg.op !275
  store i64 %T17.cc_dst, ptr %T17.envptr, align 16, !tbaa !257, !tcg.op !275
; ======== TCG [18] st_i32 cc_op,env:0xa8 ========
  %T18.envptr = getelementptr i8, ptr %env, i64 168, !tcg.op !276
  store i32 %cc_op, ptr %T18.envptr, align 8, !tbaa !257, !tcg.op !276
; ======== TCG [19] st_i64 rip,env:0x80 ========
  %T19.envptr = getelementptr i8, ptr %env, i64 128, !tcg.op !277
  store i64 %rip, ptr %T19.envptr, align 16, !tbaa !257, !tcg.op !277
; ======== TCG [20] st_vec v128,e8,v0,env:0x360 ========
  %T20.v0 = load <16 x i8>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !278
  %T20.envptr = getelementptr i8, ptr %env, i64 864, !tcg.op !278
  store <16 x i8> %T20.v0, ptr %T20.envptr, align 16, !tbaa !257, !tcg.op !278
; ======== TCG [21] st_vec v128,e8,v1,env:0x370 ========
  %T21.envptr = getelementptr i8, ptr %env, i64 880, !tcg.op !279
  store <2 x i64> %ymm0_h, ptr %T21.envptr, align 16, !tbaa !257, !tcg.op !279
; ======== TCG [22] st_vec v128,e8,v2,env:0x3a0 ========
  %T22.envptr = getelementptr i8, ptr %env, i64 928, !tcg.op !280
  store <2 x i64> %xmm1, ptr %T22.envptr, align 16, !tbaa !257, !tcg.op !280
; ======== TCG [23] st_vec v128,e8,v3,env:0x3b0 ========
  %T23.envptr = getelementptr i8, ptr %env, i64 944, !tcg.op !281
  store <2 x i64> %ymm1_h, ptr %T23.envptr, align 16, !tbaa !257, !tcg.op !281
; ======== TCG [24] st_vec v128,e8,v4,env:0x3e0 ========
  %T24.v4 = load <16 x i8>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !282
  %T24.envptr = getelementptr i8, ptr %env, i64 992, !tcg.op !282
  store <16 x i8> %T24.v4, ptr %T24.envptr, align 16, !tbaa !257, !tcg.op !282
; ======== TCG [25] st_vec v128,e8,v5,env:0x3f0 ========
  %T25.envptr = getelementptr i8, ptr %env, i64 1008, !tcg.op !283
  store <2 x i64> %ymm2_h, ptr %T25.envptr, align 16, !tbaa !257, !tcg.op !283
; ======== TCG [26] st_vec v128,e8,v6,env:0x420 ========
  %T26.envptr = getelementptr i8, ptr %env, i64 1056, !tcg.op !284
  store <2 x i64> %xmm3, ptr %T26.envptr, align 16, !tbaa !257, !tcg.op !284
; ======== TCG [27] st_vec v128,e8,v7,env:0x430 ========
  %T27.envptr = getelementptr i8, ptr %env, i64 1072, !tcg.op !285
  store <2 x i64> %ymm3_h, ptr %T27.envptr, align 16, !tbaa !257, !tcg.op !285
; ======== TCG [28] st_vec v128,e8,v8,env:0x460 ========
  %T28.envptr = getelementptr i8, ptr %env, i64 1120, !tcg.op !286
  store <2 x i64> %xmm4, ptr %T28.envptr, align 16, !tbaa !257, !tcg.op !286
; ======== TCG [29] st_vec v128,e8,v9,env:0x470 ========
  %T29.envptr = getelementptr i8, ptr %env, i64 1136, !tcg.op !287
  store <2 x i64> %ymm4_h, ptr %T29.envptr, align 16, !tbaa !257, !tcg.op !287
; ======== TCG [30] st_vec v128,e8,v10,env:0x4a0 ========
  %T30.envptr = getelementptr i8, ptr %env, i64 1184, !tcg.op !288
  store <2 x i64> %xmm5, ptr %T30.envptr, align 16, !tbaa !257, !tcg.op !288
; ======== TCG [31] st_vec v128,e8,v11,env:0x4b0 ========
  %T31.envptr = getelementptr i8, ptr %env, i64 1200, !tcg.op !289
  store <2 x i64> %ymm5_h, ptr %T31.envptr, align 16, !tbaa !257, !tcg.op !289
; ======== TCG [32] st_vec v128,e8,v12,env:0x4e0 ========
  %T32.envptr = getelementptr i8, ptr %env, i64 1248, !tcg.op !290
  store <2 x i64> %xmm6, ptr %T32.envptr, align 16, !tbaa !257, !tcg.op !290
; ======== TCG [33] st_vec v128,e8,v13,env:0x4f0 ========
  %T33.envptr = getelementptr i8, ptr %env, i64 1264, !tcg.op !291
  store <2 x i64> %ymm6_h, ptr %T33.envptr, align 16, !tbaa !257, !tcg.op !291
; ======== TCG [34] st_vec v128,e8,v14,env:0x520 ========
  %T34.envptr = getelementptr i8, ptr %env, i64 1312, !tcg.op !292
  store <2 x i64> %xmm7, ptr %T34.envptr, align 16, !tbaa !257, !tcg.op !292
; ======== TCG [35] st_vec v128,e8,v15,env:0x530 ========
  %T35.envptr = getelementptr i8, ptr %env, i64 1328, !tcg.op !293
  store <2 x i64> %ymm7_h, ptr %T35.envptr, align 16, !tbaa !257, !tcg.op !293
; ======== TCG [36] st_vec v128,e8,v16,env:0x560 ========
  %T36.envptr = getelementptr i8, ptr %env, i64 1376, !tcg.op !294
  store <2 x i64> %xmm8, ptr %T36.envptr, align 16, !tbaa !257, !tcg.op !294
; ======== TCG [37] st_vec v128,e8,v17,env:0x570 ========
  %T37.envptr = getelementptr i8, ptr %env, i64 1392, !tcg.op !295
  store <2 x i64> %ymm8_h, ptr %T37.envptr, align 16, !tbaa !257, !tcg.op !295
; ======== TCG [38] st_vec v128,e8,v18,env:0x5a0 ========
  %T38.envptr = getelementptr i8, ptr %env, i64 1440, !tcg.op !296
  store <2 x i64> %xmm9, ptr %T38.envptr, align 16, !tbaa !257, !tcg.op !296
; ======== TCG [39] st_vec v128,e8,v19,env:0x5b0 ========
  %T39.envptr = getelementptr i8, ptr %env, i64 1456, !tcg.op !297
  store <2 x i64> %ymm9_h, ptr %T39.envptr, align 16, !tbaa !257, !tcg.op !297
; ======== TCG [40] st_vec v128,e8,v20,env:0x5e0 ========
  %T40.v20 = load <16 x i8>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !298
  %T40.envptr = getelementptr i8, ptr %env, i64 1504, !tcg.op !298
  store <16 x i8> %T40.v20, ptr %T40.envptr, align 16, !tbaa !257, !tcg.op !298
; ======== TCG [41] st_vec v128,e8,v21,env:0x5f0 ========
  %T41.envptr = getelementptr i8, ptr %env, i64 1520, !tcg.op !299
  store <2 x i64> %ymm10_h, ptr %T41.envptr, align 16, !tbaa !257, !tcg.op !299
; ======== TCG [42] st_vec v128,e8,v22,env:0x620 ========
  %T42.v22 = load <16 x i8>, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !300
  %T42.envptr = getelementptr i8, ptr %env, i64 1568, !tcg.op !300
  store <16 x i8> %T42.v22, ptr %T42.envptr, align 16, !tbaa !257, !tcg.op !300
; ======== TCG [43] st_vec v128,e8,v23,env:0x630 ========
  %T43.envptr = getelementptr i8, ptr %env, i64 1584, !tcg.op !301
  store <2 x i64> %ymm11_h, ptr %T43.envptr, align 16, !tbaa !257, !tcg.op !301
; ======== TCG [44] st_vec v128,e8,v24,env:0x660 ========
  %T44.v24 = load <16 x i8>, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !302
  %T44.envptr = getelementptr i8, ptr %env, i64 1632, !tcg.op !302
  store <16 x i8> %T44.v24, ptr %T44.envptr, align 16, !tbaa !257, !tcg.op !302
; ======== TCG [45] st_vec v128,e8,v25,env:0x670 ========
  %T45.envptr = getelementptr i8, ptr %env, i64 1648, !tcg.op !303
  store <2 x i64> %ymm12_h, ptr %T45.envptr, align 16, !tbaa !257, !tcg.op !303
; ======== TCG [46] st_vec v128,e8,v26,env:0x6a0 ========
  %T46.envptr = getelementptr i8, ptr %env, i64 1696, !tcg.op !304
  store <2 x i64> %xmm13, ptr %T46.envptr, align 16, !tbaa !257, !tcg.op !304
; ======== TCG [47] st_vec v128,e8,v27,env:0x6b0 ========
  %T47.envptr = getelementptr i8, ptr %env, i64 1712, !tcg.op !305
  store <2 x i64> %ymm13_h, ptr %T47.envptr, align 16, !tbaa !257, !tcg.op !305
; ======== TCG [48] st_vec v128,e8,v28,env:0x6e0 ========
  %T48.envptr = getelementptr i8, ptr %env, i64 1760, !tcg.op !306
  store <2 x i64> %xmm14, ptr %T48.envptr, align 16, !tbaa !257, !tcg.op !306
; ======== TCG [49] st_vec v128,e8,v29,env:0x6f0 ========
  %T49.envptr = getelementptr i8, ptr %env, i64 1776, !tcg.op !307
  store <2 x i64> %ymm14_h, ptr %T49.envptr, align 16, !tbaa !257, !tcg.op !307
; ======== TCG [50] tail_call_default helper_raise_exception,arg0,arg1 ========
  tail call void @helper_raise_exception(i64 %arg0, i64 %arg1), !tcg.op !308
  ret void, !tcg.op !308
}

declare void @helper_raise_exception(i64, i64)

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
!49 = !{!"[46] brcond_i32 t1,0x0,eq,L0"}
!50 = !{!"[47] setcond_i32 [t10],t1,0xffffffffffffffff,eq"}
!51 = !{!"[48] setcond_i32 [t11],t0,0x80000000,eq"}
!52 = !{!"[49] and_i32 [t10],t10,t11"}
!53 = !{!"[50] brcond_i32 t10,0x1,eq,L0"}
!54 = !{!"[252] func_addr t21,0x0,0x1"}
!55 = !{!"[253] tail_call_qemuaot t21,env,0x0 VEC_ARGS:"}
!56 = !{!"[51] divs_i32 [t2],t0,t1"}
!57 = !{!"[52] brcond_i64 t1,0x0,eq,L0"}
!58 = !{!"[53] setcond_i64 [t12],t1,0xffffffffffffffff,eq"}
!59 = !{!"[54] setcond_i64 [t13],t0,0x8000000000000000,eq"}
!60 = !{!"[55] and_i64 [t12],t12,t13"}
!61 = !{!"[56] brcond_i64 t12,0x1,eq,L0"}
!62 = !{!"[57] divs_i64 [t2],t0,t1"}
!63 = !{!"[58] brcond_i32 t1,0x0,eq,L0"}
!64 = !{!"[59] divu_i32 [t2],t0,t1"}
!65 = !{!"[60] brcond_i64 t1,0x0,eq,L0"}
!66 = !{!"[61] divu_i64 [t2],t0,t1"}
!67 = !{!"[62] rems_i32 [t2],t0,t1"}
!68 = !{!"[63] rems_i64 [t2],t0,t1"}
!69 = !{!"[64] remu_i32 [t2],t0,t1"}
!70 = !{!"[65] remu_i64 [t2],t0,t1"}
!71 = !{!"[66] sar_i32 [t2],t0,t1"}
!72 = !{!"[67] sar_i64 [t2],t0,t1"}
!73 = !{!"[68] and_i32 [t2],t0,t1"}
!74 = !{!"[69] and_i64 [t2],t0,t1"}
!75 = !{!"[70] mul_i32 [t2],t0,t1"}
!76 = !{!"[71] mul_i64 [t2],t0,t1"}
!77 = !{!"[72] or_i32 [t2],t0,t1"}
!78 = !{!"[73] or_i64 [t2],t0,t1"}
!79 = !{!"[74] shl_i32 [t2],t0,t1"}
!80 = !{!"[75] shl_i64 [t2],t0,t1"}
!81 = !{!"[76] shr_i32 [t2],t0,t1"}
!82 = !{!"[77] shr_i64 [t2],t0,t1"}
!83 = !{!"[78] xor_i32 [t2],t0,t1"}
!84 = !{!"[79] xor_i64 [t2],t0,t1"}
!85 = !{!"[80] sarv_vec v128,e8,[t8],t3,t4"}
!86 = !{!"[81] sarv_vec v128,e32,[t8],t3,t4"}
!87 = !{!"[82] shlv_vec v128,e8,[t8],t3,t4"}
!88 = !{!"[83] shlv_vec v128,e32,[t8],t3,t4"}
!89 = !{!"[84] shrv_vec v128,e8,[t8],t3,t4"}
!90 = !{!"[85] shrv_vec v128,e32,[t8],t3,t4"}
!91 = !{!"[86] and_vec v128,e8,[t8],t3,t4"}
!92 = !{!"[87] and_vec v128,e32,[t8],t3,t4"}
!93 = !{!"[88] mul_vec v128,e8,[t8],t3,t4"}
!94 = !{!"[89] mul_vec v128,e32,[t8],t3,t4"}
!95 = !{!"[90] or_vec v128,e8,[t8],t3,t4"}
!96 = !{!"[91] or_vec v128,e32,[t8],t3,t4"}
!97 = !{!"[92] xor_vec v128,e8,[t8],t3,t4"}
!98 = !{!"[93] xor_vec v128,e32,[t8],t3,t4"}
!99 = !{!"[94] clz_i32 [t2],t2,t0"}
!100 = !{!"[95] clz_i64 [t2],t2,t0"}
!101 = !{!"[96] ctz_i32 [t2],t2,t0"}
!102 = !{!"[97] ctz_i64 [t2],t2,t0"}
!103 = !{!"[98] smax_vec v128,e8,[t8],t3,t4"}
!104 = !{!"[99] smax_vec v128,e32,[t8],t3,t4"}
!105 = !{!"[100] smin_vec v128,e8,[t8],t3,t4"}
!106 = !{!"[101] smin_vec v128,e32,[t8],t3,t4"}
!107 = !{!"[102] ssadd_vec v128,e8,[t8],t3,t4"}
!108 = !{!"[103] ssadd_vec v128,e32,[t8],t3,t4"}
!109 = !{!"[104] sssub_vec v128,e8,[t8],t3,t4"}
!110 = !{!"[105] sssub_vec v128,e32,[t8],t3,t4"}
!111 = !{!"[106] usadd_vec v128,e8,[t8],t3,t4"}
!112 = !{!"[107] usadd_vec v128,e32,[t8],t3,t4"}
!113 = !{!"[108] ussub_vec v128,e8,[t8],t3,t4"}
!114 = !{!"[109] ussub_vec v128,e32,[t8],t3,t4"}
!115 = !{!"[110] rotl_i32 [t2],t2,t0"}
!116 = !{!"[111] rotl_i64 [t2],t2,t0"}
!117 = !{!"[112] rotl_i32 [t2],t2,0x4"}
!118 = !{!"[113] rotl_i64 [t2],t2,0x100"}
!119 = !{!"[114] rotli_vec v128,e8,[t8],t3,0x2"}
!120 = !{!"[115] rotli_vec v128,e8,[t8],t3,0x8"}
!121 = !{!"[116] rotli_vec v128,e8,[t8],t3,0x9"}
!122 = !{!"[117] rotli_vec v128,e16,[t8],t3,0x12"}
!123 = !{!"[118] rotli_vec v128,e32,[t8],t3,0x21"}
!124 = !{!"[119] rotli_vec v128,e64,[t8],t3,0x42"}
!125 = !{!"[120] rotls_vec v128,e32,[t8],t3,t2"}
!126 = !{!"[121] rotlv_vec v128,e32,[t8],t3,t4"}
!127 = !{!"[122] rotr_i32 [t2],t2,t0"}
!128 = !{!"[123] rotr_i64 [t2],t2,t0"}
!129 = !{!"[124] rotr_i32 [t2],t2,0x4"}
!130 = !{!"[125] rotr_i64 [t2],t2,0x100"}
!131 = !{!"[126] rotrv_vec v128,e32,[t8],t3,t4"}
!132 = !{!"[127] shli_vec v128,e8,[t8],t3,0x2"}
!133 = !{!"[128] shli_vec v128,e8,[t8],t3,0x9"}
!134 = !{!"[129] shli_vec v128,e16,[t8],t3,0x11"}
!135 = !{!"[130] shli_vec v128,e32,[t8],t3,0x21"}
!136 = !{!"[131] shli_vec v128,e64,[t8],t3,0x42"}
!137 = !{!"[132] shls_vec v128,e32,[t8],t3,t2"}
!138 = !{!"[133] shri_vec v128,e32,[t8],t3,0x2"}
!139 = !{!"[134] shrs_vec v128,e32,[t8],t3,t2"}
!140 = !{!"[135] sari_vec v128,e32,[t8],t3,0x2"}
!141 = !{!"[136] sars_vec v128,e32,[t8],t3,t2"}
!142 = !{!"[137] andc_i32 [t2],t2,t0"}
!143 = !{!"[138] andc_i64 [t2],t2,t0"}
!144 = !{!"[139] andc_vec v128,e32,[t8],t3,t4"}
!145 = !{!"[140] nor_i32 [t2],t2,t0"}
!146 = !{!"[141] nor_i64 [t2],t2,t0"}
!147 = !{!"[142] nor_vec v128,e32,[t8],t3,t4"}
!148 = !{!"[143] orc_i32 [t2],t2,t0"}
!149 = !{!"[144] orc_i64 [t2],t2,t0"}
!150 = !{!"[145] orc_vec v128,e32,[t8],t3,t4"}
!151 = !{!"[146] nand_i32 [t2],t2,t0"}
!152 = !{!"[147] nand_i64 [t2],t2,t0"}
!153 = !{!"[148] nand_vec v128,e32,[t8],t3,t4"}
!154 = !{!"[149] eqv_i32 [t2],t2,t0"}
!155 = !{!"[150] eqv_i64 [t2],t2,t0"}
!156 = !{!"[151] eqv_vec v128,e32,[t8],t3,t4"}
!157 = !{!"[152] neg_i32 [t2],t2"}
!158 = !{!"[153] neg_i64 [t2],t2"}
!159 = !{!"[154] neg_vec v128,e32,[t8],t3"}
!160 = !{!"[155] not_i32 [t2],t2"}
!161 = !{!"[156] not_i64 [t2],t2"}
!162 = !{!"[157] not_vec v128,e32,[t8],t3"}
!163 = !{!"[158] bswap16_i32 [t2],t2,attr-swp:oz"}
!164 = !{!"[159] bswap16_i32 [t2],t2,attr-swp:os"}
!165 = !{!"[160] bswap16_i32 [t2],t2,attr-swp:iz"}
!166 = !{!"[161] bswap16_i32 [t2],t2,attr-swp:iz,attr-swp:oz"}
!167 = !{!"[162] bswap16_i32 [t2],t2,attr-swp:iz,attr-swp:os"}
!168 = !{!"[163] bswap16_i32 [t2],t2"}
!169 = !{!"[164] bswap16_i64 [t2],t2,attr-swp:oz"}
!170 = !{!"[165] bswap16_i64 [t2],t2,attr-swp:os"}
!171 = !{!"[166] bswap16_i64 [t2],t2,attr-swp:iz"}
!172 = !{!"[167] bswap16_i64 [t2],t2,attr-swp:iz,attr-swp:oz"}
!173 = !{!"[168] bswap16_i64 [t2],t2,attr-swp:iz,attr-swp:os"}
!174 = !{!"[169] bswap16_i64 [t2],t2"}
!175 = !{!"[170] bswap32_i32 [t2],t2,attr-swp:oz"}
!176 = !{!"[171] bswap32_i32 [t2],t2,attr-swp:os"}
!177 = !{!"[172] bswap32_i32 [t2],t2,attr-swp:iz"}
!178 = !{!"[173] bswap32_i32 [t2],t2,attr-swp:iz,attr-swp:oz"}
!179 = !{!"[174] bswap32_i32 [t2],t2,attr-swp:iz,attr-swp:os"}
!180 = !{!"[175] bswap32_i32 [t2],t2"}
!181 = !{!"[176] bswap32_i64 [t2],t2,attr-swp:oz"}
!182 = !{!"[177] bswap32_i64 [t2],t2,attr-swp:os"}
!183 = !{!"[178] bswap32_i64 [t2],t2,attr-swp:iz"}
!184 = !{!"[179] bswap32_i64 [t2],t2,attr-swp:iz,attr-swp:oz"}
!185 = !{!"[180] bswap32_i64 [t2],t2,attr-swp:iz,attr-swp:os"}
!186 = !{!"[181] bswap32_i64 [t2],t2"}
!187 = !{!"[182] bswap64_i64 [t2],t2,attr-swp:oz"}
!188 = !{!"[183] bswap64_i64 [t2],t2,attr-swp:os"}
!189 = !{!"[184] bswap64_i64 [t2],t2,attr-swp:iz"}
!190 = !{!"[185] bswap64_i64 [t2],t2,attr-swp:iz,attr-swp:oz"}
!191 = !{!"[186] bswap64_i64 [t2],t2,attr-swp:iz,attr-swp:os"}
!192 = !{!"[187] bswap64_i64 [t2],t2"}
!193 = !{!"[188] deposit_i32 [t2],t2,t0,0x0,0x8"}
!194 = !{!"[189] deposit_i32 [t2],t2,t0,0x10,0x8"}
!195 = !{!"[190] deposit_i32 [t2],t2,t0,0x18,0x8"}
!196 = !{!"[191] deposit_i32 [t2],t2,t0,0x18,0x18"}
!197 = !{!"[192] deposit_i64 [rax],rax,t2,0x0,0x8"}
!198 = !{!"[193] deposit_i64 [rax],rax,t2,0x0,0x0"}
!199 = !{!"[194] deposit_i64 [rax],rax,t2,0x10,0x0"}
!200 = !{!"[195] dupm_vec v128,e8,[t9],v0"}
!201 = !{!"[196] dupm_vec v128,e64,[t9],v0"}
!202 = !{!"[197] extract2_i32 [t2],t0,t2,0x8"}
!203 = !{!"[198] extract2_i64 [t2],t0,t2,0x38"}
!204 = !{!"[199] extract_i32 [t2],t0,0x8,0x4"}
!205 = !{!"[200] extract_i64 [t2],t0,0x0,0x10"}
!206 = !{!"[201] sextract_i32 [t2],t0,0x8,0x4"}
!207 = !{!"[202] sextract_i64 [t2],t0,0x0,0x20"}
!208 = !{!"[203] extrh_i64_i32 [t2],t0"}
!209 = !{!"[204] ext_i32_i64 [t2],t0"}
!210 = !{!"[205] extu_i32_i64 [t2],t0"}
!211 = !{!"[206] movcond_i32 [t0],t2,0x0,0x1a,0x26,eq"}
!212 = !{!"[207] movcond_i64 [t2],t0,0x0,cc_dst,t2,eq"}
!213 = !{!"[208] movcond_vec v128,e8,[t8],t3,t4,t3,t4,ne"}
!214 = !{!"[209] mulsh_i32 [t2],t0,t2"}
!215 = !{!"[210] mulsh_i64 [t2],t0,t2"}
!216 = !{!"[211] muluh_i32 [t2],t0,t2"}
!217 = !{!"[212] muluh_i64 [t2],t0,t2"}
!218 = !{!"[213] muls2_i32 [t2],[t0],t2,t2"}
!219 = !{!"[214] muls2_i64 [t2],[t0],t2,t2"}
!220 = !{!"[215] mulu2_i32 [t2],[t0],t2,t2"}
!221 = !{!"[216] mulu2_i64 [t2],[t0],t2,t2"}
!222 = !{!"[217] setcond_i32 [t2],cc_dst,0xffffffff,tsteq"}
!223 = !{!"[218] setcond_i64 [t2],cc_dst,0xffffffff,tsteq"}
!224 = !{!"[219] negsetcond_i32 [t2],cc_dst,0xffffffff,tsteq"}
!225 = !{!"[220] negsetcond_i64 [t2],cc_dst,0xffffffff,tsteq"}
!226 = !{!"[221] umax_vec v128,e8,[t8],t3,t4"}
!227 = !{!"[222] umax_vec v128,e32,[t8],t3,t4"}
!228 = !{!"[223] umin_vec v128,e8,[t8],t3,t4"}
!229 = !{!"[224] umin_vec v128,e32,[t8],t3,t4"}
!230 = !{!"[225] dup_vec v128,e8,[t9],rax"}
!231 = !{!"[226] dup_vec v128,e64,[t9],t2"}
!232 = !{!"[227] brcond_i32 t1,0x0,eq,L0"}
!233 = !{!"[228] setcond_i32 [t14],t1,0xffffffffffffffff,eq"}
!234 = !{!"[229] setcond_i32 [t15],t0,0x80000000,eq"}
!235 = !{!"[230] setcond_i32 [t16],t2,0x0,eq"}
!236 = !{!"[231] and_i32 [t15],t15,t16"}
!237 = !{!"[232] and_i32 [t14],t14,t15"}
!238 = !{!"[233] brcond_i32 t14,0x1,eq,L0"}
!239 = !{!"[234] divs2_i32 [t2],[t0],t2,t0,t1,L0"}
!240 = !{!"[235] brcond_i64 t1,0x0,eq,L0"}
!241 = !{!"[236] setcond_i64 [t17],t1,0xffffffffffffffff,eq"}
!242 = !{!"[237] setcond_i64 [t18],t0,0x8000000000000000,eq"}
!243 = !{!"[238] setcond_i64 [t19],t2,0x0,eq"}
!244 = !{!"[239] and_i64 [t18],t18,t19"}
!245 = !{!"[240] and_i64 [t17],t17,t18"}
!246 = !{!"[241] brcond_i64 t17,0x1,eq,L0"}
!247 = !{!"[242] divs2_i64 [t2],[t0],t2,t0,t1,L0"}
!248 = !{!"[243] brcond_i32 t1,0x0,eq,L0"}
!249 = !{!"[244] divu2_i32 [t2],[t0],t2,t0,t1,L0"}
!250 = !{!"[245] brcond_i64 t1,0x0,eq,L0"}
!251 = !{!"[246] divu2_i64 [t2],[t0],t2,t0,t1,L0"}
!252 = !{!"[247] discard rax"}
!253 = !{!"[248] discard t2"}
!254 = !{!"[249] func_addr t20,0x55aa,0x0"}
!255 = !{!"[250] tail_call_qemuaot t20 VEC_ARGS:"}
!256 = !{!"[0] st_i64 rax,env"}
!257 = !{!258, !258, i64 0}
!258 = !{!"CPUState", !2}
!259 = !{!"[1] st_i64 rcx,env:0x8"}
!260 = !{!"[2] st_i64 rdx,env:0x10"}
!261 = !{!"[3] st_i64 rbx,env:0x18"}
!262 = !{!"[4] st_i64 rsp,env:0x20"}
!263 = !{!"[5] st_i64 rbp,env:0x28"}
!264 = !{!"[6] st_i64 rsi,env:0x30"}
!265 = !{!"[7] st_i64 rdi,env:0x38"}
!266 = !{!"[8] st_i64 r8,env:0x40"}
!267 = !{!"[9] st_i64 r9,env:0x48"}
!268 = !{!"[10] st_i64 r10,env:0x50"}
!269 = !{!"[11] st_i64 r11,env:0x58"}
!270 = !{!"[12] st_i64 r12,env:0x60"}
!271 = !{!"[13] st_i64 r13,env:0x68"}
!272 = !{!"[14] st_i64 r14,env:0x70"}
!273 = !{!"[15] st_i64 r15,env:0x78"}
!274 = !{!"[16] st_i64 cc_src,env:0x98"}
!275 = !{!"[17] st_i64 cc_dst,env:0x90"}
!276 = !{!"[18] st_i32 cc_op,env:0xa8"}
!277 = !{!"[19] st_i64 rip,env:0x80"}
!278 = !{!"[20] st_vec v128,e8,v0,env:0x360"}
!279 = !{!"[21] st_vec v128,e8,v1,env:0x370"}
!280 = !{!"[22] st_vec v128,e8,v2,env:0x3a0"}
!281 = !{!"[23] st_vec v128,e8,v3,env:0x3b0"}
!282 = !{!"[24] st_vec v128,e8,v4,env:0x3e0"}
!283 = !{!"[25] st_vec v128,e8,v5,env:0x3f0"}
!284 = !{!"[26] st_vec v128,e8,v6,env:0x420"}
!285 = !{!"[27] st_vec v128,e8,v7,env:0x430"}
!286 = !{!"[28] st_vec v128,e8,v8,env:0x460"}
!287 = !{!"[29] st_vec v128,e8,v9,env:0x470"}
!288 = !{!"[30] st_vec v128,e8,v10,env:0x4a0"}
!289 = !{!"[31] st_vec v128,e8,v11,env:0x4b0"}
!290 = !{!"[32] st_vec v128,e8,v12,env:0x4e0"}
!291 = !{!"[33] st_vec v128,e8,v13,env:0x4f0"}
!292 = !{!"[34] st_vec v128,e8,v14,env:0x520"}
!293 = !{!"[35] st_vec v128,e8,v15,env:0x530"}
!294 = !{!"[36] st_vec v128,e8,v16,env:0x560"}
!295 = !{!"[37] st_vec v128,e8,v17,env:0x570"}
!296 = !{!"[38] st_vec v128,e8,v18,env:0x5a0"}
!297 = !{!"[39] st_vec v128,e8,v19,env:0x5b0"}
!298 = !{!"[40] st_vec v128,e8,v20,env:0x5e0"}
!299 = !{!"[41] st_vec v128,e8,v21,env:0x5f0"}
!300 = !{!"[42] st_vec v128,e8,v22,env:0x620"}
!301 = !{!"[43] st_vec v128,e8,v23,env:0x630"}
!302 = !{!"[44] st_vec v128,e8,v24,env:0x660"}
!303 = !{!"[45] st_vec v128,e8,v25,env:0x670"}
!304 = !{!"[46] st_vec v128,e8,v26,env:0x6a0"}
!305 = !{!"[47] st_vec v128,e8,v27,env:0x6b0"}
!306 = !{!"[48] st_vec v128,e8,v28,env:0x6e0"}
!307 = !{!"[49] st_vec v128,e8,v29,env:0x6f0"}
!308 = !{!"[50] tail_call_default helper_raise_exception,arg0,arg1"}
