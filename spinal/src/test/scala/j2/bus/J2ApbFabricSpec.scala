package j2.bus

import j2.bus.ahb5._
import j2.bus.apb.Apb4Matrix
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import j2.bus.apb._
import spinal.lib.bus.misc.SizeMapping
import scala.collection.mutable.ArrayBuffer

class J2ApbFabricSpec extends munit.FunSuite {
  private val config = Ahb5Config(writeStrobes = true)
  class Probe extends Component {
    val io = new Bundle {
      val managers    = Vec(slave(Ahb5Master(config)), 3)
      val peripherals = Vec(master(Apb4(Apb4Config(32, 32))), 2)
    }
    val routes = new Ahb5RoutingMatrix(
      config,
      3,
      Seq(SizeMapping(0x1000, 0x1000), SizeMapping(0x3000, 0x1000)),
      Seq(Set(0, 1), Set(0, 1), Set(0, 1))
    )
    routes.io.managers <> io.managers
    val biu = new J2Biu(config, 3)
    biu.io.managers <> routes.io.destinations(0)
    val bridge = new Ahb5ToApb4Bridge(config)
    bridge.io.ahb <> biu.io.subordinate
    val apb =
      new Apb4Matrix(bridge.apbConfig, Seq(SizeMapping(0x1000, 0x400), SizeMapping(0x1800, 0x400)))
    apb.io.input <> bridge.io.apb
    io.peripherals <> apb.io.outputs
    // A distinct AHB domain must remain usable while APB is reserved or stalled.
    val other = new Ahb5SubordinateArbiter(config, 3)
    other.io.managers <> routes.io.destinations(1)
    val error = new Ahb5DefaultSubordinate(config)
    error.io.bus <> other.io.subordinate
  }
  case class Reply(ready: Boolean, error: Boolean, data: BigInt)
  class Rig(val dut: Probe) {
    val completed     = ArrayBuffer[(BigInt, Boolean, BigInt)]()
    val metadata      = ArrayBuffer[(Int, Int)]()
    var latency       = 3
    var failing       = BigInt(-1)
    private val waits = Array.fill(2)(0)
    private val held  = Array.fill[Option[(BigInt, Boolean, BigInt, Int, Int)]](2)(None)
    for ((b, i) <- dut.io.managers.zipWithIndex) {
      b.address.HADDR   #= 0; b.address.HTRANS    #= 0; b.address.HWRITE #= false
      b.address.HSIZE   #= 2; b.address.HBURST    #= 0; b.address.HPROT  #= 3
      b.address.HMASTER #= i; b.address.HMASTLOCK #= false
      b.HWDATA          #= 0; b.HWSTRB            #= 15
    }
    for (p <- dut.io.peripherals) { p.PREADY #= false; p.PRDATA #= 0; p.PSLVERR #= false }
    dut.clockDomain.clockSim #= false
    def edge(): Unit = {
      dut.clockDomain.clockSim #= true; sleep(5)
      dut.clockDomain.clockSim #= false; sleep(5)
    }
    dut.clockDomain.assertReset(); for (_ <- 0 until 3) edge()
    dut.clockDomain.deassertReset(); sleep(1)
    def tick(): Seq[Reply] = {
      sleep(1)
      for ((p, i) <- dut.io.peripherals.zipWithIndex) {
        val selected = p.PSEL.toInt == 1
        val access   = selected && p.PENABLE.toBoolean
        val signature =
          (p.PADDR.toBigInt, p.PWRITE.toBoolean, p.PWDATA.toBigInt, p.PSTRB.toInt, p.PPROT.toInt)
        if (selected) {
          if (!p.PENABLE.toBoolean) {
            assert(held(i).isEmpty, "APB SETUP interrupted a pending transfer")
            held(i)  = Some(signature)
            waits(i) = 0
          } else {
            assertEquals(held(i), Some(signature), "missing SETUP or changed waited APB payload")
          }
        } else assert(held(i).isEmpty, "APB transfer withdrawn before completion")
        p.PREADY #= access && waits(i) >= latency
        p.PRDATA #= (0xabc00000L | p.PADDR.toLong)
        // Errors outside a completing ACCESS must not terminate an AHB request.
        p.PSLVERR #= !access || waits(i) < latency || p.PADDR.toBigInt == failing
      }
      sleep(1)
      val replies = dut.io.managers
        .map(b => Reply(b.HREADY.toBoolean, b.HRESP.toBoolean, b.HRDATA.toBigInt))
        .toSeq
      for ((p, i) <- dut.io.peripherals.zipWithIndex if p.PSEL.toInt == 1 && p.PENABLE.toBoolean)
        if (p.PREADY.toBoolean) {
          completed += ((p.PADDR.toBigInt, p.PWRITE.toBoolean, p.PWDATA.toBigInt))
          metadata += ((p.PSTRB.toInt, p.PPROT.toInt))
          held(i) = None
        } else waits(i) += 1
      edge()
      replies
    }
    def address(
        port: Int,
        address: Int,
        write: Boolean = false,
        lock: Boolean = false,
        size: Int = 2
    ): Unit = {
      val b = dut.io.managers(port)
      b.address.HADDR  #= address; b.address.HTRANS  #= 2
      b.address.HWRITE #= write; b.address.HMASTLOCK #= lock; b.address.HSIZE #= size
    }
    def idle(port: Int, lock: Boolean = false): Unit = {
      dut.io.managers(port).address.HTRANS    #= 0
      dut.io.managers(port).address.HMASTLOCK #= lock
    }
    def finish(port: Int, fail: Boolean = false): Reply = {
      var reply       = Reply(false, false, BigInt(0))
      var errorCycles = 0
      var cycles      = 0
      while (!reply.ready && cycles < 150) {
        reply = tick()(port)
        if (reply.error) errorCycles += 1
        cycles += 1
      }
      assert(reply.ready, "AHB completion timed out")
      assertEquals(reply.error, fail)
      assertEquals(errorCycles, if (fail) 2 else 0)
      reply
    }
    def single(
        port: Int,
        addr: Int,
        write: Boolean = false,
        lock: Boolean = false,
        size: Int = 2,
        data: BigInt = 0,
        strobes: Int = 15,
        fail: Boolean = false
    ): Reply = {
      dut.io.managers(port).HWDATA #= 0xdeadbeefL
      address(port, addr, write, lock, size)
      assert(tick()(port).ready)
      idle(port, lock)
      dut.io.managers(port).HWDATA #= data
      dut.io.managers(port).HWSTRB #= strobes
      finish(port, fail)
    }
  }
  private def run(body: Rig => Unit): Unit =
    SimConfig.withVerilator.compile(new Probe).doSim(dut => body(new Rig(dut)))

  test("AHB/APB phases, wait states, data ownership, unmapped and peripheral errors") {
    run { r =>
      r.single(0, 0x1000, write = true, data = 0x12345678)
      assertEquals(r.completed.toSeq, Seq((BigInt(0x1000), true, BigInt(0x12345678))))
      assertEquals(r.single(1, 0x1800).data, BigInt(0xabc01800L))
      r.failing = 0x1804
      r.single(0, 0x1804, fail = true)
      val before = r.completed.size
      r.single(0, 0x1400, fail = true) // hole inside APB domain
      r.single(0, 0x9000, fail = true) // hole outside AHB domains
      r.single(0, 0x1000, size = 3, fail = true)
      r.single(0, 0x1001, size = 1, fail = true)
      r.single(0, 0x1001, fail = true)
      assertEquals(r.completed.size, before, "unsupported access touched APB")
      for (offset <- 0 until 4) {
        r.single(0, 0x1000 + offset, write = true, size = 0, data = 0x11223344)
        assertEquals(r.completed.last._1, BigInt(0x1000))
        assertEquals(r.metadata.last, (1 << offset, 1))
      }
      r.single(0, 0x1002, size = 1)
      assertEquals(r.metadata.last, (0, 1))
      r.single(0, 0x1000, write = true, strobes = 5)
      assertEquals(r.metadata.last, (5, 1))
      r.single(2, 0x1004)
      // A response-completion edge also accepts the following address.
      r.address(0, 0x1008); r.tick()
      r.address(0, 0x1808); r.finish(0)
      r.idle(0); r.finish(0)
      assertEquals(r.completed.takeRight(2).map(_._1).toSeq, Seq(BigInt(0x1008), BigInt(0x1808)))
    }
  }
  test("standalone BIU reserves the whole APB domain through IDLE gaps and releases on HREADY") {
    run { r =>
      r.single(0, 0x1000, lock = true)
      r.address(1, 0x1800); r.tick(); r.idle(1)
      for (_ <- 0 until 10) assert(!r.tick()(1).ready)
      // Other domain's ERROR can complete while the peripheral domain is locked.
      r.single(2, 0x3000, fail = true)
      assertEquals(r.completed.size, 1)
      r.single(0, 0x1804, write = true, lock = true, data = 0x80)
      assertEquals(r.completed.map(_._1).toSeq, Seq(BigInt(0x1000), BigInt(0x1804)))
      r.idle(0)
      r.finish(1)
      assertEquals(r.completed.last._1, BigInt(0x1800))
      r.single(2, 0x1000)
    }
  }
}
