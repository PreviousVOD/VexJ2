`default_nettype none

module EG_PHY_PAD (
  input  wire       ipad,
  output wire       opad,
  inout  wire       bpad,
  input  wire       rst,
  input  wire       ce,
  input  wire       isclk,
  input  wire       ipclk,
  input  wire       osclk,
  input  wire       opclk,
  input  wire       ts,
  input  wire [3:0] do,
  output wire       di,
  output wire [3:0] diq
);
  parameter MODE = "IN";
  parameter TSMUX = "1";
  parameter IOTYPE = "LVCMOS25";
  parameter DRIVE = "NONE";

  assign bpad = (MODE == "BI" && TSMUX == "TS" && !ts) ? do[0] : 1'bz;
  assign opad = bpad;
  assign di = bpad;
  assign diq = {4{bpad}};
endmodule

`default_nettype wire
