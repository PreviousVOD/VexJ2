# J2SCIF: SCIF registers with configurable buffering

Each board instantiates `j2.periph.J2SCIF(fifoDepth)` directly. `scifBase` and
`scifFifoDepth` in `board.properties` select its address and buffering. Both
current boards use base `0xff001000` and depth `4`.

The register interface always follows the asynchronous SCIF in the
[SH7265 hardware manual, section 16](https://www.renesas.com/en/document/mah/sh7265-group-users-manual-hardware?r=1054971).
The local reference is `../REN_r01uh0472ej0300_sh7265_MAH_20140327_1.pdf`.
Depth zero means a single transmit holding
register and a single receive holding register, excluding the transmit shift
register. It does **not** select the old SH7124 SCI register layout or flags.
Old SCI firmware must be rebuilt against the SCIF driver.

For example, `new J2SCIF(fifoDepth = 16)` instantiates the reference FIFO capacity.
Positive depths specify the capacity in bytes of **each** FIFO; supported values
are 1–255, including non-powers of two. Depth 1 and depth 0 have equal storage
capacity. The software interface is identical at every depth.

## Registers and APB accesses

The APB4 interface is 32-bit BE32. Registers are spaced four bytes apart, so
reading SCFSR cannot accidentally pop SCFRDR. Halfword registers occupy lanes
3/2; byte registers occupy lane 3. Write strobes preserve unselected bytes.
Zero-strobe writes have no effect. Reserved lanes/fields read zero and ignore
writes; addresses beyond `0x28` and unaligned APB addresses return a bus error.
A completed read of the SCFRDR word pops exactly one byte; APB setup cycles do
not pop. Software uses the documented byte/halfword access widths.

| Offset | Register | Width | Reset / behavior |
| --- | --- | --- | --- |
| `00` | SCSMR | 16 | `0000`; CHR, PE, O/E, STOP, CKS supported |
| `04` | SCBRR | 8 | `ff`; PCLK baud divisor |
| `08` | SCSCR | 16 | `0000`; TIE, RIE, TE, RE, REIE supported |
| `0c` | SCFTDR | 8 | Write enqueues; read returns zero |
| `10` | SCFSR | 16 | `0060`; status and queued error counts |
| `14` | SCFRDR | 8 | Read pops; empty reads return zero |
| `18` | SCFCR | 16 | `0000`; RX/TX triggers and FIFO resets |
| `1c` | SCFDR | 16 | `0000`; TX count in bits 15:8, RX count in bits 7:0 |
| `20` | SCSPTR | 16 | RTS/CTS data fixed high; bit 0 reads synchronized RXD |
| `24` | SCLSR | 16 | `0000`; sticky overrun flag ORER |
| `28` | SCEMR | 16 | `0000`; unsupported extension bits fixed zero |

Synchronous/external clocks, modem flow control, loopback and SCEMR baud
extensions are unsupported and hard-wired inactive. SCSPTR.SPB2IO/SPB2DT can
drive TXD low or high when TE is disabled; without that override TXD idles high.
There is no TEI or SCI MSB-first/EIO mode. Frames are LSB-first, with 7/8 data
bits, even/odd/no parity and one/two transmit stop bits. RX checks the first
stop bit; the receive timeout accounts for the configured final stop bit.

## Clock and FIFO behavior

PCLK/Pφ is the enclosing APB clock. One bit lasts
`32 * (SCBRR + 1) * 4^CKS` clocks. RX is synchronized and sampled at bit centers;
frame settings are captured at start. No generated clock domain is used.

Writing SCFTDR submits a byte immediately. With TE enabled, queued data moves
automatically into the shift register and transmits continuously. A full FIFO
ignores excess writes. SCFDR excludes the shift register. TE=0 aborts the active
transmission but preserves queued bytes; TFRST clears and holds the FIFO empty.
Software acknowledges TDFE/TEND after enqueueing. TEND indicates the final
stop bit with no further data queued; allow that bit to finish before disabling
TE, as the shared driver does.

Receive data includes per-byte parity/framing metadata. SCFSR.PER/FER describe
the next byte to be popped and are read-only. The high nibbles count queued
parity/framing errors modulo 16, including the manual's sixteen-errors-as-zero
behavior. ER is a separate sticky event; a receive error does not stop further
reception. A full FIFO drops the arriving byte and sets SCLSR.ORER, preserving
older data. ORER blocks new frames until software clears it. RE=0 aborts the
current frame without discarding buffered data or acknowledging flags.

BRK detects a framing error followed by another framing-error zero character.
After detection, repeated zero characters are suppressed until RXD returns
high. RFRST clears and holds the receive FIFO and its per-byte error counts
empty. Buffer resets do not acknowledge sticky receive event flags.

A pop and arrival on the same edge can replace an entry in a full FIFO. An empty
read cannot consume a simultaneous new arrival. FIFO reset takes precedence
over enqueue and dequeue.

## Trigger flags, timeout and interrupts

At depth 16, triggers match SH7265. For other capacities `N=max(1,fifoDepth)`,
they scale as follows; this scaling and the full eight-bit SCFDR count fields
are project extensions to the fixed 16-byte device.

| Selector | TX threshold (TTRG) | RX threshold (RTRG) | Values at N=16 |
| --- | --- | --- | --- |
| `00` | floor(N/2) | 1 | 8 / 1 |
| `01` | floor(N/4) | ceil(N/4) | 4 / 4 |
| `10` | floor(N/8) | ceil(N/2) | 2 / 8 |
| `11` | 0 | ceil(7N/8) | 0 / 14 |

TDFE sets when TX count is at or below its threshold. RDF sets when RX count
reaches its threshold. DR sets for a nonempty, below-threshold receive FIFO
when no subsequent character completes within 15 bit periods after the final
stop bit. This gives short packets an interrupt even below the RX threshold.

ER, TEND, TDFE, BRK, RDF, DR and ORER use the project's ordinary W0C policy:
a selected zero clears, a one preserves and cannot create a flag. No hardware
read-history latch is implemented. Hardware events win simultaneous clears;
threshold flags reassert while their conditions hold. Draining SCFRDR alone
does not acknowledge RDF/DR.

The four outputs are registered by one PCLK:

| Output bit | Source | Condition |
| --- | --- | --- |
| 0 | ERI | (RIE or REIE) and ER |
| 1 | RXI | RIE and (RDF or DR) |
| 2 | TXI | TIE and TDFE |
| 3 | BRI | (RIE or REIE) and (BRK or ORER) |

Each board owns the source-to-INTC mapping. Current profiles use
`CMT0,CMT1,SCIF_ERI,SCIF_RXI,SCIF_TXI,SCIF_BRI,PIO`; BRI replaces the former SCI TEI
source at index 5. There is no fixed priority imposed by this output ordering.

## Firmware and validation

`sw/include/scif.h` defines the SCIF offsets and explicit byte/halfword accessors.
The shared UART initializer resets both FIFOs, selects RX threshold 1 and TX
threshold 0, and polls TDFE for transmission. It works without knowing FIFO
depth. Polling reception uses SCFDR and discards error-marked bytes.

BootROM polls the hardware RX FIFO with CPU interrupts masked; it does not
configure INTC or link the optional receive ISR and 512-byte software ring.
`uart_try_rx` returns data, empty, or error without blocking. Parity/framing,
break and overrun remain latched until the loader resets the receive FIFO and
acknowledges them before retry. CMT supplies the foreground receive timeout.
The handoff discards residual RX data and leaves SR.I=15 for application startup.

The upload protocol sends at most one 256-byte page at a time. The host waits
for `Received <offset>` before sending the next page, so foreground flash erase,
program and verification run while the host is paused. FIFO buffering does not
permit an unpaced stream during flash operations. Firmware receives the first
page and validates its header before erasing; it commits the header last.
Application interrupt handling and the optional ISR regression fixtures remain
available. Their vector definitions use the board interrupt map.

`J2SCIFSpec` covers depths 0, 1, 3, 4, 16 and 255, register widths/strobes, automatic
TX, full/drop/reset/wrap behavior, framing and baud divisors, trigger levels,
short-packet timeout, per-byte error counts, overrun, break/recovery and
receive/pop collisions. The format matrix tests all 12 combinations of 7/8 data bits,
none/even/odd parity and 1/2 stop bits at depths 0, 4 and 16. They check
seven-bit masking with bit 7 set, both parity values, bad-parity reporting and
recovery, exact spacing of consecutive TX frames, contiguous RX frames and
first-stop-only framing checks. `BoardSocSpec` boots both real SoCs with their default depth four and
with depth 16 plus relocated registers and reordered IRQs. `J2BootUartIrqSpec`
tests the optional ISR at depths 0/16 and the production polling driver at
depth 4, including hardware overrun, parity errors, retry and a continuous
256-byte transfer with CPU/peripheral interrupts disabled. The C++ reference console model uses the
same SCIF register map with immediate transmission and no external RX source.

Initial SCIF migration evidence (before the depth-four polling BootROM change):

- `build/scif-full-tests.log`: full 141-test Scala regression passed.
- `build/scif-final-validation.log`: then-production ISR stress at depths 0 and 16,
  board RTL generation, and Wukong cold boot through the complete XIP/ISA app.
- `build/scif-final-board-checks.log`: final board integration at depths 0/16,
  default/reordered IRQ maps, and Tang FPGA RTL generation.
- `build/scif-tang-boot.log`: Tang reset boot, cold boot and complete UART upload
  all pass the XIP application, including CMT, INTC and ISA checks.
- `build/scif-host.log` and `build/scif-model.log`: 40 host tests and reference
  peripheral-model checks passed.
- `build/scif-coremark-builds.log`: performance and validation firmware build
  for both boards. No new CoreMark score was measured.

## Physical board validation

`tools/scif_validation.py` programs a timing-checked bitstream through volatile
JTAG and tests the real UART. Without `--image`, it builds and uploads
`sw/bootrom/test/scif.c`. This host-assisted application checks FIFO counts,
ordered transmission, rejected writes while full, receive overrun without
corrupting older bytes, W0C acknowledgement, short-packet reception, per-byte
parity metadata and all four SCIF requests at the private INTC. Capacity one
uses RDF; larger capacities additionally check the below-threshold DR timeout.
The fixture masks CPU interrupts while inspecting requests; the normal XIP
application exercises interrupt handlers, while BootROM upload uses polling.

For example, after building Tang with its default depth-four profile:

```sh
python3 tools/scif_validation.py --board tang-primer --fifo-depth 4 \
  --bitstream build/fpga/tang-primer/j2_tang_primer.bit \
  --output build/scif-hardware/tang-primer/depth4/fifo --backup
```

For Wukong, select `--board wukong-v1` and
`build/wukong-v1/vivado/j2_wukong_v1.bit`. A nonzero test depth must match the
bitstream's `scifFifoDepth`; the application checks the actual storage capacity.
Omitting `--fifo-depth` uses the board property. The usual `TD_HOME` or `VIVADO_HOME` build environment also selects the
programmer. Wukong uses the Xilinx hardware manager.

These tests replace the application flash sectors they use. `--backup` saves
those sectors to `flash-before.bin` before erasing them. To upload and validate
the normal XIP/ISA application, add `--image <packed-flash.bin> --upload`.
With `--image` and no `--upload`, the script validates an independent boot of
the installed application after FPGA reconfiguration. Each successful run
saves `results.json` with image/bitstream hashes, `uart.log`, and programmer
logs. Configuration flash is never written.

On 2026-11-20, Tang Primer (`/dev/ttyACM0`, 32 MHz) and Wukong v1
(`/dev/ttyUSB0`, 72 MHz) both pass the standalone SCIF test at depths **0 and
16**. At each depth both boards also pass the production BootROM UART upload
and complete normal XIP application: startup, APB4 subword accesses, cache,
external SDRAM/DDR, CMT, INTC, and every ISA regression marker. The original
64-KiB application sector from each board is preserved in
`build/scif-hardware/<board>/depth0/isa/flash-before.bin`.

Per-run UART/programmer logs and hashes are under
`build/scif-hardware/<board>/depth{0,16}/{fifo,isa}/`. The hardware test uses
19200-baud 8N1, with intentional parity mismatch during the error check; it
does not repeat the simulator's full framing/baud/break matrix or measure
CoreMark performance.

Finally, both boards were reconfigured with their then-default depth-zero bitstream
and independently booted the normal SCIF-compatible XIP/ISA application already
in flash, without another upload. Both pass every application marker. Evidence
is in `build/scif-hardware/<board>/depth0/final-boot/`; the aggregate record is
`build/scif-hardware/results.json`. That validation left this configuration running on
both boards. Configuration flash contents remain unchanged.

Post-route results on 2026-11-20 (all setup/hold checks pass):

| Board | Clock | FIFO depth | Worst setup slack | Worst hold slack | LUTs | Registers |
| --- | --- | --- | --- | --- | --- | --- |
| Tang Primer | 32 MHz | 0 | 3.223 ns | 0.281 ns | 12,290 | 4,826 |
| Tang Primer | 32 MHz | 16 | 4.249 ns | 0.083 ns | 12,652 | 4,861 |
| Wukong v1 | 72 MHz | 0 | 0.272 ns | 0.062 ns | 9,208 | 8,091 |
| Wukong v1 | 72 MHz | 16 | 0.543 ns | 0.053 ns | 9,322 | 8,130 |

These are separate routed implementations, so the slack difference includes
placement/routing variation. FIFO depth 16 adds 362 LUTs / 35 registers on Tang
and 114 LUTs / 39 registers on Wukong. BRAM and DSP usage are unchanged.

The depth-zero bitstreams and reports were archived under
`build/scif-hardware/<board>/depth0/archive/` before updating the board defaults. Isolated depth-16 builds are under
`build/scif-hardware/<board>/depth16/`, with separate generated RTL and copied
properties. At that validation point the board profiles selected depth zero. Tang's first
isolated build stopped at timing-report export because its report directory
matched its work directory; the successful retry uses separate directories,
as the standard Tang flow does. No RTL change was needed for hardware validation.

## Current default: four-byte FIFO and polling BootROM

Both board profiles now select `scifFifoDepth=4`. They also define
`spiControlBase=0xff002000` and `xipCacheControlBase=0xff004000`; those values
configure the board APB mappings and the generated BootROM definitions.
The XIP application's word/byte cache-invalidation test uses the same property.
Relocation tests move both controls to `0xff008000`/`0xff009000`, execute the
production cache-invalidation function, and verify SPI control access on both
SoCs, alongside relocated SCIF/CMT and reordered interrupts.

BootROM now uses polling only. Its link map contains no receive ISR or software
ring. Optional ISR fixtures remain for interrupt regression coverage; production
ROM vectors halt safely and startup explicitly sets SR.I=15. The normal
application retains its INTC/SCIF interrupt tests.

Validation on 2026-11-20:

- `build/scif-depth4-board-tests.log`: both SoCs, default and relocated maps,
  three reset seeds each. Profile/SCIF tests and 40 host checks also pass.
- `build/scif-poll-driver-tests.log`: polling at depth 4 with interrupts
  disabled, overrun/parity recovery and a continuous 256-byte page; optional
  ISR regressions at depths 0/16 also pass.
- `build/scif-poll-loader-sim.log`: Wukong backup/upload, invalid range/header,
  receive timeout, framing error, flash program failure, successful retry and
  bad-checksum rejection pass with the production polling ROM.
- `build/scif-poll-tang-sim.log`: Tang reset and cold boots pass. The upload
  reached the last ISA marker at the old 200-million-cycle limit;
  `build/scif-poll-tang-upload-retry.log` passes the complete upload and ISA
  application with the loader budget increased to 300 million cycles in both
  the native Makefile and ISA validation runner.
- `build/scif-poll-hardware/results.json`: both physical boards pass the FIFO
  test, production UART upload/full ISA application and independent final boot.
  Per-run logs, hashes and application-sector backups are in the adjacent
  board directories. Configuration flash was not written.

Both polling-ROM FPGA builds pass post-route timing:

| Board | Clock | Setup slack | Hold slack |
| --- | --- | --- | --- |
| Tang Primer | 32 MHz | 3.897 ns | 0.146 ns |
| Wukong v1 | 72 MHz | 0.140 ns | 0.038 ns |

Both boards are left running this four-byte FIFO, polling-ROM configuration
with the normal SCIF-compatible XIP/ISA application installed. This supersedes
the earlier depth-zero hardware state recorded above.
