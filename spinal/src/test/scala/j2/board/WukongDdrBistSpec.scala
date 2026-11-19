package j2.board

import j2.board.wukong_v1.WukongDdrBist
import spinal.core.sim._
import scala.collection.mutable

class WukongDdrBistSpec extends munit.FunSuite {
  for (corrupt <- Seq(false, true))
    test(s"DDR BIST independent command/data backpressure, corrupt=$corrupt") {
      SimConfig.withVerilator.compile(new WukongDdrBist).doSim { dut =>
        dut.io.calibrated #= false
        dut.io.ready      #= false; dut.io.wready #= false
        dut.io.rvalid     #= false; dut.io.rend   #= false; dut.io.rdata #= 0
        dut.clockDomain.forkStimulus(10)
        dut.clockDomain.waitSampling(10)
        dut.io.calibrated #= true
        val random     = new scala.util.Random(7341)
        val memory     = mutable.Map.empty[Long, BigInt]
        val commands   = mutable.Queue.empty[Long]
        val writes     = mutable.Queue.empty[(BigInt, Int)]
        val reads      = mutable.Queue.empty[(Int, BigInt)]
        var cycles     = 0
        var readCount  = 0
        var writeCount = 0
        while (!dut.io.done.toBoolean && cycles < 100000) {
          dut.clockDomain.waitFallingEdge()
          dut.io.ready  #= random.nextBoolean()
          dut.io.wready #= random.nextBoolean()
          dut.io.rvalid #= false
          if (reads.nonEmpty && reads.front._1 <= cycles) {
            val (_, value) = reads.dequeue()
            dut.io.rdata  #= (if (corrupt && readCount == 1) value ^ 1 else value)
            dut.io.rvalid #= true; dut.io.rend #= true
          }
          sleep(1)
          val acceptCommand = dut.io.en.toBoolean && dut.io.ready.toBoolean
          val acceptData    = dut.io.wren.toBoolean && dut.io.wready.toBoolean
          if (acceptCommand) {
            val addr = dut.io.addr.toLong
            assert((addr & 7) == 0 && addr < 0x8000000L)
            if (dut.io.cmd.toInt == 1) {
              assert(memory.contains(addr), "read before write")
              readCount += 1
              reads.enqueue((cycles + 2 + random.nextInt(10), memory(addr)))
            } else {
              assert(writes.nonEmpty, "write command issued before its data was accepted")
              commands.enqueue(addr)
            }
          }
          if (acceptData) {
            assert(dut.io.wend.toBoolean)
            writes.enqueue((dut.io.wdata.toBigInt, dut.io.mask.toInt))
          }
          if (commands.nonEmpty && writes.nonEmpty) {
            val addr          = commands.dequeue()
            val (value, mask) = writes.dequeue()
            var result        = memory.getOrElse(addr, BigInt(0))
            for (b <- 0 until 16 if (mask & (1 << b)) == 0) {
              val lane = BigInt(255) << (b * 8)
              result = (result & ~lane) | (value & lane)
            }
            memory(addr) = result
            writeCount += 1
          }
          dut.clockDomain.waitSampling()
          sleep(1)
          cycles += 1
        }
        assert(dut.io.done.toBoolean, "test timeout")
        assertEquals(dut.io.failed.toBoolean, corrupt)
        if (!corrupt) {
          assertEquals(memory.size, 1024)
          assertEquals(writeCount, 2048)
          assertEquals(readCount, 2048)
          assert(commands.isEmpty && writes.isEmpty && reads.isEmpty)
        }
      }
    }
}
