package j2.soc

import j2.bus.{J2Wishbone, J2WishboneIntercon, J2ReadCache, J2ReadCacheConfig}
import j2.core.{J2CoreConfig, J2MicrocodedCore}
import j2.periph._
import spinal.core._
import spinal.lib._
import spinal.lib.bus.misc.SizeMapping
import spinal.lib.com.uart.{UartCtrlMemoryMappedConfig, WishboneUartCtrl}
import spinal.lib.io.TriStateArray
import spinal.lib.memory.sdram.sdr.{EG4S20, SdramInterface}

final class J2Soc(
    useBramRom: Boolean = false,
    clockHz: Int = 32000000,
    timerTickHz: Int = 1000000
) extends Component {
  val io = new Bundle {
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
    baseAddress = 0x10000000L,
    rangeBytes  = 0x00100000L
  )
  private val romMapping          = SizeMapping(0x00000000L, 0x00008000L)
  private val sramMapping         = SizeMapping(0x00008000L, 0x00008000L)
  private val flashMapping        = SizeMapping(xipConfig.baseAddress, xipConfig.rangeBytes)
  private val sdramMapping        = SizeMapping(0x80000000L, 0x00800000L)
  private val pioMapping          = SizeMapping(0xff000000L, 0x1000)
  private val uartMapping         = SizeMapping(0xff001000L, 0x1000)
  private val flashControlMapping = SizeMapping(0xff002000L, 0x1000)
  private val timerMapping        = SizeMapping(0xff003000L, 0x1000)
  private val cacheControlMapping = SizeMapping(0xff004000L, 0x1000)

  private val xipCache = new J2ReadCache(xipConfig)
  private val cpu      = new J2MicrocodedCore(J2CoreConfig(useBramRom, exposeDebug = false))
  private val rom      = new J2Rom(useBramRom)
  private val sram     = new J2Sram
  private val flash    = new J2SpiFlash(xipConfig.lineBytes)
  private val sdram    = new J2Sdram
  private val pio      = new J2Pio
  private val timer    = new J2Timer(clockHz, timerTickHz)
  private val uart = new WishboneUartCtrl(
    UartCtrlMemoryMappedConfig(19200, txFifoDepth = 32, rxFifoDepth = 32)
  )
  val sdramInterface = master(SdramInterface(EG4S20.layout))
  sdramInterface <> sdram.io.sdram

  // Cache tags/refill commands use absolute addresses. Only the backend adapter
  // translates the mapped window to flash offsets, so relocation is explicit.
  flash.io.xip.cmd.valid       := xipCache.io.refill.cmd.valid
  flash.io.xip.cmd.address     := xipCache.io.refill.cmd.address - U(xipConfig.baseAddress, 32 bits)
  flash.io.xip.cmd.length      := xipCache.io.refill.cmd.length
  xipCache.io.refill.cmd.ready := flash.io.xip.cmd.ready
  xipCache.io.refill.rsp <> flash.io.xip.rsp
  xipCache.io.hold       := flash.io.readHold
  xipCache.io.invalidate := flash.io.invalidate
  flash.io.readBusy      := xipCache.io.busy

  private val instructionMappings = Seq(romMapping, sramMapping, flashMapping, sdramMapping)
  private val dataMappings = instructionMappings ++ Seq(
    pioMapping,
    uartMapping,
    flashControlMapping,
    timerMapping,
    cacheControlMapping
  )
  private val instructionUnmapped = !instructionMappings.map(_.hit(cpu.io.ibus.ADR)).reduce(_ || _)
  private val dataUnmapped        = !dataMappings.map(_.hit(cpu.io.dbus.ADR)).reduce(_ || _)
  private val instructionError    = RegInit(False)
  private val dataError           = RegInit(False)
  when(instructionUnmapped && cpu.io.ibus.CYC) {
    instructionError := True
  }.elsewhen(!cpu.io.ibus.CYC) {
    instructionError := False
  }
  when(dataUnmapped && cpu.io.dbus.CYC) {
    dataError := True
  }.elsewhen(!cpu.io.dbus.CYC) {
    dataError := False
  }

  private val instructionBus = J2Wishbone()
  instructionBus.CYC      := cpu.io.ibus.CYC && !instructionUnmapped
  instructionBus.STB      := cpu.io.ibus.STB
  instructionBus.WE       := cpu.io.ibus.WE
  instructionBus.ADR      := cpu.io.ibus.ADR
  instructionBus.DAT_MOSI := cpu.io.ibus.DAT_MOSI
  instructionBus.SEL      := cpu.io.ibus.SEL
  instructionBus.LOCK     := cpu.io.ibus.LOCK

  private val dataBus = J2Wishbone()
  dataBus.CYC      := cpu.io.dbus.CYC && !dataUnmapped
  dataBus.STB      := cpu.io.dbus.STB
  dataBus.WE       := cpu.io.dbus.WE
  dataBus.ADR      := cpu.io.dbus.ADR
  dataBus.DAT_MOSI := cpu.io.dbus.DAT_MOSI
  dataBus.SEL      := cpu.io.dbus.SEL
  dataBus.LOCK     := cpu.io.dbus.LOCK

  private val uartBus = J2Wishbone()
  J2Wishbone.connectToWordAddressed(uartBus, uart.io.bus)

  private val matrix = J2WishboneIntercon()
  matrix.addSlaves(
    rom.io.bus -> romMapping,
    sram.io.bus -> sramMapping,
    xipCache.io.bus -> flashMapping,
    sdram.io.bus -> sdramMapping,
    pio.io.bus -> pioMapping,
    uartBus -> uartMapping,
    flash.io.control -> flashControlMapping,
    timer.io.bus -> timerMapping,
    xipCache.io.control -> cacheControlMapping
  )
  matrix.addMaster(
    dataBus,
    Seq(
      rom.io.bus,
      sram.io.bus,
      xipCache.io.bus,
      sdram.io.bus,
      pio.io.bus,
      uartBus,
      flash.io.control,
      timer.io.bus,
      xipCache.io.control
    )
  )
  matrix.addInstructionMaster(
    instructionBus,
    dataBus,
    Seq(rom.io.bus, sram.io.bus, xipCache.io.bus, sdram.io.bus)
  )

  cpu.io.ibus.ACK      := Mux(instructionUnmapped, False, instructionBus.ACK)
  cpu.io.ibus.DAT_MISO := instructionBus.DAT_MISO
  cpu.io.ibus.ERR      := Mux(instructionUnmapped, instructionError, instructionBus.ERR)
  cpu.io.dbus.ACK      := Mux(dataUnmapped, False, dataBus.ACK)
  cpu.io.dbus.ERR      := Mux(dataUnmapped, dataError, dataBus.ERR)
  cpu.io.dbus.DAT_MISO := dataBus.DAT_MISO

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
