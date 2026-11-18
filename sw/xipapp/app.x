OUTPUT_FORMAT("elf32-sh")
OUTPUT_ARCH(sh)
ENTRY(_xip_start)

MEMORY
{
  app : o = DEFINED(LOAD_ADDRESS) ? LOAD_ADDRESS : 0x10000020, l = 0x00400000
}

SECTIONS
{
  /* Stronger alignment of a later input section must not move the image entry. */
  .text ORIGIN(app) : {
    *(.text.start)
    *(.text)
    *(.rodata*)
  } > app
  .data : { *(.data) } > app
  .bss : { *(.bss) *(COMMON) } > app
  ASSERT(_xip_start == ORIGIN(app), "Application entry does not match its load address")
}
