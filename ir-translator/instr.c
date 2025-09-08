#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include "tcg_ast.h"

#define SET_SLOT(IDX)                               \
    do {                                            \
        assert(s##IDX.s.slot_type <= SUB_SLOT_TMPT);      \
        i->slot##IDX##_type = s##IDX.s.slot_type;    \
        i->slot##IDX##_idx = s##IDX.s.slot_idx;   \
    } while (0)

uint8_t instr_buf[64];
static uint64_t tcg_next_capacity = (128 * 1024);
static uint64_t tcg_instrs_capacity = 0;
static size_t tcg_instrs_idx = 0;
static uint8_t *tcg_instrs = NULL;
static uint16_t xmm_offsets[16] = {0};

void *get_instr_buffer() {
    return (void *)tcg_instrs;
}

size_t get_instr_buffer_size() {
    return tcg_instrs_idx;
}

void reset_instr_buffer() {
    tcg_instrs_idx = 0;
}

void register_xmm(uint64_t idx, uint64_t offset) {
    assert(idx < 15);
    xmm_offsets[idx] = (uint16_t)offset;
}

void register_xmm_tmp(uint64_t offset) {
    xmm_offsets[15] = (uint16_t)offset;
}

XMMReg lookup_xmm(uint64_t offset) {
    uint16_t off = (uint16_t)offset;
    XMMReg x;
    x.xmm_idx = NON_XMM;
    x.xmm_offset = 0;
    if (xmm_offsets[0] <= off && off < (xmm_offsets[14] + 0x20)) {
        uint16_t idx = (off - xmm_offsets[0]) / 0x40;
        uint16_t delta = (off - xmm_offsets[0]) % 0x40;
        if (delta < 0x10) {
            x.xmm_idx = idx * 2;
            x.xmm_offset = delta;
        } else if (delta < 0x20) {
            x.xmm_idx = idx * 2 + 1;
            x.xmm_offset = delta - 0x10;
        }
    } else if (xmm_offsets[15] <= off && off < (xmm_offsets[15] + 0x20)) {
        if ((off - xmm_offsets[15]) < 0x10) {
            x.xmm_idx = XMMT;
            x.xmm_offset = (off - xmm_offsets[15]);
        } else {
            x.xmm_idx = YMMT_H;
            x.xmm_offset = (off - (xmm_offsets[15] + 0x10));
        }
    }
    return x;
}

const char *attr_type_str[] = {
    #define X(name) #name,
    ATTR_TYPE_LIST
    #undef X
};

const char *envvar_type_str[] = {
    #define X(name) #name,
    ENVVAR_TYPE_LIST
    #undef X
};

const char *xreg_type_str[] = {
    #define X(name) #name,
    XREG_TYPE_LIST
    #undef X
};

const char *relop_type_str[] = {
    #define X(name) #name,
    RELOP_TYPE_LIST
    #undef X
};

const char *helper_str[] = {
    #define X(name) #name,
    HELPER_LIST
    #undef X
};

const char *opcode_type_str[] = {
    #define X(name) #name,
    OPCODE_TYPE_LIST
    #undef X
};

const char *alignment_type_str[] = {
    #define X(name) #name,
    ALIGNMENT_TYPE_LIST
    #undef X
};

const char *srcext_type_str[] = {
    #define X(name) #name,
    SRCEXT_TYPE_LIST
    #undef X
};

const char *slot_type_str[] = {
    #define X(name) #name,
    SLOT_TYPE_LIST
    #undef X
};

const char *instr_type_str[] = {
    #define X(name) #name,
    INSTR_TYPE_LIST
    #undef X
};

const char *instr_ext_type_str[] = {
    #define X(name) #name,
    INSTR_EXT_TYPE_LIST
    #undef X
};

static void get_more_space() {
    tcg_instrs = realloc(tcg_instrs, tcg_next_capacity);
    assert(tcg_instrs);
    tcg_instrs_capacity = tcg_next_capacity;
    tcg_next_capacity *= 2;
}

void insert_instr(void *ptr_src, size_t sz) {
    if ((tcg_instrs_idx + sz) > tcg_instrs_capacity) {
        get_more_space();
    }
    void *ptr = (void *)&(tcg_instrs[tcg_instrs_idx]);
    if (sz == 2) {
        *(uint16_t *)ptr = *(uint16_t *)ptr_src;
    } else if (sz == 4) {
        *(uint32_t *)ptr = *(uint32_t *)ptr_src;
    } else if (sz == 8) {
        *(uint64_t *)ptr = *(uint64_t *)ptr_src;
    } else {
        memcpy(ptr, ptr_src, sz);
    }
    tcg_instrs_idx += sz;
}

static void dump_2B(Instr2B i) {
}

static void dump_4B(Instr4B i) {
}

static void dump_instr() {
    uint64_t idx = 0;
    while (idx < tcg_instrs_idx) {
        Instr2B *ptr2b = (Instr2B *)&tcg_instrs[idx];
        Instr4B *ptr4b = (Instr4B *)&tcg_instrs[idx];
        if (ptr2b->instr_type == SIZE2B) {
            dump_2B(ptr2b[0]);
            idx += sizeof(Instr2B);
        } else if (ptr2b->instr_type == SIZE4B) {
            dump_4B(ptr4b[0]);
            idx += sizeof(Instr4B);
        } else {
            assert(0);
        }
    }
}

/* Sort by frequency in hello_world_static
 203957 create_scalar_slot2
 133839 create_jmpdirect
  95461 create_scalar_slot_imm
  85552 create_discard
  45306 create_scalar_slot2_imm
  42241 create_scalar_slot2_attr3_num
  39656 create_scalar_slot3
  27067 create_vector_slot_env_imm
  21561 create_scalar_slot2_imm2
  16724 create_scalar_slot_env_imm
  15543 create_branch_condition
  15503 create_setlabel
  10967 create_helper_slot4
   6448 create_vector_slot3
   5969 create_helper_slot5
   4961 create_vector_slot_vimm
   4927 create_scalar_slot3_attr3_num
   4305 create_vector_slot2_imm
   3924 create_calldirect
   2987 create_vector_slot2
   2259 create_vector_slot3_relop
   1939 create_helper_env_imm
   1924 create_scalar_slot
   1901 create_scalar_slot3_imm
   1435 create_vector_slot2_vimm
   1232 create_scalar_slot2_imm_slot2_relop
    800 create_scalar_slot3_imm2
    581 create_helper_env_slot3
    558 create_scalar_imm_env_imm
    510 create_helper_env_slot
    398 create_scalar_slot2_imm_slot_imm_relop
    276 create_scalar_slot5_relop
    255 create_helper_env_slot3_imm
    229 create_scalar_slot2_imm_relop
    151 create_helper_env_slot2_imm
    138 create_helper_env
    110 create_helper_env_imm_slot
     47 create_scalar_slot2_attr
     30 create_scalar_slot_imm_slot
     29 create_helper_slot3
     22 create_scalar_slot2_imm2_slot_relop
     21 create_helper_slot2_imm2
     20 create_helper_slot2_imm
     15 create_scalar_slot3_relop
     15 create_helper_env_imm2
     10 create_helper_env_slot_imm
      8 create_scalar_slot2_attr2
      8 create_helper_slot_env_slot
      7 create_scalar_imm_slot_imm
      7 create_helper_env_slot2
      5 create_helper_slot_env
      5 create_helper_slot3_imm
 */
size_t create_scalar_slot2(void *ptr, OpCodeType op, OperandType s0, OperandType s1) {
    Instr4B *i = (Instr4B *)ptr;
    i->instr_type = SIZE4B;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    i->attr_type = SUB_ATTR_INVALID;
    return sizeof(*i);
}

size_t create_scalar_slot2_attr(void *ptr, OpCodeType op, OperandType s0, OperandType s1, AttrSrcInfo a0) {
    Instr4B *i = (Instr4B *)ptr;
    i->instr_type = SIZE4B;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(a0.subt == SUB_ATTR_SWAP);
    i->attr_type = a0.subt;
    i->attr_val = a0.p.swap;
    return sizeof(*i);
}

size_t create_scalar_slot2_attr2(void *ptr, OpCodeType op, OperandType s0, OperandType s1, AttrSrcInfo a0, AttrSrcInfo a1) {
    Instr4B *i = (Instr4B *)ptr;
    i->instr_type = SIZE4B;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(a0.subt == SUB_ATTR_SWAP);
    assert(a0.subt == a1.subt);
    i->attr_type = a0.subt;
    i->attr_val = a0.p.swap | a1.p.swap;
    return sizeof(*i);
}

size_t create_jmpdirect(void *ptr, uint64_t val) {
    if (likely(val < (1<<5))) {
        Instr2B *i = (Instr2B *)ptr;
        i->instr_type = SIZE2B;
        i->opc = jmp_direct;
        i->imm = val;
        return sizeof(*i);
    } else {
        Instr1B14 *i = (Instr1B14 *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1B14_ext;
        i->opc = jmp_direct;
        assert((uint64_t)((long)((int32_t)val)) == val);
        i->imm = val;
        return sizeof(*i);
    }
}

size_t create_scalar_slot_imm(void *ptr, OpCodeType op, OperandType s0, uint64_t i0) {
    if (likely((uint64_t)((long)((int32_t)i0)) == i0)) {
        Instr2B4 *i = (Instr2B4 *)ptr;
        i->instr_type = SIZE6B;
        i->opc = op;
        SET_SLOT(0);
        i->imm = i0;
        return sizeof(*i);
    } else {
        Instr1B28 *i = (Instr1B28 *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1B28_ext;
        i->opc = op;
        SET_SLOT(0);
        i->imm = i0;
        return sizeof(*i);
    }
}

size_t create_scalar_slot2_imm(void *ptr, OpCodeType op, OperandType s0, OperandType s1, uint64_t i0) {
    Instr1B44 *i = (Instr1B44 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B44_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert((uint64_t)((long)((int32_t)i0)) == i0);
    i->imm = i0;
    return sizeof(*i);
}

// Ignore num which is used as mmuidx for now.
size_t create_scalar_slot2_attr3_num(void *ptr, OpCodeType op, OperandType s0, OperandType s1, AttrSrcInfo a0, AttrSrcInfo a1, AttrSrcInfo a2, uint64_t n0) {
    Instr4B *i = (Instr4B *)ptr;
    i->instr_type = SIZE4B;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(a0.subt == SUB_ATTR_ATOMIC && a1.subt == SUB_ATTR_ALIGNMENT && a2.subt == SUB_ATTR_SRCSIZEEXT);
    i->attr_type = SUB_ATTR_STORAGE;
    i->attr_val = (a0.p.storage.attr.atomic << 6) | (a1.p.storage.attr.alignment << 4) | (a2.p.storage.attr.ext << 3) | a2.p.storage.size;
    return sizeof(*i);
}

size_t create_scalar_slot3(void *ptr, OpCodeType op, OperandType s0, OperandType s1, OperandType s2) {
    Instr1B4 *i = (Instr1B4 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B4_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    return sizeof(*i);
}

size_t create_vector_slot_env_imm(void *ptr, OpCodeType op, AttrSrcInfo ai, OperandType s0, uint64_t i0) {
    XMMReg x = lookup_xmm(i0);
    if (x.xmm_idx != NON_XMM) {
        Instr1BV4X *i = (Instr1BV4X *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1BV4X_ext;
        i->opc = op;
        i->es = ai.p.ves;
        SET_SLOT(0);
        i->xmm_idx = x.xmm_idx;
        i->xmm_offset = x.xmm_offset;
        return sizeof(*i);
    } else {
        Instr1BV4XE *i = (Instr1BV4XE *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1BV4XE_ext;
        i->opc = op;
        i->es = ai.p.ves;
        SET_SLOT(0);
        i->env_offset = i0;
        return sizeof(*i);
    }
}

size_t create_scalar_slot2_imm2(void *ptr, OpCodeType op, OperandType s0, OperandType s1, uint64_t i0, uint64_t i1) {
    Instr1B41I2 *i = (Instr1B41I2 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B41I2_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(i0 < (1<<8));
    i->imm0 = i0;
    assert(i1 < (1<<8));
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_scalar_slot_env_imm(void *ptr, OpCodeType op, OperandType s0, uint64_t i0) {
    XMMReg x = lookup_xmm(i0);
    if (x.xmm_idx != NON_XMM) {
        Instr1B4X *i = (Instr1B4X *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1B4X_ext;
        i->opc = op;
        SET_SLOT(0);
        i->xmm_idx = x.xmm_idx;
        i->xmm_offset = x.xmm_offset;
        return sizeof(*i);
    } else {
        Instr1B22 *i = (Instr1B22 *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1B22_ext;
        i->opc = op;
        SET_SLOT(0);
        assert(i0 < (1<<16));
        i->env_offset = i0;
        return sizeof(*i);
    }
}

size_t create_branch_condition(void *ptr, OperandType s0, uint64_t i0, uint8_t relop, uint8_t label) {
    Instr1B21 *i = (Instr1B21 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B21_ext;
    i->opc = brcond_i64;
    SET_SLOT(0);
    i->imm = i0;
    i->relop = relop;
    assert(label <= 2);
    i->label = label;
    return sizeof(*i);
}

size_t create_setlabel(void *ptr, OpCodeType op, uint8_t label) {
    Instr1B2 *i = (Instr1B2 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B2_ext;
    i->opc = set_label;
    assert(label <= 2);
    i->label = label;
    return sizeof(*i);
}

size_t create_helper_slot4(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, OperandType s3) {
    Instr1BH4 *i = (Instr1BH4 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4_ext;
    i->helper_l = (uint8_t)h;
    i->helper_h = h >> 8;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    return sizeof(*i);
}

size_t create_vector_slot3(void *ptr, OpCodeType op, AttrSrcInfo ai, OperandType s0, OperandType s1, OperandType s2) {
    Instr1BV4 *i = (Instr1BV4 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV4_ext;
    i->opc = op;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    return sizeof(*i);
}

size_t create_helper_slot5(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, OperandType s3, OperandType s4) {
    Instr1BH141 *i = (Instr1BH141 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH141_ext;
    i->helper_l = (uint8_t)h;
    i->helper_h = h >> 8;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    SET_SLOT(4);
    return sizeof(*i);
}

size_t create_vector_slot_vimm(void *ptr, OpCodeType op, AttrSrcInfo ai, OperandType s0, uint64_t vi0) {
    Instr1BV21 *i = (Instr1BV21 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV21_ext;
    i->opc = op;
    i->es = ai.p.ves;
    SET_SLOT(0);
    assert(vi0 < (1<<8));
    i->imm = vi0;
    return sizeof(*i);
}

// Ignore num which is used as mmuidx for now.
size_t create_scalar_slot3_attr3_num(void *ptr, OpCodeType op, OperandType s0, OperandType s1, OperandType s2, AttrSrcInfo a0, AttrSrcInfo a1, AttrSrcInfo a2, uint64_t n0) {
    Instr1B41 *i = (Instr1B41 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B41_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(a0.subt == SUB_ATTR_ATOMIC && a1.subt == SUB_ATTR_ALIGNMENT && a2.subt == SUB_ATTR_SRCSIZEEXT);
    i->attr_type = SUB_ATTR_STORAGE;
    i->attr_val = (a0.p.storage.attr.atomic << 6) | (a1.p.storage.attr.alignment << 4) | (a2.p.storage.attr.ext << 3) | a2.p.storage.size;
    return sizeof(*i);
}

size_t create_vector_slot2_imm(void *ptr, OpCodeType op, AttrSrcInfo ai, OperandType s0, OperandType s1, uint64_t i0) {
    Instr1BV4I *i = (Instr1BV4I *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV4I_ext;
    i->opc = op;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(i0 < (1<<8));
    i->imm = i0;
    return sizeof(*i);
}

size_t create_slot_imm2(void *ptr, OpCodeType op, OperandType s0, uint64_t i0, uint64_t i1) {
    Instr1B24 *i = (Instr1B24 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B24_ext;
    i->opc = op;
    SET_SLOT(0);
    assert(i0 < (1<<8));
    i->imm0 = i0;
    // NOTICE: those calls to negative address are illegal
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_vector_slot2(void *ptr, OpCodeType op, AttrSrcInfo ai, OperandType s0, OperandType s1) {
    Instr1BV4S2 *i = (Instr1BV4S2 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV4S2_ext;
    i->opc = op;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    return sizeof(*i);
}

size_t create_vector_slot3_relop(void *ptr, OpCodeType op, AttrSrcInfo ai, OperandType s0, OperandType s1, OperandType s2, uint8_t relop) {
    Instr1BV41 *i = (Instr1BV41 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV41_ext;
    i->opc = op;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i->relop = relop;
    return sizeof(*i);
}

size_t create_helper_env_imm(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, uint32_t i0) {
    Instr1BH24I *i = (Instr1BH24I *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH24I_ext;
    i->helper = h;
    assert(noargs == 0);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_slot(void *ptr, OpCodeType op, OperandType s0) {
    Instr1B2S *i = (Instr1B2S *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B2S_ext;
    i->opc = op;
    SET_SLOT(0);
    return sizeof(*i);
}

size_t create_scalar_slot3_imm(void *ptr, OpCodeType op, OperandType s0, OperandType s1, OperandType s2, uint64_t i0) {
    Instr1B41I *i = (Instr1B41I *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B41I_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(i0 < (1<<8));
    i->imm = i0;
    return sizeof(*i);
}

size_t create_vector_slot2_vimm(void *ptr, OpCodeType op, AttrSrcInfo ai, OperandType s0, OperandType s1, uint64_t vi0) {
    Instr1BV48 *i = (Instr1BV48 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV48_ext;
    i->opc = op;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm = vi0;
    return sizeof(*i);
}

size_t create_scalar_slot2_imm_slot2_relop(void *ptr, OpCodeType op, OperandType s0, OperandType s1, uint64_t i0, OperandType s2, OperandType s3, RelopType r) {
    Instr1B422 *i = (Instr1B422 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B422_ext;
    i->opc = op;
    i->relop = r;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    assert(i0 < (1<<16));
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_slot3_imm2(void *ptr, OpCodeType op, OperandType s0, OperandType s1, OperandType s2, uint64_t i0, uint64_t i1) {
    Instr1B411 *i = (Instr1B411 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B411_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(i0 < (1<<8));
    i->imm0 = i0;
    assert(i1 < (1<<8));
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_scalar_imm_env_imm(void *ptr, OpCodeType op, uint64_t i0, uint64_t i1) {
    XMMReg x = lookup_xmm(i1);
    if (x.xmm_idx != NON_XMM) {
        Instr1B142 *i = (Instr1B142 *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1B142_ext;
        i->opc = op;
        assert(i0 < (1UL<<32));
        i->imm = i0;
        i->xmm_idx = x.xmm_idx;
        i->xmm_offset = x.xmm_offset;
        return sizeof(*i);
    } else {
        Instr1B142E *i = (Instr1B142E *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1B142E_ext;
        i->opc = op;
        assert(i0 < (1UL<<32));
        i->imm = i0;
        assert((uint64_t)((long)((int16_t)i1)) == i1);
        i->env_offset = (uint16_t)i1;
        return sizeof(*i);
    }
}

size_t create_helper_env_slot(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, OperandType s0) {
    Instr1BH21 *i = (Instr1BH21 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH21_ext;
    i->helper = h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    return sizeof(*i);
}

size_t create_scalar_slot2_imm_slot_imm_relop(void *ptr, OpCodeType op, OperandType s0, OperandType s1, uint64_t i0, OperandType s2, uint64_t i1, RelopType r) {
    Instr1B4111 *i = (Instr1B4111 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B4111_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(i0 < (1<<8));
    i->imm0 = i0;
    assert(i1 < (1<<8));
    i->imm1 = i1;
    i->relop = r;
    return sizeof(*i);
}

size_t create_scalar_slot5_relop(void *ptr, OpCodeType op, OperandType s0, OperandType s1, OperandType s2, OperandType s3, OperandType s4, RelopType r) {
    Instr1B8 *i = (Instr1B8 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B8_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    SET_SLOT(4);
    return sizeof(*i);
}

size_t create_helper_env_slot3_imm(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, uint32_t i0) {
    Instr1BH4I *i = (Instr1BH4I *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4I_ext;
    i->helper_l = (uint8_t)h;
    i->helper_h = h >> 8;
    assert(noargs == 0);
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(i0 < (1 << 8) || (i0 & 0xffffff80) == 0xffffff80);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_slot2_imm_relop(void *ptr, OpCodeType op, OperandType s0, OperandType s1, uint64_t i0, RelopType r) {
    Instr1B42 *i = (Instr1B42 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B42_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(i0 < (1<<16));
    i->imm = i0;
    i->relop = r;
    return sizeof(*i);
}

size_t create_helper_env(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs) {
    Instr1BH2 *i = (Instr1BH2 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH2_ext;
    i->helper = h;
    assert(noargs == 0);
    return sizeof(*i);
}

size_t create_helper_env_imm_slot(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, uint32_t i0, OperandType s0) {
    Instr1BH21S *i = (Instr1BH21S *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH21S_ext;
    i->helper = h;
    assert(noargs < 2);
    i->noargs = noargs;
    assert(i0 < (1<<4));
    i->imm = i0;
    SET_SLOT(0);
    return sizeof(*i);
}

size_t create_scalar_slot_imm_slot(void *ptr, OpCodeType op, OperandType s0, uint64_t i0, OperandType s1) {
    Instr1B281 *i = (Instr1B281 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B281_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_helper_slot3(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2) {
    Instr1BH4S3 *i = (Instr1BH4S3 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4S3_ext;
    i->helper_l = (uint8_t)h;
    i->helper_h = h >> 8;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    return sizeof(*i);
}

size_t create_scalar_slot2_imm2_slot_relop(void *ptr, OpCodeType op, OperandType s0, OperandType s1, uint64_t i0, uint64_t i1, OperandType s2, RelopType r) {
    Instr1B4112 *i = (Instr1B4112 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B4112_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(i0 < (1<<8));
    i->imm0 = i0;
    assert(i1 < (1<<8));
    i->imm1 = i1;
    i->relop = r;
    return sizeof(*i);
}

size_t create_helper_slot2_imm2(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, uint32_t i0, uint32_t i1) {
    Instr1BH412 *i = (Instr1BH412 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH412_ext;
    i->helper = h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(i0 < (1<<8));
    i->imm0 = i0;
    assert(i1 < (1<<16));
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_helper_slot2_imm(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, uint32_t i0) {
    Instr1BH41 *i = (Instr1BH41 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH41_ext;
    i->helper = h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(i0 < (1<<8));
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_slot3_relop(void *ptr, OpCodeType op, OperandType s0, OperandType s1, OperandType s2, RelopType r) {
    Instr1B41R *i = (Instr1B41R *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B41R_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i->relop = r;
    return sizeof(*i);
}

size_t create_helper_env_imm2(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, uint32_t i0, uint32_t i1) {
    Instr1BH24 *i = (Instr1BH24 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH24_ext;
    i->helper = h;
    assert(noargs < 2);
    i->noargs = noargs;
    assert(i0 < (1<<4));
    i->imm0 = i0;
    assert(i1 < (1UL<<32));
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_helper_env_slot_imm(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, OperandType s0, uint32_t i0) {
    Instr1BH211 *i = (Instr1BH211 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH211_ext;
    i->helper = h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    assert(i0 < (1<<8));
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_imm_slot_imm(void *ptr, OpCodeType op, uint64_t i0, OperandType s0, uint64_t i1) {
    Instr1B1111 *i = (Instr1B1111 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B1111_ext;
    i->opc = op;
    assert(i0 < (1<<8));
    i->imm0 = i0;
    SET_SLOT(0);
    assert(i1 < (1<<8));
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_helper_env_slot2(void *ptr, HelperType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1) {
    Instr1BH4S *i = (Instr1BH4S *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4S_ext;
    i->helper = h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    return sizeof(*i);
}

// INPUT-slot-bits, INPUT-effective-bits, OUTPUT-bits
LLVMType opciosz[OPCODE_MAX][3] = {
    [add_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [andc_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [and_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [and_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    // high 32bits ignored
    [bswap32_i64] = {LLVMInt64, LLVMInt32, LLVMInt64},
    [clz_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [ctz_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [deposit_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [deposit_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [extract2_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [extract_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [extract_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [extrl_i64_i32] = {LLVMInt64, LLVMInt32, LLVMInt32},
    [extu_i32_i64] = {LLVMInt32, LLVMInt32, LLVMInt64},
    [ld32s_i64] = {LLVMInt32, LLVMInt32, LLVMInt64},
    [ld32u_i64] = {LLVMInt32, LLVMInt32, LLVMInt64},
    [ld8u_i64] = {LLVMInt8, LLVMInt8, LLVMInt64},
    [ld_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [ld_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [movcond_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [movcond_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [mov_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [mov_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [mov_i64_const] = {LLVMInvalidType, LLVMInvalidType, LLVMInt64},
    [mul_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [mul_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [mulsh_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [muluh_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [neg_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [neg_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [negsetcond_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [not_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [or_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [or_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [push_ret_addr] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [qemu_ld2_i128] = {LLVMInvalidType, LLVMInvalidType, LLVMInt64},
    [qemu_ld_i32] = {LLVMInvalidType, LLVMInvalidType, LLVMInt32},
    [qemu_ld_i64] = {LLVMInvalidType, LLVMInvalidType, LLVMInt64},
    [qemu_st2_i128] = {LLVMInt64, LLVMInvalidType, LLVMInvalidType},
    [qemu_st_i32] = {LLVMInt32, LLVMInvalidType, LLVMInvalidType},
    [qemu_st_i64] = {LLVMInt64, LLVMInvalidType, LLVMInvalidType},
    [ret] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [rotr_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [rotr_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [sar_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [setcond_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [sextract_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [shl_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [shl_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [shr_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [shr_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [st16_i32] = {LLVMInt32, LLVMInt16, LLVMInvalidType},
    [st16_i64] = {LLVMInt64, LLVMInt16, LLVMInvalidType},
    [st32_i64] = {LLVMInt64, LLVMInt32, LLVMInvalidType},
    [st_i32] = {LLVMInt32, LLVMInt32, LLVMInvalidType},
    [st_i64] = {LLVMInt64, LLVMInt64, LLVMInvalidType},
    [sub_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [sub_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [xor_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [xor_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [bswap64_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [brcond_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [call_direct] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [add_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [andc_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [and_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [cmp_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [dupm_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [ld_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [mov_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [or_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [shli_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [st_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [sub_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [umax_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [umin_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [xor_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
};

uint8_t opcoc[OPCODE_MAX] = {
    [add_i64] = 1,
    [andc_i64] = 1,
    [and_i64] = 1,
    [and_i32] = 1,
    [bswap32_i64] = 1,
    [clz_i64] = 1,
    [ctz_i64] = 1,
    [deposit_i32] = 1,
    [deposit_i64] = 1,
    [extract2_i64] = 1,
    [extract_i32] = 1,
    [extract_i64] = 1,
    [extrl_i64_i32] = 1,
    [extu_i32_i64] = 1,
    [ld32s_i64] = 1,
    [ld32u_i64] = 1,
    [ld8u_i64] = 1,
    [ld_i32] = 1,
    [ld_i64] = 1,
    [movcond_i32] = 1,
    [movcond_i64] = 1,
    [mov_i32] = 1,
    [mov_i64] = 1,
    [mov_i64_const] = 1,
    [mul_i32] = 1,
    [mul_i64] = 1,
    [mulsh_i64] = 1,
    [muluh_i64] = 1,
    [neg_i32] = 1,
    [neg_i64] = 1,
    [negsetcond_i64] = 1,
    [not_i64] = 1,
    [or_i64] = 1,
    [or_i32] = 1,
    [push_ret_addr] = 1,
    [qemu_ld2_i128] = 2,
    [qemu_ld_i32] = 1,
    [qemu_ld_i64] = 1,
    [qemu_st2_i128] = 0,
    [qemu_st_i32] = 0,
    [qemu_st_i64] = 0,
    [ret] = 0,
    [rotr_i32] = 1,
    [rotr_i64] = 1,
    [sar_i64] = 1,
    [setcond_i64] = 1,
    [sextract_i64] = 1,
    [shl_i64] = 1,
    [shl_i32] = 1,
    [shr_i64] = 1,
    [shr_i32] = 1,
    [st16_i32] = 0,
    [st16_i64] = 0,
    [st32_i64] = 0,
    [st_i32] = 0,
    [st_i64] = 0,
    [sub_i64] = 1,
    [sub_i32] = 1,
    [xor_i64] = 1,
    [xor_i32] = 1,
    [bswap64_i64] = 1,
    [brcond_i64] = 0,
    [call_direct] = 0,
    [add_vec] = 1,
    [andc_vec] = 1,
    [and_vec] = 1,
    [cmp_vec] = 1,
    [dupm_vec] = 1,
    [ld_vec] = 1,
    [mov_vec] = 1,
    [or_vec] = 1,
    [shli_vec] = 1,
    [st_vec] = 0,
    [sub_vec] = 1,
    [umax_vec] = 1,
    [umin_vec] = 1,
    [xor_vec] = 1,
};
