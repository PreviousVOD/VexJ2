package j2.periph

import j2.bus.{J2Apb, J2ReadBurst}
import spinal.core._
import spinal.lib._
import j2.bus.apb._
import spinal.lib.com.spi.ddr.{SpiXdrMaster, SpiXdrMasterCtrl, SpiXdrParameter}
import spinal.lib.io.TriStateArray

final class J2SpiFlash(lineBytes: Int = 32) extends Component {
  require(isPow2(lineBytes) && lineBytes >= 8)
  val io = new Bundle {
    val control              = slave(J2Apb())
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
  private val controller = new Apb4SpiXdrMasterCtrl(parameters)
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
  // A waiting outer APB transfer must still give the controller its own SETUP
  // cycle after the refill drains; never gate PSEL on mid-ACCESS readiness.
  private object ControlState extends SpinalEnum { val IDLE, SETUP, ACCESS = newElement() }
  private val controlState = RegInit(ControlState.IDLE)
  io.readHold               := io.control.PSEL(0)
  controller.io.apb.PADDR   := io.control.PADDR.resized
  controller.io.apb.PWRITE  := io.control.PWRITE
  controller.io.apb.PWDATA  := io.control.PWDATA
  controller.io.apb.PSEL(0) := controlState =/= ControlState.IDLE
  controller.io.apb.PENABLE := controlState === ControlState.ACCESS
  io.control.PREADY         := controlState === ControlState.ACCESS && controller.io.apb.PREADY
  io.control.PRDATA         := controller.io.apb.PRDATA
  controller.io.apb.PSTRB   := io.control.PSTRB
  controller.io.apb.PPROT   := io.control.PPROT
  io.control.PSLVERR        := io.control.PREADY && controller.io.apb.PSLVERR
  switch(controlState) {
    is(ControlState.IDLE) {
      when(io.control.PSEL(0) && controlAllowed)(controlState := ControlState.SETUP)
    }
    is(ControlState.SETUP)(controlState := ControlState.ACCESS)
    is(ControlState.ACCESS)(when(io.control.PREADY)(controlState := ControlState.IDLE))
  }
  io.invalidate := io.control.PSEL(0) && io.control.PENABLE && io.control.PREADY &&
    io.control.PWRITE && io.control.PSTRB.orR && !io.control.PSLVERR

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

/** Native APB4 mapping of the SPI controller; no APB3 adapter or RMW. */
private class Apb4SpiXdrMasterCtrl(p: SpiXdrMasterCtrl.MemoryMappingParameters) extends Component {
  val io = new Bundle {
    val apb       = slave(Apb4(Apb4Config(8, 32)))
    val xip       = slave(SpiXdrMasterCtrl.XipBus(p.xip))
    val spi       = master(SpiXdrMaster(p.ctrl.spi))
    val interrupt = out Bool ()
  }
  private val ctrl    = SpiXdrMasterCtrl(p.ctrl)
  private val factory = Apb4SlaveFactory(io.apb)
  factory.requireWriteStrobes(0x00, 3)
  factory.requireWriteStrobes(0x50, 15)
  factory.requireWriteStrobes(0x54, 15)
  private val mapping = SpiXdrMasterCtrl.driveFrom(ctrl, factory)(p)
  io.xip <> mapping.xip.xipBus
  io.spi <> ctrl.io.spi
  io.interrupt <> mapping.interruptCtrl.interrupt
}
