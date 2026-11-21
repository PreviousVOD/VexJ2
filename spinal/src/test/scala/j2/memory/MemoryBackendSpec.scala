package j2.memory

import j2.vendor.anlogic.Eg4MemoryBackend
import j2.vendor.xilinx.XilinxMemoryBackend
import java.nio.file.Files
import scala.jdk.CollectionConverters._
import spinal.core._

class MemoryBackendSpec extends munit.FunSuite {
  private val words = Vector.tabulate(256)(i => (BigInt(i) << 64) | BigInt(i * 0x10203L))

  private class Probe(async: Boolean = false) extends Component {
    val io = new Bundle {
      val address       = in UInt (8 bits)
      val enable, write = in Bool ()
      val data          = in Bits (8 bits)
      val rom           = out Bits (72 bits)
      val ram           = out Bits (8 bits)
    }
    val rom = Mem(Bits(72 bits), 256)
    rom.setTechnology(ramBlock)
    rom.initBigInt(words)
    io.rom := (if (async) rom.readAsync(io.address) else rom.readSync(io.address, io.enable))
    val ram = Mem(Bits(8 bits), 256)
    ram.setTechnology(ramBlock)
    ram.initBigInt(Seq.fill(256)(BigInt(0)))
    ram.write(io.address, io.data, io.write)
    io.ram := ram.readSync(io.address)
  }

  test("generation policy preserves ROM contents and keeps writable RAM inferred") {
    // Inferred is deliberately last: backend policy must not leak into later elaborations.
    for (backend <- Seq(Eg4MemoryBackend, XilinxMemoryBackend, MemoryBackend.Inferred)) {
      val directory = Files.createTempDirectory("memory-backend-")
      backend
        .configure(SpinalConfig(targetDirectory = directory.toString))
        .generateVerilog(new Probe)
      val rtl   = Files.readString(directory.resolve("Probe.v"))
      val files = Files.list(directory)
      val mifs =
        try files.iterator().asScala.filter(_.toString.endsWith(".mif")).toVector
        finally files.close()
      backend match {
        case Eg4MemoryBackend =>
          assert(rtl.contains("EG_LOGIC_BRAM"))
          assert(rtl.replaceAll("\\s", "").contains(".DATA_WIDTH_A(72)"))
          assert(rtl.replaceAll("\\s", "").contains(".DATA_DEPTH_A(256)"))
          assert(rtl.replaceAll("\\s", "").contains(".IMPLEMENT(\"32K\")"))
          assert(rtl.contains("reg [7:0] ram [0:255]"))
          assertEquals(mifs.size, 1)
          val entry = "(?m)^([0-9a-f]+) : ([0-9a-f]+);$".r
          val image = entry
            .findAllMatchIn(Files.readString(mifs.head))
            .map { m =>
              Integer.parseInt(m.group(1), 16) -> BigInt(m.group(2), 16)
            }
            .toVector
          assertEquals(image, words.zipWithIndex.map { case (word, index) => index -> word })
          assert(rtl.contains(mifs.head.getFileName.toString))
        case XilinxMemoryBackend =>
          assertEquals("ram_style = \"block\"".r.findAllIn(rtl).length, 2)
          assert(!rtl.contains("EG_LOGIC_BRAM"))
          assert(mifs.isEmpty)
        case MemoryBackend.Inferred =>
          assert(!rtl.contains("ram_style") && !rtl.contains("EG_LOGIC_BRAM"))
          assert(mifs.isEmpty)
        case other => fail(s"Unexpected backend: $other")
      }
    }
  }

  test("EG4 backend rejects an asynchronous block ROM instead of changing its latency") {
    val directory = Files.createTempDirectory("memory-backend-invalid-")
    val error = intercept[Exception] {
      Eg4MemoryBackend
        .configure(SpinalConfig(targetDirectory = directory.toString))
        .generateVerilog(new Probe(async = true))
    }
    assert(error.toString.contains("one synchronous read port"), error.toString)
  }
}
