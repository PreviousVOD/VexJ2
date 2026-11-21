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
- `spinal/src/main/scala/j2/core/{fetch,decode,execute,regfile,schedule,misc}/`: subsystem plugins.
- `spinal/src/main/scala/j2/core/isa/`: ISA definitions and microcode predecoder.
- `spinal/src/main/scala/j2/core/microcode/`: ROM data, control decoding, sequencing.
- `spinal/src/main/scala/j2/memory/`: vendor-independent memory policy contract and inferred implementation.
- `spinal/src/main/scala/j2/vendor/anlogic/`: EG4 ROM mapping, block-ROM and SDRAM PHY primitives, and pad connections.
- `spinal/src/main/scala/j2/vendor/xilinx/`: Vivado block-memory inference policy and I/O buffers.
- `spinal/src/main/scala/j2/bus/`: generic AHB5/APB IP, standalone system BIU, native AHB memory endpoints and cache.
- `spinal/src/main/scala/j2/periph/`: ROM/SRAM, GPIO and SPI/XIP peripherals.
- `spinal/src/main/scala/j2/soc/`: shared SoC configuration and reset utilities.
- `spinal/src/main/scala/j2/board/tang-primer/`: Tang Primer top, clock wrappers, SDRAM controller and PHY integration.
- `spinal/src/main/scala/j2/board/wukong-v1/`: Wukong top, clock/reset wrappers, AHB DDR bridge, MIG backend and integration.
- `sw/bootrom/`: common boot ROM, profile-selected flash setup and UART loader for both boards.
- `sw/xipapp/`: XIP application and SDRAM read/write/execute tests.
- `tools/xip_image.py`: shared image packager and Tang Primer UART uploader.

Each board keeps its clock primitives in `J2Clock.scala`. Wukong's
`WukongMig.scala` contains only the MIG interface; its separate SoC and DDR-input
MMCMs belong to the board clock file.
- `tools/check_wukong_boot.py`: Wukong upload and boot validation.
- `third_party/qspiflash/`: flash simulator sources only; upstream RTL is removed.
- `fpga/tang-primer/`: Tang Primer board profile, constraints and Tang Dynasty project.
- `fpga/wukong-v1/`: Wukong board profile, pin constraints and MIG configuration.
- `reference/`: original VHDL/VHM sources for simulator cross-reference.
- `docs/isa/j2_isa.csv`: ISA instruction and micro-step specification.

Legacy Wishbone buses, adapters and reference memory/cache fixtures live only
under `spinal/src/test/scala/j2/`. They support historical regression tests and
CPU test harnesses; production sources and generated SoCs contain no Wishbone.
Native memory regressions are `J2NativeMemorySpec`, `J2AhbDdrBridgeSpec` and
`J2AhbReadCacheSpec`; see [the memory-path reference](ahb-memory.md).

The canonical microcode source is `spinal/src/main/resources/j2_microcode.hex`,
containing all 256 72-bit entries. `j2_predecode.tsv` is the generated opcode
mapping. Spinal generates the memory initialization files used by both FPGA
flows; `make microcode-mif` remains an optional export for legacy flows.
See [memory inference](memory-inference.md) for the synthesis constraints and
backend selection.

## Verification

The commands below run the shared CPU suite and Tang Primer SoC flows.
Wukong has separate boot, DDR and hardware targets in its [board guide](wukong-v1.md#build-and-validation).

```sh
make spinal-test           # CPU, matrix, ISA, reset, SPI/cache, timer and DDR bridge tests
make spinal-generate       # shared CPU/components under build/spinal/verilog
make tang-sim-generate     # Tang simulation top and CPU, inferred memories
make tang-generate         # Tang FPGA top and CPU, EG4 memory backend
make wukong-generate       # Wukong FPGA top and CPU, Xilinx memory backend
make spinal-microcode-verif # full ROM, RTE, and interrupt regressions
make verilog-hw-sim         # native SoC and full legacy CPU test ROM
make xip-hw-sim             # direct XIP and blank-flash UART loader tests
make reference-verif        # full ROM and RTE on the VHDL baseline
make fpga-clock-test        # vendor PLL model; run after FPGA RTL generation
make isa-sim                # CPU regressions + legacy ROMs + shared ISA app, three boot modes
make isa-hw                 # build/timing/PLL + ISA app upload and fresh FPGA boot
```

`j2.Generate` owns common Spinal settings and standalone CPU/component generation;
it has no board dependencies and does not select FPGA primitives. The symmetric
board entry points are `j2.Generate_TangPrimer` and `j2.Generate_Wukong`.
Both reuse its settings/core generation and select their memory backend locally.
`j2.Generate_Wukong` always generates the complete DDR3-backed SoC.
DDR BIST logic lives in test sources for native-interface regression coverage.

Both boards use `fpga/<board>/board.properties`, with the same keys and shared
`j2.board.BoardProfile` / `tools/board_config.py` loaders. The profile defines the
FPGA, input/system clocks, PLL selection, UART, flash layout, and external memory
type/base/size. The loaders check generic numeric/address invariants; board descriptions are
trusted inputs, with hardware-specific constraints owned by each board.
`flashType` selects the Winbond or Micron initialization path in the common
`sw/bootrom` sources through `J2_FLASH_MICRON`. JEDEC ID is reported at startup;
the selected protocol comes from the board profile, not runtime autodetection.
Both profiles set `sramBytes=0x00008000` (32 KiB) by default. The value controls
the on-chip SRAM depth and AHB window beginning at `0x00008000`, and is exported
as `J2_SRAM_BYTES` for boot/application stacks and CoreMark's linker layout.
Sizes must be powers of two, at least 4 KiB, and must not overlap other windows.
FPGA BRAM capacity still limits what can be implemented. The supplied ISA app
uses fixed scratch addresses through `0x0000b000`, so it needs at least 16 KiB;
the legacy ROM regressions retain their original 32 KiB SRAM assumption.
The board wrappers own SDRAM/DDR controllers; each board SoC routes a generic AHB
memory window and the core has no knowledge of physical memory technology.
Run `python3 tools/board_config.py tang-primer` or `... wukong-v1` to generate
`build/<board>/rom/board.h` and `build/<board>/board.tcl`.
Optional `<field>Env` properties declare environment overrides in both loaders.
Tang declares `J2_CLOCK_HZ` / `J2_USE_PLL`; Wukong does not inherit these overrides.
Both ROMs are built with `make -C sw/bootrom BOARD=<board>` and written to
`build/<board>/rom/`. They share image validation, XIP boot and the UART loader. The ROM initializes
its own data/BSS and uses only internal SRAM for a 256-byte upload buffer. It
validates the header before erasing, checks each programmed payload chunk,
checks the complete payload checksum, and commits the header last. It neither
probes external memory nor copies applications into RAM. Applications own their
startup, including data/BSS initialization and any code relocation. The updated uploader and simulators use `Send image` and
`Received <offset>` acknowledgements on both boards.
Source directories use the board names `tang-primer` and `wukong-v1`; Scala
package identifiers use `tang_primer` and `wukong_v1`.

Tang simulation uses `Generate_TangPrimer --sim`, with inferred memories and
clock bypass. `J2_FPGA` is no longer a generator switch. Existing RTL output
directories are preserved; `J2_SPINAL_OUT` overrides the directory for any entry
point (relative paths are resolved from `spinal/` when invoked through Make).
The Verilog simulator Makefile selects the Tang simulation entry point explicitly.

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
fixes are recorded in [the integration notes](integration.md).

For benchmark builds, duration requirements and result comparisons, see
[CoreMark](coremark.md). Recorded test counts and timing figures in the
architecture and bring-up pages describe the revisions validated there.

Board FPGA builds use `make BOARD=<name> fpga`. Each board owns its Tcl entry
point and sources the common Xilinx or Anlogic workflow; see [FPGA build flows](fpga-build.md).
