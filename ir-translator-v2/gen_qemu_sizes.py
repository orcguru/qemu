#!/usr/bin/env python3
"""
Materialize sizeof(CPUState) / sizeof(CPUArchState) (and optionally field
offsets) for one QEMU build, without hardcoding any number.

Mechanism
---------
1. Read <build-dir>/compile_commands.json and pick a compile command for a
   target-specific .c file (it already carries -DNEED_CPU_H, -I target/<arch>,
   -I <build>/include, the per-target config-target.h, etc.).
2. Compile a tiny probe .c with that *exact* command, only swapping the input
   and -o paths.
3. Read the sizes straight out of the resulting .o's ELF symbol table.
   Each probe is a tentative definition -> .bss -> symbol size == sizeof(T),
   and .bss costs zero bytes in the file.

This never executes anything, so it is safe for cross builds, and it does not
require the QEMU binary to carry debug info.

Usage
-----
  gen_qemu_sizes.py --build-dir /path/to/qemu/build --target i386 \
                    --out qemu_cpu_sizes.h
  gen_qemu_sizes.py --build-dir ... --target i386 \
                    --offset 'CPUArchState:regs[0]' \
                    --offset 'CPUArchState:xmm_regs[0]'

Requires: python3 + the compiler recorded in compile_commands.json.
No binutils/nm needed (ELF parsing is done here).
"""

import argparse
import json
import os
import shlex
import struct
import subprocess
import sys
import tempfile

PROBE_PREFIX = "qemu_size_probe_"
OFF_PREFIX = "qemu_off_probe_"


# --------------------------------------------------------------------------
# minimal ELF symbol-size reader
# --------------------------------------------------------------------------
def elf_symbol_sizes(path):
    """{symbol_name: size} for defined symbols, from the ELF symtab."""
    with open(path, "rb") as f:
        data = f.read()

    if data[:4] != b"\x7fELF":
        raise SystemExit(f"{path}: not an ELF file")

    ei_class, ei_data = data[4], data[5]
    if ei_class not in (1, 2):
        raise SystemExit(f"{path}: unknown ELF class {ei_class}")
    is64 = ei_class == 2
    end = "<" if ei_data == 1 else ">"

    if is64:
        (e_shoff,) = struct.unpack_from(end + "Q", data, 0x28)
        e_shentsize, e_shnum, e_shstrndx = struct.unpack_from(end + "HHH", data, 0x3A)
    else:
        (e_shoff,) = struct.unpack_from(end + "I", data, 0x20)
        e_shentsize, e_shnum, e_shstrndx = struct.unpack_from(end + "HHH", data, 0x2E)

    def shdr(i):
        off = e_shoff + i * e_shentsize
        if is64:
            name, typ, _flags, _addr, offset, size, link, _info, _align, entsize = \
                struct.unpack_from(end + "IIQQQQIIQQ", data, off)
        else:
            name, typ, _flags, _addr, offset, size, link, _info, _align, entsize = \
                struct.unpack_from(end + "IIIIIIIIII", data, off)
        return name, typ, offset, size, link, entsize

    # section name table
    _, _, shstr_off, shstr_size, _, _ = shdr(e_shstrndx)
    shstr = data[shstr_off:shstr_off + shstr_size]

    symtab = None
    strtab = None
    for i in range(e_shnum):
        name, typ, offset, size, link, entsize = shdr(i)
        nm = shstr[name:shstr.index(b"\0")].decode("utf-8", "replace")
        if typ == 2:  # SHT_SYMTAB
            symtab = (offset, size, entsize, link)
    if symtab is None:
        raise SystemExit(f"{path}: no .symtab (object stripped?)")

    off, size, entsize, link = symtab
    _, _, stroff, strsize, _, _ = shdr(link)
    strtab = data[stroff:stroff + strsize]

    out = {}
    n = size // (entsize or 1)
    for k in range(n):
        o = off + k * entsize
        if is64:
            st_name, st_info, _other, st_shndx, _val, st_size = \
                struct.unpack_from(end + "IBBHQQ", data, o)
        else:
            st_name, _val, st_size, st_info, _other, st_shndx = \
                struct.unpack_from(end + "IIIBBH", data, o)
        if st_shndx == 0:  # SHN_UNDEF
            continue
        nm = strtab[st_name:strtab.index(b"\0", st_name)].decode("utf-8", "replace")
        out[nm] = st_size
    return out


# --------------------------------------------------------------------------
# locate a usable compile command
# --------------------------------------------------------------------------
def pick_command(build_dir, target, prefer=None):
    cdb = os.path.join(build_dir, "compile_commands.json")
    if not os.path.exists(cdb):
        raise SystemExit(
            f"{cdb} not found.\n"
            f"  Generate it with:  ninja -C {build_dir} -t compdb > {cdb}\n"
            f"  (or configure meson with -Dgenerate_compile_commands=true)")
    with open(cdb) as f:
        entries = json.load(f)

    def args_of(e):
        if "arguments" in e:
            return list(e["arguments"])
        return shlex.split(e["command"])

    want = [f"target{os.sep}{target}{os.sep}", f"target/{target}/"]
    cands = []
    for e in entries:
        src = e.get("file", "")
        if not src.endswith(".c"):
            continue
        if not any(w in src for w in want):
            continue
        a = args_of(e)
        # must be a real compile (-c), not a link
        if "-c" not in a:
            continue
        cands.append((src, a, e.get("directory", build_dir)))

    if not cands:
        raise SystemExit(f"no target/{target}/*.c entry in {cdb}")

    if prefer:
        for src, a, d in cands:
            if prefer in os.path.basename(src):
                return src, a, d
    # prefer a "central" file: it is most likely to pull in cpu.h
    for name in ("cpu.c", "helper.c", "translate.c", "machine.c", "op_helper.c"):
        for src, a, d in cands:
            if os.path.basename(src) == name:
                return src, a, d
    return cands[0]


PROBE_TEMPLATE = """\
/* Generated by gen_qemu_sizes.py -- do not edit. */
#include "qemu/osdep.h"
#include "cpu.h"
#include "hw/core/cpu.h"

/* Tentative definitions: each lands in .bss, so the ELF symbol size is
   exactly sizeof(T) while costing zero bytes in the object file.
   +1 keeps the array non-empty for a zero offset. */
%(probes)s
"""


def build_probe( offsets):
    lines = [
        "char %sCPUState[sizeof(CPUState)];" % PROBE_PREFIX,
        "char %sCPUArchState[sizeof(CPUArchState)];" % PROBE_PREFIX,
    ]
    for i, (ty, field) in enumerate(offsets):
        lines.append("char %s%d[offsetof(%s, %s) + 1u]; /* %s.%s */"
                     % (OFF_PREFIX, i, ty, field, ty, field))
    return PROBE_TEMPLATE % {"probes": "\n".join(lines)}


def compile_probe(args, cwd, src_path, obj_path):
    """Run the recorded command, swapping input and -o."""
    new = []
    skip_next = False
    saw_input = False
    for i, a in enumerate(args):
        if skip_next:
            skip_next = False
            continue
        if a == "-o":
            new += ["-o", obj_path]
            skip_next = True
            continue
        if a.startswith("-o") and len(a) > 2:
            new.append("-o" + obj_path)
            continue
        if a.endswith(".c") and not a.startswith("-") and not saw_input:
            # the recorded source file
            new.append(src_path)
            saw_input = True
            continue
        new.append(a)
    if not saw_input:
        new.append(src_path)

    r = subprocess.run(new, cwd=cwd, stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT, text=True)
    if r.returncode != 0 or not os.path.exists(obj_path):
        sys.stderr.write("probe compile failed:\n")
        sys.stderr.write("  cwd : %s\n" % cwd)
        sys.stderr.write("  cmd : %s\n" % " ".join(shlex.quote(x) for x in new))
        sys.stderr.write(r.stdout)
        raise SystemExit(1)
    return new


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--build-dir", required=True)
    ap.add_argument("--target", required=True, help="e.g. i386, x86_64, arm, aarch64")
    ap.add_argument("--out", default="qemu_cpu_sizes.h")
    ap.add_argument("--from-source", default=None,
                    help="basename of the .c whose flags to reuse (default: cpu.c)")
    ap.add_argument("--offset", action="append", default=[],
                    metavar="CPUArchState:field",
                    help="also emit offsetof(); repeatable")
    ap.add_argument("--keep", action="store_true", help="keep the probe .c/.o")
    a = ap.parse_args()

    offsets = []
    for spec in a.offset:
        if ":" not in spec:
            raise SystemExit("--offset expects TYPE:FIELD, got %r" % spec)
        ty, field = spec.split(":", 1)
        offsets.append((ty.strip(), field.strip()))

    src, args, cwd = pick_command(a.build_dir, a.target, a.from_source)

    tmpdir = tempfile.mkdtemp(prefix="qemu-sizes-") if a.keep else None
    work = tmpdir or tempfile.mkdtemp(prefix="qemu-sizes-")
    probe_c = os.path.join(work, "probe.c")
    probe_o = os.path.join(work, "probe.o")
    with open(probe_c, "w") as f:
        f.write(build_probe(offsets))

    compile_probe(args, cwd, probe_c, probe_o)
    sizes = elf_symbol_sizes(probe_o)

    def need(sym):
        if sym not in sizes:
            raise SystemExit(
                "symbol %s missing from %s\n"
                "  (check that the probe compiled against the right target headers)"
                % (sym, probe_o))
        return sizes[sym]

    s_cs = need(PROBE_PREFIX + "CPUState")
    s_env = need(PROBE_PREFIX + "CPUArchState")

    guard = "QEMU_CPU_SIZES_H"
    lines = [
        "/* Generated by gen_qemu_sizes.py -- do not edit, regenerate instead. */",
        "/*",
        " * source  : %s" % src,
        " * build   : %s" % os.path.abspath(a.build_dir),
        " * target  : %s" % a.target,
        " */",
        "#ifndef %s" % guard,
        "#define %s" % guard,
        "",
        "#define QEMU_SIZEOF_CPUSTATE      %d" % s_cs,
        "#define QEMU_SIZEOF_CPUARCHSTATE  %d" % s_env,
        "",
        "/* QEMU guarantees this (see QEMU_BUILD_BUG_ON in target-info-stub.c): */",
        "/*   offsetof(ArchCPU, parent_obj) == 0                                */",
        "/*   offsetof(ArchCPU, env)       == sizeof(CPUState)                  */",
        "#define QEMU_OFFSETOF_ENV_IN_ARCHCPU  QEMU_SIZEOF_CPUSTATE",
        "",
    ]
    if offsets:
        lines.append("/* offsetof() values */")
        for i, (ty, field) in enumerate(offsets):
            v = sizes[OFF_PREFIX + str(i)] - 1
            key = field.replace("[", "_").replace("]", "").replace(".", "_")
            lines.append("#define QEMU_OFFSET_%s_%s  %d" % (ty, key, v))
        lines.append("")

    # compile-time self-check you can paste into the translator
    lines += [
        "/* Optional: paste into your translator to fail fast on a stale build.",
        " * Requires the values above to be re-generated whenever QEMU changes. */",
        "#if defined(__cplusplus) || defined(__STDC_VERSION__)",
        "#define QEMU_SIZES_CHECK(cs, env)                                  \\",
        "    _Static_assert((cs) == QEMU_SIZEOF_CPUSTATE,                   \\",
        "                   \"sizeof(CPUState) changed -- regenerate\");     \\",
        "    _Static_assert((env) == QEMU_SIZEOF_CPUARCHSTATE,              \\",
        "                   \"sizeof(CPUArchState) changed -- regenerate\")",
        "#endif",
        "",
        "#endif /* %s */" % guard,
    ]

    with open(a.out, "w") as f:
        f.write("\n".join(lines) + "\n")

    print("reused flags from : %s" % src)
    print("sizeof(CPUState)     = %d  (0x%x)" % (s_cs, s_cs))
    print("sizeof(CPUArchState) = %d  (0x%x)" % (s_env, s_env))
    for i, (ty, field) in enumerate(offsets):
        print("offsetof(%s, %-20s) = %d" % (ty, field, sizes[OFF_PREFIX + str(i)] - 1))
    print("wrote %s" % a.out)
    if a.keep:
        print("probe kept in %s" % work)
    elif not a.keep:
        import shutil
        shutil.rmtree(work, ignore_errors=True)


if __name__ == "__main__":
    main()
