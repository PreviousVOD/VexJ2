// J2 instruction decoder: decode core + decode table + pipeline registers.
//
// Ported from reference/soc_top/components/cpu/decode/decode.vhd.
//
// The table output for the op in ID is registered into the pipeline when
// 'slot' is high:  ex1 (EX stage), wb1 (EX), wb2 (MA), wb3 (WB).
// Side-effecting "_stall" records get bubbles while ID is stalled.
module j2_decode
  import j2_cpu_pkg::*;
  import j2_decode_pkg::*;
#(
  parameter bit ILLEGAL_VEC_FIX = 1'b1
) (
  input  logic         clk,
  input  logic         rst,
  input  logic         slot,
  input  logic         enter_debug,
  input  cpu_event_i_t event_i,
  input  logic [3:0]   ibit,
  input  logic [15:0]  if_dr,
  input  logic         if_stall,
  input  logic         illegal_delay_slot,
  input  logic         illegal_instr,
  input  logic         mac_busy,
  input  logic         mask_int,
  input  logic         t_bcc,
  output buses_ctrl_t  buses,
  output logic         debug,
  output logic         event_ack,
  output func_ctrl_t   func,
  output instr_ctrl_t  instr,
  output mac_ctrl_t    mac,
  output mem_ctrl_t    mem,
  output pc_ctrl_t     pc,
  output reg_ctrl_t    reg_o,
  output logic         slp,
  output sr_ctrl_t     sr
);

  operation_t      op;
  logic            next_id_stall;
  logic            core_if_issue, core_ifadsel, core_incpc;
  logic [3:0]      core_ilevel;
  decode_table_o_t t_raw;
  pipeline_ex_t    t_ex;
  pipeline_wb_t    t_wb;
  mac_busy_t       mac_busy_sel;
  pipeline_t       p_q, p_d;

  j2_decode_core #(.ILLEGAL_VEC_FIX(ILLEGAL_VEC_FIX)) u_core (
    .clk, .rst, .slot,
    .delay_jump(t_raw.delay_jump), .dispatch(t_raw.dispatch), .event_ack_0(t_raw.event_ack_0),
    .ex(t_raw.ex), .ex_stall(t_raw.ex_stall), .id(t_raw.id), .ilevel_cap(t_raw.ilevel_cap),
    .mac_stall_sense(t_raw.mac_stall_sense), .maskint_next(mask_int | t_raw.maskint_next),
    .debug(t_raw.debug), .p(p_q),
    .event_i, .ibit, .if_dr, .if_stall, .illegal_delay_slot, .illegal_instr, .mac_busy,
    .enter_debug,
    .event_ack, .if_issue(core_if_issue), .ifadsel(core_ifadsel), .ilevel(core_ilevel),
    .incpc(core_incpc), .op, .next_id_stall
  );

  // The table's mac_busy outputs depend on next_id_stall, which itself
  // depends on table outputs (register conflict). The table is evaluated
  // with next_id_stall = 0 and the two stall-dependent bits are applied here,
  // which keeps the logic identical but avoids a false combinational loop.
  j2_decode_table u_table (.next_id_stall(1'b0), .op, .t_bcc, .o(t_raw), .mac_busy_sel);

  always_comb begin
    t_ex = t_raw.ex;
    t_wb = t_raw.wb;
    t_ex.mac_busy = (mac_busy_sel == MACB_EX_NOT_STALL) ? ~next_id_stall
                                                        : (mac_busy_sel == MACB_EX_BUSY);
    t_wb.mac_busy = (mac_busy_sel == MACB_WB_NOT_STALL) ? ~next_id_stall
                                                        : (mac_busy_sel == MACB_WB_BUSY);
  end

  assign debug = t_raw.debug;
  assign slp   = t_raw.slp;

  // pipeline control registers
  always_comb begin
    p_d = p_q;
    if (slot) begin
      p_d.wb3       = p_q.wb2;
      p_d.wb2       = p_q.wb1;
      p_d.wb1       = t_wb;
      p_d.ex1       = t_ex;
      p_d.wb3_stall = p_q.wb2_stall;
      p_d.wb2_stall = p_q.wb1_stall;
      if (next_id_stall) begin
        p_d.ex1_stall = STAGE_EX_STALL_RESET;
        p_d.wb1_stall = STAGE_WB_STALL_RESET;
      end else begin
        p_d.ex1_stall = t_raw.ex_stall;
        p_d.wb1_stall = t_raw.wb_stall;
      end
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) p_q <= PIPELINE_RESET;
    else     p_q <= p_d;
  end

  // ---------------------------------------------------- stage outputs
  always_comb begin
    func.alu.inx_sel = p_q.ex1.aluinx_sel;
    func.alu.iny_sel = p_q.ex1.aluiny_sel;
    func.alu.manip   = p_q.ex1.alumanip;
    func.arith.ci_en = p_q.ex1.arith_ci_en;
    func.arith.func  = p_q.ex1.arith_func;
    func.arith.sr    = p_q.ex1.arith_sr_func;
    func.logic_func  = p_q.ex1.logic_func;
    func.logic_sr    = p_q.ex1.logic_sr_func;
    func.shift       = p_q.ex1_stall.shiftfunc;

    buses.imm_val = p_q.ex1.imm_val;
    buses.x_sel   = p_q.ex1.xbus_sel;
    buses.y_sel   = p_q.ex1.ybus_sel;
    buses.z_sel   = p_q.ex1_stall.zbus_sel;

    mem.issue     = p_q.ex1_stall.ma_issue;
    mem.wr        = p_q.ex1.ma_wr;
    mem.lock      = p_q.ex1.mem_lock;
    mem.size      = p_q.ex1.mem_size;
    mem.addr_sel  = p_q.ex1_stall.mem_addr_sel;
    mem.wdata_sel = p_q.ex1_stall.mem_wdata_sel;

    reg_o.num_x = p_q.ex1.regnum_x;
    reg_o.num_y = p_q.ex1.regnum_y;
    reg_o.num_z = p_q.ex1.regnum_z;
    reg_o.num_w = p_q.wb3.regnum_w;
    reg_o.wr_z  = p_q.ex1_stall.wrreg_z;
    reg_o.wr_w  = p_q.wb3_stall.wrreg_w;

    pc.wr_z = p_q.ex1_stall.wrpc_z;
    pc.wrpr = p_q.ex1_stall.wrpr_pc;
    pc.inc  = core_incpc;

    instr.issue    = core_if_issue;
    instr.addr_sel = core_ifadsel;

    sr.t      = p_q.ex1_stall.t_sel;
    sr.sel    = p_q.wb3_stall.wrsr_w ? SR_WBUS : p_q.ex1_stall.sr_sel;
    sr.ilevel = core_ilevel;

    mac.s_latch = t_raw.mac_s_latch;
    // MAC controls merge the EX stage (register loads) and WB stage
    // (MAC.W/MAC.L operands from memory); EX has priority.
    mac.com1   = p_q.ex1_stall.mulcom1 | p_q.wb3_stall.mulcom1;
    mac.wrmach = p_q.ex1_stall.wrmach  | p_q.wb3_stall.wrmach;
    mac.wrmacl = p_q.ex1_stall.wrmacl  | p_q.wb3_stall.wrmacl;
    mac.sel1   = (p_q.ex1_stall.mulcom1 | p_q.ex1_stall.wrmach) ? p_q.ex1_stall.macsel1
                                                                : p_q.wb3_stall.macsel1;
    mac.sel2   = (p_q.ex1_stall.mulcom2 != MULT_NOP || p_q.ex1_stall.wrmacl)
                   ? p_q.ex1_stall.macsel2 : p_q.wb3_stall.macsel2;
    mac.com2   = (p_q.ex1_stall.mulcom2 != MULT_NOP) ? p_q.ex1_stall.mulcom2
                                                     : p_q.wb3_stall.mulcom2;
  end

endmodule
