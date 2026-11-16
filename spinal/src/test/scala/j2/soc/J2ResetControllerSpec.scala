package j2.soc

import spinal.core._
import spinal.core.sim._

class J2ResetControllerSpec extends munit.FunSuite {
  test("cold boot, PLL lock loss and button reset release only on system clock edges") {
    SimConfig.withVerilator.compile(new J2ResetController(powerOnBits = 3)).doSim { dut =>
      dut.io.referenceClock #= false
      dut.io.systemClock    #= false
      dut.io.resetN         #= true // Never assert the button during power-up.
      dut.io.clockLocked    #= true
      sleep(2)

      def systemTick(): Unit = {
        dut.io.systemClock #= true
        sleep(2)
        dut.io.systemClock #= false
        sleep(2)
      }
      systemTick()
      assert(dut.io.reset.toBoolean)
      for (_ <- 0 until 7) {
        dut.io.referenceClock #= true
        sleep(2)
        dut.io.referenceClock #= false
        sleep(2)
        assert(dut.io.reset.toBoolean)
      }
      def release(): Unit = {
        for (_ <- 0 until 2) {
          systemTick()
          assert(dut.io.reset.toBoolean)
        }
        systemTick()
        assert(!dut.io.reset.toBoolean)
      }
      release()

      // A late or lost lock asserts reset even if the PLL stops its clock.
      dut.io.clockLocked #= false
      sleep(2)
      assert(dut.io.reset.toBoolean)
      for (_ <- 0 until 5) systemTick()
      assert(dut.io.reset.toBoolean)
      dut.io.clockLocked #= true
      sleep(2)
      assert(dut.io.reset.toBoolean)
      release()

      dut.io.resetN #= false
      sleep(2)
      assert(dut.io.reset.toBoolean)
      dut.io.resetN #= true
      sleep(2)
      assert(dut.io.reset.toBoolean)
      release()
    }
  }
}
