package j2.bus

import spinal.core._
import spinal.core.sim._
import scala.collection.mutable.ArrayBuffer

class J2ReadCacheSpec extends munit.FunSuite {
  for ((capacity, lineSize) <- Seq((4096, 32), (256, 16))) {
    test(s"two-way read cache $capacity/$lineSize refills, LRU, cancellation and invalidation") {
      val lastIndex = lineSize / 4 - 1
      val stride    = capacity / 2
      SimConfig.withVerilator
        .compile(new J2ReadCache(J2ReadCacheConfig(capacity, lineSize)))
        .doSim { dut =>
          dut.clockDomain.clockSim         #= false
          dut.io.bus.CYC                   #= false
          dut.io.bus.STB                   #= false
          dut.io.bus.WE                    #= false
          dut.io.bus.ADR                   #= 0
          dut.io.bus.SEL                   #= 15
          dut.io.bus.LOCK                  #= false
          dut.io.bus.DAT_MOSI              #= 0
          dut.io.control.CYC               #= false
          dut.io.control.STB               #= false
          dut.io.control.WE                #= false
          dut.io.control.ADR               #= 0
          dut.io.control.DAT_MOSI          #= 0
          dut.io.control.SEL               #= 15
          dut.io.control.LOCK              #= false
          dut.io.refill.rsp.fragment.error #= false
          dut.io.invalidate                #= false
          dut.io.hold                      #= false
          dut.io.refill.cmd.ready          #= false
          dut.io.refill.rsp.valid          #= false
          dut.io.refill.rsp.fragment.data  #= 0
          dut.io.refill.rsp.last           #= false
          case class Reply(ack: Boolean, err: Boolean, data: Long)
          case class Fill(base: Long, index: Int, gap: Int)
          val commands                  = ArrayBuffer.empty[Long]
          var fill: Option[Fill]        = None
          var waiting: Option[Long]     = None
          var commandWaits              = 0
          var salt                      = 0
          var lastWord                  = lastIndex
          var invalidateAt: Option[Int] = None
          var invalidateOnReply         = false
          var softwareAt: Option[Int]   = None
          var errorAt: Option[Int]      = None
          var abortAt: Option[Int]      = None
          def flashByte(address: Long): Int =
            (((address * 37) ^ (address >> 7) ^ (address >> 13) ^ (address >> 24) ^ 0xa5) & 255).toInt ^ salt
          def expected(address: Long): Long = {
            val aligned = address & ~3L
            (0 until 4).foldLeft(0L)((word, i) => (word << 8) | flashByte(aligned + i))
          }
          def edge(): Unit = {
            dut.clockDomain.clockSim #= true
            sleep(5)
            dut.clockDomain.clockSim #= false
            sleep(5)
          }
          dut.clockDomain.assertReset()
          for (_ <- 0 until 4) edge()
          dut.clockDomain.deassertReset()
          sleep(1)

          def step(invalidate: Boolean = false): Reply = {
            dut.io.invalidate                #= invalidate
            dut.io.refill.cmd.ready          #= false
            dut.io.refill.rsp.valid          #= false
            dut.io.refill.rsp.last           #= false
            dut.io.refill.rsp.fragment.error #= false
            dut.io.control.CYC               #= false
            dut.io.control.STB               #= false
            sleep(1)
            if (dut.io.refill.cmd.valid.toBoolean) {
              val base = dut.io.refill.cmd.address.toLong
              assertEquals(base & (lineSize - 1), 0L, "unaligned refill")
              assertEquals(dut.io.refill.cmd.length.toInt, lastIndex)
              waiting.foreach(old => assertEquals(base, old, "command changed before ready"))
              waiting = Some(base)
              commandWaits += 1
              dut.io.refill.cmd.ready #= (commandWaits >= 4 && fill.isEmpty)
            } else {
              waiting      = None
              commandWaits = 0
            }
            fill.foreach { f =>
              if (f.gap == 0) {
                dut.io.refill.rsp.valid         #= true
                dut.io.refill.rsp.fragment.data #= expected(f.base + f.index * 4)
                dut.io.refill.rsp.last          #= (f.index == lastWord)
                if (invalidateAt.contains(f.index)) {
                  dut.io.invalidate #= true
                  salt ^= 0x3c
                  invalidateAt = None
                }
                dut.io.refill.rsp.fragment.error #= errorAt.contains(f.index)
                if (softwareAt.contains(f.index)) {
                  dut.io.control.CYC      #= true
                  dut.io.control.STB      #= true
                  dut.io.control.WE       #= true
                  dut.io.control.DAT_MOSI #= 1
                  salt ^= 0x63
                  softwareAt = None
                }
                if (abortAt.contains(f.index)) {
                  dut.io.bus.CYC #= false
                  dut.io.bus.STB #= false
                  abortAt = None
                }
              }
            }
            sleep(1)
            if (invalidateOnReply && dut.io.bus.ACK.toBoolean) {
              dut.io.invalidate #= true
              salt ^= 0x71
              invalidateOnReply = false
              sleep(1)
            }
            if (dut.io.control.CYC.toBoolean) {
              assert(dut.io.control.ACK.toBoolean)
              assertEquals(dut.io.control.DAT_MISO.toLong, 2L, "busy status during refill")
            }
            val reply =
              Reply(dut.io.bus.ACK.toBoolean, dut.io.bus.ERR.toBoolean, dut.io.bus.DAT_MISO.toLong)
            val commandFire = dut.io.refill.cmd.valid.toBoolean && dut.io.refill.cmd.ready.toBoolean
            val responseFire =
              dut.io.refill.rsp.valid.toBoolean && dut.io.refill.rsp.ready.toBoolean
            val next = fill.flatMap { f =>
              if (responseFire && f.index == lastWord) None
              else if (responseFire) Some(f.copy(index = f.index + 1, gap = (f.index + 1) % 3))
              else Some(f.copy(gap = (f.gap - 1).max(0)))
            }
            val base = dut.io.refill.cmd.address.toLong
            edge()
            fill = next
            if (commandFire) {
              commands += base
              fill         = Some(Fill(base, 0, 2))
              waiting      = None
              commandWaits = 0
            }
            reply
          }
          def start(address: Long, write: Boolean = false): Unit = {
            dut.io.bus.ADR #= address
            dut.io.bus.WE  #= write
            dut.io.bus.CYC #= true
            dut.io.bus.STB #= true
          }
          def finish(error: Boolean = false): Long = {
            var reply  = step()
            var cycles = 0
            while (!reply.ack && !reply.err && cycles < 1000) {
              reply = step()
              cycles += 1
            }
            assert(cycles < 1000, "cache request timed out")
            assertEquals(reply.err, error)
            assertEquals(reply.ack, !error)
            // A master may leave its request asserted beyond the response edge.
            for (_ <- 0 until 3) {
              val repeated = step()
              assert(!repeated.ack && !repeated.err, "duplicate response to held STB")
            }
            dut.io.bus.CYC #= false
            dut.io.bus.STB #= false
            step()
            step()
            reply.data
          }
          def read(address: Long): Unit = {
            start(address)
            val value = finish()
            assertEquals(value, expected(address), s"word at ${address.toHexString}")
          }

          def control(write: Boolean, data: Int = 0, sel: Int = 15, offset: Int = 0): Long = {
            dut.io.control.CYC #= true; dut.io.control.STB       #= true
            dut.io.control.WE  #= write; dut.io.control.DAT_MOSI #= data
            dut.io.control.SEL #= sel; dut.io.control.ADR        #= offset
            sleep(1)
            assertEquals(dut.io.control.ACK.toBoolean, offset == 0)
            assertEquals(dut.io.control.ERR.toBoolean, offset != 0)
            val result = dut.io.control.DAT_MISO.toLong
            edge()
            for (_ <- 0 until 3) {
              assert(!dut.io.control.ACK.toBoolean && !dut.io.control.ERR.toBoolean)
              edge()
            }
            dut.io.control.CYC #= false; dut.io.control.STB #= false
            dut.io.control.SEL #= 15; dut.io.control.ADR    #= 0
            edge()
            result
          }

          read(0x10000000L + lineSize - 4) // Requested word is the last word of a cold refill.
          assertEquals(commands.toSeq, Seq(0x10000000L))
          for (offset <- 0 until lineSize) read(0x10000000L + offset)
          assertEquals(commands.size, 1, "words and halfwords in a line must hit")
          read(0x10000000L + lineSize)
          assertEquals(commands.size, 2, "line boundary must miss")

          // All three addresses map to set zero. Both ways must coexist; a hit on
          // A makes B the victim when C arrives.
          read(0x10000000L + stride)
          read(0x10000000)
          val beforeC = commands.size
          read(0x10000000L + 2 * stride)
          read(0x10000000)
          read(0x10000000L + 2 * stride)
          assertEquals(commands.size, beforeC + 1)
          read(0x10000000L + stride)
          assertEquals(commands.size, beforeC + 2, "least recently used way was not replaced")

          salt ^= 0x55
          step(invalidate = true)
          val beforeFlush = commands.size
          read(0x10000000)
          read(0x10000000L + stride)
          assertEquals(commands.size, beforeFlush + 2, "invalidate must clear both ways")

          val beforeControl = commands.size
          assertEquals(control(false), 0L) // Invalidate reads as zero, idle busy=0.
          control(true, 0)
          control(true, 1, sel = 8) // Wrong byte lane must not invalidate bit zero.
          control(true, 2) // RO busy bit has no side effect.
          read(0x10000000)
          assertEquals(commands.size, beforeControl)
          control(true, 1)
          salt ^= 0x28
          read(0x10000000)
          read(0x10000000L + stride)
          assertEquals(commands.size, beforeControl + 2)
          control(false, offset = 4) // Undefined register returns ERR once.

          // Full 32-bit addresses participate in the tag, not just a flash offset.
          val beforeHigh = commands.size
          read(0x20000000L + stride)
          assertEquals(commands.size, beforeHigh + 1)

          for (word <- Seq(0, lastIndex / 2, lastIndex)) {
            control(true, 1)
            softwareAt = Some(word)
            val before = commands.size
            read(0x10000004)
            assertEquals(commands.size, before + 2, "register invalidation must beat publication")
          }
          for (word <- Seq(0, lastIndex)) {
            control(true, 1)
            errorAt = Some(word)
            start(0x10000000)
            finish(error = true)
            errorAt = None
            val before = commands.size
            read(0x10000000)
            assertEquals(commands.size, before + 1, "errored refill became valid")
          }

          // Invalidation during a refill, including its last word, must not publish
          // mixed old/new flash data. The pending request is retried with a fresh fill.
          for (word <- Seq(0, lastIndex / 2, lastIndex)) {
            step(invalidate = true)
            invalidateAt = Some(word)
            val before = commands.size
            read(0x10000004)
            assertEquals(commands.size, before + 2)
          }
          invalidateOnReply = true
          val beforeReplyFlush = commands.size
          read(0x10000004)
          assertEquals(commands.size, beforeReplyFlush + 1, "invalidate must beat a cached reply")

          step(invalidate = true)
          start(0x10000000)
          // Abort while cmd.valid is held waiting for the engine to accept it.
          while (!dut.io.refill.cmd.valid.toBoolean) step()
          step()
          dut.io.bus.CYC #= false
          dut.io.bus.STB #= false
          var drained = 0
          while ((dut.io.busy.toBoolean || fill.nonEmpty) && drained < 300) {
            val response = step()
            assert(!response.ack && !response.err)
            drained += 1
          }
          assert(drained < 300)
          val beforeAbortRetry = commands.size
          read(0x10000000)
          assertEquals(commands.size, beforeAbortRetry + 1, "aborted fill became valid")

          for (word <- Seq(0, lastIndex / 2, lastIndex)) {
            step(invalidate = true)
            abortAt = Some(word)
            start(0x10000000)
            for (_ <- 0 until 180) {
              val response = step()
              assert(!response.ack && !response.err)
            }
            assert(!dut.io.busy.toBoolean)
            read(0x10000000)
          }

          // Truncated and oversized bursts are drained/rejected, never cached.
          for (length <- Seq(1, lastIndex + 2)) {
            step(invalidate = true)
            lastWord = length
            start(0x10000000)
            finish(error = true)
            lastWord = lastIndex
            val before = commands.size
            read(0x10000000)
            assertEquals(commands.size, before + 1)
          }
          val beforeWrite = commands.size
          start(0x10000000, write = true)
          finish(error            = true)
          assertEquals(commands.size, beforeWrite, "cache writes must not reach the SPI engine")

          dut.io.hold #= true
          start(0x10000200)
          for (_ <- 0 until 10) {
            assert(!step().ack)
            assert(!dut.io.refill.cmd.valid.toBoolean)
          }
          dut.io.hold #= false
          assertEquals(finish(), expected(0x10000200))

          // A shared reset also resets the downstream SPI transaction.
          step(invalidate = true)
          start(0x10000000)
          while (fill.forall(_.index < 3)) step()
          dut.io.bus.CYC          #= false
          dut.io.bus.STB          #= false
          dut.io.refill.rsp.valid #= false
          dut.io.refill.cmd.ready #= false
          dut.clockDomain.assertReset()
          edge()
          edge()
          fill         = None
          waiting      = None
          commandWaits = 0
          dut.clockDomain.deassertReset()
          step()
          read(0x10000000)
          assert(!dut.io.busy.toBoolean)
        }
    }
  }
}
