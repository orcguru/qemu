; ModuleID = 'qemuaot'
source_filename = "qemuaot"
target triple = "riscv64-unknown-linux-gnu"

; Function Attrs: noinline nounwind
define weak qemuaot void @trampoline_do_not_sync_vector_param4_env0(i64 %rax, i64 %rcx, i64 %rdx, i64 %rbx, i64 %rsp, i64 %rbp, i64 %rsi, i64 %rdi, i64 %r8, i64 %r9, i64 %r10, i64 %r11, i64 %r12, i64 %r13, i64 %r14, i64 %r15, i64 %cc_src, i64 %cc_dst, i32 %cc_op, i64 %rip, i64 %param0, i64 %param1, i64 %param2, i64 %next, i64 %helper) #0 section ".text.trampoline" {
entry:
  %env_ptr__aaay = call i64 asm sideeffect "mv $0, x25", "=r"()
  %trampoline_cnt_addr__aaaz = sub i64 %env_ptr__aaay, 104
  %trampoline_cnt_ptr__aaba = inttoptr i64 %trampoline_cnt_addr__aaaz to ptr
  %trampoline_cnt_before__aabb = load i64, ptr %trampoline_cnt_ptr__aaba, align 8
  %trampoline_cnt_val_updated__aabc = add i64 %trampoline_cnt_before__aabb, 1
  store i64 %trampoline_cnt_val_updated__aabc, ptr %trampoline_cnt_ptr__aaba, align 8
  %env_ptr__aabd = call i64 asm sideeffect "mv $0, x25", "=r"()
  %spill_fixed_addr__aabe = add i64 %env_ptr__aabd, 0
  %spill_fixed_ptr__aabf = inttoptr i64 %spill_fixed_addr__aabe to ptr
  store i64 %rax, ptr %spill_fixed_ptr__aabf, align 8
  %spill_fixed_addr__aabg = add i64 %env_ptr__aabd, 8
  %spill_fixed_ptr__aabh = inttoptr i64 %spill_fixed_addr__aabg to ptr
  store i64 %rcx, ptr %spill_fixed_ptr__aabh, align 8
  %spill_fixed_addr__aabi = add i64 %env_ptr__aabd, 16
  %spill_fixed_ptr__aabj = inttoptr i64 %spill_fixed_addr__aabi to ptr
  store i64 %rdx, ptr %spill_fixed_ptr__aabj, align 8
  %spill_fixed_addr__aabk = add i64 %env_ptr__aabd, 24
  %spill_fixed_ptr__aabl = inttoptr i64 %spill_fixed_addr__aabk to ptr
  store i64 %rbx, ptr %spill_fixed_ptr__aabl, align 8
  %spill_fixed_addr__aabm = add i64 %env_ptr__aabd, 32
  %spill_fixed_ptr__aabn = inttoptr i64 %spill_fixed_addr__aabm to ptr
  store i64 %rsp, ptr %spill_fixed_ptr__aabn, align 8
  %spill_fixed_addr__aabo = add i64 %env_ptr__aabd, 40
  %spill_fixed_ptr__aabp = inttoptr i64 %spill_fixed_addr__aabo to ptr
  store i64 %rbp, ptr %spill_fixed_ptr__aabp, align 8
  %spill_fixed_addr__aabq = add i64 %env_ptr__aabd, 48
  %spill_fixed_ptr__aabr = inttoptr i64 %spill_fixed_addr__aabq to ptr
  store i64 %rsi, ptr %spill_fixed_ptr__aabr, align 8
  %spill_fixed_addr__aabs = add i64 %env_ptr__aabd, 56
  %spill_fixed_ptr__aabt = inttoptr i64 %spill_fixed_addr__aabs to ptr
  store i64 %rdi, ptr %spill_fixed_ptr__aabt, align 8
  %spill_fixed_addr__aabu = add i64 %env_ptr__aabd, 64
  %spill_fixed_ptr__aabv = inttoptr i64 %spill_fixed_addr__aabu to ptr
  store i64 %r8, ptr %spill_fixed_ptr__aabv, align 8
  %spill_fixed_addr__aabw = add i64 %env_ptr__aabd, 72
  %spill_fixed_ptr__aabx = inttoptr i64 %spill_fixed_addr__aabw to ptr
  store i64 %r9, ptr %spill_fixed_ptr__aabx, align 8
  %spill_fixed_addr__aaby = add i64 %env_ptr__aabd, 80
  %spill_fixed_ptr__aabz = inttoptr i64 %spill_fixed_addr__aaby to ptr
  store i64 %r10, ptr %spill_fixed_ptr__aabz, align 8
  %spill_fixed_addr__aaca = add i64 %env_ptr__aabd, 88
  %spill_fixed_ptr__aacb = inttoptr i64 %spill_fixed_addr__aaca to ptr
  store i64 %r11, ptr %spill_fixed_ptr__aacb, align 8
  %spill_fixed_addr__aacc = add i64 %env_ptr__aabd, 96
  %spill_fixed_ptr__aacd = inttoptr i64 %spill_fixed_addr__aacc to ptr
  store i64 %r12, ptr %spill_fixed_ptr__aacd, align 8
  %spill_fixed_addr__aace = add i64 %env_ptr__aabd, 104
  %spill_fixed_ptr__aacf = inttoptr i64 %spill_fixed_addr__aace to ptr
  store i64 %r13, ptr %spill_fixed_ptr__aacf, align 8
  %spill_fixed_addr__aacg = add i64 %env_ptr__aabd, 112
  %spill_fixed_ptr__aach = inttoptr i64 %spill_fixed_addr__aacg to ptr
  store i64 %r14, ptr %spill_fixed_ptr__aach, align 8
  %spill_fixed_addr__aaci = add i64 %env_ptr__aabd, 120
  %spill_fixed_ptr__aacj = inttoptr i64 %spill_fixed_addr__aaci to ptr
  store i64 %r15, ptr %spill_fixed_ptr__aacj, align 8
  %spill_fixed_addr__aack = add i64 %env_ptr__aabd, 152
  %spill_fixed_ptr__aacl = inttoptr i64 %spill_fixed_addr__aack to ptr
  store i64 %cc_src, ptr %spill_fixed_ptr__aacl, align 8
  %spill_fixed_addr__aacm = add i64 %env_ptr__aabd, 144
  %spill_fixed_ptr__aacn = inttoptr i64 %spill_fixed_addr__aacm to ptr
  store i64 %cc_dst, ptr %spill_fixed_ptr__aacn, align 8
  %spill_fixed_addr__aaco = add i64 %env_ptr__aabd, 168
  %spill_fixed_ptr__aacp = inttoptr i64 %spill_fixed_addr__aaco to ptr
  store i32 %cc_op, ptr %spill_fixed_ptr__aacp, align 8
  %spill_fixed_addr__aacq = add i64 %env_ptr__aabd, 128
  %spill_fixed_ptr__aacr = inttoptr i64 %spill_fixed_addr__aacq to ptr
  store i64 %rip, ptr %spill_fixed_ptr__aacr, align 8
  %env_ptr__aacs = call i64 asm sideeffect "mv $0, x25", "=r"()
  %helper_func__aact = inttoptr i64 %helper to ptr
  call void %helper_func__aact(i64 %env_ptr__aacs, i64 %param0, i64 %param1, i64 %param2)
  %reload_fixed_addr__aacu = add i64 %env_ptr__aabd, 0
  %reload_fixed_ptr__aacv = inttoptr i64 %reload_fixed_addr__aacu to ptr
  %reload_fixed_val__aacw = load i64, ptr %reload_fixed_ptr__aacv, align 8
  %reload_fixed_addr__aacx = add i64 %env_ptr__aabd, 8
  %reload_fixed_ptr__aacy = inttoptr i64 %reload_fixed_addr__aacx to ptr
  %reload_fixed_val__aacz = load i64, ptr %reload_fixed_ptr__aacy, align 8
  %reload_fixed_addr__aada = add i64 %env_ptr__aabd, 16
  %reload_fixed_ptr__aadb = inttoptr i64 %reload_fixed_addr__aada to ptr
  %reload_fixed_val__aadc = load i64, ptr %reload_fixed_ptr__aadb, align 8
  %reload_fixed_addr__aadd = add i64 %env_ptr__aabd, 24
  %reload_fixed_ptr__aade = inttoptr i64 %reload_fixed_addr__aadd to ptr
  %reload_fixed_val__aadf = load i64, ptr %reload_fixed_ptr__aade, align 8
  %reload_fixed_addr__aadg = add i64 %env_ptr__aabd, 32
  %reload_fixed_ptr__aadh = inttoptr i64 %reload_fixed_addr__aadg to ptr
  %reload_fixed_val__aadi = load i64, ptr %reload_fixed_ptr__aadh, align 8
  %reload_fixed_addr__aadj = add i64 %env_ptr__aabd, 40
  %reload_fixed_ptr__aadk = inttoptr i64 %reload_fixed_addr__aadj to ptr
  %reload_fixed_val__aadl = load i64, ptr %reload_fixed_ptr__aadk, align 8
  %reload_fixed_addr__aadm = add i64 %env_ptr__aabd, 48
  %reload_fixed_ptr__aadn = inttoptr i64 %reload_fixed_addr__aadm to ptr
  %reload_fixed_val__aado = load i64, ptr %reload_fixed_ptr__aadn, align 8
  %reload_fixed_addr__aadp = add i64 %env_ptr__aabd, 56
  %reload_fixed_ptr__aadq = inttoptr i64 %reload_fixed_addr__aadp to ptr
  %reload_fixed_val__aadr = load i64, ptr %reload_fixed_ptr__aadq, align 8
  %reload_fixed_addr__aads = add i64 %env_ptr__aabd, 64
  %reload_fixed_ptr__aadt = inttoptr i64 %reload_fixed_addr__aads to ptr
  %reload_fixed_val__aadu = load i64, ptr %reload_fixed_ptr__aadt, align 8
  %reload_fixed_addr__aadv = add i64 %env_ptr__aabd, 72
  %reload_fixed_ptr__aadw = inttoptr i64 %reload_fixed_addr__aadv to ptr
  %reload_fixed_val__aadx = load i64, ptr %reload_fixed_ptr__aadw, align 8
  %reload_fixed_addr__aady = add i64 %env_ptr__aabd, 80
  %reload_fixed_ptr__aadz = inttoptr i64 %reload_fixed_addr__aady to ptr
  %reload_fixed_val__aaea = load i64, ptr %reload_fixed_ptr__aadz, align 8
  %reload_fixed_addr__aaeb = add i64 %env_ptr__aabd, 88
  %reload_fixed_ptr__aaec = inttoptr i64 %reload_fixed_addr__aaeb to ptr
  %reload_fixed_val__aaed = load i64, ptr %reload_fixed_ptr__aaec, align 8
  %reload_fixed_addr__aaee = add i64 %env_ptr__aabd, 96
  %reload_fixed_ptr__aaef = inttoptr i64 %reload_fixed_addr__aaee to ptr
  %reload_fixed_val__aaeg = load i64, ptr %reload_fixed_ptr__aaef, align 8
  %reload_fixed_addr__aaeh = add i64 %env_ptr__aabd, 104
  %reload_fixed_ptr__aaei = inttoptr i64 %reload_fixed_addr__aaeh to ptr
  %reload_fixed_val__aaej = load i64, ptr %reload_fixed_ptr__aaei, align 8
  %reload_fixed_addr__aaek = add i64 %env_ptr__aabd, 112
  %reload_fixed_ptr__aael = inttoptr i64 %reload_fixed_addr__aaek to ptr
  %reload_fixed_val__aaem = load i64, ptr %reload_fixed_ptr__aael, align 8
  %reload_fixed_addr__aaen = add i64 %env_ptr__aabd, 120
  %reload_fixed_ptr__aaeo = inttoptr i64 %reload_fixed_addr__aaen to ptr
  %reload_fixed_val__aaep = load i64, ptr %reload_fixed_ptr__aaeo, align 8
  %reload_fixed_addr__aaeq = add i64 %env_ptr__aabd, 152
  %reload_fixed_ptr__aaer = inttoptr i64 %reload_fixed_addr__aaeq to ptr
  %reload_fixed_val__aaes = load i64, ptr %reload_fixed_ptr__aaer, align 8
  %reload_fixed_addr__aaet = add i64 %env_ptr__aabd, 144
  %reload_fixed_ptr__aaeu = inttoptr i64 %reload_fixed_addr__aaet to ptr
  %reload_fixed_val__aaev = load i64, ptr %reload_fixed_ptr__aaeu, align 8
  %reload_fixed_addr__aaew = add i64 %env_ptr__aabd, 168
  %reload_fixed_ptr__aaex = inttoptr i64 %reload_fixed_addr__aaew to ptr
  %reload_fixed_val__aaey = load i32, ptr %reload_fixed_ptr__aaex, align 8
  %reload_fixed_addr__aaez = add i64 %env_ptr__aabd, 128
  %reload_fixed_ptr__aafa = inttoptr i64 %reload_fixed_addr__aaez to ptr
  %reload_fixed_val__aafb = load i64, ptr %reload_fixed_ptr__aafa, align 8
  %next__aafc = inttoptr i64 %next to ptr
  tail call qemuaot void %next__aafc(i64 %reload_fixed_val__aacw, i64 %reload_fixed_val__aacz, i64 %reload_fixed_val__aadc, i64 %reload_fixed_val__aadf, i64 %reload_fixed_val__aadi, i64 %reload_fixed_val__aadl, i64 %reload_fixed_val__aado, i64 %reload_fixed_val__aadr, i64 %reload_fixed_val__aadu, i64 %reload_fixed_val__aadx, i64 %reload_fixed_val__aaea, i64 %reload_fixed_val__aaed, i64 %reload_fixed_val__aaeg, i64 %reload_fixed_val__aaej, i64 %reload_fixed_val__aaem, i64 %reload_fixed_val__aaep, i64 %reload_fixed_val__aaes, i64 %reload_fixed_val__aaev, i32 %reload_fixed_val__aaey, i64 %reload_fixed_val__aafb)
  ret void
}

attributes #0 = { noinline nounwind "target-features"="+m,+a,+f,+d,+v" }
