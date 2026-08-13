#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include "tcg_ast.h"

//#define BUILD_RISCV_ON_AARCH      1
//#define DEBUG                     1
#define STACK_INDEX_SHIFT           10
#define SET_SLOT(IDX)                               \
    do {                                            \
        s##IDX = get_mapped_slot(s##IDX);    \
        i->slot##IDX##_type = s##IDX.s.slot_type;   \
        i->slot##IDX##_idx = s##IDX.s.slot_idx;     \
    } while (0)
#define XMM_TMP_IDX                 16

uint8_t instr_buf[64];
static uint64_t tcg_next_capacity = (128 * 1024);
static uint64_t tcg_instrs_capacity = 0;
static size_t tcg_instrs_idx = 0;
static uint8_t *tcg_instrs = NULL;
static uint16_t xmm_offsets[17] = {0};

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
    assert(idx < 16);
    xmm_offsets[idx] = (uint16_t)offset;
}

uint64_t get_xmm_offset(uint64_t idx) {
    assert(idx <= 16);
    return xmm_offsets[idx];
}

void register_xmm_tmp(uint64_t offset) {
    xmm_offsets[XMM_TMP_IDX] = (uint16_t)offset;
}

XMMReg lookup_xmm(uint64_t offset) {
    uint16_t off = (uint16_t)offset;
    XMMReg x;
    x.xmm_idx = NON_XMM;
    x.xmm_offset = 0;
    if (XMM_COUNT > 0 && xmm_offsets[0] <= off && off < (xmm_offsets[XMM_COUNT-1] + 0x20)) {
        uint16_t idx = (off - xmm_offsets[0]) / 0x40;
        uint16_t delta = (off - xmm_offsets[0]) % 0x40;
        if (delta < 0x10) {
            x.xmm_idx = idx * 2;
            x.xmm_offset = delta;
        } else if (delta < 0x20) {
            x.xmm_idx = idx * 2 + 1;
            x.xmm_offset = delta - 0x10;
        }
    }
    return x;
}

XMMReg lookup_xmm_map(uint64_t offset) {
    uint16_t off = (uint16_t)offset;
    XMMReg x;
    x.xmm_idx = NON_XMM;
    x.xmm_offset = 0;
    if (xmm_offsets[0] <= off && off < (xmm_offsets[XMM_TMP_IDX - 1] + 0x20)) {
        uint16_t idx = (off - xmm_offsets[0]) / 0x40;
        uint16_t delta = (off - xmm_offsets[0]) % 0x40;
        if (delta < 0x10) {
            x.xmm_idx = idx * 2;
            x.xmm_offset = delta;
        } else if (delta < 0x20) {
            x.xmm_idx = idx * 2 + 1;
            x.xmm_offset = delta - 0x10;
        }
    } else if (xmm_offsets[XMM_TMP_IDX] <= off && off < (xmm_offsets[XMM_TMP_IDX] + 0x20)) {
        uint16_t idx = XMM_TMP_IDX;
        uint16_t delta = off - xmm_offsets[XMM_TMP_IDX];
        if (delta < 0x10) {
            x.xmm_idx = idx * 2;
            x.xmm_offset = delta;
        } else if (delta < 0x20) {
            x.xmm_idx = idx * 2 + 1;
            x.xmm_offset = delta - 0x10;
        }
    }
    return x;
}

static uint16_t tmpl_map[1UL<<STACK_INDEX_SHIFT] = {0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff};
static uint16_t tmpt_map[1UL<<STACK_INDEX_SHIFT] = {0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff,0xffff};
static uint16_t tmp_idx = 0;

OperandType get_original_slot_for_debug(OperandType tmp) {
    OperandType ret;
    ret.s.valid = 0;
    if (!(tmp.s.valid && tmp.s.slot_type == SUB_SLOT_TMP)) {
        return ret;
    }
    for (int i = 0; i < sizeof(tmpl_map)/sizeof(uint16_t); ++i) {
        if (tmpl_map[i] == tmp.s.slot_idx) {
            ret.s.valid = 1;
            ret.s.slot_type = SUB_SLOT_TMPL;
            ret.s.slot_idx = i;
            return ret;
        }
    }
    for (int i = 0; i < sizeof(tmpt_map)/sizeof(uint16_t); ++i) {
        if (tmpt_map[i] == tmp.s.slot_idx) {
            ret.s.valid = 1;
            ret.s.slot_type = SUB_SLOT_TMPT;
            ret.s.slot_idx = i;
            return ret;
        }
    }
    return ret;
}

void reset_tmp_mapping() {
    memset(tmpl_map, 0xff, sizeof(tmpl_map));
    memset(tmpt_map, 0xff, sizeof(tmpt_map));
    tmp_idx = 0;
}

const char *opcode_type_str[] = {
    #define X(name) #name,
    OPCODE_TYPE_LIST
    #undef X
};

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

const char *cvector_str[] = {
    #define X(name) #name,
    C_VECTOR_TYPE
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
#ifdef DEBUG
    printf("%s %lx", __FUNCTION__, ptr);
    unsigned char *byte = (unsigned char *)ptr_src;
    for (size_t i = 0; i < sz; ++i) {
        printf(" %02x", byte[i]);
    }
    printf("\n");
#endif
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

// INPUT-bits, OUTPUT-bits OR Memory-bits, Register-bits (for load/store)
const LLVMType opciosz[OPCODE_MAX][2] = {
#define SAME(T)     {T, T}
    // Not supported OPC
    [addc1o_i32] = SAME(LLVMInvalidType),
    [addc1o_i64] = SAME(LLVMInvalidType),
    [subb1o_i32] = SAME(LLVMInvalidType),
    [subb1o_i64] = SAME(LLVMInvalidType),
    [brcond_i32] = SAME(LLVMInvalidType),
    [divs2_i32] = SAME(LLVMInvalidType),
    [divs2_i64] = SAME(LLVMInvalidType),
    [divu2_i32] = SAME(LLVMInvalidType),
    [divu2_i64] = SAME(LLVMInvalidType),
    [dup_vec] = SAME(LLVMInvalidType),
    // Define supported OPC:
    [addci_i32] = SAME(LLVMInt32),
    [addci_i64] = SAME(LLVMInt64),
    [addcio_i32] = SAME(LLVMInt32),
    [addcio_i64] = SAME(LLVMInt64),
    [addco_i32] = SAME(LLVMInt32),
    [addco_i64] = SAME(LLVMInt64),
    [subbi_i32] = SAME(LLVMInt32),
    [subbi_i64] = SAME(LLVMInt64),
    [subbio_i32] = SAME(LLVMInt32),
    [subbio_i64] = SAME(LLVMInt64),
    [subbo_i32] = SAME(LLVMInt32),
    [subbo_i64] = SAME(LLVMInt64),
    // Pure vector types are all invalid since those depend on element size.
    // Arithmetic
    [add_i32] = SAME(LLVMInt32),
    [add_i64] = SAME(LLVMInt64),
    [sub_i32] = SAME(LLVMInt32),
    [sub_i64] = SAME(LLVMInt64),
    [rems_i32] = SAME(LLVMInt32),
    [rems_i64] = SAME(LLVMInt64),
    [remu_i32] = SAME(LLVMInt32),
    [remu_i64] = SAME(LLVMInt64),
    [mul_i32] = SAME(LLVMInt32),
    [mul_i64] = SAME(LLVMInt64),
    [muls2_i32] = SAME(LLVMInt32),
    [muls2_i64] = SAME(LLVMInt64),
    [mulsh_i32] = SAME(LLVMInt32),
    [mulsh_i64] = SAME(LLVMInt64),
    [mulu2_i32] = SAME(LLVMInt32),
    [mulu2_i64] = SAME(LLVMInt64),
    [muluh_i32] = SAME(LLVMInt32),
    [muluh_i64] = SAME(LLVMInt64),
    [divs_i32] = SAME(LLVMInt32),
    [divs_i64] = SAME(LLVMInt64),
    [divu_i32] = SAME(LLVMInt32),
    [divu_i64] = SAME(LLVMInt64),
    // Logic
    [andc_i32] = SAME(LLVMInt32),
    [andc_i64] = SAME(LLVMInt64),
    [and_i32] = SAME(LLVMInt32),
    [and_i64] = SAME(LLVMInt64),
    [xor_i32] = SAME(LLVMInt32),
    [xor_i64] = SAME(LLVMInt64),
    [eqv_i32] = SAME(LLVMInt32),
    [eqv_i64] = SAME(LLVMInt64),
    [nand_i32] = SAME(LLVMInt32),
    [nand_i64] = SAME(LLVMInt64),
    [neg_i32] = SAME(LLVMInt32),
    [neg_i64] = SAME(LLVMInt64),
    [nor_i32] = SAME(LLVMInt32),
    [nor_i64] = SAME(LLVMInt64),
    [not_i32] = SAME(LLVMInt32),
    [not_i64] = SAME(LLVMInt64),
    [orc_i32] = SAME(LLVMInt32),
    [orc_i64] = SAME(LLVMInt64),
    [or_i32] = SAME(LLVMInt32),
    [or_i64] = SAME(LLVMInt64),
    // Bit permutation
    [mov_i32] = SAME(LLVMInt32),
    [mov_i64] = SAME(LLVMInt64),
    [shl_i32] = SAME(LLVMInt32),
    [shl_i64] = SAME(LLVMInt64),
    [shr_i32] = SAME(LLVMInt32),
    [shr_i64] = SAME(LLVMInt64),
    [rotl_i32] = SAME(LLVMInt32),
    [rotl_i64] = SAME(LLVMInt64),
    [rotr_i32] = SAME(LLVMInt32),
    [rotr_i64] = SAME(LLVMInt64),
    [sar_i32] = SAME(LLVMInt32),
    [sar_i64] = SAME(LLVMInt64),
    [deposit_i32] = SAME(LLVMInt32),
    [deposit_i64] = SAME(LLVMInt64),
    [extract_i32] = SAME(LLVMInt32),
    [extract_i64] = SAME(LLVMInt64),
    [sextract_i32] = SAME(LLVMInt32),
    [sextract_i64] = SAME(LLVMInt64),
    [extract2_i32] = SAME(LLVMInt32),
    [extract2_i64] = SAME(LLVMInt64),
    [extrh_i64_i32] = {LLVMInt64, LLVMInt32},
    [extrl_i64_i32] = {LLVMInt64, LLVMInt32},
    [bswap16_i32] = SAME(LLVMInt32),
    [bswap16_i64] = SAME(LLVMInt64),
    [bswap32_i32] = SAME(LLVMInt32),
    [bswap32_i64] = SAME(LLVMInt64),
    [bswap64_i64] = SAME(LLVMInt64),
    // Bit statistics
    [clz_i32] = SAME(LLVMInt32),
    [clz_i64] = SAME(LLVMInt64),
    [ctpop_i32] = SAME(LLVMInt32),
    [ctpop_i64] = SAME(LLVMInt64),
    [ctz_i32] = SAME(LLVMInt32),
    [ctz_i64] = SAME(LLVMInt64),
    // Type conversion
    [ext_i32_i64] = {LLVMInt32, LLVMInt64},
    [extu_i32_i64] = {LLVMInt32, LLVMInt64},
    // Conditional
    [movcond_i32] = SAME(LLVMInt32),
    [movcond_i64] = SAME(LLVMInt64),
    [negsetcond_i32] = SAME(LLVMInt32),
    [negsetcond_i64] = SAME(LLVMInt64),
    [setcond_i32] = SAME(LLVMInt32),
    [setcond_i64] = SAME(LLVMInt64),
    // Control-flow
    [brcond_i64] = {LLVMInt64, LLVMInvalidType},
    [call] = SAME(LLVMInvalidType),
    [push_ret_addr] = SAME(LLVMInt64),
    [ret] = SAME(LLVMInt64),
    // Load
    //Memory-bits, Register-bits
    [ld16s_i32] = {LLVMInt16, LLVMInt32},
    [ld16s_i64] = {LLVMInt16, LLVMInt64},
    [ld16u_i32] = {LLVMInt16, LLVMInt32},
    [ld16u_i64] = {LLVMInt16, LLVMInt64},
    [ld32s_i64] = {LLVMInt32, LLVMInt64},
    [ld32u_i64] = {LLVMInt32, LLVMInt64},
    [ld8s_i32] = {LLVMInt8, LLVMInt32},
    [ld8s_i64] = {LLVMInt8, LLVMInt64},
    [ld8u_i32] = {LLVMInt8, LLVMInt32},
    [ld8u_i64] = {LLVMInt8, LLVMInt64},
    [ld_i32] = SAME(LLVMInt32),
    [ld_i64] = SAME(LLVMInt64),
    [ld_vec] = SAME(LLVMInvalidType),
    [qemu_ld2_i128] = SAME(LLVMInt64),
    [qemu_ld_i32] = {LLVMInvalidType, LLVMInt32},
    [qemu_ld_i64] = {LLVMInvalidType, LLVMInt64},
    // Store
    //Memory-bits, Register-bits
    [st16_i32] = {LLVMInt16, LLVMInt32},
    [st16_i64] = {LLVMInt16, LLVMInt64},
    [st32_i64] = {LLVMInt32, LLVMInt64},
    [st8_i32] = {LLVMInt8, LLVMInt32},
    [st8_i64] = {LLVMInt8, LLVMInt64},
    [st_i32] = SAME(LLVMInt32),
    [st_i64] = SAME(LLVMInt64),
    [st_vec] = SAME(LLVMInvalidType),
    [qemu_st2_i128] = SAME(LLVMInt64),
    [qemu_st_i32] = {LLVMInvalidType, LLVMInt32},
    [qemu_st_i64] = {LLVMInvalidType, LLVMInt64},
    // Vector
    [abs_vec] = SAME(LLVMInvalidType),
    [dupm_vec] = SAME(LLVMInvalidType),
    [add_vec] = SAME(LLVMInvalidType),
    [andc_vec] = SAME(LLVMInvalidType),
    [and_vec] = SAME(LLVMInvalidType),
    [bitsel_vec] = SAME(LLVMInvalidType),
    [cmpsel_vec] = SAME(LLVMInvalidType),
    [cmp_vec] = SAME(LLVMInvalidType),
    [eqv_vec] = SAME(LLVMInvalidType),
    [movcond_vec] = SAME(LLVMInvalidType),
    [mov_vec] = SAME(LLVMInvalidType),
    [mul_vec] = SAME(LLVMInvalidType),
    [nand_vec] = SAME(LLVMInvalidType),
    [neg_vec] = SAME(LLVMInvalidType),
    [nor_vec] = SAME(LLVMInvalidType),
    [not_vec] = SAME(LLVMInvalidType),
    [orc_vec] = SAME(LLVMInvalidType),
    [or_vec] = SAME(LLVMInvalidType),
    [rotli_vec] = SAME(LLVMInvalidType),
    [rotls_vec] = SAME(LLVMInvalidType),
    [rotlv_vec] = SAME(LLVMInvalidType),
    [rotrv_vec] = SAME(LLVMInvalidType),
    [sari_vec] = SAME(LLVMInvalidType),
    [sars_vec] = SAME(LLVMInvalidType),
    [sarv_vec] = SAME(LLVMInvalidType),
    [shli_vec] = SAME(LLVMInvalidType),
    [shls_vec] = SAME(LLVMInvalidType),
    [shlv_vec] = SAME(LLVMInvalidType),
    [shri_vec] = SAME(LLVMInvalidType),
    [shrs_vec] = SAME(LLVMInvalidType),
    [shrv_vec] = SAME(LLVMInvalidType),
    [smax_vec] = SAME(LLVMInvalidType),
    [smin_vec] = SAME(LLVMInvalidType),
    [ssadd_vec] = SAME(LLVMInvalidType),
    [sssub_vec] = SAME(LLVMInvalidType),
    [sub_vec] = SAME(LLVMInvalidType),
    [umax_vec] = SAME(LLVMInvalidType),
    [umin_vec] = SAME(LLVMInvalidType),
    [usadd_vec] = SAME(LLVMInvalidType),
    [ussub_vec] = SAME(LLVMInvalidType),
    [xor_vec] = SAME(LLVMInvalidType),
};

const uint8_t opcoc[OPCODE_MAX] = {
    [addci_i32] = 1,
    [addci_i64] = 1,
    [addcio_i32] = 1,
    [addcio_i64] = 1,
    [addco_i32] = 1,
    [addco_i64] = 1,
    [subbi_i32] = 1,
    [subbi_i64] = 1,
    [subbio_i32] = 1,
    [subbio_i64] = 1,
    [subbo_i32] = 1,
    [subbo_i64] = 1,
    [abs_vec] = 1,
    [add_i32] = 1,
    [add_i64] = 1,
    [add_vec] = 1,
    [andc_i32] = 1,
    [andc_i64] = 1,
    [andc_vec] = 1,
    [and_i32] = 1,
    [and_i64] = 1,
    [and_vec] = 1,
    [bitsel_vec] = 1,
    [bswap16_i32] = 1,
    [bswap16_i64] = 1,
    [bswap32_i32] = 1,
    [bswap32_i64] = 1,
    [bswap64_i64] = 1,
    [clz_i32] = 1,
    [clz_i64] = 1,
    [cmpsel_vec] = 1,
    [cmp_vec] = 1,
    [ctpop_i32] = 1,
    [ctpop_i64] = 1,
    [ctz_i32] = 1,
    [ctz_i64] = 1,
    [deposit_i32] = 1,
    [deposit_i64] = 1,
    [divs2_i32] = 2,
    [divs2_i64] = 2,
    [divs_i32] = 1,
    [divs_i64] = 1,
    [divu2_i32] = 2,
    [divu2_i64] = 2,
    [divu_i32] = 1,
    [divu_i64] = 1,
    [dupm_vec] = 1,
    [dup_vec] = 1,
    [eqv_i32] = 1,
    [eqv_i64] = 1,
    [eqv_vec] = 1,
    [ext_i32_i64] = 1,
    [extract2_i32] = 1,
    [extract2_i64] = 1,
    [extract_i32] = 1,
    [extract_i64] = 1,
    [extrh_i64_i32] = 1,
    [extrl_i64_i32] = 1,
    [extu_i32_i64] = 1,
    [ld16s_i32] = 1,
    [ld16s_i64] = 1,
    [ld16u_i32] = 1,
    [ld16u_i64] = 1,
    [ld32s_i64] = 1,
    [ld32u_i64] = 1,
    [ld8s_i32] = 1,
    [ld8s_i64] = 1,
    [ld8u_i32] = 1,
    [ld8u_i64] = 1,
    [ld_i32] = 1,
    [ld_i64] = 1,
    [ld_vec] = 1,
    [movcond_i32] = 1,
    [movcond_i64] = 1,
    [movcond_vec] = 1,
    [mov_i32] = 1,
    [mov_i64] = 1,
    [mov_vec] = 1,
    [mul_i32] = 1,
    [mul_i64] = 1,
    [muls2_i32] = 2,
    [muls2_i64] = 2,
    [mulsh_i32] = 1,
    [mulsh_i64] = 1,
    [mulu2_i32] = 2,
    [mulu2_i64] = 2,
    [muluh_i32] = 1,
    [muluh_i64] = 1,
    [mul_vec] = 1,
    [nand_i32] = 1,
    [nand_i64] = 1,
    [nand_vec] = 1,
    [neg_i32] = 1,
    [neg_i64] = 1,
    [negsetcond_i32] = 1,
    [negsetcond_i64] = 1,
    [neg_vec] = 1,
    [nor_i32] = 1,
    [nor_i64] = 1,
    [nor_vec] = 1,
    [not_i32] = 1,
    [not_i64] = 1,
    [not_vec] = 1,
    [orc_i32] = 1,
    [orc_i64] = 1,
    [orc_vec] = 1,
    [or_i32] = 1,
    [or_i64] = 1,
    [or_vec] = 1,
    [qemu_ld2_i128] = 2,
    [qemu_ld_i32] = 1,
    [qemu_ld_i64] = 1,
    [rems_i32] = 1,
    [rems_i64] = 1,
    [remu_i32] = 1,
    [remu_i64] = 1,
    [rotl_i32] = 1,
    [rotl_i64] = 1,
    [rotli_vec] = 1,
    [rotls_vec] = 1,
    [rotlv_vec] = 1,
    [rotr_i32] = 1,
    [rotr_i64] = 1,
    [rotrv_vec] = 1,
    [sar_i32] = 1,
    [sar_i64] = 1,
    [sari_vec] = 1,
    [sars_vec] = 1,
    [sarv_vec] = 1,
    [setcond_i32] = 1,
    [setcond_i64] = 1,
    [sextract_i32] = 1,
    [sextract_i64] = 1,
    [shl_i32] = 1,
    [shl_i64] = 1,
    [shli_vec] = 1,
    [shls_vec] = 1,
    [shlv_vec] = 1,
    [shr_i32] = 1,
    [shr_i64] = 1,
    [shri_vec] = 1,
    [shrs_vec] = 1,
    [shrv_vec] = 1,
    [smax_vec] = 1,
    [smin_vec] = 1,
    [ssadd_vec] = 1,
    [sssub_vec] = 1,
    [sub_i32] = 1,
    [sub_i64] = 1,
    [sub_vec] = 1,
    [umax_vec] = 1,
    [umin_vec] = 1,
    [usadd_vec] = 1,
    [ussub_vec] = 1,
    [xor_i32] = 1,
    [xor_i64] = 1,
    [xor_vec] = 1,
};

const uint8_t opcmem_addr_nzidx[OPCODE_MAX] = {
    [ld16s_i32] = 1,
    [ld16s_i64] = 1,
    [ld16u_i32] = 1,
    [ld16u_i64] = 1,
    [ld32s_i64] = 1,
    [ld32u_i64] = 1,
    [ld8s_i32] = 1,
    [ld8s_i64] = 1,
    [ld8u_i32] = 1,
    [ld8u_i64] = 1,
    [ld_i32] = 1,
    [ld_i64] = 1,
    [ld_vec] = 1,
    [qemu_ld2_i128] = 2,
    [qemu_ld_i32] = 1,
    [qemu_ld_i64] = 1,
    [qemu_st2_i128] = 2,
    [qemu_st_i32] = 1,
    [qemu_st_i64] = 1,
    [st16_i32] = 1,
    [st16_i64] = 1,
    [st32_i64] = 1,
    [st8_i32] = 1,
    [st8_i64] = 1,
    [st_i32] = 1,
    [st_i64] = 1,
    [st_vec] = 1,
};

const int helper_require_exception_path[HELPER_MAX] = {
    [helper_cc_compute_nz] = 1,
    [helper_addps_xmm] = 1,
    [helper_minps_xmm] = 1,
    [helper_cmpltps_xmm] = 1,
    [helper_addsubps_xmm] = 1,
    [helper_cmpltqps_xmm] = 1,
    [helper_vpgatherdq_xmm] = 1,
    [helper_cmpnlepd_xmm] = 1,
    [helper_cmpnequps_xmm] = 1,
    [helper_cmptrueps_xmm] = 1,
    [helper_cmpngtpd_xmm] = 1,
    [helper_cmpneqpd_xmm] = 1,
    [helper_aesdec_xmm] = 1,
    [helper_cmpfalsepd_xmm] = 1,
    [helper_cmpfalsespd_xmm] = 1,
    [helper_cmpngtps_xmm] = 1,
    [helper_cvttpd2dq_xmm] = 1,
    [helper_cmpltpd_xmm] = 1,
    [helper_mulps_xmm] = 1,
    [helper_cvtps2dq_xmm] = 1,
    [helper_cmpfalseps_xmm] = 1,
    [helper_cmpnleqpd_xmm] = 1,
    [helper_cmpneqps_xmm] = 1,
    [helper_cmpngtqpd_xmm] = 1,
    [helper_cmpltqpd_xmm] = 1,
    [helper_addsubpd_xmm] = 1,
    [helper_aesenc_xmm] = 1,
    [helper_cvtph2ps_xmm] = 1,
    [helper_sqrtpd_xmm] = 1,
    [helper_vpmaskmovq_st_xmm] = 1,
    [helper_cmpnleps_xmm] = 1,
    [helper_cmpneqqpd_xmm] = 1,
    [helper_cvtps2ph_xmm] = 1,
    [helper_cmpunordsps_xmm] = 1,
    [helper_fma4ps_xmm] = 1,
    [helper_hsubps_xmm] = 1,
    [helper_cmpordsps_xmm] = 1,
    [helper_cmpequsps_xmm] = 1,
    [helper_mulpd_xmm] = 1,
    [helper_cmpnltpd_xmm] = 1,
    [helper_cvtpd2dq_xmm] = 1,
    [helper_cmpeqpd_xmm] = 1,
    [helper_cmpngepd_xmm] = 1,
    [helper_roundss_xmm] = 1,
    [helper_dppd_xmm] = 1,
    [helper_cmpgeps_xmm] = 1,
    [helper_cmpgeqps_xmm] = 1,
    [helper_aesdeclast_xmm] = 1,
    [helper_cmpngeps_xmm] = 1,
    [helper_haddpd_xmm] = 1,
    [helper_minpd_xmm] = 1,
    [helper_cmpgeqpd_xmm] = 1,
    [helper_cmpnltqpd_xmm] = 1,
    [helper_cmpeqps_xmm] = 1,
    [helper_addpd_xmm] = 1,
    [helper_vpgatherqq_xmm] = 1,
    [helper_roundsd_xmm] = 1,
    [helper_aesimc_xmm] = 1,
    [helper_aesenclast_xmm] = 1,
    [helper_cmpngeqpd_xmm] = 1,
    [helper_maskmov_xmm] = 1,
    [helper_cmpnltps_xmm] = 1,
    [helper_cmpgepd_xmm] = 1,
    [helper_pclmulqdq_xmm] = 1,
    [helper_cmpordpd_xmm] = 1,
    [helper_cmpnequpd_xmm] = 1,
    [helper_cmplepd_xmm] = 1,
    [helper_cmpequpd_xmm] = 1,
    [helper_haddps_xmm] = 1,
    [helper_dpps_xmm] = 1,
    [helper_cmpleqpd_xmm] = 1,
    [helper_vpmaskmovd_st_xmm] = 1,
    [helper_cmpeqsps_xmm] = 1,
    [helper_cmptruepd_xmm] = 1,
    [helper_rcpps_xmm] = 1,
    [helper_divps_xmm] = 1,
    [helper_vpgatherdd_xmm] = 1,
    [helper_subpd_xmm] = 1,
    [helper_cmpleqps_xmm] = 1,
    [helper_cmpnleqps_xmm] = 1,
    [helper_cmpleps_xmm] = 1,
    [helper_maxpd_xmm] = 1,
    [helper_fma4pd_xmm] = 1,
    [helper_cmpeqspd_xmm] = 1,
    [helper_hsubpd_xmm] = 1,
    [helper_cvtpd2ps_xmm] = 1,
    [helper_cmpneqqps_xmm] = 1,
    [helper_cmpordps_xmm] = 1,
    [helper_cmpequps_xmm] = 1,
    [helper_cmpngtqps_xmm] = 1,
    [helper_cmptruesps_xmm] = 1,
    [helper_cmpfalsesps_xmm] = 1,
    [helper_cmpequspd_xmm] = 1,
    [helper_cmpordspd_xmm] = 1,
    [helper_subps_xmm] = 1,
    [helper_cvttps2dq_xmm] = 1,
    [helper_maxps_xmm] = 1,
    [helper_cmpgtqpd_xmm] = 1,
    [helper_roundps_xmm] = 1,
    [helper_cmpunordps_xmm] = 1,
    [helper_cvtdq2pd_xmm] = 1,
    [helper_vpgatherqd_xmm] = 1,
    [helper_cmpnequsps_xmm] = 1,
    [helper_cmpunordspd_xmm] = 1,
    [helper_sqrtps_xmm] = 1,
    [helper_cmpgtpd_xmm] = 1,
    [helper_cvtdq2ps_xmm] = 1,
    [helper_cmpnltqps_xmm] = 1,
    [helper_cmpunordpd_xmm] = 1,
    [helper_cmpnequspd_xmm] = 1,
    [helper_rsqrtps_xmm] = 1,
    [helper_cmptruespd_xmm] = 1,
    [helper_divpd_xmm] = 1,
    [helper_cvtps2pd_xmm] = 1,
    [helper_roundpd_xmm] = 1,
    [helper_cmpngeqps_xmm] = 1,
    [helper_cmpgtqps_xmm] = 1,
    [helper_cmpgtps_xmm] = 1,
    [helper_addpd_ymm] = 1,
    [helper_addps_ymm] = 1,
    [helper_addsubpd_ymm] = 1,
    [helper_addsubps_ymm] = 1,
    [helper_aesdeclast_ymm] = 1,
    [helper_aesdec_ymm] = 1,
    [helper_aesenclast_ymm] = 1,
    [helper_aesenc_ymm] = 1,
    [helper_cmpeqpd_ymm] = 1,
    [helper_cmpeqps_ymm] = 1,
    [helper_cmpeqspd_ymm] = 1,
    [helper_cmpeqsps_ymm] = 1,
    [helper_cmpequpd_ymm] = 1,
    [helper_cmpequps_ymm] = 1,
    [helper_cmpequspd_ymm] = 1,
    [helper_cmpequsps_ymm] = 1,
    [helper_cmpfalsepd_ymm] = 1,
    [helper_cmpfalseps_ymm] = 1,
    [helper_cmpfalsespd_ymm] = 1,
    [helper_cmpfalsesps_ymm] = 1,
    [helper_cmpgepd_ymm] = 1,
    [helper_cmpgeps_ymm] = 1,
    [helper_cmpgeqpd_ymm] = 1,
    [helper_cmpgeqps_ymm] = 1,
    [helper_cmpgtpd_ymm] = 1,
    [helper_cmpgtps_ymm] = 1,
    [helper_cmpgtqpd_ymm] = 1,
    [helper_cmpgtqps_ymm] = 1,
    [helper_cmplepd_ymm] = 1,
    [helper_cmpleps_ymm] = 1,
    [helper_cmpleqpd_ymm] = 1,
    [helper_cmpleqps_ymm] = 1,
    [helper_cmpltpd_ymm] = 1,
    [helper_cmpltps_ymm] = 1,
    [helper_cmpltqpd_ymm] = 1,
    [helper_cmpltqps_ymm] = 1,
    [helper_cmpneqpd_ymm] = 1,
    [helper_cmpneqps_ymm] = 1,
    [helper_cmpneqqpd_ymm] = 1,
    [helper_cmpneqqps_ymm] = 1,
    [helper_cmpnequpd_ymm] = 1,
    [helper_cmpnequps_ymm] = 1,
    [helper_cmpnequspd_ymm] = 1,
    [helper_cmpnequsps_ymm] = 1,
    [helper_cmpngepd_ymm] = 1,
    [helper_cmpngeps_ymm] = 1,
    [helper_cmpngeqpd_ymm] = 1,
    [helper_cmpngeqps_ymm] = 1,
    [helper_cmpngtpd_ymm] = 1,
    [helper_cmpngtps_ymm] = 1,
    [helper_cmpngtqpd_ymm] = 1,
    [helper_cmpngtqps_ymm] = 1,
    [helper_cmpnlepd_ymm] = 1,
    [helper_cmpnleps_ymm] = 1,
    [helper_cmpnleqpd_ymm] = 1,
    [helper_cmpnleqps_ymm] = 1,
    [helper_cmpnltpd_ymm] = 1,
    [helper_cmpnltps_ymm] = 1,
    [helper_cmpnltqpd_ymm] = 1,
    [helper_cmpnltqps_ymm] = 1,
    [helper_cmpordpd_ymm] = 1,
    [helper_cmpordps_ymm] = 1,
    [helper_cmpordspd_ymm] = 1,
    [helper_cmpordsps_ymm] = 1,
    [helper_cmptruepd_ymm] = 1,
    [helper_cmptrueps_ymm] = 1,
    [helper_cmptruespd_ymm] = 1,
    [helper_cmptruesps_ymm] = 1,
    [helper_cmpunordpd_ymm] = 1,
    [helper_cmpunordps_ymm] = 1,
    [helper_cmpunordspd_ymm] = 1,
    [helper_cmpunordsps_ymm] = 1,
    [helper_cvtdq2pd_ymm] = 1,
    [helper_cvtdq2ps_ymm] = 1,
    [helper_cvtpd2dq_ymm] = 1,
    [helper_cvtpd2ps_ymm] = 1,
    [helper_cvtph2ps_ymm] = 1,
    [helper_cvtps2dq_ymm] = 1,
    [helper_cvtps2pd_ymm] = 1,
    [helper_cvtps2ph_ymm] = 1,
    [helper_cvttpd2dq_ymm] = 1,
    [helper_cvttps2dq_ymm] = 1,
    [helper_divpd_ymm] = 1,
    [helper_divps_ymm] = 1,
    [helper_dpps_ymm] = 1,
    [helper_fma4pd_ymm] = 1,
    [helper_fma4ps_ymm] = 1,
    [helper_haddpd_ymm] = 1,
    [helper_haddps_ymm] = 1,
    [helper_hsubpd_ymm] = 1,
    [helper_hsubps_ymm] = 1,
    [helper_maxpd_ymm] = 1,
    [helper_maxps_ymm] = 1,
    [helper_minpd_ymm] = 1,
    [helper_minps_ymm] = 1,
    [helper_mulpd_ymm] = 1,
    [helper_mulps_ymm] = 1,
    [helper_pclmulqdq_ymm] = 1,
    [helper_rcpps_ymm] = 1,
    [helper_roundpd_ymm] = 1,
    [helper_roundps_ymm] = 1,
    [helper_rsqrtps_ymm] = 1,
    [helper_sqrtpd_ymm] = 1,
    [helper_sqrtps_ymm] = 1,
    [helper_subpd_ymm] = 1,
    [helper_subps_ymm] = 1,
    [helper_vpermdq_ymm] = 1,
    [helper_vpgatherdd_ymm] = 1,
    [helper_vpgatherdq_ymm] = 1,
    [helper_vpgatherqd_ymm] = 1,
    [helper_vpgatherqq_ymm] = 1,
    [helper_vpmaskmovd_st_ymm] = 1,
    [helper_vpmaskmovq_st_ymm] = 1,
    [helper_comisd] = 1,
    [helper_ucomisd] = 1,
    [helper_cvtsq2sd] = 1,
    [helper_cvttsd2sq] = 1,
    [helper_mulsd] = 1,
};

// Make sure argument type matches, otherwise inline could not happen!
const LLVMType helper_collapse_xmm_arg_type[HELPER_MAX][MAX_ADDED_ARGS] = {
    [helper_jmp_ind] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [helper_cc_compute_all] = {LLVMInt64, LLVMInt64, LLVMInt64, LLVMInt32},
    [helper_cc_compute_c] = {LLVMInt64, LLVMInt64, LLVMInt64, LLVMInt32},
    [helper_cc_compute_nz] = {LLVMInt64, LLVMInt64, LLVMInt32},
    [helper_palignr_xmm] = {LLVMInt32},
    [helper_dpps_xmm] = {LLVMInt32},
    [helper_pshufhw_xmm] = {LLVMInt32},
    [helper_maskmov_xmm] = {LLVMInt64},
    [helper_pclmulqdq_xmm] = {LLVMInt32},
    [helper_mpsadbw_xmm] = {LLVMInt32},
    [helper_aeskeygenassist_xmm] = {LLVMInt32},
    [helper_blendpd_xmm] = {LLVMInt32},
    [helper_blendps_xmm] = {LLVMInt32},
    [helper_roundpd_xmm] = {LLVMInt32},
    [helper_fma4pd_xmm] = {LLVMInt32, LLVMInt32},
    [helper_shufps_xmm] = {LLVMInt32},
    [helper_roundps_xmm] = {LLVMInt32},
    [helper_vpmaskmovq_st_xmm] = {LLVMInt64},
    [helper_shufpd_xmm] = {LLVMInt32},
    [helper_pblendw_xmm] = {LLVMInt32},
    [helper_fma4ps_xmm] = {LLVMInt32, LLVMInt32},
    [helper_vpermilps_imm_xmm] = {LLVMInt32},
    [helper_roundsd_xmm] = {LLVMInt32},
    [helper_vpmaskmovd_st_xmm] = {LLVMInt64},
    [helper_pcmpestri_xmm] = {LLVMInt32},
    [helper_roundss_xmm] = {LLVMInt32},
    [helper_vpermilpd_imm_xmm] = {LLVMInt32},
    [helper_pcmpistri_xmm] = {LLVMInt32},
    [helper_dppd_xmm] = {LLVMInt32},
    [helper_vpgatherqq_xmm] = {LLVMInt64, LLVMInt32},
    [helper_cvtps2ph_xmm] = {LLVMInt32},
    [helper_vpgatherdd_xmm] = {LLVMInt64, LLVMInt32},
    [helper_pcmpestrm_xmm] = {LLVMInt32},
    [helper_pcmpistrm_xmm] = {LLVMInt32},
    [helper_pshuflw_xmm] = {LLVMInt32},
    [helper_pshufd_xmm] = {LLVMInt32},
    [helper_vpgatherdq_xmm] = {LLVMInt64, LLVMInt32},
    [helper_vpgatherqd_xmm] = {LLVMInt64, LLVMInt32},
    [helper_vpgatherqd_ymm] = {LLVMInt64, LLVMInt32},
    [helper_pshufd_ymm] = {LLVMInt32},
    [helper_roundps_ymm] = {LLVMInt32},
    [helper_pclmulqdq_ymm] = {LLVMInt32},
    [helper_vpgatherqq_ymm] = {LLVMInt64, LLVMInt32},
    [helper_pshufhw_ymm] = {LLVMInt32},
    [helper_vpermq_ymm] = {LLVMInt32},
    [helper_vpermilps_imm_ymm] = {LLVMInt32},
    [helper_palignr_ymm] = {LLVMInt32},
    [helper_roundpd_ymm] = {LLVMInt32},
    [helper_pshuflw_ymm] = {LLVMInt32},
    [helper_fma4pd_ymm] = {LLVMInt32, LLVMInt32},
    [helper_fma4ps_ymm] = {LLVMInt32, LLVMInt32},
    [helper_dpps_ymm] = {LLVMInt32},
    [helper_cvtps2ph_ymm] = {LLVMInt32},
    [helper_pblendw_ymm] = {LLVMInt32},
    [helper_blendps_ymm] = {LLVMInt32},
    [helper_vpmaskmovq_st_ymm] = {LLVMInt64},
    [helper_vpmaskmovd_st_ymm] = {LLVMInt64},
    [helper_blendpd_ymm] = {LLVMInt32},
    [helper_vpgatherdd_ymm] = {LLVMInt64, LLVMInt32},
    [helper_mpsadbw_ymm] = {LLVMInt32},
    [helper_shufps_ymm] = {LLVMInt32},
    [helper_shufpd_ymm] = {LLVMInt32},
    [helper_vpgatherdq_ymm] = {LLVMInt64, LLVMInt32},
    [helper_vpermilpd_imm_ymm] = {LLVMInt32},
    [helper_vpermdq_ymm] = {LLVMInt32},
    [helper_cvtsq2sd] = {LLVMInt64},
    [helper_divq_EAX] = {LLVMInt64},
    [helper_divl_EAX] = {LLVMInt64},
    [helper_idivq_EAX] = {LLVMInt64},
    [helper_cvtsi2sd] = {LLVMInt32},
    [helper_cvtsi2ss] = {LLVMInt32},
    [helper_cvtsq2ss] = {LLVMInt64},
    [helper_fma4sd] = {LLVMInt32},
    [helper_fma4ss] = {LLVMInt32},
    [helper_sha256rnds2] = {LLVMInt32, LLVMInt32},
    [helper_cr4_testbit] = {LLVMInt32},
    [helper_divw_AX] = {LLVMInt64},
    [helper_idivb_AL] = {LLVMInt64},
    [helper_idivl_EAX] = {LLVMInt64},
    [helper_idivw_AX] = {LLVMInt64},
    [helper_pdep] = {LLVMInt64, LLVMInt64},
    [helper_pext] = {LLVMInt64, LLVMInt64},
    [helper_clrsb_i32] = {LLVMInt32},
    [helper_clrsb_i64] = {LLVMInt64},
    [helper_clz_i32] = {LLVMInt32, LLVMInt32},
    [helper_clz_i64] = {LLVMInt64, LLVMInt64},
    [helper_ctpop_i32] = {LLVMInt32},
    [helper_ctpop_i64] = {LLVMInt64},
    [helper_ctz_i32] = {LLVMInt32, LLVMInt32},
    [helper_ctz_i64] = {LLVMInt64, LLVMInt64},
    [helper_div_i32] = {LLVMInt32, LLVMInt32},
    [helper_div_i64] = {LLVMInt64, LLVMInt64},
    [helper_divu_i32] = {LLVMInt32, LLVMInt32},
    [helper_divu_i64] = {LLVMInt64, LLVMInt64},
    [helper_mulsh_i64] = {LLVMInt64, LLVMInt64},
    [helper_muluh_i64] = {LLVMInt64, LLVMInt64},
    [helper_rem_i32] = {LLVMInt32, LLVMInt32},
    [helper_rem_i64] = {LLVMInt64, LLVMInt64},
    [helper_remu_i32] = {LLVMInt32, LLVMInt32},
    [helper_remu_i64] = {LLVMInt64, LLVMInt64},
    [helper_sar_i64] = {LLVMInt64, LLVMInt64},
    [helper_shl_i64] = {LLVMInt64, LLVMInt64},
    [helper_shr_i64] = {LLVMInt64, LLVMInt64},
};

// Collected by qemu-runtime
const LLVMType helper_return_type[HELPER_MAX] = {
    [helper_div_i32] = LLVMInt32,
    [helper_rem_i32] = LLVMInt32,
    [helper_divu_i32] = LLVMInt32,
    [helper_remu_i32] = LLVMInt32,
    [helper_div_i64] = LLVMInt64,
    [helper_rem_i64] = LLVMInt64,
    [helper_divu_i64] = LLVMInt64,
    [helper_remu_i64] = LLVMInt64,
    [helper_shl_i64] = LLVMInt64,
    [helper_shr_i64] = LLVMInt64,
    [helper_sar_i64] = LLVMInt64,
    [helper_mulsh_i64] = LLVMInt64,
    [helper_muluh_i64] = LLVMInt64,
    [helper_clz_i32] = LLVMInt32,
    [helper_ctz_i32] = LLVMInt32,
    [helper_clz_i64] = LLVMInt64,
    [helper_ctz_i64] = LLVMInt64,
    [helper_clrsb_i32] = LLVMInt32,
    [helper_clrsb_i64] = LLVMInt64,
    [helper_ctpop_i32] = LLVMInt32,
    [helper_ctpop_i64] = LLVMInt64,
    [helper_lookup_tb_ptr] = LLVMInt64,
    [helper_memset] = LLVMInt64,
    //We should not observe this helper
    //[helper_ld_i128] = LLVMInt128,
    [helper_atomic_cmpxchgb] = LLVMInt32,
    [helper_atomic_cmpxchgw_be] = LLVMInt32,
    [helper_atomic_cmpxchgw_le] = LLVMInt32,
    [helper_atomic_cmpxchgl_be] = LLVMInt32,
    [helper_atomic_cmpxchgl_le] = LLVMInt32,
    [helper_atomic_cmpxchgq_be] = LLVMInt64,
    [helper_atomic_cmpxchgq_le] = LLVMInt64,
    //FIXME
    [helper_atomic_cmpxchgo_be] = LLVMInt128,
    [helper_atomic_cmpxchgo_le] = LLVMInt128,
    [helper_nonatomic_cmpxchgo] = LLVMInt128,
    [helper_atomic_fetch_addb] = LLVMInt32,
    [helper_atomic_fetch_addw_le] = LLVMInt32,
    [helper_atomic_fetch_addw_be] = LLVMInt32,
    [helper_atomic_fetch_addl_le] = LLVMInt32,
    [helper_atomic_fetch_addl_be] = LLVMInt32,
    [helper_atomic_fetch_addq_le] = LLVMInt64,
    [helper_atomic_fetch_addq_be] = LLVMInt64,
    [helper_atomic_fetch_andb] = LLVMInt32,
    [helper_atomic_fetch_andw_le] = LLVMInt32,
    [helper_atomic_fetch_andw_be] = LLVMInt32,
    [helper_atomic_fetch_andl_le] = LLVMInt32,
    [helper_atomic_fetch_andl_be] = LLVMInt32,
    [helper_atomic_fetch_andq_le] = LLVMInt64,
    [helper_atomic_fetch_andq_be] = LLVMInt64,
    [helper_atomic_fetch_orb] = LLVMInt32,
    [helper_atomic_fetch_orw_le] = LLVMInt32,
    [helper_atomic_fetch_orw_be] = LLVMInt32,
    [helper_atomic_fetch_orl_le] = LLVMInt32,
    [helper_atomic_fetch_orl_be] = LLVMInt32,
    [helper_atomic_fetch_orq_le] = LLVMInt64,
    [helper_atomic_fetch_orq_be] = LLVMInt64,
    [helper_atomic_fetch_xorb] = LLVMInt32,
    [helper_atomic_fetch_xorw_le] = LLVMInt32,
    [helper_atomic_fetch_xorw_be] = LLVMInt32,
    [helper_atomic_fetch_xorl_le] = LLVMInt32,
    [helper_atomic_fetch_xorl_be] = LLVMInt32,
    [helper_atomic_fetch_xorq_le] = LLVMInt64,
    [helper_atomic_fetch_xorq_be] = LLVMInt64,
    [helper_atomic_fetch_sminb] = LLVMInt32,
    [helper_atomic_fetch_sminw_le] = LLVMInt32,
    [helper_atomic_fetch_sminw_be] = LLVMInt32,
    [helper_atomic_fetch_sminl_le] = LLVMInt32,
    [helper_atomic_fetch_sminl_be] = LLVMInt32,
    [helper_atomic_fetch_sminq_le] = LLVMInt64,
    [helper_atomic_fetch_sminq_be] = LLVMInt64,
    [helper_atomic_fetch_uminb] = LLVMInt32,
    [helper_atomic_fetch_uminw_le] = LLVMInt32,
    [helper_atomic_fetch_uminw_be] = LLVMInt32,
    [helper_atomic_fetch_uminl_le] = LLVMInt32,
    [helper_atomic_fetch_uminl_be] = LLVMInt32,
    [helper_atomic_fetch_uminq_le] = LLVMInt64,
    [helper_atomic_fetch_uminq_be] = LLVMInt64,
    [helper_atomic_fetch_smaxb] = LLVMInt32,
    [helper_atomic_fetch_smaxw_le] = LLVMInt32,
    [helper_atomic_fetch_smaxw_be] = LLVMInt32,
    [helper_atomic_fetch_smaxl_le] = LLVMInt32,
    [helper_atomic_fetch_smaxl_be] = LLVMInt32,
    [helper_atomic_fetch_smaxq_le] = LLVMInt64,
    [helper_atomic_fetch_smaxq_be] = LLVMInt64,
    [helper_atomic_fetch_umaxb] = LLVMInt32,
    [helper_atomic_fetch_umaxw_le] = LLVMInt32,
    [helper_atomic_fetch_umaxw_be] = LLVMInt32,
    [helper_atomic_fetch_umaxl_le] = LLVMInt32,
    [helper_atomic_fetch_umaxl_be] = LLVMInt32,
    [helper_atomic_fetch_umaxq_le] = LLVMInt64,
    [helper_atomic_fetch_umaxq_be] = LLVMInt64,
    [helper_atomic_add_fetchb] = LLVMInt32,
    [helper_atomic_add_fetchw_le] = LLVMInt32,
    [helper_atomic_add_fetchw_be] = LLVMInt32,
    [helper_atomic_add_fetchl_le] = LLVMInt32,
    [helper_atomic_add_fetchl_be] = LLVMInt32,
    [helper_atomic_add_fetchq_le] = LLVMInt64,
    [helper_atomic_add_fetchq_be] = LLVMInt64,
    [helper_atomic_and_fetchb] = LLVMInt32,
    [helper_atomic_and_fetchw_le] = LLVMInt32,
    [helper_atomic_and_fetchw_be] = LLVMInt32,
    [helper_atomic_and_fetchl_le] = LLVMInt32,
    [helper_atomic_and_fetchl_be] = LLVMInt32,
    [helper_atomic_and_fetchq_le] = LLVMInt64,
    [helper_atomic_and_fetchq_be] = LLVMInt64,
    [helper_atomic_or_fetchb] = LLVMInt32,
    [helper_atomic_or_fetchw_le] = LLVMInt32,
    [helper_atomic_or_fetchw_be] = LLVMInt32,
    [helper_atomic_or_fetchl_le] = LLVMInt32,
    [helper_atomic_or_fetchl_be] = LLVMInt32,
    [helper_atomic_or_fetchq_le] = LLVMInt64,
    [helper_atomic_or_fetchq_be] = LLVMInt64,
    [helper_atomic_xor_fetchb] = LLVMInt32,
    [helper_atomic_xor_fetchw_le] = LLVMInt32,
    [helper_atomic_xor_fetchw_be] = LLVMInt32,
    [helper_atomic_xor_fetchl_le] = LLVMInt32,
    [helper_atomic_xor_fetchl_be] = LLVMInt32,
    [helper_atomic_xor_fetchq_le] = LLVMInt64,
    [helper_atomic_xor_fetchq_be] = LLVMInt64,
    [helper_atomic_smin_fetchb] = LLVMInt32,
    [helper_atomic_smin_fetchw_le] = LLVMInt32,
    [helper_atomic_smin_fetchw_be] = LLVMInt32,
    [helper_atomic_smin_fetchl_le] = LLVMInt32,
    [helper_atomic_smin_fetchl_be] = LLVMInt32,
    [helper_atomic_smin_fetchq_le] = LLVMInt64,
    [helper_atomic_smin_fetchq_be] = LLVMInt64,
    [helper_atomic_umin_fetchb] = LLVMInt32,
    [helper_atomic_umin_fetchw_le] = LLVMInt32,
    [helper_atomic_umin_fetchw_be] = LLVMInt32,
    [helper_atomic_umin_fetchl_le] = LLVMInt32,
    [helper_atomic_umin_fetchl_be] = LLVMInt32,
    [helper_atomic_umin_fetchq_le] = LLVMInt64,
    [helper_atomic_umin_fetchq_be] = LLVMInt64,
    [helper_atomic_smax_fetchb] = LLVMInt32,
    [helper_atomic_smax_fetchw_le] = LLVMInt32,
    [helper_atomic_smax_fetchw_be] = LLVMInt32,
    [helper_atomic_smax_fetchl_le] = LLVMInt32,
    [helper_atomic_smax_fetchl_be] = LLVMInt32,
    [helper_atomic_smax_fetchq_le] = LLVMInt64,
    [helper_atomic_smax_fetchq_be] = LLVMInt64,
    [helper_atomic_umax_fetchb] = LLVMInt32,
    [helper_atomic_umax_fetchw_le] = LLVMInt32,
    [helper_atomic_umax_fetchw_be] = LLVMInt32,
    [helper_atomic_umax_fetchl_le] = LLVMInt32,
    [helper_atomic_umax_fetchl_be] = LLVMInt32,
    [helper_atomic_umax_fetchq_le] = LLVMInt64,
    [helper_atomic_umax_fetchq_be] = LLVMInt64,
    [helper_atomic_xchgb] = LLVMInt32,
    [helper_atomic_xchgw_le] = LLVMInt32,
    [helper_atomic_xchgw_be] = LLVMInt32,
    [helper_atomic_xchgl_le] = LLVMInt32,
    [helper_atomic_xchgl_be] = LLVMInt32,
    [helper_atomic_xchgq_le] = LLVMInt64,
    [helper_atomic_xchgq_be] = LLVMInt64,
    [helper_cc_compute_all] = LLVMInt64,
    [helper_cc_compute_c] = LLVMInt64,
    [helper_cc_compute_nz] = LLVMInt64,
    [helper_read_eflags] = LLVMInt64,
    [helper_bndldx32] = LLVMInt64,
    [helper_bndldx64] = LLVMInt64,
    [helper_aam] = LLVMInt64,
    [helper_aad] = LLVMInt64,
    [helper_lsl] = LLVMInt64,
    [helper_lar] = LLVMInt64,
    [helper_rdpid] = LLVMInt64,
    [helper_fsts_ST0] = LLVMInt32,
    [helper_fstl_ST0] = LLVMInt64,
    [helper_fist_ST0] = LLVMInt32,
    [helper_fistl_ST0] = LLVMInt32,
    [helper_fistll_ST0] = LLVMInt64,
    [helper_fistt_ST0] = LLVMInt32,
    [helper_fisttl_ST0] = LLVMInt32,
    [helper_fisttll_ST0] = LLVMInt64,
    [helper_fnstsw] = LLVMInt32,
    [helper_fnstcw] = LLVMInt32,
    [helper_xgetbv] = LLVMInt64,
    [helper_rdpkru] = LLVMInt64,
    [helper_pdep] = LLVMInt64,
    [helper_pext] = LLVMInt64,
    [helper_cvtss2si] = LLVMInt32,
    [helper_cvtsd2si] = LLVMInt32,
    [helper_cvtss2sq] = LLVMInt64,
    [helper_cvtsd2sq] = LLVMInt64,
    [helper_cvttss2si] = LLVMInt32,
    [helper_cvttsd2si] = LLVMInt32,
    [helper_cvttss2sq] = LLVMInt64,
    [helper_cvttsd2sq] = LLVMInt64,
    [helper_movmskps_xmm] = LLVMInt32,
    [helper_movmskpd_xmm] = LLVMInt32,
    [helper_crc32] = LLVMInt64,
    [helper_movmskps_ymm] = LLVMInt32,
    [helper_movmskpd_ymm] = LLVMInt32,
    [helper_rdrand] = LLVMInt64,
};

const uint64_t xreg_offsets[XREG_MAX] = {
    [rax] = ENV_OFFSET_rax,
    [rcx] = ENV_OFFSET_rcx,
    [rdx] = ENV_OFFSET_rdx,
    [rbx] = ENV_OFFSET_rbx,
    [rsp] = ENV_OFFSET_rsp,
    [rbp] = ENV_OFFSET_rbp,
    [rsi] = ENV_OFFSET_rsi,
    [rdi] = ENV_OFFSET_rdi,
    [r8] = ENV_OFFSET_r8,
    [r9] = ENV_OFFSET_r9,
    [r10] = ENV_OFFSET_r10,
    [r11] = ENV_OFFSET_r11,
    [r12] = ENV_OFFSET_r12,
    [r13] = ENV_OFFSET_r13,
    [r14] = ENV_OFFSET_r14,
    [r15] = ENV_OFFSET_r15,
#if AOT_LEVEL == AOT_LEVEL_MAX
    [cc_src] = ENV_OFFSET_cc_src,
    [cc_dst] = ENV_OFFSET_cc_dst,
    [cc_op] = ENV_OFFSET_cc_op,
#endif
    [rip] = ENV_OFFSET_rip,
};

const CVectorType cvector_type_for_llvm_type[LLVMMAXType] = {
    [LLVMVector2xi64] = v2ulong,
    [LLVMVector4xi32] = v4uint,
    [LLVMVector8xi16] = v8ushort,
    [LLVMVector16xi8] = v16uchar,
    [LLVMVector4xi64] = v4ulong,
    [LLVMVector8xi32] = v8uint,
    [LLVMVector16xi16] = v16ushort,
    [LLVMVector32xi8] = v32uchar,
};

// FIXME: sanity check and cover more helpers
const int helper_do_not_sync_vector[HELPER_MAX] = {
    [helper_cpuid] = 1,
    [helper_rdtsc] = 1,
};
