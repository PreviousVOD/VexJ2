package j2.bus

import spinal.core.sim._
import scala.collection.mutable.ArrayBuffer

class J2AhbReadCacheSpec extends munit.FunSuite {
  for (
    config <- Seq(
      J2ReadCacheConfig(4096, 32, 0x10000000L, 0x20000000L),
      J2ReadCacheConfig(256, 16, 0xfffffc00L, 1024),
      J2ReadCacheConfig(128, 8, 0x40000008L, 24)
    )
  )
    test(
      s"native AHB cache ${config.cacheBytes}/${config.lineBytes}: refills, LRU, invalidation and errors"
    ) {
      SimConfig.withVerilator.compile(new J2ReadCache(config)).doSim { dut =>
        val bus     = dut.io.bus
        val refill  = dut.io.refill
        val control = dut.io.control
        val last    = config.lineBytes / 4 - 1
        val base    = config.baseAddress
        dut.clockDomain.clockSim #= false
        dut.io.invalidate        #= false; dut.io.hold           #= false
        control.PSEL             #= 0; control.PENABLE           #= false; control.PWRITE  #= false
        control.PADDR            #= 0; control.PWDATA            #= 0
        refill.cmd.ready         #= false; refill.rsp.valid      #= false
        refill.rsp.fragment.data #= 0; refill.rsp.fragment.error #= false; refill.rsp.last #= false
        val commands                       = ArrayBuffer.empty[BigInt]
        var pending: Option[(BigInt, Int)] = None
        var waiting: Option[BigInt]        = None
        var cycles                         = 0
        var readyWait                      = 0
        var salt                           = 0
        var lastWord                       = last
        var invalidateAt: Option[Int]      = None
        var errorAt: Option[Int]           = None
        var manualInvalidate               = false
        def value(address: BigInt): BigInt =
          ((address & ~BigInt(3)) ^ 0xabc12345L ^ salt) & 0xffffffffL
        def edge(): Unit = {
          dut.clockDomain.clockSim #= true; sleep(5)
          dut.clockDomain.clockSim #= false; sleep(5)
        }
        def cycle(): Unit = {
          cycles += 1
          refill.cmd.ready          #= false
          refill.rsp.valid          #= pending.nonEmpty && cycles % 3 != 0
          refill.rsp.fragment.error #= false
          dut.io.invalidate         #= manualInvalidate
          pending.foreach { case (address, index) =>
            refill.rsp.fragment.data #= value(address + index * 4)
            refill.rsp.last          #= (index == lastWord)
            if (cycles % 3 != 0) {
              refill.rsp.fragment.error #= errorAt.contains(index)
              if (invalidateAt.contains(index)) {
                dut.io.invalidate #= true; salt ^= 0x55; invalidateAt = None
              }
            }
          }
          sleep(1)
          if (refill.cmd.valid.toBoolean) {
            val address = refill.cmd.address.toBigInt
            waiting.foreach(a => assertEquals(address, a, "refill changed while stalled"))
            waiting = Some(address); readyWait += 1
            refill.cmd.ready #= (readyWait >= 4 && pending.isEmpty)
          } else { waiting = None; readyWait = 0 }
          sleep(1)
          val command  = refill.cmd.valid.toBoolean && refill.cmd.ready.toBoolean
          val address  = refill.cmd.address.toBigInt
          val response = refill.rsp.valid.toBoolean && refill.rsp.ready.toBoolean
          if (command) {
            assert(address >= base && address + config.lineBytes <= config.endAddress)
            assertEquals(address % config.lineBytes, BigInt(0))
            assertEquals(refill.cmd.length.toInt, last)
            commands += address
          }
          edge()
          if (response) pending = pending.flatMap { case (a, i) =>
            if (i == lastWord) None else Some((a, i + 1))
          }
          if (command) pending = Some((address, 0))
        }
        val master = new AhbMemoryDriver(bus, () => cycle())
        master.init(); dut.clockDomain.assertReset(); edge(); edge();
        dut.clockDomain.deassertReset(); sleep(1)
        def read(address: BigInt): Unit =
          assertEquals(master.access(address, size = 0), value(address))
        def flush(): Unit = {
          manualInvalidate = true; master.tick(); manualInvalidate = false; master.tick()
        }
        def csr(write: Boolean, data: Int = 0, address: Int = 0): BigInt = {
          control.PSEL    #= 1; control.PENABLE      #= false; control.PWRITE #= write
          control.PADDR   #= address; control.PWDATA #= data; master.tick()
          control.PENABLE #= true; sleep(1)
          assert(control.PREADY.toBoolean)
          assertEquals(control.PSLVERROR.toBoolean, address != 0)
          val result = control.PRDATA.toBigInt
          master.tick(); control.PSEL #= 0; control.PENABLE #= false; master.tick()
          result
        }
        read(base + config.lineBytes - 4)
        for (i <- 0 until config.lineBytes) read(base + i)
        assertEquals(commands.size, 1)
        if (config.rangeBytes > config.cacheBytes * 2) {
          val stride = config.cacheBytes / 2
          read(base + stride); read(base)
          val before = commands.size
          read(base + 2 * stride); read(base); read(base + 2 * stride)
          assertEquals(commands.size, before + 1)
          read(base + stride); assertEquals(commands.size, before + 2)
        }
        flush(); salt ^= 0x11
        for (i <- 0 until config.lineBytes) read(base + i)
        val before = commands.size
        assertEquals(csr(false), BigInt(0))
        csr(true, 0); csr(true, 2); read(base)
        assertEquals(commands.size, before)
        csr(true, 1); salt ^= 0x22; read(base)
        assertEquals(commands.size, before + 1)
        csr(false, address = 4)
        for (index <- Seq(0, last / 2, last)) {
          flush(); invalidateAt = Some(index)
          val prior = commands.size
          read(base)
          assertEquals(commands.size, prior + 2, "invalidation must discard and retry refill")
        }
        for (index <- Seq(0, last)) {
          flush(); errorAt = Some(index)
          master.access(base, error = true)
          errorAt          = None
          val prior = commands.size; read(base)
          assertEquals(commands.size, prior + 1, "failed refill became valid")
        }
        for (length <- Seq(0, last + 2)) {
          flush(); lastWord = length
          master.access(base, error = true)
          lastWord          = last
          val prior = commands.size; read(base)
          assertEquals(commands.size, prior + 1)
        }
        val prior = commands.size
        master.access(base, true, 123, error = true)
        master.access(base - 1, size         = 0, error = true)
        if (config.endAddress < (BigInt(1) << 32)) master.access(config.endAddress, error = true)
        assertEquals(commands.size, prior)
        read(config.endAddress - 1)
        flush(); dut.io.hold #= true
        master.start(base)
        for (_ <- 0 until 15) {
          master.tick(); assert(!refill.cmd.valid.toBoolean && !bus.HREADYOUT.toBoolean)
        }
        dut.io.hold #= false
        assertEquals(master.finish(), value(base))
        // An unselected next address cannot cancel an accepted refill. The driver
        // changes HSEL/HTRANS/address immediately after every accepted request.
        assert(!dut.io.busy.toBoolean)
      }
    }
}
