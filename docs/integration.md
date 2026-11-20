# Integration and bring-up checks

[Development](development.md) · [CPU architecture](cpu-architecture.md) · [SoC reference](soc.md)

Use the board-specific SoC and memory backend for FPGA generation. Simulation
uses inferred memories and models; a passing simulation does not establish
clock, reset, memory initialization or pin correctness on hardware.

## Reset, clocks and memories

Reset vectors contain initial PC and SP. BootROM startup copies its data and
zeros BSS before C code; application startup owns its own initialization and
any relocation. BootROM uses internal SRAM and boots XIP images only.

Check the generated ROM contents and synthesis memory report, not just the
source hex file. Boot ROM and microcode have synchronous read latency; their
response metadata must stay aligned with returned data. Vendor mapping is
selected at generation time, outside the core. See [memory backends](memory-inference.md).

Tang uses its PLL/reset controller. Wukong uses `proc_sys_reset`, configuration
EOS, clock locks and synchronized DDR calibration readiness. Check cold power
startup and FPGA-only reconfiguration separately. Follow each board's clock
constraints; changing a system clock also changes UART and peripheral timing.

## Fetch, buses and flash

An instruction's PC, delay-slot state, memory response and exception metadata
must advance or stall together. Use the existing CPU regressions for dependent
loads, branches, faults, MUL/MAC and TAS.B; [pipeline contracts](sh2-pipeline.md)
describe the supported behavior. Production buses are AHB5 and APB4. Wishbone
adapters under test sources serve reference regressions only.

The XIP cache sits before the physical SPI endpoint. Flash-control writes
serialize with refills and invalidate cached data. Check direct XIP, warm
restart and UART programming independently; a warm flash may retain quad mode.
Tang uses Winbond initialization, while Wukong's separate SF3 uses Micron
4-4-4 commands. The board profile selects the protocol and physical offset.
On Wukong, the onboard configuration flash is separate from application flash.

## Reproduction and evidence

```sh
make spinal-test
make spinal-microcode-verif
make isa-sim
make wukong-sim
python3 -m unittest discover -s tools -p 'test_*.py'
```

Build with `make BOARD=<board> fpga`. Use the board programming and validation
commands in [Tang Primer](tang-primer.md) or [Wukong](wukong-v1.md).
Programming FPGA SRAM is volatile; UART application upload changes application
flash. Record the generated image/hash, profile, UART transcript and timing
report together so an old bitstream is not mistaken for the current build.

The boot tests cover preloaded flash, warm protocol recovery and blank-flash
upload. The application owns external-memory, ISA, cache, CMT and INTC tests.
Production BootROM polls the four-byte SCIF RX FIFO; it has no RX ISR or
software ring. [SCIF](scif.md) records register, FIFO, error and hardware
validation. [CoreMark](coremark.md) retains benchmark comparisons and durations.
