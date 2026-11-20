package j2.core.intc

import j2.core._
import j2.bus._
import j2.periph.{J2SCIF, J2WishboneToApb}
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import scala.collection.mutable
import scala.concurrent.duration._
import scala.sys.process._
import java.nio.file.{Files, Paths}

class J2BootUartIrqSpec extends munit.FunSuite {
  override val munitTimeout = 60.seconds

  class Probe(depth: Int) extends Component {
    val io = new Bundle {
      val instruction, data = master(J2Wishbone())
      val rx                = in Bool ()
    }
    val core =
      new J2WishboneCoreFixture(J2CoreConfig(exposeDebug = false), J2CorePlugins.apply _, true)
    val scif   = new J2SCIF(depth)
    val bridge = new J2WishboneToApb(J2Apb.config)
    io.instruction <> core.io.ibus
    scif.io.bus <> bridge.io.output
    scif.io.uart.rxd    := io.rx
    core.io.interrupts  := scif.io.interrupt ## B(0, 2 bits)
    core.io.nmi         := True
    core.io.event.valid := False
    core.io.event.payload.assignFromBits(B(0, core.io.event.payload.getBitsWidth bits))
    val b        = core.io.dbus
    val selected = b.ADR(31 downto 12) === U(0xff001, 20 bits)
    for ((target, choose) <- Seq(io.data -> !selected, bridge.io.input -> selected)) {
      target.CYC      := b.CYC && choose
      target.STB      := b.STB && choose
      target.ADR      := (if (target eq bridge.io.input) b.ADR & U(0xfffffffcL, 32 bits) else b.ADR)
      target.WE       := b.WE
      target.DAT_MOSI := b.DAT_MOSI
      target.SEL      := b.SEL
      target.LOCK     := b.LOCK
    }
    b.ACK      := Mux(selected, bridge.io.input.ACK, io.data.ACK)
    b.ERR      := Mux(selected, bridge.io.input.ERR, io.data.ERR)
    b.DAT_MISO := Mux(selected, bridge.io.input.DAT_MISO, io.data.DAT_MISO)
  }

  for ((depth, interrupts) <- Seq((0, true), (16, true), (4, false)))
    test(
      s"SCIF depth $depth receive driver interrupts=$interrupts handles overflow, errors and retry"
    ) {
      val out = Paths.get(s"../build/boot-uart-stress/$depth-$interrupts").toAbsolutePath.normalize
      Files.createDirectories(out)
      Files.writeString(
        out.resolve("j2_board_irqs.h"),
        "#define J2_INTC_SOURCE_COUNT 6\n#define J2_IRQ_SCIF_ERI 2\n#define J2_IRQ_SCIF_RXI 3\n#define J2_VECTOR_SCIF_ERI 66\n#define J2_VECTOR_SCIF_RXI 67\n#define J2_IRQ_SCIF_BRI 5\n#define J2_VECTOR_SCIF_BRI 69\n"
      )
      val prefix = Paths.get("../tools/local/sh-none-elf/bin/sh-none-elf-").toAbsolutePath.toString
      val elf    = out.resolve("main.elf").toString
      val bin    = out.resolve("main.bin")
      val receiveSources =
        if (interrupts) Seq("../sw/bootrom/test/irq_driver.c", "../sw/bootrom/test/uart_irq.c")
        else Seq("../sw/bootrom/test/uart_poll.c")
      assertEquals(
        (Seq(
          prefix + "gcc",
          "-m2",
          "-mb",
          "-Os",
          "-Wall",
          "-Wextra",
          "-Werror",
          "-ffreestanding",
          "-fno-builtin",
          "-nostdlib",
          (if (interrupts) "-DJ2_UART_RX_IRQ" else "-UJ2_UART_RX_IRQ"),
          "-DJ2_CLOCK_HZ=32000000",
          "-DJ2_UART_BAUD=125000",
          "-I../sw/include",
          s"-I$out",
          "-I../sw/bootrom",
          "-Wl,--defsym=J2_SRAM_BYTES=0x8000",
          "-T",
          "../sw/bootrom/boot.x",
          (if (interrupts) "../sw/bootrom/test/uart_irq_entry.S" else "../sw/bootrom/entry.S"),
          "../sw/bootrom/uart.c"
        ) ++ receiveSources ++ Seq(
          "-lgcc",
          "-o",
          elf
        )).!,
        0
      )
      assertEquals(Seq(prefix + "objcopy", "-O", "binary", elf, bin.toString).!, 0)
      SimConfig.withVerilator.compile(new Probe(depth)).doSim { dut =>
        val mem = mutable.Map.empty[Long, Int]
        Files.readAllBytes(bin).zipWithIndex.foreach { case (v, i) => mem(i.toLong) = v & 255 }
        def word(a: Long): Long =
          (0 until 4).foldLeft(0L)((v, i) => (v << 8) | mem.getOrElse(a + i, 0))
        def setWord(a: Long, value: Long): Unit = for (i <- 0 until 4)
          mem(a + i) = ((value >> (8 * (3 - i))) & 255).toInt
        dut.io.instruction.ACK      #= false; dut.io.instruction.ERR #= false;
        dut.io.instruction.DAT_MISO #= 0
        dut.io.data.ACK #= false; dut.io.data.ERR         #= false; dut.io.data.DAT_MISO #= 0
        dut.io.rx       #= true; dut.clockDomain.clockSim #= false
        def edge(): Unit = {
          dut.clockDomain.clockSim #= true; sleep(5)
          dut.clockDomain.clockSim #= false; sleep(5)
        }
        dut.clockDomain.assertReset(); for (_ <- 0 until 4) edge()
        dut.clockDomain.deassertReset(); sleep(1)
        var cycles = 0
        def tick(count: Int = 1): Unit = for (_ <- 0 until count) {
          dut.io.instruction.ACK #= dut.io.instruction.STB.toBoolean
          if (dut.io.instruction.STB.toBoolean)
            dut.io.instruction.DAT_MISO #= word(dut.io.instruction.ADR.toLong)
          dut.io.data.ACK               #= dut.io.data.STB.toBoolean
          if (dut.io.data.STB.toBoolean) {
            val a = dut.io.data.ADR.toLong & ~3L
            if (dut.io.data.WE.toBoolean) {
              val data = dut.io.data.DAT_MOSI.toLong
              val sel  = dut.io.data.SEL.toInt
              for (i <- 0 until 4 if (sel & (1 << (3 - i))) != 0)
                mem(a + i) = ((data >> (8 * (3 - i))) & 255).toInt
            }
            dut.io.data.DAT_MISO #= word(a)
          }
          edge(); cycles += 1
          assert(
            word(0x40000008L) == 0 || word(0x40000008L) == 0x600d,
            s"firmware failure ${word(0x40000008L)} at phase ${word(0x40000000L)}"
          )
        }
        def until(condition: => Boolean): Unit = {
          val limit = cycles + 300000
          while (!condition && cycles < limit) tick()
          assert(condition, s"firmware timeout at phase ${word(0x40000000L)}")
        }
        def send(value: Int, parity: Boolean = false): Unit = {
          dut.io.rx #= false; tick(256)
          for (bit <- 0 until 8) { dut.io.rx #= ((value >> bit) & 1) != 0; tick(256) }
          if (parity) {
            dut.io.rx #= (Integer.bitCount(value) % 2 == 0); tick(256)
          } // deliberately wrong even parity
          dut.io.rx #= true; tick(256)
        }
        until(word(0x40000000L) == 1)
        if (interrupts) {
          for (n <- 0 until 512) send(n & 255)
          tick(2000); setWord(0x40000004L, 1)
          until(word(0x40000000L) == 2)
          for (n <- 0 to depth.max(1)) send(0x31 + n)
          tick(2000); setWord(0x40000004L, 2)
          until(word(0x40000000L) == 3)
          send(0x55, parity = true); tick(2000); setWord(0x40000004L, 3)
          until(word(0x40000000L) == 4)
          for (n <- 0 until 8) send(0xa0 + n)
          tick(2000); setWord(0x40000004L, 4)
        } else {
          for (n <- 0 to depth) send(0x31 + n)
          tick(2000); setWord(0x40000004L, 1)
          until(word(0x40000000L) == 2)
          send(0x55, parity = true); tick(2000); setWord(0x40000004L, 2)
          until(word(0x40000000L) == 3)
          for (n <- 0 until 256) send(n & 255)
        }
        until(word(0x40000008L) == 0x600d)
      }
    }
}
