; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h) #0 section ".text.Fx0" {
entry:
  %rax.stack = alloca i64, align 8
  store i64 %rax, ptr %rax.stack, align 8
  %rcx.stack = alloca i64, align 8
  store i64 %rcx, ptr %rcx.stack, align 8
  %rdx.stack = alloca i64, align 8
  store i64 %rdx, ptr %rdx.stack, align 8
  %rbx.stack = alloca i64, align 8
  store i64 %rbx, ptr %rbx.stack, align 8
  %v2.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm1, ptr %v2.stack, align 16
  %v4.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm2, ptr %v4.stack, align 16
  %tmp0.stack = alloca <2 x i64>, align 16
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca <2 x i64>, align 16
  %tmp4.stack = alloca <2 x i64>, align 16
  %tmp5.stack = alloca <2 x i64>, align 16
  %tmp6.stack = alloca <2 x i64>, align 16
  %tmp7.stack = alloca <2 x i64>, align 16
  %tmp8.stack = alloca i64, align 8
  %env = call i64 asm sideeffect "mov $0, x25", "=r"()
; ======== TCG [0] add_i64 [rax],rbx,rdx ========
  %T0.rbx = load i64, ptr %rbx.stack, align 8, !tcg.op !0
  %T0.rdx = load i64, ptr %rdx.stack, align 8, !tcg.op !0
  %T0.out = add i64 %T0.rbx, %T0.rdx, !tcg.op !0
  store i64 %T0.out, ptr %rax.stack, align 8, !tcg.op !0
; ======== TCG [1] add_i64 [t0],rax,0x42 ========
  %T1.rax = load i64, ptr %rax.stack, align 8, !tcg.op !1
  %T1.out = add i64 %T1.rax, 66, !tcg.op !1
  %T1.out.ie = insertelement <2 x i64> zeroinitializer, i64 %T1.out, i64 0, !tcg.op !1
  store <2 x i64> %T1.out.ie, ptr %tmp0.stack, align 16, !tcg.op !1
; ======== TCG [2] add_i64 [rcx],rcx,rcx ========
  %T2.rcx = load i64, ptr %rcx.stack, align 8, !tcg.op !2
  %T2.out = add i64 %T2.rcx, %T2.rcx, !tcg.op !2
  store i64 %T2.out, ptr %rcx.stack, align 8, !tcg.op !2
; ======== TCG [3] add_i64 [rbx],rcx,0x42 ========
  %T3.rcx = load i64, ptr %rcx.stack, align 8, !tcg.op !3
  %T3.out = add i64 %T3.rcx, 66, !tcg.op !3
  store i64 %T3.out, ptr %rbx.stack, align 8, !tcg.op !3
; ======== TCG [4] add_vec v128,e8,[t3],v2,v4 ========
  %T4.v2 = load <2 x i64>, ptr %v2.stack, align 16, !tcg.op !4
  %T4.v2.bc = bitcast <2 x i64> %T4.v2 to <16 x i8>, !tcg.op !4
  %T4.v4 = load <2 x i64>, ptr %v4.stack, align 16, !tcg.op !4
  %T4.v4.bc = bitcast <2 x i64> %T4.v4 to <16 x i8>, !tcg.op !4
  %T4.out = add <16 x i8> %T4.v2.bc, %T4.v4.bc, !tcg.op !4
  %T4.out.bc = bitcast <16 x i8> %T4.out to <2 x i64>, !tcg.op !4
  store <2 x i64> %T4.out.bc, ptr %tmp3.stack, align 16, !tcg.op !4
; ======== TCG [5] add_vec v128,e16,[t3],v2,v4 ========
  %T4.v2.bc1 = bitcast <2 x i64> %T4.v2 to <8 x i16>, !tcg.op !5
  %T4.v4.bc2 = bitcast <2 x i64> %T4.v4 to <8 x i16>, !tcg.op !5
  %T5.out = add <8 x i16> %T4.v2.bc1, %T4.v4.bc2, !tcg.op !5
  %T5.out.bc = bitcast <8 x i16> %T5.out to <2 x i64>, !tcg.op !5
  store <2 x i64> %T5.out.bc, ptr %tmp3.stack, align 16, !tcg.op !5
; ======== TCG [6] add_vec v128,e32,[t3],v2,v4 ========
  %T4.v2.bc3 = bitcast <2 x i64> %T4.v2 to <4 x i32>, !tcg.op !6
  %T4.v4.bc4 = bitcast <2 x i64> %T4.v4 to <4 x i32>, !tcg.op !6
  %T6.out = add <4 x i32> %T4.v2.bc3, %T4.v4.bc4, !tcg.op !6
  %T6.out.bc = bitcast <4 x i32> %T6.out to <2 x i64>, !tcg.op !6
  store <2 x i64> %T6.out.bc, ptr %tmp3.stack, align 16, !tcg.op !6
; ======== TCG [7] add_vec v128,e64,[t3],v2,v4 ========
  %T7.out = add <2 x i64> %T4.v2, %T4.v4, !tcg.op !7
  store <2 x i64> %T7.out, ptr %tmp3.stack, align 16, !tcg.op !7
; ======== TCG [8] add_vec v128,e64,[t4],v2,v4 ========
  %T8.out = add <2 x i64> %T4.v2, %T4.v4, !tcg.op !8
  store <2 x i64> %T8.out, ptr %tmp4.stack, align 16, !tcg.op !8
; ======== TCG [9] add_vec v128,e64,[t5],t6,t7 ========
  %T9.tmp6 = load <2 x i64>, ptr %tmp6.stack, align 16, !tcg.op !9
  %T9.tmp7 = load <2 x i64>, ptr %tmp7.stack, align 16, !tcg.op !9
  %T9.out = add <2 x i64> %T9.tmp6, %T9.tmp7, !tcg.op !9
  store <2 x i64> %T9.out, ptr %tmp5.stack, align 16, !tcg.op !9
; ======== TCG [10] add_i64 [t3],rax,fs_base(env) ========
  %T10.addr.fs_base = add i64 %env, 288, !tcg.op !10
  %T10.addr.fs_base.ptr = inttoptr i64 %T10.addr.fs_base to ptr, !tcg.op !10
  %T10.fs_base = load i64, ptr %T10.addr.fs_base.ptr, align 8, !tcg.op !10
  %T10.out = add i64 %T1.rax, %T10.fs_base, !tcg.op !10
  %T10.out.ie = insertelement <2 x i64> zeroinitializer, i64 %T10.out, i64 0, !tcg.op !10
  store <2 x i64> %T10.out.ie, ptr %tmp3.stack, align 16, !tcg.op !10
; ======== TCG [11] add_i32 [t3],t3,t3 ========
  %T11.tmp3 = load <2 x i64>, ptr %tmp3.stack, align 16, !tcg.op !11
  %T11.tmp3.bc = bitcast <2 x i64> %T11.tmp3 to <4 x i32>, !tcg.op !11
  %T11.tmp3.bc.ee = extractelement <4 x i32> %T11.tmp3.bc, i64 0, !tcg.op !11
  %T11.tmp3.bc5 = bitcast <2 x i64> %T11.tmp3 to <4 x i32>, !tcg.op !11
  %T11.tmp3.bc5.ee = extractelement <4 x i32> %T11.tmp3.bc5, i64 0, !tcg.op !11
  %T11.out = add i32 %T11.tmp3.bc.ee, %T11.tmp3.bc5.ee, !tcg.op !11
  %T11.out.ie = insertelement <4 x i32> zeroinitializer, i32 %T11.out, i64 0, !tcg.op !11
  %T11.out.ie.bc = bitcast <4 x i32> %T11.out.ie to <2 x i64>, !tcg.op !11
  store <2 x i64> %T11.out.ie.bc, ptr %tmp3.stack, align 16, !tcg.op !11
; ======== TCG [12] add_i32 [t4],t3,t3 ========
  %T12.tmp3 = load <2 x i64>, ptr %tmp3.stack, align 16, !tcg.op !12
  %T12.tmp3.bc = bitcast <2 x i64> %T12.tmp3 to <4 x i32>, !tcg.op !12
  %T12.tmp3.bc.ee = extractelement <4 x i32> %T12.tmp3.bc, i64 0, !tcg.op !12
  %T12.tmp3.bc6 = bitcast <2 x i64> %T12.tmp3 to <4 x i32>, !tcg.op !12
  %T12.tmp3.bc6.ee = extractelement <4 x i32> %T12.tmp3.bc6, i64 0, !tcg.op !12
  %T12.out = add i32 %T12.tmp3.bc.ee, %T12.tmp3.bc6.ee, !tcg.op !12
  %T12.out.ie = insertelement <4 x i32> zeroinitializer, i32 %T12.out, i64 0, !tcg.op !12
  %T12.out.ie.bc = bitcast <4 x i32> %T12.out.ie to <2 x i64>, !tcg.op !12
  store <2 x i64> %T12.out.ie.bc, ptr %tmp4.stack, align 16, !tcg.op !12
; ======== TCG [13] add_i32 [t0],t4,t3 ========
  %T13.tmp4 = load <2 x i64>, ptr %tmp4.stack, align 16, !tcg.op !13
  %T13.tmp4.bc = bitcast <2 x i64> %T13.tmp4 to <4 x i32>, !tcg.op !13
  %T13.tmp4.bc.ee = extractelement <4 x i32> %T13.tmp4.bc, i64 0, !tcg.op !13
  %T12.tmp3.bc7 = bitcast <2 x i64> %T12.tmp3 to <4 x i32>, !tcg.op !13
  %T12.tmp3.bc7.ee = extractelement <4 x i32> %T12.tmp3.bc7, i64 0, !tcg.op !13
  %T13.out = add i32 %T13.tmp4.bc.ee, %T12.tmp3.bc7.ee, !tcg.op !13
  %T13.out.ie = insertelement <4 x i32> zeroinitializer, i32 %T13.out, i64 0, !tcg.op !13
  %T13.out.ie.bc = bitcast <4 x i32> %T13.out.ie to <2 x i64>, !tcg.op !13
  store <2 x i64> %T13.out.ie.bc, ptr %tmp0.stack, align 16, !tcg.op !13
; ======== TCG [14] br L0 ========
  br label %bb_L0, !tcg.op !14

bb_L0:                                            ; preds = %entry
; ======== TCG [16] add_i32 [t3],t3,t3 ========
  %T16.tmp3 = load <2 x i64>, ptr %tmp3.stack, align 16, !tcg.op !15
  %T16.tmp3.bc = bitcast <2 x i64> %T16.tmp3 to <4 x i32>, !tcg.op !15
  %T16.tmp3.bc.ee = extractelement <4 x i32> %T16.tmp3.bc, i64 0, !tcg.op !15
  %T16.tmp3.bc8 = bitcast <2 x i64> %T16.tmp3 to <4 x i32>, !tcg.op !15
  %T16.tmp3.bc8.ee = extractelement <4 x i32> %T16.tmp3.bc8, i64 0, !tcg.op !15
  %T16.out = add i32 %T16.tmp3.bc.ee, %T16.tmp3.bc8.ee, !tcg.op !15
  %T16.out.ie = insertelement <4 x i32> zeroinitializer, i32 %T16.out, i64 0, !tcg.op !15
  %T16.out.ie.bc = bitcast <4 x i32> %T16.out.ie to <2 x i64>, !tcg.op !15
  store <2 x i64> %T16.out.ie.bc, ptr %tmp3.stack, align 16, !tcg.op !15
; ======== TCG [17] add_vec v128,e64,[t6],t4,t0 ========
  %T17.tmp4 = load <2 x i64>, ptr %tmp4.stack, align 16, !tcg.op !16
  %T17.tmp0 = load <2 x i64>, ptr %tmp0.stack, align 16, !tcg.op !16
  %T17.out = add <2 x i64> %T17.tmp4, %T17.tmp0, !tcg.op !16
  store <2 x i64> %T17.out, ptr %tmp6.stack, align 16, !tcg.op !16
; ======== TCG [18] add_vec v64,e8,[t6],t4,t0 ========
  %T17.tmp4.ee = extractelement <2 x i64> %T17.tmp4, i64 0, !tcg.op !17
  %T17.tmp4.ee.bc = bitcast i64 %T17.tmp4.ee to <8 x i8>, !tcg.op !17
  %T17.tmp0.ee = extractelement <2 x i64> %T17.tmp0, i64 0, !tcg.op !17
  %T17.tmp0.ee.bc = bitcast i64 %T17.tmp0.ee to <8 x i8>, !tcg.op !17
  %T18.out = add <8 x i8> %T17.tmp4.ee.bc, %T17.tmp0.ee.bc, !tcg.op !17
  %T18.out.bc = bitcast <8 x i8> %T18.out to <1 x i64>, !tcg.op !17
  %T18.out.bc.ee = extractelement <1 x i64> %T18.out.bc, i64 0, !tcg.op !17
  %T18.out.bc.ee.ie = insertelement <2 x i64> zeroinitializer, i64 %T18.out.bc.ee, i64 0, !tcg.op !17
  store <2 x i64> %T18.out.bc.ee.ie, ptr %tmp6.stack, align 16, !tcg.op !17
; ======== TCG [19] add_vec v64,e16,[t4],t0,t6 ========
  %T17.tmp0.ee9 = extractelement <2 x i64> %T17.tmp0, i64 0, !tcg.op !18
  %T17.tmp0.ee9.bc = bitcast i64 %T17.tmp0.ee9 to <4 x i16>, !tcg.op !18
  %T19.tmp6 = load <2 x i64>, ptr %tmp6.stack, align 16, !tcg.op !18
  %T19.tmp6.ee = extractelement <2 x i64> %T19.tmp6, i64 0, !tcg.op !18
  %T19.tmp6.ee.bc = bitcast i64 %T19.tmp6.ee to <4 x i16>, !tcg.op !18
  %T19.out = add <4 x i16> %T17.tmp0.ee9.bc, %T19.tmp6.ee.bc, !tcg.op !18
  %T19.out.bc = bitcast <4 x i16> %T19.out to <1 x i64>, !tcg.op !18
  %T19.out.bc.ee = extractelement <1 x i64> %T19.out.bc, i64 0, !tcg.op !18
  %T19.out.bc.ee.ie = insertelement <2 x i64> zeroinitializer, i64 %T19.out.bc.ee, i64 0, !tcg.op !18
  store <2 x i64> %T19.out.bc.ee.ie, ptr %tmp4.stack, align 16, !tcg.op !18
; ======== TCG [20] add_vec v64,e32,[t0],t6,t4 ========
  %T19.tmp6.ee10 = extractelement <2 x i64> %T19.tmp6, i64 0, !tcg.op !19
  %T19.tmp6.ee10.bc = bitcast i64 %T19.tmp6.ee10 to <2 x i32>, !tcg.op !19
  %T20.tmp4 = load <2 x i64>, ptr %tmp4.stack, align 16, !tcg.op !19
  %T20.tmp4.ee = extractelement <2 x i64> %T20.tmp4, i64 0, !tcg.op !19
  %T20.tmp4.ee.bc = bitcast i64 %T20.tmp4.ee to <2 x i32>, !tcg.op !19
  %T20.out = add <2 x i32> %T19.tmp6.ee10.bc, %T20.tmp4.ee.bc, !tcg.op !19
  %T20.out.bc = bitcast <2 x i32> %T20.out to <1 x i64>, !tcg.op !19
  %T20.out.bc.ee = extractelement <1 x i64> %T20.out.bc, i64 0, !tcg.op !19
  %T20.out.bc.ee.ie = insertelement <2 x i64> zeroinitializer, i64 %T20.out.bc.ee, i64 0, !tcg.op !19
  store <2 x i64> %T20.out.bc.ee.ie, ptr %tmp0.stack, align 16, !tcg.op !19
; ======== TCG [21] add_vec v64,e64,[t6],t4,t0 ========
  %T20.tmp4.ee11 = extractelement <2 x i64> %T20.tmp4, i64 0, !tcg.op !20
  %T20.tmp4.ee11.bc = bitcast i64 %T20.tmp4.ee11 to <1 x i64>, !tcg.op !20
  %T21.tmp0 = load <2 x i64>, ptr %tmp0.stack, align 16, !tcg.op !20
  %T21.tmp0.ee = extractelement <2 x i64> %T21.tmp0, i64 0, !tcg.op !20
  %T21.tmp0.ee.bc = bitcast i64 %T21.tmp0.ee to <1 x i64>, !tcg.op !20
  %T21.out = add <1 x i64> %T20.tmp4.ee11.bc, %T21.tmp0.ee.bc, !tcg.op !20
  %T21.out.ee = extractelement <1 x i64> %T21.out, i64 0, !tcg.op !20
  %T21.out.ee.ie = insertelement <2 x i64> zeroinitializer, i64 %T21.out.ee, i64 0, !tcg.op !20
  store <2 x i64> %T21.out.ee.ie, ptr %tmp6.stack, align 16, !tcg.op !20
; ======== TCG [22] add_i32 [t8],rax,0x42 ========
  %T22.rax = load i64, ptr %rax.stack, align 8, !tcg.op !21
  %T22.rax.trunc = trunc i64 %T22.rax to i32, !tcg.op !21
  %T22.out = add i32 %T22.rax.trunc, 66, !tcg.op !21
  %T22.out.zext = zext i32 %T22.out to i64, !tcg.op !21
  store i64 %T22.out.zext, ptr %tmp8.stack, align 8, !tcg.op !21
; ======== TCG [23] add_i64 [t8],rax,0x42 ========
  %T23.out = add i64 %T22.rax, 66, !tcg.op !22
  store i64 %T23.out, ptr %tmp8.stack, align 8, !tcg.op !22
}

attributes #0 = { noinline nounwind "target-features"="+neon" }

!0 = !{!"[0] add_i64 [rax],rbx,rdx"}
!1 = !{!"[1] add_i64 [t0],rax,0x42"}
!2 = !{!"[2] add_i64 [rcx],rcx,rcx"}
!3 = !{!"[3] add_i64 [rbx],rcx,0x42"}
!4 = !{!"[4] add_vec v128,e8,[t3],v2,v4"}
!5 = !{!"[5] add_vec v128,e16,[t3],v2,v4"}
!6 = !{!"[6] add_vec v128,e32,[t3],v2,v4"}
!7 = !{!"[7] add_vec v128,e64,[t3],v2,v4"}
!8 = !{!"[8] add_vec v128,e64,[t4],v2,v4"}
!9 = !{!"[9] add_vec v128,e64,[t5],t6,t7"}
!10 = !{!"[10] add_i64 [t3],rax,fs_base(env)"}
!11 = !{!"[11] add_i32 [t3],t3,t3"}
!12 = !{!"[12] add_i32 [t4],t3,t3"}
!13 = !{!"[13] add_i32 [t0],t4,t3"}
!14 = !{!"[14] br L0"}
!15 = !{!"[16] add_i32 [t3],t3,t3"}
!16 = !{!"[17] add_vec v128,e64,[t6],t4,t0"}
!17 = !{!"[18] add_vec v64,e8,[t6],t4,t0"}
!18 = !{!"[19] add_vec v64,e16,[t4],t0,t6"}
!19 = !{!"[20] add_vec v64,e32,[t0],t6,t4"}
!20 = !{!"[21] add_vec v64,e64,[t6],t4,t0"}
!21 = !{!"[22] add_i32 [t8],rax,0x42"}
!22 = !{!"[23] add_i64 [t8],rax,0x42"}
