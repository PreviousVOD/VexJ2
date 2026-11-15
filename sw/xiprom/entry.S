.section .vect
.align 2
.long _start
.long 0x0000fffc
.rept 62
.long boot_halt
.endr

.section .text
.align 2
.global _start
_start:
  mov.l boot_main_pointer, r0
  jsr @r0
  nop

boot_halt:
  bra boot_halt
  nop

.align 2
boot_main_pointer:
  .long _boot_main
