package j2.bus

import spinal.core._
import spinal.lib._

final class J2ReadCache(val config: J2ReadCacheConfig = J2ReadCacheConfig()) extends Component {
  val io = new Bundle {
    val bus              = slave(J2Ahb.subordinate())
    val control          = slave(J2Apb())
    val refill           = master(J2ReadBurst(log2Up(config.lineBytes / 4)))
    val invalidate, hold = in Bool ()
    val busy             = out Bool ()
  }
  private val cache    = new J2ReadCacheEngine(config)
  private val endpoint = new J2AhbMemoryEndpoint
  endpoint.io.ahb <> io.bus
  cache.io.bus <> endpoint.io.memory
  val validAddress = io.control.PADDR === 0
  io.control.PREADY    := True
  io.control.PRDATA    := 0
  io.control.PRDATA(1) := cache.io.busy
  io.control.PSLVERROR := io.control.PSEL(0) && io.control.PENABLE && !validAddress
  val softwareInvalidate = io.control.PSEL(0) && io.control.PENABLE && validAddress &&
    io.control.PWRITE && io.control.PWDATA(0)
  io.refill <> cache.io.refill
  cache.io.invalidate := io.invalidate || softwareInvalidate
  cache.io.hold       := io.hold
  io.busy             := cache.io.busy
}
