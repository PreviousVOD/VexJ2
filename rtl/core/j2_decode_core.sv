// J2 decoder core: selects the operation being decoded each slot and
// generates stalls.
//
// Ported from reference/soc_top/components/cpu/decode/decode_core.vhm
// (configuration cpu_decode_reverse: decode_type REVERSE, DEC_CORE_RESET).
//
//   op priority:  event > slot-illegal > general-illegal > break > instruction
//   multi-step operations: op.addr counts micro-steps; 'dispatch' ends one.
//
// ILLEGAL_VEC_FIX: the released J2 builds the general/slot illegal system ops
// with vector 0, so they vector through VBR+0 (the reset vector). 1 = use the
// SH-2 vectors 4 (general illegal) and 6 (slot illegal).
module j2_decode_core
  import j2_cpu_pkg::*;
  import j2_decode_pkg::*;
#(
  parameter bit ILLEGAL_VEC_FIX = 1'b1
) (
  input  logic               clk,
  input  logic               rst,
  input  logic               slot,
  // from the decode table (current op)
  input  logic               delay_jump,
  input  logic               dispatch,
  input  logic               event_ack_0,
  /* verilator lint_off UNUSEDSIGNAL */  // only some fields of these records are used
  input  pipeline_ex_t       ex,
  input  pipeline_ex_stall_t ex_stall,
  input  pipeline_id_t       id,
  input  logic               ilevel_cap,
  input  logic               mac_stall_sense,
  input  logic               maskint_next,
  input  logic               debug,
  input  pipeline_t          p,
  /* verilator lint_on UNUSEDSIGNAL */
  // from the datapath / outside
  input  cpu_event_i_t       event_i,
  input  logic [3:0]         ibit,
  input  logic [15:0]        if_dr,
  input  logic               if_stall,
  input  logic               illegal_delay_slot,
  input  logic               illegal_instr,
  input  logic               mac_busy,
  input  logic               enter_debug,
  // outputs
  output logic               event_ack,
  output logic               if_issue,
  output logic               ifadsel,
  output logic [3:0]         ilevel,
  output logic               incpc,
  output operation_t         op,
  output logic               next_id_stall
);

  typedef struct packed {
    logic       maskint;
    logic       delay_slot;
    logic       id_stall;
    logic       instr_seq_zero;
    operation_t op;
    logic [3:0] ilevel;
  } decode_core_reg_t;

  localparam decode_core_reg_t DEC_CORE_RESET = '{
    maskint: 1'b0, delay_slot: 1'b0, id_stall: 1'b0, instr_seq_zero: 1'b0,
    op: '{plane: SYSTEM_INSTR, code: 16'h0300, addr: 8'h01}, ilevel: 4'h0};

  decode_core_reg_t q, d;
  operation_t       next_op;
  logic             mac_stall, reg_conf;

  // System operation for an event: code = 0000 0 cmd vec
  /* verilator lint_off UNUSEDSIGNAL */
  function automatic operation_t event_op(cpu_event_i_t ev);
    return '{plane: SYSTEM_INSTR, code: {5'b00000, 1'b0, ev.cmd, ev.vec}, addr: 8'h00};
  endfunction
  /* verilator lint_on UNUSEDSIGNAL */

  function automatic operation_t sys_op(logic [2:0] cmd, logic [7:0] vec);
    return '{plane: SYSTEM_INSTR, code: {5'b00000, cmd, vec}, addr: 8'h00};
  endfunction

  localparam logic [7:0] VEC_GENERAL_ILLEGAL = ILLEGAL_VEC_FIX ? 8'd4 : 8'd0;
  localparam logic [7:0] VEC_SLOT_ILLEGAL    = ILLEGAL_VEC_FIX ? 8'd6 : 8'd0;

  // next operation (exception events take priority over the fetched instruction)
  always_comb begin
    if (!q.delay_slot && event_i.en &&
        ((!q.maskint && event_i.cmd == EV_INTERRUPT && (ibit < event_i.lvl || event_i.msk)) ||
         event_i.cmd == EV_ERROR || event_i.cmd == EV_RESET_CPU || event_i.cmd == EV_BREAK))
      next_op = event_op(event_i);
    else if (q.delay_slot && (illegal_delay_slot || illegal_instr))
      next_op = sys_op(SYS_SLOT_ILLEGAL, VEC_SLOT_ILLEGAL);
    else if (illegal_instr)
      next_op = sys_op(SYS_GENERAL_ILLEGAL, VEC_GENERAL_ILLEGAL);
    else if (!q.delay_slot && enter_debug)
      next_op = sys_op(SYS_BREAK, 8'h00);
    else
      next_op = '{plane: NORMAL_INSTR, code: if_dr, addr: 8'h00};
  end

  assign op = (q.id_stall || !q.instr_seq_zero) ? q.op : next_op;

  // Register conflict: the instruction in EX loads a register (W bus write in
  // WB) that the instruction in ID reads or writes.
  assign reg_conf = p.wb1_stall.wrreg_w &&
                    ((ex.xbus_sel == XBUS_REG && ex.regnum_x == p.wb1.regnum_w) ||
                     (ex.ybus_sel == YBUS_REG && ex.regnum_y == p.wb1.regnum_w) ||
                     (ex_stall.wrreg_z && ex.regnum_z == p.wb1.regnum_w) ||
                     (ex.aluiny_sel == ALUY_R0 && p.wb1.regnum_w == 5'd0));

  assign mac_stall = mac_stall_sense && (p.wb1.mac_busy || p.wb2.mac_busy || p.wb3.mac_busy ||
                                         p.ex1.mac_busy || mac_busy);

  assign next_id_stall = reg_conf | if_stall | mac_stall;
  assign incpc    = id.incpc & ~next_id_stall;
  assign ifadsel  = id.ifadsel;
  assign if_issue = id.if_issue & ~reg_conf & ~mac_stall;

  assign event_ack = slot && (event_ack_0 || (event_i.en && event_i.cmd == EV_BREAK && debug));

  assign ilevel = q.ilevel;

  always_comb begin
    d = q;
    if (slot) begin
      d.maskint = maskint_next;
      if (ilevel_cap) d.ilevel = event_i.lvl;
      if (!q.id_stall && q.instr_seq_zero) d.op = next_op;
      d.id_stall = next_id_stall;
      if (!next_id_stall) begin
        d.delay_slot     = delay_jump;
        d.instr_seq_zero = dispatch;
        d.op.addr        = d.op.addr + 8'd1;
      end
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) q <= DEC_CORE_RESET;
    else     q <= d;
  end

endmodule
