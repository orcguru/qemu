; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "riscv64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define weak qemuaot void @trampoline_do_not_sync_vector_param1_env0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, i64 %next, i64 %helper) #0 section ".text.trampoline" {
entry:
  %env_ptr__aaaj = call i64 asm sideeffect "mv $0, x25", "=r"()
  %trampoline_cnt_addr__aaak = sub i64 %env_ptr__aaaj, 104
  %trampoline_cnt_ptr__aaal = inttoptr i64 %trampoline_cnt_addr__aaak to ptr
  %trampoline_cnt_before__aaam = load i64, ptr %trampoline_cnt_ptr__aaal, align 8
  %trampoline_cnt_val_updated__aaan = add i64 %trampoline_cnt_before__aaam, 1
  store i64 %trampoline_cnt_val_updated__aaan, ptr %trampoline_cnt_ptr__aaal, align 8
  %env_ptr__aaao = call i64 asm sideeffect "mv $0, x25", "=r"()
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
  %env_ptr__aacd = call i64 asm sideeffect "mv $0, x25", "=r"()
  %helper_func__aace = inttoptr i64 %helper to ptr
  call void %helper_func__aace(i64 %env_ptr__aacd)
  %reload_fixed_addr__aacf = add i64 %env_ptr__aaao, 0
  %reload_fixed_ptr__aacg = inttoptr i64 %reload_fixed_addr__aacf to ptr
  %reload_fixed_val__aach = load i64, ptr %reload_fixed_ptr__aacg, align 8
  %reload_fixed_addr__aaci = add i64 %env_ptr__aaao, 8
  %reload_fixed_ptr__aacj = inttoptr i64 %reload_fixed_addr__aaci to ptr
  %reload_fixed_val__aack = load i64, ptr %reload_fixed_ptr__aacj, align 8
  %reload_fixed_addr__aacl = add i64 %env_ptr__aaao, 16
  %reload_fixed_ptr__aacm = inttoptr i64 %reload_fixed_addr__aacl to ptr
  %reload_fixed_val__aacn = load i64, ptr %reload_fixed_ptr__aacm, align 8
  %reload_fixed_addr__aaco = add i64 %env_ptr__aaao, 24
  %reload_fixed_ptr__aacp = inttoptr i64 %reload_fixed_addr__aaco to ptr
  %reload_fixed_val__aacq = load i64, ptr %reload_fixed_ptr__aacp, align 8
  %reload_fixed_addr__aacr = add i64 %env_ptr__aaao, 32
  %reload_fixed_ptr__aacs = inttoptr i64 %reload_fixed_addr__aacr to ptr
  %reload_fixed_val__aact = load i64, ptr %reload_fixed_ptr__aacs, align 8
  %reload_fixed_addr__aacu = add i64 %env_ptr__aaao, 40
  %reload_fixed_ptr__aacv = inttoptr i64 %reload_fixed_addr__aacu to ptr
  %reload_fixed_val__aacw = load i64, ptr %reload_fixed_ptr__aacv, align 8
  %reload_fixed_addr__aacx = add i64 %env_ptr__aaao, 48
  %reload_fixed_ptr__aacy = inttoptr i64 %reload_fixed_addr__aacx to ptr
  %reload_fixed_val__aacz = load i64, ptr %reload_fixed_ptr__aacy, align 8
  %reload_fixed_addr__aada = add i64 %env_ptr__aaao, 56
  %reload_fixed_ptr__aadb = inttoptr i64 %reload_fixed_addr__aada to ptr
  %reload_fixed_val__aadc = load i64, ptr %reload_fixed_ptr__aadb, align 8
  %reload_fixed_addr__aadd = add i64 %env_ptr__aaao, 64
  %reload_fixed_ptr__aade = inttoptr i64 %reload_fixed_addr__aadd to ptr
  %reload_fixed_val__aadf = load i64, ptr %reload_fixed_ptr__aade, align 8
  %reload_fixed_addr__aadg = add i64 %env_ptr__aaao, 72
  %reload_fixed_ptr__aadh = inttoptr i64 %reload_fixed_addr__aadg to ptr
  %reload_fixed_val__aadi = load i64, ptr %reload_fixed_ptr__aadh, align 8
  %reload_fixed_addr__aadj = add i64 %env_ptr__aaao, 80
  %reload_fixed_ptr__aadk = inttoptr i64 %reload_fixed_addr__aadj to ptr
  %reload_fixed_val__aadl = load i64, ptr %reload_fixed_ptr__aadk, align 8
  %reload_fixed_addr__aadm = add i64 %env_ptr__aaao, 88
  %reload_fixed_ptr__aadn = inttoptr i64 %reload_fixed_addr__aadm to ptr
  %reload_fixed_val__aado = load i64, ptr %reload_fixed_ptr__aadn, align 8
  %reload_fixed_addr__aadp = add i64 %env_ptr__aaao, 96
  %reload_fixed_ptr__aadq = inttoptr i64 %reload_fixed_addr__aadp to ptr
  %reload_fixed_val__aadr = load i64, ptr %reload_fixed_ptr__aadq, align 8
  %reload_fixed_addr__aads = add i64 %env_ptr__aaao, 104
  %reload_fixed_ptr__aadt = inttoptr i64 %reload_fixed_addr__aads to ptr
  %reload_fixed_val__aadu = load i64, ptr %reload_fixed_ptr__aadt, align 8
  %reload_fixed_addr__aadv = add i64 %env_ptr__aaao, 112
  %reload_fixed_ptr__aadw = inttoptr i64 %reload_fixed_addr__aadv to ptr
  %reload_fixed_val__aadx = load i64, ptr %reload_fixed_ptr__aadw, align 8
  %reload_fixed_addr__aady = add i64 %env_ptr__aaao, 120
  %reload_fixed_ptr__aadz = inttoptr i64 %reload_fixed_addr__aady to ptr
  %reload_fixed_val__aaea = load i64, ptr %reload_fixed_ptr__aadz, align 8
  %reload_fixed_addr__aaeb = add i64 %env_ptr__aaao, 152
  %reload_fixed_ptr__aaec = inttoptr i64 %reload_fixed_addr__aaeb to ptr
  %reload_fixed_val__aaed = load i64, ptr %reload_fixed_ptr__aaec, align 8
  %reload_fixed_addr__aaee = add i64 %env_ptr__aaao, 144
  %reload_fixed_ptr__aaef = inttoptr i64 %reload_fixed_addr__aaee to ptr
  %reload_fixed_val__aaeg = load i64, ptr %reload_fixed_ptr__aaef, align 8
  %reload_fixed_addr__aaeh = add i64 %env_ptr__aaao, 168
  %reload_fixed_ptr__aaei = inttoptr i64 %reload_fixed_addr__aaeh to ptr
  %reload_fixed_val__aaej = load i32, ptr %reload_fixed_ptr__aaei, align 8
  %reload_fixed_addr__aaek = add i64 %env_ptr__aaao, 128
  %reload_fixed_ptr__aael = inttoptr i64 %reload_fixed_addr__aaek to ptr
  %reload_fixed_val__aaem = load i64, ptr %reload_fixed_ptr__aael, align 8
  %next__aaen = inttoptr i64 %next to ptr
  tail call qemuaot void %next__aaen(i64 %reload_fixed_val__aach, i64 %reload_fixed_val__aack, i64 %reload_fixed_val__aacn, i64 %reload_fixed_val__aacq, i64 %reload_fixed_val__aact, i64 %reload_fixed_val__aacw, i64 %reload_fixed_val__aacz, i64 %reload_fixed_val__aadc, i64 %reload_fixed_val__aadf, i64 %reload_fixed_val__aadi, i64 %reload_fixed_val__aadl, i64 %reload_fixed_val__aado, i64 %reload_fixed_val__aadr, i64 %reload_fixed_val__aadu, i64 %reload_fixed_val__aadx, i64 %reload_fixed_val__aaea, i64 %reload_fixed_val__aaed, i64 %reload_fixed_val__aaeg, i32 %reload_fixed_val__aaej, i64 %reload_fixed_val__aaem)
  ret void
}

attributes #0 = { noinline nounwind "target-features"="+m,+a,+f,+d,+v" }
