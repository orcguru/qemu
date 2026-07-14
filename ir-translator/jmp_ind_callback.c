typedef struct CodeFragment {
    unsigned long target_addr;
    unsigned long host_addr;
    struct CodeFragment *next;
} CodeFragment;

typedef unsigned long __attribute__((__vector_size__(16))) v2ulong;

typedef __attribute__((qemuaot,nothrow)) void (*FuncPtrType1)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip XMM_PARAM_DECLARE_COMMON);

typedef __attribute__((qemuaot,nothrow)) void (*FuncPtrType2)(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip XMM_PARAM_DECLARE_COMMON, unsigned long env, unsigned long target);

#define LARGE_SHADOW_MAP        1
//#define DUMP_CTR_COUNTER        1
#define CTR_CALLBACK_TOTAL      0
#define CTR_CALLBACK_OOR        1
#define CTR_CALLBACK_INVAOT1    2
#define CTR_CALLBACK_INVAOT2    3
#define CTR_CALLBACK_COLLID     4
#define CTR_CALLBACK_DUP        5
#define CTR_CALLBACK_HIT        6
#define CTR_CALLBACK_SAMPLE1    7
#define CTR_CALLBACK_SAMPLE2    8
#define CTR_HELPER_TOTAL        9
#define CTR_HELPER_OOR          10
#define CTR_HELPER_EMP          11
#define CTR_HELPER_INVAOT       12
#define CTR_HELPER_HIT          13
#define CTR_COUNT               14

__attribute__((qemuaot,weak,nothrow)) void jmp_ind_callback(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long rip XMM_PARAM_DECLARE_COMMON, unsigned long target_addr, CodeFragment *list_ptr, unsigned long trampoline_helper_jit, unsigned long shadow_array_entry, unsigned long shadow_map)
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
            unsigned long *shadow_entry_ptr = (unsigned long *)shadow_array_entry;
            // FIXME: atomic store
            if (shadow_entry_ptr[0] == 0) {
                shadow_entry_ptr[0] = target_addr;
                shadow_entry_ptr[1] = host_addr;
            }
        }
        if (shadow_map) {
            unsigned long *ptr = (unsigned long *)shadow_map;
            unsigned long x64_elf_exec_start = ptr[0];
            unsigned long x64_delta_end = ptr[1];
#ifdef DUMP_CTR_COUNTER
            unsigned long *counters = (unsigned long *)(shadow_map+32);
            counters[CTR_CALLBACK_TOTAL] += 1;
#endif
#ifdef LARGE_SHADOW_MAP
            unsigned long x64_delta = target_addr - x64_elf_exec_start;
            if (x64_delta < x64_delta_end) {
                unsigned long *map_ptr = (unsigned long *)(shadow_map + 8 * (4 + CTR_COUNT));
                map_ptr[x64_delta] = host_addr;
#ifdef DUMP_CTR_COUNTER
                counters[CTR_CALLBACK_HIT] += 1;
#endif
            } else {
#ifdef DUMP_CTR_COUNTER
                counters[CTR_CALLBACK_OOR] += 1;
#endif
            }
#else
            unsigned long host_exec_start = ptr[2];
            unsigned long aux_array = ptr[3];
            unsigned long x64_delta = target_addr - x64_elf_exec_start;
            if (x64_delta < x64_delta_end) {
                unsigned long host_delta = host_addr - host_exec_start;
                ptr = (unsigned long *)aux_array;
                unsigned char *bit_array_ptr = (unsigned char *)(aux_array+8);
                if ((host_delta >> 3) < ptr[0]) {
                    unsigned long idx = host_delta >> 3;
                    unsigned char shift = host_delta % 8;
                    if (bit_array_ptr[idx] & (1 << shift)) {
                        unsigned long x64_delta = target_addr - x64_elf_exec_start;
                        unsigned char *map_ptr = (unsigned char *)(shadow_map + 8 * (4 + CTR_COUNT));
                        unsigned long map_delta = ((unsigned long)map_ptr[x64_delta+3] << 24) |
                                                  ((unsigned long)map_ptr[x64_delta+2] << 16) |
                                                  ((unsigned long)map_ptr[x64_delta+1] << 8) |
                                                  (unsigned long)map_ptr[x64_delta+0];
                        if (map_delta == 0) {
                            map_ptr[x64_delta] = host_delta & 0xff;
                            map_ptr[x64_delta+1] = (host_delta >> 8) & 0xff;
                            map_ptr[x64_delta+2] = (host_delta >> 16) & 0xff;
                            map_ptr[x64_delta+3] = (host_delta >> 24) & 0xff;
#ifdef DUMP_CTR_COUNTER
                            counters[CTR_CALLBACK_HIT] += 1;
#endif
                        } else {
#ifdef DUMP_CTR_COUNTER
                            if (map_delta == host_delta) {
                                counters[CTR_CALLBACK_DUP] += 1;
                            } else {
                                counters[CTR_CALLBACK_COLLID] += 1;
                                counters[CTR_CALLBACK_SAMPLE1] = x64_delta;
                                counters[CTR_CALLBACK_SAMPLE2] = map_delta << 4 | host_delta;
                            }
#endif
                        }
                    } else {
#ifdef DUMP_CTR_COUNTER
                        counters[CTR_CALLBACK_INVAOT2] += 1;
                        unsigned long x64_delta = target_addr - x64_elf_exec_start;
                        counters[CTR_CALLBACK_SAMPLE1] = x64_delta;
                        counters[CTR_CALLBACK_SAMPLE2] = host_addr;
#endif
                    }
                } else {
#ifdef DUMP_CTR_COUNTER
                    counters[CTR_CALLBACK_INVAOT1] += 1;
#endif
                }
            } else {
#ifdef DUMP_CTR_COUNTER
                counters[CTR_CALLBACK_OOR] += 1;
#endif
            }
#endif
        }
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, target_addr XMM_PARAM_LIST);
    } else {
        FuncPtrType2 func_ptr = (FuncPtrType2)trampoline_helper_jit;
        return func_ptr(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, target_addr XMM_PARAM_LIST, env_val, target_addr);
    }
}
