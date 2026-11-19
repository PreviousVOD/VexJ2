# J2CMT compare match timer

`j2.periph.J2CMT` follows the SH7124/SH7125 CMT register layout and counter
behavior (hardware manual section 14). Its SoC address remains `0xff003000`.
This replaces J2Timer's incompatible four-register, 32-bit timer interface.

The APB clock is PCLK/Pφ. A free-running nine-bit divider produces clock enables
at PCLK/8, /32, /128 and /512. Both channels select independently and use the
same PCLK domain. Starting/stopping a counter does not reset the divider phase.
There is no clock input or configurable timer frequency independent of PCLK.
The SoC does not implement the Renesas CPG module-standby register; the block is
accessible after reset and both STR bits reset to zero.

See the [SoC register table](soc.md#compare-match-timer) and shared software
header `sw/include/cmt.h` for offsets, reset values and masks. Reserved bits read
zero, writes are ignored, and the unused halfword at offset 0x0e reads zero.
Unmapped or unaligned APB word addresses return PSLVERR. APB PSTRB qualifies each
written byte, including packed longword writes to two adjacent registers.

On a selected clock tick, equality of CMCNT and CMCOR clears the counter and
sets CMF. Equality takes effect on the tick **after** the counter reached the
compare value, giving period CMCOR+1 ticks (section 14.4.2). Compare logic also
operates while STR is zero (section 14.5.5). Changing CMCOR does not implicitly
clear CMCNT or CMF. Changing STR or CMIE does not clear CMF.

Counter update precedence follows sections 14.5.2–14.5.4:

1. Compare-match clear, even if software writes the counter on the same edge.
2. Counter write; a byte write also suppresses increment of the untouched byte.
3. Increment when started and a selected clock tick occurs.

CMF uses the agreed ordinary write-zero-to-clear behavior. Writing one preserves
the flag and cannot set a zero flag; reads do not arm clears. A simultaneous new
match wins over a software clear. The Renesas manual's read/clear collision note
(14.2.2 note 2) is not implemented as read-history tracking. Each output CMI[n]
is a registered CMIE[n] && CMF[n], one PCLK behind status changes.

Boot ROM uses a free-running /512 channel and accumulates modular 16-bit deltas
while polling UART, handling timeouts longer than one wrap. Constant timeout
values are converted to timer ticks at compile time so each received character
does not require 64-bit division. It must poll more
often than one counter period. CoreMark extends /512 with a rollover ISR and
converts the accumulated hardware ticks to microseconds outside the timed region;
its reporting API still uses Timer Hz = 1000000. The rollover ISR runs within
the measured interval, so old benchmark results have a different timer overhead.
CoreMark installs its vector table and preserves working registers in that ISR.
The normal benchmark still defaults to 300 iterations and requires ten measured
seconds for a reportable result.

`J2CMTSpec` covers both channels, all four dividers, packed and byte register
writes, zero strobes, periodic compare timing, stopped equality, W0C, registered
IRQs and counter-write collisions. The shared XIP application tests CPU subword
accesses, CMI0 entry/rearm/SLEEP wake, and channel-1 polling. Boot/loader simulations
exercise timeout rollover. The reference-core testbench has a matching CMT
functional model. INTC routing of CMI0/CMI1 to vectors 184/188 is subsequent work;
the current SoC still routes CMI0 to vector 64, priority 14.

## Validation notes

Peripheral and regression logs are in `build/cmt-validation/` (CMT before the
SCI migration) and `build/sci-validation/` (combined CMT/SCI). The combined Scala
suite passes 102 tests; host tools pass 30 tests, and `make peripheral-model-test`
checks the reference testbench's CMT/SCI register behavior.

The reference VHDL core completed a 300-iteration performance-seed CRC check
using the new CMT model: 4.972256 measured seconds, including several 16-bit
rollovers. This short reference run is a functional check, not a reportable
CoreMark score. Its RTE regression also passes. The separate legacy
`reference-verif` test-ROM case times out at three million cycles; the unchanged
HEAD peripheral model reproduces the identical timeout and transaction counts.

Both board FPGA RTL generators accept the new peripherals. These checks do not
constitute post-route timing or FPGA hardware validation.

The full SoC/XIP checks also pass both CoreMark seed CRC sets: performance at
300 iterations measured **34.747184 s**; validation at 100 iterations measured
**11.621744 s**. The shorter validation count was used only for this functional
regression; the production default remains 300 for both seeds. Both completed
runs exceed ten seconds. The initial validation-300 process was intentionally
replaced by validation-100; `build/sci-validation/coremark-functional-results.json`
records the completed pair. The simulation cycle limit is now two billion so
the default 300-iteration run is not truncated by the old one-billion limit.

All three Tang boot cases (reset, cold boot, upload) and all four Wukong cases
(cold XIP, warm XIP, upload/error recovery, corrupt-image rejection) pass with
CMT and SCI. Final logs are `tang-final.log`, `wukong-boot-retry.log` for the two
XIP boot cases, and `wukong-loader-final.log` for upload and corrupt-image cases,
under `build/sci-validation/`. The earlier Wukong upload attempts exposed
insufficient host pacing for SCI's single receive register; the final test uses
the service gap described in [SCI](sci.md).
