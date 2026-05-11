; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define weak qemuaot void @trampoline_do_not_sync_vector_param2_env0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, i64 %param0, i64 %next, i64 %helper) #0 ".text.trampoline" {
entry:
  %env_ptr__aaak = call i64 asm sideeffect "mov $0, x25", "=r"()
  %trampoline_cnt_addr__aaal = sub i64 %env_ptr__aaak, 104
  %trampoline_cnt_ptr__aaam = inttoptr i64 %trampoline_cnt_addr__aaal to ptr
  %trampoline_cnt_before__aaan = load i64, ptr %trampoline_cnt_ptr__aaam, align 8
  %trampoline_cnt_val_updated__aaao = add i64 %trampoline_cnt_before__aaan, 1
  store i64 %trampoline_cnt_val_updated__aaao, ptr %trampoline_cnt_ptr__aaam, align 8
  %env_ptr__aaap = call i64 asm sideeffect "mov $0, x25", "=r"()
  %spill_fixed_addr__aaaq = add i64 %env_ptr__aaap, 0
  %spill_fixed_ptr__aaar = inttoptr i64 %spill_fixed_addr__aaaq to ptr
  store i64 %rax, ptr %spill_fixed_ptr__aaar, align 8
  %spill_fixed_addr__aaas = add i64 %env_ptr__aaap, 8
  %spill_fixed_ptr__aaat = inttoptr i64 %spill_fixed_addr__aaas to ptr
  store i64 %rcx, ptr %spill_fixed_ptr__aaat, align 8
  %spill_fixed_addr__aaau = add i64 %env_ptr__aaap, 16
  %spill_fixed_ptr__aaav = inttoptr i64 %spill_fixed_addr__aaau to ptr
  store i64 %rdx, ptr %spill_fixed_ptr__aaav, align 8
  %spill_fixed_addr__aaaw = add i64 %env_ptr__aaap, 24
  %spill_fixed_ptr__aaax = inttoptr i64 %spill_fixed_addr__aaaw to ptr
  store i64 %rbx, ptr %spill_fixed_ptr__aaax, align 8
  %spill_fixed_addr__aaay = add i64 %env_ptr__aaap, 32
  %spill_fixed_ptr__aaaz = inttoptr i64 %spill_fixed_addr__aaay to ptr
  store i64 %rsp, ptr %spill_fixed_ptr__aaaz, align 8
  %spill_fixed_addr__aaba = add i64 %env_ptr__aaap, 40
  %spill_fixed_ptr__aabb = inttoptr i64 %spill_fixed_addr__aaba to ptr
  store i64 %rbp, ptr %spill_fixed_ptr__aabb, align 8
  %spill_fixed_addr__aabc = add i64 %env_ptr__aaap, 48
  %spill_fixed_ptr__aabd = inttoptr i64 %spill_fixed_addr__aabc to ptr
  store i64 %rsi, ptr %spill_fixed_ptr__aabd, align 8
  %spill_fixed_addr__aabe = add i64 %env_ptr__aaap, 56
  %spill_fixed_ptr__aabf = inttoptr i64 %spill_fixed_addr__aabe to ptr
  store i64 %rdi, ptr %spill_fixed_ptr__aabf, align 8
  %spill_fixed_addr__aabg = add i64 %env_ptr__aaap, 64
  %spill_fixed_ptr__aabh = inttoptr i64 %spill_fixed_addr__aabg to ptr
  store i64 %r8, ptr %spill_fixed_ptr__aabh, align 8
  %spill_fixed_addr__aabi = add i64 %env_ptr__aaap, 72
  %spill_fixed_ptr__aabj = inttoptr i64 %spill_fixed_addr__aabi to ptr
  store i64 %r9, ptr %spill_fixed_ptr__aabj, align 8
  %spill_fixed_addr__aabk = add i64 %env_ptr__aaap, 80
  %spill_fixed_ptr__aabl = inttoptr i64 %spill_fixed_addr__aabk to ptr
  store i64 %r10, ptr %spill_fixed_ptr__aabl, align 8
  %spill_fixed_addr__aabm = add i64 %env_ptr__aaap, 88
  %spill_fixed_ptr__aabn = inttoptr i64 %spill_fixed_addr__aabm to ptr
  store i64 %r11, ptr %spill_fixed_ptr__aabn, align 8
  %spill_fixed_addr__aabo = add i64 %env_ptr__aaap, 96
  %spill_fixed_ptr__aabp = inttoptr i64 %spill_fixed_addr__aabo to ptr
  store i64 %r12, ptr %spill_fixed_ptr__aabp, align 8
  %spill_fixed_addr__aabq = add i64 %env_ptr__aaap, 104
  %spill_fixed_ptr__aabr = inttoptr i64 %spill_fixed_addr__aabq to ptr
  store i64 %r13, ptr %spill_fixed_ptr__aabr, align 8
  %spill_fixed_addr__aabs = add i64 %env_ptr__aaap, 112
  %spill_fixed_ptr__aabt = inttoptr i64 %spill_fixed_addr__aabs to ptr
  store i64 %r14, ptr %spill_fixed_ptr__aabt, align 8
  %spill_fixed_addr__aabu = add i64 %env_ptr__aaap, 120
  %spill_fixed_ptr__aabv = inttoptr i64 %spill_fixed_addr__aabu to ptr
  store i64 %r15, ptr %spill_fixed_ptr__aabv, align 8
  %spill_fixed_addr__aabw = add i64 %env_ptr__aaap, 152
  %spill_fixed_ptr__aabx = inttoptr i64 %spill_fixed_addr__aabw to ptr
  store i64 %cc_src, ptr %spill_fixed_ptr__aabx, align 8
  %spill_fixed_addr__aaby = add i64 %env_ptr__aaap, 144
  %spill_fixed_ptr__aabz = inttoptr i64 %spill_fixed_addr__aaby to ptr
  store i64 %cc_dst, ptr %spill_fixed_ptr__aabz, align 8
  %spill_fixed_addr__aaca = add i64 %env_ptr__aaap, 168
  %spill_fixed_ptr__aacb = inttoptr i64 %spill_fixed_addr__aaca to ptr
  store i32 %cc_op, ptr %spill_fixed_ptr__aacb, align 8
  %spill_fixed_addr__aacc = add i64 %env_ptr__aaap, 128
  %spill_fixed_ptr__aacd = inttoptr i64 %spill_fixed_addr__aacc to ptr
  store i64 %rip, ptr %spill_fixed_ptr__aacd, align 8
  %env_ptr__aace = call i64 asm sideeffect "mov $0, x25", "=r"()
  %helper_func__aacf = inttoptr i64 %helper to ptr
  call void %helper_func__aacf(i64 %env_ptr__aace, i64 %param0)
  %reload_fixed_addr__aacg = add i64 %env_ptr__aaap, 0
  %reload_fixed_ptr__aach = inttoptr i64 %reload_fixed_addr__aacg to ptr
  %reload_fixed_val__aaci = load i64, ptr %reload_fixed_ptr__aach, align 8
  %reload_fixed_addr__aacj = add i64 %env_ptr__aaap, 8
  %reload_fixed_ptr__aack = inttoptr i64 %reload_fixed_addr__aacj to ptr
  %reload_fixed_val__aacl = load i64, ptr %reload_fixed_ptr__aack, align 8
  %reload_fixed_addr__aacm = add i64 %env_ptr__aaap, 16
  %reload_fixed_ptr__aacn = inttoptr i64 %reload_fixed_addr__aacm to ptr
  %reload_fixed_val__aaco = load i64, ptr %reload_fixed_ptr__aacn, align 8
  %reload_fixed_addr__aacp = add i64 %env_ptr__aaap, 24
  %reload_fixed_ptr__aacq = inttoptr i64 %reload_fixed_addr__aacp to ptr
  %reload_fixed_val__aacr = load i64, ptr %reload_fixed_ptr__aacq, align 8
  %reload_fixed_addr__aacs = add i64 %env_ptr__aaap, 32
  %reload_fixed_ptr__aact = inttoptr i64 %reload_fixed_addr__aacs to ptr
  %reload_fixed_val__aacu = load i64, ptr %reload_fixed_ptr__aact, align 8
  %reload_fixed_addr__aacv = add i64 %env_ptr__aaap, 40
  %reload_fixed_ptr__aacw = inttoptr i64 %reload_fixed_addr__aacv to ptr
  %reload_fixed_val__aacx = load i64, ptr %reload_fixed_ptr__aacw, align 8
  %reload_fixed_addr__aacy = add i64 %env_ptr__aaap, 48
  %reload_fixed_ptr__aacz = inttoptr i64 %reload_fixed_addr__aacy to ptr
  %reload_fixed_val__aada = load i64, ptr %reload_fixed_ptr__aacz, align 8
  %reload_fixed_addr__aadb = add i64 %env_ptr__aaap, 56
  %reload_fixed_ptr__aadc = inttoptr i64 %reload_fixed_addr__aadb to ptr
  %reload_fixed_val__aadd = load i64, ptr %reload_fixed_ptr__aadc, align 8
  %reload_fixed_addr__aade = add i64 %env_ptr__aaap, 64
  %reload_fixed_ptr__aadf = inttoptr i64 %reload_fixed_addr__aade to ptr
  %reload_fixed_val__aadg = load i64, ptr %reload_fixed_ptr__aadf, align 8
  %reload_fixed_addr__aadh = add i64 %env_ptr__aaap, 72
  %reload_fixed_ptr__aadi = inttoptr i64 %reload_fixed_addr__aadh to ptr
  %reload_fixed_val__aadj = load i64, ptr %reload_fixed_ptr__aadi, align 8
  %reload_fixed_addr__aadk = add i64 %env_ptr__aaap, 80
  %reload_fixed_ptr__aadl = inttoptr i64 %reload_fixed_addr__aadk to ptr
  %reload_fixed_val__aadm = load i64, ptr %reload_fixed_ptr__aadl, align 8
  %reload_fixed_addr__aadn = add i64 %env_ptr__aaap, 88
  %reload_fixed_ptr__aado = inttoptr i64 %reload_fixed_addr__aadn to ptr
  %reload_fixed_val__aadp = load i64, ptr %reload_fixed_ptr__aado, align 8
  %reload_fixed_addr__aadq = add i64 %env_ptr__aaap, 96
  %reload_fixed_ptr__aadr = inttoptr i64 %reload_fixed_addr__aadq to ptr
  %reload_fixed_val__aads = load i64, ptr %reload_fixed_ptr__aadr, align 8
  %reload_fixed_addr__aadt = add i64 %env_ptr__aaap, 104
  %reload_fixed_ptr__aadu = inttoptr i64 %reload_fixed_addr__aadt to ptr
  %reload_fixed_val__aadv = load i64, ptr %reload_fixed_ptr__aadu, align 8
  %reload_fixed_addr__aadw = add i64 %env_ptr__aaap, 112
  %reload_fixed_ptr__aadx = inttoptr i64 %reload_fixed_addr__aadw to ptr
  %reload_fixed_val__aady = load i64, ptr %reload_fixed_ptr__aadx, align 8
  %reload_fixed_addr__aadz = add i64 %env_ptr__aaap, 120
  %reload_fixed_ptr__aaea = inttoptr i64 %reload_fixed_addr__aadz to ptr
  %reload_fixed_val__aaeb = load i64, ptr %reload_fixed_ptr__aaea, align 8
  %reload_fixed_addr__aaec = add i64 %env_ptr__aaap, 152
  %reload_fixed_ptr__aaed = inttoptr i64 %reload_fixed_addr__aaec to ptr
  %reload_fixed_val__aaee = load i64, ptr %reload_fixed_ptr__aaed, align 8
  %reload_fixed_addr__aaef = add i64 %env_ptr__aaap, 144
  %reload_fixed_ptr__aaeg = inttoptr i64 %reload_fixed_addr__aaef to ptr
  %reload_fixed_val__aaeh = load i64, ptr %reload_fixed_ptr__aaeg, align 8
  %reload_fixed_addr__aaei = add i64 %env_ptr__aaap, 168
  %reload_fixed_ptr__aaej = inttoptr i64 %reload_fixed_addr__aaei to ptr
  %reload_fixed_val__aaek = load i32, ptr %reload_fixed_ptr__aaej, align 8
  %reload_fixed_addr__aael = add i64 %env_ptr__aaap, 128
  %reload_fixed_ptr__aaem = inttoptr i64 %reload_fixed_addr__aael to ptr
  %reload_fixed_val__aaen = load i64, ptr %reload_fixed_ptr__aaem, align 8
  %next__aaeo = inttoptr i64 %next to ptr
  tail call qemuaot void %next__aaeo(i64 %reload_fixed_val__aaci, i64 %reload_fixed_val__aacl, i64 %reload_fixed_val__aaco, i64 %reload_fixed_val__aacr, i64 %reload_fixed_val__aacu, i64 %reload_fixed_val__aacx, i64 %reload_fixed_val__aada, i64 %reload_fixed_val__aadd, i64 %reload_fixed_val__aadg, i64 %reload_fixed_val__aadj, i64 %reload_fixed_val__aadm, i64 %reload_fixed_val__aadp, i64 %reload_fixed_val__aads, i64 %reload_fixed_val__aadv, i64 %reload_fixed_val__aady, i64 %reload_fixed_val__aaeb, i64 %reload_fixed_val__aaee, i64 %reload_fixed_val__aaeh, i32 %reload_fixed_val__aaek, i64 %reload_fixed_val__aaen)
  ret void
}

attributes #0 = { noinline nounwind "target-features"="+neon" }
