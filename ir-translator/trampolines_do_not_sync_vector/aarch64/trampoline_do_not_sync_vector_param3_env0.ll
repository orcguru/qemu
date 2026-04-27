; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define weak qemuaot void @trampoline_do_not_sync_vector_param3_env0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, i64 %param0, i64 %param1, i64 %next, i64 %helper) #0 {
entry:
  %env_ptr__aaal = call i64 asm sideeffect "mov $0, x25", "=r"()
  %spill_fixed_addr__aaam = add i64 %env_ptr__aaal, 0
  %spill_fixed_ptr__aaan = inttoptr i64 %spill_fixed_addr__aaam to ptr
  store i64 %rax, ptr %spill_fixed_ptr__aaan, align 8
  %spill_fixed_addr__aaao = add i64 %env_ptr__aaal, 8
  %spill_fixed_ptr__aaap = inttoptr i64 %spill_fixed_addr__aaao to ptr
  store i64 %rcx, ptr %spill_fixed_ptr__aaap, align 8
  %spill_fixed_addr__aaaq = add i64 %env_ptr__aaal, 16
  %spill_fixed_ptr__aaar = inttoptr i64 %spill_fixed_addr__aaaq to ptr
  store i64 %rdx, ptr %spill_fixed_ptr__aaar, align 8
  %spill_fixed_addr__aaas = add i64 %env_ptr__aaal, 24
  %spill_fixed_ptr__aaat = inttoptr i64 %spill_fixed_addr__aaas to ptr
  store i64 %rbx, ptr %spill_fixed_ptr__aaat, align 8
  %spill_fixed_addr__aaau = add i64 %env_ptr__aaal, 32
  %spill_fixed_ptr__aaav = inttoptr i64 %spill_fixed_addr__aaau to ptr
  store i64 %rsp, ptr %spill_fixed_ptr__aaav, align 8
  %spill_fixed_addr__aaaw = add i64 %env_ptr__aaal, 40
  %spill_fixed_ptr__aaax = inttoptr i64 %spill_fixed_addr__aaaw to ptr
  store i64 %rbp, ptr %spill_fixed_ptr__aaax, align 8
  %spill_fixed_addr__aaay = add i64 %env_ptr__aaal, 48
  %spill_fixed_ptr__aaaz = inttoptr i64 %spill_fixed_addr__aaay to ptr
  store i64 %rsi, ptr %spill_fixed_ptr__aaaz, align 8
  %spill_fixed_addr__aaba = add i64 %env_ptr__aaal, 56
  %spill_fixed_ptr__aabb = inttoptr i64 %spill_fixed_addr__aaba to ptr
  store i64 %rdi, ptr %spill_fixed_ptr__aabb, align 8
  %spill_fixed_addr__aabc = add i64 %env_ptr__aaal, 64
  %spill_fixed_ptr__aabd = inttoptr i64 %spill_fixed_addr__aabc to ptr
  store i64 %r8, ptr %spill_fixed_ptr__aabd, align 8
  %spill_fixed_addr__aabe = add i64 %env_ptr__aaal, 72
  %spill_fixed_ptr__aabf = inttoptr i64 %spill_fixed_addr__aabe to ptr
  store i64 %r9, ptr %spill_fixed_ptr__aabf, align 8
  %spill_fixed_addr__aabg = add i64 %env_ptr__aaal, 80
  %spill_fixed_ptr__aabh = inttoptr i64 %spill_fixed_addr__aabg to ptr
  store i64 %r10, ptr %spill_fixed_ptr__aabh, align 8
  %spill_fixed_addr__aabi = add i64 %env_ptr__aaal, 88
  %spill_fixed_ptr__aabj = inttoptr i64 %spill_fixed_addr__aabi to ptr
  store i64 %r11, ptr %spill_fixed_ptr__aabj, align 8
  %spill_fixed_addr__aabk = add i64 %env_ptr__aaal, 96
  %spill_fixed_ptr__aabl = inttoptr i64 %spill_fixed_addr__aabk to ptr
  store i64 %r12, ptr %spill_fixed_ptr__aabl, align 8
  %spill_fixed_addr__aabm = add i64 %env_ptr__aaal, 104
  %spill_fixed_ptr__aabn = inttoptr i64 %spill_fixed_addr__aabm to ptr
  store i64 %r13, ptr %spill_fixed_ptr__aabn, align 8
  %spill_fixed_addr__aabo = add i64 %env_ptr__aaal, 112
  %spill_fixed_ptr__aabp = inttoptr i64 %spill_fixed_addr__aabo to ptr
  store i64 %r14, ptr %spill_fixed_ptr__aabp, align 8
  %spill_fixed_addr__aabq = add i64 %env_ptr__aaal, 120
  %spill_fixed_ptr__aabr = inttoptr i64 %spill_fixed_addr__aabq to ptr
  store i64 %r15, ptr %spill_fixed_ptr__aabr, align 8
  %spill_fixed_addr__aabs = add i64 %env_ptr__aaal, 152
  %spill_fixed_ptr__aabt = inttoptr i64 %spill_fixed_addr__aabs to ptr
  store i64 %cc_src, ptr %spill_fixed_ptr__aabt, align 8
  %spill_fixed_addr__aabu = add i64 %env_ptr__aaal, 144
  %spill_fixed_ptr__aabv = inttoptr i64 %spill_fixed_addr__aabu to ptr
  store i64 %cc_dst, ptr %spill_fixed_ptr__aabv, align 8
  %spill_fixed_addr__aabw = add i64 %env_ptr__aaal, 168
  %spill_fixed_ptr__aabx = inttoptr i64 %spill_fixed_addr__aabw to ptr
  store i32 %cc_op, ptr %spill_fixed_ptr__aabx, align 8
  %spill_fixed_addr__aaby = add i64 %env_ptr__aaal, 128
  %spill_fixed_ptr__aabz = inttoptr i64 %spill_fixed_addr__aaby to ptr
  store i64 %rip, ptr %spill_fixed_ptr__aabz, align 8
  %env_ptr__aaca = call i64 asm sideeffect "mov $0, x25", "=r"()
  %helper_func__aacb = inttoptr i64 %helper to ptr
  call void %helper_func__aacb(i64 %env_ptr__aaca, i64 %param0, i64 %param1)
  %reload_fixed_addr__aacc = add i64 %env_ptr__aaal, 0
  %reload_fixed_ptr__aacd = inttoptr i64 %reload_fixed_addr__aacc to ptr
  %reload_fixed_val__aace = load i64, ptr %reload_fixed_ptr__aacd, align 8
  %reload_fixed_addr__aacf = add i64 %env_ptr__aaal, 8
  %reload_fixed_ptr__aacg = inttoptr i64 %reload_fixed_addr__aacf to ptr
  %reload_fixed_val__aach = load i64, ptr %reload_fixed_ptr__aacg, align 8
  %reload_fixed_addr__aaci = add i64 %env_ptr__aaal, 16
  %reload_fixed_ptr__aacj = inttoptr i64 %reload_fixed_addr__aaci to ptr
  %reload_fixed_val__aack = load i64, ptr %reload_fixed_ptr__aacj, align 8
  %reload_fixed_addr__aacl = add i64 %env_ptr__aaal, 24
  %reload_fixed_ptr__aacm = inttoptr i64 %reload_fixed_addr__aacl to ptr
  %reload_fixed_val__aacn = load i64, ptr %reload_fixed_ptr__aacm, align 8
  %reload_fixed_addr__aaco = add i64 %env_ptr__aaal, 32
  %reload_fixed_ptr__aacp = inttoptr i64 %reload_fixed_addr__aaco to ptr
  %reload_fixed_val__aacq = load i64, ptr %reload_fixed_ptr__aacp, align 8
  %reload_fixed_addr__aacr = add i64 %env_ptr__aaal, 40
  %reload_fixed_ptr__aacs = inttoptr i64 %reload_fixed_addr__aacr to ptr
  %reload_fixed_val__aact = load i64, ptr %reload_fixed_ptr__aacs, align 8
  %reload_fixed_addr__aacu = add i64 %env_ptr__aaal, 48
  %reload_fixed_ptr__aacv = inttoptr i64 %reload_fixed_addr__aacu to ptr
  %reload_fixed_val__aacw = load i64, ptr %reload_fixed_ptr__aacv, align 8
  %reload_fixed_addr__aacx = add i64 %env_ptr__aaal, 56
  %reload_fixed_ptr__aacy = inttoptr i64 %reload_fixed_addr__aacx to ptr
  %reload_fixed_val__aacz = load i64, ptr %reload_fixed_ptr__aacy, align 8
  %reload_fixed_addr__aada = add i64 %env_ptr__aaal, 64
  %reload_fixed_ptr__aadb = inttoptr i64 %reload_fixed_addr__aada to ptr
  %reload_fixed_val__aadc = load i64, ptr %reload_fixed_ptr__aadb, align 8
  %reload_fixed_addr__aadd = add i64 %env_ptr__aaal, 72
  %reload_fixed_ptr__aade = inttoptr i64 %reload_fixed_addr__aadd to ptr
  %reload_fixed_val__aadf = load i64, ptr %reload_fixed_ptr__aade, align 8
  %reload_fixed_addr__aadg = add i64 %env_ptr__aaal, 80
  %reload_fixed_ptr__aadh = inttoptr i64 %reload_fixed_addr__aadg to ptr
  %reload_fixed_val__aadi = load i64, ptr %reload_fixed_ptr__aadh, align 8
  %reload_fixed_addr__aadj = add i64 %env_ptr__aaal, 88
  %reload_fixed_ptr__aadk = inttoptr i64 %reload_fixed_addr__aadj to ptr
  %reload_fixed_val__aadl = load i64, ptr %reload_fixed_ptr__aadk, align 8
  %reload_fixed_addr__aadm = add i64 %env_ptr__aaal, 96
  %reload_fixed_ptr__aadn = inttoptr i64 %reload_fixed_addr__aadm to ptr
  %reload_fixed_val__aado = load i64, ptr %reload_fixed_ptr__aadn, align 8
  %reload_fixed_addr__aadp = add i64 %env_ptr__aaal, 104
  %reload_fixed_ptr__aadq = inttoptr i64 %reload_fixed_addr__aadp to ptr
  %reload_fixed_val__aadr = load i64, ptr %reload_fixed_ptr__aadq, align 8
  %reload_fixed_addr__aads = add i64 %env_ptr__aaal, 112
  %reload_fixed_ptr__aadt = inttoptr i64 %reload_fixed_addr__aads to ptr
  %reload_fixed_val__aadu = load i64, ptr %reload_fixed_ptr__aadt, align 8
  %reload_fixed_addr__aadv = add i64 %env_ptr__aaal, 120
  %reload_fixed_ptr__aadw = inttoptr i64 %reload_fixed_addr__aadv to ptr
  %reload_fixed_val__aadx = load i64, ptr %reload_fixed_ptr__aadw, align 8
  %reload_fixed_addr__aady = add i64 %env_ptr__aaal, 152
  %reload_fixed_ptr__aadz = inttoptr i64 %reload_fixed_addr__aady to ptr
  %reload_fixed_val__aaea = load i64, ptr %reload_fixed_ptr__aadz, align 8
  %reload_fixed_addr__aaeb = add i64 %env_ptr__aaal, 144
  %reload_fixed_ptr__aaec = inttoptr i64 %reload_fixed_addr__aaeb to ptr
  %reload_fixed_val__aaed = load i64, ptr %reload_fixed_ptr__aaec, align 8
  %reload_fixed_addr__aaee = add i64 %env_ptr__aaal, 168
  %reload_fixed_ptr__aaef = inttoptr i64 %reload_fixed_addr__aaee to ptr
  %reload_fixed_val__aaeg = load i32, ptr %reload_fixed_ptr__aaef, align 8
  %reload_fixed_addr__aaeh = add i64 %env_ptr__aaal, 128
  %reload_fixed_ptr__aaei = inttoptr i64 %reload_fixed_addr__aaeh to ptr
  %reload_fixed_val__aaej = load i64, ptr %reload_fixed_ptr__aaei, align 8
  %next__aaek = inttoptr i64 %next to ptr
  tail call qemuaot void %next__aaek(i64 %reload_fixed_val__aace, i64 %reload_fixed_val__aach, i64 %reload_fixed_val__aack, i64 %reload_fixed_val__aacn, i64 %reload_fixed_val__aacq, i64 %reload_fixed_val__aact, i64 %reload_fixed_val__aacw, i64 %reload_fixed_val__aacz, i64 %reload_fixed_val__aadc, i64 %reload_fixed_val__aadf, i64 %reload_fixed_val__aadi, i64 %reload_fixed_val__aadl, i64 %reload_fixed_val__aado, i64 %reload_fixed_val__aadr, i64 %reload_fixed_val__aadu, i64 %reload_fixed_val__aadx, i64 %reload_fixed_val__aaea, i64 %reload_fixed_val__aaed, i32 %reload_fixed_val__aaeg, i64 %reload_fixed_val__aaej)
  ret void
}

attributes #0 = { noinline nounwind "target-features"="+neon" }
