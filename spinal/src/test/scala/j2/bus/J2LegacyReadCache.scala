package j2.bus

import spinal.core._
import spinal.lib._

/** Blocking, read-only, two-way cache with a target-independent word-burst refill port. A line is
  * published only after its complete refill. The upstream master drops STB between classic
  * transfers.
  */
final class J2WishboneReadCache(val config: J2ReadCacheConfig = J2ReadCacheConfig())
    extends Component {
  private val cacheBytes   = config.cacheBytes
  private val lineBytes    = config.lineBytes
  private val sets         = cacheBytes / (2 * lineBytes)
  private val offsetBits   = log2Up(lineBytes)
  private val wordsPerLine = lineBytes / 4
  private val wordBits     = log2Up(wordsPerLine)
  private val setBits      = log2Up(sets)
  private val tagBits      = 32 - offsetBits - setBits
  val io = new Bundle {
    val bus              = slave(J2Wishbone())
    val refill           = master(J2ReadBurst(wordBits))
    val control          = slave(J2Wishbone())
    val invalidate, hold = in Bool ()
    val busy             = out Bool ()
  }

  private object State extends SpinalEnum {
    val IDLE, LOOKUP, COMMAND, REFILL, RESPONSE, ERROR, RELEASE = newElement()
  }
  private val state              = RegInit(State.IDLE)
  private val address            = Reg(UInt(32 bits)) init 0
  private val alive, invalidated = RegInit(False)
  private val victim             = RegInit(False)
  private val wordIndex          = Reg(UInt(wordBits bits)) init 0
  private val overflow           = RegInit(False)
  private val refillError        = RegInit(False)
  private val result             = Reg(Bits(32 bits)) init 0
  private val valid              = Vector.fill(2)(Vec.fill(sets)(RegInit(False)))
  // With two ways one bit is exact LRU: it names the next victim.
  private val lru                 = Vec.fill(sets)(RegInit(False))
  private val tags                = Vector.fill(2)(Mem(UInt(tagBits bits), sets))
  private val words               = Vector.fill(2)(Mem(Bits(32 bits), sets * wordsPerLine))
  private val controlRequested    = io.control.CYC && io.control.STB
  private val controlSeen         = RegInit(False)
  private val controlAddressValid = io.control.ADR(11 downto 2) === 0
  io.control.ACK         := controlRequested && !controlSeen && controlAddressValid
  io.control.ERR         := controlRequested && !controlSeen && !controlAddressValid
  io.control.DAT_MISO    := 0
  io.control.DAT_MISO(1) := state =/= State.IDLE
  when(controlRequested)(controlSeen := True) otherwise { controlSeen := False }
  // CONTROL: bit 0 W1 invalidates all lines (reads zero); bit 1 RO is busy.
  private val softwareInvalidate = io.control.ACK && io.control.WE &&
    io.control.SEL(0) && io.control.DAT_MOSI(0)
  private val invalidate = io.invalidate || softwareInvalidate
  private val requested  = io.bus.CYC && io.bus.STB
  // Use 33 bits so the exclusive upper bound 2^32 cannot wrap to zero.
  private val inRange = io.bus.ADR.resize(33) >= U(config.baseAddress, 33 bits) &&
    io.bus.ADR.resize(33) < U(config.endAddress, 33 bits)
  private val accept = state === State.IDLE && requested && !io.hold && !invalidate
  private val set    = address(offsetBits + setBits - 1 downto offsetBits)
  private val tag    = address(31 downto offsetBits + setBits)
  private val readTags =
    tags.map(_.readSync(io.bus.ADR(offsetBits + setBits - 1 downto offsetBits), accept))
  private val readWords =
    words.map(_.readSync(io.bus.ADR(offsetBits + setBits - 1 downto 2), accept))
  private val hits     = Vec((0 until 2).map(i => valid(i)(set) && readTags(i) === tag))
  private val hitWay   = hits(1)
  private val complete = state === State.REFILL && io.refill.rsp.fire && io.refill.rsp.last
  private val goodFill =
    complete && wordIndex === wordsPerLine - 1 && !overflow && !refillError && !io.refill.rsp.fragment.error && alive && requested &&
      !invalidated && !invalidate

  io.busy               := state =/= State.IDLE
  io.bus.ACK            := state === State.RESPONSE && alive && requested && !invalidate
  io.bus.ERR            := state === State.ERROR && alive && requested
  io.bus.DAT_MISO       := result
  io.refill.cmd.valid   := state === State.COMMAND
  io.refill.cmd.address := (address(31 downto offsetBits) ## U(0, offsetBits bits)).asUInt
  io.refill.cmd.length  := wordsPerLine - 1
  io.refill.rsp.ready   := state === State.REFILL

  for (way <- 0 until 2) {
    words(way).write(
      address = (set ## wordIndex).asUInt,
      data    = io.refill.rsp.fragment.data,
      enable = state === State.REFILL && io.refill.rsp.fire &&
        !overflow && victim === Bool(way == 1)
    )
    tags(way).write(set, tag, goodFill && victim === Bool(way == 1))
  }

  when(state =/= State.IDLE && !requested)(alive := False)
  switch(state) {
    is(State.IDLE) {
      when(accept) {
        address     := (io.bus.ADR(31 downto 2) ## U(0, 2 bits)).asUInt
        alive       := True
        invalidated := False
        state       := Mux(io.bus.WE || !inRange, State.ERROR, State.LOOKUP)
      }
    }
    is(State.LOOKUP) {
      when(!alive || !requested)(state := State.IDLE)
        .elsewhen(!invalidate) {
          when(hits.orR && !invalidated) {
            result   := Mux(hitWay, readWords(1), readWords(0))
            lru(set) := !hitWay
            state    := State.RESPONSE
          } otherwise {
            val chosen = Mux(!valid(0)(set), False, Mux(!valid(1)(set), True, lru(set)))
            victim := chosen
            when(chosen)(valid(1)(set) := False) otherwise { valid(0)(set) := False }
            invalidated := False
            wordIndex   := 0
            overflow    := False
            refillError := False
            state       := State.COMMAND
          }
        }
    }
    is(State.COMMAND) {
      // Backends may start consuming a command before asserting ready.
      // Even an abandoned request must keep cmd stable and drain its response.
      when(io.refill.cmd.fire)(state := State.REFILL)
    }
    is(State.REFILL) {
      when(io.refill.rsp.fire) {
        when(io.refill.rsp.fragment.error)(refillError := True)
        when(wordIndex === address(offsetBits - 1 downto 2)) {
          result := io.refill.rsp.fragment.data
        }
        when(wordIndex === wordsPerLine - 1)(overflow := True) otherwise {
          wordIndex := wordIndex + 1
        }
        when(io.refill.rsp.last) {
          when(!alive || !requested)(state := State.IDLE)
            .elsewhen(
              wordIndex =/= wordsPerLine - 1 || overflow || refillError || io.refill.rsp.fragment.error
            )(state := State.ERROR)
            .elsewhen(invalidated || invalidate)(state := State.LOOKUP)
            .otherwise {
              when(victim)(valid(1)(set) := True) otherwise { valid(0)(set) := True }
              lru(set) := !victim
              state    := State.RESPONSE
            }
        }
      }
    }
    is(State.RESPONSE) {
      when(!alive || !requested)(state := State.IDLE)
        .elsewhen(invalidate)(state := State.LOOKUP)
        .otherwise(state := State.RELEASE)
    }
    is(State.ERROR) {
      state := Mux(alive && requested, State.RELEASE, State.IDLE)
    }
    is(State.RELEASE)(when(!requested)(state := State.IDLE))
  }
  // Invalidation wins over line publication, including the final refill word.
  when(invalidate) {
    for (way <- valid; entry <- way) entry := False
    invalidated                            := True
  }
}
