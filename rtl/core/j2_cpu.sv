// J2 CPU core (SH-2 compatible, J-Core J2 pipeline) with Wishbone B4
// pipelined instruction and data bus masters.
//
// Ported from reference/soc_top/components/cpu/core/cpu.vhd.
//   j2_decode    instruction decode + pipeline control
//   j2_datapath  buses, ALU, register file, PC/SR, bus units, debug unit
//   j2_mult      multiply / MAC unit
//
// ILLEGAL_VEC_FIX: 1 = illegal / slot-illegal instructions use vectors 4 / 6
// (SH-2); 0 = as the released J2 (vector 0, i.e. through VBR+0).
// ILLEGAL_OPCODE_TRAP: 1 = every undefined opcode raises the general illegal
// instruction exception; 0 = only 0xFFxx (as the released J2).
module j2_cpu
  import j2_cpu_pkg::*;
  import j2_decode_pkg::*;
  import j2_wb_pkg::*;
#(
  parameter bit ILLEGAL_VEC_FIX     = 1'b1,
  parameter bit ILLEGAL_OPCODE_TRAP = 1'b1
) (
  input  logic         clk,
  input  logic         rst,
  // instruction bus (Wishbone B4 pipelined master, read only)
  output wb_m2s_t      ibus_o,
  input  wb_s2m_t      ibus_i,
  // data bus (Wishbone B4 pipelined master)
  output wb_m2s_t      dbus_o,
  input  wb_s2m_t      dbus_i,
  // debug port
  input  cpu_debug_i_t debug_i,
  output cpu_debug_o_t debug_o,
  // events: interrupts, errors, reset, break
  input  cpu_event_i_t event_i,
  output cpu_event_o_t event_o
);

  logic        slot, t_bcc, if_stall, mask_int, enter_debug, debug;
  logic        illegal_delay_slot, illegal_instr, event_ack, slp;
  logic [3:0]  ibit;
  logic [15:0] if_dr;
  reg_ctrl_t   reg_c;
  func_ctrl_t  func;
  sr_ctrl_t    sr_c;
  mac_ctrl_t   mac;
  mem_ctrl_t   mem;
  instr_ctrl_t instr;
  pc_ctrl_t    pc_c;
  buses_ctrl_t buses;
  logic [31:0] macin1, macin2, mach, macl;
  logic        mac_s, mac_busy;

  j2_decode #(.ILLEGAL_VEC_FIX(ILLEGAL_VEC_FIX)) u_decode (
    .clk, .rst, .slot, .enter_debug, .event_i, .ibit, .if_dr, .if_stall,
    .illegal_delay_slot, .illegal_instr, .mac_busy, .mask_int, .t_bcc,
    .buses, .debug, .event_ack, .func, .instr, .mac, .mem, .pc(pc_c), .reg_o(reg_c),
    .slp, .sr(sr_c)
  );

  j2_mult u_mult (
    .clk, .rst, .slot,
    .wr_m1(mac.com1), .command(mac.com2), .s(mac_s), .wr_mach(mac.wrmach), .wr_macl(mac.wrmacl),
    .in1(macin1), .in2(macin2), .mach, .macl, .busy(mac_busy)
  );

  j2_datapath #(.ILLEGAL_OPCODE_TRAP(ILLEGAL_OPCODE_TRAP)) u_datapath (
    .clk, .rst,
    .reg_i(reg_c), .func, .sr_ctrl(sr_c), .mac, .mem, .instr, .pc_ctrl(pc_c), .buses, .debug,
    .slot, .t_bcc, .ibit, .if_dr, .if_stall, .mask_int, .enter_debug,
    .illegal_delay_slot, .illegal_instr,
    .macin1, .macin2, .mac_s, .mach, .macl,
    .ibus_o, .ibus_i, .dbus_o, .dbus_i, .debug_i, .debug_o
  );

  assign event_o = '{ack: event_ack, lvl: ibit, slp: slp, dbg: debug};

endmodule
