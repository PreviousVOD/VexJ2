// J2 datapath.
//
// Ported from reference/soc_top/components/cpu/core/datapath.vhm, split into:
//   j2_regfile   register file (R0-R15, GBR, VBR, PR, TEMP0/1)
//   j2_sr        status register
//   j2_dbus_wbm  data bus Wishbone master (+ W bus register)
//   j2_ibus_wbm  instruction fetch Wishbone master (+ instruction register)
//   j2_debug     debug unit
// This module holds the X/Y/Z buses, the ALU, the PC and the 'slot' signal.
//
// 'slot' is the global pipeline enable: high in a cycle in which no bus
// transaction is outstanding (after this cycle's ack) and the CPU is not
// stopped in debug mode. Bus wait states stretch the slot.
module j2_datapath
  import j2_cpu_pkg::*;
  import j2_decode_pkg::*;
  import j2_alu_pkg::*;
  import j2_wb_pkg::*;
#(
  parameter bit ILLEGAL_OPCODE_TRAP = 1'b1
) (
  input  logic         clk,
  input  logic         rst,
  // decoder controls
  input  reg_ctrl_t    reg_i,
  input  func_ctrl_t   func,
  input  sr_ctrl_t     sr_ctrl,
  /* verilator lint_off UNUSEDSIGNAL */  // multiplier commands go to j2_mult directly
  input  mac_ctrl_t    mac,
  /* verilator lint_on UNUSEDSIGNAL */
  input  mem_ctrl_t    mem,
  input  instr_ctrl_t  instr,
  input  pc_ctrl_t     pc_ctrl,
  input  buses_ctrl_t  buses,
  input  logic         debug,
  // to the decoder
  output logic         slot,
  output logic         t_bcc,
  output logic [3:0]   ibit,
  output logic [15:0]  if_dr,
  output logic         if_stall,
  output logic         mask_int,
  output logic         enter_debug,
  output logic         illegal_delay_slot,
  output logic         illegal_instr,
  // multiplier
  output logic [31:0]  macin1,
  output logic [31:0]  macin2,
  output logic         mac_s,
  input  logic [31:0]  mach,
  input  logic [31:0]  macl,
  // buses
  output wb_m2s_t      ibus_o,
  input  wb_s2m_t      ibus_i,
  output wb_m2s_t      dbus_o,
  input  wb_s2m_t      dbus_i,
  // debug port
  input  cpu_debug_i_t debug_i,
  output cpu_debug_o_t debug_o
);

  logic [31:0] pc_q, pc_inc_q, pc_inc_eff, pc_d;
  logic [31:0] reg_x, reg_y, reg_0, reg_wr_data;
  logic [31:0] xbus, ybus, ybus_temp, zbus, wbus, gpf_zwd;
  logic [31:0] aluinx, aluiny;
  logic [32:0] arith_out;
  logic [31:0] logic_out;
  arith_func_t arith_func;
  logic        sfto;
  sr_t         sr;
  /* verilator lint_off UNUSEDSIGNAL */  // only T and S of the next SR are used here
  sr_t         sr_next;
  /* verilator lint_on UNUSEDSIGNAL */
  logic        mac_s_q;

  // debug unit signals
  debug_state_t dbg_state;
  logic         dbg_fetch, dbg_insert, stop_pc_inc, fetch_allowed;
  logic         ovr_en;
  logic [31:0]  ovr_d;
  // bus unit signals
  logic         d_busy, i_busy, i_done;

  // ------------------------------------------------------------ buses
  function automatic logic [31:0] sr_to_slv(sr_t s);
    logic [31:0] r;
    r = '0;
    r[SR_M] = s.m;
    r[SR_Q] = s.q;
    r[SR_I3:SR_I0] = s.int_mask;
    r[SR_S] = s.s;
    r[SR_T] = s.t;
    return r;
  endfunction

  always_comb begin
    unique case (buses.x_sel)
      XBUS_REG: xbus = reg_x;
      XBUS_PC : xbus = pc_q;
      default : xbus = buses.imm_val;
    endcase
    unique case (buses.y_sel)
      YBUS_REG : ybus_temp = reg_y;
      YBUS_PC  : ybus_temp = pc_q;
      YBUS_MACH: ybus_temp = mach;
      YBUS_MACL: ybus_temp = macl;
      YBUS_SR  : ybus_temp = sr_to_slv(sr);
      default  : ybus_temp = buses.imm_val;
    endcase
  end
  assign ybus    = ovr_en ? ovr_d : ybus_temp;
  assign gpf_zwd = pc_ctrl.wrpr ? pc_q : zbus;

  j2_regfile #(.ADDR_WIDTH(5), .NUM_REGS(21), .REG_WIDTH(32)) u_regfile (
    .clk, .rst, .ce(slot),
    .addr_ra(reg_i.num_x), .dout_a(reg_x), .addr_rb(reg_i.num_y), .dout_b(reg_y), .dout_0(reg_0),
    .we_wb(reg_i.wr_w), .w_addr_wb(reg_i.num_w), .din_wb(wbus),
    .we_ex(reg_i.wr_z), .w_addr_ex(reg_i.num_z), .din_ex(gpf_zwd),
    .wr_data_o(reg_wr_data)
  );

  // -------------------------------------------------------------- ALU
  always_comb begin
    unique case (func.alu.inx_sel)
      ALUX_FC   : aluinx = {xbus[31:2], 2'b00};
      ALUX_ROTCL: aluinx = {xbus[30:0], sr.t};  // DIV1
      ALUX_ZERO : aluinx = 32'h0;
      default   : aluinx = xbus;
    endcase
    unique case (func.alu.iny_sel)
      ALUY_IMM: aluiny = buses.imm_val;
      ALUY_R0 : aluiny = reg_0;
      default : aluiny = ybus;
    endcase
  end

  // DIV1 picks ADD/SUB at run time from M == Q
  assign arith_func = (func.arith.sr == ASR_DIV1) ? ((sr.m == sr.q) ? ARITH_SUB : ARITH_ADD)
                                                  : func.arith.func;
  assign arith_out  = arith_unit(aluinx, aluiny, arith_func, func.arith.ci_en & sr.t);
  assign logic_out  = logic_unit(aluinx, aluiny, func.logic_func);

  always_comb begin
    unique case (buses.z_sel)
      ZBUS_ARITH: zbus = arith_out[31:0];
      ZBUS_LOGIC: zbus = logic_out;
      ZBUS_SHIFT: zbus = bshifter(xbus, {ybus[31], ybus[4:0]}, sr.t, func.shift);
      ZBUS_MANIP: zbus = manip(xbus, ybus, func.alu.manip);
      ZBUS_YBUS : zbus = ybus;
      default   : zbus = wbus;  // ZBUS_WBUS
    endcase
  end

  assign sfto = ybus[31] ? xbus[0] : xbus[31];

  always_comb begin
    unique case (mac.sel1)
      MACIN1_XBUS: macin1 = xbus;
      MACIN1_ZBUS: macin1 = zbus;
      default    : macin1 = wbus;
    endcase
    unique case (mac.sel2)
      MACIN2_YBUS: macin2 = ybus;
      MACIN2_ZBUS: macin2 = zbus;
      default    : macin2 = wbus;
    endcase
  end

  // ------------------------------------------------------------- slot
  assign slot = !d_busy && !i_busy && dbg_state != DS_READY;

  // --------------------------------------------------------------- SR
  j2_sr u_sr (
    .clk, .rst, .slot, .ctrl(sr_ctrl), .wbus, .zbus, .x_msb(xbus[31]), .y_msb(ybus[31]),
    .arith_out, .arith_func, .arith_sr(func.arith.sr), .logic_out, .logic_sr(func.logic_sr),
    .sfto, .sr, .sr_next
  );
  assign t_bcc = sr_next.t;  // decoder needs this cycle's T for branches
  assign ibit  = sr.int_mask;

  // --------------------------------------------------------------- PC
  assign pc_inc_eff = stop_pc_inc ? pc_q : pc_inc_q;
  always_comb begin
    pc_d = pc_q;
    if (slot) begin
      if (pc_ctrl.wr_z)     pc_d = zbus;
      else if (pc_ctrl.inc) pc_d = pc_inc_eff;
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      pc_q     <= '0;
      pc_inc_q <= '0;
      mac_s_q  <= 1'b0;
    end else begin
      pc_q     <= pc_d;
      pc_inc_q <= pc_d + 32'd2;
      if (slot && mac.s_latch) mac_s_q <= sr_next.s;
    end
  end
  assign mac_s = mac_s_q;

  // -------------------------------------------------------- bus units
  logic [31:0] ma_addr, ma_wdata;
  always_comb begin
    unique case (mem.addr_sel)
      MADDR_XBUS: ma_addr = xbus;
      MADDR_YBUS: ma_addr = ybus;
      default   : ma_addr = zbus;
    endcase
    ma_wdata = (mem.wdata_sel == MWDATA_YBUS) ? ybus : zbus;
  end

  j2_dbus_wbm u_dbus (
    .clk, .rst, .slot,
    .issue(mem.issue), .wr(mem.wr), .lock(mem.lock), .size(mem.size),
    .addr(ma_addr), .wdata(ma_wdata),
    .busy(d_busy), .wbus,
    .wb_o(dbus_o), .wb_i(dbus_i)
  );

  j2_ibus_wbm #(.ILLEGAL_OPCODE_TRAP(ILLEGAL_OPCODE_TRAP)) u_ibus (
    .clk, .rst, .slot,
    .fetch(slot && instr.issue && fetch_allowed),
    .fetch_addr(instr.addr_sel ? zbus : pc_inc_eff), .fetch_jp(instr.addr_sel),
    .dbg_fetch, .dbg_issue(instr.issue), .dbg_addr(pc_q),
    .dbg_insert, .dbg_ir(debug_i.ir),
    .done(i_done), .busy(i_busy), .if_dr, .illegal_delay_slot, .illegal_instr,
    .wb_o(ibus_o), .wb_i(ibus_i)
  );
  assign if_stall = 1'b0;

  // ------------------------------------------------------------ debug
  j2_debug u_debug (
    .clk, .rst, .debug_i, .debug_o, .debug,
    .if_done(i_done), .slot, .instr_issue(instr.issue), .pc_next(pc_d),
    .reg_wr_data, .state(dbg_state), .dbg_fetch, .dbg_insert, .stop_pc_inc, .fetch_allowed,
    .enter_debug, .mask_int, .ybus_override_en(ovr_en), .ybus_override_d(ovr_d)
  );

endmodule
