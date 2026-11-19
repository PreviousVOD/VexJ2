package j2.core.ppb

import j2.bus.J2Ahb
import j2.bus.apb._
import spinal.core._
import spinal.core.sim._
import spinal.lib._

class J2PpbSpec extends munit.FunSuite {
  class Probe extends Component {
    val io = new Bundle {
      val bus      = slave(J2Ahb.manager())
      val external = master(J2Ahb.manager())
      val intc     = master(Apb4(Apb4Config(32, 32)))
    }
    val router = new J2PpbRouter
    val fabric = new J2PpbFabric
    router.io.input <> io.bus
    io.external <> router.io.external
    fabric.io.bus <> router.io.privateBus
    io.intc <> fabric.io.intc
  }

  test("private access checks, APB waits/errors, response ownership and lock isolation") {
    SimConfig.withVerilator.compile(new Probe).doSim { dut =>
      val b = dut.io.bus
      val e = dut.io.external
      val p = dut.io.intc
      dut.clockDomain.clockSim #= false
      b.address.HADDR          #= 0; b.address.HTRANS    #= 0; b.address.HWRITE #= false
      b.address.HSIZE          #= 2; b.address.HBURST    #= 0; b.address.HPROT  #= 3
      b.address.HMASTER        #= 1; b.address.HMASTLOCK #= false; b.HWDATA     #= 0
      e.HREADY                 #= true; e.HRESP          #= false; e.HRDATA     #= 0x12345678L
      p.PREADY                 #= true; p.PSLVERR        #= false; p.PRDATA     #= 0
      def edge(): Unit = {
        dut.clockDomain.clockSim #= true; sleep(5)
        dut.clockDomain.clockSim #= false; sleep(5)
      }
      def reset(): Unit = {
        dut.clockDomain.assertReset(); for (_ <- 0 until 3) edge()
        dut.clockDomain.deassertReset(); sleep(1)
      }
      def address(
          addr: Long,
          size: Int = 2,
          write: Boolean = false,
          lock: Boolean = false,
          prot: Int = 3
      ): Unit = {
        b.address.HADDR  #= addr; b.address.HSIZE      #= size
        b.address.HWRITE #= write; b.address.HMASTLOCK #= lock
        b.address.HPROT  #= prot; b.address.HTRANS     #= 2
        sleep(1)
      }
      def isolated(): Unit = {
        assertEquals(e.address.HTRANS.toInt, 0)
        assert(!e.address.HMASTLOCK.toBoolean)
      }
      reset()
      // Consecutive external instruction addresses/data pass without an added clock cycle,
      // including the words immediately before and after the execute-never aperture.
      for (addr <- Seq(0x1000L, 0x1004L, 0xffffdffcL, 0xfffff000L)) {
        address(addr, prot = 10)
        assert(b.HREADY.toBoolean)
        assertEquals(e.address.HTRANS.toInt, 2)
        assertEquals(e.address.HADDR.toLong, addr)
        assertEquals(e.address.HPROT.toInt, 10)
        assertEquals(b.HRDATA.toLong, 0x12345678L)
        assertEquals(p.PSEL.toInt, 0)
        edge()
      }
      b.address.HTRANS #= 0; edge()
      // Every reserved word succeeds. Invalid widths/alignment/protection never reach APB.
      val cases = (0 until 0x200 by 4).map(i => (0xffffe900L + i, 2, 3, false)) ++ Seq(
        (0xffffe900L, 0, 3, true),
        (0xffffe900L, 1, 3, true),
        (0xffffe901L, 2, 3, true),
        (0xffffe902L, 2, 3, true),
        (0xffffe900L, 3, 3, true),
        (0xffffe900L, 2, 2, true),
        (0xffffe000L, 2, 3, true),
        (0xffffe8fcL, 2, 3, true),
        (0xffffeb00L, 2, 3, true),
        (0xffffeffcL, 2, 3, true)
      )
      for ((addr, size, prot, error) <- cases; write <- Seq(false, true)) {
        address(addr, size, write, lock = true, prot = prot)
        assert(b.HREADY.toBoolean); isolated(); edge()
        b.address.HTRANS #= 0; b.HWDATA #= 0xdeadbeefL
        var clocks       = 0
        var errorCycles  = 0
        var apbTransfers = 0
        while ({ sleep(1); !b.HREADY.toBoolean } && clocks < 12) {
          isolated()
          if (b.HRESP.toBoolean) errorCycles += 1
          if (p.PSEL.toInt != 0 && p.PENABLE.toBoolean) {
            apbTransfers += 1
            assertEquals(p.PADDR.toLong, addr)
            assertEquals(p.PWRITE.toBoolean, write)
            assertEquals(p.PSTRB.toInt, if (write) 15 else 0)
            if (write) assertEquals(p.PWDATA.toLong, 0xdeadbeefL)
          }
          edge(); clocks += 1
        }
        assert(clocks < 12); isolated()
        assertEquals(b.HRESP.toBoolean, error)
        assertEquals(errorCycles, if (error) 1 else 0, "two-cycle AHB ERROR")
        assertEquals(apbTransfers, if (error) 0 else 1)
        if (!error) assertEquals(b.HRDATA.toLong, 0L)
        edge()
      }

      // External data waits while the next address points at PPB; no early APB request.
      address(0x1000, lock = true); assert(b.HREADY.toBoolean); edge()
      e.HREADY #= false
      address(0xffffe900L)
      for (_ <- 0 until 4) {
        assert(!b.HREADY.toBoolean); assertEquals(b.HRDATA.toLong, 0x12345678L)
        assertEquals(p.PSEL.toInt, 0); isolated(); edge()
      }
      e.HREADY #= true; sleep(1)
      assert(b.HREADY.toBoolean); assertEquals(b.HRDATA.toLong, 0x12345678L)
      edge() // external completion and private address acceptance
      p.PREADY #= false; p.PRDATA #= 0x89abcdefL
      address(0x2000, write = true, lock = true)
      b.HWDATA #= 0x11223344L
      for (_ <- 0 until 6) {
        assert(!b.HREADY.toBoolean); isolated(); edge()
      }
      assertEquals(p.PADDR.toLong, 0xffffe900L)
      assert(p.PENABLE.toBoolean)
      // Even once APB completes, an unready external port must not lose the next address.
      e.HREADY #= false; p.PREADY #= true; edge()
      assert(!b.HREADY.toBoolean)
      assertEquals(b.HRDATA.toLong, 0x89abcdefL)
      edge()
      e.HREADY #= true; sleep(1)
      assert(b.HREADY.toBoolean); assertEquals(e.address.HTRANS.toInt, 2)
      assert(e.address.HMASTLOCK.toBoolean)
      edge() // private completion and external address acceptance
      b.address.HTRANS #= 0; b.HWDATA     #= 0xaabbccddL
      e.HREADY         #= false; e.HRDATA #= 0x76543210L; sleep(1)
      assert(!b.HREADY.toBoolean); assertEquals(e.HWDATA.toLong, 0xaabbccddL)
      assertEquals(b.HRDATA.toLong, 0x76543210L)
      edge(); e.HREADY #= true; edge()

      // APB errors retain ownership even with an external next address.
      address(0xffffe900L); edge()
      address(0x3000); p.PSLVERR #= true
      var cycles = 0
      var errors = 0
      while ({ sleep(1); !b.HREADY.toBoolean } && cycles < 12) {
        isolated()
        if (b.HRESP.toBoolean) errors += 1
        edge(); cycles += 1
      }
      assert(cycles < 12); assertEquals(errors, 1); assert(b.HRESP.toBoolean)
      b.address.HTRANS #= 0; edge(); p.PSLVERR #= false

      // Reset an in-flight private transfer; it must not leave a stale response or lock.
      address(0xffffe900L, lock = true); edge(); p.PREADY #= false
      b.address.HTRANS                                    #= 0; edge(); edge(); isolated()
      reset()
      p.PREADY #= true; b.address.HMASTLOCK #= false
      address(0x4000); assert(b.HREADY.toBoolean); edge()
      b.address.HTRANS #= 0; sleep(1)
      assertEquals(b.HRDATA.toLong, 0x76543210L); assert(!b.HRESP.toBoolean)
    }
  }
}
