package j2.bus.apb

import j2.bus.ahb5._
import spinal.core._
import spinal.core.sim._
import spinal.lib._

class Apb4Spec extends munit.FunSuite {
  class Registers extends Component {
    val io = new Bundle {
      val bus    = slave(Apb4(Apb4Config(8, 32)))
      val stall  = in Bool ()
      val writes = out UInt (8 bits)
    }
    val factory = Apb4SlaveFactory(io.bus)
    val low     = factory.createReadAndWrite(Bits(16 bits), 0, 0) init (0)
    val high    = factory.createReadAndWrite(Bits(16 bits), 0, 16) init (0)
    val w1c     = Reg(Bits(32 bits)) init (BigInt("ffffffff", 16))
    val w0c     = Reg(Bits(32 bits)) init (BigInt("ffffffff", 16))
    val w1s     = Reg(Bits(32 bits)) init (0)
    val w0s     = Reg(Bits(32 bits)) init (0)
    factory.readAndClearOnSet(w1c, 4)
    factory.withOffset(4).withOffset(4).clearOnClear(w0c, 0); factory.read(w0c, 8)
    factory.readAndSetOnSet(w1s, 12)
    factory.withOffset(16).setOnClear(w0s, 0); factory.read(w0s, 16)
    val count = Reg(UInt(8 bits)) init (0)
    factory.requireWriteStrobes(20, 3)
    factory.onWrite(20)(count := count + 1)
    factory.read(count, 20)
    io.writes := count
    when(io.stall) {
      when(io.bus.PWRITE)(factory.writeHalt()) otherwise factory.readHalt()
    }
  }

  test("APB4 register masks, packed halfwords, flag helpers, empty writes and command effects") {
    SimConfig.withVerilator.compile(new Registers).doSim { dut =>
      val b = dut.io.bus
      dut.clockDomain.clockSim #= false
      b.PSEL                   #= 0; b.PENABLE #= false; b.PADDR #= 0; b.PWRITE     #= false
      b.PWDATA                 #= 0; b.PSTRB   #= 0; b.PPROT     #= 0; dut.io.stall #= false
      def edge(): Unit = {
        dut.clockDomain.clockSim #= true; sleep(5)
        dut.clockDomain.clockSim #= false; sleep(5)
      }
      dut.clockDomain.assertReset(); for (_ <- 0 until 3) edge()
      dut.clockDomain.deassertReset(); sleep(1)
      def access(
          address: Int,
          write: Boolean = false,
          data: Long = 0,
          mask: Int = 15,
          error: Boolean = false,
          waits: Int = 0
      ): Long = {
        b.PSEL   #= 1; b.PENABLE  #= false; b.PADDR #= address; b.PWRITE #= write
        b.PWDATA #= data; b.PSTRB #= (if (write) mask else 0)
        val before = dut.io.writes.toInt
        edge(); b.PENABLE #= true; dut.io.stall #= (waits != 0)
        for (_ <- 0 until waits) {
          sleep(1); assert(!b.PREADY.toBoolean); assert(!b.PSLVERR.toBoolean)
          edge(); assertEquals(dut.io.writes.toInt, before)
        }
        dut.io.stall #= false; sleep(1)
        assert(b.PREADY.toBoolean); assertEquals(b.PSLVERR.toBoolean, error)
        val result = b.PRDATA.toLong
        edge(); b.PSEL #= 0; b.PENABLE #= false; sleep(1)
        result
      }
      access(0, true, 0x11223344L)
      access(0, true, 0xaabbccddL, 3)
      assertEquals(access(0), 0x1122ccddL)
      access(0, true, 0x55667788L, 12)
      assertEquals(access(0), 0x5566ccddL)
      var expected = 0x5566ccddL
      for (mask <- 0 until 16) {
        val data = (0x1020304L * (mask + 1)) & 0xffffffffL
        val bitMask = (0 until 4)
          .filter(i => (mask & (1 << i)) != 0)
          .map(i => 0xffL << (8 * i))
          .foldLeft(0L)(_ | _)
        access(0, true, data, mask)
        expected = (expected & ~bitMask) | (data & bitMask)
        assertEquals(access(0), expected)
      }
      access(4, true, 0xffffffffL, 2); assertEquals(access(4), 0xffff00ffL)
      access(8, true, 0, 4); assertEquals(access(8), 0xff00ffffL)
      access(12, true, 0xffffffffL, 8); assertEquals(access(12), 0xff000000L)
      access(16, true, 0, 1); assertEquals(access(16), 0xffL)
      access(20, true, 0, 0); assertEquals(access(20), 0L)
      access(20, true, 0, 1, error = true); assertEquals(access(20), 0L)
      access(20, true, 0, 3, waits = 4); assertEquals(access(20), 1L)
      access(1, true, 0, error     = true); assertEquals(access(0), expected)
      access(1, error              = true)
    }
  }

  class BridgeProbe(config: Ahb5Config, wordInvariantBigEndian: Boolean) extends Component {
    val io = new Bundle {
      val ahb = slave(Ahb5Master(config))
      val apb = master(Apb4(Apb4Config(config.addressWidth, config.dataWidth)))
    }
    val bridge = new Ahb5ToApb4Bridge(config, wordInvariantBigEndian)
    bridge.io.ahb.address                         := io.ahb.address
    bridge.io.ahb.HWDATA                          := io.ahb.HWDATA
    if (config.writeStrobes) bridge.io.ahb.HWSTRB := io.ahb.HWSTRB
    bridge.io.ahb.HSEL                            := True
    bridge.io.ahb.HREADY                          := bridge.io.ahb.HREADYOUT
    io.ahb.HREADY                                 := bridge.io.ahb.HREADYOUT
    io.ahb.HRESP                                  := bridge.io.ahb.HRESP
    io.ahb.HRDATA                                 := bridge.io.ahb.HRDATA
    io.apb <> bridge.io.apb
  }
  for (
    width <- Seq(8, 16, 32);
    wordInvariantBigEndian <- (if (width == 32) Seq(false, true) else Seq(false))
  )
    test(
      s"AHB5/APB4 $width-bit endian=$wordInvariantBigEndian lanes, protection and waited payload"
    ) {
      val config = Ahb5Config(dataWidth = width, writeStrobes = true, secureTransfers = true)
      SimConfig.withVerilator.compile(new BridgeProbe(config, wordInvariantBigEndian)).doSim {
        dut =>
          val a = dut.io.ahb
          val p = dut.io.apb
          a.address.HADDR          #= 0; a.address.HTRANS    #= 0; a.address.HWRITE      #= false
          a.address.HSIZE          #= 0; a.address.HBURST    #= 0; a.address.HPROT       #= 0
          a.address.HMASTER        #= 0; a.address.HMASTLOCK #= false; a.address.HNONSEC #= false
          a.HWDATA                 #= 0; a.HWSTRB            #= 0
          p.PREADY                 #= false; p.PRDATA        #= 0; p.PSLVERR             #= false
          dut.clockDomain.clockSim #= false
          def edge(): Unit = {
            dut.clockDomain.clockSim #= true; sleep(5)
            dut.clockDomain.clockSim #= false; sleep(5)
          }
          dut.clockDomain.assertReset(); for (_ <- 0 until 3) edge()
          dut.clockDomain.deassertReset(); sleep(1)
          val full    = (1 << config.bytes) - 1
          val payload = 0x87654321L & ((1L << width) - 1)
          for (
            size <- 0 to log2Up(config.bytes); offset <- 0 until config.bytes by (1 << size);
            write <- Seq(false, true); mask <- Seq(0, full, full & 5); prot <- 0 until 8
          ) {
            a.address.HADDR   #= (0x100 + offset); a.address.HTRANS #= 2
            a.address.HWRITE  #= write; a.address.HSIZE             #= size
            a.address.HPROT   #= (((prot & 1) << 1) | (if ((prot & 4) == 0) 1 else 0))
            a.address.HNONSEC #= ((prot & 2) != 0)
            sleep(1); assert(a.HREADY.toBoolean); edge()
            a.address.HTRANS #= 0; a.address.HADDR   #= 0x200
            a.address.HPROT  #= 0; a.address.HNONSEC #= false
            a.HWDATA         #= payload; a.HWSTRB    #= mask
            edge()
            val lane   = if (wordInvariantBigEndian) config.bytes - (1 << size) - offset else offset
            val strobe = if (write) (((1 << (1 << size)) - 1) << lane) & mask else 0
            def check(): Unit = {
              assertEquals(p.PSEL.toInt, 1); assertEquals(p.PADDR.toLong, 0x100L)
              assertEquals(p.PWRITE.toBoolean, write); assertEquals(p.PWDATA.toLong, payload)
              assertEquals(p.PSTRB.toInt, strobe); assertEquals(p.PPROT.toInt, prot)
            }
            check(); assert(!p.PENABLE.toBoolean); edge()
            for (_ <- 0 until 3) {
              check(); assert(p.PENABLE.toBoolean); assert(!a.HREADY.toBoolean); edge()
            }
            p.PRDATA #= payload; p.PREADY #= true; edge()
            assert(a.HREADY.toBoolean); assert(!a.HRESP.toBoolean)
            assertEquals(a.HRDATA.toLong, payload)
            p.PREADY #= false; edge()
          }
      }
    }
}
