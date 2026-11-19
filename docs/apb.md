# APB peripheral subsystem and standalone BIU

[SoC reference](soc.md) · [AHB5 library](ahb5.md) · [Tang Primer](tang-primer.md)

The CPU and memory subsystem use AHB5. GPIO, UART, timer, SPI control and cache
control use 32-bit APB3. ROM, SRAM, SDRAM and XIP data stay on AHB5 with their
existing data backends. The peripheral address map is unchanged.

```mermaid
flowchart LR
  I[CPU instruction] --> ROUTE[AHB5 routing matrix]
  D[CPU data] --> ROUTE
  ROUTE --> MEMARB[Independent AHB memory arbiters]
  MEMARB --> MEM[ROM / SRAM / SDRAM / XIP data]
  ROUTE --> BIU[Standalone J2Biu]
  BIU --> BRIDGE[AHB5-to-APB3 bridge]
  BRIDGE --> MATRIX[APB matrix]
  MATRIX --> GPIO[GPIO]
  MATRIX --> UART[UART]
  MATRIX --> TIMER[Timer]
  MATRIX --> SPI[SPI control]
  MATRIX --> CACHE[Cache control]
```

## Separation of responsibilities

- `Ahb5RoutingMatrix` only decodes and routes each manager. It exposes decoded
  AHB ports carrying HSEL and upstream HREADY. It has no BIU or system policy.
- `Ahb5SubordinateArbiter` is generic AMBA arbitration for those ports. It retains
  response ownership, burst sequencing and HMASTLOCK semantics. The generic
  `Ahb5Interconnect` remains available when integrated routing/arbitration is wanted.
- `J2Biu`, in `j2.bus/J2Biu.scala`, is a standalone system boundary before the
  peripheral bridge. It currently composes a generic round-robin arbiter with
  persistent atomic ownership. It is **not an AMBA-defined component** and does
  not yet implement programmable access permissions or an SH-2A-compatible CSR set.
- `Ahb5ToApb3Bridge` performs protocol conversion, without arbitration or a lock
  policy. It belongs to the generic bus library and can be reused independently.
- `Apb3Matrix` decodes one APB manager into non-overlapping peripheral ranges.
  One input is sufficient because the upstream BIU serializes all managers.
  There is no second APB arbitration stage.

A locked sequence reserves the complete peripheral domain, including IDLE gaps.
The owner may address different APB peripherals behind that same AHB subordinate
region; competitors cannot enter until release. Independent AHB memory arbiters
continue. HMASTER is preserved up to the bridge; APB3 has neither HMASTER nor
HMASTLOCK. Ownership therefore stays on the AHB side, independent of APB PSEL.
In the current single-core SoC only the data port can reach the peripheral BIU;
its multiple-input interface is exercised by competing-manager simulation.

## Bridge contract

The same clock and reset drive both sides. The bridge accepts an AHB address
only on HSEL, HREADY and NONSEQ/SEQ. It captures the following write-data phase,
then emits a full APB SETUP cycle followed by ACCESS. Address, select, direction
and write data remain stable through PREADY waits. It captures the peripheral
response before completing AHB; writes are never acknowledged early.

PSLVERR is sampled only on a completing APB ACCESS. An APB error produces the
required two-cycle AHB ERROR response. Unmapped APB addresses also return error;
they do not select a peripheral. IDLE/BUSY AHB cycles never create APB accesses.
The final AHB response cycle may also accept the next address. Reset clears
pending state; peripherals and bridge must be reset together.

The APB3 profile has no PSTRB. The reusable bridge supports matching 8-, 16- or
32-bit AHB/APB data widths and addresses up to 32 bits, with naturally aligned,
full-width transfers only. Partial write strobes, other sizes and unaligned
requests return ERROR without peripheral side effects. The SoC selects 32 bits:
software must use aligned 32-bit peripheral register loads/stores. Byte and
halfword **memory** accesses are unaffected. Data is not byte-swapped. APB3 does
not carry AHB protection/security attributes; this bridge is not an access filter.

These rules follow [Arm's APB specification, IHI0024C](https://documentation-service.arm.com/static/60d5b617677cf7536a55c273)
and the [AHB5 specification](ahb5.md). APB3 uses PREADY/PSLVERR; APB4 write strobes
and protection signals are not part of this implementation.

## Peripheral implementation

GPIO, UART and timer use `Apb3SlaveFactory`. UART keeps `UartCtrl.driveFrom32`
and the existing FIFO depths/register map. The timer keeps its registered IRQ,
1 MHz tick and clear/rearm semantics. Cache control is a native APB register:
offset zero reads busy in bit 1; writing bit 0 invalidates the cache. Other cache
control offsets return PSLVERR.

SPI control remains backed by `Apb3SpiXdrMasterCtrl`. A pending control request
holds new XIP admissions, waits for an existing refill and physical CS release,
then supplies the controller its own SETUP/ACCESS sequence. This prevents
starting a downstream transfer halfway through ACCESS when a refill finishes.
A successful control write invalidates the XIP cache. The quad-SPI PHY timing
and data refill interface are unchanged.

## Validation

The Tang Primer build targets 32 MHz and passes timing in both clock domains:
minimum setup/hold slack is **7.045/0.104 ns**. The static timing estimate for
the SoC clock is 41.314 MHz; this is not a hardware frequency sweep. Resources
are **11,196 LUTs**, **4,543 registers**, five DSPs, 51 9K BRAMs and ten 32K
BRAMs. The vendor PLL model and all **70 Scala tests** pass.

Full-SoC reset, cold-boot and UART-loader simulations pass. FPGA application
upload and an independent volatile JTAG reload both pass cache, SDRAM, timer,
atomics, instruction fetch, forwarding, MUL/MAC and exception checks. Results,
UART logs and source/image hashes are in `build/apb-migration/{sim,hardware}/`;
the hardware directory also retains the tested bitstream and timing/area reports.


`J2ApbFabricSpec` exercises the routing matrix, standalone BIU, bridge and APB
matrix together with three contending managers and waited peripheral models.
It checks setup/access stability, following-phase write data, response ownership,
unmapped accesses, peripheral errors, rejection without side effects, back-to-back
AHB addresses, whole-domain locks and independent AHB-domain progress. Native
APB timer tests cover registered IRQ assertion/clear/rearm. SPI tests cover
refill/control serialization and physical flash sampling. The complete SoC
validation application checks the real APB registers in simulation and on FPGA.

```sh
make spinal-test
make -C verilog xip-sim-build
python3 tools/isa_validation.py sim --output build/apb-migration --timeout 300
TD_HOME=/path/to/TD_4.6.7_Linux make verilog-fpga fpga-clock-test
TD_HOME=/path/to/TD_4.6.7_Linux python3 tools/isa_validation.py hardware \
  --output build/apb-migration --timeout 300
```

The hardware command programs volatile FPGA configuration SRAM and uploads the
test application to the dedicated application flash. Wukong also passes at 72 MHz; see [Wukong validation](wukong-v1.md#ahb5apb-validation-at-72-mhz).
