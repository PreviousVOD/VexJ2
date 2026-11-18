.section .text
.align 2
.global _ddr_stack_probe
_ddr_stack_probe:
  mov r15,r2
  mov r5,r15
  mov.l r4,@-r15
  mov.l @r15+,r0
  mov r2,r15
  rts
  nop
