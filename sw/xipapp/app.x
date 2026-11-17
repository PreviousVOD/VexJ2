OUTPUT_FORMAT("elf32-sh")
OUTPUT_ARCH(sh)
ENTRY(_xip_start)

MEMORY
{
  xip : o = 0x10000010, l = 0x003ffff0
}

SECTIONS
{
  /* The packed image header loads and enters at 0x10000010. Stronger alignment
     of a later input section must not move the beginning of the image. */
  .text ORIGIN(xip) : {
    *(.text.start)
    *(.text)
    *(.rodata*)
  } > xip
  .data : { *(.data) } > xip
  .bss : { *(.bss) *(COMMON) } > xip
  ASSERT(_xip_start == ORIGIN(xip), "XIP entry does not match the image header")
}
