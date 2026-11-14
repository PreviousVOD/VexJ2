package j2.isa

import spinal.core._
import spinal.lib._

final class J2Decoder extends Component {
  val io = new Bundle {
    val instruction = in Bits (16 bits)
    val legal = out Bool ()
    val excludedJ2 = out Bool ()
    val opcode = out UInt (J2Isa.opcodeWidth bits)
    val n = out UInt (4 bits)
    val m = out UInt (4 bits)
    val disp4 = out UInt (4 bits)
    val disp8 = out UInt (8 bits)
    val disp12 = out UInt (12 bits)
    val immediate8 = out UInt (8 bits)
  }

  private def compare(defn: J2OpcodeDef): Bool =
    (io.instruction.asUInt & U(defn.mask, 16 bits)) === U(defn.value, 16 bits)

  val legalMatches = J2Isa.instructions.map(compare)
  val excludedMatches = J2Isa.excludedInstructions.map(compare)

  io.legal := legalMatches.orR
  io.excludedJ2 := excludedMatches.orR
  io.opcode := OHToUInt(legalMatches ++ excludedMatches)
    .resize(J2Isa.opcodeWidth)
  io.n := io.instruction(11 downto 8).asUInt
  io.m := io.instruction(7 downto 4).asUInt
  io.disp4 := io.instruction(3 downto 0).asUInt
  io.disp8 := io.instruction(7 downto 0).asUInt
  io.disp12 := io.instruction(11 downto 0).asUInt
  io.immediate8 := io.instruction(7 downto 0).asUInt
}
