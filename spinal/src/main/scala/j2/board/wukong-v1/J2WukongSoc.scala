package j2.board.wukong_v1

import j2.bus.{J2Ahb, J2Apb, J2Biu, J2ReadCacheConfig}
import j2.bus.ahb5._
import j2.bus.apb.Apb4Matrix
import j2.core.{J2CoreConfig, J2MicrocodedCore}
import j2.periph._
import j2.soc.J2SocConfig
import spinal.core._
import spinal.lib._
import spinal.lib.bus.misc.SizeMapping
import spinal.lib.io.TriStateArray

/** Complete wukong-v1 SoC. Memory and peripheral composition are owned by this board. */
final class J2WukongSoc(config: J2SocConfig) extends Component {
  val io = new Bundle {
    val memory        = master(J2Ahb.subordinate())
    val uartRx        = in Bool ()
    val uartTx        = out Bool ()
    val gpio          = master(TriStateArray(24))
    val spiCs, spiClk = out Bool ()
    val spiData       = master(TriStateArray(4))
  }
  private val romMapping    = SizeMapping(0x00000000L, 0x00008000L)
  private val sramMapping   = SizeMapping(0x00008000L, config.sramBytes)
  private val flashMapping  = SizeMapping(config.xipBase, config.xipBytes)
  private val memoryMapping = SizeMapping(config.memoryBase, config.memoryBytes)
  private val apbMappings = Seq(
    SizeMapping(0xff000000L, 0x1000), // GPIO
    SizeMapping(config.sciBase, 0x1000),
    SizeMapping(0xff002000L, 0x1000), // Application flash control
    SizeMapping(config.cmtBase, 0x1000),
    SizeMapping(0xff004000L, 0x1000) // XIP cache control
  )
  require(!SizeMapping.verifyOverlapping(apbMappings), "board peripheral windows overlap")
  // One BIU owns this board's peripheral domain; unmapped APB addresses fault.
  private val peripheralStart   = apbMappings.map(_.base).min
  private val peripheralEnd     = apbMappings.map(m => m.base + m.size).max
  private val peripheralMapping = SizeMapping(peripheralStart, peripheralEnd - peripheralStart)

  private val cpu = new J2MicrocodedCore(
    J2CoreConfig(exposeDebug = false, interruptCount = config.interruptSources.size)
  )
  private val rom  = new J2Rom(config.romHex)
  private val sram = new J2Sram(config.sramBytes)
  private val uart = new J2SCI
  private val cmt  = new J2CMT
  private val pio  = new J2Pio
  private val flash = new J2CachedSpiFlash(
    J2ReadCacheConfig(
      cacheBytes  = 4096,
      lineBytes   = 32,
      baseAddress = config.xipBase,
      rangeBytes  = config.xipBytes
    ),
    config.flashOffset
  )
  private val matrix = new Ahb5RoutingMatrix(
    J2Ahb.config,
    managerCount = 2,
    mappings     = Seq(romMapping, sramMapping, flashMapping, memoryMapping, peripheralMapping),
    connections  = Seq(Set(0, 1, 2, 3), Set(0, 1, 2, 3, 4))
  )
  matrix.io.managers(0) <> cpu.io.ibus
  matrix.io.managers(1) <> cpu.io.dbus
  private val memoryPorts = Seq(rom.io.bus, sram.io.bus, flash.io.bus, io.memory)
  for (index <- memoryPorts.indices) {
    val arbiter = new Ahb5SubordinateArbiter(J2Ahb.config, 2)
    arbiter.setName(s"memoryArbiter_$index")
    arbiter.io.managers <> matrix.io.destinations(index)
    arbiter.io.subordinate <> memoryPorts(index)
  }
  private val peripheralBiu = new J2Biu(J2Ahb.config, 2)
  peripheralBiu.io.managers <> matrix.io.destinations(4)
  private val peripheralBridge = new Ahb5ToApb4Bridge(J2Ahb.config, wordInvariantBigEndian = true)
  peripheralBridge.io.ahb <> peripheralBiu.io.subordinate
  private val peripheralBus = new Apb4Matrix(peripheralBridge.apbConfig, apbMappings)
  peripheralBus.io.input <> peripheralBridge.io.apb
  J2Apb.connect(peripheralBus.io.outputs(0), pio.io.bus)
  J2Apb.connect(peripheralBus.io.outputs(1), uart.io.bus)
  J2Apb.connect(peripheralBus.io.outputs(2), flash.io.control)
  J2Apb.connect(peripheralBus.io.outputs(3), cmt.io.bus)
  J2Apb.connect(peripheralBus.io.outputs(4), flash.io.cacheControl)

  // This board owns the physical requests; properties define their firmware-visible order.
  private val interruptSignals = Map(
    "CMT0" -> cmt.io.interrupt(0),
    "CMT1" -> cmt.io.interrupt(1),
    "SCI_ERI" -> uart.io.interrupt(0),
    "SCI_RXI" -> uart.io.interrupt(1),
    "SCI_TXI" -> uart.io.interrupt(2),
    "SCI_TEI" -> uart.io.interrupt(3)
  )
  require(
    config.interruptSources.toSet == interruptSignals.keySet,
    "board interruptSources must name every connected request exactly once"
  )
  for ((name, index) <- config.interruptSources.zipWithIndex)
    cpu.io.interrupts(index) := interruptSignals(name)
  cpu.io.nmi       := True
  uart.io.uart.rxd := io.uartRx
  io.uartTx        := uart.io.uart.txd
  // J11 uses GPIO positions 16..23 for SF3. Preserve software numbering of
  // the other pins while exposing only the 24 GPIO pads available on this board.
  pio.io.gpio.read(23 downto 16) := 0
  for (pin <- 0 until 24) {
    val bit = if (pin < 16) pin else pin + 8
    io.gpio.write(pin)       := pio.io.gpio.write(bit)
    io.gpio.writeEnable(pin) := pio.io.gpio.writeEnable(bit)
    pio.io.gpio.read(bit)    := io.gpio.read(pin)
  }
  io.spiCs  := flash.io.spi.cs
  io.spiClk := flash.io.spi.clk
  io.spiData <> flash.io.spi.data
}
