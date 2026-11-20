# FPGA build flows

Select a board for the complete ROM → RTL → synthesis → implementation →
bitstream flow:

```sh
make BOARD=tang-primer fpga TD_HOME=/path/to/TD_4.6.7_Linux
make BOARD=wukong-v1 fpga
make BOARD=wukong-v1 fpga-plan       # commands only; no generated files
make BOARD=wukong-v1 fpga-rtl        # ROM and RTL only
make BOARD=wukong-v1 fpga-synth      # Vivado synthesis checkpoint
make BOARD=wukong-v1 fpga-impl       # implement the successful checkpoint
make BOARD=wukong-v1 fpga-program   # volatile JTAG download of the built image
```

`fpga` never programs a device. `fpga-program` uses the default bitstream only
when its implementation completion marker exists. `BITSTREAM=/absolute/path`
selects an explicit image. Neither vendor programming flow writes configuration
flash. Anlogic runs synthesis and implementation together through `fpga`;
`fpga-synth` and `fpga-impl` are Xilinx stages.

`J2_ROM=/path/to/boot.bin` optionally replaces the ROM binary. `TD_BIN` can
select the Anlogic executable directly. `VIVADO_HOME` and `VIVADO_COMPAT_LIB`
select Vivado and its host libraries; `tools/run_vivado.sh` retains the Ubuntu
24 library setup needed by the installed Xilinx tools.

## Ownership

Each board owns `fpga/<name>/board.properties` and `build.tcl`. The Python
launcher `tools/fpga.py` builds the ROM and invokes the configured Scala generator,
then runs that board's Tcl script using the selected vendor executable.

Each Scala board SoC directly instantiates its CPU, memories, buses and
peripherals. `scifBase`, `cmtBase`, `spiControlBase` and `xipCacheControlBase`
configure the boot SCIF, CMT, SPI controller and XIP cache control addresses in
both RTL and firmware. Current boards use `0xff001000`, `0xff003000`,
`0xff002000` and `0xff004000`, respectively. `scifFifoDepth=4` selects four-byte
TX/RX FIFOs on both boards. These peripherals occupy aligned 4 KiB windows. Rebuild RTL and
firmware together after relocating them. Memory sizes and windows continue to
come from the board profile, while the board SoC owns the actual memory and
controller choices.

A minimal Anlogic entry point is:

```tcl
source [file join $::env(J2_FPGA_TOOLS) anlogic.tcl]
fpga_run
```

A Xilinx entry point sources `xilinx.tcl` instead. Both shared flows reside in
`tools/fpga/` and source `common.tcl` for generated settings and hook dispatch.
Boards may define these procedures before calling `fpga_run`:

| Hook | Responsibility |
|---|---|
| `board_prepare` | Create/read board IP before elaboration or synthesis |
| `board_post_synth` | Additional constraints and netlist checks |
| `board_pre_impl` | Clock/checkpoint checks before implementation (Xilinx) |
| `board_post_impl` | Board-specific routed-design checks before bitstream generation |

Wukong owns its MIG/reset IP, clock checks, BRAM ownership checks and CDC/skew
constraints in its board directory. These assumptions are not imposed on other
Xilinx boards. The standalone DDR and reset qualification scripts also live
there. Tang owns its TD project, pin assignments and timing template.

Generated Tcl exposes `root`, `out`, `board_dir`, `rtl`, `work`, `reports`, `top`
and settings from `build/<board>/board.tcl`. Hooks run in the global Tcl context;
procedures should declare the globals they use. Generated files stay under
`build/`; source constraints and project templates are copied, not edited.

## Adding a board

Create a directory under `fpga/`, provide its properties, Tcl entry point,
constraints and a Scala top/generator. No board-name registration is needed in
`BoardProfile`, `board_config.py`, the Makefile or the vendor flow.

The hardware/firmware fields retain the shared schema described in
[development](development.md). The FPGA flow uses these additional fields:

| Property | Meaning |
|---|---|
| `vendor` | `xilinx` or `anlogic` |
| `generator` | Scala `runMain` entry point |
| `top` | Generated RTL top-module name |
| `part` | Vendor device identifier |
| `pinConstraints` | Board-relative XDC or ADC file |
| `rtlSources` | Optional comma-separated RTL filenames; defaults to `<top>.v` |
| `rtlDirectory` | Optional repository-relative output; defaults to `build/<board>/rtl` |
| `buildDirectory` | Optional working directory; defaults to `build/<board>/vivado` or `anlogic` |
| `reportDirectory` | Optional report directory; defaults to the working directory |
| `projectFile` | Anlogic board-relative `.al` template |
| `timingTemplate` | Anlogic board-relative `.sdc.in` template |
| `jtagPart` | Optional Vivado hardware-device match pattern |
| `jtagCable` | Optional Anlogic cable index; defaults to zero |

The current boards retain their existing output paths through these fields.
Anlogic timing templates substitute `@inputClockPeriod@`, `@clockPeriod@` and
other property names. `@if usePll@` / `@endif@` conditionally includes PLL timing.

Properties are trusted, version-controlled board descriptions. Shared loaders
check numeric/address invariants, not board names, part numbers, supported
memory technologies or board-specific PLL combinations. Hardware implementation
constraints belong to the corresponding board components and Tcl hooks.

Environment overrides are opt-in properties: `clockHzEnv=J2_CLOCK_HZ` maps the
named environment variable to `clockHz`. Tang declares its legacy clock/PLL
overrides; Wukong does not, so recursive Make environments cannot change its
clock. The launcher supplies `J2_BOARD_PROPERTIES`, `J2_ROM_HEX` and
`J2_SPINAL_OUT` to the generator. `BoardProfile.load` uses the explicit profile
path when supplied, allowing a new generator or reuse of a compatible top.

Existing commands such as `verilog-fpga`, `wukong-synth` and `wukong-bitstream`
remain Make aliases for the common launcher. Use these targets or
`tools/fpga.py` directly; obsolete vendor shell wrappers have been removed.

The board also owns its INTC request map through `interruptSources` (ordered
names). Its SoC wires those names to peripheral requests; the firmware build
emits `j2_board_irqs.h` into its output directory. A board interrupt-map change
requires rebuilding both RTL and firmware. Generic INTC register offsets stay
in `sw/include/j2_intc_regs.h`.

`scifFifoDepth` selects SCIF buffering per board (0–255). Zero retains one holding
register per direction; positive values specify FIFO capacity. All depths use
the SCIF register layout and the same firmware driver. The current boards use
four; changing depth requires regenerating RTL, without a firmware ABI change.
