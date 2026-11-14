`default_nettype none

module j2_validation_rom #(
  parameter ADDR_WIDTH = 13,
  parameter INIT_FILE = "j2_validation_rom.mif",
  parameter HEX_FILE = "j2_validation_rom.hex"
) (
  input  wire        clk,
  input  wire        reset,

  input  wire        dbus_cyc,
  input  wire        dbus_stb,
  output reg         dbus_ack,
  input  wire        dbus_we,
  input  wire [31:0] dbus_adr,
  output reg  [31:0] dbus_dat_miso,
  input  wire [31:0] dbus_dat_mosi,
  input  wire [3:0]  dbus_sel,

  input  wire        ibus_cyc,
  input  wire        ibus_stb,
  output reg         ibus_ack,
  input  wire [31:0] ibus_adr,
  output wire [31:0] ibus_dat_miso
);
  localparam WORDS = (1 << ADDR_WIDTH);

  reg data_pending;
  reg instruction_pending;
  wire [31:0] data_read;
  wire [31:0] instruction_read;

  wire data_request = dbus_cyc && dbus_stb;
  wire instruction_request = ibus_cyc && ibus_stb;
  wire data_start = data_request && !data_pending;
  wire data_complete = data_request && data_pending;
  wire instruction_complete = instruction_request && instruction_pending;
  wire [ADDR_WIDTH-1:0] data_address = dbus_adr[ADDR_WIDTH+1:2];
  wire [ADDR_WIDTH-1:0] instruction_address = ibus_adr[ADDR_WIDTH+1:2];

`ifdef VERILATOR
  reg [31:0] memory [0:WORDS-1];
  reg [31:0] data_read_reg;
  reg [31:0] instruction_read_reg;

  initial $readmemh(HEX_FILE, memory);

  always @(posedge clk) begin
    if (data_request)
      data_read_reg <= memory[data_address];
    if (instruction_request)
      instruction_read_reg <= memory[instruction_address];
    if (data_start && dbus_we) begin
      if (dbus_sel[3]) memory[data_address][31:24] <= dbus_dat_mosi[31:24];
      if (dbus_sel[2]) memory[data_address][23:16] <= dbus_dat_mosi[23:16];
      if (dbus_sel[1]) memory[data_address][15:8]  <= dbus_dat_mosi[15:8];
      if (dbus_sel[0]) memory[data_address][7:0]   <= dbus_dat_mosi[7:0];
    end
  end

  assign data_read = data_read_reg;
  assign instruction_read = instruction_read_reg;
`else
  j2_eg4_bram32 #(.INIT_FILE(INIT_FILE)) ram (
    .clk(clk),
    .addra(data_address),
    .cea(data_request),
    .bea(data_start && dbus_we ? dbus_sel : 4'b0000),
    .dia(dbus_dat_mosi),
    .doa(data_read),
    .addrb(instruction_address),
    .ceb(instruction_request),
    .dib(32'b0),
    .dob(instruction_read)
  );
`endif

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      data_pending <= 1'b0;
      instruction_pending <= 1'b0;
      dbus_ack <= 1'b0;
      ibus_ack <= 1'b0;
      dbus_dat_miso <= 32'b0;
    end else begin
      dbus_ack <= data_complete;
      ibus_ack <= instruction_complete;
      if (data_complete)
        dbus_dat_miso <= data_read;
      if (data_request)
        data_pending <= !data_pending;
      else
        data_pending <= 1'b0;
      if (instruction_request)
        instruction_pending <= !instruction_pending;
      else
        instruction_pending <= 1'b0;
    end
  end

  assign ibus_dat_miso = {
    16'b0,
    ibus_adr[1] ? instruction_read[15:0] : instruction_read[31:16]
  };
endmodule

`default_nettype wire
