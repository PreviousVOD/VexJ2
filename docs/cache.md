# Reusable read cache

[SoC reference](soc.md#spi-xip-and-read-cache) · [Native AHB memory paths](ahb-memory.md)

`J2ReadCache` combines an AHB5 endpoint, APB4 control and `J2ReadCacheEngine`.
The engine is a blocking, read-only, two-way cache with a generic word-burst
refill port. `J2CachedSpiFlash` connects it to SPI; the engine itself does not
know the flash protocol or physical offset.

## Geometry

`J2ReadCacheConfig` sets capacity, line size, base address and address range.
Capacity and line size must be powers of two; lines are at least eight bytes
and capacity contains at least two sets. Window boundaries must be line
aligned and fit the 32-bit address space. The default SoCs use 4 KiB with
32-byte lines: 64 sets, two ways and eight words per line.

Tag and data arrays use synchronous reads. Valid bits reset independently of
the RAM contents. Each set has one exact LRU bit; invalid ways are preferred
before evicting the least recently used valid way. Instruction and data reads
share the same cache through the upstream XIP arbiter.

## Transactions and invalidation

The engine retains each accepted command until completion. Writes and reads
outside its configured window return errors. A hit returns the requested word;
a miss issues one aligned full-line burst. It publishes the line only after
all words arrive without error. Short, long or errored refills return errors
and do not publish a partial line. There is no early restart or prefetch.

Invalidation clears all valid bits and wins over concurrent publication.
An in-flight refill drains before retry; invalidation before response delivery
also forces a retry. `hold` stops new admissions without cancelling an already
accepted request. The SPI wrapper uses this to serialize control transactions
with refills and physical CS release. Successful nonempty flash-control writes
invalidate the cache automatically.

The APB control register at local offset zero reads busy in bit 1. Writing
bit 0 with PSTRB[0] set invalidates all lines; other offsets report PSLVERR.
Its SoC address is `xipCacheControlBase` in the board profile (currently
`0xff004000`). On SH-2 BE32, the low byte is at base+3. Invalidation is not a
writeback operation: this cache never holds dirty data.

## Validation

`J2AhbReadCacheSpec` covers AHB ownership, legal access lanes, refill failures,
waits, invalidation and command retention. `J2ReadCacheSpec` retains reference
fixture coverage across multiple capacities and line sizes, including LRU and
refill cancellation at its legacy adapter boundary. SPI and SoC tests cover
control/refill serialization and XIP execution. Benchmark comparisons belong
in [CoreMark](coremark.md); simulator throughput and FPGA clock frequency are
separate measurements.
