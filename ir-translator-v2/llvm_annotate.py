#!/usr/bin/env python3
"""
llvm_annotate.py -- turn !tcg.op metadata into readable ';' comment separators.

    ./llvm_annotate.py tb.ll -o tb.pretty.ll
    ./llvm_annotate.py tb.ll --map tb.tcgmap        # fall back to !dbg lines
    ./llvm_annotate.py tb.ll --clean -o tb.ll       # strip the metadata back out

The output is still *valid* LLVM IR (comments are ignored by the parser), so
you can feed it straight to opt/llc.

Why this exists: LLVM IR has no comment field, so the translator carries the
TCG provenance as !tcg.op metadata.  This script renders it as:

    ; ===== TCG [42] add_i64 rax, rbx, rdx =====
      %t42.rbx.stack.val = load i64, ptr %rbx.stack, align 8, !tcg.op !5
      ...
"""

import argparse
import re
import sys
from collections import OrderedDict

# !5 = !{!"[42] add_i64  rax, rbx, rdx"}
MD_TEXT = re.compile(r'^!(\d+)\s*=\s*!\{!?"(.*)"\}\s*$')
# one level of indirection: !7 = !{!5}
MD_REF = re.compile(r'^!(\d+)\s*=\s*!\{!(\d+)\}\s*$')
# !12 = !DILocation(line: 43, column: 0, scope: !3)
MD_LOC = re.compile(r'^!(\d+)\s*=\s*!DILocation\(line:\s*(\d+)')
# instruction carrying the tag
OP_ON_LINE = re.compile(r'!tcg\.op\s+!(\d+)')
DBG_ON_LINE = re.compile(r'!dbg\s+!(\d+)')


def unescape(s):
    """LLVM prints non-printable bytes as \\XX; undo the ones we care about."""
    out, i = [], 0
    while i < len(s):
        if s[i] == '\\' and i + 2 < len(s) and s[i + 1:i + 3].isalnum():
            try:
                out.append(chr(int(s[i + 1:i + 3], 16)))
                i += 3
                continue
            except ValueError:
                pass
        out.append(s[i])
        i += 1
    return ''.join(out)


def load_map(path):
    """tb.tcgmap: '<index>\\t<text>' -- index == TCG op index."""
    m = {}
    try:
        with open(path, encoding='utf-8', errors='replace') as f:
            for line in f:
                parts = line.rstrip('\n').split('\t', 1)
                if len(parts) == 2:
                    try:
                        m[int(parts[0])] = parts[1]
                    except ValueError:
                        pass
    except OSError as e:
        print('llvm_annotate: %s' % e, file=sys.stderr)
    return m


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('input')
    ap.add_argument('-o', '--output')
    ap.add_argument('--map', help='tb.tcgmap, for resolving !dbg line numbers')
    ap.add_argument('--line-offset', type=int, default=1,
                    help='op_index = !dbg line - OFFSET (default 1, matching '
                         'tcg_tag_begin which emits line = index + 1)')
    ap.add_argument('--clean', action='store_true',
                    help='remove !tcg.op from the emitted lines')
    ap.add_argument('--no-stats', action='store_true')
    args = ap.parse_args()

    with open(args.input, encoding='utf-8', errors='replace') as f:
        lines = f.read().splitlines()

    tcgmap = load_map(args.map) if args.map else {}

    # ---- pass 1: collect metadata -------------------------------------
    text_of, ref_of, line_of = {}, {}, {}
    for ln in lines:
        m = MD_TEXT.match(ln)
        if m:
            text_of[m.group(1)] = unescape(m.group(2))
            continue
        m = MD_REF.match(ln)
        if m:
            ref_of[m.group(1)] = m.group(2)
            continue
        m = MD_LOC.match(ln)
        if m:
            line_of[m.group(1)] = int(m.group(2))

    def resolve(mdnum):
        for _ in range(8):                       # follow !{!N} chains
            if mdnum in text_of:
                return text_of[mdnum]
            if mdnum in ref_of:
                mdnum = ref_of[mdnum]
                continue
            if mdnum in line_of:
                idx = line_of[mdnum] - args.line_offset
                if idx in tcgmap:
                    return '[%d] %s' % (idx, tcgmap[idx])
            return None
        return None

    NOT_INSTR = ('define', 'declare', '}', '{', '!', 'target', 'source_filename',
                 'attributes', 'module')

    def looks_like_instruction(ln):
        s = ln.strip()
        if not s or s.startswith(NOT_INSTR):
            return False
        if s.endswith(':') and ' ' not in s:      # a label
            return False
        return True

    # ---- pass 2: annotate ---------------------------------------------
    out, prev, counts = [], object(), OrderedDict()
    for ln in lines:
        m = OP_ON_LINE.search(ln)
        if m is None and tcgmap and looks_like_instruction(ln):
            m = DBG_ON_LINE.search(ln)
        cur = m.group(1) if m else None
        if cur is not None and cur != prev:
            label = resolve(cur) or 'op %s' % cur
            out.append('; ' + '=' * 8 + ' TCG ' + label + ' ' + '=' * 8)
        if cur is not None:
            counts[resolve(cur) or cur] = counts.get(resolve(cur) or cur, 0) + 1
            if args.clean:
                ln = OP_ON_LINE.sub('', ln).rstrip().rstrip(',').rstrip()
        prev = cur if cur is not None else prev
        out.append(ln)

    text = '\n'.join(out) + '\n'
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(text)
    else:
        sys.stdout.write(text)

    if not args.no_stats:
        print('llvm_annotate: %d TCG groups, %d tagged instructions'
              % (len(counts), sum(counts.values())), file=sys.stderr)
        for k, v in list(counts.items())[:10]:
            print('  %4d instrs  %s' % (v, k), file=sys.stderr)


if __name__ == '__main__':
    main()
