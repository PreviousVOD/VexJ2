// Lockstep harness: new j2_cpu (Wishbone) next to the converted original CPU
// (native bus). The C++ driver serves both from separate but identical
// memory models with matched per-transaction timing, and compares them every
// cycle. Define REF_ILL to compare against the illegal-vector-fixed variant.
module tb_lockstep
  import j2_cpu_pkg::*;
  import j2_wb_pkg::*;
#(
`ifdef REF_ILL
  parameter bit ILLEGAL_VEC_FIX = 1'b1
`else
  parameter bit ILLEGAL_VEC_FIX = 1'b0
`endif
) (
  input  logic        clk, rst,
  // ---- new CPU: Wishbone
  output logic        n_ib_cyc, n_ib_stb, n_ib_jp,
  output logic [31:0] n_ib_adr,
  output logic [3:0]  n_ib_sel,
  input  logic        n_ib_ack, n_ib_stall,
  input  logic [31:0] n_ib_dat,
  output logic        n_db_cyc, n_db_stb, n_db_we, n_db_lock,
  output logic [31:0] n_db_adr, n_db_dat_o,
  output logic [3:0]  n_db_sel,
  input  logic        n_db_ack, n_db_stall,
  input  logic [31:0] n_db_dat_i,
  // internal request state for comparison with the native bus
  output logic        n_db_pending, n_ib_pending, n_slot,
  output logic [31:0] n_db_a,
  // ---- original CPU: native
  output logic        r_inst_en, r_inst_jp,
  output logic [30:0] r_inst_a,
  input  logic        r_inst_ack,
  input  logic [15:0] r_inst_d,
  output logic        r_db_en, r_db_rd, r_db_wr, r_db_lock,
  output logic [31:0] r_db_a, r_db_do,
  output logic [3:0]  r_db_we,
  input  logic        r_db_ack,
  input  logic [31:0] r_db_di,
  output logic        r_slot,
  // ---- shared: events and debug
  input  logic        ev_en, ev_msk,
  input  logic [1:0]  ev_cmd,
  input  logic [7:0]  ev_vec,
  input  logic [3:0]  ev_lvl,
  output logic        n_ev_ack, n_ev_slp, n_ev_dbg, r_ev_ack, r_ev_slp, r_ev_dbg,
  output logic [3:0]  n_ev_lvl, r_ev_lvl,
  input  logic        dbg_en, dbg_d_en,
  input  logic [1:0]  dbg_cmd,
  input  logic [15:0] dbg_ir,
  input  logic [31:0] dbg_d,
  output logic        n_dbg_ack, n_dbg_rdy, r_dbg_ack, r_dbg_rdy,
  output logic [31:0] n_dbg_d, r_dbg_d,
  // watch signals for debugging mismatches
  output logic [1:0]  n_dstate, r_dstate,
  output logic [3:0]  n_ed, r_ed,
  output logic        n_stoppc, r_stoppc, n_ipend, r_ipend,
  // internal architectural state compared every cycle
  output logic [31:0] n_pc, r_pc,
  output logic [15:0] n_ifdr, r_ifdr,
  output logic [7:0]  n_sr, r_sr,
  output logic [32:0] n_dc, r_dc     // decode_core state
);
  wb_m2s_t ibus_o, dbus_o;
  wb_s2m_t ibus_i, dbus_i;
  cpu_event_i_t ev_i;
  cpu_event_o_t ev_o;
  cpu_debug_i_t dbg_i;
  cpu_debug_o_t dbg_o;

  assign ev_i  = '{en: ev_en, cmd: cpu_event_cmd_t'(ev_cmd), vec: ev_vec, msk: ev_msk, lvl: ev_lvl};
  assign dbg_i = '{en: dbg_en, cmd: cpu_debug_cmd_t'(dbg_cmd), ir: dbg_ir, d: dbg_d, d_en: dbg_d_en};

  j2_cpu #(.ILLEGAL_VEC_FIX(ILLEGAL_VEC_FIX)) dut (
    .clk, .rst, .ibus_o, .ibus_i, .dbus_o, .dbus_i,
    .debug_i(dbg_i), .debug_o(dbg_o), .event_i(ev_i), .event_o(ev_o));

  assign n_ib_cyc = ibus_o.cyc;  assign n_ib_stb = ibus_o.stb;  assign n_ib_jp = ibus_o.tgc[0];
  assign n_ib_adr = ibus_o.adr;  assign n_ib_sel = ibus_o.sel;
  assign ibus_i = '{ack: n_ib_ack, err: 1'b0, stall: n_ib_stall, dat: n_ib_dat};
  assign n_db_cyc = dbus_o.cyc;  assign n_db_stb = dbus_o.stb;  assign n_db_we = dbus_o.we;
  assign n_db_lock = dbus_o.lock; assign n_db_adr = dbus_o.adr; assign n_db_dat_o = dbus_o.dat;
  assign n_db_sel = dbus_o.sel;
  assign dbus_i = '{ack: n_db_ack, err: 1'b0, stall: n_db_stall, dat: n_db_dat_i};

  assign n_db_pending = dut.u_datapath.u_dbus.q.pending;
  assign n_db_a       = dut.u_datapath.u_dbus.q.a;
  assign n_ib_pending = dut.u_datapath.u_ibus.q.pending;
  assign n_slot       = dut.u_datapath.slot;

  assign {n_ev_ack, n_ev_lvl, n_ev_slp, n_ev_dbg} = {ev_o.ack, ev_o.lvl, ev_o.slp, ev_o.dbg};
  assign {n_dbg_ack, n_dbg_d, n_dbg_rdy} = {dbg_o.ack, dbg_o.d, dbg_o.rdy};

`ifdef REF_ILL
  ref_cpu_ill r (
`else
  ref_cpu r (
`endif
    .clk, .rst,
    .db_en(r_db_en), .db_a(r_db_a), .db_rd(r_db_rd), .db_wr(r_db_wr), .db_we(r_db_we),
    .db_do(r_db_do), .db_lock(r_db_lock), .db_di(r_db_di), .db_ack(r_db_ack),
    .inst_en(r_inst_en), .inst_a(r_inst_a), .inst_jp(r_inst_jp), .inst_d(r_inst_d),
    .inst_ack(r_inst_ack),
    .dbg_o_ack(r_dbg_ack), .dbg_o_d(r_dbg_d), .dbg_o_rdy(r_dbg_rdy),
    .dbg_i_en(dbg_en), .dbg_i_cmd(dbg_cmd), .dbg_i_ir(dbg_ir), .dbg_i_d(dbg_d),
    .dbg_i_d_en(dbg_d_en),
    .ev_o_ack(r_ev_ack), .ev_o_lvl(r_ev_lvl), .ev_o_slp(r_ev_slp), .ev_o_dbg(r_ev_dbg),
    .ev_i_en(ev_en), .ev_i_cmd(ev_cmd), .ev_i_vec(ev_vec), .ev_i_msk(ev_msk), .ev_i_lvl(ev_lvl)
  );
  // GHDL keeps the datapath instance; its combinational slot drives the regfile ce.
  assign r_slot = r.u.u_datapath.slot;
  // datapath_reg_t flattened by GHDL, first field at bit 0 (see datapath.vhm)
  assign r_dstate = r.u.u_datapath.this_r[288:287];
  assign r_ed     = r.u.u_datapath.this_r[284:281];
  assign r_stoppc = r.u.u_datapath.this_r[286];
  assign r_ipend  = r.u.u_datapath.this_r[115];
  assign n_dstate = dut.u_datapath.u_debug.q.state;
  assign n_ed     = dut.u_datapath.u_debug.q.enter_debug;
  assign n_stoppc = dut.u_datapath.u_debug.q.stop_pc_inc;
  assign n_ipend  = dut.u_datapath.u_ibus.q.pending;
  assign r_pc     = r.u.u_datapath.this_r[31:0];
  assign r_sr     = r.u.u_datapath.this_r[39:32];         // t,s,q,m,int_mask (bit 32 = t)
  assign r_ifdr   = r.u.u_datapath.this_r[195:180];
  assign n_pc     = dut.u_datapath.pc_q;
  assign n_sr     = {dut.u_datapath.sr.int_mask, dut.u_datapath.sr.m, dut.u_datapath.sr.q,
                     dut.u_datapath.sr.s, dut.u_datapath.sr.t};
  assign n_ifdr   = dut.u_datapath.u_ibus.q.if_dr;
  // decode_core_reg_t: GHDL order (first field at bit 0) vs SV packed (first at MSB)
  assign r_dc = r.u.u_decode.core.this_r;
  assign n_dc = {dut.u_decode.u_core.q.ilevel, dut.u_decode.u_core.q.op.addr,
                 dut.u_decode.u_core.q.op.code, dut.u_decode.u_core.q.op.plane,
                 dut.u_decode.u_core.q.instr_seq_zero, dut.u_decode.u_core.q.id_stall,
                 dut.u_decode.u_core.q.delay_slot, dut.u_decode.u_core.q.maskint};
endmodule
