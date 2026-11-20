package j2.board.wukong_v1

import j2.soc.J2SocConfig
import spinal.core._
import spinal.lib._

/** Wukong SoC with a serialized AHB5/CDC bridge to the native MIG interface. */
final class J2Wukong(config: J2SocConfig) extends Component {
  require(config.clockHz == 72000000)
  setDefinitionName("j2_wukong_v1")
  val io = new Bundle {
    val clk50, reset_n, uart_rx                         = in Bool ()
    val uart_tx                                         = out Bool ()
    val led_n                                           = out Bits (2 bits)
    val gpio                                            = inout(Analog(Bits(24 bits)))
    val flash_cs_n, flash_clk                           = out Bool ()
    val flash_dq                                        = inout(Analog(Bits(4 bits)))
    val ddr3_addr                                       = out Bits (14 bits)
    val ddr3_ba                                         = out Bits (3 bits)
    val ddr3_cas_n, ddr3_ras_n, ddr3_reset_n, ddr3_we_n = out Bool ()
    val ddr3_ck_n, ddr3_ck_p, ddr3_cke, ddr3_odt        = out Bits (1 bits)
    val ddr3_dm                                         = out Bits (2 bits)
    val ddr3_dq                                         = inout(Analog(Bits(16 bits)))
    val ddr3_dqs_n, ddr3_dqs_p                          = inout(Analog(Bits(2 bits)))
  }
  noIoPrefix()
  val pll                         = new WukongSocMmcm
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
  startup.USRCCLKTS := True
  startup.USRCCLKO  := False

  val ddrClocks                            = new WukongDdrMmcm
  val ddrFeedback, ddrSystem, ddrReference = new XilinxBufg
  ddrClocks.CLKIN1 := io.clk50; ddrClocks.RST := !io.reset_n; ddrClocks.PWRDWN := False
  ddrFeedback.I := ddrClocks.CLKFBOUT; ddrClocks.CLKFBIN := ddrFeedback.O
  ddrSystem.I   := ddrClocks.CLKOUT0; ddrReference.I     := ddrClocks.CLKOUT1
  val mig = new WukongMig
  mig.sys_clk_i := ddrSystem.O; mig.clk_ref_i := ddrReference.O
  // Any reset of the CPU/mailboxes also restarts MIG and discards native traffic.
  mig.sys_rst     := io.reset_n && pll.LOCKED && ddrClocks.LOCKED && startup.EOS
  mig.app_sr_req  := False; mig.app_ref_req         := False; mig.app_zq_req    := False
  io.ddr3_addr    := mig.ddr3_addr; io.ddr3_ba      := mig.ddr3_ba
  io.ddr3_cas_n   := mig.ddr3_cas_n; io.ddr3_ras_n  := mig.ddr3_ras_n
  io.ddr3_reset_n := mig.ddr3_reset_n; io.ddr3_we_n := mig.ddr3_we_n
  io.ddr3_ck_n    := mig.ddr3_ck_n; io.ddr3_ck_p    := mig.ddr3_ck_p
  io.ddr3_cke     := mig.ddr3_cke; io.ddr3_odt      := mig.ddr3_odt; io.ddr3_dm := mig.ddr3_dm
  io.ddr3_dq <> mig.ddr3_dq; io.ddr3_dqs_n <> mig.ddr3_dqs_n; io.ddr3_dqs_p <> mig.ddr3_dqs_p
  val resetController = new XilinxSystemReset
  resetController.slowest_sync_clk := clockBuffer.O
  resetController.ext_reset_in     := !io.reset_n
  resetController.aux_reset_in     := False
  resetController.mb_debug_sys_rst := False
  // Calibration belongs to the UI clock domain. Assert immediately on loss,
  // but release the CPU reset qualifier only after two SoC clock edges.
  // Register readiness in its source domain so the asynchronous reset input
  // cannot glitch when calibration and UI reset change at the same edge.
  val uiReadiness = new ClockingArea(ClockDomain(mig.ui_clk, mig.ui_clk_sync_rst)) {
    val ready = RegNext(mig.init_calib_complete) init False
  }
  val ddrNotReady = !uiReadiness.ready
  val ddrReadyReset = ResetCtrl
    .asyncAssertSyncDeassert(
      ddrNotReady,
      ClockDomain(clockBuffer.O)
    )
    .setName("ddrReadyReset")
  resetController.dcm_locked := pll.LOCKED && ddrClocks.LOCKED && startup.EOS && !ddrReadyReset
  val domain = ClockDomain(
    clockBuffer.O,
    resetController.peripheral_reset(0),
    frequency = FixedFrequency(config.clockHz Hz)
  )
  val soc = domain(new J2WukongSoc(config))
  soc.io.uartRx := io.uart_rx
  io.uart_tx    := soc.io.uartTx
  val uiClock            = ClockDomain(mig.ui_clk, frequency = FixedFrequency(83333333 Hz))
  val bridgeResetRequest = Bool()
  bridgeResetRequest := domain.isResetActive
  val bridgeReset =
    ResetCtrl.asyncAssertSyncDeassert(bridgeResetRequest, uiClock).setName("bridgeReset")
  val bridge = new J2AhbDdrBridge(
    domain,
    uiClock.copy(reset = bridgeReset),
    config.memoryBase,
    config.memoryBytes
  )
  bridge.io.bus <> soc.io.memory
  bridge.io.calibrated := mig.init_calib_complete && !mig.ui_clk_sync_rst
  mig.app_addr         := bridge.io.native.address; mig.app_cmd     := bridge.io.native.command
  mig.app_en           := bridge.io.native.enable; mig.app_wdf_wren := bridge.io.native.writeEnable
  mig.app_wdf_end  := bridge.io.native.writeEnd; mig.app_wdf_data := bridge.io.native.writeData
  mig.app_wdf_mask := bridge.io.native.writeMask
  bridge.io.native.ready    := mig.app_rdy; bridge.io.native.writeReady    := mig.app_wdf_rdy
  bridge.io.native.readData := mig.app_rd_data; bridge.io.native.readValid := mig.app_rd_data_valid
  bridge.io.native.readEnd  := mig.app_rd_data_end

  for (bit <- 0 until 24) {
    val pad = new XilinxIoBuffer
    pad.I                 := soc.io.gpio.write(bit)
    pad.T                 := !soc.io.gpio.writeEnable(bit)
    soc.io.gpio.read(bit) := pad.O
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
  io.led_n(0) := !mig.init_calib_complete
  io.led_n(1) := !status.heartbeat.msb
}
