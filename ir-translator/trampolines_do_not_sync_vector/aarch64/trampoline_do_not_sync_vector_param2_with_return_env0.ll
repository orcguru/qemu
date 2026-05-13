; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define weak qemuaot void @trampoline_do_not_sync_vector_param2_with_return_env0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h, i64 %param0, i64 %next, i64 %helper) #0 section ".text.trampoline" {
entry:
  %env_ptr__aaaj = call i64 asm sideeffect "mov $0, x25", "=r"()
  %trampoline_cnt_addr__aaak = sub i64 %env_ptr__aaaj, 104
  %trampoline_cnt_ptr__aaal = inttoptr i64 %trampoline_cnt_addr__aaak to ptr
  %trampoline_cnt_before__aaam = load i64, ptr %trampoline_cnt_ptr__aaal, align 8
  %trampoline_cnt_val_updated__aaan = add i64 %trampoline_cnt_before__aaam, 1
  store i64 %trampoline_cnt_val_updated__aaan, ptr %trampoline_cnt_ptr__aaal, align 8
  %env_ptr__aaao = call i64 asm sideeffect "mov $0, x25", "=r"()
  %spill_fixed_addr__aaap = add i64 %env_ptr__aaao, 0
  %spill_fixed_ptr__aaaq = inttoptr i64 %spill_fixed_addr__aaap to ptr
  store i64 %rax, ptr %spill_fixed_ptr__aaaq, align 8
  %spill_fixed_addr__aaar = add i64 %env_ptr__aaao, 8
  %spill_fixed_ptr__aaas = inttoptr i64 %spill_fixed_addr__aaar to ptr
  store i64 %rcx, ptr %spill_fixed_ptr__aaas, align 8
  %spill_fixed_addr__aaat = add i64 %env_ptr__aaao, 16
  %spill_fixed_ptr__aaau = inttoptr i64 %spill_fixed_addr__aaat to ptr
  store i64 %rdx, ptr %spill_fixed_ptr__aaau, align 8
  %spill_fixed_addr__aaav = add i64 %env_ptr__aaao, 24
  %spill_fixed_ptr__aaaw = inttoptr i64 %spill_fixed_addr__aaav to ptr
  store i64 %rbx, ptr %spill_fixed_ptr__aaaw, align 8
  %spill_fixed_addr__aaax = add i64 %env_ptr__aaao, 32
  %spill_fixed_ptr__aaay = inttoptr i64 %spill_fixed_addr__aaax to ptr
  store i64 %rsp, ptr %spill_fixed_ptr__aaay, align 8
  %spill_fixed_addr__aaaz = add i64 %env_ptr__aaao, 40
  %spill_fixed_ptr__aaba = inttoptr i64 %spill_fixed_addr__aaaz to ptr
  store i64 %rbp, ptr %spill_fixed_ptr__aaba, align 8
  %spill_fixed_addr__aabb = add i64 %env_ptr__aaao, 48
  %spill_fixed_ptr__aabc = inttoptr i64 %spill_fixed_addr__aabb to ptr
  store i64 %rsi, ptr %spill_fixed_ptr__aabc, align 8
  %spill_fixed_addr__aabd = add i64 %env_ptr__aaao, 56
  %spill_fixed_ptr__aabe = inttoptr i64 %spill_fixed_addr__aabd to ptr
  store i64 %rdi, ptr %spill_fixed_ptr__aabe, align 8
  %spill_fixed_addr__aabf = add i64 %env_ptr__aaao, 64
  %spill_fixed_ptr__aabg = inttoptr i64 %spill_fixed_addr__aabf to ptr
  store i64 %r8, ptr %spill_fixed_ptr__aabg, align 8
  %spill_fixed_addr__aabh = add i64 %env_ptr__aaao, 72
  %spill_fixed_ptr__aabi = inttoptr i64 %spill_fixed_addr__aabh to ptr
  store i64 %r9, ptr %spill_fixed_ptr__aabi, align 8
  %spill_fixed_addr__aabj = add i64 %env_ptr__aaao, 80
  %spill_fixed_ptr__aabk = inttoptr i64 %spill_fixed_addr__aabj to ptr
  store i64 %r10, ptr %spill_fixed_ptr__aabk, align 8
  %spill_fixed_addr__aabl = add i64 %env_ptr__aaao, 88
  %spill_fixed_ptr__aabm = inttoptr i64 %spill_fixed_addr__aabl to ptr
  store i64 %r11, ptr %spill_fixed_ptr__aabm, align 8
  %spill_fixed_addr__aabn = add i64 %env_ptr__aaao, 96
  %spill_fixed_ptr__aabo = inttoptr i64 %spill_fixed_addr__aabn to ptr
  store i64 %r12, ptr %spill_fixed_ptr__aabo, align 8
  %spill_fixed_addr__aabp = add i64 %env_ptr__aaao, 104
  %spill_fixed_ptr__aabq = inttoptr i64 %spill_fixed_addr__aabp to ptr
  store i64 %r13, ptr %spill_fixed_ptr__aabq, align 8
  %spill_fixed_addr__aabr = add i64 %env_ptr__aaao, 112
  %spill_fixed_ptr__aabs = inttoptr i64 %spill_fixed_addr__aabr to ptr
  store i64 %r14, ptr %spill_fixed_ptr__aabs, align 8
  %spill_fixed_addr__aabt = add i64 %env_ptr__aaao, 120
  %spill_fixed_ptr__aabu = inttoptr i64 %spill_fixed_addr__aabt to ptr
  store i64 %r15, ptr %spill_fixed_ptr__aabu, align 8
  %spill_fixed_addr__aabv = add i64 %env_ptr__aaao, 152
  %spill_fixed_ptr__aabw = inttoptr i64 %spill_fixed_addr__aabv to ptr
  store i64 %cc_src, ptr %spill_fixed_ptr__aabw, align 8
  %spill_fixed_addr__aabx = add i64 %env_ptr__aaao, 144
  %spill_fixed_ptr__aaby = inttoptr i64 %spill_fixed_addr__aabx to ptr
  store i64 %cc_dst, ptr %spill_fixed_ptr__aaby, align 8
  %spill_fixed_addr__aabz = add i64 %env_ptr__aaao, 168
  %spill_fixed_ptr__aaca = inttoptr i64 %spill_fixed_addr__aabz to ptr
  store i32 %cc_op, ptr %spill_fixed_ptr__aaca, align 8
  %spill_fixed_addr__aacb = add i64 %env_ptr__aaao, 128
  %spill_fixed_ptr__aacc = inttoptr i64 %spill_fixed_addr__aacb to ptr
  store i64 %rip, ptr %spill_fixed_ptr__aacc, align 8
  %env_ptr__aacd = call i64 asm sideeffect "mov $0, x25", "=r"()
  %helper_func__aace = inttoptr i64 %helper to ptr
  %helper_return__aacf = call i64 %helper_func__aace(i64 %env_ptr__aacd, i64 %param0)
  %reload_fixed_addr__aacg = add i64 %env_ptr__aaao, 0
  %reload_fixed_ptr__aach = inttoptr i64 %reload_fixed_addr__aacg to ptr
  %reload_fixed_val__aaci = load i64, ptr %reload_fixed_ptr__aach, align 8
  %reload_fixed_addr__aacj = add i64 %env_ptr__aaao, 8
  %reload_fixed_ptr__aack = inttoptr i64 %reload_fixed_addr__aacj to ptr
  %reload_fixed_val__aacl = load i64, ptr %reload_fixed_ptr__aack, align 8
  %reload_fixed_addr__aacm = add i64 %env_ptr__aaao, 16
  %reload_fixed_ptr__aacn = inttoptr i64 %reload_fixed_addr__aacm to ptr
  %reload_fixed_val__aaco = load i64, ptr %reload_fixed_ptr__aacn, align 8
  %reload_fixed_addr__aacp = add i64 %env_ptr__aaao, 24
  %reload_fixed_ptr__aacq = inttoptr i64 %reload_fixed_addr__aacp to ptr
  %reload_fixed_val__aacr = load i64, ptr %reload_fixed_ptr__aacq, align 8
  %reload_fixed_addr__aacs = add i64 %env_ptr__aaao, 32
  %reload_fixed_ptr__aact = inttoptr i64 %reload_fixed_addr__aacs to ptr
  %reload_fixed_val__aacu = load i64, ptr %reload_fixed_ptr__aact, align 8
  %reload_fixed_addr__aacv = add i64 %env_ptr__aaao, 40
  %reload_fixed_ptr__aacw = inttoptr i64 %reload_fixed_addr__aacv to ptr
  %reload_fixed_val__aacx = load i64, ptr %reload_fixed_ptr__aacw, align 8
  %reload_fixed_addr__aacy = add i64 %env_ptr__aaao, 48
  %reload_fixed_ptr__aacz = inttoptr i64 %reload_fixed_addr__aacy to ptr
  %reload_fixed_val__aada = load i64, ptr %reload_fixed_ptr__aacz, align 8
  %reload_fixed_addr__aadb = add i64 %env_ptr__aaao, 56
  %reload_fixed_ptr__aadc = inttoptr i64 %reload_fixed_addr__aadb to ptr
  %reload_fixed_val__aadd = load i64, ptr %reload_fixed_ptr__aadc, align 8
  %reload_fixed_addr__aade = add i64 %env_ptr__aaao, 64
  %reload_fixed_ptr__aadf = inttoptr i64 %reload_fixed_addr__aade to ptr
  %reload_fixed_val__aadg = load i64, ptr %reload_fixed_ptr__aadf, align 8
  %reload_fixed_addr__aadh = add i64 %env_ptr__aaao, 72
  %reload_fixed_ptr__aadi = inttoptr i64 %reload_fixed_addr__aadh to ptr
  %reload_fixed_val__aadj = load i64, ptr %reload_fixed_ptr__aadi, align 8
  %reload_fixed_addr__aadk = add i64 %env_ptr__aaao, 80
  %reload_fixed_ptr__aadl = inttoptr i64 %reload_fixed_addr__aadk to ptr
  %reload_fixed_val__aadm = load i64, ptr %reload_fixed_ptr__aadl, align 8
  %reload_fixed_addr__aadn = add i64 %env_ptr__aaao, 88
  %reload_fixed_ptr__aado = inttoptr i64 %reload_fixed_addr__aadn to ptr
  %reload_fixed_val__aadp = load i64, ptr %reload_fixed_ptr__aado, align 8
  %reload_fixed_addr__aadq = add i64 %env_ptr__aaao, 96
  %reload_fixed_ptr__aadr = inttoptr i64 %reload_fixed_addr__aadq to ptr
  %reload_fixed_val__aads = load i64, ptr %reload_fixed_ptr__aadr, align 8
  %reload_fixed_addr__aadt = add i64 %env_ptr__aaao, 104
  %reload_fixed_ptr__aadu = inttoptr i64 %reload_fixed_addr__aadt to ptr
  %reload_fixed_val__aadv = load i64, ptr %reload_fixed_ptr__aadu, align 8
  %reload_fixed_addr__aadw = add i64 %env_ptr__aaao, 112
  %reload_fixed_ptr__aadx = inttoptr i64 %reload_fixed_addr__aadw to ptr
  %reload_fixed_val__aady = load i64, ptr %reload_fixed_ptr__aadx, align 8
  %reload_fixed_addr__aadz = add i64 %env_ptr__aaao, 120
  %reload_fixed_ptr__aaea = inttoptr i64 %reload_fixed_addr__aadz to ptr
  %reload_fixed_val__aaeb = load i64, ptr %reload_fixed_ptr__aaea, align 8
  %reload_fixed_addr__aaec = add i64 %env_ptr__aaao, 152
  %reload_fixed_ptr__aaed = inttoptr i64 %reload_fixed_addr__aaec to ptr
  %reload_fixed_val__aaee = load i64, ptr %reload_fixed_ptr__aaed, align 8
  %reload_fixed_addr__aaef = add i64 %env_ptr__aaao, 144
  %reload_fixed_ptr__aaeg = inttoptr i64 %reload_fixed_addr__aaef to ptr
  %reload_fixed_val__aaeh = load i64, ptr %reload_fixed_ptr__aaeg, align 8
  %reload_fixed_addr__aaei = add i64 %env_ptr__aaao, 168
  %reload_fixed_ptr__aaej = inttoptr i64 %reload_fixed_addr__aaei to ptr
  %reload_fixed_val__aaek = load i32, ptr %reload_fixed_ptr__aaej, align 8
  %reload_fixed_addr__aael = add i64 %env_ptr__aaao, 128
  %reload_fixed_ptr__aaem = inttoptr i64 %reload_fixed_addr__aael to ptr
  %reload_fixed_val__aaen = load i64, ptr %reload_fixed_ptr__aaem, align 8
  %next__aaeo = inttoptr i64 %next to ptr
  tail call qemuaot void %next__aaeo(i64 %reload_fixed_val__aaci, i64 %reload_fixed_val__aacl, i64 %reload_fixed_val__aaco, i64 %reload_fixed_val__aacr, i64 %reload_fixed_val__aacu, i64 %reload_fixed_val__aacx, i64 %reload_fixed_val__aada, i64 %reload_fixed_val__aadd, i64 %reload_fixed_val__aadg, i64 %reload_fixed_val__aadj, i64 %reload_fixed_val__aadm, i64 %reload_fixed_val__aadp, i64 %reload_fixed_val__aads, i64 %reload_fixed_val__aadv, i64 %reload_fixed_val__aady, i64 %reload_fixed_val__aaeb, i64 %reload_fixed_val__aaee, i64 %reload_fixed_val__aaeh, i32 %reload_fixed_val__aaek, i64 %reload_fixed_val__aaen, <2 x i64> %xmm0, <2 x i64> %ymm0_h, <2 x i64> %xmm1, <2 x i64> %ymm1_h, <2 x i64> %xmm2, <2 x i64> %ymm2_h, <2 x i64> %xmm3, <2 x i64> %ymm3_h, <2 x i64> %xmm4, <2 x i64> %ymm4_h, <2 x i64> %xmm5, <2 x i64> %ymm5_h, <2 x i64> %xmm6, <2 x i64> %ymm6_h, <2 x i64> %xmm7, <2 x i64> %ymm7_h, <2 x i64> %xmm8, <2 x i64> %ymm8_h, <2 x i64> %xmm9, <2 x i64> %ymm9_h, <2 x i64> %xmm10, <2 x i64> %ymm10_h, <2 x i64> %xmm11, <2 x i64> %ymm11_h, <2 x i64> %xmm12, <2 x i64> %ymm12_h, <2 x i64> %xmm13, <2 x i64> %ymm13_h, <2 x i64> %xmm14, <2 x i64> %ymm14_h, i64 %helper_return__aacf)
  ret void
}

attributes #0 = { noinline nounwind "target-features"="+neon" }
