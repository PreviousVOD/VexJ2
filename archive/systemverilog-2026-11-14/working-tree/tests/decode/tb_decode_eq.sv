// Decoder equivalence harness: new generated table vs the original VHDL
// simple_logic / reverse_logic tables (converted by tools/ref_synth.sh).
module tb_decode_eq
  import j2_decode_pkg::*;
#(
  localparam int W = $bits(decode_table_o_t)
) (
  input  logic         plane,
  input  logic [15:0]  code,
  input  logic [7:0]   addr,
  input  logic         t_bcc,
  input  logic         next_id_stall,
  output logic [W-1:0] o_new,
  output logic [W-1:0] o_simple,
  output logic [W-1:0] o_reverse,
  output logic [W-1:0] care,
  output logic         valid
);
  operation_t      op;
  decode_table_o_t o, c;

  assign op = '{plane: instruction_plane_t'(plane), code: code, addr: addr};

  j2_decode_table dut (.next_id_stall, .op, .t_bcc, .o);
  j2_decode_care  cm  (.op, .o(c), .valid);

  assign o_new = o;
  assign care  = c;

  ref_decode_table_simple  rs (.next_id_stall, .plane, .code, .addr, .t_bcc, .o(o_simple));
  ref_decode_table_reverse rr (.next_id_stall, .plane, .code, .addr, .t_bcc, .o(o_reverse));
endmodule
