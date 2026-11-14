`default_nettype none

module j2_pio (
  input  wire        clk,
  input  wire        reset,
  input  wire        bus_cyc,
  input  wire        bus_stb,
  output reg         bus_ack,
  input  wire        bus_we,
  input  wire [31:0] bus_dat_mosi,
  output wire [31:0] bus_dat_miso,
  output reg  [31:0] pio_out
);
  reg pending;
  wire request = bus_cyc && bus_stb;
  wire start = request && !pending;
  wire complete = request && pending;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      pending <= 1'b0;
      bus_ack <= 1'b0;
      pio_out <= 32'h80000000;
    end else begin
      bus_ack <= complete;
      if (request)
        pending <= !pending;
      else
        pending <= 1'b0;
      if (start && bus_we)
        pio_out <= bus_dat_mosi;
    end
  end

  assign bus_dat_miso = pio_out;
endmodule

`default_nettype wire
