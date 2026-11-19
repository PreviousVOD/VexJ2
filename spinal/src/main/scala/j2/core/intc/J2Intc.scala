package j2.core.intc

import j2.bus.apb._
import spinal.core._
import spinal.lib._

final class IntcCandidate extends Bundle {
  // Fixed widths also cover count=0 and count=1 without zero-width source IDs.
  val source = UInt(8 bits)
  val vector = UInt(8 bits)
  val level  = UInt(4 bits)
  val nmi    = Bool()
}

/** Private NVIC-style controls with SH-2 priorities and held-level request inputs. candidate is
  * speculative (not a backpressured Stream). The core samples it and pulses accept only at
  * architectural acceptance, then blocks further acceptance throughout entry.
  */
final class J2Intc(val config: IntcConfig) extends Component {
  val io = new Bundle {
    val bus       = slave(Apb4(Apb4Config(9, 32)))
    val requests  = in Bits (config.peripheralCount bits)
    val nmi       = in Bool ()
    val maskLevel = in UInt (4 bits)
    val candidate = master(Flow(new IntcCandidate))
    val accept    = in Bool ()
  }
  private val enabled         = Seq.fill(config.peripheralCount)(RegInit(False))
  private val softwarePending = Seq.fill(config.peripheralCount)(RegInit(False))
  private val priorities      = Seq.fill(config.peripheralCount)(Reg(UInt(4 bits)) init (0))
  private val pending =
    (0 until config.peripheralCount).map(n => io.requests(n) || softwarePending(n))
  private val aligned                    = io.bus.PADDR(1 downto 0) === 0
  private val write                      = io.bus.fire && io.bus.PWRITE && aligned
  private def writing(offset: Int): Bool = write && io.bus.PADDR === offset
  private val writeMask                  = Bits(32 bits)
  for (byte <- 0 until 4)
    writeMask(byte * 8, 8 bits) := Mux(io.bus.PSTRB(byte), B(255, 8 bits), B(0, 8 bits))
  private val written = io.bus.PWDATA & writeMask
  io.bus.PREADY  := True
  io.bus.PSLVERR := io.bus.access && !aligned
  io.bus.PRDATA  := 0

  private val nmiPin      = BufferCC(io.nmi, init = True, bufferDepth = 2)
  private val nmiPrevious = RegNext(nmiPin) init (True)
  private val nmiSeed     = Reg(UInt(2 bits)) init (0)
  when(nmiSeed =/= 3)(nmiSeed := nmiSeed + 1)
  private val nmiRising   = RegInit(False)
  private val nmiPending  = RegInit(False)
  private val nmiEdge =
    nmiSeed === 3 && Mux(nmiRising, nmiPin && !nmiPrevious, !nmiPin && nmiPrevious)
  when(io.bus.PADDR === IntcRegisters.nmiControl) {
    io.bus.PRDATA(0) := nmiPin
    io.bus.PRDATA(1) := nmiRising
  }
  when(writing(IntcRegisters.nmiControl) && io.bus.PSTRB(0))(nmiRising := io.bus.PWDATA(1))

  private val selected = Reg(new IntcCandidate)
  selected.source init (0)
  selected.vector init (0)
  selected.level init (0)
  selected.nmi init (False)
  private val selectedValid = RegInit(False)
  private val accepted      = io.accept && io.candidate.valid
  when(accepted && selected.nmi)(nmiPending := False)
  when(nmiEdge)(nmiPending                  := True)

  // Changes that can revoke or reprioritize a candidate insert a commit-cycle bubble.
  // ISPR deliberately does not: a new software request must win simultaneous acceptance.
  private val managementWrites = (0 until config.peripheralCount).map { n =>
    val bit       = n % 32
    val word      = 4 * (n / 32)
    val shift     = 4 * (n % 8)
    val iprOffset = IntcRegisters.priority + 4 * (n / 8)
    when(
      io.bus.PADDR === IntcRegisters.setEnable + word ||
        io.bus.PADDR === IntcRegisters.clearEnable + word
    )(io.bus.PRDATA(bit) := enabled(n))
    when(
      io.bus.PADDR === IntcRegisters.setPending + word ||
        io.bus.PADDR === IntcRegisters.clearPending + word
    )(io.bus.PRDATA(bit)                                          := pending(n))
    when(io.bus.PADDR === iprOffset)(io.bus.PRDATA(shift, 4 bits) := priorities(n).asBits)

    val setEnable            = writing(IntcRegisters.setEnable + word) && written(bit)
    val clearEnable          = writing(IntcRegisters.clearEnable + word) && written(bit)
    val clearPending         = writing(IntcRegisters.clearPending + word) && written(bit)
    val setPending           = writing(IntcRegisters.setPending + word) && written(bit)
    val priorityWrite        = writing(iprOffset) && io.bus.PSTRB(shift / 8)
    when(setEnable)(enabled(n)        := True)
    when(clearEnable)(enabled(n)      := False)
    when(priorityWrite)(priorities(n) := io.bus.PWDATA(shift, 4 bits).asUInt)
    when(clearPending || (accepted && !selected.nmi && selected.source === n)) {
      softwarePending(n) := False
    }
    when(setPending)(softwarePending(n) := True)
    setEnable || clearEnable || clearPending || priorityWrite
  }
  private val managementWrite = managementWrites.foldLeft(False: Bool)(_ || _)
  private val eligible = (0 until config.peripheralCount).map { n =>
    enabled(n) && pending(n) && priorities(n) > io.maskLevel
  }

  // Balanced tournament, not a source-count-deep priority mux. Left wins equal levels,
  // so ascending source index is the deterministic tie breaker.
  private def winner(inputs: Seq[Flow[IntcCandidate]]): Flow[IntcCandidate] =
    if (inputs.size == 1) inputs.head
    else
      winner(
        inputs
          .grouped(2)
          .map {
            case Seq(left, right) =>
              val result = Flow(new IntcCandidate)
              val takeLeft =
                left.valid && (!right.valid || left.payload.level >= right.payload.level)
              result.valid   := left.valid || right.valid
              result.payload := Mux(takeLeft, left.payload, right.payload)
              result
            case Seq(single) => single
          }
          .toSeq
      )
  private val leaves = (0 until config.peripheralCount).map { n =>
    val leaf = Flow(new IntcCandidate)
    leaf.valid          := eligible(n)
    leaf.payload.source := n
    leaf.payload.vector := IntcRegisters.vectorBase + n
    leaf.payload.level  := priorities(n)
    leaf.payload.nmi    := False
    leaf
  }
  private val next = Flow(new IntcCandidate)
  if (leaves.nonEmpty) next := winner(leaves)
  else {
    next.valid := False
    next.payload.assignFromBits(B(0, next.payload.getBitsWidth bits))
  }
  when(nmiPending) {
    next.valid          := True
    next.payload.source := 0
    next.payload.vector := 11
    next.payload.level  := 15
    next.payload.nmi    := True
  }
  selected      := next.payload
  selectedValid := next.valid

  // Recheck only the registered source. Withdrawal, ICER/ICPR, SR.I and priority
  // changes cannot accept stale metadata; a newly pending NMI supersedes maskable IRQs.
  private val live = (0 until config.peripheralCount)
    .map { n =>
      selected.source === n && eligible(n) && selected.level === priorities(n)
    }
    .foldLeft(False: Bool)(_ || _)
  io.candidate.payload := selected
  io.candidate.valid := selectedValid && Mux(
    selected.nmi,
    nmiPending,
    live && !nmiPending && !managementWrite
  )
}
