package j2.memory

import spinal.core._

/** Implementation policy; synchronous read timing is identical for all targets. */
sealed trait J2MemoryBackend {
  def configure[T <: Data](memory: Mem[T]): Unit = ()
}

object J2MemoryBackend {
  case object Inferred extends J2MemoryBackend
  case object Eg4BlockRam extends J2MemoryBackend
  case object XilinxBlockRam extends J2MemoryBackend {
    override def configure[T <: Data](memory: Mem[T]): Unit =
      memory.addAttribute("ram_style", "block")
  }
}
