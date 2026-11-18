package j2.board

import j2.board.wukong.WukongV1
import j2.soc.J2Soc
import spinal.core._
import spinal.core.sim._

/** Platform-ROM smoke test; board PLL/pads are checked separately by Vivado. */
object WukongSmokeSim extends App {
  val config =
    WukongV1.load("../fpga/wukong-v1/board.properties", "../build/wukong-v1/rom/boot.hex")
  var probe: j2.core.J2MicrocodedCore = null
  val compiled = SimConfig.withVerilator
    .withConfig(SpinalConfig(defaultClockDomainFrequency = FixedFrequency(config.clockHz Hz)))
    .compile {
      val dut = new J2Soc(config)
      probe = dut.children.collectFirst { case cpu: j2.core.J2MicrocodedCore => cpu }.get
      probe.io.ibus.simPublic()
      probe.io.dbus.simPublic()
      dut
    }
  for (seed <- Seq(1854751661, 2062956257, 42)) compiled.doSim(seed = seed) { dut =>
    dut.io.uartRx            #= true
    dut.io.gpio.read         #= 0
    dut.io.spiData.read      #= 15
    dut.io.memory.ACK        #= false
    dut.io.memory.ERR        #= false
    dut.io.memory.DAT_MISO   #= 0
    dut.clockDomain.clockSim #= false
    dut.clockDomain.assertReset()
    // Seed 2 models FPGA-only restart with flash still in quad protocol.
    val flash = new Sf3Model(dut, initiallyQuad = seed == 2062956257)
    fork {
      while (true) {
        sleep(5)
        flash.tick()
        dut.clockDomain.clockSim #= true
        sleep(5)
        flash.tick()
        dut.clockDomain.clockSim #= false
      }
    }
    sleep(101)
    dut.clockDomain.deassertReset()
    dut.clockDomain.waitSampling(2)
    fork {
      waitUntil(dut.io.memory.CYC.toBoolean)
      simFailure("platform ROM accessed the absent DDR backend")
    }
    val received  = new StringBuilder
    val bitPeriod = (config.clockHz / (19200 * 5)) * 5 * 10L
    fork {
      while (true) {
        waitUntil(!dut.io.uartTx.toBoolean)
        sleep(bitPeriod + bitPeriod / 2)
        var value = 0
        for (bit <- 0 until 8) {
          if (dut.io.uartTx.toBoolean) value |= 1 << bit
          sleep(bitPeriod)
        }
        assert(dut.io.uartTx.toBoolean, "UART stop bit")
        received.append(value.toChar)
      }
    }
    val expected =
      s"Wukong-v1 platform ROM\r\nApplication flash offset: ${config.flashOffset.toString(16).reverse.padTo(8, '0').reverse}\r\nSF3 quad ID: 20ba19\r\nSF3 quad XIP: PASS\r\nDDR3 and application boot pending\r\n"
    fork {
      sleep(60000000L)
      simFailure(
        s"platform ROM UART timeout: $received; IF=${probe.io.ibus.ADR.toLong.toHexString}, data=${probe.io.dbus.ADR.toLong.toHexString}"
      )
    }
    waitUntil(received.length >= expected.length)
    assert(received.toString == expected, received.toString)
    // Exercise the independently built ROM's stack and UART receive path too.
    sleep(bitPeriod)
    dut.io.uartRx #= false
    sleep(bitPeriod)
    for (bit <- 0 until 8) {
      dut.io.uartRx #= ((0x5a >> bit) & 1) != 0
      sleep(bitPeriod)
    }
    dut.io.uartRx #= true
    waitUntil(received.length > expected.length)
    assert(received.last == 'Z')
    assert(flash.quad && flash.quadIds >= 1)
    assert(flash.quadReads.toSeq == Seq(0L, 32L, 0x100L, 0x800L, config.xipBytes.toLong - 32))
    println(
      "WUKONG_ROM_PASS: banner, partition offset, SF3 quad ID and XIP, UART echo; no DDR accesses"
    )
  }
}
