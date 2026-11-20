package j2.board

import java.nio.file.{Files, Paths}
import spinal.core._
import spinal.core.sim._

/** Same boot/loader code as hardware, using separately built fast-UART images. */
object WukongBootSim extends App {
  val config = BoardProfile
    .load("wukong-v1")
    .socConfig("../build/wukong-v1/rom-sim/boot.hex")
    .copy(uartBaud = 1125000)
  def file(kind: String) =
    Files.readAllBytes(Paths.get(s"../build/wukong-v1/app-sim-$kind/flash.bin"))
  val xip = file("xip")
  def probe(kind: String) =
    Files.readAllBytes(Paths.get(s"../build/wukong-v1/probe-$kind/flash.bin"))
  val compiled = SimConfig.withVerilator
    .withConfig(SpinalConfig(defaultClockDomainFrequency = FixedFrequency(config.clockHz Hz)))
    .compile(new WukongSocFixture(config))
  val scenarios =
    if (args.nonEmpty) args.toSeq else Seq("xip", "warm-xip", "upload-xip", "bad-checksum")
  for ((scenario, index) <- scenarios.zipWithIndex)
    compiled.doSim(name = scenario, seed = 920 + index) { dut =>
      val flash = new Sf3Model(
        dut.io.spiCs,
        dut.io.spiClk,
        dut.io.spiData.write,
        dut.io.spiData.writeEnable,
        dut.io.spiData.read,
        initiallyQuad = scenario == "warm-xip" || scenario == "upload-xip",
        erased        = true
      )
      val initial = xip.clone()
      if (scenario == "bad-checksum") initial(initial.length - 1) = (initial.last ^ 1).toByte
      flash.preload(initial)
      dut.io.uartRx #= true; dut.io.spiData.read #= 15
      dut.io.clock  #= false; dut.io.memoryClock #= false; dut.io.reset #= true
      // 250 / 216 ticks preserve the exact 72 MHz CPU / 83 1/3 MHz MIG ratio.
      val busPeriod = 250L
      require(config.clockHz == 72000000)
      fork {
        sleep(1); while (true) { sleep(108); dut.io.memoryClock #= !dut.io.memoryClock.toBoolean }
      }
      val memory = new MigModel(dut.io.native, dut.memoryDomain, seed = 134 + index)
      memory.start()
      fork {
        while (true) {
          sleep(busPeriod / 2); flash.tick(); dut.io.clock #= true; sleep(busPeriod / 2);
          flash.tick();
          dut.io.clock #= false
        }
      }
      val received  = new StringBuilder
      val bitPeriod = (config.clockHz / (config.uartBaud * 32)).toLong * 32 * busPeriod
      fork {
        waitUntil(!dut.io.reset.toBoolean); dut.busDomain.waitSampling(2)
        while (true) {
          waitUntil(!dut.io.uartTx.toBoolean); sleep(bitPeriod + bitPeriod / 2)
          var value = 0
          for (bit <- 0 until 8) {
            if (dut.io.uartTx.toBoolean) value |= 1 << bit; sleep(bitPeriod)
          }
          assert(dut.io.uartTx.toBoolean, "UART stop bit")
          received.append(value.toChar)
          if (value == 10)
            println(s"$scenario UART: " + received.toString.split("\r\n").lastOption.getOrElse(""))
        }
      }
      fork { sleep(30000000L * busPeriod); simFailure(s"$scenario timeout: $received") }
      sleep(10 * busPeriod + 1); dut.io.reset #= false
      def expect(message: String, from: Int = 0): Unit =
        waitUntil(received.toString.indexOf(message, from) >= 0)
      def send(data: Array[Byte], goodStop: Boolean = true): Unit = for (value <- data) {
        dut.io.uartRx #= false; sleep(bitPeriod)
        for (bit <- 0 until 8) { dut.io.uartRx #= ((value >> bit) & 1) != 0; sleep(bitPeriod) }
        dut.io.uartRx #= goodStop; sleep(bitPeriod)
        dut.io.uartRx #= true
        // Leave foreground processing time at this accelerated baud. Real board
        // uploads use continuous 19,200-baud characters without this gap.
        sleep(4000 * busPeriod)
      }
      def word(value: Long): Array[Byte] = Array(24, 16, 8, 0).map(shift => (value >> shift).toByte)
      def command(magic: String, offset: Long, length: Int): Unit =
        send(magic.getBytes("US-ASCII") ++ word(offset) ++ word(length))
      def upload(image: Array[Byte], success: String): Unit = {
        val start = received.length
        command("J2UP", 0, image.length); expect("Send image\r\n", start)
        for (offset <- image.indices by 256) {
          send(image.slice(offset, offset + 256))
          waitUntil(
            received.toString.indexOf(f"Received $offset%06x\r\n", start) >= 0 || received.toString
              .indexOf(success, start) >= 0
          )
          if (received.toString.indexOf(success, start) >= 0) return
        }
        expect(success, start)
      }
      expect("Flash quad XIP: PASS\r\n")
      assert(memory.commands == 0, "ROM must not access external memory")
      if (scenario.startsWith("upload")) {
        expect("Send U to load\r\n"); send(Array('U'.toByte)); expect("J2 loader\r\n")
        // Backup reads are bounded and have no array side effects.
        var start = received.length
        command("J2RD", 0, 32); expect("Read complete\r\n", start)
        val payloadStart = received.toString.indexOf("Read flash\r\n", start) + 12
        assert(
          received
            .substring(payloadStart, payloadStart + 32)
            .map(_.toByte)
            .toArray
            .sameElements(initial.take(32))
        )
        expect("J2 loader\r\n", start)
        if (scenario == "upload-xip") {
          start = received.length
          command("J2UP", 0x100000, 64); expect("Bad image range\r\n", start);
          expect("J2 loader\r\n", start)
          start = received.length
          val bad = xip.take(64); upload(bad, "Invalid image header\r\n")
          expect("J2 loader\r\n", start)
          assert(flash.erases.isEmpty && flash.programs.isEmpty)
          start = received.length
          command("J2UP", 0, 64); expect("Send image\r\n", start)
          expect("Receive timeout\r\n", start); expect("J2 loader\r\n", start)
          assert(flash.erases.isEmpty)
          // A framing error must abort polling reception and recover for
          // the next command without erasing or programming application flash.
          start = received.length
          command("J2UP", 0, 64); expect("Send image\r\n", start)
          send(Array(0x55.toByte), goodStop = false)
          expect("Receive error\r\n", start); expect("J2 loader\r\n", start)
          assert(flash.erases.isEmpty && flash.programs.isEmpty)
          flash.failProgram = true
          start             = received.length; upload(probe("xip"), "Program error\r\n");
          expect("J2 loader\r\n", start)
          assert(
            (0 until 32).forall(a => flash.byte(a) == 255),
            "header must stay erased on failure"
          )
        }
        val image = probe("xip")
        upload(image, "Flash verified\r\n")
        assert(image.indices.forall(i => flash.byte(i) == (image(i) & 255)))
        assert(flash.programs.last == ((0L, 32)), "header must be committed last")
        assert(memory.commands == 0, "ROM upload must not use external memory")
      }
      if (scenario == "bad-checksum") {
        expect("Image checksum error\r\n"); expect("J2 loader\r\n")
        assert(!received.toString.contains("Booting"))
        assert(flash.erases.isEmpty && flash.programs.isEmpty)
      } else {
        expect("Booting XIP image\r\n")
        expect(
          if (scenario.startsWith("upload")) "Wukong loader app passed\r\n"
          else "XIP CPU tests passed\r\n"
        )
        assert(!received.toString.contains("tests failed"))
        if (!scenario.startsWith("upload")) assert(received.toString.contains("INTC tests passed"))
      }
      println(s"WUKONG_BOOT_PASS: $scenario")
    }
}
