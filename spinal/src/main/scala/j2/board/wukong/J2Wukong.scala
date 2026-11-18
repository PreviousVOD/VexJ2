package j2.board.wukong

import j2.soc.{J2Soc, J2SocConfig}
import spinal.core._

/** Step-1 platform: DDR is an explicit error endpoint until the MIG bridge is installed. */
final class J2Wukong(config: J2SocConfig) extends Component {
  require(config.clockHz == 32000000)
  setDefinitionName("j2_wukong_v1")
  val io = new Bundle {
    val clk50, reset_n, uart_rx                   = in Bool ()
    val uart_tx                                   = out Bool ()
    val led_n                                     = out Bits (2 bits)
    val gpio                                      = inout(Analog(Bits(24 bits)))
    val flash_cs_n, flash_clk, configuration_cs_n = out Bool ()
    val flash_dq                                  = inout(Analog(Bits(4 bits)))
  }
  noIoPrefix()
  val pll                         = new WukongPll
  val clockBuffer, feedbackBuffer = new XilinxBufg
  pll.CLKIN1       := io.clk50
  pll.RST          := !io.reset_n
  pll.PWRDWN       := False
  feedbackBuffer.I := pll.CLKFBOUT
  pll.CLKFBIN      := feedbackBuffer.O
  clockBuffer.I    := pll.CLKOUT0

  val startup = new XilinxStartup
  startup.CLK       := False
  startup.GSR       := False
  startup.GTS       := False
  startup.KEYCLEARB := True
  startup.PACK      := False
  startup.USRDONEO  := True
  startup.USRDONETS := True
  // Configuration flash is never driven by the application SPI controller.
  startup.USRCCLKTS     := True
  startup.USRCCLKO      := False
  io.configuration_cs_n := True

  val resetController = new XilinxSystemReset
  resetController.slowest_sync_clk := clockBuffer.O
  resetController.ext_reset_in     := !io.reset_n
  resetController.aux_reset_in     := False
  resetController.mb_debug_sys_rst := False
  resetController.dcm_locked       := pll.LOCKED && startup.EOS
  val domain = ClockDomain(
    clockBuffer.O,
    resetController.peripheral_reset(0),
    frequency = FixedFrequency(config.clockHz Hz)
  )
  val soc = domain(new J2Soc(config))
  soc.io.uartRx := io.uart_rx
  io.uart_tx    := soc.io.uartTx
  // A missing DDR backend must terminate accesses rather than hang the CPU.
  soc.io.memory.ACK      := False
  soc.io.memory.ERR      := soc.io.memory.CYC && soc.io.memory.STB
  soc.io.memory.DAT_MISO := 0

  // GPIO 16..23 are reserved for J11; remaining pads retain software numbering.
  soc.io.gpio.read(23 downto 16) := 0
  for (bit <- 0 until 24) {
    val socBit = if (bit < 16) bit else bit + 8
    val pad    = new XilinxIoBuffer
    pad.I                    := soc.io.gpio.write(socBit)
    pad.T                    := !soc.io.gpio.writeEnable(socBit)
    soc.io.gpio.read(socBit) := pad.O
    pad.IO <> io.gpio(bit)
  }
  io.flash_clk  := startup.EOS && soc.io.spiClk
  io.flash_cs_n := !startup.EOS || soc.io.spiCs
  for (bit <- 0 until 4) {
    val pad = new XilinxIoBuffer
    pad.I                    := soc.io.spiData.write(bit)
    pad.T                    := !startup.EOS || !soc.io.spiData.writeEnable(bit)
    soc.io.spiData.read(bit) := pad.O
    pad.IO <> io.flash_dq(bit)
  }
  val status = new ClockingArea(domain) {
    val heartbeat = Reg(UInt(25 bits)) init 0
    heartbeat := heartbeat + 1
  }
  io.led_n(0) := !pll.LOCKED
  io.led_n(1) := !status.heartbeat.msb
}
