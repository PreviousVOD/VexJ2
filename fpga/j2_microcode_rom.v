module j2_microcode_rom #(
  parameter INIT_FILE = "../../microcode/j2_microcode.mif"
) (
  input  wire        clk,
  input  wire [7:0]  address,
  input  wire        enable,
  output wire [71:0] line
);
  wire rom_clk = clk;

  EG_LOGIC_BRAM #(
    .DATA_WIDTH_A(72),
    .DATA_WIDTH_B(72),
    .ADDR_WIDTH_A(8),
    .ADDR_WIDTH_B(8),
    .DATA_DEPTH_A(256),
    .DATA_DEPTH_B(256),
    .BYTE_ENABLE(0),
    .BYTE_A(1),
    .BYTE_B(1),
    .MODE("SP"),
    .REGMODE_A("NOREG"),
    .REGMODE_B("NOREG"),
    .WRITEMODE_A("NORMAL"),
    .WRITEMODE_B("NORMAL"),
    .RESETMODE("SYNC"),
    .IMPLEMENT("32K"),
    .INIT_FILE(INIT_FILE),
    .FILL_ALL("NONE")
  ) rom (
    .dia(72'b0),
    .dib(72'b0),
    .addra(address),
    .addrb(8'b0),
    .cea(enable),
    .ceb(1'b0),
    .ocea(1'b0),
    .oceb(1'b0),
    .clka(rom_clk),
    .clkb(rom_clk),
    .wea(1'b0),
    .web(1'b0),
    .bea(1'b0),
    .beb(1'b0),
    .rsta(1'b0),
    .rstb(1'b0),
    .doa(line),
    .dob()
  );
endmodule
