; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26528) %cpu) #0 section ".text.Fx0" {
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
  %tmp16.stack = alloca i64, align 8
  %tmp17.stack = alloca i64, align 8
  %tmp18.stack = alloca i32, align 8
  %tmp19.stack = alloca i32, align 8
  %tmp20.stack = alloca i32, align 8
  %tmp21.stack = alloca i64, align 8
  %tmp22.stack = alloca i64, align 8
  %tmp23.stack = alloca i64, align 8
  %tmp24.stack = alloca ptr, align 8
  %tmp25.stack = alloca ptr, align 8
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

bb_L0:                                            ; preds = %bb_false405, %divs2.done404, %bb_false403, %divs2.done402, %bb_false401, %bb_false400, %divs2.done, %bb_false399, %bb_false398, %T109.merge, %bb_false10, %bb_false9, %bb_false8, %bb_false7, %bb_false6, %bb_false5, %bb_false4, %bb_false3, %bb_false2, %bb_false1, %bb_false, %entry
; ======== TCG [264] func_addr t25,0x0,0x1 ========
  store ptr @trampoline_helper_raise_exception, ptr %tmp25.stack, align 8, !tbaa !0, !tcg.op !54
; ======== TCG [265] tail_call_qemuaot t25,env,0x0 VEC_ARGS: ========
  %T265.rax.stack = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !55
  %T265.rcx.stack = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !55
  %T265.cc_dst.stack = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !55
  %T265.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !55
  %T265.v4.stack = load <2 x i64>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !55
  %T265.v20.stack = load <2 x i64>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !55
  %T265.v22.stack = load <2 x i64>, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !55
  %T265.v24.stack = load <2 x i64>, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !55
  %T265.env = ptrtoint ptr %env to i64, !tcg.op !55
  %T265.loaded_fn = load ptr, ptr %tmp25.stack, align 8, !tcg.op !55
  tail call qemuaot void %T265.loaded_fn(i64 %T265.rax.stack, i64 %T265.rcx.stack, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %T265.cc_dst.stack, i32 %cc_op, i64 %rip, <2 x i64> %T265.v0.stack, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %T265.v4.stack, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %T265.v20.stack, <2 x i64> %ymm10_h, <2 x i64> %T265.v22.stack, <2 x i64> %ymm11_h, <2 x i64> %T265.v24.stack, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr %cpu, i64 %T265.env, i64 0), !tcg.op !55
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
; ======== TCG [62] brcond_i32 t1,0x0,eq,L0 ========
  %T62.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !67
  %T62.bool = icmp eq i32 %T62.tmp1, 0, !tcg.op !67
  br i1 %T62.bool, label %bb_L0, label %bb_false6, !tcg.op !67

bb_false6:                                        ; preds = %bb_false5
; ======== TCG [63] setcond_i32 [t14],t1,0xffffffffffffffff,eq ========
  %T63.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !68
  %T63.bool = icmp eq i32 %T63.tmp1, -1, !tcg.op !68
  %T63.out = zext i1 %T63.bool to i32, !tcg.op !68
  store i32 %T63.out, ptr %tmp14.stack, align 8, !tbaa !0, !tcg.op !68
; ======== TCG [64] setcond_i32 [t15],t0,0x80000000,eq ========
  %T64.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !69
  %T64.bool = icmp eq i32 %T64.tmp0, -2147483648, !tcg.op !69
  %T64.out = zext i1 %T64.bool to i32, !tcg.op !69
  store i32 %T64.out, ptr %tmp15.stack, align 8, !tbaa !0, !tcg.op !69
; ======== TCG [65] and_i32 [t14],t14,t15 ========
  %T65.tmp14 = load i32, ptr %tmp14.stack, align 8, !tbaa !0, !tcg.op !70
  %T65.tmp15 = load i32, ptr %tmp15.stack, align 8, !tbaa !0, !tcg.op !70
  %T65.out = and i32 %T65.tmp14, %T65.tmp15, !tcg.op !70
  store i32 %T65.out, ptr %tmp14.stack, align 8, !tbaa !0, !tcg.op !70
; ======== TCG [66] brcond_i32 t14,0x1,eq,L0 ========
  %T66.tmp14 = load i32, ptr %tmp14.stack, align 8, !tbaa !0, !tcg.op !71
  %T66.bool = icmp eq i32 %T66.tmp14, 1, !tcg.op !71
  br i1 %T66.bool, label %bb_L0, label %bb_false7, !tcg.op !71

bb_false7:                                        ; preds = %bb_false6
; ======== TCG [67] rems_i32 [t2],t0,t1 ========
  %T67.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !72
  %T67.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !72
  %T67.out = srem i32 %T67.tmp0, %T67.tmp1, !tcg.op !72
  store i32 %T67.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !72
; ======== TCG [68] brcond_i64 t1,0x0,eq,L0 ========
  %T68.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !73
  %T68.bool = icmp eq i64 %T68.tmp1, 0, !tcg.op !73
  br i1 %T68.bool, label %bb_L0, label %bb_false8, !tcg.op !73

bb_false8:                                        ; preds = %bb_false7
; ======== TCG [69] setcond_i64 [t16],t1,0xffffffffffffffff,eq ========
  %T69.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !74
  %T69.bool = icmp eq i64 %T69.tmp1, -1, !tcg.op !74
  %T69.out = zext i1 %T69.bool to i64, !tcg.op !74
  store i64 %T69.out, ptr %tmp16.stack, align 8, !tbaa !0, !tcg.op !74
; ======== TCG [70] setcond_i64 [t17],t0,0x8000000000000000,eq ========
  %T70.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !75
  %T70.bool = icmp eq i64 %T70.tmp0, -9223372036854775808, !tcg.op !75
  %T70.out = zext i1 %T70.bool to i64, !tcg.op !75
  store i64 %T70.out, ptr %tmp17.stack, align 8, !tbaa !0, !tcg.op !75
; ======== TCG [71] and_i64 [t16],t16,t17 ========
  %T71.tmp16 = load i64, ptr %tmp16.stack, align 8, !tbaa !0, !tcg.op !76
  %T71.tmp17 = load i64, ptr %tmp17.stack, align 8, !tbaa !0, !tcg.op !76
  %T71.out = and i64 %T71.tmp16, %T71.tmp17, !tcg.op !76
  store i64 %T71.out, ptr %tmp16.stack, align 8, !tbaa !0, !tcg.op !76
; ======== TCG [72] brcond_i64 t16,0x1,eq,L0 ========
  %T72.tmp16 = load i64, ptr %tmp16.stack, align 8, !tbaa !0, !tcg.op !77
  %T72.bool = icmp eq i64 %T72.tmp16, 1, !tcg.op !77
  br i1 %T72.bool, label %bb_L0, label %bb_false9, !tcg.op !77

bb_false9:                                        ; preds = %bb_false8
; ======== TCG [73] rems_i64 [t2],t0,t1 ========
  %T73.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !78
  %T73.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !78
  %T73.out = srem i64 %T73.tmp0, %T73.tmp1, !tcg.op !78
  store i64 %T73.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !78
; ======== TCG [74] brcond_i32 t1,0x0,eq,L0 ========
  %T74.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !79
  %T74.bool = icmp eq i32 %T74.tmp1, 0, !tcg.op !79
  br i1 %T74.bool, label %bb_L0, label %bb_false10, !tcg.op !79

bb_false10:                                       ; preds = %bb_false9
; ======== TCG [75] remu_i32 [t2],t0,t1 ========
  %T75.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !80
  %T75.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !80
  %T75.out = urem i32 %T75.tmp0, %T75.tmp1, !tcg.op !80
  store i32 %T75.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !80
; ======== TCG [76] brcond_i64 t1,0x0,eq,L0 ========
  %T76.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !81
  %T76.bool = icmp eq i64 %T76.tmp1, 0, !tcg.op !81
  br i1 %T76.bool, label %bb_L0, label %bb_false11, !tcg.op !81

bb_false11:                                       ; preds = %bb_false10
; ======== TCG [77] remu_i64 [t2],t0,t1 ========
  %T77.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !82
  %T77.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !82
  %T77.out = urem i64 %T77.tmp0, %T77.tmp1, !tcg.op !82
  store i64 %T77.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !82
; ======== TCG [78] sar_i32 [t2],t0,t1 ========
  %T78.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !83
  %T78.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !83
  %T78.out = ashr i32 %T78.tmp0, %T78.tmp1, !tcg.op !83
  store i32 %T78.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !83
; ======== TCG [79] sar_i64 [t2],t0,t1 ========
  %T79.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !84
  %T79.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !84
  %T79.out = ashr i64 %T79.tmp0, %T79.tmp1, !tcg.op !84
  store i64 %T79.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !84
; ======== TCG [80] and_i32 [t2],t0,t1 ========
  %T80.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !85
  %T80.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !85
  %T80.out = and i32 %T80.tmp0, %T80.tmp1, !tcg.op !85
  store i32 %T80.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !85
; ======== TCG [81] and_i64 [t2],t0,t1 ========
  %T81.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !86
  %T81.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !86
  %T81.out = and i64 %T81.tmp0, %T81.tmp1, !tcg.op !86
  store i64 %T81.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !86
; ======== TCG [82] mul_i32 [t2],t0,t1 ========
  %T82.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !87
  %T82.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !87
  %T82.out = mul i32 %T82.tmp0, %T82.tmp1, !tcg.op !87
  store i32 %T82.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !87
; ======== TCG [83] mul_i64 [t2],t0,t1 ========
  %T83.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !88
  %T83.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !88
  %T83.out = mul i64 %T83.tmp0, %T83.tmp1, !tcg.op !88
  store i64 %T83.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !88
; ======== TCG [84] or_i32 [t2],t0,t1 ========
  %T84.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !89
  %T84.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !89
  %T84.out = or i32 %T84.tmp0, %T84.tmp1, !tcg.op !89
  store i32 %T84.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !89
; ======== TCG [85] or_i64 [t2],t0,t1 ========
  %T85.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !90
  %T85.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !90
  %T85.out = or i64 %T85.tmp0, %T85.tmp1, !tcg.op !90
  store i64 %T85.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !90
; ======== TCG [86] shl_i32 [t2],t0,t1 ========
  %T86.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !91
  %T86.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !91
  %T86.out = shl i32 %T86.tmp0, %T86.tmp1, !tcg.op !91
  store i32 %T86.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !91
; ======== TCG [87] shl_i64 [t2],t0,t1 ========
  %T87.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !92
  %T87.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !92
  %T87.out = shl i64 %T87.tmp0, %T87.tmp1, !tcg.op !92
  store i64 %T87.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !92
; ======== TCG [88] shr_i32 [t2],t0,t1 ========
  %T88.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !93
  %T88.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !93
  %T88.out = lshr i32 %T88.tmp0, %T88.tmp1, !tcg.op !93
  store i32 %T88.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !93
; ======== TCG [89] shr_i64 [t2],t0,t1 ========
  %T89.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !94
  %T89.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !94
  %T89.out = lshr i64 %T89.tmp0, %T89.tmp1, !tcg.op !94
  store i64 %T89.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !94
; ======== TCG [90] xor_i32 [t2],t0,t1 ========
  %T90.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !95
  %T90.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !95
  %T90.out = xor i32 %T90.tmp0, %T90.tmp1, !tcg.op !95
  store i32 %T90.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !95
; ======== TCG [91] xor_i64 [t2],t0,t1 ========
  %T91.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !96
  %T91.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !96
  %T91.out = xor i64 %T91.tmp0, %T91.tmp1, !tcg.op !96
  store i64 %T91.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !96
; ======== TCG [92] sarv_vec v128,e8,[t8],t3,t4 ========
  %T92.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !97
  %T92.shift = and <16 x i8> %T92.tmp4, splat (i8 7), !tcg.op !97
  %T92.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !97
  %T92.out = ashr <16 x i8> %T92.tmp3, %T92.shift, !tcg.op !97
  store <16 x i8> %T92.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !97
; ======== TCG [93] sarv_vec v128,e32,[t8],t3,t4 ========
  %T93.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !98
  %T93.shift = and <4 x i32> %T93.tmp4, splat (i32 31), !tcg.op !98
  %T93.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !98
  %T93.out = ashr <4 x i32> %T93.tmp3, %T93.shift, !tcg.op !98
  store <4 x i32> %T93.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !98
; ======== TCG [94] shlv_vec v128,e8,[t8],t3,t4 ========
  %T94.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !99
  %T94.shift = and <16 x i8> %T94.tmp4, splat (i8 7), !tcg.op !99
  %T94.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !99
  %T94.out = shl <16 x i8> %T94.tmp3, %T94.shift, !tcg.op !99
  store <16 x i8> %T94.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !99
; ======== TCG [95] shlv_vec v128,e32,[t8],t3,t4 ========
  %T95.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !100
  %T95.shift = and <4 x i32> %T95.tmp4, splat (i32 31), !tcg.op !100
  %T95.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !100
  %T95.out = shl <4 x i32> %T95.tmp3, %T95.shift, !tcg.op !100
  store <4 x i32> %T95.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !100
; ======== TCG [96] shrv_vec v128,e8,[t8],t3,t4 ========
  %T96.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !101
  %T96.shift = and <16 x i8> %T96.tmp4, splat (i8 7), !tcg.op !101
  %T96.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !101
  %T96.out = lshr <16 x i8> %T96.tmp3, %T96.shift, !tcg.op !101
  store <16 x i8> %T96.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !101
; ======== TCG [97] shrv_vec v128,e32,[t8],t3,t4 ========
  %T97.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !102
  %T97.shift = and <4 x i32> %T97.tmp4, splat (i32 31), !tcg.op !102
  %T97.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !102
  %T97.out = lshr <4 x i32> %T97.tmp3, %T97.shift, !tcg.op !102
  store <4 x i32> %T97.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !102
; ======== TCG [98] and_vec v128,e8,[t8],t3,t4 ========
  %T98.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !103
  %T98.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !103
  %T98.out = and <16 x i8> %T98.tmp3, %T98.tmp4, !tcg.op !103
  store <16 x i8> %T98.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !103
; ======== TCG [99] and_vec v128,e32,[t8],t3,t4 ========
  %T99.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !104
  %T99.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !104
  %T99.out = and <4 x i32> %T99.tmp3, %T99.tmp4, !tcg.op !104
  store <4 x i32> %T99.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !104
; ======== TCG [100] mul_vec v128,e8,[t8],t3,t4 ========
  %T100.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !105
  %T100.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !105
  %T100.out = mul <16 x i8> %T100.tmp3, %T100.tmp4, !tcg.op !105
  store <16 x i8> %T100.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !105
; ======== TCG [101] mul_vec v128,e32,[t8],t3,t4 ========
  %T101.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !106
  %T101.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !106
  %T101.out = mul <4 x i32> %T101.tmp3, %T101.tmp4, !tcg.op !106
  store <4 x i32> %T101.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !106
; ======== TCG [102] or_vec v128,e8,[t8],t3,t4 ========
  %T102.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !107
  %T102.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !107
  %T102.out = or <16 x i8> %T102.tmp3, %T102.tmp4, !tcg.op !107
  store <16 x i8> %T102.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !107
; ======== TCG [103] or_vec v128,e32,[t8],t3,t4 ========
  %T103.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !108
  %T103.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !108
  %T103.out = or <4 x i32> %T103.tmp3, %T103.tmp4, !tcg.op !108
  store <4 x i32> %T103.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !108
; ======== TCG [104] xor_vec v128,e8,[t8],t3,t4 ========
  %T104.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !109
  %T104.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !109
  %T104.out = xor <16 x i8> %T104.tmp3, %T104.tmp4, !tcg.op !109
  store <16 x i8> %T104.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !109
; ======== TCG [105] xor_vec v128,e32,[t8],t3,t4 ========
  %T105.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !110
  %T105.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !110
  %T105.out = xor <4 x i32> %T105.tmp3, %T105.tmp4, !tcg.op !110
  store <4 x i32> %T105.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !110
; ======== TCG [106] clz_i32 [t2],t2,t0 ========
  %T106.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !111
  %T106.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !111
  %T106.icmp_eq_zero = icmp eq i32 %T106.tmp2, 0, !tcg.op !111
  br i1 %T106.icmp_eq_zero, label %T106.z, label %T106.nz, !tcg.op !111

T106.z:                                           ; preds = %bb_false11
  br label %T106.merge, !tcg.op !111

T106.nz:                                          ; preds = %bb_false11
  %T106.ct_result = call i32 @llvm.ctlz.i32.i32(i32 %T106.tmp2), !tcg.op !111
  br label %T106.merge, !tcg.op !111

T106.merge:                                       ; preds = %T106.nz, %T106.z
  %T106.phi = phi i32 [ %T106.tmp0, %T106.z ], [ %T106.ct_result, %T106.nz ], !tcg.op !111
  store i32 %T106.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !111
; ======== TCG [107] clz_i64 [t2],t2,t0 ========
  %T107.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !112
  %T107.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !112
  %T107.icmp_eq_zero = icmp eq i64 %T107.tmp2, 0, !tcg.op !112
  br i1 %T107.icmp_eq_zero, label %T107.z, label %T107.nz, !tcg.op !112

T107.z:                                           ; preds = %T106.merge
  br label %T107.merge, !tcg.op !112

T107.nz:                                          ; preds = %T106.merge
  %T107.ct_result = call i64 @llvm.ctlz.i64.i64(i64 %T107.tmp2), !tcg.op !112
  br label %T107.merge, !tcg.op !112

T107.merge:                                       ; preds = %T107.nz, %T107.z
  %T107.phi = phi i64 [ %T107.tmp0, %T107.z ], [ %T107.ct_result, %T107.nz ], !tcg.op !112
  store i64 %T107.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !112
; ======== TCG [108] ctz_i32 [t2],t2,t0 ========
  %T108.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !113
  %T108.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !113
  %T108.icmp_eq_zero = icmp eq i32 %T108.tmp2, 0, !tcg.op !113
  br i1 %T108.icmp_eq_zero, label %T108.z, label %T108.nz, !tcg.op !113

T108.z:                                           ; preds = %T107.merge
  br label %T108.merge, !tcg.op !113

T108.nz:                                          ; preds = %T107.merge
  %T108.ct_result = call i32 @llvm.cttz.i32.i32(i32 %T108.tmp2), !tcg.op !113
  br label %T108.merge, !tcg.op !113

T108.merge:                                       ; preds = %T108.nz, %T108.z
  %T108.phi = phi i32 [ %T108.tmp0, %T108.z ], [ %T108.ct_result, %T108.nz ], !tcg.op !113
  store i32 %T108.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !113
; ======== TCG [109] ctz_i64 [t2],t2,t0 ========
  %T109.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !114
  %T109.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !114
  %T109.icmp_eq_zero = icmp eq i64 %T109.tmp2, 0, !tcg.op !114
  br i1 %T109.icmp_eq_zero, label %T109.z, label %T109.nz, !tcg.op !114

T109.z:                                           ; preds = %T108.merge
  br label %T109.merge, !tcg.op !114

T109.nz:                                          ; preds = %T108.merge
  %T109.ct_result = call i64 @llvm.cttz.i64.i64(i64 %T109.tmp2), !tcg.op !114
  br label %T109.merge, !tcg.op !114

T109.merge:                                       ; preds = %T109.nz, %T109.z
  %T109.phi = phi i64 [ %T109.tmp0, %T109.z ], [ %T109.ct_result, %T109.nz ], !tcg.op !114
  store i64 %T109.phi, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !114
; ======== TCG [110] smax_vec v128,e8,[t8],t3,t4 ========
  %T110.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !115
  %T110.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !115
  %T110.out = call <16 x i8> @llvm.smax.v16i8.v16i8(<16 x i8> %T110.tmp3, <16 x i8> %T110.tmp4), !tcg.op !115
  store <16 x i8> %T110.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !115
; ======== TCG [111] smax_vec v128,e32,[t8],t3,t4 ========
  %T111.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !116
  %T111.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !116
  %T111.out = call <4 x i32> @llvm.smax.v4i32.v4i32(<4 x i32> %T111.tmp3, <4 x i32> %T111.tmp4), !tcg.op !116
  store <4 x i32> %T111.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !116
; ======== TCG [112] smin_vec v128,e8,[t8],t3,t4 ========
  %T112.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !117
  %T112.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !117
  %T112.out = call <16 x i8> @llvm.smin.v16i8.v16i8(<16 x i8> %T112.tmp3, <16 x i8> %T112.tmp4), !tcg.op !117
  store <16 x i8> %T112.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !117
; ======== TCG [113] smin_vec v128,e32,[t8],t3,t4 ========
  %T113.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !118
  %T113.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !118
  %T113.out = call <4 x i32> @llvm.smin.v4i32.v4i32(<4 x i32> %T113.tmp3, <4 x i32> %T113.tmp4), !tcg.op !118
  store <4 x i32> %T113.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !118
; ======== TCG [114] ssadd_vec v128,e8,[t8],t3,t4 ========
  %T114.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !119
  %T114.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !119
  %T114.out = call <16 x i8> @llvm.sadd.sat.v16i8.v16i8(<16 x i8> %T114.tmp3, <16 x i8> %T114.tmp4), !tcg.op !119
  store <16 x i8> %T114.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !119
; ======== TCG [115] ssadd_vec v128,e32,[t8],t3,t4 ========
  %T115.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !120
  %T115.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !120
  %T115.out = call <4 x i32> @llvm.sadd.sat.v4i32.v4i32(<4 x i32> %T115.tmp3, <4 x i32> %T115.tmp4), !tcg.op !120
  store <4 x i32> %T115.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !120
; ======== TCG [116] sssub_vec v128,e8,[t8],t3,t4 ========
  %T116.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !121
  %T116.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !121
  %T116.out = call <16 x i8> @llvm.ssub.sat.v16i8.v16i8(<16 x i8> %T116.tmp3, <16 x i8> %T116.tmp4), !tcg.op !121
  store <16 x i8> %T116.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !121
; ======== TCG [117] sssub_vec v128,e32,[t8],t3,t4 ========
  %T117.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !122
  %T117.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !122
  %T117.out = call <4 x i32> @llvm.ssub.sat.v4i32.v4i32(<4 x i32> %T117.tmp3, <4 x i32> %T117.tmp4), !tcg.op !122
  store <4 x i32> %T117.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !122
; ======== TCG [118] usadd_vec v128,e8,[t8],t3,t4 ========
  %T118.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !123
  %T118.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !123
  %T118.out = call <16 x i8> @llvm.uadd.sat.v16i8.v16i8(<16 x i8> %T118.tmp3, <16 x i8> %T118.tmp4), !tcg.op !123
  store <16 x i8> %T118.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !123
; ======== TCG [119] usadd_vec v128,e32,[t8],t3,t4 ========
  %T119.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !124
  %T119.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !124
  %T119.out = call <4 x i32> @llvm.uadd.sat.v4i32.v4i32(<4 x i32> %T119.tmp3, <4 x i32> %T119.tmp4), !tcg.op !124
  store <4 x i32> %T119.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !124
; ======== TCG [120] ussub_vec v128,e8,[t8],t3,t4 ========
  %T120.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !125
  %T120.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !125
  %T120.out = call <16 x i8> @llvm.usub.sat.v16i8.v16i8(<16 x i8> %T120.tmp3, <16 x i8> %T120.tmp4), !tcg.op !125
  store <16 x i8> %T120.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !125
; ======== TCG [121] ussub_vec v128,e32,[t8],t3,t4 ========
  %T121.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !126
  %T121.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !126
  %T121.out = call <4 x i32> @llvm.usub.sat.v4i32.v4i32(<4 x i32> %T121.tmp3, <4 x i32> %T121.tmp4), !tcg.op !126
  store <4 x i32> %T121.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !126
; ======== TCG [122] rotl_i32 [t2],t2,t0 ========
  %T122.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !127
  %T122.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !127
  %T122.out = call i32 @llvm.fshl.i32.i32.i32(i32 %T122.tmp2, i32 %T122.tmp2, i32 %T122.tmp0), !tcg.op !127
  store i32 %T122.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !127
; ======== TCG [123] rotl_i64 [t2],t2,t0 ========
  %T123.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !128
  %T123.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !128
  %T123.out = call i64 @llvm.fshl.i64.i64.i64(i64 %T123.tmp2, i64 %T123.tmp2, i64 %T123.tmp0), !tcg.op !128
  store i64 %T123.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !128
; ======== TCG [124] rotl_i32 [t2],t2,0x4 ========
  %T124.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !129
  %T124.out = call i32 @llvm.fshl.i32.i32.i32(i32 %T124.tmp2, i32 %T124.tmp2, i32 4), !tcg.op !129
  store i32 %T124.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !129
; ======== TCG [125] rotl_i64 [t2],t2,0x100 ========
  %T125.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !130
  %T125.out = call i64 @llvm.fshl.i64.i64.i64(i64 %T125.tmp2, i64 %T125.tmp2, i64 256), !tcg.op !130
  store i64 %T125.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !130
; ======== TCG [126] rotli_vec v128,e8,[t8],t3,0x2 ========
  %T126.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !131
  %T126.out = call <16 x i8> @llvm.fshl.v16i8.v16i8.v16i8(<16 x i8> %T126.tmp3, <16 x i8> %T126.tmp3, <16 x i8> splat (i8 2)), !tcg.op !131
  store <16 x i8> %T126.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !131
; ======== TCG [127] rotli_vec v128,e8,[t8],t3,0x8 ========
  %T127.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !132
  %T127.out = call <16 x i8> @llvm.fshl.v16i8.v16i8.v16i8(<16 x i8> %T127.tmp3, <16 x i8> %T127.tmp3, <16 x i8> splat (i8 8)), !tcg.op !132
  store <16 x i8> %T127.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !132
; ======== TCG [128] rotli_vec v128,e8,[t8],t3,0x9 ========
  %T128.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !133
  %T128.out = call <16 x i8> @llvm.fshl.v16i8.v16i8.v16i8(<16 x i8> %T128.tmp3, <16 x i8> %T128.tmp3, <16 x i8> splat (i8 9)), !tcg.op !133
  store <16 x i8> %T128.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !133
; ======== TCG [129] rotli_vec v128,e16,[t8],t3,0x12 ========
  %T129.tmp3 = load <8 x i16>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !134
  %T129.out = call <8 x i16> @llvm.fshl.v8i16.v8i16.v8i16(<8 x i16> %T129.tmp3, <8 x i16> %T129.tmp3, <8 x i16> splat (i16 18)), !tcg.op !134
  store <8 x i16> %T129.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !134
; ======== TCG [130] rotli_vec v128,e32,[t8],t3,0x21 ========
  %T130.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !135
  %T130.out = call <4 x i32> @llvm.fshl.v4i32.v4i32.v4i32(<4 x i32> %T130.tmp3, <4 x i32> %T130.tmp3, <4 x i32> splat (i32 33)), !tcg.op !135
  store <4 x i32> %T130.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !135
; ======== TCG [131] rotli_vec v128,e64,[t8],t3,0x42 ========
  %T131.tmp3 = load <2 x i64>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !136
  %T131.out = call <2 x i64> @llvm.fshl.v2i64.v2i64.v2i64(<2 x i64> %T131.tmp3, <2 x i64> %T131.tmp3, <2 x i64> splat (i64 66)), !tcg.op !136
  store <2 x i64> %T131.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !136
; ======== TCG [132] rotls_vec v128,e32,[t8],t3,t2 ========
  %T132.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !137
  %T132.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T132.s, i64 0, !tcg.op !137
  %T132.shift.ie12 = insertelement <4 x i32> %T132.shift.ie, i32 %T132.s, i64 1, !tcg.op !137
  %T132.shift.ie13 = insertelement <4 x i32> %T132.shift.ie12, i32 %T132.s, i64 2, !tcg.op !137
  %T132.shift.ie14 = insertelement <4 x i32> %T132.shift.ie13, i32 %T132.s, i64 3, !tcg.op !137
  %T132.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !137
  %T132.out = call <4 x i32> @llvm.fshl.v4i32.v4i32.v4i32(<4 x i32> %T132.tmp3, <4 x i32> %T132.tmp3, <4 x i32> %T132.shift.ie14), !tcg.op !137
  store <4 x i32> %T132.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !137
; ======== TCG [133] rotlv_vec v128,e32,[t8],t3,t4 ========
  %T133.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !138
  %T133.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !138
  %T133.out = call <4 x i32> @llvm.fshl.v4i32.v4i32.v4i32(<4 x i32> %T133.tmp3, <4 x i32> %T133.tmp3, <4 x i32> %T133.tmp4), !tcg.op !138
  store <4 x i32> %T133.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !138
; ======== TCG [134] rotr_i32 [t2],t2,t0 ========
  %T134.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !139
  %T134.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !139
  %T134.out = call i32 @llvm.fshr.i32.i32.i32(i32 %T134.tmp2, i32 %T134.tmp2, i32 %T134.tmp0), !tcg.op !139
  store i32 %T134.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !139
; ======== TCG [135] rotr_i64 [t2],t2,t0 ========
  %T135.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !140
  %T135.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !140
  %T135.out = call i64 @llvm.fshr.i64.i64.i64(i64 %T135.tmp2, i64 %T135.tmp2, i64 %T135.tmp0), !tcg.op !140
  store i64 %T135.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !140
; ======== TCG [136] rotr_i32 [t2],t2,0x4 ========
  %T136.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !141
  %T136.out = call i32 @llvm.fshr.i32.i32.i32(i32 %T136.tmp2, i32 %T136.tmp2, i32 4), !tcg.op !141
  store i32 %T136.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !141
; ======== TCG [137] rotr_i64 [t2],t2,0x100 ========
  %T137.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !142
  %T137.out = call i64 @llvm.fshr.i64.i64.i64(i64 %T137.tmp2, i64 %T137.tmp2, i64 256), !tcg.op !142
  store i64 %T137.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !142
; ======== TCG [138] rotrv_vec v128,e32,[t8],t3,t4 ========
  %T138.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !143
  %T138.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !143
  %T138.out = call <4 x i32> @llvm.fshr.v4i32.v4i32.v4i32(<4 x i32> %T138.tmp3, <4 x i32> %T138.tmp3, <4 x i32> %T138.tmp4), !tcg.op !143
  store <4 x i32> %T138.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !143
; ======== TCG [139] shli_vec v128,e8,[t8],t3,0x2 ========
  %T139.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !144
  %T139.out = shl <16 x i8> %T139.tmp3, splat (i8 2), !tcg.op !144
  store <16 x i8> %T139.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !144
; ======== TCG [140] shli_vec v128,e8,[t8],t3,0x9 ========
  %T140.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !145
  %T140.out = shl <16 x i8> %T140.tmp3, splat (i8 1), !tcg.op !145
  store <16 x i8> %T140.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !145
; ======== TCG [141] shli_vec v128,e16,[t8],t3,0x11 ========
  %T141.tmp3 = load <8 x i16>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !146
  %T141.out = shl <8 x i16> %T141.tmp3, splat (i16 1), !tcg.op !146
  store <8 x i16> %T141.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !146
; ======== TCG [142] shli_vec v128,e32,[t8],t3,0x21 ========
  %T142.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !147
  %T142.out = shl <4 x i32> %T142.tmp3, splat (i32 1), !tcg.op !147
  store <4 x i32> %T142.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !147
; ======== TCG [143] shli_vec v128,e64,[t8],t3,0x42 ========
  %T143.tmp3 = load <2 x i64>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !148
  %T143.out = shl <2 x i64> %T143.tmp3, splat (i64 2), !tcg.op !148
  store <2 x i64> %T143.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !148
; ======== TCG [144] shls_vec v128,e32,[t8],t3,t2 ========
  %T144.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !149
  %T144.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T144.s, i64 0, !tcg.op !149
  %T144.shift.ie15 = insertelement <4 x i32> %T144.shift.ie, i32 %T144.s, i64 1, !tcg.op !149
  %T144.shift.ie16 = insertelement <4 x i32> %T144.shift.ie15, i32 %T144.s, i64 2, !tcg.op !149
  %T144.shift.ie17 = insertelement <4 x i32> %T144.shift.ie16, i32 %T144.s, i64 3, !tcg.op !149
  %T144.shift = and <4 x i32> %T144.shift.ie17, splat (i32 31), !tcg.op !149
  %T144.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !149
  %T144.out = shl <4 x i32> %T144.tmp3, %T144.shift, !tcg.op !149
  store <4 x i32> %T144.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !149
; ======== TCG [145] shri_vec v128,e32,[t8],t3,0x2 ========
  %T145.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !150
  %T145.out = lshr <4 x i32> %T145.tmp3, splat (i32 2), !tcg.op !150
  store <4 x i32> %T145.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !150
; ======== TCG [146] shrs_vec v128,e32,[t8],t3,t2 ========
  %T146.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !151
  %T146.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T146.s, i64 0, !tcg.op !151
  %T146.shift.ie18 = insertelement <4 x i32> %T146.shift.ie, i32 %T146.s, i64 1, !tcg.op !151
  %T146.shift.ie19 = insertelement <4 x i32> %T146.shift.ie18, i32 %T146.s, i64 2, !tcg.op !151
  %T146.shift.ie20 = insertelement <4 x i32> %T146.shift.ie19, i32 %T146.s, i64 3, !tcg.op !151
  %T146.shift = and <4 x i32> %T146.shift.ie20, splat (i32 31), !tcg.op !151
  %T146.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !151
  %T146.out = lshr <4 x i32> %T146.tmp3, %T146.shift, !tcg.op !151
  store <4 x i32> %T146.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !151
; ======== TCG [147] sari_vec v128,e32,[t8],t3,0x2 ========
  %T147.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !152
  %T147.out = ashr <4 x i32> %T147.tmp3, splat (i32 2), !tcg.op !152
  store <4 x i32> %T147.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !152
; ======== TCG [148] sars_vec v128,e32,[t8],t3,t2 ========
  %T148.s = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !153
  %T148.shift.ie = insertelement <4 x i32> zeroinitializer, i32 %T148.s, i64 0, !tcg.op !153
  %T148.shift.ie21 = insertelement <4 x i32> %T148.shift.ie, i32 %T148.s, i64 1, !tcg.op !153
  %T148.shift.ie22 = insertelement <4 x i32> %T148.shift.ie21, i32 %T148.s, i64 2, !tcg.op !153
  %T148.shift.ie23 = insertelement <4 x i32> %T148.shift.ie22, i32 %T148.s, i64 3, !tcg.op !153
  %T148.shift = and <4 x i32> %T148.shift.ie23, splat (i32 31), !tcg.op !153
  %T148.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !153
  %T148.out = ashr <4 x i32> %T148.tmp3, %T148.shift, !tcg.op !153
  store <4 x i32> %T148.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !153
; ======== TCG [149] andc_i32 [t2],t2,t0 ========
  %T149.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !154
  %T149.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !154
  %T149.not = xor i32 %T149.tmp0, -1, !tcg.op !154
  %T149.and_a_not_b = and i32 %T149.tmp2, %T149.not, !tcg.op !154
  store i32 %T149.and_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !154
; ======== TCG [150] andc_i64 [t2],t2,t0 ========
  %T150.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !155
  %T150.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !155
  %T150.not = xor i64 %T150.tmp0, -1, !tcg.op !155
  %T150.and_a_not_b = and i64 %T150.tmp2, %T150.not, !tcg.op !155
  store i64 %T150.and_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !155
; ======== TCG [151] andc_vec v128,e32,[t8],t3,t4 ========
  %T151.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !156
  %T151.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !156
  %T151.not = xor <4 x i32> %T151.tmp4, splat (i32 -1), !tcg.op !156
  %T151.and_a_not_b = and <4 x i32> %T151.tmp3, %T151.not, !tcg.op !156
  store <4 x i32> %T151.and_a_not_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !156
; ======== TCG [152] nor_i32 [t2],t2,t0 ========
  %T152.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !157
  %T152.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !157
  %T152.or = or i32 %T152.tmp2, %T152.tmp0, !tcg.op !157
  %T152.not_or_a_b = xor i32 %T152.or, -1, !tcg.op !157
  store i32 %T152.not_or_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !157
; ======== TCG [153] nor_i64 [t2],t2,t0 ========
  %T153.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !158
  %T153.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !158
  %T153.or = or i64 %T153.tmp2, %T153.tmp0, !tcg.op !158
  %T153.not_or_a_b = xor i64 %T153.or, -1, !tcg.op !158
  store i64 %T153.not_or_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !158
; ======== TCG [154] nor_vec v128,e32,[t8],t3,t4 ========
  %T154.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !159
  %T154.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !159
  %T154.or = or <4 x i32> %T154.tmp3, %T154.tmp4, !tcg.op !159
  %T154.not_or_a_b = xor <4 x i32> %T154.or, splat (i32 -1), !tcg.op !159
  store <4 x i32> %T154.not_or_a_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !159
; ======== TCG [155] orc_i32 [t2],t2,t0 ========
  %T155.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !160
  %T155.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !160
  %T155.not = xor i32 %T155.tmp0, -1, !tcg.op !160
  %T155.or_a_not_b = or i32 %T155.tmp2, %T155.not, !tcg.op !160
  store i32 %T155.or_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !160
; ======== TCG [156] orc_i64 [t2],t2,t0 ========
  %T156.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !161
  %T156.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !161
  %T156.not = xor i64 %T156.tmp0, -1, !tcg.op !161
  %T156.or_a_not_b = or i64 %T156.tmp2, %T156.not, !tcg.op !161
  store i64 %T156.or_a_not_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !161
; ======== TCG [157] orc_vec v128,e32,[t8],t3,t4 ========
  %T157.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !162
  %T157.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !162
  %T157.not = xor <4 x i32> %T157.tmp4, splat (i32 -1), !tcg.op !162
  %T157.or_a_not_b = or <4 x i32> %T157.tmp3, %T157.not, !tcg.op !162
  store <4 x i32> %T157.or_a_not_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !162
; ======== TCG [158] nand_i32 [t2],t2,t0 ========
  %T158.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !163
  %T158.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !163
  %T158.and = and i32 %T158.tmp2, %T158.tmp0, !tcg.op !163
  %T158.not_and_a_b = xor i32 %T158.and, -1, !tcg.op !163
  store i32 %T158.not_and_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !163
; ======== TCG [159] nand_i64 [t2],t2,t0 ========
  %T159.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !164
  %T159.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !164
  %T159.and = and i64 %T159.tmp2, %T159.tmp0, !tcg.op !164
  %T159.not_and_a_b = xor i64 %T159.and, -1, !tcg.op !164
  store i64 %T159.not_and_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !164
; ======== TCG [160] nand_vec v128,e32,[t8],t3,t4 ========
  %T160.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !165
  %T160.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !165
  %T160.and = and <4 x i32> %T160.tmp3, %T160.tmp4, !tcg.op !165
  %T160.not_and_a_b = xor <4 x i32> %T160.and, splat (i32 -1), !tcg.op !165
  store <4 x i32> %T160.not_and_a_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !165
; ======== TCG [161] eqv_i32 [t2],t2,t0 ========
  %T161.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !166
  %T161.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !166
  %T161.xor = xor i32 %T161.tmp2, %T161.tmp0, !tcg.op !166
  %T161.not_xor_a_b = xor i32 %T161.xor, -1, !tcg.op !166
  store i32 %T161.not_xor_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !166
; ======== TCG [162] eqv_i64 [t2],t2,t0 ========
  %T162.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !167
  %T162.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !167
  %T162.xor = xor i64 %T162.tmp2, %T162.tmp0, !tcg.op !167
  %T162.not_xor_a_b = xor i64 %T162.xor, -1, !tcg.op !167
  store i64 %T162.not_xor_a_b, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !167
; ======== TCG [163] eqv_vec v128,e32,[t8],t3,t4 ========
  %T163.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !168
  %T163.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !168
  %T163.xor = xor <4 x i32> %T163.tmp3, %T163.tmp4, !tcg.op !168
  %T163.not_xor_a_b = xor <4 x i32> %T163.xor, splat (i32 -1), !tcg.op !168
  store <4 x i32> %T163.not_xor_a_b, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !168
; ======== TCG [164] neg_i32 [t2],t2 ========
  %T164.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !169
  %T164.sub_zero_a = sub i32 0, %T164.tmp2, !tcg.op !169
  store i32 %T164.sub_zero_a, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !169
; ======== TCG [165] neg_i64 [t2],t2 ========
  %T165.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !170
  %T165.sub_zero_a = sub i64 0, %T165.tmp2, !tcg.op !170
  store i64 %T165.sub_zero_a, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !170
; ======== TCG [166] neg_vec v128,e32,[t8],t3 ========
  %T166.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !171
  %T166.sub_zero_a = sub <4 x i32> zeroinitializer, %T166.tmp3, !tcg.op !171
  store <4 x i32> %T166.sub_zero_a, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !171
; ======== TCG [167] not_i32 [t2],t2 ========
  %T167.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !172
  %T167.not = xor i32 %T167.tmp2, -1, !tcg.op !172
  store i32 %T167.not, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !172
; ======== TCG [168] not_i64 [t2],t2 ========
  %T168.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !173
  %T168.not = xor i64 %T168.tmp2, -1, !tcg.op !173
  store i64 %T168.not, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !173
; ======== TCG [169] not_vec v128,e32,[t8],t3 ========
  %T169.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !174
  %T169.not = xor <4 x i32> %T169.tmp3, splat (i32 -1), !tcg.op !174
  store <4 x i32> %T169.not, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !174
; ======== TCG [170] bswap16_i32 [t2],t2,attr-swp:oz ========
  %T170.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !175
  %T170.vec = bitcast i32 %T170.tmp2 to <4 x i8>, !tcg.op !175
  %T170.vec.ee = extractelement <4 x i8> %T170.vec, i64 0, !tcg.op !175
  %T170.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T170.vec.ee, i64 3, !tcg.op !175
  %T170.vec.ee24 = extractelement <4 x i8> %T170.vec, i64 1, !tcg.op !175
  %T170.vec_swap.ie25 = insertelement <4 x i8> %T170.vec_swap.ie, i8 %T170.vec.ee24, i64 2, !tcg.op !175
  %T170.vec.ee26 = extractelement <4 x i8> %T170.vec, i64 2, !tcg.op !175
  %T170.vec_swap.ie27 = insertelement <4 x i8> %T170.vec_swap.ie25, i8 %T170.vec.ee26, i64 1, !tcg.op !175
  %T170.vec.ee28 = extractelement <4 x i8> %T170.vec, i64 3, !tcg.op !175
  %T170.vec_swap.ie29 = insertelement <4 x i8> %T170.vec_swap.ie27, i8 %T170.vec.ee28, i64 0, !tcg.op !175
  %T170.swap_out = bitcast <4 x i8> %T170.vec_swap.ie29 to i32, !tcg.op !175
  %T170.out = lshr i32 %T170.swap_out, 16, !tcg.op !175
  store i32 %T170.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !175
; ======== TCG [171] bswap16_i32 [t2],t2,attr-swp:os ========
  %T171.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !176
  %T171.vec = bitcast i32 %T171.tmp2 to <4 x i8>, !tcg.op !176
  %T171.vec.ee = extractelement <4 x i8> %T171.vec, i64 0, !tcg.op !176
  %T171.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T171.vec.ee, i64 3, !tcg.op !176
  %T171.vec.ee30 = extractelement <4 x i8> %T171.vec, i64 1, !tcg.op !176
  %T171.vec_swap.ie31 = insertelement <4 x i8> %T171.vec_swap.ie, i8 %T171.vec.ee30, i64 2, !tcg.op !176
  %T171.vec.ee32 = extractelement <4 x i8> %T171.vec, i64 2, !tcg.op !176
  %T171.vec_swap.ie33 = insertelement <4 x i8> %T171.vec_swap.ie31, i8 %T171.vec.ee32, i64 1, !tcg.op !176
  %T171.vec.ee34 = extractelement <4 x i8> %T171.vec, i64 3, !tcg.op !176
  %T171.vec_swap.ie35 = insertelement <4 x i8> %T171.vec_swap.ie33, i8 %T171.vec.ee34, i64 0, !tcg.op !176
  %T171.swap_out = bitcast <4 x i8> %T171.vec_swap.ie35 to i32, !tcg.op !176
  %T171.out = ashr i32 %T171.swap_out, 16, !tcg.op !176
  store i32 %T171.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !176
; ======== TCG [172] bswap16_i32 [t2],t2,attr-swp:iz ========
  %T172.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !177
  %T172.vec = bitcast i32 %T172.tmp2 to <4 x i8>, !tcg.op !177
  %T172.vec.ee = extractelement <4 x i8> %T172.vec, i64 0, !tcg.op !177
  %T172.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T172.vec.ee, i64 3, !tcg.op !177
  %T172.vec.ee36 = extractelement <4 x i8> %T172.vec, i64 1, !tcg.op !177
  %T172.vec_swap.ie37 = insertelement <4 x i8> %T172.vec_swap.ie, i8 %T172.vec.ee36, i64 2, !tcg.op !177
  %T172.vec.ee38 = extractelement <4 x i8> %T172.vec, i64 2, !tcg.op !177
  %T172.vec_swap.ie39 = insertelement <4 x i8> %T172.vec_swap.ie37, i8 %T172.vec.ee38, i64 1, !tcg.op !177
  %T172.vec.ee40 = extractelement <4 x i8> %T172.vec, i64 3, !tcg.op !177
  %T172.vec_swap.ie41 = insertelement <4 x i8> %T172.vec_swap.ie39, i8 %T172.vec.ee40, i64 0, !tcg.op !177
  %T172.swap_out = bitcast <4 x i8> %T172.vec_swap.ie41 to i32, !tcg.op !177
  %T172.out = lshr i32 %T172.swap_out, 16, !tcg.op !177
  store i32 %T172.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !177
; ======== TCG [173] bswap16_i32 [t2],t2,attr-swp:iz,attr-swp:oz ========
  %T173.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !178
  %T173.vec = bitcast i32 %T173.tmp2 to <4 x i8>, !tcg.op !178
  %T173.vec.ee = extractelement <4 x i8> %T173.vec, i64 0, !tcg.op !178
  %T173.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T173.vec.ee, i64 3, !tcg.op !178
  %T173.vec.ee42 = extractelement <4 x i8> %T173.vec, i64 1, !tcg.op !178
  %T173.vec_swap.ie43 = insertelement <4 x i8> %T173.vec_swap.ie, i8 %T173.vec.ee42, i64 2, !tcg.op !178
  %T173.vec.ee44 = extractelement <4 x i8> %T173.vec, i64 2, !tcg.op !178
  %T173.vec_swap.ie45 = insertelement <4 x i8> %T173.vec_swap.ie43, i8 %T173.vec.ee44, i64 1, !tcg.op !178
  %T173.vec.ee46 = extractelement <4 x i8> %T173.vec, i64 3, !tcg.op !178
  %T173.vec_swap.ie47 = insertelement <4 x i8> %T173.vec_swap.ie45, i8 %T173.vec.ee46, i64 0, !tcg.op !178
  %T173.swap_out = bitcast <4 x i8> %T173.vec_swap.ie47 to i32, !tcg.op !178
  %T173.out = lshr i32 %T173.swap_out, 16, !tcg.op !178
  store i32 %T173.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !178
; ======== TCG [174] bswap16_i32 [t2],t2,attr-swp:iz,attr-swp:os ========
  %T174.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !179
  %T174.vec = bitcast i32 %T174.tmp2 to <4 x i8>, !tcg.op !179
  %T174.vec.ee = extractelement <4 x i8> %T174.vec, i64 0, !tcg.op !179
  %T174.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T174.vec.ee, i64 3, !tcg.op !179
  %T174.vec.ee48 = extractelement <4 x i8> %T174.vec, i64 1, !tcg.op !179
  %T174.vec_swap.ie49 = insertelement <4 x i8> %T174.vec_swap.ie, i8 %T174.vec.ee48, i64 2, !tcg.op !179
  %T174.vec.ee50 = extractelement <4 x i8> %T174.vec, i64 2, !tcg.op !179
  %T174.vec_swap.ie51 = insertelement <4 x i8> %T174.vec_swap.ie49, i8 %T174.vec.ee50, i64 1, !tcg.op !179
  %T174.vec.ee52 = extractelement <4 x i8> %T174.vec, i64 3, !tcg.op !179
  %T174.vec_swap.ie53 = insertelement <4 x i8> %T174.vec_swap.ie51, i8 %T174.vec.ee52, i64 0, !tcg.op !179
  %T174.swap_out = bitcast <4 x i8> %T174.vec_swap.ie53 to i32, !tcg.op !179
  %T174.out = ashr i32 %T174.swap_out, 16, !tcg.op !179
  store i32 %T174.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !179
; ======== TCG [175] bswap16_i32 [t2],t2 ========
  %T175.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !180
  %T175.vec = bitcast i32 %T175.tmp2 to <4 x i8>, !tcg.op !180
  %T175.vec.ee = extractelement <4 x i8> %T175.vec, i64 0, !tcg.op !180
  %T175.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T175.vec.ee, i64 3, !tcg.op !180
  %T175.vec.ee54 = extractelement <4 x i8> %T175.vec, i64 1, !tcg.op !180
  %T175.vec_swap.ie55 = insertelement <4 x i8> %T175.vec_swap.ie, i8 %T175.vec.ee54, i64 2, !tcg.op !180
  %T175.vec.ee56 = extractelement <4 x i8> %T175.vec, i64 2, !tcg.op !180
  %T175.vec_swap.ie57 = insertelement <4 x i8> %T175.vec_swap.ie55, i8 %T175.vec.ee56, i64 1, !tcg.op !180
  %T175.vec.ee58 = extractelement <4 x i8> %T175.vec, i64 3, !tcg.op !180
  %T175.vec_swap.ie59 = insertelement <4 x i8> %T175.vec_swap.ie57, i8 %T175.vec.ee58, i64 0, !tcg.op !180
  %T175.swap_out = bitcast <4 x i8> %T175.vec_swap.ie59 to i32, !tcg.op !180
  %T175.out = lshr i32 %T175.swap_out, 16, !tcg.op !180
  store i32 %T175.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !180
; ======== TCG [176] bswap16_i64 [t2],t2,attr-swp:oz ========
  %T176.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !181
  %T176.vec = bitcast i64 %T176.tmp2 to <8 x i8>, !tcg.op !181
  %T176.vec.ee = extractelement <8 x i8> %T176.vec, i64 0, !tcg.op !181
  %T176.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T176.vec.ee, i64 7, !tcg.op !181
  %T176.vec.ee60 = extractelement <8 x i8> %T176.vec, i64 1, !tcg.op !181
  %T176.vec_swap.ie61 = insertelement <8 x i8> %T176.vec_swap.ie, i8 %T176.vec.ee60, i64 6, !tcg.op !181
  %T176.vec.ee62 = extractelement <8 x i8> %T176.vec, i64 2, !tcg.op !181
  %T176.vec_swap.ie63 = insertelement <8 x i8> %T176.vec_swap.ie61, i8 %T176.vec.ee62, i64 5, !tcg.op !181
  %T176.vec.ee64 = extractelement <8 x i8> %T176.vec, i64 3, !tcg.op !181
  %T176.vec_swap.ie65 = insertelement <8 x i8> %T176.vec_swap.ie63, i8 %T176.vec.ee64, i64 4, !tcg.op !181
  %T176.vec.ee66 = extractelement <8 x i8> %T176.vec, i64 4, !tcg.op !181
  %T176.vec_swap.ie67 = insertelement <8 x i8> %T176.vec_swap.ie65, i8 %T176.vec.ee66, i64 3, !tcg.op !181
  %T176.vec.ee68 = extractelement <8 x i8> %T176.vec, i64 5, !tcg.op !181
  %T176.vec_swap.ie69 = insertelement <8 x i8> %T176.vec_swap.ie67, i8 %T176.vec.ee68, i64 2, !tcg.op !181
  %T176.vec.ee70 = extractelement <8 x i8> %T176.vec, i64 6, !tcg.op !181
  %T176.vec_swap.ie71 = insertelement <8 x i8> %T176.vec_swap.ie69, i8 %T176.vec.ee70, i64 1, !tcg.op !181
  %T176.vec.ee72 = extractelement <8 x i8> %T176.vec, i64 7, !tcg.op !181
  %T176.vec_swap.ie73 = insertelement <8 x i8> %T176.vec_swap.ie71, i8 %T176.vec.ee72, i64 0, !tcg.op !181
  %T176.swap_out = bitcast <8 x i8> %T176.vec_swap.ie73 to i64, !tcg.op !181
  %T176.out = lshr i64 %T176.swap_out, 48, !tcg.op !181
  store i64 %T176.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !181
; ======== TCG [177] bswap16_i64 [t2],t2,attr-swp:os ========
  %T177.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !182
  %T177.vec = bitcast i64 %T177.tmp2 to <8 x i8>, !tcg.op !182
  %T177.vec.ee = extractelement <8 x i8> %T177.vec, i64 0, !tcg.op !182
  %T177.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T177.vec.ee, i64 7, !tcg.op !182
  %T177.vec.ee74 = extractelement <8 x i8> %T177.vec, i64 1, !tcg.op !182
  %T177.vec_swap.ie75 = insertelement <8 x i8> %T177.vec_swap.ie, i8 %T177.vec.ee74, i64 6, !tcg.op !182
  %T177.vec.ee76 = extractelement <8 x i8> %T177.vec, i64 2, !tcg.op !182
  %T177.vec_swap.ie77 = insertelement <8 x i8> %T177.vec_swap.ie75, i8 %T177.vec.ee76, i64 5, !tcg.op !182
  %T177.vec.ee78 = extractelement <8 x i8> %T177.vec, i64 3, !tcg.op !182
  %T177.vec_swap.ie79 = insertelement <8 x i8> %T177.vec_swap.ie77, i8 %T177.vec.ee78, i64 4, !tcg.op !182
  %T177.vec.ee80 = extractelement <8 x i8> %T177.vec, i64 4, !tcg.op !182
  %T177.vec_swap.ie81 = insertelement <8 x i8> %T177.vec_swap.ie79, i8 %T177.vec.ee80, i64 3, !tcg.op !182
  %T177.vec.ee82 = extractelement <8 x i8> %T177.vec, i64 5, !tcg.op !182
  %T177.vec_swap.ie83 = insertelement <8 x i8> %T177.vec_swap.ie81, i8 %T177.vec.ee82, i64 2, !tcg.op !182
  %T177.vec.ee84 = extractelement <8 x i8> %T177.vec, i64 6, !tcg.op !182
  %T177.vec_swap.ie85 = insertelement <8 x i8> %T177.vec_swap.ie83, i8 %T177.vec.ee84, i64 1, !tcg.op !182
  %T177.vec.ee86 = extractelement <8 x i8> %T177.vec, i64 7, !tcg.op !182
  %T177.vec_swap.ie87 = insertelement <8 x i8> %T177.vec_swap.ie85, i8 %T177.vec.ee86, i64 0, !tcg.op !182
  %T177.swap_out = bitcast <8 x i8> %T177.vec_swap.ie87 to i64, !tcg.op !182
  %T177.out = ashr i64 %T177.swap_out, 48, !tcg.op !182
  store i64 %T177.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !182
; ======== TCG [178] bswap16_i64 [t2],t2,attr-swp:iz ========
  %T178.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !183
  %T178.vec = bitcast i64 %T178.tmp2 to <8 x i8>, !tcg.op !183
  %T178.vec.ee = extractelement <8 x i8> %T178.vec, i64 0, !tcg.op !183
  %T178.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T178.vec.ee, i64 7, !tcg.op !183
  %T178.vec.ee88 = extractelement <8 x i8> %T178.vec, i64 1, !tcg.op !183
  %T178.vec_swap.ie89 = insertelement <8 x i8> %T178.vec_swap.ie, i8 %T178.vec.ee88, i64 6, !tcg.op !183
  %T178.vec.ee90 = extractelement <8 x i8> %T178.vec, i64 2, !tcg.op !183
  %T178.vec_swap.ie91 = insertelement <8 x i8> %T178.vec_swap.ie89, i8 %T178.vec.ee90, i64 5, !tcg.op !183
  %T178.vec.ee92 = extractelement <8 x i8> %T178.vec, i64 3, !tcg.op !183
  %T178.vec_swap.ie93 = insertelement <8 x i8> %T178.vec_swap.ie91, i8 %T178.vec.ee92, i64 4, !tcg.op !183
  %T178.vec.ee94 = extractelement <8 x i8> %T178.vec, i64 4, !tcg.op !183
  %T178.vec_swap.ie95 = insertelement <8 x i8> %T178.vec_swap.ie93, i8 %T178.vec.ee94, i64 3, !tcg.op !183
  %T178.vec.ee96 = extractelement <8 x i8> %T178.vec, i64 5, !tcg.op !183
  %T178.vec_swap.ie97 = insertelement <8 x i8> %T178.vec_swap.ie95, i8 %T178.vec.ee96, i64 2, !tcg.op !183
  %T178.vec.ee98 = extractelement <8 x i8> %T178.vec, i64 6, !tcg.op !183
  %T178.vec_swap.ie99 = insertelement <8 x i8> %T178.vec_swap.ie97, i8 %T178.vec.ee98, i64 1, !tcg.op !183
  %T178.vec.ee100 = extractelement <8 x i8> %T178.vec, i64 7, !tcg.op !183
  %T178.vec_swap.ie101 = insertelement <8 x i8> %T178.vec_swap.ie99, i8 %T178.vec.ee100, i64 0, !tcg.op !183
  %T178.swap_out = bitcast <8 x i8> %T178.vec_swap.ie101 to i64, !tcg.op !183
  %T178.out = lshr i64 %T178.swap_out, 48, !tcg.op !183
  store i64 %T178.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !183
; ======== TCG [179] bswap16_i64 [t2],t2,attr-swp:iz,attr-swp:oz ========
  %T179.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !184
  %T179.vec = bitcast i64 %T179.tmp2 to <8 x i8>, !tcg.op !184
  %T179.vec.ee = extractelement <8 x i8> %T179.vec, i64 0, !tcg.op !184
  %T179.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T179.vec.ee, i64 7, !tcg.op !184
  %T179.vec.ee102 = extractelement <8 x i8> %T179.vec, i64 1, !tcg.op !184
  %T179.vec_swap.ie103 = insertelement <8 x i8> %T179.vec_swap.ie, i8 %T179.vec.ee102, i64 6, !tcg.op !184
  %T179.vec.ee104 = extractelement <8 x i8> %T179.vec, i64 2, !tcg.op !184
  %T179.vec_swap.ie105 = insertelement <8 x i8> %T179.vec_swap.ie103, i8 %T179.vec.ee104, i64 5, !tcg.op !184
  %T179.vec.ee106 = extractelement <8 x i8> %T179.vec, i64 3, !tcg.op !184
  %T179.vec_swap.ie107 = insertelement <8 x i8> %T179.vec_swap.ie105, i8 %T179.vec.ee106, i64 4, !tcg.op !184
  %T179.vec.ee108 = extractelement <8 x i8> %T179.vec, i64 4, !tcg.op !184
  %T179.vec_swap.ie109 = insertelement <8 x i8> %T179.vec_swap.ie107, i8 %T179.vec.ee108, i64 3, !tcg.op !184
  %T179.vec.ee110 = extractelement <8 x i8> %T179.vec, i64 5, !tcg.op !184
  %T179.vec_swap.ie111 = insertelement <8 x i8> %T179.vec_swap.ie109, i8 %T179.vec.ee110, i64 2, !tcg.op !184
  %T179.vec.ee112 = extractelement <8 x i8> %T179.vec, i64 6, !tcg.op !184
  %T179.vec_swap.ie113 = insertelement <8 x i8> %T179.vec_swap.ie111, i8 %T179.vec.ee112, i64 1, !tcg.op !184
  %T179.vec.ee114 = extractelement <8 x i8> %T179.vec, i64 7, !tcg.op !184
  %T179.vec_swap.ie115 = insertelement <8 x i8> %T179.vec_swap.ie113, i8 %T179.vec.ee114, i64 0, !tcg.op !184
  %T179.swap_out = bitcast <8 x i8> %T179.vec_swap.ie115 to i64, !tcg.op !184
  %T179.out = lshr i64 %T179.swap_out, 48, !tcg.op !184
  store i64 %T179.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !184
; ======== TCG [180] bswap16_i64 [t2],t2,attr-swp:iz,attr-swp:os ========
  %T180.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !185
  %T180.vec = bitcast i64 %T180.tmp2 to <8 x i8>, !tcg.op !185
  %T180.vec.ee = extractelement <8 x i8> %T180.vec, i64 0, !tcg.op !185
  %T180.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T180.vec.ee, i64 7, !tcg.op !185
  %T180.vec.ee116 = extractelement <8 x i8> %T180.vec, i64 1, !tcg.op !185
  %T180.vec_swap.ie117 = insertelement <8 x i8> %T180.vec_swap.ie, i8 %T180.vec.ee116, i64 6, !tcg.op !185
  %T180.vec.ee118 = extractelement <8 x i8> %T180.vec, i64 2, !tcg.op !185
  %T180.vec_swap.ie119 = insertelement <8 x i8> %T180.vec_swap.ie117, i8 %T180.vec.ee118, i64 5, !tcg.op !185
  %T180.vec.ee120 = extractelement <8 x i8> %T180.vec, i64 3, !tcg.op !185
  %T180.vec_swap.ie121 = insertelement <8 x i8> %T180.vec_swap.ie119, i8 %T180.vec.ee120, i64 4, !tcg.op !185
  %T180.vec.ee122 = extractelement <8 x i8> %T180.vec, i64 4, !tcg.op !185
  %T180.vec_swap.ie123 = insertelement <8 x i8> %T180.vec_swap.ie121, i8 %T180.vec.ee122, i64 3, !tcg.op !185
  %T180.vec.ee124 = extractelement <8 x i8> %T180.vec, i64 5, !tcg.op !185
  %T180.vec_swap.ie125 = insertelement <8 x i8> %T180.vec_swap.ie123, i8 %T180.vec.ee124, i64 2, !tcg.op !185
  %T180.vec.ee126 = extractelement <8 x i8> %T180.vec, i64 6, !tcg.op !185
  %T180.vec_swap.ie127 = insertelement <8 x i8> %T180.vec_swap.ie125, i8 %T180.vec.ee126, i64 1, !tcg.op !185
  %T180.vec.ee128 = extractelement <8 x i8> %T180.vec, i64 7, !tcg.op !185
  %T180.vec_swap.ie129 = insertelement <8 x i8> %T180.vec_swap.ie127, i8 %T180.vec.ee128, i64 0, !tcg.op !185
  %T180.swap_out = bitcast <8 x i8> %T180.vec_swap.ie129 to i64, !tcg.op !185
  %T180.out = ashr i64 %T180.swap_out, 48, !tcg.op !185
  store i64 %T180.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !185
; ======== TCG [181] bswap16_i64 [t2],t2 ========
  %T181.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !186
  %T181.vec = bitcast i64 %T181.tmp2 to <8 x i8>, !tcg.op !186
  %T181.vec.ee = extractelement <8 x i8> %T181.vec, i64 0, !tcg.op !186
  %T181.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T181.vec.ee, i64 7, !tcg.op !186
  %T181.vec.ee130 = extractelement <8 x i8> %T181.vec, i64 1, !tcg.op !186
  %T181.vec_swap.ie131 = insertelement <8 x i8> %T181.vec_swap.ie, i8 %T181.vec.ee130, i64 6, !tcg.op !186
  %T181.vec.ee132 = extractelement <8 x i8> %T181.vec, i64 2, !tcg.op !186
  %T181.vec_swap.ie133 = insertelement <8 x i8> %T181.vec_swap.ie131, i8 %T181.vec.ee132, i64 5, !tcg.op !186
  %T181.vec.ee134 = extractelement <8 x i8> %T181.vec, i64 3, !tcg.op !186
  %T181.vec_swap.ie135 = insertelement <8 x i8> %T181.vec_swap.ie133, i8 %T181.vec.ee134, i64 4, !tcg.op !186
  %T181.vec.ee136 = extractelement <8 x i8> %T181.vec, i64 4, !tcg.op !186
  %T181.vec_swap.ie137 = insertelement <8 x i8> %T181.vec_swap.ie135, i8 %T181.vec.ee136, i64 3, !tcg.op !186
  %T181.vec.ee138 = extractelement <8 x i8> %T181.vec, i64 5, !tcg.op !186
  %T181.vec_swap.ie139 = insertelement <8 x i8> %T181.vec_swap.ie137, i8 %T181.vec.ee138, i64 2, !tcg.op !186
  %T181.vec.ee140 = extractelement <8 x i8> %T181.vec, i64 6, !tcg.op !186
  %T181.vec_swap.ie141 = insertelement <8 x i8> %T181.vec_swap.ie139, i8 %T181.vec.ee140, i64 1, !tcg.op !186
  %T181.vec.ee142 = extractelement <8 x i8> %T181.vec, i64 7, !tcg.op !186
  %T181.vec_swap.ie143 = insertelement <8 x i8> %T181.vec_swap.ie141, i8 %T181.vec.ee142, i64 0, !tcg.op !186
  %T181.swap_out = bitcast <8 x i8> %T181.vec_swap.ie143 to i64, !tcg.op !186
  %T181.out = lshr i64 %T181.swap_out, 48, !tcg.op !186
  store i64 %T181.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !186
; ======== TCG [182] bswap32_i32 [t2],t2,attr-swp:oz ========
  %T182.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !187
  %T182.vec = bitcast i32 %T182.tmp2 to <4 x i8>, !tcg.op !187
  %T182.vec.ee = extractelement <4 x i8> %T182.vec, i64 0, !tcg.op !187
  %T182.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T182.vec.ee, i64 3, !tcg.op !187
  %T182.vec.ee144 = extractelement <4 x i8> %T182.vec, i64 1, !tcg.op !187
  %T182.vec_swap.ie145 = insertelement <4 x i8> %T182.vec_swap.ie, i8 %T182.vec.ee144, i64 2, !tcg.op !187
  %T182.vec.ee146 = extractelement <4 x i8> %T182.vec, i64 2, !tcg.op !187
  %T182.vec_swap.ie147 = insertelement <4 x i8> %T182.vec_swap.ie145, i8 %T182.vec.ee146, i64 1, !tcg.op !187
  %T182.vec.ee148 = extractelement <4 x i8> %T182.vec, i64 3, !tcg.op !187
  %T182.vec_swap.ie149 = insertelement <4 x i8> %T182.vec_swap.ie147, i8 %T182.vec.ee148, i64 0, !tcg.op !187
  %T182.swap_out = bitcast <4 x i8> %T182.vec_swap.ie149 to i32, !tcg.op !187
  %T182.out = lshr i32 %T182.swap_out, 0, !tcg.op !187
  store i32 %T182.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !187
; ======== TCG [183] bswap32_i32 [t2],t2,attr-swp:os ========
  %T183.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !188
  %T183.vec = bitcast i32 %T183.tmp2 to <4 x i8>, !tcg.op !188
  %T183.vec.ee = extractelement <4 x i8> %T183.vec, i64 0, !tcg.op !188
  %T183.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T183.vec.ee, i64 3, !tcg.op !188
  %T183.vec.ee150 = extractelement <4 x i8> %T183.vec, i64 1, !tcg.op !188
  %T183.vec_swap.ie151 = insertelement <4 x i8> %T183.vec_swap.ie, i8 %T183.vec.ee150, i64 2, !tcg.op !188
  %T183.vec.ee152 = extractelement <4 x i8> %T183.vec, i64 2, !tcg.op !188
  %T183.vec_swap.ie153 = insertelement <4 x i8> %T183.vec_swap.ie151, i8 %T183.vec.ee152, i64 1, !tcg.op !188
  %T183.vec.ee154 = extractelement <4 x i8> %T183.vec, i64 3, !tcg.op !188
  %T183.vec_swap.ie155 = insertelement <4 x i8> %T183.vec_swap.ie153, i8 %T183.vec.ee154, i64 0, !tcg.op !188
  %T183.swap_out = bitcast <4 x i8> %T183.vec_swap.ie155 to i32, !tcg.op !188
  %T183.out = ashr i32 %T183.swap_out, 0, !tcg.op !188
  store i32 %T183.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !188
; ======== TCG [184] bswap32_i32 [t2],t2,attr-swp:iz ========
  %T184.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !189
  %T184.vec = bitcast i32 %T184.tmp2 to <4 x i8>, !tcg.op !189
  %T184.vec.ee = extractelement <4 x i8> %T184.vec, i64 0, !tcg.op !189
  %T184.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T184.vec.ee, i64 3, !tcg.op !189
  %T184.vec.ee156 = extractelement <4 x i8> %T184.vec, i64 1, !tcg.op !189
  %T184.vec_swap.ie157 = insertelement <4 x i8> %T184.vec_swap.ie, i8 %T184.vec.ee156, i64 2, !tcg.op !189
  %T184.vec.ee158 = extractelement <4 x i8> %T184.vec, i64 2, !tcg.op !189
  %T184.vec_swap.ie159 = insertelement <4 x i8> %T184.vec_swap.ie157, i8 %T184.vec.ee158, i64 1, !tcg.op !189
  %T184.vec.ee160 = extractelement <4 x i8> %T184.vec, i64 3, !tcg.op !189
  %T184.vec_swap.ie161 = insertelement <4 x i8> %T184.vec_swap.ie159, i8 %T184.vec.ee160, i64 0, !tcg.op !189
  %T184.swap_out = bitcast <4 x i8> %T184.vec_swap.ie161 to i32, !tcg.op !189
  %T184.out = lshr i32 %T184.swap_out, 0, !tcg.op !189
  store i32 %T184.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !189
; ======== TCG [185] bswap32_i32 [t2],t2,attr-swp:iz,attr-swp:oz ========
  %T185.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !190
  %T185.vec = bitcast i32 %T185.tmp2 to <4 x i8>, !tcg.op !190
  %T185.vec.ee = extractelement <4 x i8> %T185.vec, i64 0, !tcg.op !190
  %T185.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T185.vec.ee, i64 3, !tcg.op !190
  %T185.vec.ee162 = extractelement <4 x i8> %T185.vec, i64 1, !tcg.op !190
  %T185.vec_swap.ie163 = insertelement <4 x i8> %T185.vec_swap.ie, i8 %T185.vec.ee162, i64 2, !tcg.op !190
  %T185.vec.ee164 = extractelement <4 x i8> %T185.vec, i64 2, !tcg.op !190
  %T185.vec_swap.ie165 = insertelement <4 x i8> %T185.vec_swap.ie163, i8 %T185.vec.ee164, i64 1, !tcg.op !190
  %T185.vec.ee166 = extractelement <4 x i8> %T185.vec, i64 3, !tcg.op !190
  %T185.vec_swap.ie167 = insertelement <4 x i8> %T185.vec_swap.ie165, i8 %T185.vec.ee166, i64 0, !tcg.op !190
  %T185.swap_out = bitcast <4 x i8> %T185.vec_swap.ie167 to i32, !tcg.op !190
  %T185.out = lshr i32 %T185.swap_out, 0, !tcg.op !190
  store i32 %T185.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !190
; ======== TCG [186] bswap32_i32 [t2],t2,attr-swp:iz,attr-swp:os ========
  %T186.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !191
  %T186.vec = bitcast i32 %T186.tmp2 to <4 x i8>, !tcg.op !191
  %T186.vec.ee = extractelement <4 x i8> %T186.vec, i64 0, !tcg.op !191
  %T186.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T186.vec.ee, i64 3, !tcg.op !191
  %T186.vec.ee168 = extractelement <4 x i8> %T186.vec, i64 1, !tcg.op !191
  %T186.vec_swap.ie169 = insertelement <4 x i8> %T186.vec_swap.ie, i8 %T186.vec.ee168, i64 2, !tcg.op !191
  %T186.vec.ee170 = extractelement <4 x i8> %T186.vec, i64 2, !tcg.op !191
  %T186.vec_swap.ie171 = insertelement <4 x i8> %T186.vec_swap.ie169, i8 %T186.vec.ee170, i64 1, !tcg.op !191
  %T186.vec.ee172 = extractelement <4 x i8> %T186.vec, i64 3, !tcg.op !191
  %T186.vec_swap.ie173 = insertelement <4 x i8> %T186.vec_swap.ie171, i8 %T186.vec.ee172, i64 0, !tcg.op !191
  %T186.swap_out = bitcast <4 x i8> %T186.vec_swap.ie173 to i32, !tcg.op !191
  %T186.out = ashr i32 %T186.swap_out, 0, !tcg.op !191
  store i32 %T186.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !191
; ======== TCG [187] bswap32_i32 [t2],t2 ========
  %T187.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !192
  %T187.vec = bitcast i32 %T187.tmp2 to <4 x i8>, !tcg.op !192
  %T187.vec.ee = extractelement <4 x i8> %T187.vec, i64 0, !tcg.op !192
  %T187.vec_swap.ie = insertelement <4 x i8> zeroinitializer, i8 %T187.vec.ee, i64 3, !tcg.op !192
  %T187.vec.ee174 = extractelement <4 x i8> %T187.vec, i64 1, !tcg.op !192
  %T187.vec_swap.ie175 = insertelement <4 x i8> %T187.vec_swap.ie, i8 %T187.vec.ee174, i64 2, !tcg.op !192
  %T187.vec.ee176 = extractelement <4 x i8> %T187.vec, i64 2, !tcg.op !192
  %T187.vec_swap.ie177 = insertelement <4 x i8> %T187.vec_swap.ie175, i8 %T187.vec.ee176, i64 1, !tcg.op !192
  %T187.vec.ee178 = extractelement <4 x i8> %T187.vec, i64 3, !tcg.op !192
  %T187.vec_swap.ie179 = insertelement <4 x i8> %T187.vec_swap.ie177, i8 %T187.vec.ee178, i64 0, !tcg.op !192
  %T187.swap_out = bitcast <4 x i8> %T187.vec_swap.ie179 to i32, !tcg.op !192
  %T187.out = lshr i32 %T187.swap_out, 0, !tcg.op !192
  store i32 %T187.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !192
; ======== TCG [188] bswap32_i64 [t2],t2,attr-swp:oz ========
  %T188.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !193
  %T188.vec = bitcast i64 %T188.tmp2 to <8 x i8>, !tcg.op !193
  %T188.vec.ee = extractelement <8 x i8> %T188.vec, i64 0, !tcg.op !193
  %T188.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T188.vec.ee, i64 7, !tcg.op !193
  %T188.vec.ee180 = extractelement <8 x i8> %T188.vec, i64 1, !tcg.op !193
  %T188.vec_swap.ie181 = insertelement <8 x i8> %T188.vec_swap.ie, i8 %T188.vec.ee180, i64 6, !tcg.op !193
  %T188.vec.ee182 = extractelement <8 x i8> %T188.vec, i64 2, !tcg.op !193
  %T188.vec_swap.ie183 = insertelement <8 x i8> %T188.vec_swap.ie181, i8 %T188.vec.ee182, i64 5, !tcg.op !193
  %T188.vec.ee184 = extractelement <8 x i8> %T188.vec, i64 3, !tcg.op !193
  %T188.vec_swap.ie185 = insertelement <8 x i8> %T188.vec_swap.ie183, i8 %T188.vec.ee184, i64 4, !tcg.op !193
  %T188.vec.ee186 = extractelement <8 x i8> %T188.vec, i64 4, !tcg.op !193
  %T188.vec_swap.ie187 = insertelement <8 x i8> %T188.vec_swap.ie185, i8 %T188.vec.ee186, i64 3, !tcg.op !193
  %T188.vec.ee188 = extractelement <8 x i8> %T188.vec, i64 5, !tcg.op !193
  %T188.vec_swap.ie189 = insertelement <8 x i8> %T188.vec_swap.ie187, i8 %T188.vec.ee188, i64 2, !tcg.op !193
  %T188.vec.ee190 = extractelement <8 x i8> %T188.vec, i64 6, !tcg.op !193
  %T188.vec_swap.ie191 = insertelement <8 x i8> %T188.vec_swap.ie189, i8 %T188.vec.ee190, i64 1, !tcg.op !193
  %T188.vec.ee192 = extractelement <8 x i8> %T188.vec, i64 7, !tcg.op !193
  %T188.vec_swap.ie193 = insertelement <8 x i8> %T188.vec_swap.ie191, i8 %T188.vec.ee192, i64 0, !tcg.op !193
  %T188.swap_out = bitcast <8 x i8> %T188.vec_swap.ie193 to i64, !tcg.op !193
  %T188.out = lshr i64 %T188.swap_out, 32, !tcg.op !193
  store i64 %T188.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !193
; ======== TCG [189] bswap32_i64 [t2],t2,attr-swp:os ========
  %T189.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !194
  %T189.vec = bitcast i64 %T189.tmp2 to <8 x i8>, !tcg.op !194
  %T189.vec.ee = extractelement <8 x i8> %T189.vec, i64 0, !tcg.op !194
  %T189.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T189.vec.ee, i64 7, !tcg.op !194
  %T189.vec.ee194 = extractelement <8 x i8> %T189.vec, i64 1, !tcg.op !194
  %T189.vec_swap.ie195 = insertelement <8 x i8> %T189.vec_swap.ie, i8 %T189.vec.ee194, i64 6, !tcg.op !194
  %T189.vec.ee196 = extractelement <8 x i8> %T189.vec, i64 2, !tcg.op !194
  %T189.vec_swap.ie197 = insertelement <8 x i8> %T189.vec_swap.ie195, i8 %T189.vec.ee196, i64 5, !tcg.op !194
  %T189.vec.ee198 = extractelement <8 x i8> %T189.vec, i64 3, !tcg.op !194
  %T189.vec_swap.ie199 = insertelement <8 x i8> %T189.vec_swap.ie197, i8 %T189.vec.ee198, i64 4, !tcg.op !194
  %T189.vec.ee200 = extractelement <8 x i8> %T189.vec, i64 4, !tcg.op !194
  %T189.vec_swap.ie201 = insertelement <8 x i8> %T189.vec_swap.ie199, i8 %T189.vec.ee200, i64 3, !tcg.op !194
  %T189.vec.ee202 = extractelement <8 x i8> %T189.vec, i64 5, !tcg.op !194
  %T189.vec_swap.ie203 = insertelement <8 x i8> %T189.vec_swap.ie201, i8 %T189.vec.ee202, i64 2, !tcg.op !194
  %T189.vec.ee204 = extractelement <8 x i8> %T189.vec, i64 6, !tcg.op !194
  %T189.vec_swap.ie205 = insertelement <8 x i8> %T189.vec_swap.ie203, i8 %T189.vec.ee204, i64 1, !tcg.op !194
  %T189.vec.ee206 = extractelement <8 x i8> %T189.vec, i64 7, !tcg.op !194
  %T189.vec_swap.ie207 = insertelement <8 x i8> %T189.vec_swap.ie205, i8 %T189.vec.ee206, i64 0, !tcg.op !194
  %T189.swap_out = bitcast <8 x i8> %T189.vec_swap.ie207 to i64, !tcg.op !194
  %T189.out = ashr i64 %T189.swap_out, 32, !tcg.op !194
  store i64 %T189.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !194
; ======== TCG [190] bswap32_i64 [t2],t2,attr-swp:iz ========
  %T190.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !195
  %T190.vec = bitcast i64 %T190.tmp2 to <8 x i8>, !tcg.op !195
  %T190.vec.ee = extractelement <8 x i8> %T190.vec, i64 0, !tcg.op !195
  %T190.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T190.vec.ee, i64 7, !tcg.op !195
  %T190.vec.ee208 = extractelement <8 x i8> %T190.vec, i64 1, !tcg.op !195
  %T190.vec_swap.ie209 = insertelement <8 x i8> %T190.vec_swap.ie, i8 %T190.vec.ee208, i64 6, !tcg.op !195
  %T190.vec.ee210 = extractelement <8 x i8> %T190.vec, i64 2, !tcg.op !195
  %T190.vec_swap.ie211 = insertelement <8 x i8> %T190.vec_swap.ie209, i8 %T190.vec.ee210, i64 5, !tcg.op !195
  %T190.vec.ee212 = extractelement <8 x i8> %T190.vec, i64 3, !tcg.op !195
  %T190.vec_swap.ie213 = insertelement <8 x i8> %T190.vec_swap.ie211, i8 %T190.vec.ee212, i64 4, !tcg.op !195
  %T190.vec.ee214 = extractelement <8 x i8> %T190.vec, i64 4, !tcg.op !195
  %T190.vec_swap.ie215 = insertelement <8 x i8> %T190.vec_swap.ie213, i8 %T190.vec.ee214, i64 3, !tcg.op !195
  %T190.vec.ee216 = extractelement <8 x i8> %T190.vec, i64 5, !tcg.op !195
  %T190.vec_swap.ie217 = insertelement <8 x i8> %T190.vec_swap.ie215, i8 %T190.vec.ee216, i64 2, !tcg.op !195
  %T190.vec.ee218 = extractelement <8 x i8> %T190.vec, i64 6, !tcg.op !195
  %T190.vec_swap.ie219 = insertelement <8 x i8> %T190.vec_swap.ie217, i8 %T190.vec.ee218, i64 1, !tcg.op !195
  %T190.vec.ee220 = extractelement <8 x i8> %T190.vec, i64 7, !tcg.op !195
  %T190.vec_swap.ie221 = insertelement <8 x i8> %T190.vec_swap.ie219, i8 %T190.vec.ee220, i64 0, !tcg.op !195
  %T190.swap_out = bitcast <8 x i8> %T190.vec_swap.ie221 to i64, !tcg.op !195
  %T190.out = lshr i64 %T190.swap_out, 32, !tcg.op !195
  store i64 %T190.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !195
; ======== TCG [191] bswap32_i64 [t2],t2,attr-swp:iz,attr-swp:oz ========
  %T191.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !196
  %T191.vec = bitcast i64 %T191.tmp2 to <8 x i8>, !tcg.op !196
  %T191.vec.ee = extractelement <8 x i8> %T191.vec, i64 0, !tcg.op !196
  %T191.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T191.vec.ee, i64 7, !tcg.op !196
  %T191.vec.ee222 = extractelement <8 x i8> %T191.vec, i64 1, !tcg.op !196
  %T191.vec_swap.ie223 = insertelement <8 x i8> %T191.vec_swap.ie, i8 %T191.vec.ee222, i64 6, !tcg.op !196
  %T191.vec.ee224 = extractelement <8 x i8> %T191.vec, i64 2, !tcg.op !196
  %T191.vec_swap.ie225 = insertelement <8 x i8> %T191.vec_swap.ie223, i8 %T191.vec.ee224, i64 5, !tcg.op !196
  %T191.vec.ee226 = extractelement <8 x i8> %T191.vec, i64 3, !tcg.op !196
  %T191.vec_swap.ie227 = insertelement <8 x i8> %T191.vec_swap.ie225, i8 %T191.vec.ee226, i64 4, !tcg.op !196
  %T191.vec.ee228 = extractelement <8 x i8> %T191.vec, i64 4, !tcg.op !196
  %T191.vec_swap.ie229 = insertelement <8 x i8> %T191.vec_swap.ie227, i8 %T191.vec.ee228, i64 3, !tcg.op !196
  %T191.vec.ee230 = extractelement <8 x i8> %T191.vec, i64 5, !tcg.op !196
  %T191.vec_swap.ie231 = insertelement <8 x i8> %T191.vec_swap.ie229, i8 %T191.vec.ee230, i64 2, !tcg.op !196
  %T191.vec.ee232 = extractelement <8 x i8> %T191.vec, i64 6, !tcg.op !196
  %T191.vec_swap.ie233 = insertelement <8 x i8> %T191.vec_swap.ie231, i8 %T191.vec.ee232, i64 1, !tcg.op !196
  %T191.vec.ee234 = extractelement <8 x i8> %T191.vec, i64 7, !tcg.op !196
  %T191.vec_swap.ie235 = insertelement <8 x i8> %T191.vec_swap.ie233, i8 %T191.vec.ee234, i64 0, !tcg.op !196
  %T191.swap_out = bitcast <8 x i8> %T191.vec_swap.ie235 to i64, !tcg.op !196
  %T191.out = lshr i64 %T191.swap_out, 32, !tcg.op !196
  store i64 %T191.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !196
; ======== TCG [192] bswap32_i64 [t2],t2,attr-swp:iz,attr-swp:os ========
  %T192.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !197
  %T192.vec = bitcast i64 %T192.tmp2 to <8 x i8>, !tcg.op !197
  %T192.vec.ee = extractelement <8 x i8> %T192.vec, i64 0, !tcg.op !197
  %T192.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T192.vec.ee, i64 7, !tcg.op !197
  %T192.vec.ee236 = extractelement <8 x i8> %T192.vec, i64 1, !tcg.op !197
  %T192.vec_swap.ie237 = insertelement <8 x i8> %T192.vec_swap.ie, i8 %T192.vec.ee236, i64 6, !tcg.op !197
  %T192.vec.ee238 = extractelement <8 x i8> %T192.vec, i64 2, !tcg.op !197
  %T192.vec_swap.ie239 = insertelement <8 x i8> %T192.vec_swap.ie237, i8 %T192.vec.ee238, i64 5, !tcg.op !197
  %T192.vec.ee240 = extractelement <8 x i8> %T192.vec, i64 3, !tcg.op !197
  %T192.vec_swap.ie241 = insertelement <8 x i8> %T192.vec_swap.ie239, i8 %T192.vec.ee240, i64 4, !tcg.op !197
  %T192.vec.ee242 = extractelement <8 x i8> %T192.vec, i64 4, !tcg.op !197
  %T192.vec_swap.ie243 = insertelement <8 x i8> %T192.vec_swap.ie241, i8 %T192.vec.ee242, i64 3, !tcg.op !197
  %T192.vec.ee244 = extractelement <8 x i8> %T192.vec, i64 5, !tcg.op !197
  %T192.vec_swap.ie245 = insertelement <8 x i8> %T192.vec_swap.ie243, i8 %T192.vec.ee244, i64 2, !tcg.op !197
  %T192.vec.ee246 = extractelement <8 x i8> %T192.vec, i64 6, !tcg.op !197
  %T192.vec_swap.ie247 = insertelement <8 x i8> %T192.vec_swap.ie245, i8 %T192.vec.ee246, i64 1, !tcg.op !197
  %T192.vec.ee248 = extractelement <8 x i8> %T192.vec, i64 7, !tcg.op !197
  %T192.vec_swap.ie249 = insertelement <8 x i8> %T192.vec_swap.ie247, i8 %T192.vec.ee248, i64 0, !tcg.op !197
  %T192.swap_out = bitcast <8 x i8> %T192.vec_swap.ie249 to i64, !tcg.op !197
  %T192.out = ashr i64 %T192.swap_out, 32, !tcg.op !197
  store i64 %T192.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !197
; ======== TCG [193] bswap32_i64 [t2],t2 ========
  %T193.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !198
  %T193.vec = bitcast i64 %T193.tmp2 to <8 x i8>, !tcg.op !198
  %T193.vec.ee = extractelement <8 x i8> %T193.vec, i64 0, !tcg.op !198
  %T193.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T193.vec.ee, i64 7, !tcg.op !198
  %T193.vec.ee250 = extractelement <8 x i8> %T193.vec, i64 1, !tcg.op !198
  %T193.vec_swap.ie251 = insertelement <8 x i8> %T193.vec_swap.ie, i8 %T193.vec.ee250, i64 6, !tcg.op !198
  %T193.vec.ee252 = extractelement <8 x i8> %T193.vec, i64 2, !tcg.op !198
  %T193.vec_swap.ie253 = insertelement <8 x i8> %T193.vec_swap.ie251, i8 %T193.vec.ee252, i64 5, !tcg.op !198
  %T193.vec.ee254 = extractelement <8 x i8> %T193.vec, i64 3, !tcg.op !198
  %T193.vec_swap.ie255 = insertelement <8 x i8> %T193.vec_swap.ie253, i8 %T193.vec.ee254, i64 4, !tcg.op !198
  %T193.vec.ee256 = extractelement <8 x i8> %T193.vec, i64 4, !tcg.op !198
  %T193.vec_swap.ie257 = insertelement <8 x i8> %T193.vec_swap.ie255, i8 %T193.vec.ee256, i64 3, !tcg.op !198
  %T193.vec.ee258 = extractelement <8 x i8> %T193.vec, i64 5, !tcg.op !198
  %T193.vec_swap.ie259 = insertelement <8 x i8> %T193.vec_swap.ie257, i8 %T193.vec.ee258, i64 2, !tcg.op !198
  %T193.vec.ee260 = extractelement <8 x i8> %T193.vec, i64 6, !tcg.op !198
  %T193.vec_swap.ie261 = insertelement <8 x i8> %T193.vec_swap.ie259, i8 %T193.vec.ee260, i64 1, !tcg.op !198
  %T193.vec.ee262 = extractelement <8 x i8> %T193.vec, i64 7, !tcg.op !198
  %T193.vec_swap.ie263 = insertelement <8 x i8> %T193.vec_swap.ie261, i8 %T193.vec.ee262, i64 0, !tcg.op !198
  %T193.swap_out = bitcast <8 x i8> %T193.vec_swap.ie263 to i64, !tcg.op !198
  %T193.out = lshr i64 %T193.swap_out, 32, !tcg.op !198
  store i64 %T193.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !198
; ======== TCG [194] bswap64_i64 [t2],t2,attr-swp:oz ========
  %T194.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !199
  %T194.vec = bitcast i64 %T194.tmp2 to <8 x i8>, !tcg.op !199
  %T194.vec.ee = extractelement <8 x i8> %T194.vec, i64 0, !tcg.op !199
  %T194.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T194.vec.ee, i64 7, !tcg.op !199
  %T194.vec.ee264 = extractelement <8 x i8> %T194.vec, i64 1, !tcg.op !199
  %T194.vec_swap.ie265 = insertelement <8 x i8> %T194.vec_swap.ie, i8 %T194.vec.ee264, i64 6, !tcg.op !199
  %T194.vec.ee266 = extractelement <8 x i8> %T194.vec, i64 2, !tcg.op !199
  %T194.vec_swap.ie267 = insertelement <8 x i8> %T194.vec_swap.ie265, i8 %T194.vec.ee266, i64 5, !tcg.op !199
  %T194.vec.ee268 = extractelement <8 x i8> %T194.vec, i64 3, !tcg.op !199
  %T194.vec_swap.ie269 = insertelement <8 x i8> %T194.vec_swap.ie267, i8 %T194.vec.ee268, i64 4, !tcg.op !199
  %T194.vec.ee270 = extractelement <8 x i8> %T194.vec, i64 4, !tcg.op !199
  %T194.vec_swap.ie271 = insertelement <8 x i8> %T194.vec_swap.ie269, i8 %T194.vec.ee270, i64 3, !tcg.op !199
  %T194.vec.ee272 = extractelement <8 x i8> %T194.vec, i64 5, !tcg.op !199
  %T194.vec_swap.ie273 = insertelement <8 x i8> %T194.vec_swap.ie271, i8 %T194.vec.ee272, i64 2, !tcg.op !199
  %T194.vec.ee274 = extractelement <8 x i8> %T194.vec, i64 6, !tcg.op !199
  %T194.vec_swap.ie275 = insertelement <8 x i8> %T194.vec_swap.ie273, i8 %T194.vec.ee274, i64 1, !tcg.op !199
  %T194.vec.ee276 = extractelement <8 x i8> %T194.vec, i64 7, !tcg.op !199
  %T194.vec_swap.ie277 = insertelement <8 x i8> %T194.vec_swap.ie275, i8 %T194.vec.ee276, i64 0, !tcg.op !199
  %T194.swap_out = bitcast <8 x i8> %T194.vec_swap.ie277 to i64, !tcg.op !199
  %T194.out = lshr i64 %T194.swap_out, 0, !tcg.op !199
  store i64 %T194.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !199
; ======== TCG [195] bswap64_i64 [t2],t2,attr-swp:os ========
  %T195.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !200
  %T195.vec = bitcast i64 %T195.tmp2 to <8 x i8>, !tcg.op !200
  %T195.vec.ee = extractelement <8 x i8> %T195.vec, i64 0, !tcg.op !200
  %T195.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T195.vec.ee, i64 7, !tcg.op !200
  %T195.vec.ee278 = extractelement <8 x i8> %T195.vec, i64 1, !tcg.op !200
  %T195.vec_swap.ie279 = insertelement <8 x i8> %T195.vec_swap.ie, i8 %T195.vec.ee278, i64 6, !tcg.op !200
  %T195.vec.ee280 = extractelement <8 x i8> %T195.vec, i64 2, !tcg.op !200
  %T195.vec_swap.ie281 = insertelement <8 x i8> %T195.vec_swap.ie279, i8 %T195.vec.ee280, i64 5, !tcg.op !200
  %T195.vec.ee282 = extractelement <8 x i8> %T195.vec, i64 3, !tcg.op !200
  %T195.vec_swap.ie283 = insertelement <8 x i8> %T195.vec_swap.ie281, i8 %T195.vec.ee282, i64 4, !tcg.op !200
  %T195.vec.ee284 = extractelement <8 x i8> %T195.vec, i64 4, !tcg.op !200
  %T195.vec_swap.ie285 = insertelement <8 x i8> %T195.vec_swap.ie283, i8 %T195.vec.ee284, i64 3, !tcg.op !200
  %T195.vec.ee286 = extractelement <8 x i8> %T195.vec, i64 5, !tcg.op !200
  %T195.vec_swap.ie287 = insertelement <8 x i8> %T195.vec_swap.ie285, i8 %T195.vec.ee286, i64 2, !tcg.op !200
  %T195.vec.ee288 = extractelement <8 x i8> %T195.vec, i64 6, !tcg.op !200
  %T195.vec_swap.ie289 = insertelement <8 x i8> %T195.vec_swap.ie287, i8 %T195.vec.ee288, i64 1, !tcg.op !200
  %T195.vec.ee290 = extractelement <8 x i8> %T195.vec, i64 7, !tcg.op !200
  %T195.vec_swap.ie291 = insertelement <8 x i8> %T195.vec_swap.ie289, i8 %T195.vec.ee290, i64 0, !tcg.op !200
  %T195.swap_out = bitcast <8 x i8> %T195.vec_swap.ie291 to i64, !tcg.op !200
  %T195.out = ashr i64 %T195.swap_out, 0, !tcg.op !200
  store i64 %T195.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !200
; ======== TCG [196] bswap64_i64 [t2],t2,attr-swp:iz ========
  %T196.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !201
  %T196.vec = bitcast i64 %T196.tmp2 to <8 x i8>, !tcg.op !201
  %T196.vec.ee = extractelement <8 x i8> %T196.vec, i64 0, !tcg.op !201
  %T196.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T196.vec.ee, i64 7, !tcg.op !201
  %T196.vec.ee292 = extractelement <8 x i8> %T196.vec, i64 1, !tcg.op !201
  %T196.vec_swap.ie293 = insertelement <8 x i8> %T196.vec_swap.ie, i8 %T196.vec.ee292, i64 6, !tcg.op !201
  %T196.vec.ee294 = extractelement <8 x i8> %T196.vec, i64 2, !tcg.op !201
  %T196.vec_swap.ie295 = insertelement <8 x i8> %T196.vec_swap.ie293, i8 %T196.vec.ee294, i64 5, !tcg.op !201
  %T196.vec.ee296 = extractelement <8 x i8> %T196.vec, i64 3, !tcg.op !201
  %T196.vec_swap.ie297 = insertelement <8 x i8> %T196.vec_swap.ie295, i8 %T196.vec.ee296, i64 4, !tcg.op !201
  %T196.vec.ee298 = extractelement <8 x i8> %T196.vec, i64 4, !tcg.op !201
  %T196.vec_swap.ie299 = insertelement <8 x i8> %T196.vec_swap.ie297, i8 %T196.vec.ee298, i64 3, !tcg.op !201
  %T196.vec.ee300 = extractelement <8 x i8> %T196.vec, i64 5, !tcg.op !201
  %T196.vec_swap.ie301 = insertelement <8 x i8> %T196.vec_swap.ie299, i8 %T196.vec.ee300, i64 2, !tcg.op !201
  %T196.vec.ee302 = extractelement <8 x i8> %T196.vec, i64 6, !tcg.op !201
  %T196.vec_swap.ie303 = insertelement <8 x i8> %T196.vec_swap.ie301, i8 %T196.vec.ee302, i64 1, !tcg.op !201
  %T196.vec.ee304 = extractelement <8 x i8> %T196.vec, i64 7, !tcg.op !201
  %T196.vec_swap.ie305 = insertelement <8 x i8> %T196.vec_swap.ie303, i8 %T196.vec.ee304, i64 0, !tcg.op !201
  %T196.swap_out = bitcast <8 x i8> %T196.vec_swap.ie305 to i64, !tcg.op !201
  %T196.out = lshr i64 %T196.swap_out, 0, !tcg.op !201
  store i64 %T196.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !201
; ======== TCG [197] bswap64_i64 [t2],t2,attr-swp:iz,attr-swp:oz ========
  %T197.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !202
  %T197.vec = bitcast i64 %T197.tmp2 to <8 x i8>, !tcg.op !202
  %T197.vec.ee = extractelement <8 x i8> %T197.vec, i64 0, !tcg.op !202
  %T197.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T197.vec.ee, i64 7, !tcg.op !202
  %T197.vec.ee306 = extractelement <8 x i8> %T197.vec, i64 1, !tcg.op !202
  %T197.vec_swap.ie307 = insertelement <8 x i8> %T197.vec_swap.ie, i8 %T197.vec.ee306, i64 6, !tcg.op !202
  %T197.vec.ee308 = extractelement <8 x i8> %T197.vec, i64 2, !tcg.op !202
  %T197.vec_swap.ie309 = insertelement <8 x i8> %T197.vec_swap.ie307, i8 %T197.vec.ee308, i64 5, !tcg.op !202
  %T197.vec.ee310 = extractelement <8 x i8> %T197.vec, i64 3, !tcg.op !202
  %T197.vec_swap.ie311 = insertelement <8 x i8> %T197.vec_swap.ie309, i8 %T197.vec.ee310, i64 4, !tcg.op !202
  %T197.vec.ee312 = extractelement <8 x i8> %T197.vec, i64 4, !tcg.op !202
  %T197.vec_swap.ie313 = insertelement <8 x i8> %T197.vec_swap.ie311, i8 %T197.vec.ee312, i64 3, !tcg.op !202
  %T197.vec.ee314 = extractelement <8 x i8> %T197.vec, i64 5, !tcg.op !202
  %T197.vec_swap.ie315 = insertelement <8 x i8> %T197.vec_swap.ie313, i8 %T197.vec.ee314, i64 2, !tcg.op !202
  %T197.vec.ee316 = extractelement <8 x i8> %T197.vec, i64 6, !tcg.op !202
  %T197.vec_swap.ie317 = insertelement <8 x i8> %T197.vec_swap.ie315, i8 %T197.vec.ee316, i64 1, !tcg.op !202
  %T197.vec.ee318 = extractelement <8 x i8> %T197.vec, i64 7, !tcg.op !202
  %T197.vec_swap.ie319 = insertelement <8 x i8> %T197.vec_swap.ie317, i8 %T197.vec.ee318, i64 0, !tcg.op !202
  %T197.swap_out = bitcast <8 x i8> %T197.vec_swap.ie319 to i64, !tcg.op !202
  %T197.out = lshr i64 %T197.swap_out, 0, !tcg.op !202
  store i64 %T197.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !202
; ======== TCG [198] bswap64_i64 [t2],t2,attr-swp:iz,attr-swp:os ========
  %T198.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !203
  %T198.vec = bitcast i64 %T198.tmp2 to <8 x i8>, !tcg.op !203
  %T198.vec.ee = extractelement <8 x i8> %T198.vec, i64 0, !tcg.op !203
  %T198.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T198.vec.ee, i64 7, !tcg.op !203
  %T198.vec.ee320 = extractelement <8 x i8> %T198.vec, i64 1, !tcg.op !203
  %T198.vec_swap.ie321 = insertelement <8 x i8> %T198.vec_swap.ie, i8 %T198.vec.ee320, i64 6, !tcg.op !203
  %T198.vec.ee322 = extractelement <8 x i8> %T198.vec, i64 2, !tcg.op !203
  %T198.vec_swap.ie323 = insertelement <8 x i8> %T198.vec_swap.ie321, i8 %T198.vec.ee322, i64 5, !tcg.op !203
  %T198.vec.ee324 = extractelement <8 x i8> %T198.vec, i64 3, !tcg.op !203
  %T198.vec_swap.ie325 = insertelement <8 x i8> %T198.vec_swap.ie323, i8 %T198.vec.ee324, i64 4, !tcg.op !203
  %T198.vec.ee326 = extractelement <8 x i8> %T198.vec, i64 4, !tcg.op !203
  %T198.vec_swap.ie327 = insertelement <8 x i8> %T198.vec_swap.ie325, i8 %T198.vec.ee326, i64 3, !tcg.op !203
  %T198.vec.ee328 = extractelement <8 x i8> %T198.vec, i64 5, !tcg.op !203
  %T198.vec_swap.ie329 = insertelement <8 x i8> %T198.vec_swap.ie327, i8 %T198.vec.ee328, i64 2, !tcg.op !203
  %T198.vec.ee330 = extractelement <8 x i8> %T198.vec, i64 6, !tcg.op !203
  %T198.vec_swap.ie331 = insertelement <8 x i8> %T198.vec_swap.ie329, i8 %T198.vec.ee330, i64 1, !tcg.op !203
  %T198.vec.ee332 = extractelement <8 x i8> %T198.vec, i64 7, !tcg.op !203
  %T198.vec_swap.ie333 = insertelement <8 x i8> %T198.vec_swap.ie331, i8 %T198.vec.ee332, i64 0, !tcg.op !203
  %T198.swap_out = bitcast <8 x i8> %T198.vec_swap.ie333 to i64, !tcg.op !203
  %T198.out = ashr i64 %T198.swap_out, 0, !tcg.op !203
  store i64 %T198.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !203
; ======== TCG [199] bswap64_i64 [t2],t2 ========
  %T199.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !204
  %T199.vec = bitcast i64 %T199.tmp2 to <8 x i8>, !tcg.op !204
  %T199.vec.ee = extractelement <8 x i8> %T199.vec, i64 0, !tcg.op !204
  %T199.vec_swap.ie = insertelement <8 x i8> zeroinitializer, i8 %T199.vec.ee, i64 7, !tcg.op !204
  %T199.vec.ee334 = extractelement <8 x i8> %T199.vec, i64 1, !tcg.op !204
  %T199.vec_swap.ie335 = insertelement <8 x i8> %T199.vec_swap.ie, i8 %T199.vec.ee334, i64 6, !tcg.op !204
  %T199.vec.ee336 = extractelement <8 x i8> %T199.vec, i64 2, !tcg.op !204
  %T199.vec_swap.ie337 = insertelement <8 x i8> %T199.vec_swap.ie335, i8 %T199.vec.ee336, i64 5, !tcg.op !204
  %T199.vec.ee338 = extractelement <8 x i8> %T199.vec, i64 3, !tcg.op !204
  %T199.vec_swap.ie339 = insertelement <8 x i8> %T199.vec_swap.ie337, i8 %T199.vec.ee338, i64 4, !tcg.op !204
  %T199.vec.ee340 = extractelement <8 x i8> %T199.vec, i64 4, !tcg.op !204
  %T199.vec_swap.ie341 = insertelement <8 x i8> %T199.vec_swap.ie339, i8 %T199.vec.ee340, i64 3, !tcg.op !204
  %T199.vec.ee342 = extractelement <8 x i8> %T199.vec, i64 5, !tcg.op !204
  %T199.vec_swap.ie343 = insertelement <8 x i8> %T199.vec_swap.ie341, i8 %T199.vec.ee342, i64 2, !tcg.op !204
  %T199.vec.ee344 = extractelement <8 x i8> %T199.vec, i64 6, !tcg.op !204
  %T199.vec_swap.ie345 = insertelement <8 x i8> %T199.vec_swap.ie343, i8 %T199.vec.ee344, i64 1, !tcg.op !204
  %T199.vec.ee346 = extractelement <8 x i8> %T199.vec, i64 7, !tcg.op !204
  %T199.vec_swap.ie347 = insertelement <8 x i8> %T199.vec_swap.ie345, i8 %T199.vec.ee346, i64 0, !tcg.op !204
  %T199.swap_out = bitcast <8 x i8> %T199.vec_swap.ie347 to i64, !tcg.op !204
  %T199.out = lshr i64 %T199.swap_out, 0, !tcg.op !204
  store i64 %T199.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !204
; ======== TCG [200] deposit_i32 [t2],t2,t0,0x0,0x8 ========
  %T200.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !205
  %T200.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !205
  %T200.t1 = and i32 %T200.tmp2, -256, !tcg.op !205
  %T200.tr = trunc i32 %T200.tmp0 to i8, !tcg.op !205
  %T200.zext = zext i8 %T200.tr to i32, !tcg.op !205
  %T200.t2 = shl i32 %T200.zext, 0, !tcg.op !205
  %T200.out = or i32 %T200.t1, %T200.t2, !tcg.op !205
  store i32 %T200.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !205
; ======== TCG [201] deposit_i32 [t2],t2,t0,0x10,0x8 ========
  %T201.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !206
  %T201.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !206
  %T201.t1 = and i32 %T201.tmp2, -16711681, !tcg.op !206
  %T201.tr = trunc i32 %T201.tmp0 to i8, !tcg.op !206
  %T201.zext = zext i8 %T201.tr to i32, !tcg.op !206
  %T201.t2 = shl i32 %T201.zext, 16, !tcg.op !206
  %T201.out = or i32 %T201.t1, %T201.t2, !tcg.op !206
  store i32 %T201.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !206
; ======== TCG [202] deposit_i32 [t2],t2,t0,0x18,0x8 ========
  %T202.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !207
  %T202.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !207
  %T202.t1 = and i32 %T202.tmp2, 16777215, !tcg.op !207
  %T202.tr = trunc i32 %T202.tmp0 to i8, !tcg.op !207
  %T202.zext = zext i8 %T202.tr to i32, !tcg.op !207
  %T202.t2 = shl i32 %T202.zext, 24, !tcg.op !207
  %T202.out = or i32 %T202.t1, %T202.t2, !tcg.op !207
  store i32 %T202.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !207
; ======== TCG [203] deposit_i32 [t2],t2,t0,0x18,0x18 ========
  %T203.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !208
  %T203.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !208
  %T203.t1 = and i32 %T203.tmp2, 16777215, !tcg.op !208
  %T203.tr = trunc i32 %T203.tmp0 to i24, !tcg.op !208
  %T203.zext = zext i24 %T203.tr to i32, !tcg.op !208
  %T203.t2 = shl i32 %T203.zext, 24, !tcg.op !208
  %T203.out = or i32 %T203.t1, %T203.t2, !tcg.op !208
  store i32 %T203.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !208
; ======== TCG [204] deposit_i64 [rax],rax,t2,0x0,0x8 ========
  %T204.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !209
  %T204.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !209
  %T204.t1 = and i64 %T204.rax, -256, !tcg.op !209
  %T204.tr = trunc i64 %T204.tmp2 to i8, !tcg.op !209
  %T204.zext = zext i8 %T204.tr to i64, !tcg.op !209
  %T204.t2 = shl i64 %T204.zext, 0, !tcg.op !209
  %T204.out = or i64 %T204.t1, %T204.t2, !tcg.op !209
  store i64 %T204.out, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !209
; ======== TCG [205] deposit_i64 [rax],rax,t2,0x0,0x0 ========
  %T205.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !210
  %T205.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !210
  store i64 %T205.rax, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !210
; ======== TCG [206] deposit_i64 [rax],rax,t2,0x10,0x0 ========
  %T206.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !211
  %T206.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !211
  store i64 %T206.rax, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !211
; ======== TCG [207] dupm_vec v128,e8,[t9],v0 ========
  %T207.v0 = load <16 x i8>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !212
  %T207.elem = extractelement <16 x i8> %T207.v0, i64 0, !tcg.op !212
  %T207.ie = insertelement <16 x i8> zeroinitializer, i8 %T207.elem, i64 0, !tcg.op !212
  %T207.ie348 = insertelement <16 x i8> %T207.ie, i8 %T207.elem, i64 1, !tcg.op !212
  %T207.ie349 = insertelement <16 x i8> %T207.ie348, i8 %T207.elem, i64 2, !tcg.op !212
  %T207.ie350 = insertelement <16 x i8> %T207.ie349, i8 %T207.elem, i64 3, !tcg.op !212
  %T207.ie351 = insertelement <16 x i8> %T207.ie350, i8 %T207.elem, i64 4, !tcg.op !212
  %T207.ie352 = insertelement <16 x i8> %T207.ie351, i8 %T207.elem, i64 5, !tcg.op !212
  %T207.ie353 = insertelement <16 x i8> %T207.ie352, i8 %T207.elem, i64 6, !tcg.op !212
  %T207.ie354 = insertelement <16 x i8> %T207.ie353, i8 %T207.elem, i64 7, !tcg.op !212
  %T207.ie355 = insertelement <16 x i8> %T207.ie354, i8 %T207.elem, i64 8, !tcg.op !212
  %T207.ie356 = insertelement <16 x i8> %T207.ie355, i8 %T207.elem, i64 9, !tcg.op !212
  %T207.ie357 = insertelement <16 x i8> %T207.ie356, i8 %T207.elem, i64 10, !tcg.op !212
  %T207.ie358 = insertelement <16 x i8> %T207.ie357, i8 %T207.elem, i64 11, !tcg.op !212
  %T207.ie359 = insertelement <16 x i8> %T207.ie358, i8 %T207.elem, i64 12, !tcg.op !212
  %T207.ie360 = insertelement <16 x i8> %T207.ie359, i8 %T207.elem, i64 13, !tcg.op !212
  %T207.ie361 = insertelement <16 x i8> %T207.ie360, i8 %T207.elem, i64 14, !tcg.op !212
  %T207.ie362 = insertelement <16 x i8> %T207.ie361, i8 %T207.elem, i64 15, !tcg.op !212
  store <16 x i8> %T207.ie362, ptr %tmp9.stack, align 16, !tbaa !0, !tcg.op !212
; ======== TCG [208] dupm_vec v128,e64,[t9],v0 ========
  %T208.v0 = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !213
  %T208.elem = extractelement <2 x i64> %T208.v0, i64 0, !tcg.op !213
  %T208.ie = insertelement <2 x i64> zeroinitializer, i64 %T208.elem, i64 0, !tcg.op !213
  %T208.ie363 = insertelement <2 x i64> %T208.ie, i64 %T208.elem, i64 1, !tcg.op !213
  store <2 x i64> %T208.ie363, ptr %tmp9.stack, align 16, !tbaa !0, !tcg.op !213
; ======== TCG [209] extract2_i32 [t2],t0,t2,0x8 ========
  %T209.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !214
  %T209.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !214
  %T209.lshr = lshr i32 %T209.tmp0, 8, !tcg.op !214
  %T209.t1 = and i32 %T209.lshr, 16777215, !tcg.op !214
  %T209.tr = trunc i32 %T209.tmp2 to i8, !tcg.op !214
  %T209.zext = zext i8 %T209.tr to i32, !tcg.op !214
  %T209.t2 = shl i32 %T209.zext, 24, !tcg.op !214
  %T209.out = or i32 %T209.t1, %T209.t2, !tcg.op !214
  store i32 %T209.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !214
; ======== TCG [210] extract2_i64 [t2],t0,t2,0x38 ========
  %T210.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !215
  %T210.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !215
  %T210.lshr = lshr i64 %T210.tmp0, 56, !tcg.op !215
  %T210.t1 = and i64 %T210.lshr, 255, !tcg.op !215
  %T210.tr = trunc i64 %T210.tmp2 to i56, !tcg.op !215
  %T210.zext = zext i56 %T210.tr to i64, !tcg.op !215
  %T210.t2 = shl i64 %T210.zext, 8, !tcg.op !215
  %T210.out = or i64 %T210.t1, %T210.t2, !tcg.op !215
  store i64 %T210.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !215
; ======== TCG [211] extract_i32 [t2],t0,0x8,0x4 ========
  %T211.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !216
  %T211.shl = shl i32 %T211.tmp0, 20, !tcg.op !216
  %T211.out = lshr i32 %T211.shl, 28, !tcg.op !216
  store i32 %T211.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !216
; ======== TCG [212] extract_i64 [t2],t0,0x0,0x10 ========
  %T212.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !217
  %T212.shl = shl i64 %T212.tmp0, 48, !tcg.op !217
  %T212.out = lshr i64 %T212.shl, 48, !tcg.op !217
  store i64 %T212.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !217
; ======== TCG [213] sextract_i32 [t2],t0,0x8,0x4 ========
  %T213.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !218
  %T213.shl = shl i32 %T213.tmp0, 20, !tcg.op !218
  %T213.out = ashr i32 %T213.shl, 28, !tcg.op !218
  store i32 %T213.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !218
; ======== TCG [214] sextract_i64 [t2],t0,0x0,0x20 ========
  %T214.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !219
  %T214.shl = shl i64 %T214.tmp0, 32, !tcg.op !219
  %T214.out = ashr i64 %T214.shl, 32, !tcg.op !219
  store i64 %T214.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !219
; ======== TCG [215] extrh_i64_i32 [t2],t0 ========
  %T215.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !220
  %T215.lshr = lshr i64 %T215.tmp0, 32, !tcg.op !220
  %T215.out = trunc i64 %T215.lshr to i32, !tcg.op !220
  store i32 %T215.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !220
; ======== TCG [216] ext_i32_i64 [t2],t0 ========
  %T216.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !221
  %T216.sext = sext i32 %T216.tmp0 to i64, !tcg.op !221
  store i64 %T216.sext, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !221
; ======== TCG [217] extu_i32_i64 [t2],t0 ========
  %T217.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !222
  %T217.sext = zext i32 %T217.tmp0 to i64, !tcg.op !222
  store i64 %T217.sext, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !222
; ======== TCG [218] movcond_i32 [t0],t2,0x0,0x1a,0x26,eq ========
  %T218.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !223
  %T218.bool = icmp eq i32 %T218.tmp2, 0, !tcg.op !223
  %T218.out = select i1 %T218.bool, i32 26, i32 38, !tcg.op !223
  store i32 %T218.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !223
; ======== TCG [219] movcond_i64 [t2],t0,0x0,cc_dst,t2,eq ========
  %T219.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !224
  %T219.bool = icmp eq i64 %T219.tmp0, 0, !tcg.op !224
  %T219.cc_dst = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !224
  %T219.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !224
  %T219.out = select i1 %T219.bool, i64 %T219.cc_dst, i64 %T219.tmp2, !tcg.op !224
  store i64 %T219.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !224
; ======== TCG [220] movcond_vec v128,e8,[t8],t3,t4,t3,t4,ne ========
  %T220.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !225
  %T220.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !225
  %T220.bool = icmp ne <16 x i8> %T220.tmp3, %T220.tmp4, !tcg.op !225
  %T220.tmp3364 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !225
  %T220.tmp4365 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !225
  %T220.out = select <16 x i1> %T220.bool, <16 x i8> %T220.tmp3364, <16 x i8> %T220.tmp4365, !tcg.op !225
  store <16 x i8> %T220.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !225
; ======== TCG [221] mulsh_i32 [t2],t0,t2 ========
  %T221.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !226
  %T221.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !226
  %T221.double_ty = sext i32 %T221.tmp0 to i64, !tcg.op !226
  %T221.double_ty366 = sext i32 %T221.tmp2 to i64, !tcg.op !226
  %T221.mul = mul i64 %T221.double_ty, %T221.double_ty366, !tcg.op !226
  %T221.lshr = lshr i64 %T221.mul, 32, !tcg.op !226
  %T221.tr = trunc i64 %T221.lshr to i32, !tcg.op !226
  store i32 %T221.tr, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !226
; ======== TCG [222] mulsh_i64 [t2],t0,t2 ========
  %T222.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !227
  %T222.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !227
  %T222.double_ty = sext i64 %T222.tmp0 to i128, !tcg.op !227
  %T222.double_ty367 = sext i64 %T222.tmp2 to i128, !tcg.op !227
  %T222.mul = mul i128 %T222.double_ty, %T222.double_ty367, !tcg.op !227
  %T222.lshr = lshr i128 %T222.mul, 64, !tcg.op !227
  %T222.tr = trunc i128 %T222.lshr to i64, !tcg.op !227
  store i64 %T222.tr, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !227
; ======== TCG [223] muluh_i32 [t2],t0,t2 ========
  %T223.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !228
  %T223.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !228
  %T223.double_ty = zext i32 %T223.tmp0 to i64, !tcg.op !228
  %T223.double_ty368 = zext i32 %T223.tmp2 to i64, !tcg.op !228
  %T223.mul = mul i64 %T223.double_ty, %T223.double_ty368, !tcg.op !228
  %T223.lshr = lshr i64 %T223.mul, 32, !tcg.op !228
  %T223.tr = trunc i64 %T223.lshr to i32, !tcg.op !228
  store i32 %T223.tr, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !228
; ======== TCG [224] muluh_i64 [t2],t0,t2 ========
  %T224.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !229
  %T224.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !229
  %T224.double_ty = zext i64 %T224.tmp0 to i128, !tcg.op !229
  %T224.double_ty369 = zext i64 %T224.tmp2 to i128, !tcg.op !229
  %T224.mul = mul i128 %T224.double_ty, %T224.double_ty369, !tcg.op !229
  %T224.lshr = lshr i128 %T224.mul, 64, !tcg.op !229
  %T224.tr = trunc i128 %T224.lshr to i64, !tcg.op !229
  store i64 %T224.tr, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !229
; ======== TCG [225] muls2_i32 [t2],[t0],t2,t2 ========
  %T225.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !230
  %T225.tmp2370 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !230
  %T225.double_ty = sext i32 %T225.tmp2 to i64, !tcg.op !230
  %T225.double_ty371 = sext i32 %T225.tmp2370 to i64, !tcg.op !230
  %T225.mul = mul i64 %T225.double_ty, %T225.double_ty371, !tcg.op !230
  %T225.lshr = lshr i64 %T225.mul, 32, !tcg.op !230
  %T225.tr = trunc i64 %T225.lshr to i32, !tcg.op !230
  store i32 %T225.tr, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !230
  %T225.tr372 = trunc i64 %T225.mul to i32, !tcg.op !230
  store i32 %T225.tr372, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !230
; ======== TCG [226] muls2_i64 [t2],[t0],t2,t2 ========
  %T226.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !231
  %T226.tmp2373 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !231
  %T226.double_ty = sext i64 %T226.tmp2 to i128, !tcg.op !231
  %T226.double_ty374 = sext i64 %T226.tmp2373 to i128, !tcg.op !231
  %T226.mul = mul i128 %T226.double_ty, %T226.double_ty374, !tcg.op !231
  %T226.lshr = lshr i128 %T226.mul, 64, !tcg.op !231
  %T226.tr = trunc i128 %T226.lshr to i64, !tcg.op !231
  store i64 %T226.tr, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !231
  %T226.tr375 = trunc i128 %T226.mul to i64, !tcg.op !231
  store i64 %T226.tr375, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !231
; ======== TCG [227] mulu2_i32 [t2],[t0],t2,t2 ========
  %T227.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !232
  %T227.tmp2376 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !232
  %T227.double_ty = zext i32 %T227.tmp2 to i64, !tcg.op !232
  %T227.double_ty377 = zext i32 %T227.tmp2376 to i64, !tcg.op !232
  %T227.mul = mul i64 %T227.double_ty, %T227.double_ty377, !tcg.op !232
  %T227.lshr = lshr i64 %T227.mul, 32, !tcg.op !232
  %T227.tr = trunc i64 %T227.lshr to i32, !tcg.op !232
  store i32 %T227.tr, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !232
  %T227.tr378 = trunc i64 %T227.mul to i32, !tcg.op !232
  store i32 %T227.tr378, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !232
; ======== TCG [228] mulu2_i64 [t2],[t0],t2,t2 ========
  %T228.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !233
  %T228.tmp2379 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !233
  %T228.double_ty = zext i64 %T228.tmp2 to i128, !tcg.op !233
  %T228.double_ty380 = zext i64 %T228.tmp2379 to i128, !tcg.op !233
  %T228.mul = mul i128 %T228.double_ty, %T228.double_ty380, !tcg.op !233
  %T228.lshr = lshr i128 %T228.mul, 64, !tcg.op !233
  %T228.tr = trunc i128 %T228.lshr to i64, !tcg.op !233
  store i64 %T228.tr, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !233
  %T228.tr381 = trunc i128 %T228.mul to i64, !tcg.op !233
  store i64 %T228.tr381, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !233
; ======== TCG [229] setcond_i32 [t2],cc_dst,0xffffffff,tsteq ========
  %T229.cc_dst = load i32, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !234
  %T229.and_a_b = and i32 %T229.cc_dst, -1, !tcg.op !234
  %T229.bool = icmp eq i32 %T229.and_a_b, 0, !tcg.op !234
  %T229.out = zext i1 %T229.bool to i32, !tcg.op !234
  store i32 %T229.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !234
; ======== TCG [230] setcond_i64 [t2],cc_dst,0xffffffff,tsteq ========
  %T230.cc_dst = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !235
  %T230.and_a_b = and i64 %T230.cc_dst, 4294967295, !tcg.op !235
  %T230.bool = icmp eq i64 %T230.and_a_b, 0, !tcg.op !235
  %T230.out = zext i1 %T230.bool to i64, !tcg.op !235
  store i64 %T230.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !235
; ======== TCG [231] negsetcond_i32 [t2],cc_dst,0xffffffff,tsteq ========
  %T231.cc_dst = load i32, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !236
  %T231.and_a_b = and i32 %T231.cc_dst, -1, !tcg.op !236
  %T231.bool = icmp eq i32 %T231.and_a_b, 0, !tcg.op !236
  %T231.out = sext i1 %T231.bool to i32, !tcg.op !236
  store i32 %T231.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !236
; ======== TCG [232] negsetcond_i64 [t2],cc_dst,0xffffffff,tsteq ========
  %T232.cc_dst = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !237
  %T232.and_a_b = and i64 %T232.cc_dst, 4294967295, !tcg.op !237
  %T232.bool = icmp eq i64 %T232.and_a_b, 0, !tcg.op !237
  %T232.out = sext i1 %T232.bool to i64, !tcg.op !237
  store i64 %T232.out, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !237
; ======== TCG [233] umax_vec v128,e8,[t8],t3,t4 ========
  %T233.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !238
  %T233.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !238
  %T233.out = call <16 x i8> @llvm.umax.v16i8.v16i8(<16 x i8> %T233.tmp3, <16 x i8> %T233.tmp4), !tcg.op !238
  store <16 x i8> %T233.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !238
; ======== TCG [234] umax_vec v128,e32,[t8],t3,t4 ========
  %T234.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !239
  %T234.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !239
  %T234.out = call <4 x i32> @llvm.umax.v4i32.v4i32(<4 x i32> %T234.tmp3, <4 x i32> %T234.tmp4), !tcg.op !239
  store <4 x i32> %T234.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !239
; ======== TCG [235] umin_vec v128,e8,[t8],t3,t4 ========
  %T235.tmp3 = load <16 x i8>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !240
  %T235.tmp4 = load <16 x i8>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !240
  %T235.out = call <16 x i8> @llvm.umin.v16i8.v16i8(<16 x i8> %T235.tmp3, <16 x i8> %T235.tmp4), !tcg.op !240
  store <16 x i8> %T235.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !240
; ======== TCG [236] umin_vec v128,e32,[t8],t3,t4 ========
  %T236.tmp3 = load <4 x i32>, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !241
  %T236.tmp4 = load <4 x i32>, ptr %tmp4.stack, align 16, !tbaa !0, !tcg.op !241
  %T236.out = call <4 x i32> @llvm.umin.v4i32.v4i32(<4 x i32> %T236.tmp3, <4 x i32> %T236.tmp4), !tcg.op !241
  store <4 x i32> %T236.out, ptr %tmp8.stack, align 16, !tbaa !0, !tcg.op !241
; ======== TCG [237] dup_vec v128,e8,[t9],rax ========
  %T237.ld_element = load i8, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !242
  %T237.ie = insertelement <16 x i8> zeroinitializer, i8 %T237.ld_element, i64 0, !tcg.op !242
  %T237.ie382 = insertelement <16 x i8> %T237.ie, i8 %T237.ld_element, i64 1, !tcg.op !242
  %T237.ie383 = insertelement <16 x i8> %T237.ie382, i8 %T237.ld_element, i64 2, !tcg.op !242
  %T237.ie384 = insertelement <16 x i8> %T237.ie383, i8 %T237.ld_element, i64 3, !tcg.op !242
  %T237.ie385 = insertelement <16 x i8> %T237.ie384, i8 %T237.ld_element, i64 4, !tcg.op !242
  %T237.ie386 = insertelement <16 x i8> %T237.ie385, i8 %T237.ld_element, i64 5, !tcg.op !242
  %T237.ie387 = insertelement <16 x i8> %T237.ie386, i8 %T237.ld_element, i64 6, !tcg.op !242
  %T237.ie388 = insertelement <16 x i8> %T237.ie387, i8 %T237.ld_element, i64 7, !tcg.op !242
  %T237.ie389 = insertelement <16 x i8> %T237.ie388, i8 %T237.ld_element, i64 8, !tcg.op !242
  %T237.ie390 = insertelement <16 x i8> %T237.ie389, i8 %T237.ld_element, i64 9, !tcg.op !242
  %T237.ie391 = insertelement <16 x i8> %T237.ie390, i8 %T237.ld_element, i64 10, !tcg.op !242
  %T237.ie392 = insertelement <16 x i8> %T237.ie391, i8 %T237.ld_element, i64 11, !tcg.op !242
  %T237.ie393 = insertelement <16 x i8> %T237.ie392, i8 %T237.ld_element, i64 12, !tcg.op !242
  %T237.ie394 = insertelement <16 x i8> %T237.ie393, i8 %T237.ld_element, i64 13, !tcg.op !242
  %T237.ie395 = insertelement <16 x i8> %T237.ie394, i8 %T237.ld_element, i64 14, !tcg.op !242
  %T237.ie396 = insertelement <16 x i8> %T237.ie395, i8 %T237.ld_element, i64 15, !tcg.op !242
  store <16 x i8> %T237.ie396, ptr %tmp9.stack, align 16, !tbaa !0, !tcg.op !242
; ======== TCG [238] dup_vec v128,e64,[t9],t2 ========
  %T238.ld_element = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !243
  %T238.ie = insertelement <2 x i64> zeroinitializer, i64 %T238.ld_element, i64 0, !tcg.op !243
  %T238.ie397 = insertelement <2 x i64> %T238.ie, i64 %T238.ld_element, i64 1, !tcg.op !243
  store <2 x i64> %T238.ie397, ptr %tmp9.stack, align 16, !tbaa !0, !tcg.op !243
; ======== TCG [239] brcond_i32 t1,0x0,eq,L0 ========
  %T239.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !244
  %T239.bool = icmp eq i32 %T239.tmp1, 0, !tcg.op !244
  br i1 %T239.bool, label %bb_L0, label %bb_false398, !tcg.op !244

bb_false398:                                      ; preds = %T109.merge
; ======== TCG [240] setcond_i32 [t18],t1,0xffffffffffffffff,eq ========
  %T240.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !245
  %T240.bool = icmp eq i32 %T240.tmp1, -1, !tcg.op !245
  %T240.out = zext i1 %T240.bool to i32, !tcg.op !245
  store i32 %T240.out, ptr %tmp18.stack, align 8, !tbaa !0, !tcg.op !245
; ======== TCG [241] setcond_i32 [t19],t0,0x80000000,eq ========
  %T241.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !246
  %T241.bool = icmp eq i32 %T241.tmp0, -2147483648, !tcg.op !246
  %T241.out = zext i1 %T241.bool to i32, !tcg.op !246
  store i32 %T241.out, ptr %tmp19.stack, align 8, !tbaa !0, !tcg.op !246
; ======== TCG [242] setcond_i32 [t20],t2,0x0,eq ========
  %T242.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !247
  %T242.bool = icmp eq i32 %T242.tmp2, 0, !tcg.op !247
  %T242.out = zext i1 %T242.bool to i32, !tcg.op !247
  store i32 %T242.out, ptr %tmp20.stack, align 8, !tbaa !0, !tcg.op !247
; ======== TCG [243] and_i32 [t19],t19,t20 ========
  %T243.tmp19 = load i32, ptr %tmp19.stack, align 8, !tbaa !0, !tcg.op !248
  %T243.tmp20 = load i32, ptr %tmp20.stack, align 8, !tbaa !0, !tcg.op !248
  %T243.out = and i32 %T243.tmp19, %T243.tmp20, !tcg.op !248
  store i32 %T243.out, ptr %tmp19.stack, align 8, !tbaa !0, !tcg.op !248
; ======== TCG [244] and_i32 [t18],t18,t19 ========
  %T244.tmp18 = load i32, ptr %tmp18.stack, align 8, !tbaa !0, !tcg.op !249
  %T244.tmp19 = load i32, ptr %tmp19.stack, align 8, !tbaa !0, !tcg.op !249
  %T244.out = and i32 %T244.tmp18, %T244.tmp19, !tcg.op !249
  store i32 %T244.out, ptr %tmp18.stack, align 8, !tbaa !0, !tcg.op !249
; ======== TCG [245] brcond_i32 t18,0x1,eq,L0 ========
  %T245.tmp18 = load i32, ptr %tmp18.stack, align 8, !tbaa !0, !tcg.op !250
  %T245.bool = icmp eq i32 %T245.tmp18, 1, !tcg.op !250
  br i1 %T245.bool, label %bb_L0, label %bb_false399, !tcg.op !250

bb_false399:                                      ; preds = %bb_false398
; ======== TCG [246] divs2_i32 [t2],[t0],t2,t0,t1,L0 ========
  %T246.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !251
  %T246.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !251
  %T246.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !251
  %T246.nh_double = sext i32 %T246.tmp0 to i64, !tcg.op !251
  %T246.num_hi = shl i64 %T246.nh_double, 32, !tcg.op !251
  %T246.nl_double = zext i32 %T246.tmp2 to i64, !tcg.op !251
  %T246.num = or i64 %T246.num_hi, %T246.nl_double, !tcg.op !251
  %T246.d_128 = sext i32 %T246.tmp1 to i64, !tcg.op !251
  %T246.q_128 = sdiv i64 %T246.num, %T246.d_128, !tcg.op !251
  %T246.r_128 = srem i64 %T246.num, %T246.d_128, !tcg.op !251
  %T246.q = trunc i64 %T246.q_128 to i32, !tcg.op !251
  %T246.r = trunc i64 %T246.r_128 to i32, !tcg.op !251
  %T246.q_back = sext i32 %T246.q to i64, !tcg.op !251
  %T246.q_fits = icmp eq i64 %T246.q_back, %T246.q_128, !tcg.op !251
  br i1 %T246.q_fits, label %divs2.done, label %bb_L0, !tcg.op !251

divs2.done:                                       ; preds = %bb_false399
  store i32 %T246.q, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !251
  store i32 %T246.r, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !251
; ======== TCG [247] brcond_i64 t1,0x0,eq,L0 ========
  %T247.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !252
  %T247.bool = icmp eq i64 %T247.tmp1, 0, !tcg.op !252
  br i1 %T247.bool, label %bb_L0, label %bb_false400, !tcg.op !252

bb_false400:                                      ; preds = %divs2.done
; ======== TCG [248] setcond_i64 [t21],t1,0xffffffffffffffff,eq ========
  %T248.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !253
  %T248.bool = icmp eq i64 %T248.tmp1, -1, !tcg.op !253
  %T248.out = zext i1 %T248.bool to i64, !tcg.op !253
  store i64 %T248.out, ptr %tmp21.stack, align 8, !tbaa !0, !tcg.op !253
; ======== TCG [249] setcond_i64 [t22],t0,0x8000000000000000,eq ========
  %T249.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !254
  %T249.bool = icmp eq i64 %T249.tmp0, -9223372036854775808, !tcg.op !254
  %T249.out = zext i1 %T249.bool to i64, !tcg.op !254
  store i64 %T249.out, ptr %tmp22.stack, align 8, !tbaa !0, !tcg.op !254
; ======== TCG [250] setcond_i64 [t23],t2,0x0,eq ========
  %T250.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !255
  %T250.bool = icmp eq i64 %T250.tmp2, 0, !tcg.op !255
  %T250.out = zext i1 %T250.bool to i64, !tcg.op !255
  store i64 %T250.out, ptr %tmp23.stack, align 8, !tbaa !0, !tcg.op !255
; ======== TCG [251] and_i64 [t22],t22,t23 ========
  %T251.tmp22 = load i64, ptr %tmp22.stack, align 8, !tbaa !0, !tcg.op !256
  %T251.tmp23 = load i64, ptr %tmp23.stack, align 8, !tbaa !0, !tcg.op !256
  %T251.out = and i64 %T251.tmp22, %T251.tmp23, !tcg.op !256
  store i64 %T251.out, ptr %tmp22.stack, align 8, !tbaa !0, !tcg.op !256
; ======== TCG [252] and_i64 [t21],t21,t22 ========
  %T252.tmp21 = load i64, ptr %tmp21.stack, align 8, !tbaa !0, !tcg.op !257
  %T252.tmp22 = load i64, ptr %tmp22.stack, align 8, !tbaa !0, !tcg.op !257
  %T252.out = and i64 %T252.tmp21, %T252.tmp22, !tcg.op !257
  store i64 %T252.out, ptr %tmp21.stack, align 8, !tbaa !0, !tcg.op !257
; ======== TCG [253] brcond_i64 t21,0x1,eq,L0 ========
  %T253.tmp21 = load i64, ptr %tmp21.stack, align 8, !tbaa !0, !tcg.op !258
  %T253.bool = icmp eq i64 %T253.tmp21, 1, !tcg.op !258
  br i1 %T253.bool, label %bb_L0, label %bb_false401, !tcg.op !258

bb_false401:                                      ; preds = %bb_false400
; ======== TCG [254] divs2_i64 [t2],[t0],t2,t0,t1,L0 ========
  %T254.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !259
  %T254.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !259
  %T254.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !259
  %T254.nh_double = sext i64 %T254.tmp0 to i128, !tcg.op !259
  %T254.num_hi = shl i128 %T254.nh_double, 64, !tcg.op !259
  %T254.nl_double = zext i64 %T254.tmp2 to i128, !tcg.op !259
  %T254.num = or i128 %T254.num_hi, %T254.nl_double, !tcg.op !259
  %T254.d_128 = sext i64 %T254.tmp1 to i128, !tcg.op !259
  %T254.q_128 = sdiv i128 %T254.num, %T254.d_128, !tcg.op !259
  %T254.r_128 = srem i128 %T254.num, %T254.d_128, !tcg.op !259
  %T254.q = trunc i128 %T254.q_128 to i64, !tcg.op !259
  %T254.r = trunc i128 %T254.r_128 to i64, !tcg.op !259
  %T254.q_back = sext i64 %T254.q to i128, !tcg.op !259
  %T254.q_fits = icmp eq i128 %T254.q_back, %T254.q_128, !tcg.op !259
  br i1 %T254.q_fits, label %divs2.done402, label %bb_L0, !tcg.op !259

divs2.done402:                                    ; preds = %bb_false401
  store i64 %T254.q, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !259
  store i64 %T254.r, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !259
; ======== TCG [255] brcond_i32 t1,0x0,eq,L0 ========
  %T255.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !260
  %T255.bool = icmp eq i32 %T255.tmp1, 0, !tcg.op !260
  br i1 %T255.bool, label %bb_L0, label %bb_false403, !tcg.op !260

bb_false403:                                      ; preds = %divs2.done402
; ======== TCG [256] divu2_i32 [t2],[t0],t2,t0,t1,L0 ========
  %T256.tmp2 = load i32, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !261
  %T256.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !261
  %T256.tmp1 = load i32, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !261
  %T256.nh_double = sext i32 %T256.tmp0 to i64, !tcg.op !261
  %T256.num_hi = shl i64 %T256.nh_double, 32, !tcg.op !261
  %T256.nl_double = zext i32 %T256.tmp2 to i64, !tcg.op !261
  %T256.num = or i64 %T256.num_hi, %T256.nl_double, !tcg.op !261
  %T256.d_128 = zext i32 %T256.tmp1 to i64, !tcg.op !261
  %T256.q_128 = udiv i64 %T256.num, %T256.d_128, !tcg.op !261
  %T256.r_128 = urem i64 %T256.num, %T256.d_128, !tcg.op !261
  %T256.q = trunc i64 %T256.q_128 to i32, !tcg.op !261
  %T256.r = trunc i64 %T256.r_128 to i32, !tcg.op !261
  %T256.q_back = zext i32 %T256.q to i64, !tcg.op !261
  %T256.q_fits = icmp eq i64 %T256.q_back, %T256.q_128, !tcg.op !261
  br i1 %T256.q_fits, label %divs2.done404, label %bb_L0, !tcg.op !261

divs2.done404:                                    ; preds = %bb_false403
  store i32 %T256.q, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !261
  store i32 %T256.r, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !261
; ======== TCG [257] brcond_i64 t1,0x0,eq,L0 ========
  %T257.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !262
  %T257.bool = icmp eq i64 %T257.tmp1, 0, !tcg.op !262
  br i1 %T257.bool, label %bb_L0, label %bb_false405, !tcg.op !262

bb_false405:                                      ; preds = %divs2.done404
; ======== TCG [258] divu2_i64 [t2],[t0],t2,t0,t1,L0 ========
  %T258.tmp2 = load i64, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !263
  %T258.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !263
  %T258.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !263
  %T258.nh_double = sext i64 %T258.tmp0 to i128, !tcg.op !263
  %T258.num_hi = shl i128 %T258.nh_double, 64, !tcg.op !263
  %T258.nl_double = zext i64 %T258.tmp2 to i128, !tcg.op !263
  %T258.num = or i128 %T258.num_hi, %T258.nl_double, !tcg.op !263
  %T258.d_128 = zext i64 %T258.tmp1 to i128, !tcg.op !263
  %T258.q_128 = udiv i128 %T258.num, %T258.d_128, !tcg.op !263
  %T258.r_128 = urem i128 %T258.num, %T258.d_128, !tcg.op !263
  %T258.q = trunc i128 %T258.q_128 to i64, !tcg.op !263
  %T258.r = trunc i128 %T258.r_128 to i64, !tcg.op !263
  %T258.q_back = zext i64 %T258.q to i128, !tcg.op !263
  %T258.q_fits = icmp eq i128 %T258.q_back, %T258.q_128, !tcg.op !263
  br i1 %T258.q_fits, label %divs2.done406, label %bb_L0, !tcg.op !263

divs2.done406:                                    ; preds = %bb_false405
  store i64 %T258.q, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !263
  store i64 %T258.r, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !263
; ======== TCG [259] discard rax ========
  store i64 poison, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !264
; ======== TCG [260] discard t2 ========
  store <2 x i64> poison, ptr %tmp2.stack, align 16, !tbaa !0, !tcg.op !265
; ======== TCG [261] func_addr t24,0x55aa,0x0 ========
  store ptr @Fx55aa, ptr %tmp24.stack, align 8, !tbaa !0, !tcg.op !266
; ======== TCG [262] tail_call_qemuaot t24 VEC_ARGS: ========
  %T262.rax.stack = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !267
  %T262.rcx.stack = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !267
  %T262.cc_dst.stack = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !267
  %T262.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !267
  %T262.v4.stack = load <2 x i64>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !267
  %T262.v20.stack = load <2 x i64>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !267
  %T262.v22.stack = load <2 x i64>, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !267
  %T262.v24.stack = load <2 x i64>, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !267
  %T262.loaded_fn = load ptr, ptr %tmp24.stack, align 8, !tcg.op !267
  tail call qemuaot void %T262.loaded_fn(i64 %T262.rax.stack, i64 %T262.rcx.stack, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %T262.cc_dst.stack, i32 %cc_op, i64 %rip, <2 x i64> %T262.v0.stack, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %T262.v4.stack, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %T262.v20.stack, <2 x i64> %ymm10_h, <2 x i64> %T262.v22.stack, <2 x i64> %ymm11_h, <2 x i64> %T262.v24.stack, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr %cpu), !tcg.op !267
  ret void, !tcg.op !267
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
declare i32 @llvm.fshl.i32.i32.i32(i32, i32, i32) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.fshl.i64.i64.i64(i64, i64, i64) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.fshl.v16i8.v16i8.v16i8(<16 x i8>, <16 x i8>, <16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <8 x i16> @llvm.fshl.v8i16.v8i16.v8i16(<8 x i16>, <8 x i16>, <8 x i16>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.fshl.v4i32.v4i32.v4i32(<4 x i32>, <4 x i32>, <4 x i32>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <2 x i64> @llvm.fshl.v2i64.v2i64.v2i64(<2 x i64>, <2 x i64>, <2 x i64>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.fshr.i32.i32.i32(i32, i32, i32) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i64 @llvm.fshr.i64.i64.i64(i64, i64, i64) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.fshr.v4i32.v4i32.v4i32(<4 x i32>, <4 x i32>, <4 x i32>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.umax.v16i8.v16i8(<16 x i8>, <16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.umax.v4i32.v4i32(<4 x i32>, <4 x i32>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.umin.v16i8.v16i8(<16 x i8>, <16 x i8>) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.umin.v4i32.v4i32(<4 x i32>, <4 x i32>) #1

; Function Attrs: nounwind
declare qemuaot void @Fx55aa(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, ptr align 8 dereferenceable(26528)) #2 section ".text.Fx55aa"

; Function Attrs: noinline nounwind
define qemuaot void @trampoline_helper_raise_exception(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26528) %cpu, i64 %arg0, i64 %arg1) #0 section ".text.trampoline_helper_raise_exception" {
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
  %tmp16.stack = alloca i64, align 8
  %tmp17.stack = alloca i64, align 8
  %tmp18.stack = alloca i32, align 8
  %tmp19.stack = alloca i32, align 8
  %tmp20.stack = alloca i32, align 8
  %tmp21.stack = alloca i64, align 8
  %tmp22.stack = alloca i64, align 8
  %tmp23.stack = alloca i64, align 8
  %carry.stack = alloca i1, align 8
  %borrow.stack = alloca i1, align 8
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] st_i64 rax,env ========
  %T0.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !268
  %T0.envptr = getelementptr i8, ptr %env, i64 0, !tcg.op !268
  store i64 %T0.rax, ptr %T0.envptr, align 16, !tbaa !269, !tcg.op !268
; ======== TCG [1] st_i64 rcx,env:0x8 ========
  %T1.rcx = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !271
  %T1.envptr = getelementptr i8, ptr %env, i64 8, !tcg.op !271
  store i64 %T1.rcx, ptr %T1.envptr, align 8, !tbaa !269, !tcg.op !271
; ======== TCG [2] st_i64 rdx,env:0x10 ========
  %T2.envptr = getelementptr i8, ptr %env, i64 16, !tcg.op !272
  store i64 %rdx, ptr %T2.envptr, align 16, !tbaa !269, !tcg.op !272
; ======== TCG [3] st_i64 rbx,env:0x18 ========
  %T3.envptr = getelementptr i8, ptr %env, i64 24, !tcg.op !273
  store i64 %rbx, ptr %T3.envptr, align 8, !tbaa !269, !tcg.op !273
; ======== TCG [4] st_i64 rsp,env:0x20 ========
  %T4.envptr = getelementptr i8, ptr %env, i64 32, !tcg.op !274
  store i64 %rsp, ptr %T4.envptr, align 16, !tbaa !269, !tcg.op !274
; ======== TCG [5] st_i64 rbp,env:0x28 ========
  %T5.envptr = getelementptr i8, ptr %env, i64 40, !tcg.op !275
  store i64 %rbp, ptr %T5.envptr, align 8, !tbaa !269, !tcg.op !275
; ======== TCG [6] st_i64 rsi,env:0x30 ========
  %T6.envptr = getelementptr i8, ptr %env, i64 48, !tcg.op !276
  store i64 %rsi, ptr %T6.envptr, align 16, !tbaa !269, !tcg.op !276
; ======== TCG [7] st_i64 rdi,env:0x38 ========
  %T7.envptr = getelementptr i8, ptr %env, i64 56, !tcg.op !277
  store i64 %rdi, ptr %T7.envptr, align 8, !tbaa !269, !tcg.op !277
; ======== TCG [8] st_i64 r8,env:0x40 ========
  %T8.envptr = getelementptr i8, ptr %env, i64 64, !tcg.op !278
  store i64 %r8, ptr %T8.envptr, align 16, !tbaa !269, !tcg.op !278
; ======== TCG [9] st_i64 r9,env:0x48 ========
  %T9.envptr = getelementptr i8, ptr %env, i64 72, !tcg.op !279
  store i64 %r9, ptr %T9.envptr, align 8, !tbaa !269, !tcg.op !279
; ======== TCG [10] st_i64 r10,env:0x50 ========
  %T10.envptr = getelementptr i8, ptr %env, i64 80, !tcg.op !280
  store i64 %r10, ptr %T10.envptr, align 16, !tbaa !269, !tcg.op !280
; ======== TCG [11] st_i64 r11,env:0x58 ========
  %T11.envptr = getelementptr i8, ptr %env, i64 88, !tcg.op !281
  store i64 %r11, ptr %T11.envptr, align 8, !tbaa !269, !tcg.op !281
; ======== TCG [12] st_i64 r12,env:0x60 ========
  %T12.envptr = getelementptr i8, ptr %env, i64 96, !tcg.op !282
  store i64 %r12, ptr %T12.envptr, align 16, !tbaa !269, !tcg.op !282
; ======== TCG [13] st_i64 r13,env:0x68 ========
  %T13.envptr = getelementptr i8, ptr %env, i64 104, !tcg.op !283
  store i64 %r13, ptr %T13.envptr, align 8, !tbaa !269, !tcg.op !283
; ======== TCG [14] st_i64 r14,env:0x70 ========
  %T14.envptr = getelementptr i8, ptr %env, i64 112, !tcg.op !284
  store i64 %r14, ptr %T14.envptr, align 16, !tbaa !269, !tcg.op !284
; ======== TCG [15] st_i64 r15,env:0x78 ========
  %T15.envptr = getelementptr i8, ptr %env, i64 120, !tcg.op !285
  store i64 %r15, ptr %T15.envptr, align 8, !tbaa !269, !tcg.op !285
; ======== TCG [16] st_i64 cc_src,env:0x98 ========
  %T16.envptr = getelementptr i8, ptr %env, i64 152, !tcg.op !286
  store i64 %cc_src, ptr %T16.envptr, align 8, !tbaa !269, !tcg.op !286
; ======== TCG [17] st_i64 cc_dst,env:0x90 ========
  %T17.cc_dst = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !287
  %T17.envptr = getelementptr i8, ptr %env, i64 144, !tcg.op !287
  store i64 %T17.cc_dst, ptr %T17.envptr, align 16, !tbaa !269, !tcg.op !287
; ======== TCG [18] st_i32 cc_op,env:0xa8 ========
  %T18.envptr = getelementptr i8, ptr %env, i64 168, !tcg.op !288
  store i32 %cc_op, ptr %T18.envptr, align 8, !tbaa !269, !tcg.op !288
; ======== TCG [19] st_i64 rip,env:0x80 ========
  %T19.envptr = getelementptr i8, ptr %env, i64 128, !tcg.op !289
  store i64 %rip, ptr %T19.envptr, align 16, !tbaa !269, !tcg.op !289
; ======== TCG [20] st_vec v128,e8,v0,env:0x360 ========
  %T20.v0 = load <16 x i8>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !290
  %T20.envptr = getelementptr i8, ptr %env, i64 864, !tcg.op !290
  store <16 x i8> %T20.v0, ptr %T20.envptr, align 16, !tbaa !269, !tcg.op !290
; ======== TCG [21] st_vec v128,e8,v1,env:0x370 ========
  %T21.envptr = getelementptr i8, ptr %env, i64 880, !tcg.op !291
  store <2 x i64> %ymm0_h, ptr %T21.envptr, align 16, !tbaa !269, !tcg.op !291
; ======== TCG [22] st_vec v128,e8,v2,env:0x3a0 ========
  %T22.envptr = getelementptr i8, ptr %env, i64 928, !tcg.op !292
  store <2 x i64> %xmm1, ptr %T22.envptr, align 16, !tbaa !269, !tcg.op !292
; ======== TCG [23] st_vec v128,e8,v3,env:0x3b0 ========
  %T23.envptr = getelementptr i8, ptr %env, i64 944, !tcg.op !293
  store <2 x i64> %ymm1_h, ptr %T23.envptr, align 16, !tbaa !269, !tcg.op !293
; ======== TCG [24] st_vec v128,e8,v4,env:0x3e0 ========
  %T24.v4 = load <16 x i8>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !294
  %T24.envptr = getelementptr i8, ptr %env, i64 992, !tcg.op !294
  store <16 x i8> %T24.v4, ptr %T24.envptr, align 16, !tbaa !269, !tcg.op !294
; ======== TCG [25] st_vec v128,e8,v5,env:0x3f0 ========
  %T25.envptr = getelementptr i8, ptr %env, i64 1008, !tcg.op !295
  store <2 x i64> %ymm2_h, ptr %T25.envptr, align 16, !tbaa !269, !tcg.op !295
; ======== TCG [26] st_vec v128,e8,v6,env:0x420 ========
  %T26.envptr = getelementptr i8, ptr %env, i64 1056, !tcg.op !296
  store <2 x i64> %xmm3, ptr %T26.envptr, align 16, !tbaa !269, !tcg.op !296
; ======== TCG [27] st_vec v128,e8,v7,env:0x430 ========
  %T27.envptr = getelementptr i8, ptr %env, i64 1072, !tcg.op !297
  store <2 x i64> %ymm3_h, ptr %T27.envptr, align 16, !tbaa !269, !tcg.op !297
; ======== TCG [28] st_vec v128,e8,v8,env:0x460 ========
  %T28.envptr = getelementptr i8, ptr %env, i64 1120, !tcg.op !298
  store <2 x i64> %xmm4, ptr %T28.envptr, align 16, !tbaa !269, !tcg.op !298
; ======== TCG [29] st_vec v128,e8,v9,env:0x470 ========
  %T29.envptr = getelementptr i8, ptr %env, i64 1136, !tcg.op !299
  store <2 x i64> %ymm4_h, ptr %T29.envptr, align 16, !tbaa !269, !tcg.op !299
; ======== TCG [30] st_vec v128,e8,v10,env:0x4a0 ========
  %T30.envptr = getelementptr i8, ptr %env, i64 1184, !tcg.op !300
  store <2 x i64> %xmm5, ptr %T30.envptr, align 16, !tbaa !269, !tcg.op !300
; ======== TCG [31] st_vec v128,e8,v11,env:0x4b0 ========
  %T31.envptr = getelementptr i8, ptr %env, i64 1200, !tcg.op !301
  store <2 x i64> %ymm5_h, ptr %T31.envptr, align 16, !tbaa !269, !tcg.op !301
; ======== TCG [32] st_vec v128,e8,v12,env:0x4e0 ========
  %T32.envptr = getelementptr i8, ptr %env, i64 1248, !tcg.op !302
  store <2 x i64> %xmm6, ptr %T32.envptr, align 16, !tbaa !269, !tcg.op !302
; ======== TCG [33] st_vec v128,e8,v13,env:0x4f0 ========
  %T33.envptr = getelementptr i8, ptr %env, i64 1264, !tcg.op !303
  store <2 x i64> %ymm6_h, ptr %T33.envptr, align 16, !tbaa !269, !tcg.op !303
; ======== TCG [34] st_vec v128,e8,v14,env:0x520 ========
  %T34.envptr = getelementptr i8, ptr %env, i64 1312, !tcg.op !304
  store <2 x i64> %xmm7, ptr %T34.envptr, align 16, !tbaa !269, !tcg.op !304
; ======== TCG [35] st_vec v128,e8,v15,env:0x530 ========
  %T35.envptr = getelementptr i8, ptr %env, i64 1328, !tcg.op !305
  store <2 x i64> %ymm7_h, ptr %T35.envptr, align 16, !tbaa !269, !tcg.op !305
; ======== TCG [36] st_vec v128,e8,v16,env:0x560 ========
  %T36.envptr = getelementptr i8, ptr %env, i64 1376, !tcg.op !306
  store <2 x i64> %xmm8, ptr %T36.envptr, align 16, !tbaa !269, !tcg.op !306
; ======== TCG [37] st_vec v128,e8,v17,env:0x570 ========
  %T37.envptr = getelementptr i8, ptr %env, i64 1392, !tcg.op !307
  store <2 x i64> %ymm8_h, ptr %T37.envptr, align 16, !tbaa !269, !tcg.op !307
; ======== TCG [38] st_vec v128,e8,v18,env:0x5a0 ========
  %T38.envptr = getelementptr i8, ptr %env, i64 1440, !tcg.op !308
  store <2 x i64> %xmm9, ptr %T38.envptr, align 16, !tbaa !269, !tcg.op !308
; ======== TCG [39] st_vec v128,e8,v19,env:0x5b0 ========
  %T39.envptr = getelementptr i8, ptr %env, i64 1456, !tcg.op !309
  store <2 x i64> %ymm9_h, ptr %T39.envptr, align 16, !tbaa !269, !tcg.op !309
; ======== TCG [40] st_vec v128,e8,v20,env:0x5e0 ========
  %T40.v20 = load <16 x i8>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !310
  %T40.envptr = getelementptr i8, ptr %env, i64 1504, !tcg.op !310
  store <16 x i8> %T40.v20, ptr %T40.envptr, align 16, !tbaa !269, !tcg.op !310
; ======== TCG [41] st_vec v128,e8,v21,env:0x5f0 ========
  %T41.envptr = getelementptr i8, ptr %env, i64 1520, !tcg.op !311
  store <2 x i64> %ymm10_h, ptr %T41.envptr, align 16, !tbaa !269, !tcg.op !311
; ======== TCG [42] st_vec v128,e8,v22,env:0x620 ========
  %T42.v22 = load <16 x i8>, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !312
  %T42.envptr = getelementptr i8, ptr %env, i64 1568, !tcg.op !312
  store <16 x i8> %T42.v22, ptr %T42.envptr, align 16, !tbaa !269, !tcg.op !312
; ======== TCG [43] st_vec v128,e8,v23,env:0x630 ========
  %T43.envptr = getelementptr i8, ptr %env, i64 1584, !tcg.op !313
  store <2 x i64> %ymm11_h, ptr %T43.envptr, align 16, !tbaa !269, !tcg.op !313
; ======== TCG [44] st_vec v128,e8,v24,env:0x660 ========
  %T44.v24 = load <16 x i8>, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !314
  %T44.envptr = getelementptr i8, ptr %env, i64 1632, !tcg.op !314
  store <16 x i8> %T44.v24, ptr %T44.envptr, align 16, !tbaa !269, !tcg.op !314
; ======== TCG [45] st_vec v128,e8,v25,env:0x670 ========
  %T45.envptr = getelementptr i8, ptr %env, i64 1648, !tcg.op !315
  store <2 x i64> %ymm12_h, ptr %T45.envptr, align 16, !tbaa !269, !tcg.op !315
; ======== TCG [46] st_vec v128,e8,v26,env:0x6a0 ========
  %T46.envptr = getelementptr i8, ptr %env, i64 1696, !tcg.op !316
  store <2 x i64> %xmm13, ptr %T46.envptr, align 16, !tbaa !269, !tcg.op !316
; ======== TCG [47] st_vec v128,e8,v27,env:0x6b0 ========
  %T47.envptr = getelementptr i8, ptr %env, i64 1712, !tcg.op !317
  store <2 x i64> %ymm13_h, ptr %T47.envptr, align 16, !tbaa !269, !tcg.op !317
; ======== TCG [48] tail_call_default helper_raise_exception,arg0,arg1 ========
  %T48.env = ptrtoint ptr %env to i64, !tcg.op !318
  tail call void asm sideeffect "mov x25, $0\0A\09mov x0, $1\0A\09mov x1, $2\0A\09b helper_raise_exception", "r,r,r,~{x0},~{x1},~{x2},~{x3},~{x4},~{x5},~{x6},~{x7},~{x8},~{x9},~{x10},~{x11},~{x12},~{x13},~{x14},~{x15},~{x16},~{x17},~{x18},~{x29},~{x30},~{v0},~{v1},~{v2},~{v3},~{v4},~{v5},~{v6},~{v7},~{v8},~{v9},~{v10},~{v11},~{v12},~{v13},~{v14},~{v15},~{v16},~{v17},~{v18},~{v19},~{v20},~{v21},~{v22},~{v23},~{v24},~{v25},~{v26},~{v27},~{v28},~{v29},~{v30},~{v31},~{cc},~{memory}"(i64 %T48.env, i64 %arg0, i64 %arg1), !tcg.op !318
  ret void, !tcg.op !318
}

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
!54 = !{!"[264] func_addr t25,0x0,0x1"}
!55 = !{!"[265] tail_call_qemuaot t25,env,0x0 VEC_ARGS:"}
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
!67 = !{!"[62] brcond_i32 t1,0x0,eq,L0"}
!68 = !{!"[63] setcond_i32 [t14],t1,0xffffffffffffffff,eq"}
!69 = !{!"[64] setcond_i32 [t15],t0,0x80000000,eq"}
!70 = !{!"[65] and_i32 [t14],t14,t15"}
!71 = !{!"[66] brcond_i32 t14,0x1,eq,L0"}
!72 = !{!"[67] rems_i32 [t2],t0,t1"}
!73 = !{!"[68] brcond_i64 t1,0x0,eq,L0"}
!74 = !{!"[69] setcond_i64 [t16],t1,0xffffffffffffffff,eq"}
!75 = !{!"[70] setcond_i64 [t17],t0,0x8000000000000000,eq"}
!76 = !{!"[71] and_i64 [t16],t16,t17"}
!77 = !{!"[72] brcond_i64 t16,0x1,eq,L0"}
!78 = !{!"[73] rems_i64 [t2],t0,t1"}
!79 = !{!"[74] brcond_i32 t1,0x0,eq,L0"}
!80 = !{!"[75] remu_i32 [t2],t0,t1"}
!81 = !{!"[76] brcond_i64 t1,0x0,eq,L0"}
!82 = !{!"[77] remu_i64 [t2],t0,t1"}
!83 = !{!"[78] sar_i32 [t2],t0,t1"}
!84 = !{!"[79] sar_i64 [t2],t0,t1"}
!85 = !{!"[80] and_i32 [t2],t0,t1"}
!86 = !{!"[81] and_i64 [t2],t0,t1"}
!87 = !{!"[82] mul_i32 [t2],t0,t1"}
!88 = !{!"[83] mul_i64 [t2],t0,t1"}
!89 = !{!"[84] or_i32 [t2],t0,t1"}
!90 = !{!"[85] or_i64 [t2],t0,t1"}
!91 = !{!"[86] shl_i32 [t2],t0,t1"}
!92 = !{!"[87] shl_i64 [t2],t0,t1"}
!93 = !{!"[88] shr_i32 [t2],t0,t1"}
!94 = !{!"[89] shr_i64 [t2],t0,t1"}
!95 = !{!"[90] xor_i32 [t2],t0,t1"}
!96 = !{!"[91] xor_i64 [t2],t0,t1"}
!97 = !{!"[92] sarv_vec v128,e8,[t8],t3,t4"}
!98 = !{!"[93] sarv_vec v128,e32,[t8],t3,t4"}
!99 = !{!"[94] shlv_vec v128,e8,[t8],t3,t4"}
!100 = !{!"[95] shlv_vec v128,e32,[t8],t3,t4"}
!101 = !{!"[96] shrv_vec v128,e8,[t8],t3,t4"}
!102 = !{!"[97] shrv_vec v128,e32,[t8],t3,t4"}
!103 = !{!"[98] and_vec v128,e8,[t8],t3,t4"}
!104 = !{!"[99] and_vec v128,e32,[t8],t3,t4"}
!105 = !{!"[100] mul_vec v128,e8,[t8],t3,t4"}
!106 = !{!"[101] mul_vec v128,e32,[t8],t3,t4"}
!107 = !{!"[102] or_vec v128,e8,[t8],t3,t4"}
!108 = !{!"[103] or_vec v128,e32,[t8],t3,t4"}
!109 = !{!"[104] xor_vec v128,e8,[t8],t3,t4"}
!110 = !{!"[105] xor_vec v128,e32,[t8],t3,t4"}
!111 = !{!"[106] clz_i32 [t2],t2,t0"}
!112 = !{!"[107] clz_i64 [t2],t2,t0"}
!113 = !{!"[108] ctz_i32 [t2],t2,t0"}
!114 = !{!"[109] ctz_i64 [t2],t2,t0"}
!115 = !{!"[110] smax_vec v128,e8,[t8],t3,t4"}
!116 = !{!"[111] smax_vec v128,e32,[t8],t3,t4"}
!117 = !{!"[112] smin_vec v128,e8,[t8],t3,t4"}
!118 = !{!"[113] smin_vec v128,e32,[t8],t3,t4"}
!119 = !{!"[114] ssadd_vec v128,e8,[t8],t3,t4"}
!120 = !{!"[115] ssadd_vec v128,e32,[t8],t3,t4"}
!121 = !{!"[116] sssub_vec v128,e8,[t8],t3,t4"}
!122 = !{!"[117] sssub_vec v128,e32,[t8],t3,t4"}
!123 = !{!"[118] usadd_vec v128,e8,[t8],t3,t4"}
!124 = !{!"[119] usadd_vec v128,e32,[t8],t3,t4"}
!125 = !{!"[120] ussub_vec v128,e8,[t8],t3,t4"}
!126 = !{!"[121] ussub_vec v128,e32,[t8],t3,t4"}
!127 = !{!"[122] rotl_i32 [t2],t2,t0"}
!128 = !{!"[123] rotl_i64 [t2],t2,t0"}
!129 = !{!"[124] rotl_i32 [t2],t2,0x4"}
!130 = !{!"[125] rotl_i64 [t2],t2,0x100"}
!131 = !{!"[126] rotli_vec v128,e8,[t8],t3,0x2"}
!132 = !{!"[127] rotli_vec v128,e8,[t8],t3,0x8"}
!133 = !{!"[128] rotli_vec v128,e8,[t8],t3,0x9"}
!134 = !{!"[129] rotli_vec v128,e16,[t8],t3,0x12"}
!135 = !{!"[130] rotli_vec v128,e32,[t8],t3,0x21"}
!136 = !{!"[131] rotli_vec v128,e64,[t8],t3,0x42"}
!137 = !{!"[132] rotls_vec v128,e32,[t8],t3,t2"}
!138 = !{!"[133] rotlv_vec v128,e32,[t8],t3,t4"}
!139 = !{!"[134] rotr_i32 [t2],t2,t0"}
!140 = !{!"[135] rotr_i64 [t2],t2,t0"}
!141 = !{!"[136] rotr_i32 [t2],t2,0x4"}
!142 = !{!"[137] rotr_i64 [t2],t2,0x100"}
!143 = !{!"[138] rotrv_vec v128,e32,[t8],t3,t4"}
!144 = !{!"[139] shli_vec v128,e8,[t8],t3,0x2"}
!145 = !{!"[140] shli_vec v128,e8,[t8],t3,0x9"}
!146 = !{!"[141] shli_vec v128,e16,[t8],t3,0x11"}
!147 = !{!"[142] shli_vec v128,e32,[t8],t3,0x21"}
!148 = !{!"[143] shli_vec v128,e64,[t8],t3,0x42"}
!149 = !{!"[144] shls_vec v128,e32,[t8],t3,t2"}
!150 = !{!"[145] shri_vec v128,e32,[t8],t3,0x2"}
!151 = !{!"[146] shrs_vec v128,e32,[t8],t3,t2"}
!152 = !{!"[147] sari_vec v128,e32,[t8],t3,0x2"}
!153 = !{!"[148] sars_vec v128,e32,[t8],t3,t2"}
!154 = !{!"[149] andc_i32 [t2],t2,t0"}
!155 = !{!"[150] andc_i64 [t2],t2,t0"}
!156 = !{!"[151] andc_vec v128,e32,[t8],t3,t4"}
!157 = !{!"[152] nor_i32 [t2],t2,t0"}
!158 = !{!"[153] nor_i64 [t2],t2,t0"}
!159 = !{!"[154] nor_vec v128,e32,[t8],t3,t4"}
!160 = !{!"[155] orc_i32 [t2],t2,t0"}
!161 = !{!"[156] orc_i64 [t2],t2,t0"}
!162 = !{!"[157] orc_vec v128,e32,[t8],t3,t4"}
!163 = !{!"[158] nand_i32 [t2],t2,t0"}
!164 = !{!"[159] nand_i64 [t2],t2,t0"}
!165 = !{!"[160] nand_vec v128,e32,[t8],t3,t4"}
!166 = !{!"[161] eqv_i32 [t2],t2,t0"}
!167 = !{!"[162] eqv_i64 [t2],t2,t0"}
!168 = !{!"[163] eqv_vec v128,e32,[t8],t3,t4"}
!169 = !{!"[164] neg_i32 [t2],t2"}
!170 = !{!"[165] neg_i64 [t2],t2"}
!171 = !{!"[166] neg_vec v128,e32,[t8],t3"}
!172 = !{!"[167] not_i32 [t2],t2"}
!173 = !{!"[168] not_i64 [t2],t2"}
!174 = !{!"[169] not_vec v128,e32,[t8],t3"}
!175 = !{!"[170] bswap16_i32 [t2],t2,attr-swp:oz"}
!176 = !{!"[171] bswap16_i32 [t2],t2,attr-swp:os"}
!177 = !{!"[172] bswap16_i32 [t2],t2,attr-swp:iz"}
!178 = !{!"[173] bswap16_i32 [t2],t2,attr-swp:iz,attr-swp:oz"}
!179 = !{!"[174] bswap16_i32 [t2],t2,attr-swp:iz,attr-swp:os"}
!180 = !{!"[175] bswap16_i32 [t2],t2"}
!181 = !{!"[176] bswap16_i64 [t2],t2,attr-swp:oz"}
!182 = !{!"[177] bswap16_i64 [t2],t2,attr-swp:os"}
!183 = !{!"[178] bswap16_i64 [t2],t2,attr-swp:iz"}
!184 = !{!"[179] bswap16_i64 [t2],t2,attr-swp:iz,attr-swp:oz"}
!185 = !{!"[180] bswap16_i64 [t2],t2,attr-swp:iz,attr-swp:os"}
!186 = !{!"[181] bswap16_i64 [t2],t2"}
!187 = !{!"[182] bswap32_i32 [t2],t2,attr-swp:oz"}
!188 = !{!"[183] bswap32_i32 [t2],t2,attr-swp:os"}
!189 = !{!"[184] bswap32_i32 [t2],t2,attr-swp:iz"}
!190 = !{!"[185] bswap32_i32 [t2],t2,attr-swp:iz,attr-swp:oz"}
!191 = !{!"[186] bswap32_i32 [t2],t2,attr-swp:iz,attr-swp:os"}
!192 = !{!"[187] bswap32_i32 [t2],t2"}
!193 = !{!"[188] bswap32_i64 [t2],t2,attr-swp:oz"}
!194 = !{!"[189] bswap32_i64 [t2],t2,attr-swp:os"}
!195 = !{!"[190] bswap32_i64 [t2],t2,attr-swp:iz"}
!196 = !{!"[191] bswap32_i64 [t2],t2,attr-swp:iz,attr-swp:oz"}
!197 = !{!"[192] bswap32_i64 [t2],t2,attr-swp:iz,attr-swp:os"}
!198 = !{!"[193] bswap32_i64 [t2],t2"}
!199 = !{!"[194] bswap64_i64 [t2],t2,attr-swp:oz"}
!200 = !{!"[195] bswap64_i64 [t2],t2,attr-swp:os"}
!201 = !{!"[196] bswap64_i64 [t2],t2,attr-swp:iz"}
!202 = !{!"[197] bswap64_i64 [t2],t2,attr-swp:iz,attr-swp:oz"}
!203 = !{!"[198] bswap64_i64 [t2],t2,attr-swp:iz,attr-swp:os"}
!204 = !{!"[199] bswap64_i64 [t2],t2"}
!205 = !{!"[200] deposit_i32 [t2],t2,t0,0x0,0x8"}
!206 = !{!"[201] deposit_i32 [t2],t2,t0,0x10,0x8"}
!207 = !{!"[202] deposit_i32 [t2],t2,t0,0x18,0x8"}
!208 = !{!"[203] deposit_i32 [t2],t2,t0,0x18,0x18"}
!209 = !{!"[204] deposit_i64 [rax],rax,t2,0x0,0x8"}
!210 = !{!"[205] deposit_i64 [rax],rax,t2,0x0,0x0"}
!211 = !{!"[206] deposit_i64 [rax],rax,t2,0x10,0x0"}
!212 = !{!"[207] dupm_vec v128,e8,[t9],v0"}
!213 = !{!"[208] dupm_vec v128,e64,[t9],v0"}
!214 = !{!"[209] extract2_i32 [t2],t0,t2,0x8"}
!215 = !{!"[210] extract2_i64 [t2],t0,t2,0x38"}
!216 = !{!"[211] extract_i32 [t2],t0,0x8,0x4"}
!217 = !{!"[212] extract_i64 [t2],t0,0x0,0x10"}
!218 = !{!"[213] sextract_i32 [t2],t0,0x8,0x4"}
!219 = !{!"[214] sextract_i64 [t2],t0,0x0,0x20"}
!220 = !{!"[215] extrh_i64_i32 [t2],t0"}
!221 = !{!"[216] ext_i32_i64 [t2],t0"}
!222 = !{!"[217] extu_i32_i64 [t2],t0"}
!223 = !{!"[218] movcond_i32 [t0],t2,0x0,0x1a,0x26,eq"}
!224 = !{!"[219] movcond_i64 [t2],t0,0x0,cc_dst,t2,eq"}
!225 = !{!"[220] movcond_vec v128,e8,[t8],t3,t4,t3,t4,ne"}
!226 = !{!"[221] mulsh_i32 [t2],t0,t2"}
!227 = !{!"[222] mulsh_i64 [t2],t0,t2"}
!228 = !{!"[223] muluh_i32 [t2],t0,t2"}
!229 = !{!"[224] muluh_i64 [t2],t0,t2"}
!230 = !{!"[225] muls2_i32 [t2],[t0],t2,t2"}
!231 = !{!"[226] muls2_i64 [t2],[t0],t2,t2"}
!232 = !{!"[227] mulu2_i32 [t2],[t0],t2,t2"}
!233 = !{!"[228] mulu2_i64 [t2],[t0],t2,t2"}
!234 = !{!"[229] setcond_i32 [t2],cc_dst,0xffffffff,tsteq"}
!235 = !{!"[230] setcond_i64 [t2],cc_dst,0xffffffff,tsteq"}
!236 = !{!"[231] negsetcond_i32 [t2],cc_dst,0xffffffff,tsteq"}
!237 = !{!"[232] negsetcond_i64 [t2],cc_dst,0xffffffff,tsteq"}
!238 = !{!"[233] umax_vec v128,e8,[t8],t3,t4"}
!239 = !{!"[234] umax_vec v128,e32,[t8],t3,t4"}
!240 = !{!"[235] umin_vec v128,e8,[t8],t3,t4"}
!241 = !{!"[236] umin_vec v128,e32,[t8],t3,t4"}
!242 = !{!"[237] dup_vec v128,e8,[t9],rax"}
!243 = !{!"[238] dup_vec v128,e64,[t9],t2"}
!244 = !{!"[239] brcond_i32 t1,0x0,eq,L0"}
!245 = !{!"[240] setcond_i32 [t18],t1,0xffffffffffffffff,eq"}
!246 = !{!"[241] setcond_i32 [t19],t0,0x80000000,eq"}
!247 = !{!"[242] setcond_i32 [t20],t2,0x0,eq"}
!248 = !{!"[243] and_i32 [t19],t19,t20"}
!249 = !{!"[244] and_i32 [t18],t18,t19"}
!250 = !{!"[245] brcond_i32 t18,0x1,eq,L0"}
!251 = !{!"[246] divs2_i32 [t2],[t0],t2,t0,t1,L0"}
!252 = !{!"[247] brcond_i64 t1,0x0,eq,L0"}
!253 = !{!"[248] setcond_i64 [t21],t1,0xffffffffffffffff,eq"}
!254 = !{!"[249] setcond_i64 [t22],t0,0x8000000000000000,eq"}
!255 = !{!"[250] setcond_i64 [t23],t2,0x0,eq"}
!256 = !{!"[251] and_i64 [t22],t22,t23"}
!257 = !{!"[252] and_i64 [t21],t21,t22"}
!258 = !{!"[253] brcond_i64 t21,0x1,eq,L0"}
!259 = !{!"[254] divs2_i64 [t2],[t0],t2,t0,t1,L0"}
!260 = !{!"[255] brcond_i32 t1,0x0,eq,L0"}
!261 = !{!"[256] divu2_i32 [t2],[t0],t2,t0,t1,L0"}
!262 = !{!"[257] brcond_i64 t1,0x0,eq,L0"}
!263 = !{!"[258] divu2_i64 [t2],[t0],t2,t0,t1,L0"}
!264 = !{!"[259] discard rax"}
!265 = !{!"[260] discard t2"}
!266 = !{!"[261] func_addr t24,0x55aa,0x0"}
!267 = !{!"[262] tail_call_qemuaot t24 VEC_ARGS:"}
!268 = !{!"[0] st_i64 rax,env"}
!269 = !{!270, !270, i64 0}
!270 = !{!"CPUState", !2}
!271 = !{!"[1] st_i64 rcx,env:0x8"}
!272 = !{!"[2] st_i64 rdx,env:0x10"}
!273 = !{!"[3] st_i64 rbx,env:0x18"}
!274 = !{!"[4] st_i64 rsp,env:0x20"}
!275 = !{!"[5] st_i64 rbp,env:0x28"}
!276 = !{!"[6] st_i64 rsi,env:0x30"}
!277 = !{!"[7] st_i64 rdi,env:0x38"}
!278 = !{!"[8] st_i64 r8,env:0x40"}
!279 = !{!"[9] st_i64 r9,env:0x48"}
!280 = !{!"[10] st_i64 r10,env:0x50"}
!281 = !{!"[11] st_i64 r11,env:0x58"}
!282 = !{!"[12] st_i64 r12,env:0x60"}
!283 = !{!"[13] st_i64 r13,env:0x68"}
!284 = !{!"[14] st_i64 r14,env:0x70"}
!285 = !{!"[15] st_i64 r15,env:0x78"}
!286 = !{!"[16] st_i64 cc_src,env:0x98"}
!287 = !{!"[17] st_i64 cc_dst,env:0x90"}
!288 = !{!"[18] st_i32 cc_op,env:0xa8"}
!289 = !{!"[19] st_i64 rip,env:0x80"}
!290 = !{!"[20] st_vec v128,e8,v0,env:0x360"}
!291 = !{!"[21] st_vec v128,e8,v1,env:0x370"}
!292 = !{!"[22] st_vec v128,e8,v2,env:0x3a0"}
!293 = !{!"[23] st_vec v128,e8,v3,env:0x3b0"}
!294 = !{!"[24] st_vec v128,e8,v4,env:0x3e0"}
!295 = !{!"[25] st_vec v128,e8,v5,env:0x3f0"}
!296 = !{!"[26] st_vec v128,e8,v6,env:0x420"}
!297 = !{!"[27] st_vec v128,e8,v7,env:0x430"}
!298 = !{!"[28] st_vec v128,e8,v8,env:0x460"}
!299 = !{!"[29] st_vec v128,e8,v9,env:0x470"}
!300 = !{!"[30] st_vec v128,e8,v10,env:0x4a0"}
!301 = !{!"[31] st_vec v128,e8,v11,env:0x4b0"}
!302 = !{!"[32] st_vec v128,e8,v12,env:0x4e0"}
!303 = !{!"[33] st_vec v128,e8,v13,env:0x4f0"}
!304 = !{!"[34] st_vec v128,e8,v14,env:0x520"}
!305 = !{!"[35] st_vec v128,e8,v15,env:0x530"}
!306 = !{!"[36] st_vec v128,e8,v16,env:0x560"}
!307 = !{!"[37] st_vec v128,e8,v17,env:0x570"}
!308 = !{!"[38] st_vec v128,e8,v18,env:0x5a0"}
!309 = !{!"[39] st_vec v128,e8,v19,env:0x5b0"}
!310 = !{!"[40] st_vec v128,e8,v20,env:0x5e0"}
!311 = !{!"[41] st_vec v128,e8,v21,env:0x5f0"}
!312 = !{!"[42] st_vec v128,e8,v22,env:0x620"}
!313 = !{!"[43] st_vec v128,e8,v23,env:0x630"}
!314 = !{!"[44] st_vec v128,e8,v24,env:0x660"}
!315 = !{!"[45] st_vec v128,e8,v25,env:0x670"}
!316 = !{!"[46] st_vec v128,e8,v26,env:0x6a0"}
!317 = !{!"[47] st_vec v128,e8,v27,env:0x6b0"}
!318 = !{!"[48] tail_call_default helper_raise_exception,arg0,arg1"}
