package j2.board.tang_primer

import j2.bus._
import spinal.core._
import spinal.lib._
import spinal.lib.bus.bmb._
import spinal.lib.memory.sdram.sdr.{BmbSdramCtrl, EG4S20, SdramInterface}

/** AHB operations feed the SDRAM controller directly through its native BMB port. */
final class J2Sdram extends Component {
  val io = new Bundle {
    val bus   = slave(J2Ahb.subordinate())
    val sdram = master(SdramInterface(EG4S20.layout))
  }
  private val endpoint = new J2AhbMemoryEndpoint
  endpoint.io.ahb <> io.bus
  private val port = endpoint.io.memory
  private val controller = BmbSdramCtrl(
    BmbParameter(
      addressWidth = EG4S20.layout.byteAddressWidth,
      dataWidth    = 32,
      sourceWidth  = 0,
      contextWidth = 0,
      lengthWidth  = 2
    ),
    EG4S20.layout,
    EG4S20.timingGrade7,
    CAS = 3
  )
  private val bmb = controller.io.bmb
  bmb.cmd.valid  := port.cmd.valid
  bmb.cmd.opcode := Bmb.Cmd.Opcode.READ
  when(port.cmd.write)(bmb.cmd.opcode := Bmb.Cmd.Opcode.WRITE)
  bmb.cmd.address := (port.cmd
    .address(EG4S20.layout.byteAddressWidth - 1 downto 2) ## U(0, 2 bits)).asUInt
  bmb.cmd.data    := port.cmd.data
  bmb.cmd.mask    := port.cmd.mask
  bmb.cmd.length  := 3
  bmb.cmd.last    := True
  bmb.cmd.source  := 0
  bmb.cmd.context := 0
  port.cmd.ready  := bmb.cmd.ready
  port.rsp.valid  := bmb.rsp.valid
  port.rsp.data   := bmb.rsp.data
  port.rsp.error  := bmb.rsp.isError
  bmb.rsp.ready   := port.rsp.ready
  io.sdram <> controller.io.sdram
}
