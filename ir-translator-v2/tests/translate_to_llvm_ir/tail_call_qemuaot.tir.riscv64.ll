; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target datalayout = "e-m:e-p:64:64-i64:64-i128:128-n32:64-S128"
target triple = "riscv64-unknown-linux-gnu"

@helper_retaddr = thread_local local_unnamed_addr global i64 0, align 8

; Function Attrs: noinline nounwind
define qemuaot void @Fx55aa(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr align 8 dereferenceable(26544) %cpu) #0 section ".text.Fx55aa" {
entry:
  %rsi.stack = alloca i64, align 8
  store i64 %rsi, ptr %rsi.stack, align 8, !tbaa !7
  %v0.stack = alloca <vscale x 1 x i64>, align 16
  store <vscale x 1 x i64> %xmm0, ptr %v0.stack, align 16, !tbaa !7
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca i64, align 8
  %tmp5.stack = alloca ptr, align 8
  %tmp6.stack = alloca ptr, align 8
  %env = getelementptr i8, ptr %cpu, i64 11488
; ======== TCG [0] mov_i64 [t0],0xffffffffffffffe1 ========
  store i64 -31, ptr %tmp0.stack, align 8, !tbaa !7, !tcg.op !10
; ======== TCG [1] func_addr t5,helper_pshufd_xmm,v0,v0 ========
  store ptr @helper_pshufd_xmm_V0_V0, ptr %tmp5.stack, align 8, !tbaa !7, !tcg.op !11
; ======== TCG [2] func_addr t6,0x55aa,0x1 ========
  store ptr @Fx55aa_1, ptr %tmp6.stack, align 8, !tbaa !7, !tcg.op !12
; ======== TCG [3] tail_call_qemuaot t5,0xe1,t6 VEC_ARGS:v0,v0, ========
  %T3.rsi.stack = load i64, ptr %rsi.stack, align 8, !tbaa !7, !tcg.op !13
  %T3.v0.stack = load <vscale x 1 x i64>, ptr %v0.stack, align 16, !tbaa !7, !tcg.op !13
  %T3.tmp6 = load i64, ptr %tmp6.stack, align 8, !tbaa !7, !tcg.op !13
  %T3.loaded_fn = load ptr, ptr %tmp5.stack, align 8, !tcg.op !13
  tail call qemuaot void %T3.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %T3.rsi.stack, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %T3.v0.stack, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr %cpu, i32 225, i64 %T3.tmp6), !tcg.op !13
  ret void, !tcg.op !13
}

; Function Attrs: alwaysinline nounwind vscale_range(2,1024)
define weak qemuaot void @helper_pshufd_xmm_V0_V0(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %qemuaot_src1, i64 noundef %qemuaot_dst, i32 noundef signext %qemuaot_op, i64 noundef %rip, <vscale x 1 x i64> noundef %xmm0.coerce, <vscale x 1 x i64> noundef %ymm0_h.coerce, <vscale x 1 x i64> noundef %xmm1.coerce, <vscale x 1 x i64> noundef %ymm1_h.coerce, <vscale x 1 x i64> noundef %xmm2.coerce, <vscale x 1 x i64> noundef %ymm2_h.coerce, <vscale x 1 x i64> noundef %xmm3.coerce, <vscale x 1 x i64> noundef %ymm3_h.coerce, <vscale x 1 x i64> noundef %xmm4.coerce, <vscale x 1 x i64> noundef %ymm4_h.coerce, <vscale x 1 x i64> noundef %xmm5.coerce, <vscale x 1 x i64> noundef %ymm5_h.coerce, <vscale x 1 x i64> noundef %xmm6.coerce, <vscale x 1 x i64> noundef %ymm6_h.coerce, <vscale x 1 x i64> noundef %xmm7.coerce, <vscale x 1 x i64> noundef %ymm7_h.coerce, <vscale x 1 x i64> noundef %xmm8.coerce, <vscale x 1 x i64> noundef %ymm8_h.coerce, <vscale x 1 x i64> noundef %xmm9.coerce, <vscale x 1 x i64> noundef %ymm9_h.coerce, <vscale x 1 x i64> noundef %xmm10.coerce, <vscale x 1 x i64> noundef %ymm10_h.coerce, <vscale x 1 x i64> noundef %xmm11.coerce, <vscale x 1 x i64> noundef %ymm11_h.coerce, <vscale x 1 x i64> noundef %xmm12.coerce, <vscale x 1 x i64> noundef %ymm12_h.coerce, <vscale x 1 x i64> noundef %xmm13.coerce, <vscale x 1 x i64> noundef %ymm13_h.coerce, ptr noundef %cpu_param, i32 noundef signext %order, i64 noundef %normal_return) local_unnamed_addr #1 {
entry:
  %xmm0 = tail call <2 x i64> @llvm.vector.extract.v2i64.nxv1i64(<vscale x 1 x i64> %xmm0.coerce, i64 0)
  %and = and i32 %order, 3
  %shr = lshr i32 %order, 2
  %and28 = and i32 %shr, 3
  %shr31 = lshr i32 %order, 4
  %and32 = and i32 %shr31, 3
  %shr35 = lshr i32 %order, 6
  %and36 = and i32 %shr35, 3
  %0 = bitcast <2 x i64> %xmm0 to <4 x i32>
  %vecext = extractelement <4 x i32> %0, i32 %and
  %vecext30 = extractelement <4 x i32> %0, i32 %and28
  %vecext34 = extractelement <4 x i32> %0, i32 %and32
  %vecext38 = extractelement <4 x i32> %0, i32 %and36
  %vecins = insertelement <4 x i32> poison, i32 %vecext, i64 0
  %vecins41 = insertelement <4 x i32> %vecins, i32 %vecext30, i64 1
  %vecins44 = insertelement <4 x i32> %vecins41, i32 %vecext34, i64 2
  %vecins47 = insertelement <4 x i32> %vecins44, i32 %vecext38, i64 3
  %1 = bitcast <4 x i32> %vecins47 to <2 x i64>
  %2 = inttoptr i64 %normal_return to ptr
  %cast.scalable = tail call <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64(<vscale x 1 x i64> poison, <2 x i64> %1, i64 0)
  tail call qemuaot void %2(i64 noundef %rax, i64 noundef %rcx, i64 noundef %rdx, i64 noundef %rbx, i64 noundef %rsp, i64 noundef %rbp, i64 noundef %rsi, i64 noundef %rdi, i64 noundef %r8, i64 noundef %r9, i64 noundef %r10, i64 noundef %r11, i64 noundef %r12, i64 noundef %r13, i64 noundef %r14, i64 noundef %r15, i64 noundef %qemuaot_src1, i64 noundef %qemuaot_dst, i32 noundef signext %qemuaot_op, i64 noundef %rip, <vscale x 1 x i64> noundef %cast.scalable, <vscale x 1 x i64> noundef %ymm0_h.coerce, <vscale x 1 x i64> noundef %xmm1.coerce, <vscale x 1 x i64> noundef %ymm1_h.coerce, <vscale x 1 x i64> noundef %xmm2.coerce, <vscale x 1 x i64> noundef %ymm2_h.coerce, <vscale x 1 x i64> noundef %xmm3.coerce, <vscale x 1 x i64> noundef %ymm3_h.coerce, <vscale x 1 x i64> noundef %xmm4.coerce, <vscale x 1 x i64> noundef %ymm4_h.coerce, <vscale x 1 x i64> noundef %xmm5.coerce, <vscale x 1 x i64> noundef %ymm5_h.coerce, <vscale x 1 x i64> noundef %xmm6.coerce, <vscale x 1 x i64> noundef %ymm6_h.coerce, <vscale x 1 x i64> noundef %xmm7.coerce, <vscale x 1 x i64> noundef %ymm7_h.coerce, <vscale x 1 x i64> noundef %xmm8.coerce, <vscale x 1 x i64> noundef %ymm8_h.coerce, <vscale x 1 x i64> noundef %xmm9.coerce, <vscale x 1 x i64> noundef %ymm9_h.coerce, <vscale x 1 x i64> noundef %xmm10.coerce, <vscale x 1 x i64> noundef %ymm10_h.coerce, <vscale x 1 x i64> noundef %xmm11.coerce, <vscale x 1 x i64> noundef %ymm11_h.coerce, <vscale x 1 x i64> noundef %xmm12.coerce, <vscale x 1 x i64> noundef %ymm12_h.coerce, <vscale x 1 x i64> noundef %xmm13.coerce, <vscale x 1 x i64> noundef %ymm13_h.coerce, ptr noundef %cpu_param) #4
  ret void
}

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <2 x i64> @llvm.vector.extract.v2i64.nxv1i64(<vscale x 1 x i64>, i64 immarg) #2

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare <vscale x 1 x i64> @llvm.vector.insert.nxv1i64.v2i64(<vscale x 1 x i64>, <2 x i64>, i64 immarg) #2

; Function Attrs: noinline nounwind
define qemuaot void @Fx55aa_1(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %xmm0, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr align 8 dereferenceable(26544) %cpu) #0 section ".text.Fx55aa_1" {
entry:
  %rsi.stack = alloca i64, align 8
  store i64 %rsi, ptr %rsi.stack, align 8, !tbaa !7
  %v0.stack = alloca <vscale x 1 x i64>, align 16
  store <vscale x 1 x i64> %xmm0, ptr %v0.stack, align 16, !tbaa !7
  %tmp0.stack = alloca i64, align 8
  %tmp1.stack = alloca i64, align 8
  %tmp2.stack = alloca i64, align 8
  %tmp3.stack = alloca i64, align 8
  %tmp4.stack = alloca ptr, align 8
  %env = getelementptr i8, ptr %cpu, i64 11488
; ======== TCG [0] add_i64 [t3],rsi,0x10 ========
  %T0.rsi = load i64, ptr %rsi.stack, align 8, !tbaa !7, !tcg.op !14
  %T0.out = add i64 %T0.rsi, 16, !tcg.op !14
  store i64 %T0.out, ptr %tmp3.stack, align 8, !tbaa !7, !tcg.op !14
; ======== TCG [1] func_addr t4,0xaa55,0x0 ========
  store ptr @Fxaa55, ptr %tmp4.stack, align 8, !tbaa !7, !tcg.op !15
; ======== TCG [2] tail_call_qemuaot t4 VEC_ARGS: ========
  %T2.rsi.stack = load i64, ptr %rsi.stack, align 8, !tbaa !7, !tcg.op !16
  %T2.v0.stack = load <vscale x 1 x i64>, ptr %v0.stack, align 16, !tbaa !7, !tcg.op !16
  %T2.loaded_fn = load ptr, ptr %tmp4.stack, align 8, !tcg.op !16
  tail call qemuaot void %T2.loaded_fn(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %T2.rsi.stack, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <vscale x 1 x i64> %T2.v0.stack, <vscale x 1 x i64> %ymm0_h, <vscale x 1 x i64> %xmm1, <vscale x 1 x i64> %ymm1_h, <vscale x 1 x i64> %xmm2, <vscale x 1 x i64> %ymm2_h, <vscale x 1 x i64> %xmm3, <vscale x 1 x i64> %ymm3_h, <vscale x 1 x i64> %xmm4, <vscale x 1 x i64> %ymm4_h, <vscale x 1 x i64> %xmm5, <vscale x 1 x i64> %ymm5_h, <vscale x 1 x i64> %xmm6, <vscale x 1 x i64> %ymm6_h, <vscale x 1 x i64> %xmm7, <vscale x 1 x i64> %ymm7_h, <vscale x 1 x i64> %xmm8, <vscale x 1 x i64> %ymm8_h, <vscale x 1 x i64> %xmm9, <vscale x 1 x i64> %ymm9_h, <vscale x 1 x i64> %xmm10, <vscale x 1 x i64> %ymm10_h, <vscale x 1 x i64> %xmm11, <vscale x 1 x i64> %ymm11_h, <vscale x 1 x i64> %xmm12, <vscale x 1 x i64> %ymm12_h, <vscale x 1 x i64> %xmm13, <vscale x 1 x i64> %ymm13_h, ptr %cpu), !tcg.op !16
  ret void, !tcg.op !16
}

; Function Attrs: nounwind
declare qemuaot void @Fxaa55(i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i64, i32, i64, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, <vscale x 1 x i64>, ptr align 8 dereferenceable(26544)) #3 section ".text.Fxaa55"

attributes #0 = { noinline nounwind "target-features"="+m,+a,+f,+d,+v" }
attributes #1 = { alwaysinline nounwind vscale_range(2,1024) "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic-rv64" "target-features"="+64bit,+a,+d,+f,+m,+relax,+v,+zaamo,+zalrsc,+zicsr,+zmmul,+zve32f,+zve32x,+zve64d,+zve64f,+zve64x,+zvl128b,+zvl32b,+zvl64b,-b,-c,-e,-experimental-p,-experimental-smctr,-experimental-ssctr,-experimental-svukte,-experimental-xqccmp,-experimental-xqcia,-experimental-xqciac,-experimental-xqcibi,-experimental-xqcibm,-experimental-xqcicli,-experimental-xqcicm,-experimental-xqcics,-experimental-xqcicsr,-experimental-xqciint,-experimental-xqciio,-experimental-xqcilb,-experimental-xqcili,-experimental-xqcilia,-experimental-xqcilo,-experimental-xqcilsm,-experimental-xqcisim,-experimental-xqcisls,-experimental-xqcisync,-experimental-xrivosvisni,-experimental-xrivosvizip,-experimental-xsfmclic,-experimental-xsfsclic,-experimental-zalasr,-experimental-zicfilp,-experimental-zicfiss,-experimental-zvbc32e,-experimental-zvkgs,-experimental-zvqdotq,-h,-q,-sdext,-sdtrig,-sha,-shcounterenw,-shgatpa,-shlcofideleg,-shtvala,-shvsatpa,-shvstvala,-shvstvecd,-smaia,-smcdeleg,-smcntrpmf,-smcsrind,-smdbltrp,-smepmp,-smmpm,-smnpm,-smrnmi,-smstateen,-ssaia,-ssccfg,-ssccptr,-sscofpmf,-sscounterenw,-sscsrind,-ssdbltrp,-ssnpm,-sspm,-ssqosid,-ssstateen,-ssstrict,-sstc,-sstvala,-sstvecd,-ssu64xl,-supm,-svade,-svadu,-svbare,-svinval,-svnapot,-svpbmt,-svvptc,-xandesperf,-xandesvbfhcvt,-xandesvdot,-xandesvpackfph,-xandesvsintload,-xcvalu,-xcvbi,-xcvbitmanip,-xcvelw,-xcvmac,-xcvmem,-xcvsimd,-xmipscbop,-xmipscmov,-xmipslsp,-xsfcease,-xsfmm128t,-xsfmm16t,-xsfmm32a16f,-xsfmm32a32f,-xsfmm32a8f,-xsfmm32a8i,-xsfmm32t,-xsfmm64a64f,-xsfmm64t,-xsfmmbase,-xsfvcp,-xsfvfnrclipxfqf,-xsfvfwmaccqqq,-xsfvqmaccdod,-xsfvqmaccqoq,-xsifivecdiscarddlone,-xsifivecflushdlone,-xtheadba,-xtheadbb,-xtheadbs,-xtheadcmo,-xtheadcondmov,-xtheadfmemidx,-xtheadmac,-xtheadmemidx,-xtheadmempair,-xtheadsync,-xtheadvdot,-xventanacondops,-xwchc,-za128rs,-za64rs,-zabha,-zacas,-zama16b,-zawrs,-zba,-zbb,-zbc,-zbkb,-zbkc,-zbkx,-zbs,-zca,-zcb,-zcd,-zce,-zcf,-zclsd,-zcmop,-zcmp,-zcmt,-zdinx,-zfa,-zfbfmin,-zfh,-zfhmin,-zfinx,-zhinx,-zhinxmin,-zic64b,-zicbom,-zicbop,-zicboz,-ziccamoa,-ziccamoc,-ziccif,-zicclsm,-ziccrse,-zicntr,-zicond,-zifencei,-zihintntl,-zihintpause,-zihpm,-zilsd,-zimop,-zk,-zkn,-zknd,-zkne,-zknh,-zkr,-zks,-zksed,-zksh,-zkt,-ztso,-zvbb,-zvbc,-zvfbfmin,-zvfbfwma,-zvfh,-zvfhmin,-zvkb,-zvkg,-zvkn,-zvknc,-zvkned,-zvkng,-zvknha,-zvknhb,-zvks,-zvksc,-zvksed,-zvksg,-zvksh,-zvkt,-zvl1024b,-zvl16384b,-zvl2048b,-zvl256b,-zvl32768b,-zvl4096b,-zvl512b,-zvl65536b,-zvl8192b" }
attributes #2 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }
attributes #3 = { nounwind "target-features"="+m,+a,+f,+d,+v" }
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
!10 = !{!"[0] mov_i64 [t0],0xffffffffffffffe1"}
!11 = !{!"[1] func_addr t5,helper_pshufd_xmm,v0,v0"}
!12 = !{!"[2] func_addr t6,0x55aa,0x1"}
!13 = !{!"[3] tail_call_qemuaot t5,0xe1,t6 VEC_ARGS:v0,v0,"}
!14 = !{!"[0] add_i64 [t3],rsi,0x10"}
!15 = !{!"[1] func_addr t4,0xaa55,0x0"}
!16 = !{!"[2] tail_call_qemuaot t4 VEC_ARGS:"}
