package j2.soc

import j2.bus.{J2Wishbone, J2WishboneArbiter, J2ReadCache, J2ReadCacheConfig}
import j2.core.{J2CoreConfig, J2MicrocodedCore}
import j2.periph._
import spinal.core._
import spinal.lib._
import spinal.lib.bus.misc.SizeMapping
import spinal.lib.bus.wishbone.{Wishbone, WishboneDecoder}
import spinal.lib.com.uart.{UartCtrlMemoryMappedConfig, WishboneUartCtrl}
import spinal.lib.io.TriStateArray

final class J2Soc(
    useEg4Rom: Boolean = false,
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
  private val cpu      = new J2MicrocodedCore(J2CoreConfig(useEg4Rom, exposeDebug = false))
  private val rom      = new J2Rom(useEg4Rom)
  private val sram     = new J2Sram
  private val flash    = new J2SpiFlash(xipConfig.lineBytes)
  private val sdram    = new J2Sdram
  private val pio      = new J2Pio
  private val timer    = new J2Timer(clockHz, timerTickHz)
  private val uart = new WishboneUartCtrl(
    UartCtrlMemoryMappedConfig(19200, txFifoDepth = 32, rxFifoDepth = 32)
  )
  val sdramInterface = sdram.io.sdram

  private def select(master: Wishbone, mapping: SizeMapping): Wishbone = {
    val selected = J2Wishbone()
    selected.CYC      := master.CYC && mapping.hit(master.ADR)
    selected.STB      := master.STB
    selected.WE       := master.WE
    selected.ADR      := master.ADR
    selected.DAT_MOSI := master.DAT_MOSI
    selected.SEL      := master.SEL
    // Only the selected memory participates in an atomic cycle. Forwarding a
    // global LOCK to inactive memory arbiters can reserve the instruction ROM
    // while an atomic SRAM operation waits for its next microstep.
    selected.LOCK := master.LOCK && mapping.hit(master.ADR)
    selected
  }

  private val dRom   = select(cpu.io.dbus, romMapping)
  private val dSram  = select(cpu.io.dbus, sramMapping)
  private val dFlash = select(cpu.io.dbus, flashMapping)
  private val dSdram = select(cpu.io.dbus, sdramMapping)
  private val memoryAccess = romMapping.hit(cpu.io.dbus.ADR) || sramMapping.hit(cpu.io.dbus.ADR) ||
    flashMapping.hit(cpu.io.dbus.ADR) || sdramMapping.hit(cpu.io.dbus.ADR)

  private val romArbiter   = new J2WishboneArbiter(2, instructionInput = Some(1))
  private val sramArbiter  = new J2WishboneArbiter(2, instructionInput = Some(1))
  private val flashArbiter = new J2WishboneArbiter(2, instructionInput = Some(1))
  private val sdramArbiter = new J2WishboneArbiter(2, instructionInput = Some(1))
  romArbiter.io.inputs(0) <> dRom
  sramArbiter.io.inputs(0) <> dSram
  flashArbiter.io.inputs(0) <> dFlash
  sdramArbiter.io.inputs(0) <> dSdram
  romArbiter.io.output <> rom.io.bus
  sramArbiter.io.output <> sram.io.bus
  flashArbiter.io.output <> xipCache.io.bus
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
  sdramArbiter.io.output <> sdram.io.bus

  private val instructionUnmapped =
    !romMapping.hit(cpu.io.ibus.ADR) && !sramMapping.hit(cpu.io.ibus.ADR) &&
      !flashMapping.hit(cpu.io.ibus.ADR) && !sdramMapping.hit(cpu.io.ibus.ADR)
  private val instructionError = RegInit(False)
  when(instructionUnmapped && cpu.io.ibus.CYC) {
    instructionError := True
  }.elsewhen(!cpu.io.ibus.CYC) {
    instructionError := False
  }
  private val instructionBus = J2Wishbone()
  instructionBus.CYC      := cpu.io.ibus.CYC && !instructionUnmapped
  instructionBus.STB      := cpu.io.ibus.STB
  instructionBus.WE       := cpu.io.ibus.WE
  instructionBus.ADR      := cpu.io.ibus.ADR
  instructionBus.DAT_MOSI := cpu.io.ibus.DAT_MOSI
  instructionBus.SEL      := cpu.io.ibus.SEL
  instructionBus.LOCK     := cpu.io.ibus.LOCK
  private val iMux = WishboneDecoder(
    instructionBus,
    Seq(
      romArbiter.io.inputs(1) -> romMapping,
      sramArbiter.io.inputs(1) -> sramMapping,
      flashArbiter.io.inputs(1) -> flashMapping,
      sdramArbiter.io.inputs(1) -> sdramMapping
    ),
    byteAddressedDecodings = false
  )
  cpu.io.ibus.ACK := Mux(instructionUnmapped, False, instructionBus.ACK)
  cpu.io.ibus.DAT_MISO := Mux(
    cpu.io.ibus.ADR(1),
    Cat(U(0, 16 bits), instructionBus.DAT_MISO(15 downto 0)),
    Cat(U(0, 16 bits), instructionBus.DAT_MISO(31 downto 16))
  )
  cpu.io.ibus.ERR := Mux(instructionUnmapped, instructionError, instructionBus.ERR)

  private val peripheralAccess =
    pioMapping.hit(cpu.io.dbus.ADR) || uartMapping.hit(cpu.io.dbus.ADR) ||
      flashControlMapping.hit(cpu.io.dbus.ADR) || timerMapping.hit(cpu.io.dbus.ADR) ||
      cacheControlMapping.hit(cpu.io.dbus.ADR)
  private val peripheralUnmapped = !memoryAccess && !peripheralAccess
  private val sdramPhy           = new Eg4SdramPhy
  sdramPhy.clk   := ClockDomain.current.readClockWire
  sdramPhy.ras_n := sdramInterface.RASn
  sdramPhy.cas_n := sdramInterface.CASn
  sdramPhy.we_n  := sdramInterface.WEn
  sdramPhy.addr  := sdramInterface.ADDR
  sdramPhy.ba    := sdramInterface.BA
  sdramPhy.cs_n  := sdramInterface.CSn
  sdramPhy.dm0   := sdramInterface.DQM(0)
  sdramPhy.dm1   := sdramInterface.DQM(1)
  sdramPhy.dm2   := sdramInterface.DQM(2)
  sdramPhy.dm3   := sdramInterface.DQM(3)
  sdramPhy.cke   := sdramInterface.CKE
  private val sdramDq = Analog(Bits(32 bits))
  sdramPhy.dq <> sdramDq
  when(sdramInterface.DQ.writeEnable(0)) {
    sdramDq := sdramInterface.DQ.write
  }
  sdramInterface.DQ.read := sdramDq

  private val peripheralError = RegInit(False)
  when(peripheralUnmapped && cpu.io.dbus.CYC) {
    peripheralError := True
  }.elsewhen(!cpu.io.dbus.CYC) {
    peripheralError := False
  }
  private val peripheralBus = J2Wishbone()
  peripheralBus.CYC      := cpu.io.dbus.CYC && !peripheralUnmapped && !memoryAccess
  peripheralBus.STB      := cpu.io.dbus.STB
  peripheralBus.WE       := cpu.io.dbus.WE
  peripheralBus.ADR      := cpu.io.dbus.ADR
  peripheralBus.DAT_MOSI := cpu.io.dbus.DAT_MOSI
  peripheralBus.SEL      := cpu.io.dbus.SEL
  peripheralBus.LOCK     := cpu.io.dbus.LOCK
  private val uartBus = J2Wishbone()
  J2Wishbone.connectToWordAddressed(uartBus, uart.io.bus)
  private val dMux = WishboneDecoder(
    peripheralBus,
    Seq(
      pio.io.bus -> pioMapping,
      uartBus -> uartMapping,
      flash.io.control -> flashControlMapping,
      timer.io.bus -> timerMapping,
      xipCache.io.control -> cacheControlMapping
    ),
    byteAddressedDecodings = false
  )

  private val memoryAck = MuxOH(
    Vec(
      romMapping.hit(cpu.io.dbus.ADR),
      sramMapping.hit(cpu.io.dbus.ADR),
      flashMapping.hit(cpu.io.dbus.ADR),
      sdramMapping.hit(cpu.io.dbus.ADR)
    ),
    Vec(
      romArbiter.io.inputs(0).ACK,
      sramArbiter.io.inputs(0).ACK,
      flashArbiter.io.inputs(0).ACK,
      sdramArbiter.io.inputs(0).ACK
    )
  )
  private val memoryError = MuxOH(
    Vec(
      romMapping.hit(cpu.io.dbus.ADR),
      sramMapping.hit(cpu.io.dbus.ADR),
      flashMapping.hit(cpu.io.dbus.ADR),
      sdramMapping.hit(cpu.io.dbus.ADR)
    ),
    Vec(
      romArbiter.io.inputs(0).ERR,
      sramArbiter.io.inputs(0).ERR,
      flashArbiter.io.inputs(0).ERR,
      sdramArbiter.io.inputs(0).ERR
    )
  )
  private val memoryData = MuxOH(
    Vec(
      romMapping.hit(cpu.io.dbus.ADR),
      sramMapping.hit(cpu.io.dbus.ADR),
      flashMapping.hit(cpu.io.dbus.ADR),
      sdramMapping.hit(cpu.io.dbus.ADR)
    ),
    Vec(
      romArbiter.io.inputs(0).DAT_MISO,
      sramArbiter.io.inputs(0).DAT_MISO,
      flashArbiter.io.inputs(0).DAT_MISO,
      sdramArbiter.io.inputs(0).DAT_MISO
    )
  )
  cpu.io.dbus.ACK := Mux(peripheralUnmapped, False, Mux(memoryAccess, memoryAck, peripheralBus.ACK))
  cpu.io.dbus.ERR := Mux(
    peripheralUnmapped,
    peripheralError,
    Mux(memoryAccess, memoryError, peripheralBus.ERR)
  )
  cpu.io.dbus.DAT_MISO := Mux(memoryAccess, memoryData, peripheralBus.DAT_MISO)

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
