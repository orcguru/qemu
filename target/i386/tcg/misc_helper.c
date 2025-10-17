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
__attribute__((qemuaot)) void helper_jmp_ind(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip, v2long xmm0, v2long ymm0_h, v2long xmm1, v2long ymm1_h, v2long xmm2, v2long ymm2_h, v2long xmm3, v2long ymm3_h, v2long xmm4, v2long ymm4_h, v2long xmm5, v2long ymm5_h, v2long xmm6, v2long ymm6_h, v2long xmm7, v2long ymm7_h, v2long xmm8, v2long ymm8_h, v2long xmm9, v2long ymm9_h, v2long xmm10, v2long ymm10_h, v2long xmm11, v2long ymm11_h, v2long xmm12, v2long ymm12_h, v2long xmm13, v2long ymm13_h, v2long xmm14, v2long ymm14_h, unsigned long target_addr, unsigned long jmp_ind_callback, unsigned long trampoline_helper_jit)
{
    return g_hash_table_lookup_qemuaot(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, rip, xmm0, ymm0_h, xmm1, ymm1_h, xmm2, ymm2_h, xmm3, ymm3_h, xmm4, ymm4_h, xmm5, ymm5_h, xmm6, ymm6_h, xmm7, ymm7_h, xmm8, ymm8_h, xmm9, ymm9_h, xmm10, ymm10_h, xmm11, ymm11_h, xmm12, ymm12_h, xmm13, ymm13_h, xmm14, ymm14_h, (unsigned long)tb_ctx.aot_htable, target_addr, jmp_ind_callback, trampoline_helper_jit);
}

void register_for_aot_helper(const char *name, uint64_t addr);
void register_for_aot_helper_jmp_ind(void) __attribute__((weak,constructor));
void register_for_aot_helper_jmp_ind()
{
    register_for_aot_helper("helper_jmp_ind", (uint64_t)helper_jmp_ind);
}

void helper_jit(CPUX86State *env, unsigned long target)
{
    assert(0);
}

void register_for_aot_helper_jit(void) __attribute__((weak,constructor));
void register_for_aot_helper_jit()
{
    register_for_aot_helper("helper_jit", (uint64_t)helper_jit);
}

void helper_iret_ind(CPUX86State *env)
{
    assert(0);
}

void register_for_aot_helper_iret_ind(void) __attribute__((weak,constructor));
void register_for_aot_helper_iret_ind()
{
    register_for_aot_helper("helper_iret_ind", (uint64_t)helper_iret_ind);
}

#define MAX_PID                 4194304
int last_dump_valid[MAX_PID+1] = {0};
CPUX86State **last_env = NULL;
uintptr_t last_shadow_stack = 0;
const char *x64_reg_name[16] = {"RAX", "RCX", "RDX", "RBX", "RSP", "RBP", "RSI", "RDI", "R8", "R9", "R10", "R11", "R12", "R13", "R14", "R15"};
unsigned long dump_cnt = 0;

void helper_dump_registers(CPUX86State *env)
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
        qemu_log_mask(LOG_AOT, "pid=%d RIP=%016lx RAX=%016lx RCX=%016lx RDX=%016lx RBX=%016lx RSP=%016lx RBP=%016lx RSI=%016lx RDI=%016lx R8=%016lx R9=%016lx R10=%016lx R11=%016lx R12=%016lx R13=%016lx R14=%016lx R15=%016lx CC_SRC=%016lx CC_DST=%016lx CC_OP=%08x CC_SRC2=%016lx XMM0=%016lx-%016lx XMM1=%016lx-%016lx XMM2=%016lx-%016lx XMM3=%016lx-%016lx XMM4=%016lx-%016lx XMM5=%016lx-%016lx XMM6=%016lx-%016lx XMM7=%016lx-%016lx XMM8=%016lx-%016lx XMM9=%016lx-%016lx XMM10=%016lx-%016lx SS=%016lx\n", pid, env->eip, env->regs[0], env->regs[1], env->regs[2], env->regs[3], env->regs[4], env->regs[5], env->regs[6], env->regs[7], env->regs[8], env->regs[9], env->regs[10], env->regs[11], env->regs[12], env->regs[13], env->regs[14], env->regs[15], env->cc_src, env->cc_dst, env->cc_op, env->cc_src2, env->xmm_regs[0]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[0]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[1]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[1]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[2]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[2]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[3]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[3]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[4]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[4]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[5]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[5]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[6]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[6]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[7]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[7]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[8]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[8]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[9]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[9]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[10]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[10]._x_ZMMReg[0]._q_XMMReg[1], shadow_stack_pointer_ptr[0]);
        last_dump_valid[pid] = 0x55aa;
    } else {
        char *msg_buffer = (char *)calloc(4096, 1);
        assert(msg_buffer);
        sprintf(msg_buffer, "pid=%d .RIP=%016lx", pid, env->eip);
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
            qemu_log_mask(LOG_AOT, "pid=%d RIP=%016lx RAX=%016lx RCX=%016lx RDX=%016lx RBX=%016lx RSP=%016lx RBP=%016lx RSI=%016lx RDI=%016lx R8=%016lx R9=%016lx R10=%016lx R11=%016lx R12=%016lx R13=%016lx R14=%016lx R15=%016lx CC_SRC=%016lx CC_DST=%016lx CC_OP=%08x CC_SRC2=%016lx XMM0=%016lx-%016lx XMM1=%016lx-%016lx XMM2=%016lx-%016lx XMM3=%016lx-%016lx XMM4=%016lx-%016lx XMM5=%016lx-%016lx XMM6=%016lx-%016lx XMM7=%016lx-%016lx XMM8=%016lx-%016lx XMM9=%016lx-%016lx XMM10=%016lx-%016lx SS=%016lx\n", pid, env->eip, env->regs[0], env->regs[1], env->regs[2], env->regs[3], env->regs[4], env->regs[5], env->regs[6], env->regs[7], env->regs[8], env->regs[9], env->regs[10], env->regs[11], env->regs[12], env->regs[13], env->regs[14], env->regs[15], env->cc_src, env->cc_dst, env->cc_op, env->cc_src2, env->xmm_regs[0]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[0]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[1]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[1]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[2]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[2]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[3]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[3]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[4]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[4]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[5]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[5]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[6]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[6]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[7]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[7]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[8]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[8]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[9]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[9]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[10]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[10]._x_ZMMReg[0]._q_XMMReg[1], shadow_stack_pointer_ptr[0]);
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

void helper_dump_load(unsigned long addr, unsigned long val)
{
    qemu_log_mask(LOG_AOT, "LOAD A:%lx V:%lx\n", addr, val);
}

void helper_dump_store(unsigned long addr, unsigned long val)
{
    qemu_log_mask(LOG_AOT, "STORE A:%lx V:%lx\n", addr, val);
}
#endif
