typedef struct CodeFragment {
    unsigned long target_addr;
    unsigned long host_addr;
    struct CodeFragment *next;
} CodeFragment;

typedef unsigned long __attribute__((__vector_size__(16))) v2ulong;

typedef __attribute__((qemuaot)) void (*FuncPtrType1)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip, XMM_PARAM_DECLARE_COMMON);

typedef __attribute__((qemuaot)) void (*FuncPtrType2)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip, XMM_PARAM_DECLARE_COMMON, void *env, unsigned long target);

__attribute__((qemuaot,weak)) void jmp_ind_callback(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip, XMM_PARAM_DECLARE_COMMON, unsigned long target_addr, CodeFragment *list_ptr, unsigned long trampoline_helper_jit)
{
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
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, target_addr, XMM_PARAM_LIST);
    } else {
        FuncPtrType2 func_ptr = (FuncPtrType2)trampoline_helper_jit;
#if defined(__GNUC__) && defined(__aarch64__)
        void *env;
        asm volatile("mov %0, X25" : "=r"(env));
#elif defined(__GNUC__) && defined(__riscv64__)
        FIXME
#endif
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, target_addr, XMM_PARAM_LIST, env, target_addr);
    }
}
