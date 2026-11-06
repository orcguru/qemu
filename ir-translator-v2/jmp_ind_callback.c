#include "qemu_cpu_sizes.h"

typedef unsigned long __attribute__((__vector_size__(16))) v2ulong;

typedef __attribute__((qemuaot,nothrow)) void (*FuncPtrType1)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip XMM_PARAM_DECLARE_COMMON, unsigned long cpu_param);

typedef __attribute__((qemuaot,nothrow)) void (*FuncPtrType2)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip XMM_PARAM_DECLARE_COMMON, unsigned long cpu_param, unsigned long env, unsigned long target);

__attribute__((qemuaot,weak,nothrow)) void jmp_ind_callback(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip XMM_PARAM_DECLARE_COMMON, unsigned long cpu_param, unsigned long host_addr, unsigned long trampoline_helper_jit)
{
    if (host_addr) {
        FuncPtrType1 func_ptr = (FuncPtrType1)host_addr;
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, rip XMM_PARAM_LIST, cpu_param);
    } else {
        FuncPtrType2 func_ptr = (FuncPtrType2)trampoline_helper_jit;
        unsigned long env = cpu_param + QEMU_OFFSETOF_ENV_IN_ARCHCPU;
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, rip XMM_PARAM_LIST, cpu_param, env, rip);
    }
}
