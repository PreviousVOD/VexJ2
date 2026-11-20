package j2.board

import java.nio.file.{Files, Paths}
import scala.sys.process._
import j2.board.tang_primer.J2TangPrimerSoc
import j2.board.wukong_v1.J2WukongSoc
import j2.bus.J2Ahb
import j2.bus.ahb5.Ahb5
import j2.soc.J2SocConfig
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.io.TriStateArray

class BoardSocSpec extends munit.FunSuite {
  class Probe(board: String, config: J2SocConfig) extends Component {
    setDefinitionName(s"${board.replace('-', '_')}_peripheral_test_${config.sramBytes}")
    val io = new Bundle {
      val memory         = master(J2Ahb.subordinate())
      val uartTx         = out Bool ()
      val uartRx         = in Bool ()
      val result, enable = out Bits (8 bits)
    }
    def connect(
        memory: Ahb5,
        rx: Bool,
        tx: Bool,
        gpio: TriStateArray,
        flash: TriStateArray
    ): Unit = {
      io.memory <> memory
      rx         := io.uartRx
      io.uartTx  := tx
      gpio.read  := 0
      flash.read := 15
      io.result  := gpio.write(7 downto 0)
      io.enable  := gpio.writeEnable(7 downto 0)
    }
    if (board == "tang-primer") {
      val soc = new J2TangPrimerSoc(config)
      connect(soc.io.memory, soc.io.uartRx, soc.io.uartTx, soc.io.gpio, soc.io.spiData)
    } else {
      val soc = new J2WukongSoc(config)
      connect(soc.io.memory, soc.io.uartRx, soc.io.uartTx, soc.io.gpio, soc.io.spiData)
    }
  }

  for (board <- Seq("tang-primer", "wukong-v1"); relocate <- Seq(false, true)) {
    test(s"$board boots and services board IRQs with relocated map=$relocate") {
      val prefix = Paths.get("../tools/local/sh-none-elf/bin/sh-none-elf-").toAbsolutePath.toString
      val out    = Paths.get(s"../build/direct-soc-test/$board/$relocate").toAbsolutePath.normalize
      Files.createDirectories(out)
      val hex    = out.resolve("main.hex")
      val values = BoardProfile.load(board, Map.empty).values
      val profile = BoardProfile(
        if (relocate)
          values ++ Map(
            "sciBase" -> "0xff006000",
            "cmtBase" -> "0xff007000",
            "spiControlBase" -> "0xff008000",
            "xipCacheControlBase" -> "0xff009000",
            "sramBytes" -> "65536",
            "sciFifoDepth" -> "16",
            "interruptSources" -> "SCI_BRI,SCI_RXI,CMT1,SCI_TXI,CMT0,SCI_ERI"
          )
        else values
      )
      val properties = out.resolve("board.properties")
      Files.writeString(properties, profile.values.map { case (k, v) => s"$k=$v" }.mkString("\n"))
      assertEquals(
        Seq(
          "python3",
          "-c",
          "import sys; from pathlib import Path; sys.path.insert(0, '../tools'); from board_config import load_file, generate, generate_interrupt_header; p = load_file(sys.argv[1], {}); generate(p, Path(sys.argv[2]).parent); generate_interrupt_header(p, Path(sys.argv[2]))",
          properties.toString,
          out.resolve("j2_board_irqs.h").toString
        ).!,
        0
      )
      val config = profile.socConfig(hex.toString)
      val elf    = out.resolve("main.elf").toString
      val bin    = out.resolve("main.bin").toString
      assertEquals(
        Seq(
          prefix + "gcc",
          "-m2",
          "-mb",
          "-Os",
          "-Wall",
          "-Wextra",
          "-Werror",
          "-ffreestanding",
          "-fno-builtin",
          "-nostdlib",
          "-DJ2_UART_RX_IRQ",
          "-I../sw/include",
          s"-I$out",
          "-I../sw/bootrom",
          s"-I$out/rom",
          "-include",
          out.resolve("rom/board.h").toString,
          "-DJ2_UART_BAUD=125000",
          s"-Wl,--defsym=J2_SRAM_BYTES=${config.sramBytes}",
          "-T",
          "../sw/bootrom/boot.x",
          "../sw/bootrom/test/uart_irq_entry.S",
          "../sw/bootrom/uart.c",
          "../sw/bootrom/test/irq_driver.c",
          "../sw/bootrom/flash.c",
          "../sw/bootrom/test/board_peripherals.c",
          "../sw/xipapp/intc.c",
          "-lgcc",
          "-o",
          elf
        ).!,
        0
      )
      assertEquals(Seq(prefix + "objcopy", "-O", "binary", elf, bin).!, 0)
      assertEquals(Seq("python3", "../tools/gen_verilog_rom.py", bin, hex.toString).!, 0)
      // Each configuration embeds different firmware; compile its memory image afresh.
      val compiled = SimConfig.withVerilator.disableCache
        .withConfig(SpinalConfig(defaultClockDomainFrequency = FixedFrequency(config.clockHz Hz)))
        .compile(new Probe(board, config))
      for (seed <- Seq(1, 2, 3)) compiled.doSim(seed = seed) { dut =>
        dut.io.uartRx            #= true
        dut.io.memory.HREADYOUT  #= true
        dut.io.memory.HRESP      #= false
        dut.io.memory.HRDATA     #= 0
        dut.clockDomain.clockSim #= false
        dut.clockDomain.assertReset()
        sleep(1)
        fork {
          while (true) {
            sleep(5); dut.clockDomain.clockSim #= true
            sleep(5); dut.clockDomain.clockSim #= false
          }
        }
        sleep(160)
        dut.clockDomain.deassertReset()
        dut.clockDomain.waitSampling(2)
        var received  = -1
        val bitCycles = ((config.clockHz.toLong + 16L * 125000) / (32L * 125000) * 32).toInt
        fork {
          waitUntil(dut.io.result.toInt == 2)
          dut.clockDomain.waitSampling(bitCycles)
          dut.io.uartRx #= false
          dut.clockDomain.waitSampling(bitCycles)
          for (bit <- 0 until 8) {
            dut.io.uartRx #= ((0x5a >> bit) & 1) != 0
            dut.clockDomain.waitSampling(bitCycles)
          }
          dut.io.uartRx #= true
        }
        fork {
          waitUntil(!dut.io.uartTx.toBoolean)
          sleep(bitCycles * 15L)
          var value = 0
          for (bit <- 0 until 8) {
            if (dut.io.uartTx.toBoolean) value |= 1 << bit
            sleep(bitCycles * 10L)
          }
          assert(dut.io.uartTx.toBoolean, "SCI stop bit")
          received = value
        }
        var cycles = 0
        while (
          (dut.io.enable.toInt != 255 || (dut.io.result.toInt != 0x77 && dut.io.result.toInt != 0x55)) && cycles < 200000
        ) {
          dut.clockDomain.waitSampling()
          assert(!dut.io.memory.HSEL.toBoolean, "ROM test must not need external memory")
          cycles += 1
        }
        assertEquals(dut.io.enable.toInt, 255, s"$board relocated=$relocate timed out")
        assertEquals(
          dut.io.result.toInt,
          0x77,
          s"$board relocated=$relocate phase=${dut.io.result.toInt} UART=$received"
        )
        dut.clockDomain.waitSampling(bitCycles * 2)
        assertEquals(received, 'R'.toInt)
      }
    }
  }
}
