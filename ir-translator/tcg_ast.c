#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include "tcg_ast.h"
#include "tcg_context.h"
#include "tcg_parser.tab.h"
#include "tcg_lexer.yy.h"
#include "api.h"
#include <llvm-c/Core.h>
#include <llvm-c/Types.h>
#include <stdbool.h>

#ifdef __GNUC__
#define likely(x)    __builtin_expect(!!(x), 1)  // True with high probability
#define unlikely(x)  __builtin_expect(!!(x), 0)  // False with high probability
#else
#define likely(x)    (x)  // Fallback for non-GCC compilers
#define unlikely(x)  (x)
#endif

#define SET_SLOT(IDX)                       \
    do {                                    \
        i.slot##IDX##_type = s##IDX.subt;   \
        assert(s##IDX.p.idx < (1<<5));      \
        i.slot##IDX##_idx = s##IDX.p.idx;   \
    } while (0)

extern char *lineptr;
static uint64_t tcg_next_capacity = (128 * 1024);
static uint64_t tcg_instrs_capacity = 0;
static size_t tcg_instrs_idx = 0;
static uint8_t *tcg_instrs = NULL;
static uint16_t xmm_offsets[17] = {0};

void register_xmm(uint64_t idx, uint64_t offset) {
    assert(idx < 16);
    xmm_offsets[idx] = (uint16_t)offset;
}

void register_xmm_tmp(uint64_t offset) {
    xmm_offsets[16] = (uint16_t)offset;
}

XMMReg lookup_xmm(uint64_t offset) {
    uint16_t off = (uint16_t)offset;
    XMMReg x;
    x.xmm_idx = NON_XMM;
    x.xmm_offset = 0;
    if (xmm_offsets[0] <= off && off < (xmm_offsets[15] + 0x20)) {
        uint16_t idx = (off - xmm_offsets[0]) / 0x40;
        uint16_t delta = (off - xmm_offsets[0]) % 0x40;
        if (delta < 0x10) {
            x.xmm_idx = idx * 2;
            x.xmm_offset = delta;
        } else if (delta < 0x20) {
            x.xmm_idx = idx * 2 + 1;
            x.xmm_offset = delta - 0x10;
        }
    } else if (xmm_offsets[16] <= off && off < (xmm_offsets[16] + 0x20)) {
        if ((off - xmm_offsets[16]) < 0x10) {
            x.xmm_idx = XMMT;
            x.xmm_offset = (off - xmm_offsets[16]);
        } else {
            x.xmm_idx = YMMT_H;
            x.xmm_offset = (off - (xmm_offsets[16] + 0x10));
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

static void insert_instr(void *ptr_src, size_t sz) {
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
    printf("%s %04x\n", __FUNCTION__, i);
}

static void dump_4B(Instr4B i) {
    printf("%s %08x\n", __FUNCTION__, i);
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
void create_scalar_slot2(OpCodeType op, SlotInfo s0, SlotInfo s1) {
    Instr4B i;
    i.instr_type = SIZE4B;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    i.attr_type = SUB_ATTR_INVALID;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot2_attr(OpCodeType op, SlotInfo s0, SlotInfo s1, AttrSrcInfo a0) {
    Instr4B i;
    i.instr_type = SIZE4B;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(a0.subt == SUB_ATTR_SWAP);
    i.attr_type = a0.subt;
    i.attr_val = a0.p.swap;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot2_attr2(OpCodeType op, SlotInfo s0, SlotInfo s1, AttrSrcInfo a0, AttrSrcInfo a1) {
    Instr4B i;
    i.instr_type = SIZE4B;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(a0.subt == SUB_ATTR_SWAP);
    assert(a0.subt == a1.subt);
    i.attr_type = a0.subt;
    i.attr_val = a0.p.swap | a1.p.swap;
    insert_instr((void *)&i, sizeof(i));
}

void create_jmpdirect(uint64_t val) {
    if (likely(val < (1<<5))) {
        Instr2B i;
        i.instr_type = SIZE2B;
        i.opc = jmp_direct;
        i.imm = val;
        insert_instr((void *)&i, sizeof(i));
    } else {
        Instr1B14 i;
        i.instr_type = SIZEXB;
        i.instr_type_ext = Instr1B14_ext;
        i.opc = jmp_direct;
        assert((uint64_t)((long)((int32_t)val)) == val);
        i.imm = val;
        insert_instr((void *)&i, sizeof(i));
    }
}

void create_scalar_slot_imm(OpCodeType op, SlotInfo s0, uint64_t i0) {
    if (likely((uint64_t)((long)((int32_t)i0)) == i0)) {
        Instr2B4 i;
        i.instr_type = SIZE6B;
        i.opc = op;
        SET_SLOT(0);
        i.imm = i0;
        insert_instr((void *)&i, sizeof(i));
    } else {
        Instr1B28 i;
        i.instr_type = SIZEXB;
        i.instr_type_ext = Instr1B28_ext;
        i.opc = op;
        SET_SLOT(0);
        i.imm = i0;
        insert_instr((void *)&i, sizeof(i));
    }
}

void create_discard(SlotInfo s0) {
    // FIXME
}

void create_scalar_slot2_imm(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0) {
    Instr1B44 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B44_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert((uint64_t)((long)((int32_t)i0)) == i0);
    i.imm = i0;
    insert_instr((void *)&i, sizeof(i));
}

// Ignore num which is used as mmuidx for now.
void create_scalar_slot2_attr3_num(OpCodeType op, SlotInfo s0, SlotInfo s1, AttrSrcInfo a0, AttrSrcInfo a1, AttrSrcInfo a2, uint64_t n0) {
    Instr4B i;
    i.instr_type = SIZE4B;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(a0.subt == SUB_ATTR_ATOMIC && a1.subt == SUB_ATTR_ALIGNMENT && a2.subt == SUB_ATTR_SRCSIZEEXT);
    i.attr_type = SUB_ATTR_STORAGE;
    i.attr_val = (a0.p.storage.attr.atomic << 6) | (a1.p.storage.attr.alignment << 4) | (a2.p.storage.attr.ext << 3) | a2.p.storage.size;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot3(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2) {
    Instr1B4 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B4_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    insert_instr((void *)&i, sizeof(i));
}

void create_vector_slot_env_imm(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, uint64_t i0) {
    XMMReg x = lookup_xmm(i0);
    assert(x.xmm_idx != NON_XMM);
    Instr1BV4X i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BV4X_ext;
    i.opc = op;
    i.es = ai.p.ves;
    SET_SLOT(0);
    i.xmm_idx = x.xmm_idx;
    i.xmm_offset = x.xmm_offset;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot2_imm2(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0, uint64_t i1) {
    Instr1B41I2 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B41I2_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(i0 < (1<<8));
    i.imm0 = i0;
    assert(i1 < (1<<8));
    i.imm1 = i1;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot_env_imm(OpCodeType op, SlotInfo s0, uint64_t i0) {
    XMMReg x = lookup_xmm(i0);
    if (x.xmm_idx != NON_XMM) {
        Instr1B4X i;
        i.instr_type = SIZEXB;
        i.instr_type_ext = Instr1B4X_ext;
        i.opc = op;
        SET_SLOT(0);
        i.xmm_idx = x.xmm_idx;
        i.xmm_offset = x.xmm_offset;
        insert_instr((void *)&i, sizeof(i));
    } else {
        Instr1B22 i;
        i.instr_type = SIZEXB;
        i.instr_type_ext = Instr1B22_ext;
        i.opc = op;
        SET_SLOT(0);
        assert(i0 < (1<<16));
        i.env_offset = i0;
        insert_instr((void *)&i, sizeof(i));
    }
}

void create_branch_condition(SlotInfo s0, uint64_t i0, uint8_t relop, uint8_t label) {
    Instr1B21 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B21_ext;
    i.opc = brcond_i64;
    SET_SLOT(0);
    i.imm = i0;
    i.relop = relop;
    assert(label <= 2);
    i.label = label;
    insert_instr((void *)&i, sizeof(i));
}

void create_setlabel(OpCodeType op, uint8_t label) {
    Instr1B2 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B2_ext;
    i.opc = brcond_i64;
    assert(label <= 2);
    i.label = label;
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_slot4(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, SlotInfo s2, SlotInfo s3) {
    Instr1BH4 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH4_ext;
    i.helper_l = (uint8_t)h;
    i.helper_h = h >> 8;
    assert(noargs < 2);
    i.noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    insert_instr((void *)&i, sizeof(i));
}

void create_vector_slot3(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, SlotInfo s1, SlotInfo s2) {
    Instr1BV4 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BV4_ext;
    i.opc = op;
    i.es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_slot5(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, SlotInfo s2, SlotInfo s3, SlotInfo s4) {
    Instr1BH141 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH141_ext;
    i.helper_l = (uint8_t)h;
    i.helper_h = h >> 8;
    assert(noargs < 2);
    i.noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    SET_SLOT(4);
    insert_instr((void *)&i, sizeof(i));
}

void create_vector_slot_vimm(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, uint64_t vi0) {
    Instr1BV21 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BV21_ext;
    i.opc = op;
    i.es = ai.p.ves;
    SET_SLOT(0);
    assert(vi0 < (1<<8));
    i.imm = vi0;
    insert_instr((void *)&i, sizeof(i));
}

// Ignore num which is used as mmuidx for now.
void create_scalar_slot3_attr3_num(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2, AttrSrcInfo a0, AttrSrcInfo a1, AttrSrcInfo a2, uint64_t n0) {
    Instr1B41 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B41_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(a0.subt == SUB_ATTR_ATOMIC && a1.subt == SUB_ATTR_ALIGNMENT && a2.subt == SUB_ATTR_SRCSIZEEXT);
    i.attr_type = SUB_ATTR_STORAGE;
    i.attr_val = (a0.p.storage.attr.atomic << 6) | (a1.p.storage.attr.alignment << 4) | (a2.p.storage.attr.ext << 3) | a2.p.storage.size;
    insert_instr((void *)&i, sizeof(i));
}

void create_vector_slot2_imm(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, SlotInfo s1, uint64_t i0) {
    Instr1BV4I i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BV4I_ext;
    i.opc = op;
    i.es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(i0 < (1<<8));
    i.imm = i0;
    insert_instr((void *)&i, sizeof(i));
}

void create_calldirect(SlotInfo s0, uint64_t i0, uint64_t i1) {
    Instr1B24 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B24_ext;
    SET_SLOT(0);
    assert(i0 < (1<<8));
    i.imm0 = i0;
    // NOTICE: those calls to negative address are illegal
    i.imm1 = i1;
    insert_instr((void *)&i, sizeof(i));
}

void create_vector_slot2(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, SlotInfo s1) {
    Instr1BV4S2 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BV4S2_ext;
    i.opc = op;
    i.es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    insert_instr((void *)&i, sizeof(i));
}

void create_vector_slot3_relop(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, SlotInfo s1, SlotInfo s2, uint8_t relop) {
    Instr1BV41 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BV41_ext;
    i.opc = op;
    i.es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i.relop = relop;
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_env_imm(HelperType h, uint16_t cflags, uint8_t noargs, uint32_t i0) {
    Instr1BH24I i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH24I_ext;
    i.helper = h;
    assert(noargs == 0);
    i.imm = i0;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot(OpCodeType op, SlotInfo s0) {
    Instr1B2S i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B2S_ext;
    i.opc = op;
    SET_SLOT(0);
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot3_imm(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2, uint64_t i0) {
    Instr1B41I i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B41I_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(i0 < (1<<8));
    i.imm = i0;
    insert_instr((void *)&i, sizeof(i));
}

void create_vector_slot2_vimm(OpCodeType op, AttrSrcInfo ai, SlotInfo s0, SlotInfo s1, uint64_t vi0) {
    Instr1BV48 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BV48_ext;
    i.opc = op;
    i.es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    i.imm = vi0;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot2_imm_slot2_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0, SlotInfo s2, SlotInfo s3, RelopType r) {
    Instr1B422 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B422_ext;
    i.opc = op;
    i.relop = r;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    assert(i0 < (1<<16));
    i.imm = i0;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot3_imm2(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2, uint64_t i0, uint64_t i1) {
    Instr1B411 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B411_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(i0 < (1<<8));
    i.imm0 = i0;
    assert(i1 < (1<<8));
    i.imm1 = i1;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_imm_env_imm(OpCodeType op, uint64_t i0, uint64_t i1) {
    XMMReg x = lookup_xmm(i1);
    if (x.xmm_idx != NON_XMM) {
        Instr1B142 i;
        i.instr_type = SIZEXB;
        i.instr_type_ext = Instr1B142_ext;
        i.opc = op;
        assert(i0 < (1UL<<32));
        i.imm = i0;
        i.xmm_idx = x.xmm_idx;
        i.xmm_offset = x.xmm_offset;
        insert_instr((void *)&i, sizeof(i));
    } else {
        Instr1B142E i;
        i.instr_type = SIZEXB;
        i.instr_type_ext = Instr1B142E_ext;
        i.opc = op;
        assert(i0 < (1UL<<32));
        i.imm = i0;
        assert((uint64_t)((long)((int16_t)i1)) == i1);
        i.env_offset = (uint16_t)i1;
        insert_instr((void *)&i, sizeof(i));
    }
}

void create_helper_env_slot(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0) {
    Instr1BH21 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH21_ext;
    i.helper = h;
    assert(noargs < 2);
    i.noargs = noargs;
    SET_SLOT(0);
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot2_imm_slot_imm_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0, SlotInfo s2, uint64_t i1, RelopType r) {
    Instr1B4111 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B4111_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(i0 < (1<<8));
    i.imm0 = i0;
    assert(i1 < (1<<8));
    i.imm1 = i1;
    i.relop = r;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot5_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2, SlotInfo s3, SlotInfo s4, RelopType r) {
    Instr1B8 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B8_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    SET_SLOT(4);
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_env_slot3_imm(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, SlotInfo s2, uint32_t i0) {
    Instr1BH4I i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH4I_ext;
    i.helper_l = (uint8_t)h;
    i.helper_h = h >> 8;
    assert(noargs == 0);
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(i0 < (1 << 8) || (i0 & 0xffffff80) == 0xffffff80);
    i.imm = i0;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot2_imm_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0, RelopType r) {
    Instr1B42 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B42_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(i0 < (1<<16));
    i.imm = i0;
    i.relop = r;
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_env(HelperType h, uint16_t cflags, uint8_t noargs) {
    Instr1BH2 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH2_ext;
    i.helper = h;
    assert(noargs == 0);
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_env_imm_slot(HelperType h, uint16_t cflags, uint8_t noargs, uint32_t i0, SlotInfo s0) {
    Instr1BH21S i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH21S_ext;
    i.helper = h;
    assert(noargs < 2);
    i.noargs = noargs;
    assert(i0 < (1<<4));
    i.imm = i0;
    SET_SLOT(0);
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot_imm_slot(OpCodeType op, SlotInfo s0, uint64_t i0, SlotInfo s1) {
    Instr1B281 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B281_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    i.imm = i0;
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_slot3(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, SlotInfo s2) {
    Instr1BH4S3 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH4S3_ext;
    i.helper_l = (uint8_t)h;
    i.helper_h = h >> 8;
    assert(noargs < 2);
    i.noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot2_imm2_slot_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, uint64_t i0, uint64_t i1, SlotInfo s2, RelopType r) {
    Instr1B4112 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B4112_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(i0 < (1<<8));
    i.imm0 = i0;
    assert(i1 < (1<<8));
    i.imm1 = i1;
    i.relop = r;
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_slot2_imm2(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, uint32_t i0, uint32_t i1) {
    Instr1BH412 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH412_ext;
    i.helper = h;
    assert(noargs < 2);
    i.noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(i0 < (1<<8));
    i.imm0 = i0;
    assert(i1 < (1<<16));
    i.imm1 = i1;
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_slot2_imm(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1, uint32_t i0) {
    Instr1BH41 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH41_ext;
    i.helper = h;
    assert(noargs < 2);
    i.noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(i0 < (1<<8));
    i.imm = i0;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_slot3_relop(OpCodeType op, SlotInfo s0, SlotInfo s1, SlotInfo s2, RelopType r) {
    Instr1B41R i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B41R_ext;
    i.opc = op;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i.relop = r;
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_env_imm2(HelperType h, uint16_t cflags, uint8_t noargs, uint32_t i0, uint32_t i1) {
    Instr1BH24 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH24_ext;
    i.helper = h;
    assert(noargs < 2);
    i.noargs = noargs;
    assert(i0 < (1<<4));
    i.imm0 = i0;
    assert(i1 < (1UL<<32));
    i.imm1 = i1;
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_env_slot_imm(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, uint32_t i0) {
    Instr1BH211 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH211_ext;
    i.helper = h;
    assert(noargs < 2);
    i.noargs = noargs;
    SET_SLOT(0);
    assert(i0 < (1<<8));
    i.imm = i0;
    insert_instr((void *)&i, sizeof(i));
}

void create_scalar_imm_slot_imm(OpCodeType op, uint64_t i0, SlotInfo s0, uint64_t i1) {
    Instr1B1111 i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1B1111_ext;
    i.opc = op;
    assert(i0 < (1<<8));
    i.imm0 = i0;
    SET_SLOT(0);
    assert(i1 < (1<<8));
    i.imm1 = i1;
    insert_instr((void *)&i, sizeof(i));
}

void create_helper_env_slot2(HelperType h, uint16_t cflags, uint8_t noargs, SlotInfo s0, SlotInfo s1) {
    Instr1BH4S i;
    i.instr_type = SIZEXB;
    i.instr_type_ext = Instr1BH4S_ext;
    i.helper = h;
    assert(noargs < 2);
    i.noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    insert_instr((void *)&i, sizeof(i));
}

static LLVMModuleRef create_module(const char *module_name) {
    LLVMContextRef context = LLVMGetGlobalContext();
    LLVMModuleRef module = LLVMModuleCreateWithNameInContext(module_name, context);

    LLVMSetTarget(module, "riscv64-unknown-linux-gnu");
    return module;
}

void create_program(TcgAst *funcs) {
    printf("tcg_instrs_idx:%ld\n", tcg_instrs_idx);
    void *ptr = (void *)tcg_instrs;
    void *ptr_max = tcg_instrs + tcg_instrs_idx;
    while (ptr < ptr_max) {
        ptr = move_to_next(ptr);
    }
#if 0
    LLVMModuleRef module = create_module("qemuaot");
    LLVMBuilderRef builder = LLVMCreateBuilder();

    // Parameter setup (same for all functions)
    LLVMTypeRef vscale_i64 = LLVMScalableVectorType(LLVMInt64Type(), 1); // <1 x i64>
    int base_param_count = 20;
    int extra_param_count = 15 * 2;
    int total_param_count = base_param_count + extra_param_count;
    LLVMTypeRef param_types[base_param_count + extra_param_count];
    const char *base_names[20] = {
        "rax", "rcx", "rdx", "rbx",
        "rsp", "rbp", "rsi", "rdi",
        "r8", "r9", "r10", "r11",
        "r12", "r13", "r14", "r15",
        "cc_src", "cc_dst", "cc_op", "lr_input"
    };
    const char *arg_names[base_param_count + extra_param_count];
    for (int i = 0; i < base_param_count; i++) {
        if (i < 16) param_types[i] = LLVMInt64Type();
        else if (i == 16 || i == 17 || i == 19) param_types[i] = LLVMInt64Type();
        else if (i == 18) param_types[i] = LLVMInt32Type();
        arg_names[i] = base_names[i];
    }
    static char extra_name_buf[30][16];
    for (int i = 0; i < 15; i++) {
        int idx = base_param_count + i * 2;
        param_types[idx] = vscale_i64;
        param_types[idx + 1] = vscale_i64;
        snprintf(extra_name_buf[i * 2], sizeof(extra_name_buf[i * 2]), "xmm%d", i);
        snprintf(extra_name_buf[i * 2 + 1], sizeof(extra_name_buf[i * 2 + 1]), "ymm%d_h", i);
        arg_names[idx] = extra_name_buf[i * 2];
        arg_names[idx + 1] = extra_name_buf[i * 2 + 1];
    }


    // Collect the funcs into an array to reverse the order
    int func_count = 0;
    for (TcgAst *cur = funcs; cur != NULL; cur = cur->next) func_count++;
    TcgAst **func_array = malloc(sizeof(TcgAst *) * func_count);
    int idx = 0;
    for (TcgAst *cur = funcs; cur != NULL; cur = cur->next) func_array[idx++] = cur;

    // Generate functions in reverse order
    for (int i = func_count - 1; i >= 0; i--) {
        TcgAst *func = func_array[i];
        char func_name[64];
        sprintf(func_name, "func_%x", func->data.func.label);
        LLVMValueRef llvm_func = LLVMAddFunction(module, func_name,
            LLVMFunctionType(LLVMVoidType(), param_types, total_param_count, 0));
        for (int j = 0; j < total_param_count; j++) {
            LLVMValueRef param = LLVMGetParam(llvm_func, j);
            LLVMSetValueName(param, arg_names[j]);
        }
        LLVMSetFunctionCallConv(llvm_func, 124);

        LLVMBasicBlockRef entry = LLVMAppendBasicBlock(llvm_func, "entry");
        LLVMPositionBuilderAtEnd(builder, entry);
        LLVMBuildRetVoid(builder);
    }
    free(func_array);

    //LLVMDumpModule(module);
    LLVMDisposeModule(module);
#endif
}

void parse_tcg_instructions(const char *filename) {
    FILE *source_file = fopen(filename, "r");
    if (!source_file) {
        perror("Error opening source file");
        return;
    }

    TcgContext ctx = {0};
    yyscan_t scanner;
    yylex_init(&scanner);
    yyset_in(source_file, scanner);

    yyparse(scanner, &ctx);
    yylex_destroy(scanner);
    free(lineptr);
    fclose(source_file);
    return;
}

int main(int argc, const char *argv[]) {
  if (argc < 2) {
    printf("Usage: ./app <tcg-ir>\n");
    return -1;
  }
  parse_tcg_instructions(argv[1]);
  return 0;
}
