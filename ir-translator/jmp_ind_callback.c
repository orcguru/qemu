typedef struct CodeFragment {
    unsigned long target_addr;
    unsigned long host_addr;
    struct CodeFragment *next;
} CodeFragment;

typedef unsigned long __attribute__((__vector_size__(16))) v2ulong;

typedef __attribute__((qemuaot,nothrow)) void (*FuncPtrType1)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip XMM_PARAM_DECLARE_COMMON);

typedef __attribute__((qemuaot,nothrow)) void (*FuncPtrType2)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip XMM_PARAM_DECLARE_COMMON, unsigned long env, unsigned long target);

__attribute__((qemuaot,weak,nothrow)) void jmp_ind_callback(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip XMM_PARAM_DECLARE_COMMON, unsigned long target_addr, CodeFragment *list_ptr, unsigned long trampoline_helper_jit, unsigned long shadow_array_entry)
{
    unsigned long env_val;
#if defined(__aarch64__) && !defined(BUILD_RISCV_ON_AARCH)
    asm volatile ("mov %0, x25" : "=r" (env_val) : :);
#elif (defined(__riscv) && __riscv_xlen == 64) || defined(BUILD_RISCV_ON_AARCH)
    asm volatile ("mv %0, x25" : "=r" (env_val) : :);
#endif
#ifdef HELPER_COUNTERS
    unsigned long *jmp_ind_callback_cnt_ptr = (unsigned long *)(env_val - 112);
    *jmp_ind_callback_cnt_ptr += 1;
#endif

    unsigned long host_addr = 0;
    while (list_ptr) {
        if (list_ptr->target_addr == target_addr) {
            host_addr = list_ptr->host_addr;
            break;
        }
        list_ptr = list_ptr->next;
    }
    if (host_addr) {
        FuncPtrType1 func_ptr = (FuncPtrType1)host_addr;
        if (shadow_array_entry != 0) {
            unsigned long *shadow_entry_ptr = (unsigned long *)(shadow_array_entry & 0xfffffffffffffff0UL);
            const int cnt = 1;
            // FIXME: atomic store
            for (int i = 0; i < cnt; ++i) {
                if (shadow_entry_ptr[2*i] == 0) {
                    shadow_entry_ptr[2*i] = target_addr;
                    shadow_entry_ptr[2*i+1] = host_addr;
                    break;
                }
            }
        }
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, target_addr XMM_PARAM_LIST);
    } else {
        FuncPtrType2 func_ptr = (FuncPtrType2)trampoline_helper_jit;
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, target_addr XMM_PARAM_LIST, env_val, target_addr);
    }
}
