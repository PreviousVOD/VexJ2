/* Board/simulator regressions. Leaf routines use only caller-saved registers.
 * The atomic blob is position independent and runs from both SRAM and SDRAM. */
.section .text
.align 2
.global _isa_atomic_begin, _isa_atomic_end
_isa_atomic_begin:
  mov #1,r5
  mov #0,r1
  mov.l r1,@r4
  tas.b @r4
  bf 9f
  mov #2,r5
  mov.b @r4,r1
  mov #-128,r2
  cmp/eq r1,r2
  bf 9f
  mov #3,r5
  tas.b @r4
  bt 9f
  mov #4,r5
  mov #17,r2
  mov.l r2,@r4
  mov r4,r0
  mov #34,r1
  .word 0x2123 /* cas.l r2,r1,@r0 */
  bf 9f
  mov #5,r5
  cmp/eq r2,r1
  bf 9f
  mov #34,r6
  mov.l @r4,r3
  cmp/eq r6,r3
  bf 9f
  mov #6,r5
  mov #51,r1
  mov #17,r2
  .word 0x2123
  bt 9f
  cmp/eq r6,r1
  bf 9f
  mov.l @r4,r3
  cmp/eq r6,r3
  bf 9f
  mov #0,r0
  rts
  nop
9:
  mov r5,r0
  rts
  nop
.align 2
_isa_atomic_end:

.global _isa_forward
_isa_forward:
  mov #7,r0
  mov.l r0,@r4
  mov.l @r4,r1
  add #5,r1
  mov r1,r2
  cmp/eq r1,r2
  bf 9f
  mov #12,r3
  cmp/eq r3,r2
  bf 9f
  /* T forwarding, carry/borrow, and a taken branch's single delay slot. */
  mov #-1,r1
  mov #0,r2
  sett
  addc r1,r2
  bf 9f
  tst r2,r2
  bf 9f
  mov #0,r2
  mov #0,r1
  sett
  subc r1,r2
  bf 9f
  mov #-1,r3
  cmp/eq r3,r2
  bf 9f
  mov #0,r0
  bra 1f
  add #1,r0
  add #64,r0
1:
  cmp/eq #1,r0
  bf 9f
  /* J2 SHAD/SHLD must handle a negative shift of exactly 32. */
  mov #-32,r1
  mov #-1,r2
  .word 0x421c /* shad r1,r2 */
  cmp/eq r3,r2
  bf 9f
  .word 0x421d /* shld r1,r2 */
  tst r2,r2
  bf 9f
  mov #0,r0
  rts
  nop
9:
  mov #1,r0
  rts
  nop

/* Input: MACH, MACL, operand A, operand B, SR.S.
 * Output: MACH, MACL, final operand pointers. */
.macro mac_test name, instruction
.global _\name
_\name:
  stc sr,r7
  mov.l @r4,r0
  lds r0,mach
  mov.l @(4,r4),r0
  lds r0,macl
  mov.l @(16,r4),r0
  ldc r0,sr
  mov r4,r5
  add #8,r5
  mov r4,r6
  add #12,r6
  \instruction @r5+,@r6+
  sts mach,r0
  mov.l r0,@(20,r4)
  sts macl,r0
  mov.l r0,@(24,r4)
  mov.l r5,@(28,r4)
  mov.l r6,@(32,r4)
  ldc r7,sr
  rts
  nop
.endm
mac_test isa_macl, mac.l
mac_test isa_macw, mac.w

/* Exception context at 0x9000: expected PC, observed PC, SR, vector, count.
 * Repair the frame to the test's continuation so a bad PC is reported rather
 * than repeatedly faulting. Original frame contents are recorded first. */
.macro exception_entry name, vector
.global _\name
_\name:
  mov.l r0,@-r15
  mov #\vector,r0
  bra isa_exception
  nop
.endm
exception_entry isa_address_error, 9
exception_entry isa_illegal, 4
exception_entry isa_slot_illegal, 6
isa_exception:
  mov.l r1,@-r15
  mov.l r2,@-r15
  mov.l context_address,r1
  mov.l r0,@(12,r1)
  mov.l @(12,r15),r0
  mov.l r0,@(4,r1)
  mov.l @(16,r15),r0
  mov.l r0,@(8,r1)
  mov.l @(16,r1),r0
  add #1,r0
  mov.l r0,@(16,r1)
  mov.l @r1,r0
  mov.l r0,@(12,r15)
  mov.l @r15+,r2
  mov.l @r15+,r1
  mov.l @r15+,r0
  rte
  nop
.align 2
context_address: .long 0x9000

.macro fault_test name, instruction
.global _\name
_\name:
  mov.l 2f,r1
  mov.l r1,@r4
  mov #77,r0
  mov.l @(20,r4),r1
  mov.l @r1,r2
  \instruction
1:
  rts
  nop
.align 2
2: .long 1b
.endm
fault_test isa_bad_long, "mov.l @r2,r0"
fault_test isa_bad_word, "mov.w @r2,r0"
fault_test isa_bad_store_long, "mov.l r0,@r2"
fault_test isa_bad_store_word, "mov.w r0,@r2"
fault_test isa_bad_postinc, "mov.l @r2+,r0"
fault_test isa_bus_error, "mov.l @r2,r0"

.global _isa_delay_fault
_isa_delay_fault:
  mov.l 2f,r1
  mov.l r1,@r4
  mov #77,r0
  mov.l @(24,r4),r2
  bra 1f
  mov.l @r2,r0
  mov #-1,r0
1:
  rts
  nop
.align 2
2: .long 1b

.global _isa_fetch_error
_isa_fetch_error:
  mov.l 2f,r1
  mov.l r1,@r4
  mov #77,r0
  mov.l @(24,r4),r2
  jmp @r2
  nop
1:
  rts
  nop
.align 2
2: .long 1b

/* In a delay slot PC is branch destination + 2, rounded down for MOV.L. */
.global _isa_pc_relative
_isa_pc_relative:
  bra 1f
  .word 0xd001 /* (target + 2) & ~3, plus displacement 4 */
  .long 0xdeadbeef
.align 2
1:
  rts
  nop
  .long 0x13579bdf

/* Failed memory loads must not overwrite special registers. */
.macro special_fault name, reg, load
.global _\name
_\name:
  mov.l 2f,r1
  mov.l r1,@r4
  mov #77,r0
  lds r0,\reg
  mov.l @(20,r4),r1
  mov.l @r1,r2
  \load @r2+,\reg
1:
  sts \reg,r0
  rts
  nop
.align 2
2: .long 1b
.endm
special_fault isa_bad_mach, mach, lds.l
special_fault isa_bad_macl, macl, lds.l

.global _isa_bad_sr
_isa_bad_sr:
  mov.l 2f,r1
  mov.l r1,@r4
  mov #77,r0
  mov.l @(20,r4),r1
  mov.l @r1,r2
  ldc.l @r2+,sr
1:
  rts
  nop
.align 2
2: .long 1b
