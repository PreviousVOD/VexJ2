`default_nettype none

module j2_sdram_phy (
  input  wire        clk,
  input  wire        ras_n,
  input  wire        cas_n,
  input  wire        we_n,
  input  wire [10:0] addr,
  input  wire [1:0]  ba,
  inout  wire [31:0] dq,
  input  wire        cs_n,
  input  wire [3:0]  dm,
  input  wire        cke
);
  EG_PHY_SDRAM_2M_32 memory (
    .clk(clk),
    .ras_n(ras_n),
    .cas_n(cas_n),
    .we_n(we_n),
    .addr(addr),
    .ba(ba),
    .dq(dq),
    .cs_n(cs_n),
    .dm0(dm[0]),
    .dm1(dm[1]),
    .dm2(dm[2]),
    .dm3(dm[3]),
    .cke(cke)
  );
endmodule

`default_nettype wire
