package j2.soc

import spinal.core._
import spinal.core.sim._

import scala.language.reflectiveCalls

class J2SocSimSpec extends munit.FunSuite {
  private def pokeHalf(words: Array[BigInt], address: Int, value: Int): Unit = {
    val index = (address >>> 2) & (words.length - 1)
    words(index) = if ((address & 2) == 0) {
      (words(index) & 0xffff) | (BigInt(value & 0xffff) << 16)
    } else {
      (words(index) & (BigInt(0xffff) << 16)) | BigInt(value & 0xffff)
    }
  }

  private def pokeWord(words: Array[BigInt], address: Int, value: Long): Unit =
    words((address >>> 2) & (words.length - 1)) = BigInt(value & 0xffffffffL)

  test("core boots from internal BRAM and reaches an external Wishbone slave") {
    val init = Array.fill[BigInt](1024)(BigInt(0))
    pokeWord(init, 0x0000, 0x00000100L)
    pokeWord(init, 0x0004, 0x00000800L)

    pokeHalf(init, 0x0100, 0xe101) // mov #1,r1
    pokeHalf(init, 0x0102, 0xe202) // mov #2,r2
    pokeHalf(init, 0x0104, 0xd302) // mov.l @(2,pc),r3
    pokeHalf(init, 0x0106, 0x312c) // add r2,r1
    pokeHalf(init, 0x0108, 0x2312) // mov.l r1,@r3
    pokeHalf(init, 0x010a, 0xaffe) // bra 0x10a
    pokeHalf(init, 0x010c, 0x0009) // delay-slot nop
    pokeWord(init, 0x0110, 0x00001000L)

    SimConfig.withVerilator
      .compile(new J2Soc(ramWords = 1024, ramInit = init.toSeq))
      .doSim { dut =>
        dut.io.external.ACK #= false
        dut.io.external.ERR #= false
        dut.io.external.DAT_MISO #= 0
        dut.io.uartRx #= true
        dut.io.pioIn #= 0
        dut.io.event.valid #= false
        dut.io.event.payload.command #= 0
        dut.io.event.payload.vector #= 0
        dut.io.event.payload.level #= 0
        dut.io.event.payload.bypassMask #= false

        def tick(): Unit = {
          dut.clockDomain.clockSim #= false
          sleep(5)
          dut.clockDomain.clockSim #= true
          sleep(5)
          dut.clockDomain.clockSim #= false
          sleep(1)
        }
        dut.clockDomain.clockSim #= false
        dut.clockDomain.assertReset()
        for (_ <- 0 until 4) tick()
        dut.clockDomain.deassertReset()
        sleep(1)

        var retired = 0
        var cycles = 0
        var externalWrite = Option.empty[(Long, Long)]

        while (retired < 8 && cycles < 300) {
          if (dut.io.external.CYC.toBoolean && dut.io.external.STB.toBoolean) {
            if (dut.io.external.WE.toBoolean) {
              externalWrite = Some(
                dut.io.external.ADR.toLong -> dut.io.external.DAT_MOSI.toLong
              )
            }
            dut.io.external.DAT_MISO #= 0
            dut.io.external.ACK #= true
          } else {
            dut.io.external.ACK #= false
          }
          tick()
          cycles += 1
          if (dut.io.retired.toBoolean) retired += 1
        }

        assert(retired == 8, s"SoC retired only $retired instructions in $cycles cycles")
        assertEquals(
          externalWrite,
          Some(0x1000L -> 3L),
          s"final PC was 0x${dut.io.pc.toLong.toHexString}"
        )
        assertEquals(dut.io.pc.toLong, 0x10aL)
      }
  }
}
