`default_nettype none

module j2_tang_primer #(
  parameter ROM_INIT_FILE = "j2_validation_rom.mif",
  parameter ROM_HEX_FILE = "j2_validation_rom.hex"
) (
  input  wire       clk24,
  input  wire       rst_n,
  input  wire       uart_rx,
  output wire       uart_tx,
  output wire [2:0] rgb_led,
  output wire       spi_clk,
  output wire       spi_cs,
  output wire       spi_mosi,
  input  wire       spi_miso,
  output wire       spi_wp_n,
  output wire       spi_hold_n
);
  reg [1:0] reset_count;
  wire reset = !rst_n || reset_count != 0;

  initial reset_count = 2'b11;

  always @(posedge clk24 or negedge rst_n) begin
    if (!rst_n)
      reset_count <= 2'b11;
    else if (reset_count != 0)
      reset_count <= reset_count - 1'b1;
  end

  j2_soc #(
    .ROM_INIT_FILE(ROM_INIT_FILE),
    .ROM_HEX_FILE(ROM_HEX_FILE)
  ) soc (
    .clk(clk24),
    .reset(reset),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx),
    .rgb_led(rgb_led),
    .spi_cs_n(spi_cs),
    .spi_sck(spi_clk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso)
  );

  assign spi_wp_n = 1'b1;
  assign spi_hold_n = 1'b1;
endmodule

`default_nettype wire
