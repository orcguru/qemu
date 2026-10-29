; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26528) %cpu) #0 section ".text.Fx0" {
entry:
  %v10.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm5, ptr %v10.stack, align 16, !tbaa !0
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp4.stack = alloca ptr, align 8
  %tmp5.stack = alloca ptr, align 8
  %tmp6.stack = alloca i64, align 8
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] func_addr t4,0x0,0x2 ========
  store ptr @trampoline_helper_rdrand, ptr %tmp4.stack, align 8, !tbaa !0, !tcg.op !3
; ======== TCG [1] func_addr t5,0x0,0x1 ========
  store ptr @Fx0_1, ptr %tmp5.stack, align 8, !tbaa !0, !tcg.op !4
; ======== TCG [2] add_i64 [t6],env,0x4a0 ========
  %T2.env = ptrtoint ptr %env to i64, !tcg.op !5
  %T2.out = add i64 %T2.env, 1184, !tcg.op !5
  store i64 %T2.out, ptr %tmp6.stack, align 8, !tbaa !0, !tcg.op !5
; ======== TCG [3] tail_call_qemuaot t4,env,t6,0x42,t5 VEC_ARGS: ========
  %T3.v10.stack = load <2 x i64>, ptr %v10.stack, align 16, !tbaa !0, !tcg.op !6
  %T3.env = ptrtoint ptr %env to i64, !tcg.op !6
  %T3.tmp6 = load i64, ptr %tmp6.stack, align 8, !tbaa !0, !tcg.op !6
  %T3.tmp5 = load i64, ptr %tmp5.stack, align 8, !tbaa !0, !tcg.op !6
  %T3.loaded_fn = load ptr, ptr %tmp4.stack, align 8, !tcg.op !6
  tail call qemuaot void %T3.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %T3.v10.stack, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr %cpu, i64 %T3.env, i64 %T3.tmp6, i64 66, i64 %T3.tmp5), !tcg.op !6
  ret void, !tcg.op !6
}

; Function Attrs: noinline nounwind
define qemuaot void @trampoline_helper_rdrand(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26528) %cpu, i64 %arg0, i64 %arg1, i64 %arg2, i64 %nc) #0 section ".text.trampoline_helper_rdrand" {
entry:
  %v27.stack = alloca <2 x i64>, align 16
  %v26.stack = alloca <2 x i64>, align 16
  %v25.stack = alloca <2 x i64>, align 16
  %v24.stack = alloca <2 x i64>, align 16
  %v23.stack = alloca <2 x i64>, align 16
  %v22.stack = alloca <2 x i64>, align 16
  %v21.stack = alloca <2 x i64>, align 16
  %v20.stack = alloca <2 x i64>, align 16
  %v19.stack = alloca <2 x i64>, align 16
  %v18.stack = alloca <2 x i64>, align 16
  %v17.stack = alloca <2 x i64>, align 16
  %v16.stack = alloca <2 x i64>, align 16
  %v15.stack = alloca <2 x i64>, align 16
  %v14.stack = alloca <2 x i64>, align 16
  %v13.stack = alloca <2 x i64>, align 16
  %v12.stack = alloca <2 x i64>, align 16
  %v11.stack = alloca <2 x i64>, align 16
  %v9.stack = alloca <2 x i64>, align 16
  %v8.stack = alloca <2 x i64>, align 16
  %v7.stack = alloca <2 x i64>, align 16
  %v6.stack = alloca <2 x i64>, align 16
  %v5.stack = alloca <2 x i64>, align 16
  %v4.stack = alloca <2 x i64>, align 16
  %v3.stack = alloca <2 x i64>, align 16
  %v2.stack = alloca <2 x i64>, align 16
  %v1.stack = alloca <2 x i64>, align 16
  %v0.stack = alloca <2 x i64>, align 16
  %rip.stack = alloca i64, align 8
  %cc_op.stack = alloca i32, align 8
  %cc_dst.stack = alloca i64, align 8
  %cc_src.stack = alloca i64, align 8
  %r15.stack = alloca i64, align 8
  %r14.stack = alloca i64, align 8
  %r13.stack = alloca i64, align 8
  %r12.stack = alloca i64, align 8
  %r11.stack = alloca i64, align 8
  %r10.stack = alloca i64, align 8
  %r9.stack = alloca i64, align 8
  %r8.stack = alloca i64, align 8
  %rdi.stack = alloca i64, align 8
  %rsi.stack = alloca i64, align 8
  %rbp.stack = alloca i64, align 8
  %rsp.stack = alloca i64, align 8
  %rbx.stack = alloca i64, align 8
  %rdx.stack = alloca i64, align 8
  %rcx.stack = alloca i64, align 8
  %rax.stack = alloca i64, align 8
  %v10.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm5, ptr %v10.stack, align 16, !tbaa !0
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp6.stack = alloca i64, align 8
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] st_i64 rax,env ========
  %T0.envptr = getelementptr i8, ptr %env, i64 0, !tcg.op !7
  store i64 %rax, ptr %T0.envptr, align 16, !tbaa !8, !tcg.op !7
; ======== TCG [1] st_i64 rcx,env:0x8 ========
  %T1.envptr = getelementptr i8, ptr %env, i64 8, !tcg.op !10
  store i64 %rcx, ptr %T1.envptr, align 8, !tbaa !8, !tcg.op !10
; ======== TCG [2] st_i64 rdx,env:0x10 ========
  %T2.envptr = getelementptr i8, ptr %env, i64 16, !tcg.op !11
  store i64 %rdx, ptr %T2.envptr, align 16, !tbaa !8, !tcg.op !11
; ======== TCG [3] st_i64 rbx,env:0x18 ========
  %T3.envptr = getelementptr i8, ptr %env, i64 24, !tcg.op !12
  store i64 %rbx, ptr %T3.envptr, align 8, !tbaa !8, !tcg.op !12
; ======== TCG [4] st_i64 rsp,env:0x20 ========
  %T4.envptr = getelementptr i8, ptr %env, i64 32, !tcg.op !13
  store i64 %rsp, ptr %T4.envptr, align 16, !tbaa !8, !tcg.op !13
; ======== TCG [5] st_i64 rbp,env:0x28 ========
  %T5.envptr = getelementptr i8, ptr %env, i64 40, !tcg.op !14
  store i64 %rbp, ptr %T5.envptr, align 8, !tbaa !8, !tcg.op !14
; ======== TCG [6] st_i64 rsi,env:0x30 ========
  %T6.envptr = getelementptr i8, ptr %env, i64 48, !tcg.op !15
  store i64 %rsi, ptr %T6.envptr, align 16, !tbaa !8, !tcg.op !15
; ======== TCG [7] st_i64 rdi,env:0x38 ========
  %T7.envptr = getelementptr i8, ptr %env, i64 56, !tcg.op !16
  store i64 %rdi, ptr %T7.envptr, align 8, !tbaa !8, !tcg.op !16
; ======== TCG [8] st_i64 r8,env:0x40 ========
  %T8.envptr = getelementptr i8, ptr %env, i64 64, !tcg.op !17
  store i64 %r8, ptr %T8.envptr, align 16, !tbaa !8, !tcg.op !17
; ======== TCG [9] st_i64 r9,env:0x48 ========
  %T9.envptr = getelementptr i8, ptr %env, i64 72, !tcg.op !18
  store i64 %r9, ptr %T9.envptr, align 8, !tbaa !8, !tcg.op !18
; ======== TCG [10] st_i64 r10,env:0x50 ========
  %T10.envptr = getelementptr i8, ptr %env, i64 80, !tcg.op !19
  store i64 %r10, ptr %T10.envptr, align 16, !tbaa !8, !tcg.op !19
; ======== TCG [11] st_i64 r11,env:0x58 ========
  %T11.envptr = getelementptr i8, ptr %env, i64 88, !tcg.op !20
  store i64 %r11, ptr %T11.envptr, align 8, !tbaa !8, !tcg.op !20
; ======== TCG [12] st_i64 r12,env:0x60 ========
  %T12.envptr = getelementptr i8, ptr %env, i64 96, !tcg.op !21
  store i64 %r12, ptr %T12.envptr, align 16, !tbaa !8, !tcg.op !21
; ======== TCG [13] st_i64 r13,env:0x68 ========
  %T13.envptr = getelementptr i8, ptr %env, i64 104, !tcg.op !22
  store i64 %r13, ptr %T13.envptr, align 8, !tbaa !8, !tcg.op !22
; ======== TCG [14] st_i64 r14,env:0x70 ========
  %T14.envptr = getelementptr i8, ptr %env, i64 112, !tcg.op !23
  store i64 %r14, ptr %T14.envptr, align 16, !tbaa !8, !tcg.op !23
; ======== TCG [15] st_i64 r15,env:0x78 ========
  %T15.envptr = getelementptr i8, ptr %env, i64 120, !tcg.op !24
  store i64 %r15, ptr %T15.envptr, align 8, !tbaa !8, !tcg.op !24
; ======== TCG [16] st_i64 cc_src,env:0x98 ========
  %T16.envptr = getelementptr i8, ptr %env, i64 152, !tcg.op !25
  store i64 %cc_src, ptr %T16.envptr, align 8, !tbaa !8, !tcg.op !25
; ======== TCG [17] st_i64 cc_dst,env:0x90 ========
  %T17.envptr = getelementptr i8, ptr %env, i64 144, !tcg.op !26
  store i64 %cc_dst, ptr %T17.envptr, align 16, !tbaa !8, !tcg.op !26
; ======== TCG [18] st_i32 cc_op,env:0xa8 ========
  %T18.envptr = getelementptr i8, ptr %env, i64 168, !tcg.op !27
  store i32 %cc_op, ptr %T18.envptr, align 8, !tbaa !8, !tcg.op !27
; ======== TCG [19] st_i64 rip,env:0x80 ========
  %T19.envptr = getelementptr i8, ptr %env, i64 128, !tcg.op !28
  store i64 %rip, ptr %T19.envptr, align 16, !tbaa !8, !tcg.op !28
; ======== TCG [20] st_vec v128,e8,v0,env:0x360 ========
  %T20.envptr = getelementptr i8, ptr %env, i64 864, !tcg.op !29
  store <2 x i64> %xmm0, ptr %T20.envptr, align 16, !tbaa !8, !tcg.op !29
; ======== TCG [21] st_vec v128,e8,v1,env:0x370 ========
  %T21.envptr = getelementptr i8, ptr %env, i64 880, !tcg.op !30
  store <2 x i64> %ymm0_h, ptr %T21.envptr, align 16, !tbaa !8, !tcg.op !30
; ======== TCG [22] st_vec v128,e8,v2,env:0x3a0 ========
  %T22.envptr = getelementptr i8, ptr %env, i64 928, !tcg.op !31
  store <2 x i64> %xmm1, ptr %T22.envptr, align 16, !tbaa !8, !tcg.op !31
; ======== TCG [23] st_vec v128,e8,v3,env:0x3b0 ========
  %T23.envptr = getelementptr i8, ptr %env, i64 944, !tcg.op !32
  store <2 x i64> %ymm1_h, ptr %T23.envptr, align 16, !tbaa !8, !tcg.op !32
; ======== TCG [24] st_vec v128,e8,v4,env:0x3e0 ========
  %T24.envptr = getelementptr i8, ptr %env, i64 992, !tcg.op !33
  store <2 x i64> %xmm2, ptr %T24.envptr, align 16, !tbaa !8, !tcg.op !33
; ======== TCG [25] st_vec v128,e8,v5,env:0x3f0 ========
  %T25.envptr = getelementptr i8, ptr %env, i64 1008, !tcg.op !34
  store <2 x i64> %ymm2_h, ptr %T25.envptr, align 16, !tbaa !8, !tcg.op !34
; ======== TCG [26] st_vec v128,e8,v6,env:0x420 ========
  %T26.envptr = getelementptr i8, ptr %env, i64 1056, !tcg.op !35
  store <2 x i64> %xmm3, ptr %T26.envptr, align 16, !tbaa !8, !tcg.op !35
; ======== TCG [27] st_vec v128,e8,v7,env:0x430 ========
  %T27.envptr = getelementptr i8, ptr %env, i64 1072, !tcg.op !36
  store <2 x i64> %ymm3_h, ptr %T27.envptr, align 16, !tbaa !8, !tcg.op !36
; ======== TCG [28] st_vec v128,e8,v8,env:0x460 ========
  %T28.envptr = getelementptr i8, ptr %env, i64 1120, !tcg.op !37
  store <2 x i64> %xmm4, ptr %T28.envptr, align 16, !tbaa !8, !tcg.op !37
; ======== TCG [29] st_vec v128,e8,v9,env:0x470 ========
  %T29.envptr = getelementptr i8, ptr %env, i64 1136, !tcg.op !38
  store <2 x i64> %ymm4_h, ptr %T29.envptr, align 16, !tbaa !8, !tcg.op !38
; ======== TCG [30] st_vec v128,e8,v10,env:0x4a0 ========
  %T30.v10 = load <16 x i8>, ptr %v10.stack, align 16, !tbaa !0, !tcg.op !39
  %T30.envptr = getelementptr i8, ptr %env, i64 1184, !tcg.op !39
  store <16 x i8> %T30.v10, ptr %T30.envptr, align 16, !tbaa !8, !tcg.op !39
; ======== TCG [31] st_vec v128,e8,v11,env:0x4b0 ========
  %T31.envptr = getelementptr i8, ptr %env, i64 1200, !tcg.op !40
  store <2 x i64> %ymm5_h, ptr %T31.envptr, align 16, !tbaa !8, !tcg.op !40
; ======== TCG [32] st_vec v128,e8,v12,env:0x4e0 ========
  %T32.envptr = getelementptr i8, ptr %env, i64 1248, !tcg.op !41
  store <2 x i64> %xmm6, ptr %T32.envptr, align 16, !tbaa !8, !tcg.op !41
; ======== TCG [33] st_vec v128,e8,v13,env:0x4f0 ========
  %T33.envptr = getelementptr i8, ptr %env, i64 1264, !tcg.op !42
  store <2 x i64> %ymm6_h, ptr %T33.envptr, align 16, !tbaa !8, !tcg.op !42
; ======== TCG [34] st_vec v128,e8,v14,env:0x520 ========
  %T34.envptr = getelementptr i8, ptr %env, i64 1312, !tcg.op !43
  store <2 x i64> %xmm7, ptr %T34.envptr, align 16, !tbaa !8, !tcg.op !43
; ======== TCG [35] st_vec v128,e8,v15,env:0x530 ========
  %T35.envptr = getelementptr i8, ptr %env, i64 1328, !tcg.op !44
  store <2 x i64> %ymm7_h, ptr %T35.envptr, align 16, !tbaa !8, !tcg.op !44
; ======== TCG [36] st_vec v128,e8,v16,env:0x560 ========
  %T36.envptr = getelementptr i8, ptr %env, i64 1376, !tcg.op !45
  store <2 x i64> %xmm8, ptr %T36.envptr, align 16, !tbaa !8, !tcg.op !45
; ======== TCG [37] st_vec v128,e8,v17,env:0x570 ========
  %T37.envptr = getelementptr i8, ptr %env, i64 1392, !tcg.op !46
  store <2 x i64> %ymm8_h, ptr %T37.envptr, align 16, !tbaa !8, !tcg.op !46
; ======== TCG [38] st_vec v128,e8,v18,env:0x5a0 ========
  %T38.envptr = getelementptr i8, ptr %env, i64 1440, !tcg.op !47
  store <2 x i64> %xmm9, ptr %T38.envptr, align 16, !tbaa !8, !tcg.op !47
; ======== TCG [39] st_vec v128,e8,v19,env:0x5b0 ========
  %T39.envptr = getelementptr i8, ptr %env, i64 1456, !tcg.op !48
  store <2 x i64> %ymm9_h, ptr %T39.envptr, align 16, !tbaa !8, !tcg.op !48
; ======== TCG [40] st_vec v128,e8,v20,env:0x5e0 ========
  %T40.envptr = getelementptr i8, ptr %env, i64 1504, !tcg.op !49
  store <2 x i64> %xmm10, ptr %T40.envptr, align 16, !tbaa !8, !tcg.op !49
; ======== TCG [41] st_vec v128,e8,v21,env:0x5f0 ========
  %T41.envptr = getelementptr i8, ptr %env, i64 1520, !tcg.op !50
  store <2 x i64> %ymm10_h, ptr %T41.envptr, align 16, !tbaa !8, !tcg.op !50
; ======== TCG [42] st_vec v128,e8,v22,env:0x620 ========
  %T42.envptr = getelementptr i8, ptr %env, i64 1568, !tcg.op !51
  store <2 x i64> %xmm11, ptr %T42.envptr, align 16, !tbaa !8, !tcg.op !51
; ======== TCG [43] st_vec v128,e8,v23,env:0x630 ========
  %T43.envptr = getelementptr i8, ptr %env, i64 1584, !tcg.op !52
  store <2 x i64> %ymm11_h, ptr %T43.envptr, align 16, !tbaa !8, !tcg.op !52
; ======== TCG [44] st_vec v128,e8,v24,env:0x660 ========
  %T44.envptr = getelementptr i8, ptr %env, i64 1632, !tcg.op !53
  store <2 x i64> %xmm12, ptr %T44.envptr, align 16, !tbaa !8, !tcg.op !53
; ======== TCG [45] st_vec v128,e8,v25,env:0x670 ========
  %T45.envptr = getelementptr i8, ptr %env, i64 1648, !tcg.op !54
  store <2 x i64> %ymm12_h, ptr %T45.envptr, align 16, !tbaa !8, !tcg.op !54
; ======== TCG [46] st_vec v128,e8,v26,env:0x6a0 ========
  %T46.envptr = getelementptr i8, ptr %env, i64 1696, !tcg.op !55
  store <2 x i64> %xmm13, ptr %T46.envptr, align 16, !tbaa !8, !tcg.op !55
; ======== TCG [47] st_vec v128,e8,v27,env:0x6b0 ========
  %T47.envptr = getelementptr i8, ptr %env, i64 1712, !tcg.op !56
  store <2 x i64> %ymm13_h, ptr %T47.envptr, align 16, !tbaa !8, !tcg.op !56
; ======== TCG [48] call_default helper_rdrand,[t1],arg0,arg1,arg2 ========
  %T48.env = ptrtoint ptr %env to i64, !tcg.op !57
  %T48.cr = call i64 asm sideeffect "mov x25, $1\0A\09mov x0, $2\0A\09mov x1, $3\0A\09mov x2, $4\0A\09bl helper_rdrand\0A\09mov $0, x0", "=r,r,r,r,r,~{x0},~{x1},~{x2},~{x3},~{x4},~{x5},~{x6},~{x7},~{x8},~{x9},~{x10},~{x11},~{x12},~{x13},~{x14},~{x15},~{x16},~{x17},~{x18},~{x29},~{x30},~{v0},~{v1},~{v2},~{v3},~{v4},~{v5},~{v6},~{v7},~{v8},~{v9},~{v10},~{v11},~{v12},~{v13},~{v14},~{v15},~{v16},~{v17},~{v18},~{v19},~{v20},~{v21},~{v22},~{v23},~{v24},~{v25},~{v26},~{v27},~{v28},~{v29},~{v30},~{v31},~{cc},~{memory}"(i64 %T48.env, i64 %arg0, i64 %arg1, i64 %arg2), !tcg.op !57
  store i64 %T48.cr, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !57
; ======== TCG [49] ld_i64 [rax],env ========
  %T49.envptr = getelementptr i8, ptr %env, i64 0, !tcg.op !58
  %T49.envval = load i64, ptr %T49.envptr, align 16, !tbaa !8, !tcg.op !58
  store i64 %T49.envval, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !58
; ======== TCG [50] ld_i64 [rcx],env:0x8 ========
  %T50.envptr = getelementptr i8, ptr %env, i64 8, !tcg.op !59
  %T50.envval = load i64, ptr %T50.envptr, align 8, !tbaa !8, !tcg.op !59
  store i64 %T50.envval, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !59
; ======== TCG [51] ld_i64 [rdx],env:0x10 ========
  %T51.envptr = getelementptr i8, ptr %env, i64 16, !tcg.op !60
  %T51.envval = load i64, ptr %T51.envptr, align 16, !tbaa !8, !tcg.op !60
  store i64 %T51.envval, ptr %rdx.stack, align 8, !tbaa !0, !tcg.op !60
; ======== TCG [52] ld_i64 [rbx],env:0x18 ========
  %T52.envptr = getelementptr i8, ptr %env, i64 24, !tcg.op !61
  %T52.envval = load i64, ptr %T52.envptr, align 8, !tbaa !8, !tcg.op !61
  store i64 %T52.envval, ptr %rbx.stack, align 8, !tbaa !0, !tcg.op !61
; ======== TCG [53] ld_i64 [rsp],env:0x20 ========
  %T53.envptr = getelementptr i8, ptr %env, i64 32, !tcg.op !62
  %T53.envval = load i64, ptr %T53.envptr, align 16, !tbaa !8, !tcg.op !62
  store i64 %T53.envval, ptr %rsp.stack, align 8, !tbaa !0, !tcg.op !62
; ======== TCG [54] ld_i64 [rbp],env:0x28 ========
  %T54.envptr = getelementptr i8, ptr %env, i64 40, !tcg.op !63
  %T54.envval = load i64, ptr %T54.envptr, align 8, !tbaa !8, !tcg.op !63
  store i64 %T54.envval, ptr %rbp.stack, align 8, !tbaa !0, !tcg.op !63
; ======== TCG [55] ld_i64 [rsi],env:0x30 ========
  %T55.envptr = getelementptr i8, ptr %env, i64 48, !tcg.op !64
  %T55.envval = load i64, ptr %T55.envptr, align 16, !tbaa !8, !tcg.op !64
  store i64 %T55.envval, ptr %rsi.stack, align 8, !tbaa !0, !tcg.op !64
; ======== TCG [56] ld_i64 [rdi],env:0x38 ========
  %T56.envptr = getelementptr i8, ptr %env, i64 56, !tcg.op !65
  %T56.envval = load i64, ptr %T56.envptr, align 8, !tbaa !8, !tcg.op !65
  store i64 %T56.envval, ptr %rdi.stack, align 8, !tbaa !0, !tcg.op !65
; ======== TCG [57] ld_i64 [r8],env:0x40 ========
  %T57.envptr = getelementptr i8, ptr %env, i64 64, !tcg.op !66
  %T57.envval = load i64, ptr %T57.envptr, align 16, !tbaa !8, !tcg.op !66
  store i64 %T57.envval, ptr %r8.stack, align 8, !tbaa !0, !tcg.op !66
; ======== TCG [58] ld_i64 [r9],env:0x48 ========
  %T58.envptr = getelementptr i8, ptr %env, i64 72, !tcg.op !67
  %T58.envval = load i64, ptr %T58.envptr, align 8, !tbaa !8, !tcg.op !67
  store i64 %T58.envval, ptr %r9.stack, align 8, !tbaa !0, !tcg.op !67
; ======== TCG [59] ld_i64 [r10],env:0x50 ========
  %T59.envptr = getelementptr i8, ptr %env, i64 80, !tcg.op !68
  %T59.envval = load i64, ptr %T59.envptr, align 16, !tbaa !8, !tcg.op !68
  store i64 %T59.envval, ptr %r10.stack, align 8, !tbaa !0, !tcg.op !68
; ======== TCG [60] ld_i64 [r11],env:0x58 ========
  %T60.envptr = getelementptr i8, ptr %env, i64 88, !tcg.op !69
  %T60.envval = load i64, ptr %T60.envptr, align 8, !tbaa !8, !tcg.op !69
  store i64 %T60.envval, ptr %r11.stack, align 8, !tbaa !0, !tcg.op !69
; ======== TCG [61] ld_i64 [r12],env:0x60 ========
  %T61.envptr = getelementptr i8, ptr %env, i64 96, !tcg.op !70
  %T61.envval = load i64, ptr %T61.envptr, align 16, !tbaa !8, !tcg.op !70
  store i64 %T61.envval, ptr %r12.stack, align 8, !tbaa !0, !tcg.op !70
; ======== TCG [62] ld_i64 [r13],env:0x68 ========
  %T62.envptr = getelementptr i8, ptr %env, i64 104, !tcg.op !71
  %T62.envval = load i64, ptr %T62.envptr, align 8, !tbaa !8, !tcg.op !71
  store i64 %T62.envval, ptr %r13.stack, align 8, !tbaa !0, !tcg.op !71
; ======== TCG [63] ld_i64 [r14],env:0x70 ========
  %T63.envptr = getelementptr i8, ptr %env, i64 112, !tcg.op !72
  %T63.envval = load i64, ptr %T63.envptr, align 16, !tbaa !8, !tcg.op !72
  store i64 %T63.envval, ptr %r14.stack, align 8, !tbaa !0, !tcg.op !72
; ======== TCG [64] ld_i64 [r15],env:0x78 ========
  %T64.envptr = getelementptr i8, ptr %env, i64 120, !tcg.op !73
  %T64.envval = load i64, ptr %T64.envptr, align 8, !tbaa !8, !tcg.op !73
  store i64 %T64.envval, ptr %r15.stack, align 8, !tbaa !0, !tcg.op !73
; ======== TCG [65] ld_i64 [cc_src],env:0x98 ========
  %T65.envptr = getelementptr i8, ptr %env, i64 152, !tcg.op !74
  %T65.envval = load i64, ptr %T65.envptr, align 8, !tbaa !8, !tcg.op !74
  store i64 %T65.envval, ptr %cc_src.stack, align 8, !tbaa !0, !tcg.op !74
; ======== TCG [66] ld_i64 [cc_dst],env:0x90 ========
  %T66.envptr = getelementptr i8, ptr %env, i64 144, !tcg.op !75
  %T66.envval = load i64, ptr %T66.envptr, align 16, !tbaa !8, !tcg.op !75
  store i64 %T66.envval, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !75
; ======== TCG [67] ld_i32 [cc_op],env:0xa8 ========
  %T67.envptr = getelementptr i8, ptr %env, i64 168, !tcg.op !76
  %T67.envval = load i32, ptr %T67.envptr, align 8, !tbaa !8, !tcg.op !76
  store i32 %T67.envval, ptr %cc_op.stack, align 8, !tbaa !0, !tcg.op !76
; ======== TCG [68] ld_i64 [rip],env:0x80 ========
  %T68.envptr = getelementptr i8, ptr %env, i64 128, !tcg.op !77
  %T68.envval = load i64, ptr %T68.envptr, align 16, !tbaa !8, !tcg.op !77
  store i64 %T68.envval, ptr %rip.stack, align 8, !tbaa !0, !tcg.op !77
; ======== TCG [69] ld_vec v128,e8,[v0],env:0x360 ========
  %T69.envptr = getelementptr i8, ptr %env, i64 864, !tcg.op !78
  %T69.envval = load <16 x i8>, ptr %T69.envptr, align 16, !tbaa !8, !tcg.op !78
  store <16 x i8> %T69.envval, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !78
; ======== TCG [70] ld_vec v128,e8,[v1],env:0x370 ========
  %T70.envptr = getelementptr i8, ptr %env, i64 880, !tcg.op !79
  %T70.envval = load <16 x i8>, ptr %T70.envptr, align 16, !tbaa !8, !tcg.op !79
  store <16 x i8> %T70.envval, ptr %v1.stack, align 16, !tbaa !0, !tcg.op !79
; ======== TCG [71] ld_vec v128,e8,[v2],env:0x3a0 ========
  %T71.envptr = getelementptr i8, ptr %env, i64 928, !tcg.op !80
  %T71.envval = load <16 x i8>, ptr %T71.envptr, align 16, !tbaa !8, !tcg.op !80
  store <16 x i8> %T71.envval, ptr %v2.stack, align 16, !tbaa !0, !tcg.op !80
; ======== TCG [72] ld_vec v128,e8,[v3],env:0x3b0 ========
  %T72.envptr = getelementptr i8, ptr %env, i64 944, !tcg.op !81
  %T72.envval = load <16 x i8>, ptr %T72.envptr, align 16, !tbaa !8, !tcg.op !81
  store <16 x i8> %T72.envval, ptr %v3.stack, align 16, !tbaa !0, !tcg.op !81
; ======== TCG [73] ld_vec v128,e8,[v4],env:0x3e0 ========
  %T73.envptr = getelementptr i8, ptr %env, i64 992, !tcg.op !82
  %T73.envval = load <16 x i8>, ptr %T73.envptr, align 16, !tbaa !8, !tcg.op !82
  store <16 x i8> %T73.envval, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !82
; ======== TCG [74] ld_vec v128,e8,[v5],env:0x3f0 ========
  %T74.envptr = getelementptr i8, ptr %env, i64 1008, !tcg.op !83
  %T74.envval = load <16 x i8>, ptr %T74.envptr, align 16, !tbaa !8, !tcg.op !83
  store <16 x i8> %T74.envval, ptr %v5.stack, align 16, !tbaa !0, !tcg.op !83
; ======== TCG [75] ld_vec v128,e8,[v6],env:0x420 ========
  %T75.envptr = getelementptr i8, ptr %env, i64 1056, !tcg.op !84
  %T75.envval = load <16 x i8>, ptr %T75.envptr, align 16, !tbaa !8, !tcg.op !84
  store <16 x i8> %T75.envval, ptr %v6.stack, align 16, !tbaa !0, !tcg.op !84
; ======== TCG [76] ld_vec v128,e8,[v7],env:0x430 ========
  %T76.envptr = getelementptr i8, ptr %env, i64 1072, !tcg.op !85
  %T76.envval = load <16 x i8>, ptr %T76.envptr, align 16, !tbaa !8, !tcg.op !85
  store <16 x i8> %T76.envval, ptr %v7.stack, align 16, !tbaa !0, !tcg.op !85
; ======== TCG [77] ld_vec v128,e8,[v8],env:0x460 ========
  %T77.envptr = getelementptr i8, ptr %env, i64 1120, !tcg.op !86
  %T77.envval = load <16 x i8>, ptr %T77.envptr, align 16, !tbaa !8, !tcg.op !86
  store <16 x i8> %T77.envval, ptr %v8.stack, align 16, !tbaa !0, !tcg.op !86
; ======== TCG [78] ld_vec v128,e8,[v9],env:0x470 ========
  %T78.envptr = getelementptr i8, ptr %env, i64 1136, !tcg.op !87
  %T78.envval = load <16 x i8>, ptr %T78.envptr, align 16, !tbaa !8, !tcg.op !87
  store <16 x i8> %T78.envval, ptr %v9.stack, align 16, !tbaa !0, !tcg.op !87
; ======== TCG [79] ld_vec v128,e8,[v10],env:0x4a0 ========
  %T79.envptr = getelementptr i8, ptr %env, i64 1184, !tcg.op !88
  %T79.envval = load <16 x i8>, ptr %T79.envptr, align 16, !tbaa !8, !tcg.op !88
  store <16 x i8> %T79.envval, ptr %v10.stack, align 16, !tbaa !0, !tcg.op !88
; ======== TCG [80] ld_vec v128,e8,[v11],env:0x4b0 ========
  %T80.envptr = getelementptr i8, ptr %env, i64 1200, !tcg.op !89
  %T80.envval = load <16 x i8>, ptr %T80.envptr, align 16, !tbaa !8, !tcg.op !89
  store <16 x i8> %T80.envval, ptr %v11.stack, align 16, !tbaa !0, !tcg.op !89
; ======== TCG [81] ld_vec v128,e8,[v12],env:0x4e0 ========
  %T81.envptr = getelementptr i8, ptr %env, i64 1248, !tcg.op !90
  %T81.envval = load <16 x i8>, ptr %T81.envptr, align 16, !tbaa !8, !tcg.op !90
  store <16 x i8> %T81.envval, ptr %v12.stack, align 16, !tbaa !0, !tcg.op !90
; ======== TCG [82] ld_vec v128,e8,[v13],env:0x4f0 ========
  %T82.envptr = getelementptr i8, ptr %env, i64 1264, !tcg.op !91
  %T82.envval = load <16 x i8>, ptr %T82.envptr, align 16, !tbaa !8, !tcg.op !91
  store <16 x i8> %T82.envval, ptr %v13.stack, align 16, !tbaa !0, !tcg.op !91
; ======== TCG [83] ld_vec v128,e8,[v14],env:0x520 ========
  %T83.envptr = getelementptr i8, ptr %env, i64 1312, !tcg.op !92
  %T83.envval = load <16 x i8>, ptr %T83.envptr, align 16, !tbaa !8, !tcg.op !92
  store <16 x i8> %T83.envval, ptr %v14.stack, align 16, !tbaa !0, !tcg.op !92
; ======== TCG [84] ld_vec v128,e8,[v15],env:0x530 ========
  %T84.envptr = getelementptr i8, ptr %env, i64 1328, !tcg.op !93
  %T84.envval = load <16 x i8>, ptr %T84.envptr, align 16, !tbaa !8, !tcg.op !93
  store <16 x i8> %T84.envval, ptr %v15.stack, align 16, !tbaa !0, !tcg.op !93
; ======== TCG [85] ld_vec v128,e8,[v16],env:0x560 ========
  %T85.envptr = getelementptr i8, ptr %env, i64 1376, !tcg.op !94
  %T85.envval = load <16 x i8>, ptr %T85.envptr, align 16, !tbaa !8, !tcg.op !94
  store <16 x i8> %T85.envval, ptr %v16.stack, align 16, !tbaa !0, !tcg.op !94
; ======== TCG [86] ld_vec v128,e8,[v17],env:0x570 ========
  %T86.envptr = getelementptr i8, ptr %env, i64 1392, !tcg.op !95
  %T86.envval = load <16 x i8>, ptr %T86.envptr, align 16, !tbaa !8, !tcg.op !95
  store <16 x i8> %T86.envval, ptr %v17.stack, align 16, !tbaa !0, !tcg.op !95
; ======== TCG [87] ld_vec v128,e8,[v18],env:0x5a0 ========
  %T87.envptr = getelementptr i8, ptr %env, i64 1440, !tcg.op !96
  %T87.envval = load <16 x i8>, ptr %T87.envptr, align 16, !tbaa !8, !tcg.op !96
  store <16 x i8> %T87.envval, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !96
; ======== TCG [88] ld_vec v128,e8,[v19],env:0x5b0 ========
  %T88.envptr = getelementptr i8, ptr %env, i64 1456, !tcg.op !97
  %T88.envval = load <16 x i8>, ptr %T88.envptr, align 16, !tbaa !8, !tcg.op !97
  store <16 x i8> %T88.envval, ptr %v19.stack, align 16, !tbaa !0, !tcg.op !97
; ======== TCG [89] ld_vec v128,e8,[v20],env:0x5e0 ========
  %T89.envptr = getelementptr i8, ptr %env, i64 1504, !tcg.op !98
  %T89.envval = load <16 x i8>, ptr %T89.envptr, align 16, !tbaa !8, !tcg.op !98
  store <16 x i8> %T89.envval, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !98
; ======== TCG [90] ld_vec v128,e8,[v21],env:0x5f0 ========
  %T90.envptr = getelementptr i8, ptr %env, i64 1520, !tcg.op !99
  %T90.envval = load <16 x i8>, ptr %T90.envptr, align 16, !tbaa !8, !tcg.op !99
  store <16 x i8> %T90.envval, ptr %v21.stack, align 16, !tbaa !0, !tcg.op !99
; ======== TCG [91] ld_vec v128,e8,[v22],env:0x620 ========
  %T91.envptr = getelementptr i8, ptr %env, i64 1568, !tcg.op !100
  %T91.envval = load <16 x i8>, ptr %T91.envptr, align 16, !tbaa !8, !tcg.op !100
  store <16 x i8> %T91.envval, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !100
; ======== TCG [92] ld_vec v128,e8,[v23],env:0x630 ========
  %T92.envptr = getelementptr i8, ptr %env, i64 1584, !tcg.op !101
  %T92.envval = load <16 x i8>, ptr %T92.envptr, align 16, !tbaa !8, !tcg.op !101
  store <16 x i8> %T92.envval, ptr %v23.stack, align 16, !tbaa !0, !tcg.op !101
; ======== TCG [93] ld_vec v128,e8,[v24],env:0x660 ========
  %T93.envptr = getelementptr i8, ptr %env, i64 1632, !tcg.op !102
  %T93.envval = load <16 x i8>, ptr %T93.envptr, align 16, !tbaa !8, !tcg.op !102
  store <16 x i8> %T93.envval, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !102
; ======== TCG [94] ld_vec v128,e8,[v25],env:0x670 ========
  %T94.envptr = getelementptr i8, ptr %env, i64 1648, !tcg.op !103
  %T94.envval = load <16 x i8>, ptr %T94.envptr, align 16, !tbaa !8, !tcg.op !103
  store <16 x i8> %T94.envval, ptr %v25.stack, align 16, !tbaa !0, !tcg.op !103
; ======== TCG [95] ld_vec v128,e8,[v26],env:0x6a0 ========
  %T95.envptr = getelementptr i8, ptr %env, i64 1696, !tcg.op !104
  %T95.envval = load <16 x i8>, ptr %T95.envptr, align 16, !tbaa !8, !tcg.op !104
  store <16 x i8> %T95.envval, ptr %v26.stack, align 16, !tbaa !0, !tcg.op !104
; ======== TCG [96] ld_vec v128,e8,[v27],env:0x6b0 ========
  %T96.envptr = getelementptr i8, ptr %env, i64 1712, !tcg.op !105
  %T96.envval = load <16 x i8>, ptr %T96.envptr, align 16, !tbaa !8, !tcg.op !105
  store <16 x i8> %T96.envval, ptr %v27.stack, align 16, !tbaa !0, !tcg.op !105
; ======== TCG [97] tail_call_qemuaot __last_arg__,t1 VEC_ARGS: ========
  %T97.rax.stack = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.rcx.stack = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.rdx.stack = load i64, ptr %rdx.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.rbx.stack = load i64, ptr %rbx.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.rsp.stack = load i64, ptr %rsp.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.rbp.stack = load i64, ptr %rbp.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.rsi.stack = load i64, ptr %rsi.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.rdi.stack = load i64, ptr %rdi.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.r8.stack = load i64, ptr %r8.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.r9.stack = load i64, ptr %r9.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.r10.stack = load i64, ptr %r10.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.r11.stack = load i64, ptr %r11.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.r12.stack = load i64, ptr %r12.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.r13.stack = load i64, ptr %r13.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.r14.stack = load i64, ptr %r14.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.r15.stack = load i64, ptr %r15.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.cc_src.stack = load i64, ptr %cc_src.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.cc_dst.stack = load i64, ptr %cc_dst.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.cc_op.stack = load i32, ptr %cc_op.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.rip.stack = load i64, ptr %rip.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v1.stack = load <2 x i64>, ptr %v1.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v2.stack = load <2 x i64>, ptr %v2.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v3.stack = load <2 x i64>, ptr %v3.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v4.stack = load <2 x i64>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v5.stack = load <2 x i64>, ptr %v5.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v6.stack = load <2 x i64>, ptr %v6.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v7.stack = load <2 x i64>, ptr %v7.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v8.stack = load <2 x i64>, ptr %v8.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v9.stack = load <2 x i64>, ptr %v9.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v10.stack = load <2 x i64>, ptr %v10.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v11.stack = load <2 x i64>, ptr %v11.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v12.stack = load <2 x i64>, ptr %v12.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v13.stack = load <2 x i64>, ptr %v13.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v14.stack = load <2 x i64>, ptr %v14.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v15.stack = load <2 x i64>, ptr %v15.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v16.stack = load <2 x i64>, ptr %v16.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v17.stack = load <2 x i64>, ptr %v17.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v18.stack = load <2 x i64>, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v19.stack = load <2 x i64>, ptr %v19.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v20.stack = load <2 x i64>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v21.stack = load <2 x i64>, ptr %v21.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v22.stack = load <2 x i64>, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v23.stack = load <2 x i64>, ptr %v23.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v24.stack = load <2 x i64>, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v25.stack = load <2 x i64>, ptr %v25.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v26.stack = load <2 x i64>, ptr %v26.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.v27.stack = load <2 x i64>, ptr %v27.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.loaded_fn = inttoptr i64 %nc to ptr, !tcg.op !106
  tail call qemuaot void %T97.loaded_fn(i64 %T97.rax.stack, i64 %T97.rcx.stack, i64 %T97.rdx.stack, i64 %T97.rbx.stack, i64 %T97.rsp.stack, i64 %T97.rbp.stack, i64 %T97.rsi.stack, i64 %T97.rdi.stack, i64 %T97.r8.stack, i64 %T97.r9.stack, i64 %T97.r10.stack, i64 %T97.r11.stack, i64 %T97.r12.stack, i64 %T97.r13.stack, i64 %T97.r14.stack, i64 %T97.r15.stack, i64 %T97.cc_src.stack, i64 %T97.cc_dst.stack, i32 %T97.cc_op.stack, i64 %T97.rip.stack, <2 x i64> %T97.v0.stack, <2 x i64> %T97.v1.stack, <2 x i64> %T97.v2.stack, <2 x i64> %T97.v3.stack, <2 x i64> %T97.v4.stack, <2 x i64> %T97.v5.stack, <2 x i64> %T97.v6.stack, <2 x i64> %T97.v7.stack, <2 x i64> %T97.v8.stack, <2 x i64> %T97.v9.stack, <2 x i64> %T97.v10.stack, <2 x i64> %T97.v11.stack, <2 x i64> %T97.v12.stack, <2 x i64> %T97.v13.stack, <2 x i64> %T97.v14.stack, <2 x i64> %T97.v15.stack, <2 x i64> %T97.v16.stack, <2 x i64> %T97.v17.stack, <2 x i64> %T97.v18.stack, <2 x i64> %T97.v19.stack, <2 x i64> %T97.v20.stack, <2 x i64> %T97.v21.stack, <2 x i64> %T97.v22.stack, <2 x i64> %T97.v23.stack, <2 x i64> %T97.v24.stack, <2 x i64> %T97.v25.stack, <2 x i64> %T97.v26.stack, <2 x i64> %T97.v27.stack, ptr %cpu, i64 %T97.tmp1), !tcg.op !106
  ret void, !tcg.op !106
}

; Function Attrs: noinline nounwind
define qemuaot void @Fx0_1(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26528) %cpu, i64 %rv) #0 section ".text.Fx0_1" {
entry:
  %v10.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm5, ptr %v10.stack, align 16, !tbaa !0
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca ptr, align 8
  %tmp6.stack = alloca i64, align 8
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] mov_i64 [t1],__last_arg__ ========
  store i64 %rv, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !107
; ======== TCG [1] mov_i64 [t2],t1 ========
  %T1.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !108
  store i64 %T1.tmp1, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !108
; ======== TCG [2] func_addr t3,0x55aa,0x0 ========
  store ptr @Fx55aa, ptr %tmp3.stack, align 8, !tbaa !0, !tcg.op !109
; ======== TCG [3] tail_call_qemuaot t3 VEC_ARGS: ========
  %T3.v10.stack = load <2 x i64>, ptr %v10.stack, align 16, !tbaa !0, !tcg.op !110
  %T3.loaded_fn = load ptr, ptr %tmp3.stack, align 8, !tcg.op !110
  tail call qemuaot void %T3.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %T3.v10.stack, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr %cpu), !tcg.op !110
  ret void, !tcg.op !110
}

; Function Attrs: nounwind
declare qemuaot void @Fx55aa(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, ptr align 8 dereferenceable(26528)) #1 section ".text.Fx55aa"

attributes #0 = { noinline nounwind "target-features"="+neon" }
attributes #1 = { nounwind "target-features"="+neon" }

!0 = !{!1, !1, i64 0}
!1 = !{!"SpillSlo", !2}
!2 = !{!"Root"}
!3 = !{!"[0] func_addr t4,0x0,0x2"}
!4 = !{!"[1] func_addr t5,0x0,0x1"}
!5 = !{!"[2] add_i64 [t6],env,0x4a0"}
!6 = !{!"[3] tail_call_qemuaot t4,env,t6,0x42,t5 VEC_ARGS:"}
!7 = !{!"[0] st_i64 rax,env"}
!8 = !{!9, !9, i64 0}
!9 = !{!"CPUState", !2}
!10 = !{!"[1] st_i64 rcx,env:0x8"}
!11 = !{!"[2] st_i64 rdx,env:0x10"}
!12 = !{!"[3] st_i64 rbx,env:0x18"}
!13 = !{!"[4] st_i64 rsp,env:0x20"}
!14 = !{!"[5] st_i64 rbp,env:0x28"}
!15 = !{!"[6] st_i64 rsi,env:0x30"}
!16 = !{!"[7] st_i64 rdi,env:0x38"}
!17 = !{!"[8] st_i64 r8,env:0x40"}
!18 = !{!"[9] st_i64 r9,env:0x48"}
!19 = !{!"[10] st_i64 r10,env:0x50"}
!20 = !{!"[11] st_i64 r11,env:0x58"}
!21 = !{!"[12] st_i64 r12,env:0x60"}
!22 = !{!"[13] st_i64 r13,env:0x68"}
!23 = !{!"[14] st_i64 r14,env:0x70"}
!24 = !{!"[15] st_i64 r15,env:0x78"}
!25 = !{!"[16] st_i64 cc_src,env:0x98"}
!26 = !{!"[17] st_i64 cc_dst,env:0x90"}
!27 = !{!"[18] st_i32 cc_op,env:0xa8"}
!28 = !{!"[19] st_i64 rip,env:0x80"}
!29 = !{!"[20] st_vec v128,e8,v0,env:0x360"}
!30 = !{!"[21] st_vec v128,e8,v1,env:0x370"}
!31 = !{!"[22] st_vec v128,e8,v2,env:0x3a0"}
!32 = !{!"[23] st_vec v128,e8,v3,env:0x3b0"}
!33 = !{!"[24] st_vec v128,e8,v4,env:0x3e0"}
!34 = !{!"[25] st_vec v128,e8,v5,env:0x3f0"}
!35 = !{!"[26] st_vec v128,e8,v6,env:0x420"}
!36 = !{!"[27] st_vec v128,e8,v7,env:0x430"}
!37 = !{!"[28] st_vec v128,e8,v8,env:0x460"}
!38 = !{!"[29] st_vec v128,e8,v9,env:0x470"}
!39 = !{!"[30] st_vec v128,e8,v10,env:0x4a0"}
!40 = !{!"[31] st_vec v128,e8,v11,env:0x4b0"}
!41 = !{!"[32] st_vec v128,e8,v12,env:0x4e0"}
!42 = !{!"[33] st_vec v128,e8,v13,env:0x4f0"}
!43 = !{!"[34] st_vec v128,e8,v14,env:0x520"}
!44 = !{!"[35] st_vec v128,e8,v15,env:0x530"}
!45 = !{!"[36] st_vec v128,e8,v16,env:0x560"}
!46 = !{!"[37] st_vec v128,e8,v17,env:0x570"}
!47 = !{!"[38] st_vec v128,e8,v18,env:0x5a0"}
!48 = !{!"[39] st_vec v128,e8,v19,env:0x5b0"}
!49 = !{!"[40] st_vec v128,e8,v20,env:0x5e0"}
!50 = !{!"[41] st_vec v128,e8,v21,env:0x5f0"}
!51 = !{!"[42] st_vec v128,e8,v22,env:0x620"}
!52 = !{!"[43] st_vec v128,e8,v23,env:0x630"}
!53 = !{!"[44] st_vec v128,e8,v24,env:0x660"}
!54 = !{!"[45] st_vec v128,e8,v25,env:0x670"}
!55 = !{!"[46] st_vec v128,e8,v26,env:0x6a0"}
!56 = !{!"[47] st_vec v128,e8,v27,env:0x6b0"}
!57 = !{!"[48] call_default helper_rdrand,[t1],arg0,arg1,arg2"}
!58 = !{!"[49] ld_i64 [rax],env"}
!59 = !{!"[50] ld_i64 [rcx],env:0x8"}
!60 = !{!"[51] ld_i64 [rdx],env:0x10"}
!61 = !{!"[52] ld_i64 [rbx],env:0x18"}
!62 = !{!"[53] ld_i64 [rsp],env:0x20"}
!63 = !{!"[54] ld_i64 [rbp],env:0x28"}
!64 = !{!"[55] ld_i64 [rsi],env:0x30"}
!65 = !{!"[56] ld_i64 [rdi],env:0x38"}
!66 = !{!"[57] ld_i64 [r8],env:0x40"}
!67 = !{!"[58] ld_i64 [r9],env:0x48"}
!68 = !{!"[59] ld_i64 [r10],env:0x50"}
!69 = !{!"[60] ld_i64 [r11],env:0x58"}
!70 = !{!"[61] ld_i64 [r12],env:0x60"}
!71 = !{!"[62] ld_i64 [r13],env:0x68"}
!72 = !{!"[63] ld_i64 [r14],env:0x70"}
!73 = !{!"[64] ld_i64 [r15],env:0x78"}
!74 = !{!"[65] ld_i64 [cc_src],env:0x98"}
!75 = !{!"[66] ld_i64 [cc_dst],env:0x90"}
!76 = !{!"[67] ld_i32 [cc_op],env:0xa8"}
!77 = !{!"[68] ld_i64 [rip],env:0x80"}
!78 = !{!"[69] ld_vec v128,e8,[v0],env:0x360"}
!79 = !{!"[70] ld_vec v128,e8,[v1],env:0x370"}
!80 = !{!"[71] ld_vec v128,e8,[v2],env:0x3a0"}
!81 = !{!"[72] ld_vec v128,e8,[v3],env:0x3b0"}
!82 = !{!"[73] ld_vec v128,e8,[v4],env:0x3e0"}
!83 = !{!"[74] ld_vec v128,e8,[v5],env:0x3f0"}
!84 = !{!"[75] ld_vec v128,e8,[v6],env:0x420"}
!85 = !{!"[76] ld_vec v128,e8,[v7],env:0x430"}
!86 = !{!"[77] ld_vec v128,e8,[v8],env:0x460"}
!87 = !{!"[78] ld_vec v128,e8,[v9],env:0x470"}
!88 = !{!"[79] ld_vec v128,e8,[v10],env:0x4a0"}
!89 = !{!"[80] ld_vec v128,e8,[v11],env:0x4b0"}
!90 = !{!"[81] ld_vec v128,e8,[v12],env:0x4e0"}
!91 = !{!"[82] ld_vec v128,e8,[v13],env:0x4f0"}
!92 = !{!"[83] ld_vec v128,e8,[v14],env:0x520"}
!93 = !{!"[84] ld_vec v128,e8,[v15],env:0x530"}
!94 = !{!"[85] ld_vec v128,e8,[v16],env:0x560"}
!95 = !{!"[86] ld_vec v128,e8,[v17],env:0x570"}
!96 = !{!"[87] ld_vec v128,e8,[v18],env:0x5a0"}
!97 = !{!"[88] ld_vec v128,e8,[v19],env:0x5b0"}
!98 = !{!"[89] ld_vec v128,e8,[v20],env:0x5e0"}
!99 = !{!"[90] ld_vec v128,e8,[v21],env:0x5f0"}
!100 = !{!"[91] ld_vec v128,e8,[v22],env:0x620"}
!101 = !{!"[92] ld_vec v128,e8,[v23],env:0x630"}
!102 = !{!"[93] ld_vec v128,e8,[v24],env:0x660"}
!103 = !{!"[94] ld_vec v128,e8,[v25],env:0x670"}
!104 = !{!"[95] ld_vec v128,e8,[v26],env:0x6a0"}
!105 = !{!"[96] ld_vec v128,e8,[v27],env:0x6b0"}
!106 = !{!"[97] tail_call_qemuaot __last_arg__,t1 VEC_ARGS:"}
!107 = !{!"[0] mov_i64 [t1],__last_arg__"}
!108 = !{!"[1] mov_i64 [t2],t1"}
!109 = !{!"[2] func_addr t3,0x55aa,0x0"}
!110 = !{!"[3] tail_call_qemuaot t3 VEC_ARGS:"}
