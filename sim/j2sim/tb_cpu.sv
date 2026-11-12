// j2sim CPU testbench top: j2_cpu with flat Wishbone ports for the C++
// models, plus trace points used by the ISS checker.
module tb_cpu
  import j2_cpu_pkg::*;
  import j2_decode_pkg::*;
  import j2_wb_pkg::*;
#(
  parameter bit ILLEGAL_VEC_FIX     = 1'b1,
  parameter bit ILLEGAL_OPCODE_TRAP = 1'b1
) (
  input  logic        clk, rst,
  // instruction bus
  output logic        ib_cyc, ib_stb, ib_jp,
  output logic [31:0] ib_adr,
  output logic [3:0]  ib_sel,
  input  logic        ib_ack, ib_stall,
  input  logic [31:0] ib_dat,
  // data bus
  output logic        db_cyc, db_stb, db_we, db_lock,
  output logic [31:0] db_adr, db_dat_o,
  output logic [3:0]  db_sel,
  input  logic        db_ack, db_stall,
  input  logic [31:0] db_dat_i,
  // events
  input  logic        ev_en, ev_msk,
  input  logic [1:0]  ev_cmd,
  input  logic [7:0]  ev_vec,
  input  logic [3:0]  ev_lvl,
  output logic        ev_ack, ev_slp, ev_dbg,
  output logic [3:0]  ev_sr_i,
  // debug port
  input  logic        dbg_en, dbg_d_en,
  input  logic [1:0]  dbg_cmd,
  input  logic [15:0] dbg_ir,
  input  logic [31:0] dbg_d,
  output logic        dbg_ack, dbg_rdy,
  output logic [31:0] dbg_dout,
  // ---- trace points (simulation only)
  output logic        tr_slot,
  output logic        tr_start,        // an operation starts executing this slot
  output logic        tr_op_sys,       //   ... system plane (event / illegal / break)
  output logic [15:0] tr_op_code,
  output logic        tr_reg_we,       // register file commit this slot
  output logic [4:0]  tr_reg_n,
  output logic [31:0] tr_reg_d,
  output logic [31:0] tr_pc
);
  wb_m2s_t ibus_o, dbus_o;
  wb_s2m_t ibus_i, dbus_i;
  cpu_event_o_t ev_o;
  cpu_debug_o_t dbg_o;

  j2_cpu #(.ILLEGAL_VEC_FIX(ILLEGAL_VEC_FIX), .ILLEGAL_OPCODE_TRAP(ILLEGAL_OPCODE_TRAP)) dut (
    .clk, .rst, .ibus_o, .ibus_i, .dbus_o, .dbus_i,
    .debug_i('{en: dbg_en, cmd: cpu_debug_cmd_t'(dbg_cmd), ir: dbg_ir, d: dbg_d, d_en: dbg_d_en}),
    .debug_o(dbg_o),
    .event_i('{en: ev_en, cmd: cpu_event_cmd_t'(ev_cmd), vec: ev_vec, msk: ev_msk, lvl: ev_lvl}),
    .event_o(ev_o));

  assign {ib_cyc, ib_stb, ib_jp, ib_adr, ib_sel} =
         {ibus_o.cyc, ibus_o.stb, ibus_o.tgc[0], ibus_o.adr, ibus_o.sel};
  assign ibus_i = '{ack: ib_ack, err: 1'b0, stall: ib_stall, dat: ib_dat};
  assign {db_cyc, db_stb, db_we, db_lock, db_adr, db_dat_o, db_sel} =
         {dbus_o.cyc, dbus_o.stb, dbus_o.we, dbus_o.lock, dbus_o.adr, dbus_o.dat, dbus_o.sel};
  assign dbus_i = '{ack: db_ack, err: 1'b0, stall: db_stall, dat: db_dat_i};
  assign {ev_ack, ev_sr_i, ev_slp, ev_dbg} = {ev_o.ack, ev_o.lvl, ev_o.slp, ev_o.dbg};
  assign {dbg_ack, dbg_dout, dbg_rdy} = {dbg_o.ack, dbg_o.d, dbg_o.rdy};

  // An operation starts when the decoder takes a new op in a slot without
  // stalling (a stalled first attempt is replayed). Delay-slot instructions
  // count as their own operation.
  assign tr_slot    = dut.u_datapath.slot;
  assign tr_start   = dut.u_datapath.slot && dut.u_decode.u_core.q.instr_seq_zero &&
                      !dut.u_decode.next_id_stall;
  assign tr_op_sys  = dut.u_decode.op.plane == SYSTEM_INSTR;
  assign tr_op_code = dut.u_decode.op.code;
  assign tr_reg_we  = dut.u_datapath.slot && dut.u_datapath.u_regfile.wr_en;
  assign tr_reg_n   = dut.u_datapath.u_regfile.wr_addr;
  assign tr_reg_d   = dut.u_datapath.u_regfile.wr_data;
  assign tr_pc      = dut.u_datapath.pc_q;
endmodule
