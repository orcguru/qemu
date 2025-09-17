#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include "tcg_ast.h"

#define SET_SLOT(IDX)                               \
    do {                                            \
        s##IDX = get_mapped_slot(s##IDX);    \
        i->slot##IDX##_type = s##IDX.s.slot_type;   \
        i->slot##IDX##_idx = s##IDX.s.slot_idx;     \
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

uint64_t get_xmm_offset(uint64_t idx) {
    assert(idx <= 15);
    return xmm_offsets[idx];
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
            x.xmm_idx = xmmt;
            x.xmm_offset = (off - xmm_offsets[15]);
        } else {
            x.xmm_idx = ymmt_h;
            x.xmm_offset = (off - (xmm_offsets[15] + 0x10));
        }
    }
    return x;
}

static uint8_t tmpl_map[1<<6] = {0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
static uint8_t tmpt_map[1<<6] = {0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff,0xff};
static uint8_t tmp_idx = 0;

OperandType get_mapped_slot(OperandType slot) {
    if (slot.s.slot_type == SUB_SLOT_TMPL) {
        assert(slot.s.slot_idx < (1<<6));
        if (tmpl_map[slot.s.slot_idx] == 0xff) {
            assert(tmp_idx < (1<<5));
            //printf("register loc%d as %d\n", slot.s.slot_idx, tmp_idx);
            tmpl_map[slot.s.slot_idx] = tmp_idx;
            tmp_idx += 1;
        }
        slot.s.slot_type = SUB_SLOT_TMP;
        slot.s.slot_idx = tmpl_map[slot.s.slot_idx];
        return slot;
    } else if (slot.s.slot_type == SUB_SLOT_TMPT) {
        assert(slot.s.slot_idx < (1<<6));
        if (tmpt_map[slot.s.slot_idx] == 0xff) {
            assert(tmp_idx < (1<<5));
            //printf("register tmp%d as %d\n", slot.s.slot_idx, tmp_idx);
            tmpt_map[slot.s.slot_idx] = tmp_idx;
            tmp_idx += 1;
        }
        slot.s.slot_type = SUB_SLOT_TMP;
        slot.s.slot_idx = tmpt_map[slot.s.slot_idx];
        return slot;
    } else {
        return slot;
    }
}

void reset_tmp_mapping() {
    memset(tmpl_map, 0xff, sizeof(tmpl_map));
    memset(tmpt_map, 0xff, sizeof(tmpt_map));
    tmp_idx = 0;
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

const char *llvm_type_str[] = {
    #define X(name) #name,
    LLVM_TYPE_LIST
    #undef X
};

const char *xmmreg_str[] = {
    #define X(name) #name,
    XMM_REG_LIST
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

size_t create_scalar_slot2_immUL(void *ptr, OpCodeType op, OperandType s0, OperandType s1, uint64_t i0) {
    Instr1B48 *i = (Instr1B48 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B48_ext;
    i->opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
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
    i->label = label;
    return sizeof(*i);
}

size_t create_setlabel(void *ptr, OpCodeType op, uint8_t label) {
    Instr1B2 *i = (Instr1B2 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B2_ext;
    i->opc = set_label;
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

size_t create_vector_slot5_relop(void *ptr, OpCodeType op, AttrSrcInfo ai, OperandType s0, OperandType s1, OperandType s2, OperandType s3, OperandType s4, uint8_t relop) {
    Instr1BV8 *i = (Instr1BV8 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV8_ext;
    i->opc = op;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    SET_SLOT(4);
    i->relop = relop;
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
    assert((uint64_t)((long)((int32_t)i1)) == i1);
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
    i->relop = r;
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
    [qemu_ld2_i128] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [qemu_ld_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [qemu_ld_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [qemu_st2_i128] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [qemu_st_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [qemu_st_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [ret] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [rotr_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [rotr_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [sar_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [sar_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [setcond_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [sextract_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [shl_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [shl_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [shr_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [shr_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [st16_i32] = {LLVMInt32, LLVMInt16, LLVMInt16},
    [st16_i64] = {LLVMInt64, LLVMInt16, LLVMInt16},
    [st32_i64] = {LLVMInt64, LLVMInt32, LLVMInt32},
    [st_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [st_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
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
    [movcond_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
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
    [push_ret_addr] = 0,
    [qemu_ld2_i128] = 2,
    [qemu_ld_i32] = 1,
    [qemu_ld_i64] = 1,
    [qemu_st2_i128] = 0,
    [qemu_st_i32] = 0,
    [qemu_st_i64] = 0,
    [ret] = 0,
    [rotr_i32] = 1,
    [rotr_i64] = 1,
    [sar_i32] = 1,
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
    [movcond_vec] = 1,
};

uint8_t opcmem_addr_nzidx[OPCODE_MAX] = {
    [add_i64] = 0,
    [andc_i64] = 0,
    [and_i64] = 0,
    [and_i32] = 0,
    [bswap32_i64] = 0,
    [clz_i64] = 0,
    [ctz_i64] = 0,
    [deposit_i32] = 0,
    [deposit_i64] = 0,
    [extract2_i64] = 0,
    [extract_i32] = 0,
    [extract_i64] = 0,
    [extrl_i64_i32] = 0,
    [extu_i32_i64] = 0,
    [ld32s_i64] = 1,
    [ld32u_i64] = 1,
    [ld8u_i64] = 1,
    [ld_i32] = 1,
    [ld_i64] = 1,
    [movcond_i32] = 0,
    [movcond_i64] = 0,
    [mov_i32] = 0,
    [mov_i64] = 0,
    [mul_i32] = 0,
    [mul_i64] = 0,
    [mulsh_i64] = 0,
    [muluh_i64] = 0,
    [neg_i32] = 0,
    [neg_i64] = 0,
    [negsetcond_i64] = 0,
    [not_i64] = 0,
    [or_i64] = 0,
    [or_i32] = 0,
    [push_ret_addr] = 0,
    [qemu_ld2_i128] = 2,
    [qemu_ld_i32] = 1,
    [qemu_ld_i64] = 1,
    [qemu_st2_i128] = 2,
    [qemu_st_i32] = 1,
    [qemu_st_i64] = 1,
    [ret] = 0,
    [rotr_i32] = 0,
    [rotr_i64] = 0,
    [sar_i32] = 0,
    [sar_i64] = 0,
    [setcond_i64] = 0,
    [sextract_i64] = 0,
    [shl_i64] = 0,
    [shl_i32] = 0,
    [shr_i64] = 0,
    [shr_i32] = 0,
    [st16_i32] = 0,
    [st16_i64] = 0,
    [st32_i64] = 0,
    [st_i32] = 0,
    [st_i64] = 0,
    [sub_i64] = 0,
    [sub_i32] = 0,
    [xor_i64] = 0,
    [xor_i32] = 0,
    [bswap64_i64] = 0,
    [brcond_i64] = 0,
    [call_direct] = 0,
    [add_vec] = 0,
    [andc_vec] = 0,
    [and_vec] = 0,
    [cmp_vec] = 0,
    [dupm_vec] = 1,
    [ld_vec] = 1,
    [mov_vec] = 0,
    [or_vec] = 0,
    [shli_vec] = 0,
    [st_vec] = 1,
    [sub_vec] = 0,
    [umax_vec] = 0,
    [umin_vec] = 0,
    [xor_vec] = 0,
    [movcond_vec] = 0,
};

LLVMType helper_vec_type[HELPER_MAX] = {
    [psrlw_xmm] = LLVMVector2xi64,
    [psllw_xmm] = LLVMVector2xi64,
    [psraw_xmm] = LLVMVector8xi16,
    [psrld_xmm] = LLVMVector2xi64,
    [pslld_xmm] = LLVMVector2xi64,
    [psrad_xmm] = LLVMVector4xi32,
    [psrlq_xmm] = LLVMVector2xi64,
    [psllq_xmm] = LLVMVector2xi64,
    [psrldq_xmm] = LLVMVector16xi8,
    [pslldq_xmm] = LLVMVector16xi8,
    [pmulhuw_xmm] = LLVMVector8xi16,
    [pmulhw_xmm] = LLVMVector8xi16,
    [pavgb_xmm] = LLVMVector16xi8,
    [pavgw_xmm] = LLVMVector8xi16,
    [pmuludq_xmm] = LLVMVector4xi32,
    [pmaddwd_xmm] = LLVMVector8xi16,
    [psadbw_xmm] = LLVMVector16xi8,
    [maskmov_xmm] = LLVMVector16xi8,
    [shufps_xmm] = LLVMVector4xi32,
    [shufpd_xmm] = LLVMVector2xi64,
    [pshufd_xmm] = LLVMVector4xi32,
    [pshuflw_xmm] = LLVMVector8xi16,
    [pshufhw_xmm] = LLVMVector8xi16,
    [cvtpd2dq_xmm] = LLVMVector2xi64,
    [cvttpd2dq_xmm] = LLVMVector2xi64,
    [movmskps_xmm] = LLVMVector4xi32,
    [movmskpd_xmm] = LLVMVector2xi64,
    [packsswb_xmm] = LLVMVector8xi16,
    [packuswb_xmm] = LLVMVector8xi16,
    [packssdw_xmm] = LLVMVector4xi32,
    [punpcklbw_xmm] = LLVMVector16xi8,
    [punpcklwd_xmm] = LLVMVector8xi16,
    [punpckldq_xmm] = LLVMVector4xi32,
    [punpcklqdq_xmm] = LLVMVector2xi64,
    [punpckhbw_xmm] = LLVMVector16xi8,
    [punpckhwd_xmm] = LLVMVector8xi16,
    [punpckhdq_xmm] = LLVMVector4xi32,
    [punpckhqdq_xmm] = LLVMVector2xi64,
    [pshufb_xmm] = LLVMVector16xi8,
    [phaddw_xmm] = LLVMVector8xi16,
    [phsubw_xmm] = LLVMVector8xi16,
    [phaddsw_xmm] = LLVMVector8xi16,
    [phsubsw_xmm] = LLVMVector8xi16,
    [phaddd_xmm] = LLVMVector4xi32,
    [phsubd_xmm] = LLVMVector4xi32,
    [pmaddubsw_xmm] = LLVMVector16xi8,
    [pmulhrsw_xmm] = LLVMVector8xi16,
    [psignb_xmm] = LLVMVector16xi8,
    [psignw_xmm] = LLVMVector8xi16,
    [psignd_xmm] = LLVMVector4xi32,
    [palignr_xmm] = LLVMVector2xi64,
    [pblendvb_xmm] = LLVMVector16xi8,
    [blendvps_xmm] = LLVMVector4xi32,
    [blendvpd_xmm] = LLVMVector2xi64,
    [ptest_xmm] = LLVMVector2xi64,
    [pmovsxbw_xmm] = LLVMVector8xi16,
    [pmovsxbd_xmm] = LLVMVector4xi32,
    [pmovsxbq_xmm] = LLVMVector2xi64,
    [pmovsxwd_xmm] = LLVMVector4xi32,
    [pmovsxwq_xmm] = LLVMVector8xi16,
    [pmovsxdq_xmm] = LLVMVector4xi32,
    [pmovzxbw_xmm] = LLVMVector16xi8,
    [pmovzxbd_xmm] = LLVMVector16xi8,
    [pmovzxbq_xmm] = LLVMVector2xi64,
    [pmovzxwd_xmm] = LLVMVector8xi16,
    [pmovzxwq_xmm] = LLVMVector2xi64,
    [pmovzxdq_xmm] = LLVMVector2xi64,
    [pmovsldup_xmm] = LLVMVector4xi32,
    [pmovshdup_xmm] = LLVMVector4xi32,
    [pmovdldup_xmm] = LLVMVector2xi64,
    [pmuldq_xmm] = LLVMVector4xi32,
    [packusdw_xmm] = LLVMVector4xi32,
    [phminposuw_xmm] = LLVMVector8xi16,
    [blendps_xmm] = LLVMVector4xi32,
    [blendpd_xmm] = LLVMVector2xi64,
    [pblendw_xmm] = LLVMVector8xi16,
    [mpsadbw_xmm] = LLVMVector16xi8,
    [aeskeygenassist_xmm] = LLVMVector4xi32,
    [vpermilpd_xmm] = LLVMVector2xi64,
    [vpermilps_xmm] = LLVMVector4xi32,
    [vpermilpd_imm_xmm] = LLVMVector2xi64,
    [vpermilps_imm_xmm] = LLVMVector4xi32,
    [vpsrlvd_xmm] = LLVMVector4xi32,
    [vpsravd_xmm] = LLVMVector4xi32,
    [vpsllvd_xmm] = LLVMVector4xi32,
    [vpsrlvq_xmm] = LLVMVector2xi64,
    [vpsravq_xmm] = LLVMVector2xi64,
    [vpsllvq_xmm] = LLVMVector2xi64,
    [vtestps_xmm] = LLVMVector4xi32,
    [vtestpd_xmm] = LLVMVector2xi64,
    [vpmaskmovd_st_xmm] = LLVMVector4xi32,
    [vpmaskmovq_st_xmm] = LLVMVector2xi64,
    [vpmaskmovd_xmm] = LLVMVector4xi32,
    [vpmaskmovq_xmm] = LLVMVector2xi64,
    [vpgatherdd_xmm] = LLVMVector4xi32,
    [vpgatherdq_xmm] = LLVMVector2xi64,
    [vpgatherqd_xmm] = LLVMVector2xi64,
    [vpgatherqq_xmm] = LLVMVector2xi64,
};

uint8_t inline_helper_enabled[HELPER_MAX] = {
    [blendvpd_xmm] = 1,
    [blendvps_xmm] = 1,
    [cvtpd2dq_xmm] = 1,
    [cvttpd2dq_xmm] = 1,
    [movmskpd_xmm] = 1,
    [movmskps_xmm] = 1,
    [packssdw_xmm] = 1,
    [packsswb_xmm] = 1,
    [packusdw_xmm] = 1,
    [packuswb_xmm] = 1,
    [pavgb_xmm] = 1,
    [pavgw_xmm] = 1,
    [pblendvb_xmm] = 1,
    [phaddd_xmm] = 1,
    [phaddsw_xmm] = 1,
    [phaddw_xmm] = 1,
    [phminposuw_xmm] = 1,
    [phsubd_xmm] = 1,
    [phsubsw_xmm] = 1,
    [phsubw_xmm] = 1,
    [pmaddubsw_xmm] = 1,
    [pmaddwd_xmm] = 1,
    [pmovdldup_xmm] = 1,
    [pmovshdup_xmm] = 1,
    [pmovsldup_xmm] = 1,
    [pmovsxbd_xmm] = 1,
    [pmovsxbq_xmm] = 1,
    [pmovsxbw_xmm] = 1,
    [pmovsxdq_xmm] = 1,
    [pmovsxwd_xmm] = 1,
    [pmovsxwq_xmm] = 1,
    [pmovzxbd_xmm] = 1,
    [pmovzxbq_xmm] = 1,
    [pmovzxbw_xmm] = 1,
    [pmovzxdq_xmm] = 1,
    [pmovzxwd_xmm] = 1,
    [pmovzxwq_xmm] = 1,
    [pmuldq_xmm] = 1,
    [pmulhrsw_xmm] = 1,
    [pmulhuw_xmm] = 1,
    [pmulhw_xmm] = 1,
    [pmuludq_xmm] = 1,
    [psadbw_xmm] = 1,
    [pshufb_xmm] = 1,
    [psignb_xmm] = 1,
    [psignd_xmm] = 1,
    [psignw_xmm] = 1,
    [pslldq_xmm] = 1,
    [pslld_xmm] = 1,
    [psllq_xmm] = 1,
    [psllw_xmm] = 1,
    [psrad_xmm] = 1,
    [psraw_xmm] = 1,
    [psrldq_xmm] = 1,
    [psrld_xmm] = 1,
    [psrlq_xmm] = 1,
    [psrlw_xmm] = 1,
    [ptest_xmm] = 1,
    [punpckhbw_xmm] = 1,
    [punpckhdq_xmm] = 1,
    [punpckhqdq_xmm] = 1,
    [punpckhwd_xmm] = 1,
    [punpcklbw_xmm] = 1,
    [punpckldq_xmm] = 1,
    [punpcklqdq_xmm] = 1,
    [punpcklwd_xmm] = 1,
    [vpermilpd_xmm] = 1,
    [vpermilps_xmm] = 1,
    [vpmaskmovd_xmm] = 1,
    [vpmaskmovq_xmm] = 1,
    [vpsllvd_xmm] = 1,
    [vpsllvq_xmm] = 1,
    [vpsravd_xmm] = 1,
    [vpsravq_xmm] = 1,
    [vpsrlvd_xmm] = 1,
    [vpsrlvq_xmm] = 1,
    [vtestpd_xmm] = 1,
    [vtestps_xmm] = 1,
};
