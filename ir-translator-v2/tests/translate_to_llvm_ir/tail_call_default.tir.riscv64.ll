; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "riscv64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx55aa(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr align 8 dereferenceable(26544) %cpu) #0 section ".text.Fx55aa" {
entry:
  %rip.stack = alloca i64, align 8
  store i64 %rip, ptr %rip.stack, align 8, !tbaa !7
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca ptr, align 8
  %tmp4.stack = alloca ptr, align 8
  %tmp5.stack = alloca ptr, align 8
  %env = getelementptr i8, ptr %cpu, i64 11488
; ======== TCG [0] ld_i64 [t0],env:0xfffffffffffffff8 ========
  %T0.envptr = getelementptr i8, ptr %env, i64 -8, !tcg.op !10
  %T0.envval = load i64, ptr %T0.envptr, align 8, !tbaa !11, !tcg.op !10
  store i64 %T0.envval, ptr %tmp0.stack, align 8, !tbaa !7, !tcg.op !10
; ======== TCG [1] qemu_ld_i64 [t1],t0,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B ========
  %T1.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !7, !tcg.op !13
  %T1.tmp0.ptr = inttoptr i64 %T1.tmp0 to ptr, !tcg.op !13
  %T1.ld = load i64, ptr %T1.tmp0.ptr, align 8, !tbaa !14, !tcg.op !13
  store i64 %T1.ld, ptr %tmp1.stack, align 8, !tbaa !7, !tcg.op !13
; ======== TCG [2] add_i64 [t0],t0,0x8 ========
  %T2.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !7, !tcg.op !16
  %T2.out = add i64 %T2.tmp0, 8, !tcg.op !16
  store i64 %T2.out, ptr %tmp0.stack, align 8, !tbaa !7, !tcg.op !16
; ======== TCG [3] qemu_ld_i64 [t2],t0,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B ========
  %T3.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !7, !tcg.op !17
  %T3.tmp0.ptr = inttoptr i64 %T3.tmp0 to ptr, !tcg.op !17
  %T3.ld = load i64, ptr %T3.tmp0.ptr, align 8, !tbaa !14, !tcg.op !17
  store i64 %T3.ld, ptr %tmp2.stack, align 8, !tbaa !7, !tcg.op !17
; ======== TCG [4] add_i64 [t0],t0,0x8 ========
  %T4.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !7, !tcg.op !18
  %T4.out = add i64 %T4.tmp0, 8, !tcg.op !18
  store i64 %T4.out, ptr %tmp0.stack, align 8, !tbaa !7, !tcg.op !18
; ======== TCG [5] st_i64 t0,env:0xfffffffffffffff8 ========
  %T5.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !7, !tcg.op !19
  %T5.envptr = getelementptr i8, ptr %env, i64 -8, !tcg.op !19
  store i64 %T5.tmp0, ptr %T5.envptr, align 8, !tbaa !11, !tcg.op !19
; ======== TCG [6] brcond_i64 rip,t2,ne,L0 ========
  %T6.rip = load i64, ptr %rip.stack, align 8, !tbaa !7, !tcg.op !20
  %T6.tmp2 = load i64, ptr %tmp2.stack, align 8, !tbaa !7, !tcg.op !20
  %T6.bool = icmp ne i64 %T6.rip, %T6.tmp2, !tcg.op !20
  br i1 %T6.bool, label %bb_L0, label %bb_false, !tcg.op !20

bb_false:                                         ; preds = %entry
; ======== TCG [7] tail_call_qemuaot t1 VEC_ARGS: ========
  %T7.rip.stack = load i64, ptr %rip.stack, align 8, !tbaa !7, !tcg.op !21
  %T7.loaded_fn = load ptr, ptr %tmp1.stack, align 8, !tcg.op !21
  tail call qemuaot void %T7.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %T7.rip.stack, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr %cpu), !tcg.op !21
  ret void, !tcg.op !21

bb_L0:                                            ; preds = %entry
; ======== TCG [9] func_addr t3,helper_jmp_ind ========
  store ptr @helper_jmp_ind, ptr %tmp3.stack, align 8, !tbaa !7, !tcg.op !22
; ======== TCG [10] func_addr t4,jmp_ind_callback ========
  store ptr @jmp_ind_callback, ptr %tmp4.stack, align 8, !tbaa !7, !tcg.op !23
; ======== TCG [11] func_addr t5,0x55aa,0x1 ========
  store ptr @trampoline_helper_jit, ptr %tmp5.stack, align 8, !tbaa !7, !tcg.op !24
; ======== TCG [12] tail_call_qemuaot t3,env,rip,t5,t4 VEC_ARGS: ========
  %T12.rip.stack = load i64, ptr %rip.stack, align 8, !tbaa !7, !tcg.op !25
  %T12.env = ptrtoint ptr %env to i64, !tcg.op !25
  %T12.rip = load i64, ptr %rip.stack, align 8, !tbaa !7, !tcg.op !25
  %T12.tmp5 = load i64, ptr %tmp5.stack, align 8, !tbaa !7, !tcg.op !25
  %T12.tmp4 = load i64, ptr %tmp4.stack, align 8, !tbaa !7, !tcg.op !25
  %T12.loaded_fn = load ptr, ptr %tmp3.stack, align 8, !tcg.op !25
  tail call qemuaot void %T12.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %T12.rip.stack, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr %cpu, i64 %T12.env, i64 %T12.rip, i64 %T12.tmp5, i64 %T12.tmp4), !tcg.op !25
  ret void, !tcg.op !25
}

; Function Attrs: nounwind
declare qemuaot void @helper_jmp_ind(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, ptr, i64, i64, i64, i64) #1

; Function Attrs: nounwind vscale_range(2,1024)
define weak qemuaot void @jmp_ind_callback(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %src, i64 noundef %dst, i32 noundef signext %op, i64 noundef %rip, <vscale x 1 x i64> noundef %xmm0.coerce, <vscale x 1 x i64> noundef %ymm0_h.coerce, <vscale x 1 x i64> noundef %xmm1.coerce, <vscale x 1 x i64> noundef %ymm1_h.coerce, <vscale x 1 x i64> noundef %xmm2.coerce, <vscale x 1 x i64> noundef %ymm2_h.coerce, <vscale x 1 x i64> noundef %xmm3.coerce, <vscale x 1 x i64> noundef %ymm3_h.coerce, <vscale x 1 x i64> noundef %xmm4.coerce, <vscale x 1 x i64> noundef %ymm4_h.coerce, <vscale x 1 x i64> noundef %xmm5.coerce, <vscale x 1 x i64> noundef %ymm5_h.coerce, <vscale x 1 x i64> noundef %xmm6.coerce, <vscale x 1 x i64> noundef %ymm6_h.coerce, <vscale x 1 x i64> noundef %xmm7.coerce, <vscale x 1 x i64> noundef %ymm7_h.coerce, <vscale x 1 x i64> noundef %xmm8.coerce, <vscale x 1 x i64> noundef %ymm8_h.coerce, <vscale x 1 x i64> noundef %xmm9.coerce, <vscale x 1 x i64> noundef %ymm9_h.coerce, <vscale x 1 x i64> noundef %xmm10.coerce, <vscale x 1 x i64> noundef %ymm10_h.coerce, <vscale x 1 x i64> noundef %xmm11.coerce, <vscale x 1 x i64> noundef %ymm11_h.coerce, <vscale x 1 x i64> noundef %xmm12.coerce, <vscale x 1 x i64> noundef %ymm12_h.coerce, <vscale x 1 x i64> noundef %xmm13.coerce, <vscale x 1 x i64> noundef %ymm13_h.coerce, i64 noundef %cpu_param, i64 noundef %target_addr, i64 noundef %host_addr, i64 noundef %trampoline_helper_jit) local_unnamed_addr #2 {
entry:
  %tobool.not = icmp eq i64 %host_addr, 0
  br i1 %tobool.not, label %if.else, label %if.then

if.then:                                          ; preds = %entry
  %0 = inttoptr i64 %host_addr to ptr
  tail call qemuaot void %0(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %src, i64 noundef %dst, i32 noundef signext %op, i64 noundef %target_addr, <vscale x 1 x i64> noundef %xmm0.coerce, <vscale x 1 x i64> noundef %ymm0_h.coerce, <vscale x 1 x i64> noundef %xmm1.coerce, <vscale x 1 x i64> noundef %ymm1_h.coerce, <vscale x 1 x i64> noundef %xmm2.coerce, <vscale x 1 x i64> noundef %ymm2_h.coerce, <vscale x 1 x i64> noundef %xmm3.coerce, <vscale x 1 x i64> noundef %ymm3_h.coerce, <vscale x 1 x i64> noundef %xmm4.coerce, <vscale x 1 x i64> noundef %ymm4_h.coerce, <vscale x 1 x i64> noundef %xmm5.coerce, <vscale x 1 x i64> noundef %ymm5_h.coerce, <vscale x 1 x i64> noundef %xmm6.coerce, <vscale x 1 x i64> noundef %ymm6_h.coerce, <vscale x 1 x i64> noundef %xmm7.coerce, <vscale x 1 x i64> noundef %ymm7_h.coerce, <vscale x 1 x i64> noundef %xmm8.coerce, <vscale x 1 x i64> noundef %ymm8_h.coerce, <vscale x 1 x i64> noundef %xmm9.coerce, <vscale x 1 x i64> noundef %ymm9_h.coerce, <vscale x 1 x i64> noundef %xmm10.coerce, <vscale x 1 x i64> noundef %ymm10_h.coerce, <vscale x 1 x i64> noundef %xmm11.coerce, <vscale x 1 x i64> noundef %ymm11_h.coerce, <vscale x 1 x i64> noundef %xmm12.coerce, <vscale x 1 x i64> noundef %ymm12_h.coerce, <vscale x 1 x i64> noundef %xmm13.coerce, <vscale x 1 x i64> noundef %ymm13_h.coerce, i64 noundef %cpu_param) #4
  br label %return

if.else:                                          ; preds = %entry
  %1 = inttoptr i64 %trampoline_helper_jit to ptr
  %add = add i64 %cpu_param, 11488
  tail call qemuaot void %1(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %src, i64 noundef %dst, i32 noundef signext %op, i64 noundef %target_addr, <vscale x 1 x i64> noundef %xmm0.coerce, <vscale x 1 x i64> noundef %ymm0_h.coerce, <vscale x 1 x i64> noundef %xmm1.coerce, <vscale x 1 x i64> noundef %ymm1_h.coerce, <vscale x 1 x i64> noundef %xmm2.coerce, <vscale x 1 x i64> noundef %ymm2_h.coerce, <vscale x 1 x i64> noundef %xmm3.coerce, <vscale x 1 x i64> noundef %ymm3_h.coerce, <vscale x 1 x i64> noundef %xmm4.coerce, <vscale x 1 x i64> noundef %ymm4_h.coerce, <vscale x 1 x i64> noundef %xmm5.coerce, <vscale x 1 x i64> noundef %ymm5_h.coerce, <vscale x 1 x i64> noundef %xmm6.coerce, <vscale x 1 x i64> noundef %ymm6_h.coerce, <vscale x 1 x i64> noundef %xmm7.coerce, <vscale x 1 x i64> noundef %ymm7_h.coerce, <vscale x 1 x i64> noundef %xmm8.coerce, <vscale x 1 x i64> noundef %ymm8_h.coerce, <vscale x 1 x i64> noundef %xmm9.coerce, <vscale x 1 x i64> noundef %ymm9_h.coerce, <vscale x 1 x i64> noundef %xmm10.coerce, <vscale x 1 x i64> noundef %ymm10_h.coerce, <vscale x 1 x i64> noundef %xmm11.coerce, <vscale x 1 x i64> noundef %ymm11_h.coerce, <vscale x 1 x i64> noundef %xmm12.coerce, <vscale x 1 x i64> noundef %ymm12_h.coerce, <vscale x 1 x i64> noundef %xmm13.coerce, <vscale x 1 x i64> noundef %ymm13_h.coerce, i64 noundef %cpu_param, i64 noundef %add, i64 noundef %target_addr) #4
  br label %return

return:                                           ; preds = %if.else, %if.then
  ret void
}

; Function Attrs: noinline nounwind
define qemuaot void @trampoline_helper_jit(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr align 8 dereferenceable(26544) %cpu, i64 %arg0, i64 %arg1) #0 section ".text.trampoline_helper_jit" {
entry:
  %rip.stack = alloca i64, align 8
  store i64 %rip, ptr %rip.stack, align 8, !tbaa !7
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %env = getelementptr i8, ptr %cpu, i64 11488
; ======== TCG [0] st_i64 rax,env ========
  %T0.envptr = getelementptr i8, ptr %env, i64 0, !tcg.op !26
  store i64 %rax, ptr %T0.envptr, align 16, !tbaa !11, !tcg.op !26
; ======== TCG [1] st_i64 rcx,env:0x8 ========
  %T1.envptr = getelementptr i8, ptr %env, i64 8, !tcg.op !27
  store i64 %rcx, ptr %T1.envptr, align 8, !tbaa !11, !tcg.op !27
; ======== TCG [2] st_i64 rdx,env:0x10 ========
  %T2.envptr = getelementptr i8, ptr %env, i64 16, !tcg.op !28
  store i64 %rdx, ptr %T2.envptr, align 16, !tbaa !11, !tcg.op !28
; ======== TCG [3] st_i64 rbx,env:0x18 ========
  %T3.envptr = getelementptr i8, ptr %env, i64 24, !tcg.op !29
  store i64 %rbx, ptr %T3.envptr, align 8, !tbaa !11, !tcg.op !29
; ======== TCG [4] st_i64 rsp,env:0x20 ========
  %T4.envptr = getelementptr i8, ptr %env, i64 32, !tcg.op !30
  store i64 %rsp, ptr %T4.envptr, align 16, !tbaa !11, !tcg.op !30
; ======== TCG [5] st_i64 rbp,env:0x28 ========
  %T5.envptr = getelementptr i8, ptr %env, i64 40, !tcg.op !31
  store i64 %rbp, ptr %T5.envptr, align 8, !tbaa !11, !tcg.op !31
; ======== TCG [6] st_i64 rsi,env:0x30 ========
  %T6.envptr = getelementptr i8, ptr %env, i64 48, !tcg.op !32
  store i64 %rsi, ptr %T6.envptr, align 16, !tbaa !11, !tcg.op !32
; ======== TCG [7] st_i64 rdi,env:0x38 ========
  %T7.envptr = getelementptr i8, ptr %env, i64 56, !tcg.op !33
  store i64 %rdi, ptr %T7.envptr, align 8, !tbaa !11, !tcg.op !33
; ======== TCG [8] st_i64 r8,env:0x40 ========
  %T8.envptr = getelementptr i8, ptr %env, i64 64, !tcg.op !34
  store i64 %r8, ptr %T8.envptr, align 16, !tbaa !11, !tcg.op !34
; ======== TCG [9] st_i64 r9,env:0x48 ========
  %T9.envptr = getelementptr i8, ptr %env, i64 72, !tcg.op !35
  store i64 %r9, ptr %T9.envptr, align 8, !tbaa !11, !tcg.op !35
; ======== TCG [10] st_i64 r10,env:0x50 ========
  %T10.envptr = getelementptr i8, ptr %env, i64 80, !tcg.op !36
  store i64 %r10, ptr %T10.envptr, align 16, !tbaa !11, !tcg.op !36
; ======== TCG [11] st_i64 r11,env:0x58 ========
  %T11.envptr = getelementptr i8, ptr %env, i64 88, !tcg.op !37
  store i64 %r11, ptr %T11.envptr, align 8, !tbaa !11, !tcg.op !37
; ======== TCG [12] st_i64 r12,env:0x60 ========
  %T12.envptr = getelementptr i8, ptr %env, i64 96, !tcg.op !38
  store i64 %r12, ptr %T12.envptr, align 16, !tbaa !11, !tcg.op !38
; ======== TCG [13] st_i64 r13,env:0x68 ========
  %T13.envptr = getelementptr i8, ptr %env, i64 104, !tcg.op !39
  store i64 %r13, ptr %T13.envptr, align 8, !tbaa !11, !tcg.op !39
; ======== TCG [14] st_i64 r14,env:0x70 ========
  %T14.envptr = getelementptr i8, ptr %env, i64 112, !tcg.op !40
  store i64 %r14, ptr %T14.envptr, align 16, !tbaa !11, !tcg.op !40
; ======== TCG [15] st_i64 r15,env:0x78 ========
  %T15.envptr = getelementptr i8, ptr %env, i64 120, !tcg.op !41
  store i64 %r15, ptr %T15.envptr, align 8, !tbaa !11, !tcg.op !41
; ======== TCG [16] st_i64 cc_src,env:0x98 ========
  %T16.envptr = getelementptr i8, ptr %env, i64 152, !tcg.op !42
  store i64 %cc_src, ptr %T16.envptr, align 8, !tbaa !11, !tcg.op !42
; ======== TCG [17] st_i64 cc_dst,env:0x90 ========
  %T17.envptr = getelementptr i8, ptr %env, i64 144, !tcg.op !43
  store i64 %cc_dst, ptr %T17.envptr, align 16, !tbaa !11, !tcg.op !43
; ======== TCG [18] st_i32 cc_op,env:0xa8 ========
  %T18.envptr = getelementptr i8, ptr %env, i64 168, !tcg.op !44
  store i32 %cc_op, ptr %T18.envptr, align 8, !tbaa !11, !tcg.op !44
; ======== TCG [19] st_i64 rip,env:0x80 ========
  %T19.rip = load i64, ptr %rip.stack, align 8, !tbaa !7, !tcg.op !45
  %T19.envptr = getelementptr i8, ptr %env, i64 128, !tcg.op !45
  store i64 %T19.rip, ptr %T19.envptr, align 16, !tbaa !11, !tcg.op !45
; ======== TCG [20] st_vec v128,e8,v0,env:0x360 ========
  %T20.bc = bitcast <vscale x 1 x i64> %xmm0 to <vscale x 8 x i8>, !tcg.op !46
  %T20.envptr = getelementptr i8, ptr %env, i64 864, !tcg.op !46
  %T20.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T20.bc, i64 0), !tcg.op !46
  store <16 x i8> %T20.vector_extract, ptr %T20.envptr, align 16, !tbaa !11, !tcg.op !46
; ======== TCG [21] st_vec v128,e8,v1,env:0x370 ========
  %T21.bc = bitcast <vscale x 1 x i64> %ymm0_h to <vscale x 8 x i8>, !tcg.op !47
  %T21.envptr = getelementptr i8, ptr %env, i64 880, !tcg.op !47
  %T21.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T21.bc, i64 0), !tcg.op !47
  store <16 x i8> %T21.vector_extract, ptr %T21.envptr, align 16, !tbaa !11, !tcg.op !47
; ======== TCG [22] st_vec v128,e8,v2,env:0x3a0 ========
  %T22.bc = bitcast <vscale x 1 x i64> %xmm1 to <vscale x 8 x i8>, !tcg.op !48
  %T22.envptr = getelementptr i8, ptr %env, i64 928, !tcg.op !48
  %T22.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T22.bc, i64 0), !tcg.op !48
  store <16 x i8> %T22.vector_extract, ptr %T22.envptr, align 16, !tbaa !11, !tcg.op !48
; ======== TCG [23] st_vec v128,e8,v3,env:0x3b0 ========
  %T23.bc = bitcast <vscale x 1 x i64> %ymm1_h to <vscale x 8 x i8>, !tcg.op !49
  %T23.envptr = getelementptr i8, ptr %env, i64 944, !tcg.op !49
  %T23.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T23.bc, i64 0), !tcg.op !49
  store <16 x i8> %T23.vector_extract, ptr %T23.envptr, align 16, !tbaa !11, !tcg.op !49
; ======== TCG [24] st_vec v128,e8,v4,env:0x3e0 ========
  %T24.bc = bitcast <vscale x 1 x i64> %xmm2 to <vscale x 8 x i8>, !tcg.op !50
  %T24.envptr = getelementptr i8, ptr %env, i64 992, !tcg.op !50
  %T24.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T24.bc, i64 0), !tcg.op !50
  store <16 x i8> %T24.vector_extract, ptr %T24.envptr, align 16, !tbaa !11, !tcg.op !50
; ======== TCG [25] st_vec v128,e8,v5,env:0x3f0 ========
  %T25.bc = bitcast <vscale x 1 x i64> %ymm2_h to <vscale x 8 x i8>, !tcg.op !51
  %T25.envptr = getelementptr i8, ptr %env, i64 1008, !tcg.op !51
  %T25.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T25.bc, i64 0), !tcg.op !51
  store <16 x i8> %T25.vector_extract, ptr %T25.envptr, align 16, !tbaa !11, !tcg.op !51
; ======== TCG [26] st_vec v128,e8,v6,env:0x420 ========
  %T26.bc = bitcast <vscale x 1 x i64> %xmm3 to <vscale x 8 x i8>, !tcg.op !52
  %T26.envptr = getelementptr i8, ptr %env, i64 1056, !tcg.op !52
  %T26.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T26.bc, i64 0), !tcg.op !52
  store <16 x i8> %T26.vector_extract, ptr %T26.envptr, align 16, !tbaa !11, !tcg.op !52
; ======== TCG [27] st_vec v128,e8,v7,env:0x430 ========
  %T27.bc = bitcast <vscale x 1 x i64> %ymm3_h to <vscale x 8 x i8>, !tcg.op !53
  %T27.envptr = getelementptr i8, ptr %env, i64 1072, !tcg.op !53
  %T27.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T27.bc, i64 0), !tcg.op !53
  store <16 x i8> %T27.vector_extract, ptr %T27.envptr, align 16, !tbaa !11, !tcg.op !53
; ======== TCG [28] st_vec v128,e8,v8,env:0x460 ========
  %T28.bc = bitcast <vscale x 1 x i64> %xmm4 to <vscale x 8 x i8>, !tcg.op !54
  %T28.envptr = getelementptr i8, ptr %env, i64 1120, !tcg.op !54
  %T28.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T28.bc, i64 0), !tcg.op !54
  store <16 x i8> %T28.vector_extract, ptr %T28.envptr, align 16, !tbaa !11, !tcg.op !54
; ======== TCG [29] st_vec v128,e8,v9,env:0x470 ========
  %T29.bc = bitcast <vscale x 1 x i64> %ymm4_h to <vscale x 8 x i8>, !tcg.op !55
  %T29.envptr = getelementptr i8, ptr %env, i64 1136, !tcg.op !55
  %T29.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T29.bc, i64 0), !tcg.op !55
  store <16 x i8> %T29.vector_extract, ptr %T29.envptr, align 16, !tbaa !11, !tcg.op !55
; ======== TCG [30] st_vec v128,e8,v10,env:0x4a0 ========
  %T30.bc = bitcast <vscale x 1 x i64> %xmm5 to <vscale x 8 x i8>, !tcg.op !56
  %T30.envptr = getelementptr i8, ptr %env, i64 1184, !tcg.op !56
  %T30.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T30.bc, i64 0), !tcg.op !56
  store <16 x i8> %T30.vector_extract, ptr %T30.envptr, align 16, !tbaa !11, !tcg.op !56
; ======== TCG [31] st_vec v128,e8,v11,env:0x4b0 ========
  %T31.bc = bitcast <vscale x 1 x i64> %ymm5_h to <vscale x 8 x i8>, !tcg.op !57
  %T31.envptr = getelementptr i8, ptr %env, i64 1200, !tcg.op !57
  %T31.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T31.bc, i64 0), !tcg.op !57
  store <16 x i8> %T31.vector_extract, ptr %T31.envptr, align 16, !tbaa !11, !tcg.op !57
; ======== TCG [32] st_vec v128,e8,v12,env:0x4e0 ========
  %T32.bc = bitcast <vscale x 1 x i64> %xmm6 to <vscale x 8 x i8>, !tcg.op !58
  %T32.envptr = getelementptr i8, ptr %env, i64 1248, !tcg.op !58
  %T32.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T32.bc, i64 0), !tcg.op !58
  store <16 x i8> %T32.vector_extract, ptr %T32.envptr, align 16, !tbaa !11, !tcg.op !58
; ======== TCG [33] st_vec v128,e8,v13,env:0x4f0 ========
  %T33.bc = bitcast <vscale x 1 x i64> %ymm6_h to <vscale x 8 x i8>, !tcg.op !59
  %T33.envptr = getelementptr i8, ptr %env, i64 1264, !tcg.op !59
  %T33.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T33.bc, i64 0), !tcg.op !59
  store <16 x i8> %T33.vector_extract, ptr %T33.envptr, align 16, !tbaa !11, !tcg.op !59
; ======== TCG [34] st_vec v128,e8,v14,env:0x520 ========
  %T34.bc = bitcast <vscale x 1 x i64> %xmm7 to <vscale x 8 x i8>, !tcg.op !60
  %T34.envptr = getelementptr i8, ptr %env, i64 1312, !tcg.op !60
  %T34.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T34.bc, i64 0), !tcg.op !60
  store <16 x i8> %T34.vector_extract, ptr %T34.envptr, align 16, !tbaa !11, !tcg.op !60
; ======== TCG [35] st_vec v128,e8,v15,env:0x530 ========
  %T35.bc = bitcast <vscale x 1 x i64> %ymm7_h to <vscale x 8 x i8>, !tcg.op !61
  %T35.envptr = getelementptr i8, ptr %env, i64 1328, !tcg.op !61
  %T35.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T35.bc, i64 0), !tcg.op !61
  store <16 x i8> %T35.vector_extract, ptr %T35.envptr, align 16, !tbaa !11, !tcg.op !61
; ======== TCG [36] st_vec v128,e8,v16,env:0x560 ========
  %T36.bc = bitcast <vscale x 1 x i64> %xmm8 to <vscale x 8 x i8>, !tcg.op !62
  %T36.envptr = getelementptr i8, ptr %env, i64 1376, !tcg.op !62
  %T36.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T36.bc, i64 0), !tcg.op !62
  store <16 x i8> %T36.vector_extract, ptr %T36.envptr, align 16, !tbaa !11, !tcg.op !62
; ======== TCG [37] st_vec v128,e8,v17,env:0x570 ========
  %T37.bc = bitcast <vscale x 1 x i64> %ymm8_h to <vscale x 8 x i8>, !tcg.op !63
  %T37.envptr = getelementptr i8, ptr %env, i64 1392, !tcg.op !63
  %T37.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T37.bc, i64 0), !tcg.op !63
  store <16 x i8> %T37.vector_extract, ptr %T37.envptr, align 16, !tbaa !11, !tcg.op !63
; ======== TCG [38] st_vec v128,e8,v18,env:0x5a0 ========
  %T38.bc = bitcast <vscale x 1 x i64> %xmm9 to <vscale x 8 x i8>, !tcg.op !64
  %T38.envptr = getelementptr i8, ptr %env, i64 1440, !tcg.op !64
  %T38.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T38.bc, i64 0), !tcg.op !64
  store <16 x i8> %T38.vector_extract, ptr %T38.envptr, align 16, !tbaa !11, !tcg.op !64
; ======== TCG [39] st_vec v128,e8,v19,env:0x5b0 ========
  %T39.bc = bitcast <vscale x 1 x i64> %ymm9_h to <vscale x 8 x i8>, !tcg.op !65
  %T39.envptr = getelementptr i8, ptr %env, i64 1456, !tcg.op !65
  %T39.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T39.bc, i64 0), !tcg.op !65
  store <16 x i8> %T39.vector_extract, ptr %T39.envptr, align 16, !tbaa !11, !tcg.op !65
; ======== TCG [40] st_vec v128,e8,v20,env:0x5e0 ========
  %T40.bc = bitcast <vscale x 1 x i64> %xmm10 to <vscale x 8 x i8>, !tcg.op !66
  %T40.envptr = getelementptr i8, ptr %env, i64 1504, !tcg.op !66
  %T40.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T40.bc, i64 0), !tcg.op !66
  store <16 x i8> %T40.vector_extract, ptr %T40.envptr, align 16, !tbaa !11, !tcg.op !66
; ======== TCG [41] st_vec v128,e8,v21,env:0x5f0 ========
  %T41.bc = bitcast <vscale x 1 x i64> %ymm10_h to <vscale x 8 x i8>, !tcg.op !67
  %T41.envptr = getelementptr i8, ptr %env, i64 1520, !tcg.op !67
  %T41.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T41.bc, i64 0), !tcg.op !67
  store <16 x i8> %T41.vector_extract, ptr %T41.envptr, align 16, !tbaa !11, !tcg.op !67
; ======== TCG [42] st_vec v128,e8,v22,env:0x620 ========
  %T42.bc = bitcast <vscale x 1 x i64> %xmm11 to <vscale x 8 x i8>, !tcg.op !68
  %T42.envptr = getelementptr i8, ptr %env, i64 1568, !tcg.op !68
  %T42.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T42.bc, i64 0), !tcg.op !68
  store <16 x i8> %T42.vector_extract, ptr %T42.envptr, align 16, !tbaa !11, !tcg.op !68
; ======== TCG [43] st_vec v128,e8,v23,env:0x630 ========
  %T43.bc = bitcast <vscale x 1 x i64> %ymm11_h to <vscale x 8 x i8>, !tcg.op !69
  %T43.envptr = getelementptr i8, ptr %env, i64 1584, !tcg.op !69
  %T43.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T43.bc, i64 0), !tcg.op !69
  store <16 x i8> %T43.vector_extract, ptr %T43.envptr, align 16, !tbaa !11, !tcg.op !69
; ======== TCG [44] st_vec v128,e8,v24,env:0x660 ========
  %T44.bc = bitcast <vscale x 1 x i64> %xmm12 to <vscale x 8 x i8>, !tcg.op !70
  %T44.envptr = getelementptr i8, ptr %env, i64 1632, !tcg.op !70
  %T44.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T44.bc, i64 0), !tcg.op !70
  store <16 x i8> %T44.vector_extract, ptr %T44.envptr, align 16, !tbaa !11, !tcg.op !70
; ======== TCG [45] st_vec v128,e8,v25,env:0x670 ========
  %T45.bc = bitcast <vscale x 1 x i64> %ymm12_h to <vscale x 8 x i8>, !tcg.op !71
  %T45.envptr = getelementptr i8, ptr %env, i64 1648, !tcg.op !71
  %T45.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T45.bc, i64 0), !tcg.op !71
  store <16 x i8> %T45.vector_extract, ptr %T45.envptr, align 16, !tbaa !11, !tcg.op !71
; ======== TCG [46] st_vec v128,e8,v26,env:0x6a0 ========
  %T46.bc = bitcast <vscale x 1 x i64> %xmm13 to <vscale x 8 x i8>, !tcg.op !72
  %T46.envptr = getelementptr i8, ptr %env, i64 1696, !tcg.op !72
  %T46.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T46.bc, i64 0), !tcg.op !72
  store <16 x i8> %T46.vector_extract, ptr %T46.envptr, align 16, !tbaa !11, !tcg.op !72
; ======== TCG [47] st_vec v128,e8,v27,env:0x6b0 ========
  %T47.bc = bitcast <vscale x 1 x i64> %ymm13_h to <vscale x 8 x i8>, !tcg.op !73
  %T47.envptr = getelementptr i8, ptr %env, i64 1712, !tcg.op !73
  %T47.vector_extract = call <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8> %T47.bc, i64 0), !tcg.op !73
  store <16 x i8> %T47.vector_extract, ptr %T47.envptr, align 16, !tbaa !11, !tcg.op !73
; ======== TCG [48] tail_call_default helper_jit,arg0,arg1 ========
  %T48.env = ptrtoint ptr %env to i64, !tcg.op !74
  call void asm "mv x7, $0", "r,~{x7}"(i64 %T48.env), !tcg.op !74
  tail call void @helper_jit(i64 %arg0, i64 %arg1), !tcg.op !74
  ret void, !tcg.op !74
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <16 x i8> @llvm.vector.extract.v16i8.nxv8i8.i64(<vscale x 8 x i8>, i64 immarg) #3

declare void @helper_jit(i64, i64)

attributes #0 = { noinline nounwind "target-features"="+m,+a,+f,+d,+v" }
attributes #1 = { nounwind "target-features"="+m,+a,+f,+d,+v" }
attributes #2 = { nounwind vscale_range(2,1024) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv64" "target-features"="+64bit,+a,+d,+f,+m,+relax,+v,+zaamo,+zalrsc,+zicsr,+zmmul,+zve32f,+zve32x,+zve64d,+zve64f,+zve64x,+zvl128b,+zvl32b,+zvl64b,-b,-c,-e,-experimental-p,-experimental-smctr,-experimental-ssctr,-experimental-svukte,-experimental-xqccmp,-experimental-xqcia,-experimental-xqciac,-experimental-xqcibi,-experimental-xqcibm,-experimental-xqcicli,-experimental-xqcicm,-experimental-xqcics,-experimental-xqcicsr,-experimental-xqciint,-experimental-xqciio,-experimental-xqcilb,-experimental-xqcili,-experimental-xqcilia,-experimental-xqcilo,-experimental-xqcilsm,-experimental-xqcisim,-experimental-xqcisls,-experimental-xqcisync,-experimental-xrivosvisni,-experimental-xrivosvizip,-experimental-xsfmclic,-experimental-xsfsclic,-experimental-zalasr,-experimental-zicfilp,-experimental-zicfiss,-experimental-zvbc32e,-experimental-zvkgs,-experimental-zvqdotq,-h,-q,-sdext,-sdtrig,-sha,-shcounterenw,-shgatpa,-shlcofideleg,-shtvala,-shvsatpa,-shvstvala,-shvstvecd,-smaia,-smcdeleg,-smcntrpmf,-smcsrind,-smdbltrp,-smepmp,-smmpm,-smnpm,-smrnmi,-smstateen,-ssaia,-ssccfg,-ssccptr,-sscofpmf,-sscounterenw,-sscsrind,-ssdbltrp,-ssnpm,-sspm,-ssqosid,-ssstateen,-ssstrict,-sstc,-sstvala,-sstvecd,-ssu64xl,-supm,-svade,-svadu,-svbare,-svinval,-svnapot,-svpbmt,-svvptc,-xandesperf,-xandesvbfhcvt,-xandesvdot,-xandesvpackfph,-xandesvsintload,-xcvalu,-xcvbi,-xcvbitmanip,-xcvelw,-xcvmac,-xcvmem,-xcvsimd,-xmipscbop,-xmipscmov,-xmipslsp,-xsfcease,-xsfmm128t,-xsfmm16t,-xsfmm32a16f,-xsfmm32a32f,-xsfmm32a8f,-xsfmm32a8i,-xsfmm32t,-xsfmm64a64f,-xsfmm64t,-xsfmmbase,-xsfvcp,-xsfvfnrclipxfqf,-xsfvfwmaccqqq,-xsfvqmaccdod,-xsfvqmaccqoq,-xsifivecdiscarddlone,-xsifivecflushdlone,-xtheadba,-xtheadbb,-xtheadbs,-xtheadcmo,-xtheadcondmov,-xtheadfmemidx,-xtheadmac,-xtheadmemidx,-xtheadmempair,-xtheadsync,-xtheadvdot,-xventanacondops,-xwchc,-za128rs,-za64rs,-zabha,-zacas,-zama16b,-zawrs,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zca,-zcb,-zcd,-zce,-zcf,-zclsd,-zcmop,-zcmp,-zcmt,-zdinx,-zfa,-zfbfmin,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zic64b,-zicbom,-zicbop,-zicboz,-ziccamoa,-ziccamoc,-ziccif,-zicclsm,-ziccrse,-zicntr,-zicond,-zifencei,-zihintntl,-zihintpause,-zihpm,-zilsd,-zimop,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-ztso,-zvbb,-zvbc,-zvfbfmin,-zvfbfwma,-zvfh,-zvfhmin,-zvkb,-zvkg,-zvkn,-zvknc,-zvkned,-zvkng,-zvknha,-zvknhb,-zvks,-zvksc,-zvksed,-zvksg,-zvksh,-zvkt,-zvl1024b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl4096b,-zvl512b,-zvl65536b,-zvl8192b" }
attributes #3 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #4 = { nounwind }

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
!10 = !{!"[0] ld_i64 [t0],env:0xfffffffffffffff8"}
!11 = !{!12, !12, i64 0}
!12 = !{!"CPUState", !9}
!13 = !{!"[1] qemu_ld_i64 [t1],t0,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B"}
!14 = !{!15, !15, i64 0}
!15 = !{!"GuestMem", !9}
!16 = !{!"[2] add_i64 [t0],t0,0x8"}
!17 = !{!"[3] qemu_ld_i64 [t2],t0,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B"}
!18 = !{!"[4] add_i64 [t0],t0,0x8"}
!19 = !{!"[5] st_i64 t0,env:0xfffffffffffffff8"}
!20 = !{!"[6] brcond_i64 rip,t2,ne,L0"}
!21 = !{!"[7] tail_call_qemuaot t1 VEC_ARGS:"}
!22 = !{!"[9] func_addr t3,helper_jmp_ind"}
!23 = !{!"[10] func_addr t4,jmp_ind_callback"}
!24 = !{!"[11] func_addr t5,0x55aa,0x1"}
!25 = !{!"[12] tail_call_qemuaot t3,env,rip,t5,t4 VEC_ARGS:"}
!26 = !{!"[0] st_i64 rax,env"}
!27 = !{!"[1] st_i64 rcx,env:0x8"}
!28 = !{!"[2] st_i64 rdx,env:0x10"}
!29 = !{!"[3] st_i64 rbx,env:0x18"}
!30 = !{!"[4] st_i64 rsp,env:0x20"}
!31 = !{!"[5] st_i64 rbp,env:0x28"}
!32 = !{!"[6] st_i64 rsi,env:0x30"}
!33 = !{!"[7] st_i64 rdi,env:0x38"}
!34 = !{!"[8] st_i64 r8,env:0x40"}
!35 = !{!"[9] st_i64 r9,env:0x48"}
!36 = !{!"[10] st_i64 r10,env:0x50"}
!37 = !{!"[11] st_i64 r11,env:0x58"}
!38 = !{!"[12] st_i64 r12,env:0x60"}
!39 = !{!"[13] st_i64 r13,env:0x68"}
!40 = !{!"[14] st_i64 r14,env:0x70"}
!41 = !{!"[15] st_i64 r15,env:0x78"}
!42 = !{!"[16] st_i64 cc_src,env:0x98"}
!43 = !{!"[17] st_i64 cc_dst,env:0x90"}
!44 = !{!"[18] st_i32 cc_op,env:0xa8"}
!45 = !{!"[19] st_i64 rip,env:0x80"}
!46 = !{!"[20] st_vec v128,e8,v0,env:0x360"}
!47 = !{!"[21] st_vec v128,e8,v1,env:0x370"}
!48 = !{!"[22] st_vec v128,e8,v2,env:0x3a0"}
!49 = !{!"[23] st_vec v128,e8,v3,env:0x3b0"}
!50 = !{!"[24] st_vec v128,e8,v4,env:0x3e0"}
!51 = !{!"[25] st_vec v128,e8,v5,env:0x3f0"}
!52 = !{!"[26] st_vec v128,e8,v6,env:0x420"}
!53 = !{!"[27] st_vec v128,e8,v7,env:0x430"}
!54 = !{!"[28] st_vec v128,e8,v8,env:0x460"}
!55 = !{!"[29] st_vec v128,e8,v9,env:0x470"}
!56 = !{!"[30] st_vec v128,e8,v10,env:0x4a0"}
!57 = !{!"[31] st_vec v128,e8,v11,env:0x4b0"}
!58 = !{!"[32] st_vec v128,e8,v12,env:0x4e0"}
!59 = !{!"[33] st_vec v128,e8,v13,env:0x4f0"}
!60 = !{!"[34] st_vec v128,e8,v14,env:0x520"}
!61 = !{!"[35] st_vec v128,e8,v15,env:0x530"}
!62 = !{!"[36] st_vec v128,e8,v16,env:0x560"}
!63 = !{!"[37] st_vec v128,e8,v17,env:0x570"}
!64 = !{!"[38] st_vec v128,e8,v18,env:0x5a0"}
!65 = !{!"[39] st_vec v128,e8,v19,env:0x5b0"}
!66 = !{!"[40] st_vec v128,e8,v20,env:0x5e0"}
!67 = !{!"[41] st_vec v128,e8,v21,env:0x5f0"}
!68 = !{!"[42] st_vec v128,e8,v22,env:0x620"}
!69 = !{!"[43] st_vec v128,e8,v23,env:0x630"}
!70 = !{!"[44] st_vec v128,e8,v24,env:0x660"}
!71 = !{!"[45] st_vec v128,e8,v25,env:0x670"}
!72 = !{!"[46] st_vec v128,e8,v26,env:0x6a0"}
!73 = !{!"[47] st_vec v128,e8,v27,env:0x6b0"}
!74 = !{!"[48] tail_call_default helper_jit,arg0,arg1"}
