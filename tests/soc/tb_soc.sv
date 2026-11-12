// SoC testbench top: flattens the SoC's Wishbone external ports for C++.
// Define SOC_NEW to test j2_soc (new peripherals) instead of j2_soc_ref.
module tb_soc
  import j2_wb_pkg::*;
(
  input  logic        clk, rst,
  output logic        xd_cyc, xd_stb, xd_we,
  output logic [31:0] xd_adr, xd_dat_o,
  output logic [3:0]  xd_sel,
  input  logic        xd_ack, xd_stall,
  input  logic [31:0] xd_dat_i,
  output logic        xi_cyc, xi_stb,
  output logic [31:0] xi_adr,
  input  logic        xi_ack, xi_stall,
  input  logic [31:0] xi_dat_i,
  input  logic        uart_rx,
  output logic        uart_tx,
  output logic        spi_clk,
  output logic [1:0]  spi_cs,
  output logic        spi_mosi,
  input  logic        spi_miso,
  input  logic [31:0] pi,
  output logic [31:0] po
);
  wb_m2s_t xd_o, xi_o;
`ifdef SOC_NEW
  j2_soc u_soc (
`else
  j2_soc_ref u_soc (
`endif
    .clk, .rst,
    .ext_d_o(xd_o), .ext_d_i('{ack: xd_ack, err: 1'b0, stall: xd_stall, dat: xd_dat_i}),
    .ext_i_o(xi_o), .ext_i_i('{ack: xi_ack, err: 1'b0, stall: xi_stall, dat: xi_dat_i}),
    .uart_rx, .uart_tx, .spi_clk, .spi_cs, .spi_mosi, .spi_miso, .pi, .po);
  assign {xd_cyc, xd_stb, xd_we, xd_adr, xd_dat_o, xd_sel} =
         {xd_o.cyc, xd_o.stb, xd_o.we, xd_o.adr, xd_o.dat, xd_o.sel};
  assign {xi_cyc, xi_stb, xi_adr} = {xi_o.cyc, xi_o.stb, xi_o.adr};
endmodule
