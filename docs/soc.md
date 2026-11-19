# SoC architecture and software interface

[Project overview](../README.md) · [CPU architecture](cpu-architecture.md)

`J2Soc` combines the shared CPU, AHB5 matrix, memories and native
SpinalHDL peripherals. Board wrappers supply clocks, reset, memory primitives
and external-memory controllers. Source paths and commands below are relative
to the repository root.

## Bus matrix

`Ahb5RoutingMatrix` connects native 32-bit, big-endian CPU instruction and data
ports, with HMASTER values 0 and 1. Both use SINGLE transfers and separate
address/data phases. The I-bus reaches ROM, SRAM, XIP and external memory; the
D-bus additionally reaches the peripheral domain. Unmapped or forbidden
accesses return the standard two-cycle AHB ERROR response.

ROM, SRAM, XIP and external memory remain on AHB5, each behind an independent
`Ahb5SubordinateArbiter`. The routing matrix exposes decoded ports; these
arbiters are instantiated explicitly by `J2Soc`.

A standalone **`J2Biu`**, outside the generic AMBA library, covers the peripheral
domain `0xff000000`–`0xff007fff`. It precedes `Ahb5ToApb3Bridge` and `Apb3Matrix`,
which selects GPIO, UART, SPI control, timer or cache control. The BIU composes
standard AHB arbitration and persistent lock ownership at that system boundary;
programmable access-control policy is not implemented yet. Destination ownership
uses the physical ingress port. HMASTER reaches the bridge unchanged; APB3 has
no master-ID or lock signals. See [APB and BIU architecture](apb.md).

TAS holds HMASTLOCK across its read/modify/write sequence, including idle gaps.
The instruction port defers prefetch while the data port holds a reservation.
The sequencer can finish TAS without that prefetch, releases the reservation
on write completion (or error), then waits for fetch before starting the next
instruction. No instruction port borrows another port's reservation.

HPROT marks privileged, non-bufferable accesses, distinguishing instruction
from data. Memory accesses are cacheable; the `0xffxxxxxx` peripheral aperture
is non-cacheable. The matrix transports attributes without applying a security
policy. See the [generic AHB5 library](ahb5.md) for protocol and identity rules.

CPU and memory ports remain AHB5. `J2AhbToWishbone` adapters retain the existing
ROM, SRAM, cache data engine and SDRAM backends. GPIO, UART, timer, SPI control
and cache control now expose native APB3 interfaces. There is no Wishbone
protocol conversion on the production peripheral path.

Peripheral registers require aligned **32-bit** loads/stores. APB3 has no write
strobes; byte/halfword, unaligned or partial-strobe peripheral accesses receive
AHB ERROR without an APB transaction. The bridge preserves data bits without
byte swapping. Memory byte/halfword accesses are unchanged. The software
addresses and flash image format are unchanged.

## Memory map

These are the board profiles' current mappings. `J2SocConfig` configures the XIP
base, range and physical flash offset, external-memory range, clock and UART.
The two external-memory entries below are alternatives selected by the board.

| Region | Address range |
|---|---:|
| Internal ROM | `0x00000000`–`0x00007fff` |
| Internal SRAM | `0x00008000`–`0x0000ffff` |
| SPI flash XIP, 1 MiB | `0x10000000`–`0x100fffff` |
| Tang Primer SiP SDRAM, 8 MiB | `0x80000000`–`0x807fffff` |
| Wukong DDR3, 256 MiB | `0x80000000`–`0x8fffffff` |
| GPIO | `0xff000000` |
| UART | `0xff001000` |
| SPI flash control | `0xff002000` |
| Architecture timer | `0xff003000` |
| XIP cache control | `0xff004000` |

ROM and SRAM use synchronous one-cycle reads. Memory backends provide
board-specific block RAM implementations; simulation uses inferred memories.

## SPI XIP and read cache

`J2SpiFlash` wraps native `Apb3SpiXdrMasterCtrl`. Responses are assembled in
big-endian order and aligned to 32-bit words before the CPU selects a byte
or halfword lane. The physical `toSpi()` adapter registers outputs and inputs
to match the controller's receive pipeline; the raw XDR interface must not
drive pins directly. Flash protocol setup differs between
[Tang Primer's Winbond device](tang-primer.md#application-flash) and
[Wukong's SF3](wukong-v1.md#integration-boundary).

A shared 4 KiB, two-way XIP read cache uses 64 sets, 32-byte lines and exact LRU
replacement. The reusable `J2ReadCache` module sits between the XIP AHB arbiter and
the SPI controller, using a generic word-burst refill interface.
`J2ReadCacheConfig` sets capacity, line size, base address and mapped range; the
SoC derives its XIP mapping from the same configuration. Misses refill a
complete line in one quad-SPI transaction; hits serve both instruction and data
reads from synchronous RAM. Reset and accepted
flash-control writes invalidate all lines. Control accesses wait for an active
refill and CS release. Writing `1` to `0xff004000` explicitly invalidates both
ways; reads return busy in bit 1 and zero in other bits. See the
[cache architecture and validation](cpu-architecture.md#two-way-xip-read-cache-2026-11-17).

## Application image and boot modes

`tools/xip_image.py pack` prefixes each application with a 32-byte big-endian
header. All reserved words must be zero.

| Offset | Field | Meaning |
|---:|---|---|
| `0x00` | Magic | `J2X1` (`0x4a325831`) |
| `0x04` | Entry address | Halfword-aligned address inside the application |
| `0x08` | Application length | Payload bytes, excluding the header |
| `0x0c` | Checksum | Sum of all payload bytes, modulo 32 bits |
| `0x10` | Load address | Destination selected by the pack command |
| `0x14`–`0x1f` | Reserved | Three zero words |

When the load address is the XIP payload address `0x10000020`, the BootROM runs
the application directly from flash. Any other load address must fit with the
complete application inside the board's external-memory region (see the map
above); the BootROM copies the verified payload there and jumps to its entry
address. Wukong additionally validates complete staged uploads before erasing
SF3 and programs the header last; its [loader guide](wukong-v1.md#sf3-application-loading-and-boot)
describes the bounds and UART protocol.

For Tang Primer, build the validation application for SDRAM instead of XIP
with the repository tools on `PATH` (`. tools/env.sh`):

```sh
make -C sw/xipapp OUT="$PWD/build/sw/sdramapp" LOAD_ADDRESS=0x80400000
tools/xip_image.py pack build/sw/sdramapp/main.bin \
  build/sw/sdramapp/flash.bin --load-address 0x80400000
```

Use the resulting `flash.bin` with the normal simulator or UART upload flow.

For Wukong, `make wukong-apps` builds both XIP and DDR images using the
board profile's clock settings. Use the Wukong loader workflow, not the
Tang Primer UART uploader.

## 32-bit GPIO

`J2Pio` uses native APB3 registers with 32 bidirectional pins:

| Offset | Function |
|---:|---|
| `0x00` | Input values |
| `0x04` | Output values |
| `0x08` | Output enable, one bit per pin; reset to zero/input |

Pad primitives and pin assignments are board-specific; see
[Tang Primer GPIO](tang-primer.md#gpio-pads) and
[Wukong board wiring](wukong-v1.md#board-profile).

## Architecture timer

`J2Timer` connects the native SpinalHDL `Timer` through `Apb3SlaveFactory`.
Its 32-bit counter ticks at 1 MHz, derived from the parameterized SoC clock, and
stops at the programmable limit. The interrupt is a level request on vector
`0x40` at priority 14; software must stop, clear, or rearm the timer in the ISR.
The CPU IRQ is registered: assertion and deassertion follow the enabled compare
result by one system clock. Pending status still reports the current comparison.
This keeps the timer comparator behind a register before CPU event selection.

| Offset | Function |
|---:|---|
| `0x00` | Bit 0 enables counter ticks |
| `0x04` | Read/write limit; writing clears the counter |
| `0x08` | Read counter; any write clears it |
| `0x0c` | Bit 0 enables the interrupt; bit 8 is read-only pending status |
