OUTPUT_FORMAT("elf32-sh")
OUTPUT_ARCH(sh)
ENTRY(_start)
MEMORY { ram : o = 0x00000000, l = 0x7000 }
SECTIONS {
  .text : { *(.vect) *(.text) *(.rodata*) } > ram
  .data : { *(.data) } > ram
  .bss  : { *(.bss) *(COMMON) } > ram
  _stack_top = 0x7ffc;
}
