#include "cmt.h"

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
  mov.l vectors_address, r0
  ldc r0, vbr
  mov.l main_address, r0
  jsr @r0
  nop
5:
  bra 5b
  nop
.align 2
stack_top: .long (0x00008000 + J2_SRAM_BYTES)
mask_interrupts: .long 0x000000f0
data_source: .long _data_load
data_start: .long _data_start
data_end: .long _data_end
bss_start: .long _bss_start
bss_end: .long _bss_end
main_address: .long _main

vectors_address: .long coremark_vectors

/* Extend CMT0 across 16-bit rollovers. No benchmark working register is clobbered. */
coremark_cmt_isr:
  mov.l r0, @-r15
  mov.l r1, @-r15
  mov.l overflow_address, r0
  mov.l @r0, r1
  add #1, r1
  mov.l r1, @r0
  mov.l cmt_csr_address, r0
  mov.w @r0, r1
  mov #0x43, r1
  mov.w r1, @r0
  mov.w @r0, r1
  mov.l @r15+, r1
  mov.l @r15+, r0
  rte
  nop
.align 2
overflow_address: .long _cmt_overflows
cmt_csr_address: .long CMT_CMCSR_ADDRESS(0)
.align 4
coremark_vectors:
  .rept 64
  .long 5b
  .endr
  .long coremark_cmt_isr
