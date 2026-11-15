# J2 microcoded CPU and Verilog SoC

SpinalHDL generates the validated `J2MicrocodedCore` and its core-level support
modules. The SoC wrapper, validation memory, Wishbone fabric, PIO, UART adapter,
and Tang Primer top are Verilog modules under `verilog/`. Original J-Core VHDL
sources under `reference/` are used only for simulator cross-reference.

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
| SPI flash loader and XIP application | Passing simulation and Tang Primer hardware |
| EG4S20 SiP SDRAM controller | Passing simulation and Tang Primer hardware |
| EG4S20 Verilog SoC TD build | 7,120 LUTs, 1,936 registers, 13 BRAM32K |
| VHDL simulator cross-reference | Full original ROM and RTE passing |

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
- `verilog/j2_spiflash.v`: classic-Wishbone adapter and instruction/data arbiter
  for ZipCPU `llqspi`, with a `0x10000000` XIP window and `0xff002000`
  flash-control port.
- `verilog/j2_sdram.v`: single-beat Wishbone controller for the 8 MiB EG4S20
  SiP SDRAM at `0x80000000`; `j2_sdram_phy.v` wraps the TD primitive.
- `sw/xiprom/`: resident boot ROM, flash driver, and flow-controlled UART loader.
- `sw/xipapp/`: minimal XIP application and its flash linker script.
- `tools/xip_image.py`: application packager and host-side UART uploader.
- `third_party/qspiflash/`: [ZipCPU qspiflash](https://github.com/ZipCPU/qspiflash)
  at commit `f0a3d2ac4c0e2d4bd2a7847bc0df24bb3a7c11ad`, including its flash
  simulator.
- `fpga/j2_tang_primer_verilog/`: the sole FPGA project, using the generated
  SpinalHDL core and Verilog SoC.
- `reference/`: original VHDL/VHM sources for the simulator cross-reference.
- `docs/isa/j2_isa.csv`: ISA instruction and micro-step specification.
- `third_party/uart16550/`: [FreeCores UART 16550](https://github.com/freecores/uart16550)
  at commit `2b0ad80d0968f201f95506854ad769c8a44abe2b`.

The Verilog SoC memory map is independent of the original J2 ROM layout:

| Region | Address range |
|---|---:|
| Internal ROM/RAM | `0x00000000`–`0x00007fff` |
| SPI flash XIP (1 MiB) | `0x10000000`–`0x100fffff` |
| SiP SDRAM (8 MiB) | `0x80000000`–`0x807fffff` |
| PIO | `0xff000000` |
| 16550 UART | `0xff001000` |
| SPI flash control | `0xff002000` |

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
make xip-hw-sim             # direct XIP and blank-flash UART loader tests
make reference-verif        # full ROM and RTE on the VHDL baseline
```

`spinal-hw-sim` is a compatibility alias for `verilog-hw-sim`. The generated
simulator CPU and EG4 CPU use separate output directories, so an FPGA build does
not replace the simulator's microcode implementation.

The XIP regression runs the application once from preloaded flash and once after
a blank-flash UART upload. The loader waits for erase completion before sending
page data and waits for verification before each subsequent page, preventing
16550 receive-FIFO overruns.

A timeout without `TEST_RESULT` or expected UART output fails. `--stop-pc` is
only a diagnostic stop, not a regression pass. Integration pitfalls and their
fixes are recorded in `docs/microcoded-core-debug.md`.

## FPGA

Build the Verilog SoC with:

```sh
TD_HOME=/home/imi415/Softwares/Tools/TD_4.6.7_Linux make verilog-fpga
```

`spinal-fpga` remains a compatibility alias for `verilog-fpga`. The flow runs
synthesis, place, route, timing analysis, and bit generation.

The Verilog SoC uses 7,120 LUTs, 1,936 registers, nine DSPs, 13 BRAM32K blocks,
and the SiP SDRAM macro. TD reports no setup or hold errors, a 27.028 ns minimum
period for the 41.667 ns (24 MHz) clock, 7.319 ns minimum setup slack, and
0.221 ns minimum hold slack. Volatile JTAG programming, the 16550 hardware test,
and direct XIP boot with SDRAM read/write tests pass.

Pins use the Tang Primer J13/H13 UART:

- FPGA TX: J13
- FPGA RX: H13

The free Winbond 25Q80 uses CS=D3, CLK=H4, MOSI=B3, MISO=F4, IO2=F5, and
IO3=B1. The design drives IO2/WP and IO3/HOLD high. All top-level I/O pins use
LVCMOS33. The configuration flash on CSO/CCLK is never targeted. Hardware reads
the expected JEDEC ID `ef4014`; UART erase, program, verification, and XIP boot
pass. To upload the packaged application after a fresh boot banner, run:

```sh
make xip-upload
```

If the ROM is already waiting at `J2 loader`, use:

```sh
tools/xip_image.py upload build/sw/xipapp/flash.bin --no-wait
```

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
