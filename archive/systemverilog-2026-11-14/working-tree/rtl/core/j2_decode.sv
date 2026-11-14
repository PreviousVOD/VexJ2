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
  mac_busy_t       mac_busy_sel;
  logic [31:0]   ex_imm_val;
  xbus_sel_t     ex_xbus_sel;
  ybus_sel_t     ex_ybus_sel;
  regnum_t       ex_regnum_z, ex_regnum_x, ex_regnum_y;
  alumanip_t     ex_alumanip;
  aluinx_sel_t   ex_aluinx_sel;
  aluiny_sel_t   ex_aluiny_sel;
  arith_func_t   ex_arith_func;
  logic          ex_arith_ci_en;
  arith_sr_func_t ex_arith_sr_func;
  logic_func_t   ex_logic_func;
  logic_sr_func_t ex_logic_sr_func;
  logic          ex_mac_busy;
  logic          ex_ma_wr, ex_mem_lock;
  mem_size_t     ex_mem_size;
  pipeline_ex_stall_t ex1_stall_q;
  pipeline_wb_t       wb1_q, wb2_q, wb3_q;
  pipeline_wb_stall_t wb1_stall_q, wb2_stall_q, wb3_stall_q;
  pipeline_t          p_view;

  always_comb begin
    p_view             = PIPELINE_RESET;
    p_view.ex1.imm_val       = ex_imm_val;
    p_view.ex1.xbus_sel      = ex_xbus_sel;
    p_view.ex1.ybus_sel      = ex_ybus_sel;
    p_view.ex1.regnum_z      = ex_regnum_z;
    p_view.ex1.regnum_x      = ex_regnum_x;
    p_view.ex1.regnum_y      = ex_regnum_y;
    p_view.ex1.alumanip      = ex_alumanip;
    p_view.ex1.aluinx_sel    = ex_aluinx_sel;
    p_view.ex1.aluiny_sel    = ex_aluiny_sel;
    p_view.ex1.arith_func    = ex_arith_func;
    p_view.ex1.arith_ci_en   = ex_arith_ci_en;
    p_view.ex1.arith_sr_func = ex_arith_sr_func;
    p_view.ex1.logic_func    = ex_logic_func;
    p_view.ex1.logic_sr_func = ex_logic_sr_func;
    p_view.ex1.mac_busy      = ex_mac_busy;
    p_view.ex1.ma_wr         = ex_ma_wr;
    p_view.ex1.mem_lock      = ex_mem_lock;
    p_view.ex1.mem_size      = ex_mem_size;
    p_view.ex1_stall   = ex1_stall_q;
    p_view.wb1         = wb1_q;
    p_view.wb2         = wb2_q;
    p_view.wb3         = wb3_q;
    p_view.wb1_stall   = wb1_stall_q;
    p_view.wb2_stall   = wb2_stall_q;
    p_view.wb3_stall   = wb3_stall_q;
  end

  j2_decode_core #(.ILLEGAL_VEC_FIX(ILLEGAL_VEC_FIX)) u_core (
    .clk, .rst, .slot,
    .delay_jump(t_raw.delay_jump), .dispatch(t_raw.dispatch), .event_ack_0(t_raw.event_ack_0),
    .ex(t_raw.ex), .ex_stall(t_raw.ex_stall), .id(t_raw.id), .ilevel_cap(t_raw.ilevel_cap),
    .mac_stall_sense(t_raw.mac_stall_sense), .maskint_next(mask_int | t_raw.maskint_next),
    .debug(t_raw.debug), .p(p_view),
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

  assign debug = t_raw.debug;
  assign slp   = t_raw.slp;

  // Pipeline control registers.  Keep the struct fields as separate
  // nonblocking assignments: this is equivalent to the former p_q/p_d pair,
  // but avoids constructing a wide temporary mux around the decoder output.
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      ex_imm_val    <= STAGE_EX_RESET.imm_val;
      ex_xbus_sel   <= STAGE_EX_RESET.xbus_sel;
      ex_ybus_sel   <= STAGE_EX_RESET.ybus_sel;
      ex_regnum_z   <= STAGE_EX_RESET.regnum_z;
      ex_regnum_x   <= STAGE_EX_RESET.regnum_x;
      ex_regnum_y   <= STAGE_EX_RESET.regnum_y;
      ex_alumanip   <= STAGE_EX_RESET.alumanip;
      ex_aluinx_sel <= STAGE_EX_RESET.aluinx_sel;
      ex_aluiny_sel <= STAGE_EX_RESET.aluiny_sel;
    end else if (slot) begin
      ex_imm_val    <= t_raw.ex.imm_val;
      ex_xbus_sel   <= t_raw.ex.xbus_sel;
      ex_ybus_sel   <= t_raw.ex.ybus_sel;
      ex_regnum_z   <= t_raw.ex.regnum_z;
      ex_regnum_x   <= t_raw.ex.regnum_x;
      ex_regnum_y   <= t_raw.ex.regnum_y;
      ex_alumanip   <= t_raw.ex.alumanip;
      ex_aluinx_sel <= t_raw.ex.aluinx_sel;
      ex_aluiny_sel <= t_raw.ex.aluiny_sel;
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      ex_arith_func    <= STAGE_EX_RESET.arith_func;
      ex_arith_ci_en   <= STAGE_EX_RESET.arith_ci_en;
      ex_arith_sr_func <= STAGE_EX_RESET.arith_sr_func;
      ex_logic_func    <= STAGE_EX_RESET.logic_func;
      ex_logic_sr_func <= STAGE_EX_RESET.logic_sr_func;
      ex_mac_busy      <= STAGE_EX_RESET.mac_busy;
      ex_ma_wr         <= STAGE_EX_RESET.ma_wr;
      ex_mem_lock      <= STAGE_EX_RESET.mem_lock;
      ex_mem_size      <= STAGE_EX_RESET.mem_size;
    end else if (slot) begin
      ex_arith_func    <= t_raw.ex.arith_func;
      ex_arith_ci_en   <= t_raw.ex.arith_ci_en;
      ex_arith_sr_func <= t_raw.ex.arith_sr_func;
      ex_logic_func    <= t_raw.ex.logic_func;
      ex_logic_sr_func <= t_raw.ex.logic_sr_func;
      ex_mac_busy      <= (mac_busy_sel == MACB_EX_NOT_STALL) ? ~next_id_stall
                                                              : (mac_busy_sel == MACB_EX_BUSY);
      ex_ma_wr         <= t_raw.ex.ma_wr;
      ex_mem_lock      <= t_raw.ex.mem_lock;
      ex_mem_size      <= t_raw.ex.mem_size;
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst)
      ex1_stall_q <= STAGE_EX_STALL_RESET;
    else if (slot)
      ex1_stall_q <= next_id_stall ? STAGE_EX_STALL_RESET : t_raw.ex_stall;
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      wb1_q <= STAGE_WB_RESET;
    end else if (slot) begin
      wb1_q.regnum_w <= t_raw.wb.regnum_w;
      wb1_q.mac_busy <= (mac_busy_sel == MACB_WB_NOT_STALL) ? ~next_id_stall
                                                            : (mac_busy_sel == MACB_WB_BUSY);
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) wb2_q <= STAGE_WB_RESET;
    else if (slot) wb2_q <= wb1_q;
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) wb3_q <= STAGE_WB_RESET;
    else if (slot) wb3_q <= wb2_q;
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) wb1_stall_q <= STAGE_WB_STALL_RESET;
    else if (slot)
      wb1_stall_q <= next_id_stall ? STAGE_WB_STALL_RESET : t_raw.wb_stall;
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) wb2_stall_q <= STAGE_WB_STALL_RESET;
    else if (slot) wb2_stall_q <= wb1_stall_q;
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) wb3_stall_q <= STAGE_WB_STALL_RESET;
    else if (slot) wb3_stall_q <= wb2_stall_q;
  end

  // ---------------------------------------------------- stage outputs
  always_comb begin
    func.alu.inx_sel = ex_aluinx_sel;
    func.alu.iny_sel = ex_aluiny_sel;
    func.alu.manip   = ex_alumanip;
    func.arith.ci_en = ex_arith_ci_en;
    func.arith.func  = ex_arith_func;
    func.arith.sr    = ex_arith_sr_func;
    func.logic_func  = ex_logic_func;
    func.logic_sr    = ex_logic_sr_func;
    func.shift       = ex1_stall_q.shiftfunc;

    buses.imm_val = ex_imm_val;
    buses.x_sel   = ex_xbus_sel;
    buses.y_sel   = ex_ybus_sel;
    buses.z_sel   = ex1_stall_q.zbus_sel;

    mem.issue     = ex1_stall_q.ma_issue;
    mem.wr        = ex_ma_wr;
    mem.lock      = ex_mem_lock;
    mem.size      = ex_mem_size;
    mem.addr_sel  = ex1_stall_q.mem_addr_sel;
    mem.wdata_sel = ex1_stall_q.mem_wdata_sel;

    reg_o.num_x = ex_regnum_x;
    reg_o.num_y = ex_regnum_y;
    reg_o.num_z = ex_regnum_z;
    reg_o.num_w = wb3_q.regnum_w;
    reg_o.wr_z  = ex1_stall_q.wrreg_z;
    reg_o.wr_w  = wb3_stall_q.wrreg_w;

    pc.wr_z = ex1_stall_q.wrpc_z;
    pc.wrpr = ex1_stall_q.wrpr_pc;
    pc.inc  = core_incpc;

    instr.issue    = core_if_issue;
    instr.addr_sel = core_ifadsel;

    sr.t      = ex1_stall_q.t_sel;
    sr.sel    = wb3_stall_q.wrsr_w ? SR_WBUS : ex1_stall_q.sr_sel;
    sr.ilevel = core_ilevel;

    mac.s_latch = t_raw.mac_s_latch;
    // MAC controls merge the EX stage (register loads) and WB stage
    // (MAC.W/MAC.L operands from memory); EX has priority.
    mac.com1   = ex1_stall_q.mulcom1 | wb3_stall_q.mulcom1;
    mac.wrmach = ex1_stall_q.wrmach  | wb3_stall_q.wrmach;
    mac.wrmacl = ex1_stall_q.wrmacl  | wb3_stall_q.wrmacl;
    mac.sel1   = (ex1_stall_q.mulcom1 | ex1_stall_q.wrmach) ? ex1_stall_q.macsel1
                                                            : wb3_stall_q.macsel1;
    mac.sel2   = (ex1_stall_q.mulcom2 != MULT_NOP || ex1_stall_q.wrmacl)
                   ? ex1_stall_q.macsel2 : wb3_stall_q.macsel2;
    mac.com2   = (ex1_stall_q.mulcom2 != MULT_NOP) ? ex1_stall_q.mulcom2
                                                   : wb3_stall_q.mulcom2;
  end

endmodule
