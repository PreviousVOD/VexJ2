package j2.periph

import j2.bus.{J2Wishbone, J2ReadBurst}
import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb.{Apb3, Apb3Config}
import spinal.lib.com.spi.ddr.{Apb3SpiXdrMasterCtrl, SpiXdrMasterCtrl, SpiXdrParameter}
import spinal.lib.io.TriStateArray

final class J2WishboneToApb(config: Apb3Config) extends Component {
  val io = new Bundle {
    val input  = slave(J2Wishbone())
    val output = master(Apb3(config))
  }
  private val enable = RegInit(False)
  io.output.PADDR   := io.input.ADR(config.addressWidth - 1 downto 0)
  io.output.PSEL    := B(io.input.CYC && io.input.STB)
  io.output.PENABLE := enable
  io.output.PWRITE  := io.input.WE
  io.output.PWDATA  := io.input.DAT_MOSI
  when(!enable && io.input.CYC && io.input.STB) {
    enable := True
  }
  when(enable && io.output.PREADY) {
    enable := False
  }
  io.input.ACK      := enable && io.output.PREADY
  io.input.DAT_MISO := io.output.PRDATA
  io.input.ERR      := False
}

final class J2SpiFlash(lineBytes: Int = 32) extends Component {
  require(isPow2(lineBytes) && lineBytes >= 8)
  val io = new Bundle {
    val control              = slave(J2Wishbone())
    val xip                  = slave(J2ReadBurst(log2Up(lineBytes / 4)))
    val readBusy             = in Bool ()
    val readHold, invalidate = out Bool ()
    val spi = new Bundle {
      val cs   = out Bool ()
      val clk  = out Bool ()
      val data = master(TriStateArray(4))
    }
  }
  private val parameters = SpiXdrMasterCtrl.MemoryMappingParameters(
    SpiXdrMasterCtrl
      .Parameters(
        dataWidth  = 8,
        timerWidth = 12,
        spi        = SpiXdrParameter(dataWidth = 4, ioRate = 1, ssWidth = 1)
      )
      .addFullDuplex(id = 0)
      .addHalfDuplex(id = 1, rate = 1, ddr = false, spiWidth = 4),
    cmdFifoDepth   = 32,
    rspFifoDepth   = 32,
    sclkToggleInit = 1,
    xip = SpiXdrMasterCtrl.XipBusParameters(addressWidth = 24, lengthWidth = log2Up(lineBytes)),
    xipEnableInit            = true,
    xipInstructionEnableInit = true,
    xipInstructionDataInit   = 0xeb,
    xipDummyCountInit        = 2,
    xipAddressModInit        = 1,
    xipDummyModInit          = 1,
    xipPayloadModInit        = 1
  )
  private val controller = Apb3SpiXdrMasterCtrl(parameters)
  private val apbBridge  = new J2WishboneToApb(Apb3SpiXdrMasterCtrl.getApb3Config)
  // Keep byte ordering and SPI-specific command timing outside the generic cache.
  controller.io.xip.cmd.valid   := io.xip.cmd.valid
  controller.io.xip.cmd.address := io.xip.cmd.address(23 downto 0)
  controller.io.xip.cmd.length  := (io.xip.cmd.length ## U(3, 2 bits)).asUInt
  io.xip.cmd.ready              := controller.io.xip.cmd.ready
  private val byteIndex                   = Reg(UInt(2 bits)) init 0
  private val assembly                    = Reg(Bits(24 bits)) init 0
  private val responseValid               = RegInit(False)
  private val responseData                = Reg(Bits(32 bits)) init 0
  private val responseLast, responseError = RegInit(False)
  io.xip.rsp.valid            := responseValid
  io.xip.rsp.fragment.data    := responseData
  io.xip.rsp.fragment.error   := responseError
  io.xip.rsp.last             := responseLast
  controller.io.xip.rsp.ready := !responseValid || io.xip.rsp.ready
  when(io.xip.rsp.fire)(responseValid := False)
  when(controller.io.xip.rsp.fire) {
    assembly  := assembly(15 downto 0) ## controller.io.xip.rsp.fragment
    byteIndex := byteIndex + 1
    when(byteIndex === 3 || controller.io.xip.rsp.last) {
      responseValid := True
      responseData  := assembly ## controller.io.xip.rsp.fragment
      responseLast  := controller.io.xip.rsp.last
      responseError := byteIndex =/= 3
    }
    when(controller.io.xip.rsp.last)(byteIndex := 0)
  }

  // Control accesses take priority over admission of new cache requests.
  // Finish any existing refill, including the controller's trailing CS release,
  // before changing SPI configuration or accessing its shared command/RX FIFOs.
  private val draining       = RegInit(False)
  private val controlAllowed = !io.readBusy && !draining
  io.readHold                 := io.control.CYC && io.control.STB
  apbBridge.io.input.CYC      := io.control.CYC && controlAllowed
  apbBridge.io.input.STB      := io.control.STB && controlAllowed
  apbBridge.io.input.WE       := io.control.WE
  apbBridge.io.input.ADR      := io.control.ADR
  apbBridge.io.input.DAT_MOSI := io.control.DAT_MOSI
  apbBridge.io.input.SEL      := io.control.SEL
  apbBridge.io.input.LOCK     := io.control.LOCK
  io.control.ACK              := apbBridge.io.input.ACK
  io.control.ERR              := apbBridge.io.input.ERR
  io.control.DAT_MISO         := apbBridge.io.input.DAT_MISO
  apbBridge.io.output <> controller.io.apb
  io.invalidate := io.control.CYC && io.control.STB && io.control.WE && io.control.ACK

  // The XDR controller's receive pipeline assumes one output-register cycle
  // and one input-register cycle. Driving its raw PHY signals straight onto
  // pins samples the next bit on a real mode-0 flash (JEDEC ID shifts left).
  private val spiPins = controller.io.spi.toSpi()
  when(!io.readBusy && spiPins.ss(0))(draining := False)
  when(io.xip.cmd.fire)(draining               := True)
  io.spi.cs := spiPins.ss(0)
  io.spi.clk := spiPins.sclk
  for (pin <- 0 until 4) {
    io.spi.data.write(pin)       := spiPins.data.write(pin)
    io.spi.data.writeEnable(pin) := spiPins.data.writeEnable(pin)
    spiPins.data.read(pin)       := io.spi.data.read(pin)
  }

}
