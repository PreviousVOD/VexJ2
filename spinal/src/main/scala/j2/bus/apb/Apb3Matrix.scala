package j2.bus.apb

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb._
import spinal.lib.bus.misc.SizeMapping

/** One-manager APB matrix behind an arbitrating BIU/bridge. Address ranges are non-overlapping;
  * responses come only from the selected peripheral. An unmapped ACCESS completes with PSLVERR.
  * SETUP and waited ACCESS signals pass unchanged.
  */
final class Apb3Matrix(config: Apb3Config, mappings: Seq[SizeMapping]) extends Component {
  require(Set(8, 16, 32)(config.dataWidth) && config.addressWidth > 0 && config.addressWidth <= 32)
  require(config.selWidth == 1 && config.useSlaveError)
  require(mappings.nonEmpty && !SizeMapping.verifyOverlapping(mappings))
  require(
    mappings.forall(m =>
      m.base >= 0 && m.size > 0 &&
        m.base + m.size <= (BigInt(1) << config.addressWidth)
    )
  )
  val io = new Bundle {
    val input   = slave(Apb3(config))
    val outputs = Vec(master(Apb3(config)), mappings.size)
  }
  io.input.PREADY    := True
  io.input.PRDATA    := 0
  io.input.PSLVERROR := io.input.PSEL(0) && io.input.PENABLE
  for ((output, mapping) <- io.outputs.zip(mappings)) {
    val selected = io.input.PSEL(0) && mapping.hit(io.input.PADDR)
    output.PADDR   := io.input.PADDR
    output.PWRITE  := io.input.PWRITE
    output.PWDATA  := io.input.PWDATA
    output.PSEL(0) := selected
    output.PENABLE := io.input.PENABLE
    when(selected) {
      io.input.PREADY    := output.PREADY
      io.input.PRDATA    := output.PRDATA
      io.input.PSLVERROR := io.input.PENABLE && output.PREADY && output.PSLVERROR
    }
  }
}
