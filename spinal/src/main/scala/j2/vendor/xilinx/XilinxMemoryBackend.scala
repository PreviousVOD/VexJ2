package j2.vendor.xilinx

import j2.memory.MemoryBackend
import spinal.core._
import spinal.core.internals._

/** Preserve block-memory intent through Vivado inference, including initialized ROMs. */
case object XilinxMemoryBackend extends MemoryBackend {
  override def configure(config: SpinalConfig): SpinalConfig = {
    config.memBlackBoxers += new PhaseMemBlackboxing {
      override def doBlackboxing(pc: PhaseContext, topo: MemTopology): Unit =
        if (topo.mem.technology == ramBlock) {
          topo.mem.addAttribute("ram_style", "block")
        }
    }
    config
  }
}
