; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h, ptr align 8 dereferenceable(26528) %cpu) #0 section ".text.Fx0" {
entry:
  %v1.stack = alloca <2 x i64>, align 16
  store <2 x i64> %ymm0_h, ptr %v1.stack, align 16, !tbaa !0
  %v19.stack = alloca <2 x i64>, align 16
  store <2 x i64> %ymm9_h, ptr %v19.stack, align 16, !tbaa !0
  %rcx.stack = alloca i64, align 8
  store i64 %rcx, ptr %rcx.stack, align 8, !tbaa !0
  %rax.stack = alloca i64, align 8
  store i64 %rax, ptr %rax.stack, align 8, !tbaa !0
  %rsp.stack = alloca i64, align 8
  store i64 %rsp, ptr %rsp.stack, align 8, !tbaa !0
  %v0.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm0, ptr %v0.stack, align 16, !tbaa !0
  %v4.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm2, ptr %v4.stack, align 16, !tbaa !0
  %v18.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm9, ptr %v18.stack, align 16, !tbaa !0
  %v26.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm13, ptr %v26.stack, align 16, !tbaa !0
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
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] ld8u_i32 [t0],env:0xab ========
  %T0.envptr = getelementptr i8, ptr %env, i64 171, !tcg.op !3
  %T0.envval = load i8, ptr %T0.envptr, align 1, !tbaa !4, !tcg.op !3
  %T0.out = zext i8 %T0.envval to i32, !tcg.op !3
  store i32 %T0.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !3
; ======== TCG [1] ld8u_i64 [t0],env:0xac ========
  %T1.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !6
  %T1.envval = load i8, ptr %T1.envptr, align 4, !tbaa !4, !tcg.op !6
  %T1.out = zext i8 %T1.envval to i64, !tcg.op !6
  store i64 %T1.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !6
; ======== TCG [2] ld16u_i32 [t0],env:0xab ========
  %T2.envptr = getelementptr i8, ptr %env, i64 171, !tcg.op !7
  %T2.envval = load i16, ptr %T2.envptr, align 1, !tbaa !4, !tcg.op !7
  %T2.out = zext i16 %T2.envval to i32, !tcg.op !7
  store i32 %T2.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !7
; ======== TCG [3] ld16u_i64 [t0],env:0xac ========
  %T3.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !8
  %T3.envval = load i16, ptr %T3.envptr, align 4, !tbaa !4, !tcg.op !8
  %T3.out = zext i16 %T3.envval to i64, !tcg.op !8
  store i64 %T3.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !8
; ======== TCG [4] ld32u_i64 [t0],env:0xac ========
  %T4.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !9
  %T4.envval = load i32, ptr %T4.envptr, align 4, !tbaa !4, !tcg.op !9
  %T4.out = zext i32 %T4.envval to i64, !tcg.op !9
  store i64 %T4.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !9
; ======== TCG [5] ld8s_i32 [t0],env:0xab ========
  %T5.envptr = getelementptr i8, ptr %env, i64 171, !tcg.op !10
  %T5.envval = load i8, ptr %T5.envptr, align 1, !tbaa !4, !tcg.op !10
  %T5.out = sext i8 %T5.envval to i32, !tcg.op !10
  store i32 %T5.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !10
; ======== TCG [6] ld8s_i64 [t0],env:0xac ========
  %T6.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !11
  %T6.envval = load i8, ptr %T6.envptr, align 4, !tbaa !4, !tcg.op !11
  %T6.out = sext i8 %T6.envval to i64, !tcg.op !11
  store i64 %T6.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !11
; ======== TCG [7] ld16s_i32 [t0],env:0xac ========
  %T7.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !12
  %T7.envval = load i16, ptr %T7.envptr, align 4, !tbaa !4, !tcg.op !12
  %T7.out = sext i16 %T7.envval to i32, !tcg.op !12
  store i32 %T7.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !12
; ======== TCG [8] ld16s_i64 [t0],env:0xac ========
  %T8.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !13
  %T8.envval = load i16, ptr %T8.envptr, align 4, !tbaa !4, !tcg.op !13
  %T8.out = sext i16 %T8.envval to i64, !tcg.op !13
  store i64 %T8.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !13
; ======== TCG [9] ld32s_i64 [t0],env:0xac ========
  %T9.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !14
  %T9.envval = load i32, ptr %T9.envptr, align 4, !tbaa !4, !tcg.op !14
  %T9.out = sext i32 %T9.envval to i64, !tcg.op !14
  store i64 %T9.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !14
; ======== TCG [10] ld32s_i64 [t2],v18,0x4 ========
  %T10.v18 = load <4 x i32>, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !15
  %T10.v18.ee = extractelement <4 x i32> %T10.v18, i64 1, !tcg.op !15
  %T10.out = sext i32 %T10.v18.ee to i64, !tcg.op !15
  store i64 %T10.out, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !15
; ======== TCG [11] ld_vec v128,e8,[t3],env:0xb60 ========
  %T11.envptr = getelementptr i8, ptr %env, i64 2912, !tcg.op !16
  %T11.envval = load <16 x i8>, ptr %T11.envptr, align 16, !tbaa !4, !tcg.op !16
  store <16 x i8> %T11.envval, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !16
; ======== TCG [12] ld_i32 [t4],env:0xd0 ========
  %T12.envptr = getelementptr i8, ptr %env, i64 208, !tcg.op !17
  %T12.envval = load i32, ptr %T12.envptr, align 16, !tbaa !4, !tcg.op !17
  store i32 %T12.envval, ptr %tmp4.stack, align 8, !tbaa !0, !tcg.op !17
; ======== TCG [13] ld_i64 [t5],env:0x88 ========
  %T13.envptr = getelementptr i8, ptr %env, i64 136, !tcg.op !18
  %T13.envval = load i64, ptr %T13.envptr, align 8, !tbaa !4, !tcg.op !18
  store i64 %T13.envval, ptr %tmp5.stack, align 8, !tbaa !0, !tcg.op !18
; ======== TCG [14] ld_i64 [t6],v4 ========
  %T14.v4 = load i64, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !19
  store i64 %T14.v4, ptr %tmp6.stack, align 8, !tbaa !0, !tcg.op !19
; ======== TCG [15] ld_i64 [t6],v4:o4 ========
  %T15.v4 = load <2 x i64>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !20
  %T15.envptr = getelementptr i8, ptr %env, i64 992, !tcg.op !20
  store <2 x i64> %T15.v4, ptr %T15.envptr, align 16, !tbaa !4, !tcg.op !20
  %T15.envptr1 = getelementptr i8, ptr %env, i64 996, !tcg.op !20
  %T15.envval = load i64, ptr %T15.envptr1, align 4, !tbaa !4, !tcg.op !20
  store i64 %T15.envval, ptr %tmp6.stack, align 8, !tbaa !0, !tcg.op !20
; ======== TCG [16] ld_i64 [t6],v4:o8 ========
  %T16.v4 = load <2 x i64>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !21
  %T16.v4.ee = extractelement <2 x i64> %T16.v4, i64 1, !tcg.op !21
  store i64 %T16.v4.ee, ptr %tmp6.stack, align 8, !tbaa !0, !tcg.op !21
; ======== TCG [17] add_i64 [t7],rsp,0x0 ========
  %T17.rsp = load i64, ptr %rsp.stack, align 8, !tbaa !0, !tcg.op !22
  %T17.out = add i64 %T17.rsp, 0, !tcg.op !22
  store i64 %T17.out, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !22
; ======== TCG [18] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2 ========
  %T18.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !23
  %T18.tmp7.ptr = inttoptr i64 %T18.tmp7 to ptr, !tcg.op !23
  %T18.ld = load i8, ptr %T18.tmp7.ptr, align 1, !tbaa !0, !tcg.op !23
  %T18.ld.zext = zext i8 %T18.ld to i64, !tcg.op !23
  store i64 %T18.ld.zext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !23
; ======== TCG [19] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:INVALID_ALIGNMENT:ZERO:SRC1B,0x2 ========
  %T19.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !24
  %T19.tmp7.ptr = inttoptr i64 %T19.tmp7 to ptr, !tcg.op !24
  %T19.ld = load i8, ptr %T19.tmp7.ptr, align 1, !tbaa !0, !tcg.op !24
  %T19.ld.zext = zext i8 %T19.ld to i64, !tcg.op !24
  store i64 %T19.ld.zext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !24
; ======== TCG [20] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2 ========
  %T20.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !25
  %T20.tmp7.ptr = inttoptr i64 %T20.tmp7 to ptr, !tcg.op !25
  %T20.ld = load i8, ptr %T20.tmp7.ptr, align 1, !tbaa !0, !tcg.op !25
  %T20.ld.sext = sext i8 %T20.ld to i64, !tcg.op !25
  store i64 %T20.ld.sext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !25
; ======== TCG [21] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2 ========
  %T21.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !26
  %T21.tmp7.ptr = inttoptr i64 %T21.tmp7 to ptr, !tcg.op !26
  %T21.ld = load i16, ptr %T21.tmp7.ptr, align 1, !tbaa !0, !tcg.op !26
  %T21.ld.zext = zext i16 %T21.ld to i64, !tcg.op !26
  store i64 %T21.ld.zext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !26
; ======== TCG [22] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2 ========
  %T22.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !27
  %T22.tmp7.ptr = inttoptr i64 %T22.tmp7 to ptr, !tcg.op !27
  %T22.ld = load i16, ptr %T22.tmp7.ptr, align 1, !tbaa !0, !tcg.op !27
  %T22.ld.sext = sext i16 %T22.ld to i64, !tcg.op !27
  store i64 %T22.ld.sext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !27
; ======== TCG [23] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2 ========
  %T23.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !28
  %T23.tmp7.ptr = inttoptr i64 %T23.tmp7 to ptr, !tcg.op !28
  %T23.ld = load i32, ptr %T23.tmp7.ptr, align 1, !tbaa !0, !tcg.op !28
  %T23.ld.zext = zext i32 %T23.ld to i64, !tcg.op !28
  store i64 %T23.ld.zext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !28
; ======== TCG [24] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2 ========
  %T24.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !29
  %T24.tmp7.ptr = inttoptr i64 %T24.tmp7 to ptr, !tcg.op !29
  %T24.ld = load i32, ptr %T24.tmp7.ptr, align 1, !tbaa !0, !tcg.op !29
  %T24.ld.sext = sext i32 %T24.ld to i64, !tcg.op !29
  store i64 %T24.ld.sext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !29
; ======== TCG [25] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2 ========
  %T25.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !30
  %T25.tmp7.ptr = inttoptr i64 %T25.tmp7 to ptr, !tcg.op !30
  %T25.ld = load i64, ptr %T25.tmp7.ptr, align 1, !tbaa !0, !tcg.op !30
  store i64 %T25.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !30
; ======== TCG [26] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC1B,0x2 ========
  %T26.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !31
  %T26.tmp7.ptr = inttoptr i64 %T26.tmp7 to ptr, !tcg.op !31
  %T26.ld = load i8, ptr %T26.tmp7.ptr, align 1, !tbaa !0, !tcg.op !31
  %T26.ld.zext = zext i8 %T26.ld to i64, !tcg.op !31
  store i64 %T26.ld.zext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !31
; ======== TCG [27] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC1B,0x2 ========
  %T27.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !32
  %T27.tmp7.ptr = inttoptr i64 %T27.tmp7 to ptr, !tcg.op !32
  %T27.ld = load i8, ptr %T27.tmp7.ptr, align 1, !tbaa !0, !tcg.op !32
  %T27.ld.sext = sext i8 %T27.ld to i64, !tcg.op !32
  store i64 %T27.ld.sext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !32
; ======== TCG [28] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC2B,0x2 ========
  %T28.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !33
  %T28.tmp7.ptr = inttoptr i64 %T28.tmp7 to ptr, !tcg.op !33
  %T28.ld = load i16, ptr %T28.tmp7.ptr, align 2, !tbaa !0, !tcg.op !33
  %T28.ld.zext = zext i16 %T28.ld to i64, !tcg.op !33
  store i64 %T28.ld.zext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !33
; ======== TCG [29] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC2B,0x2 ========
  %T29.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !34
  %T29.tmp7.ptr = inttoptr i64 %T29.tmp7 to ptr, !tcg.op !34
  %T29.ld = load i16, ptr %T29.tmp7.ptr, align 2, !tbaa !0, !tcg.op !34
  %T29.ld.sext = sext i16 %T29.ld to i64, !tcg.op !34
  store i64 %T29.ld.sext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !34
; ======== TCG [30] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC4B,0x2 ========
  %T30.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !35
  %T30.tmp7.ptr = inttoptr i64 %T30.tmp7 to ptr, !tcg.op !35
  %T30.ld = load i32, ptr %T30.tmp7.ptr, align 4, !tbaa !0, !tcg.op !35
  %T30.ld.zext = zext i32 %T30.ld to i64, !tcg.op !35
  store i64 %T30.ld.zext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !35
; ======== TCG [31] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC4B,0x2 ========
  %T31.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !36
  %T31.tmp7.ptr = inttoptr i64 %T31.tmp7 to ptr, !tcg.op !36
  %T31.ld = load i32, ptr %T31.tmp7.ptr, align 4, !tbaa !0, !tcg.op !36
  %T31.ld.sext = sext i32 %T31.ld to i64, !tcg.op !36
  store i64 %T31.ld.sext, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !36
; ======== TCG [32] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T32.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !37
  %T32.tmp7.ptr = inttoptr i64 %T32.tmp7 to ptr, !tcg.op !37
  %T32.ld = load i64, ptr %T32.tmp7.ptr, align 8, !tbaa !0, !tcg.op !37
  store i64 %T32.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !37
; ======== TCG [33] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_2:ZERO:SRC8B,0x2 ========
  %T33.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !38
  %T33.tmp7.ptr = inttoptr i64 %T33.tmp7 to ptr, !tcg.op !38
  %T33.ld = load i64, ptr %T33.tmp7.ptr, align 2, !tbaa !0, !tcg.op !38
  store i64 %T33.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !38
; ======== TCG [34] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_4:ZERO:SRC8B,0x2 ========
  %T34.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !39
  %T34.tmp7.ptr = inttoptr i64 %T34.tmp7 to ptr, !tcg.op !39
  %T34.ld = load i64, ptr %T34.tmp7.ptr, align 4, !tbaa !0, !tcg.op !39
  store i64 %T34.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !39
; ======== TCG [35] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B,0x2 ========
  %T35.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !40
  %T35.tmp7.ptr = inttoptr i64 %T35.tmp7 to ptr, !tcg.op !40
  %T35.ld = load i64, ptr %T35.tmp7.ptr, align 8, !tbaa !0, !tcg.op !40
  store i64 %T35.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !40
; ======== TCG [36] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC8B,0x2 ========
  %T36.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !41
  %T36.tmp7.ptr = inttoptr i64 %T36.tmp7 to ptr, !tcg.op !41
  %T36.ld = load i64, ptr %T36.tmp7.ptr, align 16, !tbaa !0, !tcg.op !41
  store i64 %T36.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !41
; ======== TCG [37] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_32:ZERO:SRC8B,0x2 ========
  %T37.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !42
  %T37.tmp7.ptr = inttoptr i64 %T37.tmp7 to ptr, !tcg.op !42
  %T37.ld = load i64, ptr %T37.tmp7.ptr, align 32, !tbaa !0, !tcg.op !42
  store i64 %T37.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !42
; ======== TCG [38] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_64:ZERO:SRC8B,0x2 ========
  %T38.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !43
  %T38.tmp7.ptr = inttoptr i64 %T38.tmp7 to ptr, !tcg.op !43
  %T38.ld = load i64, ptr %T38.tmp7.ptr, align 64, !tbaa !0, !tcg.op !43
  store i64 %T38.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !43
; ======== TCG [39] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2 ========
  %T39.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !44
  %T39.tmp7.ptr = inttoptr i64 %T39.tmp7 to ptr, !tcg.op !44
  %T39.ld = load i8, ptr %T39.tmp7.ptr, align 1, !tbaa !0, !tcg.op !44
  %T39.ld.zext = zext i8 %T39.ld to i32, !tcg.op !44
  store i32 %T39.ld.zext, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !44
; ======== TCG [40] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2 ========
  %T40.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !45
  %T40.tmp7.ptr = inttoptr i64 %T40.tmp7 to ptr, !tcg.op !45
  %T40.ld = load i8, ptr %T40.tmp7.ptr, align 1, !tbaa !0, !tcg.op !45
  %T40.ld.sext = sext i8 %T40.ld to i32, !tcg.op !45
  store i32 %T40.ld.sext, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !45
; ======== TCG [41] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2 ========
  %T41.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !46
  %T41.tmp7.ptr = inttoptr i64 %T41.tmp7 to ptr, !tcg.op !46
  %T41.ld = load i16, ptr %T41.tmp7.ptr, align 1, !tbaa !0, !tcg.op !46
  %T41.ld.zext = zext i16 %T41.ld to i32, !tcg.op !46
  store i32 %T41.ld.zext, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !46
; ======== TCG [42] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2 ========
  %T42.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !47
  %T42.tmp7.ptr = inttoptr i64 %T42.tmp7 to ptr, !tcg.op !47
  %T42.ld = load i16, ptr %T42.tmp7.ptr, align 1, !tbaa !0, !tcg.op !47
  %T42.ld.sext = sext i16 %T42.ld to i32, !tcg.op !47
  store i32 %T42.ld.sext, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !47
; ======== TCG [43] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2 ========
  %T43.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !48
  %T43.tmp7.ptr = inttoptr i64 %T43.tmp7 to ptr, !tcg.op !48
  %T43.ld = load i32, ptr %T43.tmp7.ptr, align 1, !tbaa !0, !tcg.op !48
  store i32 %T43.ld, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !48
; ======== TCG [44] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2 ========
  %T44.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !49
  %T44.tmp7.ptr = inttoptr i64 %T44.tmp7 to ptr, !tcg.op !49
  %T44.ld = load i32, ptr %T44.tmp7.ptr, align 1, !tbaa !0, !tcg.op !49
  store i32 %T44.ld, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !49
; ======== TCG [45] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2 ========
  %T45.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !50
  %T45.tmp7.ptr = inttoptr i64 %T45.tmp7 to ptr, !tcg.op !50
  %T45.ld = load i64, ptr %T45.tmp7.ptr, align 1, !tbaa !0, !tcg.op !50
  %T45.ld.trunc = trunc i64 %T45.ld to i32, !tcg.op !50
  store i32 %T45.ld.trunc, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !50
; ======== TCG [46] qemu_ld_i64 [t8],t7,attr-stg:ATOM_NONE:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T46.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !51
  %T46.tmp7.ptr = inttoptr i64 %T46.tmp7 to ptr, !tcg.op !51
  %T46.ld = load i64, ptr %T46.tmp7.ptr, align 8, !tbaa !0, !tcg.op !51
  store i64 %T46.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !51
; ======== TCG [47] qemu_ld_i64 [t8],t7,attr-stg:ATOM_SUBALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T47.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !52
  %T47.tmp7.ptr = inttoptr i64 %T47.tmp7 to ptr, !tcg.op !52
  %T47.ld = load i64, ptr %T47.tmp7.ptr, align 8, !tbaa !0, !tcg.op !52
  store i64 %T47.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !52
; ======== TCG [48] qemu_ld_i64 [t8],t7,attr-stg:ATOM_WITHIN16_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T48.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !53
  %T48.tmp7.ptr = inttoptr i64 %T48.tmp7 to ptr, !tcg.op !53
  %T48.ld = load i64, ptr %T48.tmp7.ptr, align 8, !tbaa !0, !tcg.op !53
  store i64 %T48.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !53
; ======== TCG [49] qemu_ld_i64 [t8],t7,attr-stg:ATOM_WITHIN16:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T49.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !54
  %T49.tmp7.ptr = inttoptr i64 %T49.tmp7 to ptr, !tcg.op !54
  %T49.ld = load i64, ptr %T49.tmp7.ptr, align 8, !tbaa !0, !tcg.op !54
  store i64 %T49.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !54
; ======== TCG [50] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T50.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !55
  %T50.tmp7.ptr = inttoptr i64 %T50.tmp7 to ptr, !tcg.op !55
  %T50.ld = load i64, ptr %T50.tmp7.ptr, align 8, !tbaa !0, !tcg.op !55
  store i64 %T50.ld, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !55
; ======== TCG [51] qemu_ld2_i128 [t10],[t11],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC16B,0x2 ========
  %T51.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !56
  %T51.tmp7.ptr = inttoptr i64 %T51.tmp7 to ptr, !tcg.op !56
  %T51.ld = load <2 x i64>, ptr %T51.tmp7.ptr, align 1, !tbaa !0, !tcg.op !56
  %T51.ld.ee = extractelement <2 x i64> %T51.ld, i64 0, !tcg.op !56
  store i64 %T51.ld.ee, ptr %tmp10.stack, align 8, !tbaa !0, !tcg.op !56
  %T51.ld.ee2 = extractelement <2 x i64> %T51.ld, i64 1, !tcg.op !56
  store i64 %T51.ld.ee2, ptr %tmp11.stack, align 8, !tbaa !0, !tcg.op !56
; ======== TCG [52] qemu_ld2_i128 [t10],[t11],t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC16B,0x2 ========
  %T52.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !57
  %T52.tmp7.ptr = inttoptr i64 %T52.tmp7 to ptr, !tcg.op !57
  %T52.ld = load <2 x i64>, ptr %T52.tmp7.ptr, align 16, !tbaa !0, !tcg.op !57
  %T52.ld.ee = extractelement <2 x i64> %T52.ld, i64 0, !tcg.op !57
  store i64 %T52.ld.ee, ptr %tmp10.stack, align 8, !tbaa !0, !tcg.op !57
  %T52.ld.ee3 = extractelement <2 x i64> %T52.ld, i64 1, !tcg.op !57
  store i64 %T52.ld.ee3, ptr %tmp11.stack, align 8, !tbaa !0, !tcg.op !57
; ======== TCG [53] st8_i32 t0,env:0xac ========
  %T53.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !58
  %T53.tmp0.trunc = trunc i32 %T53.tmp0 to i8, !tcg.op !58
  %T53.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !58
  store i8 %T53.tmp0.trunc, ptr %T53.envptr, align 4, !tbaa !4, !tcg.op !58
; ======== TCG [54] st8_i64 t0,env:0xac ========
  %T54.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !59
  %T54.tmp0.trunc = trunc i64 %T54.tmp0 to i8, !tcg.op !59
  %T54.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !59
  store i8 %T54.tmp0.trunc, ptr %T54.envptr, align 4, !tbaa !4, !tcg.op !59
; ======== TCG [55] st16_i32 t0,env:0xac ========
  %T55.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !60
  %T55.tmp0.trunc = trunc i32 %T55.tmp0 to i16, !tcg.op !60
  %T55.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !60
  store i16 %T55.tmp0.trunc, ptr %T55.envptr, align 4, !tbaa !4, !tcg.op !60
; ======== TCG [56] st16_i64 t0,env:0xac ========
  %T56.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !61
  %T56.tmp0.trunc = trunc i64 %T56.tmp0 to i16, !tcg.op !61
  %T56.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !61
  store i16 %T56.tmp0.trunc, ptr %T56.envptr, align 4, !tbaa !4, !tcg.op !61
; ======== TCG [57] st32_i64 t0,env:0xac ========
  %T57.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !62
  %T57.tmp0.trunc = trunc i64 %T57.tmp0 to i32, !tcg.op !62
  %T57.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !62
  store i32 %T57.tmp0.trunc, ptr %T57.envptr, align 4, !tbaa !4, !tcg.op !62
; ======== TCG [58] st_i32 t0,env:0xac ========
  %T58.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !63
  %T58.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !63
  store i32 %T58.tmp0, ptr %T58.envptr, align 4, !tbaa !4, !tcg.op !63
; ======== TCG [59] st_i64 t0,env:0xac ========
  %T59.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !64
  %T59.envptr = getelementptr i8, ptr %env, i64 172, !tcg.op !64
  store i64 %T59.tmp0, ptr %T59.envptr, align 4, !tbaa !4, !tcg.op !64
; ======== TCG [60] st32_i64 t2,v18,0x4 ========
  %T60.tmp2 = load i64, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !65
  %T60.tmp2.trunc = trunc i64 %T60.tmp2 to i32, !tcg.op !65
  %T60.v18 = load <4 x i32>, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !65
  %T60.tmp2.trunc.ie = insertelement <4 x i32> %T60.v18, i32 %T60.tmp2.trunc, i64 1, !tcg.op !65
  store <4 x i32> %T60.tmp2.trunc.ie, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !65
; ======== TCG [61] st32_i64 t2,v18,0x2 ========
  %T61.tmp2 = load i64, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !66
  %T61.tmp2.trunc = trunc i64 %T61.tmp2 to i32, !tcg.op !66
  %T61.envptr = getelementptr i8, ptr %env, i64 1442, !tcg.op !66
  %T61.envptr4 = getelementptr i8, ptr %env, i64 1440, !tcg.op !66
  %T61.v18 = load <2 x i64>, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !66
  store <2 x i64> %T61.v18, ptr %T61.envptr4, align 16, !tbaa !4, !tcg.op !66
  store i32 %T61.tmp2.trunc, ptr %T61.envptr, align 2, !tbaa !4, !tcg.op !66
  %T61.envptr5 = getelementptr i8, ptr %env, i64 1440, !tcg.op !66
  %T61.envval = load <2 x i64>, ptr %T61.envptr5, align 16, !tbaa !4, !tcg.op !66
  store <2 x i64> %T61.envval, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !66
; ======== TCG [62] add_vec v128,e64,[t12],v18,v18 ========
  %T62.v18 = load <2 x i64>, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !67
  %T62.v186 = load <2 x i64>, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !67
  %T62.out = add <2 x i64> %T62.v18, %T62.v186, !tcg.op !67
  store <2 x i64> %T62.out, ptr %tmp12.stack, align 16, !tbaa !0, !tcg.op !67
; ======== TCG [63] st_i64 t0,env ========
  %T63.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !68
  %T63.envptr = getelementptr i8, ptr %env, i64 0, !tcg.op !68
  %T63.envptr7 = getelementptr i8, ptr %env, i64 0, !tcg.op !68
  %T63.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !68
  store i64 %T63.rax, ptr %T63.envptr7, align 16, !tbaa !4, !tcg.op !68
  store i64 %T63.tmp0, ptr %T63.envptr, align 16, !tbaa !4, !tcg.op !68
  %T63.envptr8 = getelementptr i8, ptr %env, i64 0, !tcg.op !68
  %T63.envval = load i64, ptr %T63.envptr8, align 16, !tbaa !4, !tcg.op !68
  store i64 %T63.envval, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !68
; ======== TCG [64] st_i64 t0,env:0x1 ========
  %T64.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !69
  %T64.envptr = getelementptr i8, ptr %env, i64 1, !tcg.op !69
  %T64.envptr9 = getelementptr i8, ptr %env, i64 0, !tcg.op !69
  %T64.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !69
  store i64 %T64.rax, ptr %T64.envptr9, align 16, !tbaa !4, !tcg.op !69
  %T64.envptr10 = getelementptr i8, ptr %env, i64 8, !tcg.op !69
  %T64.rcx = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !69
  store i64 %T64.rcx, ptr %T64.envptr10, align 8, !tbaa !4, !tcg.op !69
  store i64 %T64.tmp0, ptr %T64.envptr, align 1, !tbaa !4, !tcg.op !69
  %T64.envptr11 = getelementptr i8, ptr %env, i64 0, !tcg.op !69
  %T64.envval = load i64, ptr %T64.envptr11, align 16, !tbaa !4, !tcg.op !69
  store i64 %T64.envval, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !69
  %T64.envptr12 = getelementptr i8, ptr %env, i64 8, !tcg.op !69
  %T64.envval13 = load i64, ptr %T64.envptr12, align 8, !tbaa !4, !tcg.op !69
  store i64 %T64.envval13, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !69
; ======== TCG [65] st_i32 t0,env ========
  %T65.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !70
  %T65.envptr = getelementptr i8, ptr %env, i64 0, !tcg.op !70
  %T65.envptr14 = getelementptr i8, ptr %env, i64 0, !tcg.op !70
  %T65.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !70
  store i64 %T65.rax, ptr %T65.envptr14, align 16, !tbaa !4, !tcg.op !70
  store i32 %T65.tmp0, ptr %T65.envptr, align 16, !tbaa !4, !tcg.op !70
  %T65.envptr15 = getelementptr i8, ptr %env, i64 0, !tcg.op !70
  %T65.envval = load i64, ptr %T65.envptr15, align 16, !tbaa !4, !tcg.op !70
  store i64 %T65.envval, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !70
; ======== TCG [66] st_i32 t0,env:0x5 ========
  %T66.tmp0 = load i32, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !71
  %T66.envptr = getelementptr i8, ptr %env, i64 5, !tcg.op !71
  %T66.envptr16 = getelementptr i8, ptr %env, i64 0, !tcg.op !71
  %T66.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !71
  store i64 %T66.rax, ptr %T66.envptr16, align 16, !tbaa !4, !tcg.op !71
  %T66.envptr17 = getelementptr i8, ptr %env, i64 8, !tcg.op !71
  %T66.rcx = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !71
  store i64 %T66.rcx, ptr %T66.envptr17, align 8, !tbaa !4, !tcg.op !71
  store i32 %T66.tmp0, ptr %T66.envptr, align 1, !tbaa !4, !tcg.op !71
  %T66.envptr18 = getelementptr i8, ptr %env, i64 0, !tcg.op !71
  %T66.envval = load i64, ptr %T66.envptr18, align 16, !tbaa !4, !tcg.op !71
  store i64 %T66.envval, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !71
  %T66.envptr19 = getelementptr i8, ptr %env, i64 8, !tcg.op !71
  %T66.envval20 = load i64, ptr %T66.envptr19, align 8, !tbaa !4, !tcg.op !71
  store i64 %T66.envval20, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !71
; ======== TCG [67] st32_i64 t2,v18 ========
  %T67.tmp2 = load i64, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !72
  %T67.tmp2.trunc = trunc i64 %T67.tmp2 to i32, !tcg.op !72
  store i32 %T67.tmp2.trunc, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !72
; ======== TCG [68] st32_i64 t2,v18,0x1 ========
  %T68.tmp2 = load i64, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !73
  %T68.tmp2.trunc = trunc i64 %T68.tmp2 to i32, !tcg.op !73
  %T68.envptr = getelementptr i8, ptr %env, i64 1441, !tcg.op !73
  %T68.envptr21 = getelementptr i8, ptr %env, i64 1440, !tcg.op !73
  %T68.v18 = load <2 x i64>, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !73
  store <2 x i64> %T68.v18, ptr %T68.envptr21, align 16, !tbaa !4, !tcg.op !73
  store i32 %T68.tmp2.trunc, ptr %T68.envptr, align 1, !tbaa !4, !tcg.op !73
  %T68.envptr22 = getelementptr i8, ptr %env, i64 1440, !tcg.op !73
  %T68.envval = load <2 x i64>, ptr %T68.envptr22, align 16, !tbaa !4, !tcg.op !73
  store <2 x i64> %T68.envval, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !73
; ======== TCG [69] st32_i64 t2,v18,0x4 ========
  %T69.tmp2 = load i64, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !74
  %T69.tmp2.trunc = trunc i64 %T69.tmp2 to i32, !tcg.op !74
  %T69.v18 = load <4 x i32>, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !74
  %T69.tmp2.trunc.ie = insertelement <4 x i32> %T69.v18, i32 %T69.tmp2.trunc, i64 1, !tcg.op !74
  store <4 x i32> %T69.tmp2.trunc.ie, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !74
; ======== TCG [70] st32_i64 t2,v18,0xd ========
  %T70.tmp2 = load i64, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !75
  %T70.tmp2.trunc = trunc i64 %T70.tmp2 to i32, !tcg.op !75
  %T70.envptr = getelementptr i8, ptr %env, i64 1453, !tcg.op !75
  %T70.envptr23 = getelementptr i8, ptr %env, i64 1440, !tcg.op !75
  %T70.v18 = load <2 x i64>, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !75
  store <2 x i64> %T70.v18, ptr %T70.envptr23, align 16, !tbaa !4, !tcg.op !75
  %T70.envptr24 = getelementptr i8, ptr %env, i64 1456, !tcg.op !75
  %T70.v19 = load <2 x i64>, ptr %v19.stack, align 16, !tbaa !0, !tcg.op !75
  store <2 x i64> %T70.v19, ptr %T70.envptr24, align 16, !tbaa !4, !tcg.op !75
  store i32 %T70.tmp2.trunc, ptr %T70.envptr, align 1, !tbaa !4, !tcg.op !75
  %T70.envptr25 = getelementptr i8, ptr %env, i64 1440, !tcg.op !75
  %T70.envval = load <2 x i64>, ptr %T70.envptr25, align 16, !tbaa !4, !tcg.op !75
  store <2 x i64> %T70.envval, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !75
  %T70.envptr26 = getelementptr i8, ptr %env, i64 1456, !tcg.op !75
  %T70.envval27 = load <2 x i64>, ptr %T70.envptr26, align 16, !tbaa !4, !tcg.op !75
  store <2 x i64> %T70.envval27, ptr %v19.stack, align 16, !tbaa !0, !tcg.op !75
; ======== TCG [71] ld_vec v64,e32,[t13],v26 ========
  %T71.v26 = load <2 x i32>, ptr %v26.stack, align 16, !tbaa !0, !tcg.op !76
  store <2 x i32> %T71.v26, ptr %tmp13.stack, align 16, !tbaa !0, !tcg.op !76
; ======== TCG [72] st_vec v64,e8,t13,v0 ========
  %T72.tmp13 = load <8 x i8>, ptr %tmp13.stack, align 16, !tbaa !0, !tcg.op !77
  store <8 x i8> %T72.tmp13, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !77
; ======== TCG [73] ld_vec v128,e16,[t14],v26 ========
  %T73.v26 = load <8 x i16>, ptr %v26.stack, align 16, !tbaa !0, !tcg.op !78
  store <8 x i16> %T73.v26, ptr %tmp14.stack, align 16, !tbaa !0, !tcg.op !78
; ======== TCG [74] st_vec v64,e32,t14,v0 ========
  %T74.tmp14 = load <2 x i32>, ptr %tmp14.stack, align 16, !tbaa !0, !tcg.op !79
  store <2 x i32> %T74.tmp14, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !79
; ======== TCG [75] st_vec v64,e8,t13,v0:o1 ========
  %T75.tmp13 = load <8 x i8>, ptr %tmp13.stack, align 16, !tbaa !0, !tcg.op !80
  %T75.envptr = getelementptr i8, ptr %env, i64 865, !tcg.op !80
  %T75.envptr28 = getelementptr i8, ptr %env, i64 864, !tcg.op !80
  %T75.v0 = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !80
  store <2 x i64> %T75.v0, ptr %T75.envptr28, align 16, !tbaa !4, !tcg.op !80
  store <8 x i8> %T75.tmp13, ptr %T75.envptr, align 1, !tbaa !4, !tcg.op !80
  %T75.envptr29 = getelementptr i8, ptr %env, i64 864, !tcg.op !80
  %T75.envval = load <2 x i64>, ptr %T75.envptr29, align 16, !tbaa !4, !tcg.op !80
  store <2 x i64> %T75.envval, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !80
; ======== TCG [76] st_vec v64,e8,t13,v0:o9 ========
  %T76.tmp13 = load <8 x i8>, ptr %tmp13.stack, align 16, !tbaa !0, !tcg.op !81
  %T76.envptr = getelementptr i8, ptr %env, i64 873, !tcg.op !81
  %T76.envptr30 = getelementptr i8, ptr %env, i64 864, !tcg.op !81
  %T76.v0 = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !81
  store <2 x i64> %T76.v0, ptr %T76.envptr30, align 16, !tbaa !4, !tcg.op !81
  %T76.envptr31 = getelementptr i8, ptr %env, i64 880, !tcg.op !81
  %T76.v1 = load <2 x i64>, ptr %v1.stack, align 16, !tbaa !0, !tcg.op !81
  store <2 x i64> %T76.v1, ptr %T76.envptr31, align 16, !tbaa !4, !tcg.op !81
  store <8 x i8> %T76.tmp13, ptr %T76.envptr, align 1, !tbaa !4, !tcg.op !81
  %T76.envptr32 = getelementptr i8, ptr %env, i64 864, !tcg.op !81
  %T76.envval = load <2 x i64>, ptr %T76.envptr32, align 16, !tbaa !4, !tcg.op !81
  store <2 x i64> %T76.envval, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !81
  %T76.envptr33 = getelementptr i8, ptr %env, i64 880, !tcg.op !81
  %T76.envval34 = load <2 x i64>, ptr %T76.envptr33, align 16, !tbaa !4, !tcg.op !81
  store <2 x i64> %T76.envval34, ptr %v1.stack, align 16, !tbaa !0, !tcg.op !81
; ======== TCG [77] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2 ========
  %T77.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !82
  %T77.tmp7.ptr = inttoptr i64 %T77.tmp7 to ptr, !tcg.op !82
  %T77.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !82
  %T77.tmp8.trunc = trunc i64 %T77.tmp8 to i8, !tcg.op !82
  store i8 %T77.tmp8.trunc, ptr %T77.tmp7.ptr, align 1, !tbaa !0, !tcg.op !82
; ======== TCG [78] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2 ========
  %T78.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !83
  %T78.tmp7.ptr = inttoptr i64 %T78.tmp7 to ptr, !tcg.op !83
  %T78.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !83
  %T78.tmp8.trunc = trunc i64 %T78.tmp8 to i8, !tcg.op !83
  store i8 %T78.tmp8.trunc, ptr %T78.tmp7.ptr, align 1, !tbaa !0, !tcg.op !83
; ======== TCG [79] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2 ========
  %T79.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !84
  %T79.tmp7.ptr = inttoptr i64 %T79.tmp7 to ptr, !tcg.op !84
  %T79.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !84
  %T79.tmp8.trunc = trunc i64 %T79.tmp8 to i16, !tcg.op !84
  store i16 %T79.tmp8.trunc, ptr %T79.tmp7.ptr, align 1, !tbaa !0, !tcg.op !84
; ======== TCG [80] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2 ========
  %T80.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !85
  %T80.tmp7.ptr = inttoptr i64 %T80.tmp7 to ptr, !tcg.op !85
  %T80.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !85
  %T80.tmp8.trunc = trunc i64 %T80.tmp8 to i16, !tcg.op !85
  store i16 %T80.tmp8.trunc, ptr %T80.tmp7.ptr, align 1, !tbaa !0, !tcg.op !85
; ======== TCG [81] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2 ========
  %T81.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !86
  %T81.tmp7.ptr = inttoptr i64 %T81.tmp7 to ptr, !tcg.op !86
  %T81.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !86
  %T81.tmp8.trunc = trunc i64 %T81.tmp8 to i32, !tcg.op !86
  store i32 %T81.tmp8.trunc, ptr %T81.tmp7.ptr, align 1, !tbaa !0, !tcg.op !86
; ======== TCG [82] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2 ========
  %T82.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !87
  %T82.tmp7.ptr = inttoptr i64 %T82.tmp7 to ptr, !tcg.op !87
  %T82.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !87
  %T82.tmp8.trunc = trunc i64 %T82.tmp8 to i32, !tcg.op !87
  store i32 %T82.tmp8.trunc, ptr %T82.tmp7.ptr, align 1, !tbaa !0, !tcg.op !87
; ======== TCG [83] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2 ========
  %T83.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !88
  %T83.tmp7.ptr = inttoptr i64 %T83.tmp7 to ptr, !tcg.op !88
  %T83.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !88
  store i64 %T83.tmp8, ptr %T83.tmp7.ptr, align 1, !tbaa !0, !tcg.op !88
; ======== TCG [84] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC1B,0x2 ========
  %T84.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !89
  %T84.tmp7.ptr = inttoptr i64 %T84.tmp7 to ptr, !tcg.op !89
  %T84.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !89
  %T84.tmp8.trunc = trunc i64 %T84.tmp8 to i8, !tcg.op !89
  store i8 %T84.tmp8.trunc, ptr %T84.tmp7.ptr, align 1, !tbaa !0, !tcg.op !89
; ======== TCG [85] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC1B,0x2 ========
  %T85.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !90
  %T85.tmp7.ptr = inttoptr i64 %T85.tmp7 to ptr, !tcg.op !90
  %T85.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !90
  %T85.tmp8.trunc = trunc i64 %T85.tmp8 to i8, !tcg.op !90
  store i8 %T85.tmp8.trunc, ptr %T85.tmp7.ptr, align 1, !tbaa !0, !tcg.op !90
; ======== TCG [86] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC2B,0x2 ========
  %T86.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !91
  %T86.tmp7.ptr = inttoptr i64 %T86.tmp7 to ptr, !tcg.op !91
  %T86.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !91
  %T86.tmp8.trunc = trunc i64 %T86.tmp8 to i16, !tcg.op !91
  store i16 %T86.tmp8.trunc, ptr %T86.tmp7.ptr, align 2, !tbaa !0, !tcg.op !91
; ======== TCG [87] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC2B,0x2 ========
  %T87.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !92
  %T87.tmp7.ptr = inttoptr i64 %T87.tmp7 to ptr, !tcg.op !92
  %T87.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !92
  %T87.tmp8.trunc = trunc i64 %T87.tmp8 to i16, !tcg.op !92
  store i16 %T87.tmp8.trunc, ptr %T87.tmp7.ptr, align 2, !tbaa !0, !tcg.op !92
; ======== TCG [88] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC4B,0x2 ========
  %T88.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !93
  %T88.tmp7.ptr = inttoptr i64 %T88.tmp7 to ptr, !tcg.op !93
  %T88.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !93
  %T88.tmp8.trunc = trunc i64 %T88.tmp8 to i32, !tcg.op !93
  store i32 %T88.tmp8.trunc, ptr %T88.tmp7.ptr, align 4, !tbaa !0, !tcg.op !93
; ======== TCG [89] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC4B,0x2 ========
  %T89.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !94
  %T89.tmp7.ptr = inttoptr i64 %T89.tmp7 to ptr, !tcg.op !94
  %T89.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !94
  %T89.tmp8.trunc = trunc i64 %T89.tmp8 to i32, !tcg.op !94
  store i32 %T89.tmp8.trunc, ptr %T89.tmp7.ptr, align 4, !tbaa !0, !tcg.op !94
; ======== TCG [90] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T90.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !95
  %T90.tmp7.ptr = inttoptr i64 %T90.tmp7 to ptr, !tcg.op !95
  %T90.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !95
  store i64 %T90.tmp8, ptr %T90.tmp7.ptr, align 8, !tbaa !0, !tcg.op !95
; ======== TCG [91] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_2:ZERO:SRC8B,0x2 ========
  %T91.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !96
  %T91.tmp7.ptr = inttoptr i64 %T91.tmp7 to ptr, !tcg.op !96
  %T91.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !96
  store i64 %T91.tmp8, ptr %T91.tmp7.ptr, align 2, !tbaa !0, !tcg.op !96
; ======== TCG [92] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_4:ZERO:SRC8B,0x2 ========
  %T92.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !97
  %T92.tmp7.ptr = inttoptr i64 %T92.tmp7 to ptr, !tcg.op !97
  %T92.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !97
  store i64 %T92.tmp8, ptr %T92.tmp7.ptr, align 4, !tbaa !0, !tcg.op !97
; ======== TCG [93] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B,0x2 ========
  %T93.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !98
  %T93.tmp7.ptr = inttoptr i64 %T93.tmp7 to ptr, !tcg.op !98
  %T93.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !98
  store i64 %T93.tmp8, ptr %T93.tmp7.ptr, align 8, !tbaa !0, !tcg.op !98
; ======== TCG [94] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC8B,0x2 ========
  %T94.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !99
  %T94.tmp7.ptr = inttoptr i64 %T94.tmp7 to ptr, !tcg.op !99
  %T94.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !99
  store i64 %T94.tmp8, ptr %T94.tmp7.ptr, align 16, !tbaa !0, !tcg.op !99
; ======== TCG [95] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_32:ZERO:SRC8B,0x2 ========
  %T95.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !100
  %T95.tmp7.ptr = inttoptr i64 %T95.tmp7 to ptr, !tcg.op !100
  %T95.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !100
  store i64 %T95.tmp8, ptr %T95.tmp7.ptr, align 32, !tbaa !0, !tcg.op !100
; ======== TCG [96] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_64:ZERO:SRC8B,0x2 ========
  %T96.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !101
  %T96.tmp7.ptr = inttoptr i64 %T96.tmp7 to ptr, !tcg.op !101
  %T96.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !101
  store i64 %T96.tmp8, ptr %T96.tmp7.ptr, align 64, !tbaa !0, !tcg.op !101
; ======== TCG [97] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2 ========
  %T97.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !102
  %T97.tmp7.ptr = inttoptr i64 %T97.tmp7 to ptr, !tcg.op !102
  %T97.tmp9 = load i32, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !102
  %T97.tmp9.trunc = trunc i32 %T97.tmp9 to i8, !tcg.op !102
  store i8 %T97.tmp9.trunc, ptr %T97.tmp7.ptr, align 1, !tbaa !0, !tcg.op !102
; ======== TCG [98] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2 ========
  %T98.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !103
  %T98.tmp7.ptr = inttoptr i64 %T98.tmp7 to ptr, !tcg.op !103
  %T98.tmp9 = load i32, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !103
  %T98.tmp9.trunc = trunc i32 %T98.tmp9 to i8, !tcg.op !103
  store i8 %T98.tmp9.trunc, ptr %T98.tmp7.ptr, align 1, !tbaa !0, !tcg.op !103
; ======== TCG [99] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2 ========
  %T99.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !104
  %T99.tmp7.ptr = inttoptr i64 %T99.tmp7 to ptr, !tcg.op !104
  %T99.tmp9 = load i32, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !104
  %T99.tmp9.trunc = trunc i32 %T99.tmp9 to i16, !tcg.op !104
  store i16 %T99.tmp9.trunc, ptr %T99.tmp7.ptr, align 1, !tbaa !0, !tcg.op !104
; ======== TCG [100] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2 ========
  %T100.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !105
  %T100.tmp7.ptr = inttoptr i64 %T100.tmp7 to ptr, !tcg.op !105
  %T100.tmp9 = load i32, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !105
  %T100.tmp9.trunc = trunc i32 %T100.tmp9 to i16, !tcg.op !105
  store i16 %T100.tmp9.trunc, ptr %T100.tmp7.ptr, align 1, !tbaa !0, !tcg.op !105
; ======== TCG [101] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2 ========
  %T101.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !106
  %T101.tmp7.ptr = inttoptr i64 %T101.tmp7 to ptr, !tcg.op !106
  %T101.tmp9 = load i32, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !106
  store i32 %T101.tmp9, ptr %T101.tmp7.ptr, align 1, !tbaa !0, !tcg.op !106
; ======== TCG [102] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2 ========
  %T102.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !107
  %T102.tmp7.ptr = inttoptr i64 %T102.tmp7 to ptr, !tcg.op !107
  %T102.tmp9 = load i32, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !107
  store i32 %T102.tmp9, ptr %T102.tmp7.ptr, align 1, !tbaa !0, !tcg.op !107
; ======== TCG [103] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2 ========
  %T103.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !108
  %T103.tmp7.ptr = inttoptr i64 %T103.tmp7 to ptr, !tcg.op !108
  %T103.tmp9 = load i32, ptr %tmp9.stack, align 8, !tbaa !0, !tcg.op !108
  %T103.tmp9.zext = zext i32 %T103.tmp9 to i64, !tcg.op !108
  store i64 %T103.tmp9.zext, ptr %T103.tmp7.ptr, align 1, !tbaa !0, !tcg.op !108
; ======== TCG [104] qemu_st_i64 t8,t7,attr-stg:ATOM_NONE:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T104.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !109
  %T104.tmp7.ptr = inttoptr i64 %T104.tmp7 to ptr, !tcg.op !109
  %T104.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !109
  store i64 %T104.tmp8, ptr %T104.tmp7.ptr, align 8, !tbaa !0, !tcg.op !109
; ======== TCG [105] qemu_st_i64 t8,t7,attr-stg:ATOM_SUBALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T105.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !110
  %T105.tmp7.ptr = inttoptr i64 %T105.tmp7 to ptr, !tcg.op !110
  %T105.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !110
  store i64 %T105.tmp8, ptr %T105.tmp7.ptr, align 8, !tbaa !0, !tcg.op !110
; ======== TCG [106] qemu_st_i64 t8,t7,attr-stg:ATOM_WITHIN16_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T106.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !111
  %T106.tmp7.ptr = inttoptr i64 %T106.tmp7 to ptr, !tcg.op !111
  %T106.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !111
  store i64 %T106.tmp8, ptr %T106.tmp7.ptr, align 8, !tbaa !0, !tcg.op !111
; ======== TCG [107] qemu_st_i64 t8,t7,attr-stg:ATOM_WITHIN16:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T107.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !112
  %T107.tmp7.ptr = inttoptr i64 %T107.tmp7 to ptr, !tcg.op !112
  %T107.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !112
  store i64 %T107.tmp8, ptr %T107.tmp7.ptr, align 8, !tbaa !0, !tcg.op !112
; ======== TCG [108] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2 ========
  %T108.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !113
  %T108.tmp7.ptr = inttoptr i64 %T108.tmp7 to ptr, !tcg.op !113
  %T108.tmp8 = load i64, ptr %tmp8.stack, align 8, !tbaa !0, !tcg.op !113
  store i64 %T108.tmp8, ptr %T108.tmp7.ptr, align 8, !tbaa !0, !tcg.op !113
; ======== TCG [109] qemu_st2_i128 t10,t11,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC16B,0x2 ========
  %T109.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !114
  %T109.tmp7.ptr = inttoptr i64 %T109.tmp7 to ptr, !tcg.op !114
  %T109.tmp10 = load i64, ptr %tmp10.stack, align 8, !tbaa !0, !tcg.op !114
  %T109.tmp11 = load i64, ptr %tmp11.stack, align 8, !tbaa !0, !tcg.op !114
  %T109.st2.ie = insertelement <2 x i64> zeroinitializer, i64 %T109.tmp10, i64 0, !tcg.op !114
  %T109.st2.ie35 = insertelement <2 x i64> %T109.st2.ie, i64 %T109.tmp11, i64 1, !tcg.op !114
  store <2 x i64> %T109.st2.ie35, ptr %T109.tmp7.ptr, align 1, !tbaa !0, !tcg.op !114
; ======== TCG [110] qemu_st2_i128 t10,t11,t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC16B,0x2 ========
  %T110.tmp7 = load i64, ptr %tmp7.stack, align 8, !tbaa !0, !tcg.op !115
  %T110.tmp7.ptr = inttoptr i64 %T110.tmp7 to ptr, !tcg.op !115
  %T110.tmp10 = load i64, ptr %tmp10.stack, align 8, !tbaa !0, !tcg.op !115
  %T110.tmp11 = load i64, ptr %tmp11.stack, align 8, !tbaa !0, !tcg.op !115
  %T110.st2.ie = insertelement <2 x i64> zeroinitializer, i64 %T110.tmp10, i64 0, !tcg.op !115
  %T110.st2.ie36 = insertelement <2 x i64> %T110.st2.ie, i64 %T110.tmp11, i64 1, !tcg.op !115
  store <2 x i64> %T110.st2.ie36, ptr %T110.tmp7.ptr, align 16, !tbaa !0, !tcg.op !115
}

attributes #0 = { noinline nounwind "target-features"="+neon" }

!0 = !{!1, !1, i64 0}
!1 = !{!"GuestMem", !2}
!2 = !{!"Root"}
!3 = !{!"[0] ld8u_i32 [t0],env:0xab"}
!4 = !{!5, !5, i64 0}
!5 = !{!"CPUState", !2}
!6 = !{!"[1] ld8u_i64 [t0],env:0xac"}
!7 = !{!"[2] ld16u_i32 [t0],env:0xab"}
!8 = !{!"[3] ld16u_i64 [t0],env:0xac"}
!9 = !{!"[4] ld32u_i64 [t0],env:0xac"}
!10 = !{!"[5] ld8s_i32 [t0],env:0xab"}
!11 = !{!"[6] ld8s_i64 [t0],env:0xac"}
!12 = !{!"[7] ld16s_i32 [t0],env:0xac"}
!13 = !{!"[8] ld16s_i64 [t0],env:0xac"}
!14 = !{!"[9] ld32s_i64 [t0],env:0xac"}
!15 = !{!"[10] ld32s_i64 [t2],v18,0x4"}
!16 = !{!"[11] ld_vec v128,e8,[t3],env:0xb60"}
!17 = !{!"[12] ld_i32 [t4],env:0xd0"}
!18 = !{!"[13] ld_i64 [t5],env:0x88"}
!19 = !{!"[14] ld_i64 [t6],v4"}
!20 = !{!"[15] ld_i64 [t6],v4:o4"}
!21 = !{!"[16] ld_i64 [t6],v4:o8"}
!22 = !{!"[17] add_i64 [t7],rsp,0x0"}
!23 = !{!"[18] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2"}
!24 = !{!"[19] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:INVALID_ALIGNMENT:ZERO:SRC1B,0x2"}
!25 = !{!"[20] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2"}
!26 = !{!"[21] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2"}
!27 = !{!"[22] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2"}
!28 = !{!"[23] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2"}
!29 = !{!"[24] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2"}
!30 = !{!"[25] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2"}
!31 = !{!"[26] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC1B,0x2"}
!32 = !{!"[27] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC1B,0x2"}
!33 = !{!"[28] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC2B,0x2"}
!34 = !{!"[29] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC2B,0x2"}
!35 = !{!"[30] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC4B,0x2"}
!36 = !{!"[31] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC4B,0x2"}
!37 = !{!"[32] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!38 = !{!"[33] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_2:ZERO:SRC8B,0x2"}
!39 = !{!"[34] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_4:ZERO:SRC8B,0x2"}
!40 = !{!"[35] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B,0x2"}
!41 = !{!"[36] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC8B,0x2"}
!42 = !{!"[37] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_32:ZERO:SRC8B,0x2"}
!43 = !{!"[38] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN:ALIGN_64:ZERO:SRC8B,0x2"}
!44 = !{!"[39] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2"}
!45 = !{!"[40] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2"}
!46 = !{!"[41] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2"}
!47 = !{!"[42] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2"}
!48 = !{!"[43] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2"}
!49 = !{!"[44] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2"}
!50 = !{!"[45] qemu_ld_i32 [t9],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2"}
!51 = !{!"[46] qemu_ld_i64 [t8],t7,attr-stg:ATOM_NONE:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!52 = !{!"[47] qemu_ld_i64 [t8],t7,attr-stg:ATOM_SUBALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!53 = !{!"[48] qemu_ld_i64 [t8],t7,attr-stg:ATOM_WITHIN16_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!54 = !{!"[49] qemu_ld_i64 [t8],t7,attr-stg:ATOM_WITHIN16:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!55 = !{!"[50] qemu_ld_i64 [t8],t7,attr-stg:ATOM_IFALIGN_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!56 = !{!"[51] qemu_ld2_i128 [t10],[t11],t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC16B,0x2"}
!57 = !{!"[52] qemu_ld2_i128 [t10],[t11],t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC16B,0x2"}
!58 = !{!"[53] st8_i32 t0,env:0xac"}
!59 = !{!"[54] st8_i64 t0,env:0xac"}
!60 = !{!"[55] st16_i32 t0,env:0xac"}
!61 = !{!"[56] st16_i64 t0,env:0xac"}
!62 = !{!"[57] st32_i64 t0,env:0xac"}
!63 = !{!"[58] st_i32 t0,env:0xac"}
!64 = !{!"[59] st_i64 t0,env:0xac"}
!65 = !{!"[60] st32_i64 t2,v18,0x4"}
!66 = !{!"[61] st32_i64 t2,v18,0x2"}
!67 = !{!"[62] add_vec v128,e64,[t12],v18,v18"}
!68 = !{!"[63] st_i64 t0,env"}
!69 = !{!"[64] st_i64 t0,env:0x1"}
!70 = !{!"[65] st_i32 t0,env"}
!71 = !{!"[66] st_i32 t0,env:0x5"}
!72 = !{!"[67] st32_i64 t2,v18"}
!73 = !{!"[68] st32_i64 t2,v18,0x1"}
!74 = !{!"[69] st32_i64 t2,v18,0x4"}
!75 = !{!"[70] st32_i64 t2,v18,0xd"}
!76 = !{!"[71] ld_vec v64,e32,[t13],v26"}
!77 = !{!"[72] st_vec v64,e8,t13,v0"}
!78 = !{!"[73] ld_vec v128,e16,[t14],v26"}
!79 = !{!"[74] st_vec v64,e32,t14,v0"}
!80 = !{!"[75] st_vec v64,e8,t13,v0:o1"}
!81 = !{!"[76] st_vec v64,e8,t13,v0:o9"}
!82 = !{!"[77] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2"}
!83 = !{!"[78] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2"}
!84 = !{!"[79] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2"}
!85 = !{!"[80] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2"}
!86 = !{!"[81] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2"}
!87 = !{!"[82] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2"}
!88 = !{!"[83] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2"}
!89 = !{!"[84] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC1B,0x2"}
!90 = !{!"[85] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC1B,0x2"}
!91 = !{!"[86] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC2B,0x2"}
!92 = !{!"[87] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC2B,0x2"}
!93 = !{!"[88] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC4B,0x2"}
!94 = !{!"[89] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:SIGN:SRC4B,0x2"}
!95 = !{!"[90] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!96 = !{!"[91] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_2:ZERO:SRC8B,0x2"}
!97 = !{!"[92] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_4:ZERO:SRC8B,0x2"}
!98 = !{!"[93] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B,0x2"}
!99 = !{!"[94] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC8B,0x2"}
!100 = !{!"[95] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_32:ZERO:SRC8B,0x2"}
!101 = !{!"[96] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN:ALIGN_64:ZERO:SRC8B,0x2"}
!102 = !{!"[97] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC1B,0x2"}
!103 = !{!"[98] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC1B,0x2"}
!104 = !{!"[99] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC2B,0x2"}
!105 = !{!"[100] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC2B,0x2"}
!106 = !{!"[101] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC4B,0x2"}
!107 = !{!"[102] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:SIGN:SRC4B,0x2"}
!108 = !{!"[103] qemu_st_i32 t9,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC8B,0x2"}
!109 = !{!"[104] qemu_st_i64 t8,t7,attr-stg:ATOM_NONE:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!110 = !{!"[105] qemu_st_i64 t8,t7,attr-stg:ATOM_SUBALIGN:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!111 = !{!"[106] qemu_st_i64 t8,t7,attr-stg:ATOM_WITHIN16_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!112 = !{!"[107] qemu_st_i64 t8,t7,attr-stg:ATOM_WITHIN16:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!113 = !{!"[108] qemu_st_i64 t8,t7,attr-stg:ATOM_IFALIGN_PAIR:ALIGN_MEM_SIZE:ZERO:SRC8B,0x2"}
!114 = !{!"[109] qemu_st2_i128 t10,t11,t7,attr-stg:ATOM_IFALIGN:UNALIGNED:ZERO:SRC16B,0x2"}
!115 = !{!"[110] qemu_st2_i128 t10,t11,t7,attr-stg:ATOM_IFALIGN:ALIGN_16:ZERO:SRC16B,0x2"}
