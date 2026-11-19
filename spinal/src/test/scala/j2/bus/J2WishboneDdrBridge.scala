package j2.bus

import j2.board.wukong_v1._

import spinal.core._
import spinal.lib._

/** Clock domains must assert reset together and reset MIG too. Independent reset release is safe;
  * single-sided reset during live traffic is not supported. LOCK/CYC ownership stays in the
  * upstream matrix, including idle TAS beats.
  */
final class J2WishboneDdrBridge(
    busClock: ClockDomain,
    memoryClock: ClockDomain,
    base: BigInt = 0x80000000L,
    size: BigInt = 0x10000000L,
    timeoutBits: Int = 20
) extends Component {
  val io = new Bundle {
    val bus        = slave(J2Wishbone())
    val native     = master(J2MigPort())
    val calibrated = in Bool ()
  }
  val requests =
    new StreamCCByToggle(J2DdrRequest(), busClock, memoryClock, withOutputBufferedReset = false)
  val responses =
    new StreamCCByToggle(J2DdrResponse(), memoryClock, busClock, withOutputBufferedReset = false)
  val backend = memoryClock(new J2MigBackend(base, size, timeoutBits))
  backend.io.request << requests.io.output
  responses.io.input << backend.io.response
  io.native <> backend.io.native
  backend.io.calibrated := io.calibrated
  val front = new ClockingArea(busClock) {
    val pending   = RegInit(False)
    val abandoned = RegInit(False)
    requests.io.input.valid   := io.bus.CYC && io.bus.STB && !pending
    requests.io.input.address := io.bus.ADR
    requests.io.input.data    := io.bus.DAT_MOSI
    requests.io.input.select  := io.bus.SEL
    requests.io.input.write   := io.bus.WE
    when(requests.io.input.fire) { pending := True; abandoned := False }
    when(pending && (!io.bus.CYC || !io.bus.STB))(abandoned := True)
    responses.io.output.ready := pending && (io.bus.STB || abandoned || !io.bus.CYC)
    val complete = responses.io.output.valid && pending && !abandoned && io.bus.CYC && io.bus.STB
    io.bus.ACK                := complete && !responses.io.output.error
    io.bus.ERR                := complete && responses.io.output.error
    io.bus.DAT_MISO           := responses.io.output.data
    when(responses.io.output.fire) { pending := False; abandoned := False }
  }
}
