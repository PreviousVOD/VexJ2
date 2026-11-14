# J2 microcoded CPU and Verilog SoC

SpinalHDL generates the validated `J2MicrocodedCore` and its core-level support
modules. The SoC wrapper, validation memory, Wishbone fabric, PIO, UART adapter,
and Tang Primer top are Verilog modules under `verilog/`. The validated VHDL
implementation remains available as the baseline.

The previous SystemVerilog implementation is archived under
`archive/systemverilog-2026-11-14/`.

The ISA baseline is the SH-2 specification in
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
| Full original CPU test ROM | Passing, 5,779 retired instructions |
| Verilog SoC with 16550 UART | Passing simulation and Tang Primer hardware |
| EG4S20 Verilog SoC TD build | 8,265 LUTs, 1,777 registers, 13 BRAM32K |
| EG4S20 VHDL baseline TD build | 4,568 LUTs, 1,053 registers, 8 BRAM32K |

The core passes the complete ROM in the classic Wishbone harness, plus RTE,
interrupt, illegal-instruction, and address-error programs. The Verilog SoC runs
the same architectural tests and prints `CPU tests passed` through the 16550
UART on hardware.

## Project layout

- `spinal/src/main/scala/j2/core/`: CPU, datapath, pipeline, register file, and
  multiply/MAC modules.
- `spinal/src/main/scala/j2/isa/`: ISA definitions and microcode predecoder.
- `spinal/src/main/scala/j2/microcode/`: ROM data, control decoding, and
  sequencing.
- `verilog/j2_soc.v`: CPU, memory, and peripheral integration.
- `verilog/j2_validation_rom.v`: initialized dual-port validation memory, with
  behavioral simulation and explicit EG4 block-RAM implementations.
- `verilog/j2_uart16550.v`: big-endian CPU adapter for the 16550's 8-bit bus.
- `fpga/j2_tang_primer_verilog/`: independent Verilog-only TD project.
- `fpga/j2_tang_primer_microcode.al`: VHDL baseline TD project.
- `third_party/uart16550/`: [FreeCores UART 16550](https://github.com/freecores/uart16550)
  at commit `2b0ad80d0968f201f95506854ad769c8a44abe2b`.

The canonical microcode source is
`spinal/src/main/resources/j2_microcode.hex`, containing all 256 72-bit entries.
`j2_predecode.tsv` is the generated opcode mapping. Simulation uses these
resources directly. `make microcode-mif` generates
`build/microcode/j2_microcode.mif` only for FPGA targets.

The baseline and 16550 validation ROMs are separate outputs:
`build/sw/testrom/main.bin` uses UART-lite for the VHDL/core harnesses, while
`build/sw/testrom16550/main.bin` uses the 16550 driver. `gen_verilog_rom.py`
creates complete HEX and MIF images for the Verilog validation memory.

## Toolchain

- Java 21
- sbt 1.10.7 through `tools/local/bin/sbt`
- Scala 2.13.14
- SpinalHDL 1.14.2
- Scalafmt 3.8.4; run `scalafmtAll` in `spinal/` after every Scala edit
- Verilator for core and Verilog SoC simulation
- Tang Dynasty 4.6.7 at `TD_HOME`

## Verification

```sh
make spinal-test            # 26 retained CPU and ISA tests
make spinal-generate        # CPU Verilog under build/spinal/verilog
make spinal-microcode-verif # full ROM, RTE, and interrupt regressions
make verilog-hw-sim         # Verilog SoC, 16550 UART decode, and full ROM
make reference-verif        # full ROM and RTE on the VHDL baseline
```

`spinal-hw-sim` is a compatibility alias for `verilog-hw-sim`. The generated
simulator CPU and EG4 CPU use separate output directories, so an FPGA build does
not replace the simulator's microcode implementation.

A timeout without `TEST_RESULT` or expected UART output fails. `--stop-pc` is
only a diagnostic stop, not a regression pass. Integration pitfalls and their
fixes are recorded in `docs/microcoded-core-debug.md`.

## FPGA

Build the Verilog SoC with:

```sh
TD_HOME=/home/imi415/Softwares/Tools/TD_4.6.7_Linux make verilog-fpga
```

Build the VHDL baseline with:

```sh
TD_HOME=/home/imi415/Softwares/Tools/TD_4.6.7_Linux make reference-fpga
```

`spinal-fpga` remains a compatibility alias for `verilog-fpga`. Both flows run
synthesis, place, route, timing analysis, and bit generation.

The Verilog SoC uses 8,265 LUTs, 1,777 registers, nine DSPs, and 13 BRAM32K
blocks. TD reports no setup or hold errors, a 29.780 ns minimum period for the
41.667 ns (24 MHz) clock, 5.943 ns minimum setup slack, and 0.266 ns minimum
hold slack. Volatile JTAG programming and the 16550 hardware test pass.

The VHDL baseline reports 4,568 LUTs, 1,053 registers, eight BRAM32K blocks,
two DSPs, no setup errors, and a 32.732 ns minimum period. Four hold errors
remain on clock-mesh/BRAM paths. The build script refuses bitstream generation
while timing errors remain; historical hardware success is not timing closure.

Pins use the Tang Primer J13/H13 UART:

- FPGA TX: J13
- FPGA RX: H13

After a timing-clean build, program volatile FPGA configuration and listen at
19,200 baud:

```sh
make verilog-program TD_HOME=/home/imi415/Softwares/Tools/TD_4.6.7_Linux
stty -F /dev/ttyACM0 19200 raw -echo
cat /dev/ttyACM0
```

`verilog-program` rebuilds before downloading, and `spinal-program` is an alias.
Start the UART listener before rebuilding, with a sufficient timeout. JTAG
`download -mode jtag` writes only volatile FPGA configuration SRAM; it never
writes external configuration flash.

Generated output and logs stay under ignored `build/` directories. Verilog TD
logs are under `build/logs/td_verilog`; the hardware UART capture is
`build/logs/verilog_fpga_uart.log`.
