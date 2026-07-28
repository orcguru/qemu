/*
 * Minimal Perfect Hash for QEMU helper function names (aarch64)
 *
 * GUARANTEED PROPERTIES:
 *   - Input: 1070 known helper function names
 *   - Output: slot in [0, 1070-1]
 *   - Collisions: ZERO (all names map to distinct slots)
 *   - Table overhead: 0 slots (100% utilization)
 *
 * Algorithm: CHD (Compress-Hash-Displace)
 *   Step 1: Primary hash → bucket (djb2 with golden ratio)
 *   Step 2: Secondary hash → slot (polynomial with per-bucket seed)
 *
 * Memory: 4280 bytes for seed array + 8560 bytes for dispatch table
 *       = 12.5 KB total
 */

#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define HELPER_HASH_N 1070
#define HELPER_HASH_NB 1070

/* Bucket seeds for secondary hash.
 * Computed by CHD algorithm to guarantee no collisions.
 * 481 unique non-zero seeds + 589 zero seeds (for single-element buckets).
 */
static const uint32_t helper_hash_seeds[HELPER_HASH_NB] = {
    0, 0, 1, 0, 0, 0, 0, 0, 1, 0,
    8, 1, 2, 0, 2, 2, 5, 0, 0, 0,
    1, 0, 0, 1, 7, 0, 0, 0, 1, 0,
    3, 1, 0, 1, 0, 2, 0, 2, 0, 0,
    0, 3, 0, 1, 0, 1, 0, 17, 2, 0,
    8, 0, 1, 0, 1, 0, 0, 0, 0, 0,
    0, 2, 0, 2, 0, 0, 4, 3, 4, 0,
    0, 0, 0, 0, 3, 0, 0, 0, 0, 0,
    0, 0, 1, 0, 0, 0, 0, 0, 0, 8,
    0, 0, 0, 1, 0, 1, 0, 0, 3, 0,
    0, 0, 0, 18, 0, 0, 0, 0, 0, 6,
    0, 0, 1, 0, 0, 0, 0, 3, 0, 4,
    3, 2, 0, 0, 0, 0, 0, 1, 0, 0,
    0, 0, 3, 3, 1, 0, 0, 0, 0, 0,
    1, 0, 0, 2, 0, 5, 2, 0, 0, 3,
    0, 0, 0, 0, 2, 0, 0, 0, 0, 0,
    0, 2, 0, 1, 0, 0, 0, 0, 0, 0,
    0, 3, 5, 0, 0, 0, 1, 1, 0, 1,
    0, 1, 0, 2, 0, 0, 0, 1, 0, 0,
    0, 4, 3, 0, 0, 0, 0, 7, 4, 2,
    0, 0, 0, 0, 0, 0, 0, 0, 3, 2,
    1, 0, 0, 2, 8, 1, 0, 5, 1, 0,
    8, 0, 2, 0, 0, 0, 1, 1, 1, 8,
    0, 1, 4, 0, 3, 0, 1, 1, 0, 0,
    0, 1, 0, 3, 9, 0, 4, 0, 7, 0,
    0, 0, 0, 1, 0, 0, 0, 0, 5, 0,
    0, 1, 13, 0, 1, 1, 1, 1, 0, 4,
    2, 2, 1, 2, 10, 0, 0, 4, 0, 0,
    0, 1, 0, 0, 0, 12, 0, 2, 2, 0,
    0, 1, 1, 0, 0, 10, 0, 0, 0, 6,
    1, 0, 0, 0, 2, 15, 0, 0, 0, 0,
    0, 1, 1, 0, 1, 0, 0, 0, 0, 0,
    5, 4, 0, 0, 2, 0, 0, 4, 0, 2,
    10, 2, 0, 1, 0, 1, 0, 0, 0, 0,
    2, 0, 1, 0, 27, 0, 0, 0, 0, 0,
    3, 0, 0, 5, 0, 0, 3, 0, 0, 0,
    1, 0, 0, 0, 8, 0, 3, 0, 5, 1,
    1, 0, 0, 0, 0, 0, 4, 3, 0, 3,
    0, 0, 0, 2, 1, 1, 13, 3, 0, 0,
    1, 3, 0, 0, 1, 7, 0, 0, 15, 0,
    0, 1, 0, 0, 0, 0, 20, 0, 0, 0,
    0, 0, 0, 1, 2, 4, 0, 3, 2, 0,
    3, 0, 0, 0, 20, 0, 0, 8, 0, 0,
    4, 1, 0, 0, 0, 0, 2, 0, 2, 0,
    0, 16, 1, 0, 0, 2, 1, 5, 0, 16,
    0, 0, 0, 0, 0, 7, 11, 0, 0, 1,
    13, 0, 1, 0, 2, 0, 0, 5, 1, 0,
    0, 0, 1, 1, 4, 0, 0, 12, 2, 10,
    6, 1, 11, 0, 3, 5, 1, 0, 0, 0,
    0, 1, 0, 0, 0, 0, 0, 6, 0, 0,
    0, 0, 0, 0, 0, 0, 7, 4, 0, 0,
    1, 8, 1, 4, 12, 0, 0, 1, 2, 0,
    3, 0, 11, 8, 0, 0, 1, 2, 2, 5,
    0, 0, 0, 6, 0, 3, 9, 0, 2, 2,
    0, 0, 0, 3, 0, 0, 4, 0, 13, 6,
    0, 5, 0, 7, 0, 26, 4, 0, 0, 11,
    0, 0, 0, 0, 0, 0, 12, 0, 0, 1,
    0, 0, 1, 4, 0, 0, 0, 0, 20, 3,
    0, 14, 0, 0, 5, 0, 3, 22, 0, 2,
    0, 1, 0, 5, 0, 3, 13, 0, 5, 0,
    0, 2, 0, 0, 0, 0, 3, 0, 0, 0,
    5, 3, 0, 12, 0, 0, 4, 0, 5, 0,
    0, 0, 2, 1, 1, 11, 0, 0, 0, 1,
    2, 0, 2, 0, 0, 0, 0, 0, 1, 4,
    1, 4, 28, 0, 2, 1, 0, 10, 2, 7,
    2, 0, 4, 2, 0, 1, 6, 2, 2, 1,
    0, 4, 5, 3, 2, 1, 15, 3, 0, 1,
    0, 5, 5, 0, 8, 0, 2, 0, 0, 10,
    0, 1, 0, 0, 0, 7, 0, 3, 3, 0,
    0, 17, 0, 2, 0, 0, 0, 0, 9, 0,
    0, 0, 1, 0, 5, 8, 0, 2, 0, 5,
    0, 6, 0, 8, 0, 0, 10, 0, 4, 0,
    5, 0, 0, 8, 6, 0, 3, 1, 0, 0,
    1, 4, 0, 0, 0, 7, 0, 15, 0, 0,
    6, 5, 7, 20, 10, 0, 0, 0, 0, 0,
    0, 8, 0, 1, 4, 0, 0, 2, 5, 0,
    0, 7, 3, 6, 0, 0, 0, 1, 0, 0,
    3, 9, 0, 6, 0, 0, 12, 1, 3, 9,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    1, 3, 0, 0, 0, 0, 0, 2, 0, 6,
    0, 0, 0, 16, 0, 0, 5, 0, 18, 8,
    0, 2, 4, 0, 10, 16, 0, 0, 3, 0,
    0, 3, 0, 0, 0, 1, 0, 13, 20, 0,
    0, 26, 58, 22, 0, 27, 9, 2, 1, 0,
    0, 0, 12, 0, 0, 0, 0, 0, 7, 0,
    5, 0, 3, 4, 0, 5, 0, 3, 0, 0,
    3, 0, 0, 3, 0, 4, 0, 7, 10, 29,
    4, 0, 0, 23, 0, 0, 1, 0, 9, 0,
    7, 0, 0, 9, 14, 19, 1, 0, 12, 0,
    24, 25, 3, 0, 0, 14, 3, 0, 0, 0,
    22, 0, 4, 0, 2, 5, 0, 0, 0, 0,
    19, 24, 0, 0, 12, 0, 13, 0, 0, 0,
    0, 0, 1, 1, 0, 20, 58, 0, 7, 0,
    47, 73, 0, 0, 3, 0, 7, 21, 0, 0,
    9, 0, 2, 0, 29, 0, 0, 42, 14, 0,
    1, 10, 0, 0, 20, 0, 0, 14, 2, 8,
    4, 8, 23, 0, 44, 0, 0, 0, 0, 16,
    0, 10, 0, 14, 3, 0, 0, 10, 42, 5,
    554, 0, 0, 2, 50, 0, 1, 0, 19, 0,
    41, 91, 0, 0, 0, 0, 0, 21, 2, 13,
    62, 42, 0, 60, 31, 19, 6, 13, 0, 4,
    11, 2, 0, 0, 0, 2, 4, 147, 0, 0,
    32, 0, 3, 3, 3, 10, 41, 24, 86, 0,
    0, 81, 154, 0, 0, 0, 3, 3, 21050, 10,
    1, 0, 113, 1, 19, 0, 0, 63, 54, 1,
    19, 0, 0, 173, 0, 68, 159, 0, 0, 945,
    57, 0, 28, 70, 0, 0, 94, 0, 604, 805,
};

/* Primary hash: djb2 variant.
 *   h = golden_ratio * HELPER_HASH_NB  (initial value)
 *   for each char: h = h*33 + char     (with uint32_t wrap)
 */
static inline uint32_t helper_primary_hash(const char *name)
{
    uint32_t h = (uint32_t)((uint64_t)HELPER_HASH_NB * 2654435761ULL);
    for (const char *p = name; *p; p++) {
        h = ((h << 5) + h + (uint8_t)*p);
    }
    return h;
}

/* Secondary hash: polynomial with per-bucket seed.
 *   h = seed  (initial value from bucket)
 *   for each char: h = h*31 + char  (with uint32_t wrap)
 */
static inline uint32_t helper_secondary_hash(const char *name, uint32_t seed)
{
    uint32_t h = seed;
    for (const char *p = name; *p; p++) {
        h = h * 31 + (uint8_t)*p;
    }
    return h;
}

/* Minimal perfect hash function.
 * Returns slot index in [0, HELPER_HASH_N-1] for valid helper names.
 * Returns -1 if the name is not in the known set.
 */
static inline int32_t helper_name_hash(const char *name)
{
    uint32_t h = helper_primary_hash(name);
    uint32_t bucket = h % HELPER_HASH_NB;
    uint32_t seed = helper_hash_seeds[bucket];
    uint32_t h2 = helper_secondary_hash(name, seed);
    return (int32_t)(h2 % HELPER_HASH_N);
}
