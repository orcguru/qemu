; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "riscv64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr align 8 dereferenceable(26544) %cpu) #0 section ".text.Fx0" {
entry:
  %cc_src.stack = alloca i64, align 8
  store i64 %cc_src, ptr %cc_src.stack, align 8, !tbaa !7
  %cc_dst.stack = alloca i64, align 8
  store i64 %cc_dst, ptr %cc_dst.stack, align 8, !tbaa !7
  %cc_op.stack = alloca i32, align 8
  store i32 %cc_op, ptr %cc_op.stack, align 8, !tbaa !7
  %v10.stack = alloca <vscale x 1 x i64>, align 16
  store <vscale x 1 x i64> %xmm5, ptr %v10.stack, align 16, !tbaa !7
  %tmp0.stack = alloca <vscale x 1 x i64>, align 16
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca ptr, align 8
  %tmp3.stack = alloca ptr, align 8
  %env = getelementptr i8, ptr %cpu, i64 11488
; ======== TCG [0] ld_vec v128,e8,[t0],v10 ========
  %T0.v10 = load <vscale x 8 x i8>, ptr %v10.stack, align 16, !tbaa !7, !tcg.op !10
  store <vscale x 8 x i8> %T0.v10, ptr %tmp0.stack, align 16, !tbaa !7, !tcg.op !10
; ======== TCG [1] func_addr t3,helper_cc_compute_c ========
  store ptr @helper_cc_compute_c, ptr %tmp3.stack, align 8, !tbaa !7, !tcg.op !11
; ======== TCG [2] call_qemuaot t3,[t0],cc_dst,cc_src,cc_src2(env),cc_op VEC_ARGS: ========
  %T2.cc_src.stack = load i64, ptr %cc_src.stack, align 8, !tbaa !7, !tcg.op !12
  %T2.cc_dst.stack = load i64, ptr %cc_dst.stack, align 8, !tbaa !7, !tcg.op !12
  %T2.cc_op.stack = load i32, ptr %cc_op.stack, align 8, !tbaa !7, !tcg.op !12
  %T2.v10.stack = load <vscale x 1 x i64>, ptr %v10.stack, align 16, !tbaa !7, !tcg.op !12
  %T2.cc_dst = load i64, ptr %cc_dst.stack, align 8, !tbaa !7, !tcg.op !12
  %T2.cc_src = load i64, ptr %cc_src.stack, align 8, !tbaa !7, !tcg.op !12
  %T2.envptr = getelementptr i8, ptr %env, i64 160, !tcg.op !12
  %T2.cc_src2 = load i64, ptr %T2.envptr, align 16, !tbaa !13, !tcg.op !12
  %T2.cc_op = load i32, ptr %cc_op.stack, align 8, !tbaa !7, !tcg.op !12
  %T2.loaded_fn = load ptr, ptr %tmp3.stack, align 8, !tcg.op !12
  %T2.cr = call qemuaot i64 %T2.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %T2.cc_src.stack, i64 %T2.cc_dst.stack, i32 %T2.cc_op.stack, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %T2.v10.stack, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr %cpu, i64 %T2.cc_dst, i64 %T2.cc_src, i64 %T2.cc_src2, i32 %T2.cc_op), !tcg.op !12
  store i64 %T2.cr, ptr %tmp0.stack, align 16, !tbaa !7, !tcg.op !12
; ======== TCG [3] mov_i64 [t1],t0 ========
  %T3.tmp0 = load i64, ptr %tmp0.stack, align 16, !tbaa !7, !tcg.op !15
  store i64 %T3.tmp0, ptr %tmp1.stack, align 8, !tbaa !7, !tcg.op !15
; ======== TCG [4] func_addr t2,0x55aa,0x0 ========
  store ptr @Fx55aa, ptr %tmp2.stack, align 8, !tbaa !7, !tcg.op !16
; ======== TCG [5] tail_call_qemuaot t2 VEC_ARGS: ========
  %T5.cc_src.stack = load i64, ptr %cc_src.stack, align 8, !tbaa !7, !tcg.op !17
  %T5.cc_dst.stack = load i64, ptr %cc_dst.stack, align 8, !tbaa !7, !tcg.op !17
  %T5.cc_op.stack = load i32, ptr %cc_op.stack, align 8, !tbaa !7, !tcg.op !17
  %T5.v10.stack = load <vscale x 1 x i64>, ptr %v10.stack, align 16, !tbaa !7, !tcg.op !17
  %T5.loaded_fn = load ptr, ptr %tmp2.stack, align 8, !tcg.op !17
  tail call qemuaot void %T5.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %T5.cc_src.stack, i64 %T5.cc_dst.stack, i32 %T5.cc_op.stack, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %T5.v10.stack, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr %cpu), !tcg.op !17
  ret void, !tcg.op !17
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_addb(i8 noundef zeroext %dst, i8 noundef zeroext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ult i8 %dst, %src1
  %conv2 = zext i1 %cmp to i32
  ret i32 %conv2
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_adcb(i8 noundef zeroext %dst, i8 noundef zeroext %src1, i8 noundef zeroext %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %conv = zext i8 %src1 to i32
  %conv1 = zext i8 %src3 to i32
  %add = add nuw nsw i32 %conv1, %conv
  %conv2 = zext i8 %dst to i32
  %cmp = icmp samesign ugt i32 %add, %conv2
  %conv3 = zext i1 %cmp to i32
  ret i32 %conv3
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_subb(i8 noundef zeroext %dst, i8 noundef zeroext %src2, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = xor i8 %src2, -1
  %cmp = icmp ugt i8 %dst, %0
  %conv5 = zext i1 %cmp to i32
  ret i32 %conv5
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_sbbb(i8 noundef zeroext %dst, i8 noundef zeroext %src2, i8 noundef zeroext %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
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

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_shlb(i8 noundef zeroext %dst, i8 noundef zeroext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = lshr i8 %src1, 7
  %shr = zext nneg i8 %0 to i32
  ret i32 %shr
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_bmilgb(i8 noundef zeroext %dst, i8 noundef zeroext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp eq i8 %src1, 0
  %conv1 = zext i1 %cmp to i32
  ret i32 %conv1
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_blsib(i8 noundef zeroext %dst, i8 noundef zeroext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ne i8 %src1, 0
  %conv1 = zext i1 %cmp to i32
  ret i32 %conv1
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_addw(i16 noundef zeroext %dst, i16 noundef zeroext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ult i16 %dst, %src1
  %conv2 = zext i1 %cmp to i32
  ret i32 %conv2
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_adcw(i16 noundef zeroext %dst, i16 noundef zeroext %src1, i16 noundef zeroext %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %conv = zext i16 %src1 to i32
  %conv1 = zext i16 %src3 to i32
  %add = add nuw nsw i32 %conv1, %conv
  %conv2 = zext i16 %dst to i32
  %cmp = icmp samesign ugt i32 %add, %conv2
  %conv3 = zext i1 %cmp to i32
  ret i32 %conv3
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_subw(i16 noundef zeroext %dst, i16 noundef zeroext %src2, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = xor i16 %src2, -1
  %cmp = icmp ugt i16 %dst, %0
  %conv5 = zext i1 %cmp to i32
  ret i32 %conv5
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_sbbw(i16 noundef zeroext %dst, i16 noundef zeroext %src2, i16 noundef zeroext %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
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

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_shlw(i16 noundef zeroext %dst, i16 noundef zeroext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = lshr i16 %src1, 15
  %shr = zext nneg i16 %0 to i32
  ret i32 %shr
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_bmilgw(i16 noundef zeroext %dst, i16 noundef zeroext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp eq i16 %src1, 0
  %conv1 = zext i1 %cmp to i32
  ret i32 %conv1
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_blsiw(i16 noundef zeroext %dst, i16 noundef zeroext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ne i16 %src1, 0
  %conv1 = zext i1 %cmp to i32
  ret i32 %conv1
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_addl(i32 noundef signext %dst, i32 noundef signext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ult i32 %dst, %src1
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_adcl(i32 noundef signext %dst, i32 noundef signext %src1, i32 noundef signext %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %conv = zext i32 %src1 to i64
  %conv1 = zext i32 %src3 to i64
  %add = add nuw nsw i64 %conv1, %conv
  %conv2 = zext i32 %dst to i64
  %cmp = icmp samesign ugt i64 %add, %conv2
  %conv3 = zext i1 %cmp to i32
  ret i32 %conv3
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_subl(i32 noundef signext %dst, i32 noundef signext %src2, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = xor i32 %src2, -1
  %cmp = icmp ugt i32 %dst, %0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_sbbl(i32 noundef signext %dst, i32 noundef signext %src2, i32 noundef signext %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
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

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_shll(i32 noundef signext %dst, i32 noundef signext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %shr = lshr i32 %src1, 31
  ret i32 %shr
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_bmilgl(i32 noundef signext %dst, i32 noundef signext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp eq i32 %src1, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_blsil(i32 noundef signext %dst, i32 noundef signext %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ne i32 %src1, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_addq(i64 noundef %dst, i64 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ult i64 %dst, %src1
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_adcq(i64 noundef %dst, i64 noundef %src1, i64 noundef %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %tobool.not = icmp eq i64 %src3, 0
  %cmp = icmp ule i64 %dst, %src1
  %cmp1 = icmp ult i64 %dst, %src1
  %cond.in = select i1 %tobool.not, i1 %cmp1, i1 %cmp
  %cond = zext i1 %cond.in to i32
  ret i32 %cond
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_subq(i64 noundef %dst, i64 noundef %src2, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %0 = xor i64 %src2, -1
  %cmp = icmp ugt i64 %dst, %0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_sbbq(i64 noundef %dst, i64 noundef %src2, i64 noundef %src3, ptr noundef %cpu_param) local_unnamed_addr #1 {
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

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_shlq(i64 noundef %dst, i64 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %shr = lshr i64 %src1, 63
  %conv = trunc nuw nsw i64 %shr to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_bmilgq(i64 noundef %dst, i64 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp eq i64 %src1, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot signext i32 @compute_c_blsiq(i64 noundef %dst, i64 noundef %src1, ptr noundef %cpu_param) local_unnamed_addr #1 {
entry:
  %cmp = icmp ne i64 %src1, 0
  %conv = zext i1 %cmp to i32
  ret i32 %conv
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot i64 @helper_cc_compute_c(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %qemuaot_src1, i64 noundef %qemuaot_dst, i32 noundef signext %qemuaot_op, i64 noundef %rip, <vscale x 1 x i64> noundef %xmm0.coerce, <vscale x 1 x i64> noundef %ymm0_h.coerce, <vscale x 1 x i64> noundef %xmm1.coerce, <vscale x 1 x i64> noundef %ymm1_h.coerce, <vscale x 1 x i64> noundef %xmm2.coerce, <vscale x 1 x i64> noundef %ymm2_h.coerce, <vscale x 1 x i64> noundef %xmm3.coerce, <vscale x 1 x i64> noundef %ymm3_h.coerce, <vscale x 1 x i64> noundef %xmm4.coerce, <vscale x 1 x i64> noundef %ymm4_h.coerce, <vscale x 1 x i64> noundef %xmm5.coerce, <vscale x 1 x i64> noundef %ymm5_h.coerce, <vscale x 1 x i64> noundef %xmm6.coerce, <vscale x 1 x i64> noundef %ymm6_h.coerce, <vscale x 1 x i64> noundef %xmm7.coerce, <vscale x 1 x i64> noundef %ymm7_h.coerce, <vscale x 1 x i64> noundef %xmm8.coerce, <vscale x 1 x i64> noundef %ymm8_h.coerce, <vscale x 1 x i64> noundef %xmm9.coerce, <vscale x 1 x i64> noundef %ymm9_h.coerce, <vscale x 1 x i64> noundef %xmm10.coerce, <vscale x 1 x i64> noundef %ymm10_h.coerce, <vscale x 1 x i64> noundef %xmm11.coerce, <vscale x 1 x i64> noundef %ymm11_h.coerce, <vscale x 1 x i64> noundef %xmm12.coerce, <vscale x 1 x i64> noundef %ymm12_h.coerce, <vscale x 1 x i64> noundef %xmm13.coerce, <vscale x 1 x i64> noundef %ymm13_h.coerce, ptr noundef %cpu_param, i64 noundef %dst, i64 noundef %src1, i64 noundef %src2, i32 noundef signext %op, i64 noundef %normal_return) local_unnamed_addr #1 {
entry:
  switch i32 %op, label %cleanup [
    i32 51, label %sw.bb161
    i32 47, label %sw.bb158
    i32 39, label %sw.bb155
    i32 23, label %sw.bb152
    i32 19, label %sw.bb149
    i32 0, label %sw.bb28
    i32 40, label %sw.bb28
    i32 41, label %sw.bb28
    i32 42, label %sw.bb28
    i32 43, label %sw.bb28
    i32 2, label %sw.bb28
    i32 28, label %sw.bb29
    i32 29, label %sw.bb29
    i32 30, label %sw.bb29
    i32 31, label %sw.bb29
    i32 32, label %sw.bb29
    i32 33, label %sw.bb29
    i32 34, label %sw.bb29
    i32 35, label %sw.bb29
    i32 4, label %sw.bb30
    i32 5, label %sw.bb30
    i32 6, label %sw.bb30
    i32 7, label %sw.bb30
    i32 1, label %sw.bb32
    i32 3, label %sw.bb32
    i32 8, label %sw.bb33
    i32 9, label %sw.bb37
    i32 10, label %sw.bb42
    i32 12, label %sw.bb47
    i32 13, label %sw.bb53
    i32 14, label %sw.bb59
    i32 16, label %sw.bb65
    i32 17, label %sw.bb70
    i32 18, label %sw.bb75
    i32 20, label %sw.bb80
    i32 21, label %sw.bb86
    i32 22, label %sw.bb92
    i32 36, label %sw.bb98
    i32 37, label %sw.bb103
    i32 38, label %sw.bb108
    i32 44, label %sw.bb113
    i32 45, label %sw.bb118
    i32 46, label %sw.bb123
    i32 48, label %sw.bb128
    i32 49, label %sw.bb133
    i32 50, label %sw.bb138
    i32 11, label %sw.bb143
    i32 15, label %sw.bb146
  ]

sw.bb28:                                          ; preds = %entry, %entry, %entry, %entry, %entry, %entry
  %and = and i64 %src1, 1
  br label %cleanup

sw.bb29:                                          ; preds = %entry, %entry, %entry, %entry, %entry, %entry, %entry, %entry
  br label %cleanup

sw.bb30:                                          ; preds = %entry, %entry, %entry, %entry
  %cmp = icmp ne i64 %src1, 0
  %conv31 = zext i1 %cmp to i64
  br label %cleanup

sw.bb32:                                          ; preds = %entry, %entry
  br label %cleanup

sw.bb33:                                          ; preds = %entry
  %conv34 = trunc i64 %dst to i8
  %conv35 = trunc i64 %src1 to i8
  %cmp.i = icmp ult i8 %conv34, %conv35
  %conv36 = zext i1 %cmp.i to i64
  br label %cleanup

sw.bb37:                                          ; preds = %entry
  %conv38 = trunc i64 %dst to i16
  %conv39 = trunc i64 %src1 to i16
  %cmp.i275 = icmp ult i16 %conv38, %conv39
  %conv41 = zext i1 %cmp.i275 to i64
  br label %cleanup

sw.bb42:                                          ; preds = %entry
  %conv43 = trunc i64 %dst to i32
  %conv44 = trunc i64 %src1 to i32
  %cmp.i297 = icmp ult i32 %conv43, %conv44
  %conv46 = zext i1 %cmp.i297 to i64
  br label %cleanup

sw.bb47:                                          ; preds = %entry
  %conv48 = trunc i64 %dst to i32
  %conv49 = trunc i64 %src1 to i32
  %conv50 = trunc i64 %src2 to i32
  %conv.i = and i32 %conv49, 255
  %conv1.i = and i32 %conv50, 255
  %add.i = add nuw nsw i32 %conv1.i, %conv.i
  %conv2.i263 = and i32 %conv48, 255
  %cmp.i264 = icmp samesign ugt i32 %add.i, %conv2.i263
  %conv52 = zext i1 %cmp.i264 to i64
  br label %cleanup

sw.bb53:                                          ; preds = %entry
  %conv54 = trunc i64 %dst to i32
  %conv55 = trunc i64 %src1 to i32
  %conv56 = trunc i64 %src2 to i32
  %conv.i277 = and i32 %conv55, 65535
  %conv1.i278 = and i32 %conv56, 65535
  %add.i279 = add nuw nsw i32 %conv1.i278, %conv.i277
  %conv2.i280 = and i32 %conv54, 65535
  %cmp.i281 = icmp samesign ugt i32 %add.i279, %conv2.i280
  %conv58 = zext i1 %cmp.i281 to i64
  br label %cleanup

sw.bb59:                                          ; preds = %entry
  %conv.i299 = and i64 %src1, 4294967295
  %conv1.i300 = and i64 %src2, 4294967295
  %add.i301 = add nuw nsw i64 %conv1.i300, %conv.i299
  %conv2.i302 = and i64 %dst, 4294967295
  %cmp.i303 = icmp samesign ugt i64 %add.i301, %conv2.i302
  %conv64 = zext i1 %cmp.i303 to i64
  br label %cleanup

sw.bb65:                                          ; preds = %entry
  %conv66 = trunc i64 %dst to i8
  %conv67 = trunc i64 %src1 to i8
  %0 = xor i8 %conv67, -1
  %cmp.i265 = icmp ugt i8 %conv66, %0
  %conv69 = zext i1 %cmp.i265 to i64
  br label %cleanup

sw.bb70:                                          ; preds = %entry
  %conv71 = trunc i64 %dst to i16
  %conv72 = trunc i64 %src1 to i16
  %1 = xor i16 %conv72, -1
  %cmp.i283 = icmp ugt i16 %conv71, %1
  %conv74 = zext i1 %cmp.i283 to i64
  br label %cleanup

sw.bb75:                                          ; preds = %entry
  %conv76 = trunc i64 %dst to i32
  %conv77 = trunc i64 %src1 to i32
  %2 = xor i32 %conv77, -1
  %cmp.i305 = icmp ugt i32 %conv76, %2
  %conv79 = zext i1 %cmp.i305 to i64
  br label %cleanup

sw.bb80:                                          ; preds = %entry
  %conv81 = trunc i64 %dst to i32
  %conv82 = trunc i64 %src1 to i32
  %conv83 = trunc i64 %src2 to i32
  %conv.i266 = and i32 %conv82, 255
  %conv1.i267 = and i32 %conv83, 255
  %add.i268 = add nuw nsw i32 %conv1.i267, %conv.i266
  %conv4.i = add i32 %add.i268, %conv81
  %conv5.i269 = and i32 %conv4.i, 255
  %cmp.i270 = icmp samesign ugt i32 %add.i268, %conv5.i269
  %conv85 = zext i1 %cmp.i270 to i64
  br label %cleanup

sw.bb86:                                          ; preds = %entry
  %conv87 = trunc i64 %dst to i32
  %conv88 = trunc i64 %src1 to i32
  %conv89 = trunc i64 %src2 to i32
  %conv.i285 = and i32 %conv88, 65535
  %conv1.i286 = and i32 %conv89, 65535
  %add.i287 = add nuw nsw i32 %conv1.i286, %conv.i285
  %conv4.i288 = add i32 %add.i287, %conv87
  %conv5.i289 = and i32 %conv4.i288, 65535
  %cmp.i290 = icmp samesign ugt i32 %add.i287, %conv5.i289
  %conv91 = zext i1 %cmp.i290 to i64
  br label %cleanup

sw.bb92:                                          ; preds = %entry
  %conv.i307 = and i64 %src1, 4294967295
  %conv1.i308 = and i64 %src2, 4294967295
  %add.i309 = add nuw nsw i64 %conv1.i308, %conv.i307
  %conv4.i310 = add i64 %add.i309, %dst
  %conv5.i311 = and i64 %conv4.i310, 4294967295
  %cmp.i312 = icmp samesign ugt i64 %add.i309, %conv5.i311
  %conv97 = zext i1 %cmp.i312 to i64
  br label %cleanup

sw.bb98:                                          ; preds = %entry
  %3 = lshr i64 %src1, 7
  %shr.i = and i64 %3, 1
  br label %cleanup

sw.bb103:                                         ; preds = %entry
  %4 = lshr i64 %src1, 15
  %shr.i292 = and i64 %4, 1
  br label %cleanup

sw.bb108:                                         ; preds = %entry
  %shr.i314 = lshr i64 %src1, 31
  %conv112 = and i64 %shr.i314, 1
  br label %cleanup

sw.bb113:                                         ; preds = %entry
  %5 = and i64 %src1, 255
  %cmp.i271 = icmp eq i64 %5, 0
  %conv117 = zext i1 %cmp.i271 to i64
  br label %cleanup

sw.bb118:                                         ; preds = %entry
  %6 = and i64 %src1, 65535
  %cmp.i293 = icmp eq i64 %6, 0
  %conv122 = zext i1 %cmp.i293 to i64
  br label %cleanup

sw.bb123:                                         ; preds = %entry
  %7 = and i64 %src1, 4294967295
  %cmp.i315 = icmp eq i64 %7, 0
  %conv127 = zext i1 %cmp.i315 to i64
  br label %cleanup

sw.bb128:                                         ; preds = %entry
  %8 = and i64 %src1, 255
  %cmp.i273 = icmp ne i64 %8, 0
  %conv132 = zext i1 %cmp.i273 to i64
  br label %cleanup

sw.bb133:                                         ; preds = %entry
  %9 = and i64 %src1, 65535
  %cmp.i295 = icmp ne i64 %9, 0
  %conv137 = zext i1 %cmp.i295 to i64
  br label %cleanup

sw.bb138:                                         ; preds = %entry
  %10 = and i64 %src1, 4294967295
  %cmp.i317 = icmp ne i64 %10, 0
  %conv142 = zext i1 %cmp.i317 to i64
  br label %cleanup

sw.bb143:                                         ; preds = %entry
  %cmp.i319 = icmp ult i64 %dst, %src1
  %conv145 = zext i1 %cmp.i319 to i64
  br label %cleanup

sw.bb146:                                         ; preds = %entry
  %tobool.not.i = icmp eq i64 %src2, 0
  %cmp.i321 = icmp ule i64 %dst, %src1
  %cmp1.i = icmp ult i64 %dst, %src1
  %cond.in.i = select i1 %tobool.not.i, i1 %cmp1.i, i1 %cmp.i321
  %conv148 = zext i1 %cond.in.i to i64
  br label %cleanup

sw.bb149:                                         ; preds = %entry
  %11 = xor i64 %src1, -1
  %cmp.i322 = icmp ugt i64 %dst, %11
  %conv151 = zext i1 %cmp.i322 to i64
  br label %cleanup

sw.bb152:                                         ; preds = %entry
  %add.i324 = add i64 %src1, %dst
  %add1.i = add i64 %add.i324, %src2
  %tobool.not.i325 = icmp eq i64 %src2, 0
  %cmp.i326 = icmp ule i64 %add1.i, %src1
  %cmp2.i = icmp ult i64 %add1.i, %src1
  %cond.in.i327 = select i1 %tobool.not.i325, i1 %cmp2.i, i1 %cmp.i326
  %conv154 = zext i1 %cond.in.i327 to i64
  br label %cleanup

sw.bb155:                                         ; preds = %entry
  %shr.i329 = lshr i64 %src1, 63
  br label %cleanup

sw.bb158:                                         ; preds = %entry
  %cmp.i331 = icmp eq i64 %src1, 0
  %conv160 = zext i1 %cmp.i331 to i64
  br label %cleanup

sw.bb161:                                         ; preds = %entry
  %cmp.i333 = icmp ne i64 %src1, 0
  %conv163 = zext i1 %cmp.i333 to i64
  br label %cleanup

cleanup:                                          ; preds = %entry, %sw.bb161, %sw.bb158, %sw.bb155, %sw.bb152, %sw.bb149, %sw.bb146, %sw.bb143, %sw.bb138, %sw.bb133, %sw.bb128, %sw.bb123, %sw.bb118, %sw.bb113, %sw.bb108, %sw.bb103, %sw.bb98, %sw.bb92, %sw.bb86, %sw.bb80, %sw.bb75, %sw.bb70, %sw.bb65, %sw.bb59, %sw.bb53, %sw.bb47, %sw.bb42, %sw.bb37, %sw.bb33, %sw.bb32, %sw.bb30, %sw.bb29, %sw.bb28
  %retval.0 = phi i64 [ %conv163, %sw.bb161 ], [ %conv160, %sw.bb158 ], [ %shr.i329, %sw.bb155 ], [ %conv154, %sw.bb152 ], [ %conv151, %sw.bb149 ], [ %and, %sw.bb28 ], [ %src1, %sw.bb29 ], [ %conv31, %sw.bb30 ], [ %dst, %sw.bb32 ], [ %conv36, %sw.bb33 ], [ %conv41, %sw.bb37 ], [ %conv46, %sw.bb42 ], [ %conv52, %sw.bb47 ], [ %conv58, %sw.bb53 ], [ %conv64, %sw.bb59 ], [ %conv69, %sw.bb65 ], [ %conv74, %sw.bb70 ], [ %conv79, %sw.bb75 ], [ %conv85, %sw.bb80 ], [ %conv91, %sw.bb86 ], [ %conv97, %sw.bb92 ], [ %shr.i, %sw.bb98 ], [ %shr.i292, %sw.bb103 ], [ %conv112, %sw.bb108 ], [ %conv117, %sw.bb113 ], [ %conv122, %sw.bb118 ], [ %conv127, %sw.bb123 ], [ %conv132, %sw.bb128 ], [ %conv137, %sw.bb133 ], [ %conv142, %sw.bb138 ], [ %conv145, %sw.bb143 ], [ %conv148, %sw.bb146 ], [ 0, %entry ]
  ret i64 %retval.0
}

; Function Attrs: nounwind
declare qemuaot void @Fx55aa(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, ptr align 8 dereferenceable(26544)) #2 section ".text.Fx55aa"

attributes #0 = { noinline nounwind "target-features"="+m,+a,+f,+d,+v" }
attributes #1 = { alwaysinline nounwind vscale_range(2,1024) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv64" "target-features"="+64bit,+a,+d,+f,+m,+relax,+v,+zaamo,+zalrsc,+zicsr,+zmmul,+zve32f,+zve32x,+zve64d,+zve64f,+zve64x,+zvl128b,+zvl32b,+zvl64b,-b,-c,-e,-experimental-p,-experimental-smctr,-experimental-ssctr,-experimental-svukte,-experimental-xqccmp,-experimental-xqcia,-experimental-xqciac,-experimental-xqcibi,-experimental-xqcibm,-experimental-xqcicli,-experimental-xqcicm,-experimental-xqcics,-experimental-xqcicsr,-experimental-xqciint,-experimental-xqciio,-experimental-xqcilb,-experimental-xqcili,-experimental-xqcilia,-experimental-xqcilo,-experimental-xqcilsm,-experimental-xqcisim,-experimental-xqcisls,-experimental-xqcisync,-experimental-xrivosvisni,-experimental-xrivosvizip,-experimental-xsfmclic,-experimental-xsfsclic,-experimental-zalasr,-experimental-zicfilp,-experimental-zicfiss,-experimental-zvbc32e,-experimental-zvkgs,-experimental-zvqdotq,-h,-q,-sdext,-sdtrig,-sha,-shcounterenw,-shgatpa,-shlcofideleg,-shtvala,-shvsatpa,-shvstvala,-shvstvecd,-smaia,-smcdeleg,-smcntrpmf,-smcsrind,-smdbltrp,-smepmp,-smmpm,-smnpm,-smrnmi,-smstateen,-ssaia,-ssccfg,-ssccptr,-sscofpmf,-sscounterenw,-sscsrind,-ssdbltrp,-ssnpm,-sspm,-ssqosid,-ssstateen,-ssstrict,-sstc,-sstvala,-sstvecd,-ssu64xl,-supm,-svade,-svadu,-svbare,-svinval,-svnapot,-svpbmt,-svvptc,-xandesperf,-xandesvbfhcvt,-xandesvdot,-xandesvpackfph,-xandesvsintload,-xcvalu,-xcvbi,-xcvbitmanip,-xcvelw,-xcvmac,-xcvmem,-xcvsimd,-xmipscbop,-xmipscmov,-xmipslsp,-xsfcease,-xsfmm128t,-xsfmm16t,-xsfmm32a16f,-xsfmm32a32f,-xsfmm32a8f,-xsfmm32a8i,-xsfmm32t,-xsfmm64a64f,-xsfmm64t,-xsfmmbase,-xsfvcp,-xsfvfnrclipxfqf,-xsfvfwmaccqqq,-xsfvqmaccdod,-xsfvqmaccqoq,-xsifivecdiscarddlone,-xsifivecflushdlone,-xtheadba,-xtheadbb,-xtheadbs,-xtheadcmo,-xtheadcondmov,-xtheadfmemidx,-xtheadmac,-xtheadmemidx,-xtheadmempair,-xtheadsync,-xtheadvdot,-xventanacondops,-xwchc,-za128rs,-za64rs,-zabha,-zacas,-zama16b,-zawrs,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zca,-zcb,-zcd,-zce,-zcf,-zclsd,-zcmop,-zcmp,-zcmt,-zdinx,-zfa,-zfbfmin,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zic64b,-zicbom,-zicbop,-zicboz,-ziccamoa,-ziccamoc,-ziccif,-zicclsm,-ziccrse,-zicntr,-zicond,-zifencei,-zihintntl,-zihintpause,-zihpm,-zilsd,-zimop,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-ztso,-zvbb,-zvbc,-zvfbfmin,-zvfbfwma,-zvfh,-zvfhmin,-zvkb,-zvkg,-zvkn,-zvknc,-zvkned,-zvkng,-zvknha,-zvknhb,-zvks,-zvksc,-zvksed,-zvksg,-zvksh,-zvkt,-zvl1024b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl4096b,-zvl512b,-zvl65536b,-zvl8192b" }
attributes #2 = { nounwind "target-features"="+m,+a,+f,+d,+v" }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1, !2, !3, !5, !6}

!0 = !{!"<COMPILER_VERSION>"}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 1, !"target-abi", !"lp64d"}
!3 = !{i32 6, !"riscv-isa", !4}
!4 = !{!"rv64i2p1_m2p0_a2p1_f2p2_d2p2_v1p0_zicsr2p0_zmmul1p0_zaamo1p0_zalrsc1p0_zve32f1p0_zve32x1p0_zve64d1p0_zve64f1p0_zve64x1p0_zvl128b1p0_zvl32b1p0_zvl64b1p0"}
!5 = !{i32 8, !"PIC Level", i32 2}
!6 = !{i32 8, !"SmallDataLimit", i32 0}
!7 = !{!8, !8, i64 0}
!8 = !{!"SpillSlo", !9}
!9 = !{!"Root"}
!10 = !{!"[0] ld_vec v128,e8,[t0],v10"}
!11 = !{!"[1] func_addr t3,helper_cc_compute_c"}
!12 = !{!"[2] call_qemuaot t3,[t0],cc_dst,cc_src,cc_src2(env),cc_op VEC_ARGS:"}
!13 = !{!14, !14, i64 0}
!14 = !{!"CPUState", !9}
!15 = !{!"[3] mov_i64 [t1],t0"}
!16 = !{!"[4] func_addr t2,0x55aa,0x0"}
!17 = !{!"[5] tail_call_qemuaot t2 VEC_ARGS:"}
