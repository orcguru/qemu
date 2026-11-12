/*
 * elf_add_helpermap.c -- append a .helpermap section to an AArch64/RISC-V64 ELF.
 *
 * Reproduces the .helpermap payload of aarch64_text_add_funcmap_rbtree.pl
 * (reconstruct_elf(), the block that builds $helpermap_data), but operates on
 * a real binary ELF file instead of a readelf-style text dump.
 *
 * Script semantics, exactly:
 *   foreach symbol in the symbol table, in increasing symbol-index order:
 *       if (symbol name is a key of QEMU's perfect helper hash)
 *           emit pack("VV", sym->index, helper_hash{sym->name});
 *   => array of 8-byte records { uint32 sym_index; uint32 helper_id; }
 *   No filtering on symbol type/binding; duplicates are emitted too.
 *   Section header: name ".helpermap", SHT_PROGBITS, SHF_ALLOC,
 *                   sh_addralign = 8, sh_entsize = 8, sh_link = sh_info = 0.
 *
 * The embedded kHelperHash[] is the exact %helper_hash from the script
 * (QEMU include/tcg/helper_hash.h): 1070 entries, IDs 0..1069.
 * Use --hash to override it with another Perl-style '"name" => ID,' list.
 *
 * How the output is built (all original bytes are preserved):
 *   - copy the whole input file,
 *   - append an extended copy of .shstrtab containing ".helpermap\0"
 *     (unless that exact string already exists; then its offset is reused),
 *   - append the .helpermap records (file offset aligned to 8),
 *   - append a fresh section-header table: old headers + the new one
 *     (aligned to 16, as the script does),
 *   - patch only e_shoff / e_shnum / e_shstrndx in the ELF header.
 * Program headers, segments, symbol tables and all existing section data
 * are left untouched. The old section-header table / .shstrtab simply
 * become unreferenced trailing bytes.
 *
 * ELF64 (ELFCLASS64) is required; both ELFDATA2LSB and ELFDATA2MSB are
 * handled. Extended section numbering (e_shnum == 0 / SHN_XINDEX) is kept.
 * Records are written in the input ELF's byte order by default (little for
 * normal aarch64/riscv64); --le forces little-endian for strict script parity.
 *
 * Build:
 *   gcc -O2 -Wall -Wextra -std=c11 -o elf_add_helpermap elf_add_helpermap.c
 *
 * Usage:
 *   elf_add_helpermap [options] input.elf
 *     -o FILE        output (default: <input>.helpermap.elf; may equal input)
 *     -v, --verbose  print every matched symbol: index, name, helper id
 *     --hash FILE    override helper hash ('"name" => ID,' lines)
 *     --no-alloc     clear SHF_ALLOC and sh_addr (useful for ET_EXEC/ET_DYN)
 *     --le           force little-endian records
 *     --force        add .helpermap even if one already exists
 *     -h, --help     show help
 *
 * Example:
 *   ./elf_add_helpermap -v -o tb.helpermap.o tb.o
 *   readelf -S -x .helpermap tb.helpermap.o
 *
 * Public domain / CC0. No external dependencies beyond the C library.
 */

#define _POSIX_C_SOURCE 200809L
#define _FILE_OFFSET_BITS 64

#include <ctype.h>
#include <errno.h>
#include <inttypes.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

/* ---- ELF constants (self-contained; no <elf.h> needed) ---- */
#define ELFCLASS64      2
#define ELFDATA2LSB     1
#define ELFDATA2MSB     2
#define EV_CURRENT      1
#define ET_REL          1
#define EM_AARCH64      183
#define EM_RISCV        243
#define SHT_NULL        0
#define SHT_PROGBITS    1
#define SHT_SYMTAB      2
#define SHT_STRTAB      3
#define SHT_NOBITS      8
#define SHT_DYNSYM      11
#define SHF_ALLOC       0x2
#define SHN_UNDEF       0
#define SHN_XINDEX      0xffff
#define SHN_LORESERVE   0xff00
#define EHDR64_SIZE     64
#define SHDR64_SIZE     64
#define SYM64_SIZE      24
#define HELPERMAP_NAME  ".helpermap"

static int g_be = 0;       /* input ELF byte order: 1 = big endian */
static int g_rec_be = 0;   /* byte order used for .helpermap records */

/* ---- byte-order aware raw access ---- */
static uint64_t rdn(const uint8_t *p, int n)
{
    uint64_t v = 0;
    if (g_be) { for (int i = 0; i < n; ++i) v = (v << 8) | p[i]; }
    else      { for (int i = n - 1; i >= 0; --i) v = (v << 8) | p[i]; }
    return v;
}
static void wrn(uint8_t *p, uint64_t v, int n, int be)
{
    if (be) { for (int i = n - 1; i >= 0; --i) { p[i] = (uint8_t)(v & 0xff); v >>= 8; } }
    else    { for (int i = 0; i < n; ++i)     { p[i] = (uint8_t)(v & 0xff); v >>= 8; } }
}
#define rd16(p) ((uint16_t)rdn((p), 2))
#define rd32(p) ((uint32_t)rdn((p), 4))
#define rd64(p) ((uint64_t)rdn((p), 8))
#define wrf(p, v, n) wrn((p), (v), (n), g_be)      /* ELF structures */
#define wrr(p, v, n) wrn((p), (v), (n), g_rec_be)  /* helpermap records */

static uint64_t align_up(uint64_t v, uint64_t a) { return (v + a - 1) & ~(a - 1); }

static void die(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    fputs("elf_add_helpermap: ", stderr);
    vfprintf(stderr, fmt, ap);
    fputc('\n', stderr);
    va_end(ap);
    exit(1);
}
static void warn(const char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    fputs("elf_add_helpermap: warning: ", stderr);
    vfprintf(stderr, fmt, ap);
    fputc('\n', stderr);
    va_end(ap);
}

/* ---- decoded ELF64 structures ---- */
typedef struct {
    uint16_t e_type, e_machine, e_ehsize, e_phentsize, e_phnum, e_shentsize;
    uint16_t e_shnum, e_shstrndx;
    uint32_t e_version, e_flags;
    uint64_t e_entry, e_phoff, e_shoff;
} Ehdr;

typedef struct {
    uint32_t sh_name, sh_type, sh_link, sh_info;
    uint64_t sh_flags, sh_addr, sh_offset, sh_size, sh_addralign, sh_entsize;
} Shdr;

static void parse_ehdr(const uint8_t *b, Ehdr *e)
{
    e->e_type      = rd16(b + 0x10);
    e->e_machine   = rd16(b + 0x12);
    e->e_version   = rd32(b + 0x14);
    e->e_entry     = rd64(b + 0x18);
    e->e_phoff     = rd64(b + 0x20);
    e->e_shoff     = rd64(b + 0x28);
    e->e_flags     = rd32(b + 0x30);
    e->e_ehsize    = rd16(b + 0x34);
    e->e_phentsize = rd16(b + 0x36);
    e->e_phnum     = rd16(b + 0x38);
    e->e_shentsize = rd16(b + 0x3a);
    e->e_shnum     = rd16(b + 0x3c);
    e->e_shstrndx  = rd16(b + 0x3e);
}
static void parse_shdr(const uint8_t *p, Shdr *s)
{
    s->sh_name      = rd32(p + 0);
    s->sh_type      = rd32(p + 4);
    s->sh_flags     = rd64(p + 8);
    s->sh_addr      = rd64(p + 16);
    s->sh_offset    = rd64(p + 24);
    s->sh_size      = rd64(p + 32);
    s->sh_link      = rd32(p + 40);
    s->sh_info      = rd32(p + 44);
    s->sh_addralign = rd64(p + 48);
    s->sh_entsize   = rd64(p + 56);
}
static void emit_shdr(uint8_t *p, const Shdr *s)
{
    memset(p, 0, SHDR64_SIZE);
    wrf(p + 0,  s->sh_name,      4);
    wrf(p + 4,  s->sh_type,      4);
    wrf(p + 8,  s->sh_flags,     8);
    wrf(p + 16, s->sh_addr,      8);
    wrf(p + 24, s->sh_offset,    8);
    wrf(p + 32, s->sh_size,      8);
    wrf(p + 40, s->sh_link,      4);
    wrf(p + 44, s->sh_info,      4);
    wrf(p + 48, s->sh_addralign, 8);
    wrf(p + 56, s->sh_entsize,   8);
}

static int range_ok(uint64_t off, uint64_t len, size_t fsize)
{
    return off <= (uint64_t)fsize && len <= (uint64_t)fsize - off;
}
/* NUL-terminated string inside a string table; "" on any problem */
static const char *table_string(const uint8_t *tab, size_t tabsz, uint64_t off)
{
    if (off >= (uint64_t)tabsz) return "";
    const char *s = (const char *)tab + off;
    if (!memchr(s, '\0', tabsz - (size_t)off)) return "";
    return s;
}

/* ---- QEMU perfect helper hash ---- */
typedef struct { const char *name; uint32_t id; } HelperEntry;

static const HelperEntry kHelperHash[] = {
    {"helper_aaa", 999},
    {"helper_aad", 203},
    {"helper_aam", 212},
    {"helper_aas", 796},
    {"helper_addpd_xmm", 515},
    {"helper_addpd_ymm", 717},
    {"helper_addps_xmm", 933},
    {"helper_addps_ymm", 689},
    {"helper_addsd", 888},
    {"helper_addss", 92},
    {"helper_addsubpd_xmm", 382},
    {"helper_addsubpd_ymm", 1038},
    {"helper_addsubps_xmm", 33},
    {"helper_addsubps_ymm", 408},
    {"helper_aesdec_xmm", 39},
    {"helper_aesdec_ymm", 450},
    {"helper_aesdeclast_xmm", 916},
    {"helper_aesdeclast_ymm", 322},
    {"helper_aesenc_xmm", 719},
    {"helper_aesenc_ymm", 1005},
    {"helper_aesenclast_xmm", 305},
    {"helper_aesenclast_ymm", 196},
    {"helper_aesimc_xmm", 106},
    {"helper_aeskeygenassist_xmm", 670},
    {"helper_atomic_add_fetchb", 768},
    {"helper_atomic_add_fetchl_be", 891},
    {"helper_atomic_add_fetchl_le", 626},
    {"helper_atomic_add_fetchq_be", 46},
    {"helper_atomic_add_fetchq_le", 356},
    {"helper_atomic_add_fetchw_be", 102},
    {"helper_atomic_add_fetchw_le", 747},
    {"helper_atomic_and_fetchb", 912},
    {"helper_atomic_and_fetchl_be", 251},
    {"helper_atomic_and_fetchl_le", 561},
    {"helper_atomic_and_fetchq_be", 1051},
    {"helper_atomic_and_fetchq_le", 946},
    {"helper_atomic_and_fetchw_be", 692},
    {"helper_atomic_and_fetchw_le", 1002},
    {"helper_atomic_cmpxchgb", 26},
    {"helper_atomic_cmpxchgl_be", 338},
    {"helper_atomic_cmpxchgl_le", 85},
    {"helper_atomic_cmpxchgo_be", 394},
    {"helper_atomic_cmpxchgo_le", 704},
    {"helper_atomic_cmpxchgq_be", 507},
    {"helper_atomic_cmpxchgq_le", 705},
    {"helper_atomic_cmpxchgw_be", 112},
    {"helper_atomic_cmpxchgw_le", 366},
    {"helper_atomic_fetch_addb", 486},
    {"helper_atomic_fetch_addl_be", 867},
    {"helper_atomic_fetch_addl_le", 3},
    {"helper_atomic_fetch_addq_be", 653},
    {"helper_atomic_fetch_addq_le", 228},
    {"helper_atomic_fetch_addw_be", 78},
    {"helper_atomic_fetch_addw_le", 388},
    {"helper_atomic_fetch_andb", 619},
    {"helper_atomic_fetch_andl_be", 1037},
    {"helper_atomic_fetch_andl_le", 93},
    {"helper_atomic_fetch_andq_be", 168},
    {"helper_atomic_fetch_andq_le", 558},
    {"helper_atomic_fetch_andw_be", 743},
    {"helper_atomic_fetch_andw_le", 214},
    {"helper_atomic_fetch_orb", 320},
    {"helper_atomic_fetch_orl_be", 1057},
    {"helper_atomic_fetch_orl_le", 173},
    {"helper_atomic_fetch_orq_be", 147},
    {"helper_atomic_fetch_orq_le", 926},
    {"helper_atomic_fetch_orw_be", 268},
    {"helper_atomic_fetch_orw_le", 245},
    {"helper_atomic_fetch_smaxb", 401},
    {"helper_atomic_fetch_smaxl_be", 819},
    {"helper_atomic_fetch_smaxl_le", 560},
    {"helper_atomic_fetch_smaxq_be", 1044},
    {"helper_atomic_fetch_smaxq_le", 284},
    {"helper_atomic_fetch_smaxw_be", 30},
    {"helper_atomic_fetch_smaxw_le", 841},
    {"helper_atomic_fetch_sminb", 625},
    {"helper_atomic_fetch_sminl_be", 122},
    {"helper_atomic_fetch_sminl_le", 790},
    {"helper_atomic_fetch_sminq_be", 576},
    {"helper_atomic_fetch_sminq_le", 453},
    {"helper_atomic_fetch_sminw_be", 403},
    {"helper_atomic_fetch_sminw_le", 942},
    {"helper_atomic_fetch_umaxb", 396},
    {"helper_atomic_fetch_umaxl_be", 529},
    {"helper_atomic_fetch_umaxl_le", 882},
    {"helper_atomic_fetch_umaxq_be", 278},
    {"helper_atomic_fetch_umaxq_le", 588},
    {"helper_atomic_fetch_umaxw_be", 1039},
    {"helper_atomic_fetch_umaxw_le", 279},
    {"helper_atomic_fetch_uminb", 847},
    {"helper_atomic_fetch_uminl_be", 426},
    {"helper_atomic_fetch_uminl_le", 31},
    {"helper_atomic_fetch_uminq_be", 1016},
    {"helper_atomic_fetch_uminq_le", 256},
    {"helper_atomic_fetch_uminw_be", 70},
    {"helper_atomic_fetch_uminw_le", 434},
    {"helper_atomic_fetch_xorb", 844},
    {"helper_atomic_fetch_xorl_be", 971},
    {"helper_atomic_fetch_xorl_le", 371},
    {"helper_atomic_fetch_xorq_be", 286},
    {"helper_atomic_fetch_xorq_le", 21},
    {"helper_atomic_fetch_xorw_be", 342},
    {"helper_atomic_fetch_xorw_le", 572},
    {"helper_atomic_or_fetchb", 629},
    {"helper_atomic_or_fetchl_be", 1063},
    {"helper_atomic_or_fetchl_le", 303},
    {"helper_atomic_or_fetchq_be", 557},
    {"helper_atomic_or_fetchq_le", 266},
    {"helper_atomic_or_fetchw_be", 678},
    {"helper_atomic_or_fetchw_le", 923},
    {"helper_atomic_smax_fetchb", 45},
    {"helper_atomic_smax_fetchl_be", 291},
    {"helper_atomic_smax_fetchl_le", 805},
    {"helper_atomic_smax_fetchq_be", 405},
    {"helper_atomic_smax_fetchq_le", 715},
    {"helper_atomic_smax_fetchw_be", 894},
    {"helper_atomic_smax_fetchw_le", 839},
    {"helper_atomic_smin_fetchb", 693},
    {"helper_atomic_smin_fetchl_be", 149},
    {"helper_atomic_smin_fetchl_le", 459},
    {"helper_atomic_smin_fetchq_be", 127},
    {"helper_atomic_smin_fetchq_le", 208},
    {"helper_atomic_smin_fetchw_be", 183},
    {"helper_atomic_smin_fetchw_le", 493},
    {"helper_atomic_umax_fetchb", 623},
    {"helper_atomic_umax_fetchl_be", 193},
    {"helper_atomic_umax_fetchl_le", 503},
    {"helper_atomic_umax_fetchq_be", 418},
    {"helper_atomic_umax_fetchq_le", 177},
    {"helper_atomic_umax_fetchw_be", 109},
    {"helper_atomic_umax_fetchw_le", 462},
    {"helper_atomic_umin_fetchb", 708},
    {"helper_atomic_umin_fetchl_be", 51},
    {"helper_atomic_umin_fetchl_le", 361},
    {"helper_atomic_umin_fetchq_be", 276},
    {"helper_atomic_umin_fetchq_le", 221},
    {"helper_atomic_umin_fetchw_be", 833},
    {"helper_atomic_umin_fetchw_le", 73},
    {"helper_atomic_xchgb", 365},
    {"helper_atomic_xchgl_be", 673},
    {"helper_atomic_xchgl_le", 224},
    {"helper_atomic_xchgq_be", 139},
    {"helper_atomic_xchgq_le", 563},
    {"helper_atomic_xchgw_be", 817},
    {"helper_atomic_xchgw_le", 57},
    {"helper_atomic_xor_fetchb", 1047},
    {"helper_atomic_xor_fetchl_be", 80},
    {"helper_atomic_xor_fetchl_le", 781},
    {"helper_atomic_xor_fetchq_be", 880},
    {"helper_atomic_xor_fetchq_le", 40},
    {"helper_atomic_xor_fetchw_be", 856},
    {"helper_atomic_xor_fetchw_le", 87},
    {"helper_blendpd_xmm", 75},
    {"helper_blendpd_ymm", 985},
    {"helper_blendps_xmm", 517},
    {"helper_blendps_ymm", 510},
    {"helper_blendvpd_xmm", 409},
    {"helper_blendvpd_ymm", 1041},
    {"helper_blendvps_xmm", 191},
    {"helper_blendvps_ymm", 159},
    {"helper_bnd_jmp", 13},
    {"helper_bndck", 865},
    {"helper_bndldx32", 32},
    {"helper_bndldx64", 400},
    {"helper_bndstx32", 949},
    {"helper_bndstx64", 340},
    {"helper_boundl", 281},
    {"helper_boundw", 62},
    {"helper_cc_compute_all", 1028},
    {"helper_cc_compute_c", 185},
    {"helper_cc_compute_nz", 966},
    {"helper_clrsb_i32", 163},
    {"helper_clrsb_i64", 881},
    {"helper_clts", 752},
    {"helper_clz_i32", 373},
    {"helper_clz_i64", 685},
    {"helper_cmpeqpd_xmm", 641},
    {"helper_cmpeqpd_ymm", 532},
    {"helper_cmpeqps_xmm", 166},
    {"helper_cmpeqps_ymm", 6},
    {"helper_cmpeqsd", 1010},
    {"helper_cmpeqspd_xmm", 649},
    {"helper_cmpeqspd_ymm", 845},
    {"helper_cmpeqsps_xmm", 479},
    {"helper_cmpeqsps_ymm", 370},
    {"helper_cmpeqss", 1025},
    {"helper_cmpeqssd", 283},
    {"helper_cmpeqsss", 478},
    {"helper_cmpequpd_xmm", 601},
    {"helper_cmpequpd_ymm", 952},
    {"helper_cmpequps_xmm", 586},
    {"helper_cmpequps_ymm", 477},
    {"helper_cmpequsd", 884},
    {"helper_cmpequspd_xmm", 318},
    {"helper_cmpequspd_ymm", 209},
    {"helper_cmpequsps_xmm", 309},
    {"helper_cmpequsps_ymm", 804},
    {"helper_cmpequss", 375},
    {"helper_cmpequssd", 890},
    {"helper_cmpequsss", 11},
    {"helper_cmpfalsepd_xmm", 397},
    {"helper_cmpfalsepd_ymm", 544},
    {"helper_cmpfalseps_xmm", 992},
    {"helper_cmpfalseps_ymm", 701},
    {"helper_cmpfalsesd", 472},
    {"helper_cmpfalsespd_xmm", 64},
    {"helper_cmpfalsespd_ymm", 441},
    {"helper_cmpfalsesps_xmm", 659},
    {"helper_cmpfalsesps_ymm", 861},
    {"helper_cmpfalsess", 871},
    {"helper_cmpfalsessd", 995},
    {"helper_cmpfalsesss", 483},
    {"helper_cmpgepd_xmm", 936},
    {"helper_cmpgepd_ymm", 810},
    {"helper_cmpgeps_xmm", 495},
    {"helper_cmpgeps_ymm", 352},
    {"helper_cmpgeqpd_xmm", 567},
    {"helper_cmpgeqpd_ymm", 134},
    {"helper_cmpgeqps_xmm", 552},
    {"helper_cmpgeqps_ymm", 288},
    {"helper_cmpgeqsd", 906},
    {"helper_cmpgeqss", 648},
    {"helper_cmpgesd", 829},
    {"helper_cmpgess", 627},
    {"helper_cmpgtpd_xmm", 824},
    {"helper_cmpgtpd_ymm", 834},
    {"helper_cmpgtps_xmm", 417},
    {"helper_cmpgtps_ymm", 223},
    {"helper_cmpgtqpd_xmm", 681},
    {"helper_cmpgtqpd_ymm", 267},
    {"helper_cmpgtqps_xmm", 666},
    {"helper_cmpgtqps_ymm", 252},
    {"helper_cmpgtqsd", 762},
    {"helper_cmpgtqss", 504},
    {"helper_cmpgtsd", 264},
    {"helper_cmpgtss", 360},
    {"helper_cmplepd_xmm", 991},
    {"helper_cmplepd_ymm", 695},
    {"helper_cmpleps_xmm", 703},
    {"helper_cmpleps_ymm", 645},
    {"helper_cmpleqpd_xmm", 630},
    {"helper_cmpleqpd_ymm", 37},
    {"helper_cmpleqps_xmm", 939},
    {"helper_cmpleqps_ymm", 346},
    {"helper_cmpleqsd", 915},
    {"helper_cmpleqss", 930},
    {"helper_cmplesd", 65},
    {"helper_cmpless", 718},
    {"helper_cmpltpd_xmm", 115},
    {"helper_cmpltpd_ymm", 1008},
    {"helper_cmpltps_xmm", 761},
    {"helper_cmpltps_ymm", 652},
    {"helper_cmpltqpd_xmm", 458},
    {"helper_cmpltqpd_ymm", 635},
    {"helper_cmpltqps_xmm", 574},
    {"helper_cmpltqps_ymm", 639},
    {"helper_cmpltqsd", 427},
    {"helper_cmpltqss", 786},
    {"helper_cmpltsd", 801},
    {"helper_cmpltss", 206},
    {"helper_cmpneqpd_xmm", 954},
    {"helper_cmpneqpd_ymm", 385},
    {"helper_cmpneqps_xmm", 324},
    {"helper_cmpneqps_ymm", 675},
    {"helper_cmpneqqpd_xmm", 60},
    {"helper_cmpneqqpd_ymm", 482},
    {"helper_cmpneqqps_xmm", 294},
    {"helper_cmpneqqps_ymm", 651},
    {"helper_cmpneqqsd", 391},
    {"helper_cmpneqqss", 406},
    {"helper_cmpneqsd", 613},
    {"helper_cmpneqss", 606},
    {"helper_cmpnequpd_xmm", 853},
    {"helper_cmpnequpd_ymm", 140},
    {"helper_cmpnequps_xmm", 982},
    {"helper_cmpnequps_ymm", 502},
    {"helper_cmpnequsd", 164},
    {"helper_cmpnequspd_xmm", 195},
    {"helper_cmpnequspd_ymm", 489},
    {"helper_cmpnequsps_xmm", 662},
    {"helper_cmpnequsps_ymm", 22},
    {"helper_cmpnequss", 146},
    {"helper_cmpnequssd", 227},
    {"helper_cmpnequsss", 969},
    {"helper_cmpngepd_xmm", 569},
    {"helper_cmpngepd_ymm", 155},
    {"helper_cmpngeps_xmm", 859},
    {"helper_cmpngeps_ymm", 440},
    {"helper_cmpngeqpd_xmm", 543},
    {"helper_cmpngeqpd_ymm", 380},
    {"helper_cmpngeqps_xmm", 14},
    {"helper_cmpngeqps_ymm", 975},
    {"helper_cmpngeqsd", 501},
    {"helper_cmpngeqss", 204},
    {"helper_cmpngesd", 218},
    {"helper_cmpngess", 779},
    {"helper_cmpngtpd_xmm", 271},
    {"helper_cmpngtpd_ymm", 162},
    {"helper_cmpngtps_xmm", 101},
    {"helper_cmpngtps_ymm", 1062},
    {"helper_cmpngtqpd_xmm", 531},
    {"helper_cmpngtqpd_ymm", 709},
    {"helper_cmpngtqps_xmm", 289},
    {"helper_cmpngtqps_ymm", 413},
    {"helper_cmpngtqsd", 864},
    {"helper_cmpngtqss", 432},
    {"helper_cmpngtsd", 996},
    {"helper_cmpngtss", 738},
    {"helper_cmpnlepd_xmm", 1012},
    {"helper_cmpnlepd_ymm", 753},
    {"helper_cmpnleps_xmm", 82},
    {"helper_cmpnleps_ymm", 1043},
    {"helper_cmpnleqpd_xmm", 272},
    {"helper_cmpnleqpd_ymm", 491},
    {"helper_cmpnleqps_xmm", 84},
    {"helper_cmpnleqps_ymm", 1013},
    {"helper_cmpnleqsd", 609},
    {"helper_cmpnleqss", 624},
    {"helper_cmpnlesd", 443},
    {"helper_cmpnless", 480},
    {"helper_cmpnltpd_xmm", 564},
    {"helper_cmpnltpd_ymm", 300},
    {"helper_cmpnltps_xmm", 699},
    {"helper_cmpnltps_ymm", 1050},
    {"helper_cmpnltqpd_xmm", 918},
    {"helper_cmpnltqpd_ymm", 809},
    {"helper_cmpnltqps_xmm", 909},
    {"helper_cmpnltqps_ymm", 800},
    {"helper_cmpnltqsd", 972},
    {"helper_cmpnltqss", 852},
    {"helper_cmpnltsd", 948},
    {"helper_cmpnltss", 188},
    {"helper_cmpordpd_xmm", 7},
    {"helper_cmpordpd_ymm", 663},
    {"helper_cmpordps_xmm", 602},
    {"helper_cmpordps_ymm", 207},
    {"helper_cmpordsd", 25},
    {"helper_cmpordspd_xmm", 875},
    {"helper_cmpordspd_ymm", 669},
    {"helper_cmpordsps_xmm", 167},
    {"helper_cmpordsps_ymm", 153},
    {"helper_cmpordss", 1001},
    {"helper_cmpordssd", 927},
    {"helper_cmpordsss", 568},
    {"helper_cmptruepd_xmm", 120},
    {"helper_cmptruepd_ymm", 1040},
    {"helper_cmptrueps_xmm", 577},
    {"helper_cmptrueps_ymm", 2},
    {"helper_cmptruesd", 818},
    {"helper_cmptruespd_xmm", 837},
    {"helper_cmptruespd_ymm", 1003},
    {"helper_cmptruesps_xmm", 637},
    {"helper_cmptruesps_ymm", 528},
    {"helper_cmptruess", 345},
    {"helper_cmptruessd", 1058},
    {"helper_cmptruesss", 376},
    {"helper_cmpunordpd_xmm", 868},
    {"helper_cmpunordpd_ymm", 421},
    {"helper_cmpunordps_xmm", 55},
    {"helper_cmpunordps_ymm", 870},
    {"helper_cmpunordsd", 592},
    {"helper_cmpunordspd_xmm", 895},
    {"helper_cmpunordspd_ymm", 27},
    {"helper_cmpunordsps_xmm", 420},
    {"helper_cmpunordsps_ymm", 38},
    {"helper_cmpunordss", 35},
    {"helper_cmpunordssd", 114},
    {"helper_cmpunordsss", 197},
    {"helper_comisd", 821},
    {"helper_comiss", 741},
    {"helper_cpuid", 1023},
    {"helper_cr4_testbit", 792},
    {"helper_crc32", 29},
    {"helper_ctpop_i32", 216},
    {"helper_ctpop_i64", 758},
    {"helper_ctz_i32", 81},
    {"helper_ctz_i64", 474},
    {"helper_cvtdq2pd_xmm", 343},
    {"helper_cvtdq2pd_ymm", 545},
    {"helper_cvtdq2ps_xmm", 328},
    {"helper_cvtdq2ps_ymm", 350},
    {"helper_cvtpd2dq_xmm", 1048},
    {"helper_cvtpd2dq_ymm", 0},
    {"helper_cvtpd2pi", 555},
    {"helper_cvtpd2ps_xmm", 832},
    {"helper_cvtpd2ps_ymm", 723},
    {"helper_cvtph2ps_xmm", 506},
    {"helper_cvtph2ps_ymm", 547},
    {"helper_cvtpi2pd", 49},
    {"helper_cvtpi2ps", 337},
    {"helper_cvtps2dq_xmm", 857},
    {"helper_cvtps2dq_ymm", 748},
    {"helper_cvtps2pd_xmm", 351},
    {"helper_cvtps2pd_ymm", 242},
    {"helper_cvtps2ph_xmm", 490},
    {"helper_cvtps2ph_ymm", 381},
    {"helper_cvtps2pi", 253},
    {"helper_cvtsd2si", 123},
    {"helper_cvtsd2sq", 263},
    {"helper_cvtsd2ss", 265},
    {"helper_cvtsi2sd", 1021},
    {"helper_cvtsi2ss", 1036},
    {"helper_cvtsq2sd", 100},
    {"helper_cvtsq2ss", 754},
    {"helper_cvtss2sd", 919},
    {"helper_cvtss2si", 133},
    {"helper_cvtss2sq", 938},
    {"helper_cvttpd2dq_xmm", 774},
    {"helper_cvttpd2dq_ymm", 665},
    {"helper_cvttpd2pi", 858},
    {"helper_cvttps2dq_xmm", 583},
    {"helper_cvttps2dq_ymm", 103},
    {"helper_cvttps2pi", 775},
    {"helper_cvttsd2si", 526},
    {"helper_cvttsd2sq", 399},
    {"helper_cvttss2si", 983},
    {"helper_cvttss2sq", 4},
    {"helper_daa", 1065},
    {"helper_das", 961},
    {"helper_div_i32", 275},
    {"helper_div_i64", 562},
    {"helper_divb_AL", 1020},
    {"helper_divl_EAX", 311},
    {"helper_divpd_xmm", 986},
    {"helper_divpd_ymm", 430},
    {"helper_divps_xmm", 334},
    {"helper_divps_ymm", 589},
    {"helper_divq_EAX", 249},
    {"helper_divsd", 825},
    {"helper_divss", 921},
    {"helper_divu_i32", 124},
    {"helper_divu_i64", 650},
    {"helper_divw_AX", 910},
    {"helper_dppd_xmm", 530},
    {"helper_dpps_xmm", 579},
    {"helper_dpps_ymm", 126},
    {"helper_dump_load", 714},
    {"helper_dump_registers", 633},
    {"helper_dump_store", 219},
    {"helper_emms", 989},
    {"helper_enter_mmx", 393},
    {"helper_exit_atomic", 765},
    {"helper_extrq_i", 525},
    {"helper_extrq_r", 317},
    {"helper_f2xm1", 257},
    {"helper_fabs_ST0", 42},
    {"helper_fadd_ST0_FT0", 782},
    {"helper_fadd_STN_ST0", 1015},
    {"helper_fbld_ST0", 716},
    {"helper_fbst_ST0", 17},
    {"helper_fchs_ST0", 519},
    {"helper_fclex", 597},
    {"helper_fcom_ST0_FT0", 953},
    {"helper_fcomi_ST0_FT0", 540},
    {"helper_fcos", 962},
    {"helper_fdecstp", 96},
    {"helper_fdiv_ST0_FT0", 235},
    {"helper_fdiv_STN_ST0", 8},
    {"helper_fdivr_ST0_FT0", 117},
    {"helper_fdivr_STN_ST0", 960},
    {"helper_ffree_STN", 199},
    {"helper_fildl_FT0", 398},
    {"helper_fildl_ST0", 186},
    {"helper_fildll_ST0", 358},
    {"helper_fincstp", 963},
    {"helper_fist_ST0", 903},
    {"helper_fistl_ST0", 237},
    {"helper_fistll_ST0", 965},
    {"helper_fistt_ST0", 679},
    {"helper_fisttl_ST0", 330},
    {"helper_fisttll_ST0", 929},
    {"helper_fld1_ST0", 784},
    {"helper_fldcw", 955},
    {"helper_fldenv", 536},
    {"helper_fldl2e_ST0", 362},
    {"helper_fldl2t_ST0", 407},
    {"helper_fldl_FT0", 190},
    {"helper_fldl_ST0", 913},
    {"helper_fldlg2_ST0", 908},
    {"helper_fldln2_ST0", 1},
    {"helper_fldpi_ST0", 520},
    {"helper_flds_FT0", 967},
    {"helper_flds_ST0", 369},
    {"helper_fldt_ST0", 731},
    {"helper_fldz_FT0", 696},
    {"helper_fldz_ST0", 327},
    {"helper_fma4pd_xmm", 307},
    {"helper_fma4pd_ymm", 541},
    {"helper_fma4ps_xmm", 175},
    {"helper_fma4ps_ymm", 66},
    {"helper_fma4sd", 862},
    {"helper_fma4ss", 877},
    {"helper_fmov_FT0_STN", 836},
    {"helper_fmov_ST0_FT0", 759},
    {"helper_fmov_ST0_STN", 736},
    {"helper_fmov_STN_ST0", 521},
    {"helper_fmul_ST0_FT0", 94},
    {"helper_fmul_STN_ST0", 937},
    {"helper_fninit", 820},
    {"helper_fnstcw", 108},
    {"helper_fnstsw", 1024},
    {"helper_fpatan", 91},
    {"helper_fpop", 494},
    {"helper_fprem", 674},
    {"helper_fprem1", 979},
    {"helper_fptan", 157},
    {"helper_fpush", 600},
    {"helper_frndint", 883},
    {"helper_frstor", 499},
    {"helper_fsave", 751},
    {"helper_fscale", 620},
    {"helper_fsin", 1049},
    {"helper_fsincos", 392},
    {"helper_fsqrt", 63},
    {"helper_fstenv", 99},
    {"helper_fstl_ST0", 608},
    {"helper_fsts_ST0", 671},
    {"helper_fstt_ST0", 667},
    {"helper_fsub_ST0_FT0", 1054},
    {"helper_fsub_STN_ST0", 827},
    {"helper_fsubr_ST0_FT0", 683},
    {"helper_fsubr_STN_ST0", 594},
    {"helper_fucom_ST0_FT0", 464},
    {"helper_fucomi_ST0_FT0", 24},
    {"helper_fwait", 215},
    {"helper_fxam_ST0", 435},
    {"helper_fxchg_ST0_STN", 1029},
    {"helper_fxrstor", 755},
    {"helper_fxsave", 325},
    {"helper_fxtract", 707},
    {"helper_fyl2x", 201},
    {"helper_fyl2xp1", 297},
    {"helper_gvec_abs16", 1030},
    {"helper_gvec_abs32", 682},
    {"helper_gvec_abs64", 1006},
    {"helper_gvec_abs8", 313},
    {"helper_gvec_add16", 851},
    {"helper_gvec_add32", 141},
    {"helper_gvec_add64", 1004},
    {"helper_gvec_add8", 700},
    {"helper_gvec_adds16", 539},
    {"helper_gvec_adds32", 835},
    {"helper_gvec_adds64", 471},
    {"helper_gvec_adds8", 1061},
    {"helper_gvec_and", 814},
    {"helper_gvec_andc", 411},
    {"helper_gvec_andcs", 56},
    {"helper_gvec_ands", 739},
    {"helper_gvec_bitsel", 457},
    {"helper_gvec_dup16", 116},
    {"helper_gvec_dup32", 230},
    {"helper_gvec_dup64", 1052},
    {"helper_gvec_dup8", 987},
    {"helper_gvec_eq16", 234},
    {"helper_gvec_eq32", 292},
    {"helper_gvec_eq64", 698},
    {"helper_gvec_eq8", 607},
    {"helper_gvec_eqs16", 632},
    {"helper_gvec_eqs32", 690},
    {"helper_gvec_eqs64", 58},
    {"helper_gvec_eqs8", 142},
    {"helper_gvec_eqv", 898},
    {"helper_gvec_le16", 47},
    {"helper_gvec_le32", 863},
    {"helper_gvec_le64", 512},
    {"helper_gvec_le8", 771},
    {"helper_gvec_les16", 799},
    {"helper_gvec_les32", 628},
    {"helper_gvec_les64", 941},
    {"helper_gvec_les8", 90},
    {"helper_gvec_leu16", 456},
    {"helper_gvec_leu32", 67},
    {"helper_gvec_leu64", 59},
    {"helper_gvec_leu8", 152},
    {"helper_gvec_leus16", 437},
    {"helper_gvec_leus32", 614},
    {"helper_gvec_leus64", 368},
    {"helper_gvec_leus8", 644},
    {"helper_gvec_lt16", 105},
    {"helper_gvec_lt32", 922},
    {"helper_gvec_lt64", 1017},
    {"helper_gvec_lt8", 548},
    {"helper_gvec_lts16", 559},
    {"helper_gvec_lts32", 233},
    {"helper_gvec_lts64", 712},
    {"helper_gvec_lts8", 907},
    {"helper_gvec_ltu16", 341},
    {"helper_gvec_ltu32", 742},
    {"helper_gvec_ltu64", 110},
    {"helper_gvec_ltu8", 169},
    {"helper_gvec_ltus16", 726},
    {"helper_gvec_ltus32", 580},
    {"helper_gvec_ltus64", 232},
    {"helper_gvec_ltus8", 935},
    {"helper_gvec_mov", 783},
    {"helper_gvec_mul16", 578},
    {"helper_gvec_mul32", 595},
    {"helper_gvec_mul64", 181},
    {"helper_gvec_mul8", 277},
    {"helper_gvec_muls16", 687},
    {"helper_gvec_muls32", 932},
    {"helper_gvec_muls64", 925},
    {"helper_gvec_muls8", 367},
    {"helper_gvec_nand", 565},
    {"helper_gvec_ne16", 332},
    {"helper_gvec_ne32", 442},
    {"helper_gvec_ne64", 174},
    {"helper_gvec_ne8", 848},
    {"helper_gvec_neg16", 905},
    {"helper_gvec_neg32", 402},
    {"helper_gvec_neg64", 840},
    {"helper_gvec_neg8", 315},
    {"helper_gvec_nor", 304},
    {"helper_gvec_not", 672},
    {"helper_gvec_or", 466},
    {"helper_gvec_orc", 273},
    {"helper_gvec_ors", 497},
    {"helper_gvec_rotl16i", 777},
    {"helper_gvec_rotl16v", 306},
    {"helper_gvec_rotl32i", 1045},
    {"helper_gvec_rotl32v", 598},
    {"helper_gvec_rotl64i", 475},
    {"helper_gvec_rotl64v", 446},
    {"helper_gvec_rotl8i", 1042},
    {"helper_gvec_rotl8v", 1055},
    {"helper_gvec_rotr16v", 846},
    {"helper_gvec_rotr32v", 44},
    {"helper_gvec_rotr64v", 239},
    {"helper_gvec_rotr8v", 452},
    {"helper_gvec_sar16i", 974},
    {"helper_gvec_sar16v", 19},
    {"helper_gvec_sar32i", 734},
    {"helper_gvec_sar32v", 798},
    {"helper_gvec_sar64i", 469},
    {"helper_gvec_sar64v", 431},
    {"helper_gvec_sar8i", 260},
    {"helper_gvec_sar8v", 1000},
    {"helper_gvec_shl16i", 727},
    {"helper_gvec_shl16v", 740},
    {"helper_gvec_shl32i", 436},
    {"helper_gvec_shl32v", 449},
    {"helper_gvec_shl64i", 171},
    {"helper_gvec_shl64v", 184},
    {"helper_gvec_shl8i", 842},
    {"helper_gvec_shl8v", 128},
    {"helper_gvec_shr16i", 732},
    {"helper_gvec_shr16v", 745},
    {"helper_gvec_shr32i", 390},
    {"helper_gvec_shr32v", 505},
    {"helper_gvec_shr64i", 617},
    {"helper_gvec_shr64v", 189},
    {"helper_gvec_shr8i", 874},
    {"helper_gvec_shr8v", 887},
    {"helper_gvec_smax16", 546},
    {"helper_gvec_smax32", 655},
    {"helper_gvec_smax64", 647},
    {"helper_gvec_smax8", 950},
    {"helper_gvec_smin16", 182},
    {"helper_gvec_smin32", 36},
    {"helper_gvec_smin64", 12},
    {"helper_gvec_smin8", 838},
    {"helper_gvec_ssadd16", 200},
    {"helper_gvec_ssadd32", 258},
    {"helper_gvec_ssadd64", 48},
    {"helper_gvec_ssadd8", 593},
    {"helper_gvec_sssub16", 763},
    {"helper_gvec_sssub32", 516},
    {"helper_gvec_sssub64", 461},
    {"helper_gvec_sssub8", 18},
    {"helper_gvec_sub16", 537},
    {"helper_gvec_sub32", 990},
    {"helper_gvec_sub64", 1033},
    {"helper_gvec_sub8", 23},
    {"helper_gvec_subs16", 791},
    {"helper_gvec_subs32", 849},
    {"helper_gvec_subs64", 179},
    {"helper_gvec_subs8", 445},
    {"helper_gvec_umax16", 1059},
    {"helper_gvec_umax32", 998},
    {"helper_gvec_umax64", 940},
    {"helper_gvec_umax8", 143},
    {"helper_gvec_umin16", 797},
    {"helper_gvec_umin32", 634},
    {"helper_gvec_umin64", 746},
    {"helper_gvec_umin8", 1060},
    {"helper_gvec_usadd16", 476},
    {"helper_gvec_usadd32", 229},
    {"helper_gvec_usadd64", 934},
    {"helper_gvec_usadd8", 138},
    {"helper_gvec_ussub16", 889},
    {"helper_gvec_ussub32", 642},
    {"helper_gvec_ussub64", 737},
    {"helper_gvec_ussub8", 293},
    {"helper_gvec_xor", 492},
    {"helper_gvec_xors", 968},
    {"helper_haddpd_xmm", 333},
    {"helper_haddpd_ymm", 951},
    {"helper_haddps_xmm", 928},
    {"helper_haddps_ymm", 487},
    {"helper_hsubpd_xmm", 599},
    {"helper_hsubpd_ymm", 656},
    {"helper_hsubps_xmm", 290},
    {"helper_hsubps_ymm", 524},
    {"helper_icebp", 522},
    {"helper_idivb_AL", 349},
    {"helper_idivl_EAX", 89},
    {"helper_idivq_EAX", 551},
    {"helper_idivw_AX", 180},
    {"helper_insertq_i", 323},
    {"helper_insertq_r", 280},
    {"helper_into", 359},
    {"helper_iret_ind", 806},
    {"helper_iret_protected", 1011},
    {"helper_iret_real", 535},
    {"helper_jit", 556},
    {"helper_jmp_ind", 776},
    {"helper_lar", 88},
    {"helper_lcall_protected", 876},
    {"helper_lcall_real", 488},
    {"helper_ld_i128", 721},
    {"helper_ldmxcsr", 724},
    {"helper_ljmp_protected", 873},
    {"helper_lldt", 767},
    {"helper_load_seg", 631},
    {"helper_lookup_tb_ptr", 438},
    {"helper_lret_protected", 660},
    {"helper_lsl", 640},
    {"helper_ltr", 677},
    {"helper_maskmov_mmx", 766},
    {"helper_maskmov_xmm", 643},
    {"helper_maxpd_xmm", 811},
    {"helper_maxpd_ymm", 744},
    {"helper_maxps_xmm", 107},
    {"helper_maxps_ymm", 622},
    {"helper_maxsd", 994},
    {"helper_maxss", 386},
    {"helper_minpd_xmm", 770},
    {"helper_minpd_ymm", 661},
    {"helper_minps_xmm", 295},
    {"helper_minps_ymm", 944},
    {"helper_minsd", 285},
    {"helper_minss", 571},
    {"helper_movmskpd_xmm", 550},
    {"helper_movmskpd_ymm", 920},
    {"helper_movmskps_xmm", 1009},
    {"helper_movmskps_ymm", 750},
    {"helper_mpsadbw_xmm", 299},
    {"helper_mpsadbw_ymm", 241},
    {"helper_mulpd_xmm", 542},
    {"helper_mulpd_ymm", 69},
    {"helper_mulps_xmm", 773},
    {"helper_mulps_ymm", 664},
    {"helper_mulsd", 886},
    {"helper_mulsh_i64", 118},
    {"helper_mulss", 901},
    {"helper_muluh_i64", 1027},
    {"helper_nonatomic_cmpxchgo", 301},
    {"helper_packssdw_mmx", 904},
    {"helper_packssdw_xmm", 1069},
    {"helper_packssdw_ymm", 321},
    {"helper_packsswb_mmx", 822},
    {"helper_packsswb_xmm", 527},
    {"helper_packsswb_ymm", 878},
    {"helper_packusdw_xmm", 1068},
    {"helper_packusdw_ymm", 194},
    {"helper_packuswb_mmx", 187},
    {"helper_packuswb_xmm", 657},
    {"helper_packuswb_ymm", 243},
    {"helper_palignr_mmx", 697},
    {"helper_palignr_xmm", 591},
    {"helper_palignr_ymm", 448},
    {"helper_pause", 585},
    {"helper_pavgb_mmx", 997},
    {"helper_pavgb_xmm", 151},
    {"helper_pavgb_ymm", 1018},
    {"helper_pavgw_mmx", 970},
    {"helper_pavgw_xmm", 425},
    {"helper_pavgw_ymm", 98},
    {"helper_pblendvb_xmm", 308},
    {"helper_pblendvb_ymm", 945},
    {"helper_pblendw_xmm", 590},
    {"helper_pblendw_ymm", 158},
    {"helper_pclmulqdq_xmm", 428},
    {"helper_pclmulqdq_ymm", 86},
    {"helper_pcmpestri_xmm", 924},
    {"helper_pcmpestrm_xmm", 943},
    {"helper_pcmpistri_xmm", 513},
    {"helper_pcmpistrm_xmm", 957},
    {"helper_pdep", 711},
    {"helper_pext", 404},
    {"helper_pf2id", 596},
    {"helper_pf2iw", 778},
    {"helper_pfacc", 176},
    {"helper_pfadd", 113},
    {"helper_pfcmpeq", 161},
    {"helper_pfcmpge", 130},
    {"helper_pfcmpgt", 226},
    {"helper_pfmax", 980},
    {"helper_pfmin", 135},
    {"helper_pfmul", 410},
    {"helper_pfnacc", 566},
    {"helper_pfpnacc", 15},
    {"helper_pfrcp", 205},
    {"helper_pfrsqrt", 730},
    {"helper_pfsub", 816},
    {"helper_pfsubr", 735},
    {"helper_phaddd_mmx", 802},
    {"helper_phaddd_xmm", 869},
    {"helper_phaddd_ymm", 210},
    {"helper_phaddsw_mmx", 710},
    {"helper_phaddsw_xmm", 621},
    {"helper_phaddsw_ymm", 885},
    {"helper_phaddw_mmx", 978},
    {"helper_phaddw_xmm", 860},
    {"helper_phaddw_ymm", 729},
    {"helper_phminposuw_xmm", 395},
    {"helper_phsubd_mmx", 764},
    {"helper_phsubd_xmm", 156},
    {"helper_phsubd_ymm", 899},
    {"helper_phsubsw_mmx", 364},
    {"helper_phsubsw_xmm", 326},
    {"helper_phsubsw_ymm", 217},
    {"helper_phsubw_mmx", 733},
    {"helper_phsubw_xmm", 250},
    {"helper_phsubw_ymm", 484},
    {"helper_pi2fd", 511},
    {"helper_pi2fw", 259},
    {"helper_pmaddubsw_mmx", 353},
    {"helper_pmaddubsw_xmm", 213},
    {"helper_pmaddubsw_ymm", 104},
    {"helper_pmaddwd_mmx", 211},
    {"helper_pmaddwd_xmm", 71},
    {"helper_pmaddwd_ymm", 1032},
    {"helper_pmovdldup_xmm", 702},
    {"helper_pmovdldup_ymm", 826},
    {"helper_pmovshdup_xmm", 1022},
    {"helper_pmovshdup_ymm", 76},
    {"helper_pmovsldup_xmm", 793},
    {"helper_pmovsldup_ymm", 684},
    {"helper_pmovsxbd_xmm", 61},
    {"helper_pmovsxbd_ymm", 538},
    {"helper_pmovsxbq_xmm", 584},
    {"helper_pmovsxbq_ymm", 780},
    {"helper_pmovsxbw_xmm", 335},
    {"helper_pmovsxbw_ymm", 638},
    {"helper_pmovsxdq_xmm", 131},
    {"helper_pmovsxdq_ymm", 787},
    {"helper_pmovsxwd_xmm", 172},
    {"helper_pmovsxwd_ymm", 523},
    {"helper_pmovsxwq_xmm", 240},
    {"helper_pmovsxwq_ymm", 896},
    {"helper_pmovzxbd_xmm", 658},
    {"helper_pmovzxbd_ymm", 549},
    {"helper_pmovzxbq_xmm", 1031},
    {"helper_pmovzxbq_ymm", 1053},
    {"helper_pmovzxbw_xmm", 148},
    {"helper_pmovzxbw_ymm", 518},
    {"helper_pmovzxdq_xmm", 728},
    {"helper_pmovzxdq_ymm", 314},
    {"helper_pmovzxwd_xmm", 769},
    {"helper_pmovzxwd_ymm", 355},
    {"helper_pmovzxwq_xmm", 72},
    {"helper_pmovzxwq_ymm", 573},
    {"helper_pmuldq_xmm", 760},
    {"helper_pmuldq_ymm", 1046},
    {"helper_pmulhrsw_mmx", 68},
    {"helper_pmulhrsw_xmm", 843},
    {"helper_pmulhrsw_ymm", 429},
    {"helper_pmulhrw_mmx", 473},
    {"helper_pmulhuw_mmx", 79},
    {"helper_pmulhuw_xmm", 1026},
    {"helper_pmulhuw_ymm", 509},
    {"helper_pmulhw_mmx", 911},
    {"helper_pmulhw_xmm", 553},
    {"helper_pmulhw_ymm", 319},
    {"helper_pmuludq_mmx", 533},
    {"helper_pmuludq_xmm", 444},
    {"helper_pmuludq_ymm", 165},
    {"helper_psadbw_mmx", 43},
    {"helper_psadbw_xmm", 339},
    {"helper_psadbw_ymm", 344},
    {"helper_pshufb_mmx", 202},
    {"helper_pshufb_xmm", 789},
    {"helper_pshufb_ymm", 1064},
    {"helper_pshufd_xmm", 668},
    {"helper_pshufd_ymm", 902},
    {"helper_pshufhw_xmm", 357},
    {"helper_pshufhw_ymm", 248},
    {"helper_pshuflw_xmm", 160},
    {"helper_pshuflw_ymm", 1019},
    {"helper_pshufw_mmx", 50},
    {"helper_psignb_mmx", 713},
    {"helper_psignb_xmm", 53},
    {"helper_psignb_ymm", 1014},
    {"helper_psignd_mmx", 415},
    {"helper_psignd_xmm", 795},
    {"helper_psignd_ymm", 893},
    {"helper_psignw_mmx", 384},
    {"helper_psignw_xmm", 244},
    {"helper_psignw_ymm", 312},
    {"helper_pslld_mmx", 831},
    {"helper_pslld_xmm", 691},
    {"helper_pslld_ymm", 270},
    {"helper_pslldq_xmm", 1066},
    {"helper_pslldq_ymm", 603},
    {"helper_psllq_mmx", 310},
    {"helper_psllq_xmm", 170},
    {"helper_psllq_ymm", 508},
    {"helper_psllw_mmx", 976},
    {"helper_psllw_xmm", 348},
    {"helper_psllw_ymm", 686},
    {"helper_psrad_mmx", 636},
    {"helper_psrad_xmm", 496},
    {"helper_psrad_ymm", 387},
    {"helper_psraw_mmx", 605},
    {"helper_psraw_xmm", 465},
    {"helper_psraw_ymm", 803},
    {"helper_psrld_mmx", 414},
    {"helper_psrld_xmm", 897},
    {"helper_psrld_ymm", 788},
    {"helper_psrldq_xmm", 129},
    {"helper_psrldq_ymm", 83},
    {"helper_psrlq_mmx", 28},
    {"helper_psrlq_xmm", 917},
    {"helper_psrlq_ymm", 808},
    {"helper_psrlw_mmx", 694},
    {"helper_psrlw_xmm", 866},
    {"helper_psrlw_ymm", 757},
    {"helper_pswapd", 892},
    {"helper_ptest_xmm", 1034},
    {"helper_ptest_ymm", 302},
    {"helper_punpckhbw_mmx", 34},
    {"helper_punpckhbw_xmm", 964},
    {"helper_punpckhbw_ymm", 855},
    {"helper_punpckhdq_mmx", 900},
    {"helper_punpckhdq_xmm", 20},
    {"helper_punpckhdq_ymm", 144},
    {"helper_punpckhqdq_xmm", 77},
    {"helper_punpckhqdq_ymm", 198},
    {"helper_punpckhwd_mmx", 500},
    {"helper_punpckhwd_xmm", 222},
    {"helper_punpckhwd_ymm", 823},
    {"helper_punpcklbw_mmx", 914},
    {"helper_punpcklbw_xmm", 582},
    {"helper_punpcklbw_ymm", 389},
    {"helper_punpckldq_mmx", 646},
    {"helper_punpckldq_xmm", 378},
    {"helper_punpckldq_ymm", 269},
    {"helper_punpcklqdq_xmm", 612},
    {"helper_punpcklqdq_ymm", 119},
    {"helper_punpcklwd_mmx", 254},
    {"helper_punpcklwd_xmm", 347},
    {"helper_punpcklwd_ymm", 238},
    {"helper_raise_exception", 534},
    {"helper_raise_interrupt", 467},
    {"helper_rcpps_xmm", 451},
    {"helper_rcpps_ymm", 1007},
    {"helper_rcpss", 581},
    {"helper_rdpid", 981},
    {"helper_rdpkru", 931},
    {"helper_rdpmc", 481},
    {"helper_rdrand", 377},
    {"helper_rdtsc", 854},
    {"helper_read_eflags", 468},
    {"helper_rechecking_single_step", 154},
    {"helper_rem_i32", 828},
    {"helper_rem_i64", 463},
    {"helper_remu_i32", 52},
    {"helper_remu_i64", 54},
    {"helper_roundpd_xmm", 136},
    {"helper_roundpd_ymm", 10},
    {"helper_roundps_xmm", 680},
    {"helper_roundps_ymm", 554},
    {"helper_roundsd_xmm", 812},
    {"helper_roundss_xmm", 354},
    {"helper_rsqrtps_xmm", 794},
    {"helper_rsqrtps_ymm", 872},
    {"helper_rsqrtss", 5},
    {"helper_sar_i64", 225},
    {"helper_sha1msg1", 610},
    {"helper_sha1msg2", 611},
    {"helper_sha1nexte", 416},
    {"helper_sha1rnds4_f0", 422},
    {"helper_sha1rnds4_f1", 423},
    {"helper_sha1rnds4_f2", 879},
    {"helper_sha1rnds4_f3", 575},
    {"helper_sha256msg1", 830},
    {"helper_sha256msg2", 145},
    {"helper_sha256rnds2", 439},
    {"helper_shl_i64", 618},
    {"helper_shr_i64", 772},
    {"helper_shufpd_xmm", 470},
    {"helper_shufpd_ymm", 756},
    {"helper_shufps_xmm", 722},
    {"helper_shufps_ymm", 956},
    {"helper_single_step", 514},
    {"helper_sqrtpd_xmm", 192},
    {"helper_sqrtpd_ymm", 9},
    {"helper_sqrtps_xmm", 329},
    {"helper_sqrtps_ymm", 947},
    {"helper_sqrtsd", 460},
    {"helper_sqrtss", 570},
    {"helper_st_i128", 379},
    {"helper_subpd_xmm", 220},
    {"helper_subpd_ymm", 111},
    {"helper_subps_xmm", 815},
    {"helper_subps_ymm", 706},
    {"helper_subsd", 231},
    {"helper_subss", 246},
    {"helper_syscall", 316},
    {"helper_sysenter", 372},
    {"helper_sysexit", 298},
    {"helper_sysret", 654},
    {"helper_ucomisd", 813},
    {"helper_ucomiss", 137},
    {"helper_update_mxcsr", 455},
    {"helper_verr", 331},
    {"helper_verw", 454},
    {"helper_vpermd_ymm", 993},
    {"helper_vpermdq_ymm", 615},
    {"helper_vpermilpd_imm_xmm", 363},
    {"helper_vpermilpd_imm_ymm", 424},
    {"helper_vpermilpd_xmm", 383},
    {"helper_vpermilpd_ymm", 973},
    {"helper_vpermilps_imm_xmm", 97},
    {"helper_vpermilps_imm_ymm", 498},
    {"helper_vpermilps_xmm", 374},
    {"helper_vpermilps_ymm", 688},
    {"helper_vpermq_ymm", 296},
    {"helper_vpgatherdd_xmm", 125},
    {"helper_vpgatherdd_ymm", 16},
    {"helper_vpgatherdq_xmm", 95},
    {"helper_vpgatherdq_ymm", 1056},
    {"helper_vpgatherqd_xmm", 988},
    {"helper_vpgatherqd_ymm", 604},
    {"helper_vpgatherqq_xmm", 958},
    {"helper_vpgatherqq_ymm", 977},
    {"helper_vpmaskmovd_st_xmm", 1067},
    {"helper_vpmaskmovd_st_ymm", 41},
    {"helper_vpmaskmovd_xmm", 984},
    {"helper_vpmaskmovd_ymm", 336},
    {"helper_vpmaskmovq_st_xmm", 725},
    {"helper_vpmaskmovq_st_ymm", 616},
    {"helper_vpmaskmovq_xmm", 287},
    {"helper_vpmaskmovq_ymm", 178},
    {"helper_vpsllvd_xmm", 485},
    {"helper_vpsllvd_ymm", 274},
    {"helper_vpsllvq_xmm", 807},
    {"helper_vpsllvq_ymm", 749},
    {"helper_vpsravd_xmm", 74},
    {"helper_vpsravd_ymm", 1035},
    {"helper_vpsravq_xmm", 447},
    {"helper_vpsravq_ymm", 236},
    {"helper_vpsrlvd_xmm", 412},
    {"helper_vpsrlvd_ymm", 150},
    {"helper_vpsrlvq_xmm", 785},
    {"helper_vpsrlvq_ymm", 676},
    {"helper_vtestpd_xmm", 262},
    {"helper_vtestpd_ymm", 255},
    {"helper_vtestps_xmm", 959},
    {"helper_vtestps_ymm", 850},
    {"helper_write_eflags", 247},
    {"helper_wrpkru", 132},
    {"helper_xgetbv", 419},
    {"helper_xrstor", 282},
    {"helper_xsave", 433},
    {"helper_xsaveopt", 587},
    {"helper_xsetbv", 261},
    {"memset", 121},
};

static const HelperEntry *g_hash = kHelperHash;
static size_t g_hash_count = sizeof(kHelperHash) / sizeof(kHelperHash[0]);

static int cmp_key_entry(const void *key, const void *elem)
{
    return strcmp((const char *)key, ((const HelperEntry *)elem)->name);
}
static int cmp_entry_entry(const void *a, const void *b)
{
    return strcmp(((const HelperEntry *)a)->name, ((const HelperEntry *)b)->name);
}
static const HelperEntry *lookup_helper(const char *name)
{
    return (const HelperEntry *)bsearch(name, g_hash, g_hash_count,
                                        sizeof(HelperEntry), cmp_key_entry);
}

/* Optional override: parse lines containing  "name" => ID,  */
static void load_hash_file(const char *path)
{
    FILE *f = fopen(path, "r");
    if (!f) die("cannot open hash file '%s': %s", path, strerror(errno));
    HelperEntry *arr = NULL;
    size_t n = 0, cap = 0;
    char line[4096];
    while (fgets(line, sizeof line, f)) {
        char *q1 = strchr(line, '"');
        if (!q1) continue;
        char *q2 = strchr(q1 + 1, '"');
        if (!q2) continue;
        size_t len = (size_t)(q2 - (q1 + 1));
        char *arrow = strstr(q2 + 1, "=>");
        if (!arrow || len == 0) continue;
        char *p = arrow + 2;
        while (*p && isspace((unsigned char)*p)) ++p;
        if (!isdigit((unsigned char)*p)) continue;
        errno = 0;
        char *end = NULL;
        unsigned long v = strtoul(p, &end, 10);
        if (end == p || errno || v > 0xffffffffUL) continue;
        if (n == cap) {
            cap = cap ? cap * 2 : 256;
            HelperEntry *t = (HelperEntry *)realloc(arr, cap * sizeof(*arr));
            if (!t) die("out of memory");
            arr = t;
        }
        char *name = (char *)malloc(len + 1);
        if (!name) die("out of memory");
        memcpy(name, q1 + 1, len);
        name[len] = '\0';
        arr[n].name = name;
        arr[n].id = (uint32_t)v;
        ++n;
    }
    fclose(f);
    if (n == 0) die("hash file '%s' contains no \"name\" => ID entries", path);
    qsort(arr, n, sizeof(*arr), cmp_entry_entry);
    for (size_t i = 1; i < n; ++i) {
        if (!strcmp(arr[i - 1].name, arr[i].name) && arr[i - 1].id != arr[i].id)
            warn("hash file has conflicting IDs for '%s'", arr[i].name);
    }
    g_hash = arr;
    g_hash_count = n;
}

/* ---- .helpermap records ---- */
typedef struct { uint32_t sym_index; uint32_t helper_id; const char *name; } Record;

static void push_record(Record **recs, size_t *n, size_t *cap, Record r)
{
    if (*n == *cap) {
        *cap = *cap ? *cap * 2 : 128;
        Record *t = (Record *)realloc(*recs, *cap * sizeof(**recs));
        if (!t) die("out of memory");
        *recs = t;
    }
    (*recs)[(*n)++] = r;
}

/* Scan symbol tables of the requested type; returns number of tables seen. */
static uint64_t collect(uint32_t want_type, const uint8_t *buf, size_t fsize,
                        const Shdr *sh, uint64_t shnum,
                        Record **recs, size_t *nrec, size_t *cap, int verbose)
{
    uint64_t tables = 0;
    for (uint64_t i = 0; i < shnum; ++i) {
        const Shdr *st = &sh[i];
        if (st->sh_type != want_type) continue;
        ++tables;
        if (!range_ok(st->sh_offset, st->sh_size, fsize)) {
            warn("symbol table at section %" PRIu64 " is out of file bounds", i);
            continue;
        }
        if (st->sh_link >= shnum) {
            warn("symbol table at section %" PRIu64 " has bad sh_link", i);
            continue;
        }
        const Shdr *str = &sh[st->sh_link];
        if (!range_ok(str->sh_offset, str->sh_size, fsize)) {
            warn("string table for section %" PRIu64 " is out of file bounds", i);
            continue;
        }
        uint64_t entsize = st->sh_entsize ? st->sh_entsize : SYM64_SIZE;
        if (entsize < SYM64_SIZE) {
            warn("symbol table at section %" PRIu64 " has sh_entsize < 24", i);
            continue;
        }
        uint64_t nsyms = st->sh_size / entsize;
        const uint8_t *strp = buf + str->sh_offset;
        size_t strsz = (size_t)str->sh_size;
        for (uint64_t j = 0; j < nsyms; ++j) {
            const uint8_t *sym = buf + st->sh_offset + j * entsize;
            uint32_t st_name = rd32(sym);          /* Elf64_Sym.st_name */
            const char *name = table_string(strp, strsz, st_name);
            if (!*name) continue;                   /* index 0 / bad names */
            const HelperEntry *he = lookup_helper(name);
            if (!he) continue;
            Record r = { (uint32_t)j, he->id, name };
            push_record(recs, nrec, cap, r);
            if (verbose)
                printf("  [%6" PRIu64 "] %-48s -> helper id %u\n", j, name, he->id);
        }
    }
    return tables;
}

static uint8_t *read_file(const char *path, size_t *size)
{
    FILE *f = fopen(path, "rb");
    if (!f) die("cannot open '%s': %s", path, strerror(errno));
    if (fseek(f, 0, SEEK_END) != 0) die("cannot seek '%s'", path);
    long sz = ftell(f);
    if (sz < 0) die("cannot determine size of '%s'", path);
    rewind(f);
    uint8_t *b = (uint8_t *)malloc((size_t)sz ? (size_t)sz : 1);
    if (!b) die("out of memory");
    if (sz > 0 && fread(b, 1, (size_t)sz, f) != (size_t)sz)
        die("short read on '%s'", path);
    fclose(f);
    *size = (size_t)sz;
    return b;
}

static void usage(FILE *f)
{
    fputs(
        "Usage: elf_add_helpermap [options] input.elf\n"
        "  -o FILE        output ELF (default: <input>.helpermap.elf)\n"
        "  -v, --verbose  list matched symbols\n"
        "  --hash FILE    override helper hash ('\"name\" => ID,' lines)\n"
        "  --no-alloc     clear SHF_ALLOC and sh_addr\n"
        "  --le           force little-endian .helpermap records\n"
        "  --force        add .helpermap even if one already exists\n"
        "  -h, --help     show this help\n", f);
}

int main(int argc, char **argv)
{
    const char *in_path = NULL, *out_path = NULL, *hash_path = NULL;
    int verbose = 0, use_alloc = 1, force_le = 0, force = 0;

    for (int i = 1; i < argc; ++i) {
        const char *a = argv[i];
        if (!strcmp(a, "-h") || !strcmp(a, "--help")) { usage(stdout); return 0; }
        else if (!strcmp(a, "-o")) {
            if (i + 1 >= argc) die("-o needs a file name");
            out_path = argv[++i];
        }
        else if (!strncmp(a, "--output=", 9)) out_path = a + 9;
        else if (!strcmp(a, "-v") || !strcmp(a, "--verbose")) verbose = 1;
        else if (!strcmp(a, "--no-alloc")) use_alloc = 0;
        else if (!strcmp(a, "--le")) force_le = 1;
        else if (!strcmp(a, "--force")) force = 1;
        else if (!strcmp(a, "--hash")) {
            if (i + 1 >= argc) die("--hash needs a file name");
            hash_path = argv[++i];
        }
        else if (!strncmp(a, "--hash=", 7)) hash_path = a + 7;
        else if (a[0] == '-') { fprintf(stderr, "unknown option: %s\n", a); usage(stderr); return 1; }
        else {
            if (in_path) die("more than one input file given");
            in_path = a;
        }
    }
    if (!in_path) { usage(stderr); return 1; }
    if (hash_path) load_hash_file(hash_path);
    if (!out_path) {
        size_t l = strlen(in_path);
        char *p = (char *)malloc(l + 16);
        if (!p) die("out of memory");
        memcpy(p, in_path, l);
        memcpy(p + l, ".helpermap.elf", 15);
        out_path = p;
    }

    size_t fsize = 0;
    uint8_t *buf = read_file(in_path, &fsize);
    if (fsize < EHDR64_SIZE) die("'%s' is too small to be an ELF64 file", in_path);
    if (buf[0] != 0x7f || buf[1] != 'E' || buf[2] != 'L' || buf[3] != 'F')
        die("'%s' is not an ELF file", in_path);
    if (buf[4] != ELFCLASS64) die("only ELF64 is supported (aarch64 / riscv64)");
    if (buf[5] == ELFDATA2LSB) g_be = 0;
    else if (buf[5] == ELFDATA2MSB) g_be = 1;
    else die("unknown ELF data encoding %u", buf[5]);
    g_rec_be = force_le ? 0 : g_be;
    if (buf[6] != EV_CURRENT) die("unsupported ELF ident version %u", buf[6]);

    Ehdr eh;
    parse_ehdr(buf, &eh);
    if (eh.e_machine != EM_AARCH64 && eh.e_machine != EM_RISCV)
        warn("e_machine=%u is neither EM_AARCH64(183) nor EM_RISCV(243); continuing",
             eh.e_machine);
    if (eh.e_shentsize != SHDR64_SIZE)
        die("e_shentsize=%u, expected 64", eh.e_shentsize);
    if (eh.e_shoff == 0) die("input has no section header table");
    if (eh.e_shoff > (uint64_t)fsize ||
        (uint64_t)fsize - eh.e_shoff < SHDR64_SIZE)
        die("section header table lies outside the file");

    uint64_t shnum = eh.e_shnum;
    if (shnum == 0)   /* extended: real count in sh_size of section header 0 */
        shnum = rd64(buf + eh.e_shoff + 32);
    if (shnum < 1 || shnum > ((uint64_t)fsize - eh.e_shoff) / SHDR64_SIZE)
        die("implausible section count %" PRIu64, shnum);

    Shdr *sh = (Shdr *)calloc((size_t)shnum, sizeof(*sh));
    if (!sh) die("out of memory");
    for (uint64_t i = 0; i < shnum; ++i)
        parse_shdr(buf + eh.e_shoff + i * SHDR64_SIZE, &sh[i]);

    uint64_t shstrndx = eh.e_shstrndx;
    if (shstrndx == SHN_XINDEX)              /* extended: sh_link of SHN_UNDEF */
        shstrndx = rd32(buf + eh.e_shoff + 40);
    if (shstrndx == SHN_UNDEF)
        die("input has no .shstrtab (e_shstrndx=0); cannot name the new section");
    if (shstrndx >= shnum) die("e_shstrndx %" PRIu64 " is out of range", shstrndx);
    if (sh[shstrndx].sh_type != SHT_STRTAB)
        warn("section %" PRIu64 " is used as .shstrtab but has type %u",
             shstrndx, sh[shstrndx].sh_type);
    if (!range_ok(sh[shstrndx].sh_offset, sh[shstrndx].sh_size, fsize))
        die(".shstrtab lies outside the file");

    const uint8_t *shstr = buf + sh[shstrndx].sh_offset;
    size_t shstr_sz = (size_t)sh[shstrndx].sh_size;

    /* Find an existing ".helpermap" string (exact, NUL-delimited). */
    uint64_t name_off = UINT64_MAX;
    for (size_t p = 0; p < shstr_sz; ) {
        size_t e = p;
        while (e < shstr_sz && shstr[e]) ++e;
        if (e - p == strlen(HELPERMAP_NAME) &&
            !memcmp(shstr + p, HELPERMAP_NAME, e - p)) { name_off = p; break; }
        if (e >= shstr_sz) break;
        p = e + 1;
    }
    if (!force) {
        for (uint64_t i = 0; i < shnum; ++i) {
            const char *nm = table_string(shstr, shstr_sz, sh[i].sh_name);
            if (!strcmp(nm, HELPERMAP_NAME))
                die("input already has a .helpermap section (use --force to add another)");
        }
    }

    /* ---- gather records ---- */
    Record *recs = NULL;
    size_t nrec = 0, cap = 0;
    uint64_t tables = collect(SHT_SYMTAB, buf, fsize, sh, shnum,
                              &recs, &nrec, &cap, verbose);
    if (tables == 0) {
        warn("no SHT_SYMTAB found; falling back to dynamic symbol tables");
        tables = collect(SHT_DYNSYM, buf, fsize, sh, shnum,
                         &recs, &nrec, &cap, verbose);
    }
    if (tables == 0)
        warn("no symbol table at all; .helpermap will be empty");

    size_t rec_bytes = nrec * 8;
    printf("matched %zu symbol%s -> %zu bytes of .helpermap data\n",
           nrec, nrec == 1 ? "" : "s", rec_bytes);

    /* ---- build the output ---- */
    int need_shstr = (name_off == UINT64_MAX);
    size_t new_shstr_sz = shstr_sz + (need_shstr ? strlen(HELPERMAP_NAME) + 1 : 0);
    if (need_shstr) {
        if (new_shstr_sz > 0xffffffffULL) die(".shstrtab would exceed 4 GiB");
        name_off = shstr_sz;
    }
    size_t extra = (need_shstr ? new_shstr_sz : 0) + 8 + rec_bytes
                 + 16 + (size_t)((shnum + 1) * SHDR64_SIZE) + 64;
    if ((uint64_t)fsize + extra > (uint64_t)SIZE_MAX)
        die("output would be too large");
    uint8_t *out = (uint8_t *)malloc((size_t)fsize + extra);
    if (!out) die("out of memory");
    memcpy(out, buf, fsize);
    size_t off = fsize;

    if (need_shstr) {
        size_t base = off;
        memcpy(out + off, shstr, shstr_sz);
        off += shstr_sz;
        memcpy(out + off, HELPERMAP_NAME, strlen(HELPERMAP_NAME) + 1);
        off += strlen(HELPERMAP_NAME) + 1;
        sh[shstrndx].sh_offset = base;
        sh[shstrndx].sh_size = new_shstr_sz;
    }

    size_t sec_off = (size_t)align_up(off, 8);
    if (sec_off > off) { memset(out + off, 0, sec_off - off); off = sec_off; }
    for (size_t i = 0; i < nrec; ++i) {
        wrr(out + off,     recs[i].sym_index, 4);
        wrr(out + off + 4, recs[i].helper_id, 4);
        off += 8;
    }

    /* sh_addr: just past the last allocated section, as the script intends. */
    uint64_t sh_addr = 0, max_end = 0;
    if (use_alloc) {
        for (uint64_t i = 0; i < shnum; ++i) {
            if ((sh[i].sh_flags & SHF_ALLOC) && sh[i].sh_addr != 0) {
                uint64_t end = sh[i].sh_addr + sh[i].sh_size;
                if (end > max_end) max_end = end;
            }
        }
        sh_addr = align_up(max_end, 8);
    }

    Shdr ns;
    memset(&ns, 0, sizeof ns);
    ns.sh_name      = (uint32_t)name_off;
    ns.sh_type      = SHT_PROGBITS;
    ns.sh_flags     = use_alloc ? SHF_ALLOC : 0;
    ns.sh_addr      = sh_addr;
    ns.sh_offset    = sec_off;
    ns.sh_size      = rec_bytes;
    ns.sh_link      = 0;
    ns.sh_info      = 0;
    ns.sh_addralign = 8;
    ns.sh_entsize   = 8;

    size_t shoff = (size_t)align_up(off, 16);
    if (shoff > off) { memset(out + off, 0, shoff - off); off = shoff; }

    uint64_t new_shnum = shnum + 1;
    if (new_shnum >= SHN_LORESERVE) {
        eh.e_shnum = 0;
        sh[0].sh_size = new_shnum;          /* extended section count */
    } else {
        eh.e_shnum = (uint16_t)new_shnum;
        sh[0].sh_size = 0;
    }
    if (shstrndx >= SHN_LORESERVE) {
        eh.e_shstrndx = SHN_XINDEX;
        sh[0].sh_link = (uint32_t)shstrndx;
    } else {
        eh.e_shstrndx = (uint16_t)shstrndx;
        sh[0].sh_link = 0;
    }

    for (uint64_t i = 0; i < shnum; ++i) {
        emit_shdr(out + off, &sh[i]);
        off += SHDR64_SIZE;
    }
    emit_shdr(out + off, &ns);
    off += SHDR64_SIZE;

    /* Patch only three ELF header fields. */
    wrf(out + 0x28, shoff,            8);   /* e_shoff   */
    wrf(out + 0x3c, eh.e_shnum,       2);   /* e_shnum   */
    wrf(out + 0x3e, eh.e_shstrndx,    2);   /* e_shstrndx */

    FILE *of = fopen(out_path, "wb");
    if (!of) die("cannot write '%s': %s", out_path, strerror(errno));
    if (fwrite(out, 1, off, of) != off) die("short write on '%s'", out_path);
    if (fclose(of) != 0) die("cannot close '%s': %s", out_path, strerror(errno));
    struct stat st;
    if (stat(in_path, &st) == 0) chmod(out_path, st.st_mode & 07777);

    printf("wrote '%s': .helpermap is section %" PRIu64
           ", offset 0x%zx, size %zu, %zu entries\n",
           out_path, shnum, sec_off, rec_bytes, nrec);
    printf("verify with: readelf -S -x .helpermap '%s'\n", out_path);

    free(recs); free(sh); free(buf); free(out);
    return 0;
}
