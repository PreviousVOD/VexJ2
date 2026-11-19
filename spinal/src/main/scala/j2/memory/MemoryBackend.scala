package j2.memory

import spinal.core._
import spinal.core.internals._

/** Generation policy for memories marked with Spinal's generic ramBlock intent. CPU and SoC
  * components do not select or import a backend.
  */
sealed trait MemoryBackend {
  def configure(config: SpinalConfig): SpinalConfig
}

object MemoryBackend {
  case object Inferred extends MemoryBackend {
    override def configure(config: SpinalConfig): SpinalConfig = config
  }

  case object Xilinx extends MemoryBackend {
    override def configure(config: SpinalConfig): SpinalConfig = {
      config.memBlackBoxers += new PhaseMemBlackboxing {
        override def doBlackboxing(pc: PhaseContext, topo: MemTopology): Unit =
          if (topo.mem.technology == ramBlock) topo.mem.addAttribute("ram_style", "block")
      }
      config
    }
  }

  case object Eg4 extends MemoryBackend {
    override def configure(config: SpinalConfig): SpinalConfig = {
      config.memBlackBoxers += new Eg4RomPhase
      config
    }
  }
}
