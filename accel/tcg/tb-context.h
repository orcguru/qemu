/*
 * Internal structs that QEMU exports to TCG
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

#ifndef QEMU_TB_CONTEXT_H
#define QEMU_TB_CONTEXT_H

#include "qemu/thread.h"
#include "qemu/qht.h"

#define CODE_GEN_HTABLE_BITS     15
#define CODE_GEN_HTABLE_SIZE     (1 << CODE_GEN_HTABLE_BITS)

typedef struct TBContext TBContext;

struct TBContext {

    struct qht htable;

    /* statistics */
    unsigned tb_flush_count;
    unsigned tb_phys_invalidate_count;

#ifdef AOT
    /*
     * hashtable for indirect branch lookup
     * - readers: AOT threads
     * - writers: helper_jit and cpu_exec_loop
     */
    gpointer        cur;       /* published GHashTable*; written only under wlock */
    gatomicrefcount readers;   /* 1 = permanent root ref; >1 = AOT readers in CS */
    GMutex          wlock;     /* serializes publish + retire + steal */
    GPtrArray      *retired;   /* unpublished snapshots awaiting grace period */
#endif
};

extern TBContext tb_ctx;

#endif
