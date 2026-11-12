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
| 5 | Wishbone fabric, Wishbone→native bridge, peripherals | — |
| 6 | FPGA readiness | — |

\* The released J2 vectors illegal instructions through VBR+0. `ref_cpu_ill` is the same original design with that one fix (vectors 4/6).

## Layout

```
reference/   original J-Core source (read-only)
spec/        j2_isa.csv: instruction / micro-step spec (source of truth for the decoder)
rtl/pkg/     packages (j2_isa_pkg.sv is generated)
rtl/core/    CPU: j2_cpu, j2_decode*, j2_datapath, j2_regfile, j2_mult, j2_sr,
             j2_dbus_wbm, j2_ibus_wbm, j2_debug (j2_decode_table.sv is generated)
ref/         VHDL wrappers for the reference; ref/gen = GHDL-converted Verilog
tools/       gen_decode.py, gen_random.py, ods2csv.py, ref_synth.sh, env.sh,
             third_party/build-tools.sh
sim/         j2sim (Verilator simulator of the new CPU), j2iss (golden instruction-set
             simulator), shared C++ models (sim/common), generated tables (sim/gen)
tests/       decode/, unit/, ref/ (baseline and lockstep testbenches)
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
