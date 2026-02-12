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

#define AOT_LEVEL_0                 0
#define AOT_LEVEL_MAX               3
#define AOT_LEVEL                   AOT_LEVEL_0

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

typedef struct aot_range_info {
    uint64_t x_addr_range_begin;
    uint64_t x_addr_range_end;
    char elf_name[256];
    struct aot_range_info *next;
} aot_range_info_t;

#endif /* TCG_AOT_H */
