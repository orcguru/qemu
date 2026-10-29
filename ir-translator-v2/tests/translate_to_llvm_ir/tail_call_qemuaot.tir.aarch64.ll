; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

@helper_retaddr = thread_local local_unnamed_addr global i64 0, align 8

; Function Attrs: noinline nounwind
define qemuaot void @Fx55aa(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26528) %cpu) #0 section ".text.Fx55aa" {
entry:
  %rsi.stack = alloca i64, align 8
  store i64 %rsi, ptr %rsi.stack, align 8, !tbaa !4
  %v0.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm0, ptr %v0.stack, align 16, !tbaa !4
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca i64, align 8
  %tmp5.stack = alloca ptr, align 8
  %tmp6.stack = alloca ptr, align 8
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] mov_i64 [t0],0xffffffffffffffe1 ========
  store i64 -31, ptr %tmp0.stack, align 8, !tbaa !4, !tcg.op !7
; ======== TCG [1] func_addr t5,helper_pshufd_xmm,v0,v0 ========
  store ptr @helper_pshufd_xmm_V0_V0, ptr %tmp5.stack, align 8, !tbaa !4, !tcg.op !8
; ======== TCG [2] func_addr t6,0x55aa,0x1 ========
  store ptr @Fx55aa_1, ptr %tmp6.stack, align 8, !tbaa !4, !tcg.op !9
; ======== TCG [3] tail_call_qemuaot t5,0xe1,t6 VEC_ARGS:v0,v0, ========
  %T3.rsi.stack = load i64, ptr %rsi.stack, align 8, !tbaa !4, !tcg.op !10
  %T3.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !4, !tcg.op !10
  %T3.tmp6 = load i64, ptr %tmp6.stack, align 8, !tbaa !4, !tcg.op !10
  %T3.loaded_fn = load ptr, ptr %tmp5.stack, align 8, !tcg.op !10
  tail call qemuaot void %T3.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %T3.rsi.stack, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %T3.v0.stack, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr %cpu, i32 225, i64 %T3.tmp6), !tcg.op !10
  ret void, !tcg.op !10
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot void @helper_pshufd_xmm_V0_V0(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %qemuaot_src1, i64 noundef %qemuaot_dst, i32 noundef %qemuaot_op, i64 noundef %rip, <2 x i64> noundef %xmm0, <2 x i64> noundef %ymm0_h, <2 x i64> noundef %xmm1, <2 x i64> noundef %ymm1_h, <2 x i64> noundef %xmm2, <2 x i64> noundef %ymm2_h, <2 x i64> noundef %xmm3, <2 x i64> noundef %ymm3_h, <2 x i64> noundef %xmm4, <2 x i64> noundef %ymm4_h, <2 x i64> noundef %xmm5, <2 x i64> noundef %ymm5_h, <2 x i64> noundef %xmm6, <2 x i64> noundef %ymm6_h, <2 x i64> noundef %xmm7, <2 x i64> noundef %ymm7_h, <2 x i64> noundef %xmm8, <2 x i64> noundef %ymm8_h, <2 x i64> noundef %xmm9, <2 x i64> noundef %ymm9_h, <2 x i64> noundef %xmm10, <2 x i64> noundef %ymm10_h, <2 x i64> noundef %xmm11, <2 x i64> noundef %ymm11_h, <2 x i64> noundef %xmm12, <2 x i64> noundef %ymm12_h, <2 x i64> noundef %xmm13, <2 x i64> noundef %ymm13_h, ptr noundef %cpu_param, i32 noundef %order, i64 noundef %normal_return) local_unnamed_addr #1 {
entry:
  %and = and i32 %order, 3
  %shr = lshr i32 %order, 2
  %and1 = and i32 %shr, 3
  %shr4 = lshr i32 %order, 4
  %and5 = and i32 %shr4, 3
  %shr8 = lshr i32 %order, 6
  %and9 = and i32 %shr8, 3
  %0 = bitcast <2 x i64> %xmm0 to <4 x i32>
  %vecext = extractelement <4 x i32> %0, i32 %and
  %vecext3 = extractelement <4 x i32> %0, i32 %and1
  %vecext7 = extractelement <4 x i32> %0, i32 %and5
  %vecext11 = extractelement <4 x i32> %0, i32 %and9
  %vecins = insertelement <4 x i32> poison, i32 %vecext, i64 0
  %vecins14 = insertelement <4 x i32> %vecins, i32 %vecext3, i64 1
  %vecins17 = insertelement <4 x i32> %vecins14, i32 %vecext7, i64 2
  %vecins20 = insertelement <4 x i32> %vecins17, i32 %vecext11, i64 3
  %1 = bitcast <4 x i32> %vecins20 to <2 x i64>
  %2 = inttoptr i64 %normal_return to ptr
  tail call qemuaot void %2(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %qemuaot_src1, i64 noundef %qemuaot_dst, i32 noundef %qemuaot_op, i64 noundef %rip, <2 x i64> noundef %1, <2 x i64> noundef %ymm0_h, <2 x i64> noundef %xmm1, <2 x i64> noundef %ymm1_h, <2 x i64> noundef %xmm2, <2 x i64> noundef %ymm2_h, <2 x i64> noundef %xmm3, <2 x i64> noundef %ymm3_h, <2 x i64> noundef %xmm4, <2 x i64> noundef %ymm4_h, <2 x i64> noundef %xmm5, <2 x i64> noundef %ymm5_h, <2 x i64> noundef %xmm6, <2 x i64> noundef %ymm6_h, <2 x i64> noundef %xmm7, <2 x i64> noundef %ymm7_h, <2 x i64> noundef %xmm8, <2 x i64> noundef %ymm8_h, <2 x i64> noundef %xmm9, <2 x i64> noundef %ymm9_h, <2 x i64> noundef %xmm10, <2 x i64> noundef %ymm10_h, <2 x i64> noundef %xmm11, <2 x i64> noundef %ymm11_h, <2 x i64> noundef %xmm12, <2 x i64> noundef %ymm12_h, <2 x i64> noundef %xmm13, <2 x i64> noundef %ymm13_h, ptr noundef %cpu_param) #3
  ret void
}

; Function Attrs: noinline nounwind
define qemuaot void @Fx55aa_1(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26528) %cpu) #0 section ".text.Fx55aa_1" {
entry:
  %rsi.stack = alloca i64, align 8
  store i64 %rsi, ptr %rsi.stack, align 8, !tbaa !4
  %v0.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm0, ptr %v0.stack, align 16, !tbaa !4
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca i64, align 8
  %tmp4.stack = alloca ptr, align 8
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] add_i64 [t3],rsi,0x10 ========
  %T0.rsi = load i64, ptr %rsi.stack, align 8, !tbaa !4, !tcg.op !11
  %T0.out = add i64 %T0.rsi, 16, !tcg.op !11
  store i64 %T0.out, ptr %tmp3.stack, align 8, !tbaa !4, !tcg.op !11
; ======== TCG [1] func_addr t4,0xaa55,0x0 ========
  store ptr @Fxaa55, ptr %tmp4.stack, align 8, !tbaa !4, !tcg.op !12
; ======== TCG [2] tail_call_qemuaot t4 VEC_ARGS: ========
  %T2.rsi.stack = load i64, ptr %rsi.stack, align 8, !tbaa !4, !tcg.op !13
  %T2.v0.stack = load <2 x i64>, ptr %v0.stack, align 16, !tbaa !4, !tcg.op !13
  %T2.loaded_fn = load ptr, ptr %tmp4.stack, align 8, !tcg.op !13
  tail call qemuaot void %T2.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %T2.rsi.stack, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %T2.v0.stack, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr %cpu), !tcg.op !13
  ret void, !tcg.op !13
}

; Function Attrs: nounwind
declare qemuaot void @Fxaa55(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, ptr align 8 dereferenceable(26528)) #2 section ".text.Fxaa55"

attributes #0 = { noinline nounwind "target-features"="+neon" }
attributes #1 = { alwaysinline nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-a15" "target-features"="+aes,+bf16,+bti,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fpac,+fullfp16,+i8mm,+jsconv,+lse,+neon,+outline-atomics,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8.6a,+v8a,-fmv" }
attributes #2 = { nounwind "target-features"="+neon" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1, !2, !3}

!0 = !{!"clang version 21.0.0git (git@github.com:orcguru/llvm-project.git aac6dfaa883a699dfc57db3d2518fbdf809bc6ae)"}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"frame-pointer", i32 1}
!4 = !{!5, !5, i64 0}
!5 = !{!"SpillSlo", !6}
!6 = !{!"Root"}
!7 = !{!"[0] mov_i64 [t0],0xffffffffffffffe1"}
!8 = !{!"[1] func_addr t5,helper_pshufd_xmm,v0,v0"}
!9 = !{!"[2] func_addr t6,0x55aa,0x1"}
!10 = !{!"[3] tail_call_qemuaot t5,0xe1,t6 VEC_ARGS:v0,v0,"}
!11 = !{!"[0] add_i64 [t3],rsi,0x10"}
!12 = !{!"[1] func_addr t4,0xaa55,0x0"}
!13 = !{!"[2] tail_call_qemuaot t4 VEC_ARGS:"}
