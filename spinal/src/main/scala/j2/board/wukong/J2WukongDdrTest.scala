package j2.board.wukong

import spinal.core._
import spinal.lib._
import spinal.lib.com.uart._

/** Standalone DDR qualification image; no CPU, SF3 operations or configuration writes. */
final class J2WukongDdrTest extends Component {
  setDefinitionName("j2_wukong_ddr_test")
  val io = new Bundle {
    val clk50, reset_n                                  = in Bool ()
    val uart_tx, flash_cs_n, configuration_cs_n         = out Bool ()
    val led_n                                           = out Bits (2 bits)
    val ddr3_addr                                       = out Bits (14 bits)
    val ddr3_ba                                         = out Bits (3 bits)
    val ddr3_cas_n, ddr3_ras_n, ddr3_reset_n, ddr3_we_n = out Bool ()
    val ddr3_ck_n, ddr3_ck_p, ddr3_cke, ddr3_odt        = out Bits (1 bits)
    val ddr3_dm                                         = out Bits (2 bits)
    val ddr3_dq                                         = inout(Analog(Bits(16 bits)))
    val ddr3_dqs_n, ddr3_dqs_p                          = inout(Analog(Bits(2 bits)))
  }
  noIoPrefix()
  io.flash_cs_n := True; io.configuration_cs_n := True
  val clocks                      = new WukongDdrMmcm
  val feedback, system, reference = new XilinxBufg
  clocks.CLKIN1 := io.clk50; clocks.RST            := !io.reset_n; clocks.PWRDWN := False
  feedback.I    := clocks.CLKFBOUT; clocks.CLKFBIN := feedback.O
  system.I      := clocks.CLKOUT0; reference.I     := clocks.CLKOUT1
  val pll                     = new WukongPll
  val uartClock, uartFeedback = new XilinxBufg
  pll.CLKIN1     := io.clk50; pll.RST         := !io.reset_n; pll.PWRDWN := False
  uartFeedback.I := pll.CLKFBOUT; pll.CLKFBIN := uartFeedback.O
  uartClock.I    := pll.CLKOUT0
  val reset = new XilinxSystemReset
  reset.slowest_sync_clk := uartClock.O
  reset.ext_reset_in     := !io.reset_n
  reset.aux_reset_in     := False; reset.mb_debug_sys_rst := False
  reset.dcm_locked       := pll.LOCKED
  val mig = new WukongMig
  mig.sys_clk_i   := system.O; mig.clk_ref_i        := reference.O
  mig.sys_rst     := io.reset_n && clocks.LOCKED
  mig.app_sr_req  := False; mig.app_ref_req         := False; mig.app_zq_req    := False
  io.ddr3_addr    := mig.ddr3_addr; io.ddr3_ba      := mig.ddr3_ba
  io.ddr3_cas_n   := mig.ddr3_cas_n; io.ddr3_ras_n  := mig.ddr3_ras_n
  io.ddr3_reset_n := mig.ddr3_reset_n; io.ddr3_we_n := mig.ddr3_we_n
  io.ddr3_ck_n    := mig.ddr3_ck_n; io.ddr3_ck_p    := mig.ddr3_ck_p
  io.ddr3_cke     := mig.ddr3_cke; io.ddr3_odt      := mig.ddr3_odt; io.ddr3_dm := mig.ddr3_dm
  io.ddr3_dq <> mig.ddr3_dq; io.ddr3_dqs_n <> mig.ddr3_dqs_n; io.ddr3_dqs_p <> mig.ddr3_dqs_p
  val uiDomain =
    ClockDomain(mig.ui_clk, mig.ui_clk_sync_rst, frequency = FixedFrequency(83333333 Hz))
  val bist = uiDomain(new WukongDdrBist)
  bist.io.calibrated := mig.init_calib_complete
  mig.app_addr       := bist.io.addr; mig.app_cmd       := bist.io.cmd; mig.app_en := bist.io.en
  mig.app_wdf_data   := bist.io.wdata; mig.app_wdf_mask := bist.io.mask
  mig.app_wdf_end    := bist.io.wend; mig.app_wdf_wren  := bist.io.wren
  bist.io.ready      := mig.app_rdy; bist.io.wready     := mig.app_wdf_rdy
  bist.io.rdata      := mig.app_rd_data; bist.io.rvalid := mig.app_rd_data_valid;
  bist.io.rend       := mig.app_rd_data_end
  val status = new ClockingArea(
    ClockDomain(uartClock.O, reset.peripheral_reset(0), frequency = FixedFrequency(32000000 Hz))
  ) {
    val calibrated  = BufferCC(mig.init_calib_complete, init = False)
    val done        = BufferCC(bist.io.done, init = False)
    val failed      = BufferCC(bist.io.failed, init = False)
    val doneSettled = RegNext(done) init False
    val timeout     = RegInit(False)
    val timer       = Reg(UInt(27 bits)) init 0
    timer := timer + 1
    when(timer.andR && !calibrated)(timeout := True)
    val uart = new UartCtrl()
    uart.io.config.setClockDivider(19200 Hz)
    uart.io.config.frame.dataLength := 7
    uart.io.config.frame.parity     := UartParityType.NONE
    uart.io.config.frame.stop       := UartStopType.ONE
    uart.io.uart.rxd                := True
    uart.io.read.ready              := True
    uart.io.writeBreak              := False
    io.uart_tx                      := uart.io.uart.txd
    val texts = Seq(
      "Wukong DDR3: waiting for calibration\r\n",
      "Wukong DDR3: PASS\r\n",
      "Wukong DDR3: FAIL\r\n",
      "Wukong DDR3: calibration TIMEOUT\r\n"
    )
    val message  = Reg(UInt(2 bits)) init 0
    val position = Reg(UInt(6 bits)) init 0
    val sending  = RegInit(True)
    val reported = RegInit(False)
    val data = Vec(
      texts.map(t => Vec((t.padTo(64, '\u0000')).map(c => B(c.toInt, 8 bits)))(position))
    )
    val lengths = Vec(texts.map(t => U(t.length, 6 bits)))
    uart.io.write.valid   := sending
    uart.io.write.payload := data(message)
    when(uart.io.write.fire) {
      position := position + 1
      when(position === lengths(message) - 1) { sending := False; position := 0 }
    }
    when(!sending && !reported && (doneSettled || timeout)) {
      // Give synchronized status bits an extra cycle to settle before selecting text.
      reported := True; sending := True
      message  := Mux(timeout, U(3, 2 bits), Mux(failed, U(2, 2 bits), U(1, 2 bits)))
    }
    io.led_n(0) := !calibrated
    io.led_n(1) := !(done && !failed)
  }
}
