// Sipeed Tang Primer integration top (Anlogic EG4S20BG256).
//
// The board has a 24 MHz oscillator and an active-low user key.  The J2 SoC
// runs directly at 24 MHz, so the UART baud divider and AIC bus-period
// parameters are set for that clock.
//
// The CPU, ROM and stack use the SoC's 32 KiB on-chip SRAM.  External
// Wishbone accesses receive a one-cycle zero-data response; the EG4S20's
// integrated SDRAM controller is intentionally not part of this first board
// integration.  PROGRAM_FILE is the $readmemh image loaded at synthesis.
module j2_tang_primer
  import j2_wb_pkg::*;
#(
  parameter string PROGRAM_FILE = ""
) (
  input  logic       clk24,
  input  logic       rst_n,
  input  logic       uart_rx,
  output logic       uart_tx,
  output logic       spi_clk,
  output logic       spi_cs,
  output logic       spi_mosi,
  input  logic       spi_miso,
  output logic [2:0] rgb_led
);
  logic [1:0] rst_sync;
  logic       rst;
  /* verilator lint_off UNUSEDSIGNAL */  // only RGB LED bits are pinned
  logic [31:0] po;
  /* verilator lint_on UNUSEDSIGNAL */

  /* verilator lint_off UNUSEDSIGNAL */  // only cycle/strobe are monitored
  wb_m2s_t ext_d_o, ext_i_o;
  /* verilator lint_on UNUSEDSIGNAL */
  wb_s2m_t ext_d_i, ext_i_i;
  logic    ext_d_ack, ext_i_ack;
  /* verilator lint_off UNUSEDSIGNAL */  // second SPI CS is not pinned
  logic [1:0] spi_cs_vec;
  /* verilator lint_on UNUSEDSIGNAL */

  initial rst_sync = '0;
  always_ff @(posedge clk24)
    rst_sync <= {rst_sync[0], rst_n};
  assign rst = !rst_sync[1];

  always_ff @(posedge clk24 or posedge rst) begin
    if (rst) begin
      ext_d_ack <= 1'b0;
      ext_i_ack <= 1'b0;
    end else begin
      ext_d_ack <= ext_d_o.cyc && ext_d_o.stb;
      ext_i_ack <= ext_i_o.cyc && ext_i_o.stb;
    end
  end
  assign ext_d_i = '{ack: ext_d_ack, err: 1'b0, stall: 1'b0, dat: 32'h0};
  assign ext_i_i = '{ack: ext_i_ack, err: 1'b0, stall: 1'b0, dat: 32'h0};

  j2_soc #(
    .SRAM_WORDS(8192),
    .CLK_HZ(24_000_000),
    .BUS_PERIOD_NS(42),
    .SRAM_INIT_FILE(PROGRAM_FILE)
  ) u_soc (
    .clk(clk24),
    .rst(rst),
    .ext_d_o(ext_d_o),
    .ext_d_i(ext_d_i),
    .ext_i_o(ext_i_o),
    .ext_i_i(ext_i_i),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx),
    .spi_clk(spi_clk),
    .spi_cs(spi_cs_vec),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    .pi(32'h0),
    .po(po)
  );

  assign rgb_led = po[2:0];
  assign spi_cs  = spi_cs_vec[0];
endmodule
