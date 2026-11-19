package j2.periph

import java.nio.charset.StandardCharsets
import java.nio.file.Files
import spinal.core.sim._
import scala.language.reflectiveCalls

class J2RomSpec extends munit.FunSuite {
  for (
    (name, contents) <- Seq(
      "zero image" -> Map.empty[Int, BigInt],
      "one word" -> Map(0 -> BigInt("12345678", 16)),
      "partial image" -> Map(0 -> BigInt("89abcdef", 16), 256 -> BigInt(1), 299 -> BigInt(2)),
      "full window" -> Map(0 -> BigInt(1), 8191 -> BigInt("fedcba98", 16))
    )
  )
    test(s"ROM $name preserves the entire window and synchronous response") {
      val file  = Files.createTempFile("j2-rom-", ".hex")
      val words = Vector.tabulate(8192)(i => contents.getOrElse(i, BigInt(0)))
      Files.write(file, words.map(w => f"$w%08x\n").mkString.getBytes(StandardCharsets.US_ASCII))
      try
        SimConfig.withVerilator.compile(new J2WishboneRom(file.toString)).doSim { dut =>
          val bus = dut.io.bus
          bus.ADR                  #= 0; bus.CYC     #= false; bus.STB   #= false
          bus.WE                   #= false; bus.SEL #= 15; bus.DAT_MOSI #= 0
          dut.clockDomain.clockSim #= false
          def edge(): Unit = {
            sleep(1); dut.clockDomain.clockSim #= true; sleep(5)
            dut.clockDomain.clockSim           #= false; sleep(5)
          }
          dut.clockDomain.assertReset(); edge(); edge()
          dut.clockDomain.deassertReset(); edge()
          var previous = words(0)
          // Visit every address, repeatedly crossing between stored data and the
          // zero tail. Changing the address must not change data before a clock.
          for (i <- 0 until 8192) {
            val index = (i * 4093) % 8192
            bus.ADR #= (index * 4); bus.CYC #= true; bus.STB #= true
            // ROM writes remain acknowledged but never modify its contents.
            bus.WE #= ((i & 1) != 0); bus.DAT_MOSI #= 0xffffffffL
            sleep(1)
            assertEquals(bus.DAT_MISO.toBigInt, previous)
            assert(!bus.ACK.toBoolean)
            edge()
            assert(bus.ACK.toBoolean && !bus.ERR.toBoolean)
            assertEquals(bus.DAT_MISO.toBigInt, words(index), s"word $index")
            previous = words(index)
            bus.CYC #= false; bus.STB #= false; edge()
          }
          // Revisit the words after attempted writes, also catching an
          // accidental read-before-write RAM implementation.
          bus.WE #= false
          for (index <- 0 until 8192) {
            bus.ADR #= (index * 4); edge()
            assertEquals(bus.DAT_MISO.toBigInt, words(index), s"readback word $index")
          }
        }
      finally Files.deleteIfExists(file)
    }
}
