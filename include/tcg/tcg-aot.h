/*
 * Tiny Code Generator for QEMU
 *
 * Copyright (c) 2025 Fabrice Bellard
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#ifndef TCG_AOT_H
#define TCG_AOT_H

#define AOT_VADDR_FIXTO_GROUND  0x0000000000000001UL
#define DO_DUMP_RUNTIME_TRACE   1

// FIXME: data types need to match scenario
typedef struct {
    uint64_t flags;
    uint64_t vaddr;
    uint64_t tgt_insn_size;
    uint64_t tgt_insn_off;
    uint64_t aot_insn_size;
    uint64_t jmptbl_size;
    uint64_t stats_size;
    uint64_t tgt_elf_checksum;
} AotImageHdr;

typedef struct {
    uint32_t host_off;
    uint32_t adrp_delta; // FIXME: naming
    uint32_t reg;
} RIPPatchInfo;

typedef struct {
    uint32_t host_off;
    uint32_t host_size;
    uint32_t target_off;
    uint32_t target_size;
} InstrMapInfo;

typedef struct CodeFragment {
    uint64_t target_addr;
    uint64_t host_addr;
    struct CodeFragment *next;
} CodeFragment;

typedef struct helper_func {
  const char *name;
  uint64_t addr;
} helper_func_t;

typedef unsigned long __attribute__((__vector_size__(16))) v2long;

#endif /* TCG_AOT_H */
