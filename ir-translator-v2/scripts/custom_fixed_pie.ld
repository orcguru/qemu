
SECTIONS
{
  . = SIZEOF_HEADERS;

  /* ---- read-only / executable part (goes into the first PT_LOAD) ---- */
  .interp            : { *(.interp) }
  .note.gnu.build-id : { *(.note.gnu.build-id) }
  .note.gnu.property : { *(.note.gnu.property) }   /* AArch64 BTI/PAC notes */
  .gnu.hash          : { *(.gnu.hash) }
  .hash              : { *(.hash) }
  .dynsym            : { *(.dynsym) }
  .dynstr            : { *(.dynstr) }
  .gnu.version       : { *(.gnu.version) }
  .gnu.version_d     : { *(.gnu.version_d) }
  .gnu.version_r     : { *(.gnu.version_r) }
  .rela.dyn          : { *(.rela.dyn) }
  .rela.plt          : { *(.rela.plt) }
  .plt               : { *(.plt) *(.iplt) *(.plt.got) }
  .text : {
    *(.text)
    *(.text.trampoline)
    *(.text.helper)
    *(.text.declare_only)
  }
  .rodata            : { *(.rodata) }
  .eh_frame          : { *(.eh_frame) }
  .gcc_except_table  : { *(.gcc_except_table) }

  /* ---- writable part: must start on a fresh page ---- */
  . = ALIGN(CONSTANT (MAXPAGESIZE));

  .got               : { *(.got) *(.got.plt) }
  .preinit_array     : { *(.preinit_array) }
  .init_array        : { *(.init_array) }
  .fini_array        : { *(.fini_array) }
  .data              : { *(.data) }
  .bss               : { *(.bss) }
  .dynamic           : { *(.dynamic) }

  /* ---- non-allocatable metadata (no PT_LOAD) ---- */
  .comment           : { *(.comment) }
  .note.GNU-stack    : { *(.note.GNU-stack) }
}
