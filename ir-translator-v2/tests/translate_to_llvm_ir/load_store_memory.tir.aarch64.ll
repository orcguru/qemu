; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h) #0 section ".text.Fx0" {
entry:
  %rsp.stack = alloca i64, align 8
  store i64 %rsp, ptr %rsp.stack, align 8
  %v4.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm2, ptr %v4.stack, align 16
  %v18.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm9, ptr %v18.stack, align 16
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca <2 x i64>, align 16
  %tmp4.stack = alloca i32, align 8
  %tmp5.stack = alloca i64, align 8
  %tmp6.stack = alloca i64, align 8
  %tmp7.stack = alloca i64, align 8
  %tmp8.stack = alloca i64, align 8
  %tmp9.stack = alloca i32, align 8
  %tmp10.stack = alloca i64, align 8
  %tmp11.stack = alloca i64, align 8
  %env = call i64 asm sideeffect "mov $0, x25", "=r"()
; ======== TCG [0] ld8u_i32 [t0],env:0xac ========
  %T0.addr.envoff = add i64 %env, 172, !tcg.op !0
  %T0.addr.envoff.ptr = inttoptr i64 %T0.addr.envoff to ptr, !tcg.op !0
  %T0.envval = load i8, ptr %T0.addr.envoff.ptr, align 4, !tcg.op !0
  %T0.out = zext i8 %T0.envval to i32, !tcg.op !0
  %T0.out.zext = zext i32 %T0.out to i64, !tcg.op !0
  store i64 %T0.out.zext, ptr %tmp0.stack, align 8, !tcg.op !0
; ======== TCG [1] ld8u_i64 [t0],env:0xac ========
  %T1.addr.envoff = add i64 %env, 172, !tcg.op !1
  %T1.addr.envoff.ptr = inttoptr i64 %T1.addr.envoff to ptr, !tcg.op !1
  %T1.envval = load i8, ptr %T1.addr.envoff.ptr, align 4, !tcg.op !1
  %T1.out = zext i8 %T1.envval to i64, !tcg.op !1
  store i64 %T1.out, ptr %tmp0.stack, align 8, !tcg.op !1
; ======== TCG [2] ld16u_i32 [t0],env:0xac ========
  %T2.addr.envoff = add i64 %env, 172, !tcg.op !2
  %T2.addr.envoff.ptr = inttoptr i64 %T2.addr.envoff to ptr, !tcg.op !2
  %T2.envval = load i16, ptr %T2.addr.envoff.ptr, align 4, !tcg.op !2
  %T2.out = zext i16 %T2.envval to i32, !tcg.op !2
  %T2.out.zext = zext i32 %T2.out to i64, !tcg.op !2
  store i64 %T2.out.zext, ptr %tmp0.stack, align 8, !tcg.op !2
; ======== TCG [3] ld16u_i64 [t0],env:0xac ========
  %T3.addr.envoff = add i64 %env, 172, !tcg.op !3
  %T3.addr.envoff.ptr = inttoptr i64 %T3.addr.envoff to ptr, !tcg.op !3
  %T3.envval = load i16, ptr %T3.addr.envoff.ptr, align 4, !tcg.op !3
  %T3.out = zext i16 %T3.envval to i64, !tcg.op !3
  store i64 %T3.out, ptr %tmp0.stack, align 8, !tcg.op !3
; ======== TCG [4] ld32u_i64 [t0],env:0xac ========
  %T4.addr.envoff = add i64 %env, 172, !tcg.op !4
  %T4.addr.envoff.ptr = inttoptr i64 %T4.addr.envoff to ptr, !tcg.op !4
  %T4.envval = load i32, ptr %T4.addr.envoff.ptr, align 4, !tcg.op !4
  %T4.out = zext i32 %T4.envval to i64, !tcg.op !4
  store i64 %T4.out, ptr %tmp0.stack, align 8, !tcg.op !4
; ======== TCG [5] ld8s_i32 [t0],env:0xac ========
  %T5.addr.envoff = add i64 %env, 172, !tcg.op !5
  %T5.addr.envoff.ptr = inttoptr i64 %T5.addr.envoff to ptr, !tcg.op !5
  %T5.envval = load i8, ptr %T5.addr.envoff.ptr, align 4, !tcg.op !5
  %T5.out = sext i8 %T5.envval to i32, !tcg.op !5
  %T5.out.zext = zext i32 %T5.out to i64, !tcg.op !5
  store i64 %T5.out.zext, ptr %tmp0.stack, align 8, !tcg.op !5
; ======== TCG [6] ld8s_i64 [t0],env:0xac ========
  %T6.addr.envoff = add i64 %env, 172, !tcg.op !6
  %T6.addr.envoff.ptr = inttoptr i64 %T6.addr.envoff to ptr, !tcg.op !6
  %T6.envval = load i8, ptr %T6.addr.envoff.ptr, align 4, !tcg.op !6
  %T6.out = sext i8 %T6.envval to i64, !tcg.op !6
  store i64 %T6.out, ptr %tmp0.stack, align 8, !tcg.op !6
; ======== TCG [7] ld16s_i32 [t0],env:0xac ========
  %T7.addr.envoff = add i64 %env, 172, !tcg.op !7
  %T7.addr.envoff.ptr = inttoptr i64 %T7.addr.envoff to ptr, !tcg.op !7
  %T7.envval = load i16, ptr %T7.addr.envoff.ptr, align 4, !tcg.op !7
  %T7.out = sext i16 %T7.envval to i32, !tcg.op !7
  %T7.out.zext = zext i32 %T7.out to i64, !tcg.op !7
  store i64 %T7.out.zext, ptr %tmp0.stack, align 8, !tcg.op !7
; ======== TCG [8] ld16s_i64 [t0],env:0xac ========
  %T8.addr.envoff = add i64 %env, 172, !tcg.op !8
  %T8.addr.envoff.ptr = inttoptr i64 %T8.addr.envoff to ptr, !tcg.op !8
  %T8.envval = load i16, ptr %T8.addr.envoff.ptr, align 4, !tcg.op !8
  %T8.out = sext i16 %T8.envval to i64, !tcg.op !8
  store i64 %T8.out, ptr %tmp0.stack, align 8, !tcg.op !8
; ======== TCG [9] ld32s_i64 [t0],env:0xac ========
  %T9.addr.envoff = add i64 %env, 172, !tcg.op !9
  %T9.addr.envoff.ptr = inttoptr i64 %T9.addr.envoff to ptr, !tcg.op !9
  %T9.envval = load i32, ptr %T9.addr.envoff.ptr, align 4, !tcg.op !9
  %T9.out = sext i32 %T9.envval to i64, !tcg.op !9
  store i64 %T9.out, ptr %tmp0.stack, align 8, !tcg.op !9
; ======== TCG [10] ld32s_i64 [t2],v18,0x4 ========
  %T10.v18 = load <2 x i64>, ptr %v18.stack, align 16, !tcg.op !10
  %T10.v18.bc = bitcast <2 x i64> %T10.v18 to <4 x i32>, !tcg.op !10
  %T10.v18.bc.ee = extractelement <4 x i32> %T10.v18.bc, i64 1, !tcg.op !10
  %T10.out = sext i32 %T10.v18.bc.ee to i64, !tcg.op !10
  store i64 %T10.out, ptr %tmp2.stack, align 8, !tcg.op !10
; ======== TCG [11] ld_vec v128,e8,[t3],env:0xb60 ========
  %T11.addr.envoff = add i64 %env, 2912, !tcg.op !11
  %T11.addr.envoff.ptr = inttoptr i64 %T11.addr.envoff to ptr, !tcg.op !11
  %T11.envval = load <16 x i8>, ptr %T11.addr.envoff.ptr, align 8, !tcg.op !11
  %T11.envval.bc = bitcast <16 x i8> %T11.envval to <2 x i64>, !tcg.op !11
  store <2 x i64> %T11.envval.bc, ptr %tmp3.stack, align 16, !tcg.op !11
; ======== TCG [12] ld_i32 [t4],env:0xd0 ========
  %T12.addr.envoff = add i64 %env, 208, !tcg.op !12
  %T12.addr.envoff.ptr = inttoptr i64 %T12.addr.envoff to ptr, !tcg.op !12
  %T12.envval = load i32, ptr %T12.addr.envoff.ptr, align 8, !tcg.op !12
  store i32 %T12.envval, ptr %tmp4.stack, align 8, !tcg.op !12
; ======== TCG [13] ld_i64 [t5],env:0x88 ========
  %T13.addr.envoff = add i64 %env, 136, !tcg.op !13
  %T13.addr.envoff.ptr = inttoptr i64 %T13.addr.envoff to ptr, !tcg.op !13
  %T13.envval = load i64, ptr %T13.addr.envoff.ptr, align 8, !tcg.op !13
  store i64 %T13.envval, ptr %tmp5.stack, align 8, !tcg.op !13
; ======== TCG [14] ld_i64 [t6],v4 ========
  %T14.v4 = load <2 x i64>, ptr %v4.stack, align 16, !tcg.op !14
  %T14.v4.ee = extractelement <2 x i64> %T14.v4, i64 0, !tcg.op !14
  store i64 %T14.v4.ee, ptr %tmp6.stack, align 8, !tcg.op !14
; ======== TCG [15] ld_i64 [t6],v4:o4 ========
  %T15.addr.envoff = add i64 %env, 992, !tcg.op !15
  %T15.addr.envoff.ptr = inttoptr i64 %T15.addr.envoff to ptr, !tcg.op !15
  store <2 x i64> %T14.v4, ptr %T15.addr.envoff.ptr, align 8, !tcg.op !15
  %T15.addr.envoff1 = add i64 %env, 996, !tcg.op !15
  %T15.addr.envoff1.ptr = inttoptr i64 %T15.addr.envoff1 to ptr, !tcg.op !15
  %T15.envval = load i64, ptr %T15.addr.envoff1.ptr, align 4, !tcg.op !15
  store i64 %T15.envval, ptr %tmp6.stack, align 8, !tcg.op !15
; ======== TCG [16] ld_i64 [t6],v4:o8 ========
  %T14.v4.ee2 = extractelement <2 x i64> %T14.v4, i64 1, !tcg.op !16
  store i64 %T14.v4.ee2, ptr %tmp6.stack, align 8, !tcg.op !16
; ======== TCG [17] add_i64 [t7],rsp,0x0 ========
  %T17.rsp = load i64, ptr %rsp.stack, align 8, !tcg.op !17
  %T17.out = add i64 %T17.rsp, 0, !tcg.op !17
  store i64 %T17.out, ptr %tmp7.stack, align 8, !tcg.op !17
; ======== TCG [18] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7 = load i64, ptr %tmp7.stack, align 8, !tcg.op !18
  %T18.tmp7.ptr = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !18
  %T18.ld = load i8, ptr %T18.tmp7.ptr, align 1, !tcg.op !18
  %T18.ld.sext = zext i8 %T18.ld to i64, !tcg.op !18
  store i64 %T18.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !18
; ======== TCG [19] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr3 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !19
  %T19.ld = load i8, ptr %T18.tmp7.ptr3, align 1, !tcg.op !19
  %T19.ld.sext = sext i8 %T19.ld to i64, !tcg.op !19
  store i64 %T19.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !19
; ======== TCG [20] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr4 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !20
  %T20.ld = load i16, ptr %T18.tmp7.ptr4, align 1, !tcg.op !20
  %T20.ld.sext = zext i16 %T20.ld to i64, !tcg.op !20
  store i64 %T20.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !20
; ======== TCG [21] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr5 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !21
  %T21.ld = load i16, ptr %T18.tmp7.ptr5, align 1, !tcg.op !21
  %T21.ld.sext = sext i16 %T21.ld to i64, !tcg.op !21
  store i64 %T21.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !21
; ======== TCG [22] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr6 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !22
  %T22.ld = load i32, ptr %T18.tmp7.ptr6, align 1, !tcg.op !22
  %T22.ld.sext = zext i32 %T22.ld to i64, !tcg.op !22
  store i64 %T22.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !22
; ======== TCG [23] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr7 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !23
  %T23.ld = load i32, ptr %T18.tmp7.ptr7, align 1, !tcg.op !23
  %T23.ld.sext = sext i32 %T23.ld to i64, !tcg.op !23
  store i64 %T23.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !23
; ======== TCG [24] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr8 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !24
  %T24.ld = load i64, ptr %T18.tmp7.ptr8, align 1, !tcg.op !24
  store i64 %T24.ld, ptr %tmp8.stack, align 8, !tcg.op !24
; ======== TCG [25] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr9 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !25
  %T25.ld = load i8, ptr %T18.tmp7.ptr9, align 1, !tcg.op !25
  %T25.ld.sext = zext i8 %T25.ld to i64, !tcg.op !25
  store i64 %T25.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !25
; ======== TCG [26] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr10 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !26
  %T26.ld = load i8, ptr %T18.tmp7.ptr10, align 1, !tcg.op !26
  %T26.ld.sext = sext i8 %T26.ld to i64, !tcg.op !26
  store i64 %T26.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !26
; ======== TCG [27] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr11 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !27
  %T27.ld = load i16, ptr %T18.tmp7.ptr11, align 2, !tcg.op !27
  %T27.ld.sext = zext i16 %T27.ld to i64, !tcg.op !27
  store i64 %T27.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !27
; ======== TCG [28] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr12 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !28
  %T28.ld = load i16, ptr %T18.tmp7.ptr12, align 2, !tcg.op !28
  %T28.ld.sext = sext i16 %T28.ld to i64, !tcg.op !28
  store i64 %T28.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !28
; ======== TCG [29] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr13 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !29
  %T29.ld = load i32, ptr %T18.tmp7.ptr13, align 4, !tcg.op !29
  %T29.ld.sext = zext i32 %T29.ld to i64, !tcg.op !29
  store i64 %T29.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !29
; ======== TCG [30] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr14 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !30
  %T30.ld = load i32, ptr %T18.tmp7.ptr14, align 4, !tcg.op !30
  %T30.ld.sext = sext i32 %T30.ld to i64, !tcg.op !30
  store i64 %T30.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !30
; ======== TCG [31] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr15 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !31
  %T31.ld = load i64, ptr %T18.tmp7.ptr15, align 8, !tcg.op !31
  store i64 %T31.ld, ptr %tmp8.stack, align 8, !tcg.op !31
; ======== TCG [32] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr16 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !32
  %T32.ld = load i64, ptr %T18.tmp7.ptr16, align 2, !tcg.op !32
  store i64 %T32.ld, ptr %tmp8.stack, align 8, !tcg.op !32
; ======== TCG [33] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr17 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !33
  %T33.ld = load i64, ptr %T18.tmp7.ptr17, align 4, !tcg.op !33
  store i64 %T33.ld, ptr %tmp8.stack, align 8, !tcg.op !33
; ======== TCG [34] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr18 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !34
  %T34.ld = load i64, ptr %T18.tmp7.ptr18, align 8, !tcg.op !34
  store i64 %T34.ld, ptr %tmp8.stack, align 8, !tcg.op !34
; ======== TCG [35] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr19 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !35
  %T35.ld = load i64, ptr %T18.tmp7.ptr19, align 16, !tcg.op !35
  store i64 %T35.ld, ptr %tmp8.stack, align 8, !tcg.op !35
; ======== TCG [36] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr20 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !36
  %T36.ld = load i64, ptr %T18.tmp7.ptr20, align 32, !tcg.op !36
  store i64 %T36.ld, ptr %tmp8.stack, align 8, !tcg.op !36
; ======== TCG [37] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr21 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !37
  %T37.ld = load i64, ptr %T18.tmp7.ptr21, align 64, !tcg.op !37
  store i64 %T37.ld, ptr %tmp8.stack, align 8, !tcg.op !37
; ======== TCG [38] qemu_ld_i32 [t9],t7,attr,0x2 ========
  %T18.tmp7.ptr22 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !38
  %T38.ld = load i8, ptr %T18.tmp7.ptr22, align 1, !tcg.op !38
  %T38.ld.sext = zext i8 %T38.ld to i32, !tcg.op !38
  store i32 %T38.ld.sext, ptr %tmp9.stack, align 8, !tcg.op !38
; ======== TCG [39] qemu_ld_i32 [t9],t7,attr,0x2 ========
  %T18.tmp7.ptr23 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !39
  %T39.ld = load i8, ptr %T18.tmp7.ptr23, align 1, !tcg.op !39
  %T39.ld.sext = sext i8 %T39.ld to i32, !tcg.op !39
  store i32 %T39.ld.sext, ptr %tmp9.stack, align 8, !tcg.op !39
; ======== TCG [40] qemu_ld_i32 [t9],t7,attr,0x2 ========
  %T18.tmp7.ptr24 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !40
  %T40.ld = load i16, ptr %T18.tmp7.ptr24, align 1, !tcg.op !40
  %T40.ld.sext = zext i16 %T40.ld to i32, !tcg.op !40
  store i32 %T40.ld.sext, ptr %tmp9.stack, align 8, !tcg.op !40
; ======== TCG [41] qemu_ld_i32 [t9],t7,attr,0x2 ========
  %T18.tmp7.ptr25 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !41
  %T41.ld = load i16, ptr %T18.tmp7.ptr25, align 1, !tcg.op !41
  %T41.ld.sext = sext i16 %T41.ld to i32, !tcg.op !41
  store i32 %T41.ld.sext, ptr %tmp9.stack, align 8, !tcg.op !41
; ======== TCG [42] qemu_ld_i32 [t9],t7,attr,0x2 ========
  %T18.tmp7.ptr26 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !42
  %T42.ld = load i32, ptr %T18.tmp7.ptr26, align 1, !tcg.op !42
  store i32 %T42.ld, ptr %tmp9.stack, align 8, !tcg.op !42
; ======== TCG [43] qemu_ld_i32 [t9],t7,attr,0x2 ========
  %T18.tmp7.ptr27 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !43
  %T43.ld = load i32, ptr %T18.tmp7.ptr27, align 1, !tcg.op !43
  store i32 %T43.ld, ptr %tmp9.stack, align 8, !tcg.op !43
; ======== TCG [44] qemu_ld_i32 [t9],t7,attr,0x2 ========
  %T18.tmp7.ptr28 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !44
  %T44.ld = load i64, ptr %T18.tmp7.ptr28, align 1, !tcg.op !44
  %T44.ld.trunc = trunc i64 %T44.ld to i32, !tcg.op !44
  store i32 %T44.ld.trunc, ptr %tmp9.stack, align 8, !tcg.op !44
; ======== TCG [45] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr29 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !45
  %T45.ld = load i64, ptr %T18.tmp7.ptr29, align 8, !tcg.op !45
  store i64 %T45.ld, ptr %tmp8.stack, align 8, !tcg.op !45
; ======== TCG [46] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr30 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !46
  %T46.ld = load i64, ptr %T18.tmp7.ptr30, align 8, !tcg.op !46
  store i64 %T46.ld, ptr %tmp8.stack, align 8, !tcg.op !46
; ======== TCG [47] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr31 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !47
  %T47.ld = load i64, ptr %T18.tmp7.ptr31, align 8, !tcg.op !47
  store i64 %T47.ld, ptr %tmp8.stack, align 8, !tcg.op !47
; ======== TCG [48] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr32 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !48
  %T48.ld = load i64, ptr %T18.tmp7.ptr32, align 8, !tcg.op !48
  store i64 %T48.ld, ptr %tmp8.stack, align 8, !tcg.op !48
; ======== TCG [49] qemu_ld_i64 [t8],t7,attr,0x2 ========
  %T18.tmp7.ptr33 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !49
  %T49.ld = load i64, ptr %T18.tmp7.ptr33, align 8, !tcg.op !49
  store i64 %T49.ld, ptr %tmp8.stack, align 8, !tcg.op !49
; ======== TCG [50] qemu_ld2_i128 [t10],[t11],t7,attr,0x2 ========
  %T18.tmp7.ptr34 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !50
  %T50.ld = load <2 x i64>, ptr %T18.tmp7.ptr34, align 1, !tcg.op !50
  %T50.ld.ee = extractelement <2 x i64> %T50.ld, i64 0, !tcg.op !50
  store i64 %T50.ld.ee, ptr %tmp10.stack, align 8, !tcg.op !50
  %T50.ld.ee35 = extractelement <2 x i64> %T50.ld, i64 1, !tcg.op !50
  store i64 %T50.ld.ee35, ptr %tmp11.stack, align 8, !tcg.op !50
}

attributes #0 = { noinline nounwind "target-features"="+neon" }

!0 = !{!"[0] ld8u_i32 [t0],env:0xac"}
!1 = !{!"[1] ld8u_i64 [t0],env:0xac"}
!2 = !{!"[2] ld16u_i32 [t0],env:0xac"}
!3 = !{!"[3] ld16u_i64 [t0],env:0xac"}
!4 = !{!"[4] ld32u_i64 [t0],env:0xac"}
!5 = !{!"[5] ld8s_i32 [t0],env:0xac"}
!6 = !{!"[6] ld8s_i64 [t0],env:0xac"}
!7 = !{!"[7] ld16s_i32 [t0],env:0xac"}
!8 = !{!"[8] ld16s_i64 [t0],env:0xac"}
!9 = !{!"[9] ld32s_i64 [t0],env:0xac"}
!10 = !{!"[10] ld32s_i64 [t2],v18,0x4"}
!11 = !{!"[11] ld_vec v128,e8,[t3],env:0xb60"}
!12 = !{!"[12] ld_i32 [t4],env:0xd0"}
!13 = !{!"[13] ld_i64 [t5],env:0x88"}
!14 = !{!"[14] ld_i64 [t6],v4"}
!15 = !{!"[15] ld_i64 [t6],v4:o4"}
!16 = !{!"[16] ld_i64 [t6],v4:o8"}
!17 = !{!"[17] add_i64 [t7],rsp,0x0"}
!18 = !{!"[18] qemu_ld_i64 [t8],t7,attr,0x2"}
!19 = !{!"[19] qemu_ld_i64 [t8],t7,attr,0x2"}
!20 = !{!"[20] qemu_ld_i64 [t8],t7,attr,0x2"}
!21 = !{!"[21] qemu_ld_i64 [t8],t7,attr,0x2"}
!22 = !{!"[22] qemu_ld_i64 [t8],t7,attr,0x2"}
!23 = !{!"[23] qemu_ld_i64 [t8],t7,attr,0x2"}
!24 = !{!"[24] qemu_ld_i64 [t8],t7,attr,0x2"}
!25 = !{!"[25] qemu_ld_i64 [t8],t7,attr,0x2"}
!26 = !{!"[26] qemu_ld_i64 [t8],t7,attr,0x2"}
!27 = !{!"[27] qemu_ld_i64 [t8],t7,attr,0x2"}
!28 = !{!"[28] qemu_ld_i64 [t8],t7,attr,0x2"}
!29 = !{!"[29] qemu_ld_i64 [t8],t7,attr,0x2"}
!30 = !{!"[30] qemu_ld_i64 [t8],t7,attr,0x2"}
!31 = !{!"[31] qemu_ld_i64 [t8],t7,attr,0x2"}
!32 = !{!"[32] qemu_ld_i64 [t8],t7,attr,0x2"}
!33 = !{!"[33] qemu_ld_i64 [t8],t7,attr,0x2"}
!34 = !{!"[34] qemu_ld_i64 [t8],t7,attr,0x2"}
!35 = !{!"[35] qemu_ld_i64 [t8],t7,attr,0x2"}
!36 = !{!"[36] qemu_ld_i64 [t8],t7,attr,0x2"}
!37 = !{!"[37] qemu_ld_i64 [t8],t7,attr,0x2"}
!38 = !{!"[38] qemu_ld_i32 [t9],t7,attr,0x2"}
!39 = !{!"[39] qemu_ld_i32 [t9],t7,attr,0x2"}
!40 = !{!"[40] qemu_ld_i32 [t9],t7,attr,0x2"}
!41 = !{!"[41] qemu_ld_i32 [t9],t7,attr,0x2"}
!42 = !{!"[42] qemu_ld_i32 [t9],t7,attr,0x2"}
!43 = !{!"[43] qemu_ld_i32 [t9],t7,attr,0x2"}
!44 = !{!"[44] qemu_ld_i32 [t9],t7,attr,0x2"}
!45 = !{!"[45] qemu_ld_i64 [t8],t7,attr,0x2"}
!46 = !{!"[46] qemu_ld_i64 [t8],t7,attr,0x2"}
!47 = !{!"[47] qemu_ld_i64 [t8],t7,attr,0x2"}
!48 = !{!"[48] qemu_ld_i64 [t8],t7,attr,0x2"}
!49 = !{!"[49] qemu_ld_i64 [t8],t7,attr,0x2"}
!50 = !{!"[50] qemu_ld2_i128 [t10],[t11],t7,attr,0x2"}
