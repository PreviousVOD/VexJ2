# J2 SpinalHDL redesign

The previous SystemVerilog implementation is archived under
`archive/systemverilog-2026-11-14/`. The active CPU, SoC, and Tang Primer
integration are implemented in SpinalHDL. `J2Soc` selects the pipelined,
microcode-driven `J2MicrocodedCore`; the validated VHDL implementation remains
available as the baseline.

The baseline ISA is the SH-2 specification in
`docs/isa/REN_rej09b0171_superh_MAH_20040630.pdf`. The J2-only `SHAD`, `SHLD`,
`CAS.L`, and `BGND` instructions are implemented and decoded as legal
instructions. There are no excluded instructions.

## Status

| Area | Status |
|---|---|
| SH-2 and J2 decode | 54,521 legal encodings, zero exclusions |
| `SHAD` / `SHLD` | Passing signed and unsigned shift-direction tests |
| `CAS.L` | Passing read-compare-write tests, including `Rm == Rn` |
| `BGND` | Implemented with the `debugBreak` pulse |
| Microcoded three-bus datapath and EX/WB pipeline | Implemented |
| Classic instruction/data Wishbone B4 masters | Implemented |
| Addressing, arithmetic, shift/rotate, multiply, MAC, divide | Passing |
| Delayed branches, illegal/slot-illegal exceptions, TRAPA, RTE | Passing |
| NMI/interrupt masking, delay-slot deferral, SR-access hazard | Passing |
| Internal BRAM, SoC router, PIO, UART | Passing simulation |
| Full original test ROM, no instruction bypasses | Passing, 5,779 retired instructions |
| EG4S20 SpinalHDL TD build | 7,654 LUTs, 1,616 registers, 64 BRAM9K and 5 BRAM32K |
| EG4S20 VHDL baseline TD build | 4,568 LUTs, 1,053 registers, 8 BRAM32K |
| Tang Primer hardware | VHDL baseline and SpinalHDL both print `CPU tests passed` |

The microcoded core passes the complete ROM in the classic Wishbone harness,
plus RTE, interrupt, illegal-instruction, and address-error programs. The
three-bus datapath, EX/WB controls, hazards, delayed register writes, and
multiply/MAC implementation are separate modules under `j2/core`; ISA,
microcode, bus, peripheral, and SoC modules have their own packages.

Microcode has one canonical representation:
`spinal/src/main/resources/j2_microcode.hex` contains all 256 72-bit entries.
`j2_predecode.tsv` is the generated opcode mapping. Simulation uses these
resources directly. `make microcode-mif` generates
`build/microcode/j2_microcode.mif` only for FPGA targets; no target-specific
copy is a second source of truth.

## Toolchain

- Java 21
- sbt 1.10.7 through `tools/local/bin/sbt`
- Scala 2.13.14
- SpinalHDL 1.14.2
- Scalafmt 3.8.4; run `scalafmtAll` in `spinal/` after every Scala edit
- Verilator for generated-Verilog and board-top simulation
- Tang Dynasty 4.6.7 at `TD_HOME`

## Verification

```sh
make spinal-test            # Scala unit, core, and SoC tests
make spinal-generate        # Verilog under build/spinal/verilog
make spinal-microcode-verif # full ROM, RTE, and interrupt regressions
make spinal-hw-sim          # generated Tang Primer top, including UART decode
make reference-verif        # full ROM and RTE on the VHDL baseline
```

The verification Makefile regenerates RTL when Scala sources or generation
settings change and builds every program it invokes. A timeout without a
`TEST_RESULT` or expected UART output fails; `--stop-pc` is only a diagnostic
stop, not a regression pass.

The full ROM covers branches, all MOV forms, ALU and shift operations,
`SHAD`/`SHLD`, the `CAS.L` path, multiply, divide, MAC.W/MAC.L, and status
behavior. Integration pitfalls and their fixes are recorded in
`docs/microcoded-core-debug.md`.

## FPGA

Build the SpinalHDL implementation with:

```sh
TD_HOME=/home/imi415/Softwares/Tools/TD_4.6.7_Linux make spinal-fpga
```

Build the VHDL baseline with:

```sh
TD_HOME=/home/imi415/Softwares/Tools/TD_4.6.7_Linux make reference-fpga
```

Both targets generate their required ROM data and run synthesis, place, route,
timing analysis, and bit generation. The SpinalHDL target uses the explicit
EG4 block-RAM wrapper in `fpga/j2_microcode_rom.v`.

The SpinalHDL build reports 7,654 LUTs, 1,616 registers, nine DSPs, 64 BRAM9K
blocks, five BRAM32K blocks, no setup or hold errors, and a 29.414 ns minimum
period for the 41.667 ns (24 MHz) clock. Minimum setup slack is 6.126 ns and
minimum hold slack is 0.307 ns.

The VHDL baseline reports 4,568 LUTs, 1,053 registers, eight BRAM32K blocks,
two DSPs, no setup errors, and a 32.732 ns minimum period. Four hold errors
remain on clock-mesh/BRAM paths. The build script checks the timing summary
and refuses bitstream generation while those errors remain; successful
execution of the historical image on one board is not treated as timing
closure.

Pins use the Tang Primer J13/H13 UART:

- FPGA TX: J13
- FPGA RX: H13

After a timing-clean build, program the volatile FPGA configuration and listen
at 19,200 baud with:

```sh
make spinal-program TD_HOME=/home/imi415/Softwares/Tools/TD_4.6.7_Linux
stty -F /dev/ttyACM0 19200 raw -echo
cat /dev/ttyACM0
```

`spinal-program` rebuilds the SpinalHDL image before downloading. To capture
output during that rebuild and download, start the UART listener first with a
sufficient timeout. Programming uses `download -mode jtag`, which writes only
volatile FPGA configuration SRAM; it never writes external configuration
flash.

TD scripts use paths relative to `build/logs/td`, and all generated output and
logs stay under ignored `build/` directories.
