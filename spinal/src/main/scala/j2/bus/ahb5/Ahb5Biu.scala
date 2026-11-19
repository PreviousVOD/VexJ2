package j2.bus.ahb5

import spinal.core._
import spinal.lib._

/** Destination arbitration and an AHB manager. Bursts retain the selected port, with BUSY inserted
  * while the next beat is buffered. Locks additionally survive burst boundaries. HMASTER is
  * transported unchanged; the physical ingress port owns arbitration state.
  */
private[ahb5] class Ahb5BiuEngine(config: Ahb5Config, inputCount: Int) extends Component {
  require(inputCount > 0)
  val io = new Bundle {
    val inputs = Vec(slave(Ahb5Transport(config)), inputCount)
    val output = master(Ahb5(config))
  }
  object State extends SpinalEnum { val IDLE, ADDRESS, DATA, RESPONSE = newElement() }
  val state       = RegInit(State.IDLE)
  val owner       = Reg(UInt(Math.max(1, log2Up(inputCount)) bits)) init (0)
  val lastGrant   = Reg(Bits(inputCount bits)) init (BigInt(1) << (inputCount - 1))
  val locked      = RegInit(False)
  val bursting    = RegInit(False)
  val aborted     = RegInit(False)
  val remaining   = Reg(UInt(5 bits)) init (0)
  val request     = Reg(Ahb5Request(config))
  val response    = Reg(Ahb5Response(config))
  val lockControl = Reg(Ahb5Control(config))
  val nextAddress = Reg(UInt(config.addressWidth bits))

  val wants = io.inputs.map(p => p.request.valid || p.reservation).asBits()
  val priority =
    if (inputCount == 1) lastGrant else lastGrant(inputCount - 2 downto 0) ## lastGrant.msb
  val proposal = OHMasking.roundRobin(wants, priority)
  val chosen   = UInt(owner.getWidth bits)
  chosen := OHToUInt(proposal).resized
  when(locked || bursting)(chosen := owner)
  val selected = if (inputCount == 1) io.inputs.head else io.inputs(chosen)
  val current  = if (inputCount == 1) io.inputs.head else io.inputs(owner)

  for ((input, index) <- io.inputs.zipWithIndex) {
    input.request.ready := state === State.IDLE && chosen === index &&
      (locked || bursting || proposal.orR)
    input.response.valid   := state === State.RESPONSE && owner === index
    input.response.payload := response
  }

  when(state === State.IDLE) {
    // Release is observed even when no transfer addresses this BIU.
    when(locked && !current.reservation)(locked := False)
    when(bursting && !current.continuing && !current.request.valid)(bursting := False)
    when(bursting && current.request.valid && current.request.control.HTRANS === Ahb5Trans.NONSEQ) {
      bursting := False
    }
    when((proposal.orR || locked || bursting) && selected.reservation) {
      locked      := True
      lockControl := selected.reservationControl
      owner       := chosen
    }
    when(selected.request.fire) {
      request   := selected.request.payload
      owner     := chosen
      lastGrant := (B(1, inputCount bits) |<< chosen).resized
      state     := State.ADDRESS
    }
  }

  io.output.address.HTRANS.allowOverride
  io.output.address.HADDR.allowOverride
  io.output.address.HMASTLOCK.allowOverride
  io.output.address           := request.control
  io.output.address.HTRANS    := Ahb5Trans.IDLE
  io.output.address.HADDR     := nextAddress
  io.output.address.HMASTLOCK := locked && current.reservation
  when(locked && !bursting && state === State.IDLE) {
    io.output.address           := lockControl
    io.output.address.HTRANS    := Ahb5Trans.IDLE
    io.output.address.HMASTLOCK := current.reservation
  }
  io.output.HSEL                            := locked || bursting || state === State.ADDRESS
  io.output.HREADY                          := state =/= State.DATA || io.output.HREADYOUT
  io.output.HWDATA                          := request.data
  if (config.writeStrobes) io.output.HWSTRB := request.strobes
  when(bursting && !aborted)(io.output.address.HTRANS := Ahb5Trans.BUSY)

  when(state === State.ADDRESS) {
    io.output.address := request.control
    // A downstream ERROR cancels its burst. A manager may nevertheless continue upstream
    // (3.6.2); transport those remaining beats as independent transfers, never orphan SEQs.
    when(aborted && request.control.HTRANS === Ahb5Trans.SEQ) {
      io.output.address.HTRANS := Ahb5Trans.NONSEQ
      io.output.address.HBURST := Ahb5Burst.SINGLE
    }
    state       := State.DATA // No previous data phase is outstanding on this port.
    nextAddress := request.control.nextAddress
    when(request.control.HTRANS === Ahb5Trans.NONSEQ) {
      aborted   := False
      bursting  := request.control.HBURST =/= Ahb5Burst.SINGLE
      remaining := 0 // INCR has no fixed end count.
      switch(request.control.HBURST) {
        is(Ahb5Burst.WRAP4, Ahb5Burst.INCR4)(remaining := 3)
        is(Ahb5Burst.WRAP8, Ahb5Burst.INCR8)(remaining := 7)
        is(Ahb5Burst.WRAP16, Ahb5Burst.INCR16)(remaining := 15)
      }
    } otherwise
      when(remaining =/= 0) {
        remaining := remaining - 1
        when(remaining === 1)(bursting := False)
      }
  }
  // Cancel the following address phase in the second cycle of a downstream ERROR (5.1.3).
  when(state === State.DATA && io.output.HRESP)(aborted := True)
  when(state === State.DATA && io.output.HREADYOUT) {
    response.data  := io.output.HRDATA
    response.error := io.output.HRESP
    state          := State.RESPONSE
  }
  when(state === State.RESPONSE && current.response.ready)(state := State.IDLE)
}

/** Standalone BIU for one destination domain. All inputs use the same clock and reset. */
class Ahb5Biu(config: Ahb5Config, managerCount: Int) extends Component {
  require(managerCount > 0)
  val io = new Bundle {
    val managers    = Vec(slave(Ahb5Master(config)), managerCount)
    val subordinate = master(Ahb5(config))
  }
  private val engine = new Ahb5BiuEngine(config, managerCount)
  for (index <- 0 until managerCount) {
    val ingress = new Ahb5Ingress(config)
    ingress.io.bus <> io.managers(index)
    engine.io.inputs(index) <> ingress.io.transport
  }
  io.subordinate <> engine.io.output
}
