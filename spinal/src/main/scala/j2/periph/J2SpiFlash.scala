package j2.periph

import j2.bus.J2Wishbone
import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb.{Apb3, Apb3Config}
import spinal.lib.bus.simple.{PipelinedMemoryBus, PipelinedMemoryBusConfig}
import spinal.lib.com.spi.ddr.{Apb3SpiXdrMasterCtrl, SpiXdrMasterCtrl, SpiXdrParameter}

final class J2WishboneToPipelinedMemory extends Component {
  val io = new Bundle {
    val input  = slave(J2Wishbone())
    val output = master(PipelinedMemoryBus(PipelinedMemoryBusConfig(24, 32)))
  }
  private val fired = RegInit(False)
  io.output.cmd.valid   := io.input.CYC && io.input.STB && !fired
  io.output.cmd.write   := False
  io.output.cmd.address := (io.input.ADR(23 downto 2) ## U(0, 2 bits)).asUInt
  io.output.cmd.data    := 0
  io.output.cmd.mask    := B"1111"
  when(io.output.cmd.fire) {
    fired := True
  }
  io.input.ACK      := io.output.rsp.valid
  io.input.DAT_MISO := io.output.rsp.data
  io.input.ERR      := False
  when(io.output.rsp.valid) {
    fired := False
  }
}

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

final class J2SpiFlash extends Component {
  val io = new Bundle {
    val control = slave(J2Wishbone())
    val xip     = slave(J2Wishbone())
    val spi = new Bundle {
      val cs   = out Bool ()
      val clk  = out Bool ()
      val mosi = out Bool ()
      val miso = in Bool ()
    }
  }
  private val parameters = SpiXdrMasterCtrl.MemoryMappingParameters(
    SpiXdrMasterCtrl
      .Parameters(
        dataWidth  = 8,
        timerWidth = 12,
        spi        = SpiXdrParameter(dataWidth = 2, ioRate = 1, ssWidth = 1)
      )
      .addFullDuplex(id = 0),
    cmdFifoDepth   = 32,
    rspFifoDepth   = 32,
    sclkToggleInit = 1,
    xip            = SpiXdrMasterCtrl.XipBusParameters(addressWidth = 24, lengthWidth = 2),
    xipEnableInit  = true,
    xipInstructionEnableInit = true,
    xipInstructionDataInit   = 0x0b,
    xipDummyCountInit        = 0
  )
  private val controller = Apb3SpiXdrMasterCtrl(parameters)
  private val apbBridge  = new J2WishboneToApb(Apb3SpiXdrMasterCtrl.getApb3Config)
  apbBridge.io.input <> io.control
  apbBridge.io.output <> controller.io.apb

  private val xipAdapter = new J2WishboneToPipelinedMemory
  xipAdapter.io.input <> io.xip
  private val pmb    = xipAdapter.io.output
  private val xipBus = controller.io.xip
  xipBus.cmd.valid   := pmb.cmd.valid && !pmb.cmd.write
  xipBus.cmd.address := pmb.cmd.address
  xipBus.cmd.length  := 3
  pmb.cmd.ready      := xipBus.cmd.ready

  private val responseBuffer  = Reg(Bits(24 bits)) init 0
  private val responseCounter = Reg(UInt(2 bits)) init 0
  pmb.rsp.valid    := False
  pmb.rsp.data     := responseBuffer ## xipBus.rsp.fragment
  xipBus.rsp.ready := True
  when(xipBus.rsp.fire) {
    responseCounter := responseCounter + 1
    when(responseCounter =/= 3) {
      responseBuffer := responseBuffer(15 downto 0) ## xipBus.rsp.fragment
    } otherwise {
      pmb.rsp.valid := True
    }
  }

  // The XDR controller's receive pipeline assumes one output-register cycle
  // and one input-register cycle. Driving its raw PHY signals straight onto
  // pins samples the next bit on a real mode-0 flash (JEDEC ID shifts left).
  private val spiPins = controller.io.spi.toSpi()
  io.spi.cs            := spiPins.ss(0)
  io.spi.clk           := spiPins.sclk
  io.spi.mosi          := spiPins.data.write(0)
  spiPins.data.read(0) := False
  spiPins.data.read(1) := io.spi.miso
}
