OUTPUT_FORMAT("elf32-sh")
OUTPUT_ARCH(sh)
ENTRY(_start)
MEMORY
{
  rom : ORIGIN = 0x00000000, LENGTH = 0x8000
  sram : ORIGIN = 0x00008000, LENGTH = J2_SRAM_BYTES
}
SECTIONS
{
  .text : { KEEP(*(.vect)) *(.text*) *(.rodata*) . = ALIGN(4); } > rom
  .data : {
    _data_start = .; *(.data*) . = ALIGN(4); _data_end = .;
  } > sram AT > rom
  _data_load = LOADADDR(.data);
  .bss (NOLOAD) : {
    _bss_start = .; *(.bss*) *(COMMON) . = ALIGN(4); _bss_end = .;
  } > sram
  _stack_top = ORIGIN(sram) + LENGTH(sram) - 4;
  ASSERT(_bss_end <= _stack_top - 1024, "Boot ROM data overlaps stack")
}
