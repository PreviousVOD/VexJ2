# Microcoded SpinalHDL core integration notes

## Scope and state

The validated VHDL baseline is commit `4c281cf`. It passed the reference
simulation and ran on the Tang Primer, printing `CPU tests passed` over UART.
Commit `2bebec7` checkpoints the modular SpinalHDL implementation. Scala now
generates only the microcoded CPU and its support modules. The current SoC,
validation memory, bus fabric, PIO, and UART adapter are Verilog modules under
`verilog/`. Original VHDL sources under `reference/` are retained only for
simulator cross-reference; the VHDL FPGA flow has been removed.

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

## SLEEP and synchronous access faults (2026-11-15)

The first two findings from the microarchitecture review are fixed in the
SpinalHDL core:

- `SLEEP` latches an internal sleeping state and stops pipeline slots until an
  eligible event arrives. Masked interrupts leave it asleep; an unmasked IRQ or
  bypass-mask interrupt wakes it through the existing exception sequence.
  This works with debug ports disabled. The debug `sleep` output now reports
  the sleeping state rather than a one-slot pulse.
- Word accesses require two-byte alignment, long accesses require four-byte
  alignment, and instruction fetches require two-byte alignment. A rejected
  access never asserts its bus request. Either Wishbone `ERR` terminates the
  outstanding request and raises CPU address-error vector 9 (`VBR + 0x24`),
  even without `ACK`; `ERR` takes precedence when both are asserted.

Failed data responses carry an invalid flag through the W path to suppress
GPR, SR, and multiply-register writeback. Pending data faults cancel younger
EX effects and their WB1 controls while older writebacks drain. Instruction
fetch faults substitute a harmless opcode until exception selection, allowing
the preceding instruction to complete. Internal exception acknowledgements
do not acknowledge an unrelated external event.

Exception return addresses are tracked separately from the microcode's
prefetch PC, including across multi-cycle instructions. A data fault saves
the following instruction address; an ordinary fetch fault saves the failed
fetch address. A fault in a branch delay slot saves the branch target. The
existing ERROR microcode stacks that address and SR, and RTE resumes from the
saved frame. The CPU address-error semantics are described in section 5.3 of
the [Renesas SH-2 hardware manual](https://www.renesas.com/en/document/mah/sh-2-sh7052-f-ztat-sh7053-f-ztat-sh7054-f-ztat).

There is no rollback of side effects already completed by the faulting
instruction or a bus slave. A second access fault during internal address-error
entry stops both buses until reset; nested address-error recovery is not
implemented. Board-level interrupt delivery remains a separate review finding.

Validation:

- `make spinal-test`: 27 tests pass. `J2SleepFaultSpec` runs 25 scenarios at two
  bus latencies, with debug ports enabled and disabled (100 simulations). It
  checks valid byte/word/long loads, alignment faults, instruction/data `ERR`,
  failed SR/MACH/MACL loads, delayed branches, saved exception frames, RTE,
  masked and unmasked wakeup, and faults during exception entry.
- `make spinal-microcode-verif`: CPU ROM, RTE, and interrupt ROMs pass, at
  31,561, 886, and 1,817 cycles respectively.

These changes have simulation coverage; the earlier FPGA timing and hardware
results below predate this fix.

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

### SPI flash and XIP

`verilog/j2_spiflash.v` integrates ZipCPU `llqspi` at 24 MHz. The 1 MiB XIP
window is `0x10000000` through `0x100fffff`; the byte-control port is
`0xff002000`. A registered arbiter
allows one data or instruction transaction at a time. The controller sends the
`0x03` command and 24-bit address in one four-byte transfer, then performs a
32-bit read while managing chip-select hold. Configuration writes use the same
byte-transfer path and preserve received data for configuration reads.

The Verilog SoC no longer preserves the original J2 peripheral layout. PIO is
at `0xff000000`, UART at `0xff001000`, and flash control at `0xff002000`.
CPU debug/event outputs are left unconnected in the SoC. Production FPGA
generation sets `exposeDebug = false`, so the debug ports are absent from the
generated core itself. Simulator/core regressions retain debug instrumentation.

`llqspi` always transmits from bit 31, including for byte transfers, so control
bytes must be left-aligned. Its command/address transfer is 32 bits, not 24.
Chip select must remain asserted across the ROM's multi-byte control sequences,
including the ACK and cooldown cycles between bytes, until the ROM explicitly
releases it. Releasing CS after each byte resets the flash command state and
produced idle `0xfe` reads.

Both instruction and data flash reads issue word-aligned `0x03` commands. Data
reads rely on the CPU's normal byte-lane selection; reading from the exact byte
address shifts the data twice and breaks checksums. Instruction reads retain the
original address bit 1 for halfword selection. Using an exact halfword flash
address returned apparently correct opcodes but led to an exception during early
XIP execution; word-aligned commands match the validated `spixpress` behavior.

The earlier `spixpress` attempt required an external DDR clock-output stage.
Approximating that stage incorrectly shifted the command (`0x9f` became `0x4f`)
and did not produce a valid hardware ID. The lower-level `llqspi` has a directly
registered SCK and explicit transfer timing, avoiding that ambiguity. The flash
simulator returns single-bit MISO on QSPI data bit 1, which the harness extracts
explicitly.

The board has two Winbond 25Q80 devices; the PDF's `26Q80B` label is a typo.
The device on CSO/CCLK is the FPGA configuration flash and must not be written
by this project. The free device uses CS=D3, CLK=H4, MOSI/IO0=B3,
MISO/IO1=F4, IO2=F5, and IO3=B1. Single-SPI mode drives IO2/WP and IO3/HOLD
high; leaving them undriven allowed the flash to remain write-protected or held.
The working E203 constraints confirm these locations. All top-level I/O pins,
not only flash, use LVCMOS33. The boot ROM limits image sizes to its 1 MiB
capacity and sends sixteen `0xff` bytes before identification to recover a
flash left in continuous/QPI mode.

The resident ROM in `sw/xiprom` supports JEDEC ID, 64 KiB erase, 256-byte page
program, busy polling, and read-back verification. UART uploads require two
flow-control handshakes: wait for `Program flash` after erase, then wait for a
`Page xxxxxx` acknowledgment after each page is programmed and verified. Raw
streaming overruns the 16550's 16-byte receive FIFO while the CPU is working on
flash. `tools/xip_image.py` packs the 16-byte application header and implements
the host protocol.

`make xip-hw-sim` verifies both a preloaded direct XIP boot and a blank-flash
UART upload followed by XIP execution. The test image prints `XIP CPU tests
passed`.

### EG4S20 SiP SDRAM

The EG4S20 contains an 8 MiB SDRAM die, so no external SDRAM pins appear on the
Tang Primer schematic. TD's `EG_PHY_SDRAM_2M_32` primitive provides a 2M x 32
interface with 11-bit rows, 8-bit columns, four banks, and four byte masks.
`verilog/j2_sdram.v` is a single-outstanding classic-Wishbone controller;
`verilog/j2_sdram_phy.v` contains only the primitive wrapper. No additional
clock PLL or external PHY is required at 24 MHz.

The controller maps SDRAM at `0x80000000` through `0x807fffff`, uses CL=3,
single-word accesses, auto-precharge, and byte enables. It performs a 200 us
power-up delay, precharge-all, two refreshes, and mode-register setup, then
refreshes every 15 us. The address mapping is bank=`addr[3:2]`,
column=`addr[11:4]`, row=`addr[22:12]`.

The initialization and timing choices were checked against the official Tang
examples and the minimal controller in
`ReinForce-II/anlogic_eg4s_sdram_controller` at commit
`a488f2f73dbd2af4c57436a62eee0b13b1919da2`. The Wishbone/SDRAM example in
`Icenowy/picorv32-wb-test` at commit
`e1c80ff0f705b841ca487ee78ea2678e9bb89317` also confirms the primitive and
geometry. The controller here is implemented locally rather than importing the
larger asynchronous/FIFO-based SDRAM core.

`verilog/verif/j2_sdram_model.v` supplies the simulation-only primitive model.
The XIP application checks all four banks, multiple rows and columns, and
word/byte/halfword writes before printing `SDRAM tests passed`. Byte lane
expectations must follow big-endian SH addressing: byte offset 1 selects bits
23:16. A missing tri-state DQ assignment during initial bring-up made every
written word zero even though the Wishbone write data was correct.

### Deferred boot-mode controls

For a future power-up download-mode control, use one button for CPU reset and
sample a second boot-mode button while reset is asserted. Release reset into the
UART loader when boot mode is held, otherwise boot the validated flash image.
Debounce and synchronize the asynchronous buttons before using them in the SoC.

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
Verilog SoC completes synthesis, place, route, and bit generation with 7,120
LUTs, 1,936 registers, nine DSPs, 13 BRAM32K blocks, and the SiP SDRAM macro.
TD reports zero setup and zero hold errors, a 27.028 ns minimum period, 7.319 ns
minimum setup slack, and 0.221 ns minimum hold slack for the 24 MHz clock.

Volatile JTAG programming succeeded and `/dev/ttyACM0` captured `CPU tests
passed` at 19,200 baud through the 16550, followed by DDR and GDB messages. The
raw capture is `build/logs/verilog_fpga_uart.log`.

The XIP design also passed on the Tang Primer. The free flash reported JEDEC ID
`ef4014`, then the UART loader erased and programmed two pages, verified the
image, and printed `XIP CPU tests passed`. The normal uploader waits for a fresh
boot banner; when the ROM is already waiting at `J2 loader`, use the uploader's
`--no-wait` option instead of waiting for output that has already been emitted.

With SDRAM enabled, the three-page uploaded image and a subsequent direct flash
boot both printed `SDRAM tests passed` and `XIP CPU tests passed` on hardware.
This validates the local controller's initialization, addressing, byte masks,
and read/write path at 24 MHz; it is not yet an exhaustive full-capacity memory
stress test.

The original VHDL implementation is supported only through `reference-verif`
on the simulator. Its former FPGA build and timing waivers have been removed.
The core's debug interface is still a stub; these programs and hardware results
do not establish debug support or exhaustive ISA correctness.
