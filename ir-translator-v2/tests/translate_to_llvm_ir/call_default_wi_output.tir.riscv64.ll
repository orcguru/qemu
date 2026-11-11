; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "riscv64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr align 8 dereferenceable(26544) %cpu) #0 section ".text.Fx0" {
entry:
  %v10.stack = alloca <vscale x 1 x i64>, align 16
  %setup_stack.vector_extract = call <2 x i64> @llvm.vector.extract.v2i64.nxv1i64.i64(<vscale x 1 x i64> %xmm5, i64 0)
  store <2 x i64> %setup_stack.vector_extract, ptr %v10.stack, align 16, !tbaa !0
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp4.stack = alloca ptr, align 8
  %tmp5.stack = alloca ptr, align 8
  %tmp6.stack = alloca i64, align 8
  %env = getelementptr i8, ptr %cpu, i64 11488
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
  %T3.vector_insert = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T3.v10.stack, i64 0), !tcg.op !6
  %T3.env = ptrtoint ptr %env to i64, !tcg.op !6
  %T3.tmp6 = load i64, ptr %tmp6.stack, align 8, !tbaa !0, !tcg.op !6
  %T3.tmp5 = load i64, ptr %tmp5.stack, align 8, !tbaa !0, !tcg.op !6
  %T3.loaded_fn = load ptr, ptr %tmp4.stack, align 8, !tcg.op !6
  tail call qemuaot void %T3.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %T3.vector_insert, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr %cpu, i64 %T3.env, i64 %T3.tmp6, i64 66, i64 %T3.tmp5), !tcg.op !6
  ret void, !tcg.op !6
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <2 x i64> @llvm.vector.extract.v2i64.nxv1i64.i64(<vscale x 1 x i64>, i64 immarg) #1

; Function Attrs: noinline nounwind
define qemuaot void @trampoline_helper_rdrand(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr align 8 dereferenceable(26544) %cpu, i64 %arg0, i64 %arg1, i64 %arg2, i64 %nc) #0 section ".text.trampoline" {
entry:
  %v27.stack = alloca <vscale x 1 x i64>, align 16
  %v26.stack = alloca <vscale x 1 x i64>, align 16
  %v25.stack = alloca <vscale x 1 x i64>, align 16
  %v24.stack = alloca <vscale x 1 x i64>, align 16
  %v23.stack = alloca <vscale x 1 x i64>, align 16
  %v22.stack = alloca <vscale x 1 x i64>, align 16
  %v21.stack = alloca <vscale x 1 x i64>, align 16
  %v20.stack = alloca <vscale x 1 x i64>, align 16
  %v19.stack = alloca <vscale x 1 x i64>, align 16
  %v18.stack = alloca <vscale x 1 x i64>, align 16
  %v17.stack = alloca <vscale x 1 x i64>, align 16
  %v16.stack = alloca <vscale x 1 x i64>, align 16
  %v15.stack = alloca <vscale x 1 x i64>, align 16
  %v14.stack = alloca <vscale x 1 x i64>, align 16
  %v13.stack = alloca <vscale x 1 x i64>, align 16
  %v12.stack = alloca <vscale x 1 x i64>, align 16
  %v11.stack = alloca <vscale x 1 x i64>, align 16
  %v9.stack = alloca <vscale x 1 x i64>, align 16
  %v8.stack = alloca <vscale x 1 x i64>, align 16
  %v7.stack = alloca <vscale x 1 x i64>, align 16
  %v6.stack = alloca <vscale x 1 x i64>, align 16
  %v5.stack = alloca <vscale x 1 x i64>, align 16
  %v4.stack = alloca <vscale x 1 x i64>, align 16
  %v3.stack = alloca <vscale x 1 x i64>, align 16
  %v2.stack = alloca <vscale x 1 x i64>, align 16
  %v1.stack = alloca <vscale x 1 x i64>, align 16
  %v0.stack = alloca <vscale x 1 x i64>, align 16
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
  %v10.stack = alloca <vscale x 1 x i64>, align 16
  %setup_stack.vector_extract = call <2 x i64> @llvm.vector.extract.v2i64.nxv1i64.i64(<vscale x 1 x i64> %xmm5, i64 0)
  store <2 x i64> %setup_stack.vector_extract, ptr %v10.stack, align 16, !tbaa !0
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp6.stack = alloca i64, align 8
  %env = getelementptr i8, ptr %cpu, i64 11488
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
  %T20.bc = bitcast <vscale x 1 x i64> %xmm0 to <vscale x 8 x i8>, !tcg.op !29
  %T20.envptr = getelementptr i8, ptr %env, i64 864, !tcg.op !29
  %T20.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T20.bc, i64 0), !tcg.op !29
  store <16 x i8> %T20.vector_extract, ptr %T20.envptr, align 16, !tbaa !8, !tcg.op !29
; ======== TCG [21] st_vec v128,e8,v1,env:0x370 ========
  %T21.bc = bitcast <vscale x 1 x i64> %ymm0_h to <vscale x 8 x i8>, !tcg.op !30
  %T21.envptr = getelementptr i8, ptr %env, i64 880, !tcg.op !30
  %T21.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T21.bc, i64 0), !tcg.op !30
  store <16 x i8> %T21.vector_extract, ptr %T21.envptr, align 16, !tbaa !8, !tcg.op !30
; ======== TCG [22] st_vec v128,e8,v2,env:0x3a0 ========
  %T22.bc = bitcast <vscale x 1 x i64> %xmm1 to <vscale x 8 x i8>, !tcg.op !31
  %T22.envptr = getelementptr i8, ptr %env, i64 928, !tcg.op !31
  %T22.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T22.bc, i64 0), !tcg.op !31
  store <16 x i8> %T22.vector_extract, ptr %T22.envptr, align 16, !tbaa !8, !tcg.op !31
; ======== TCG [23] st_vec v128,e8,v3,env:0x3b0 ========
  %T23.bc = bitcast <vscale x 1 x i64> %ymm1_h to <vscale x 8 x i8>, !tcg.op !32
  %T23.envptr = getelementptr i8, ptr %env, i64 944, !tcg.op !32
  %T23.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T23.bc, i64 0), !tcg.op !32
  store <16 x i8> %T23.vector_extract, ptr %T23.envptr, align 16, !tbaa !8, !tcg.op !32
; ======== TCG [24] st_vec v128,e8,v4,env:0x3e0 ========
  %T24.bc = bitcast <vscale x 1 x i64> %xmm2 to <vscale x 8 x i8>, !tcg.op !33
  %T24.envptr = getelementptr i8, ptr %env, i64 992, !tcg.op !33
  %T24.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T24.bc, i64 0), !tcg.op !33
  store <16 x i8> %T24.vector_extract, ptr %T24.envptr, align 16, !tbaa !8, !tcg.op !33
; ======== TCG [25] st_vec v128,e8,v5,env:0x3f0 ========
  %T25.bc = bitcast <vscale x 1 x i64> %ymm2_h to <vscale x 8 x i8>, !tcg.op !34
  %T25.envptr = getelementptr i8, ptr %env, i64 1008, !tcg.op !34
  %T25.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T25.bc, i64 0), !tcg.op !34
  store <16 x i8> %T25.vector_extract, ptr %T25.envptr, align 16, !tbaa !8, !tcg.op !34
; ======== TCG [26] st_vec v128,e8,v6,env:0x420 ========
  %T26.bc = bitcast <vscale x 1 x i64> %xmm3 to <vscale x 8 x i8>, !tcg.op !35
  %T26.envptr = getelementptr i8, ptr %env, i64 1056, !tcg.op !35
  %T26.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T26.bc, i64 0), !tcg.op !35
  store <16 x i8> %T26.vector_extract, ptr %T26.envptr, align 16, !tbaa !8, !tcg.op !35
; ======== TCG [27] st_vec v128,e8,v7,env:0x430 ========
  %T27.bc = bitcast <vscale x 1 x i64> %ymm3_h to <vscale x 8 x i8>, !tcg.op !36
  %T27.envptr = getelementptr i8, ptr %env, i64 1072, !tcg.op !36
  %T27.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T27.bc, i64 0), !tcg.op !36
  store <16 x i8> %T27.vector_extract, ptr %T27.envptr, align 16, !tbaa !8, !tcg.op !36
; ======== TCG [28] st_vec v128,e8,v8,env:0x460 ========
  %T28.bc = bitcast <vscale x 1 x i64> %xmm4 to <vscale x 8 x i8>, !tcg.op !37
  %T28.envptr = getelementptr i8, ptr %env, i64 1120, !tcg.op !37
  %T28.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T28.bc, i64 0), !tcg.op !37
  store <16 x i8> %T28.vector_extract, ptr %T28.envptr, align 16, !tbaa !8, !tcg.op !37
; ======== TCG [29] st_vec v128,e8,v9,env:0x470 ========
  %T29.bc = bitcast <vscale x 1 x i64> %ymm4_h to <vscale x 8 x i8>, !tcg.op !38
  %T29.envptr = getelementptr i8, ptr %env, i64 1136, !tcg.op !38
  %T29.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T29.bc, i64 0), !tcg.op !38
  store <16 x i8> %T29.vector_extract, ptr %T29.envptr, align 16, !tbaa !8, !tcg.op !38
; ======== TCG [30] st_vec v128,e8,v10,env:0x4a0 ========
  %T30.v10 = load <16 x i8>, ptr %v10.stack, align 16, !tbaa !0, !tcg.op !39
  %T30.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T30.v10, i64 0), !tcg.op !39
  %T30.envptr = getelementptr i8, ptr %env, i64 1184, !tcg.op !39
  %T30.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T30.vector_insert, i64 0), !tcg.op !39
  store <16 x i8> %T30.vector_extract, ptr %T30.envptr, align 16, !tbaa !8, !tcg.op !39
; ======== TCG [31] st_vec v128,e8,v11,env:0x4b0 ========
  %T31.bc = bitcast <vscale x 1 x i64> %ymm5_h to <vscale x 8 x i8>, !tcg.op !40
  %T31.envptr = getelementptr i8, ptr %env, i64 1200, !tcg.op !40
  %T31.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T31.bc, i64 0), !tcg.op !40
  store <16 x i8> %T31.vector_extract, ptr %T31.envptr, align 16, !tbaa !8, !tcg.op !40
; ======== TCG [32] st_vec v128,e8,v12,env:0x4e0 ========
  %T32.bc = bitcast <vscale x 1 x i64> %xmm6 to <vscale x 8 x i8>, !tcg.op !41
  %T32.envptr = getelementptr i8, ptr %env, i64 1248, !tcg.op !41
  %T32.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T32.bc, i64 0), !tcg.op !41
  store <16 x i8> %T32.vector_extract, ptr %T32.envptr, align 16, !tbaa !8, !tcg.op !41
; ======== TCG [33] st_vec v128,e8,v13,env:0x4f0 ========
  %T33.bc = bitcast <vscale x 1 x i64> %ymm6_h to <vscale x 8 x i8>, !tcg.op !42
  %T33.envptr = getelementptr i8, ptr %env, i64 1264, !tcg.op !42
  %T33.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T33.bc, i64 0), !tcg.op !42
  store <16 x i8> %T33.vector_extract, ptr %T33.envptr, align 16, !tbaa !8, !tcg.op !42
; ======== TCG [34] st_vec v128,e8,v14,env:0x520 ========
  %T34.bc = bitcast <vscale x 1 x i64> %xmm7 to <vscale x 8 x i8>, !tcg.op !43
  %T34.envptr = getelementptr i8, ptr %env, i64 1312, !tcg.op !43
  %T34.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T34.bc, i64 0), !tcg.op !43
  store <16 x i8> %T34.vector_extract, ptr %T34.envptr, align 16, !tbaa !8, !tcg.op !43
; ======== TCG [35] st_vec v128,e8,v15,env:0x530 ========
  %T35.bc = bitcast <vscale x 1 x i64> %ymm7_h to <vscale x 8 x i8>, !tcg.op !44
  %T35.envptr = getelementptr i8, ptr %env, i64 1328, !tcg.op !44
  %T35.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T35.bc, i64 0), !tcg.op !44
  store <16 x i8> %T35.vector_extract, ptr %T35.envptr, align 16, !tbaa !8, !tcg.op !44
; ======== TCG [36] st_vec v128,e8,v16,env:0x560 ========
  %T36.bc = bitcast <vscale x 1 x i64> %xmm8 to <vscale x 8 x i8>, !tcg.op !45
  %T36.envptr = getelementptr i8, ptr %env, i64 1376, !tcg.op !45
  %T36.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T36.bc, i64 0), !tcg.op !45
  store <16 x i8> %T36.vector_extract, ptr %T36.envptr, align 16, !tbaa !8, !tcg.op !45
; ======== TCG [37] st_vec v128,e8,v17,env:0x570 ========
  %T37.bc = bitcast <vscale x 1 x i64> %ymm8_h to <vscale x 8 x i8>, !tcg.op !46
  %T37.envptr = getelementptr i8, ptr %env, i64 1392, !tcg.op !46
  %T37.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T37.bc, i64 0), !tcg.op !46
  store <16 x i8> %T37.vector_extract, ptr %T37.envptr, align 16, !tbaa !8, !tcg.op !46
; ======== TCG [38] st_vec v128,e8,v18,env:0x5a0 ========
  %T38.bc = bitcast <vscale x 1 x i64> %xmm9 to <vscale x 8 x i8>, !tcg.op !47
  %T38.envptr = getelementptr i8, ptr %env, i64 1440, !tcg.op !47
  %T38.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T38.bc, i64 0), !tcg.op !47
  store <16 x i8> %T38.vector_extract, ptr %T38.envptr, align 16, !tbaa !8, !tcg.op !47
; ======== TCG [39] st_vec v128,e8,v19,env:0x5b0 ========
  %T39.bc = bitcast <vscale x 1 x i64> %ymm9_h to <vscale x 8 x i8>, !tcg.op !48
  %T39.envptr = getelementptr i8, ptr %env, i64 1456, !tcg.op !48
  %T39.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T39.bc, i64 0), !tcg.op !48
  store <16 x i8> %T39.vector_extract, ptr %T39.envptr, align 16, !tbaa !8, !tcg.op !48
; ======== TCG [40] st_vec v128,e8,v20,env:0x5e0 ========
  %T40.bc = bitcast <vscale x 1 x i64> %xmm10 to <vscale x 8 x i8>, !tcg.op !49
  %T40.envptr = getelementptr i8, ptr %env, i64 1504, !tcg.op !49
  %T40.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T40.bc, i64 0), !tcg.op !49
  store <16 x i8> %T40.vector_extract, ptr %T40.envptr, align 16, !tbaa !8, !tcg.op !49
; ======== TCG [41] st_vec v128,e8,v21,env:0x5f0 ========
  %T41.bc = bitcast <vscale x 1 x i64> %ymm10_h to <vscale x 8 x i8>, !tcg.op !50
  %T41.envptr = getelementptr i8, ptr %env, i64 1520, !tcg.op !50
  %T41.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T41.bc, i64 0), !tcg.op !50
  store <16 x i8> %T41.vector_extract, ptr %T41.envptr, align 16, !tbaa !8, !tcg.op !50
; ======== TCG [42] st_vec v128,e8,v22,env:0x620 ========
  %T42.bc = bitcast <vscale x 1 x i64> %xmm11 to <vscale x 8 x i8>, !tcg.op !51
  %T42.envptr = getelementptr i8, ptr %env, i64 1568, !tcg.op !51
  %T42.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T42.bc, i64 0), !tcg.op !51
  store <16 x i8> %T42.vector_extract, ptr %T42.envptr, align 16, !tbaa !8, !tcg.op !51
; ======== TCG [43] st_vec v128,e8,v23,env:0x630 ========
  %T43.bc = bitcast <vscale x 1 x i64> %ymm11_h to <vscale x 8 x i8>, !tcg.op !52
  %T43.envptr = getelementptr i8, ptr %env, i64 1584, !tcg.op !52
  %T43.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T43.bc, i64 0), !tcg.op !52
  store <16 x i8> %T43.vector_extract, ptr %T43.envptr, align 16, !tbaa !8, !tcg.op !52
; ======== TCG [44] st_vec v128,e8,v24,env:0x660 ========
  %T44.bc = bitcast <vscale x 1 x i64> %xmm12 to <vscale x 8 x i8>, !tcg.op !53
  %T44.envptr = getelementptr i8, ptr %env, i64 1632, !tcg.op !53
  %T44.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T44.bc, i64 0), !tcg.op !53
  store <16 x i8> %T44.vector_extract, ptr %T44.envptr, align 16, !tbaa !8, !tcg.op !53
; ======== TCG [45] st_vec v128,e8,v25,env:0x670 ========
  %T45.bc = bitcast <vscale x 1 x i64> %ymm12_h to <vscale x 8 x i8>, !tcg.op !54
  %T45.envptr = getelementptr i8, ptr %env, i64 1648, !tcg.op !54
  %T45.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T45.bc, i64 0), !tcg.op !54
  store <16 x i8> %T45.vector_extract, ptr %T45.envptr, align 16, !tbaa !8, !tcg.op !54
; ======== TCG [46] st_vec v128,e8,v26,env:0x6a0 ========
  %T46.bc = bitcast <vscale x 1 x i64> %xmm13 to <vscale x 8 x i8>, !tcg.op !55
  %T46.envptr = getelementptr i8, ptr %env, i64 1696, !tcg.op !55
  %T46.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T46.bc, i64 0), !tcg.op !55
  store <16 x i8> %T46.vector_extract, ptr %T46.envptr, align 16, !tbaa !8, !tcg.op !55
; ======== TCG [47] st_vec v128,e8,v27,env:0x6b0 ========
  %T47.bc = bitcast <vscale x 1 x i64> %ymm13_h to <vscale x 8 x i8>, !tcg.op !56
  %T47.envptr = getelementptr i8, ptr %env, i64 1712, !tcg.op !56
  %T47.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T47.bc, i64 0), !tcg.op !56
  store <16 x i8> %T47.vector_extract, ptr %T47.envptr, align 16, !tbaa !8, !tcg.op !56
; ======== TCG [48] call_default helper_rdrand,[t1],arg0,arg1,arg2 ========
  %T48.env = ptrtoint ptr %env to i64, !tcg.op !57
  call void asm "mv x7, $0", "r,~{x7}"(i64 %T48.env), !tcg.op !57
  %T48.cr = call i64 @helper_rdrand(i64 %arg0, i64 %arg1, i64 %arg2), !tcg.op !57
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
  %T69.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T69.envval, i64 0), !tcg.op !78
  %T69.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T69.vector_insert, i64 0), !tcg.op !78
  store <16 x i8> %T69.vector_extract, ptr %v0.stack, align 16, !tbaa !0, !tcg.op !78
; ======== TCG [70] ld_vec v128,e8,[v1],env:0x370 ========
  %T70.envptr = getelementptr i8, ptr %env, i64 880, !tcg.op !79
  %T70.envval = load <16 x i8>, ptr %T70.envptr, align 16, !tbaa !8, !tcg.op !79
  %T70.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T70.envval, i64 0), !tcg.op !79
  %T70.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T70.vector_insert, i64 0), !tcg.op !79
  store <16 x i8> %T70.vector_extract, ptr %v1.stack, align 16, !tbaa !0, !tcg.op !79
; ======== TCG [71] ld_vec v128,e8,[v2],env:0x3a0 ========
  %T71.envptr = getelementptr i8, ptr %env, i64 928, !tcg.op !80
  %T71.envval = load <16 x i8>, ptr %T71.envptr, align 16, !tbaa !8, !tcg.op !80
  %T71.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T71.envval, i64 0), !tcg.op !80
  %T71.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T71.vector_insert, i64 0), !tcg.op !80
  store <16 x i8> %T71.vector_extract, ptr %v2.stack, align 16, !tbaa !0, !tcg.op !80
; ======== TCG [72] ld_vec v128,e8,[v3],env:0x3b0 ========
  %T72.envptr = getelementptr i8, ptr %env, i64 944, !tcg.op !81
  %T72.envval = load <16 x i8>, ptr %T72.envptr, align 16, !tbaa !8, !tcg.op !81
  %T72.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T72.envval, i64 0), !tcg.op !81
  %T72.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T72.vector_insert, i64 0), !tcg.op !81
  store <16 x i8> %T72.vector_extract, ptr %v3.stack, align 16, !tbaa !0, !tcg.op !81
; ======== TCG [73] ld_vec v128,e8,[v4],env:0x3e0 ========
  %T73.envptr = getelementptr i8, ptr %env, i64 992, !tcg.op !82
  %T73.envval = load <16 x i8>, ptr %T73.envptr, align 16, !tbaa !8, !tcg.op !82
  %T73.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T73.envval, i64 0), !tcg.op !82
  %T73.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T73.vector_insert, i64 0), !tcg.op !82
  store <16 x i8> %T73.vector_extract, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !82
; ======== TCG [74] ld_vec v128,e8,[v5],env:0x3f0 ========
  %T74.envptr = getelementptr i8, ptr %env, i64 1008, !tcg.op !83
  %T74.envval = load <16 x i8>, ptr %T74.envptr, align 16, !tbaa !8, !tcg.op !83
  %T74.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T74.envval, i64 0), !tcg.op !83
  %T74.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T74.vector_insert, i64 0), !tcg.op !83
  store <16 x i8> %T74.vector_extract, ptr %v5.stack, align 16, !tbaa !0, !tcg.op !83
; ======== TCG [75] ld_vec v128,e8,[v6],env:0x420 ========
  %T75.envptr = getelementptr i8, ptr %env, i64 1056, !tcg.op !84
  %T75.envval = load <16 x i8>, ptr %T75.envptr, align 16, !tbaa !8, !tcg.op !84
  %T75.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T75.envval, i64 0), !tcg.op !84
  %T75.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T75.vector_insert, i64 0), !tcg.op !84
  store <16 x i8> %T75.vector_extract, ptr %v6.stack, align 16, !tbaa !0, !tcg.op !84
; ======== TCG [76] ld_vec v128,e8,[v7],env:0x430 ========
  %T76.envptr = getelementptr i8, ptr %env, i64 1072, !tcg.op !85
  %T76.envval = load <16 x i8>, ptr %T76.envptr, align 16, !tbaa !8, !tcg.op !85
  %T76.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T76.envval, i64 0), !tcg.op !85
  %T76.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T76.vector_insert, i64 0), !tcg.op !85
  store <16 x i8> %T76.vector_extract, ptr %v7.stack, align 16, !tbaa !0, !tcg.op !85
; ======== TCG [77] ld_vec v128,e8,[v8],env:0x460 ========
  %T77.envptr = getelementptr i8, ptr %env, i64 1120, !tcg.op !86
  %T77.envval = load <16 x i8>, ptr %T77.envptr, align 16, !tbaa !8, !tcg.op !86
  %T77.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T77.envval, i64 0), !tcg.op !86
  %T77.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T77.vector_insert, i64 0), !tcg.op !86
  store <16 x i8> %T77.vector_extract, ptr %v8.stack, align 16, !tbaa !0, !tcg.op !86
; ======== TCG [78] ld_vec v128,e8,[v9],env:0x470 ========
  %T78.envptr = getelementptr i8, ptr %env, i64 1136, !tcg.op !87
  %T78.envval = load <16 x i8>, ptr %T78.envptr, align 16, !tbaa !8, !tcg.op !87
  %T78.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T78.envval, i64 0), !tcg.op !87
  %T78.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T78.vector_insert, i64 0), !tcg.op !87
  store <16 x i8> %T78.vector_extract, ptr %v9.stack, align 16, !tbaa !0, !tcg.op !87
; ======== TCG [79] ld_vec v128,e8,[v10],env:0x4a0 ========
  %T79.envptr = getelementptr i8, ptr %env, i64 1184, !tcg.op !88
  %T79.envval = load <16 x i8>, ptr %T79.envptr, align 16, !tbaa !8, !tcg.op !88
  %T79.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T79.envval, i64 0), !tcg.op !88
  %T79.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T79.vector_insert, i64 0), !tcg.op !88
  store <16 x i8> %T79.vector_extract, ptr %v10.stack, align 16, !tbaa !0, !tcg.op !88
; ======== TCG [80] ld_vec v128,e8,[v11],env:0x4b0 ========
  %T80.envptr = getelementptr i8, ptr %env, i64 1200, !tcg.op !89
  %T80.envval = load <16 x i8>, ptr %T80.envptr, align 16, !tbaa !8, !tcg.op !89
  %T80.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T80.envval, i64 0), !tcg.op !89
  %T80.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T80.vector_insert, i64 0), !tcg.op !89
  store <16 x i8> %T80.vector_extract, ptr %v11.stack, align 16, !tbaa !0, !tcg.op !89
; ======== TCG [81] ld_vec v128,e8,[v12],env:0x4e0 ========
  %T81.envptr = getelementptr i8, ptr %env, i64 1248, !tcg.op !90
  %T81.envval = load <16 x i8>, ptr %T81.envptr, align 16, !tbaa !8, !tcg.op !90
  %T81.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T81.envval, i64 0), !tcg.op !90
  %T81.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T81.vector_insert, i64 0), !tcg.op !90
  store <16 x i8> %T81.vector_extract, ptr %v12.stack, align 16, !tbaa !0, !tcg.op !90
; ======== TCG [82] ld_vec v128,e8,[v13],env:0x4f0 ========
  %T82.envptr = getelementptr i8, ptr %env, i64 1264, !tcg.op !91
  %T82.envval = load <16 x i8>, ptr %T82.envptr, align 16, !tbaa !8, !tcg.op !91
  %T82.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T82.envval, i64 0), !tcg.op !91
  %T82.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T82.vector_insert, i64 0), !tcg.op !91
  store <16 x i8> %T82.vector_extract, ptr %v13.stack, align 16, !tbaa !0, !tcg.op !91
; ======== TCG [83] ld_vec v128,e8,[v14],env:0x520 ========
  %T83.envptr = getelementptr i8, ptr %env, i64 1312, !tcg.op !92
  %T83.envval = load <16 x i8>, ptr %T83.envptr, align 16, !tbaa !8, !tcg.op !92
  %T83.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T83.envval, i64 0), !tcg.op !92
  %T83.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T83.vector_insert, i64 0), !tcg.op !92
  store <16 x i8> %T83.vector_extract, ptr %v14.stack, align 16, !tbaa !0, !tcg.op !92
; ======== TCG [84] ld_vec v128,e8,[v15],env:0x530 ========
  %T84.envptr = getelementptr i8, ptr %env, i64 1328, !tcg.op !93
  %T84.envval = load <16 x i8>, ptr %T84.envptr, align 16, !tbaa !8, !tcg.op !93
  %T84.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T84.envval, i64 0), !tcg.op !93
  %T84.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T84.vector_insert, i64 0), !tcg.op !93
  store <16 x i8> %T84.vector_extract, ptr %v15.stack, align 16, !tbaa !0, !tcg.op !93
; ======== TCG [85] ld_vec v128,e8,[v16],env:0x560 ========
  %T85.envptr = getelementptr i8, ptr %env, i64 1376, !tcg.op !94
  %T85.envval = load <16 x i8>, ptr %T85.envptr, align 16, !tbaa !8, !tcg.op !94
  %T85.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T85.envval, i64 0), !tcg.op !94
  %T85.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T85.vector_insert, i64 0), !tcg.op !94
  store <16 x i8> %T85.vector_extract, ptr %v16.stack, align 16, !tbaa !0, !tcg.op !94
; ======== TCG [86] ld_vec v128,e8,[v17],env:0x570 ========
  %T86.envptr = getelementptr i8, ptr %env, i64 1392, !tcg.op !95
  %T86.envval = load <16 x i8>, ptr %T86.envptr, align 16, !tbaa !8, !tcg.op !95
  %T86.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T86.envval, i64 0), !tcg.op !95
  %T86.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T86.vector_insert, i64 0), !tcg.op !95
  store <16 x i8> %T86.vector_extract, ptr %v17.stack, align 16, !tbaa !0, !tcg.op !95
; ======== TCG [87] ld_vec v128,e8,[v18],env:0x5a0 ========
  %T87.envptr = getelementptr i8, ptr %env, i64 1440, !tcg.op !96
  %T87.envval = load <16 x i8>, ptr %T87.envptr, align 16, !tbaa !8, !tcg.op !96
  %T87.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T87.envval, i64 0), !tcg.op !96
  %T87.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T87.vector_insert, i64 0), !tcg.op !96
  store <16 x i8> %T87.vector_extract, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !96
; ======== TCG [88] ld_vec v128,e8,[v19],env:0x5b0 ========
  %T88.envptr = getelementptr i8, ptr %env, i64 1456, !tcg.op !97
  %T88.envval = load <16 x i8>, ptr %T88.envptr, align 16, !tbaa !8, !tcg.op !97
  %T88.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T88.envval, i64 0), !tcg.op !97
  %T88.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T88.vector_insert, i64 0), !tcg.op !97
  store <16 x i8> %T88.vector_extract, ptr %v19.stack, align 16, !tbaa !0, !tcg.op !97
; ======== TCG [89] ld_vec v128,e8,[v20],env:0x5e0 ========
  %T89.envptr = getelementptr i8, ptr %env, i64 1504, !tcg.op !98
  %T89.envval = load <16 x i8>, ptr %T89.envptr, align 16, !tbaa !8, !tcg.op !98
  %T89.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T89.envval, i64 0), !tcg.op !98
  %T89.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T89.vector_insert, i64 0), !tcg.op !98
  store <16 x i8> %T89.vector_extract, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !98
; ======== TCG [90] ld_vec v128,e8,[v21],env:0x5f0 ========
  %T90.envptr = getelementptr i8, ptr %env, i64 1520, !tcg.op !99
  %T90.envval = load <16 x i8>, ptr %T90.envptr, align 16, !tbaa !8, !tcg.op !99
  %T90.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T90.envval, i64 0), !tcg.op !99
  %T90.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T90.vector_insert, i64 0), !tcg.op !99
  store <16 x i8> %T90.vector_extract, ptr %v21.stack, align 16, !tbaa !0, !tcg.op !99
; ======== TCG [91] ld_vec v128,e8,[v22],env:0x620 ========
  %T91.envptr = getelementptr i8, ptr %env, i64 1568, !tcg.op !100
  %T91.envval = load <16 x i8>, ptr %T91.envptr, align 16, !tbaa !8, !tcg.op !100
  %T91.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T91.envval, i64 0), !tcg.op !100
  %T91.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T91.vector_insert, i64 0), !tcg.op !100
  store <16 x i8> %T91.vector_extract, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !100
; ======== TCG [92] ld_vec v128,e8,[v23],env:0x630 ========
  %T92.envptr = getelementptr i8, ptr %env, i64 1584, !tcg.op !101
  %T92.envval = load <16 x i8>, ptr %T92.envptr, align 16, !tbaa !8, !tcg.op !101
  %T92.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T92.envval, i64 0), !tcg.op !101
  %T92.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T92.vector_insert, i64 0), !tcg.op !101
  store <16 x i8> %T92.vector_extract, ptr %v23.stack, align 16, !tbaa !0, !tcg.op !101
; ======== TCG [93] ld_vec v128,e8,[v24],env:0x660 ========
  %T93.envptr = getelementptr i8, ptr %env, i64 1632, !tcg.op !102
  %T93.envval = load <16 x i8>, ptr %T93.envptr, align 16, !tbaa !8, !tcg.op !102
  %T93.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T93.envval, i64 0), !tcg.op !102
  %T93.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T93.vector_insert, i64 0), !tcg.op !102
  store <16 x i8> %T93.vector_extract, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !102
; ======== TCG [94] ld_vec v128,e8,[v25],env:0x670 ========
  %T94.envptr = getelementptr i8, ptr %env, i64 1648, !tcg.op !103
  %T94.envval = load <16 x i8>, ptr %T94.envptr, align 16, !tbaa !8, !tcg.op !103
  %T94.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T94.envval, i64 0), !tcg.op !103
  %T94.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T94.vector_insert, i64 0), !tcg.op !103
  store <16 x i8> %T94.vector_extract, ptr %v25.stack, align 16, !tbaa !0, !tcg.op !103
; ======== TCG [95] ld_vec v128,e8,[v26],env:0x6a0 ========
  %T95.envptr = getelementptr i8, ptr %env, i64 1696, !tcg.op !104
  %T95.envval = load <16 x i8>, ptr %T95.envptr, align 16, !tbaa !8, !tcg.op !104
  %T95.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T95.envval, i64 0), !tcg.op !104
  %T95.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T95.vector_insert, i64 0), !tcg.op !104
  store <16 x i8> %T95.vector_extract, ptr %v26.stack, align 16, !tbaa !0, !tcg.op !104
; ======== TCG [96] ld_vec v128,e8,[v27],env:0x6b0 ========
  %T96.envptr = getelementptr i8, ptr %env, i64 1712, !tcg.op !105
  %T96.envval = load <16 x i8>, ptr %T96.envptr, align 16, !tbaa !8, !tcg.op !105
  %T96.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T96.envval, i64 0), !tcg.op !105
  %T96.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T96.vector_insert, i64 0), !tcg.op !105
  store <16 x i8> %T96.vector_extract, ptr %v27.stack, align 16, !tbaa !0, !tcg.op !105
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
  %T97.vector_insert = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v0.stack, i64 0), !tcg.op !106
  %T97.v1.stack = load <2 x i64>, ptr %v1.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert1 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v1.stack, i64 0), !tcg.op !106
  %T97.v2.stack = load <2 x i64>, ptr %v2.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert2 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v2.stack, i64 0), !tcg.op !106
  %T97.v3.stack = load <2 x i64>, ptr %v3.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert3 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v3.stack, i64 0), !tcg.op !106
  %T97.v4.stack = load <2 x i64>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert4 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v4.stack, i64 0), !tcg.op !106
  %T97.v5.stack = load <2 x i64>, ptr %v5.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert5 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v5.stack, i64 0), !tcg.op !106
  %T97.v6.stack = load <2 x i64>, ptr %v6.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert6 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v6.stack, i64 0), !tcg.op !106
  %T97.v7.stack = load <2 x i64>, ptr %v7.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert7 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v7.stack, i64 0), !tcg.op !106
  %T97.v8.stack = load <2 x i64>, ptr %v8.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert8 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v8.stack, i64 0), !tcg.op !106
  %T97.v9.stack = load <2 x i64>, ptr %v9.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert9 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v9.stack, i64 0), !tcg.op !106
  %T97.v10.stack = load <2 x i64>, ptr %v10.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert10 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v10.stack, i64 0), !tcg.op !106
  %T97.v11.stack = load <2 x i64>, ptr %v11.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert11 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v11.stack, i64 0), !tcg.op !106
  %T97.v12.stack = load <2 x i64>, ptr %v12.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert12 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v12.stack, i64 0), !tcg.op !106
  %T97.v13.stack = load <2 x i64>, ptr %v13.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert13 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v13.stack, i64 0), !tcg.op !106
  %T97.v14.stack = load <2 x i64>, ptr %v14.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert14 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v14.stack, i64 0), !tcg.op !106
  %T97.v15.stack = load <2 x i64>, ptr %v15.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert15 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v15.stack, i64 0), !tcg.op !106
  %T97.v16.stack = load <2 x i64>, ptr %v16.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert16 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v16.stack, i64 0), !tcg.op !106
  %T97.v17.stack = load <2 x i64>, ptr %v17.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert17 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v17.stack, i64 0), !tcg.op !106
  %T97.v18.stack = load <2 x i64>, ptr %v18.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert18 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v18.stack, i64 0), !tcg.op !106
  %T97.v19.stack = load <2 x i64>, ptr %v19.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert19 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v19.stack, i64 0), !tcg.op !106
  %T97.v20.stack = load <2 x i64>, ptr %v20.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert20 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v20.stack, i64 0), !tcg.op !106
  %T97.v21.stack = load <2 x i64>, ptr %v21.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert21 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v21.stack, i64 0), !tcg.op !106
  %T97.v22.stack = load <2 x i64>, ptr %v22.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert22 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v22.stack, i64 0), !tcg.op !106
  %T97.v23.stack = load <2 x i64>, ptr %v23.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert23 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v23.stack, i64 0), !tcg.op !106
  %T97.v24.stack = load <2 x i64>, ptr %v24.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert24 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v24.stack, i64 0), !tcg.op !106
  %T97.v25.stack = load <2 x i64>, ptr %v25.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert25 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v25.stack, i64 0), !tcg.op !106
  %T97.v26.stack = load <2 x i64>, ptr %v26.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert26 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v26.stack, i64 0), !tcg.op !106
  %T97.v27.stack = load <2 x i64>, ptr %v27.stack, align 16, !tbaa !0, !tcg.op !106
  %T97.vector_insert27 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T97.v27.stack, i64 0), !tcg.op !106
  %T97.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !106
  %T97.loaded_fn = inttoptr i64 %nc to ptr, !tcg.op !106
  tail call qemuaot void %T97.loaded_fn(i64 %T97.rax.stack, i64 %T97.rcx.stack, i64 %T97.rdx.stack, i64 %T97.rbx.stack, i64 %T97.rsp.stack, i64 %T97.rbp.stack, i64 %T97.rsi.stack, i64 %T97.rdi.stack, i64 %T97.r8.stack, i64 %T97.r9.stack, i64 %T97.r10.stack, i64 %T97.r11.stack, i64 %T97.r12.stack, i64 %T97.r13.stack, i64 %T97.r14.stack, i64 %T97.r15.stack, i64 %T97.cc_src.stack, i64 %T97.cc_dst.stack, i32 %T97.cc_op.stack, i64 %T97.rip.stack, <vscale x 1 x i64> %T97.vector_insert, <vscale x 1 x i64> %T97.vector_insert1, <vscale x 1 x i64> %T97.vector_insert2, <vscale x 1 x i64> %T97.vector_insert3, <vscale x 1 x i64> %T97.vector_insert4, <vscale x 1 x i64> %T97.vector_insert5, <vscale x 1 x i64> %T97.vector_insert6, <vscale x 1 x i64> %T97.vector_insert7, <vscale x 1 x i64> %T97.vector_insert8, <vscale x 1 x i64> %T97.vector_insert9, <vscale x 1 x i64> %T97.vector_insert10, <vscale x 1 x i64> %T97.vector_insert11, <vscale x 1 x i64> %T97.vector_insert12, <vscale x 1 x i64> %T97.vector_insert13, <vscale x 1 x i64> %T97.vector_insert14, <vscale x 1 x i64> %T97.vector_insert15, <vscale x 1 x i64> %T97.vector_insert16, <vscale x 1 x i64> %T97.vector_insert17, <vscale x 1 x i64> %T97.vector_insert18, <vscale x 1 x i64> %T97.vector_insert19, <vscale x 1 x i64> %T97.vector_insert20, <vscale x 1 x i64> %T97.vector_insert21, <vscale x 1 x i64> %T97.vector_insert22, <vscale x 1 x i64> %T97.vector_insert23, <vscale x 1 x i64> %T97.vector_insert24, <vscale x 1 x i64> %T97.vector_insert25, <vscale x 1 x i64> %T97.vector_insert26, <vscale x 1 x i64> %T97.vector_insert27, ptr %cpu, i64 %T97.tmp1), !tcg.op !106
  ret void, !tcg.op !106
}

; Function Attrs: noinline nounwind
define qemuaot void @Fx0_1(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr align 8 dereferenceable(26544) %cpu, i64 %rv) #0 section ".text.Fx0_1" {
entry:
  %v10.stack = alloca <vscale x 1 x i64>, align 16
  %setup_stack.vector_extract = call <2 x i64> @llvm.vector.extract.v2i64.nxv1i64.i64(<vscale x 1 x i64> %xmm5, i64 0)
  store <2 x i64> %setup_stack.vector_extract, ptr %v10.stack, align 16, !tbaa !0
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca ptr, align 8
  %tmp6.stack = alloca i64, align 8
  %env = getelementptr i8, ptr %cpu, i64 11488
; ======== TCG [0] mov_i64 [t1],__last_arg__ ========
  store i64 %rv, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !107
; ======== TCG [1] mov_i64 [t2],t1 ========
  %T1.tmp1 = load i64, ptr %tmp1.stack, align 8, !tbaa !0, !tcg.op !108
  store i64 %T1.tmp1, ptr %tmp2.stack, align 8, !tbaa !0, !tcg.op !108
; ======== TCG [2] func_addr t3,0x55aa,0x0 ========
  store ptr @Fx55aa, ptr %tmp3.stack, align 8, !tbaa !0, !tcg.op !109
; ======== TCG [3] tail_call_qemuaot t3 VEC_ARGS: ========
  %T3.v10.stack = load <2 x i64>, ptr %v10.stack, align 16, !tbaa !0, !tcg.op !110
  %T3.vector_insert = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T3.v10.stack, i64 0), !tcg.op !110
  %T3.loaded_fn = load ptr, ptr %tmp3.stack, align 8, !tcg.op !110
  tail call qemuaot void %T3.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %T3.vector_insert, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr %cpu), !tcg.op !110
  ret void, !tcg.op !110
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64>, <2 x i64>, i64 immarg) #1

; Function Attrs: nounwind
declare qemuaot void @Fx55aa(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, ptr align 8 dereferenceable(26544)) #2 section ".text.Fx55aa"

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8>, i64 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8>, <16 x i8>, i64 immarg) #1

declare i64 @helper_rdrand(i64, i64, i64)

attributes #0 = { noinline nounwind "target-features"="+m,+a,+f,+d,+v" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { nounwind "target-features"="+m,+a,+f,+d,+v" }

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
