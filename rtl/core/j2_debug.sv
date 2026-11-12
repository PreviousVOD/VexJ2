// J2 debug unit.
//
// Ported from the debug-related part of the datapath process in
// reference/soc_top/components/cpu/core/datapath.vhm. Statement order of the
// original process is preserved:
//   1. BREAK instruction (decoder 'debug' rose) / BREAK command while running
//   2. commands in READY (only if no instruction fetch completed this cycle)
//   3. enter_debug shift, using the PREVIOUS cycle's slot
//   4. pausing at the next instruction fetch issue (-> READY)
//   5. command acknowledge / debug_o update, state update
//
// States: RUN -> (BREAK) AWAIT_BREAK -> AWAIT_IF -> READY;
// in READY the CPU is stopped (slot = 0) and accepts INSERT (execute an
// instruction word, optionally overriding the Y bus), STEP, CONTINUE.
module j2_debug
  import j2_cpu_pkg::*;
(
  input  logic         clk,
  input  logic         rst,
  /* verilator lint_off UNUSEDSIGNAL */  // ir goes to the instruction unit
  input  cpu_debug_i_t debug_i,
  /* verilator lint_on UNUSEDSIGNAL */
  output cpu_debug_o_t debug_o,
  input  logic         debug,          // decoder: BREAK sequence raised debug
  input  logic         if_done,        // instruction fetch completed this cycle
  input  logic         slot,           // combinational slot of this cycle
  input  logic         instr_issue,    // decoder requests an instruction fetch
  input  logic [31:0]  pc_next,        // PC after this cycle's update
  input  logic [31:0]  reg_wr_data,    // register file write data (INSERT result)
  output debug_state_t state,          // registered state
  output logic         dbg_fetch,      // STEP/CONTINUE: start fetch at PC
  output logic         dbg_insert,     // INSERT: execute debug_i.ir
  output logic         stop_pc_inc,    // use PC instead of PC+2 for sequential fetch
  output logic         fetch_allowed,  // normal instruction fetches allowed
  output logic         enter_debug,
  output logic         mask_int,
  output logic         ybus_override_en,
  output logic [31:0]  ybus_override_d
);

  typedef struct packed {
    logic        en;
    logic [31:0] d;
  } bus_val_t;

  typedef struct packed {
    debug_state_t state;
    logic [3:0]   enter_debug;
    logic         old_debug;
    logic         stop_pc_inc;
    logic         slot;           // previous cycle's slot
    bus_val_t     ovr2, ovr1, ovr0; // y-bus override pipeline (2 = newest)
    cpu_debug_o_t debug_o;
  } debug_reg_t;

  debug_reg_t q, d;
  debug_state_t next_state;

  assign state         = q.state;
  assign fetch_allowed = (q.state == DS_RUN || q.state == DS_AWAIT_BREAK);

  // commands handled in READY (no fetch completed this cycle)
  logic cmd_ready;
  assign cmd_ready  = q.state == DS_READY && debug_i.en && !if_done;
  assign dbg_insert = cmd_ready && debug_i.cmd == DBG_INSERT;
  assign dbg_fetch  = cmd_ready && (debug_i.cmd == DBG_STEP || debug_i.cmd == DBG_CONTINUE);
  assign stop_pc_inc = q.stop_pc_inc | dbg_insert;

  always_comb begin
    d = q;
    d.debug_o.ack = 1'b0;
    next_state = q.state;

    // 1. BREAK instruction executed / BREAK command while running
    if (!q.old_debug && debug && (q.state == DS_RUN || q.state == DS_AWAIT_BREAK)) begin
      next_state    = DS_AWAIT_IF;
      d.enter_debug = '0;
    end else if (q.state == DS_RUN && debug_i.en && debug_i.cmd == DBG_BREAK) begin
      d.enter_debug[3] = 1'b1;
      next_state       = DS_AWAIT_BREAK;
    end
    d.old_debug = debug;

    // 2. commands in READY
    if (cmd_ready) begin
      unique case (debug_i.cmd)
        DBG_BREAK: d.debug_o.ack = 1'b1;
        DBG_INSERT: begin
          d.stop_pc_inc = 1'b1;
          d.ovr2        = '{en: debug_i.d_en, d: debug_i.d};
          next_state    = DS_AWAIT_IF;
        end
        DBG_STEP: begin
          d.enter_debug[3] = 1'b1;
          next_state       = DS_AWAIT_BREAK;
        end
        default: begin  // DBG_CONTINUE
          d.enter_debug[3] = 1'b0;
          next_state       = DS_RUN;
        end
      endcase
    end

    // 3. shift the enter_debug pipeline (left-most bit is duplicated)
    if (q.slot) d.enter_debug = {d.enter_debug[3], d.enter_debug[3:1]};

    d.slot = slot;

    // 4. pause at the next instruction fetch issue
    if (slot && instr_issue && !fetch_allowed &&
        (q.state == DS_AWAIT_IF || next_state == DS_AWAIT_IF)) begin
      next_state = DS_READY;
      d.ovr0 = d.ovr1;
      d.ovr1 = d.ovr2;
      d.ovr2 = '0;
    end

    // 5. acknowledge commands when RUN or READY is reached
    if (next_state == DS_RUN || next_state == DS_READY) begin
      if (!d.debug_o.ack && debug_i.en)
        d.debug_o.d = (debug_i.cmd == DBG_INSERT) ? reg_wr_data : pc_next;
      d.debug_o.ack = debug_i.en;
      d.stop_pc_inc = 1'b0;
    end
    d.state       = next_state;
    d.debug_o.rdy = (next_state == DS_READY);
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) q <= '{state: DS_RUN, slot: 1'b1, default: '0};
    else     q <= d;
  end

  assign debug_o          = d.debug_o;      // combinational, as the original
  assign enter_debug      = q.enter_debug[0];
  assign mask_int         = !(q.state == DS_RUN && q.enter_debug == 4'b0000);
  assign ybus_override_en = q.ovr0.en;
  assign ybus_override_d  = q.ovr0.d;

endmodule
