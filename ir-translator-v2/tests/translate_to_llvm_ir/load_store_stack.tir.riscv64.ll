; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "riscv64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr align 8 dereferenceable(26544) %cpu) #0 section ".text.Fx0" {
entry:
  %rax.stack = alloca i64, align 8
  store i64 %rax, ptr %rax.stack, align 8, !tbaa !0
  %rcx.stack = alloca i64, align 8
  store i64 %rcx, ptr %rcx.stack, align 8, !tbaa !0
  %rdx.stack = alloca i64, align 8
  store i64 %rdx, ptr %rdx.stack, align 8, !tbaa !0
  %rbx.stack = alloca i64, align 8
  store i64 %rbx, ptr %rbx.stack, align 8, !tbaa !0
  %v2.stack = alloca <vscale x 1 x i64>, align 16
  %setup_stack.vector_extract = call <2 x i64> @llvm.vector.extract.v2i64.nxv1i64.i64(<vscale x 1 x i64> %xmm1, i64 0)
  store <2 x i64> %setup_stack.vector_extract, ptr %v2.stack, align 16, !tbaa !0
  %v4.stack = alloca <vscale x 1 x i64>, align 16
  %setup_stack.vector_extract1 = call <2 x i64> @llvm.vector.extract.v2i64.nxv1i64.i64(<vscale x 1 x i64> %xmm2, i64 0)
  store <2 x i64> %setup_stack.vector_extract1, ptr %v4.stack, align 16, !tbaa !0
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca <vscale x 1 x i64>, align 16
  %env = getelementptr i8, ptr %cpu, i64 11488
; ======== TCG [0] add_i64 [rax],rbx,rdx ========
  %T0.rbx = load i64, ptr %rbx.stack, align 8, !tbaa !0, !tcg.op !3
  %T0.rdx = load i64, ptr %rdx.stack, align 8, !tbaa !0, !tcg.op !3
  %T0.out = add i64 %T0.rbx, %T0.rdx, !tcg.op !3
  store i64 %T0.out, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !3
; ======== TCG [1] add_i64 [t0],rax,0x42 ========
  %T1.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !4
  %T1.out = add i64 %T1.rax, 66, !tcg.op !4
  store i64 %T1.out, ptr %tmp0.stack, align 8, !tbaa !0, !tcg.op !4
; ======== TCG [2] add_i64 [rcx],rcx,rcx ========
  %T2.rcx = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !5
  %T2.rcx2 = load i64, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !5
  %T2.out = add i64 %T2.rcx, %T2.rcx2, !tcg.op !5
  store i64 %T2.out, ptr %rcx.stack, align 8, !tbaa !0, !tcg.op !5
; ======== TCG [3] add_vec v128,e8,[t3],v2,v4 ========
  %T3.v2 = load <16 x i8>, ptr %v2.stack, align 16, !tbaa !0, !tcg.op !6
  %T3.vector_insert = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T3.v2, i64 0), !tcg.op !6
  %T3.v4 = load <16 x i8>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !6
  %T3.vector_insert3 = call <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8> poison, <16 x i8> %T3.v4, i64 0), !tcg.op !6
  %T3.out = add <vscale x 8 x i8> %T3.vector_insert, %T3.vector_insert3, !tcg.op !6
  %T3.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T3.out, i64 0), !tcg.op !6
  store <16 x i8> %T3.vector_extract, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !6
; ======== TCG [4] add_vec v128,e16,[t3],v2,v4 ========
  %T4.v2 = load <8 x i16>, ptr %v2.stack, align 16, !tbaa !0, !tcg.op !7
  %T4.vector_insert = call <vscale x 4 x i16> @llvm.vector.insert.nxv4i16.v8i16.i64(<vscale x 4 x i16> poison, <8 x i16> %T4.v2, i64 0), !tcg.op !7
  %T4.v4 = load <8 x i16>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !7
  %T4.vector_insert4 = call <vscale x 4 x i16> @llvm.vector.insert.nxv4i16.v8i16.i64(<vscale x 4 x i16> poison, <8 x i16> %T4.v4, i64 0), !tcg.op !7
  %T4.out = add <vscale x 4 x i16> %T4.vector_insert, %T4.vector_insert4, !tcg.op !7
  %T4.vector_extract = call <8 x i16> @llvm.vector.extract.v8i16.nxv4i16.i64(<vscale x 4 x i16> %T4.out, i64 0), !tcg.op !7
  store <8 x i16> %T4.vector_extract, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !7
; ======== TCG [5] add_vec v128,e32,[t3],v2,v4 ========
  %T5.v2 = load <4 x i32>, ptr %v2.stack, align 16, !tbaa !0, !tcg.op !8
  %T5.vector_insert = call <vscale x 2 x i32> @llvm.vector.insert.nxv2i32.v4i32.i64(<vscale x 2 x i32> poison, <4 x i32> %T5.v2, i64 0), !tcg.op !8
  %T5.v4 = load <4 x i32>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !8
  %T5.vector_insert5 = call <vscale x 2 x i32> @llvm.vector.insert.nxv2i32.v4i32.i64(<vscale x 2 x i32> poison, <4 x i32> %T5.v4, i64 0), !tcg.op !8
  %T5.out = add <vscale x 2 x i32> %T5.vector_insert, %T5.vector_insert5, !tcg.op !8
  %T5.vector_extract = call <4 x i32> @llvm.vector.extract.v4i32.nxv2i32.i64(<vscale x 2 x i32> %T5.out, i64 0), !tcg.op !8
  store <4 x i32> %T5.vector_extract, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !8
; ======== TCG [6] add_vec v128,e64,[t3],v2,v4 ========
  %T6.v2 = load <2 x i64>, ptr %v2.stack, align 16, !tbaa !0, !tcg.op !9
  %T6.vector_insert = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T6.v2, i64 0), !tcg.op !9
  %T6.v4 = load <2 x i64>, ptr %v4.stack, align 16, !tbaa !0, !tcg.op !9
  %T6.vector_insert6 = call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64> poison, <2 x i64> %T6.v4, i64 0), !tcg.op !9
  %T6.out = add <vscale x 1 x i64> %T6.vector_insert, %T6.vector_insert6, !tcg.op !9
  %T6.vector_extract = call <2 x i64> @llvm.vector.extract.v2i64.nxv1i64.i64(<vscale x 1 x i64> %T6.out, i64 0), !tcg.op !9
  store <2 x i64> %T6.vector_extract, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !9
; ======== TCG [7] add_i64 [t3],rax,fs_base(env) ========
  %T7.rax = load i64, ptr %rax.stack, align 8, !tbaa !0, !tcg.op !10
  %T7.envptr = getelementptr i8, ptr %env, i64 288, !tcg.op !10
  %T7.fs_base = load i64, ptr %T7.envptr, align 16, !tbaa !11, !tcg.op !10
  %T7.out = add i64 %T7.rax, %T7.fs_base, !tcg.op !10
  store i64 %T7.out, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !10
; ======== TCG [8] add_i32 [t3],t3,t3 ========
  %T8.tmp3 = load i32, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !13
  %T8.tmp37 = load i32, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !13
  %T8.out = add i32 %T8.tmp3, %T8.tmp37, !tcg.op !13
  store i32 %T8.out, ptr %tmp3.stack, align 16, !tbaa !0, !tcg.op !13
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <2 x i64> @llvm.vector.extract.v2i64.nxv1i64.i64(<vscale x 1 x i64>, i64 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <vscale x 8 x i8> @llvm.vector.insert.nxv8i8.v16i8.i64(<vscale x 8 x i8>, <16 x i8>, i64 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8>, i64 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <vscale x 4 x i16> @llvm.vector.insert.nxv4i16.v8i16.i64(<vscale x 4 x i16>, <8 x i16>, i64 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <8 x i16> @llvm.vector.extract.v8i16.nxv4i16.i64(<vscale x 4 x i16>, i64 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <vscale x 2 x i32> @llvm.vector.insert.nxv2i32.v4i32.i64(<vscale x 2 x i32>, <4 x i32>, i64 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <4 x i32> @llvm.vector.extract.v4i32.nxv2i32.i64(<vscale x 2 x i32>, i64 immarg) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64.i64(<vscale x 1 x i64>, <2 x i64>, i64 immarg) #1

attributes #0 = { noinline nounwind "target-features"="+m,+a,+f,+d,+v" }
attributes #1 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!0 = !{!1, !1, i64 0}
!1 = !{!"SpillSlo", !2}
!2 = !{!"Root"}
!3 = !{!"[0] add_i64 [rax],rbx,rdx"}
!4 = !{!"[1] add_i64 [t0],rax,0x42"}
!5 = !{!"[2] add_i64 [rcx],rcx,rcx"}
!6 = !{!"[3] add_vec v128,e8,[t3],v2,v4"}
!7 = !{!"[4] add_vec v128,e16,[t3],v2,v4"}
!8 = !{!"[5] add_vec v128,e32,[t3],v2,v4"}
!9 = !{!"[6] add_vec v128,e64,[t3],v2,v4"}
!10 = !{!"[7] add_i64 [t3],rax,fs_base(env)"}
!11 = !{!12, !12, i64 0}
!12 = !{!"CPUState", !2}
!13 = !{!"[8] add_i32 [t3],t3,t3"}
