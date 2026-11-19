package j2.periph

import j2.bus._
import spinal.core._
import spinal.lib._
import scala.io.Source

object J2RomData {
  def words(path: String): Seq[BigInt] = {
    val source = Source.fromFile(path)
    val values =
      try
        source.getLines().map(_.trim).filter(_.nonEmpty).map(line => BigInt(line, 16)).toVector
      finally source.close()
    require(values.length <= 8192, s"ROM contains ${values.length} words")
    values.padTo(8192, BigInt(0))
  }
}

final class J2Rom(initFile: String) extends Component {
  val io               = new Bundle { val bus = slave(J2Ahb.subordinate()) }
  private val endpoint = new J2AhbMemoryEndpoint
  endpoint.io.ahb <> io.bus
  private val memory = Mem(UInt(32 bits), 8192)
  memory.setTechnology(ramBlock)
  memory.initBigInt(J2RomData.words(initFile))
  private val port    = endpoint.io.memory
  private val pending = RegInit(False)
  port.cmd.ready := !pending
  private val data = memory.readSync(port.cmd.address(14 downto 2), port.cmd.fire)
  port.rsp.valid := pending
  port.rsp.data  := data.asBits
  port.rsp.error := False
  when(port.cmd.fire)(pending := True)
  when(port.rsp.fire)(pending := False)
}

final class J2Sram(sizeBytes: Int = 32768) extends Component {
  require(sizeBytes >= 8 && (sizeBytes & (sizeBytes - 1)) == 0)
  private val words    = sizeBytes / 4
  val io               = new Bundle { val bus = slave(J2Ahb.subordinate()) }
  private val endpoint = new J2AhbMemoryEndpoint
  endpoint.io.ahb <> io.bus
  private val port    = endpoint.io.memory
  private val pending = RegInit(False)
  port.cmd.ready := !pending
  // SRAM starts at 0x8000, which is not naturally aligned for sizes above 32 KiB.
  private val address = ((port.cmd.address - U(0x8000, 32 bits)) >> 2).resize(log2Up(words))
  private val banks   = Seq.fill(4)(Mem(Bits(8 bits), words))
  banks.foreach { bank =>
    bank.setTechnology(ramBlock)
    bank.initBigInt(Seq.fill(words)(BigInt(0)))
  }
  port.rsp.data := Cat(
    banks(3).readSync(address, port.cmd.fire),
    banks(2).readSync(address, port.cmd.fire),
    banks(1).readSync(address, port.cmd.fire),
    banks(0).readSync(address, port.cmd.fire)
  )
  for (index <- 0 until 4)
    banks(index).write(
      address,
      port.cmd.data(index * 8, 8 bits),
      port.cmd.fire && port.cmd.write && port.cmd.mask(index)
    )
  port.rsp.valid := pending
  port.rsp.error := False
  when(port.cmd.fire)(pending := True)
  when(port.rsp.fire)(pending := False)
}
