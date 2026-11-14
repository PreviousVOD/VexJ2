// 8192 x 32-bit EG4 true-dual-port RAM.
// Port A services the J2 data bus; port B services the instruction bus.
module j2_eg4_bram32 #(
  parameter INIT_FILE = "NONE"
) (
  input  wire        clk,
  input  wire [12:0] addra,
  input  wire        cea,
  input  wire [3:0]  bea,
  input  wire [31:0] dia,
  output wire [31:0] doa,
  input  wire [12:0] addrb,
  input  wire        ceb,
  input  wire [31:0] dib,
  output wire [31:0] dob
);
  EG_LOGIC_BRAM #(
    .DATA_WIDTH_A(32),
    .DATA_WIDTH_B(32),
    .ADDR_WIDTH_A(13),
    .ADDR_WIDTH_B(13),
    .DATA_DEPTH_A(8192),
    .DATA_DEPTH_B(8192),
    .BYTE_ENABLE(8),
    .BYTE_A(4),
    .BYTE_B(4),
    .MODE("DP"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"),
    .RESETMODE("SYNC"),
    .IMPLEMENT("32K"),
    .INIT_FILE(INIT_FILE),
    .FILL_ALL("NONE")
  ) ram (
    .dia(dia),
    .dib(dib),
    .addra(addra),
    .addrb(addrb),
    .cea(cea),
    .ceb(ceb),
    .ocea(1'b0),
    .oceb(1'b0),
    .clka(clk),
    .clkb(clk),
    .wea(1'b0),
    .web(1'b0),
    .bea(bea),
    .beb(4'b0000),
    .rsta(1'b0),
    .rstb(1'b0),
    .doa(doa),
    .dob(dob)
  );
endmodule
