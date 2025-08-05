/*
 *  x86 condition code helpers
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
#include "cpu.h"
#include "exec/helper-proto.h"
#include "helper-tcg.h"

#define SHIFT 0
#include "cc_helper_template.h.inc"
#undef SHIFT

#define SHIFT 1
#include "cc_helper_template.h.inc"
#undef SHIFT

#define SHIFT 2
#include "cc_helper_template.h.inc"
#undef SHIFT

#ifdef TARGET_X86_64

#define SHIFT 3
#include "cc_helper_template.h.inc"
#undef SHIFT

#endif

static target_ulong compute_all_adcx(target_ulong dst, target_ulong src1,
                                     target_ulong src2)
{
    return (src1 & ~CC_C) | (dst * CC_C);
}

static target_ulong compute_all_adox(target_ulong dst, target_ulong src1,
                                     target_ulong src2)
{
    return (src1 & ~CC_O) | (src2 * CC_O);
}

static target_ulong compute_all_adcox(target_ulong dst, target_ulong src1,
                                      target_ulong src2)
{
    return (src1 & ~(CC_C | CC_O)) | (dst * CC_C) | (src2 * CC_O);
}

target_ulong helper_cc_compute_nz(target_ulong dst, target_ulong src1,
                                  int op)
{
    if (CC_OP_HAS_EFLAGS(op)) {
        return ~src1 & CC_Z;
    } else {
        MemOp size = cc_op_size(op);
        target_ulong mask = MAKE_64BIT_MASK(0, 8 << size);

        return dst & mask;
    }
}

#ifdef AOT
target_ulong __attribute__((qemuaot,flatten)) helper_A_cc_compute_nz(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long lr,
                                                                             target_ulong in_dst, target_ulong in_src1, int in_op)
{
    target_ulong ret;
    if (CC_OP_HAS_EFLAGS(in_op)) {
        ret = ~in_src1 & CC_Z;
    } else {
        MemOp size = cc_op_size(in_op);
        target_ulong mask = MAKE_64BIT_MASK(0, 8 << size);

        ret = in_dst & mask;
    }
    return helper_A_return_one(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, lr, ret);
}
#endif

target_ulong helper_cc_compute_all(target_ulong dst, target_ulong src1,
                                   target_ulong src2, int op)
{
    switch (op) {
    default: /* should never happen */
        return 0;

    case CC_OP_EFLAGS:
        return src1;
    case CC_OP_POPCNT:
        return dst ? 0 : CC_Z;

    case CC_OP_MULB:
        return compute_all_mulb(dst, src1);
    case CC_OP_MULW:
        return compute_all_mulw(dst, src1);
    case CC_OP_MULL:
        return compute_all_mull(dst, src1);

    case CC_OP_ADDB:
        return compute_all_addb(dst, src1);
    case CC_OP_ADDW:
        return compute_all_addw(dst, src1);
    case CC_OP_ADDL:
        return compute_all_addl(dst, src1);

    case CC_OP_ADCB:
        return compute_all_adcb(dst, src1, src2);
    case CC_OP_ADCW:
        return compute_all_adcw(dst, src1, src2);
    case CC_OP_ADCL:
        return compute_all_adcl(dst, src1, src2);

    case CC_OP_SUBB:
        return compute_all_subb(dst, src1);
    case CC_OP_SUBW:
        return compute_all_subw(dst, src1);
    case CC_OP_SUBL:
        return compute_all_subl(dst, src1);

    case CC_OP_SBBB:
        return compute_all_sbbb(dst, src1, src2);
    case CC_OP_SBBW:
        return compute_all_sbbw(dst, src1, src2);
    case CC_OP_SBBL:
        return compute_all_sbbl(dst, src1, src2);

    case CC_OP_LOGICB:
        return compute_all_logicb(dst, src1);
    case CC_OP_LOGICW:
        return compute_all_logicw(dst, src1);
    case CC_OP_LOGICL:
        return compute_all_logicl(dst, src1);

    case CC_OP_INCB:
        return compute_all_incb(dst, src1);
    case CC_OP_INCW:
        return compute_all_incw(dst, src1);
    case CC_OP_INCL:
        return compute_all_incl(dst, src1);

    case CC_OP_DECB:
        return compute_all_decb(dst, src1);
    case CC_OP_DECW:
        return compute_all_decw(dst, src1);
    case CC_OP_DECL:
        return compute_all_decl(dst, src1);

    case CC_OP_SHLB:
        return compute_all_shlb(dst, src1);
    case CC_OP_SHLW:
        return compute_all_shlw(dst, src1);
    case CC_OP_SHLL:
        return compute_all_shll(dst, src1);

    case CC_OP_SARB:
        return compute_all_sarb(dst, src1);
    case CC_OP_SARW:
        return compute_all_sarw(dst, src1);
    case CC_OP_SARL:
        return compute_all_sarl(dst, src1);

    case CC_OP_BMILGB:
        return compute_all_bmilgb(dst, src1);
    case CC_OP_BMILGW:
        return compute_all_bmilgw(dst, src1);
    case CC_OP_BMILGL:
        return compute_all_bmilgl(dst, src1);

    case CC_OP_BLSIB:
        return compute_all_blsib(dst, src1);
    case CC_OP_BLSIW:
        return compute_all_blsiw(dst, src1);
    case CC_OP_BLSIL:
        return compute_all_blsil(dst, src1);

    case CC_OP_ADCX:
        return compute_all_adcx(dst, src1, src2);
    case CC_OP_ADOX:
        return compute_all_adox(dst, src1, src2);
    case CC_OP_ADCOX:
        return compute_all_adcox(dst, src1, src2);

#ifdef TARGET_X86_64
    case CC_OP_MULQ:
        return compute_all_mulq(dst, src1);
    case CC_OP_ADDQ:
        return compute_all_addq(dst, src1);
    case CC_OP_ADCQ:
        return compute_all_adcq(dst, src1, src2);
    case CC_OP_SUBQ:
        return compute_all_subq(dst, src1);
    case CC_OP_SBBQ:
        return compute_all_sbbq(dst, src1, src2);
    case CC_OP_LOGICQ:
        return compute_all_logicq(dst, src1);
    case CC_OP_INCQ:
        return compute_all_incq(dst, src1);
    case CC_OP_DECQ:
        return compute_all_decq(dst, src1);
    case CC_OP_SHLQ:
        return compute_all_shlq(dst, src1);
    case CC_OP_SARQ:
        return compute_all_sarq(dst, src1);
    case CC_OP_BMILGQ:
        return compute_all_bmilgq(dst, src1);
    case CC_OP_BLSIQ:
        return compute_all_blsiq(dst, src1);
#endif
    }
}

#ifdef AOT
target_ulong __attribute__((qemuaot,flatten)) helper_A_cc_compute_all(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long lr,
                                                                              unsigned long in_dst, unsigned long in_src1, unsigned long in_src2, int in_op)
{
    unsigned long ret = in_src1;

    switch (in_op) {
    default: /* should never happen */
        ret = 0;
        break;

    case CC_OP_EFLAGS:
        ret = in_src1;
        break;
    case CC_OP_POPCNT:
        ret = in_dst ? 0 : CC_Z;
        break;

    case CC_OP_MULB:
        ret = compute_all_mulb(in_dst, in_src1);
        break;
    case CC_OP_MULW:
        ret = compute_all_mulw(in_dst, in_src1);
        break;
    case CC_OP_MULL:
        ret = compute_all_mull(in_dst, in_src1);
        break;

    case CC_OP_ADDB:
        ret = compute_all_addb(in_dst, in_src1);
        break;
    case CC_OP_ADDW:
        ret = compute_all_addw(in_dst, in_src1);
        break;
    case CC_OP_ADDL:
        ret = compute_all_addl(in_dst, in_src1);
        break;

    case CC_OP_ADCB:
        ret = compute_all_adcb(in_dst, in_src1, in_src2);
        break;
    case CC_OP_ADCW:
        ret = compute_all_adcw(in_dst, in_src1, in_src2);
        break;
    case CC_OP_ADCL:
        ret = compute_all_adcl(in_dst, in_src1, in_src2);
        break;

    case CC_OP_SUBB:
        ret = compute_all_subb(in_dst, in_src1);
        break;
    case CC_OP_SUBW:
        ret = compute_all_subw(in_dst, in_src1);
        break;
    case CC_OP_SUBL:
        ret = compute_all_subl(in_dst, in_src1);
        break;

    case CC_OP_SBBB:
        ret = compute_all_sbbb(in_dst, in_src1, in_src2);
        break;
    case CC_OP_SBBW:
        ret = compute_all_sbbw(in_dst, in_src1, in_src2);
        break;
    case CC_OP_SBBL:
        ret = compute_all_sbbl(in_dst, in_src1, in_src2);
        break;

    case CC_OP_LOGICB:
        ret = compute_all_logicb(in_dst, in_src1);
        break;
    case CC_OP_LOGICW:
        ret = compute_all_logicw(in_dst, in_src1);
        break;
    case CC_OP_LOGICL:
        ret = compute_all_logicl(in_dst, in_src1);
        break;

    case CC_OP_INCB:
        ret = compute_all_incb(in_dst, in_src1);
        break;
    case CC_OP_INCW:
        ret = compute_all_incw(in_dst, in_src1);
        break;
    case CC_OP_INCL:
        ret = compute_all_incl(in_dst, in_src1);
        break;

    case CC_OP_DECB:
        ret = compute_all_decb(in_dst, in_src1);
        break;
    case CC_OP_DECW:
        ret = compute_all_decw(in_dst, in_src1);
        break;
    case CC_OP_DECL:
        ret = compute_all_decl(in_dst, in_src1);
        break;

    case CC_OP_SHLB:
        ret = compute_all_shlb(in_dst, in_src1);
        break;
    case CC_OP_SHLW:
        ret = compute_all_shlw(in_dst, in_src1);
        break;
    case CC_OP_SHLL:
        ret = compute_all_shll(in_dst, in_src1);
        break;

    case CC_OP_SARB:
        ret = compute_all_sarb(in_dst, in_src1);
        break;
    case CC_OP_SARW:
        ret = compute_all_sarw(in_dst, in_src1);
        break;
    case CC_OP_SARL:
        ret = compute_all_sarl(in_dst, in_src1);
        break;

    case CC_OP_BMILGB:
        ret = compute_all_bmilgb(in_dst, in_src1);
        break;
    case CC_OP_BMILGW:
        ret = compute_all_bmilgw(in_dst, in_src1);
        break;
    case CC_OP_BMILGL:
        ret = compute_all_bmilgl(in_dst, in_src1);
        break;

    case CC_OP_BLSIB:
        ret = compute_all_blsib(in_dst, in_src1);
        break;
    case CC_OP_BLSIW:
        ret = compute_all_blsiw(in_dst, in_src1);
        break;
    case CC_OP_BLSIL:
        ret = compute_all_blsil(in_dst, in_src1);
        break;

    case CC_OP_ADCX:
        ret = compute_all_adcx(in_dst, in_src1, in_src2);
        break;
    case CC_OP_ADOX:
        ret = compute_all_adox(in_dst, in_src1, in_src2);
        break;
    case CC_OP_ADCOX:
        ret = compute_all_adcox(in_dst, in_src1, in_src2);
        break;

#ifdef TARGET_X86_64
    case CC_OP_MULQ:
        ret = compute_all_mulq(in_dst, in_src1);
        break;
    case CC_OP_ADDQ:
        ret = compute_all_addq(in_dst, in_src1);
        break;
    case CC_OP_ADCQ:
        ret = compute_all_adcq(in_dst, in_src1, in_src2);
        break;
    case CC_OP_SUBQ:
        ret = compute_all_subq(in_dst, in_src1);
        break;
    case CC_OP_SBBQ:
        ret = compute_all_sbbq(in_dst, in_src1, in_src2);
        break;
    case CC_OP_LOGICQ:
        ret = compute_all_logicq(in_dst, in_src1);
        break;
    case CC_OP_INCQ:
        ret = compute_all_incq(in_dst, in_src1);
        break;
    case CC_OP_DECQ:
        ret = compute_all_decq(in_dst, in_src1);
        break;
    case CC_OP_SHLQ:
        ret = compute_all_shlq(in_dst, in_src1);
        break;
    case CC_OP_SARQ:
        ret = compute_all_sarq(in_dst, in_src1);
        break;
    case CC_OP_BMILGQ:
        ret = compute_all_bmilgq(in_dst, in_src1);
        break;
    case CC_OP_BLSIQ:
        ret = compute_all_blsiq(in_dst, in_src1);
        break;
#endif
    }
    return helper_A_return_one(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, lr, ret);
}
#endif

uint32_t cpu_cc_compute_all(CPUX86State *env)
{
    return helper_cc_compute_all(CC_DST, CC_SRC, CC_SRC2, CC_OP);
}

target_ulong helper_cc_compute_c(target_ulong dst, target_ulong src1,
                                 target_ulong src2, int op)
{
    switch (op) {
    default: /* should never happen */
    case CC_OP_LOGICB:
    case CC_OP_LOGICW:
    case CC_OP_LOGICL:
    case CC_OP_LOGICQ:
    case CC_OP_POPCNT:
        return 0;

    case CC_OP_EFLAGS:
    case CC_OP_SARB:
    case CC_OP_SARW:
    case CC_OP_SARL:
    case CC_OP_SARQ:
    case CC_OP_ADOX:
        return src1 & 1;

    case CC_OP_INCB:
    case CC_OP_INCW:
    case CC_OP_INCL:
    case CC_OP_INCQ:
    case CC_OP_DECB:
    case CC_OP_DECW:
    case CC_OP_DECL:
    case CC_OP_DECQ:
        return src1;

    case CC_OP_MULB:
    case CC_OP_MULW:
    case CC_OP_MULL:
    case CC_OP_MULQ:
        return src1 != 0;

    case CC_OP_ADCX:
    case CC_OP_ADCOX:
        return dst;

    case CC_OP_ADDB:
        return compute_c_addb(dst, src1);
    case CC_OP_ADDW:
        return compute_c_addw(dst, src1);
    case CC_OP_ADDL:
        return compute_c_addl(dst, src1);

    case CC_OP_ADCB:
        return compute_c_adcb(dst, src1, src2);
    case CC_OP_ADCW:
        return compute_c_adcw(dst, src1, src2);
    case CC_OP_ADCL:
        return compute_c_adcl(dst, src1, src2);

    case CC_OP_SUBB:
        return compute_c_subb(dst, src1);
    case CC_OP_SUBW:
        return compute_c_subw(dst, src1);
    case CC_OP_SUBL:
        return compute_c_subl(dst, src1);

    case CC_OP_SBBB:
        return compute_c_sbbb(dst, src1, src2);
    case CC_OP_SBBW:
        return compute_c_sbbw(dst, src1, src2);
    case CC_OP_SBBL:
        return compute_c_sbbl(dst, src1, src2);

    case CC_OP_SHLB:
        return compute_c_shlb(dst, src1);
    case CC_OP_SHLW:
        return compute_c_shlw(dst, src1);
    case CC_OP_SHLL:
        return compute_c_shll(dst, src1);

    case CC_OP_BMILGB:
        return compute_c_bmilgb(dst, src1);
    case CC_OP_BMILGW:
        return compute_c_bmilgw(dst, src1);
    case CC_OP_BMILGL:
        return compute_c_bmilgl(dst, src1);

    case CC_OP_BLSIB:
        return compute_c_blsib(dst, src1);
    case CC_OP_BLSIW:
        return compute_c_blsiw(dst, src1);
    case CC_OP_BLSIL:
        return compute_c_blsil(dst, src1);

#ifdef TARGET_X86_64
    case CC_OP_ADDQ:
        return compute_c_addq(dst, src1);
    case CC_OP_ADCQ:
        return compute_c_adcq(dst, src1, src2);
    case CC_OP_SUBQ:
        return compute_c_subq(dst, src1);
    case CC_OP_SBBQ:
        return compute_c_sbbq(dst, src1, src2);
    case CC_OP_SHLQ:
        return compute_c_shlq(dst, src1);
    case CC_OP_BMILGQ:
        return compute_c_bmilgq(dst, src1);
    case CC_OP_BLSIQ:
        return compute_c_blsiq(dst, src1);
#endif
    }
}

#ifdef AOT
target_ulong __attribute__((qemuaot,flatten)) helper_A_cc_compute_c(unsigned long rax, unsigned long rcx, unsigned long rdx, unsigned long rbx, unsigned long rsp, unsigned long rbp, unsigned long rsi, unsigned long rdi, unsigned long r8, unsigned long r9, unsigned long r10, unsigned long r11, unsigned long r12, unsigned long r13, unsigned long r14, unsigned long r15, unsigned long src, unsigned long dst, int op, unsigned long lr,
                                                                            unsigned long in_dst, unsigned long in_src1, unsigned long in_src2, int in_op)
{
    unsigned long ret = 0;
    switch (in_op) {
    default: /* should never happen */
    case CC_OP_LOGICB:
    case CC_OP_LOGICW:
    case CC_OP_LOGICL:
    case CC_OP_LOGICQ:
    case CC_OP_POPCNT:
        break;

    case CC_OP_EFLAGS:
    case CC_OP_SARB:
    case CC_OP_SARW:
    case CC_OP_SARL:
    case CC_OP_SARQ:
    case CC_OP_ADOX:
        ret = in_src1 & 1;
        break;

    case CC_OP_INCB:
    case CC_OP_INCW:
    case CC_OP_INCL:
    case CC_OP_INCQ:
    case CC_OP_DECB:
    case CC_OP_DECW:
    case CC_OP_DECL:
    case CC_OP_DECQ:
        ret = in_src1;
        break;

    case CC_OP_MULB:
    case CC_OP_MULW:
    case CC_OP_MULL:
    case CC_OP_MULQ:
        ret = in_src1 != 0;
        break;

    case CC_OP_ADCX:
    case CC_OP_ADCOX:
        ret = in_dst;
        break;

    case CC_OP_ADDB:
        ret = compute_c_addb(in_dst, in_src1);
        break;
    case CC_OP_ADDW:
        ret = compute_c_addw(in_dst, in_src1);
        break;
    case CC_OP_ADDL:
        ret = compute_c_addl(in_dst, in_src1);
        break;

    case CC_OP_ADCB:
        ret = compute_c_adcb(in_dst, in_src1, in_src2);
        break;
    case CC_OP_ADCW:
        ret = compute_c_adcw(in_dst, in_src1, in_src2);
        break;
    case CC_OP_ADCL:
        ret = compute_c_adcl(in_dst, in_src1, in_src2);
        break;

    case CC_OP_SUBB:
        ret = compute_c_subb(in_dst, in_src1);
        break;
    case CC_OP_SUBW:
        ret = compute_c_subw(in_dst, in_src1);
        break;
    case CC_OP_SUBL:
        ret = compute_c_subl(in_dst, in_src1);
        break;

    case CC_OP_SBBB:
        ret = compute_c_sbbb(in_dst, in_src1, in_src2);
        break;
    case CC_OP_SBBW:
        ret = compute_c_sbbw(in_dst, in_src1, in_src2);
        break;
    case CC_OP_SBBL:
        ret = compute_c_sbbl(in_dst, in_src1, in_src2);
        break;

    case CC_OP_SHLB:
        ret = compute_c_shlb(in_dst, in_src1);
        break;
    case CC_OP_SHLW:
        ret = compute_c_shlw(in_dst, in_src1);
        break;
    case CC_OP_SHLL:
        ret = compute_c_shll(in_dst, in_src1);
        break;

    case CC_OP_BMILGB:
        ret = compute_c_bmilgb(in_dst, in_src1);
        break;
    case CC_OP_BMILGW:
        ret = compute_c_bmilgw(in_dst, in_src1);
        break;
    case CC_OP_BMILGL:
        ret = compute_c_bmilgl(in_dst, in_src1);
        break;

    case CC_OP_BLSIB:
        ret = compute_c_blsib(in_dst, in_src1);
        break;
    case CC_OP_BLSIW:
        ret = compute_c_blsiw(in_dst, in_src1);
        break;
    case CC_OP_BLSIL:
        ret = compute_c_blsil(in_dst, in_src1);
        break;

#ifdef TARGET_X86_64
    case CC_OP_ADDQ:
        ret = compute_c_addq(in_dst, in_src1);
        break;
    case CC_OP_ADCQ:
        ret = compute_c_adcq(in_dst, in_src1, in_src2);
        break;
    case CC_OP_SUBQ:
        ret = compute_c_subq(in_dst, in_src1);
        break;
    case CC_OP_SBBQ:
        ret = compute_c_sbbq(in_dst, in_src1, in_src2);
        break;
    case CC_OP_SHLQ:
        ret = compute_c_shlq(in_dst, in_src1);
        break;
    case CC_OP_BMILGQ:
        ret = compute_c_bmilgq(in_dst, in_src1);
        break;
    case CC_OP_BLSIQ:
        ret = compute_c_blsiq(in_dst, in_src1);
        break;
#endif
    }
    return helper_A_return_one(rax, rcx, rdx, rbx, rsp, rbp, rsi, rdi, r8, r9, r10, r11, r12, r13, r14, r15, src, dst, op, lr, ret);
}
#endif

void helper_write_eflags(CPUX86State *env, target_ulong t0,
                         uint32_t update_mask)
{
    cpu_load_eflags(env, t0, update_mask);
}

target_ulong helper_read_eflags(CPUX86State *env)
{
    uint32_t eflags;

    eflags = cpu_cc_compute_all(env);
    eflags |= (env->df & DF_MASK);
    eflags |= env->eflags & ~(VM_MASK | RF_MASK);
    return eflags;
}

void helper_clts(CPUX86State *env)
{
    env->cr[0] &= ~CR0_TS_MASK;
    env->hflags &= ~HF_TS_MASK;
}
