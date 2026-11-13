/*
 * load_aot_elf.c -- custom loader for QEMU-style AOT ELF images.
 *
 * Loads an ELF64 position independent executable (ET_DYN; ET_EXEC and ET_REL
 * are accepted as well) for AArch64 / RISC-V64 into memory, applies its
 * relocations, and hands back the addresses of the mapped .text and .funcmap.
 *
 * The input ELF is expected to have been post-processed by elf_add_maps.c,
 * i.e. it carries two extra ALLOC sections outside every PT_LOAD segment:
 *
 *   .helpermap  array of 8-byte records, in increasing symbol-index order
 *               { uint32 sym_index; uint32 helper_id; }
 *               sym_index is an index into the symbol table that
 *               elf_add_maps.c scanned (SHT_SYMTAB preferred, SHT_DYNSYM
 *               fallback); helper_id is the index into HelperFuncs[].
 *               Records are written with the input ELF's byte order by
 *               default (little for normal aarch64/riscv64); elf_add_maps
 *               --le always writes little endian. This loader auto-detects
 *               the record byte order and also honours the override macro
 *               AOT_HELPERMAP_FORCE_LE.
 *
 *   .funcmap    { uint32 root_index; uint32 node_count; } followed by
 *               32-byte RB-tree nodes. Opaque to this loader: it is copied
 *               into the image verbatim and its address is returned.
 *
 * Because the two added sections are appended after the original file and are
 * not described by any program header, this loader explicitly copies them to
 * their sh_addr (or to a synthesized address when sh_addr == 0, e.g. after
 * elf_add_maps --no-alloc or for ET_REL objects).
 *
 * ---------------------------------------------------------------------------
 * Public API
 * ---------------------------------------------------------------------------
 *   typedef struct helper_func { const char *name; uint64_t addr; }
 *           helper_func_t;
 *
 *   int load_aot_elf(const char *AotFile,
 *                    void (*AotLog)(const char *),
 *                    void *HelperFuncs, size_t HelperFuncsCnt,
 *                    uint64_t *AotCodeBasePtr,
 *                    uint64_t *FuncmapRbtreeRootPtr);
 *
 *   Returns 0 on success, -1 on failure (every diagnostic is delivered through
 *   AotLog, never to stdout/stderr). AotLog may be NULL.
 *
 *   On success:
 *     *AotCodeBasePtr        = address of the mapped .text section
 *                             (or of the first executable PT_LOAD if absent)
 *     *FuncmapRbtreeRootPtr  = address of the mapped .funcmap section
 *                             (0 and a warning if the section is missing)
 *
 *   Optional extension (not part of the requested API):
 *     void unload_aot_elf(uint64_t AotCodeBase);
 *   releases the mapping created by load_aot_elf().
 *
 * ---------------------------------------------------------------------------
 * What is resolved
 * ---------------------------------------------------------------------------
 *   * PT_LOAD segments are copied into one contiguous anonymous mapping, with
 *     a load bias; page protections are derived from p_flags / sh_flags and
 *     applied only after relocation is complete.
 *   * ET_DYN / ET_EXEC: DT_RELA / DT_REL / DT_JMPREL / DT_RELR from
 *     PT_DYNAMIC, plus DT_SYMTAB / DT_STRTAB. All PLT slots are bound eagerly.
 *   * ET_REL (or any image without PT_DYNAMIC): section-based SHT_RELA /
 *     SHT_REL / SHT_RELR tables are applied against their sh_info target.
 *   * Symbol lookup order for a relocation's symbol:
 *       1. .helpermap record for that symbol index -> HelperFuncs[id].addr
 *       2. .helpermap-derived name -> HelperFuncs[id].addr
 *       3. symbol defined inside the image (bias + st_value, or
 *          bias + section-base + st_value for ET_REL)
 *       4. name matched against HelperFuncs[].name
 *       5. weak undefined -> 0; otherwise the load fails
 *   * AArch64: ABS64/32/16, PREL64/32/16, GLOB_DAT, JUMP_SLOT, RELATIVE,
 *     IRELATIVE, ADR_PREL_LO21, ADR_PREL_PG_HI21(_NC), ADD_ABS_LO12_NC,
 *     LDST{8,16,32,64,128}_ABS_LO12_NC, JUMP26/CALL26 (with an out-of-range
 *     veneer), ADR_GOT_PAGE / LD64_GOT_LO12_NC (with generated GOT slots).
 *   * RISC-V64: 32, 64, RELATIVE, JUMP_SLOT, IRELATIVE, COPY(noop+warn),
 *     32_PCREL, BRANCH, JAL, CALL/CALL_PLT/PLT32, GOT_HI20,
 *     PCREL_HI20/LO12_I/LO12_S (with a HI20 cache), HI20/LO12_I/LO12_S,
 *     RVC_BRANCH, RVC_JUMP, RELAX(noop). Far JAL/CALL targets are redirected
 *     through a generated stub that tail-jumps to the real target.
 *   * COPY / TLS-only relocation types are reported as unsupported rather than
 *     being silently ignored.
 *
 * ---------------------------------------------------------------------------
 * Notes / limits
 * ---------------------------------------------------------------------------
 *   * Constructors (DT_INIT / DT_INIT_ARRAY) are NOT run; AOT code is data +
 *     code only. The log reports the relocated entry point.
 *   * DT_NEEDED / lazy PLT binding / symbol versioning / Android packed
 *     relocations are not implemented.
 *   * R_*_IRELATIVE executes a resolver in the loaded image. That is only
 *     supported when the host architecture matches the ELF machine; on a
 *     foreign host the load fails with a clear message instead of crashing.
 *   * A far JAL/BRANCH needs a stub within the instruction's branch range.
 *     Stubs live at the end of the single contiguous mapping, so this only
 *     matters for images larger than 1 MiB (JAL) or with very large text.
 *   * Build (no external dependencies beyond libc / libm is not needed):
 *       gcc -O2 -Wall -Wextra -std=c11 -c load_aot_elf.c
 *     Define AOT_HELPERMAP_FORCE_LE=1 if the maps were produced with --le on
 *     a big-endian input, and AOT_STRICT_HELPER_NAMES=1 to reject a
 *     .helpermap id whose HelperFuncs[].name differs from the symbol name.
 *
 * Public domain / CC0.
 * ---------------------------------------------------------------------------
 */
#ifdef AOT
#ifndef _POSIX_C_SOURCE
#define _POSIX_C_SOURCE 200809L
#endif
#ifndef _DEFAULT_SOURCE
#define _DEFAULT_SOURCE 1
#endif

#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <limits.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

#ifndef MAP_ANONYMOUS
#define MAP_ANONYMOUS MAP_ANON
#endif

/* ------------------------------------------------------------------ API -- */

#ifndef AOT_HELPER_FUNC_T_DEFINED
#define AOT_HELPER_FUNC_T_DEFINED
typedef struct helper_func {
    const char *name;
    uint64_t addr;
} helper_func_t;
#endif

int load_aot_elf(const char *AotFile, void (*AotLog)(const char *),
                 void *HelperFuncs, size_t HelperFuncsCnt,
                 uint64_t *AotCodeBasePtr, uint64_t *FuncmapRbtreeRootPtr);
void unload_aot_elf(uint64_t AotCodeBase);

/* --------------------------------------------------------------- ELF bits -- */

enum {
    AOT_CLASS64 = 2, AOT_DATA2LSB = 1, AOT_DATA2MSB = 2, AOT_EV_CURRENT = 1,
    AOT_ET_REL = 1, AOT_ET_EXEC = 2, AOT_ET_DYN = 3,
    AOT_EM_AARCH64 = 183, AOT_EM_RISCV = 243,

    AOT_PT_LOAD = 1, AOT_PT_DYNAMIC = 2,
    AOT_PF_X = 1, AOT_PF_W = 2, AOT_PF_R = 4,

    AOT_SHT_NULL = 0, AOT_SHT_PROGBITS = 1, AOT_SHT_SYMTAB = 2,
    AOT_SHT_STRTAB = 3, AOT_SHT_RELA = 4, AOT_SHT_NOBITS = 8,
    AOT_SHT_REL = 9, AOT_SHT_DYNSYM = 11, AOT_SHT_RELR = 19,
    AOT_SHF_WRITE = 1, AOT_SHF_ALLOC = 2, AOT_SHF_EXECINSTR = 4,

    AOT_SHN_UNDEF = 0, AOT_SHN_LORESERVE = 0xff00,
    AOT_SHN_ABS = 0xfff1, AOT_SHN_COMMON = 0xfff2, AOT_SHN_XINDEX = 0xffff,
    AOT_STB_WEAK = 2,
    AOT_PN_XNUM = 0xffff,

    AOT_DT_NULL = 0, AOT_DT_PLTRELSZ = 2, AOT_DT_STRTAB = 5,
    AOT_DT_SYMTAB = 6, AOT_DT_RELA = 7, AOT_DT_RELASZ = 8,
    AOT_DT_RELAENT = 9, AOT_DT_STRSZ = 10, AOT_DT_SYMENT = 11,
    AOT_DT_REL = 17, AOT_DT_RELSZ = 18, AOT_DT_RELENT = 19,
    AOT_DT_PLTREL = 20, AOT_DT_TEXTREL = 22, AOT_DT_JMPREL = 23,
    AOT_DT_FLAGS = 30, AOT_DT_RELRSZ = 35, AOT_DT_RELR = 36,
    AOT_DT_RELRENT = 37,
    AOT_DT_FLAGS_1 = 0x6ffffffb, AOT_DF_TEXTREL = 0x4,

    AOT_EHDR_SIZE = 64, AOT_PHDR_SIZE = 56, AOT_SHDR_SIZE = 64,
    AOT_SYM_SIZE = 24, AOT_RELA_SIZE = 24, AOT_REL_SIZE = 16,
    AOT_DYN_SIZE = 16
};

/* AArch64 relocation numbers (elf.h) */
enum {
    A64_NONE = 0, A64_ABS64 = 257, A64_ABS32 = 258, A64_ABS16 = 259,
    A64_PREL64 = 260, A64_PREL32 = 261, A64_PREL16 = 262,
    A64_ADR_PREL_LO21 = 274, A64_ADR_PREL_PG_HI21 = 275,
    A64_ADR_PREL_PG_HI21_NC = 276, A64_ADD_ABS_LO12_NC = 277,
    A64_LDST8_ABS_LO12_NC = 278, A64_JUMP26 = 282, A64_CALL26 = 283,
    A64_LDST16_ABS_LO12_NC = 284, A64_LDST32_ABS_LO12_NC = 285,
    A64_LDST64_ABS_LO12_NC = 286, A64_LDST128_ABS_LO12_NC = 299,
    A64_ADR_GOT_PAGE = 311, A64_LD64_GOT_LO12_NC = 312,
    A64_COPY = 1024, A64_GLOB_DAT = 1025, A64_JUMP_SLOT = 1026,
    A64_RELATIVE = 1027, A64_IRELATIVE = 1032
};

/* RISC-V relocation numbers (elf.h) */
enum {
    RV_NONE = 0, RV_32 = 1, RV_64 = 2, RV_RELATIVE = 3, RV_COPY = 4,
    RV_JUMP_SLOT = 5, RV_BRANCH = 16, RV_JAL = 17, RV_CALL = 18,
    RV_CALL_PLT = 19, RV_GOT_HI20 = 20, RV_PCREL_HI20 = 23,
    RV_PCREL_LO12_I = 24, RV_PCREL_LO12_S = 25, RV_HI20 = 26,
    RV_LO12_I = 27, RV_LO12_S = 28, RV_RVC_BRANCH = 44, RV_RVC_JUMP = 45,
    RV_RELAX = 51, RV_32_PCREL = 57, RV_IRELATIVE = 58, RV_PLT32 = 59
};

/* ------------------------------------------------------------ structures -- */

typedef struct {
    uint16_t type, machine;
    uint32_t version, flags;
    uint64_t entry, phoff, shoff;
    uint16_t ehsize, phentsize, phnum, shentsize, shnum, shstrndx;
} Ehdr;

typedef struct {
    uint32_t type, flags;
    uint64_t offset, vaddr, paddr, filesz, memsz, align;
} Phdr;

typedef struct {
    uint32_t name, type, link, info;
    uint64_t flags, addr, offset, size, addralign, entsize;
} Shdr;

typedef struct {
    const uint8_t *sym;             /* symbol table bytes in the file image  */
    size_t nsyms, entsize;
    const uint8_t *str;             /* linked string table                   */
    size_t strsz;
    size_t secidx;                  /* section index of this symbol table    */
} SymTab;

typedef struct {
    uint32_t symidx, id;
    uint64_t addr;
    char *name;                     /* HelperFuncs[id].name (may be NULL)    */
} HelperRec;

typedef struct {
    const char *name;
    uint64_t addr;
} NameAddr;

typedef struct {
    uint64_t key;                   /* raw r_offset of the HI20 relocation   */
    int64_t  val;                   /* T - P_hi                              */
} HiCache;

typedef struct {
    uint32_t symidx;
    uint64_t addr;                  /* address of the generated GOT slot     */
} GotSlot;

typedef struct {
    void (*log)(const char *);
    char  *path;
    uint8_t *file;  size_t fsz;
    int be;                         /* ELF byte order: 1 = big endian         */
    int rec_be;                     /* byte order of .helpermap records       */

    Ehdr eh;
    Phdr *ph;  size_t phnum;
    Shdr *sh;  size_t shnum;
    size_t shstrndx;
    const uint8_t *shstr; size_t shstrsz;

    uint64_t page, vaddr_base, bias, memsz;
    uint8_t *mem;
    uint64_t *sec_vaddr;            /* link-time vaddr of each placed section */
    uint64_t *sec_abs;              /* absolute mapped address, 0 if unplaced */
    uint8_t  *sec_placed;

    SymTab *symtabs; size_t nsymtabs;
    size_t primary_symtab;          /* index into symtabs[] used by helpermap */
    uint64_t *helper_idx_addr; uint8_t *helper_idx_set; size_t helper_idx_n;
    HelperRec *hrecs; size_t nhrecs;
    NameAddr *names; size_t nnames, capnames;

    uint64_t veneer_cur, veneer_end;
    HiCache *hicache; size_t nhicache, caphicache;
    GotSlot *gots; size_t ngots, capgots;

    size_t funcsec, helper_sec, textsec;
    uint64_t func_addr, code_addr;
    int textrel;
    size_t nreloc, nhelper_hits, nstubs;

    helper_func_t *helpers; size_t nhelpers;
} Aot;

/* -------------------------------------------------------------- utilities -- */

static uint64_t rdN(const uint8_t *p, int n, int be)
{
    uint64_t v = 0;
    if (be) { for (int i = 0; i < n; ++i) v = (v << 8) | p[i]; }
    else    { for (int i = n - 1; i >= 0; --i) v = (v << 8) | p[i]; }
    return v;
}
static void wrN(uint8_t *p, uint64_t v, int n, int be)
{
    if (be) { for (int i = n - 1; i >= 0; --i) { p[i] = (uint8_t)(v & 0xff); v >>= 8; } }
    else    { for (int i = 0; i < n; ++i)     { p[i] = (uint8_t)(v & 0xff); v >>= 8; } }
}
static uint16_t u16(const Aot *a, const uint8_t *p) { return (uint16_t)rdN(p, 2, a->be); }
static uint32_t u32(const Aot *a, const uint8_t *p) { return (uint32_t)rdN(p, 4, a->be); }
static uint64_t u64(const Aot *a, const uint8_t *p) { return rdN(p, 8, a->be); }
static void w16(Aot *a, uint8_t *p, uint16_t v) { wrN(p, v, 2, a->be); }
static void w32(Aot *a, uint8_t *p, uint32_t v) { wrN(p, v, 4, a->be); }
static void w64(Aot *a, uint8_t *p, uint64_t v) { wrN(p, v, 8, a->be); }

static uint64_t align_up(uint64_t v, uint64_t a)
{
    return a ? (v + a - 1) & ~(a - 1) : v;
}
static uint64_t align_dn(uint64_t v, uint64_t a) { return v & ~(a - 1); }

static int range_ok(uint64_t off, uint64_t len, size_t sz)
{
    return off <= (uint64_t)sz && len <= (uint64_t)sz - off;
}

static void alog(Aot *a, const char *fmt, ...)
{
    if (!a->log) return;
    char buf[1024];
    int n;
    va_list ap;
    va_start(ap, fmt);
    n = vsnprintf(buf, sizeof buf, fmt, ap);
    va_end(ap);
    if (n < 0) return;
    buf[sizeof buf - 1] = '\0';
    char line[1100];
    snprintf(line, sizeof line, "load_aot_elf: %s", buf);
    a->log(line);
    a->log("\n");
}
#define AOT_ERR(a, ...) do { alog((a), "error: " __VA_ARGS__); goto fail; } while (0)

static uint8_t *mptr(Aot *a, uint64_t addr, size_t need)
{
    uint64_t base = (uint64_t)(uintptr_t)a->mem;
    if (addr < base || addr - base > a->memsz || need > a->memsz - (addr - base))
        return NULL;
    return (uint8_t *)(uintptr_t)addr;
}

static const char *str_at(const uint8_t *tab, size_t sz, uint64_t off)
{
    if (off >= (uint64_t)sz) return "";
    const uint8_t *s = tab + off;
    if (!memchr(s, '\0', sz - (size_t)off)) return "";
    return (const char *)s;
}

static const char *sec_name(Aot *a, size_t i)
{
    if (!a->shstr || i >= a->shnum) return "";
    return str_at(a->shstr, a->shstrsz, a->sh[i].name);
}

static size_t find_sec(Aot *a, const char *name)
{
    for (size_t i = 0; i < a->shnum; ++i)
        if (!strcmp(sec_name(a, i), name)) return i;
    return SIZE_MAX;
}

static int read_file(Aot *a)
{
    int fd = open(a->path, O_RDONLY);
    if (fd < 0) { alog(a, "error: cannot open '%s': %s", a->path, strerror(errno)); return -1; }
    struct stat st;
    if (fstat(fd, &st) != 0 || st.st_size < 0) {
        alog(a, "error: cannot stat '%s': %s", a->path, strerror(errno));
        close(fd); return -1;
    }
    size_t sz = (size_t)st.st_size;
    uint8_t *b = (uint8_t *)malloc(sz ? sz : 1);
    if (!b) { alog(a, "error: out of memory reading '%s'", a->path); close(fd); return -1; }
    size_t got = 0;
    while (got < sz) {
        ssize_t r = read(fd, b + got, sz - got);
        if (r < 0 && errno == EINTR) continue;
        if (r <= 0) break;
        got += (size_t)r;
    }
    close(fd);
    if (got != sz) { free(b); alog(a, "error: short read on '%s'", a->path); return -1; }
    a->file = b; a->fsz = sz;
    return 0;
}

static void parse_ehdr(Aot *a, const uint8_t *b, Ehdr *e)
{
    e->type      = u16(a, b + 0x10); e->machine = u16(a, b + 0x12);
    e->version   = u32(a, b + 0x14); e->entry   = u64(a, b + 0x18);
    e->phoff     = u64(a, b + 0x20); e->shoff   = u64(a, b + 0x28);
    e->flags     = u32(a, b + 0x30); e->ehsize  = u16(a, b + 0x34);
    e->phentsize = u16(a, b + 0x36); e->phnum   = u16(a, b + 0x38);
    e->shentsize = u16(a, b + 0x3a); e->shnum   = u16(a, b + 0x3c);
    e->shstrndx  = u16(a, b + 0x3e);
}
static void parse_phdr(Aot *a, const uint8_t *p, Phdr *h)
{
    h->type   = u32(a, p + 0);  h->flags  = u32(a, p + 4);
    h->offset = u64(a, p + 8);  h->vaddr  = u64(a, p + 16);
    h->paddr  = u64(a, p + 24); h->filesz = u64(a, p + 32);
    h->memsz  = u64(a, p + 40); h->align  = u64(a, p + 48);
}
static void parse_shdr(Aot *a, const uint8_t *p, Shdr *s)
{
    s->name      = u32(a, p + 0);  s->type      = u32(a, p + 4);
    s->flags     = u64(a, p + 8);  s->addr      = u64(a, p + 16);
    s->offset    = u64(a, p + 24); s->size      = u64(a, p + 32);
    s->link      = u32(a, p + 40); s->info      = u32(a, p + 44);
    s->addralign = u64(a, p + 48); s->entsize   = u64(a, p + 56);
}

/* ELF extended numbering: section 0 holds the real counts. */
static int parse_headers(Aot *a)
{
    if (a->fsz < AOT_EHDR_SIZE || memcmp(a->file, "\177ELF", 4) != 0)
        AOT_ERR(a, "'%s' is not an ELF file", a->path);
    if (a->file[4] != AOT_CLASS64)
        AOT_ERR(a, "only ELF64 is supported (aarch64 / riscv64)");
    if (a->file[5] == AOT_DATA2LSB) a->be = 0;
    else if (a->file[5] == AOT_DATA2MSB) a->be = 1;
    else AOT_ERR(a, "unknown ELF data encoding %u", a->file[5]);
    if (a->file[6] != AOT_EV_CURRENT)
        AOT_ERR(a, "unsupported ELF ident version %u", a->file[6]);

    parse_ehdr(a, a->file, &a->eh);
    if (a->eh.machine != AOT_EM_AARCH64 && a->eh.machine != AOT_EM_RISCV)
        alog(a, "warning: e_machine=%u is neither AArch64(183) nor RISC-V(243)",
             a->eh.machine);

    const uint8_t *sh0 = NULL;
    if (a->eh.shoff && range_ok(a->eh.shoff, AOT_SHDR_SIZE, a->fsz))
        sh0 = a->file + a->eh.shoff;

    uint64_t phnum = a->eh.phnum;
    if (phnum == AOT_PN_XNUM) {
        if (!sh0) AOT_ERR(a, "PN_XNUM used but section header 0 is unavailable");
        phnum = u32(a, sh0 + 44);
    }
    uint64_t shnum = a->eh.shnum;
    if (shnum == 0 && sh0) shnum = u64(a, sh0 + 32);
    uint64_t shstrndx = a->eh.shstrndx;
    if (shstrndx == AOT_SHN_XINDEX && sh0) shstrndx = u32(a, sh0 + 40);

    if (phnum > 65536 || shnum > 262144)
        AOT_ERR(a, "implausible header counts (phnum=%" PRIu64 ", shnum=%" PRIu64 ")",
                phnum, shnum);
    if (phnum) {
        if (a->eh.phentsize != AOT_PHDR_SIZE || !range_ok(a->eh.phoff, phnum * AOT_PHDR_SIZE, a->fsz))
            AOT_ERR(a, "program header table is missing or out of bounds");
    }
    if (shnum) {
        if (a->eh.shentsize != AOT_SHDR_SIZE || !range_ok(a->eh.shoff, shnum * AOT_SHDR_SIZE, a->fsz))
            AOT_ERR(a, "section header table is missing or out of bounds");
    }

    a->phnum = (size_t)phnum;
    a->shnum = (size_t)shnum;
    a->shstrndx = (size_t)shstrndx;
    if (phnum) {
        a->ph = (Phdr *)calloc(a->phnum, sizeof *a->ph);
        if (!a->ph) AOT_ERR(a, "out of memory");
        for (size_t i = 0; i < a->phnum; ++i)
            parse_phdr(a, a->file + a->eh.phoff + i * AOT_PHDR_SIZE, &a->ph[i]);
    }
    if (shnum) {
        a->sh = (Shdr *)calloc(a->shnum, sizeof *a->sh);
        a->sec_vaddr = (uint64_t *)calloc(a->shnum, sizeof *a->sec_vaddr);
        a->sec_abs   = (uint64_t *)calloc(a->shnum, sizeof *a->sec_abs);
        a->sec_placed = (uint8_t *)calloc(a->shnum, 1);
        if (!a->sh || !a->sec_vaddr || !a->sec_abs || !a->sec_placed)
            AOT_ERR(a, "out of memory");
        for (size_t i = 0; i < a->shnum; ++i)
            parse_shdr(a, a->file + a->eh.shoff + i * AOT_SHDR_SIZE, &a->sh[i]);
        if (a->shstrndx && a->shstrndx < a->shnum) {
            const Shdr *s = &a->sh[a->shstrndx];
            if (s->type == AOT_SHT_STRTAB && range_ok(s->offset, s->size, a->fsz)) {
                a->shstr = a->file + s->offset;
                a->shstrsz = (size_t)s->size;
            }
        }
        if (!a->shstr) alog(a, "warning: no usable .shstrtab; section names unavailable");
    } else {
        alog(a, "warning: input has no section headers; .funcmap/.helpermap unavailable");
    }
    return 0;
fail:
    return -1;
}

static int count_loads(Aot *a)
{
    size_t n = 0;
    for (size_t i = 0; i < a->phnum; ++i) if (a->ph[i].type == AOT_PT_LOAD) ++n;
    return (int)n;
}

/* ----------------------------------------------------------- symbol tables -- */

static int build_symtabs(Aot *a)
{
    for (size_t i = 0; i < a->shnum; ++i)
        if (a->sh[i].type == AOT_SHT_SYMTAB || a->sh[i].type == AOT_SHT_DYNSYM)
            ++a->nsymtabs;
    if (!a->nsymtabs) return 0;
    a->symtabs = (SymTab *)calloc(a->nsymtabs, sizeof *a->symtabs);
    if (!a->symtabs) return -1;
    size_t k = 0;
    for (size_t i = 0; i < a->shnum; ++i) {
        const Shdr *s = &a->sh[i];
        if (s->type != AOT_SHT_SYMTAB && s->type != AOT_SHT_DYNSYM) continue;
        SymTab *t = &a->symtabs[k++];
        t->secidx = i;
        t->entsize = s->entsize ? (size_t)s->entsize : AOT_SYM_SIZE;
        if (t->entsize < AOT_SYM_SIZE) t->entsize = AOT_SYM_SIZE;
        if (!range_ok(s->offset, s->size, a->fsz)) continue;
        t->sym = a->file + s->offset;
        t->nsyms = (size_t)(s->size / t->entsize);
        if (s->link < a->shnum) {
            const Shdr *l = &a->sh[s->link];
            if (range_ok(l->offset, l->size, a->fsz)) {
                t->str = a->file + l->offset;
                t->strsz = (size_t)l->size;
            }
        }
        if (!t->str) t->nsyms = 0;
    }
    return 0;
}

static const uint8_t *sym_at(const SymTab *t, uint32_t idx)
{
    return (idx < t->nsyms) ? t->sym + (size_t)idx * t->entsize : NULL;
}
static const char *sym_name(Aot *a, const SymTab *t, uint32_t idx)
{
    const uint8_t *s = sym_at(t, idx);
    if (!s) return "";
    return str_at(t->str, t->strsz, u32(a, s));
}
static int sym_defined(Aot *a, const SymTab *t, uint32_t idx, uint64_t *out)
{
    const uint8_t *s = sym_at(t, idx);
    if (!s) return 0;
    uint16_t shndx = u16(a, s + 6);
    uint64_t v = u64(a, s + 8);
    if (shndx == AOT_SHN_UNDEF || shndx == AOT_SHN_COMMON) return 0;
    if (shndx == AOT_SHN_ABS) { *out = v; return 1; }
    if (shndx >= AOT_SHN_LORESERVE) return 0;
    if (a->eh.type == AOT_ET_REL) {
        if (shndx >= a->shnum || !a->sec_placed[shndx]) return 0;
        *out = a->bias + a->sec_vaddr[shndx] + v;
    } else {
        *out = a->bias + v;
    }
    return 1;
}

static void add_name(Aot *a, const char *name, uint64_t addr)
{
    if (!name || !*name || !addr) return;
    for (size_t i = 0; i < a->nnames; ++i)
        if (!strcmp(a->names[i].name, name)) { a->names[i].addr = addr; return; }
    if (a->nnames == a->capnames) {
        size_t nc = a->capnames ? a->capnames * 2 : 64;
        NameAddr *p = (NameAddr *)realloc(a->names, nc * sizeof *p);
        if (!p) return;
        a->names = p; a->capnames = nc;
    }
    a->names[a->nnames].name = name;
    a->names[a->nnames].addr = addr;
    ++a->nnames;
}
static uint64_t name_addr(Aot *a, const char *name)
{
    if (!name || !*name) return 0;
    for (size_t i = 0; i < a->nnames; ++i)
        if (!strcmp(a->names[i].name, name)) return a->names[i].addr;
    return 0;
}

/* Parse .helpermap, auto-detecting the byte order of its 8-byte records. */
static int build_helpermap(Aot *a)
{
    a->funcsec = find_sec(a, ".funcmap");
    a->helper_sec = find_sec(a, ".helpermap");
    a->textsec = find_sec(a, ".text");

    for (size_t i = 0; i < a->nhelpers; ++i)
        if (a->helpers[i].name) add_name(a, a->helpers[i].name, a->helpers[i].addr);

    if (a->helper_sec == SIZE_MAX) {
        alog(a, "warning: no .helpermap section; helper symbols resolve by name only");
        return 0;
    }
    const Shdr *s = &a->sh[a->helper_sec];
    if (!range_ok(s->offset, s->size, a->fsz))
        AOT_ERR(a, ".helpermap lies outside the file");
    size_t n = (size_t)(s->size / 8);
    const uint8_t *d = a->file + s->offset;
    if (!n) { alog(a, ".helpermap: 0 records"); return 0; }

    size_t maxsym = 1;
    for (size_t i = 0; i < a->nsymtabs; ++i)
        if (a->symtabs[i].nsyms > maxsym) maxsym = a->symtabs[i].nsyms;

    int best = a->be;
#ifndef AOT_HELPERMAP_FORCE_LE
    {
        long score[2] = { -1, -1 };
        for (int be = 0; be < 2; ++be) {
            long sc = 0;
            for (size_t i = 0; i < n; ++i) {
                uint32_t idx = (uint32_t)rdN(d + 8 * i, 4, be);
                uint32_t id  = (uint32_t)rdN(d + 8 * i + 4, 4, be);
                if (idx < maxsym && (a->nhelpers == 0 || id < a->nhelpers)) ++sc;
            }
            score[be] = sc;
        }
        best = (score[0] > score[1]) ? 0 : (score[1] > score[0]) ? 1 : a->be;
    }
#else
    best = 0;
#endif
    a->rec_be = best;
    alog(a, ".helpermap: %zu records, %s-endian", n, best ? "big" : "little");

    a->hrecs = (HelperRec *)calloc(n, sizeof *a->hrecs);
    if (!a->hrecs) AOT_ERR(a, "out of memory");
    a->nhrecs = n;
    for (size_t i = 0; i < n; ++i) {
        HelperRec *r = &a->hrecs[i];
        r->symidx = (uint32_t)rdN(d + 8 * i, 4, best);
        r->id     = (uint32_t)rdN(d + 8 * i + 4, 4, best);
        if (r->id >= a->nhelpers) {
            alog(a, "warning: .helpermap record %zu has helper id %u >= count %zu (ignored)",
                 i, r->id, a->nhelpers);
            continue;
        }
        r->addr = a->helpers[r->id].addr;
        r->name = a->helpers[r->id].name ? strdup(a->helpers[r->id].name) : NULL;

        /* Name-based fallback, valid for every symbol table. */
        for (size_t t = 0; t < a->nsymtabs; ++t) {
            const char *sn = sym_name(a, &a->symtabs[t], r->symidx);
            if (*sn) {
                add_name(a, sn, r->addr);
#ifdef AOT_STRICT_HELPER_NAMES
                if (r->name && strcmp(sn, r->name) != 0)
                    AOT_ERR(a, "helper id %u at symidx %u is '%s' but ELF says '%s'",
                            r->id, r->symidx, r->name, sn);
#endif
            }
        }
        if (r->name) add_name(a, r->name, r->addr);
    }
    /* Pick the symtab whose index->name agreement is strongest. */
    size_t best_tab = 0, best_score = 0;
    for (size_t t = 0; t < a->nsymtabs; ++t) {
        size_t sc = 0;
        for (size_t i = 0; i < n; ++i) {
            const char *sn = sym_name(a, &a->symtabs[t], a->hrecs[i].symidx);
            if (!*sn || !a->hrecs[i].addr) continue;
            if (a->hrecs[i].name && !strcmp(sn, a->hrecs[i].name)) sc += 2;
            else sc += 1;
        }
        if (sc > best_score) { best_score = sc; best_tab = t; }
    }
    a->primary_symtab = best_tab;
    a->helper_idx_n = a->nsymtabs ? a->symtabs[best_tab].nsyms : 0;
    a->helper_idx_addr = (uint64_t *)calloc(a->helper_idx_n ? a->helper_idx_n : 1,
                                            sizeof *a->helper_idx_addr);
    a->helper_idx_set = (uint8_t *)calloc(a->helper_idx_n ? a->helper_idx_n : 1, 1);
    if (!a->helper_idx_addr || !a->helper_idx_set) AOT_ERR(a, "out of memory");
    for (size_t i = 0; i < n; ++i) {
        HelperRec *r = &a->hrecs[i];
        if (!r->addr || r->symidx >= a->helper_idx_n) continue;
        a->helper_idx_addr[r->symidx] = r->addr;
        a->helper_idx_set[r->symidx] = 1;
    }
    if (a->nsymtabs)
        alog(a, ".helpermap: primary symbol table = section %zu (%zu syms), score %zu",
             a->symtabs[best_tab].secidx, a->helper_idx_n, best_score);
    else
        alog(a, "warning: .helpermap present but no symbol table; using name lookups");
    return 0;
fail:
    return -1;
}

static int resolve(Aot *a, const SymTab *st, uint32_t symidx, uint64_t *S,
                   int *is_weak)
{
    *is_weak = 0;
    *S = 0;
    const char *nm = sym_name(a, st, symidx);
    const uint8_t *sym = sym_at(st, symidx);
    if (sym) *is_weak = ((sym[4] >> 4) == AOT_STB_WEAK);

    if (a->nsymtabs && st == &a->symtabs[a->primary_symtab] &&
        symidx < a->helper_idx_n && a->helper_idx_set[symidx]) {
        *S = a->helper_idx_addr[symidx];
        ++a->nhelper_hits;
        return 0;
    }
    if (*nm) {
        uint64_t v = name_addr(a, nm);
        if (v) { *S = v; ++a->nhelper_hits; return 0; }
    }
    if (sym_defined(a, st, symidx, S)) return 0;
    if (*nm) {
        uint64_t v = name_addr(a, nm);
        if (v) { *S = v; return 0; }
    }
    if (*is_weak) { alog(a, "warning: weak symbol '%s' is unresolved, using 0", nm); return 0; }
    alog(a, "error: unresolved symbol %u ('%s'): no .helpermap record, no "
            "definition, no HelperFuncs name match",
         symidx, *nm ? nm : "<noname>");
    return -1;
}

/* ------------------------------------------------------------- stubs/GOT -- */

static uint64_t alloc_space(Aot *a, size_t size, size_t align)
{
    uint64_t p = align_up(a->veneer_cur, align);
    if (p + size > a->veneer_end) return 0;
    a->veneer_cur = p + size;
    uint8_t *m = mptr(a, a->bias + p, size);
    if (m) memset(m, 0, size);
    return a->bias + p;         /* absolute address in the image */
}

static uint64_t make_a64_stub(Aot *a, uint64_t target)
{
    uint64_t p = alloc_space(a, 16, 16);
    if (!p) { alog(a, "error: out of veneer space for AArch64 stub"); return 0; }
    uint8_t *m = mptr(a, p, 16);
    if (!m) return 0;
    w32(a, m + 0, 0x58000050u);   /* ldr  x16, #8       */
    w32(a, m + 4, 0xd61f0200u);   /* br   x16           */
    w64(a, m + 8, target);
    ++a->nstubs;
    return p;
}

static uint64_t make_rv_stub(Aot *a, uint64_t target)
{
    uint64_t p = alloc_space(a, 24, 8);
    if (!p) { alog(a, "error: out of veneer space for RISC-V stub"); return 0; }
    uint8_t *m = mptr(a, p, 24);
    if (!m) return 0;
    w32(a, m + 0,  0x00000317u);  /* auipc t1, 0        -> t1 = stub   */
    w32(a, m + 4,  0x01033303u);  /* ld    t1, 16(t1)   -> t1 = target */
    w32(a, m + 8,  0x00030067u);  /* jr    t1           (ra preserved) */
    w32(a, m + 12, 0x00000013u);  /* nop                              */
    w64(a, m + 16, target);
    ++a->nstubs;
    return p;
}

static uint64_t got_slot(Aot *a, uint32_t symidx, uint64_t target)
{
    for (size_t i = 0; i < a->ngots; ++i)
        if (a->gots[i].symidx == symidx) return a->gots[i].addr;
    if (a->ngots == a->capgots) {
        size_t nc = a->capgots ? a->capgots * 2 : 32;
        GotSlot *p = (GotSlot *)realloc(a->gots, nc * sizeof *p);
        if (!p) return 0;
        a->gots = p; a->capgots = nc;
    }
    uint64_t slot = alloc_space(a, 8, 8);
    if (!slot) return 0;
    uint8_t *m = mptr(a, slot, 8);
    if (!m) return 0;
    w64(a, m, target);
    a->gots[a->ngots].symidx = symidx;
    a->gots[a->ngots].addr = slot;
    ++a->ngots;
    return slot;
}

static void hicache_put(Aot *a, uint64_t key, int64_t val)
{
    if (a->nhicache == a->caphicache) {
        size_t nc = a->caphicache ? a->caphicache * 2 : 32;
        HiCache *p = (HiCache *)realloc(a->hicache, nc * sizeof *p);
        if (!p) return;
        a->hicache = p; a->caphicache = nc;
    }
    a->hicache[a->nhicache].key = key;
    a->hicache[a->nhicache].val = val;
    ++a->nhicache;
}
static int hicache_get(Aot *a, uint64_t key, int64_t *val)
{
    for (size_t i = 0; i < a->nhicache; ++i)
        if (a->hicache[i].key == key) { *val = a->hicache[i].val; return 1; }
    return 0;
}

/* ------------------------------------------------- instruction encoders -- */

static int fits(int64_t v, unsigned bits)
{
    int64_t lo = -(int64_t)(1ULL << (bits - 1));
    int64_t hi = (int64_t)((1ULL << (bits - 1)) - 1);
    return v >= lo && v <= hi;
}

static int a64_patch_adr(Aot *a, uint64_t P, uint64_t T, int page)
{
    uint8_t *m = mptr(a, P, 4);
    if (!m) return -1;
    uint32_t insn = u32(a, m);
    int64_t d = page ? (int64_t)((T & ~(uint64_t)0xfff) - (P & ~(uint64_t)0xfff))
                     : (int64_t)(T - P);
    if (page) d >>= 12;
    if (!fits(d, 21)) return -1;
    uint32_t imm = (uint32_t)d;
    w32(a, m, (insn & 0x9f00001fu) | ((imm & 3u) << 29) |
              (((imm >> 2) & 0x7ffffu) << 5));
    return 0;
}

static int a64_patch_lo12(Aot *a, uint64_t P, uint64_t T, int scale, int is_add)
{
    uint8_t *m = mptr(a, P, 4);
    if (!m) return -1;
    uint32_t insn = u32(a, m);
    uint64_t lo = T & 0xfff;
    uint32_t imm;
    if (is_add) {
        if (insn & (1u << 22)) lo = (T >> 12) & 0xfff;
        imm = (uint32_t)lo;
    } else {
        if (lo % (uint64_t)scale) return -1;
        imm = (uint32_t)(lo / (uint64_t)scale);
    }
    w32(a, m, (insn & ~(0xfffu << 10)) | (imm << 10));
    return 0;
}

static int a64_patch_branch(Aot *a, uint64_t P, uint64_t T)
{
    uint8_t *m = mptr(a, P, 4);
    if (!m) return -1;
    int64_t d = (int64_t)(T - P);
    if (d & 3) return -1;
    d >>= 2;
    if (!fits(d, 26)) {
        uint64_t stub = make_a64_stub(a, T);
        if (!stub) return -1;
        d = (int64_t)(stub - P) >> 2;
        if (!fits(d, 26)) return -1;
        alog(a, "CALL26/JUMP26 out of range at 0x%" PRIx64 ": veneer 0x%" PRIx64
                " -> 0x%" PRIx64, P, stub, T);
    }
    w32(a, m, (u32(a, m) & 0xfc000000u) | ((uint32_t)d & 0x03ffffffu));
    return 0;
}

static uint32_t rv_j_set(uint32_t insn, int64_t imm)
{
    uint32_t u = (uint32_t)imm;
    return (insn & 0xfffu) | (u & 0xff000u) | ((u & 0x800u) << 9) |
           ((u & 0x7feu) << 20) | ((u & 0x100000u) << 11);
}
static uint32_t rv_b_set(uint32_t insn, int64_t imm)
{
    uint32_t u = (uint32_t)imm;
    return (insn & 0x01fff07fu) | (u & 0x1000u) << 19 | ((u & 0x7e0u) << 20) |
           ((u & 0x1eu) << 7) | ((u & 0x800u) >> 4);
}
static uint32_t rv_u_set(uint32_t insn, uint32_t imm20)
{
    return (insn & 0xfffu) | ((imm20 & 0xfffffu) << 12);
}
static uint32_t rv_i_set(uint32_t insn, uint32_t imm12)
{
    return (insn & 0x000fffffu) | ((imm12 & 0xfffu) << 20);
}
static uint32_t rv_s_set(uint32_t insn, uint32_t imm12)
{
    return (insn & 0x01fff07fu) | ((imm12 & 0xfe0u) << 20) | ((imm12 & 0x1fu) << 7);
}
static uint32_t rv_cb_set(uint16_t insn, int64_t imm)
{
    uint32_t u = (uint32_t)imm;
    return (insn & 0xe383u) | ((u & 0x100u) << 3) | ((u & 0x18u) << 7) |
           ((u & 0xc0u) >> 3) | ((u & 0x6u) << 2) | ((u & 0x20u) >> 3);
}
static uint32_t rv_cj_set(uint16_t insn, int64_t imm)
{
    uint32_t u = (uint32_t)imm;
    return (insn & 0xe003u) | ((u & 0x800u) << 1) | ((u & 0x400u) >> 1) |
           ((u & 0x300u) << 1) | ((u & 0x80u) << 1) | ((u & 0x40u) >> 1) |
           ((u & 0x20u) << 5) | ((u & 0x10u) << 7) | ((u & 0xe) << 1);
}

/* ----------------------------------------------------------- IRELATIVE -- */

#if defined(__aarch64__)
#define AOT_HOST_AARCH64 1
#endif
#if defined(__riscv) && (__riscv_xlen == 64)
#define AOT_HOST_RISCV64 1
#endif

/* Execute an IRELATIVE resolver. Only possible on a native host. */
static int call_irelative_value(Aot *a, uint64_t resolver, uint64_t *out)
{
    int ok = 0;
    if (a->eh.machine == AOT_EM_AARCH64) {
#ifdef AOT_HOST_AARCH64
        ok = 1;
#endif
    } else if (a->eh.machine == AOT_EM_RISCV) {
#ifdef AOT_HOST_RISCV64
        ok = 1;
#endif
    }
    if (!ok) {
        alog(a, "error: R_*_IRELATIVE resolver cannot run on this host "
                "(machine %u)", a->eh.machine);
        return -1;
    }
    uint64_t pg = align_dn(resolver, a->page);
    if (mprotect((void *)(uintptr_t)pg, a->page,
                 PROT_READ | PROT_WRITE | PROT_EXEC) != 0) {
        alog(a, "error: mprotect(RWX) for IRELATIVE failed: %s", strerror(errno));
        return -1;
    }
    typedef uint64_t (*resolver_fn)(void);
    *out = ((resolver_fn)(uintptr_t)resolver)();
    return 0;
}

/* ------------------------------------------------------- one relocation -- */

static int apply_reloc(Aot *a, uint64_t P, uint64_t r_off, uint32_t type,
                       uint32_t symidx, int64_t A, int is_rela,
                       const SymTab *st)
{
    uint64_t S = 0, B = a->bias, T;
    int weak = 0;
    uint8_t *m = mptr(a, P, 8);
    if (!m) { alog(a, "error: relocation target 0x%" PRIx64 " is outside the image", P); return -1; }

    /* Implicit addend for SHT_REL / DT_REL. */
    if (!is_rela) {
        switch (type) {
        case A64_ABS32: case A64_PREL32: case RV_32: case RV_32_PCREL:
            A = (int32_t)u32(a, m); break;
        case RV_PCREL_LO12_I: case RV_PCREL_LO12_S:
        case RV_LO12_I: case RV_LO12_S:
            A = (int32_t)u32(a, m) >> 20; break;
        default: A = (int64_t)u64(a, m); break;
        }
    }

    /* Types that never reference a symbol. */
    if (type == A64_NONE || type == RV_NONE || type == RV_RELAX) return 0;
    if (type == A64_RELATIVE || type == RV_RELATIVE) {
        w64(a, m, B + (uint64_t)A);
        return 0;
    }
    if (type == A64_COPY || type == RV_COPY) {
        alog(a, "warning: COPY relocation at 0x%" PRIx64 " ignored (no source object)", P);
        return 0;
    }
    if (type == A64_IRELATIVE || type == RV_IRELATIVE) {
        uint64_t res;
        if (call_irelative_value(a, B + (uint64_t)A, &res) != 0) return -1;
        w64(a, m, res);
        return 0;
    }

    if (resolve(a, st, symidx, &S, &weak) != 0) return -1;
    T = S + (uint64_t)A;

    if (a->eh.machine == AOT_EM_AARCH64) {
        switch (type) {
        case A64_ABS64: case A64_GLOB_DAT: case A64_JUMP_SLOT:
            w64(a, m, T); return 0;
        case A64_ABS32:
            if ((int64_t)T < INT32_MIN || (int64_t)T > UINT32_MAX)
                alog(a, "warning: ABS32 truncation at 0x%" PRIx64 " (0x%" PRIx64 ")", P, T);
            w32(a, m, (uint32_t)T); return 0;
        case A64_ABS16:
            w16(a, m, (uint16_t)T); return 0;
        case A64_PREL64:
            w64(a, m, S + (uint64_t)A - P); return 0;
        case A64_PREL32:
            w32(a, m, (uint32_t)(int64_t)(S + (uint64_t)A - P)); return 0;
        case A64_PREL16:
            w16(a, m, (uint16_t)(int64_t)(S + (uint64_t)A - P)); return 0;
        case A64_ADR_PREL_LO21:
            if (a64_patch_adr(a, P, T, 0) != 0) goto overflow;
            return 0;
        case A64_ADR_PREL_PG_HI21: case A64_ADR_PREL_PG_HI21_NC:
            if (a64_patch_adr(a, P, T, 1) != 0) goto overflow;
            return 0;
        case A64_ADD_ABS_LO12_NC:
            if (a64_patch_lo12(a, P, T, 1, 1) != 0) goto overflow;
            return 0;
        case A64_LDST8_ABS_LO12_NC:
            if (a64_patch_lo12(a, P, T, 1, 0) != 0) goto overflow;
            return 0;
        case A64_LDST16_ABS_LO12_NC:
            if (a64_patch_lo12(a, P, T, 2, 0) != 0) goto overflow;
            return 0;
        case A64_LDST32_ABS_LO12_NC:
            if (a64_patch_lo12(a, P, T, 4, 0) != 0) goto overflow;
            return 0;
        case A64_LDST64_ABS_LO12_NC:
            if (a64_patch_lo12(a, P, T, 8, 0) != 0) goto overflow;
            return 0;
        case A64_LDST128_ABS_LO12_NC:
            if (a64_patch_lo12(a, P, T, 16, 0) != 0) goto overflow;
            return 0;
        case A64_CALL26: case A64_JUMP26:
            if (a64_patch_branch(a, P, T) != 0) goto overflow;
            return 0;
        case A64_ADR_GOT_PAGE: {
            uint64_t slot = got_slot(a, symidx, T);
            if (!slot || a64_patch_adr(a, P, slot, 1) != 0) goto overflow;
            return 0;
        }
        case A64_LD64_GOT_LO12_NC: {
            uint64_t slot = 0;
            for (size_t i = 0; i < a->ngots; ++i)
                if (a->gots[i].symidx == symidx) { slot = a->gots[i].addr; break; }
            if (!slot) {
                slot = got_slot(a, symidx, T);
                if (!slot) goto overflow;
            }
            if (a64_patch_lo12(a, P, slot, 8, 0) != 0) goto overflow;
            return 0;
        }
        default: break;
        }
    } else {
        int64_t d = (int64_t)(T - P);
        switch (type) {
        case RV_64: case RV_JUMP_SLOT:
            w64(a, m, T); return 0;
        case RV_32:
            w32(a, m, (uint32_t)T); return 0;
        case RV_32_PCREL:
            w32(a, m, (uint32_t)d); return 0;
        case RV_PCREL_HI20: case RV_GOT_HI20: case RV_HI20: {
            /* HI20 is absolute; PCREL_HI20 / GOT_HI20 are PC-relative. */
            int64_t v = (type == RV_HI20) ? (int64_t)T : d;
            if (type == RV_GOT_HI20) {
                uint64_t slot = got_slot(a, symidx, T);
                if (!slot) goto overflow;
                v = (int64_t)(slot - P);
            }
            if (type != RV_HI20 && !fits(v, 32)) goto overflow;
            uint32_t hi = (uint32_t)((v + 0x800) >> 12) & 0xfffffu;
            w32(a, m, rv_u_set(u32(a, m), hi));
            if (type != RV_HI20) hicache_put(a, r_off, v);
            return 0;
        }
        case RV_PCREL_LO12_I: case RV_PCREL_LO12_S: {
            int64_t v;
            if (!hicache_get(a, (uint64_t)A, &v)) {
                alog(a, "error: PCREL_LO12 at 0x%" PRIx64 " has no matching HI20 (addend %" PRId64 ")",
                     P, A);
                return -1;
            }
            uint32_t lo = (uint32_t)v & 0xfffu;
            if (type == RV_PCREL_LO12_I) w32(a, m, rv_i_set(u32(a, m), lo));
            else                        w32(a, m, rv_s_set(u32(a, m), lo));
            return 0;
        }
        case RV_LO12_I:
            w32(a, m, rv_i_set(u32(a, m), (uint32_t)T & 0xfffu)); return 0;
        case RV_LO12_S:
            w32(a, m, rv_s_set(u32(a, m), (uint32_t)T & 0xfffu)); return 0;
        case RV_BRANCH: {
            if (!fits(d, 13) || (d & 1)) goto overflow;
            w32(a, m, rv_b_set(u32(a, m), d)); return 0;
        }
        case RV_JAL: {
            if (!fits(d, 21) || (d & 1)) {
                uint64_t stub = make_rv_stub(a, T);
                if (!stub) return -1;
                int64_t sd = (int64_t)(stub - P);
                if (!fits(sd, 21) || (sd & 1)) goto overflow;
                alog(a, "JAL out of range at 0x%" PRIx64 ": stub 0x%" PRIx64
                        " -> 0x%" PRIx64, P, stub, T);
                d = sd;
            }
            w32(a, m, rv_j_set(u32(a, m), d)); return 0;
        }
        case RV_CALL: case RV_CALL_PLT: case RV_PLT32: {
            int64_t hi = d;
            if (!fits(d, 32)) {
                uint64_t stub = make_rv_stub(a, T);
                if (!stub) return -1;
                hi = (int64_t)(stub - P);
                if (!fits(hi, 32)) goto overflow;
                alog(a, "CALL out of range at 0x%" PRIx64 ": stub 0x%" PRIx64
                        " -> 0x%" PRIx64, P, stub, T);
            }
            uint32_t hi20 = (uint32_t)((hi + 0x800) >> 12) & 0xfffffu;
            uint32_t lo12 = (uint32_t)hi & 0xfffu;
            uint8_t *m2 = mptr(a, P + 4, 4);
            if (!m2) return -1;
            w32(a, m, rv_u_set(u32(a, m), hi20));
            w32(a, m2, rv_i_set(u32(a, m2), lo12));
            return 0;
        }
        case RV_RVC_BRANCH: {
            if (!fits(d, 9) || (d & 1)) goto overflow;
            uint16_t insn = u16(a, m);
            w16(a, m, (uint16_t)rv_cb_set(insn, d)); return 0;
        }
        case RV_RVC_JUMP: {
            if (!fits(d, 12) || (d & 1)) goto overflow;
            uint16_t insn = u16(a, m);
            w16(a, m, (uint16_t)rv_cj_set(insn, d)); return 0;
        }
        default: break;
        }
    }
    alog(a, "error: unsupported relocation type %u for machine %u at 0x%" PRIx64
            " (symbol %u)", type, a->eh.machine, P, symidx);
    return -1;
overflow:
    alog(a, "error: relocation type %u overflow at 0x%" PRIx64 " (target 0x%" PRIx64
            ", symbol %u)", type, P, T, symidx);
    return -1;
}

/* ---------------------------------------------------- relocation tables -- */

static int apply_table(Aot *a, const uint8_t *tab, size_t count, size_t entsize,
                       int is_rela, uint64_t addr_base, int off_is_vaddr,
                       const SymTab *st)
{
    for (size_t i = 0; i < count; ++i) {
        const uint8_t *r = tab + i * entsize;
        uint64_t r_off = u64(a, r);
        uint64_t r_info = u64(a, r + 8);
        int64_t add = is_rela ? (int64_t)u64(a, r + 16) : 0;
        uint32_t type = (uint32_t)(r_info & 0xffffffffu);
        uint32_t symidx = (uint32_t)(r_info >> 32);
        uint64_t P = off_is_vaddr ? (a->bias + r_off) : (addr_base + r_off);
        if (apply_reloc(a, P, r_off, type, symidx, add, is_rela, st) != 0) return -1;
        ++a->nreloc;
    }
    return 0;
}

static int apply_relr(Aot *a, const uint8_t *tab, size_t count)
{
    uint64_t where = 0;
    for (size_t i = 0; i < count; ++i) {
        uint64_t e = u64(a, tab + 8 * i);
        if (!(e & 1)) {
            where = e;
            uint8_t *m = mptr(a, a->bias + where, 8);
            if (!m) return -1;
            w64(a, m, u64(a, m) + a->bias);
            where += 8;
        } else {
            uint64_t bits = e >> 1;
            uint64_t w = where;
            for (unsigned b = 0; bits; ++b, bits >>= 1) {
                if (bits & 1) {
                    uint8_t *m = mptr(a, a->bias + w + (uint64_t)b * 8, 8);
                    if (!m) return -1;
                    w64(a, m, u64(a, m) + a->bias);
                }
            }
            where = w + 8 * 63;
        }
        ++a->nreloc;
    }
    return 0;
}

static const SymTab *dynsym_for(Aot *a, uint64_t symtab_vaddr)
{
    const SymTab *best = NULL;
    for (size_t i = 0; i < a->nsymtabs; ++i) {
        const Shdr *s = &a->sh[a->symtabs[i].secidx];
        if (s->addr == symtab_vaddr) { best = &a->symtabs[i]; break; }
        if (s->type == AOT_SHT_DYNSYM) best = &a->symtabs[i];
    }
    if (!best && a->nsymtabs) best = &a->symtabs[0];
    return best;
}

static int relocate_dynamic(Aot *a)
{
    const Phdr *dyn = NULL;
    for (size_t i = 0; i < a->phnum; ++i)
        if (a->ph[i].type == AOT_PT_DYNAMIC) { dyn = &a->ph[i]; break; }
    if (!dyn) return 1;        /* 0 = done, 1 = not applicable, -1 = error */

    uint8_t *d = mptr(a, a->bias + dyn->vaddr, (size_t)dyn->filesz);
    if (!d) { alog(a, "error: PT_DYNAMIC is outside the mapping"); return -1; }
    size_t n = (size_t)(dyn->filesz / AOT_DYN_SIZE);
    uint64_t dt_rela = 0, dt_relasz = 0, dt_relaent = AOT_RELA_SIZE;
    uint64_t dt_rel = 0, dt_relsz = 0, dt_relent = AOT_REL_SIZE;
    uint64_t dt_jmprel = 0, dt_pltrelsz = 0, dt_pltrel = 0;
    uint64_t dt_symtab = 0, dt_syment = AOT_SYM_SIZE;
    uint64_t dt_relr = 0, dt_relrsz = 0;
    for (size_t i = 0; i < n; ++i) {
        uint64_t tag = u64(a, d + 16 * i);
        uint64_t val = u64(a, d + 16 * i + 8);
        if (tag == AOT_DT_NULL) break;
        switch (tag) {
        case AOT_DT_RELA: dt_rela = val; break;
        case AOT_DT_RELASZ: dt_relasz = val; break;
        case AOT_DT_RELAENT: dt_relaent = val; break;
        case AOT_DT_REL: dt_rel = val; break;
        case AOT_DT_RELSZ: dt_relsz = val; break;
        case AOT_DT_RELENT: dt_relent = val; break;
        case AOT_DT_JMPREL: dt_jmprel = val; break;
        case AOT_DT_PLTRELSZ: dt_pltrelsz = val; break;
        case AOT_DT_PLTREL: dt_pltrel = val; break;
        case AOT_DT_SYMTAB: dt_symtab = val; break;
        case AOT_DT_SYMENT: dt_syment = val; break;
        case AOT_DT_RELR: dt_relr = val; break;
        case AOT_DT_RELRSZ: dt_relrsz = val; break;
        case AOT_DT_TEXTREL: a->textrel = 1; break;
        case AOT_DT_FLAGS: if (val & AOT_DF_TEXTREL) a->textrel = 1; break;
        default: break;
        }
    }
    if (dt_syment != AOT_SYM_SIZE)
        alog(a, "warning: DT_SYMENT=%" PRIu64 " (expected 24)", dt_syment);
    const SymTab *st = dynsym_for(a, dt_symtab);
    if (!st) { alog(a, "error: DT_SYMTAB present but no symbol table found"); return -1; }
    alog(a, "PT_DYNAMIC: symtab 0x%" PRIx64 " (section %zu, %zu syms), textrel=%d",
         dt_symtab, st->secidx, st->nsyms, a->textrel);

    if (dt_rela && dt_relasz) {
        if (dt_relaent != AOT_RELA_SIZE) { alog(a, "error: bad DT_RELAENT"); return -1; }
        uint8_t *t = mptr(a, a->bias + dt_rela, (size_t)dt_relasz);
        if (!t) { alog(a, "error: DT_RELA outside the mapping"); return -1; }
        if (apply_table(a, t, (size_t)(dt_relasz / dt_relaent), dt_relaent, 1,
                        a->bias, 1, st) != 0) return -1;
    }
    if (dt_rel && dt_relsz) {
        if (dt_relent != AOT_REL_SIZE) { alog(a, "error: bad DT_RELENT"); return -1; }
        uint8_t *t = mptr(a, a->bias + dt_rel, (size_t)dt_relsz);
        if (!t) { alog(a, "error: DT_REL outside the mapping"); return -1; }
        if (apply_table(a, t, (size_t)(dt_relsz / dt_relent), dt_relent, 0,
                        a->bias, 1, st) != 0) return -1;
    }
    if (dt_jmprel && dt_pltrelsz) {
        int rela = (dt_pltrel == AOT_DT_RELA) ||
                   (dt_pltrel == 0 && (a->eh.machine == AOT_EM_AARCH64 ||
                                       a->eh.machine == AOT_EM_RISCV));
        size_t ent = rela ? AOT_RELA_SIZE : AOT_REL_SIZE;
        uint8_t *t = mptr(a, a->bias + dt_jmprel, (size_t)dt_pltrelsz);
        if (!t) { alog(a, "error: DT_JMPREL outside the mapping"); return -1; }
        if (apply_table(a, t, (size_t)(dt_pltrelsz / ent), ent, rela,
                        a->bias, 1, st) != 0) return -1;
    }
    if (dt_relr && dt_relrsz) {
        uint8_t *t = mptr(a, a->bias + dt_relr, (size_t)dt_relrsz);
        if (!t) { alog(a, "error: DT_RELR outside the mapping"); return -1; }
        if (apply_relr(a, t, (size_t)(dt_relrsz / 8)) != 0) return -1;
    }
    return 0;
}

static int relocate_sections(Aot *a)
{
    for (size_t i = 0; i < a->shnum; ++i) {
        const Shdr *s = &a->sh[i];
        if (s->type != AOT_SHT_RELA && s->type != AOT_SHT_REL &&
            s->type != AOT_SHT_RELR) continue;
        if (!range_ok(s->offset, s->size, a->fsz)) {
            alog(a, "warning: relocation section %zu lies outside the file", i); continue;
        }
        size_t tgt = s->info;
        if (tgt >= a->shnum || !a->sec_placed[tgt]) {
            alog(a, "warning: relocation section %zu targets unplaced section %zu", i, tgt);
            continue;
        }
        const SymTab *st = NULL;
        if (s->link < a->shnum) {
            for (size_t k = 0; k < a->nsymtabs; ++k)
                if (a->symtabs[k].secidx == s->link) { st = &a->symtabs[k]; break; }
        }
        if (!st) {
            alog(a, "warning: no symbol table for relocation section %zu", i);
            if (!a->nsymtabs) continue;
            st = &a->symtabs[0];
        }
        const uint8_t *tab = a->file + s->offset;
        int off_is_vaddr = (a->eh.type != AOT_ET_REL);
        uint64_t base = a->sec_abs[tgt];
        if (s->type == AOT_SHT_RELR) {
            if (apply_relr(a, tab, (size_t)(s->size / 8)) != 0) return -1;
        } else {
            int rela = (s->type == AOT_SHT_RELA);
            size_t ent = rela ? AOT_RELA_SIZE : AOT_REL_SIZE;
            if (apply_table(a, tab, (size_t)(s->size / ent), ent, rela,
                            base, off_is_vaddr, st) != 0) return -1;
        }
        alog(a, "section %zu (%s): %" PRIu64 " relocation entries -> %s",
             i, sec_name(a, i), s->size / (s->type == AOT_SHT_RELR ? 8 :
                                          (s->type == AOT_SHT_RELA ? 24 : 16)),
             sec_name(a, tgt));
    }
    return 0;
}

/* ------------------------------------------------------------- mapping -- */

static int build_layout(Aot *a)
{
    a->page = (uint64_t)sysconf(_SC_PAGESIZE);
    if (!a->page) a->page = 4096;

    int nloads = count_loads(a);
    int synth = (a->eh.type == AOT_ET_REL) || (nloads == 0);
    uint64_t minv = UINT64_MAX, maxv = 0;

    if (!synth) {
        for (size_t i = 0; i < a->phnum; ++i) {
            const Phdr *p = &a->ph[i];
            if (p->type != AOT_PT_LOAD) continue;
            if (p->vaddr < minv) minv = p->vaddr;
            if (p->vaddr + p->memsz > maxv) maxv = p->vaddr + p->memsz;
        }
        a->vaddr_base = align_dn(minv, a->page);
        for (size_t i = 0; i < a->shnum; ++i) {
            const Shdr *s = &a->sh[i];
            if (!(s->flags & AOT_SHF_ALLOC) || !s->addr) continue;
            a->sec_vaddr[i] = s->addr;
            a->sec_placed[i] = 1;
            if (s->addr + s->size > maxv) maxv = s->addr + s->size;
        }
    } else {
        a->vaddr_base = 0;
        uint64_t cursor = a->page;   /* keep vaddr 0 as "not mapped" */
        for (size_t i = 0; i < a->shnum; ++i) {
            const Shdr *s = &a->sh[i];
            if (!(s->flags & AOT_SHF_ALLOC)) continue;
            uint64_t al = s->addralign ? s->addralign : 8;
            cursor = align_up(cursor, al);
            a->sec_vaddr[i] = cursor;
            a->sec_placed[i] = 1;
            cursor += s->size;
        }
        maxv = cursor;
        alog(a, "ET_REL / no PT_LOAD: synthesized section addresses from 0x%" PRIx64,
             a->page);
    }

    /* The two appended map sections may have sh_addr == 0 (--no-alloc,
       ET_REL) or lie beyond all PT_LOADs. Give them a home. */
    size_t maps[2] = { a->funcsec, a->helper_sec };
    for (int k = 0; k < 2; ++k) {
        size_t i = maps[k];
        if (i == SIZE_MAX || i >= a->shnum) continue;
        const Shdr *s = &a->sh[i];
        uint64_t al = k == 0 ? 32 : 8;
        if (!a->sec_placed[i] || !a->sec_vaddr[i] ||
            (synth && a->sec_vaddr[i] < a->page)) {
            if (synth) {
                a->sec_vaddr[i] = align_up(maxv, al);
                a->sec_placed[i] = 1;
                maxv = a->sec_vaddr[i] + s->size;
            } else {
                a->sec_vaddr[i] = s->addr ? s->addr : align_up(maxv, al);
                a->sec_placed[i] = 1;
                if (a->sec_vaddr[i] + s->size > maxv)
                    maxv = a->sec_vaddr[i] + s->size;
            }
        }
        if (a->sec_vaddr[i] + s->size > maxv) maxv = a->sec_vaddr[i] + s->size;
    }

    /* Scratch area for stubs / generated GOT slots, inside the same mapping
       so that short PC-relative branches can reach it. */
    uint64_t stub_base = align_up(maxv, 64);
    uint64_t stub_size = 128 * 1024;
    uint64_t end = stub_base + stub_size;
    a->memsz = align_up(end - a->vaddr_base, a->page);
    if (a->memsz == 0 || a->memsz > (uint64_t)SIZE_MAX) {
        alog(a, "error: implausible image size"); return -1;
    }

    void *p = mmap(NULL, (size_t)a->memsz, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
    if (p == MAP_FAILED) {
        alog(a, "error: mmap(%zu) failed: %s", (size_t)a->memsz, strerror(errno));
        return -1;
    }
    a->mem = (uint8_t *)p;
    a->bias = (uint64_t)(uintptr_t)a->mem - a->vaddr_base;
    a->veneer_cur = stub_base;
    a->veneer_end = stub_base + stub_size;

    /* Segment bytes. */
    for (size_t i = 0; i < a->phnum; ++i) {
        const Phdr *ph = &a->ph[i];
        if (ph->type != AOT_PT_LOAD) continue;
        if (!range_ok(ph->offset, ph->filesz, a->fsz) || ph->filesz > ph->memsz) {
            alog(a, "error: PT_LOAD %zu has out-of-range file data", i);
            return -1;
        }
        uint8_t *dst = mptr(a, a->bias + ph->vaddr, (size_t)ph->memsz);
        if (!dst) { alog(a, "error: PT_LOAD %zu is outside the mapping", i); return -1; }
        if (ph->filesz) memcpy(dst, a->file + ph->offset, (size_t)ph->filesz);
    }
    /* Section bytes (also covers .funcmap/.helpermap appended by elf_add_maps). */
    for (size_t i = 0; i < a->shnum; ++i) {
        if (!a->sec_placed[i]) continue;
        const Shdr *s = &a->sh[i];
        if (s->type == AOT_SHT_NOBITS || !s->size) continue;
        if (!range_ok(s->offset, s->size, a->fsz)) {
            alog(a, "warning: section %zu (%s) data outside the file, skipped",
                 i, sec_name(a, i));
            continue;
        }
        uint8_t *dst = mptr(a, a->bias + a->sec_vaddr[i], (size_t)s->size);
        if (!dst) { alog(a, "error: section %zu is outside the mapping", i); return -1; }
        memcpy(dst, a->file + s->offset, (size_t)s->size);
        a->sec_abs[i] = (uint64_t)(uintptr_t)dst;
    }
    if (a->funcsec != SIZE_MAX && a->sec_placed[a->funcsec])
        a->func_addr = a->sec_abs[a->funcsec];
    if (a->textsec != SIZE_MAX && a->sec_placed[a->textsec])
        a->code_addr = a->sec_abs[a->textsec];
    if (!a->code_addr) {
        for (size_t i = 0; i < a->phnum; ++i)
            if (a->ph[i].type == AOT_PT_LOAD && (a->ph[i].flags & AOT_PF_X)) {
                a->code_addr = a->bias + a->ph[i].vaddr; break;
            }
    }
    alog(a, "mapped %zu bytes at 0x%" PRIx64 ", bias 0x%" PRIx64
            ", code 0x%" PRIx64 ", funcmap 0x%" PRIx64,
         (size_t)a->memsz, (uint64_t)(uintptr_t)a->mem, a->bias,
         a->code_addr, a->func_addr);
    return 0;
}

static int apply_protections(Aot *a)
{
    size_t npages = (size_t)(a->memsz / a->page);
    uint8_t *prot = (uint8_t *)calloc(npages ? npages : 1, 1);
    if (!prot) { alog(a, "error: out of memory"); return -1; }
    int rc = -1;
    for (size_t i = 0; i < a->phnum; ++i) {
        const Phdr *p = &a->ph[i];
        if (p->type != AOT_PT_LOAD || !p->memsz) continue;
        uint8_t f = PROT_READ;
        if (p->flags & AOT_PF_W) f |= PROT_WRITE;
        if (p->flags & AOT_PF_X) f |= PROT_EXEC;
        uint64_t lo = align_dn(p->vaddr, a->page);
        uint64_t hi = align_up(p->vaddr + p->memsz, a->page);
        for (uint64_t v = lo; v < hi; v += a->page) {
            size_t k = (size_t)((v - a->vaddr_base) / a->page);
            if (k < npages) prot[k] |= f;
        }
    }
    for (size_t i = 0; i < a->shnum; ++i) {
        if (!a->sec_placed[i]) continue;
        const Shdr *s = &a->sh[i];
        uint8_t f = PROT_READ | PROT_WRITE;
        if (s->flags & AOT_SHF_EXECINSTR) f |= PROT_EXEC;
        if (!(s->flags & AOT_SHF_WRITE)) f &= ~(uint8_t)PROT_WRITE;
        uint64_t lo = align_dn(a->sec_vaddr[i], a->page);
        uint64_t hi = align_up(a->sec_vaddr[i] + s->size, a->page);
        for (uint64_t v = lo; v < hi; v += a->page) {
            size_t k = (size_t)((v - a->vaddr_base) / a->page);
            if (k < npages) prot[k] |= f;
        }
    }
    /* Pages holding only our scratch area / appended maps stay readable. */
    for (size_t k = 0; k < npages; ++k) {
        if (!prot[k]) prot[k] = PROT_READ | PROT_WRITE;
        if (a->textrel) prot[k] |= PROT_WRITE;
    }
    if (a->textrel)
        alog(a, "warning: DF_TEXTREL/DT_TEXTREL set; keeping all pages writable");

    size_t start = 0;
    for (size_t i = 1; i <= npages; ++i) {
        if (i == npages || prot[i] != prot[start]) {
            void *addr = a->mem + start * a->page;
            size_t len = (i - start) * (size_t)a->page;
            int want = prot[start];
            if (mprotect(addr, len, want) != 0) {
                int alt = want & ~PROT_WRITE;
                if (alt != want && mprotect(addr, len, alt) == 0) {
                    alog(a, "warning: W^X policy at 0x%" PRIx64 "; page kept "
                            "non-writable (text relocations already applied)",
                         (uint64_t)(uintptr_t)addr);
                } else {
                    alog(a, "error: mprotect(0x%" PRIx64 ", %zu, %d) failed: %s",
                         (uint64_t)(uintptr_t)addr, len, want, strerror(errno));
                    goto out;
                }
            }
            start = i;
        }
    }
    rc = 0;
out:
    free(prot);
    return rc;
}

/* ------------------------------------------------------------ registry -- */

#define AOT_MAX_IMAGES 64
static struct { uint64_t base; size_t size; } g_images[AOT_MAX_IMAGES];

static void register_image(uint64_t base, size_t size)
{
    for (size_t i = 0; i < AOT_MAX_IMAGES; ++i)
        if (!g_images[i].base) { g_images[i].base = base; g_images[i].size = size; return; }
}

void unload_aot_elf(uint64_t AotCodeBase)
{
    for (size_t i = 0; i < AOT_MAX_IMAGES; ++i) {
        if (!g_images[i].base) continue;
        uint64_t b = g_images[i].base;
        if (AotCodeBase >= b && AotCodeBase - b < g_images[i].size) {
            munmap((void *)(uintptr_t)b, g_images[i].size);
            g_images[i].base = 0;
            g_images[i].size = 0;
            return;
        }
    }
}

/* --------------------------------------------------------------- cleanup -- */

static void free_aot(Aot *a)
{
    free(a->ph); free(a->sh); free(a->sec_vaddr); free(a->sec_abs);
    free(a->sec_placed); free(a->symtabs);
    free(a->helper_idx_addr); free(a->helper_idx_set);
    free(a->names); free(a->hicache); free(a->gots);
    if (a->hrecs) {
        for (size_t i = 0; i < a->nhrecs; ++i) free(a->hrecs[i].name);
        free(a->hrecs);
    }
    free(a->file);
}

/* ------------------------------------------------------------------ API -- */

int load_aot_elf(const char *AotFile, void (*AotLog)(const char *),
                 void *HelperFuncs, size_t HelperFuncsCnt,
                 uint64_t *AotCodeBasePtr, uint64_t *FuncmapRbtreeRootPtr)
{
    Aot a;
    memset(&a, 0, sizeof a);
    int rc = -1;
    a.log = AotLog;
    a.funcsec = a.helper_sec = a.textsec = SIZE_MAX;
    a.helpers = (helper_func_t *)HelperFuncs;
    a.nhelpers = HelperFuncs ? HelperFuncsCnt : 0;

    if (!AotFile || !AotCodeBasePtr || !FuncmapRbtreeRootPtr)
        AOT_ERR(&a, "NULL argument (AotFile / AotCodeBasePtr / FuncmapRbtreeRootPtr)");
    if (HelperFuncsCnt && !HelperFuncs)
        AOT_ERR(&a, "HelperFuncsCnt=%zu but HelperFuncs is NULL", HelperFuncsCnt);
    a.path = strdup(AotFile);
    if (!a.path) AOT_ERR(&a, "out of memory");
    *AotCodeBasePtr = 0;
    *FuncmapRbtreeRootPtr = 0;

    alog(&a, "loading '%s' (%zu helper functions)", AotFile, a.nhelpers);
    if (read_file(&a) != 0) goto fail;
    if (parse_headers(&a) != 0) goto fail;
    if (build_symtabs(&a) != 0) AOT_ERR(&a, "out of memory building symbol tables");
    if (a.nsymtabs == 0)
        alog(&a, "warning: no symbol table found; only RELATIVE/name lookups can resolve");
    /* Locate .text/.funcmap/.helpermap and parse the helper records before
       the layout is built, because the appended map sections need a slot. */
    if (build_helpermap(&a) != 0) goto fail;
    if (build_layout(&a) != 0) goto fail;

    if (a.eh.type != AOT_ET_REL) {
        int dr = relocate_dynamic(&a);
        if (dr == 0) {
            alog(&a, "dynamic relocations: %zu entries applied", a.nreloc);
        } else if (dr == 1) {
            alog(&a, "no usable PT_DYNAMIC; falling back to section relocations");
            if (relocate_sections(&a) != 0) goto fail;
        } else {
            goto fail;
        }
    } else {
        if (relocate_sections(&a) != 0) goto fail;
    }
    if (a.nreloc == 0)
        alog(&a, "warning: no relocation entries were applied");
    if (apply_protections(&a) != 0) goto fail;

    if (!a.code_addr) AOT_ERR(&a, "cannot determine .text / executable segment address");
    if (!a.func_addr)
        alog(&a, "warning: .funcmap missing or empty; FuncmapRbtreeRootPtr = 0");
    else {
        const uint8_t *f = mptr(&a, a.func_addr, 8);
        if (f) {
            uint32_t root = (uint32_t)rdN(f, 4, a.rec_be);
            uint32_t cnt  = (uint32_t)rdN(f + 4, 4, a.rec_be);
            alog(&a, ".funcmap: root index %u, %u nodes at 0x%" PRIx64,
                 root, cnt, a.func_addr);
        }
    }
    alog(&a, "entry point 0x%" PRIx64 ", helpers bound %zu, stubs %zu, done",
         a.bias + a.eh.entry, a.nhelper_hits, a.nstubs);

    *AotCodeBasePtr = a.code_addr;
    *FuncmapRbtreeRootPtr = a.func_addr;
    register_image((uint64_t)(uintptr_t)a.mem, (size_t)a.memsz);
    rc = 0;
    goto done;
fail:
    if (a.mem) munmap(a.mem, (size_t)a.memsz);
done:
    free_aot(&a);
    free(a.path);
    return rc;
}
#endif
