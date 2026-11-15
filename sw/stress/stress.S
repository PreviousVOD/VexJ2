! Lockstep stress program: loops the original J2 CPU self-tests forever.
! (testmov is left out: it loads VBR with test patterns, so interrupts taken
! inside it would vector through garbage.)
! Every exception / interrupt vector points to an RTE handler, so random
! events injected by the testbench return to the interrupted code; the reset
! vectors restart the program. Each pass writes a counter to the PIO port.

        .section .vect, "ax"
        .align 2
        .long _start, _stack_top, _start, _stack_top
        .rept 60
        .long _isr
        .endr

        .text
        .align 2
        .global _start
_start:
        mov.l   stack_k, r15
        mov     #0, r0
        mov.l   counter_k, r1
        mov.l   r0, @r1
loop:
        mov.l   testbra_k, r0
        jsr     @r0
        nop
        mov.l   testmov2_k, r0
        jsr     @r0
        nop
        mov.l   testalu_k, r0
        jsr     @r0
        nop
        mov.l   testshift_k, r0
        jsr     @r0
        nop
        mov.l   testmul_k, r0
        jsr     @r0
        nop
        mov.l   testmulconf_k, r0
        jsr     @r0
        nop
        mov.l   testdiv_k, r0
        jsr     @r0
        nop
        mov.l   testmacw_k, r0
        jsr     @r0
        nop
        mov.l   testmacl_k, r0
        jsr     @r0
        nop
        ! TAS.B (locked read-modify-write) on a scratch byte
        mov.l   scratch_k, r1
        mov     #0, r0
        mov.b   r0, @r1
        tas.b   @r1
        ! pass counter -> PIO
        mov.l   counter_k, r1
        mov.l   @r1, r0
        add     #1, r0
        mov.l   r0, @r1
        mov.l   pio_k, r1
        mov.l   r0, @r1
        bra     loop
        nop

_isr:
        rte
        nop

        .align 2
stack_k:        .long _stack_top
counter_k:      .long _counter
scratch_k:      .long _scratch
pio_k:          .long 0xff000000
testbra_k:      .long _testbra
testmov2_k:     .long _testmov2
testalu_k:      .long _testalu
testshift_k:    .long _testshift
testmul_k:      .long _testmul
testmulconf_k:  .long _testmulconf
testdiv_k:      .long _testdiv
testmacw_k:     .long _testmacw
testmacl_k:     .long _testmacl

        .data
        .align 2
_counter:       .long 0
_scratch:       .long 0
        ! working RAM used by the self-test routines (main.c: char ram0[256])
        .global _ram0
        .align 4
_ram0:  .space 256
