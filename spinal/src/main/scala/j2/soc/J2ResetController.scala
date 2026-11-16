package j2.soc

import spinal.core._

/** Power-up reset independent of the button, with asynchronous assertion and release synchronized
  * to the system clock after PLL lock.
  */
final class J2ResetController(powerOnBits: Int = 8, releaseCycles: Int = 3) extends Component {
  require(powerOnBits > 0 && releaseCycles >= 2)
  val io = new Bundle {
    val referenceClock = in Bool ()
    val systemClock    = in Bool ()
    val resetN         = in Bool ()
    val clockLocked    = in Bool ()
    val reset          = out Bool ()
  }

  // BOOT emits an FPGA configuration initial value. RegInit in an ASYNC
  // domain only specifies the value on reset and cannot create power-on reset.
  private val powerOn = new ClockingArea(
    ClockDomain(
      io.referenceClock,
      config = ClockDomainConfig(resetKind = BOOT)
    )
  ) {
    val count  = Reg(UInt(powerOnBits bits)) init 0
    when(!count.andR)(count := count + 1)
    val active = !count.andR
  }
  private val request = powerOn.active || !io.resetN || !io.clockLocked
  // This crossing is deliberately asynchronous on assertion. The release
  // stages keep reset asserted until three system edges after request clears.
  request.addTag(crossClockDomain)
  private val release = new ClockingArea(ClockDomain(io.systemClock, request)) {
    val stages =
      Reg(Bits(releaseCycles bits)) init B((BigInt(1) << releaseCycles) - 1, releaseCycles bits)
    stages := stages |>> 1
  }
  // Only the final synchronizer stage may feed the SoC. OR-ing request here
  // would reintroduce a reference-clock path into synchronous reset/data logic.
  io.reset := release.stages(0)
}
