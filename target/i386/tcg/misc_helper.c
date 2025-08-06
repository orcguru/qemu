/*
 *  x86 misc helpers
 *
 *  Copyright (c) 2003 Fabrice Bellard
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 */

#include "qemu/osdep.h"
#include "qemu/log.h"
#include "cpu.h"
#include "exec/helper-proto.h"
#include "exec/cputlb.h"
#include "helper-tcg.h"

#ifdef AOT
#include "accel/tcg/tb-context.h"
#endif

/*
 * NOTE: the translator must set DisasContext.cc_op to CC_OP_EFLAGS
 * after generating a call to a helper that uses this.
 */
void cpu_load_eflags(CPUX86State *env, int eflags, int update_mask)
{
    CC_SRC = eflags & (CC_O | CC_S | CC_Z | CC_A | CC_P | CC_C);
    CC_OP = CC_OP_EFLAGS;
    env->df = 1 - (2 * ((eflags >> 10) & 1));
    env->eflags = (env->eflags & ~update_mask) |
        (eflags & update_mask) | 0x2;
}

void helper_into(CPUX86State *env, int next_eip_addend)
{
    int eflags;

    eflags = cpu_cc_compute_all(env);
    if (eflags & CC_O) {
        raise_interrupt(env, EXCP04_INTO, next_eip_addend);
    }
}

void helper_cpuid(CPUX86State *env)
{
#ifdef AOT
    uint32_t tmp32u = env->regs[R_EAX];
    uint32_t eax = 0;
    uint32_t ebx = 0;
    uint32_t ecx = 0;
    uint32_t edx = 0;
    switch (tmp32u) {
        case 0x0:
            /* This spells out "AuthenticAMD" -- glibc:sysdeps/x86/cpu-features.c */
            eax = 0xd;
            ebx = 0x68747541;
            ecx = 0x444d4163;
            edx = 0x69746e65;
            break;
        case 0x1:
            eax = 0x60fb1;
            ebx = 0x40800;
            ecx = 0x80002001;
            edx = 0x178bfbfd;
            break;
        case 0x7:
            eax = 0x0;
            ebx = 0x0;
            ecx = 0x0;
            edx = 0x0;
            break;
        case 0xd:
            eax = 0x0;
            ebx = 0x0;
            ecx = 0x0;
            edx = 0x0;
            break;
        case 0x80000000:
            eax = 0x8000000a;
            ebx = 0x68747541;
            ecx = 0x444d4163;
            edx = 0x69746e65;
            break;
        case 0x80000001:
            eax = 0x60fb1;
            ebx = 0x0;
            ecx = 0x7;
            edx = 0x2193fbfd;
            break;
        case 0x80000007:
            eax = 0x0;
            ebx = 0x0;
            ecx = 0x0;
            edx = 0x0;
            break;
        case 0x80000008:
            eax = 0x3028;
            ebx = 0x0;
            ecx = 0x2003;
            edx = 0x0;
            break;
        case 0x80000005:
            eax = 0x1ff01ff;
            ebx = 0x1ff01ff;
            ecx = 0x40020140;
            edx = 0x40020140;
            break;
        case 0x80000006:
            eax = 0x0;
            ebx = 0x42004200;
            ecx = 0x2008140;
            edx = 0x808140;
            break;
        default:
            break;
    }
    env->regs[R_EAX] = REG_EXT(env->regs[R_EAX], eax);
    env->regs[R_EBX] = REG_EXT(env->regs[R_EBX], ebx);
    env->regs[R_ECX] = REG_EXT(env->regs[R_ECX], ecx);
    env->regs[R_EDX] = REG_EXT(env->regs[R_EDX], edx);
#else
    uint32_t eax, ebx, ecx, edx;

    cpu_svm_check_intercept_param(env, SVM_EXIT_CPUID, 0, GETPC());

    cpu_x86_cpuid(env, (uint32_t)env->regs[R_EAX], (uint32_t)env->regs[R_ECX],
                  &eax, &ebx, &ecx, &edx);
    env->regs[R_EAX] = eax;
    env->regs[R_EBX] = ebx;
    env->regs[R_ECX] = ecx;
    env->regs[R_EDX] = edx;
#endif
}

#ifdef AOT
void __attribute__((qemuaot)) helper_A_cpuid(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long lr)
{
    uint32_t tmp32u = rax;
    uint32_t eax = 0;
    uint32_t ebx = 0;
    uint32_t ecx = 0;
    uint32_t edx = 0;
    switch (tmp32u) {
        case 0x0:
            /* This spells out "AuthenticAMD" -- glibc:sysdeps/x86/cpu-features.c */
            eax = 0xd;
            ebx = 0x68747541;
            ecx = 0x444d4163;
            edx = 0x69746e65;
            break;
        case 0x1:
            eax = 0x60fb1;
            ebx = 0x40800;
            ecx = 0x80002001;
            edx = 0x178bfbfd;
            break;
        case 0x7:
            eax = 0x0;
            ebx = 0x0;
            ecx = 0x0;
            edx = 0x0;
            break;
        case 0xd:
            eax = 0x0;
            ebx = 0x0;
            ecx = 0x0;
            edx = 0x0;
            break;
        case 0x80000000:
            eax = 0x8000000a;
            ebx = 0x68747541;
            ecx = 0x444d4163;
            edx = 0x69746e65;
            break;
        case 0x80000001:
            eax = 0x60fb1;
            ebx = 0x0;
            ecx = 0x7;
            edx = 0x2193fbfd;
            break;
        case 0x80000007:
            eax = 0x0;
            ebx = 0x0;
            ecx = 0x0;
            edx = 0x0;
            break;
        case 0x80000008:
            eax = 0x3028;
            ebx = 0x0;
            ecx = 0x2003;
            edx = 0x0;
            break;
        case 0x80000005:
            eax = 0x1ff01ff;
            ebx = 0x1ff01ff;
            ecx = 0x40020140;
            edx = 0x40020140;
            break;
        case 0x80000006:
            eax = 0x0;
            ebx = 0x42004200;
            ecx = 0x2008140;
            edx = 0x808140;
            break;
        default:
            break;
    }
    rax = REG_EXT(rax, eax);
    rbx = REG_EXT(rbx, ebx);
    rcx = REG_EXT(rcx, ecx);
    rdx = REG_EXT(rdx, edx);
    return helper_A_return(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, lr);
}
#endif

void helper_rdtsc(CPUX86State *env)
{
    uint64_t val;

    if ((env->cr[4] & CR4_TSD_MASK) && ((env->hflags & HF_CPL_MASK) != 0)) {
        raise_exception_ra(env, EXCP0D_GPF, GETPC());
    }
    cpu_svm_check_intercept_param(env, SVM_EXIT_RDTSC, 0, GETPC());

    val = cpu_get_tsc(env) + env->tsc_offset;
    env->regs[R_EAX] = (uint32_t)(val);
    env->regs[R_EDX] = (uint32_t)(val >> 32);
}

#ifdef AOT
void __attribute__((qemuaot)) helper_A_rdtsc(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long lr)
{
    CPUX86State *env;
#if defined(__aarch64__)
    asm volatile ("mov %0, x25" : "=r" (env) :);
#elif defined(__riscv) && __riscv_xlen == 64
    asm volatile ("mv %0, x25" : "=r" (env) :);
#endif
    uint64_t val;

    if ((env->cr[4] & CR4_TSD_MASK) && ((env->hflags & HF_CPL_MASK) != 0)) {
        return raise_exception_ra_A(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, EXCP0D_GPF, GETPC());
    }
    //cpu_svm_check_intercept_param(env, SVM_EXIT_RDTSC, 0, GETPC());

    //FIXME
    val = 0/*cpu_get_tsc(env)*/ + env->tsc_offset;
    rax = (uint32_t)(val);
    rdx = (uint32_t)(val >> 32);
    return helper_A_return(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, lr);
}
#endif

G_NORETURN void helper_rdpmc(CPUX86State *env)
{
    if (((env->cr[4] & CR4_PCE_MASK) == 0 ) &&
        ((env->hflags & HF_CPL_MASK) != 0)) {
        raise_exception_ra(env, EXCP0D_GPF, GETPC());
    }
    cpu_svm_check_intercept_param(env, SVM_EXIT_RDPMC, 0, GETPC());

    /* currently unimplemented */
    qemu_log_mask(LOG_UNIMP, "x86: unimplemented rdpmc\n");
    raise_exception_err(env, EXCP06_ILLOP, 0);
}

G_NORETURN void helper_pause(CPUX86State *env)
{
    CPUState *cs = env_cpu(env);

    /* Do gen_eob() tasks before going back to the main loop.  */
    do_end_instruction(env);
    helper_rechecking_single_step(env);

    /* Just let another CPU run.  */
    cs->exception_index = EXCP_INTERRUPT;
    cpu_loop_exit(cs);
}

uint64_t helper_rdpkru(CPUX86State *env, uint32_t ecx)
{
    if ((env->cr[4] & CR4_PKE_MASK) == 0) {
        raise_exception_err_ra(env, EXCP06_ILLOP, 0, GETPC());
    }
    if (ecx != 0) {
        raise_exception_err_ra(env, EXCP0D_GPF, 0, GETPC());
    }

    return env->pkru;
}

void helper_wrpkru(CPUX86State *env, uint32_t ecx, uint64_t val)
{
    CPUState *cs = env_cpu(env);

    if ((env->cr[4] & CR4_PKE_MASK) == 0) {
        raise_exception_err_ra(env, EXCP06_ILLOP, 0, GETPC());
    }
    if (ecx != 0 || (val & 0xFFFFFFFF00000000ull)) {
        raise_exception_err_ra(env, EXCP0D_GPF, 0, GETPC());
    }

    env->pkru = val;
    tlb_flush(cs);
}

target_ulong HELPER(rdpid)(CPUX86State *env)
{
#if !defined CONFIG_USER_ONLY
    return env->tsc_aux;
#elif defined CONFIG_LINUX && defined CONFIG_GETCPU
    unsigned cpu, node;
    getcpu(&cpu, &node);
    return (node << 12) | (cpu & 0xfff);
#elif defined CONFIG_SCHED_GETCPU
    return sched_getcpu();
#else
    return 0;
#endif
}

#ifdef AOT
#include "tcg/tcg-aot.h"
typedef __attribute__((qemuaot)) void (*FuncPtrType1)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, uint64_t jmp_dest);

typedef __attribute__((qemuaot)) void (*FuncPtrType2)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op);

__attribute__((qemuaot)) r2_t helper_A_jmp_ind_entry(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long lr, uint64_t target_addr)
{
    return g_hash_table_lookup_qemuaot(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, lr, tb_ctx.aot_htable, (void *)target_addr);
}

__attribute__((qemuaot)) void helper_A_jmp_ind_resume(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, uint64_t target_addr, CodeFragment *list_ptr)
{
    uint64_t host_addr = 0;
    while (list_ptr) {
        if (list_ptr->target_addr == target_addr) {
            host_addr = list_ptr->host_addr;
            break;
        }
        list_ptr = list_ptr->next;
    }
    if (host_addr) {
        FuncPtrType2 func_ptr = (FuncPtrType2)host_addr;
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op);
    } else {
        //FuncPtrType1 func_ptr = (FuncPtrType1)(HELPER_BASE_ADDR + QEMU_REUSE_FUNC_call_ind * SINGLE_HELPER_SIZE);
        //FIXME
        FuncPtrType1 func_ptr = (FuncPtrType1)(0);
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, host_addr);
    }
}

#define MAX_PID                 4194304
int last_dump_valid[MAX_PID+1] = {0};
CPUX86State **last_env = NULL;
uintptr_t last_shadow_stack = 0;
const char *x64_reg_name[16] = {"RAX", "RCX", "RDX", "RBX", "RSP", "RBP", "RSI", "RDI", "R8", "R9", "R10", "R11", "R12", "R13", "R14", "R15"};
unsigned long dump_cnt = 0;

static unsigned long get_module_offset(unsigned int module)
{
    unsigned long offset = 0;
    switch (module) {
    /* Information collected by:
     grep "^load_aot" trace1 | grep -v ".dbg" | tr '(' ':' | tr ')' ':' | awk -F: '{print "    case "$2": offset = "$NF"; break;"}'
     */
    case 0x850f8798: offset = 0x1000; break;
    default: break;
    }
    return offset;
}

static unsigned long get_module_elf_load_addr(unsigned int module)
{
    unsigned long addr = 0;
    switch (module) {
    /* Information collected by:
     grep "^load_aot" trace1 | grep -v ".dbg" | tr '(' ':' | tr ')' ':' | tr ' ' ':' | awk -F: '{print "    case "$2": offset = "$(NF-2)"; break;"}'
     */
    case 0x850f8798: addr = 0x400000; break;
    default: break;
    }
    return addr;
}

static unsigned long get_x64_rip(unsigned long xoffset, int rel)
{
    unsigned int module = (unsigned int)(xoffset >> 32);
    unsigned int offset = (unsigned int)xoffset;
    unsigned long ret = (unsigned long)offset + (rel ? 0 : get_module_elf_load_addr(module)) + get_module_offset(module);
    return ret;
}

__attribute__((optnone)) void helper_J_runtime_trace(CPUX86State *env, unsigned long xoffset)
{
    uint64_t *shadow_stack_pointer_ptr = (uint64_t *)((unsigned long)env - 8);
    uint64_t shadow_stack_pointer_lower_bound = *(uint64_t *)((unsigned long)env - 16);
    uint64_t shadow_stack_pointer_upper_bound = *(uint64_t *)((unsigned long)env - 24);
    assert(shadow_stack_pointer_lower_bound < shadow_stack_pointer_ptr[0]);
    assert(shadow_stack_pointer_ptr[0] <= shadow_stack_pointer_upper_bound);

    if (!last_env) {
        last_env = (CPUX86State **)calloc(sizeof(CPUX86State *), (MAX_PID+1));
        assert(last_env);
    }
    pid_t pid = getpid();
    assert(pid <= MAX_PID);
    if (!last_env[pid]) {
        last_env[pid] = (CPUX86State *)calloc(sizeof(CPUX86State), 1);
        assert(last_env[pid]);
    }
    if (last_dump_valid[pid] != 0x55aa) {
        qemu_log_mask(LOG_AOT, "pid=%d RIP=%016lx/%x/%x RAX=%016lx RCX=%016lx RDX=%016lx RBX=%016lx RSP=%016lx RBP=%016lx RSI=%016lx RDI=%016lx R8=%016lx R9=%016lx R10=%016lx R11=%016lx R12=%016lx R13=%016lx R14=%016lx R15=%016lx CC_SRC=%016lx CC_DST=%016lx CC_OP=%08x CC_SRC2=%016lx XMM0=%016lx-%016lx XMM1=%016lx-%016lx XMM2=%016lx-%016lx XMM3=%016lx-%016lx XMM4=%016lx-%016lx XMM5=%016lx-%016lx XMM6=%016lx-%016lx XMM7=%016lx-%016lx XMM8=%016lx-%016lx XMM9=%016lx-%016lx XMM10=%016lx-%016lx SS=%016lx\n", pid, get_x64_rip(xoffset, 0), (unsigned int)get_x64_rip(xoffset, 1), (unsigned int)(xoffset & 0xffffffff), env->regs[0], env->regs[1], env->regs[2], env->regs[3], env->regs[4], env->regs[5], env->regs[6], env->regs[7], env->regs[8], env->regs[9], env->regs[10], env->regs[11], env->regs[12], env->regs[13], env->regs[14], env->regs[15], env->cc_src, env->cc_dst, env->cc_op, env->cc_src2, env->xmm_regs[0]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[0]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[1]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[1]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[2]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[2]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[3]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[3]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[4]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[4]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[5]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[5]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[6]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[6]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[7]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[7]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[8]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[8]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[9]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[9]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[10]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[10]._x_ZMMReg[0]._q_XMMReg[1], shadow_stack_pointer_ptr[0]);
        last_dump_valid[pid] = 0x55aa;
    } else {
        char *msg_buffer = (char *)calloc(4096, 1);
        assert(msg_buffer);
        sprintf(msg_buffer, "pid=%d .RIP=%016lx/%x/%x", pid, get_x64_rip(xoffset, 0), (unsigned int)get_x64_rip(xoffset, 1), (unsigned int)(xoffset & 0xffffffff));
        for (int i = 0; i <= 15; ++i) {
            if (env->regs[i] != last_env[pid]->regs[i]) {
                char buf[128] = {0};
                sprintf(buf, " %s=%016lx", x64_reg_name[i], env->regs[i]);
                strcat(msg_buffer, buf);
            }
        }
        if (env->cc_src != last_env[pid]->cc_src) {
            char buf[128] = {0};
            sprintf(buf, " CC_SRC=%016lx", env->cc_src);
            strcat(msg_buffer, buf);
        }
        if (env->cc_dst != last_env[pid]->cc_dst) {
            char buf[128] = {0};
            sprintf(buf, " CC_DST=%016lx", env->cc_dst);
            strcat(msg_buffer, buf);
        }
        if (env->cc_op != last_env[pid]->cc_op) {
            char buf[128] = {0};
            sprintf(buf, " CC_OP=%08x", env->cc_op);
            strcat(msg_buffer, buf);
        }
        if (env->cc_src2 != last_env[pid]->cc_src2) {
            char buf[128] = {0};
            sprintf(buf, " CC_SRC2=%016lx", env->cc_src2);
            strcat(msg_buffer, buf);
        }
        for (int i = 0; i <= 10; ++i) {
            if (env->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[0] != last_env[pid]->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[0] ||
                env->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[1] != last_env[pid]->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[1]) {
                char buf[128] = {0};
                sprintf(buf, " X%d=%016lx-%016lx", i, env->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[1]);
                strcat(msg_buffer, buf);
            }
        }
        if (last_shadow_stack != shadow_stack_pointer_ptr[0]) {
            char buf[128] = {0};
            sprintf(buf, " SS=%016lx", shadow_stack_pointer_ptr[0]);
            strcat(msg_buffer, buf);
        }
        strcat(msg_buffer, "\n");
        qemu_log_mask(LOG_AOT, "%s", msg_buffer);
        free(msg_buffer);
        if (dump_cnt % 10000 == 0) {
            qemu_log_mask(LOG_AOT, "pid=%d RIP=%016lx/%x/%x RAX=%016lx RCX=%016lx RDX=%016lx RBX=%016lx RSP=%016lx RBP=%016lx RSI=%016lx RDI=%016lx R8=%016lx R9=%016lx R10=%016lx R11=%016lx R12=%016lx R13=%016lx R14=%016lx R15=%016lx CC_SRC=%016lx CC_DST=%016lx CC_OP=%08x CC_SRC2=%016lx XMM0=%016lx-%016lx XMM1=%016lx-%016lx XMM2=%016lx-%016lx XMM3=%016lx-%016lx XMM4=%016lx-%016lx XMM5=%016lx-%016lx XMM6=%016lx-%016lx XMM7=%016lx-%016lx XMM8=%016lx-%016lx XMM9=%016lx-%016lx XMM10=%016lx-%016lx SS=%016lx\n", pid, get_x64_rip(xoffset, 0), (unsigned int)get_x64_rip(xoffset, 1), (unsigned int)(xoffset & 0xffffffff), env->regs[0], env->regs[1], env->regs[2], env->regs[3], env->regs[4], env->regs[5], env->regs[6], env->regs[7], env->regs[8], env->regs[9], env->regs[10], env->regs[11], env->regs[12], env->regs[13], env->regs[14], env->regs[15], env->cc_src, env->cc_dst, env->cc_op, env->cc_src2, env->xmm_regs[0]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[0]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[1]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[1]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[2]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[2]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[3]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[3]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[4]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[4]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[5]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[5]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[6]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[6]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[7]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[7]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[8]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[8]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[9]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[9]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[10]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[10]._x_ZMMReg[0]._q_XMMReg[1], shadow_stack_pointer_ptr[0]);
        }
    }
    memcpy(last_env[pid], env, sizeof(CPUX86State));
    memcpy(last_env[pid], env->regs, 16*8);
    last_env[pid]->cc_src = env->cc_src;
    last_env[pid]->cc_dst = env->cc_dst;
    last_env[pid]->cc_op = (unsigned int)env->cc_op;
    last_shadow_stack = shadow_stack_pointer_ptr[0];
    ++dump_cnt;
}

#ifdef AOT
void __attribute__((qemuaot)) helper_A_dump_registers(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip, unsigned long checksum_low)
{
    CPUX86State *env;
#if defined(__aarch64__)
    asm volatile ("mov %0, x25" : "=r" (env) :);
#elif defined(__riscv) && __riscv_xlen == 64
    asm volatile ("mv %0, x25" : "=r" (env) :);
#endif
    env->regs[0] = rax;
    env->regs[1] = rcx;
    env->regs[2] = rdx;
    env->regs[3] = rbx;
    env->regs[4] = rsp;
    env->regs[5] = rbp;
    env->regs[6] = rsi;
    env->regs[7] = rdi;
    env->regs[8] = r8;
    env->regs[9] = r9;
    env->regs[10] = r10;
    env->regs[11] = r11;
    env->regs[12] = r12;
    env->regs[13] = r13;
    env->regs[14] = r14;
    env->regs[15] = r15;
    env->cc_src = src;
    env->cc_dst = dst;
    env->cc_op = op;
    helper_J_runtime_trace(env, ((rip & 0xffffffff) | ((checksum_low & 0xffffffff) << 32)));
    return helper_A_return_implicit_lr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op);
}

void __attribute__((qemuaot)) helper_A_dump_load(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long addr, unsigned long val)
{
    qemu_log_mask(LOG_AOT, "LOAD A:%lx V:%lx\n", addr, val);
    return helper_A_return_implicit_lr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op);
}

void __attribute__((qemuaot)) helper_A_dump_store(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long addr, unsigned long val)
{
    qemu_log_mask(LOG_AOT, "STORE A:%lx V:%lx\n", addr, val);
    return helper_A_return_implicit_lr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op);
}
#endif
#endif
