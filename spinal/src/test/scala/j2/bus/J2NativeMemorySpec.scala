package j2.bus

import j2.periph._
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import java.nio.file.Files
import j2.bus.ahb5.Ahb5SubordinateDecoder
import spinal.lib.bus.misc.SizeMapping

final class SizedSramFixture(size: Int) extends Component {
  val io      = new Bundle { val bus = slave(J2Ahb.subordinate()) }
  val decoder = new Ahb5SubordinateDecoder(J2Ahb.config, Seq(SizeMapping(0x8000, size)))
  val sram    = new J2Sram(size)
  decoder.io.input <> io.bus
  sram.io.bus <> decoder.io.outputs(0)
}

class J2NativeMemorySpec extends munit.FunSuite {
  test("configurable SRAM window and storage agree below and above 32 KiB") {
    for (size <- Seq(8192, 65536))
      SimConfig.withVerilator.compile(new SizedSramFixture(size)).doSim { dut =>
        dut.clockDomain.clockSim #= false
        def edge(): Unit = {
          dut.clockDomain.clockSim #= true; sleep(5)
          dut.clockDomain.clockSim #= false; sleep(5)
        }
        val master = new AhbMemoryDriver(dut.io.bus, () => edge())
        master.init(); dut.clockDomain.assertReset(); edge(); edge()
        dut.clockDomain.deassertReset(); sleep(1)
        val addresses = Seq(0x8000, 0x8000 + size / 2, 0x8000 + size - 4)
        for ((address, i) <- addresses.zipWithIndex) master.access(address, true, 0x12345670 + i)
        for ((address, i) <- addresses.zipWithIndex)
          assertEquals(master.access(address), BigInt(0x12345670 + i))
        master.access(0x7ffc, error        = true)
        master.access(0x8000 + size, error = true)
      }
  }
  test("native SRAM BE32 lanes, phase ownership, illegal sizes and back-to-back beats") {
    SimConfig.withVerilator.compile(new J2Sram).doSim { dut =>
      dut.clockDomain.clockSim #= false
      def edge(): Unit = {
        dut.clockDomain.clockSim #= true; sleep(5)
        dut.clockDomain.clockSim #= false; sleep(5)
      }
      val master = new AhbMemoryDriver(dut.io.bus, () => edge())
      master.init(); dut.clockDomain.assertReset(); edge(); edge()
      dut.clockDomain.deassertReset(); sleep(1)
      val b = dut.io.bus
      for (size <- 0 to 2; offset <- 0 until 4 by (1 << size)) {
        master.access(0x8100, true, 0x11223344L)
        master.access(0x8100 + offset, true, 0xaabbccddL, size)
        val mask     = ((BigInt(1) << (8 * (1 << size))) - 1) << ((4 - offset - (1 << size)) * 8)
        val expected = (BigInt(0x11223344L) & ~mask) | (BigInt(0xaabbccddL) & mask)
        assertEquals(master.access(0x8100), expected)
      }
      for ((address, size) <- Seq((0x8101, 1), (0x8102, 2), (0x8100, 3))) {
        val before = master.access(0x8100)
        master.access(address, true, 0, size, error = true)
        assertEquals(master.access(0x8100), before)
      }
      // HSEL and HREADY both gate admission; IDLE/BUSY never write.
      master.access(0x8200, true, 0x12345678)
      b.address.HADDR                  #= 0x8200; b.address.HWRITE #= true; b.HWDATA #= 0
      b.HSEL                           #= true; b.address.HTRANS   #= 2; b.HREADY    #= false
      edge(); edge(); b.address.HTRANS #= 0; master.tick()
      for (trans <- Seq(0, 1)) { b.address.HTRANS #= trans; master.tick() }
      b.HSEL #= false; b.address.HTRANS #= 2; master.tick(); b.address.HTRANS #= 0
      assertEquals(master.access(0x8200), BigInt(0x12345678))
      // Present the next address on the previous data completion edge.
      master.start(0x8200)
      while (!b.HREADYOUT.toBoolean) master.tick()
      assertEquals(b.HRDATA.toBigInt, BigInt(0x12345678))
      b.HSEL                #= true; b.address.HTRANS  #= 3; b.address.HADDR #= 0x8204
      b.address.HWRITE      #= true; b.address.HSIZE   #= 2; b.HWDATA        #= 0xdeadbeefL
      master.tick(); b.HSEL #= false; b.address.HTRANS #= 0; b.HWDATA        #= 0x87654321L
      master.finish()
      assertEquals(master.access(0x8204), BigInt(0x87654321L))
    }
  }

  test("native ROM retains its full window, synchronous response and ignored writes") {
    val file = Files.createTempFile("ahb-rom-", ".hex")
    val contents =
      Vector.tabulate(8192)(i => if (i == 0 || i == 8191) BigInt(0x12345678L + i) else BigInt(0))
    Files.writeString(file, contents.map(w => f"$w%08x\n").mkString)
    try
      SimConfig.withVerilator.compile(new J2Rom(file.toString)).doSim { dut =>
        dut.clockDomain.clockSim #= false
        def edge(): Unit = {
          dut.clockDomain.clockSim #= true; sleep(5); dut.clockDomain.clockSim #= false; sleep(5)
        }
        val master = new AhbMemoryDriver(dut.io.bus, () => edge())
        master.init(); dut.clockDomain.assertReset(); edge(); edge();
        dut.clockDomain.deassertReset()
        for (i <- 0 until 8192) {
          master.access(i * 4, true, 0xffffffffL)
          assertEquals(master.access(i * 4), contents(i))
        }
      }
    finally Files.deleteIfExists(file)
  }
}
