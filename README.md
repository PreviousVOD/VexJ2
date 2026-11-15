# J2 microcoded CPU and SpinalHDL SoC

SpinalHDL generates the `J2MicrocodedCore` and the complete SoC. The design uses
native SpinalHDL Wishbone, UART, SPI/XIP, GPIO, and SDRAM libraries. Original
J-Core VHDL sources under `reference/` are used only for simulator
cross-reference; the handwritten Verilog SoC and third-party bus/peripheral RTL
have been removed.

The ISA baseline is `docs/isa/REN_rej09b0171_superh_MAH_20040630.pdf`. The
J2-only `SHAD`, `SHLD`, `CAS.L`, and `BGND` instructions are implemented and
decoded as legal instructions. There are no excluded instructions.

## Status

| Area | Status |
|---|---|
| SH-2 and J2 decode | 54,521 legal encodings, zero exclusions |
| Scala CPU and ISA tests | 27 suites passing |
| Full original CPU test ROM | Passing, 5,779 retired instructions |
| VHDL simulator cross-reference | Full original ROM and RTE passing |
| Native UART, SPI/XIP, and SDRAM | Passing direct and loader simulations |
| 32-bit bidirectional GPIO | Native `WishboneGpio` plus 32 EG4 pads |
| FPGA implementation | Timing-clean at 30 MHz |
| Tang Primer hardware | JTAG programming succeeds; no UART banner yet |

The remaining board bring-up issue is unresolved: the current image produces no
serial transitions, although simulation, ROM initialization, clock constraints,
and place-and-route all pass. Do not treat earlier hardware results from the
removed Verilog SoC as validation of this implementation.

## Architecture

```text
                              +-------------------+
 clk24 ---------------------->| EG4 PLL + BUFG    |--> 30 MHz SoC clock/reset
                              +-------------------+
                                        |
                 +----------------------+----------------------+
                 |             J2MicrocodedCore                 |
                 |  I-bus                              D-bus   |
                 +---+----------------+---------------------+--+
                     |                |                     |
                     |                |                     +----------------+
                     |                |                                      |
               WishboneDecoder        |                             WishboneDecoder
                 (iMux)               |                                  (dMux)
                     |                |                                      |
        +------------+-----------+    |                         +------------+-----------+
        |                        |    |                         |                        |
   +----+----+            +------+----+-+--+             +------+------+          +------+------+
   | ROM     |            | SRAM       |    |            | GPIO 32-bit|          | UART       |
   | arbiter |            | arbiter    |    |            | 0xff000000 |          | 0xff001000 |
   +----+----+            +------+-----+    |            +------+-----+          +------+-----+
        |                        |          |                   |                       |
   +----+----+            +------+-----+    |            +------+-----+                 |
   | Flash   |            | SDRAM    |      |            | EG_PHY_PAD |                 |
   | arbiter |            | arbiter  |      |            | x32        |                 |
   +----+----+            +------+---+      |            +------------+                 |
        |                        |          |
   +----+----+            +------+-----+    |
   | SPI XDR |            | BmbSdramCtrl|   |
   | APB/XIP |            | EG4 SDRAM   |   |
   +---------+            +-------------+   |
                                              |
                         D-bus memory select -+
```

Each memory has its own native `WishboneArbiter`: data master 0, instruction
master 1. The instruction side has no peripheral path. GPIO and UART are
peripheral-only. Unmapped instruction, memory, or peripheral accesses return a
Wishbone error.

## Memory map

| Region | Address range |
|---|---:|
| Internal ROM | `0x00000000`–`0x00007fff` |
| Internal SRAM | `0x00008000`–`0x0000ffff` |
| SPI flash XIP, 1 MiB | `0x10000000`–`0x100fffff` |
| SiP SDRAM, 8 MiB | `0x80000000`–`0x807fffff` |
| GPIO | `0xff000000` |
| UART | `0xff001000` |
| SPI flash control | `0xff002000` |

The SPI controller is native `Apb3SpiXdrMasterCtrl`. XIP uses fast-read opcode
`0x0b`, which matches the controller's mandatory dummy byte. Responses are
assembled in big-endian order and aligned to 32-bit words before the CPU selects
a byte or halfword lane. ROM and SRAM use synchronous one-cycle reads. FPGA boot
ROM uses `EG_LOGIC_BRAM` with a generated MIF; simulation uses a native `Mem`.

## 32-bit GPIO

`J2Pio` wraps native `WishboneGpio` with 32 bidirectional pins:

| Offset | Function |
|---:|---|
| `0x00` | Input values |
| `0x04` | Output values |
| `0x08` | Output enable, one bit per pin; reset to zero/input |

The Tang Primer top instantiates 32 `EG_PHY_PAD` primitives with `MODE="BI"`,
`TSMUX="TS"`, `DRIVE="12"`, and `IOTYPE="LVCMOS33"`. `ts` is the inverse of the
native output-enable signal: zero drives the pad, one makes it high impedance.
The simulation-only model is `verilog/verif/j2_gpio_pad_model.v`.

GPIO 0–2 retain the RGB LED locations R3/J14/P13. GPIO 3–31 use free
display/camera header pins listed in `fpga/j2_tang_primer_verilog/j2_tang_primer.adc`.
All external pins are LVCMOS33. The legacy validation ROM enables outputs at
`0xff000008` before writing values at `0xff000004`.

## Project layout

- `spinal/src/main/scala/j2/core/`: CPU, datapath, pipeline, register file, MAC.
- `spinal/src/main/scala/j2/isa/`: ISA definitions and microcode predecoder.
- `spinal/src/main/scala/j2/microcode/`: ROM data, control decoding, sequencing.
- `spinal/src/main/scala/j2/bus/`: byte-addressed CPU Wishbone and native adapters.
- `spinal/src/main/scala/j2/periph/`: ROM/SRAM, GPIO, SPI/XIP, SDRAM peripherals.
- `spinal/src/main/scala/j2/soc/`: SoC interconnect, PLL/reset, board top.
- `sw/xiprom/`: resident boot ROM, flash driver, and UART loader.
- `sw/xipapp/`: XIP application and SDRAM read/write/execute tests.
- `tools/xip_image.py`: application packager and host-side UART uploader.
- `third_party/qspiflash/`: flash simulator sources only; upstream RTL is removed.
- `fpga/j2_tang_primer_verilog/`: the sole FPGA project.
- `reference/`: original VHDL/VHM sources for simulator cross-reference.
- `docs/isa/j2_isa.csv`: ISA instruction and micro-step specification.

The canonical microcode source is `spinal/src/main/resources/j2_microcode.hex`,
containing all 256 72-bit entries. `j2_predecode.tsv` is the generated opcode
mapping. `make microcode-mif` generates the FPGA MIF on demand; no separately
maintained microcode representation is required.

## Toolchain

- Java 21, sbt 1.10.7, Scala 2.13.14, SpinalHDL 1.14.2
- Scalafmt 3.8.4; run `scalafmtAll` in `spinal/` after Scala edits
- Verilator for core and SoC simulation
- Tang Dynasty 4.6.7 at `TD_HOME`

## Verification

```sh
make spinal-test            # 27 retained CPU and ISA test suites
make spinal-generate        # CPU and SoC Verilog under build/spinal/verilog
make spinal-microcode-verif # full ROM, RTE, and interrupt regressions
make verilog-hw-sim         # native SoC and full legacy CPU test ROM
make xip-hw-sim             # direct XIP and blank-flash UART loader tests
make reference-verif        # full ROM and RTE on the VHDL baseline
```

The XIP regression runs once from preloaded flash and once after a blank-flash
UART upload. Both paths print `SDRAM tests passed` and `XIP CPU tests passed`.
A timeout without expected UART output fails. Integration pitfalls and their
fixes are recorded in `docs/microcoded-core-debug.md`.

## FPGA

The default SoC frequency is 30 MHz using `feedbackDivider=15` and
`outputDivider=12`. Override generation parameters with:

```sh
J2_CLOCK_HZ=30000000 J2_USE_PLL=1 make verilog-fpga
```

`J2_USE_PLL=0` selects the 24 MHz input directly for diagnosis. UART divisors
and simulation baud timing derive from `J2_CLOCK_HZ`; the FPGA SDC is generated
with the same value. `spinal-fpga` remains a compatibility alias.

The final 30 MHz build reports 9,832 LUTs, 2,151 registers, nine DSPs, 37 9K
BRAMs, and 10 32K BRAMs. Timing passes with 0.058 ns minimum setup slack and no
hold violations. The 48 MHz configuration was also tried but failed timing;
higher frequencies must be validated rather than assumed.

Program volatile FPGA configuration and listen at 19,200 baud:

```sh
make verilog-program TD_HOME=/home/imi415/Softwares/Tools/TD_4.6.7_Linux
stty -F /dev/ttyACM0 19200 raw -echo
cat /dev/ttyACM0
```

`verilog-program` writes only volatile FPGA configuration SRAM, never external
configuration flash. To upload the application after a fresh boot banner:

```sh
make xip-upload
```

If the ROM is already waiting at `J2 loader`, use:

```sh
tools/xip_image.py upload build/sw/xipapp/flash.bin --no-wait
```

The free Winbond 25Q80 uses CS=D3, CLK=H4, MOSI=B3, MISO=F4, IO2=F5, and
IO3=B1. IO2/WP and IO3/HOLD are driven high. The configuration flash on
CSO/CCLK is never targeted. Generated output and logs stay under ignored
`build/` directories; Verilog TD logs are under `build/logs/td_verilog`.
