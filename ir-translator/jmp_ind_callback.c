typedef struct CodeFragment {
    unsigned long target_addr;
    unsigned long host_addr;
    struct CodeFragment *next;
} CodeFragment;

typedef unsigned long __attribute__((__vector_size__(16))) v2long;

typedef __attribute__((qemuaot)) void (*FuncPtrType1)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip, v2long xmm0, v2long ymm0_h, v2long xmm1, v2long ymm1_h, v2long xmm2, v2long ymm2_h, v2long xmm3, v2long ymm3_h, v2long xmm4, v2long ymm4_h, v2long xmm5, v2long ymm5_h, v2long xmm6, v2long ymm6_h, v2long xmm7, v2long ymm7_h, v2long xmm8, v2long ymm8_h, v2long xmm9, v2long ymm9_h, v2long xmm10, v2long ymm10_h, v2long xmm11, v2long ymm11_h, v2long xmm12, v2long ymm12_h, v2long xmm13, v2long ymm13_h, v2long xmm14, v2long ymm14_h);

typedef __attribute__((qemuaot)) void (*FuncPtrType2)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip, v2long xmm0, v2long ymm0_h, v2long xmm1, v2long ymm1_h, v2long xmm2, v2long ymm2_h, v2long xmm3, v2long ymm3_h, v2long xmm4, v2long ymm4_h, v2long xmm5, v2long ymm5_h, v2long xmm6, v2long ymm6_h, v2long xmm7, v2long ymm7_h, v2long xmm8, v2long ymm8_h, v2long xmm9, v2long ymm9_h, v2long xmm10, v2long ymm10_h, v2long xmm11, v2long ymm11_h, v2long xmm12, v2long ymm12_h, v2long xmm13, v2long ymm13_h, v2long xmm14, v2long ymm14_h, unsigned long target);

__attribute__((qemuaot,weak)) void jmp_ind_callback(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip, v2long xmm0, v2long ymm0_h, v2long xmm1, v2long ymm1_h, v2long xmm2, v2long ymm2_h, v2long xmm3, v2long ymm3_h, v2long xmm4, v2long ymm4_h, v2long xmm5, v2long ymm5_h, v2long xmm6, v2long ymm6_h, v2long xmm7, v2long ymm7_h, v2long xmm8, v2long ymm8_h, v2long xmm9, v2long ymm9_h, v2long xmm10, v2long ymm10_h, v2long xmm11, v2long ymm11_h, v2long xmm12, v2long ymm12_h, v2long xmm13, v2long ymm13_h, v2long xmm14, v2long ymm14_h, unsigned long target_addr, CodeFragment *list_ptr, unsigned long trampoline_helper_jit)
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
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, target_addr, xmm0, ymm0_h, xmm1, ymm1_h, xmm2, ymm2_h, xmm3, ymm3_h, xmm4, ymm4_h, xmm5, ymm5_h, xmm6, ymm6_h, xmm7, ymm7_h, xmm8, ymm8_h, xmm9, ymm9_h, xmm10, ymm10_h, xmm11, ymm11_h, xmm12, ymm12_h, xmm13, ymm13_h, xmm14, ymm14_h);
    } else {
        FuncPtrType2 func_ptr = (FuncPtrType2)trampoline_helper_jit;
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, target_addr, xmm0, ymm0_h, xmm1, ymm1_h, xmm2, ymm2_h, xmm3, ymm3_h, xmm4, ymm4_h, xmm5, ymm5_h, xmm6, ymm6_h, xmm7, ymm7_h, xmm8, ymm8_h, xmm9, ymm9_h, xmm10, ymm10_h, xmm11, ymm11_h, xmm12, ymm12_h, xmm13, ymm13_h, xmm14, ymm14_h, target_addr);
    }
}
