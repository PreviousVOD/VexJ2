package j2.board.wukong_v1

import spinal.core._

/** MIG 4.2 generated from fpga/wukong-v1/mig.prj. */
final class WukongMig extends BlackBox {
  setDefinitionName("wukong_mig")
  val sys_clk_i, clk_ref_i, sys_rst                            = in Bool ()
  val ui_clk, ui_clk_sync_rst, init_calib_complete             = out Bool ()
  val app_addr                                                 = in UInt (28 bits)
  val app_cmd                                                  = in Bits (3 bits)
  val app_en, app_wdf_end, app_wdf_wren                        = in Bool ()
  val app_wdf_data                                             = in Bits (128 bits)
  val app_wdf_mask                                             = in Bits (16 bits)
  val app_rdy, app_wdf_rdy, app_rd_data_end, app_rd_data_valid = out Bool ()
  val app_rd_data                                              = out Bits (128 bits)
  val app_sr_req, app_ref_req, app_zq_req                      = in Bool ()
  val ddr3_addr                                                = out Bits (14 bits)
  val ddr3_ba                                                  = out Bits (3 bits)
  val ddr3_cas_n, ddr3_ras_n, ddr3_reset_n, ddr3_we_n          = out Bool ()
  val ddr3_ck_n, ddr3_ck_p, ddr3_cke, ddr3_odt                 = out Bits (1 bits)
  val ddr3_dm                                                  = out Bits (2 bits)
  val ddr3_dq                                                  = inout(Analog(Bits(16 bits)))
  val ddr3_dqs_n, ddr3_dqs_p                                   = inout(Analog(Bits(2 bits)))
}
