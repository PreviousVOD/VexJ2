# J2SCI asynchronous serial interface

`j2.periph.J2SCI` implements one channel using the SH7124/SH7125 SCI register
layout (hardware manual section 12), at the existing SoC address `0xff001000`.
It replaces `J2Uart` and its FIFO register interface. Firmware must use the new
SCI byte-register driver; binaries built for the old UART map are incompatible.

## Registers and supported modes

All registers are eight bits wide, at even byte offsets. In each aligned 32-bit
APB word the registers occupy bits 31:24 and 15:8. The intervening odd bytes read
zero and ignore writes. PSTRB qualifies each written byte. Reads have no side
effects, including SCRDR reads. Unmapped or unaligned APB word accesses return
PSLVERR. Naturally aligned CPU byte, halfword and word transfers use the bridge's
normal BE32 lane mapping.

| Offset | Register | Reset | Writable fields |
| --- | --- | --- | --- |
| `0x00` | SCSMR | `00` | CHR, PE, OE, STOP, CKS[1:0] (mask `7b`) |
| `0x02` | SCBRR | `ff` | All bits |
| `0x04` | SCSCR | `00` | TIE, RIE, TE, RE, TEIE (mask `f4`) |
| `0x06` | SCTDR | `00` | Transmit data |
| `0x08` | SCSSR | `84` | TDRE/RDRF/ORER/FER/PER: W0C; TEND: read-only |
| `0x0a` | SCRDR | `00` | Read-only receive data |
| `0x0c` | SCSDCR | `f2` | DIR[3]; remaining bits fixed at `f2` |
| `0x0e` | SCSPTR | `00` readback | EIO[7], write-only SPB0DT[0] (resets to 1) |

SCSMR.C/A and MP, SCSCR.MPIE and CKE[1:0], SCSSR.MPB/MPBT, and
SCSPTR.SPB1IO/SPB1DT are **hard-wired to zero**. Writes cannot enable synchronous,
external-clock or multiprocessor operation. All reserved bits are fixed at their
documented values. SCSPTR's write-only data bits read deterministically as zero
(the manual leaves their read values undefined). There is no SCK pin or pin mux.
SPB0DT controls TX break while TE is zero; it does not affect active transmission.

Supported framing is 7/8 data bits, even/odd/no parity and one/two transmit stop
bits. Reception checks the first stop bit, as documented. DIR selects MSB-first
for eight-bit frames; seven-bit frames are always LSB-first.

## Clock, buffering and flags

The enclosing APB clock is PCLK/Pφ. The baud period is
`32 * (SCBRR + 1) * 4^CKS` PCLK cycles. No generated clock domain is used. RXD
passes through a synchronizer and is sampled at bit centers after start-bit
validation. Frame settings are captured at the start of each character.
Configure the baud/framing with TE/RE disabled and allow at least one bit period
before enabling them, following the manual's initialization sequence.

There is one TDR plus a transmit shift register. Writing SCTDR does not submit
a character: software must also clear TDRE. Moving TDR into the shift register
sets TDRE again. TEND indicates the final stop bit when no character is queued;
software that disables TE must allow that stop bit to finish. TE=0 aborts TX and
forces TDRE/TEND to one. There are no additional transmit or receive FIFOs.

SCRDR holds one character. Software reads SCRDR and clears RDRF explicitly.
A new character while RDRF is set raises ORER and preserves the old SCRDR.
Parity/framing errors retain the received byte when SCRDR was free but do not set
RDRF. ORER/FER/PER block subsequent reception until cleared. RE=0 aborts a receive
in progress without clearing SCRDR or status flags.

Flags follow the agreed ordinary W0C policy: a selected zero clears, a one
preserves and cannot set an inactive flag. No read-history latch is implemented.
A simultaneous hardware event wins over its software clear. TEND is read-only;
a new transmit submission clears it. Clearing a flag uses an inverse-bit mask so
other pending flags are preserved.

Four interrupt outputs, registered by one PCLK, are exposed in ascending order:

| Output bit | Source | Condition |
| --- | --- | --- |
| 0 | ERI | RIE and any ORER/FER/PER |
| 1 | RXI | RIE and RDRF and not EIO |
| 2 | TXI | TIE and TDRE |
| 3 | TEI | TEIE and TEND |

The current SoC console polls these registers. Routing the four sources through
the planned private INTC remains subsequent work; they are not ORed into a
single invented SCI vector.

## Software and validation

`sw/include/sci.h` defines the byte register map. The shared boot ROM/XIP/CoreMark
UART driver selects a representable BRR/CKS, submits TX through TDRE, and handles
RX flags explicitly. Its initialization drains the previous transmitter before
reconfiguration. Both boards retain nominal 19,200 baud: actual baud is about
19,230.8 at 32 MHz (BRR=51) and 72 MHz (BRR=116). The accelerated Wukong boot
simulation uses exactly 1,125,000 baud (BRR=1), within SCI's PCLK/32 limit.

`J2SCISpec` checks reset and hard-wired fields, strobes, read/error behavior,
transmit submission and double buffering, all clock divisors, framing/direction,
overrun and parity/framing recovery, W0C, EIO and all four IRQ outputs.
The board boot/loader simulations exercise the shared byte driver over AHB/APB
and real serial pins. The reference-core functional console also uses the SCI
register handshake, with immediate TX completion; it is not a serial timing model.

The loader's constant timeouts are converted to CMT ticks at compile time.
Per-byte runtime 64-bit division needlessly delayed servicing SCI. The accelerated
simulator allows 4,000 PCLK cycles between characters for CPU service without a FIFO; ordinary board uploads remain at 19,200 baud.

The combined regression passes 102 Scala tests, all three Tang boot cases and
all four Wukong boot cases, plus both CoreMark CRC seed sets with measured times
above ten seconds. Both FPGA RTL generators pass. FPGA synthesis, timing and
board execution have not been rerun for this migration. Detailed results and
the unrelated baseline reference-ROM timeout are in [CMT validation notes](cmt.md#validation-notes).
