# Core-private PPB and interrupt controller

[CPU architecture](cpu-architecture.md) · [APB4](apb.md) · [SoC reference](soc.md)

Each core owns a data-only private peripheral bus (PPB) at
`0xffffe000–0xffffefff`. Its INTC occupies `0xffffe900–0xffffeaff`.
`J2PpbPlugin` routes these data accesses locally; they never reach the SoC
matrix. Instruction fetches into PPB fault locally, without adding a pipeline
stage to ordinary instruction fetch. Unassigned PPB addresses fault.

The controller uses NVIC-style enable/pending aliases with SH-2 priority and
exception entry. It does not emulate a particular Renesas register layout.
`IntcConfig(peripheralCount)` supports 0–192 held-level peripheral sources.
Source n uses vector 64+n; NMI uses vector 11. The core retains 8-bit vectors.
The register banks reserve space for 256 sources, with unused fields reading
zero. GPIO edge sensing, external IRQ/PINT registers, multicore messaging and
SH-2A register banks are outside this controller.

## Register map

All registers are 32 bits; offsets are relative to INTC base `0xffffe900`.
Control banks reserve eight words each, independent of the configured count.

| Offset | Register | Read | Write |
|---|---|---|---|
| `0x000` | NMI control | Bit 0: synchronized pin; bit 1: edge selection | Bit 1: 0 falling edge (reset), 1 rising edge; other bits ignored |
| `0x010 + 4*w`, `w=0..7` | ISER[w] | Enable bitmap | One sets enable; zero has no effect |
| `0x030 + 4*w`, `w=0..7` | ICER[w] | Same enable bitmap | One clears enable; zero has no effect |
| `0x050 + 4*w`, `w=0..7` | ISPR[w] | Effective pending bitmap | One sets software pending; zero has no effect |
| `0x070 + 4*w`, `w=0..7` | ICPR[w] | Same effective pending bitmap | One clears software pending; zero has no effect |
| `0x100 + 4*r`, `r=0..31` | IPR[r] | Eight 4-bit priority fields | Ordinary read/write for implemented sources |
| Other offsets in the window | Reserved | Zero | Ignored |

ISER/ICER alias one enable bitmap, and ISPR/ICPR expose one pending bitmap;
they are not four independent state arrays. Enable, software pending and
priority storage reset to zero. NMI is always enabled and has no bit in these
banks. Unimplemented source bits and priority fields are read-only zero,
including unused fields in a partially populated word.

```text
IRQ n:             word = n / 32, bit = n % 32
priority for IRQ n: IPR[n / 8], bits [4*(n % 8)+3 : 4*(n % 8)]
vector for IRQ n:   64 + n
```

For six sources, only bits 0–5 in word zero of each control bank and six nibbles
in IPR[0] are implemented. At the current maximum, control words 0–5 and IPR
words 0–23 are implemented. Control words 6–7 and IPR words 24–31 reserve the
future 64 sources. With count zero, all source registers read zero; NMI works.

Use aligned 32-bit CPU accesses for this register interface. Reject byte,
halfword and misaligned accesses; no old Renesas width contract is retained.
Honor APB4 PSTRB on writes: expand each strobe to its eight data bits before
applying set/clear masks or priority updates. Zero strobes change nothing.
Bit numbering refers to the architectural 32-bit register value; use the
existing SH-2 BE32 bridge lane mapping. Reads have no side effects. Valid word
accesses to reserved locations succeed without bus errors.

## Pending and arbitration

Effective pending is the peripheral request OR software pending. A source is
eligible when enabled, its priority is nonzero, and its priority exceeds SR.I.
Higher priorities win; equal priorities select the lowest source index.
ISPR can pend a disabled or masked source. ICPR and CPU acceptance clear only
software pending: firmware must clear the peripheral's own interrupt flag.
A simultaneous software set wins over an acceptance clear.

A balanced arbiter registers its candidate. Acceptance rechecks the live
request, enable, priority and SR.I so a stale candidate cannot enter after a
management write or mask change. The CPU accepts at legal instruction
boundaries, respecting faults, delay slots and atomic sequences. Accepted
vector and entry mask remain stable through exception entry. There is no
active bitmap or automatic tail chaining. RTE can retrigger a held request.

NMI has a synchronized pin, selectable edge and sticky pending latch. The
detector seeds itself after reset to avoid a false startup edge; tie an unused
pin high. A new edge wins over acceptance. NMI bypasses SR.I but still respects
instruction atomicity and delay slots, and enters with SR.I=15.
Ordinary sources follow a held-level contract in the core clock domain;
integrations must synchronize asynchronous sources and retain short events.

## Firmware

Board SoCs own source wiring and ordering. Both current profiles list CMT0,
CMT1, SCI_ERI, SCI_RXI, SCI_TXI, SCI_BRI and PIO. PIO uses vector 70 in the
default maps; its peripheral owns edge sensing and W1C pending flags. Generated `j2_board_irqs.h`
provides source indices and vector constants; do not hard-code that order in
portable drivers. `sw/include/intc.h` supplies reset, enable/disable and
priority helpers, using register definitions generated from `IntcRegisters`.

Configure with interrupts masked: reset the controller, install handlers at
`VBR + 4*vector`, clear peripheral flags, set priorities, then enable sources
and lower SR.I. Enable and priority both reset to zero. The application and
CoreMark use CMT0 at priority 14. Production BootROM polls the SCIF FIFO and
does not enable UART RX interrupts. The optional RX ISR driver and its vector
startup live under `sw/bootrom/test/` for interrupt regressions.

Standalone generation, from `spinal/`:

```sh
../tools/local/bin/sbt -batch 'runMain j2.Generate_Intc 6 ../build/intc CMT0 CMT1 SCI_ERI SCI_RXI SCI_TXI SCI_BRI'
```

## Validation

`make spinal-test` covers PPB routing and execution rejection, aligned-word
access rules, reserved registers, source-count boundaries, APB strobes,
priority ties, pending races, stale candidates, NMI, SLEEP/RTE, fault precedence
and interrupt boundaries. `BoardSocSpec` exercises both real SoCs with default
and reordered sources and relocated peripherals. `J2BootUartIrqSpec` retains
optional ISR tests alongside the production polling driver test.

The shared XIP application checks INTC and instruction boundaries on simulator
and FPGA. See [SCI validation](sci.md) for FIFO, UART stress and current board
runs, and [CoreMark](coremark.md) for timer-interrupt benchmarking.
