`default_nettype none

module j2_tang_primer (
  input  wire       clk24,
  input  wire       rst_n,
  input  wire       uart_rx,
  output wire       uart_tx,
  output wire [2:0] rgb_led
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

  j2_soc soc (
    .clk(clk24),
    .reset(reset),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx),
    .rgb_led(rgb_led)
  );
endmodule

`default_nettype wire
