# J2 rewrite: SystemVerilog J-Core J2 with Wishbone B4

A modular SystemVerilog rewrite of the J-Core J2 CPU, which is SH-2 compatible, and of its SoC peripherals. The original VHDL release lives in `reference/` and stays untouched. It is converted to Verilog with GHDL and used as the golden reference in simulation.

## Status

| Phase | Content | Gate |
|---|---|---|
| 0 | Toolchain, reference flow, baseline | The original CPU, converted from VHDL, passes the test ROM, `rte.S` and `interrupts.S`* |
| 1 | Decoder generator (`spec/j2_isa.csv` → SV) | Exhaustive equivalence with the original decode tables (8.4 M vectors) |
| 2 | ALU, register file, multiplier | Differential tests against the original units |
| 3 | Pipeline + Wishbone bus units (`j2_cpu`) | **Cycle-exact lockstep with the original CPU** |
| 4 | `j2iss` instruction-set simulator, `j2sim`, constrained-random programs | Every instruction, memory access and register write checked against the ISS |
| 5 | Wishbone fabric, native peripherals, `j2_soc` | Reference and native SoCs pass the test ROM; peripheral register/IRQ tests pass |
| 6 | FPGA readiness | Original VHDL boots on Tang Primer/EG4S20 and passes `CPU tests passed` |

\* The released J2 vectors illegal instructions through VBR+0. `ref_cpu_ill` is the same original design with that one fix (vectors 4/6).

## Layout

```
reference/   original J-Core source (read-only)
spec/        j2_isa.csv: instruction / micro-step spec (source of truth for the decoder)
rtl/pkg/     packages (j2_isa_pkg.sv is generated)
rtl/core/    CPU: j2_cpu, j2_decode*, j2_datapath, j2_regfile, j2_mult, j2_sr,
             j2_dbus_wbm, j2_ibus_wbm, j2_debug (j2_decode_table.sv is generated)
rtl/wb/      Wishbone decoder, SRAM, and Wishbone→native bridge
rtl/periph/  PIO, SPI, cache control, uartlite, AIC, and peripheral decoder
rtl/soc/     j2_soc: CPU, SRAM, native Wishbone peripherals
rtl/fpga/    Tang Primer EG4S20 top, Anlogic ADC and SDC constraints
ref/         VHDL wrappers for the reference; ref/gen = GHDL-converted Verilog
tools/       gen_decode.py, gen_random.py, ods2csv.py, synth_tang_primer.ys, ref_synth.sh, env.sh,
             third_party/build-tools.sh
sim/         j2sim (Verilator simulator of the new CPU), j2iss (golden instruction-set
             simulator), shared C++ models (sim/common), generated tables (sim/gen)
tests/       decode/, unit/, ref/, soc/, periph/, fpga/
sw/          test programs: original test ROM, original simulator tests, stress program
```

## Toolchain

System tools are used when they are installed: verilator, ghdl (with synthesis), yosys, and sh-elf-gcc (Debian: `gcc-sh-elf`).

Any tool missing from the system can be built into `tools/local` without root. The script skips tools that are already installed; set `FORCE=1` to build them anyway.

```
tools/third_party/build-tools.sh     # flex, bison, help2man, Verilator, Yosys, GNAT (bootstrap) + GHDL,
                                     # and the SH toolchain from ../Rev_UDI/Toolchain/sh-none-elf.tar.gz
```

The Makefile and `tools/ref_synth.sh` fall back to `tools/local` on their own. For interactive use, `. tools/env.sh` appends it to PATH, after the system directories.

## Running

```
make check          # everything below
make gen            # regenerate decoder files from spec/j2_isa.csv
make ref            # convert the original VHDL to Verilog (ref/gen)
make lint           # verilator -Wall on the RTL
make test-decode    # exhaustive decoder equivalence
make test-unit      # ALU / regfile / multiplier vs original
make test-ref       # baseline: original CPU runs the test programs
make test-lockstep  # new CPU vs original CPU, cycle-exact: test ROM, rte.S, interrupts.S,
                    # random bus stall/latency, random interrupts/errors/resets/debug commands
make test-isa       # test programs on the new CPU, checked by the j2iss ISS
make test-random    # constrained-random programs (RANDOM_N=16), checked by the ISS
make test-soc       # reference and native peripheral SoCs run the test ROM
make test-periph    # PIO, SPI, UART, cache control and AIC bus/IRQ tests
make test-fpga      # Tang Primer top at 24 MHz, boot and UART console
make synth          # Yosys/slang Anlogic netlist for the Tang Primer EG4S20
make bitstream      # full TD VHDL flow for the original-CPU hardware validation
make program        # load the validation bitstream into volatile FPGA SRAM over JTAG
```

### j2sim

```
make j2sim [TRACE=1]
build/j2sim/j2sim image.bin [--iss] [--log-ops] [--stall S --kmin K --kmax K --seed N]
                            [--irq-rand N] [--expect STR] [--max-cycles N] [--trace f.fst A B]
```

With `--iss`, the ISS checks:
- each instruction the CPU starts (opcode, and so control flow);
- every data access, in order;
- every value written to each register.

Interrupts, errors and resets are applied to the ISS at the same instruction boundaries where the RTL accepts them.

`j2iss` models J2 where it differs from the SH-2 manual:
- SLEEP doesn't halt;
- a slot-illegal exception stacks the branch target;
- interrupt entry pushes to the word-aligned stack;
- CAS.L with Rm = Rn always succeeds.

These are documented in `sim/iss/j2iss.h`.

## CPU parameters (`j2_cpu`)

| Parameter | Default | Meaning |
|---|---|---|
| `ILLEGAL_VEC_FIX` | 1 | Illegal and slot-illegal instructions use vectors 4 and 6. 0 = as released (vector 0). |
| `ILLEGAL_OPCODE_TRAP` | 1 | Every opcode not defined by the spec raises the illegal-instruction exception. 0 = only 0xFFxx traps, as released; other undefined opcodes have unspecified behaviour. |

## Bus

The CPU has separate instruction and data **Wishbone B4 pipelined** masters:
- big-endian byte lanes, with `sel[3]` = byte offset 0;
- reads carry a size-accurate `sel`;
- `lock` covers TAS.B and CAS.L;
- `tgc[0]` = jump-target fetch.

Acks arrive at least one cycle after a request is accepted. Compared with the original's zero-wait SRAM, each access therefore costs one extra cycle. Instruction flow is unchanged: a slave that acks *k* cycles after accepting behaves exactly like a native-bus slave with ack latency *k*.

## SoC peripherals

`j2_soc` preserves the Mimas v2 address map:

| Address | Device |
|---|---|
| `0xABCD0000` | PIO (32-bit input/output, edge mask, change latch) |
| `0xABCD0040` | SPI (one-byte transactions, two chip selects, loopback) |
| `0xABCD00C0` | cache control/status registers |
| `0xABCD0100` | Xilinx uartlite-compatible UART, nominal 19,200 baud |
| `0xABCD0200` | AIC (interrupt priority/vectors, PIT, RTC, breakpoint/error events) |

## FPGA target

The board is a Sipeed Tang Primer with an Anlogic EG4S20BG256. It runs at the
board's 24 MHz clock. The console is UART1 at 19,200 baud: FPGA TX is J13 and
FPGA RX is H13.

Two FPGA paths are present:

- `make synth` uses Yosys/slang and TD place-and-route for the SystemVerilog SoC
  ([j2_tang_primer.sv](rtl/fpga/j2_tang_primer.sv)).
- `make bitstream` is the hardware-validation path. It performs analysis,
  elaboration, mapping, packing, placement, routing and bit generation entirely
  in TD from the original J-Core VHDL. Yosys is not used for this path.

The validation wrapper is
[j2_tang_primer_original.vhd](rtl/fpga/j2_tang_primer_original.vhd). It runs the
released CPU, UART and PIO directly and supplies a 32 KiB, 8192x32 TD block RAM
initialized from the test ROM. [j2_eg4_bram32.v](rtl/fpga/j2_eg4_bram32.v) is
the TD `EG_LOGIC_BRAM` wrapper. The generated MIF image is build-local.

The verified original-VHDL mapping uses 4,304 LUTs, 984 registers, two DSPs,
eight BRAM32K blocks, and 4,404 of 19,600 logic elements. TD reports no setup
errors and a 26.541 ns minimum period at the 41.667 ns clock constraint. Four
hold checks remain in the route report; they are associated with the generated
clock mesh and are still under investigation. Setting TD's `route fix_hold`
property before routing produced an identical report. On hardware, the
original test ROM completes and prints `CPU tests passed` followed by the GDB
stub banner.

```
make bitstream TD_HOME=/path/to/TD_4.6.7_Linux
make program   TD_HOME=/path/to/TD_4.6.7_Linux
```

`make program` uses `download -mode jtag`, which loads volatile FPGA
configuration SRAM. It does not write the external configuration flash.

Build products are under `build/fpga`; TD and synthesis logs are under
`build/logs`. The Tcl and generated project paths are relative to their working
directories, and all generated artifacts are ignored by Git.

### SDRAM path

The EG4S20 package contains a 64 Mbit (2M x 32) SDRAM die exposed through TD's
`EG_PHY_SDRAM_2M_32` hard PHY. Its pins are package-internal, so there are no
SDRAM entries for [tang_primer.adc](rtl/fpga/tang_primer.adc). TD supplies the
PHY but not a complete SDRAM controller: initialization, refresh, command
sequencing, data capture and arbitration remain soft logic. The local TD
templates under `SDRAM_Test/al_ip` are incomplete and provide useful PHY/PLL
configuration examples only.

The recommended first mapping is:

| Range | Use |
|---|---|
| `0x00000000` | On-chip BRAM boot/recovery code |
| `0x10000000` | 8 MiB EG4S20 SiP SDRAM |
| `0xABCD0000` | Original peripheral map |

Generate the controller and PHY clocks from an `EG_PHY_PLL` with the documented
0/90-degree relationship, and begin at a lower SDRAM rate than the example's
168 MHz. First validate a direct, uncached Wishbone data path while executing
from BRAM, then add the instruction port/arbiter. Add caches only after direct
access, byte masks, `TAS.B`/`CAS.L` locking and refresh are proven. This keeps
the BRAM image as a recovery path throughout bring-up.
