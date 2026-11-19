# Development and verification

[Project overview](../README.md) · [SoC reference](soc.md)

Run commands from the repository root unless a command changes directories.
Board-specific tool setup and programming are in the [Tang Primer](tang-primer.md)
and [Wukong](wukong-v1.md) guides. Generated RTL, binaries and reports stay under
ignored `build/` directories.

## Toolchain

Run `make toolchain` to populate `tools/local` with sbt 1.10.7, Verilator
5.032, and a big-endian SH-2 GCC 13.3.0/binutils 2.43.1 cross-toolchain using
the `sh-none-elf-` prefix. The individual targets are `toolchain-sbt`,
`toolchain-verilator`, and `toolchain-sh`. Downloads and build trees are cached
under `tools/third_party/`; no root privileges or external source tarballs are
required. Scala, simulation, and firmware targets bootstrap their respective
tools automatically. Verilator 5.032 is intentional: newer releases are not
currently compatible with SpinalHDL 1.14.2's generated simulation wrapper.

Host prerequisites are Java 21, gcc/g++, make, autoconf, m4, perl, python3,
curl, wget, and Verilator's documented build dependencies. Source
`tools/env.sh` to use the repository-local tools in a shell. Scalafmt 3.8.4 is
available through sbt; run `scalafmtAll` in `spinal/` after Scala edits. The
optional VHDL reference build can install GHDL with
`tools/third_party/build-tools.sh ghdl`.

Tang Dynasty 4.6.7 is a separate vendor installation. Set `TD_HOME` or `TD_BIN`,
or put `td` on `PATH`; no vendor installation path is stored in the project.

The Wukong flow uses Vivado through `tools/run_vivado.sh`; see its
[build instructions](wukong-v1.md#build-and-validation) for the required host-library setup.

## Project layout

- `spinal/src/main/scala/j2/core/`: CPU composition, service types, reusable datapath/pipeline units.
- `spinal/src/main/scala/j2/{fetch,decode,execute,regfile,schedule,misc}/`: subsystem plugins.
- `spinal/src/main/scala/j2/isa/`: ISA definitions and microcode predecoder.
- `spinal/src/main/scala/j2/microcode/`: ROM data, control decoding, sequencing.
- `spinal/src/main/scala/j2/bus/`: generic AHB5/APB IP, standalone system BIU and retained Wishbone memory backends.
- `spinal/src/main/scala/j2/periph/`: ROM/SRAM, GPIO, SPI/XIP, SDRAM peripherals.
- `spinal/src/main/scala/j2/soc/`: board-independent SoC, interconnect and reset control.
- `spinal/src/main/scala/j2/board/tang_primer/`: Tang Primer top, EG4 PLL/pads, SDRAM PHY and memory wrappers.
- `spinal/src/main/scala/j2/board/wukong/`: Wukong top, Xilinx primitives and MIG integration.
- `sw/wukongrom/`: Wukong platform ROM and SF3 application loader.
- `sw/xiprom/`: Tang Primer boot ROM, flash driver, and UART loader.
- `sw/xipapp/`: XIP application and SDRAM read/write/execute tests.
- `tools/xip_image.py`: shared image packager and Tang Primer UART uploader.
- `tools/check_wukong_boot.py`: Wukong upload and boot validation.
- `third_party/qspiflash/`: flash simulator sources only; upstream RTL is removed.
- `fpga/j2_tang_primer_verilog/`: Tang Primer constraints and Tang Dynasty project.
- `fpga/wukong-v1/`: Wukong board profile, pin constraints and MIG configuration.
- `reference/`: original VHDL/VHM sources for simulator cross-reference.
- `docs/isa/j2_isa.csv`: ISA instruction and micro-step specification.

The canonical microcode source is `spinal/src/main/resources/j2_microcode.hex`,
containing all 256 72-bit entries. `j2_predecode.tsv` is the generated opcode
mapping. `make microcode-mif` generates the FPGA MIF on demand; no separately
maintained microcode representation is required.

## Verification

The commands below run the shared CPU suite and Tang Primer SoC flows.
Wukong has separate boot, DDR and hardware targets in its [board guide](wukong-v1.md#build-and-validation).

```sh
make spinal-test           # CPU, matrix, ISA, reset, SPI/cache, timer and DDR bridge tests
make spinal-generate       # CPU and SoC Verilog under build/spinal/verilog
make spinal-microcode-verif # full ROM, RTE, and interrupt regressions
make verilog-hw-sim         # native SoC and full legacy CPU test ROM
make xip-hw-sim             # direct XIP and blank-flash UART loader tests
make reference-verif        # full ROM and RTE on the VHDL baseline
make fpga-clock-test        # vendor PLL model; run after FPGA RTL generation
make isa-sim                # CPU regressions + legacy ROMs + shared ISA app, three boot modes
make isa-hw                 # build/timing/PLL + ISA app upload and fresh FPGA boot
```

The XIP regression covers reset-button and cold startup from preloaded flash,
plus a cold blank-flash UART upload. All paths print `SDRAM tests passed`,
`Timer tests passed`, and `XIP CPU tests passed`. The timer test covers masking,
vector-`0x40` ISR entry, clearing, and rearming. The CPU ROM also runs without a
reset-button pulse.
The timer test also executes `SLEEP` and returns through the timer ISR. The
shared application in `sw/xipapp/isa.c` and `isa.S` checks same-memory atomics
from SRAM and SDRAM, forwarding and delay slots, MAC saturation, and exception
frames after dependent loads. It prints `ISA regression tests passed` before
the final XIP completion marker. `isa-hw` uses `/dev/ttyACM0` at 19,200 baud,
programs volatile FPGA configuration SRAM and replaces the dedicated application
flash image. Set `TD_HOME` or `TD_BIN` as for the existing FPGA targets.
Logs and image/source hashes are recorded under `build/isa-validation/`.
A timeout without expected UART output fails. Integration pitfalls and their
fixes are recorded in [the integration notes](microcoded-core-debug.md).

For benchmark builds, duration requirements and result comparisons, see
[CoreMark](coremark.md). Recorded test counts and timing figures in the
architecture and bring-up pages describe the revisions validated there.
