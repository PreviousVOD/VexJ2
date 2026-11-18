package j2.bus

import spinal.core._
import spinal.lib._

case class J2MigPort() extends Bundle with IMasterSlave {
  val address                               = UInt(28 bits)
  val command                               = Bits(3 bits)
  val enable, writeEnable, writeEnd         = Bool()
  val writeData, readData                   = Bits(128 bits)
  val writeMask                             = Bits(16 bits)
  val ready, writeReady, readValid, readEnd = Bool()
  override def asMaster(): Unit = {
    out(address, command, enable, writeEnable, writeEnd, writeData, writeMask)
    in(ready, writeReady, readData, readValid, readEnd)
  }
}
case class J2DdrRequest() extends Bundle {
  val address = UInt(32 bits)
  val data    = Bits(32 bits)
  val select  = Bits(4 bits)
  val write   = Bool()
}
case class J2DdrResponse() extends Bundle {
  val data  = Bits(32 bits)
  val error = Bool()
}

/** One outstanding burst. A timeout poisons the backend until coordinated reset: pending write data
  * or a delayed read must never be paired with another request.
  */
final class J2MigBackend(base: BigInt, size: BigInt, timeoutBits: Int = 20) extends Component {
  require(base >= 0 && base % 16 == 0 && size > 0 && size % 16 == 0)
  require(size <= (BigInt(1) << 28) && base + size <= (BigInt(1) << 32))
  require(timeoutBits >= 4)
  val io = new Bundle {
    val request    = slave(Stream(J2DdrRequest()))
    val response   = master(Stream(J2DdrResponse()))
    val native     = master(J2MigPort())
    val calibrated = in Bool ()
  }
  object State extends SpinalEnum { val IDLE, DATA, COMMAND, READ, RESPONSE = newElement() }
  val state    = RegInit(State.IDLE)
  val request  = Reg(J2DdrRequest())
  val response = Reg(J2DdrResponse())
  val poisoned = RegInit(False)
  val watchdog = Reg(UInt(timeoutBits bits)) init 0
  val offset   = request.address - U(base, 32 bits)
  val slot     = offset(3 downto 2)
  io.request.ready      := state === State.IDLE && (io.calibrated || poisoned)
  io.response.valid     := state === State.RESPONSE
  io.response.payload   := response
  io.native.address     := ((offset >> 4) << 3).resized
  io.native.command     := Mux(request.write, B"000", B"001")
  io.native.enable      := state === State.COMMAND && io.calibrated && !poisoned
  io.native.writeEnable := state === State.DATA && io.calibrated && !poisoned
  io.native.writeEnd    := True
  // Lowest MIG byte is lowest memory address; Wishbone lane 3 is SH-2's first byte.
  io.native.writeData := 0
  io.native.writeMask := B(0xffff, 16 bits)
  for (word <- 0 until 4; byte <- 0 until 4)
    when(slot === word) {
      io.native.writeData((word * 4 + byte) * 8, 8 bits) := request.data((3 - byte) * 8, 8 bits)
      io.native.writeMask(word * 4 + byte)               := !request.select(3 - byte)
    }
  val readWord = io.native.readData.subdivideIn(32 bits)(slot)
  when(state === State.DATA || state === State.COMMAND || state === State.READ) {
    watchdog := watchdog + 1
  }
  when(io.request.fire) {
    request       := io.request.payload
    response.data := 0; response.error := False; watchdog := 0
    val address = io.request.address.resize(33)
    when(poisoned || address < U(base, 33 bits) || address >= U(base + size, 33 bits)) {
      response.error := True; state := State.RESPONSE
    } elsewhen (io.request.write && !io.request.select.orR) {
      state := State.RESPONSE
    } otherwise {
      state := Mux(io.request.write, State.DATA, State.COMMAND)
    }
  }
  when(io.native.writeEnable && io.native.writeReady) { state := State.COMMAND; watchdog := 0 }
  when(io.native.enable && io.native.ready) {
    state := Mux(request.write, State.RESPONSE, State.READ); watchdog := 0
  }
  when(state === State.READ && io.native.readValid) {
    for (byte <- 0 until 4) response.data((3 - byte) * 8, 8 bits) := readWord(byte * 8, 8 bits)
    response.error                                                := !io.native.readEnd
    when(!io.native.readEnd)(poisoned := True)
    state := State.RESPONSE
  }
  when(io.response.fire)(state := State.IDLE)
  when(state === State.DATA || state === State.COMMAND || state === State.READ) {
    when(watchdog.andR || !io.calibrated) {
      poisoned := True; response.error := True; response.data := 0; state := State.RESPONSE
    }
  }
}

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
    io.bus.ACK      := complete && !responses.io.output.error
    io.bus.ERR      := complete && responses.io.output.error
    io.bus.DAT_MISO := responses.io.output.data
    when(responses.io.output.fire) { pending := False; abandoned := False }
  }
}
