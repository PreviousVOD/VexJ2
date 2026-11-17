package j2.bus

import spinal.core._
import spinal.core.sim._
import scala.collection.mutable.ArrayBuffer

class J2ReadCacheWindowSpec extends munit.FunSuite {
  test("cache configuration rejects invalid geometry and unsafe refill windows") {
    intercept[IllegalArgumentException](J2ReadCacheConfig(cacheBytes = 192))
    intercept[IllegalArgumentException](J2ReadCacheConfig(lineBytes = 24))
    intercept[IllegalArgumentException](J2ReadCacheConfig(cacheBytes = 64, lineBytes = 32))
    intercept[IllegalArgumentException](J2ReadCacheConfig(baseAddress = -32))
    intercept[IllegalArgumentException](J2ReadCacheConfig(baseAddress = 1, rangeBytes = 32))
    intercept[IllegalArgumentException](J2ReadCacheConfig(rangeBytes = 0))
    intercept[IllegalArgumentException](J2ReadCacheConfig(rangeBytes = 33))
    intercept[IllegalArgumentException](
      J2ReadCacheConfig(baseAddress = 0xffffffe0L, rangeBytes = 64)
    )
  }

  for (
    config <- Seq(
      J2ReadCacheConfig(256, 32, 0x12000100L, 96),
      J2ReadCacheConfig(256, 32, 0xffffffe0L, 32),
      J2ReadCacheConfig(128, 8, 0x40000008L, 24)
    )
  )
    test(
      s"cache window ${config.baseAddress.toString(16)} + ${config.rangeBytes}, line ${config.lineBytes}"
    ) {
      SimConfig.withVerilator.compile(new J2ReadCache(config)).doSim { dut =>
        dut.clockDomain.clockSim #= false
        for (bus <- Seq(dut.io.bus, dut.io.control)) {
          bus.CYC #= false; bus.STB #= false; bus.WE #= false
          bus.ADR #= 0; bus.SEL     #= 15; bus.LOCK  #= false; bus.DAT_MOSI #= 0
        }
        dut.io.invalidate               #= false; dut.io.hold                  #= false
        dut.io.refill.cmd.ready         #= true
        dut.io.refill.rsp.valid         #= false; dut.io.refill.rsp.last       #= false
        dut.io.refill.rsp.fragment.data #= 0; dut.io.refill.rsp.fragment.error #= false
        def edge(): Unit = {
          dut.clockDomain.clockSim #= true; sleep(5)
          dut.clockDomain.clockSim #= false; sleep(5)
        }
        dut.clockDomain.assertReset()
        for (_ <- 0 until 4) edge()
        dut.clockDomain.deassertReset()
        var pending: Option[(BigInt, Int)] = None
        val commands                       = ArrayBuffer.empty[BigInt]
        def value(address: BigInt): BigInt = (address & ~BigInt(3)) ^ BigInt("abcd1234", 16)
        def step(): (Boolean, Boolean, BigInt) = {
          dut.io.refill.rsp.valid #= pending.nonEmpty
          pending.foreach { case (base, word) =>
            dut.io.refill.rsp.fragment.data #= value(base + word * 4)
            dut.io.refill.rsp.last          #= (word == config.lineBytes / 4 - 1)
          }
          sleep(1)
          val command  = dut.io.refill.cmd.valid.toBoolean
          val base     = dut.io.refill.cmd.address.toBigInt
          val response = dut.io.refill.rsp.valid.toBoolean && dut.io.refill.rsp.ready.toBoolean
          val reply =
            (dut.io.bus.ACK.toBoolean, dut.io.bus.ERR.toBoolean, dut.io.bus.DAT_MISO.toBigInt)
          if (command) {
            assert(pending.isEmpty, "overlapping refills")
            assertEquals(dut.io.refill.cmd.length.toInt, config.lineBytes / 4 - 1)
            assertEquals(base % config.lineBytes, BigInt(0))
            assert(base >= config.baseAddress && base + config.lineBytes <= config.endAddress)
            commands += base
          }
          edge()
          if (response) pending = pending.flatMap { case (a, w) =>
            if (w == config.lineBytes / 4 - 1) None else Some((a, w + 1))
          }
          if (command) pending = Some((base, 0))
          reply
        }
        def read(address: BigInt, error: Boolean = false): Unit = {
          val before = commands.size
          dut.io.bus.ADR #= address; dut.io.bus.CYC #= true; dut.io.bus.STB #= true
          var reply  = step()
          var cycles = 0
          while (!reply._1 && !reply._2 && cycles < 100) { reply = step(); cycles += 1 }
          assert(cycles < 100)
          assertEquals(reply._1, !error); assertEquals(reply._2, error)
          if (error) assertEquals(commands.size, before, "out-of-window request reached backend")
          else assertEquals(reply._3, value(address))
          for (_ <- 0 until 3) {
            val held = step()
            assert(!held._1 && !held._2, "duplicate response")
          }
          dut.io.bus.CYC #= false; dut.io.bus.STB #= false
          step(); step()
        }
        // Include unaligned byte addresses at both edges and the 2^32 endpoint.
        read(config.baseAddress - 1, error = true)
        read(0, error                      = true)
        for (offset <- 0 until config.rangeBytes.toInt by 4) read(config.baseAddress + offset)
        read(config.endAddress - 1)
        assertEquals(commands.size, (config.rangeBytes / config.lineBytes).toInt)
        if (config.endAddress < (BigInt(1) << 32)) read(config.endAddress, error = true)
        val beforeHits = commands.size
        read(config.baseAddress)
        assertEquals(commands.size, beforeHits)
      }
    }
}
