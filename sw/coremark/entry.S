.section .text.start
.align 2
.global _coremark_start
_coremark_start:
  mov.l stack_top, r15
  mov.l mask_interrupts, r0
  ldc r0, sr
  mov.l data_source, r0
  mov.l data_start, r1
  mov.l data_end, r2
1:
  cmp/hs r2, r1
  bt 2f
  mov.l @r0+, r3
  mov.l r3, @r1
  add #4, r1
  bra 1b
  nop
2:
  mov.l bss_start, r1
  mov.l bss_end, r2
  mov #0, r3
3:
  cmp/hs r2, r1
  bt 4f
  mov.l r3, @r1
  add #4, r1
  bra 3b
  nop
4:
  mov.l main_address, r0
  jsr @r0
  nop
5:
  bra 5b
  nop
.align 2
stack_top: .long 0x00010000
mask_interrupts: .long 0x000000f0
data_source: .long _data_load
data_start: .long _data_start
data_end: .long _data_end
bss_start: .long _bss_start
bss_end: .long _bss_end
main_address: .long _main
