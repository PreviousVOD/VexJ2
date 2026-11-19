package j2.bus

import spinal.core._
import spinal.lib._

case class J2ReadCacheConfig(
    cacheBytes: Int = 4096,
    lineBytes: Int = 32,
    baseAddress: BigInt = 0,
    rangeBytes: BigInt = BigInt(1) << 32
) {
  require(isPow2(lineBytes) && lineBytes >= 8, "line size must be a power of two, at least 8 bytes")
  require(
    isPow2(cacheBytes) && cacheBytes.toLong >= 4L * lineBytes,
    "capacity must be a power of two with at least two sets"
  )
  require(
    baseAddress >= 0 && rangeBytes > 0 && baseAddress + rangeBytes <= (BigInt(1) << 32),
    "cache window must fit in the 32-bit address space"
  )
  require(
    baseAddress % lineBytes == 0 && rangeBytes % lineBytes == 0,
    "cache window boundaries must be line aligned"
  )
  val endAddress: BigInt = baseAddress + rangeBytes // exclusive; may equal 2^32
}

/** Blocking, read-only, two-way cache with a target-independent word-burst refill port. A line is
  * published only after its complete refill. Accepted commands are irrevocable; the response
  * remains valid until consumed.
  */
final class J2ReadCacheEngine(val config: J2ReadCacheConfig = J2ReadCacheConfig())
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
    val bus              = slave(J2MemoryPort())
    val refill           = master(J2ReadBurst(wordBits))
    val invalidate, hold = in Bool ()
    val busy             = out Bool ()
  }

  private object State extends SpinalEnum {
    val IDLE, LOOKUP, COMMAND, REFILL, RESPONSE, ERROR = newElement()
  }
  private val state       = RegInit(State.IDLE)
  private val address     = Reg(UInt(32 bits)) init 0
  private val invalidated = RegInit(False)
  private val victim      = RegInit(False)
  private val wordIndex   = Reg(UInt(wordBits bits)) init 0
  private val overflow    = RegInit(False)
  private val refillError = RegInit(False)
  private val result      = Reg(Bits(32 bits)) init 0
  private val valid       = Vector.fill(2)(Vec.fill(sets)(RegInit(False)))
  // With two ways one bit is exact LRU: it names the next victim.
  private val lru        = Vec.fill(sets)(RegInit(False))
  private val tags       = Vector.fill(2)(Mem(UInt(tagBits bits), sets))
  private val words      = Vector.fill(2)(Mem(Bits(32 bits), sets * wordsPerLine))
  private val invalidate = io.invalidate
  // Use 33 bits so the exclusive upper bound 2^32 cannot wrap to zero.
  private val inRange = io.bus.cmd.address.resize(33) >= U(config.baseAddress, 33 bits) &&
    io.bus.cmd.address.resize(33) < U(config.endAddress, 33 bits)
  io.bus.cmd.ready := state === State.IDLE && !io.hold && !invalidate
  private val accept = io.bus.cmd.fire
  private val set    = address(offsetBits + setBits - 1 downto offsetBits)
  private val tag    = address(31 downto offsetBits + setBits)
  private val readTags =
    tags.map(_.readSync(io.bus.cmd.address(offsetBits + setBits - 1 downto offsetBits), accept))
  private val readWords =
    words.map(_.readSync(io.bus.cmd.address(offsetBits + setBits - 1 downto 2), accept))
  private val hits     = Vec((0 until 2).map(i => valid(i)(set) && readTags(i) === tag))
  private val hitWay   = hits(1)
  private val complete = state === State.REFILL && io.refill.rsp.fire && io.refill.rsp.last
  private val goodFill =
    complete && wordIndex === wordsPerLine - 1 && !overflow && !refillError && !io.refill.rsp.fragment.error &&
      !invalidated && !invalidate

  io.busy               := state =/= State.IDLE
  io.bus.rsp.valid      := (state === State.RESPONSE && !invalidate) || state === State.ERROR
  io.bus.rsp.error      := state === State.ERROR
  io.bus.rsp.data       := result
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

  switch(state) {
    is(State.IDLE) {
      when(accept) {
        address     := (io.bus.cmd.address(31 downto 2) ## U(0, 2 bits)).asUInt
        invalidated := False
        state       := Mux(io.bus.cmd.write || !inRange, State.ERROR, State.LOOKUP)
      }
    }
    is(State.LOOKUP) {
      when(!invalidate) {
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
      // Keep the command stable until it is accepted, then drain the full response.
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
          when(
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
      when(invalidate)(state := State.LOOKUP)
        .elsewhen(io.bus.rsp.fire)(state := State.IDLE)
    }
    is(State.ERROR)(when(io.bus.rsp.fire)(state := State.IDLE))
  }

  // Invalidation wins over line publication, including the final refill word.
  when(invalidate) {
    for (way <- valid; entry <- way) entry := False
    invalidated                            := True
  }
}
