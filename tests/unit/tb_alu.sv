// ALU function equivalence harness: rtl/pkg/j2_alu_pkg.sv vs original VHDL.
module tb_alu
  import j2_cpu_pkg::*;
  import j2_alu_pkg::*;
(
  input  logic [31:0] a, b,
  input  logic [0:0]  arith_func,
  input  logic        ci,
  input  logic [7:0]  sr_in,
  input  logic        a_msb, b_msb,
  input  logic [2:0]  arith_sr,
  input  logic [1:0]  logic_func,
  input  logic [0:0]  logic_sr,
  input  logic [5:0]  shift_b,
  input  logic        shift_c,
  input  logic [1:0]  shift_func,
  input  logic [2:0]  manip_func,
  output logic [32:0] arith_o,    r_arith_o,
  output logic [7:0]  arith_sr_o, r_arith_sr_o,
  output logic [31:0] logic_o,    r_logic_o,
  output logic [7:0]  logic_sr_o, r_logic_sr_o,
  output logic [31:0] shift_o,    r_shift_o,
  output logic [31:0] manip_o,    r_manip_o
);
  always_comb begin
    arith_o    = arith_unit(a, b, arith_func_t'(arith_func), ci);
    arith_sr_o = arith_update_sr(sr_t'(sr_in), a_msb, b_msb, arith_o[31:0], arith_o[32],
                                 arith_func_t'(arith_func), arith_sr_func_t'(arith_sr));
    logic_o    = logic_unit(a, b, logic_func_t'(logic_func));
    logic_sr_o = logic_update_sr(sr_t'(sr_in), logic_o, logic_sr_func_t'(logic_sr));
    shift_o    = bshifter(a, shift_b, shift_c, shiftfunc_t'(shift_func));
    manip_o    = manip(a, b, alumanip_t'(manip_func));
  end

  ref_alu r (.a, .b, .arith_func, .ci, .sr_in, .a_msb, .b_msb, .arith_sr, .logic_func,
             .logic_sr, .shift_b, .shift_c, .shift_func, .manip_func,
             .arith_o(r_arith_o), .arith_sr_o(r_arith_sr_o), .logic_o(r_logic_o),
             .logic_sr_o(r_logic_sr_o), .shift_o(r_shift_o), .manip_o(r_manip_o));
endmodule
