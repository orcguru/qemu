; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define qemuaot void @Fx0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h) #0 section ".text.Fx0" {
entry:
  %rax.stack = alloca i64, align 8
  store i64 %rax, ptr %rax.stack, align 8
  %rcx.stack = alloca i64, align 8
  store i64 %rcx, ptr %rcx.stack, align 8
  %rdx.stack = alloca i64, align 8
  store i64 %rdx, ptr %rdx.stack, align 8
  %rbx.stack = alloca i64, align 8
  store i64 %rbx, ptr %rbx.stack, align 8
  %v2.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm1, ptr %v2.stack, align 16
  %v4.stack = alloca <2 x i64>, align 16
  store <2 x i64> %xmm2, ptr %v4.stack, align 16
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca <2 x i64>, align 16
  %env = call i64 asm sideeffect "mov $0, x25", "=r"()
; ======== TCG [0] add_i64 [rax],rbx,rdx ========
  %T0.rbx = load i64, ptr %rbx.stack, align 8, !tcg.op !0
  %T0.rdx = load i64, ptr %rdx.stack, align 8, !tcg.op !0
  %T0.out = add i64 %T0.rbx, %T0.rdx, !tcg.op !0
  store i64 %T0.out, ptr %rax.stack, align 8, !tcg.op !0
; ======== TCG [1] add_i64 [t0],rax,0x42 ========
  %T1.rax = load i64, ptr %rax.stack, align 8, !tcg.op !1
  %T1.out = add i64 %T1.rax, 66, !tcg.op !1
  store i64 %T1.out, ptr %tmp0.stack, align 8, !tcg.op !1
; ======== TCG [2] add_i64 [rcx],rcx,rcx ========
  %T2.rcx = load i64, ptr %rcx.stack, align 8, !tcg.op !2
  %T2.rcx1 = load i64, ptr %rcx.stack, align 8, !tcg.op !2
  %T2.out = add i64 %T2.rcx, %T2.rcx1, !tcg.op !2
  store i64 %T2.out, ptr %rcx.stack, align 8, !tcg.op !2
; ======== TCG [3] add_vec v128,e8,[t3],v2,v4 ========
  %T3.v2 = load <16 x i8>, ptr %v2.stack, align 16, !tcg.op !3
  %T3.v4 = load <16 x i8>, ptr %v4.stack, align 16, !tcg.op !3
  %T3.out = add <16 x i8> %T3.v2, %T3.v4, !tcg.op !3
  store <16 x i8> %T3.out, ptr %tmp3.stack, align 16, !tcg.op !3
; ======== TCG [4] add_vec v128,e16,[t3],v2,v4 ========
  %T4.v2 = load <8 x i16>, ptr %v2.stack, align 16, !tcg.op !4
  %T4.v4 = load <8 x i16>, ptr %v4.stack, align 16, !tcg.op !4
  %T4.out = add <8 x i16> %T4.v2, %T4.v4, !tcg.op !4
  store <8 x i16> %T4.out, ptr %tmp3.stack, align 16, !tcg.op !4
; ======== TCG [5] add_vec v128,e32,[t3],v2,v4 ========
  %T5.v2 = load <4 x i32>, ptr %v2.stack, align 16, !tcg.op !5
  %T5.v4 = load <4 x i32>, ptr %v4.stack, align 16, !tcg.op !5
  %T5.out = add <4 x i32> %T5.v2, %T5.v4, !tcg.op !5
  store <4 x i32> %T5.out, ptr %tmp3.stack, align 16, !tcg.op !5
; ======== TCG [6] add_vec v128,e64,[t3],v2,v4 ========
  %T6.v2 = load <2 x i64>, ptr %v2.stack, align 16, !tcg.op !6
  %T6.v4 = load <2 x i64>, ptr %v4.stack, align 16, !tcg.op !6
  %T6.out = add <2 x i64> %T6.v2, %T6.v4, !tcg.op !6
  store <2 x i64> %T6.out, ptr %tmp3.stack, align 16, !tcg.op !6
; ======== TCG [7] add_i64 [t3],rax,fs_base(env) ========
  %T7.rax = load i64, ptr %rax.stack, align 8, !tcg.op !7
  %T7.addr.fs_base = add i64 %env, 288, !tcg.op !7
  %T7.addr.fs_base.ptr = inttoptr i64 %T7.addr.fs_base to ptr, !tcg.op !7
  %T7.fs_base = load i64, ptr %T7.addr.fs_base.ptr, align 8, !tcg.op !7
  %T7.out = add i64 %T7.rax, %T7.fs_base, !tcg.op !7
  store i64 %T7.out, ptr %tmp3.stack, align 16, !tcg.op !7
; ======== TCG [8] add_i32 [t3],t3,t3 ========
  %T8.tmp3 = load i32, ptr %tmp3.stack, align 16, !tcg.op !8
  %T8.tmp32 = load i32, ptr %tmp3.stack, align 16, !tcg.op !8
  %T8.out = add i32 %T8.tmp3, %T8.tmp32, !tcg.op !8
  store i32 %T8.out, ptr %tmp3.stack, align 16, !tcg.op !8
}

attributes #0 = { noinline nounwind "target-features"="+neon" }

!0 = !{!"[0] add_i64 [rax],rbx,rdx"}
!1 = !{!"[1] add_i64 [t0],rax,0x42"}
!2 = !{!"[2] add_i64 [rcx],rcx,rcx"}
!3 = !{!"[3] add_vec v128,e8,[t3],v2,v4"}
!4 = !{!"[4] add_vec v128,e16,[t3],v2,v4"}
!5 = !{!"[5] add_vec v128,e32,[t3],v2,v4"}
!6 = !{!"[6] add_vec v128,e64,[t3],v2,v4"}
!7 = !{!"[7] add_i64 [t3],rax,fs_base(env)"}
!8 = !{!"[8] add_i32 [t3],t3,t3"}
