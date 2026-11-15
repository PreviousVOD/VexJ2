`default_nettype none

module EG_PHY_SDRAM_2M_32 (
  input  wire        clk,
  input  wire        ras_n,
  input  wire        cas_n,
  input  wire        we_n,
  input  wire [10:0] addr,
  input  wire [1:0]  ba,
  inout  wire [31:0] dq,
  input  wire        cs_n,
  input  wire        dm0,
  input  wire        dm1,
  input  wire        dm2,
  input  wire        dm3,
  input  wire        cke
);
  reg [31:0] memory [0:2097151];
  reg [10:0] active_row [0:3];
  reg [31:0] read_data;
  reg [1:0] read_count;
  wire [3:0] mask = {dm3, dm2, dm1, dm0};
  wire [2:0] command = {ras_n, cas_n, we_n};
  wire [20:0] read_address = {ba, active_row[ba], addr[7:0]};
  wire [20:0] write_address = {ba, active_row[ba], addr[7:0]};
  integer index;

  initial begin
    read_data = 0;
    read_count = 0;
    for (index = 0; index < 2097152; index = index + 1)
      memory[index] = 0;
  end

  always @(posedge clk) begin
    if (read_count != 0)
      read_count <= read_count - 1'b1;
    if (cke && !cs_n) begin
      case (command)
        3'b011: active_row[ba] <= addr;
        3'b101: begin
          read_data <= memory[read_address];
          read_count <= 3;
        end
        3'b100: begin
          if (!mask[0]) memory[write_address][7:0] <= dq[7:0];
          if (!mask[1]) memory[write_address][15:8] <= dq[15:8];
          if (!mask[2]) memory[write_address][23:16] <= dq[23:16];
          if (!mask[3]) memory[write_address][31:24] <= dq[31:24];
        end
        default: begin
        end
      endcase
    end
  end

  assign dq = read_count != 0 ? read_data : 32'bz;
endmodule

`default_nettype wire
