package j2.periph

import spinal.core._
import spinal.core.sim._

class J2UartSpec extends munit.FunSuite {
  test("APB4 UART only enqueues selected payload bytes") {
    SimConfig.withVerilator
      .withConfig(SpinalConfig(defaultClockDomainFrequency = FixedFrequency(4000000 Hz)))
      .compile(new J2Uart(10000))
      .doSim { dut =>
        val b = dut.io.bus
        b.PSEL                   #= 0; b.PENABLE #= false; b.PWRITE #= false; b.PADDR     #= 0
        b.PWDATA                 #= 0; b.PSTRB   #= 0; b.PPROT      #= 0; dut.io.uart.rxd #= true
        dut.clockDomain.clockSim #= false
        def tick(): Unit = {
          dut.clockDomain.clockSim #= true; sleep(5)
          dut.clockDomain.clockSim #= false; sleep(5)
        }
        dut.clockDomain.assertReset(); for (_ <- 0 until 3) tick()
        dut.clockDomain.deassertReset(); tick()
        def access(address: Int, write: Boolean = false, mask: Int = 0, error: Boolean = false)
            : Long = {
          b.PSEL    #= 1; b.PENABLE  #= false; b.PWRITE #= write; b.PADDR #= address
          b.PWDATA  #= 0x41; b.PSTRB #= mask; tick()
          b.PENABLE #= true; sleep(1)
          assert(b.PREADY.toBoolean); assertEquals(b.PSLVERR.toBoolean, error)
          val data = b.PRDATA.toLong
          tick(); b.PSEL #= 0; b.PENABLE #= false; tick()
          data
        }
        assertEquals((access(4) >> 16) & 255, 32L)
        access(0, true, 0)
        access(0, true, 8, error = true)
        for (_ <- 0 until 20) tick()
        assert(dut.io.uart.txd.toBoolean)
        assertEquals((access(4) >> 16) & 255, 32L)
        access(0, true, 1); access(0, true, 3); access(0, true, 15)
        for (_ <- 0 until 3) {
          var waits = 0
          while (dut.io.uart.txd.toBoolean && waits < 5000) { tick(); waits += 1 }
          assert(waits < 5000, "UART TX did not start")
          for (_ <- 0 until 600) tick() // 1.5 bits at 4 MHz / 10 kbaud.
          var data = 0
          for (bit <- 0 until 8) {
            if (dut.io.uart.txd.toBoolean) data |= 1 << bit
            for (_ <- 0 until 400) tick()
          }
          assertEquals(data, 0x41)
          assert(dut.io.uart.txd.toBoolean, "UART stop bit")
        }
        for (_ <- 0 until 500) tick()
        assertEquals((access(4) >> 16) & 255, 32L)
      }
  }
}
