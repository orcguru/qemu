#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <string.h>
#include "tcg_ast.h"

//#define BUILD_RISCV_ON_AARCH      1
//#define DEBUG                     1
#define STACK_INDEX_SHIFT           10
#define XMM_COUNT                   15
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

static XMMReg lookup_xmm(uint64_t offset) {
    uint16_t off = (uint16_t)offset;
    XMMReg x;
    x.xmm_idx = NON_XMM;
    x.xmm_offset = 0;
    if (xmm_offsets[0] <= off && off < (xmm_offsets[XMM_COUNT-1] + 0x20)) {
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

OperandType get_mapped_slot(OperandType slot) {
    if (slot.s.slot_type == SUB_SLOT_TMPL) {
        assert(slot.s.slot_idx < (1UL<<STACK_INDEX_SHIFT));
        if (tmpl_map[slot.s.slot_idx] == 0xffff) {
            assert(tmp_idx < (1UL<<STACK_INDEX_SHIFT));
#ifdef DEBUG
            printf("register loc%d as %d\n", slot.s.slot_idx, tmp_idx); fflush(NULL);
#endif
            tmpl_map[slot.s.slot_idx] = tmp_idx;
            tmp_idx += 1;
        }
        slot.s.slot_type = SUB_SLOT_TMP;
        slot.s.slot_idx = tmpl_map[slot.s.slot_idx];
        return slot;
    } else if (slot.s.slot_type == SUB_SLOT_TMPT) {
        assert(slot.s.slot_idx < (1UL<<STACK_INDEX_SHIFT));
        if (tmpt_map[slot.s.slot_idx] == 0xffff) {
            assert(tmp_idx < (1UL<<STACK_INDEX_SHIFT));
#ifdef DEBUG
            printf("register tmp%d as %d\n", slot.s.slot_idx, tmp_idx); fflush(NULL);
#endif
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
size_t create_scalar_slot2(void *ptr, OHType op, OperandType s0, OperandType s1) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr4B *i = (Instr4B *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr4B_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    i->attr_type = SUB_ATTR_INVALID;
    return sizeof(*i);
}

size_t create_scalar_slot2_attr(void *ptr, OHType op, OperandType s0, OperandType s1, AttrSrcInfo a0) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr4B *i = (Instr4B *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr4B_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(a0.subt == SUB_ATTR_SWAP);
    i->attr_type = a0.subt;
    i->attr_val = a0.p.swap;
    return sizeof(*i);
}

size_t create_scalar_slot2_attr2(void *ptr, OHType op, OperandType s0, OperandType s1, AttrSrcInfo a0, AttrSrcInfo a1) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr4B *i = (Instr4B *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr4B_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(a0.subt == SUB_ATTR_SWAP);
    assert(a0.subt == a1.subt);
    i->attr_type = a0.subt;
    i->attr_val = a0.p.swap | a1.p.swap;
    return sizeof(*i);
}

size_t create_jmpdirect(void *ptr, uint64_t val) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[jmp_direct]); fflush(NULL);
#endif
    Instr1B14 *i = (Instr1B14 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B14_ext;
    i->opc = jmp_direct;
    i->imm = val;
    return sizeof(*i);
}

size_t create_scalar_slot_imm(void *ptr, OHType op, OperandType s0, uint64_t i0) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B28 *i = (Instr1B28 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B28_ext;
    i->opc = op.o;
    SET_SLOT(0);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_slot2_imm(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B44 *i = (Instr1B44 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B44_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm = i0;
    return sizeof(*i);
}

// Ignore num which is used as mmuidx for now.
size_t create_scalar_slot2_attr3_num(void *ptr, OHType op, OperandType s0, OperandType s1, AttrSrcInfo a0, AttrSrcInfo a1, AttrSrcInfo a2, uint64_t n0) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr4B *i = (Instr4B *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr4B_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    assert(a0.subt == SUB_ATTR_ATOMIC && a1.subt == SUB_ATTR_ALIGNMENT && a2.subt == SUB_ATTR_SRCSIZEEXT);
    i->attr_type = SUB_ATTR_STORAGE;
    i->attr_val = (a0.p.storage.attr.atomic << 6) | (a1.p.storage.attr.alignment << 4) | (a2.p.storage.attr.ext << 3) | a2.p.storage.size;
    return sizeof(*i);
}

size_t create_scalar_slot3(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B4 *i = (Instr1B4 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B4_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    return sizeof(*i);
}

size_t create_vector_slot_env_imm(void *ptr, OHType op, AttrSrcInfo ai, OperandType s0, uint64_t i0) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    XMMReg x = lookup_xmm(i0);
    if (x.xmm_idx != NON_XMM) {
        Instr1BV4X *i = (Instr1BV4X *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1BV4X_ext;
        i->opc = op.o;
        i->es = ai.p.ves;
        SET_SLOT(0);
        i->xmm_idx = x.xmm_idx;
        i->xmm_offset = x.xmm_offset;
        return sizeof(*i);
    } else {
        Instr1BV4XE *i = (Instr1BV4XE *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1BV4XE_ext;
        i->opc = op.o;
        i->es = ai.p.ves;
        SET_SLOT(0);
        i->env_offset = i0;
        return sizeof(*i);
    }
}

size_t create_scalar_slot2_imm2(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, uint64_t i1) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B41I2 *i = (Instr1B41I2 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B41I2_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm0 = i0;
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_scalar_slot_env_imm(void *ptr, OHType op, OperandType s0, uint64_t i0) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    XMMReg x = lookup_xmm(i0);
    if (x.xmm_idx != NON_XMM) {
        Instr1B4X *i = (Instr1B4X *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1B4X_ext;
        i->opc = op.o;
        SET_SLOT(0);
        i->xmm_idx = x.xmm_idx;
        i->xmm_offset = x.xmm_offset;
        return sizeof(*i);
    } else {
        Instr1B22 *i = (Instr1B22 *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1B22_ext;
        i->opc = op.o;
        SET_SLOT(0);
        assert(i0 < (1<<16));
        i->env_offset = i0;
        return sizeof(*i);
    }
}

size_t create_branch_condition(void *ptr, OperandType s0, uint64_t i0, uint8_t relop, uint8_t label) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[brcond_i64]); fflush(NULL);
#endif
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

size_t create_branch_condition_slot(void *ptr, OperandType s0, OperandType s1, uint8_t relop, uint8_t label) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[brcond_i64]); fflush(NULL);
#endif
    Instr1B143 *i = (Instr1B143 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B143_ext;
    i->opc = brcond_i64;
    SET_SLOT(0);
    SET_SLOT(1);
    i->relop = relop;
    i->label = label;
    return sizeof(*i);
}

size_t create_setlabel(void *ptr, OHType op, uint8_t label) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B2 *i = (Instr1B2 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B2_ext;
    i->opc = op.o;
    i->label = label;
    return sizeof(*i);
}

size_t create_helper_slot4(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, OperandType s3) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH4 *i = (Instr1BH4 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4_ext;
    i->helper_l = (uint8_t)h.h;
    i->helper_h = h.h >> 8;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    return sizeof(*i);
}

size_t create_vector_slot3(void *ptr, OHType op, AttrSrcInfo ai, OperandType s0, OperandType s1, OperandType s2) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1BV4 *i = (Instr1BV4 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV4_ext;
    i->opc = op.o;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    return sizeof(*i);
}

size_t create_vector_slot4(void *ptr, OHType op, AttrSrcInfo ai, OperandType s0, OperandType s1, OperandType s2, OperandType s3) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1BV42 *i = (Instr1BV42 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV42_ext;
    i->opc = op.o;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    return sizeof(*i);
}

size_t create_vector_slot5_relop(void *ptr, OHType op, AttrSrcInfo ai, OperandType s0, OperandType s1, OperandType s2, OperandType s3, OperandType s4, uint8_t relop) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1BV8 *i = (Instr1BV8 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV8_ext;
    i->opc = op.o;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    SET_SLOT(4);
    i->relop = relop;
    return sizeof(*i);
}

size_t create_helper_slot5(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, OperandType s3, OperandType s4) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH141 *i = (Instr1BH141 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH141_ext;
    i->helper_l = (uint8_t)h.h;
    i->helper_h = h.h >> 8;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    SET_SLOT(4);
    return sizeof(*i);
}

size_t create_helper_slot4_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, OperandType s3, uint32_t i0) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH42 *i = (Instr1BH42 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH42_ext;
    i->helper_l = (uint8_t)h.h;
    i->helper_h = h.h >> 8;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_vector_slot_vimm(void *ptr, OHType op, AttrSrcInfo ai, OperandType s0, uint64_t vi0) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1BV21 *i = (Instr1BV21 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV21_ext;
    i->opc = op.o;
    i->es = ai.p.ves;
    SET_SLOT(0);
    i->imm = vi0;
    return sizeof(*i);
}

// Ignore num which is used as mmuidx for now.
size_t create_scalar_slot3_attr3_num(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2, AttrSrcInfo a0, AttrSrcInfo a1, AttrSrcInfo a2, uint64_t n0) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B41 *i = (Instr1B41 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B41_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    assert(a0.subt == SUB_ATTR_ATOMIC && a1.subt == SUB_ATTR_ALIGNMENT && a2.subt == SUB_ATTR_SRCSIZEEXT);
    i->attr_type = SUB_ATTR_STORAGE;
    i->attr_val = (a0.p.storage.attr.atomic << 6) | (a1.p.storage.attr.alignment << 4) | (a2.p.storage.attr.ext << 3) | a2.p.storage.size;
    return sizeof(*i);
}

size_t create_vector_slot2_imm(void *ptr, OHType op, AttrSrcInfo ai, OperandType s0, OperandType s1, uint64_t i0) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1BV4I *i = (Instr1BV4I *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV4I_ext;
    i->opc = op.o;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_slot_imm2(void *ptr, OHType op, OperandType s0, uint64_t i0, uint64_t i1) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B24 *i = (Instr1B24 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B24_ext;
    i->opc = op.o;
    SET_SLOT(0);
    i->imm0 = i0;
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_vector_slot2(void *ptr, OHType op, AttrSrcInfo ai, OperandType s0, OperandType s1) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1BV4S2 *i = (Instr1BV4S2 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV4S2_ext;
    i->opc = op.o;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    return sizeof(*i);
}

size_t create_vector_slot3_relop(void *ptr, OHType op, AttrSrcInfo ai, OperandType s0, OperandType s1, OperandType s2, uint8_t relop) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1BV41 *i = (Instr1BV41 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BV41_ext;
    i->opc = op.o;
    i->es = ai.p.ves;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i->relop = relop;
    return sizeof(*i);
}

size_t create_helper_env_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, uint32_t i0) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH24I_ENV0 *i = (Instr1BH24I_ENV0 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH24I_ENV0_ext;
    i->helper = h.h;
    assert(noargs == 0);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_slot(void *ptr, OHType op, OperandType s0) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B2S *i = (Instr1B2S *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B2S_ext;
    i->opc = op.o;
    SET_SLOT(0);
    return sizeof(*i);
}

size_t create_scalar_slot3_imm(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2, uint64_t i0) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B41I *i = (Instr1B41I *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B41I_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_slot2_imm_slot2_relop(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, OperandType s2, OperandType s3, RelopType r) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B422 *i = (Instr1B422 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B422_ext;
    i->opc = op.o;
    i->relop = r;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_slot3_imm2(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2, uint64_t i0, uint64_t i1) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B411 *i = (Instr1B411 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B411_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i->imm0 = i0;
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_scalar_imm_env_imm(void *ptr, OHType op, uint64_t i0, uint64_t i1) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    XMMReg x = lookup_xmm(i1);
    if (x.xmm_idx != NON_XMM) {
        Instr1B142 *i = (Instr1B142 *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1B142_ext;
        i->opc = op.o;
        i->imm = i0;
        i->xmm_idx = x.xmm_idx;
        i->xmm_offset = x.xmm_offset;
        return sizeof(*i);
    } else {
        Instr1B142E *i = (Instr1B142E *)ptr;
        i->instr_type = SIZEXB;
        i->instr_type_ext = Instr1B142E_ext;
        i->opc = op.o;
        i->imm = i0;
        assert((uint64_t)((long)((int16_t)i1)) == i1);
        i->env_offset = (uint16_t)i1;
        return sizeof(*i);
    }
}

size_t create_helper_env_slot(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH21_ENV0 *i = (Instr1BH21_ENV0 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH21_ENV0_ext;
    i->helper = h.h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    return sizeof(*i);
}

size_t create_helper_slot_env(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH21_ENV1 *i = (Instr1BH21_ENV1 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH21_ENV1_ext;
    i->helper = h.h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    return sizeof(*i);
}

size_t create_scalar_slot2_imm_slot_imm_relop(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, OperandType s2, uint64_t i1, RelopType r) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B4111 *i = (Instr1B4111 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B4111_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i->imm0 = i0;
    i->imm1 = i1;
    i->relop = r;
    return sizeof(*i);
}

size_t create_scalar_slot5_relop(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2, OperandType s3, OperandType s4, RelopType r) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B8 *i = (Instr1B8 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B8_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    SET_SLOT(3);
    SET_SLOT(4);
    i->relop = r;
    return sizeof(*i);
}

size_t create_helper_slot3_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, uint32_t i0) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH4I *i = (Instr1BH4I *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4I_ext;
    i->helper_l = (uint8_t)h.h;
    i->helper_h = h.h >> 8;
    assert(noargs == 0);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_helper_slot3_imm2(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, uint32_t i0, uint32_t i1) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH4I1 *i = (Instr1BH4I1 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4I1_ext;
    i->helper_l = (uint8_t)h.h;
    i->helper_h = h.h >> 8;
    assert(noargs == 1);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i->imm0 = i0;
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_helper_slot2_imm3(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, uint32_t i0, uint32_t i1, uint32_t i2) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH4I11 *i = (Instr1BH4I11 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4I11_ext;
    i->helper_l = (uint8_t)h.h;
    i->helper_h = h.h >> 8;
    assert(noargs == 1);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm0 = i0;
    i->imm1 = i1;
    i->imm2 = i2;
    return sizeof(*i);
}

size_t create_helper_env_slot3_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2, uint32_t i0) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH4I_ENV0 *i = (Instr1BH4I_ENV0 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4I_ENV0_ext;
    i->helper_l = (uint8_t)h.h;
    i->helper_h = h.h >> 8;
    assert(noargs == 0);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_slot2_imm_relop(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, RelopType r) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B42 *i = (Instr1B42 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B42_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm = i0;
    i->relop = r;
    return sizeof(*i);
}

size_t create_helper_env(void *ptr, OHType h, uint16_t cflags, uint8_t noargs) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH2_ENV0 *i = (Instr1BH2_ENV0 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH2_ENV0_ext;
    i->helper = h.h;
    assert(noargs == 0);
    return sizeof(*i);
}

size_t create_helper_env_imm_slot(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, uint32_t i0, OperandType s0) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH21S_ENV0 *i = (Instr1BH21S_ENV0 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH21S_ENV0_ext;
    i->helper = h.h;
    assert(noargs < 2);
    i->noargs = noargs;
    i->imm = i0;
    SET_SLOT(0);
    return sizeof(*i);
}

size_t create_scalar_slot_imm_slot(void *ptr, OHType op, OperandType s0, uint64_t i0, OperandType s1) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B281 *i = (Instr1B281 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B281_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_helper_slot3(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH4S3 *i = (Instr1BH4S3 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4S3_ext;
    i->helper_l = (uint8_t)h.h;
    i->helper_h = h.h >> 8;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    return sizeof(*i);
}

size_t create_helper_env_slot3(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, OperandType s2) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH4S3_ENV0 *i = (Instr1BH4S3_ENV0 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4S3_ENV0_ext;
    i->helper_l = (uint8_t)h.h;
    i->helper_h = h.h >> 8;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    return sizeof(*i);
}

size_t create_scalar_slot2_imm2_slot_relop(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, uint64_t i1, OperandType s2, RelopType r) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B4112 *i = (Instr1B4112 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B4112_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i->imm0 = i0;
    i->imm1 = i1;
    i->relop = r;
    return sizeof(*i);
}

size_t create_scalar_slot2_imm3_relop(void *ptr, OHType op, OperandType s0, OperandType s1, uint64_t i0, uint64_t i1, uint64_t i2, RelopType r) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B41122 *i = (Instr1B41122 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B41122_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm0 = i0;
    i->imm1 = i1;
    i->imm2 = i2;
    i->relop = r;
    return sizeof(*i);
}

size_t create_helper_slot2_imm2(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, uint32_t i0, uint32_t i1) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH412 *i = (Instr1BH412 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH412_ext;
    i->helper = h.h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm0 = i0;
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_helper_slot2_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, uint32_t i0) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH41 *i = (Instr1BH41 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH41_ext;
    i->helper = h.h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_helper_env_slot2_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1, uint32_t i0) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH41_ENV0 *i = (Instr1BH41_ENV0 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH41_ENV0_ext;
    i->helper = h.h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_slot3_relop(void *ptr, OHType op, OperandType s0, OperandType s1, OperandType s2, RelopType r) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B41R *i = (Instr1B41R *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B41R_ext;
    i->opc = op.o;
    SET_SLOT(0);
    SET_SLOT(1);
    SET_SLOT(2);
    i->relop = r;
    return sizeof(*i);
}

size_t create_helper_env_imm2(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, uint32_t i0, uint32_t i1) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH24_ENV0 *i = (Instr1BH24_ENV0 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH24_ENV0_ext;
    i->helper = h.h;
    assert(noargs < 2);
    i->noargs = noargs;
    i->imm0 = i0;
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_helper_env_slot_imm(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, uint32_t i0) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH211_ENV0 *i = (Instr1BH211_ENV0 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH211_ENV0_ext;
    i->helper = h.h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    i->imm = i0;
    return sizeof(*i);
}

size_t create_scalar_imm_slot_imm(void *ptr, OHType op, uint64_t i0, OperandType s0, uint64_t i1) {
#ifdef DEBUG
    printf("%s %s ", __FUNCTION__, opcode_type_str[op.o]); fflush(NULL);
#endif
    Instr1B1111 *i = (Instr1B1111 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1B1111_ext;
    i->opc = op.o;
    i->imm0 = i0;
    SET_SLOT(0);
    i->imm1 = i1;
    return sizeof(*i);
}

size_t create_helper_env_slot2(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH4S_ENV0 *i = (Instr1BH4S_ENV0 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4S_ENV0_ext;
    i->helper = h.h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    return sizeof(*i);
}

size_t create_helper_slot_env_slot(void *ptr, OHType h, uint16_t cflags, uint8_t noargs, OperandType s0, OperandType s1) {
#ifdef DEBUG
    printf("%s %s %s ", __FUNCTION__, opcode_type_str[call], helper_str[h.h]); fflush(NULL);
#endif
    Instr1BH4S_ENV1 *i = (Instr1BH4S_ENV1 *)ptr;
    i->instr_type = SIZEXB;
    i->instr_type_ext = Instr1BH4S_ENV1_ext;
    i->helper = h.h;
    assert(noargs < 2);
    i->noargs = noargs;
    SET_SLOT(0);
    SET_SLOT(1);
    return sizeof(*i);
}

// INPUT-slot-bits, INPUT-effective-bits, OUTPUT-bits
const LLVMType opciosz[OPCODE_MAX][3] = {
    [addc1o_i32] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [addc1o_i64] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [addci_i32] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [addci_i64] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [addcio_i32] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [addcio_i64] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [addco_i32] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [addco_i64] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [subb1o_i32] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [subb1o_i64] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [subbi_i32] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [subbi_i64] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [subbio_i32] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [subbio_i64] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [subbo_i32] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [subbo_i64] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [abs_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [add_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [add_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [add_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [andc_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [andc_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [andc_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [and_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [and_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [and_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [bitsel_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [brcond_i32] = {LLVMInvalidType, LLVMInvalidType, LLVMInvalidType},
    [brcond_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [bswap16_i32] = {LLVMInt32, LLVMInt16, LLVMInt32},
    [bswap16_i64] = {LLVMInt64, LLVMInt16, LLVMInt64},
    [bswap32_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [bswap32_i64] = {LLVMInt64, LLVMInt32, LLVMInt64},
    [bswap64_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [clz_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [clz_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [cmpsel_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [cmp_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [ctpop_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [ctpop_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [ctz_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [ctz_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [deposit_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [deposit_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [divs2_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [divs2_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [divs_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [divs_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [divu2_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [divu2_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [divu_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [divu_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [dupm_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [dup_vec] = {LLVMInt64, LLVMInt64, LLVMVector16xi8},
    [eqv_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [eqv_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [eqv_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [ext_i32_i64] = {LLVMInt32, LLVMInt32, LLVMInt64},
    [extract2_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [extract2_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [extract_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [extract_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [extrh_i64_i32] = {LLVMInt64, LLVMInt64, LLVMInt32},
    [extrl_i64_i32] = {LLVMInt64, LLVMInt32, LLVMInt32},
    [extu_i32_i64] = {LLVMInt32, LLVMInt32, LLVMInt64},
    [ld16s_i32] = {LLVMInt16, LLVMInt16, LLVMInt32},
    [ld16s_i64] = {LLVMInt16, LLVMInt16, LLVMInt64},
    [ld16u_i32] = {LLVMInt16, LLVMInt16, LLVMInt32},
    [ld16u_i64] = {LLVMInt16, LLVMInt16, LLVMInt64},
    [ld32s_i64] = {LLVMInt32, LLVMInt32, LLVMInt64},
    [ld32u_i64] = {LLVMInt32, LLVMInt32, LLVMInt64},
    [ld8s_i32] = {LLVMInt8, LLVMInt8, LLVMInt32},
    [ld8s_i64] = {LLVMInt8, LLVMInt8, LLVMInt64},
    [ld8u_i32] = {LLVMInt8, LLVMInt8, LLVMInt32},
    [ld8u_i64] = {LLVMInt8, LLVMInt8, LLVMInt64},
    [ld_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [ld_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [ld_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [movcond_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [movcond_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [movcond_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [mov_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [mov_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [mov_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [mul_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [mul_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [muls2_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [muls2_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [mulsh_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [mulsh_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [mulu2_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [mulu2_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [muluh_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [muluh_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [mul_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [nand_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [nand_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [nand_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [neg_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [neg_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [negsetcond_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [negsetcond_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [neg_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [nor_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [nor_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [nor_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [not_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [not_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [not_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [orc_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [orc_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [orc_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [or_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [or_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [or_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [push_ret_addr] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [qemu_ld2_i128] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [qemu_ld_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [qemu_ld_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [qemu_st2_i128] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [qemu_st_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [qemu_st_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [rems_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [rems_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [remu_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [remu_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [ret] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [rotl_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [rotl_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [rotli_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [rotls_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [rotlv_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [rotr_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [rotr_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [rotrv_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [sar_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [sar_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [sari_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [sars_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [sarv_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [setcond_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [setcond_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [sextract_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [sextract_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [shl_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [shl_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [shli_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [shls_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [shlv_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [shr_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [shr_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [shri_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [shrs_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [shrv_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [smax_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [smin_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [ssadd_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [sssub_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [st16_i32] = {LLVMInt32, LLVMInt16, LLVMInt16},
    [st16_i64] = {LLVMInt64, LLVMInt16, LLVMInt16},
    [st32_i64] = {LLVMInt64, LLVMInt32, LLVMInt32},
    [st8_i32] = {LLVMInt32, LLVMInt8, LLVMInt8},
    [st8_i64] = {LLVMInt64, LLVMInt8, LLVMInt8},
    [st_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [st_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [st_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [sub_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [sub_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [sub_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [umax_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [umin_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [usadd_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [ussub_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [xor_i32] = {LLVMInt32, LLVMInt32, LLVMInt32},
    [xor_i64] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [xor_vec] = {LLVMVector16xi8, LLVMVector16xi8, LLVMVector16xi8},
    [call] = {LLVMInt64, LLVMInt64, LLVMInt64},
};

const uint8_t opcoc[OPCODE_MAX] = {
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

const int helper_compress_arg_cnt[HELPER_MAX] = {
    [helper_cc_compute_nz] = 3,
};

#define MAX_COMPRESSED_ARGS         3
const XRegType helper_compress_arg_expectations[HELPER_MAX][MAX_COMPRESSED_ARGS] = {
    [helper_cc_compute_nz] = {cc_dst, cc_src, cc_op},
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
};

// Make sure argument type matches, otherwise inline could not happen!
#define MAX_ADDED_ARGS              5
const LLVMType helper_arg_type[HELPER_MAX][MAX_ADDED_ARGS] = {
    [helper_jmp_ind] = {LLVMInt64, LLVMInt64, LLVMInt64},
    [helper_cc_compute_all] = {LLVMInt64},
    [helper_cc_compute_all_ADD1] = {LLVMInt64, LLVMInt32},
    [helper_cc_compute_all_ADD2] = {LLVMInt64, LLVMInt64, LLVMInt32},
    [helper_cc_compute_c] = {LLVMInt64},
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
};

const LLVMType helper_return_type[HELPER_MAX] = {
    [helper_cc_compute_all] = LLVMInt64,
    [helper_cc_compute_all_ADD1] = LLVMInt64,
    [helper_cc_compute_all_ADD2] = LLVMInt64,
    [helper_cc_compute_c] = LLVMInt64,
    [helper_cc_compute_nz] = LLVMInt64,
    [helper_movmskps_xmm] = LLVMInt32,
    [helper_movmskpd_xmm] = LLVMInt32,
    [helper_movmskps_ymm] = LLVMInt32,
    [helper_movmskpd_ymm] = LLVMInt32,
};

const uint64_t xreg_offsets[XREG_MAX] = {
    [rax] = 0x0,
    [rcx] = 0x8,
    [rdx] = 0x10,
    [rbx] = 0x18,
    [rsp] = 0x20,
    [rbp] = 0x28,
    [rsi] = 0x30,
    [rdi] = 0x38,
    [r8] = 0x40,
    [r9] = 0x48,
    [r10] = 0x50,
    [r11] = 0x58,
    [r12] = 0x60,
    [r13] = 0x68,
    [r14] = 0x70,
    [r15] = 0x78,
    [cc_src] = 0x98,
    [cc_dst] = 0x90,
    [cc_op] = 0xa8,
    [rip] = 0x80,
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

const char *ymm_str[NON_XMM] = {
    [xmm0] = "ymm0",
    [xmm1] = "ymm1",
    [xmm2] = "ymm2",
    [xmm3] = "ymm3",
    [xmm4] = "ymm4",
    [xmm5] = "ymm5",
    [xmm6] = "ymm6",
    [xmm7] = "ymm7",
    [xmm8] = "ymm8",
    [xmm9] = "ymm9",
    [xmm10] = "ymm10",
    [xmm11] = "ymm11",
    [xmm12] = "ymm12",
    [xmm13] = "ymm13",
    [xmm14] = "ymm14",
    [xmm15] = "ymm15",
};
