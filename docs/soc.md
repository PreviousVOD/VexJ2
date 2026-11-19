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
domain `0xff000000`–`0xff007fff`. It precedes `Ahb5ToApb4Bridge` and `Apb4Matrix`,
which selects GPIO, UART, SPI control, timer or cache control. The BIU composes
standard AHB arbitration and persistent lock ownership at that system boundary;
programmable access-control policy is not implemented yet. Destination ownership
uses the physical ingress port. HMASTER reaches the bridge unchanged; APB4 has
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

CPU and memory ports use native AHB5. ROM, SRAM and the XIP cache accept AHB
through `J2AhbMemoryEndpoint`; Tang SDRAM feeds the SDRAM controller's BMB port
directly, and Wukong DDR feeds the MIG request/response mailboxes directly.
GPIO, UART, timer, SPI control and cache control expose native APB4 interfaces.
There is no Wishbone interface or conversion anywhere in the production SoC.
See [native AHB memory paths](ahb-memory.md) for phase timing and backend contracts.

Peripheral registers support naturally aligned byte, halfword and word AHB
accesses. The bridge aligns the APB address and generates `PSTRB` for writes;
the CPU selects read lanes from the returned word. The SoC uses word-invariant
big-endian lanes: a register's low byte is at base + 3, its low halfword at
base + 2. Read side effects apply to the whole APB word. UART/SPI command
registers require their complete payload lanes; see the [APB4 contract](apb.md).
The software addresses and flash image format are unchanged.

## Memory map

These are the board profiles' current mappings. `J2SocConfig` configures the XIP
base, range and physical flash offset, external-memory range, clock and UART.
The two external-memory entries below are alternatives selected by the board.

| Region | Address range |
|---|---:|
| Internal ROM | `0x00000000`–`0x00007fff` |
| Internal SRAM | `0x00008000`–`0x00008000 + sramBytes - 1` (default end `0x0000ffff`) |
| SPI flash XIP, 1 MiB | `0x10000000`–`0x100fffff` |
| Tang Primer SiP SDRAM, 8 MiB | `0x80000000`–`0x807fffff` |
| Wukong DDR3, 256 MiB | `0x80000000`–`0x8fffffff` |
| GPIO | `0xff000000` |
| UART | `0xff001000` |
| SPI flash control | `0xff002000` |
| Architecture timer | `0xff003000` |
| XIP cache control | `0xff004000` |

ROM and SRAM describe native Spinal `Mem` with synchronous one-cycle reads.
Board generation selects [memory backends](memory-inference.md) independently
of the core and SoC; the address map and storage sizes are unchanged.

## SPI XIP and read cache

`J2SpiFlash` wraps native `Apb4SpiXdrMasterCtrl`. Responses are assembled in
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
| `0x10` | Load address | Must equal the XIP payload address (`0x10000020`) |
| `0x14`–`0x1f` | Reserved | Three zero words |

The BootROM accepts only images linked at the XIP payload address and jumps
into flash after validating the header and checksum. RAM destinations are
rejected. An application can provide its own XIP relocation stub if its code
needs to execute in RAM; the ROM has no external-memory setup or dependency.

Both boards use the same ROM and UART protocol. Uploads use a 256-byte buffer
in internal SRAM: validate the header, erase affected sectors, program and
verify payload chunks, check the checksum, and commit the header last. The
`Received <offset>` response acknowledges each programmed chunk. See the
[loader guide](wukong-v1.md#sf3-application-loading-and-boot).

ROM and application startup copy `.data` from their image to internal SRAM and
clear `.bss` before entering C. CoreMark already follows this convention.
`make wukong-apps` builds the XIP ISA application with the board profile's clock
and SRAM settings. External-memory tests remain in the application.

## 32-bit GPIO

`J2Pio` uses native APB4 registers with 32 bidirectional pins:

| Offset | Function |
|---:|---|
| `0x00` | Input values |
| `0x04` | Output values |
| `0x08` | Output enable, one bit per pin; reset to zero/input |

Pad primitives and pin assignments are board-specific; see
[Tang Primer GPIO](tang-primer.md#gpio-pads) and
[Wukong board wiring](wukong-v1.md#board-profile).

## Architecture timer

`J2Timer` connects the native SpinalHDL `Timer` through `Apb4SlaveFactory`.
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
