.section .text.start
.align 2
.global _xip_start
_xip_start:
  mov.l xip_main_pointer, r0
  jsr @r0
  nop
xip_halt:
  bra xip_halt
  nop

.align 2
xip_main_pointer:
  .long _xip_main

.global _sdram_test_function
_sdram_test_function:
  mov r4, r0
  add r5, r0
  rts
  nop
