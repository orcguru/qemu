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
    uint32_t eax, ebx, ecx, edx;

    cpu_svm_check_intercept_param(env, SVM_EXIT_CPUID, 0, GETPC());

    cpu_x86_cpuid(env, (uint32_t)env->regs[R_EAX], (uint32_t)env->regs[R_ECX],
                  &eax, &ebx, &ecx, &edx);
    env->regs[R_EAX] = eax;
    env->regs[R_EBX] = ebx;
    env->regs[R_ECX] = ecx;
    env->regs[R_EDX] = edx;
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

#if AOT_LEVEL == AOT_LEVEL_MAX
__attribute__((qemuaot)) void helper_jmp_ind(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip, v2long xmm0, v2long ymm0_h, v2long xmm1, v2long ymm1_h, v2long xmm2, v2long ymm2_h, v2long xmm3, v2long ymm3_h, v2long xmm4, v2long ymm4_h, v2long xmm5, v2long ymm5_h, v2long xmm6, v2long ymm6_h, v2long xmm7, v2long ymm7_h, v2long xmm8, v2long ymm8_h, v2long xmm9, v2long ymm9_h, v2long xmm10, v2long ymm10_h, v2long xmm11, v2long ymm11_h, v2long xmm12, v2long ymm12_h, v2long xmm13, v2long ymm13_h, v2long xmm14, v2long ymm14_h, v2long xmm15, v2long ymm15_h, void *env, unsigned long target_addr, unsigned long jmp_ind_callback, unsigned long trampoline_helper_jit)
{
    return g_hash_table_lookup_qemuaot(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, rip, xmm0, ymm0_h, xmm1, ymm1_h, xmm2, ymm2_h, xmm3, ymm3_h, xmm4, ymm4_h, xmm5, ymm5_h, xmm6, ymm6_h, xmm7, ymm7_h, xmm8, ymm8_h, xmm9, ymm9_h, xmm10, ymm10_h, xmm11, ymm11_h, xmm12, ymm12_h, xmm13, ymm13_h, xmm14, ymm14_h, xmm15, ymm15_h, (unsigned long)tb_ctx.aot_htable, target_addr, jmp_ind_callback, trampoline_helper_jit);
}
#elif AOT_LEVEL == AOT_LEVEL_0
__attribute__((qemuaot)) void helper_jmp_ind(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long rip, void *env, unsigned long target_addr, unsigned long jmp_ind_callback, unsigned long trampoline_helper_jit)
{
    return g_hash_table_lookup_qemuaot(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, rip, (unsigned long)tb_ctx.aot_htable, target_addr, jmp_ind_callback, trampoline_helper_jit);
}
#endif

void register_for_aot_helper(const char *name, uint64_t addr, const char *ret_type);
void register_for_aot_helper_jmp_ind(void) __attribute__((weak,constructor));
void register_for_aot_helper_jmp_ind()
{
    register_for_aot_helper("helper_jmp_ind", (uint64_t)helper_jmp_ind, "void");
}

extern void load_aot_image(const char *image_name, unsigned long start_code, unsigned long entry);

#include <unistd.h>
#include <stddef.h>
#define ELF_CLASS       ELFCLASS64
#define ELF_DATA        ELFDATA2LSB
#include "include/elf.h"
#include "user/cpu_loop.h"
#include "user/abitypes.h"
#include "linux-user/qemu.h"
#include "linux-user/loader.h"
extern void bswap_ehdr(struct elfhdr *ehdr);
extern bool elf_check_ident(struct elfhdr *ehdr);
extern bool elf_check_ehdr(struct elfhdr *ehdr);
extern void bswap_phdr(struct elf_phdr *phdr, int phnum);
extern void bswap_shdr(struct elf_shdr *shdr, int shnum);

void find_and_load_missing_aot(uintptr_t x_addr)
{
    qemu_log_mask(LOG_AOT, "%s x_addr:%lx\n", __FUNCTION__, x_addr);
    char fn[64] = {0};
    sprintf(fn, "/proc/%d/maps", getpid());
    FILE *fp = fopen(fn, "r");
    assert(fp);
    char *line = NULL;
    size_t len = 0;
    size_t rd;
    char elf_fn[256] = {0};
    char aot_fn[256] = {0};
    uintptr_t start = -1UL;
    uintptr_t end = -1UL;
    uintptr_t offset = -1UL;
    while ((rd = getline(&line, &len, fp)) != -1) {
        char* p2;
        start = strtol(line, (char **)&p2, 16);
        p2++;
        end = strtol(p2, (char **)&p2, 16);
        p2 += 6;
        offset = strtol(p2, NULL, 16);
        if (x_addr >= start && x_addr < end) {
            char *ptr = strstr(line, "/");
            if (ptr) {
                if (strlen(ptr) > 250) {
                    assert(0);
                }
                strcpy(elf_fn, ptr);
                elf_fn[strlen(elf_fn) - 1] = '\0';
                sprintf(aot_fn, "%s.aot", elf_fn);
            }
            break;
        } else {
            start = -1UL;
            end = -1UL;
            continue;
        }
    }
    fclose(fp);
    assert(elf_fn[0]);
    qemu_log_mask(LOG_AOT, "load aot for:%s\n", elf_fn);
    // FIXME: handle offset
    assert(start != -1UL && end != -1UL && offset == 0);

    // Figure out start_code/entry
    unsigned long start_vaddr = -1UL;
    unsigned long start_code = -1UL;
    unsigned long entry = -1UL;
    char bprm_buf[BPRM_BUF_SIZE] = {0};
    struct elfhdr ehdr;
    ImageSource src;
    int fd, retval;
    fd = open(elf_fn, O_RDONLY);
    assert(fd != -1);
    retval = read(fd, bprm_buf, BPRM_BUF_SIZE);
    assert(retval != -1);
    src.fd = fd;
    src.cache = bprm_buf;
    src.cache_size = retval;

    g_autofree struct elf_phdr *phdr = NULL;
    Error *err = NULL;

    if (!imgsrc_read(&ehdr, 0, sizeof(ehdr), &src, &err)) {
        assert(0);
    }
    if (!elf_check_ident(&ehdr)) {
        assert(0);
    }
    bswap_ehdr(&ehdr);
    if (!elf_check_ehdr(&ehdr)) {
        assert(0);
    }
    phdr = imgsrc_read_alloc(ehdr.e_phoff,
                             ehdr.e_phnum * sizeof(struct elf_phdr),
                             &src, &err);
    if (phdr == NULL) {
        assert(0);
    }
    bswap_phdr(phdr, ehdr.e_phnum);
    for (int i = 0; i < ehdr.e_phnum; i++) {
        struct elf_phdr *eppnt = phdr + i;
        if (eppnt->p_type == PT_LOAD && eppnt->p_offset == offset) {
            start_vaddr = eppnt->p_vaddr;
            qemu_log_mask(LOG_AOT, "start_vaddr:%lx\n", start_vaddr);
        }
    }
    assert(start_vaddr != -1UL);
    entry = start + (ehdr.e_entry - start_vaddr);
    qemu_log_mask(LOG_AOT, "entry:%lx = start:%lx + (ehdr.e_entry:%lx - start_vaddr:%lx)\n", entry, start, ehdr.e_entry, start_vaddr);
    g_autofree struct elf_shdr *shdr = NULL;
    shdr = imgsrc_read_alloc(ehdr.e_shoff, ehdr.e_shnum * sizeof(struct elf_shdr),
                             &src, NULL);
    if (shdr == NULL) {
        assert(0);
    }
    bswap_shdr(shdr, ehdr.e_shnum);
    abi_long exec_begin = (1UL << 63)-1;
    for (int i = 0; i < ehdr.e_shnum; ++i) {
        if (shdr[i].sh_flags &= SHF_EXECINSTR) {
            if (shdr[i].sh_addr < exec_begin) {
                exec_begin = shdr[i].sh_addr;
                qemu_log_mask(LOG_AOT, "updated exec_begin:%lx on i:%d\n", exec_begin, i);
            }
        }
    }
    start_code = start + (exec_begin - start_vaddr);
    qemu_log_mask(LOG_AOT, "start_code:%lx = start:%lx + (exec_begin:%lx - start_vaddr:%lx)\n", start_code, start, exec_begin, start_vaddr);
    assert(start_code != -1UL && entry != -1UL);
    qemu_log_mask(LOG_AOT, "Load %s start_code:%lx entry:%lx\n", elf_fn, start_code, entry);
    load_aot_image(elf_fn, start_code, entry);
}

// Triggers AOT file load
void helper_jit(CPUX86State *env, unsigned long target)
{
    // FIXME: need an RBTree to decide if we need to load_aot
    find_and_load_missing_aot(target);
    CPUState *cs = env_cpu(env);
    cs->exception_index = EXCP_TCGJIT;
    env->exception_is_int = 0;
    env->exception_next_eip = target;
    cpu_loop_exit(cs);
}

void register_for_aot_helper_jit(void) __attribute__((weak,constructor));
void register_for_aot_helper_jit()
{
    register_for_aot_helper("helper_jit", (uint64_t)helper_jit, "void");
}

void helper_iret_ind(CPUX86State *env)
{
    assert(0);
}

void register_for_aot_helper_iret_ind(void) __attribute__((weak,constructor));
void register_for_aot_helper_iret_ind()
{
    register_for_aot_helper("helper_iret_ind", (uint64_t)helper_iret_ind, "void");
}

#define MAX_PID                 4194304
int last_dump_valid[MAX_PID+1] = {0};
CPUX86State **last_env = NULL;
uintptr_t last_shadow_stack = 0;
const char *x64_reg_name[16] = {"RAX", "RCX", "RDX", "RBX", "RSP", "RBP", "RSI", "RDI", "R8", "R9", "R10", "R11", "R12", "R13", "R14", "R15"};
const char *segment_base_name[6] = {"ES_BASE", "CS_BASE", "SS_BASE", "DS_BASE", "FS_BASE", "GS_BASE"};
unsigned long dump_cnt = 0;

void helper_dump_registers(CPUX86State *env, unsigned long func_offset)
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
#define DUMP_FULL_REGISTERS         \
    do {                            \
        qemu_log_mask(LOG_AOT, "pid=%d FUNC=%lx RIP=%016lx RAX=%016lx RCX=%016lx RDX=%016lx RBX=%016lx RSP=%016lx RBP=%016lx RSI=%016lx RDI=%016lx R8=%016lx R9=%016lx R10=%016lx R11=%016lx R12=%016lx R13=%016lx R14=%016lx R15=%016lx CC_SRC=%016lx CC_DST=%016lx CC_OP=%08x CC_SRC2=%016lx"   \
                     " XMM0=%016lx-%016lx YMM0_H=%016lx-%016lx"   \
                     " XMM1=%016lx-%016lx YMM1_H=%016lx-%016lx"   \
                     " XMM2=%016lx-%016lx YMM2_H=%016lx-%016lx"   \
                     " XMM3=%016lx-%016lx YMM3_H=%016lx-%016lx"   \
                     " XMM4=%016lx-%016lx YMM4_H=%016lx-%016lx"   \
                     " XMM5=%016lx-%016lx YMM5_H=%016lx-%016lx"   \
                     " XMM6=%016lx-%016lx YMM6_H=%016lx-%016lx"   \
                     " XMM7=%016lx-%016lx YMM7_H=%016lx-%016lx"   \
                     " XMM8=%016lx-%016lx YMM8_H=%016lx-%016lx"   \
                     " XMM9=%016lx-%016lx YMM9_H=%016lx-%016lx"   \
                     " XMM10=%016lx-%016lx YMM10_H=%016lx-%016lx"   \
                     " XMM11=%016lx-%016lx YMM11_H=%016lx-%016lx"   \
                     " XMM12=%016lx-%016lx YMM12_H=%016lx-%016lx"   \
                     " XMM13=%016lx-%016lx YMM13_H=%016lx-%016lx"   \
                     " XMM14=%016lx-%016lx YMM14_H=%016lx-%016lx"   \
                     " XMM15=%016lx-%016lx YMM15_H=%016lx-%016lx"   \
                     " SS=%016lx ES_BASE=%016lx CS_BASE=%016lx SS_BASE=%016lx DS_BASE=%016lx FS_BASE=%016lx GS_BASE=%016lx\n",   \
                     pid, func_offset, env->eip, env->regs[0], env->regs[1], env->regs[2], env->regs[3], env->regs[4], env->regs[5], env->regs[6], env->regs[7], env->regs[8], env->regs[9], env->regs[10], env->regs[11], env->regs[12], env->regs[13], env->regs[14], env->regs[15], env->cc_src, env->cc_dst, env->cc_op, env->cc_src2,   \
                     env->xmm_regs[0]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[0]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[0]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[0]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[1]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[1]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[1]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[1]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[2]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[2]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[2]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[2]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[3]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[3]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[3]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[3]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[4]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[4]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[4]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[4]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[5]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[5]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[5]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[5]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[6]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[6]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[6]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[6]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[7]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[7]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[7]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[7]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[8]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[8]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[8]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[8]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[9]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[9]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[9]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[9]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[10]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[10]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[10]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[10]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[11]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[11]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[11]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[11]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[12]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[12]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[12]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[12]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[13]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[13]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[13]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[13]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[14]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[14]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[14]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[14]._x_ZMMReg[1]._q_XMMReg[1],   \
                     env->xmm_regs[15]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[15]._x_ZMMReg[0]._q_XMMReg[1], env->xmm_regs[15]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[15]._x_ZMMReg[1]._q_XMMReg[1],   \
                     shadow_stack_pointer_ptr[0], env->segs[0].base, env->segs[1].base, env->segs[2].base, env->segs[3].base, env->segs[4].base, env->segs[5].base);   \
    } while (0)

    if (last_dump_valid[pid] != 0x55aa) {
        DUMP_FULL_REGISTERS;
        last_dump_valid[pid] = 0x55aa;
    } else {
        char *msg_buffer = (char *)calloc(4096, 1);
        assert(msg_buffer);
        sprintf(msg_buffer, "pid=%d FUNC=%lx .RIP=%016lx", pid, func_offset, env->eip);
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
        for (int i = 0; i <= 15; ++i) {
            if (env->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[0] != last_env[pid]->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[0] ||
                env->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[1] != last_env[pid]->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[1]) {
                char buf[128] = {0};
                sprintf(buf, " X%d=%016lx-%016lx", i, env->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[0], env->xmm_regs[i]._x_ZMMReg[0]._q_XMMReg[1]);
                strcat(msg_buffer, buf);
            }
            if (env->xmm_regs[i]._x_ZMMReg[1]._q_XMMReg[0] != last_env[pid]->xmm_regs[i]._x_ZMMReg[1]._q_XMMReg[0] ||
                env->xmm_regs[i]._x_ZMMReg[1]._q_XMMReg[1] != last_env[pid]->xmm_regs[i]._x_ZMMReg[1]._q_XMMReg[1]) {
                char buf[128] = {0};
                sprintf(buf, " Y%d_H=%016lx-%016lx", i, env->xmm_regs[i]._x_ZMMReg[1]._q_XMMReg[0], env->xmm_regs[i]._x_ZMMReg[1]._q_XMMReg[1]);
                strcat(msg_buffer, buf);
            }
        }
        if (last_shadow_stack != shadow_stack_pointer_ptr[0]) {
            char buf[128] = {0};
            sprintf(buf, " SS=%016lx", shadow_stack_pointer_ptr[0]);
            strcat(msg_buffer, buf);
        }
        for (int i = 0; i < 6; ++i) {
            if (env->segs[i].base != last_env[pid]->segs[i].base) {
                char buf[128] = {0};
                sprintf(buf, " %s=%016lx", segment_base_name[i], env->segs[i].base);
                strcat(msg_buffer, buf);
            }
        }
        strcat(msg_buffer, "\n");
        qemu_log_mask(LOG_AOT, "%s", msg_buffer);
        free(msg_buffer);
        if (dump_cnt % 10000 == 0) {
            DUMP_FULL_REGISTERS;
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

void helper_dump_load(CPUX86State *env, unsigned long addr, unsigned long val)
{
    qemu_log_mask(LOG_AOT, "LOAD A:%lx V:%lx\n", addr, val);
}

void helper_dump_store(CPUX86State *env, unsigned long addr, unsigned long val)
{
    qemu_log_mask(LOG_AOT, "STORE A:%lx V:%lx\n", addr, val);
}
#endif
