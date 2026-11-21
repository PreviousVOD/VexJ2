package j2.memory

import spinal.core._

/** Generation policy for memories marked with Spinal's generic ramBlock intent. CPU and SoC
  * components do not select or import a backend. Vendor packages supply FPGA implementations.
  */
trait MemoryBackend {
  def configure(config: SpinalConfig): SpinalConfig
}

object MemoryBackend {
  case object Inferred extends MemoryBackend {
    override def configure(config: SpinalConfig): SpinalConfig = config
  }
}
