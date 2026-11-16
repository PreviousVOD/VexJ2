# J2 CPU composition and timing contracts

`J2MicrocodedCore` owns the external IO and a SpinalHDL `PluginHost`.
`J2CoreConfig` is immutable; `J2CorePlugins(config)` creates fresh plugin
instances for each core. The existing Boolean constructor remains supported.
Generation and SoC integration use the configuration constructor.

The organization follows VexiiRiscv's plugin host, typed services, and generic
pipeline links. It retains J2's microcoded execution model, complete ISA,
canonical control ROM, and classic Wishbone interfaces.

## Ownership and interfaces

| Subsystem | State and responsibilities |
|---|---|
| `fetch` | Active request, prefetched opcode/address and classification, fetch fault |
| `decode` | Falling-edge ROM, control table, sequencer, hazards |
| `schedule` | Registered slot enable, generic pipeline graph, final builder |
| `regfile` | Register file, W/Z writeback selection and suppression |
| `execute` | Datapath, multiplier/MACH/MACL, data bus transactions and faults |
| `misc` | PC/SR, instruction metadata, traps/events, sleep, debug observation |

Service traits and their port types are in `core/J2CoreServices.scala`.
Ports expose wires; other plugins cannot reach the owner's registers or child
components through the service. Each register has one owner. The external
service exposes the stable CPU bus/event/debug IO.

State-owning plugins publish interfaces and wire dependencies in separate fibers. The allocation fiber creates its interface
and local state without looking up another service. The wiring fiber then
retrieves the published interfaces. This permits hardware feedback between
services without creating a cycle in elaboration dependencies. Required
services must have exactly one enabled provider; composition validates this
before binding plugins to the host.

The schedule plugin retains the pipeline builder during setup, connects the
graph during build, and releases the retainer afterward. The builder creates
the pipeline registers once all connections are registered. Plugin list order
does not define hardware priority or elaboration order.

## Microstep pipeline

```text
                     +--> EX1 control/actions/metadata --> execution
decode node 0 -------+
                     +--> WB1 --> WB2 --> WB3 --> W writeback
                          |       |       |
                          +-------+-------+---- instruction/resume metadata
```

`J2PipelineLogic` uses `Payload`, `CtrlLink`, and `StageLink.withoutCollapse()`.
EX1 and WB1 are parallel payload paths at node 1; only writeback and metadata
continue to nodes 2 and 3. The standalone `J2Pipeline` component is a test and
generation wrapper around this same graph, not a second implementation.

All stages advance together. There is no elastic bubble collapse. A decode
hazard inserts no-effect EX/WB action bundles while older writeback advances.
A data fault suppresses the younger EX effects and clears WB1's actions as it
enters WB2; older WB2 still drains into WB3. Metadata travels with its microstep,
including when actions are cancelled. Stage occupancy represents microsteps;
the action bundles determine which architectural effects occur.

`schedule.advance` is registered. A memory request launches once on an enabled
edge and clears the next slot enable on that issuing edge. Waiting for the
registered bus-active flag alone would allow an extra microstep. Instruction
and data completions are captured independently of slot advancement, then held
until the next enabled slot. This keeps the W value paired with its WB controls
and avoids repeating stores or multiplier commands while waiting.

The control ROM still reads on the falling edge. Its output drives the control
table before the rising-edge microstep transfer. Pipeline migration does not
change this half-cycle path or retime the sequencer.

The response buffer's opcode is predecoded before ID consumes it. The resulting
address, legality, and delay-slot classification are latched on the same edge
as the accepted opcode. This gives predecode a full cycle and keeps its logic
off the rising-to-falling-edge ROM path, without adding a slot or changing when
an instruction is visible. Patterns are checked for mutual exclusion at
elaboration and select through a one-hot mux. Exhaustive testing checks every
16-bit encoding; CPU traces check the unchanged timing of instruction acceptance.

## Architectural priorities

- PC/SR writes belong to the architectural plugin. A valid WB3 SR load takes
  priority over EX SR selection. Branch decode sees the current EX T result
  through `nextStatus` before the status register is updated.
- Register reads forward W, then Z1, then Z2, then stored data. Physical
  register-file writes prefer the delayed Z2 write over W when both are present.
  The register file keeps its existing two-slot Z buffering.
- Architectural instruction/resume addresses are separate from speculative PC.
  The EX metadata's resume address is captured with a data request. A delay-slot
  fault resumes at the branch target; fetch errors remain attached to the
  prefetched opcode while preceding work drains.
- Internal faults take priority over external events. Event acknowledgement
  excludes internal fault service. A fault while entering its handler halts
  bus activity until reset. Sleep and wakeup retain interrupt-mask behavior.
- Legacy debug outputs retain their meaning. In particular, `retired` remains
  the slot-and-dispatch observation, rather than a new commit interface.

## Bus contracts

Both buses use classic Wishbone with byte addresses. Requests hold address,
data, byte selects, and write control stable through ACK or ERR. ERR wins if
both responses are asserted; failed reads cannot write registers, SR, MACH, or
MACL. Misaligned requests fault before reaching the bus.

Instruction responses retain the existing SoC convention: the selected
halfword arrives in the low 16 bits. Data lane selection, replicated subword
stores, and sign extension remain big-endian. Atomic operations hold CYC and
LOCK across the read/write sequence, including the gap between transfers.

The SoC uses `J2WishboneArbiter` with native one-hot round-robin selection and
registered grants held until both CYC and LOCK are released. A competing-master
regression exposed that SpinalHDL 1.14.2's `WishboneArbiter` excludes locked
masters from its request vector and can reselect a different master during a
locked cycle. The integration wrapper corrects this without changing the CPU
ports or peripheral implementations. TAS/CAS tests cover contention, response
waits, and reset during an atomic cycle.

## Extending and validating the design

To replace a subsystem, implement its service trait and substitute its plugin
in the configuration factory passed to `J2MicrocodedCore`. Publish the service
port before resolving dependencies, retain single ownership of its state, and
preserve the contracts above. Extend observation through service ports rather
than private implementation hierarchy. Keep configuration and construction
inside each core; do not share plugin instances between cores.

New pipeline payloads must be registered before the builder is released. Add
consumers at the intended node, provide reset behavior for effect-carrying
payloads, and retain collective stalls. Changes to ISA/microcode or instruction
timing require separate specification and validation.

The verification Makefiles discover Scala sources recursively and include
microcode resources as RTL-generation prerequisites. Run `make spinal-test`,
the CPU ROM/RTE/interrupt regressions, SoC and XIP/loader simulations, the
32 MHz FPGA implementation and clock-model check, and both CoreMark seed sets.
Plugin tests cover all ROM/debug configurations, missing/duplicate services,
reversed plugin order, frozen payloads, cancellation, metadata, bus stability,
and single store issue under waits. Existing fault and sleep scenarios remain
part of the acceptance suite.

CoreMark comparison uses the saved pre-refactor firmware hashes, seed sets,
iteration counts, clock, compiler, and memory environment. Baseline artifacts
are preserved in `build/coremark/baseline-2cfc302.tar.gz`; candidate results use
`COREMARK_LABEL=refactored`. Performance differences must be reported alongside
correctness, timing, and resource results.

## Refactor acceptance results

The CPU ports retain their names, widths, directions, and order. The full ROM,
RTE, and interrupt programs produce identical cycle-by-cycle retirement and bus
traces to the baseline (49,648 matching trace lines). All 34 Scala tests pass,
including successful/failed CAS, TAS, contention, waits, and reset during an
atomic cycle. The 12 benchmark-tool tests and normal SoC/XIP regressions pass.

| Measurement at 32 MHz | Baseline | Refactored |
|---|---:|---:|
| LUTs | 10,364 | 10,000 |
| Registers | 2,295 | 2,303 |
| Minimum setup slack | 0.384 ns | 2.327 ns |
| Minimum hold slack | 0.104 ns | 0.148 ns |
| CoreMark performance seeds, 1 simulated iteration | 4,024,702 ticks | 4,024,702 ticks |
| CoreMark validation seeds, 1 simulated iteration | 4,029,594 ticks | 4,029,594 ticks |
| CoreMark performance seeds, 10 hardware iterations | 40,252,267 ticks | 40,252,268 ticks |
| CoreMark validation seeds, 10 hardware iterations | 40,312,476 ticks | 40,312,476 ticks |

CoreMark ticks are microseconds. Firmware hashes, compiler flags, seed CRCs, and
final CRCs match. The hardware performance difference is one timer tick; both
hardware workloads exceed ten seconds. Nine DSPs, 37 BRAM9Ks, and ten BRAM32Ks
are unchanged. The vendor PLL model measures 31.249950 ns against the expected
31.25 ns, using the 384 MHz VCO and output divider 12.

The FPGA was programmed with the refactored bitstream. After benchmarking, the
normal validation application was restored to dedicated application flash.
SDRAM, timer interrupts, and XIP pass after upload and a fresh JTAG reload.
Configuration flash was not written. The detailed traces, reports, and summary
are under `build/refactor/`; matched benchmark artifacts are under
`build/coremark/refactored/`.

## Validation after Scala formatting

The 2026-11-16 rerun uses the consecutive-assignment Scalafmt rules for Scala
`=`, SpinalHDL `:=`, and simulation `#=`. Both the CPU and SoC RTL, for simulation
and FPGA, are byte-identical to the accepted pre-format refactor. All 34 Scala
tests, 12 benchmark-tool tests, CPU ROM/RTE/interrupt regressions, native SoC
reset and cold-boot checks, XIP and UART-loader simulations, and VHDL reference
ROM/RTE checks pass. Fresh CPU traces match the frozen baseline byte for byte.
The Scala and sbt formatting checks pass.

Both simulated CoreMark seed sets retain the baseline timings of 4,024,702 and
4,029,594 microseconds for one iteration. These short simulation runs validate
correctness; reportable benchmark durations come from ten hardware iterations.
The fresh 32 MHz implementation retains 10,000 LUTs, 2,303 registers, 2.327 ns
setup slack, and 0.148 ns hold slack. The vendor PLL model passes with the
384 MHz VCO and output divider 12.

The hardware rerun passes both ten-iteration seed sets in 40,252,267 and
40,312,476 microseconds, matching the original baseline exactly. Both runs
exceed ten seconds, with matching firmware hashes and all seed/final CRCs.
The normal validation application was restored afterward. SDRAM, timer
interrupts, and XIP pass after UART upload and a fresh JTAG reload; the board is
left running that application.

Formatting changes the raw hashes of the five peripheral Scala sources. The
original benchmark comparator deliberately rejects changed environment hashes.
For this rerun, a separate audit verifies those five diffs contain only
whitespace changes and checks all 26 peripheral RTL modules against the frozen
baseline byte for byte. Firmware hashes, compiler flags, clocks, seeds, CRCs,
and the remaining memory-environment hashes must still match exactly. The
original baseline reports and strict comparator are preserved.

Rerun logs, source snapshots, RTL/port checks, and benchmark comparisons are in
`build/validation-final/`; the new CoreMark reports are in
`build/coremark/final-formatted/{simulation,hardware}/`.
