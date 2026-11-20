.section .vect
.align 2
.long _start
.long _stack_top
/* BootROM polls with interrupts masked; unexpected vectors halt safely. */
.rept 254
.long boot_halt
.endr

.section .text
.align 2
.global _start
_start:
  mov #0xf0, r0
  extu.b r0, r0
  ldc r0, sr
  mov #0, r0
  ldc r0, vbr
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
  mov.l boot_main_pointer, r0
  jsr @r0
  nop

boot_halt:
  bra boot_halt
  nop

.align 2
boot_main_pointer:
  .long _boot_main

.align 2
data_source: .long _data_load
data_start: .long _data_start
data_end: .long _data_end
bss_start: .long _bss_start
bss_end: .long _bss_end
