/* Real-INTC boundary programs. The simulator owns request levels and records
 * external bus transactions; it does not inject exception descriptors. */
.section .text
.org 0
.long start, 0x9000
.org 0x2c
.long high_handler
.org 0x100
.long low_handler, high_handler
.org 0x700
#if CASE == 5
.long 0xf0
#else
.long 0
#endif
.long 0
.org 0x1000
.global start, boundary, after_boundary, unmasked, branch_target, low_handler, high_handler, low_wait
start:
  mov.l intc_base,r1
  mov #3,r0
  mov.l r0,@(16,r1)
  mov.l ipr_base,r1
  mov #0xa6,r0
  extu.b r0,r0
  mov.l r0,@r1
  mov.l report_base,r8
#if CASE == 6 || CASE == 7
  /* Leave the reset mask high until the target SR load. */
#else
  mov #0,r0
  ldc r0,sr
#endif
  mov #1,r0
  mov.l r0,@r8
  .rept 8
  nop
  .endr
#if CASE == 4
  mov #0xf0,r0
  extu.b r0,r0
boundary:
  ldc r0,sr
#elif CASE == 5 || CASE == 7
  mov.l sr_address,r4
boundary:
  ldc.l @r4+,sr
#elif CASE == 6
  mov #0,r0
boundary:
  ldc r0,sr
#elif CASE == 8
  mov #0x35,r0
boundary:
  bra branch_target
  mov.l r0,@(8,r8)
  .word 0xffff
branch_target:
  nop
#elif CASE == 9
  mov.l tas_address,r4
boundary:
  tas.b @r4
  bf failed
#else
boundary:
  nop
#endif
#if CASE != 8
branch_target:
#endif
after_boundary:
#if CASE == 4 || CASE == 5
  stc sr,r0
  mov.l r0,@(52,r8)
  /* A stale candidate must not enter with the newly raised SR.I. */
  nop
  nop
  nop
  mov #0,r0
  ldc r0,sr
#endif
unmasked:
  mov.l @(4,r8),r0
  tst r0,r0
  bt unmasked
  mov #0x77,r0
  mov.l r0,@(40,r8)
finished:
  bra finished
  nop
failed:
  mov #0x55,r0
  mov.l r0,@(40,r8)
  bra finished
  nop
.align 2
intc_base: .long 0xffffe900
ipr_base: .long 0xffffea00
report_base: .long 0x600
sr_address: .long 0x700
tas_address: .long 0x704
.org 0x1800
low_handler:
  mov.l r0,@-r15
  mov.l r1,@-r15
  mov.l r2,@-r15
  mov.l r3,@-r15
  mov.l report_low,r1
  stc sr,r0
  mov.l r0,@(12,r1)
  mov.l @(16,r15),r0
  mov.l r0,@(16,r1)
  mov.l @(20,r15),r0
  mov.l r0,@(20,r1)
  mov.l @(48,r1),r0
  add #1,r0
  mov.l r0,@(48,r1)
#if CASE == 1 || CASE == 2
low_wait:
  mov.l @(24,r1),r0
  tst r0,r0
  bt low_wait
#else
low_wait:
#endif
#if CASE == 3
  cmp/eq #2,r0
  bf low_return
#endif
  mov #1,r0
  mov.l r0,@(4,r1)
low_return:
  mov.l @r15+,r3
  mov.l @r15+,r2
  mov.l @r15+,r1
  mov.l @r15+,r0
  rte
  nop
.align 2
report_low: .long 0x600
.org 0x2000
high_handler:
  mov.l r0,@-r15
  mov.l r1,@-r15
  mov.l report_high,r1
  stc sr,r0
  mov.l r0,@(28,r1)
  mov.l @(8,r15),r0
  mov.l r0,@(32,r1)
  mov.l @(12,r15),r0
  mov.l r0,@(36,r1)
  mov #1,r0
  mov.l r0,@(24,r1)
  mov.l @r15+,r1
  mov.l @r15+,r0
  rte
  nop
.align 2
report_high: .long 0x600
