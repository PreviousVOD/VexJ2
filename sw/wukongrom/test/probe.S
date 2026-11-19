/* Small upload fixture. Full ISA applications are used by the boot cases and
 * hardware tests. Padding exercises page boundaries and a partial final page. */
.section .text.start
.align 2
.global _xip_start
_xip_start:
  mov.l status_address,r1
  mov.l data_address,r2
  mov.l available_mask,r3
  mova message,r0
  mov r0,r4
next_byte:
  mov.b @r4+,r0
  tst r0,r0
  bt finished
wait_space:
  mov.l @r1,r5
  tst r3,r5
  bt wait_space
  mov.l r0,@r2
  bra next_byte
  nop
finished:
  bra finished
  nop
.align 2
status_address: .long 0xff001004
data_address: .long 0xff001000
available_mask: .long 0x00ff0000
message: .asciz "Wukong loader app passed\r\n"
.space 513,0x5a
