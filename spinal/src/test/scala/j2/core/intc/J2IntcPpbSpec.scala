package j2.core.intc

import j2.bus.J2Ahb
import j2.core.ppb._
import spinal.core._
import spinal.core.sim._
import spinal.lib._

class J2IntcPpbSpec extends munit.FunSuite {
  class Probe extends Component {
    val io = new Bundle {
      val bus       = slave(J2Ahb.manager())
      val candidate = master(Flow(new IntcCandidate))
      val accept    = in Bool ()
    }
    val fabric = new J2PpbFabric
    val intc   = new J2Intc(IntcConfig(6))
    J2Ahb.connect(io.bus, fabric.io.bus)
    // INTC base is 0x100 into a 512-byte boundary: truncating absolute PADDR would
    // swap the control and priority regions. Translate before reducing the width.
    val source = fabric.io.intc
    val target = intc.io.bus
    target.PADDR      := (source.PADDR - U(J2Ppb.intc.base, 32 bits)).resized
    target.PSEL       := source.PSEL
    target.PENABLE    := source.PENABLE
    target.PWRITE     := source.PWRITE
    target.PWDATA     := source.PWDATA
    target.PSTRB      := source.PSTRB
    target.PPROT      := source.PPROT
    source.PREADY     := target.PREADY
    source.PSLVERR    := target.PSLVERR
    source.PRDATA     := target.PRDATA
    intc.io.requests  := 0
    intc.io.nmi       := True
    intc.io.maskLevel := 0
    intc.io.accept    := io.accept
    io.candidate <> intc.io.candidate
  }

  test("PPB base translation and BE32 bridge reach the correct INTC banks") {
    SimConfig.withVerilator.compile(new Probe).doSim { dut =>
      val b = dut.io.bus
      dut.clockDomain.clockSim #= false
      b.address.HADDR          #= 0; b.address.HTRANS    #= 0; b.address.HWRITE #= false
      b.address.HSIZE          #= 2; b.address.HBURST    #= 0; b.address.HPROT  #= 3
      b.address.HMASTER        #= 1; b.address.HMASTLOCK #= false; b.HWDATA     #= 0
      dut.io.accept            #= false
      def edge(): Unit = {
        dut.clockDomain.clockSim #= true; sleep(5)
        dut.clockDomain.clockSim #= false; sleep(5)
      }
      dut.clockDomain.assertReset(); for (_ <- 0 until 4) edge()
      dut.clockDomain.deassertReset(); for (_ <- 0 until 6) edge()
      def access(
          offset: Int,
          write: Boolean = false,
          data: Long = 0,
          size: Int = 2,
          error: Boolean = false
      ): Long = {
        b.address.HADDR  #= (0xffffe900L + offset); b.address.HWRITE #= write
        b.address.HTRANS #= 2; b.address.HSIZE                       #= size
        sleep(1); assert(b.HREADY.toBoolean); edge()
        b.address.HTRANS #= 0; b.HWDATA #= data
        var cycles = 0
        while ({ sleep(1); !b.HREADY.toBoolean } && cycles < 12) { edge(); cycles += 1 }
        assert(cycles < 12); assertEquals(b.HRESP.toBoolean, error)
        val result = b.HRDATA.toLong
        edge(); result
      }
      assertEquals(access(0), 1L)
      access(0x10, write = true, data = 0xffffffffL)
      assertEquals(access(0x30), 63L)
      access(0x100, write = true, data = 0xffedcba9L)
      assertEquals(access(0x100), 0xedcba9L)
      access(0x50, write = true, data = 32)
      assertEquals(access(0x70), 32L)
      assert(dut.io.candidate.valid.toBoolean)
      assertEquals(dut.io.candidate.payload.vector.toInt, 69)
      assertEquals(dut.io.candidate.payload.level.toInt, 14)
      dut.io.accept #= true; edge(); dut.io.accept #= false
      assertEquals(access(0x50), 0L)
      access(0x10, write = true, data = 0xffffffffL, size = 0, error = true)
      assertEquals(access(0x30), 63L)
      access(0x28, write = true, data = 0xffffffffL) // future bank word 6
      assertEquals(access(0x28), 0L)
    }
  }
}
