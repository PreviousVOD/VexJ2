# J2CMT compare match timer

Each board instantiates this peripheral directly. Its base address comes from
`cmtBase` in `board.properties` (currently `0xff003000` on both boards),
and the same setting is passed to RTL and firmware builds.

`j2.periph.J2CMT` follows the SH7124/SH7125 CMT register layout and counter
behavior (hardware manual section 14).

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
while polling the SCIF receive FIFO, handling timeouts longer than one wrap. Constant timeout
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
functional model. Each board maps CMI0/CMI1 through its `interruptSources`
property; the current profiles use INTC sources 0/1 and vectors 64/65. Firmware explicitly enables and prioritizes each source; CoreMark and
the CMT0 test use priority 14. The XIP INTC test also services CMT1. See the
[PPB/INTC architecture](ppb-intc.md).

## Validation notes

`make spinal-test` includes the timer and integrated interrupt regressions;
`make peripheral-model-test` checks the reference testbench's CMT/SCIF model.
Both board boot simulations and the XIP application exercise timeout rollover,
CMT interrupt entry and peripheral flag clearing. Current physical-board runs
are recorded in [SCI/SCIF](sci.md); timer-based benchmark validation and the
minimum ten-second duration are documented in [CoreMark](coremark.md).
