# J2 SpinalHDL redesign

The previous SystemVerilog implementation is archived under
`archive/systemverilog-2026-11-14/`. The active CPU, SoC, and Tang Primer
integration are implemented in SpinalHDL. The FPGA validation image uses the
reference three-bus J2 core and its microcode decoder.

The baseline is the SH-2 ISA in
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
| Multicycle CPU with classic instruction/data Wishbone B4 masters | Implemented |
| Addressing, arithmetic, shift/rotate, multiply, MAC, divide | Passing |
| Delayed branches, illegal/slot-illegal exceptions, TRAPA, RTE | Passing |
| NMI/interrupt masking, delay-slot deferral, SR-access hazard | Passing |
| Internal BRAM, SoC router, PIO, UART | Passing simulation |
| Full original test ROM, no instruction bypasses | Passing, 5,024 retired instructions |
| EG4S20 reference LUT-ROM TD build | 4,568 LUTs, 1,053 registers, 8 BRAM32K |
| Tang Primer hardware | Historical reference image prints `CPU tests passed` |

The active SpinalHDL multi-cycle CPU passes the complete ROM in the classic
Wishbone verification harness. Its combinational executor still maps too large
for EG4S20. The hardware target therefore uses the reference three-bus J2 core
with its 256 x 72-bit LUT-ROM decoder, which already contains the J2 extensions
and fits the device.

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
make spinal-test       # Scala decoder/ALU/shifter/register-file/core/SoC tests
make spinal-generate   # Verilog under build/spinal/verilog
make spinal-verif      # full unmodified ROM, RTE, and interrupt regressions
make spinal-hw-sim     # generated SpinalHDL Tang Primer top, including UART decode
make reference-verif   # full ROM and RTE on the reference microcode CPU
```

The verification Makefile regenerates RTL when Scala sources or generation
settings change and builds every program it invokes. A timeout without a
`TEST_RESULT` or expected UART output fails; `--stop-pc` is only a diagnostic
stop, not a regression pass.

The full ROM covers branches, all MOV forms, ALU and shift operations,
`SHAD`/`SHLD`, the `CAS.L` path, multiply, divide, MAC.W/MAC.L, and status
behavior. The existing `rte.bin` and `interrupts.bin` programs also pass.

## FPGA

Build the reference microcode implementation with:

```sh
TD_HOME=/home/imi415/Softwares/Tools/TD_4.6.7_Linux make reference-fpga
```

`spinal-fpga` remains a compatibility alias for `reference-fpga`. The
`spinal-executor-fpga` target instead selects the experimental SpinalHDL
executor, which is known not to fit the EG4S20. The reference target extracts
`jcore-source-latest.tar.gz`, builds the original test ROM, generates the TD
VHDL and program MIF, and runs synthesis through bit generation.

TD reports 4,568 LUTs, 1,053 registers, 8 `BRAM32K` blocks, two DSPs, no setup
errors, and a 32.732 ns minimum period for the 41.667 ns (24 MHz) clock. Four
hold errors remain on clock-mesh/BRAM paths. The build script checks the timing
summary and refuses bitstream generation while those errors remain; successful
execution of the historical image on one board is not treated as timing
closure.

Pins use the Tang Primer J13/H13 UART:

- FPGA TX: J13
- FPGA RX: H13

After timing closure, program the volatile FPGA configuration with:

```sh
make spinal-program TD_HOME=/home/imi415/Softwares/Tools/TD_4.6.7_Linux
picocom -b 19200 /dev/ttyACM0
```

`spinal-program` uses `download -mode jtag`, which writes volatile FPGA
configuration SRAM only. It never writes the external configuration flash.

TD scripts use paths relative to `build/logs/td`, and all generated output and
logs stay under ignored `build/` directories.
