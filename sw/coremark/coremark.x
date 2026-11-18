OUTPUT_FORMAT("elf32-sh")
OUTPUT_ARCH(sh)
ENTRY(_coremark_start)
MEMORY
{
  xip : ORIGIN = 0x10000020, LENGTH = 0x000fffe0
  sram : ORIGIN = 0x00008000, LENGTH = 0x00006000
}
SECTIONS
{
  .text : { KEEP(*(.text.start)) *(.text*) *(.rodata*) . = ALIGN(4); } > xip
  .data : {
    _data_start = .; *(.data*) . = ALIGN(4); _data_end = .;
  } > sram AT > xip
  _data_load = LOADADDR(.data);
  .bss (NOLOAD) : {
    _bss_start = .; *(.bss*) *(COMMON) . = ALIGN(4); _bss_end = .;
  } > sram
  /* Upper 8 KiB of the 32 KiB SRAM is reserved for the stack. */
  ASSERT(_bss_end <= 0x0000e000, "CoreMark data overlaps stack")
}
