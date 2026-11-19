.section .vect, "ax", @progbits
.align 2
.long _coremark_start
.long (0x00008000 + J2_SRAM_BYTES)
