package j2.core

import spinal.core._
import spinal.core.sim._

import scala.language.reflectiveCalls

class J2CoreSimSpec extends munit.FunSuite {
  private def wordIndex(address: Long): Int = ((address >>> 2) & 0x3ff).toInt

  private def pokeHalf(words: Array[Long], address: Long, value: Long): Unit = {
    val index = wordIndex(address)
    words(index) = if ((address & 2) == 0) {
      (words(index) & 0x0000ffffL) | ((value & 0xffffL) << 16)
    } else {
      (words(index) & 0xffff0000L) | (value & 0xffffL)
    }
  }

  private def pokeWord(words: Array[Long], address: Long, value: Long): Unit =
    words(wordIndex(address)) = value & 0xffffffffL

  private def maskedWrite(
      words: Array[Long],
      address: Long,
      select: Long,
      data: Long
  ): Unit = {
    val index = wordIndex(address)
    var word = words(index)
    for (lane <- 0 until 4)
      if ((select & (1L << (3 - lane))) != 0) {
        val shift = lane * 8
        val mask = 0xffL << shift
        word = (word & ~mask) | ((data >>> shift) & mask)
      }
    words(index) = word & 0xffffffffL
  }

  test("reset vector, ALU, literal load, store and delayed branch") {
    SimConfig.withVerilator.compile(new J2Core).doSim { dut =>
      val words = Array.fill[Long](1024)(0L)

      pokeWord(words, 0x0000, 0x00000100L)
      pokeWord(words, 0x0004, 0x00000800L)

      pokeHalf(words, 0x0100, 0xe101L) // mov #1,r1
      pokeHalf(words, 0x0102, 0xe202L) // mov #2,r2
      pokeHalf(words, 0x0104, 0xd302L) // mov.l @(2,pc),r3
      pokeHalf(words, 0x0106, 0x312cL) // add r2,r1
      pokeHalf(words, 0x0108, 0x2312L) // mov.l r1,@r3
      pokeHalf(words, 0x010a, 0xaffeL) // bra 0x10a
      pokeHalf(words, 0x010c, 0x0009L) // delay-slot nop
      pokeWord(words, 0x0110, 0x00000400L)

      dut.clockDomain.forkStimulus(10)
      dut.io.ibus.ACK #= false
      dut.io.ibus.ERR #= false
      dut.io.ibus.DAT_MISO #= 0
      dut.io.dbus.ACK #= false
      dut.io.dbus.ERR #= false
      dut.io.dbus.DAT_MISO #= 0
      dut.io.event.valid #= false
      dut.io.event.payload.command #= 0
      dut.io.event.payload.vector #= 0
      dut.io.event.payload.level #= 0
      dut.io.event.payload.bypassMask #= false

      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()
      dut.clockDomain.waitSampling()

      var retired = 0
      var cycles = 0
      while (retired < 8 && cycles < 300) {
        if (dut.io.ibus.CYC.toBoolean && dut.io.ibus.STB.toBoolean) {
          val logicalAddress = dut.io.ibus.ADR.toLong
          val address = logicalAddress & ~3L
          val word = words(wordIndex(address))
          dut.io.ibus.DAT_MISO #=
            (if ((logicalAddress & 2) == 0) (word >>> 16) & 0xffffL else word & 0xffffL)
          dut.io.ibus.ACK #= true
        } else {
          dut.io.ibus.ACK #= false
        }
        if (dut.io.dbus.CYC.toBoolean && dut.io.dbus.STB.toBoolean) {
          val address = dut.io.dbus.ADR.toLong & ~3L
          if (dut.io.dbus.WE.toBoolean) {
            maskedWrite(words, address, dut.io.dbus.SEL.toLong, dut.io.dbus.DAT_MOSI.toLong)
          }
          dut.io.dbus.DAT_MISO #= words(wordIndex(address))
          dut.io.dbus.ACK #= true
        } else {
          dut.io.dbus.ACK #= false
        }
        sleep(1)
        dut.clockDomain.waitSampling()
        cycles += 1
        if (dut.io.retired.toBoolean) retired += 1
      }

      assert(retired == 8, s"core retired only $retired instructions in $cycles cycles")
      assertEquals(words(wordIndex(0x400)), 3L)
      assertEquals(dut.io.pc.toLong, 0x10aL)
    }
  }

  test("BGND raises the debug-break pulse and retires") {
    SimConfig.withVerilator.compile(new J2Core).doSim { dut =>
      val words = Array.fill[Long](1024)(0L)

      pokeWord(words, 0x0000, 0x00000100L)
      pokeWord(words, 0x0004, 0x00000800L)
      pokeHalf(words, 0x0100, 0x003bL) // bgnd

      dut.clockDomain.forkStimulus(10)
      dut.io.ibus.ACK #= false
      dut.io.ibus.ERR #= false
      dut.io.ibus.DAT_MISO #= 0
      dut.io.dbus.ACK #= false
      dut.io.dbus.ERR #= false
      dut.io.dbus.DAT_MISO #= 0
      dut.io.event.valid #= false
      dut.io.event.payload.command #= 0
      dut.io.event.payload.vector #= 0
      dut.io.event.payload.level #= 0
      dut.io.event.payload.bypassMask #= false

      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()
      dut.clockDomain.waitSampling()

      var sawBreak = false
      var retired = false
      var cycles = 0
      while (!retired && cycles < 100) {
        if (dut.io.ibus.CYC.toBoolean && dut.io.ibus.STB.toBoolean) {
          val logicalAddress = dut.io.ibus.ADR.toLong
          val address = logicalAddress & ~3L
          val word = words(wordIndex(address))
          dut.io.ibus.DAT_MISO #=
            (if ((logicalAddress & 2) == 0) (word >>> 16) & 0xffffL else word & 0xffffL)
          dut.io.ibus.ACK #= true
        } else {
          dut.io.ibus.ACK #= false
        }
        if (dut.io.dbus.CYC.toBoolean && dut.io.dbus.STB.toBoolean) {
          val address = dut.io.dbus.ADR.toLong & ~3L
          dut.io.dbus.DAT_MISO #= words(wordIndex(address))
          dut.io.dbus.ACK #= true
        } else {
          dut.io.dbus.ACK #= false
        }
        sleep(1)
        dut.clockDomain.waitSampling()
        sawBreak ||= dut.io.debugBreak.toBoolean
        retired ||= dut.io.retired.toBoolean
        cycles += 1
      }

      assert(
        sawBreak,
        s"BGND did not assert debugBreak: pc=0x${dut.io.pc.toLong.toHexString} " +
          s"op=0x${dut.io.debugOpcode.toLong.toHexString} state=${dut.io.debugState.toLong} " +
          s"retired=$retired cycles=$cycles"
      )
      assert(retired, s"BGND did not retire in $cycles cycles")
      dut.clockDomain.waitSampling()
      assertEquals(dut.io.pc.toLong, 0x102L)
    }
  }

  test("TAS preserves a continuous locked cycle across delayed transfers") {
    SimConfig.withVerilator.compile(new J2Core).doSim { dut =>
      val words = Array.fill[Long](1024)(0L)

      pokeWord(words, 0x0000, 0x00000100L)
      pokeWord(words, 0x0004, 0x00000800L)
      pokeHalf(words, 0x0100, 0xd102L) // mov.l @(2,pc),r1
      pokeHalf(words, 0x0102, 0x411bL) // tas.b @r1
      pokeHalf(words, 0x0104, 0xaffeL) // bra 0x104
      pokeHalf(words, 0x0106, 0x0009L) // delay-slot nop
      pokeWord(words, 0x010c, 0x00000400L)

      dut.clockDomain.forkStimulus(10)
      dut.io.ibus.ACK #= false
      dut.io.ibus.ERR #= false
      dut.io.ibus.DAT_MISO #= 0
      dut.io.dbus.ACK #= false
      dut.io.dbus.ERR #= false
      dut.io.dbus.DAT_MISO #= 0
      dut.io.event.valid #= false
      dut.io.event.payload.command #= 0
      dut.io.event.payload.vector #= 0
      dut.io.event.payload.level #= 0
      dut.io.event.payload.bypassMask #= false

      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()
      dut.clockDomain.waitSampling()

      var retired = 0
      var cycles = 0
      var dataPending = false
      var dataDelay = 0
      var dataTransfers = 0
      var sawAtomicGap = false
      var sawAtomicEnd = false

      while (retired < 2 && cycles < 100) {
        if (dut.io.ibus.CYC.toBoolean && dut.io.ibus.STB.toBoolean) {
          val logicalAddress = dut.io.ibus.ADR.toLong
          val word = words(wordIndex(logicalAddress))
          dut.io.ibus.DAT_MISO #=
            (if ((logicalAddress & 2) == 0) (word >>> 16) & 0xffffL else word & 0xffffL)
          dut.io.ibus.ACK #= true
        } else {
          dut.io.ibus.ACK #= false
        }

        if (dut.io.dbus.LOCK.toBoolean) {
          assert(dut.io.dbus.CYC.toBoolean, "LOCK asserted without CYC")
          if (!dut.io.dbus.STB.toBoolean) sawAtomicGap = true
        }
        if (sawAtomicGap && !dut.io.dbus.CYC.toBoolean) sawAtomicEnd = true

        dut.io.dbus.ACK #= false
        if (dut.io.dbus.CYC.toBoolean && dut.io.dbus.STB.toBoolean) {
          if (!dataPending) {
            dataPending = true
            dataDelay = 1
          } else if (dataDelay > 0) {
            dataDelay -= 1
          } else {
            val address = dut.io.dbus.ADR.toLong
            dut.io.dbus.DAT_MISO #= words(wordIndex(address))
            if (dut.io.dbus.WE.toBoolean) {
              maskedWrite(words, address, dut.io.dbus.SEL.toLong, dut.io.dbus.DAT_MOSI.toLong)
            }
            dut.io.dbus.ACK #= true
            dataPending = false
            if (dut.io.dbus.LOCK.toBoolean) dataTransfers += 1
          }
        } else if (!dut.io.dbus.CYC.toBoolean) {
          dataPending = false
        }

        sleep(1)
        dut.clockDomain.waitSampling()
        cycles += 1
        if (dut.io.retired.toBoolean) retired += 1
      }
      dut.clockDomain.waitSampling()
      if (sawAtomicGap && !dut.io.dbus.CYC.toBoolean) sawAtomicEnd = true

      assertEquals(retired, 2)
      assertEquals(dataTransfers, 2)
      assert(sawAtomicGap, "TAS did not have a locked inter-transfer gap")
      assert(sawAtomicEnd, "TAS did not release CYC and LOCK after completion")
      assertEquals(words(wordIndex(0x400)), 0x80L)
    }
  }
}
