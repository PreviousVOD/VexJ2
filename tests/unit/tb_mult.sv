// Multiplier equivalence harness: j2_mult vs original mult(stru).
module tb_mult
  import j2_cpu_pkg::*;
(
  input  logic        clk, rst, slot,
  input  logic        wr_m1,
  input  logic [4:0]  command,
  input  logic        s, wr_mach, wr_macl,
  input  logic [31:0] in1, in2,
  output logic [31:0] mach, macl, r_mach, r_macl,
  output logic        busy, r_busy
);
  j2_mult dut (.clk, .rst, .slot, .wr_m1, .command(mult_state_t'(command)), .s, .wr_mach,
               .wr_macl, .in1, .in2, .mach, .macl, .busy);
  ref_mult r (.clk, .rst, .slot, .wr_m1, .command, .s, .wr_mach, .wr_macl, .in1, .in2,
              .mach(r_mach), .macl(r_macl), .busy(r_busy));
endmodule
