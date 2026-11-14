# Microcoded SpinalHDL core integration notes

## Scope and state

The validated VHDL baseline is commit `4c281cf`. It passed the reference
simulation and ran on the Tang Primer, printing `CPU tests passed` over UART.
Commit `2bebec7` checkpoints the modular SpinalHDL implementation. Scala now
generates only the microcoded CPU and its support modules. The current SoC,
validation memory, bus fabric, PIO, and UART adapter are Verilog modules under
`verilog/`; the VHDL implementation remains available through `reference-fpga`.

Useful entry points:

- `spinal/src/main/scala/j2/core/J2MicrocodedCore.scala`: integrated core.
- `spinal/src/main/scala/j2/core/J2Control.scala`: typed control bundles.
- `spinal/src/main/scala/j2/core/J2Datapath.scala`: shared X/Y/Z datapath.
- `spinal/src/main/scala/j2/core/J2Pipeline.scala`: EX/WB controls and hazards.
- `spinal/src/main/scala/j2/core/J2PipelineRegFile.scala`: delayed Z writes and W forwarding.
- `spinal/src/main/scala/j2/core/J2Multiply.scala`: multi-cycle multiply/MAC.
- `spinal/src/main/scala/j2/isa/J2Predecoder.scala`: opcode to ROM address.
- `spinal/src/main/scala/j2/microcode/`: ROM, control-word decoding, and sequencing.

## Resolution (2026-11-14)

`make spinal-microcode-verif` now passes all three programs:

- Full CPU ROM: `CPU tests passed` (31,561 cycles).
- RTE: `TEST_RESULT=0` (886 cycles).
- Interrupts, illegal instructions and address-error events: `TEST_RESULT=0`
  (1,817 cycles).

`make spinal-test` passes all 26 retained CPU/ISA tests, including the
integrated microcoded-core regression at three bus latency settings. SoC and
peripheral-only Scala tests were removed with their replaced modules.

The missing SP read was the first of several integration defects:

1. **Slot advanced after issuing a request.** `slot` was registered from the old
   bus-active flags, so it stayed high for another edge after a request began.
   EX/WB and the sequencer advanced, dropping the second reset request. Issuing
   either bus request now deasserts the next slot immediately. Reset reads
   `0x0=0x0000010c`, then `0x4=0x00007ffc`.
2. **Read data and prefetched instructions advanced ahead of their controls.**
   Presenting completed data before the next slot made the PC consume the SP
   vector. Presenting the next opcode early also destroyed the microcode's
   prefetch/delay-slot relationship. Both now advance on the slot edge with
   their pipeline controls. The microcoded PC increments whenever ID requests
   it, independently of instruction issue, and supplies EX and PR directly.
   The earlier instruction-address and link-address workarounds were removed.
3. **Conditional branches saw stale T.** Branch decoding now receives the
   current EX/WB status result combinationally, as in the reference datapath.
4. **Multiply control and timing were conflated.** Operand-start, MACH-write,
   and MACL-write enables are now independent. MAC retains its first operand
   across WB slots; an executing multiply has a separate operand snapshot.
   Arithmetic progresses every clock while busy, including stretched slots.
5. **Saturating MAC.W mishandled signed overflow and MACH.** Overflow requires
   matching operand signs and a changed result sign. Saturation now selects the
   correct signed limit and sets MACH bit 0 without discarding other bits;
   without overflow, saturating MAC.W preserves MACH.
6. **Illegal-instruction system operations supplied vector zero.** The ROM
   derives the vector address from the system opcode's low byte. General and
   slot-illegal sequences now supply vector 4 and 6 (`0x0704`, `0x0606`).

`J2MicrocodedCoreSpec` checks reset read order, the actual initialized R15 via
an architectural store, PC-relative loading, adjacent compare/branch behavior,
and delay-slot execution under three independently delayed bus configurations.
`J2MultiplySpec` checks separated operand arrival, progress while slots are
stalled, and signed MAC.W saturation with MACH preservation.

The generated CPU is instantiated by `verilog/j2_soc.v`. The Verilog SoC passes
`make verilog-hw-sim`, running the full CPU test image and printing `CPU tests
passed` through the 16550 UART. Simulation, FPGA timing, and hardware validation
remain separate requirements.

## Reproduction

Build the generated RTL and run the new core:

```sh
make spinal-microcode-verif
```

For a trace from the start:

```sh
make -C spinal/verif microcode-test   # builds the model when needed
cd build/spinal/verif/microcoded
./VJ2MicrocodedCore \
  /home/imi415/Documents/Hardwares/TD_Projects/J2/build/sw/testrom/main.bin \
  --quiet --max-cycles 12000 --log-bus-from 0 \
  > /home/imi415/Documents/Hardwares/TD_Projects/J2/build/logs/microcoded_full_trace.log 2>&1
```

Reference trace:

```sh
build/ref_microcode/Vref_cpu build/sw/testrom/main.bin \
  --quiet --trace-bus --max-cycles 20000 --expect 'CPU tests passed' \
  > build/logs/reference_full_trace.log 2>&1
```

Compare ordered transactions, not cycle numbers: the implementations have
different timing. Instruction-fetch ordering around data accesses can also
 differ, so compare the data stream separately when checking functional state.
Read data and write data are both printed by the current harness.

## Confirmed implementation pitfalls and fixes

### ROM initialization files are runtime artifacts

SpinalHDL emitted `J2MicrocodedCore.v_toplevel_rom_memory.bin`. Initially the
simulator could not find it, resulting in zero activity. Copy generated
`J2MicrocodedCore.v_*.bin` files into the simulator working directory and run the
binary there. `spinal/verif/Makefile` now does this for `microcode-test`.

### Falling-edge ROM and SpinalHDL checks

The reference ROM reads on the falling clock edge. SpinalHDL reports structural
cross-clock violations in both directions: core to ROM address and ROM line back
to the core. The current implementation places `crossClockDomain` tags on the ROM
address input and line output/source. These are targeted annotations for this
intentional interface, not FPGA timing waivers. TD timing analysis still applies.

Use the project-compatible memory idiom:

```scala
val memory = Mem(UInt(72 bits), 256)
memory.initBigInt(J2MicrocodeData.entries)
```

`spinal/src/main/resources/j2_microcode.hex` is the canonical 256 x 72-bit
data. Simulation consumes it directly; `make microcode-mif` generates the FPGA
MIF on demand. Do not add another independently maintained ROM representation.

For the EG4 wrapper, use `setDefinitionName("j2_microcode_rom")`, not
`setName`: the latter changed only the instance name and left TD trying to
elaborate an unknown `Eg4MicrocodeRom` module. Drive `rom.io.clk` only from the
core; combining that assignment with `mapClockDomain(clock = io.clk)` caused a
TD assignment-overlap error.

### Reset must allow the first ROM read

A synchronous falling-edge ROM has no valid reset micro-op before its first
read edge. `slot` therefore resets low, preventing the first active rising edge
from advancing EX/WB with an arbitrary ROM output. Without this hold, randomized
SoC simulations occasionally started at PC zero with SP zero and repeatedly
stacked exceptions at `0xfffffffc`, `0xfffffff8`, and so on.

The standalone core regression uses explicit clock edges and four reset cycles.
The Verilog board wrapper also holds the core in reset for several complete
clocks. Releasing a direct core's asynchronous reset at an arbitrary
`forkStimulus` phase remains unsupported and was still able to expose bad
startup behavior in testing; do not use that stimulus as a hardware reset model.

### Verilog SoC integration

The 16550 is configured for its upstream 8-bit Wishbone interface. The adapter
in `verilog/j2_uart16550.v` presents 32-bit registers to the CPU with the data
byte in bits 7:0. Its peripheral window must cover all eight 32-bit registers:
the original 16-byte decode missed LSR at offset `0x14`, causing an immediate
loopback ACK and a zero status read. The Verilog router uses a 32-byte window.

The validation image needs writable data and BSS, so `j2_validation_rom` is an
initialized dual-port memory, not a read-only instruction array. Generic
`$readmemh` inference caused TD to construct hundreds of thousands of muxes.
Hardware uses the existing `j2_eg4_bram32` true-dual-port primitive; Verilator
uses the behavioral model in the same Verilog module. `gen_verilog_rom.py`
generates the complete HEX and MIF images, avoiding uninitialized-word loops
that also exceeded TD's elaboration limit. The SoC's `ROM_INIT_FILE` must name
the MIF; passing the HEX file to the EG4 primitive produced a silent, empty
hardware boot despite a successful simulation and bitstream build.

Simulator and FPGA CPU generation use separate output directories. Sharing one
output replaced the simulation ROM with the EG4 BlackBox on the next simulator
build. The generated CPU now goes to `build/spinal/verilog-fpga` when
`J2_FPGA=1`.

### FC must align, not shift

An earlier implementation used:

```scala
io.xbus(31 downto 2).resize(32)
```

That drops the low bits and shifts the value right. The correct FC input is:

```scala
Cat(io.xbus(31 downto 2), U(0, 2 bits)).asUInt
```

This bug changed PC-relative literal addresses. There is a regression test in
`J2DatapathSpec`.

### Shift direction and rotate variants

For a right shift, the magnitude is the negated low five bits of Y, not the raw
low bits. A right shift by 32 needs separate saturation/zero handling because the
five-bit magnitude wraps to zero.

Ordinary ROTATE uses a 32-bit circular rotate. ROTC is a shift through T and does
not wrap the discarded bit into the result. The shift-out T value is separate.

### Instruction, PC, and W timing

The microcode assumes a prefetched instruction. Capture bus responses on ACK,
then present the captured opcode and W data only on the slot edge. Advance PC
on ID's increment control even if that microstep does not issue a fetch. Use
that microcoded PC for the datapath and PR capture. Deriving PC from the last
acknowledged instruction or presenting its opcode before the slot breaks this
relationship and can skip branch delay slots.

### Register-file timing matters

Do not replace `J2PipelineRegFile` with a conventional register file without
changing the microarchitecture:

- Z writes are delayed through two pending-write stages.
- W writes use WB3 controls.
- Reads forward current W and pending Z values.
- A slot advances these stages; ad hoc writes change branch and load behavior.

### Simulation test setup

SpinalHDL simulation does not support `#=` on whole bundles. Use the leaf drivers
in `spinal/src/test/scala/j2/core/J2ControlDrive.scala`. Allow sequential and
combinational outputs to settle after sampling edges before assertions. Several
early test failures came from incorrect test setup rather than RTL.

## FPGA validation and remaining boundary

The earlier all-SpinalHDL SoC was validated at commit `3c38cca`. The current
Verilog SoC completes synthesis, place, route, and bit generation with 8,265
LUTs, 1,777 registers, nine DSPs, and 13 BRAM32K blocks. TD reports zero setup
and zero hold errors, a 29.780 ns minimum period, 5.943 ns minimum setup slack,
and 0.266 ns minimum hold slack for the 24 MHz clock.

Volatile JTAG programming succeeded and `/dev/ttyACM0` captured `CPU tests
passed` at 19,200 baud through the 16550, followed by DDR and GDB messages. The
raw capture is `build/logs/verilog_fpga_uart.log`.

The VHDL baseline has four known hold violations and the build script rejects
bitstream generation when timing errors remain. The core's debug interface is
still a stub; these programs and hardware results do not establish debug support
or exhaustive ISA correctness.
