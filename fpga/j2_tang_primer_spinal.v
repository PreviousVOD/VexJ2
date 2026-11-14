module j2_tang_primer (
  input  wire       clk24,
  input  wire       rst_n,
  input  wire       uart_rx,
  output wire       uart_tx,
  output wire [2:0] rgb_led
);
  J2TangPrimer dut (
    .io_clk24(clk24),
    .io_rstN(rst_n),
    .io_uartRx(uart_rx),
    .io_uartTx(uart_tx),
    .io_rgbLed(rgb_led),
    .io_pc(),
    .io_retired()
  );
endmodule
