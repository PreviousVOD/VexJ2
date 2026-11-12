// J2 status register (SR: T, S, I[3:0], Q, M).
//
// Ported from the SR update in reference/.../cpu/core/datapath.vhm.
// Updated at slot boundaries; 'sr_next' is the combinational next value (the
// decoder uses sr_next.t for conditional branches in the same slot).
module j2_sr
  import j2_cpu_pkg::*;
  import j2_decode_pkg::*;
  import j2_alu_pkg::*;
(
  input  logic           clk,
  input  logic           rst,
  input  logic           slot,
  input  sr_ctrl_t       ctrl,
  input  logic [31:0]    wbus,
  input  logic [31:0]    zbus,
  input  logic           x_msb,        // X/Y bus MSBs (for DIV1 the ALU input
  input  logic           y_msb,        //  is already shifted, so not used)
  input  logic [32:0]    arith_out,
  input  arith_func_t    arith_func,   // effective function (DIV1 resolved)
  input  arith_sr_func_t arith_sr,
  input  logic [31:0]    logic_out,
  input  logic_sr_func_t logic_sr,
  input  logic           sfto,         // shifted-out bit
  output sr_t            sr,
  output sr_t            sr_next
);

  function automatic sr_t to_sr(logic [31:0] a);
    return '{t: a[SR_T], s: a[SR_S], q: a[SR_Q], m: a[SR_M], int_mask: a[SR_I3:SR_I0]};
  endfunction

  always_comb begin
    sr_next = sr;
    if (slot) begin
      unique case (ctrl.sel)
        SR_WBUS : sr_next = to_sr(wbus);
        SR_ZBUS : sr_next = to_sr(zbus);
        SR_DIV0U: begin
          sr_next.m = 1'b0;
          sr_next.q = 1'b0;
          sr_next.t = 1'b0;
        end
        SR_ARITH: sr_next = arith_update_sr(sr, x_msb, y_msb, arith_out[31:0], arith_out[32],
                                            arith_func, arith_sr);
        SR_LOGIC: sr_next = logic_update_sr(sr, logic_out, logic_sr);
        SR_INT_MASK: sr_next.int_mask = ctrl.ilevel;
        SR_SET_T: unique case (ctrl.t)
          T_CLEAR: sr_next.t = 1'b0;
          T_SET  : sr_next.t = 1'b1;
          T_SHIFT: sr_next.t = sfto;
          default: sr_next.t = arith_out[32];  // T_CARRY
        endcase
        default: ;  // SR_PREV
      endcase
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) sr <= '{int_mask: 4'b1111, default: '0};
    else     sr <= sr_next;
  end

endmodule
