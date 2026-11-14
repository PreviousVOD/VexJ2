// J2 instruction fetch unit: Wishbone B4 pipelined master.
//
// Replaces the native inst_o register of the original datapath.vhm and the
// if_dr / if_dr_next instruction register pipeline:
//   - 16-bit fetches over a 32-bit bus (sel 1100 / 0011, big-endian halves);
//     'jp' (non-sequential fetch) is driven on tgc[0].
//   - The fetched halfword is moved into if_dr at the next slot boundary and
//     pre-decoded for illegal instructions.
//   - The debug unit can start a fetch (STEP/CONTINUE) or insert an
//     instruction word directly (INSERT).
module j2_ibus_wbm
  import j2_decode_pkg::*;
  import j2_wb_pkg::*;
#(
  // 1: every opcode not defined by the ISA spec is an illegal instruction;
  // 0: only 0xFFxx (as the released J2; other undefined opcodes then have
  //    unspecified behaviour)
  parameter bit ILLEGAL_OPCODE_TRAP = 1'b1
) (
  input  logic        clk,
  input  logic        rst,
  input  logic        slot,
  // fetch request at a slot boundary
  input  logic        fetch,       // slot & issue & fetch allowed
  /* verilator lint_off UNUSEDSIGNAL */  // bit 0 of fetch addresses
  input  logic [31:0] fetch_addr,
  input  logic        fetch_jp,
  // debug unit
  input  logic        dbg_fetch,   // STEP/CONTINUE: (re)start the fetch at dbg_addr
  input  logic        dbg_issue,   //   ... only if the decoder requests a fetch
  input  logic [31:0] dbg_addr,
  /* verilator lint_on UNUSEDSIGNAL */
  input  logic        dbg_insert,  // insert dbg_ir as the next instruction
  input  logic [15:0] dbg_ir,
  // status
  output logic        done,        // fetch completed this cycle
  output logic        busy,        // fetch outstanding after this cycle's ack
  output logic [15:0] if_dr,
  output logic        illegal_delay_slot,
  output logic        illegal_instr,
  // Wishbone
  output wb_m2s_t     wb_o,
  input  wb_s2m_t     wb_i
);

  typedef struct packed {
    logic        pending;
    logic        accepted;
    logic [31:1] a;
    logic        jp;
    logic [15:0] if_dr_next;
    logic        if_en;
    logic [15:0] if_dr;
    logic        illegal_delay_slot;
    logic        illegal_instr;
  } ibus_reg_t;

  ibus_reg_t q, d;

  assign done = q.pending && (wb_i.ack || wb_i.err);

  always_comb begin
    d = q;
    if (q.pending && !q.accepted && !wb_i.stall) d.accepted = 1'b1;
    if (done) begin
      d.if_dr_next = wb_i.err ? 16'h0 : (q.a[1] ? wb_i.dat[15:0] : wb_i.dat[31:16]);
      d.if_en      = 1'b1;
      d.pending    = 1'b0;
    end else if (dbg_insert) begin
      d.if_dr_next = dbg_ir;
      d.if_en      = 1'b1;
    end else if (dbg_fetch) begin
      // as the original: the request register is overwritten
      d.pending  = dbg_issue;
      d.accepted = 1'b0;
      d.a        = dbg_issue ? dbg_addr[31:1] : 31'h0;
      d.jp       = dbg_issue;
    end
    if (slot) begin
      if (d.if_en) begin
        d.if_dr              = d.if_dr_next;
        d.illegal_delay_slot = check_illegal_delay_slot(d.if_dr_next);
        d.illegal_instr      = ILLEGAL_OPCODE_TRAP ? !j2_isa_pkg::opcode_defined(d.if_dr_next)
                                                  : check_illegal_instruction(d.if_dr_next);
        d.if_en              = 1'b0;
      end
      if (fetch && !d.pending) begin
        d.pending  = 1'b1;
        d.accepted = 1'b0;
        d.a        = fetch_addr[31:1];
        d.jp       = fetch_jp;
      end
    end
  end

  // Fetch outstanding after this cycle's ack (feeds 'slot'). Debug-started
  // fetches are ignored here: they only happen in the debug READY state, in
  // which slot is 0 anyway (this also avoids a structural combinational loop
  // slot -> T -> decoder fetch issue -> busy).
  assign busy = q.pending && !done;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) q <= '0;
    else     q <= d;
  end

  assign if_dr              = q.if_dr;
  assign illegal_delay_slot = q.illegal_delay_slot;
  assign illegal_instr      = q.illegal_instr;

  always_comb begin
    wb_o        = WB_M2S_IDLE;
    wb_o.cyc    = q.pending;
    wb_o.stb    = q.pending & ~q.accepted;
    wb_o.adr    = {q.a[31:2], 2'b00};
    wb_o.sel    = q.a[1] ? 4'b0011 : 4'b1100;
    wb_o.tgc[0] = q.jp;
  end

endmodule
