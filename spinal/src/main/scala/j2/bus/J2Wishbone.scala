package j2.bus

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._

object J2Wishbone {
  val config: WishboneConfig = WishboneConfig(
    addressWidth = 32,
    dataWidth = 32,
    selWidth = 4,
    useSTALL = true,
    useLOCK = true,
    useERR = true
  ).pipelined

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

  val dataRequest = io.data.CYC && io.data.STB
  val instructionRequest =
    io.instruction.CYC && io.instruction.STB && !io.instruction.WE
  val dataAddress = index(io.data)
  val instructionAddress = index(io.instruction)

  val dataAck = Reg(Bool()) init False
  val dataPending = Reg(Bool()) init False
  val dataResult = Reg(UInt(32 bits)) init 0
  val instructionAck = Reg(Bool()) init False
  val instructionPending = Reg(Bool()) init False
  val instructionData = Reg(UInt(32 bits)) init 0

  val dataReadData = memory.readSync(dataAddress, dataRequest)
  val instructionReadData =
    memory.readSync(instructionAddress, instructionRequest)
  val instructionHalfword =
    Mux(!io.instruction.ADR(1), instructionData(31 downto 16), instructionData(15 downto 0))
  memory.write(
    address = dataAddress,
    data = io.data.DAT_MOSI.asUInt,
    mask = io.data.SEL,
    enable = dataRequest && io.data.WE && !dataPending
  )

  when(ClockDomain.current.isResetActive) {
    dataAck := False
    dataPending := False
    instructionAck := False
    instructionPending := False
  } otherwise {
    dataAck := False
    when(dataRequest) {
      when(!dataPending) {
        dataPending := True
      } otherwise {
        dataResult := dataReadData
        dataAck := True
        dataPending := False
      }
    } otherwise {
      dataPending := False
    }
    instructionAck := False
    when(instructionRequest) {
      when(!instructionPending) {
        instructionPending := True
      } otherwise {
        instructionData := instructionReadData
        instructionAck := True
        instructionPending := False
      }
    } otherwise {
      instructionPending := False
    }
  }

  io.data.ACK := dataAck
  io.data.ERR := False
  io.data.STALL := False
  io.data.DAT_MISO := dataResult.asBits

  io.instruction.ACK := instructionAck
  io.instruction.ERR := False
  io.instruction.STALL := False
  io.instruction.DAT_MISO := instructionHalfword.resize(32).asBits
}
