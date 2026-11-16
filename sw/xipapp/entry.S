.section .text.start
.align 2
.global _xip_start
_xip_start:
  mov.l xip_vectors_pointer, r0
  ldc r0, vbr
  mov.l xip_main_pointer, r0
  jsr @r0
  nop
xip_halt:
  bra xip_halt
  nop

.align 2
xip_main_pointer:
  .long _xip_main
xip_vectors_pointer:
  .long _xip_vectors

.global _sdram_test_function
_sdram_test_function:
  mov r4, r0
  add r5, r0
  rts
  nop

.global _xip_timer_isr
_xip_timer_isr:
  mov.l r0, @-r15
  mov.l r1, @-r15
  mov.l timer_count_address, r0
  mov.l @r0, r1
  add #1, r1
  mov.l r1, @r0
  mov.l timer_enable_address, r0
  mov #0, r1
  mov.l r1, @r0
  mov.l timer_value_address, r0
  mov.l r1, @r0
  mov.l @r15+, r1
  mov.l @r15+, r0
  rte
  nop

.align 2
timer_count_address:
  .long 0x80710000
timer_enable_address:
  .long 0xff003000
timer_value_address:
  .long 0xff003008

.align 4
.global _xip_vectors
_xip_vectors:
  .long _xip_start
  .long 0x0000fffc
  .rept 2
  .long xip_halt
  .endr
  .long _isa_illegal
  .long xip_halt
  .long _isa_slot_illegal
  .long xip_halt
  .long xip_halt
  .long _isa_address_error
  .rept 54
  .long xip_halt
  .endr
  .long _xip_timer_isr
