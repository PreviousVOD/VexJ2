package j2.bus

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._

object J2Wishbone {
  val config: WishboneConfig = WishboneConfig(
    addressWidth = 32,
    dataWidth = 32,
    selWidth = 4,
    useSTALL = false,
    useLOCK = true,
    useERR = true
  )

  def apply(): Wishbone = Wishbone(config)
}

final class J2WbRam(
    val words: Int = 8192,
    val init: Seq[BigInt] = Seq.empty
) extends Component {
  require(words > 0 && (words & (words - 1)) == 0)
  require(init.length <= words)

  val io = new Bundle {
    val data = slave(J2Wishbone())
    val instruction = slave(J2Wishbone())
  }

  private val addressBits = log2Up(words)
  private val memory = Mem(UInt(32 bits), words)
  if (init.nonEmpty) {
    memory.initBigInt(init.padTo(words, BigInt(0)))
  }

  private def index(bus: Wishbone): UInt = bus.ADR(addressBits + 1 downto 2)

  private val dataCycle = new J2WbClassicCycle(io.data)
  private val instructionCycle = new J2WbClassicCycle(io.instruction, !io.instruction.WE)
  private val dataAddress = index(io.data)
  private val instructionAddress = index(io.instruction)
  private val dataResult = Reg(UInt(32 bits)) init 0
  private val instructionData = Reg(UInt(32 bits)) init 0

  private val dataReadData = memory.readSync(dataAddress, dataCycle.request)
  private val instructionReadData =
    memory.readSync(instructionAddress, instructionCycle.request)
  private val instructionHalfword =
    Mux(!io.instruction.ADR(1), instructionData(31 downto 16), instructionData(15 downto 0))
  memory.write(
    address = dataAddress,
    data = io.data.DAT_MOSI.asUInt,
    mask = io.data.SEL,
    enable = dataCycle.start && io.data.WE
  )

  when(dataCycle.complete) {
    dataResult := dataReadData
  }
  when(instructionCycle.complete) {
    instructionData := instructionReadData
  }

  io.data.ERR := False
  io.data.DAT_MISO := dataResult.asBits

  io.instruction.ERR := False
  io.instruction.DAT_MISO := instructionHalfword.resize(32).asBits
}
