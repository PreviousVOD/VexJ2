`default_nettype none

module j2_uart16550 (
  input  wire        clk,
  input  wire        reset,
  input  wire        bus_cyc,
  input  wire        bus_stb,
  output wire        bus_ack,
  input  wire        bus_we,
  input  wire [31:0] bus_adr,
  output wire [31:0] bus_dat_miso,
  input  wire [31:0] bus_dat_mosi,
  input  wire        uart_rx,
  output wire        uart_tx
);
  wire [7:0] uart_data;

  uart_top uart (
    .wb_clk_i(clk),
    .wb_rst_i(reset),
    .wb_adr_i(bus_adr[4:2]),
    .wb_dat_i(bus_dat_mosi[7:0]),
    .wb_dat_o(uart_data),
    .wb_we_i(bus_we),
    .wb_stb_i(bus_stb),
    .wb_cyc_i(bus_cyc),
    .wb_ack_o(bus_ack),
    .wb_sel_i(4'b0001),
    .int_o(),
    .stx_pad_o(uart_tx),
    .srx_pad_i(uart_rx),
    .rts_pad_o(),
    .cts_pad_i(1'b0),
    .dtr_pad_o(),
    .dsr_pad_i(1'b0),
    .ri_pad_i(1'b1),
    .dcd_pad_i(1'b0)
  );

  assign bus_dat_miso = {24'b0, uart_data};
endmodule

`default_nettype wire
