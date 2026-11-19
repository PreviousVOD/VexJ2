package j2.soc

import j2.bus.{J2Ahb, J2Apb, J2Biu, J2ReadCache, J2ReadCacheConfig}
import j2.bus.ahb5._
import j2.bus.apb.Apb3Matrix
import j2.core.{J2CoreConfig, J2MicrocodedCore}
import j2.periph._
import spinal.core._
import spinal.lib._
import spinal.lib.bus.misc.SizeMapping
import spinal.lib.io.TriStateArray

final class J2Soc(
    val config: J2SocConfig = J2SocConfig()
) extends Component {
  private val clockHz = config.clockHz
  val io = new Bundle {
    val memory  = master(J2Ahb.subordinate())
    val uartRx  = in Bool ()
    val uartTx  = out Bool ()
    val gpio    = master(TriStateArray(32))
    val spiCs   = out Bool ()
    val spiClk  = out Bool ()
    val spiData = master(TriStateArray(4))
  }
  private val xipConfig = J2ReadCacheConfig(
    cacheBytes  = 4096,
    lineBytes   = 32,
    baseAddress = config.xipBase,
    rangeBytes  = config.xipBytes
  )
  private val romMapping          = SizeMapping(0x00000000L, 0x00008000L)
  private val sramMapping         = SizeMapping(0x00008000L, config.sramBytes)
  private val flashMapping        = SizeMapping(xipConfig.baseAddress, xipConfig.rangeBytes)
  private val memoryMapping       = SizeMapping(config.memoryBase, config.memoryBytes)
  private val pioMapping          = SizeMapping(0xff000000L, 0x1000)
  private val uartMapping         = SizeMapping(0xff001000L, 0x1000)
  private val flashControlMapping = SizeMapping(0xff002000L, 0x1000)
  private val timerMapping        = SizeMapping(0xff003000L, 0x1000)
  private val cacheControlMapping = SizeMapping(0xff004000L, 0x1000)

  private val xipCache = new J2ReadCache(xipConfig)
  private val cpu      = new J2MicrocodedCore(J2CoreConfig(exposeDebug = false))
  private val rom      = new J2Rom(config.romHex)
  private val sram     = new J2Sram(config.sramBytes)
  private val flash    = new J2SpiFlash(xipConfig.lineBytes)
  private val pio      = new J2Pio
  private val timer    = new J2Timer(clockHz, config.timerTickHz)
  private val uart     = new J2Uart(config.uartBaud)

  // Cache tags/refill commands use absolute addresses. Only the backend adapter
  // translates the mapped window to flash offsets, so relocation is explicit.
  flash.io.xip.cmd.valid := xipCache.io.refill.cmd.valid
  flash.io.xip.cmd.address := xipCache.io.refill.cmd.address - U(
    xipConfig.baseAddress,
    32 bits
  ) + U(config.flashOffset, 32 bits)
  flash.io.xip.cmd.length      := xipCache.io.refill.cmd.length
  xipCache.io.refill.cmd.ready := flash.io.xip.cmd.ready
  xipCache.io.refill.rsp <> flash.io.xip.rsp
  xipCache.io.hold       := flash.io.readHold
  xipCache.io.invalidate := flash.io.invalidate
  flash.io.readBusy      := xipCache.io.busy

  // Routing and AMBA arbitration are separate from the system peripheral BIU.
  private val peripheralMapping = SizeMapping(0xff000000L, 0x8000)
  private val matrix = new Ahb5RoutingMatrix(
    J2Ahb.config,
    managerCount = 2,
    mappings     = Seq(romMapping, sramMapping, flashMapping, memoryMapping, peripheralMapping),
    connections  = Seq(Set(0, 1, 2, 3), Set(0, 1, 2, 3, 4))
  )
  matrix.io.managers(0) <> cpu.io.ibus
  matrix.io.managers(1) <> cpu.io.dbus
  private val memoryPorts = Seq(rom.io.bus, sram.io.bus, xipCache.io.bus, io.memory)
  for (index <- memoryPorts.indices) {
    val arbiter = new Ahb5SubordinateArbiter(J2Ahb.config, 2)
    arbiter.setName(s"memoryArbiter_$index")
    arbiter.io.managers <> matrix.io.destinations(index)
    arbiter.io.subordinate <> memoryPorts(index)
  }
  // The standalone system BIU owns the complete peripheral bridge domain.
  private val peripheralBiu = new J2Biu(J2Ahb.config, 2)
  peripheralBiu.io.managers <> matrix.io.destinations(4)
  private val peripheralBridge = new Ahb5ToApb3Bridge(J2Ahb.config)
  peripheralBridge.io.ahb <> peripheralBiu.io.subordinate
  private val peripheralBus = new Apb3Matrix(
    peripheralBridge.apbConfig,
    Seq(pioMapping, uartMapping, flashControlMapping, timerMapping, cacheControlMapping)
  )
  peripheralBus.io.input <> peripheralBridge.io.apb
  J2Apb.connect(peripheralBus.io.outputs(0), pio.io.bus)
  J2Apb.connect(peripheralBus.io.outputs(1), uart.io.bus)
  J2Apb.connect(peripheralBus.io.outputs(2), flash.io.control)
  J2Apb.connect(peripheralBus.io.outputs(3), timer.io.bus)
  J2Apb.connect(peripheralBus.io.outputs(4), xipCache.io.control)

  cpu.io.event.valid              := timer.io.interrupt
  cpu.io.event.payload.command    := 0
  cpu.io.event.payload.vector     := 0x40
  cpu.io.event.payload.level      := 14
  cpu.io.event.payload.bypassMask := False

  uart.io.uart.rxd := io.uartRx
  io.uartTx        := uart.io.uart.txd
  io.gpio <> pio.io.gpio
  io.spiCs  := flash.io.spi.cs
  io.spiClk := flash.io.spi.clk
  io.spiData <> flash.io.spi.data
}
