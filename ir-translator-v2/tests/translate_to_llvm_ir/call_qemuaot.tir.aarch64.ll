; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26528) %cpu) #0 section ".text.Fx0" {
entry:
  %cc_src.stack = alloca i64, align 8
  store i64 %cc_src, ptr %cc_src.stack, align 8, !tbaa !4
  %cc_dst.stack = alloca i64, align 8
  store i64 %cc_dst, ptr %cc_dst.stack, align 8, !tbaa !4
  %cc_op.stack = alloca i32, align 8
  store i32 %cc_op, ptr %cc_op.stack, align 8, !tbaa !4
  %v10.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm5, ptr %v10.stack, align 16, !tbaa !4
  %tmp0.stack = alloca <2 x i64>, align 16
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca ptr, align 8
  %tmp3.stack = alloca ptr, align 8
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] ld_vec v128,e8,[t0],v10 ========
  %T0.v10 = load <16 x i8>, ptr %v10.stack, align 16, !tbaa !4, !tcg.op !7
  store <16 x i8> %T0.v10, ptr %tmp0.stack, align 16, !tbaa !4, !tcg.op !7
; ======== TCG [1] func_addr t3,helper_cc_compute_c ========
  store ptr @helper_cc_compute_c, ptr %tmp3.stack, align 8, !tbaa !4, !tcg.op !8
; ======== TCG [2] call_qemuaot t3,[t0],cc_dst,cc_src,cc_src2(env),cc_op VEC_ARGS: ========
  %T2.cc_src.stack = load i64, ptr %cc_src.stack, align 8, !tbaa !4, !tcg.op !9
  %T2.cc_dst.stack = load i64, ptr %cc_dst.stack, align 8, !tbaa !4, !tcg.op !9
  %T2.cc_op.stack = load i32, ptr %cc_op.stack, align 8, !tbaa !4, !tcg.op !9
  %T2.v10.stack = load <2 x i64>, ptr %v10.stack, align 16, !tbaa !4, !tcg.op !9
  %T2.cc_dst = load i64, ptr %cc_dst.stack, align 8, !tbaa !4, !tcg.op !9
  %T2.cc_src = load i64, ptr %cc_src.stack, align 8, !tbaa !4, !tcg.op !9
  %T2.envptr = getelementptr i8, ptr %env, i64 160, !tcg.op !9
  %T2.cc_src2 = load i64, ptr %T2.envptr, align 16, !tbaa !10, !tcg.op !9
  %T2.cc_op = load i32, ptr %cc_op.stack, align 8, !tbaa !4, !tcg.op !9
  %T2.loaded_fn = load ptr, ptr %tmp3.stack, align 8, !tcg.op !9
  %T2.cr = call qemuaot i64 %T2.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %T2.cc_src.stack, i64 %T2.cc_dst.stack, i32 %T2.cc_op.stack, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %T2.v10.stack, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr %cpu, i64 %T2.cc_dst, i64 %T2.cc_src, i64 %T2.cc_src2, i32 %T2.cc_op), !tcg.op !9
  store i64 %T2.cr, ptr %tmp0.stack, align 16, !tbaa !4, !tcg.op !9
; ======== TCG [3] mov_i64 [t1],t0 ========
  %T3.tmp0 = load i64, ptr %tmp0.stack, align 16, !tbaa !4, !tcg.op !12
  store i64 %T3.tmp0, ptr %tmp1.stack, align 8, !tbaa !4, !tcg.op !12
; ======== TCG [4] func_addr t2,0x55aa,0x0 ========
  store ptr @Fx55aa, ptr %tmp2.stack, align 8, !tbaa !4, !tcg.op !13
; ======== TCG [5] tail_call_qemuaot t2 VEC_ARGS: ========
  %T5.cc_src.stack = load i64, ptr %cc_src.stack, align 8, !tbaa !4, !tcg.op !14
  %T5.cc_dst.stack = load i64, ptr %cc_dst.stack, align 8, !tbaa !4, !tcg.op !14
  %T5.cc_op.stack = load i32, ptr %cc_op.stack, align 8, !tbaa !4, !tcg.op !14
  %T5.v10.stack = load <2 x i64>, ptr %v10.stack, align 16, !tbaa !4, !tcg.op !14
  %T5.loaded_fn = load ptr, ptr %tmp2.stack, align 8, !tcg.op !14
  tail call qemuaot void %T5.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %T5.cc_src.stack, i64 %T5.cc_dst.stack, i32 %T5.cc_op.stack, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %T5.v10.stack, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr %cpu), !tcg.op !14
  ret void, !tcg.op !14
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_addb(i8 noundef %dst, i8 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ult i8 %dst, %src1
  %conv2 = zext i1 %cmp to i32
  ret i32 %conv2
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_adcb(i8 noundef %dst, i8 noundef %src1, i8 noundef %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %conv = zext i8 %src1 to i32
  %conv1 = zext i8 %src3 to i32
  %add = add nuw nsw i32 %conv1, %conv
  %conv2 = zext i8 %dst to i32
  %cmp = icmp samesign ugt i32 %add, %conv2
  %conv3 = zext i1 %cmp to i32
  ret i32 %conv3
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_subb(i8 noundef %dst, i8 noundef %src2, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = xor i8 %src2, -1
  %cmp = icmp ugt i8 %dst, %0
  %conv5 = zext i1 %cmp to i32
  ret i32 %conv5
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_sbbb(i8 noundef %dst, i8 noundef %src2, i8 noundef %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %conv = zext i8 %src2 to i32
  %conv1 = zext i8 %src3 to i32
  %add = add nuw nsw i32 %conv1, %conv
  %0 = trunc i32 %add to i8
  %conv4 = add i8 %dst, %0
  %conv5 = zext i8 %conv4 to i32
  %cmp = icmp samesign ugt i32 %add, %conv5
  %conv6 = zext i1 %cmp to i32
  ret i32 %conv6
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_shlb(i8 noundef %dst, i8 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = lshr i8 %src1, 7
  %shr = zext nneg i8 %0 to i32
  ret i32 %shr
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_bmilgb(i8 noundef %dst, i8 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp eq i8 %src1, 0
  %conv1 = zext i1 %cmp to i32
  ret i32 %conv1
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_blsib(i8 noundef %dst, i8 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ne i8 %src1, 0
  %conv1 = zext i1 %cmp to i32
  ret i32 %conv1
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_addw(i16 noundef %dst, i16 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ult i16 %dst, %src1
  %conv2 = zext i1 %cmp to i32
  ret i32 %conv2
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_adcw(i16 noundef %dst, i16 noundef %src1, i16 noundef %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %conv = zext i16 %src1 to i32
  %conv1 = zext i16 %src3 to i32
  %add = add nuw nsw i32 %conv1, %conv
  %conv2 = zext i16 %dst to i32
  %cmp = icmp samesign ugt i32 %add, %conv2
  %conv3 = zext i1 %cmp to i32
  ret i32 %conv3
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_subw(i16 noundef %dst, i16 noundef %src2, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = xor i16 %src2, -1
  %cmp = icmp ugt i16 %dst, %0
  %conv5 = zext i1 %cmp to i32
  ret i32 %conv5
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_sbbw(i16 noundef %dst, i16 noundef %src2, i16 noundef %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %conv = zext i16 %src2 to i32
  %conv1 = zext i16 %src3 to i32
  %add = add nuw nsw i32 %conv1, %conv
  %0 = trunc i32 %add to i16
  %conv4 = add i16 %dst, %0
  %conv5 = zext i16 %conv4 to i32
  %cmp = icmp samesign ugt i32 %add, %conv5
  %conv6 = zext i1 %cmp to i32
  ret i32 %conv6
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_shlw(i16 noundef %dst, i16 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = lshr i16 %src1, 15
  %shr = zext nneg i16 %0 to i32
  ret i32 %shr
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_bmilgw(i16 noundef %dst, i16 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp eq i16 %src1, 0
  %conv1 = zext i1 %cmp to i32
  ret i32 %conv1
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_blsiw(i16 noundef %dst, i16 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ne i16 %src1, 0
  %conv1 = zext i1 %cmp to i32
  ret i32 %conv1
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_addl(i32 noundef %dst, i32 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ult i32 %dst, %src1
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_adcl(i32 noundef %dst, i32 noundef %src1, i32 noundef %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %conv = zext i32 %src1 to i64
  %conv1 = zext i32 %src3 to i64
  %add = add nuw nsw i64 %conv1, %conv
  %conv2 = zext i32 %dst to i64
  %cmp = icmp samesign ugt i64 %add, %conv2
  %conv3 = zext i1 %cmp to i32
  ret i32 %conv3
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_subl(i32 noundef %dst, i32 noundef %src2, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = xor i32 %src2, -1
  %cmp = icmp ugt i32 %dst, %0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_sbbl(i32 noundef %dst, i32 noundef %src2, i32 noundef %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %conv = zext i32 %src2 to i64
  %conv1 = zext i32 %src3 to i64
  %add = add nuw nsw i64 %conv1, %conv
  %0 = trunc i64 %add to i32
  %conv4 = add i32 %dst, %0
  %conv5 = zext i32 %conv4 to i64
  %cmp = icmp samesign ugt i64 %add, %conv5
  %conv6 = zext i1 %cmp to i32
  ret i32 %conv6
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_shll(i32 noundef %dst, i32 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %shr = lshr i32 %src1, 31
  ret i32 %shr
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_bmilgl(i32 noundef %dst, i32 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp eq i32 %src1, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_blsil(i32 noundef %dst, i32 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ne i32 %src1, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_addq(i64 noundef %dst, i64 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ult i64 %dst, %src1
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_adcq(i64 noundef %dst, i64 noundef %src1, i64 noundef %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %tobool.not = icmp eq i64 %src3, 0
  %cmp = icmp ule i64 %dst, %src1
  %cmp1 = icmp ult i64 %dst, %src1
  %cond.in = select i1 %tobool.not, i1 %cmp1, i1 %cmp
  %cond = zext i1 %cond.in to i32
  ret i32 %cond
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_subq(i64 noundef %dst, i64 noundef %src2, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = xor i64 %src2, -1
  %cmp = icmp ugt i64 %dst, %0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_sbbq(i64 noundef %dst, i64 noundef %src2, i64 noundef %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %add = add i64 %src2, %dst
  %add1 = add i64 %add, %src3
  %tobool.not = icmp eq i64 %src3, 0
  %cmp = icmp ule i64 %add1, %src2
  %cmp2 = icmp ult i64 %add1, %src2
  %cond.in = select i1 %tobool.not, i1 %cmp2, i1 %cmp
  %cond = zext i1 %cond.in to i32
  ret i32 %cond
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_shlq(i64 noundef %dst, i64 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %shr = lshr i64 %src1, 63
  %conv = trunc nuw nsw i64 %shr to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_bmilgq(i64 noundef %dst, i64 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp eq i64 %src1, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i32 @compute_c_blsiq(i64 noundef %dst, i64 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ne i64 %src1, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind
define weak qemuaot i64 @helper_cc_compute_c(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %qemuaot_src1, i64 noundef %qemuaot_dst, i32 noundef %qemuaot_op, i64 noundef %rip, <2 x i64> noundef %xmm0, <2 x i64> noundef %ymm0_h, <2 x i64> noundef %xmm1, <2 x i64> noundef %ymm1_h, <2 x i64> noundef %xmm2, <2 x i64> noundef %ymm2_h, <2 x i64> noundef %xmm3, <2 x i64> noundef %ymm3_h, <2 x i64> noundef %xmm4, <2 x i64> noundef %ymm4_h, <2 x i64> noundef %xmm5, <2 x i64> noundef %ymm5_h, <2 x i64> noundef %xmm6, <2 x i64> noundef %ymm6_h, <2 x i64> noundef %xmm7, <2 x i64> noundef %ymm7_h, <2 x i64> noundef %xmm8, <2 x i64> noundef %ymm8_h, <2 x i64> noundef %xmm9, <2 x i64> noundef %ymm9_h, <2 x i64> noundef %xmm10, <2 x i64> noundef %ymm10_h, <2 x i64> noundef %xmm11, <2 x i64> noundef %ymm11_h, <2 x i64> noundef %xmm12, <2 x i64> noundef %ymm12_h, <2 x i64> noundef %xmm13, <2 x i64> noundef %ymm13_h, ptr noundef %cpu_param, i64 noundef %dst, i64 noundef %src1, i64 noundef %src2, i32 noundef %op, i64 noundef %normal_return) local_unnamed_addr #1 {
entry:
  switch i32 %op, label %cleanup [
    i32 51, label %sw.bb134
    i32 47, label %sw.bb131
    i32 39, label %sw.bb128
    i32 23, label %sw.bb125
    i32 19, label %sw.bb122
    i32 0, label %sw.bb1
    i32 40, label %sw.bb1
    i32 41, label %sw.bb1
    i32 42, label %sw.bb1
    i32 43, label %sw.bb1
    i32 2, label %sw.bb1
    i32 28, label %sw.bb2
    i32 29, label %sw.bb2
    i32 30, label %sw.bb2
    i32 31, label %sw.bb2
    i32 32, label %sw.bb2
    i32 33, label %sw.bb2
    i32 34, label %sw.bb2
    i32 35, label %sw.bb2
    i32 4, label %sw.bb3
    i32 5, label %sw.bb3
    i32 6, label %sw.bb3
    i32 7, label %sw.bb3
    i32 1, label %sw.bb5
    i32 3, label %sw.bb5
    i32 8, label %sw.bb6
    i32 9, label %sw.bb10
    i32 10, label %sw.bb15
    i32 12, label %sw.bb20
    i32 13, label %sw.bb26
    i32 14, label %sw.bb32
    i32 16, label %sw.bb38
    i32 17, label %sw.bb43
    i32 18, label %sw.bb48
    i32 20, label %sw.bb53
    i32 21, label %sw.bb59
    i32 22, label %sw.bb65
    i32 36, label %sw.bb71
    i32 37, label %sw.bb76
    i32 38, label %sw.bb81
    i32 44, label %sw.bb86
    i32 45, label %sw.bb91
    i32 46, label %sw.bb96
    i32 48, label %sw.bb101
    i32 49, label %sw.bb106
    i32 50, label %sw.bb111
    i32 11, label %sw.bb116
    i32 15, label %sw.bb119
  ]

sw.bb1:                                           ; preds = %entry, %entry, %entry, %entry, %entry, %entry
  %and = and i64 %src1, 1
  br label %cleanup

sw.bb2:                                           ; preds = %entry, %entry, %entry, %entry, %entry, %entry, %entry, %entry
  br label %cleanup

sw.bb3:                                           ; preds = %entry, %entry, %entry, %entry
  %cmp = icmp ne i64 %src1, 0
  %conv4 = zext i1 %cmp to i64
  br label %cleanup

sw.bb5:                                           ; preds = %entry, %entry
  br label %cleanup

sw.bb6:                                           ; preds = %entry
  %conv7 = trunc i64 %dst to i8
  %conv8 = trunc i64 %src1 to i8
  %cmp.i = icmp ult i8 %conv7, %conv8
  %conv9 = zext i1 %cmp.i to i64
  br label %cleanup

sw.bb10:                                          ; preds = %entry
  %conv11 = trunc i64 %dst to i16
  %conv12 = trunc i64 %src1 to i16
  %cmp.i248 = icmp ult i16 %conv11, %conv12
  %conv14 = zext i1 %cmp.i248 to i64
  br label %cleanup

sw.bb15:                                          ; preds = %entry
  %conv16 = trunc i64 %dst to i32
  %conv17 = trunc i64 %src1 to i32
  %cmp.i270 = icmp ult i32 %conv16, %conv17
  %conv19 = zext i1 %cmp.i270 to i64
  br label %cleanup

sw.bb20:                                          ; preds = %entry
  %conv21 = trunc i64 %dst to i32
  %conv22 = trunc i64 %src1 to i32
  %conv23 = trunc i64 %src2 to i32
  %conv.i = and i32 %conv22, 255
  %conv1.i = and i32 %conv23, 255
  %add.i = add nuw nsw i32 %conv1.i, %conv.i
  %conv2.i236 = and i32 %conv21, 255
  %cmp.i237 = icmp samesign ugt i32 %add.i, %conv2.i236
  %conv25 = zext i1 %cmp.i237 to i64
  br label %cleanup

sw.bb26:                                          ; preds = %entry
  %conv27 = trunc i64 %dst to i32
  %conv28 = trunc i64 %src1 to i32
  %conv29 = trunc i64 %src2 to i32
  %conv.i250 = and i32 %conv28, 65535
  %conv1.i251 = and i32 %conv29, 65535
  %add.i252 = add nuw nsw i32 %conv1.i251, %conv.i250
  %conv2.i253 = and i32 %conv27, 65535
  %cmp.i254 = icmp samesign ugt i32 %add.i252, %conv2.i253
  %conv31 = zext i1 %cmp.i254 to i64
  br label %cleanup

sw.bb32:                                          ; preds = %entry
  %conv.i272 = and i64 %src1, 4294967295
  %conv1.i273 = and i64 %src2, 4294967295
  %add.i274 = add nuw nsw i64 %conv1.i273, %conv.i272
  %conv2.i275 = and i64 %dst, 4294967295
  %cmp.i276 = icmp samesign ugt i64 %add.i274, %conv2.i275
  %conv37 = zext i1 %cmp.i276 to i64
  br label %cleanup

sw.bb38:                                          ; preds = %entry
  %conv39 = trunc i64 %dst to i8
  %conv40 = trunc i64 %src1 to i8
  %0 = xor i8 %conv40, -1
  %cmp.i238 = icmp ugt i8 %conv39, %0
  %conv42 = zext i1 %cmp.i238 to i64
  br label %cleanup

sw.bb43:                                          ; preds = %entry
  %conv44 = trunc i64 %dst to i16
  %conv45 = trunc i64 %src1 to i16
  %1 = xor i16 %conv45, -1
  %cmp.i256 = icmp ugt i16 %conv44, %1
  %conv47 = zext i1 %cmp.i256 to i64
  br label %cleanup

sw.bb48:                                          ; preds = %entry
  %conv49 = trunc i64 %dst to i32
  %conv50 = trunc i64 %src1 to i32
  %2 = xor i32 %conv50, -1
  %cmp.i278 = icmp ugt i32 %conv49, %2
  %conv52 = zext i1 %cmp.i278 to i64
  br label %cleanup

sw.bb53:                                          ; preds = %entry
  %conv54 = trunc i64 %dst to i32
  %conv55 = trunc i64 %src1 to i32
  %conv56 = trunc i64 %src2 to i32
  %conv.i239 = and i32 %conv55, 255
  %conv1.i240 = and i32 %conv56, 255
  %add.i241 = add nuw nsw i32 %conv1.i240, %conv.i239
  %conv4.i = add i32 %add.i241, %conv54
  %conv5.i242 = and i32 %conv4.i, 255
  %cmp.i243 = icmp samesign ugt i32 %add.i241, %conv5.i242
  %conv58 = zext i1 %cmp.i243 to i64
  br label %cleanup

sw.bb59:                                          ; preds = %entry
  %conv60 = trunc i64 %dst to i32
  %conv61 = trunc i64 %src1 to i32
  %conv62 = trunc i64 %src2 to i32
  %conv.i258 = and i32 %conv61, 65535
  %conv1.i259 = and i32 %conv62, 65535
  %add.i260 = add nuw nsw i32 %conv1.i259, %conv.i258
  %conv4.i261 = add i32 %add.i260, %conv60
  %conv5.i262 = and i32 %conv4.i261, 65535
  %cmp.i263 = icmp samesign ugt i32 %add.i260, %conv5.i262
  %conv64 = zext i1 %cmp.i263 to i64
  br label %cleanup

sw.bb65:                                          ; preds = %entry
  %conv.i280 = and i64 %src1, 4294967295
  %conv1.i281 = and i64 %src2, 4294967295
  %add.i282 = add nuw nsw i64 %conv1.i281, %conv.i280
  %conv4.i283 = add i64 %add.i282, %dst
  %conv5.i284 = and i64 %conv4.i283, 4294967295
  %cmp.i285 = icmp samesign ugt i64 %add.i282, %conv5.i284
  %conv70 = zext i1 %cmp.i285 to i64
  br label %cleanup

sw.bb71:                                          ; preds = %entry
  %3 = lshr i64 %src1, 7
  %shr.i = and i64 %3, 1
  br label %cleanup

sw.bb76:                                          ; preds = %entry
  %4 = lshr i64 %src1, 15
  %shr.i265 = and i64 %4, 1
  br label %cleanup

sw.bb81:                                          ; preds = %entry
  %shr.i287 = lshr i64 %src1, 31
  %conv85 = and i64 %shr.i287, 1
  br label %cleanup

sw.bb86:                                          ; preds = %entry
  %5 = and i64 %src1, 255
  %cmp.i244 = icmp eq i64 %5, 0
  %conv90 = zext i1 %cmp.i244 to i64
  br label %cleanup

sw.bb91:                                          ; preds = %entry
  %6 = and i64 %src1, 65535
  %cmp.i266 = icmp eq i64 %6, 0
  %conv95 = zext i1 %cmp.i266 to i64
  br label %cleanup

sw.bb96:                                          ; preds = %entry
  %7 = and i64 %src1, 4294967295
  %cmp.i288 = icmp eq i64 %7, 0
  %conv100 = zext i1 %cmp.i288 to i64
  br label %cleanup

sw.bb101:                                         ; preds = %entry
  %8 = and i64 %src1, 255
  %cmp.i246 = icmp ne i64 %8, 0
  %conv105 = zext i1 %cmp.i246 to i64
  br label %cleanup

sw.bb106:                                         ; preds = %entry
  %9 = and i64 %src1, 65535
  %cmp.i268 = icmp ne i64 %9, 0
  %conv110 = zext i1 %cmp.i268 to i64
  br label %cleanup

sw.bb111:                                         ; preds = %entry
  %10 = and i64 %src1, 4294967295
  %cmp.i290 = icmp ne i64 %10, 0
  %conv115 = zext i1 %cmp.i290 to i64
  br label %cleanup

sw.bb116:                                         ; preds = %entry
  %cmp.i292 = icmp ult i64 %dst, %src1
  %conv118 = zext i1 %cmp.i292 to i64
  br label %cleanup

sw.bb119:                                         ; preds = %entry
  %tobool.not.i = icmp eq i64 %src2, 0
  %cmp.i294 = icmp ule i64 %dst, %src1
  %cmp1.i = icmp ult i64 %dst, %src1
  %cond.in.i = select i1 %tobool.not.i, i1 %cmp1.i, i1 %cmp.i294
  %conv121 = zext i1 %cond.in.i to i64
  br label %cleanup

sw.bb122:                                         ; preds = %entry
  %11 = xor i64 %src1, -1
  %cmp.i295 = icmp ugt i64 %dst, %11
  %conv124 = zext i1 %cmp.i295 to i64
  br label %cleanup

sw.bb125:                                         ; preds = %entry
  %add.i297 = add i64 %src1, %dst
  %add1.i = add i64 %add.i297, %src2
  %tobool.not.i298 = icmp eq i64 %src2, 0
  %cmp.i299 = icmp ule i64 %add1.i, %src1
  %cmp2.i = icmp ult i64 %add1.i, %src1
  %cond.in.i300 = select i1 %tobool.not.i298, i1 %cmp2.i, i1 %cmp.i299
  %conv127 = zext i1 %cond.in.i300 to i64
  br label %cleanup

sw.bb128:                                         ; preds = %entry
  %shr.i302 = lshr i64 %src1, 63
  br label %cleanup

sw.bb131:                                         ; preds = %entry
  %cmp.i304 = icmp eq i64 %src1, 0
  %conv133 = zext i1 %cmp.i304 to i64
  br label %cleanup

sw.bb134:                                         ; preds = %entry
  %cmp.i306 = icmp ne i64 %src1, 0
  %conv136 = zext i1 %cmp.i306 to i64
  br label %cleanup

cleanup:                                          ; preds = %entry, %sw.bb134, %sw.bb131, %sw.bb128, %sw.bb125, %sw.bb122, %sw.bb119, %sw.bb116, %sw.bb111, %sw.bb106, %sw.bb101, %sw.bb96, %sw.bb91, %sw.bb86, %sw.bb81, %sw.bb76, %sw.bb71, %sw.bb65, %sw.bb59, %sw.bb53, %sw.bb48, %sw.bb43, %sw.bb38, %sw.bb32, %sw.bb26, %sw.bb20, %sw.bb15, %sw.bb10, %sw.bb6, %sw.bb5, %sw.bb3, %sw.bb2, %sw.bb1
  %retval.0 = phi i64 [ %conv136, %sw.bb134 ], [ %conv133, %sw.bb131 ], [ %shr.i302, %sw.bb128 ], [ %conv127, %sw.bb125 ], [ %conv124, %sw.bb122 ], [ %and, %sw.bb1 ], [ %src1, %sw.bb2 ], [ %conv4, %sw.bb3 ], [ %dst, %sw.bb5 ], [ %conv9, %sw.bb6 ], [ %conv14, %sw.bb10 ], [ %conv19, %sw.bb15 ], [ %conv25, %sw.bb20 ], [ %conv31, %sw.bb26 ], [ %conv37, %sw.bb32 ], [ %conv42, %sw.bb38 ], [ %conv47, %sw.bb43 ], [ %conv52, %sw.bb48 ], [ %conv58, %sw.bb53 ], [ %conv64, %sw.bb59 ], [ %conv70, %sw.bb65 ], [ %shr.i, %sw.bb71 ], [ %shr.i265, %sw.bb76 ], [ %conv85, %sw.bb81 ], [ %conv90, %sw.bb86 ], [ %conv95, %sw.bb91 ], [ %conv100, %sw.bb96 ], [ %conv105, %sw.bb101 ], [ %conv110, %sw.bb106 ], [ %conv115, %sw.bb111 ], [ %conv118, %sw.bb116 ], [ %conv121, %sw.bb119 ], [ 0, %entry ]
  ret i64 %retval.0
}

; Function Attrs: nounwind
declare qemuaot void @Fx55aa(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, ptr align 8 dereferenceable(26528)) #2 section ".text.Fx55aa"

attributes #0 = { noinline nounwind "target-features"="+neon" }
attributes #1 = { alwaysinline nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-a15" "target-features"="+aes,+bf16,+bti,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fpac,+fullfp16,+i8mm,+jsconv,+lse,+neon,+outline-atomics,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8.6a,+v8a,-fmv" }
attributes #2 = { nounwind "target-features"="+neon" }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1, !2, !3}

!0 = !{!"clang version 21.0.0git (git@github.com:orcguru/llvm-project.git aac6dfaa883a699dfc57db3d2518fbdf809bc6ae)"}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"frame-pointer", i32 1}
!4 = !{!5, !5, i64 0}
!5 = !{!"SpillSlo", !6}
!6 = !{!"Root"}
!7 = !{!"[0] ld_vec v128,e8,[t0],v10"}
!8 = !{!"[1] func_addr t3,helper_cc_compute_c"}
!9 = !{!"[2] call_qemuaot t3,[t0],cc_dst,cc_src,cc_src2(env),cc_op VEC_ARGS:"}
!10 = !{!11, !11, i64 0}
!11 = !{!"CPUState", !6}
!12 = !{!"[3] mov_i64 [t1],t0"}
!13 = !{!"[4] func_addr t2,0x55aa,0x0"}
!14 = !{!"[5] tail_call_qemuaot t2 VEC_ARGS:"}
