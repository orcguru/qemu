; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx55aa(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26528) %cpu) #0 section ".text.Fx55aa" {
entry:
  %rip.stack = alloca i64, align 8
  store i64 %rip, ptr %rip.stack, align 8, !tbaa !4
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca ptr, align 8
  %tmp4.stack = alloca ptr, align 8
  %tmp5.stack = alloca ptr, align 8
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] ld_i64 [t0],env:0xfffffffffffffff8 ========
  %T0.envptr = getelementptr i8, ptr %env, i64 -8, !tcg.op !7
  %T0.envval = load i64, ptr %T0.envptr, align 8, !tbaa !8, !tcg.op !7
  store i64 %T0.envval, ptr %tmp0.stack, align 8, !tbaa !4, !tcg.op !7
; ======== TCG [1] qemu_ld_i64 [t1],t0,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B ========
  %T1.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !4, !tcg.op !10
  %T1.tmp0.ptr = inttoptr i64 %T1.tmp0 to ptr, !tcg.op !10
  %T1.ld = load i64, ptr %T1.tmp0.ptr, align 8, !tbaa !11, !tcg.op !10
  store i64 %T1.ld, ptr %tmp1.stack, align 8, !tbaa !4, !tcg.op !10
; ======== TCG [2] add_i64 [t0],t0,0x8 ========
  %T2.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !4, !tcg.op !13
  %T2.out = add i64 %T2.tmp0, 8, !tcg.op !13
  store i64 %T2.out, ptr %tmp0.stack, align 8, !tbaa !4, !tcg.op !13
; ======== TCG [3] qemu_ld_i64 [t2],t0,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B ========
  %T3.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !4, !tcg.op !14
  %T3.tmp0.ptr = inttoptr i64 %T3.tmp0 to ptr, !tcg.op !14
  %T3.ld = load i64, ptr %T3.tmp0.ptr, align 8, !tbaa !11, !tcg.op !14
  store i64 %T3.ld, ptr %tmp2.stack, align 8, !tbaa !4, !tcg.op !14
; ======== TCG [4] add_i64 [t0],t0,0x8 ========
  %T4.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !4, !tcg.op !15
  %T4.out = add i64 %T4.tmp0, 8, !tcg.op !15
  store i64 %T4.out, ptr %tmp0.stack, align 8, !tbaa !4, !tcg.op !15
; ======== TCG [5] st_i64 t0,env:0xfffffffffffffff8 ========
  %T5.tmp0 = load i64, ptr %tmp0.stack, align 8, !tbaa !4, !tcg.op !16
  %T5.envptr = getelementptr i8, ptr %env, i64 -8, !tcg.op !16
  store i64 %T5.tmp0, ptr %T5.envptr, align 8, !tbaa !8, !tcg.op !16
; ======== TCG [6] brcond_i64 rip,t2,ne,L0 ========
  %T6.rip = load i64, ptr %rip.stack, align 8, !tbaa !4, !tcg.op !17
  %T6.tmp2 = load i64, ptr %tmp2.stack, align 8, !tbaa !4, !tcg.op !17
  %T6.bool = icmp ne i64 %T6.rip, %T6.tmp2, !tcg.op !17
  br i1 %T6.bool, label %bb_L0, label %bb_false, !tcg.op !17

bb_false:                                         ; preds = %entry
; ======== TCG [7] tail_call_qemuaot t1 VEC_ARGS: ========
  %T7.rip.stack = load i64, ptr %rip.stack, align 8, !tbaa !4, !tcg.op !18
  %T7.loaded_fn = load ptr, ptr %tmp1.stack, align 8, !tcg.op !18
  tail call qemuaot void %T7.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %T7.rip.stack, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr %cpu), !tcg.op !18
  ret void, !tcg.op !18

bb_L0:                                            ; preds = %entry
; ======== TCG [9] func_addr t3,helper_jmp_ind ========
  store ptr @helper_jmp_ind, ptr %tmp3.stack, align 8, !tbaa !4, !tcg.op !19
; ======== TCG [10] func_addr t4,jmp_ind_callback ========
  store ptr @jmp_ind_callback, ptr %tmp4.stack, align 8, !tbaa !4, !tcg.op !20
; ======== TCG [11] func_addr t5,0x55aa,0x1 ========
  store ptr @trampoline_helper_jit, ptr %tmp5.stack, align 8, !tbaa !4, !tcg.op !21
; ======== TCG [12] tail_call_qemuaot t3,env,rip,t5,t4 VEC_ARGS: ========
  %T12.rip.stack = load i64, ptr %rip.stack, align 8, !tbaa !4, !tcg.op !22
  %T12.env = ptrtoint ptr %env to i64, !tcg.op !22
  %T12.rip = load i64, ptr %rip.stack, align 8, !tbaa !4, !tcg.op !22
  %T12.tmp5 = load i64, ptr %tmp5.stack, align 8, !tbaa !4, !tcg.op !22
  %T12.tmp4 = load i64, ptr %tmp4.stack, align 8, !tbaa !4, !tcg.op !22
  %T12.loaded_fn = load ptr, ptr %tmp3.stack, align 8, !tcg.op !22
  tail call qemuaot void %T12.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %T12.rip.stack, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr %cpu, i64 %T12.env, i64 %T12.rip, i64 %T12.tmp5, i64 %T12.tmp4), !tcg.op !22
  ret void, !tcg.op !22
}

; Function Attrs: nounwind
declare qemuaot void @helper_jmp_ind(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, <2 x i64>, ptr, i64, i64, i64, i64) #1

; Function Attrs: nounwind
define weak qemuaot void @jmp_ind_callback(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %src, i64 noundef %dst, i32 noundef %op, i64 noundef %rip, <2 x i64> noundef %xmm0, <2 x i64> noundef %ymm0_h, <2 x i64> noundef %xmm1, <2 x i64> noundef %ymm1_h, <2 x i64> noundef %xmm2, <2 x i64> noundef %ymm2_h, <2 x i64> noundef %xmm3, <2 x i64> noundef %ymm3_h, <2 x i64> noundef %xmm4, <2 x i64> noundef %ymm4_h, <2 x i64> noundef %xmm5, <2 x i64> noundef %ymm5_h, <2 x i64> noundef %xmm6, <2 x i64> noundef %ymm6_h, <2 x i64> noundef %xmm7, <2 x i64> noundef %ymm7_h, <2 x i64> noundef %xmm8, <2 x i64> noundef %ymm8_h, <2 x i64> noundef %xmm9, <2 x i64> noundef %ymm9_h, <2 x i64> noundef %xmm10, <2 x i64> noundef %ymm10_h, <2 x i64> noundef %xmm11, <2 x i64> noundef %ymm11_h, <2 x i64> noundef %xmm12, <2 x i64> noundef %ymm12_h, <2 x i64> noundef %xmm13, <2 x i64> noundef %ymm13_h, i64 noundef %cpu_param, i64 noundef %target_addr, i64 noundef %host_addr, i64 noundef %trampoline_helper_jit) local_unnamed_addr #2 {
entry:
  %tobool.not = icmp eq i64 %host_addr, 0
  br i1 %tobool.not, label %if.else, label %if.then

if.then:                                          ; preds = %entry
  %0 = inttoptr i64 %host_addr to ptr
  tail call qemuaot void %0(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %src, i64 noundef %dst, i32 noundef %op, i64 noundef %target_addr, <2 x i64> noundef %xmm0, <2 x i64> noundef %ymm0_h, <2 x i64> noundef %xmm1, <2 x i64> noundef %ymm1_h, <2 x i64> noundef %xmm2, <2 x i64> noundef %ymm2_h, <2 x i64> noundef %xmm3, <2 x i64> noundef %ymm3_h, <2 x i64> noundef %xmm4, <2 x i64> noundef %ymm4_h, <2 x i64> noundef %xmm5, <2 x i64> noundef %ymm5_h, <2 x i64> noundef %xmm6, <2 x i64> noundef %ymm6_h, <2 x i64> noundef %xmm7, <2 x i64> noundef %ymm7_h, <2 x i64> noundef %xmm8, <2 x i64> noundef %ymm8_h, <2 x i64> noundef %xmm9, <2 x i64> noundef %ymm9_h, <2 x i64> noundef %xmm10, <2 x i64> noundef %ymm10_h, <2 x i64> noundef %xmm11, <2 x i64> noundef %ymm11_h, <2 x i64> noundef %xmm12, <2 x i64> noundef %ymm12_h, <2 x i64> noundef %xmm13, <2 x i64> noundef %ymm13_h, i64 noundef %cpu_param) #3
  br label %return

if.else:                                          ; preds = %entry
  %1 = inttoptr i64 %trampoline_helper_jit to ptr
  %add = add i64 %cpu_param, 11472
  tail call qemuaot void %1(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %src, i64 noundef %dst, i32 noundef %op, i64 noundef %target_addr, <2 x i64> noundef %xmm0, <2 x i64> noundef %ymm0_h, <2 x i64> noundef %xmm1, <2 x i64> noundef %ymm1_h, <2 x i64> noundef %xmm2, <2 x i64> noundef %ymm2_h, <2 x i64> noundef %xmm3, <2 x i64> noundef %ymm3_h, <2 x i64> noundef %xmm4, <2 x i64> noundef %ymm4_h, <2 x i64> noundef %xmm5, <2 x i64> noundef %ymm5_h, <2 x i64> noundef %xmm6, <2 x i64> noundef %ymm6_h, <2 x i64> noundef %xmm7, <2 x i64> noundef %ymm7_h, <2 x i64> noundef %xmm8, <2 x i64> noundef %ymm8_h, <2 x i64> noundef %xmm9, <2 x i64> noundef %ymm9_h, <2 x i64> noundef %xmm10, <2 x i64> noundef %ymm10_h, <2 x i64> noundef %xmm11, <2 x i64> noundef %ymm11_h, <2 x i64> noundef %xmm12, <2 x i64> noundef %ymm12_h, <2 x i64> noundef %xmm13, <2 x i64> noundef %ymm13_h, i64 noundef %cpu_param, i64 noundef %add, i64 noundef %target_addr) #3
  br label %return

return:                                           ; preds = %if.else, %if.then
  ret void
}

; Function Attrs: noinline nounwind
define qemuaot void @trampoline_helper_jit(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, ptr align 8 dereferenceable(26528) %cpu, i64 %arg0, i64 %arg1) #0 section ".text.trampoline_helper_jit" {
entry:
  %rip.stack = alloca i64, align 8
  store i64 %rip, ptr %rip.stack, align 8, !tbaa !4
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %env = getelementptr i8, ptr %cpu, i64 11472
; ======== TCG [0] st_i64 rax,env ========
  %T0.envptr = getelementptr i8, ptr %env, i64 0, !tcg.op !23
  store i64 %rax, ptr %T0.envptr, align 16, !tbaa !8, !tcg.op !23
; ======== TCG [1] st_i64 rcx,env:0x8 ========
  %T1.envptr = getelementptr i8, ptr %env, i64 8, !tcg.op !24
  store i64 %rcx, ptr %T1.envptr, align 8, !tbaa !8, !tcg.op !24
; ======== TCG [2] st_i64 rdx,env:0x10 ========
  %T2.envptr = getelementptr i8, ptr %env, i64 16, !tcg.op !25
  store i64 %rdx, ptr %T2.envptr, align 16, !tbaa !8, !tcg.op !25
; ======== TCG [3] st_i64 rbx,env:0x18 ========
  %T3.envptr = getelementptr i8, ptr %env, i64 24, !tcg.op !26
  store i64 %rbx, ptr %T3.envptr, align 8, !tbaa !8, !tcg.op !26
; ======== TCG [4] st_i64 rsp,env:0x20 ========
  %T4.envptr = getelementptr i8, ptr %env, i64 32, !tcg.op !27
  store i64 %rsp, ptr %T4.envptr, align 16, !tbaa !8, !tcg.op !27
; ======== TCG [5] st_i64 rbp,env:0x28 ========
  %T5.envptr = getelementptr i8, ptr %env, i64 40, !tcg.op !28
  store i64 %rbp, ptr %T5.envptr, align 8, !tbaa !8, !tcg.op !28
; ======== TCG [6] st_i64 rsi,env:0x30 ========
  %T6.envptr = getelementptr i8, ptr %env, i64 48, !tcg.op !29
  store i64 %rsi, ptr %T6.envptr, align 16, !tbaa !8, !tcg.op !29
; ======== TCG [7] st_i64 rdi,env:0x38 ========
  %T7.envptr = getelementptr i8, ptr %env, i64 56, !tcg.op !30
  store i64 %rdi, ptr %T7.envptr, align 8, !tbaa !8, !tcg.op !30
; ======== TCG [8] st_i64 r8,env:0x40 ========
  %T8.envptr = getelementptr i8, ptr %env, i64 64, !tcg.op !31
  store i64 %r8, ptr %T8.envptr, align 16, !tbaa !8, !tcg.op !31
; ======== TCG [9] st_i64 r9,env:0x48 ========
  %T9.envptr = getelementptr i8, ptr %env, i64 72, !tcg.op !32
  store i64 %r9, ptr %T9.envptr, align 8, !tbaa !8, !tcg.op !32
; ======== TCG [10] st_i64 r10,env:0x50 ========
  %T10.envptr = getelementptr i8, ptr %env, i64 80, !tcg.op !33
  store i64 %r10, ptr %T10.envptr, align 16, !tbaa !8, !tcg.op !33
; ======== TCG [11] st_i64 r11,env:0x58 ========
  %T11.envptr = getelementptr i8, ptr %env, i64 88, !tcg.op !34
  store i64 %r11, ptr %T11.envptr, align 8, !tbaa !8, !tcg.op !34
; ======== TCG [12] st_i64 r12,env:0x60 ========
  %T12.envptr = getelementptr i8, ptr %env, i64 96, !tcg.op !35
  store i64 %r12, ptr %T12.envptr, align 16, !tbaa !8, !tcg.op !35
; ======== TCG [13] st_i64 r13,env:0x68 ========
  %T13.envptr = getelementptr i8, ptr %env, i64 104, !tcg.op !36
  store i64 %r13, ptr %T13.envptr, align 8, !tbaa !8, !tcg.op !36
; ======== TCG [14] st_i64 r14,env:0x70 ========
  %T14.envptr = getelementptr i8, ptr %env, i64 112, !tcg.op !37
  store i64 %r14, ptr %T14.envptr, align 16, !tbaa !8, !tcg.op !37
; ======== TCG [15] st_i64 r15,env:0x78 ========
  %T15.envptr = getelementptr i8, ptr %env, i64 120, !tcg.op !38
  store i64 %r15, ptr %T15.envptr, align 8, !tbaa !8, !tcg.op !38
; ======== TCG [16] st_i64 cc_src,env:0x98 ========
  %T16.envptr = getelementptr i8, ptr %env, i64 152, !tcg.op !39
  store i64 %cc_src, ptr %T16.envptr, align 8, !tbaa !8, !tcg.op !39
; ======== TCG [17] st_i64 cc_dst,env:0x90 ========
  %T17.envptr = getelementptr i8, ptr %env, i64 144, !tcg.op !40
  store i64 %cc_dst, ptr %T17.envptr, align 16, !tbaa !8, !tcg.op !40
; ======== TCG [18] st_i32 cc_op,env:0xa8 ========
  %T18.envptr = getelementptr i8, ptr %env, i64 168, !tcg.op !41
  store i32 %cc_op, ptr %T18.envptr, align 8, !tbaa !8, !tcg.op !41
; ======== TCG [19] st_i64 rip,env:0x80 ========
  %T19.rip = load i64, ptr %rip.stack, align 8, !tbaa !4, !tcg.op !42
  %T19.envptr = getelementptr i8, ptr %env, i64 128, !tcg.op !42
  store i64 %T19.rip, ptr %T19.envptr, align 16, !tbaa !8, !tcg.op !42
; ======== TCG [20] st_vec v128,e8,v0,env:0x360 ========
  %T20.envptr = getelementptr i8, ptr %env, i64 864, !tcg.op !43
  store <2 x i64> %xmm0, ptr %T20.envptr, align 16, !tbaa !8, !tcg.op !43
; ======== TCG [21] st_vec v128,e8,v1,env:0x370 ========
  %T21.envptr = getelementptr i8, ptr %env, i64 880, !tcg.op !44
  store <2 x i64> %ymm0_h, ptr %T21.envptr, align 16, !tbaa !8, !tcg.op !44
; ======== TCG [22] st_vec v128,e8,v2,env:0x3a0 ========
  %T22.envptr = getelementptr i8, ptr %env, i64 928, !tcg.op !45
  store <2 x i64> %xmm1, ptr %T22.envptr, align 16, !tbaa !8, !tcg.op !45
; ======== TCG [23] st_vec v128,e8,v3,env:0x3b0 ========
  %T23.envptr = getelementptr i8, ptr %env, i64 944, !tcg.op !46
  store <2 x i64> %ymm1_h, ptr %T23.envptr, align 16, !tbaa !8, !tcg.op !46
; ======== TCG [24] st_vec v128,e8,v4,env:0x3e0 ========
  %T24.envptr = getelementptr i8, ptr %env, i64 992, !tcg.op !47
  store <2 x i64> %xmm2, ptr %T24.envptr, align 16, !tbaa !8, !tcg.op !47
; ======== TCG [25] st_vec v128,e8,v5,env:0x3f0 ========
  %T25.envptr = getelementptr i8, ptr %env, i64 1008, !tcg.op !48
  store <2 x i64> %ymm2_h, ptr %T25.envptr, align 16, !tbaa !8, !tcg.op !48
; ======== TCG [26] st_vec v128,e8,v6,env:0x420 ========
  %T26.envptr = getelementptr i8, ptr %env, i64 1056, !tcg.op !49
  store <2 x i64> %xmm3, ptr %T26.envptr, align 16, !tbaa !8, !tcg.op !49
; ======== TCG [27] st_vec v128,e8,v7,env:0x430 ========
  %T27.envptr = getelementptr i8, ptr %env, i64 1072, !tcg.op !50
  store <2 x i64> %ymm3_h, ptr %T27.envptr, align 16, !tbaa !8, !tcg.op !50
; ======== TCG [28] st_vec v128,e8,v8,env:0x460 ========
  %T28.envptr = getelementptr i8, ptr %env, i64 1120, !tcg.op !51
  store <2 x i64> %xmm4, ptr %T28.envptr, align 16, !tbaa !8, !tcg.op !51
; ======== TCG [29] st_vec v128,e8,v9,env:0x470 ========
  %T29.envptr = getelementptr i8, ptr %env, i64 1136, !tcg.op !52
  store <2 x i64> %ymm4_h, ptr %T29.envptr, align 16, !tbaa !8, !tcg.op !52
; ======== TCG [30] st_vec v128,e8,v10,env:0x4a0 ========
  %T30.envptr = getelementptr i8, ptr %env, i64 1184, !tcg.op !53
  store <2 x i64> %xmm5, ptr %T30.envptr, align 16, !tbaa !8, !tcg.op !53
; ======== TCG [31] st_vec v128,e8,v11,env:0x4b0 ========
  %T31.envptr = getelementptr i8, ptr %env, i64 1200, !tcg.op !54
  store <2 x i64> %ymm5_h, ptr %T31.envptr, align 16, !tbaa !8, !tcg.op !54
; ======== TCG [32] st_vec v128,e8,v12,env:0x4e0 ========
  %T32.envptr = getelementptr i8, ptr %env, i64 1248, !tcg.op !55
  store <2 x i64> %xmm6, ptr %T32.envptr, align 16, !tbaa !8, !tcg.op !55
; ======== TCG [33] st_vec v128,e8,v13,env:0x4f0 ========
  %T33.envptr = getelementptr i8, ptr %env, i64 1264, !tcg.op !56
  store <2 x i64> %ymm6_h, ptr %T33.envptr, align 16, !tbaa !8, !tcg.op !56
; ======== TCG [34] st_vec v128,e8,v14,env:0x520 ========
  %T34.envptr = getelementptr i8, ptr %env, i64 1312, !tcg.op !57
  store <2 x i64> %xmm7, ptr %T34.envptr, align 16, !tbaa !8, !tcg.op !57
; ======== TCG [35] st_vec v128,e8,v15,env:0x530 ========
  %T35.envptr = getelementptr i8, ptr %env, i64 1328, !tcg.op !58
  store <2 x i64> %ymm7_h, ptr %T35.envptr, align 16, !tbaa !8, !tcg.op !58
; ======== TCG [36] st_vec v128,e8,v16,env:0x560 ========
  %T36.envptr = getelementptr i8, ptr %env, i64 1376, !tcg.op !59
  store <2 x i64> %xmm8, ptr %T36.envptr, align 16, !tbaa !8, !tcg.op !59
; ======== TCG [37] st_vec v128,e8,v17,env:0x570 ========
  %T37.envptr = getelementptr i8, ptr %env, i64 1392, !tcg.op !60
  store <2 x i64> %ymm8_h, ptr %T37.envptr, align 16, !tbaa !8, !tcg.op !60
; ======== TCG [38] st_vec v128,e8,v18,env:0x5a0 ========
  %T38.envptr = getelementptr i8, ptr %env, i64 1440, !tcg.op !61
  store <2 x i64> %xmm9, ptr %T38.envptr, align 16, !tbaa !8, !tcg.op !61
; ======== TCG [39] st_vec v128,e8,v19,env:0x5b0 ========
  %T39.envptr = getelementptr i8, ptr %env, i64 1456, !tcg.op !62
  store <2 x i64> %ymm9_h, ptr %T39.envptr, align 16, !tbaa !8, !tcg.op !62
; ======== TCG [40] st_vec v128,e8,v20,env:0x5e0 ========
  %T40.envptr = getelementptr i8, ptr %env, i64 1504, !tcg.op !63
  store <2 x i64> %xmm10, ptr %T40.envptr, align 16, !tbaa !8, !tcg.op !63
; ======== TCG [41] st_vec v128,e8,v21,env:0x5f0 ========
  %T41.envptr = getelementptr i8, ptr %env, i64 1520, !tcg.op !64
  store <2 x i64> %ymm10_h, ptr %T41.envptr, align 16, !tbaa !8, !tcg.op !64
; ======== TCG [42] st_vec v128,e8,v22,env:0x620 ========
  %T42.envptr = getelementptr i8, ptr %env, i64 1568, !tcg.op !65
  store <2 x i64> %xmm11, ptr %T42.envptr, align 16, !tbaa !8, !tcg.op !65
; ======== TCG [43] st_vec v128,e8,v23,env:0x630 ========
  %T43.envptr = getelementptr i8, ptr %env, i64 1584, !tcg.op !66
  store <2 x i64> %ymm11_h, ptr %T43.envptr, align 16, !tbaa !8, !tcg.op !66
; ======== TCG [44] st_vec v128,e8,v24,env:0x660 ========
  %T44.envptr = getelementptr i8, ptr %env, i64 1632, !tcg.op !67
  store <2 x i64> %xmm12, ptr %T44.envptr, align 16, !tbaa !8, !tcg.op !67
; ======== TCG [45] st_vec v128,e8,v25,env:0x670 ========
  %T45.envptr = getelementptr i8, ptr %env, i64 1648, !tcg.op !68
  store <2 x i64> %ymm12_h, ptr %T45.envptr, align 16, !tbaa !8, !tcg.op !68
; ======== TCG [46] st_vec v128,e8,v26,env:0x6a0 ========
  %T46.envptr = getelementptr i8, ptr %env, i64 1696, !tcg.op !69
  store <2 x i64> %xmm13, ptr %T46.envptr, align 16, !tbaa !8, !tcg.op !69
; ======== TCG [47] st_vec v128,e8,v27,env:0x6b0 ========
  %T47.envptr = getelementptr i8, ptr %env, i64 1712, !tcg.op !70
  store <2 x i64> %ymm13_h, ptr %T47.envptr, align 16, !tbaa !8, !tcg.op !70
; ======== TCG [48] tail_call_default helper_jit,arg0,arg1 ========
  %T48.env = ptrtoint ptr %env to i64, !tcg.op !71
  call void asm "mov x16, $0", "r,~{x16}"(i64 %T48.env), !tcg.op !71
  tail call void @helper_jit(i64 %arg0, i64 %arg1), !tcg.op !71
  ret void, !tcg.op !71
}

declare void @helper_jit(i64, i64)

attributes #0 = { noinline nounwind "target-features"="+neon" }
attributes #1 = { nounwind "target-features"="+neon" }
attributes #2 = { nounwind "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-a15" "target-features"="+aes,+bf16,+bti,+ccidx,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fpac,+fullfp16,+i8mm,+jsconv,+lse,+neon,+outline-atomics,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8.5a,+v8.6a,+v8a,-fmv" }
attributes #3 = { nounwind }

!llvm.ident = !{!0}
!llvm.module.flags = !{!1, !2, !3}

!0 = !{!"<COMPILER_VERSION>"}
!1 = !{i32 1, !"wchar_size", i32 4}
!2 = !{i32 8, !"PIC Level", i32 2}
!3 = !{i32 7, !"frame-pointer", i32 1}
!4 = !{!5, !5, i64 0}
!5 = !{!"SpillSlo", !6}
!6 = !{!"Root"}
!7 = !{!"[0] ld_i64 [t0],env:0xfffffffffffffff8"}
!8 = !{!9, !9, i64 0}
!9 = !{!"CPUState", !6}
!10 = !{!"[1] qemu_ld_i64 [t1],t0,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B"}
!11 = !{!12, !12, i64 0}
!12 = !{!"GuestMem", !6}
!13 = !{!"[2] add_i64 [t0],t0,0x8"}
!14 = !{!"[3] qemu_ld_i64 [t2],t0,attr-stg:ATOM_IFALIGN:ALIGN_8:ZERO:SRC8B"}
!15 = !{!"[4] add_i64 [t0],t0,0x8"}
!16 = !{!"[5] st_i64 t0,env:0xfffffffffffffff8"}
!17 = !{!"[6] brcond_i64 rip,t2,ne,L0"}
!18 = !{!"[7] tail_call_qemuaot t1 VEC_ARGS:"}
!19 = !{!"[9] func_addr t3,helper_jmp_ind"}
!20 = !{!"[10] func_addr t4,jmp_ind_callback"}
!21 = !{!"[11] func_addr t5,0x55aa,0x1"}
!22 = !{!"[12] tail_call_qemuaot t3,env,rip,t5,t4 VEC_ARGS:"}
!23 = !{!"[0] st_i64 rax,env"}
!24 = !{!"[1] st_i64 rcx,env:0x8"}
!25 = !{!"[2] st_i64 rdx,env:0x10"}
!26 = !{!"[3] st_i64 rbx,env:0x18"}
!27 = !{!"[4] st_i64 rsp,env:0x20"}
!28 = !{!"[5] st_i64 rbp,env:0x28"}
!29 = !{!"[6] st_i64 rsi,env:0x30"}
!30 = !{!"[7] st_i64 rdi,env:0x38"}
!31 = !{!"[8] st_i64 r8,env:0x40"}
!32 = !{!"[9] st_i64 r9,env:0x48"}
!33 = !{!"[10] st_i64 r10,env:0x50"}
!34 = !{!"[11] st_i64 r11,env:0x58"}
!35 = !{!"[12] st_i64 r12,env:0x60"}
!36 = !{!"[13] st_i64 r13,env:0x68"}
!37 = !{!"[14] st_i64 r14,env:0x70"}
!38 = !{!"[15] st_i64 r15,env:0x78"}
!39 = !{!"[16] st_i64 cc_src,env:0x98"}
!40 = !{!"[17] st_i64 cc_dst,env:0x90"}
!41 = !{!"[18] st_i32 cc_op,env:0xa8"}
!42 = !{!"[19] st_i64 rip,env:0x80"}
!43 = !{!"[20] st_vec v128,e8,v0,env:0x360"}
!44 = !{!"[21] st_vec v128,e8,v1,env:0x370"}
!45 = !{!"[22] st_vec v128,e8,v2,env:0x3a0"}
!46 = !{!"[23] st_vec v128,e8,v3,env:0x3b0"}
!47 = !{!"[24] st_vec v128,e8,v4,env:0x3e0"}
!48 = !{!"[25] st_vec v128,e8,v5,env:0x3f0"}
!49 = !{!"[26] st_vec v128,e8,v6,env:0x420"}
!50 = !{!"[27] st_vec v128,e8,v7,env:0x430"}
!51 = !{!"[28] st_vec v128,e8,v8,env:0x460"}
!52 = !{!"[29] st_vec v128,e8,v9,env:0x470"}
!53 = !{!"[30] st_vec v128,e8,v10,env:0x4a0"}
!54 = !{!"[31] st_vec v128,e8,v11,env:0x4b0"}
!55 = !{!"[32] st_vec v128,e8,v12,env:0x4e0"}
!56 = !{!"[33] st_vec v128,e8,v13,env:0x4f0"}
!57 = !{!"[34] st_vec v128,e8,v14,env:0x520"}
!58 = !{!"[35] st_vec v128,e8,v15,env:0x530"}
!59 = !{!"[36] st_vec v128,e8,v16,env:0x560"}
!60 = !{!"[37] st_vec v128,e8,v17,env:0x570"}
!61 = !{!"[38] st_vec v128,e8,v18,env:0x5a0"}
!62 = !{!"[39] st_vec v128,e8,v19,env:0x5b0"}
!63 = !{!"[40] st_vec v128,e8,v20,env:0x5e0"}
!64 = !{!"[41] st_vec v128,e8,v21,env:0x5f0"}
!65 = !{!"[42] st_vec v128,e8,v22,env:0x620"}
!66 = !{!"[43] st_vec v128,e8,v23,env:0x630"}
!67 = !{!"[44] st_vec v128,e8,v24,env:0x660"}
!68 = !{!"[45] st_vec v128,e8,v25,env:0x670"}
!69 = !{!"[46] st_vec v128,e8,v26,env:0x6a0"}
!70 = !{!"[47] st_vec v128,e8,v27,env:0x6b0"}
!71 = !{!"[48] tail_call_default helper_jit,arg0,arg1"}
