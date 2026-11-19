package j2.bus

import j2.bus.ahb5._
import spinal.core._
import spinal.core.sim._
import spinal.lib.bus.misc.SizeMapping
import scala.collection.mutable.ArrayBuffer

class Ahb5Spec extends munit.FunSuite {
  private val config =
    Ahb5Config(32, 64, 5, secureTransfers = true, extendedMemoryTypes = true, writeStrobes = true)
  private val mappings = Seq(SizeMapping(0, 4096), SizeMapping(4096, 4096))
  case class Beat(
      port: Int,
      address: BigInt,
      id: BigInt,
      trans: Int,
      burst: Int,
      size: Int,
      write: Boolean,
      lock: Boolean,
      prot: BigInt,
      nonsec: Boolean
  )
  case class Reply(ready: Boolean, error: Boolean, data: BigInt)
  case class Pending(beat: Beat, var waits: Int, fail: Boolean, var errorFirst: Boolean = true)

  /** A cycle-driven subordinate model. Completion data comes from the previously accepted address,
    * never the currently visible address. This catches phase-routing mistakes.
    */
  class Rig(val dut: Ahb5Interconnect) {
    val accepted                      = ArrayBuffer[Beat]()
    val writes                        = ArrayBuffer[(Beat, BigInt, BigInt)]()
    val pending                       = Array.fill[Option[Pending]](dut.io.subordinates.size)(None)
    var waitCycles: Beat => Int       = _ => 2
    var errors: Beat => Boolean       = _ => false
    var cycles                        = 0
    val heldAddress                   = Array.fill[Option[BigInt]](dut.io.subordinates.size)(None)
    def readValue(beat: Beat): BigInt = (beat.id << 40) | (beat.port << 24) | beat.address

    for ((bus, index) <- dut.io.managers.zipWithIndex) {
      bus.address.HADDR     #= 0
      bus.address.HTRANS    #= 0
      bus.address.HBURST    #= 0
      bus.address.HSIZE     #= 2
      bus.address.HWRITE    #= false
      bus.address.HMASTLOCK #= false
      bus.address.HMASTER   #= index + 7
      bus.address.HPROT     #= 0x33
      bus.address.HNONSEC   #= true
      bus.HWDATA            #= 0
      bus.HWSTRB            #= 255
    }
    for (bus <- dut.io.subordinates) {
      bus.HREADYOUT #= true
      bus.HRESP     #= false
      bus.HRDATA    #= 0
    }
    dut.clockDomain.clockSim #= false
    dut.clockDomain.assertReset()
    for (_ <- 0 until 4) edge()
    dut.clockDomain.deassertReset()
    sleep(1)

    def edge(): Unit = {
      dut.clockDomain.clockSim #= true; sleep(5)
      dut.clockDomain.clockSim #= false; sleep(5)
    }

    def tick(): Seq[Reply] = {
      for ((bus, i) <- dut.io.subordinates.zipWithIndex) {
        val p = pending(i)
        bus.HREADYOUT #= p.forall(x => x.waits == 0 && (!x.fail || !x.errorFirst))
        bus.HRESP     #= p.exists(x => x.waits == 0 && x.fail)
        bus.HRDATA    #= p.map(x => readValue(x.beat)).getOrElse(BigInt(0))
      }
      sleep(1)
      for ((b, i) <- dut.io.subordinates.zipWithIndex) {
        // A stalled address phase may be cancelled for ERROR, but must otherwise hold.
        val a = b.address
        val signature = a.HADDR.toBigInt | (BigInt(a.HTRANS.toInt) << 32) |
          (BigInt(a.HBURST.toInt) << 34) | (BigInt(a.HSIZE.toInt) << 37) |
          (a.HMASTER.toBigInt << 40) | (a.HPROT.toBigInt << 48)
        if (!b.HRESP.toBoolean) heldAddress(i).foreach(old => assertEquals(signature, old))
        heldAddress(i) = if (!b.HREADY.toBoolean && !b.HRESP.toBoolean) Some(signature) else None
      }
      val replies = dut.io.managers
        .map(b => Reply(b.HREADY.toBoolean, b.HRESP.toBoolean, b.HRDATA.toBigInt))
        .toSeq
      val incoming = dut.io.subordinates.zipWithIndex.map { case (b, i) =>
        if (b.HSEL.toBoolean && b.HREADY.toBoolean && b.address.HTRANS.toInt >= 2) {
          val a = b.address
          Some(
            Beat(
              i,
              a.HADDR.toBigInt,
              a.HMASTER.toBigInt,
              a.HTRANS.toInt,
              a.HBURST.toInt,
              a.HSIZE.toInt,
              a.HWRITE.toBoolean,
              a.HMASTLOCK.toBoolean,
              a.HPROT.toBigInt,
              a.HNONSEC.toBoolean
            )
          )
        } else None
      }
      val next = pending.zipWithIndex.map { case (entry, i) =>
        var value = entry
        entry.foreach { p =>
          if (p.waits > 0) p.waits -= 1
          else if (p.fail && p.errorFirst) p.errorFirst = false
          else {
            if (p.beat.write && !p.fail)
              writes += ((
                p.beat,
                dut.io.subordinates(i).HWDATA.toBigInt,
                dut.io.subordinates(i).HWSTRB.toBigInt
              ))
            value = None
          }
        }
        incoming(i).foreach { beat =>
          assert(value.isEmpty, "new address accepted while the preceding data phase was stalled")
          accepted += beat
          value = Some(Pending(beat, waitCycles(beat), errors(beat)))
        }
        value
      }
      edge()
      next.indices.foreach(i => pending(i) = next(i))
      cycles += 1
      assert(cycles < 4000, "simulation timeout")
      replies
    }

    def address(
        index: Int,
        addr: Int,
        write: Boolean = false,
        lock: Boolean = false,
        trans: Int = 2,
        burst: Int = 0,
        size: Int = 2
    ): Unit = {
      val b = dut.io.managers(index)
      b.address.HADDR     #= addr
      b.address.HWRITE    #= write
      b.address.HMASTLOCK #= lock
      b.address.HTRANS    #= trans
      b.address.HBURST    #= burst
      b.address.HSIZE     #= size
    }
    def idle(index: Int, lock: Boolean = false): Unit = {
      dut.io.managers(index).address.HTRANS    #= 0
      dut.io.managers(index).address.HMASTLOCK #= lock
    }
    def finish(index: Int, expectError: Boolean = false): Reply = {
      var firstError = false
      var reply      = tick()(index)
      while (!reply.ready) {
        if (reply.error) {
          assert(!firstError, "ERROR first cycle repeated")
          firstError = true
        }
        reply = tick()(index)
      }
      assertEquals(reply.error, expectError)
      assertEquals(firstError, expectError, "ERROR must have exactly two cycles")
      reply
    }
    def single(
        index: Int,
        addr: Int,
        write: Boolean = false,
        lock: Boolean = false,
        data: BigInt = 0,
        strobe: Int = 255,
        fail: Boolean = false
    ): Reply = {
      address(index, addr, write, lock)
      assert(tick()(index).ready, "expected an idle manager port")
      idle(index, lock)
      dut.io.managers(index).HWDATA #= data
      dut.io.managers(index).HWSTRB #= strobe
      finish(index, fail)
    }
  }

  private def run(body: Rig => Unit): Unit =
    SimConfig.withVerilator
      .compile(new Ahb5Interconnect(config, 3, mappings, Seq(Set(0, 1), Set(0, 1), Set(1))))
      .doSim(dut => body(new Rig(dut)))

  test("address/data phases, IDs, attributes, strobes, contention and independent BIUs") {
    run { r =>
      r.waitCycles = b => if (b.port == 0) 12 else 1
      r.address(0, 0x20, write = true)
      r.address(1, 0x28, write = true)
      r.address(2, 0x1020)
      assert(r.tick().forall(_.ready))
      (0 until 3).foreach(r.idle(_))
      r.dut.io.managers(0).HWDATA #= BigInt("1122334455667788", 16)
      r.dut.io.managers(0).HWSTRB #= 0xa5
      r.dut.io.managers(1).HWDATA #= BigInt("8877665544332211", 16)
      r.dut.io.managers(1).HWSTRB #= 0x5a
      val done = Array.fill(3)(false)
      while (!done.forall(identity)) {
        val replies = r.tick()
        for (i <- 0 until 3 if !done(i) && replies(i).ready) {
          assert(!replies(i).error)
          if (i == 2) {
            assert(!done(0) && !done(1), "unrelated BIU waited for the slow destination")
            assertEquals(replies(i).data, (BigInt(9) << 40) | (1 << 24) | 0x1020)
          }
          done(i) = true
        }
      }
      assertEquals(r.accepted.size, 3)
      assert(r.accepted.forall(b => b.prot == 0x33 && b.nonsec))
      assertEquals(
        r.writes.map(x => (x._1.id, x._2, x._3)).toSet,
        Set(
          (BigInt(7), BigInt("1122334455667788", 16), BigInt(0xa5)),
          (BigInt(8), BigInt("8877665544332211", 16), BigInt(0x5a))
        )
      )
    }
  }

  test("locked RMW excludes competitors through idle gaps and releases on unlocked IDLE") {
    run { r =>
      r.single(0, 0x38, lock = true)
      r.address(1, 0x40)
      r.address(2, 0x1040)
      r.tick()
      r.idle(1); r.idle(2)
      var otherDone = false
      for (_ <- 0 until 20) {
        val replies = r.tick()
        assert(!replies(1).ready)
        otherDone ||= replies(2).ready
      }
      assert(otherDone)
      assert(!r.accepted.exists(_.id == 8))
      r.single(0, 0x38, write = true, lock = true, data = 0x80)
      assert(!r.accepted.exists(_.id == 8))
      r.idle(0) // No extra NONSEQ is needed to release the domain.
      r.finish(1)
      assertEquals(
        r.accepted.filter(_.port == 0).map(_.id).toSeq,
        Seq(BigInt(7), BigInt(7), BigInt(8))
      )
    }
  }

  test("leading locked IDLE acquires a reservation; HREADY qualifies release") {
    run { r =>
      r.address(0, 0x80, lock = true, trans = 0)
      for (_ <- 0 until 4) assert(r.tick()(0).ready)
      r.address(1, 0x88); r.tick(); r.idle(1)
      for (_ <- 0 until 8) assert(!r.tick()(1).ready)
      r.address(0, 0x80, lock = true)
      r.tick()
      r.idle(0) // Low during the stalled data phase must NOT release early.
      var complete = false
      while (!complete) {
        val replies = r.tick()
        assert(!r.accepted.exists(_.id == 8))
        complete = replies(0).ready
      }
      r.finish(1)
    }
  }

  test("fixed, wrapping and undefined bursts preserve beats across BUSY gaps") {
    run { r =>
      r.waitCycles = _ => 1
      for (
        (burst, addresses) <- Seq(
          3 -> Seq(0x20, 0x24, 0x28, 0x2c),
          2 -> Seq(0x34, 0x38, 0x3c, 0x30),
          4 -> (0 until 8).map(i => 0x80 + ((i + 3) % 8) * 4),
          5 -> (0 until 8).map(i => 0xa0 + i * 4),
          6 -> (0 until 16).map(i => 0x100 + ((i + 3) % 16) * 4),
          7 -> (0 until 16).map(i => 0x180 + i * 4),
          1 -> Seq(0x200, 0x204, 0x208)
        )
      ) {
        val before = r.accepted.size
        r.address(0, addresses.head, burst = burst)
        r.tick()
        for (i <- addresses.indices) {
          if (i + 1 < addresses.size) r.address(0, addresses(i + 1), trans = 1, burst = burst)
          else r.idle(0)
          r.finish(0)
          if (i + 1 < addresses.size) {
            for (_ <- 0 until 3) assert(r.tick()(0).ready) // BUSY has a zero-wait OKAY response.
            r.address(0, addresses(i + 1), trans = 3, burst = burst)
            assert(r.tick()(0).ready)
          }
        }
        val beats = r.accepted.drop(before)
        assertEquals(beats.map(_.address).toSeq, addresses.map(BigInt(_)))
        assertEquals(beats.map(_.trans).toSeq, Seq(2) ++ Seq.fill(addresses.size - 1)(3))
        assert(beats.forall(_.burst == burst))
        for (_ <- 0 until 3) r.tick()
      }
    }
  }

  test("unmapped and forbidden requests return two-cycle ERROR; locked errors can release") {
    run { r =>
      r.single(0, 0x9000, fail = true)
      r.single(2, 0x10, fail   = true)
      assert(r.accepted.isEmpty)
      r.errors = _.address == 0x50
      r.single(0, 0x50, lock = true, fail = true)
      r.address(1, 0x60); r.tick(); r.idle(1)
      for (_ <- 0 until 4) assert(!r.tick()(1).ready)
      r.idle(0)
      r.finish(1)
      r.single(0, 0x1050)
    }
  }

  test("back-to-back address acceptance on response completion and ERROR burst continuation") {
    run { r =>
      r.errors = _.address == 0x300
      r.address(0, 0x300, burst = 3)
      r.tick()
      r.address(0, 0x304, trans = 3, burst = 3)
      r.finish(0, expectError   = true) // also accepts the next address
      r.address(0, 0x308, trans = 3, burst = 3)
      r.finish(0)
      r.address(0, 0x30c, trans = 3, burst = 3)
      r.finish(0)
      r.idle(0)
      r.finish(0)
      assertEquals(r.accepted.map(_.address).toSeq, Seq(0x300, 0x304, 0x308, 0x30c).map(BigInt(_)))
      assert(r.accepted.drop(1).forall(b => b.trans == 2 && b.burst == 0))
    }
  }

  test("randomized competing reads/writes with stalls retain request and response ownership") {
    run { r =>
      val random = new scala.util.Random(0x41484235)
      r.waitCycles = _ => random.nextInt(7)
      for (round <- 0 until 35) {
        val addresses = (0 until 3).map(i =>
          (if (i == 2 || random.nextBoolean()) 4096 else 0) +
            (round * 8 + i * 512)
        )
        val write   = (0 until 3).map(_ => random.nextBoolean())
        val data    = (0 until 3).map(_ => BigInt(64, random))
        val strobes = (0 until 3).map(_ => random.nextInt(256))
        val prior   = r.writes.size
        for (i <- 0 until 3) r.address(i, addresses(i), write = write(i), size = 3)
        assert(r.tick().forall(_.ready))
        for (i <- 0 until 3) {
          r.idle(i)
          r.dut.io.managers(i).HWDATA #= data(i)
          r.dut.io.managers(i).HWSTRB #= strobes(i)
        }
        val done = Array.fill(3)(false)
        while (!done.forall(identity)) {
          val replies = r.tick()
          for (i <- 0 until 3 if !done(i) && replies(i).ready) {
            assert(!replies(i).error)
            if (!write(i))
              assertEquals(
                replies(i).data,
                (BigInt(i + 7) << 40) | (BigInt(addresses(i) / 4096) << 24) | addresses(i)
              )
            done(i) = true
          }
        }
        val results = r.writes.drop(prior)
        for (i <- 0 until 3 if write(i)) {
          val result = results.find(_._1.id == i + 7).get
          assertEquals(result._2, data(i))
          assertEquals(result._3, BigInt(strobes(i)))
        }
      }
    }
  }

  test("reset releases reservations and discards outstanding transport state") {
    run { r =>
      r.single(0, 0x20, lock = true)
      r.address(1, 0x24); r.tick(); r.idle(1)
      for (_ <- 0 until 4) assert(!r.tick()(1).ready)
      (0 until 3).foreach(r.idle(_))
      r.dut.clockDomain.assertReset()
      for (_ <- 0 until 3) r.edge()
      r.pending.indices.foreach(i => r.pending(i) = None)
      r.dut.clockDomain.deassertReset()
      r.single(1, 0x24)
    }
  }

  test("generic width/property combinations and standalone arbiter elaborate") {
    for ((width, index) <- Seq(8, 16, 32, 64, 128, 256, 512, 1024).zipWithIndex) {
      val c = Ahb5Config(
        addressWidth        = 40,
        dataWidth           = width,
        masterWidth         = 1,
        writeStrobes        = index % 2 == 0,
        secureTransfers     = index % 3 == 0,
        extendedMemoryTypes = index % 2 == 1
      )
      SpinalConfig(targetDirectory = s"target/ahb5-width-$width")
        .generateVerilog(new Ahb5Arbiter(c, if (index % 2 == 0) 1 else 5))
    }
  }

  test("direct decoder preserves pipelined response selection and default-slave ERROR") {
    SimConfig.withVerilator.compile(new Ahb5Decoder(Ahb5Config(), mappings)).doSim { dut =>
      val b = dut.io.input
      b.address.HADDR     #= 0; b.address.HWRITE     #= false; b.address.HSIZE #= 2
      b.address.HBURST    #= 0; b.address.HPROT      #= 3; b.address.HMASTER   #= 5
      b.address.HMASTLOCK #= false; b.address.HTRANS #= 0; b.HWDATA            #= 0
      for ((out, i) <- dut.io.outputs.zipWithIndex) {
        out.HREADYOUT #= true; out.HRESP #= false; out.HRDATA #= (i + 100)
      }
      dut.clockDomain.clockSim #= false
      def edge(): Unit = {
        sleep(1); dut.clockDomain.clockSim #= true; sleep(5)
        dut.clockDomain.clockSim           #= false; sleep(5)
      }
      dut.clockDomain.assertReset(); edge(); edge(); dut.clockDomain.deassertReset(); sleep(1)
      b.address.HTRANS #= 2; b.address.HADDR #= 0x20; edge()
      b.address.HADDR  #= 0x1020; sleep(1)
      assertEquals(b.HRDATA.toInt, 100)
      dut.io.outputs(0).HREADYOUT #= false; sleep(1)
      assert(!b.HREADY.toBoolean)
      edge(); assertEquals(b.HRDATA.toInt, 100)
      dut.io.outputs(0).HREADYOUT #= true; edge()
      assertEquals(b.HRDATA.toInt, 101)
      b.address.HADDR  #= 0x9000; edge()
      b.address.HTRANS #= 0; sleep(1)
      assert(b.HRESP.toBoolean && !b.HREADY.toBoolean)
      edge(); assert(b.HRESP.toBoolean && b.HREADY.toBoolean)
      edge(); assert(!b.HRESP.toBoolean && b.HREADY.toBoolean)
      b.address.HTRANS #= 1; edge() // BUSY in the default region must not start an error.
      assert(!b.HRESP.toBoolean && b.HREADY.toBoolean)
    }
  }
}
