; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h) #0 section ".text.Fx0" {
entry:
  %v1.stack = alloca <2 x i64>, align 16
  store <2 x i64> %ymm0_h, ptr %v1.stack, align 16
  %v19.stack = alloca <2 x i64>, align 16
  store <2 x i64> %ymm9_h, ptr %v19.stack, align 16
  %rcx.stack = alloca i64, align 8
  store i64 %rcx, ptr %rcx.stack, align 8
  %rax.stack = alloca i64, align 8
  store i64 %rax, ptr %rax.stack, align 8
  %rsp.stack = alloca i64, align 8
  store i64 %rsp, ptr %rsp.stack, align 8
  %v0.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm0, ptr %v0.stack, align 16
  %v4.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm2, ptr %v4.stack, align 16
  %v18.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm9, ptr %v18.stack, align 16
  %v26.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm13, ptr %v26.stack, align 16
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
  %tmp12.stack = alloca <2 x i64>, align 16
  %tmp13.stack = alloca <2 x i64>, align 16
  %tmp14.stack = alloca <2 x i64>, align 16
  %env = call i64 asm sideeffect "mov $0, x25", "=r"()
; ======== TCG [0] ld8u_i32 [t0],env:0xab ========
  %T0.addr.envoff = add i64 %env, 171, !tcg.op !0
  %T0.addr.envoff.ptr = inttoptr i64 %T0.addr.envoff to ptr, !tcg.op !0
  %T0.envval = load i8, ptr %T0.addr.envoff.ptr, align 1, !tcg.op !0
  %T0.out = zext i8 %T0.envval to i32, !tcg.op !0
  %T0.out.zext = zext i32 %T0.out to i64, !tcg.op !0
  store i64 %T0.out.zext, ptr %tmp0.stack, align 8, !tcg.op !0
; ======== TCG [1] ld8u_i64 [t0],env:0xac ========
  %T1.addr.envoff = add i64 %env, 172, !tcg.op !1
  %T1.addr.envoff.ptr = inttoptr i64 %T1.addr.envoff to ptr, !tcg.op !1
  %T1.envval = load i8, ptr %T1.addr.envoff.ptr, align 4, !tcg.op !1
  %T1.out = zext i8 %T1.envval to i64, !tcg.op !1
  store i64 %T1.out, ptr %tmp0.stack, align 8, !tcg.op !1
; ======== TCG [2] ld16u_i32 [t0],env:0xab ========
  %T2.addr.envoff = add i64 %env, 171, !tcg.op !2
  %T2.addr.envoff.ptr = inttoptr i64 %T2.addr.envoff to ptr, !tcg.op !2
  %T2.envval = load i16, ptr %T2.addr.envoff.ptr, align 1, !tcg.op !2
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
; ======== TCG [5] ld8s_i32 [t0],env:0xab ========
  %T5.addr.envoff = add i64 %env, 171, !tcg.op !5
  %T5.addr.envoff.ptr = inttoptr i64 %T5.addr.envoff to ptr, !tcg.op !5
  %T5.envval = load i8, ptr %T5.addr.envoff.ptr, align 1, !tcg.op !5
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
  %T15.addr.envoff1 = add i64 %env, 992, !tcg.op !15
  %T15.addr.envoff1.ptr = inttoptr i64 %T15.addr.envoff1 to ptr, !tcg.op !15
  %T15.envval = load <2 x i64>, ptr %T15.addr.envoff1.ptr, align 8, !tcg.op !15
  store <2 x i64> %T15.envval, ptr %v4.stack, align 16, !tcg.op !15
  %T15.addr.envoff2 = add i64 %env, 996, !tcg.op !15
  %T15.addr.envoff2.ptr = inttoptr i64 %T15.addr.envoff2 to ptr, !tcg.op !15
  %T15.envval3 = load i64, ptr %T15.addr.envoff2.ptr, align 4, !tcg.op !15
  store i64 %T15.envval3, ptr %tmp6.stack, align 8, !tcg.op !15
; ======== TCG [16] ld_i64 [t6],v4:o8 ========
  %T16.v4 = load <2 x i64>, ptr %v4.stack, align 16, !tcg.op !16
  %T16.v4.ee = extractelement <2 x i64> %T16.v4, i64 1, !tcg.op !16
  store i64 %T16.v4.ee, ptr %tmp6.stack, align 8, !tcg.op !16
; ======== TCG [17] add_i64 [t7],rsp,0x0 ========
  %T17.rsp = load i64, ptr %rsp.stack, align 8, !tcg.op !17
  %T17.out = add i64 %T17.rsp, 0, !tcg.op !17
  store i64 %T17.out, ptr %tmp7.stack, align 8, !tcg.op !17
; ======== TCG [18] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2 ========
  %T18.tmp7 = load i64, ptr %tmp7.stack, align 8, !tcg.op !18
  %T18.tmp7.ptr = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !18
  %T18.ld = load i8, ptr %T18.tmp7.ptr, align 1, !tcg.op !18
  %T18.ld.sext = zext i8 %T18.ld to i64, !tcg.op !18
  store i64 %T18.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !18
; ======== TCG [19] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:INVALID_ALIGNMENT:ZERO:SRC1B,0x2 ========
  %T18.tmp7.ptr4 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !19
  %T19.ld = load i8, ptr %T18.tmp7.ptr4, align 1, !tcg.op !19
  %T19.ld.sext = zext i8 %T19.ld to i64, !tcg.op !19
  store i64 %T19.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !19
; ======== TCG [20] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2 ========
  %T18.tmp7.ptr5 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !20
  %T20.ld = load i8, ptr %T18.tmp7.ptr5, align 1, !tcg.op !20
  %T20.ld.sext = sext i8 %T20.ld to i64, !tcg.op !20
  store i64 %T20.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !20
; ======== TCG [21] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2 ========
  %T18.tmp7.ptr6 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !21
  %T21.ld = load i16, ptr %T18.tmp7.ptr6, align 1, !tcg.op !21
  %T21.ld.sext = zext i16 %T21.ld to i64, !tcg.op !21
  store i64 %T21.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !21
; ======== TCG [22] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2 ========
  %T18.tmp7.ptr7 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !22
  %T22.ld = load i16, ptr %T18.tmp7.ptr7, align 1, !tcg.op !22
  %T22.ld.sext = sext i16 %T22.ld to i64, !tcg.op !22
  store i64 %T22.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !22
; ======== TCG [23] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2 ========
  %T18.tmp7.ptr8 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !23
  %T23.ld = load i32, ptr %T18.tmp7.ptr8, align 1, !tcg.op !23
  %T23.ld.sext = zext i32 %T23.ld to i64, !tcg.op !23
  store i64 %T23.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !23
; ======== TCG [24] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2 ========
  %T18.tmp7.ptr9 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !24
  %T24.ld = load i32, ptr %T18.tmp7.ptr9, align 1, !tcg.op !24
  %T24.ld.sext = sext i32 %T24.ld to i64, !tcg.op !24
  store i64 %T24.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !24
; ======== TCG [25] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr10 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !25
  %T25.ld = load i64, ptr %T18.tmp7.ptr10, align 1, !tcg.op !25
  store i64 %T25.ld, ptr %tmp8.stack, align 8, !tcg.op !25
; ======== TCG [26] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC1B,0x2 ========
  %T18.tmp7.ptr11 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !26
  %T26.ld = load i8, ptr %T18.tmp7.ptr11, align 1, !tcg.op !26
  %T26.ld.sext = zext i8 %T26.ld to i64, !tcg.op !26
  store i64 %T26.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !26
; ======== TCG [27] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC1B,0x2 ========
  %T18.tmp7.ptr12 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !27
  %T27.ld = load i8, ptr %T18.tmp7.ptr12, align 1, !tcg.op !27
  %T27.ld.sext = sext i8 %T27.ld to i64, !tcg.op !27
  store i64 %T27.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !27
; ======== TCG [28] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC2B,0x2 ========
  %T18.tmp7.ptr13 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !28
  %T28.ld = load i16, ptr %T18.tmp7.ptr13, align 2, !tcg.op !28
  %T28.ld.sext = zext i16 %T28.ld to i64, !tcg.op !28
  store i64 %T28.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !28
; ======== TCG [29] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC2B,0x2 ========
  %T18.tmp7.ptr14 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !29
  %T29.ld = load i16, ptr %T18.tmp7.ptr14, align 2, !tcg.op !29
  %T29.ld.sext = sext i16 %T29.ld to i64, !tcg.op !29
  store i64 %T29.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !29
; ======== TCG [30] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC4B,0x2 ========
  %T18.tmp7.ptr15 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !30
  %T30.ld = load i32, ptr %T18.tmp7.ptr15, align 4, !tcg.op !30
  %T30.ld.sext = zext i32 %T30.ld to i64, !tcg.op !30
  store i64 %T30.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !30
; ======== TCG [31] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC4B,0x2 ========
  %T18.tmp7.ptr16 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !31
  %T31.ld = load i32, ptr %T18.tmp7.ptr16, align 4, !tcg.op !31
  %T31.ld.sext = sext i32 %T31.ld to i64, !tcg.op !31
  store i64 %T31.ld.sext, ptr %tmp8.stack, align 8, !tcg.op !31
; ======== TCG [32] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr17 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !32
  %T32.ld = load i64, ptr %T18.tmp7.ptr17, align 8, !tcg.op !32
  store i64 %T32.ld, ptr %tmp8.stack, align 8, !tcg.op !32
; ======== TCG [33] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_2:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr18 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !33
  %T33.ld = load i64, ptr %T18.tmp7.ptr18, align 2, !tcg.op !33
  store i64 %T33.ld, ptr %tmp8.stack, align 8, !tcg.op !33
; ======== TCG [34] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_4:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr19 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !34
  %T34.ld = load i64, ptr %T18.tmp7.ptr19, align 4, !tcg.op !34
  store i64 %T34.ld, ptr %tmp8.stack, align 8, !tcg.op !34
; ======== TCG [35] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr20 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !35
  %T35.ld = load i64, ptr %T18.tmp7.ptr20, align 8, !tcg.op !35
  store i64 %T35.ld, ptr %tmp8.stack, align 8, !tcg.op !35
; ======== TCG [36] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr21 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !36
  %T36.ld = load i64, ptr %T18.tmp7.ptr21, align 16, !tcg.op !36
  store i64 %T36.ld, ptr %tmp8.stack, align 8, !tcg.op !36
; ======== TCG [37] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_32:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr22 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !37
  %T37.ld = load i64, ptr %T18.tmp7.ptr22, align 32, !tcg.op !37
  store i64 %T37.ld, ptr %tmp8.stack, align 8, !tcg.op !37
; ======== TCG [38] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_64:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr23 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !38
  %T38.ld = load i64, ptr %T18.tmp7.ptr23, align 64, !tcg.op !38
  store i64 %T38.ld, ptr %tmp8.stack, align 8, !tcg.op !38
; ======== TCG [39] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2 ========
  %T18.tmp7.ptr24 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !39
  %T39.ld = load i8, ptr %T18.tmp7.ptr24, align 1, !tcg.op !39
  %T39.ld.sext = zext i8 %T39.ld to i32, !tcg.op !39
  store i32 %T39.ld.sext, ptr %tmp9.stack, align 8, !tcg.op !39
; ======== TCG [40] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2 ========
  %T18.tmp7.ptr25 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !40
  %T40.ld = load i8, ptr %T18.tmp7.ptr25, align 1, !tcg.op !40
  %T40.ld.sext = sext i8 %T40.ld to i32, !tcg.op !40
  store i32 %T40.ld.sext, ptr %tmp9.stack, align 8, !tcg.op !40
; ======== TCG [41] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2 ========
  %T18.tmp7.ptr26 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !41
  %T41.ld = load i16, ptr %T18.tmp7.ptr26, align 1, !tcg.op !41
  %T41.ld.sext = zext i16 %T41.ld to i32, !tcg.op !41
  store i32 %T41.ld.sext, ptr %tmp9.stack, align 8, !tcg.op !41
; ======== TCG [42] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2 ========
  %T18.tmp7.ptr27 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !42
  %T42.ld = load i16, ptr %T18.tmp7.ptr27, align 1, !tcg.op !42
  %T42.ld.sext = sext i16 %T42.ld to i32, !tcg.op !42
  store i32 %T42.ld.sext, ptr %tmp9.stack, align 8, !tcg.op !42
; ======== TCG [43] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2 ========
  %T18.tmp7.ptr28 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !43
  %T43.ld = load i32, ptr %T18.tmp7.ptr28, align 1, !tcg.op !43
  store i32 %T43.ld, ptr %tmp9.stack, align 8, !tcg.op !43
; ======== TCG [44] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2 ========
  %T18.tmp7.ptr29 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !44
  %T44.ld = load i32, ptr %T18.tmp7.ptr29, align 1, !tcg.op !44
  store i32 %T44.ld, ptr %tmp9.stack, align 8, !tcg.op !44
; ======== TCG [45] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr30 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !45
  %T45.ld = load i64, ptr %T18.tmp7.ptr30, align 1, !tcg.op !45
  %T45.ld.trunc = trunc i64 %T45.ld to i32, !tcg.op !45
  store i32 %T45.ld.trunc, ptr %tmp9.stack, align 8, !tcg.op !45
; ======== TCG [46] qemu_ld_i64 [t8],t7,attr-stg:ATOM_NONE:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr31 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !46
  %T46.ld = load i64, ptr %T18.tmp7.ptr31, align 8, !tcg.op !46
  store i64 %T46.ld, ptr %tmp8.stack, align 8, !tcg.op !46
; ======== TCG [47] qemu_ld_i64 [t8],t7,attr-stg:ATOM_SUBALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr32 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !47
  %T47.ld = load i64, ptr %T18.tmp7.ptr32, align 8, !tcg.op !47
  store i64 %T47.ld, ptr %tmp8.stack, align 8, !tcg.op !47
; ======== TCG [48] qemu_ld_i64 [t8],t7,attr-stg:ATOM_WITHIN16_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr33 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !48
  %T48.ld = load i64, ptr %T18.tmp7.ptr33, align 8, !tcg.op !48
  store i64 %T48.ld, ptr %tmp8.stack, align 8, !tcg.op !48
; ======== TCG [49] qemu_ld_i64 [t8],t7,attr-stg:ATOM_WITHIN16:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr34 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !49
  %T49.ld = load i64, ptr %T18.tmp7.ptr34, align 8, !tcg.op !49
  store i64 %T49.ld, ptr %tmp8.stack, align 8, !tcg.op !49
; ======== TCG [50] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr35 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !50
  %T50.ld = load i64, ptr %T18.tmp7.ptr35, align 8, !tcg.op !50
  store i64 %T50.ld, ptr %tmp8.stack, align 8, !tcg.op !50
; ======== TCG [51] qemu_ld2_i128 [t10],[t11],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC16B,0x2 ========
  %T18.tmp7.ptr36 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !51
  %T51.ld = load <2 x i64>, ptr %T18.tmp7.ptr36, align 1, !tcg.op !51
  %T51.ld.ee = extractelement <2 x i64> %T51.ld, i64 0, !tcg.op !51
  store i64 %T51.ld.ee, ptr %tmp10.stack, align 8, !tcg.op !51
  %T51.ld.ee37 = extractelement <2 x i64> %T51.ld, i64 1, !tcg.op !51
  store i64 %T51.ld.ee37, ptr %tmp11.stack, align 8, !tcg.op !51
; ======== TCG [52] qemu_ld2_i128 [t10],[t11],t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC16B,0x2 ========
  %T18.tmp7.ptr38 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !52
  %T52.ld = load <2 x i64>, ptr %T18.tmp7.ptr38, align 16, !tcg.op !52
  %T52.ld.ee = extractelement <2 x i64> %T52.ld, i64 0, !tcg.op !52
  store i64 %T52.ld.ee, ptr %tmp10.stack, align 8, !tcg.op !52
  %T52.ld.ee39 = extractelement <2 x i64> %T52.ld, i64 1, !tcg.op !52
  store i64 %T52.ld.ee39, ptr %tmp11.stack, align 8, !tcg.op !52
; ======== TCG [53] st8_i32 t0,env:0xac ========
  %T53.tmp0 = load i64, ptr %tmp0.stack, align 8, !tcg.op !53
  %T53.tmp0.trunc = trunc i64 %T53.tmp0 to i32, !tcg.op !53
  %T53.tmp0.trunc.trunc = trunc i32 %T53.tmp0.trunc to i8, !tcg.op !53
  %T53.addr.envoff = add i64 %env, 172, !tcg.op !53
  %T53.addr.envoff.ptr = inttoptr i64 %T53.addr.envoff to ptr, !tcg.op !53
  store i8 %T53.tmp0.trunc.trunc, ptr %T53.addr.envoff.ptr, align 4, !tcg.op !53
; ======== TCG [54] st8_i64 t0,env:0xac ========
  %T53.tmp0.trunc40 = trunc i64 %T53.tmp0 to i8, !tcg.op !54
  %T54.addr.envoff = add i64 %env, 172, !tcg.op !54
  %T54.addr.envoff.ptr = inttoptr i64 %T54.addr.envoff to ptr, !tcg.op !54
  store i8 %T53.tmp0.trunc40, ptr %T54.addr.envoff.ptr, align 4, !tcg.op !54
; ======== TCG [55] st16_i32 t0,env:0xac ========
  %T53.tmp0.trunc41 = trunc i64 %T53.tmp0 to i32, !tcg.op !55
  %T53.tmp0.trunc41.trunc = trunc i32 %T53.tmp0.trunc41 to i16, !tcg.op !55
  %T55.addr.envoff = add i64 %env, 172, !tcg.op !55
  %T55.addr.envoff.ptr = inttoptr i64 %T55.addr.envoff to ptr, !tcg.op !55
  store i16 %T53.tmp0.trunc41.trunc, ptr %T55.addr.envoff.ptr, align 4, !tcg.op !55
; ======== TCG [56] st16_i64 t0,env:0xac ========
  %T53.tmp0.trunc42 = trunc i64 %T53.tmp0 to i16, !tcg.op !56
  %T56.addr.envoff = add i64 %env, 172, !tcg.op !56
  %T56.addr.envoff.ptr = inttoptr i64 %T56.addr.envoff to ptr, !tcg.op !56
  store i16 %T53.tmp0.trunc42, ptr %T56.addr.envoff.ptr, align 4, !tcg.op !56
; ======== TCG [57] st32_i64 t0,env:0xac ========
  %T53.tmp0.trunc43 = trunc i64 %T53.tmp0 to i32, !tcg.op !57
  %T57.addr.envoff = add i64 %env, 172, !tcg.op !57
  %T57.addr.envoff.ptr = inttoptr i64 %T57.addr.envoff to ptr, !tcg.op !57
  store i32 %T53.tmp0.trunc43, ptr %T57.addr.envoff.ptr, align 4, !tcg.op !57
; ======== TCG [58] st_i32 t0,env:0xac ========
  %T53.tmp0.trunc44 = trunc i64 %T53.tmp0 to i32, !tcg.op !58
  %T58.addr.envoff = add i64 %env, 172, !tcg.op !58
  %T58.addr.envoff.ptr = inttoptr i64 %T58.addr.envoff to ptr, !tcg.op !58
  store i32 %T53.tmp0.trunc44, ptr %T58.addr.envoff.ptr, align 4, !tcg.op !58
; ======== TCG [59] st_i64 t0,env:0xac ========
  %T59.addr.envoff = add i64 %env, 172, !tcg.op !59
  %T59.addr.envoff.ptr = inttoptr i64 %T59.addr.envoff to ptr, !tcg.op !59
  store i64 %T53.tmp0, ptr %T59.addr.envoff.ptr, align 4, !tcg.op !59
; ======== TCG [60] st32_i64 t2,v18,0x4 ========
  %T60.tmp2 = load i64, ptr %tmp2.stack, align 8, !tcg.op !60
  %T60.tmp2.trunc = trunc i64 %T60.tmp2 to i32, !tcg.op !60
  %T60.tmp2.trunc.ie = insertelement <4 x i32> zeroinitializer, i32 %T60.tmp2.trunc, i64 1, !tcg.op !60
  %T60.tmp2.trunc.ie.bc = bitcast <4 x i32> %T60.tmp2.trunc.ie to <2 x i64>, !tcg.op !60
  store <2 x i64> %T60.tmp2.trunc.ie.bc, ptr %v18.stack, align 16, !tcg.op !60
; ======== TCG [61] st32_i64 t2,v18,0x2 ========
  %T60.tmp2.trunc45 = trunc i64 %T60.tmp2 to i32, !tcg.op !61
  %T61.addr.envoff = add i64 %env, 1442, !tcg.op !61
  %T61.addr.envoff.ptr = inttoptr i64 %T61.addr.envoff to ptr, !tcg.op !61
  store i32 %T60.tmp2.trunc45, ptr %T61.addr.envoff.ptr, align 2, !tcg.op !61
  %T61.addr.envoff46 = add i64 %env, 1440, !tcg.op !61
  %T61.addr.envoff46.ptr = inttoptr i64 %T61.addr.envoff46 to ptr, !tcg.op !61
  %T61.envval = load <2 x i64>, ptr %T61.addr.envoff46.ptr, align 8, !tcg.op !61
  store <2 x i64> %T61.envval, ptr %v18.stack, align 16, !tcg.op !61
; ======== TCG [62] add_vec v128,e64,[t12],v18,v18 ========
  %T62.v18 = load <2 x i64>, ptr %v18.stack, align 16, !tcg.op !62
  %T62.out = add <2 x i64> %T62.v18, %T62.v18, !tcg.op !62
  store <2 x i64> %T62.out, ptr %tmp12.stack, align 16, !tcg.op !62
; ======== TCG [63] st_i64 t0,env ========
  %T63.addr.envoff = add i64 %env, 0, !tcg.op !63
  %T63.addr.envoff.ptr = inttoptr i64 %T63.addr.envoff to ptr, !tcg.op !63
  store i64 %T53.tmp0, ptr %T63.addr.envoff.ptr, align 8, !tcg.op !63
  %T63.addr.envoff47 = add i64 %env, 0, !tcg.op !63
  %T63.addr.envoff47.ptr = inttoptr i64 %T63.addr.envoff47 to ptr, !tcg.op !63
  %T63.envval = load i64, ptr %T63.addr.envoff47.ptr, align 8, !tcg.op !63
  store i64 %T63.envval, ptr %rax.stack, align 8, !tcg.op !63
; ======== TCG [64] st_i64 t0,env:0x1 ========
  %T64.addr.envoff = add i64 %env, 1, !tcg.op !64
  %T64.addr.envoff.ptr = inttoptr i64 %T64.addr.envoff to ptr, !tcg.op !64
  store i64 %T53.tmp0, ptr %T64.addr.envoff.ptr, align 1, !tcg.op !64
  %T64.addr.envoff48 = add i64 %env, 0, !tcg.op !64
  %T64.addr.envoff48.ptr = inttoptr i64 %T64.addr.envoff48 to ptr, !tcg.op !64
  %T64.envval = load i64, ptr %T64.addr.envoff48.ptr, align 8, !tcg.op !64
  store i64 %T64.envval, ptr %rax.stack, align 8, !tcg.op !64
  %T64.addr.envoff49 = add i64 %env, 8, !tcg.op !64
  %T64.addr.envoff49.ptr = inttoptr i64 %T64.addr.envoff49 to ptr, !tcg.op !64
  %T64.envval50 = load i64, ptr %T64.addr.envoff49.ptr, align 8, !tcg.op !64
  store i64 %T64.envval50, ptr %rcx.stack, align 8, !tcg.op !64
; ======== TCG [65] st_i64 t0,env:0x2 ========
  %T65.addr.envoff = add i64 %env, 2, !tcg.op !65
  %T65.addr.envoff.ptr = inttoptr i64 %T65.addr.envoff to ptr, !tcg.op !65
  store i64 %T53.tmp0, ptr %T65.addr.envoff.ptr, align 2, !tcg.op !65
  %T65.addr.envoff51 = add i64 %env, 0, !tcg.op !65
  %T65.addr.envoff51.ptr = inttoptr i64 %T65.addr.envoff51 to ptr, !tcg.op !65
  %T65.envval = load i64, ptr %T65.addr.envoff51.ptr, align 8, !tcg.op !65
  store i64 %T65.envval, ptr %rax.stack, align 8, !tcg.op !65
  %T65.addr.envoff52 = add i64 %env, 8, !tcg.op !65
  %T65.addr.envoff52.ptr = inttoptr i64 %T65.addr.envoff52 to ptr, !tcg.op !65
  %T65.envval53 = load i64, ptr %T65.addr.envoff52.ptr, align 8, !tcg.op !65
  store i64 %T65.envval53, ptr %rcx.stack, align 8, !tcg.op !65
; ======== TCG [66] st_i64 t0,env:0x3 ========
  %T66.addr.envoff = add i64 %env, 3, !tcg.op !66
  %T66.addr.envoff.ptr = inttoptr i64 %T66.addr.envoff to ptr, !tcg.op !66
  store i64 %T53.tmp0, ptr %T66.addr.envoff.ptr, align 1, !tcg.op !66
  %T66.addr.envoff54 = add i64 %env, 0, !tcg.op !66
  %T66.addr.envoff54.ptr = inttoptr i64 %T66.addr.envoff54 to ptr, !tcg.op !66
  %T66.envval = load i64, ptr %T66.addr.envoff54.ptr, align 8, !tcg.op !66
  store i64 %T66.envval, ptr %rax.stack, align 8, !tcg.op !66
  %T66.addr.envoff55 = add i64 %env, 8, !tcg.op !66
  %T66.addr.envoff55.ptr = inttoptr i64 %T66.addr.envoff55 to ptr, !tcg.op !66
  %T66.envval56 = load i64, ptr %T66.addr.envoff55.ptr, align 8, !tcg.op !66
  store i64 %T66.envval56, ptr %rcx.stack, align 8, !tcg.op !66
; ======== TCG [67] st_i64 t0,env:0x4 ========
  %T67.addr.envoff = add i64 %env, 4, !tcg.op !67
  %T67.addr.envoff.ptr = inttoptr i64 %T67.addr.envoff to ptr, !tcg.op !67
  store i64 %T53.tmp0, ptr %T67.addr.envoff.ptr, align 4, !tcg.op !67
  %T67.addr.envoff57 = add i64 %env, 0, !tcg.op !67
  %T67.addr.envoff57.ptr = inttoptr i64 %T67.addr.envoff57 to ptr, !tcg.op !67
  %T67.envval = load i64, ptr %T67.addr.envoff57.ptr, align 8, !tcg.op !67
  store i64 %T67.envval, ptr %rax.stack, align 8, !tcg.op !67
  %T67.addr.envoff58 = add i64 %env, 8, !tcg.op !67
  %T67.addr.envoff58.ptr = inttoptr i64 %T67.addr.envoff58 to ptr, !tcg.op !67
  %T67.envval59 = load i64, ptr %T67.addr.envoff58.ptr, align 8, !tcg.op !67
  store i64 %T67.envval59, ptr %rcx.stack, align 8, !tcg.op !67
; ======== TCG [68] st_i64 t0,env:0x5 ========
  %T68.addr.envoff = add i64 %env, 5, !tcg.op !68
  %T68.addr.envoff.ptr = inttoptr i64 %T68.addr.envoff to ptr, !tcg.op !68
  store i64 %T53.tmp0, ptr %T68.addr.envoff.ptr, align 1, !tcg.op !68
  %T68.addr.envoff60 = add i64 %env, 0, !tcg.op !68
  %T68.addr.envoff60.ptr = inttoptr i64 %T68.addr.envoff60 to ptr, !tcg.op !68
  %T68.envval = load i64, ptr %T68.addr.envoff60.ptr, align 8, !tcg.op !68
  store i64 %T68.envval, ptr %rax.stack, align 8, !tcg.op !68
  %T68.addr.envoff61 = add i64 %env, 8, !tcg.op !68
  %T68.addr.envoff61.ptr = inttoptr i64 %T68.addr.envoff61 to ptr, !tcg.op !68
  %T68.envval62 = load i64, ptr %T68.addr.envoff61.ptr, align 8, !tcg.op !68
  store i64 %T68.envval62, ptr %rcx.stack, align 8, !tcg.op !68
; ======== TCG [69] st_i64 t0,env:0x6 ========
  %T69.addr.envoff = add i64 %env, 6, !tcg.op !69
  %T69.addr.envoff.ptr = inttoptr i64 %T69.addr.envoff to ptr, !tcg.op !69
  store i64 %T53.tmp0, ptr %T69.addr.envoff.ptr, align 2, !tcg.op !69
  %T69.addr.envoff63 = add i64 %env, 0, !tcg.op !69
  %T69.addr.envoff63.ptr = inttoptr i64 %T69.addr.envoff63 to ptr, !tcg.op !69
  %T69.envval = load i64, ptr %T69.addr.envoff63.ptr, align 8, !tcg.op !69
  store i64 %T69.envval, ptr %rax.stack, align 8, !tcg.op !69
  %T69.addr.envoff64 = add i64 %env, 8, !tcg.op !69
  %T69.addr.envoff64.ptr = inttoptr i64 %T69.addr.envoff64 to ptr, !tcg.op !69
  %T69.envval65 = load i64, ptr %T69.addr.envoff64.ptr, align 8, !tcg.op !69
  store i64 %T69.envval65, ptr %rcx.stack, align 8, !tcg.op !69
; ======== TCG [70] st_i64 t0,env:0x7 ========
  %T70.addr.envoff = add i64 %env, 7, !tcg.op !70
  %T70.addr.envoff.ptr = inttoptr i64 %T70.addr.envoff to ptr, !tcg.op !70
  store i64 %T53.tmp0, ptr %T70.addr.envoff.ptr, align 1, !tcg.op !70
  %T70.addr.envoff66 = add i64 %env, 0, !tcg.op !70
  %T70.addr.envoff66.ptr = inttoptr i64 %T70.addr.envoff66 to ptr, !tcg.op !70
  %T70.envval = load i64, ptr %T70.addr.envoff66.ptr, align 8, !tcg.op !70
  store i64 %T70.envval, ptr %rax.stack, align 8, !tcg.op !70
  %T70.addr.envoff67 = add i64 %env, 8, !tcg.op !70
  %T70.addr.envoff67.ptr = inttoptr i64 %T70.addr.envoff67 to ptr, !tcg.op !70
  %T70.envval68 = load i64, ptr %T70.addr.envoff67.ptr, align 8, !tcg.op !70
  store i64 %T70.envval68, ptr %rcx.stack, align 8, !tcg.op !70
; ======== TCG [71] st_i64 t0,env:0x8 ========
  %T71.addr.envoff = add i64 %env, 8, !tcg.op !71
  %T71.addr.envoff.ptr = inttoptr i64 %T71.addr.envoff to ptr, !tcg.op !71
  store i64 %T53.tmp0, ptr %T71.addr.envoff.ptr, align 8, !tcg.op !71
  %T71.addr.envoff69 = add i64 %env, 8, !tcg.op !71
  %T71.addr.envoff69.ptr = inttoptr i64 %T71.addr.envoff69 to ptr, !tcg.op !71
  %T71.envval = load i64, ptr %T71.addr.envoff69.ptr, align 8, !tcg.op !71
  store i64 %T71.envval, ptr %rcx.stack, align 8, !tcg.op !71
; ======== TCG [72] st_i32 t0,env ========
  %T53.tmp0.trunc70 = trunc i64 %T53.tmp0 to i32, !tcg.op !72
  %T72.addr.envoff = add i64 %env, 0, !tcg.op !72
  %T72.addr.envoff.ptr = inttoptr i64 %T72.addr.envoff to ptr, !tcg.op !72
  store i32 %T53.tmp0.trunc70, ptr %T72.addr.envoff.ptr, align 8, !tcg.op !72
  %T72.addr.envoff71 = add i64 %env, 0, !tcg.op !72
  %T72.addr.envoff71.ptr = inttoptr i64 %T72.addr.envoff71 to ptr, !tcg.op !72
  %T72.envval = load i64, ptr %T72.addr.envoff71.ptr, align 8, !tcg.op !72
  store i64 %T72.envval, ptr %rax.stack, align 8, !tcg.op !72
; ======== TCG [73] st_i32 t0,env:0x1 ========
  %T53.tmp0.trunc72 = trunc i64 %T53.tmp0 to i32, !tcg.op !73
  %T73.addr.envoff = add i64 %env, 1, !tcg.op !73
  %T73.addr.envoff.ptr = inttoptr i64 %T73.addr.envoff to ptr, !tcg.op !73
  store i32 %T53.tmp0.trunc72, ptr %T73.addr.envoff.ptr, align 1, !tcg.op !73
  %T73.addr.envoff73 = add i64 %env, 0, !tcg.op !73
  %T73.addr.envoff73.ptr = inttoptr i64 %T73.addr.envoff73 to ptr, !tcg.op !73
  %T73.envval = load i64, ptr %T73.addr.envoff73.ptr, align 8, !tcg.op !73
  store i64 %T73.envval, ptr %rax.stack, align 8, !tcg.op !73
; ======== TCG [74] st_i32 t0,env:0x2 ========
  %T53.tmp0.trunc74 = trunc i64 %T53.tmp0 to i32, !tcg.op !74
  %T74.addr.envoff = add i64 %env, 2, !tcg.op !74
  %T74.addr.envoff.ptr = inttoptr i64 %T74.addr.envoff to ptr, !tcg.op !74
  store i32 %T53.tmp0.trunc74, ptr %T74.addr.envoff.ptr, align 2, !tcg.op !74
  %T74.addr.envoff75 = add i64 %env, 0, !tcg.op !74
  %T74.addr.envoff75.ptr = inttoptr i64 %T74.addr.envoff75 to ptr, !tcg.op !74
  %T74.envval = load i64, ptr %T74.addr.envoff75.ptr, align 8, !tcg.op !74
  store i64 %T74.envval, ptr %rax.stack, align 8, !tcg.op !74
; ======== TCG [75] st_i32 t0,env:0x3 ========
  %T53.tmp0.trunc76 = trunc i64 %T53.tmp0 to i32, !tcg.op !75
  %T75.addr.envoff = add i64 %env, 3, !tcg.op !75
  %T75.addr.envoff.ptr = inttoptr i64 %T75.addr.envoff to ptr, !tcg.op !75
  store i32 %T53.tmp0.trunc76, ptr %T75.addr.envoff.ptr, align 1, !tcg.op !75
  %T75.addr.envoff77 = add i64 %env, 0, !tcg.op !75
  %T75.addr.envoff77.ptr = inttoptr i64 %T75.addr.envoff77 to ptr, !tcg.op !75
  %T75.envval = load i64, ptr %T75.addr.envoff77.ptr, align 8, !tcg.op !75
  store i64 %T75.envval, ptr %rax.stack, align 8, !tcg.op !75
; ======== TCG [76] st_i32 t0,env:0x4 ========
  %T53.tmp0.trunc78 = trunc i64 %T53.tmp0 to i32, !tcg.op !76
  %T76.addr.envoff = add i64 %env, 4, !tcg.op !76
  %T76.addr.envoff.ptr = inttoptr i64 %T76.addr.envoff to ptr, !tcg.op !76
  store i32 %T53.tmp0.trunc78, ptr %T76.addr.envoff.ptr, align 4, !tcg.op !76
  %T76.addr.envoff79 = add i64 %env, 0, !tcg.op !76
  %T76.addr.envoff79.ptr = inttoptr i64 %T76.addr.envoff79 to ptr, !tcg.op !76
  %T76.envval = load i64, ptr %T76.addr.envoff79.ptr, align 8, !tcg.op !76
  store i64 %T76.envval, ptr %rax.stack, align 8, !tcg.op !76
; ======== TCG [77] st_i32 t0,env:0x5 ========
  %T53.tmp0.trunc80 = trunc i64 %T53.tmp0 to i32, !tcg.op !77
  %T77.addr.envoff = add i64 %env, 5, !tcg.op !77
  %T77.addr.envoff.ptr = inttoptr i64 %T77.addr.envoff to ptr, !tcg.op !77
  store i32 %T53.tmp0.trunc80, ptr %T77.addr.envoff.ptr, align 1, !tcg.op !77
  %T77.addr.envoff81 = add i64 %env, 0, !tcg.op !77
  %T77.addr.envoff81.ptr = inttoptr i64 %T77.addr.envoff81 to ptr, !tcg.op !77
  %T77.envval = load i64, ptr %T77.addr.envoff81.ptr, align 8, !tcg.op !77
  store i64 %T77.envval, ptr %rax.stack, align 8, !tcg.op !77
  %T77.addr.envoff82 = add i64 %env, 8, !tcg.op !77
  %T77.addr.envoff82.ptr = inttoptr i64 %T77.addr.envoff82 to ptr, !tcg.op !77
  %T77.envval83 = load i64, ptr %T77.addr.envoff82.ptr, align 8, !tcg.op !77
  store i64 %T77.envval83, ptr %rcx.stack, align 8, !tcg.op !77
; ======== TCG [78] st_i32 t0,env:0x6 ========
  %T53.tmp0.trunc84 = trunc i64 %T53.tmp0 to i32, !tcg.op !78
  %T78.addr.envoff = add i64 %env, 6, !tcg.op !78
  %T78.addr.envoff.ptr = inttoptr i64 %T78.addr.envoff to ptr, !tcg.op !78
  store i32 %T53.tmp0.trunc84, ptr %T78.addr.envoff.ptr, align 2, !tcg.op !78
  %T78.addr.envoff85 = add i64 %env, 0, !tcg.op !78
  %T78.addr.envoff85.ptr = inttoptr i64 %T78.addr.envoff85 to ptr, !tcg.op !78
  %T78.envval = load i64, ptr %T78.addr.envoff85.ptr, align 8, !tcg.op !78
  store i64 %T78.envval, ptr %rax.stack, align 8, !tcg.op !78
  %T78.addr.envoff86 = add i64 %env, 8, !tcg.op !78
  %T78.addr.envoff86.ptr = inttoptr i64 %T78.addr.envoff86 to ptr, !tcg.op !78
  %T78.envval87 = load i64, ptr %T78.addr.envoff86.ptr, align 8, !tcg.op !78
  store i64 %T78.envval87, ptr %rcx.stack, align 8, !tcg.op !78
; ======== TCG [79] st_i32 t0,env:0x7 ========
  %T53.tmp0.trunc88 = trunc i64 %T53.tmp0 to i32, !tcg.op !79
  %T79.addr.envoff = add i64 %env, 7, !tcg.op !79
  %T79.addr.envoff.ptr = inttoptr i64 %T79.addr.envoff to ptr, !tcg.op !79
  store i32 %T53.tmp0.trunc88, ptr %T79.addr.envoff.ptr, align 1, !tcg.op !79
  %T79.addr.envoff89 = add i64 %env, 0, !tcg.op !79
  %T79.addr.envoff89.ptr = inttoptr i64 %T79.addr.envoff89 to ptr, !tcg.op !79
  %T79.envval = load i64, ptr %T79.addr.envoff89.ptr, align 8, !tcg.op !79
  store i64 %T79.envval, ptr %rax.stack, align 8, !tcg.op !79
  %T79.addr.envoff90 = add i64 %env, 8, !tcg.op !79
  %T79.addr.envoff90.ptr = inttoptr i64 %T79.addr.envoff90 to ptr, !tcg.op !79
  %T79.envval91 = load i64, ptr %T79.addr.envoff90.ptr, align 8, !tcg.op !79
  store i64 %T79.envval91, ptr %rcx.stack, align 8, !tcg.op !79
; ======== TCG [80] st_i32 t0,env:0x8 ========
  %T53.tmp0.trunc92 = trunc i64 %T53.tmp0 to i32, !tcg.op !80
  %T80.addr.envoff = add i64 %env, 8, !tcg.op !80
  %T80.addr.envoff.ptr = inttoptr i64 %T80.addr.envoff to ptr, !tcg.op !80
  store i32 %T53.tmp0.trunc92, ptr %T80.addr.envoff.ptr, align 8, !tcg.op !80
  %T80.addr.envoff93 = add i64 %env, 8, !tcg.op !80
  %T80.addr.envoff93.ptr = inttoptr i64 %T80.addr.envoff93 to ptr, !tcg.op !80
  %T80.envval = load i64, ptr %T80.addr.envoff93.ptr, align 8, !tcg.op !80
  store i64 %T80.envval, ptr %rcx.stack, align 8, !tcg.op !80
; ======== TCG [81] st32_i64 t2,v18 ========
  %T60.tmp2.trunc94 = trunc i64 %T60.tmp2 to i32, !tcg.op !81
  %T60.tmp2.trunc94.ie = insertelement <4 x i32> zeroinitializer, i32 %T60.tmp2.trunc94, i64 0, !tcg.op !81
  %T60.tmp2.trunc94.ie.bc = bitcast <4 x i32> %T60.tmp2.trunc94.ie to <2 x i64>, !tcg.op !81
  store <2 x i64> %T60.tmp2.trunc94.ie.bc, ptr %v18.stack, align 16, !tcg.op !81
; ======== TCG [82] st32_i64 t2,v18,0x1 ========
  %T60.tmp2.trunc95 = trunc i64 %T60.tmp2 to i32, !tcg.op !82
  %T82.addr.envoff = add i64 %env, 1441, !tcg.op !82
  %T82.addr.envoff.ptr = inttoptr i64 %T82.addr.envoff to ptr, !tcg.op !82
  store i32 %T60.tmp2.trunc95, ptr %T82.addr.envoff.ptr, align 1, !tcg.op !82
  %T82.addr.envoff96 = add i64 %env, 1440, !tcg.op !82
  %T82.addr.envoff96.ptr = inttoptr i64 %T82.addr.envoff96 to ptr, !tcg.op !82
  %T82.envval = load <2 x i64>, ptr %T82.addr.envoff96.ptr, align 8, !tcg.op !82
  store <2 x i64> %T82.envval, ptr %v18.stack, align 16, !tcg.op !82
; ======== TCG [83] st32_i64 t2,v18,0x2 ========
  %T60.tmp2.trunc97 = trunc i64 %T60.tmp2 to i32, !tcg.op !83
  %T83.addr.envoff = add i64 %env, 1442, !tcg.op !83
  %T83.addr.envoff.ptr = inttoptr i64 %T83.addr.envoff to ptr, !tcg.op !83
  store i32 %T60.tmp2.trunc97, ptr %T83.addr.envoff.ptr, align 2, !tcg.op !83
  %T83.addr.envoff98 = add i64 %env, 1440, !tcg.op !83
  %T83.addr.envoff98.ptr = inttoptr i64 %T83.addr.envoff98 to ptr, !tcg.op !83
  %T83.envval = load <2 x i64>, ptr %T83.addr.envoff98.ptr, align 8, !tcg.op !83
  store <2 x i64> %T83.envval, ptr %v18.stack, align 16, !tcg.op !83
; ======== TCG [84] st32_i64 t2,v18,0x3 ========
  %T60.tmp2.trunc99 = trunc i64 %T60.tmp2 to i32, !tcg.op !84
  %T84.addr.envoff = add i64 %env, 1443, !tcg.op !84
  %T84.addr.envoff.ptr = inttoptr i64 %T84.addr.envoff to ptr, !tcg.op !84
  store i32 %T60.tmp2.trunc99, ptr %T84.addr.envoff.ptr, align 1, !tcg.op !84
  %T84.addr.envoff100 = add i64 %env, 1440, !tcg.op !84
  %T84.addr.envoff100.ptr = inttoptr i64 %T84.addr.envoff100 to ptr, !tcg.op !84
  %T84.envval = load <2 x i64>, ptr %T84.addr.envoff100.ptr, align 8, !tcg.op !84
  store <2 x i64> %T84.envval, ptr %v18.stack, align 16, !tcg.op !84
; ======== TCG [85] st32_i64 t2,v18,0x4 ========
  %T60.tmp2.trunc101 = trunc i64 %T60.tmp2 to i32, !tcg.op !85
  %T60.tmp2.trunc101.ie = insertelement <4 x i32> zeroinitializer, i32 %T60.tmp2.trunc101, i64 1, !tcg.op !85
  %T60.tmp2.trunc101.ie.bc = bitcast <4 x i32> %T60.tmp2.trunc101.ie to <2 x i64>, !tcg.op !85
  store <2 x i64> %T60.tmp2.trunc101.ie.bc, ptr %v18.stack, align 16, !tcg.op !85
; ======== TCG [86] st32_i64 t2,v18,0x5 ========
  %T60.tmp2.trunc102 = trunc i64 %T60.tmp2 to i32, !tcg.op !86
  %T86.addr.envoff = add i64 %env, 1445, !tcg.op !86
  %T86.addr.envoff.ptr = inttoptr i64 %T86.addr.envoff to ptr, !tcg.op !86
  store i32 %T60.tmp2.trunc102, ptr %T86.addr.envoff.ptr, align 1, !tcg.op !86
  %T86.addr.envoff103 = add i64 %env, 1440, !tcg.op !86
  %T86.addr.envoff103.ptr = inttoptr i64 %T86.addr.envoff103 to ptr, !tcg.op !86
  %T86.envval = load <2 x i64>, ptr %T86.addr.envoff103.ptr, align 8, !tcg.op !86
  store <2 x i64> %T86.envval, ptr %v18.stack, align 16, !tcg.op !86
; ======== TCG [87] st32_i64 t2,v18,0x6 ========
  %T60.tmp2.trunc104 = trunc i64 %T60.tmp2 to i32, !tcg.op !87
  %T87.addr.envoff = add i64 %env, 1446, !tcg.op !87
  %T87.addr.envoff.ptr = inttoptr i64 %T87.addr.envoff to ptr, !tcg.op !87
  store i32 %T60.tmp2.trunc104, ptr %T87.addr.envoff.ptr, align 2, !tcg.op !87
  %T87.addr.envoff105 = add i64 %env, 1440, !tcg.op !87
  %T87.addr.envoff105.ptr = inttoptr i64 %T87.addr.envoff105 to ptr, !tcg.op !87
  %T87.envval = load <2 x i64>, ptr %T87.addr.envoff105.ptr, align 8, !tcg.op !87
  store <2 x i64> %T87.envval, ptr %v18.stack, align 16, !tcg.op !87
; ======== TCG [88] st32_i64 t2,v18,0x7 ========
  %T60.tmp2.trunc106 = trunc i64 %T60.tmp2 to i32, !tcg.op !88
  %T88.addr.envoff = add i64 %env, 1447, !tcg.op !88
  %T88.addr.envoff.ptr = inttoptr i64 %T88.addr.envoff to ptr, !tcg.op !88
  store i32 %T60.tmp2.trunc106, ptr %T88.addr.envoff.ptr, align 1, !tcg.op !88
  %T88.addr.envoff107 = add i64 %env, 1440, !tcg.op !88
  %T88.addr.envoff107.ptr = inttoptr i64 %T88.addr.envoff107 to ptr, !tcg.op !88
  %T88.envval = load <2 x i64>, ptr %T88.addr.envoff107.ptr, align 8, !tcg.op !88
  store <2 x i64> %T88.envval, ptr %v18.stack, align 16, !tcg.op !88
; ======== TCG [89] st32_i64 t2,v18,0x8 ========
  %T60.tmp2.trunc108 = trunc i64 %T60.tmp2 to i32, !tcg.op !89
  %T60.tmp2.trunc108.ie = insertelement <4 x i32> zeroinitializer, i32 %T60.tmp2.trunc108, i64 2, !tcg.op !89
  %T60.tmp2.trunc108.ie.bc = bitcast <4 x i32> %T60.tmp2.trunc108.ie to <2 x i64>, !tcg.op !89
  store <2 x i64> %T60.tmp2.trunc108.ie.bc, ptr %v18.stack, align 16, !tcg.op !89
; ======== TCG [90] st32_i64 t2,v18,0x9 ========
  %T60.tmp2.trunc109 = trunc i64 %T60.tmp2 to i32, !tcg.op !90
  %T90.addr.envoff = add i64 %env, 1449, !tcg.op !90
  %T90.addr.envoff.ptr = inttoptr i64 %T90.addr.envoff to ptr, !tcg.op !90
  store i32 %T60.tmp2.trunc109, ptr %T90.addr.envoff.ptr, align 1, !tcg.op !90
  %T90.addr.envoff110 = add i64 %env, 1440, !tcg.op !90
  %T90.addr.envoff110.ptr = inttoptr i64 %T90.addr.envoff110 to ptr, !tcg.op !90
  %T90.envval = load <2 x i64>, ptr %T90.addr.envoff110.ptr, align 8, !tcg.op !90
  store <2 x i64> %T90.envval, ptr %v18.stack, align 16, !tcg.op !90
; ======== TCG [91] st32_i64 t2,v18,0xa ========
  %T60.tmp2.trunc111 = trunc i64 %T60.tmp2 to i32, !tcg.op !91
  %T91.addr.envoff = add i64 %env, 1450, !tcg.op !91
  %T91.addr.envoff.ptr = inttoptr i64 %T91.addr.envoff to ptr, !tcg.op !91
  store i32 %T60.tmp2.trunc111, ptr %T91.addr.envoff.ptr, align 2, !tcg.op !91
  %T91.addr.envoff112 = add i64 %env, 1440, !tcg.op !91
  %T91.addr.envoff112.ptr = inttoptr i64 %T91.addr.envoff112 to ptr, !tcg.op !91
  %T91.envval = load <2 x i64>, ptr %T91.addr.envoff112.ptr, align 8, !tcg.op !91
  store <2 x i64> %T91.envval, ptr %v18.stack, align 16, !tcg.op !91
; ======== TCG [92] st32_i64 t2,v18,0xb ========
  %T60.tmp2.trunc113 = trunc i64 %T60.tmp2 to i32, !tcg.op !92
  %T92.addr.envoff = add i64 %env, 1451, !tcg.op !92
  %T92.addr.envoff.ptr = inttoptr i64 %T92.addr.envoff to ptr, !tcg.op !92
  store i32 %T60.tmp2.trunc113, ptr %T92.addr.envoff.ptr, align 1, !tcg.op !92
  %T92.addr.envoff114 = add i64 %env, 1440, !tcg.op !92
  %T92.addr.envoff114.ptr = inttoptr i64 %T92.addr.envoff114 to ptr, !tcg.op !92
  %T92.envval = load <2 x i64>, ptr %T92.addr.envoff114.ptr, align 8, !tcg.op !92
  store <2 x i64> %T92.envval, ptr %v18.stack, align 16, !tcg.op !92
; ======== TCG [93] st32_i64 t2,v18,0xc ========
  %T60.tmp2.trunc115 = trunc i64 %T60.tmp2 to i32, !tcg.op !93
  %T60.tmp2.trunc115.ie = insertelement <4 x i32> zeroinitializer, i32 %T60.tmp2.trunc115, i64 3, !tcg.op !93
  %T60.tmp2.trunc115.ie.bc = bitcast <4 x i32> %T60.tmp2.trunc115.ie to <2 x i64>, !tcg.op !93
  store <2 x i64> %T60.tmp2.trunc115.ie.bc, ptr %v18.stack, align 16, !tcg.op !93
; ======== TCG [94] st32_i64 t2,v18,0xd ========
  %T60.tmp2.trunc116 = trunc i64 %T60.tmp2 to i32, !tcg.op !94
  %T94.addr.envoff = add i64 %env, 1453, !tcg.op !94
  %T94.addr.envoff.ptr = inttoptr i64 %T94.addr.envoff to ptr, !tcg.op !94
  store i32 %T60.tmp2.trunc116, ptr %T94.addr.envoff.ptr, align 1, !tcg.op !94
  %T94.addr.envoff117 = add i64 %env, 1440, !tcg.op !94
  %T94.addr.envoff117.ptr = inttoptr i64 %T94.addr.envoff117 to ptr, !tcg.op !94
  %T94.envval = load <2 x i64>, ptr %T94.addr.envoff117.ptr, align 8, !tcg.op !94
  store <2 x i64> %T94.envval, ptr %v18.stack, align 16, !tcg.op !94
  %T94.addr.envoff118 = add i64 %env, 1456, !tcg.op !94
  %T94.addr.envoff118.ptr = inttoptr i64 %T94.addr.envoff118 to ptr, !tcg.op !94
  %T94.envval119 = load <2 x i64>, ptr %T94.addr.envoff118.ptr, align 8, !tcg.op !94
  store <2 x i64> %T94.envval119, ptr %v19.stack, align 16, !tcg.op !94
; ======== TCG [95] st32_i64 t2,v18,0xe ========
  %T60.tmp2.trunc120 = trunc i64 %T60.tmp2 to i32, !tcg.op !95
  %T95.addr.envoff = add i64 %env, 1454, !tcg.op !95
  %T95.addr.envoff.ptr = inttoptr i64 %T95.addr.envoff to ptr, !tcg.op !95
  store i32 %T60.tmp2.trunc120, ptr %T95.addr.envoff.ptr, align 2, !tcg.op !95
  %T95.addr.envoff121 = add i64 %env, 1440, !tcg.op !95
  %T95.addr.envoff121.ptr = inttoptr i64 %T95.addr.envoff121 to ptr, !tcg.op !95
  %T95.envval = load <2 x i64>, ptr %T95.addr.envoff121.ptr, align 8, !tcg.op !95
  store <2 x i64> %T95.envval, ptr %v18.stack, align 16, !tcg.op !95
  %T95.addr.envoff122 = add i64 %env, 1456, !tcg.op !95
  %T95.addr.envoff122.ptr = inttoptr i64 %T95.addr.envoff122 to ptr, !tcg.op !95
  %T95.envval123 = load <2 x i64>, ptr %T95.addr.envoff122.ptr, align 8, !tcg.op !95
  store <2 x i64> %T95.envval123, ptr %v19.stack, align 16, !tcg.op !95
; ======== TCG [96] st32_i64 t2,v18,0xf ========
  %T60.tmp2.trunc124 = trunc i64 %T60.tmp2 to i32, !tcg.op !96
  %T96.addr.envoff = add i64 %env, 1455, !tcg.op !96
  %T96.addr.envoff.ptr = inttoptr i64 %T96.addr.envoff to ptr, !tcg.op !96
  store i32 %T60.tmp2.trunc124, ptr %T96.addr.envoff.ptr, align 1, !tcg.op !96
  %T96.addr.envoff125 = add i64 %env, 1440, !tcg.op !96
  %T96.addr.envoff125.ptr = inttoptr i64 %T96.addr.envoff125 to ptr, !tcg.op !96
  %T96.envval = load <2 x i64>, ptr %T96.addr.envoff125.ptr, align 8, !tcg.op !96
  store <2 x i64> %T96.envval, ptr %v18.stack, align 16, !tcg.op !96
  %T96.addr.envoff126 = add i64 %env, 1456, !tcg.op !96
  %T96.addr.envoff126.ptr = inttoptr i64 %T96.addr.envoff126 to ptr, !tcg.op !96
  %T96.envval127 = load <2 x i64>, ptr %T96.addr.envoff126.ptr, align 8, !tcg.op !96
  store <2 x i64> %T96.envval127, ptr %v19.stack, align 16, !tcg.op !96
; ======== TCG [97] st32_i64 t2,v18,0x10 ========
  %T60.tmp2.trunc128 = trunc i64 %T60.tmp2 to i32, !tcg.op !97
  %T60.tmp2.trunc128.ie = insertelement <4 x i32> zeroinitializer, i32 %T60.tmp2.trunc128, i64 4, !tcg.op !97
  %T60.tmp2.trunc128.ie.bc = bitcast <4 x i32> %T60.tmp2.trunc128.ie to <2 x i64>, !tcg.op !97
  store <2 x i64> %T60.tmp2.trunc128.ie.bc, ptr %v18.stack, align 16, !tcg.op !97
; ======== TCG [98] ld_vec v64,e32,[t13],v26 ========
  %T98.v26 = load <2 x i64>, ptr %v26.stack, align 16, !tcg.op !98
  %T98.v26.ee = extractelement <2 x i64> %T98.v26, i64 0, !tcg.op !98
  %T98.v26.ee.bc = bitcast i64 %T98.v26.ee to <2 x i32>, !tcg.op !98
  %T98.v26.ee.bc.bc = bitcast <2 x i32> %T98.v26.ee.bc to <1 x i64>, !tcg.op !98
  %T98.v26.ee.bc.bc.ee = extractelement <1 x i64> %T98.v26.ee.bc.bc, i64 0, !tcg.op !98
  %T98.v26.ee.bc.bc.ee.ie = insertelement <2 x i64> zeroinitializer, i64 %T98.v26.ee.bc.bc.ee, i64 0, !tcg.op !98
  store <2 x i64> %T98.v26.ee.bc.bc.ee.ie, ptr %tmp13.stack, align 16, !tcg.op !98
; ======== TCG [99] st_vec v64,e8,t13,v0 ========
  %T99.tmp13 = load <2 x i64>, ptr %tmp13.stack, align 16, !tcg.op !99
  %T99.tmp13.ee = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !99
  %T99.tmp13.ee.bc = bitcast i64 %T99.tmp13.ee to <8 x i8>, !tcg.op !99
  %T99.tmp13.ee.bc.bc = bitcast <8 x i8> %T99.tmp13.ee.bc to <1 x i64>, !tcg.op !99
  %T99.tmp13.ee.bc.bc.ee = extractelement <1 x i64> %T99.tmp13.ee.bc.bc, i64 0, !tcg.op !99
  %T99.tmp13.ee.bc.bc.ee.ie = insertelement <2 x i64> zeroinitializer, i64 %T99.tmp13.ee.bc.bc.ee, i64 0, !tcg.op !99
  store <2 x i64> %T99.tmp13.ee.bc.bc.ee.ie, ptr %v0.stack, align 16, !tcg.op !99
; ======== TCG [100] ld_vec v128,e16,[t14],v26 ========
  %T98.v26.bc = bitcast <2 x i64> %T98.v26 to <8 x i16>, !tcg.op !100
  %T98.v26.bc.bc = bitcast <8 x i16> %T98.v26.bc to <2 x i64>, !tcg.op !100
  store <2 x i64> %T98.v26.bc.bc, ptr %tmp14.stack, align 16, !tcg.op !100
; ======== TCG [101] st_vec v64,e32,t14,v0 ========
  %T101.tmp14 = load <2 x i64>, ptr %tmp14.stack, align 16, !tcg.op !101
  %T101.tmp14.ee = extractelement <2 x i64> %T101.tmp14, i64 0, !tcg.op !101
  %T101.tmp14.ee.bc = bitcast i64 %T101.tmp14.ee to <2 x i32>, !tcg.op !101
  %T101.tmp14.ee.bc.bc = bitcast <2 x i32> %T101.tmp14.ee.bc to <1 x i64>, !tcg.op !101
  %T101.tmp14.ee.bc.bc.ee = extractelement <1 x i64> %T101.tmp14.ee.bc.bc, i64 0, !tcg.op !101
  %T101.tmp14.ee.bc.bc.ee.ie = insertelement <2 x i64> zeroinitializer, i64 %T101.tmp14.ee.bc.bc.ee, i64 0, !tcg.op !101
  store <2 x i64> %T101.tmp14.ee.bc.bc.ee.ie, ptr %v0.stack, align 16, !tcg.op !101
; ======== TCG [102] st_vec v64,e8,t13,v0:o1 ========
  %T99.tmp13.ee129 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !102
  %T99.tmp13.ee129.bc = bitcast i64 %T99.tmp13.ee129 to <8 x i8>, !tcg.op !102
  %T102.addr.envoff = add i64 %env, 865, !tcg.op !102
  %T102.addr.envoff.ptr = inttoptr i64 %T102.addr.envoff to ptr, !tcg.op !102
  store <8 x i8> %T99.tmp13.ee129.bc, ptr %T102.addr.envoff.ptr, align 1, !tcg.op !102
  %T102.addr.envoff130 = add i64 %env, 864, !tcg.op !102
  %T102.addr.envoff130.ptr = inttoptr i64 %T102.addr.envoff130 to ptr, !tcg.op !102
  %T102.envval = load <2 x i64>, ptr %T102.addr.envoff130.ptr, align 8, !tcg.op !102
  store <2 x i64> %T102.envval, ptr %v0.stack, align 16, !tcg.op !102
; ======== TCG [103] st_vec v64,e8,t13,v0:o2 ========
  %T99.tmp13.ee131 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !103
  %T99.tmp13.ee131.bc = bitcast i64 %T99.tmp13.ee131 to <8 x i8>, !tcg.op !103
  %T103.addr.envoff = add i64 %env, 866, !tcg.op !103
  %T103.addr.envoff.ptr = inttoptr i64 %T103.addr.envoff to ptr, !tcg.op !103
  store <8 x i8> %T99.tmp13.ee131.bc, ptr %T103.addr.envoff.ptr, align 2, !tcg.op !103
  %T103.addr.envoff132 = add i64 %env, 864, !tcg.op !103
  %T103.addr.envoff132.ptr = inttoptr i64 %T103.addr.envoff132 to ptr, !tcg.op !103
  %T103.envval = load <2 x i64>, ptr %T103.addr.envoff132.ptr, align 8, !tcg.op !103
  store <2 x i64> %T103.envval, ptr %v0.stack, align 16, !tcg.op !103
; ======== TCG [104] st_vec v64,e8,t13,v0:o3 ========
  %T99.tmp13.ee133 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !104
  %T99.tmp13.ee133.bc = bitcast i64 %T99.tmp13.ee133 to <8 x i8>, !tcg.op !104
  %T104.addr.envoff = add i64 %env, 867, !tcg.op !104
  %T104.addr.envoff.ptr = inttoptr i64 %T104.addr.envoff to ptr, !tcg.op !104
  store <8 x i8> %T99.tmp13.ee133.bc, ptr %T104.addr.envoff.ptr, align 1, !tcg.op !104
  %T104.addr.envoff134 = add i64 %env, 864, !tcg.op !104
  %T104.addr.envoff134.ptr = inttoptr i64 %T104.addr.envoff134 to ptr, !tcg.op !104
  %T104.envval = load <2 x i64>, ptr %T104.addr.envoff134.ptr, align 8, !tcg.op !104
  store <2 x i64> %T104.envval, ptr %v0.stack, align 16, !tcg.op !104
; ======== TCG [105] st_vec v64,e8,t13,v0:o4 ========
  %T99.tmp13.ee135 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !105
  %T99.tmp13.ee135.bc = bitcast i64 %T99.tmp13.ee135 to <8 x i8>, !tcg.op !105
  %T105.addr.envoff = add i64 %env, 868, !tcg.op !105
  %T105.addr.envoff.ptr = inttoptr i64 %T105.addr.envoff to ptr, !tcg.op !105
  store <8 x i8> %T99.tmp13.ee135.bc, ptr %T105.addr.envoff.ptr, align 4, !tcg.op !105
  %T105.addr.envoff136 = add i64 %env, 864, !tcg.op !105
  %T105.addr.envoff136.ptr = inttoptr i64 %T105.addr.envoff136 to ptr, !tcg.op !105
  %T105.envval = load <2 x i64>, ptr %T105.addr.envoff136.ptr, align 8, !tcg.op !105
  store <2 x i64> %T105.envval, ptr %v0.stack, align 16, !tcg.op !105
; ======== TCG [106] st_vec v64,e8,t13,v0:o5 ========
  %T99.tmp13.ee137 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !106
  %T99.tmp13.ee137.bc = bitcast i64 %T99.tmp13.ee137 to <8 x i8>, !tcg.op !106
  %T106.addr.envoff = add i64 %env, 869, !tcg.op !106
  %T106.addr.envoff.ptr = inttoptr i64 %T106.addr.envoff to ptr, !tcg.op !106
  store <8 x i8> %T99.tmp13.ee137.bc, ptr %T106.addr.envoff.ptr, align 1, !tcg.op !106
  %T106.addr.envoff138 = add i64 %env, 864, !tcg.op !106
  %T106.addr.envoff138.ptr = inttoptr i64 %T106.addr.envoff138 to ptr, !tcg.op !106
  %T106.envval = load <2 x i64>, ptr %T106.addr.envoff138.ptr, align 8, !tcg.op !106
  store <2 x i64> %T106.envval, ptr %v0.stack, align 16, !tcg.op !106
; ======== TCG [107] st_vec v64,e8,t13,v0:o6 ========
  %T99.tmp13.ee139 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !107
  %T99.tmp13.ee139.bc = bitcast i64 %T99.tmp13.ee139 to <8 x i8>, !tcg.op !107
  %T107.addr.envoff = add i64 %env, 870, !tcg.op !107
  %T107.addr.envoff.ptr = inttoptr i64 %T107.addr.envoff to ptr, !tcg.op !107
  store <8 x i8> %T99.tmp13.ee139.bc, ptr %T107.addr.envoff.ptr, align 2, !tcg.op !107
  %T107.addr.envoff140 = add i64 %env, 864, !tcg.op !107
  %T107.addr.envoff140.ptr = inttoptr i64 %T107.addr.envoff140 to ptr, !tcg.op !107
  %T107.envval = load <2 x i64>, ptr %T107.addr.envoff140.ptr, align 8, !tcg.op !107
  store <2 x i64> %T107.envval, ptr %v0.stack, align 16, !tcg.op !107
; ======== TCG [108] st_vec v64,e8,t13,v0:o7 ========
  %T99.tmp13.ee141 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !108
  %T99.tmp13.ee141.bc = bitcast i64 %T99.tmp13.ee141 to <8 x i8>, !tcg.op !108
  %T108.addr.envoff = add i64 %env, 871, !tcg.op !108
  %T108.addr.envoff.ptr = inttoptr i64 %T108.addr.envoff to ptr, !tcg.op !108
  store <8 x i8> %T99.tmp13.ee141.bc, ptr %T108.addr.envoff.ptr, align 1, !tcg.op !108
  %T108.addr.envoff142 = add i64 %env, 864, !tcg.op !108
  %T108.addr.envoff142.ptr = inttoptr i64 %T108.addr.envoff142 to ptr, !tcg.op !108
  %T108.envval = load <2 x i64>, ptr %T108.addr.envoff142.ptr, align 8, !tcg.op !108
  store <2 x i64> %T108.envval, ptr %v0.stack, align 16, !tcg.op !108
; ======== TCG [109] st_vec v64,e8,t13,v0:o8 ========
  %T99.tmp13.ee143 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !109
  %T99.tmp13.ee143.bc = bitcast i64 %T99.tmp13.ee143 to <8 x i8>, !tcg.op !109
  %T99.tmp13.ee143.bc.bc = bitcast <8 x i8> %T99.tmp13.ee143.bc to <1 x i64>, !tcg.op !109
  %T99.tmp13.ee143.bc.bc.ee = extractelement <1 x i64> %T99.tmp13.ee143.bc.bc, i64 0, !tcg.op !109
  %T99.tmp13.ee143.bc.bc.ee.ie = insertelement <2 x i64> zeroinitializer, i64 %T99.tmp13.ee143.bc.bc.ee, i64 1, !tcg.op !109
  store <2 x i64> %T99.tmp13.ee143.bc.bc.ee.ie, ptr %v0.stack, align 16, !tcg.op !109
; ======== TCG [110] st_vec v64,e8,t13,v0:o9 ========
  %T99.tmp13.ee144 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !110
  %T99.tmp13.ee144.bc = bitcast i64 %T99.tmp13.ee144 to <8 x i8>, !tcg.op !110
  %T110.addr.envoff = add i64 %env, 873, !tcg.op !110
  %T110.addr.envoff.ptr = inttoptr i64 %T110.addr.envoff to ptr, !tcg.op !110
  store <8 x i8> %T99.tmp13.ee144.bc, ptr %T110.addr.envoff.ptr, align 1, !tcg.op !110
  %T110.addr.envoff145 = add i64 %env, 864, !tcg.op !110
  %T110.addr.envoff145.ptr = inttoptr i64 %T110.addr.envoff145 to ptr, !tcg.op !110
  %T110.envval = load <2 x i64>, ptr %T110.addr.envoff145.ptr, align 8, !tcg.op !110
  store <2 x i64> %T110.envval, ptr %v0.stack, align 16, !tcg.op !110
  %T110.addr.envoff146 = add i64 %env, 880, !tcg.op !110
  %T110.addr.envoff146.ptr = inttoptr i64 %T110.addr.envoff146 to ptr, !tcg.op !110
  %T110.envval147 = load <2 x i64>, ptr %T110.addr.envoff146.ptr, align 8, !tcg.op !110
  store <2 x i64> %T110.envval147, ptr %v1.stack, align 16, !tcg.op !110
; ======== TCG [111] st_vec v64,e8,t13,v0:o10 ========
  %T99.tmp13.ee148 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !111
  %T99.tmp13.ee148.bc = bitcast i64 %T99.tmp13.ee148 to <8 x i8>, !tcg.op !111
  %T111.addr.envoff = add i64 %env, 874, !tcg.op !111
  %T111.addr.envoff.ptr = inttoptr i64 %T111.addr.envoff to ptr, !tcg.op !111
  store <8 x i8> %T99.tmp13.ee148.bc, ptr %T111.addr.envoff.ptr, align 2, !tcg.op !111
  %T111.addr.envoff149 = add i64 %env, 864, !tcg.op !111
  %T111.addr.envoff149.ptr = inttoptr i64 %T111.addr.envoff149 to ptr, !tcg.op !111
  %T111.envval = load <2 x i64>, ptr %T111.addr.envoff149.ptr, align 8, !tcg.op !111
  store <2 x i64> %T111.envval, ptr %v0.stack, align 16, !tcg.op !111
  %T111.addr.envoff150 = add i64 %env, 880, !tcg.op !111
  %T111.addr.envoff150.ptr = inttoptr i64 %T111.addr.envoff150 to ptr, !tcg.op !111
  %T111.envval151 = load <2 x i64>, ptr %T111.addr.envoff150.ptr, align 8, !tcg.op !111
  store <2 x i64> %T111.envval151, ptr %v1.stack, align 16, !tcg.op !111
; ======== TCG [112] st_vec v64,e8,t13,v0:o11 ========
  %T99.tmp13.ee152 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !112
  %T99.tmp13.ee152.bc = bitcast i64 %T99.tmp13.ee152 to <8 x i8>, !tcg.op !112
  %T112.addr.envoff = add i64 %env, 875, !tcg.op !112
  %T112.addr.envoff.ptr = inttoptr i64 %T112.addr.envoff to ptr, !tcg.op !112
  store <8 x i8> %T99.tmp13.ee152.bc, ptr %T112.addr.envoff.ptr, align 1, !tcg.op !112
  %T112.addr.envoff153 = add i64 %env, 864, !tcg.op !112
  %T112.addr.envoff153.ptr = inttoptr i64 %T112.addr.envoff153 to ptr, !tcg.op !112
  %T112.envval = load <2 x i64>, ptr %T112.addr.envoff153.ptr, align 8, !tcg.op !112
  store <2 x i64> %T112.envval, ptr %v0.stack, align 16, !tcg.op !112
  %T112.addr.envoff154 = add i64 %env, 880, !tcg.op !112
  %T112.addr.envoff154.ptr = inttoptr i64 %T112.addr.envoff154 to ptr, !tcg.op !112
  %T112.envval155 = load <2 x i64>, ptr %T112.addr.envoff154.ptr, align 8, !tcg.op !112
  store <2 x i64> %T112.envval155, ptr %v1.stack, align 16, !tcg.op !112
; ======== TCG [113] st_vec v64,e8,t13,v0:o12 ========
  %T99.tmp13.ee156 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !113
  %T99.tmp13.ee156.bc = bitcast i64 %T99.tmp13.ee156 to <8 x i8>, !tcg.op !113
  %T113.addr.envoff = add i64 %env, 876, !tcg.op !113
  %T113.addr.envoff.ptr = inttoptr i64 %T113.addr.envoff to ptr, !tcg.op !113
  store <8 x i8> %T99.tmp13.ee156.bc, ptr %T113.addr.envoff.ptr, align 4, !tcg.op !113
  %T113.addr.envoff157 = add i64 %env, 864, !tcg.op !113
  %T113.addr.envoff157.ptr = inttoptr i64 %T113.addr.envoff157 to ptr, !tcg.op !113
  %T113.envval = load <2 x i64>, ptr %T113.addr.envoff157.ptr, align 8, !tcg.op !113
  store <2 x i64> %T113.envval, ptr %v0.stack, align 16, !tcg.op !113
  %T113.addr.envoff158 = add i64 %env, 880, !tcg.op !113
  %T113.addr.envoff158.ptr = inttoptr i64 %T113.addr.envoff158 to ptr, !tcg.op !113
  %T113.envval159 = load <2 x i64>, ptr %T113.addr.envoff158.ptr, align 8, !tcg.op !113
  store <2 x i64> %T113.envval159, ptr %v1.stack, align 16, !tcg.op !113
; ======== TCG [114] st_vec v64,e8,t13,v0:o13 ========
  %T99.tmp13.ee160 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !114
  %T99.tmp13.ee160.bc = bitcast i64 %T99.tmp13.ee160 to <8 x i8>, !tcg.op !114
  %T114.addr.envoff = add i64 %env, 877, !tcg.op !114
  %T114.addr.envoff.ptr = inttoptr i64 %T114.addr.envoff to ptr, !tcg.op !114
  store <8 x i8> %T99.tmp13.ee160.bc, ptr %T114.addr.envoff.ptr, align 1, !tcg.op !114
  %T114.addr.envoff161 = add i64 %env, 864, !tcg.op !114
  %T114.addr.envoff161.ptr = inttoptr i64 %T114.addr.envoff161 to ptr, !tcg.op !114
  %T114.envval = load <2 x i64>, ptr %T114.addr.envoff161.ptr, align 8, !tcg.op !114
  store <2 x i64> %T114.envval, ptr %v0.stack, align 16, !tcg.op !114
  %T114.addr.envoff162 = add i64 %env, 880, !tcg.op !114
  %T114.addr.envoff162.ptr = inttoptr i64 %T114.addr.envoff162 to ptr, !tcg.op !114
  %T114.envval163 = load <2 x i64>, ptr %T114.addr.envoff162.ptr, align 8, !tcg.op !114
  store <2 x i64> %T114.envval163, ptr %v1.stack, align 16, !tcg.op !114
; ======== TCG [115] st_vec v64,e8,t13,v0:o14 ========
  %T99.tmp13.ee164 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !115
  %T99.tmp13.ee164.bc = bitcast i64 %T99.tmp13.ee164 to <8 x i8>, !tcg.op !115
  %T115.addr.envoff = add i64 %env, 878, !tcg.op !115
  %T115.addr.envoff.ptr = inttoptr i64 %T115.addr.envoff to ptr, !tcg.op !115
  store <8 x i8> %T99.tmp13.ee164.bc, ptr %T115.addr.envoff.ptr, align 2, !tcg.op !115
  %T115.addr.envoff165 = add i64 %env, 864, !tcg.op !115
  %T115.addr.envoff165.ptr = inttoptr i64 %T115.addr.envoff165 to ptr, !tcg.op !115
  %T115.envval = load <2 x i64>, ptr %T115.addr.envoff165.ptr, align 8, !tcg.op !115
  store <2 x i64> %T115.envval, ptr %v0.stack, align 16, !tcg.op !115
  %T115.addr.envoff166 = add i64 %env, 880, !tcg.op !115
  %T115.addr.envoff166.ptr = inttoptr i64 %T115.addr.envoff166 to ptr, !tcg.op !115
  %T115.envval167 = load <2 x i64>, ptr %T115.addr.envoff166.ptr, align 8, !tcg.op !115
  store <2 x i64> %T115.envval167, ptr %v1.stack, align 16, !tcg.op !115
; ======== TCG [116] st_vec v64,e8,t13,v0:o15 ========
  %T99.tmp13.ee168 = extractelement <2 x i64> %T99.tmp13, i64 0, !tcg.op !116
  %T99.tmp13.ee168.bc = bitcast i64 %T99.tmp13.ee168 to <8 x i8>, !tcg.op !116
  %T116.addr.envoff = add i64 %env, 879, !tcg.op !116
  %T116.addr.envoff.ptr = inttoptr i64 %T116.addr.envoff to ptr, !tcg.op !116
  store <8 x i8> %T99.tmp13.ee168.bc, ptr %T116.addr.envoff.ptr, align 1, !tcg.op !116
  %T116.addr.envoff169 = add i64 %env, 864, !tcg.op !116
  %T116.addr.envoff169.ptr = inttoptr i64 %T116.addr.envoff169 to ptr, !tcg.op !116
  %T116.envval = load <2 x i64>, ptr %T116.addr.envoff169.ptr, align 8, !tcg.op !116
  store <2 x i64> %T116.envval, ptr %v0.stack, align 16, !tcg.op !116
  %T116.addr.envoff170 = add i64 %env, 880, !tcg.op !116
  %T116.addr.envoff170.ptr = inttoptr i64 %T116.addr.envoff170 to ptr, !tcg.op !116
  %T116.envval171 = load <2 x i64>, ptr %T116.addr.envoff170.ptr, align 8, !tcg.op !116
  store <2 x i64> %T116.envval171, ptr %v1.stack, align 16, !tcg.op !116
; ======== TCG [117] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2 ========
  %T18.tmp7.ptr172 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !117
  %T117.tmp8 = load i64, ptr %tmp8.stack, align 8, !tcg.op !117
  %T117.tmp8.trunc = trunc i64 %T117.tmp8 to i8, !tcg.op !117
  store i8 %T117.tmp8.trunc, ptr %T18.tmp7.ptr172, align 1, !tcg.op !117
; ======== TCG [118] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2 ========
  %T18.tmp7.ptr173 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !118
  %T117.tmp8.trunc174 = trunc i64 %T117.tmp8 to i8, !tcg.op !118
  store i8 %T117.tmp8.trunc174, ptr %T18.tmp7.ptr173, align 1, !tcg.op !118
; ======== TCG [119] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2 ========
  %T18.tmp7.ptr175 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !119
  %T117.tmp8.trunc176 = trunc i64 %T117.tmp8 to i16, !tcg.op !119
  store i16 %T117.tmp8.trunc176, ptr %T18.tmp7.ptr175, align 1, !tcg.op !119
; ======== TCG [120] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2 ========
  %T18.tmp7.ptr177 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !120
  %T117.tmp8.trunc178 = trunc i64 %T117.tmp8 to i16, !tcg.op !120
  store i16 %T117.tmp8.trunc178, ptr %T18.tmp7.ptr177, align 1, !tcg.op !120
; ======== TCG [121] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2 ========
  %T18.tmp7.ptr179 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !121
  %T117.tmp8.trunc180 = trunc i64 %T117.tmp8 to i32, !tcg.op !121
  store i32 %T117.tmp8.trunc180, ptr %T18.tmp7.ptr179, align 1, !tcg.op !121
; ======== TCG [122] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2 ========
  %T18.tmp7.ptr181 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !122
  %T117.tmp8.trunc182 = trunc i64 %T117.tmp8 to i32, !tcg.op !122
  store i32 %T117.tmp8.trunc182, ptr %T18.tmp7.ptr181, align 1, !tcg.op !122
; ======== TCG [123] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr183 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !123
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr183, align 1, !tcg.op !123
; ======== TCG [124] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC1B,0x2 ========
  %T18.tmp7.ptr184 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !124
  %T117.tmp8.trunc185 = trunc i64 %T117.tmp8 to i8, !tcg.op !124
  store i8 %T117.tmp8.trunc185, ptr %T18.tmp7.ptr184, align 1, !tcg.op !124
; ======== TCG [125] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC1B,0x2 ========
  %T18.tmp7.ptr186 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !125
  %T117.tmp8.trunc187 = trunc i64 %T117.tmp8 to i8, !tcg.op !125
  store i8 %T117.tmp8.trunc187, ptr %T18.tmp7.ptr186, align 1, !tcg.op !125
; ======== TCG [126] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC2B,0x2 ========
  %T18.tmp7.ptr188 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !126
  %T117.tmp8.trunc189 = trunc i64 %T117.tmp8 to i16, !tcg.op !126
  store i16 %T117.tmp8.trunc189, ptr %T18.tmp7.ptr188, align 2, !tcg.op !126
; ======== TCG [127] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC2B,0x2 ========
  %T18.tmp7.ptr190 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !127
  %T117.tmp8.trunc191 = trunc i64 %T117.tmp8 to i16, !tcg.op !127
  store i16 %T117.tmp8.trunc191, ptr %T18.tmp7.ptr190, align 2, !tcg.op !127
; ======== TCG [128] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC4B,0x2 ========
  %T18.tmp7.ptr192 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !128
  %T117.tmp8.trunc193 = trunc i64 %T117.tmp8 to i32, !tcg.op !128
  store i32 %T117.tmp8.trunc193, ptr %T18.tmp7.ptr192, align 4, !tcg.op !128
; ======== TCG [129] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC4B,0x2 ========
  %T18.tmp7.ptr194 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !129
  %T117.tmp8.trunc195 = trunc i64 %T117.tmp8 to i32, !tcg.op !129
  store i32 %T117.tmp8.trunc195, ptr %T18.tmp7.ptr194, align 4, !tcg.op !129
; ======== TCG [130] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr196 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !130
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr196, align 8, !tcg.op !130
; ======== TCG [131] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_2:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr197 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !131
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr197, align 2, !tcg.op !131
; ======== TCG [132] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_4:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr198 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !132
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr198, align 4, !tcg.op !132
; ======== TCG [133] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr199 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !133
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr199, align 8, !tcg.op !133
; ======== TCG [134] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr200 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !134
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr200, align 16, !tcg.op !134
; ======== TCG [135] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_32:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr201 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !135
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr201, align 32, !tcg.op !135
; ======== TCG [136] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_64:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr202 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !136
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr202, align 64, !tcg.op !136
; ======== TCG [137] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2 ========
  %T18.tmp7.ptr203 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !137
  %T137.tmp9 = load i32, ptr %tmp9.stack, align 8, !tcg.op !137
  %T137.tmp9.trunc = trunc i32 %T137.tmp9 to i8, !tcg.op !137
  store i8 %T137.tmp9.trunc, ptr %T18.tmp7.ptr203, align 1, !tcg.op !137
; ======== TCG [138] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2 ========
  %T18.tmp7.ptr204 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !138
  %T137.tmp9.trunc205 = trunc i32 %T137.tmp9 to i8, !tcg.op !138
  store i8 %T137.tmp9.trunc205, ptr %T18.tmp7.ptr204, align 1, !tcg.op !138
; ======== TCG [139] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2 ========
  %T18.tmp7.ptr206 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !139
  %T137.tmp9.trunc207 = trunc i32 %T137.tmp9 to i16, !tcg.op !139
  store i16 %T137.tmp9.trunc207, ptr %T18.tmp7.ptr206, align 1, !tcg.op !139
; ======== TCG [140] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2 ========
  %T18.tmp7.ptr208 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !140
  %T137.tmp9.trunc209 = trunc i32 %T137.tmp9 to i16, !tcg.op !140
  store i16 %T137.tmp9.trunc209, ptr %T18.tmp7.ptr208, align 1, !tcg.op !140
; ======== TCG [141] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2 ========
  %T18.tmp7.ptr210 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !141
  store i32 %T137.tmp9, ptr %T18.tmp7.ptr210, align 1, !tcg.op !141
; ======== TCG [142] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2 ========
  %T18.tmp7.ptr211 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !142
  store i32 %T137.tmp9, ptr %T18.tmp7.ptr211, align 1, !tcg.op !142
; ======== TCG [143] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr212 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !143
  store i32 %T137.tmp9, ptr %T18.tmp7.ptr212, align 1, !tcg.op !143
; ======== TCG [144] qemu_st_i64 t8,t7,attr-stg:ATOM_NONE:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr213 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !144
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr213, align 8, !tcg.op !144
; ======== TCG [145] qemu_st_i64 t8,t7,attr-stg:ATOM_SUBALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr214 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !145
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr214, align 8, !tcg.op !145
; ======== TCG [146] qemu_st_i64 t8,t7,attr-stg:ATOM_WITHIN16_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr215 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !146
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr215, align 8, !tcg.op !146
; ======== TCG [147] qemu_st_i64 t8,t7,attr-stg:ATOM_WITHIN16:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr216 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !147
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr216, align 8, !tcg.op !147
; ======== TCG [148] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T18.tmp7.ptr217 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !148
  store i64 %T117.tmp8, ptr %T18.tmp7.ptr217, align 8, !tcg.op !148
; ======== TCG [149] qemu_st2_i128 t10,t11,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC16B,0x2 ========
  %T18.tmp7.ptr218 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !149
  %T149.tmp10 = load i64, ptr %tmp10.stack, align 8, !tcg.op !149
  %T149.tmp11 = load i64, ptr %tmp11.stack, align 8, !tcg.op !149
  %.ie = insertelement <2 x i64> zeroinitializer, i64 %T149.tmp10, i64 0, !tcg.op !149
  %.ie.ie = insertelement <2 x i64> %.ie, i64 %T149.tmp11, i64 1, !tcg.op !149
  store <2 x i64> %.ie.ie, ptr %T18.tmp7.ptr218, align 1, !tcg.op !149
; ======== TCG [150] qemu_st2_i128 t10,t11,t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC16B,0x2 ========
  %T18.tmp7.ptr219 = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !150
  %.ie220 = insertelement <2 x i64> zeroinitializer, i64 %T149.tmp10, i64 0, !tcg.op !150
  %.ie220.ie = insertelement <2 x i64> %.ie220, i64 %T149.tmp11, i64 1, !tcg.op !150
  store <2 x i64> %.ie220.ie, ptr %T18.tmp7.ptr219, align 16, !tcg.op !150
}

attributes #0 = { noinline nounwind "target-features"="+neon" }

!0 = !{!"[0] ld8u_i32 [t0],env:0xab"}
!1 = !{!"[1] ld8u_i64 [t0],env:0xac"}
!2 = !{!"[2] ld16u_i32 [t0],env:0xab"}
!3 = !{!"[3] ld16u_i64 [t0],env:0xac"}
!4 = !{!"[4] ld32u_i64 [t0],env:0xac"}
!5 = !{!"[5] ld8s_i32 [t0],env:0xab"}
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
!18 = !{!"[18] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2"}
!19 = !{!"[19] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:INVALID_ALIGNMENT:ZERO:SRC1B,0x2"}
!20 = !{!"[20] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2"}
!21 = !{!"[21] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2"}
!22 = !{!"[22] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2"}
!23 = !{!"[23] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2"}
!24 = !{!"[24] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2"}
!25 = !{!"[25] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2"}
!26 = !{!"[26] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC1B,0x2"}
!27 = !{!"[27] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC1B,0x2"}
!28 = !{!"[28] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC2B,0x2"}
!29 = !{!"[29] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC2B,0x2"}
!30 = !{!"[30] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC4B,0x2"}
!31 = !{!"[31] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC4B,0x2"}
!32 = !{!"[32] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!33 = !{!"[33] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_2:ZERO:SRC8B,0x2"}
!34 = !{!"[34] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_4:ZERO:SRC8B,0x2"}
!35 = !{!"[35] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B,0x2"}
!36 = !{!"[36] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC8B,0x2"}
!37 = !{!"[37] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_32:ZERO:SRC8B,0x2"}
!38 = !{!"[38] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_64:ZERO:SRC8B,0x2"}
!39 = !{!"[39] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2"}
!40 = !{!"[40] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2"}
!41 = !{!"[41] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2"}
!42 = !{!"[42] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2"}
!43 = !{!"[43] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2"}
!44 = !{!"[44] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2"}
!45 = !{!"[45] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2"}
!46 = !{!"[46] qemu_ld_i64 [t8],t7,attr-stg:ATOM_NONE:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!47 = !{!"[47] qemu_ld_i64 [t8],t7,attr-stg:ATOM_SUBALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!48 = !{!"[48] qemu_ld_i64 [t8],t7,attr-stg:ATOM_WITHIN16_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!49 = !{!"[49] qemu_ld_i64 [t8],t7,attr-stg:ATOM_WITHIN16:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!50 = !{!"[50] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!51 = !{!"[51] qemu_ld2_i128 [t10],[t11],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC16B,0x2"}
!52 = !{!"[52] qemu_ld2_i128 [t10],[t11],t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC16B,0x2"}
!53 = !{!"[53] st8_i32 t0,env:0xac"}
!54 = !{!"[54] st8_i64 t0,env:0xac"}
!55 = !{!"[55] st16_i32 t0,env:0xac"}
!56 = !{!"[56] st16_i64 t0,env:0xac"}
!57 = !{!"[57] st32_i64 t0,env:0xac"}
!58 = !{!"[58] st_i32 t0,env:0xac"}
!59 = !{!"[59] st_i64 t0,env:0xac"}
!60 = !{!"[60] st32_i64 t2,v18,0x4"}
!61 = !{!"[61] st32_i64 t2,v18,0x2"}
!62 = !{!"[62] add_vec v128,e64,[t12],v18,v18"}
!63 = !{!"[63] st_i64 t0,env"}
!64 = !{!"[64] st_i64 t0,env:0x1"}
!65 = !{!"[65] st_i64 t0,env:0x2"}
!66 = !{!"[66] st_i64 t0,env:0x3"}
!67 = !{!"[67] st_i64 t0,env:0x4"}
!68 = !{!"[68] st_i64 t0,env:0x5"}
!69 = !{!"[69] st_i64 t0,env:0x6"}
!70 = !{!"[70] st_i64 t0,env:0x7"}
!71 = !{!"[71] st_i64 t0,env:0x8"}
!72 = !{!"[72] st_i32 t0,env"}
!73 = !{!"[73] st_i32 t0,env:0x1"}
!74 = !{!"[74] st_i32 t0,env:0x2"}
!75 = !{!"[75] st_i32 t0,env:0x3"}
!76 = !{!"[76] st_i32 t0,env:0x4"}
!77 = !{!"[77] st_i32 t0,env:0x5"}
!78 = !{!"[78] st_i32 t0,env:0x6"}
!79 = !{!"[79] st_i32 t0,env:0x7"}
!80 = !{!"[80] st_i32 t0,env:0x8"}
!81 = !{!"[81] st32_i64 t2,v18"}
!82 = !{!"[82] st32_i64 t2,v18,0x1"}
!83 = !{!"[83] st32_i64 t2,v18,0x2"}
!84 = !{!"[84] st32_i64 t2,v18,0x3"}
!85 = !{!"[85] st32_i64 t2,v18,0x4"}
!86 = !{!"[86] st32_i64 t2,v18,0x5"}
!87 = !{!"[87] st32_i64 t2,v18,0x6"}
!88 = !{!"[88] st32_i64 t2,v18,0x7"}
!89 = !{!"[89] st32_i64 t2,v18,0x8"}
!90 = !{!"[90] st32_i64 t2,v18,0x9"}
!91 = !{!"[91] st32_i64 t2,v18,0xa"}
!92 = !{!"[92] st32_i64 t2,v18,0xb"}
!93 = !{!"[93] st32_i64 t2,v18,0xc"}
!94 = !{!"[94] st32_i64 t2,v18,0xd"}
!95 = !{!"[95] st32_i64 t2,v18,0xe"}
!96 = !{!"[96] st32_i64 t2,v18,0xf"}
!97 = !{!"[97] st32_i64 t2,v18,0x10"}
!98 = !{!"[98] ld_vec v64,e32,[t13],v26"}
!99 = !{!"[99] st_vec v64,e8,t13,v0"}
!100 = !{!"[100] ld_vec v128,e16,[t14],v26"}
!101 = !{!"[101] st_vec v64,e32,t14,v0"}
!102 = !{!"[102] st_vec v64,e8,t13,v0:o1"}
!103 = !{!"[103] st_vec v64,e8,t13,v0:o2"}
!104 = !{!"[104] st_vec v64,e8,t13,v0:o3"}
!105 = !{!"[105] st_vec v64,e8,t13,v0:o4"}
!106 = !{!"[106] st_vec v64,e8,t13,v0:o5"}
!107 = !{!"[107] st_vec v64,e8,t13,v0:o6"}
!108 = !{!"[108] st_vec v64,e8,t13,v0:o7"}
!109 = !{!"[109] st_vec v64,e8,t13,v0:o8"}
!110 = !{!"[110] st_vec v64,e8,t13,v0:o9"}
!111 = !{!"[111] st_vec v64,e8,t13,v0:o10"}
!112 = !{!"[112] st_vec v64,e8,t13,v0:o11"}
!113 = !{!"[113] st_vec v64,e8,t13,v0:o12"}
!114 = !{!"[114] st_vec v64,e8,t13,v0:o13"}
!115 = !{!"[115] st_vec v64,e8,t13,v0:o14"}
!116 = !{!"[116] st_vec v64,e8,t13,v0:o15"}
!117 = !{!"[117] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2"}
!118 = !{!"[118] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2"}
!119 = !{!"[119] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2"}
!120 = !{!"[120] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2"}
!121 = !{!"[121] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2"}
!122 = !{!"[122] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2"}
!123 = !{!"[123] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2"}
!124 = !{!"[124] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC1B,0x2"}
!125 = !{!"[125] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC1B,0x2"}
!126 = !{!"[126] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC2B,0x2"}
!127 = !{!"[127] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC2B,0x2"}
!128 = !{!"[128] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC4B,0x2"}
!129 = !{!"[129] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC4B,0x2"}
!130 = !{!"[130] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!131 = !{!"[131] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_2:ZERO:SRC8B,0x2"}
!132 = !{!"[132] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_4:ZERO:SRC8B,0x2"}
!133 = !{!"[133] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B,0x2"}
!134 = !{!"[134] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC8B,0x2"}
!135 = !{!"[135] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_32:ZERO:SRC8B,0x2"}
!136 = !{!"[136] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_64:ZERO:SRC8B,0x2"}
!137 = !{!"[137] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2"}
!138 = !{!"[138] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2"}
!139 = !{!"[139] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2"}
!140 = !{!"[140] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2"}
!141 = !{!"[141] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2"}
!142 = !{!"[142] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2"}
!143 = !{!"[143] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2"}
!144 = !{!"[144] qemu_st_i64 t8,t7,attr-stg:ATOM_NONE:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!145 = !{!"[145] qemu_st_i64 t8,t7,attr-stg:ATOM_SUBALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!146 = !{!"[146] qemu_st_i64 t8,t7,attr-stg:ATOM_WITHIN16_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!147 = !{!"[147] qemu_st_i64 t8,t7,attr-stg:ATOM_WITHIN16:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!148 = !{!"[148] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!149 = !{!"[149] qemu_st2_i128 t10,t11,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC16B,0x2"}
!150 = !{!"[150] qemu_st2_i128 t10,t11,t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC16B,0x2"}
