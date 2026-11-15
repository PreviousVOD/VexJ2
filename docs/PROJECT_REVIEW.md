# J2 SpinalHDL project context and flow review

Review date: 2026-11-14  
Repository HEAD at review: `abcf341`

This review covers the working tree, including the staged SpinalHDL migration,
not just the committed HEAD. Source files were not changed during the review.

## Project context

- The project rewrites the J2 SH-2 core using SpinalHDL.
- The previous SystemVerilog implementation and its verification infrastructure
  are archived under `archive/systemverilog-2026-11-14/`.
- Original J-Core sources are extracted under the ignored `reference/soc_top/`
  directory from the tracked `jcore-source-latest.tar.gz` archive.
- The intended direction, following difficulties with distributed RAM, is to
  retain the original microcode ROM approach.
- The reference decoder uses a 256-entry, 72-bit control ROM, read on the
  falling clock edge. Its three-bus datapath and microsequencer are distinct
  from the current SpinalHDL multicycle executor.
- The current `Sh2Core` implements instruction behavior through a large
  combinational switch. Adding a control ROM without replacing that executor
  would not remove its logic cost.
- The ISA includes SH-2 plus the J2 extensions `SHAD`, `SHLD`, `CAS.L`, and
  `BGND`.
- The FPGA target is the Tang Primer with an Anlogic EG4S20BG256, a 24 MHz
  clock, and UART at 19200 baud. FPGA TX is J13; RX is H13.

## Relevant source and flow locations

| Area | Location |
|---|---|
| Main build targets | `Makefile` |
| Scala build | `spinal/build.sbt` |
| RTL generation | `spinal/src/main/scala/j2/Generate.scala` |
| Active SpinalHDL core | `spinal/src/main/scala/j2/core/Sh2Core.scala` |
| Wishbone configuration and RAM | `spinal/src/main/scala/j2/bus/J2Wishbone.scala` |
| SoC and board integration | `spinal/src/main/scala/j2/soc/` |
| Verilator verification | `spinal/verif/` |
| FPGA build scripts | `tools/build_tang_primer_td.sh`, `tools/build_tang_primer.tcl` |
| Reference VHDL preparation | `tools/gen_td_vhdl.py` |
| Microcode block-ROM experiment | `experiments/microcode_rom/` |
| Reference CPU board wrappers | `fpga/j2_cpu_flat.vhd`, `fpga/j2_tang_primer.vhd` |

The README reports successful reference-core hardware validation and a LUT-ROM
build using 4,568 LUTs, 1,053 registers, and eight BRAM32K blocks. The microcode
experiment documents an explicit block-ROM variant using five additional
BRAM32K blocks and 3,991 LUTs. These are recorded results for reference-core
variants; they do not establish that the current `spinal-fpga` target builds
those variants.

## Review findings

Priorities: P1 means a correctness or intended-flow issue to address first;
P2 means a reproducibility or validation issue.

### 1. [P1] FPGA target selects the SpinalHDL executor instead of the microcode CPU

Locations:

- `tools/build_tang_primer_td.sh:16`
- `fpga/j2_tang_primer.al:11`
- `spinal/src/main/scala/j2/soc/J2Soc.scala`

The build script copies generated `J2TangPrimer.v` and the SpinalHDL board
wrapper into the FPGA build directory. The project source list contains only
those Verilog files. `J2Soc` instantiates `Sh2Core`; the reference VHDL CPU and
its microcode decoder are not included.

As a result, `make spinal-fpga` selects the large combinational executor rather
than the documented reference microcode implementation. Existing reference-core
area reports and hardware results do not validate this target.

Suggested action: make the intended microcode implementation an explicit,
reproducible FPGA target and align the documentation and simulation target with
the implementation actually selected.

### 2. [P1] Wishbone pipelined declaration does not match transaction handling

Locations:

- `spinal/src/main/scala/j2/bus/J2Wishbone.scala:15`
- `spinal/src/main/scala/j2/bus/J2Wishbone.scala:72`
- `spinal/src/main/scala/j2/core/Sh2Core.scala:245`

The interface is configured as pipelined Wishbone. The RAM reports `STALL=0`
but requires the requester to keep `STB` asserted while waiting for its delayed
acknowledgement. A pipelined master may deassert `STB` after acceptance and keep
`CYC` asserted while awaiting the response.

A targeted simulation confirmed that a one-cycle request accepted with
`STALL=0` never received `ACK` after `STB` was deasserted. Conversely, the core
holds `STB` until acknowledgement, allowing a compliant pipelined slave to
accept duplicate requests during response latency. Existing peripheral and
loopback logic also uses similar pending/request patterns.

Suggested action: choose classic Wishbone consistently or implement pipelined
request acceptance, backpressure, and response tracking throughout the fabric.
Add checks with a single-cycle request and delayed acknowledgement.

### 3. [P1] CAS/TAS drop the bus cycle between read and write

Locations:

- `spinal/src/main/scala/j2/core/Sh2Core.scala:253`
- `spinal/src/main/scala/j2/core/Sh2Core.scala:387`
- `spinal/src/main/scala/j2/core/Sh2Core.scala:403`

CAS and TAS enter `dataGap` between their read and write transactions. The data
bus asserts `CYC` only in the `data` state, so it drops during that gap even
though `LOCK` remains high. This does not preserve a continuous locked bus
cycle, and another master could acquire the bus between the read and write.

Suggested action: preserve `CYC` and `LOCK` across the complete atomic operation;
use `STB` to separate individual transfers. Verify arbitration with a competing
master.

### 4. [P1] Simulation timeouts can report PASS

Location: `spinal/verif/cpp/sh2sim.cpp:206`.

The harness initializes `ok` to true. If no `--expect` argument is supplied and
the cycle limit expires before a `TEST_RESULT` write, it still returns success.
The RTE and interrupt regression commands use this mode.

Reproduction:

```sh
build/spinal/verif/sh2sim/VSh2Core build/sw/simtests/rte.bin \
  --max-cycles 1 --quiet
```

Observed result: `PASS`, with zero retired instructions and no test result.

Suggested action: require an explicit success condition and return failure on
timeout. Keep diagnostic stop-at-PC behavior distinct from regression success.

### 5. [P2] Verification can silently reuse stale generated RTL

Location: `spinal/verif/Makefile:26`.

The rule for `Sh2Core.v` generates it only when the file is missing. It has no
prerequisites for Scala sources, `build.sbt`, or generation settings. Editing
the core and running `make spinal-verif` can therefore test old Verilog.

A Make dry run marking `Sh2Core.scala` as newer still reported the Verilog
target as up to date.

Suggested action: add generation dependencies or explicitly regenerate before
verification. Include relevant harness headers and ROM initialization files in
the corresponding build dependencies as well.

### 6. [P2] Verification does not build all programs it invokes

Location: `spinal/verif/Makefile:15`.

The `test` target builds `main.bin`, then invokes `rte.bin` and `interrupts.bin`
without declaring prerequisites or providing generation rules for those files.
Running `make spinal-verif` relies on a previous `make sw`.

Suggested action: declare all invoked program images as dependencies and build
them through their software Makefiles.

### 7. [P2] Reference and microcode preparation depend on existing local artifacts

Locations:

- `Makefile`
- `sw/testrom/Makefile`
- `experiments/microcode_rom/run_td_probe.sh:14`

The active build no longer provides the reference-source extraction rule,
although software builds require the ignored `reference/` directory. The
microcode probe reads `build/td_vhdl/decode_bound.vhd` and other generated VHDL
without first invoking their generator. Those artifacts are also ignored.

The probe is a place-and-route experiment; its Tcl script does not generate a
bitstream, and it is not connected to the active SpinalHDL verification flow.

Suggested action: restore explicit extraction and VHDL-generation prerequisites.
Ensure the microcode target works from a clean checkout and verify the exact
ROM-backed CPU selected for hardware.

### 8. [P2] Timing failures do not block bitstream generation

Location: `tools/build_tang_primer.tcl:18`.

The script reports timing and immediately invokes `bitgen`, without checking
whether timing passed. Existing reference-core reports contain four hold
violations; the LUT-ROM report includes approximately -3.17 ns hold slack.
Both LUT-ROM and explicit block-ROM experiment reports record hold errors.

Suggested action: investigate the reported clock/hold paths and require timing
closure, or a justified analysis of any tool-model exceptions, before accepting
a hardware build. Successful execution on one board does not resolve the
reported timing violations.

## Validation performed

- Compiled the current Scala main and test sources using cached dependencies,
  then ran the existing suites through JUnit with system Verilator 5.032:
  **17 tests passed**.
- `make spinal-verif` passed the full original ROM, `rte.bin`, and
  `interrupts.bin` using the existing generated RTL. The full ROM reported
  5,024 retired instructions. These passes are subject to the stale-RTL and
  timeout limitations above.
- A separate RAM simulation demonstrated the missing acknowledgement for an
  accepted single-strobe pipelined Wishbone request.
- The one-cycle RTE command above reproduced the harness false-pass behavior.
- Reviewed existing FPGA area/timing reports and project source lists.
- FPGA synthesis was not rerun, and hardware was not programmed.

The ordinary `make spinal-test` entry point could not run in the review sandbox
because the sbt launcher selected a temporary cache and attempted a network
download. The cached Scala compiler/JUnit route allowed the current sources and
existing tests to be checked without changing project sources.

## Suggested implementation order

1. Select and connect the intended microcode CPU to the FPGA and simulation
   flows, with explicit clean-build prerequisites.
2. Make verification fail on timeout and regenerate RTL from current sources.
3. Resolve the Wishbone handshake mismatch and preserve atomic bus cycles.
4. Run the full program regressions against the exact selected implementation,
   then perform synthesis and timing closure before hardware validation.
