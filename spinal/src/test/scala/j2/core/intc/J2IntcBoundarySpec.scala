package j2.core.intc

import j2.core._
import spinal.core._
import spinal.core.sim._
import scala.collection.mutable
import scala.sys.process._
import java.nio.file.{Files, Paths}

class J2IntcBoundarySpec extends munit.FunSuite {
  test("real INTC nesting, RTE retrigger, SR writes, delay slots and TAS preserve boundaries") {
    val out = Paths.get("../build/intc-boundaries").toAbsolutePath.normalize
    Files.createDirectories(out)
    val prefix = Paths.get("../tools/local/sh-none-elf/bin/sh-none-elf-").toAbsolutePath.toString
    val programs = (1 to 9).map { mode =>
      val elf = out.resolve(s"case-$mode.elf").toString
      val bin = out.resolve(s"case-$mode.bin")
      assertEquals(
        Seq(
          prefix + "gcc",
          "-m2",
          "-mb",
          "-nostdlib",
          s"-DCASE=$mode",
          "-Wl,-Ttext=0",
          "-Wl,--entry=start",
          "src/test/resources/intc-boundaries.S",
          "-o",
          elf
        ).!,
        0
      )
      assertEquals(Seq(prefix + "objcopy", "-O", "binary", "-j", ".text", elf, bin.toString).!, 0)
      val symbols = (Seq(prefix + "nm", elf).!!).linesIterator.flatMap { line =>
        val p = line.trim.split("\\s+")
        if (p.length == 3) Some(p(2) -> java.lang.Long.parseLong(p(0), 16)) else None
      }.toMap
      (mode, (Files.readAllBytes(bin), symbols))
    }.toMap
    val raisePcs = mutable.Map(4 -> mutable.Set.empty[Long], 5 -> mutable.Set.empty[Long])
    for (debug <- Seq(false, true)) {
      val compiled = SimConfig.withVerilator.compile(
        new J2WishboneCoreFixture(J2CoreConfig(exposeDebug = debug), J2CorePlugins.apply _, true)
      )
      for (
        mode <- 1 to 9; latency <- Seq(0, 4);
        arrival <- (if (mode == 4 || mode == 5) (0 to 10) else Seq(0))
      )
        compiled.doSim(s"case-$mode-wait-$latency-arrival-$arrival") { dut =>
          val (bytes, symbols) = programs(mode)
          val mem              = mutable.Map.empty[Long, Int]
          bytes.zipWithIndex.foreach { case (v, i) => mem(i.toLong) = v & 255 }
          def word(a: Long): Long =
            (0 until 4).foldLeft(0L)((v, i) => (v << 8) | mem.getOrElse(a + i, 0))
          val reads  = mutable.ArrayBuffer.empty[Long]
          val writes = mutable.ArrayBuffer.empty[(Long, Long)]
          val frames = mutable.ArrayBuffer.empty[(Long, Long)]
          dut.io.ibus.ACK #= false; dut.io.ibus.ERR #= false; dut.io.ibus.DAT_MISO #= 0
          dut.io.dbus.ACK #= false; dut.io.dbus.ERR #= false; dut.io.dbus.DAT_MISO #= 0
          dut.io.event.valid              #= false; dut.io.event.payload.command #= 0
          dut.io.event.payload.vector     #= 0; dut.io.event.payload.level       #= 0
          dut.io.event.payload.bypassMask #= false
          dut.io.interrupts #= 0; dut.io.nmi #= true; dut.clockDomain.clockSim #= false
          def edge(): Unit = {
            dut.clockDomain.clockSim #= true; sleep(5)
            dut.clockDomain.clockSim #= false; sleep(5)
          }
          dut.clockDomain.assertReset(); for (_ <- 0 until 4) edge()
          dut.clockDomain.deassertReset(); sleep(1)
          var iw       = 0; var dw   = 0; var ticks        = 0; var triggered = false
          var raisedAt = -1; var arm = false; var highSent = false
          while (word(0x628) == 0 && ticks < 12000) {
            dut.io.ibus.ACK #= false; dut.io.dbus.ACK #= false
            if (dut.io.ibus.STB.toBoolean) {
              val address = dut.io.ibus.ADR.toLong
              if (
                mode == 4 && arm && !triggered && address == (symbols(
                  "boundary"
                ) & ~3L) && raisedAt < 0
              )
                raisedAt = ticks + arrival
              if (iw == latency) {
                dut.io.ibus.DAT_MISO #= word(address)
                dut.io.ibus.ACK      #= true; iw = 0
              } else iw += 1
            }
            if (dut.io.dbus.STB.toBoolean) {
              val a  = dut.io.dbus.ADR.toLong
              val wr = dut.io.dbus.WE.toBoolean
              if (mode == 9 && a == 0x704)
                assert(dut.io.dbus.LOCK.toBoolean, "TAS must retain its lock")
              if (
                !triggered && raisedAt < 0 &&
                ((mode == 5 && a == 0x700 && !wr) || (mode == 8 && a == 0x608 && wr) ||
                  (mode == 9 && a == 0x704 && !wr))
              ) raisedAt = ticks + arrival
              if (dw == latency + 1) {
                if (wr) {
                  val value = dut.io.dbus.DAT_MOSI.toLong
                  val sel   = dut.io.dbus.SEL.toInt
                  for (i <- 0 until 4 if (sel & (1 << (3 - i))) != 0)
                    mem((a & ~3L) + i) = ((value >> (8 * (3 - i))) & 255).toInt
                  writes += ((a, value))
                  if (a == 0x600) {
                    arm                                    = true
                    if (Set(1, 2, 3, 6, 7)(mode)) raisedAt = ticks
                  }
                  if (mode == 9 && a == 0x8ffc)
                    assertEquals(mem(0x704), 128, "TAS must finish before stacking SR")
                  if (a == 0x8ff8) frames += ((value, word(0x8ffc)))
                  if (a == 0x630) {
                    if (mode == 1 || mode == 2) {
                      dut.io.interrupts #= 0
                      if (!highSent) {
                        if (mode == 1) dut.io.interrupts #= 2 else dut.io.nmi #= false
                        highSent = true
                      }
                    } else if (mode != 3 || value == 2) dut.io.interrupts #= 0
                  }
                  if (a == 0x618) dut.io.interrupts #= 0
                } else {
                  reads += a
                  if (a == 0x100 || a == 0x104 || a == 0x2c) {
                    if (mode == 8)
                      assertEquals(word(0x608), 0x35L, "delay-slot store must precede entry")
                    if (mode == 9) assertEquals(mem(0x704), 128, "TAS write must precede entry")
                  }
                }
                dut.io.dbus.DAT_MISO #= word(a & ~3L)
                dut.io.dbus.ACK      #= true; dw = 0
              } else dw += 1
            }
            if (!triggered && raisedAt >= 0 && ticks >= raisedAt) {
              dut.io.interrupts #= 1; triggered = true
            }
            edge(); ticks += 1
          }
          assert(triggered, "test must assert an IRQ")
          assertEquals(word(0x628), 0x77L, s"case $mode must resume; frames=$frames reads=$reads")
          assertEquals(word(0x630), if (mode == 3) 2L else 1L)
          assertEquals(reads.count(_ == 0x100), if (mode == 3) 2 else 1)
          assertEquals(word(0x60c) & 0xf0, 0x60L)
          assert(
            frames.forall { case (_, sr) => (sr & 0xf0) < 0x60 },
            s"IRQ accepted with masked saved SR: $frames"
          )
          if (mode == 1 || mode == 2) {
            assert(highSent)
            assertEquals(
              reads.filter(a => a == 0x100 || a == 0x104 || a == 0x2c).toSeq,
              Seq(0x100L, if (mode == 1) 0x104L else 0x2cL)
            )
            assertEquals(word(0x61c) & 0xf0, if (mode == 1) 0xa0L else 0xf0L)
            assertEquals(
              word(0x624) & 0xf0,
              0x60L,
              "nested frame must preserve interrupted handler mask"
            )
            assert(
              Set(0L, 2L, 4L).map(_ + symbols("low_wait"))(word(0x620)),
              "nested RTE must resume an instruction in the low handler wait loop"
            )
          }
          if (mode == 4 || mode == 5) {
            assertEquals(word(0x634) & 0xf0, 0xf0L)
            raisePcs(mode) ++= frames.map(_._1)
          }
          if (mode == 8) {
            assert(frames.forall(_._1 >= symbols("branch_target")))
            assertEquals(writes.count(_._1 == 0x608), 1)
          }
          if (mode == 9) assertEquals(word(0x614) & 1, 1L, "TAS T flag must survive IRQ/RTE")
        }
    }
    assert(
      raisePcs(4).exists(_ <= programs(4)._2("boundary")),
      s"LDC sweep missed pre-write acceptance: $raisePcs"
    )
    assert(
      raisePcs(4).exists(_ >= programs(4)._2("unmasked")),
      s"LDC sweep missed post-unmask acceptance: $raisePcs"
    )
    assert(
      raisePcs(5).forall(_ >= programs(5)._2("unmasked")),
      s"LDC.L must finish its mask update before accepting: $raisePcs"
    )

  }
}
