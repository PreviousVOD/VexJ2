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
  private val cache      = new J2WishboneReadCache(config)
  private val dataBridge = new J2AhbToWishbone
  dataBridge.io.ahb <> io.bus
  cache.io.bus <> dataBridge.io.wb
  // The cache data engine remains unchanged; control registers are native APB.
  cache.io.control.CYC      := False
  cache.io.control.STB      := False
  cache.io.control.WE       := False
  cache.io.control.ADR      := 0
  cache.io.control.DAT_MOSI := 0
  cache.io.control.SEL      := 0
  cache.io.control.LOCK     := False
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
