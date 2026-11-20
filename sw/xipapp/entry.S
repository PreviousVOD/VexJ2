#include "cmt.h"
#include "j2_board_irqs.h"

.section .text.start
.align 2
.global _xip_start
_xip_start:
  mov.l stack_top, r15
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
  mov.w r1, @r0
  mov.l timer_status_address, r0
  mov.w @r0, r1
  mov #0x41, r1
  mov.w r1, @r0
  mov.w @r0, r1
  mov.l @r15+, r1
  mov.l @r15+, r0
  rte
  nop

.align 2
timer_count_address:
  .long 0x80710000
timer_enable_address:
  .long CMT_CMSTR_ADDRESS
timer_status_address:
  .long CMT_CMCSR_ADDRESS(0)

.align 4
.global _xip_vectors
_xip_vectors:
  .long _xip_start
  .long (0x00008000 + J2_SRAM_BYTES - 4)
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
  .set xip_vector, 64
  .rept J2_INTC_SOURCE_COUNT
  .if xip_vector == J2_VECTOR_CMT0
  .long _xip_timer_isr
  .elseif xip_vector == J2_VECTOR_CMT1
  .long _xip_cmt1_isr
  .elseif xip_vector == J2_VECTOR_SCI_ERI
  .long _xip_sci_eri_isr
  .elseif xip_vector == J2_VECTOR_SCI_RXI
  .long _xip_sci_rxi_isr
  .elseif xip_vector == J2_VECTOR_SCI_TXI
  .long _xip_sci_txi_isr
  .elseif xip_vector == J2_VECTOR_SCI_BRI
  .long _xip_sci_bri_isr
  .else
  .long xip_halt
  .endif
  .set xip_vector, xip_vector + 1
  .endr

.align 2
stack_top: .long (0x00008000 + J2_SRAM_BYTES - 4)
data_source: .long _data_load
data_start: .long _data_start
data_end: .long _data_end
bss_start: .long _bss_start
bss_end: .long _bss_end
