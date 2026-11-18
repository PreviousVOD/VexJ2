package j2.core

object J2InstructionMemory {
  def word(code: scala.collection.Map[Long, Int], address: Long): Long = {
    require((address & 3L) == 0, "instruction bus must request aligned words")
    (code.getOrElse(address, 9).toLong << 16) | code.getOrElse(address + 2, 9).toLong
  }
}
