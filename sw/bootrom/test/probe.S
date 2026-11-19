/* Small upload fixture. Full ISA applications are used by the boot cases and
 * hardware tests. Padding exercises page boundaries and a partial final page. */
.section .text.start
.align 2
.global _xip_start
_xip_start:
  /* BootROM must quiesce receive IRQs before application startup can replace
   * VBR, stack and SRAM. This probe deliberately retains the ROM vectors. */
  stc sr,r0
  and #0xf0,r0
  xor #0xf0,r0
  tst r0,r0
  bf handoff_failed
  mov.l control_address,r1
  mov.b @r1,r0
  tst #0x40,r0
  bf handoff_failed
  mov.l enable_address,r1
  mov.l @r1,r0
  tst r0,r0
  bf handoff_failed
  mov.l status_address,r1
  mov.l data_address,r2
  mov #0x80,r3
  mova message,r0
  mov r0,r4
next_byte:
  mov.b @r4+,r0
  tst r0,r0
  bt finished
wait_space:
  mov.b @r1,r5
  tst r3,r5
  bt wait_space
  mov.b r0,@r2
  mov #0x7f,r0
  mov.b r0,@r1
  bra next_byte
  nop
finished:
  bra finished
  nop
.align 2
handoff_failed:
  bra handoff_failed
  nop
.align 2
control_address: .long 0xff001004
enable_address: .long 0xffffe910
status_address: .long 0xff001008
data_address: .long 0xff001006
message: .asciz "Wukong loader app passed\r\n"
.space 513,0x5a
