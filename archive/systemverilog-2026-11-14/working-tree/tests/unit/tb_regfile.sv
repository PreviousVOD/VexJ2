// Register file equivalence harness: j2_regfile vs original register_file(two_bank).
module tb_regfile (
  input  logic        clk, rst, ce,
  input  logic [4:0]  addr_ra, addr_rb,
  input  logic        we_wb, we_ex,
  input  logic [4:0]  w_addr_wb, w_addr_ex,
  input  logic [31:0] din_wb, din_ex,
  output logic [31:0] dout_a, dout_b, dout_0, wr_data_o,
  output logic [31:0] r_dout_a, r_dout_b, r_dout_0, r_wr_data_o
);
  j2_regfile dut (.clk, .rst, .ce, .addr_ra, .dout_a, .addr_rb, .dout_b, .dout_0,
                  .we_wb, .w_addr_wb, .din_wb, .we_ex, .w_addr_ex, .din_ex, .wr_data_o);
  ref_regfile r (.clk, .rst, .ce, .addr_ra, .dout_a(r_dout_a), .addr_rb, .dout_b(r_dout_b),
                 .dout_0(r_dout_0), .we_wb, .w_addr_wb, .din_wb, .we_ex, .w_addr_ex, .din_ex,
                 .wr_data_o(r_wr_data_o));
endmodule
