package j2.isa

import j2.microcode.J2MicrocodeData

import spinal.core._
import spinal.lib._

final case class J2PredecodeEntry(pattern: String, address: Int, name: String) {
  require(pattern.length == 16 && pattern.forall("01nmdi".contains(_)))

  val mask: Int = Integer.parseUnsignedInt(
    pattern.map(c => if (c == '0' || c == '1') '1' else '0').mkString,
    2
  )
  val value: Int = Integer.parseUnsignedInt(
    pattern.map(c => if (c == '1') '1' else '0').mkString,
    2
  )

  def matches(instruction: Int): Boolean = (instruction & mask) == value
}

object J2PredecodeEntry {
  val entries: Vector[J2PredecodeEntry] =
    J2MicrocodeData.resourceLines("/j2_predecode.tsv").map { line =>
      line.split("\t", 3) match {
        case Array(pattern, address, name) =>
          J2PredecodeEntry(pattern, Integer.parseInt(address, 16), name)
        case _ => throw new IllegalArgumentException(s"invalid predecode entry: $line")
      }
    }

  // Address selection is one-hot. Reject ambiguous additions rather than
  // silently depending on table order or building a priority encoder.
  entries.combinations(2).foreach { pair =>
    val a = pair(0)
    val b = pair(1)
    require(
      ((a.value ^ b.value) & a.mask & b.mask) != 0,
      s"overlapping predecode patterns: ${a.name} and ${b.name}"
    )
  }

  def find(instruction: Int): Option[J2PredecodeEntry] = entries.find(_.matches(instruction))

  def isDelaySlotIllegal(instruction: Int): Boolean = {
    val code = instruction & 0xffff
    ((code >>> 12) == 0 && ((code >>> 2) & 3) == 0 && (code & 1) != 0) ||
    ((code >>> 14) == 2 && ((code >>> 11) & 3) == 1 && (code & 0x100) != 0) ||
    ((code >>> 13) == 5) ||
    ((code & 0x8000) != 0 && ((code >>> 8) & 0x3f) == 3) ||
    ((code & 0x8000) == 0 && ((code >>> 12) & 3) == 0 && (code & 0x1f) == 0x0b)
  }
}

final class J2Predecoder extends Component {
  val io = new Bundle {
    val instruction      = in UInt (16 bits)
    val address          = out UInt (8 bits)
    val firstLine        = out UInt (72 bits)
    val legal            = out Bool ()
    val delaySlotIllegal = out Bool ()
  }

  private val matches = J2PredecodeEntry.entries.map { entry =>
    entry -> ((io.instruction & U(entry.mask, 16 bits)) === U(entry.value, 16 bits))
  }

  private val selected = Vec(matches.map(_._2))
  io.address := MuxOH(selected, Vec(matches.map { case (entry, _) => U(entry.address, 8 bits) }))
  // Direct first-operation decode. The same canonical control definitions feed
  // both this logic and the continuation ROM, so the two paths cannot drift.
  io.firstLine := MuxOH(
    selected,
    Vec(matches.map { case (entry, _) =>
      U(J2MicrocodeData.entries(entry.address), 72 bits)
    })
  )
  io.legal := selected.asBits.orR
  io.delaySlotIllegal :=
    ((io.instruction(15 downto 12) === 0) && (io.instruction(3 downto 2) === 0) && io.instruction(
      0
    )) ||
      ((io.instruction(15 downto 14) === 2) && (io.instruction(12 downto 11) === 1) && io
        .instruction(8)) ||
      (io.instruction(15 downto 13) === 5) ||
      (io.instruction(15) && (io.instruction(13 downto 8) === 3)) ||
      (!io.instruction(15) && (io.instruction(13 downto 12) === 0) &&
        (io.instruction(4 downto 0) === 0x0b))
}
