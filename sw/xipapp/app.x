OUTPUT_FORMAT("elf32-sh")
OUTPUT_ARCH(sh)
ENTRY(_xip_start)

MEMORY
{
  sram : ORIGIN = 0x00008000, LENGTH = DEFINED(J2_SRAM_BYTES) ? J2_SRAM_BYTES : 0x8000
  app : o = 0x10000020, l = 0x00400000
}

SECTIONS
{
  /* Stronger alignment of a later input section must not move the image entry. */
  .text ORIGIN(app) : {
    *(.text.start)
    *(.text)
    *(.rodata*)
  } > app
  .data : {
    _data_start = .; *(.data*) . = ALIGN(4); _data_end = .;
  } > sram AT > app
  _data_load = LOADADDR(.data);
  .bss (NOLOAD) : {
    _bss_start = .; *(.bss*) *(COMMON) . = ALIGN(4); _bss_end = .;
  } > sram
  ASSERT(_bss_end <= ORIGIN(sram) + LENGTH(sram) - 1024, "Application data overlaps stack")
  ASSERT(_xip_start == ORIGIN(app), "Application entry does not match its load address")
}
