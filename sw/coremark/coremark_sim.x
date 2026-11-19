OUTPUT_FORMAT("elf32-sh")
OUTPUT_ARCH(sh)
ENTRY(_coremark_start)
MEMORY
{
  xip : ORIGIN = 0x00000000, LENGTH = 0x00008000
  sram : ORIGIN = 0x00008000, LENGTH = J2_SRAM_BYTES - 0x2000
}
SECTIONS
{
  .vect : { *(.vect) . = 0x00000100; } > xip
  .text : { KEEP(*(.text.start)) *(.text*) *(.rodata*) . = ALIGN(4); } > xip
  .data : {
    _data_start = .; *(.data*) . = ALIGN(4); _data_end = .;
  } > sram AT > xip
  _data_load = LOADADDR(.data);
  .bss (NOLOAD) : {
    _bss_start = .; *(.bss*) *(COMMON) . = ALIGN(4); _bss_end = .;
  } > sram
  ASSERT(_bss_end <= (0x00008000 + J2_SRAM_BYTES - 0x2000), "CoreMark data overlaps stack")
}
