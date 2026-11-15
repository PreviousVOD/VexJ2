OUTPUT_FORMAT("elf32-sh")
OUTPUT_ARCH(sh)

MEMORY
{
  xip : o = 0x10000010, l = 0x003ffff0
}

SECTIONS
{
  .text : {
    *(.text.start)
    *(.text)
    *(.rodata*)
  } > xip
  .data : { *(.data) } > xip
  .bss : { *(.bss) *(COMMON) } > xip
}
