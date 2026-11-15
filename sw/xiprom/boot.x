OUTPUT_FORMAT("elf32-sh")
OUTPUT_ARCH(sh)

MEMORY
{
  ram   : o = 0x00000000, l = 0x7b00
  sram  : o = 0x00008000, l = 0x0800
  stack : o = 0x00007d00, l = 0x0300
}

SECTIONS
{
  .text : {
    *(.vect)
    *(.text)
    *(.rodata*)
  } > ram

  .data : {
    *(.data)
  } > ram

  .bss : {
    *(.bss)
    *(COMMON)
  } > sram

  .stack : {
    _stack = .;
    *(.stack)
  } > stack
}
