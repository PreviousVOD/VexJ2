package j2.board.wukong_v1

import j2.bus._
import spinal.core._
import spinal.lib._

/** Native AHB frontend and toggle mailboxes for the MIG backend. Both domains and MIG must assert
  * reset together; independent release is supported. Accepted AHB operations complete even when the
  * next address phase is unselected.
  */
final class J2AhbDdrBridge(
    busClock: ClockDomain,
    memoryClock: ClockDomain,
    base: BigInt = 0x80000000L,
    size: BigInt = 0x10000000L,
    timeoutBits: Int = 20
) extends Component {
  val io = new Bundle {
    val bus        = slave(J2Ahb.subordinate())
    val native     = master(J2MigPort())
    val calibrated = in Bool ()
  }
  val requests =
    new StreamCCByToggle(J2DdrRequest(), busClock, memoryClock, withOutputBufferedReset = false)
  val responses =
    new StreamCCByToggle(J2DdrResponse(), memoryClock, busClock, withOutputBufferedReset = false)
  private val backend = memoryClock(new J2MigBackend(base, size, timeoutBits))
  backend.io.request << requests.io.output
  responses.io.input << backend.io.response
  io.native <> backend.io.native
  backend.io.calibrated := io.calibrated
  private val front = new ClockingArea(busClock) {
    val endpoint = new J2AhbMemoryEndpoint
    endpoint.io.ahb <> io.bus
    val port = endpoint.io.memory
    requests.io.input.valid   := port.cmd.valid
    requests.io.input.address := port.cmd.address
    requests.io.input.data    := port.cmd.data
    requests.io.input.select  := port.cmd.mask
    requests.io.input.write   := port.cmd.write
    port.cmd.ready            := requests.io.input.ready
    port.rsp.valid            := responses.io.output.valid
    port.rsp.data             := responses.io.output.data
    port.rsp.error            := responses.io.output.error
    responses.io.output.ready := port.rsp.ready
  }
}
