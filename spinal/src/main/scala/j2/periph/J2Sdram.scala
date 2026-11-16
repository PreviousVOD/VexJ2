package j2.periph

import j2.bus.J2Wishbone
import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone.WishboneToBmb
import spinal.lib.memory.sdram.sdr.{BmbSdramCtrl, EG4S20, SdramInterface}

final class Eg4SdramPhy extends BlackBox {
  val clk   = in Bool ()
  val ras_n = in Bool ()
  val cas_n = in Bool ()
  val we_n  = in Bool ()
  val addr  = in Bits (11 bits)
  val ba    = in Bits (2 bits)
  val dq    = inout(Analog(Bits(32 bits)))
  val cs_n  = in Bool ()
  val dm0   = in Bool ()
  val dm1   = in Bool ()
  val dm2   = in Bool ()
  val dm3   = in Bool ()
  val cke   = in Bool ()
  setDefinitionName("EG_PHY_SDRAM_2M_32")
}

final class J2Sdram extends Component {
  val io = new Bundle {
    val bus   = slave(J2Wishbone())
    val sdram = master(SdramInterface(EG4S20.layout))
  }
  private val bridge = WishboneToBmb(J2Wishbone.config.copy(useERR = false))
  private val controller =
    BmbSdramCtrl(
      bridge.io.output.p.copy(
        access = bridge.io.output.p.access.copy(addressWidth = EG4S20.layout.byteAddressWidth)
      ),
      EG4S20.layout,
      EG4S20.timingGrade7,
      CAS = 3
    )
  J2Wishbone.connectToWordAddressed(io.bus, bridge.io.input)
  controller.io.bmb.cmd.valid  := bridge.io.output.cmd.valid
  controller.io.bmb.cmd.opcode := bridge.io.output.cmd.opcode
  controller.io.bmb.cmd.address := bridge.io.output.cmd
    .address(EG4S20.layout.byteAddressWidth - 1 downto 0)
  controller.io.bmb.cmd.data    := bridge.io.output.cmd.data
  controller.io.bmb.cmd.mask    := bridge.io.output.cmd.mask
  controller.io.bmb.cmd.last    := bridge.io.output.cmd.last
  controller.io.bmb.cmd.source  := bridge.io.output.cmd.source
  controller.io.bmb.cmd.context := bridge.io.output.cmd.context
  bridge.io.output.cmd.ready    := controller.io.bmb.cmd.ready
  bridge.io.output.rsp.valid    := controller.io.bmb.rsp.valid
  bridge.io.output.rsp.data     := controller.io.bmb.rsp.data
  bridge.io.output.rsp.last     := controller.io.bmb.rsp.last
  bridge.io.output.rsp.source   := controller.io.bmb.rsp.source
  bridge.io.output.rsp.context  := controller.io.bmb.rsp.context
  controller.io.bmb.rsp.ready   := bridge.io.output.rsp.ready

  io.sdram <> controller.io.sdram
}
