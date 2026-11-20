# J2PIO GPIO and edge interrupts

[SoC register map](soc.md#32-bit-gpio) · [APB4](apb.md) · [INTC](ppb-intc.md)

`j2.periph.J2PIO` exposes 32 logical `TriStateArray` pins, a 32-bit APB4 port
and one registered interrupt output. Both board SoCs map it at `0xff000000`.
Tang exposes all pins; Wukong exposes pins 0–15 and 24–31, keeping 16–23 tied
to zero and physically separate from the SF3 pins.

## Registers

All registers reset to zero. All reads are side-effect-free. Each write honors
PSTRB; a zero-strobe write changes nothing. Reserved aligned offsets read zero
and ignore writes, while unaligned APB accesses return PSLVERR.

| Offset | Register | Access and meaning |
|---|---|---|
| `0x00` | CR | RW bit 0 IE; other bits read zero and ignore writes |
| `0x04` | DIR | RW, one bit per pin: 0 input, 1 output |
| `0x08` | DATA | Read synchronized pad inputs; write output-configured pins only |
| `0x0c` | ISR | One sticky pending flag per pin; W1C |
| `0x10` | ICR0 | RW modes for pins 0–15, two bits per pin |
| `0x14` | ICR1 | RW modes for pins 16–31, two bits per pin |

Pin n uses ICR[n/16] bits `2*(n%16)+1 : 2*(n%16)`: 00 disabled, 01 rising,
10 falling, 11 reserved/disabled. The reserved encoding retains its written
value. DIR and DATA use architectural bit n for pin n, independent of byte
order. The SH-2 BE32 bridge places the low byte at register address+3 and the
low halfword at address+2.

DATA reads the actual sampled pad, including when configured as an output;
it does not read the output latch. A write to an input pin is ignored and
cannot preload its output latch. The latch retains its value across direction
changes, so switching to output drives zero after reset or its previously
stored output value. An ISR write clears only the selected one bits; it cannot
set a flag. Software should snapshot ISR, service those sources and write the
snapshot back to acknowledge them.

## Sampling and delivery

All pads pass through two PCLK synchronizer stages. DATA reads and edge sensing
use that same sampled value. A previous-sample register tracks inputs even
when interrupts are disabled. Startup history is seeded after synchronization
so an initially high pin is not mistaken for a rising edge. No debounce is
provided, and pulses shorter than the sampling interval are not guaranteed to
be captured. Multiple edges on a pending pin coalesce into one flag.

Edges set ISR only when DIR is input and ICR selects that edge. CR.IE does not
gate capture. The aggregate condition is:

```text
IE && any(ISR[n] && !DIR[n] && ICR[n] in {rising, falling})
```

The output registers this condition, one PCLK after flag/control updates.
Changing IE, DIR or ICR retains pending flags; re-enabling a pending source
therefore reasserts the request. Register writes take effect after their clock
edge, so an edge coincident with configuration writes uses the old DIR/ICR.
A new event wins over a simultaneous W1C. Reads do not arm clearing.

Each board appends `PIO` to its default interrupt map: source 6, vector 70.
Firmware uses generated `J2_IRQ_PIO` / `J2_VECTOR_PIO`, sets an INTC priority and
enable, configures input modes, clears stale ISR bits and enables CR.IE.
INTC acceptance does not acknowledge PIO: the ISR must clear the peripheral
flag. `sw/include/pio.h` defines the register interface.

## Migration and validation

This replaces the old J2Pio ABI; there are no legacy register aliases. Native
SoC firmware must rebuild with DIR at +4 and DATA at +8. The original VHDL
reference platform retains its separate ABI through the test-ROM compatibility
header; only native-SoC test-ROM builds select `J2_NATIVE_PIO`.

`J2PIOSpec` checks register strobes, pin readback, input-write suppression,
direction retention, all 32 pins and modes, masked capture, pending retention,
startup seeding and W1C/edge collisions. `BoardSocSpec` injects edges into both
actual SoCs and verifies firmware ISR delivery, acknowledgement and retriggering
with default and reordered source maps. Wukong tests also drive the logical
hole inputs and verify they remain disconnected.

Physical input-edge qualification requires an external stimulus or loopback
fixture. Board boot smoke tests do not establish external pulse-width limits.

## Validation record (2026-11-20)

The full Scala suite passes 148 tests, with 40 host-tool tests. Focused PIO and
both-board ISR regressions also pass after restoring the original formatting.
CPU/RTE/interrupt tests, the native Tang test ROM, all three Tang XIP boot/upload
cases and all four Wukong cold/warm/upload/checksum cases pass.

| Board | Clock | Setup slack | Hold slack |
|---|---:|---:|---:|
| Tang Primer | 32 MHz | 3.320 ns | 0.135 ns |
| Wukong v1 | 72 MHz | 0.372 ns | 0.068 ns |

Both boards pass volatile JTAG programming, application-flash upload with a
backup of affected sectors, the full XIP/ISA application and a separate fresh
FPGA download/boot. Configuration flash is untouched. These hardware runs
validate SoC integration; GPIO edge injection is covered by simulation, not
an external physical stimulus.

Evidence is in `build/pio-full-tests.log`, `build/pio-after-stash-tests.log`,
`build/pio-host-tests.log`, `build/pio-cpu-sim.log`, `build/pio-wukong-sim.log`
and `build/pio-validation/`. The latter contains Tang boot simulation results,
both boards' upload/fresh-boot records, backups and bitstream/application hashes.
