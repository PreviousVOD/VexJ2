package j2.bus

import j2.bus.ahb5._
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.misc.SizeMapping

class J2AhbBoundarySpec extends munit.FunSuite {
  test("leaf adapter captures write data in its own phase and returns exactly two ERROR cycles") {
    class Probe extends Component {
      val io = new Bundle {
        val bus = slave(J2Ahb.manager())
        val wb  = master(J2Wishbone())
      }
      val bridge = new J2AhbToWishbone
      J2Ahb.connect(io.bus, bridge.io.ahb)
      io.wb <> bridge.io.wb
    }
    SimConfig.withVerilator.compile(new Probe).doSim { dut =>
      val b = dut.io.bus
      val w = dut.io.wb
      b.address.HADDR          #= 0; b.address.HTRANS    #= 0; b.address.HWRITE #= false
      b.address.HSIZE          #= 2; b.address.HBURST    #= 0; b.address.HPROT  #= 11
      b.address.HMASTER        #= 1; b.address.HMASTLOCK #= false; b.HWDATA     #= 0
      w.ACK                    #= false; w.ERR           #= false; w.DAT_MISO   #= 0
      dut.clockDomain.clockSim #= false
      def edge(): Unit = {
        sleep(1); dut.clockDomain.clockSim #= true; sleep(5)
        dut.clockDomain.clockSim           #= false; sleep(5)
      }
      dut.clockDomain.assertReset(); edge(); edge(); dut.clockDomain.deassertReset(); sleep(1)
      for (
        (address, size, select) <- Seq(
          (0x100, 0, 8),
          (0x101, 0, 4),
          (0x102, 0, 2),
          (0x103, 0, 1),
          (0x100, 1, 12),
          (0x102, 1, 3),
          (0x100, 2, 15)
        )
      ) {
        assert(b.HREADY.toBoolean)
        b.address.HADDR  #= address; b.address.HSIZE #= size
        b.address.HTRANS #= 2; b.address.HWRITE      #= true
        b.HWDATA         #= 0xdeadbeefL // previous transfer's data during address phase
        edge()
        b.address.HTRANS #= 0; b.HWDATA #= 0x12345678
        edge()
        for (_ <- 0 until 3) {
          assert(!b.HREADY.toBoolean && w.CYC.toBoolean && w.STB.toBoolean)
          assertEquals(w.ADR.toBigInt, BigInt(address)); assertEquals(w.SEL.toInt, select)
          assertEquals(w.DAT_MOSI.toBigInt, BigInt(0x12345678))
          edge()
        }
        w.ACK #= true; edge(); w.ACK #= false
        assert(b.HREADY.toBoolean && !b.HRESP.toBoolean)
        assert(!w.STB.toBoolean) // no duplicate request during buffered response
        edge()
      }
      b.address.HTRANS #= 2; b.address.HWRITE #= false; edge()
      b.address.HTRANS #= 0; edge()
      w.ERR            #= true; w.ACK         #= true; edge(); w.ERR #= false; w.ACK #= false
      assert(!b.HREADY.toBoolean && b.HRESP.toBoolean && !w.STB.toBoolean)
      edge(); assert(b.HREADY.toBoolean && b.HRESP.toBoolean)
      // Accept a new address on the previous response's completion edge.
      b.address.HTRANS #= 2; b.address.HADDR #= 0x200; edge()
      b.address.HTRANS #= 0; edge()
      assertEquals(w.ADR.toBigInt, BigInt(0x200))
      w.ACK #= true; w.DAT_MISO #= 0x89abcdefL; edge(); w.ACK #= false
      assert(b.HREADY.toBoolean && !b.HRESP.toBoolean)
      assertEquals(b.HRDATA.toBigInt, BigInt(0x89abcdefL))
      edge()
    }
  }

  test(
    "peripheral decoder qualifies address selection with HSEL and retains stalled data selection"
  ) {
    class Probe extends Component {
      val io = new Bundle {
        val bus      = slave(J2Ahb.manager())
        val selected = in Bool ()
        val outputs  = Vec(master(J2Ahb.subordinate()), 2)
      }
      val decoder =
        new Ahb5SubordinateDecoder(J2Ahb.config, Seq(SizeMapping(0, 4096), SizeMapping(4096, 4096)))
      J2Ahb.connect(io.bus, decoder.io.input)
      decoder.io.input.HSEL.allowOverride := io.selected
      io.outputs <> decoder.io.outputs
    }
    SimConfig.withVerilator.compile(new Probe).doSim { dut =>
      val b = dut.io.bus
      b.address.HADDR   #= 0; b.address.HTRANS    #= 0; b.address.HWRITE #= false
      b.address.HSIZE   #= 2; b.address.HBURST    #= 0; b.address.HPROT  #= 3
      b.address.HMASTER #= 1; b.address.HMASTLOCK #= false; b.HWDATA     #= 0
      dut.io.selected   #= false
      for ((out, i) <- dut.io.outputs.zipWithIndex) {
        out.HREADYOUT #= true; out.HRESP #= false; out.HRDATA #= (100 + i)
      }
      dut.clockDomain.clockSim #= false
      def edge(): Unit = {
        sleep(1); dut.clockDomain.clockSim #= true; sleep(5)
        dut.clockDomain.clockSim           #= false; sleep(5)
      }
      dut.clockDomain.assertReset(); edge(); edge(); dut.clockDomain.deassertReset(); sleep(1)
      b.address.HTRANS #= 2; edge()
      assert(dut.io.outputs.forall(!_.HSEL.toBoolean))
      assert(!b.HRESP.toBoolean && b.HREADY.toBoolean)
      dut.io.selected             #= true; edge()
      b.address.HADDR             #= 0x1000
      dut.io.outputs(0).HREADYOUT #= false; sleep(1)
      assert(!b.HREADY.toBoolean && b.HRDATA.toInt == 100)
      edge(); assertEquals(b.HRDATA.toInt, 100)
      dut.io.outputs(0).HREADYOUT #= true; edge()
      assertEquals(b.HRDATA.toInt, 101)
      b.address.HADDR #= 0x9000; edge(); b.address.HTRANS #= 0; sleep(1)
      assert(!b.HREADY.toBoolean && b.HRESP.toBoolean)
      edge(); assert(b.HREADY.toBoolean && b.HRESP.toBoolean)
      edge(); assert(b.HREADY.toBoolean && !b.HRESP.toBoolean)
      // HSEL must survive IDLE for downstream reservation acquisition.
      b.address.HADDR #= 0; b.address.HMASTLOCK #= true; sleep(1)
      assert(dut.io.outputs(0).HSEL.toBoolean && dut.io.outputs(0).address.HMASTLOCK.toBoolean)
    }
  }
}
