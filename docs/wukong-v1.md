# Wukong v1 port

Step 1 separates board integration and provides a synthesizable XC7A100T
platform. The CPU, pipeline, Wishbone matrix, peripherals and cache remain
shared with Tang Primer. DDR3 integration and application boot are subsequent
steps; this target is not yet a complete replacement for the Tang SoC.

## Board profile

`fpga/wukong-v1/board.properties` is the shared source for the Scala board
configuration, firmware header and Vivado settings. The schematic and DDR3
example used for the pin audit are in `../Wukong/`.

| Setting | Value |
|---|---|
| FPGA | `xc7a100tfgg676-2` |
| Oscillator | 50 MHz, M22 |
| Initial SoC clock | 32 MHz, PLL VCO 800 MHz / 25 |
| UART | `/dev/ttyUSB0`, 19,200 baud, 8N1; FPGA RX F3, TX E3 |
| Reset button | KEY0, H7, active low |
| LEDs | J6: PLL lock; H6: system-clock heartbeat; active low |
| Configuration flash | Onboard Micron MT25QL128, 16 MiB; CS P18 held high after configuration |
| Application flash | Digilent Pmod SF3, 32 MiB, on J11 |
| Application flash pins | CS H4; SCK A5; DQ0..3 F4/A4/B4/B5 |
| GPIO | Software bits 0..15 on JP2, 24..31 on J10; 16..23 reserved/read as zero |

The oscillator uses the **N side** of a clock-capable pair. Vivado reports
PLCK-12/PLIO-9 without the input routing exception also present in the QMTECH
example. `clock_route.xdc` applies `CLOCK_DEDICATED_ROUTE FALSE` only to
`clk50_IBUF`, after synthesis creates that net. PLL feedback and output use
BUFGs. Routed timing is checked at the initial 32 MHz SoC clock.

## Separate configuration and application flash

The SF3 on J11 is the application flash. It supersedes the original shared-flash
plan: the application starts at **physical offset zero**, rather than 8 MiB.
The onboard configuration flash is not connected to the SoC SPI controller.
Its CS stays high and STARTUPE2 leaves CCLK undriven by user logic.

| Device / physical bytes | Use |
|---|---|
| Onboard `0x000000–0x3FFFFF` | Configuration slot 0, 4 MiB |
| Onboard `0x400000–0x7FFFFF` | Reserved configuration slot 1; recovery/update support is future work |
| Onboard `0x800000–0xFFFFFF` | Reserved |
| SF3 `0x000000–0x0FFFFF` | Application partition, initially 1 MiB |
| SF3 `0x100000–0xFFFFFF` | Outside the current application partition |
| SF3 `0x1000000–0x1FFFFFF` | Requires future four-byte/banked addressing support |

XC7A100T's full configuration payload is 3,825,788 bytes, so two 4 MiB slots
fit within the 8 MiB reservation. See [AMD UG470, Table 1-1](https://docs.amd.com/api/khub/documents/FOs3lXmlcWxBhTIFxVKyGA/content).
The build checks the configuration binary against one 4 MiB slot.

The CPU XIP window remains `0x10000000–0x100FFFFF`; refills translate using
`flash address = CPU address - 0x10000000 + flashOffset`, now with offset zero.
The physical SF3 capacity is 32 MiB, but the SPI controller currently transmits
24-bit addresses. Configuration validation rejects XIP windows beyond the
lower 16 MiB. Future loader code must separately enforce partition bounds.

The [Digilent SF3 manual](https://digilent.com/reference/_media/reference/pmod/pmodsf3/pmodsf3_rm.pdf)
and Wukong schematic give this mapping (do not confuse the two header rows):

| J11 pin | SF3 signal | FPGA pin |
|---|---|---|
| 1 | CS# | H4 |
| 2 | DQ0 / MOSI | F4 |
| 3 | DQ1 / MISO | A4 |
| 4 | SCK | A5 |
| 7, 8 | Not connected | J4, G4; unused by this top |
| 9 | DQ2 / WP# | B4 |
| 10 | DQ3 / HOLD# | B5 |
| 5, 11 | Ground | Ground |
| 6, 12 | Supply | 3.3 V |

J11 is reserved for flash. GPIO writes cannot drive its pins; the corresponding
software input bits read zero. The top's 24 GPIO pads represent software bits
0..15 followed by 24..31, preserving JP2 and J10 software numbering.
DQ2/DQ3 have pull-ups for single-SPI operation. The SF3 manual identifies
N25Q256A; current modules may use MT25QL256. Neither should receive the Tang
loader's Winbond-specific QE/status initialization.

## Integration boundary

```mermaid
flowchart LR
  P["Board PLL + reset + I/O"] --> S["Shared J2Soc"]
  S --> R["Boot ROM / SRAM / microcode<br/>Xilinx block RAM inference"]
  S --> U["UART / timer / GPIO"]
  S --> C["XIP cache<br/>physical application offset"]
  C --> F["SPI on J11<br/>Pmod SF3 application flash"]
  S --> B["External-memory Wishbone port<br/>byte addresses + LOCK + ERR"]
  B --> E["Step 1: error termination<br/>Later: CDC + MIG DDR3"]
```

`J2MemoryBackend` selects generic inference, EG4 block RAM or Xilinx block RAM
inference. Xilinx uses synchronous reads with `ram_style=block`; microcode keeps
its rising-edge, enabled read and response-address tag. `J2SocConfig` supplies
the boot image, clocks, address windows and physical flash offset.

The EG4 SDRAM controller now lives in the Tang board wrapper, outside the
shared SoC. The external-memory port preserves absolute byte addresses, byte
selects, lock ownership and error responses. Wukong terminates DDR accesses
with ERR until its controller is implemented, rather than leaving requests
waiting forever. The initial DDR window remains 8 MiB at `0x80000000`.

The board uses Vivado's `proc_sys_reset` v5.0 IP. Its clock is the 32 MHz PLL
output, its external reset is KEY0, and its lock input requires both PLL LOCKED
and configuration EOS. The SoC uses `peripheral_reset`. IP parameters are
versioned in `tools/wukong_ip.tcl`; generated products stay under `build/`.

`sw/wukongrom` initializes the SF3 for **4-4-4 quad protocol** at 4 MHz:
command, address and payload all use DQ0..3. It first recovers single SPI if a
previous FPGA image left the flash in quad mode, selects three-byte addressing
and bank zero, then records single-SPI reference data from five 32-byte blocks.
It writes volatile VCR `0x8b` (eight dummy clocks, sequential reads, no
commandless flash-XIP), clears EVCR bit 7 to enable quad protocol, and verifies
quad `0xaf` JEDEC ID `20ba19`. No Winbond QE writes are used.

The cache backend uses quad `0xeb` commands on every burst, three quad address
bytes, four quad dummy bytes (eight clocks) and quad payload. The controller's
`dummyCount` is bytes minus one, hence `3`; mode selection is `0x01010101`.
The ROM compares cached reads at offsets 0, 32, `0x100`, `0x800`, and the last
cache line of the XIP window with the single-SPI reference, then echoes UART.
The fixed quad ID exercises all four input lanes even when array contents are
erased. Flash array data and nonvolatile registers are never written. See
[Micron N25Q256A register and read-command specifications](https://www.digikey.com/htmldatasheets/production/7446839/0/0/1/n25q256a.pdf).

The flash remains in quad mode after the diagnostic. Initialization handles
that state on the next FPGA-only reset; power cycling restores the flash's
nonvolatile defaults. The ROM does not access DDR or boot an application.
The existing Tang boot ROM is unchanged.

## Build and validation

```sh
make wukong-generate  # separate ROM and SpinalHDL board RTL
make wukong-sim       # ROM UART + quad ID/XIP; cold and warm flash states
make wukong-synth     # Vivado synthesis, pins, DRC and memory-inference checks
make wukong-reset-sim # XSim with the generated vendor reset IP
make wukong-bitstream # place/route, timing gates and volatile configuration image
make wukong-uart      # Vivado JTAG download + UART banner, quad SF3 ID/XIP and echo checks
make isa-sim          # shared CPU and existing Tang SoC regression
```

The default tool directory is
`/home/imi415/Softwares/Tools/Xilinx/2025.2/Vivado`. Override `VIVADO_HOME` if
needed. `tools/run_vivado.sh` prepends the matching Xilinx installer's
`.xinstall/2025.2/lib/lnx64.o/Ubuntu/24` directory to `LD_LIBRARY_PATH`, as required
on this host. `VIVADO_COMPAT_LIB` can override that directory. No system
libraries are modified. For XSim, the wrapper also locates the host C runtime
objects using GCC and adds their directory to `LIBRARY_PATH`.

Outputs are isolated under `build/wukong-v1/{rom,rtl,vivado}`. Synthesis checks
for missing package pins, DRC errors, unresolved black boxes and absent block
RAM. A completion marker prevents a Vivado initialization failure that returns
exit status zero from appearing successful.

Implementation checks setup/hold timing and DRC, then writes `.bit` and `.bin`
files. External GPIO/SPI timing is not yet fully constrained or qualified;
passing internal timing does not establish maximum external-interface speed.
The hardware test opens UART before programming, downloads the bitstream with
Vivado through the single connected cable, checks the exact ROM banner and
Micron quad JEDEC ID `20ba19`, the XIP comparison result, and UART echo. It records the bitstream
SHA-256 and UART transcript under `build/wukong-v1/hardware`.

For an explicitly selected implemented image:

```sh
make wukong-program WUKONG_BITSTREAM=/absolute/path/to/validated.bit
```

Both programming helpers configure volatile FPGA SRAM only. They do not write
either flash device.

The platform-ROM simulation checks banner, offset, quad JEDEC ID, cached reads
and UART echo with three initialization seeds, including a flash already in
quad mode. A pin-level Micron model supplies nonuniform array data and checks
quad lane direction, burst length, allowed commands and all five refill addresses.
No DDR access is allowed. One clock/reset driver
avoids competing automatic/manual reset stimulus. The vendor reset simulation
checks cold startup, clock-lock loss and button reset, including synchronous
release with the documented UNISIM primitive propagation delays.

The existing 53 CPU/peripheral tests and all three Tang SoC boot modes (reset,
cold, UART loader) passed after the shared refactor. Tang hardware RTL generation
also passed.

Validation on 2026-11-18:

- SF3 quad ROM simulation passed all three seeds, including warm quad-state
  recovery; vendor reset simulation passed.
- Routed 32 MHz timing: setup WNS **14.282 ns**, hold WHS **0.084 ns**,
  no failing constrained endpoints. CDC reports two safe endpoints, none unsafe.
- Routed utilization: **4,183 LUTs, 2,704 registers, 17 RAMB36s, 4 RAMB18s,
  five DSPs**. Boot ROM and SRAM each use eight RAMB36s; microcode uses one.
- Volatile Vivado JTAG programming passed on the connected XC7A100T.
  `/dev/ttyUSB0` delivered the ROM banner, quad SF3 ID **20ba19**, quad XIP comparison PASS and UART echo at
  19,200 baud. Both initial and repeated volatile downloads passed with flash
  power retained. Only volatile flash registers changed; no array erase/program
  or nonvolatile configuration writes were sent.
- DRC has no errors or critical warnings. Remaining warnings include the board
  clock routing exception, DSP pipeline opportunities and BRAM asynchronous
  control checks. External GPIO/SPI timing still needs qualification.

The hardware transcript is:

```text
Wukong-v1 platform ROM
Application flash offset: 00000000
SF3 quad ID: 20ba19
SF3 quad XIP: PASS
DDR3 and application boot pending
Wukong UART check
```

Evidence and artifact hashes are in `build/wukong-v1/validation/results.json`;
raw hardware logs and the programmed bitstream hash are in
`build/wukong-v1/hardware/`. Quad identification and cached data reads are validated. Application loading,
flash programming, executing code from SF3 and DDR operation remain pending.

## Next steps

1. Regenerate MIG and validate DDR calibration/traffic independently.
2. Add the Wishbone/MIG adapter and clock crossing, preserving byte ordering and TAS locks.
3. Implement bounded SF3 application loading and XIP application boot.
4. Run the full ISA suite, DDR tests and both CoreMark seed sets for at least ten seconds.
