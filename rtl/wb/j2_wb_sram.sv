// On-chip RAM with two Wishbone B4 pipelined slave ports (instruction and
// data), inferred as true dual-port block RAM with byte enables.
// Each port accepts every cycle (no stall) and acks one cycle later with the
// registered read data.
//
// Contents: INIT_FILE ($readmemh, one 32-bit word per line). In simulation
// the plusarg +sram=<file> overrides it.
module j2_wb_sram
  import j2_wb_pkg::*;
#(
  parameter int    WORDS     = 8192,          // 32 KB
  parameter string INIT_FILE = ""
) (
  input  logic    clk,
  input  logic    rst,
  /* verilator lint_off UNUSEDSIGNAL */  // adr[1:0], lock, tgc; port B is read-only
  input  wb_m2s_t a_i,   // data port (read / write)
  input  wb_m2s_t b_i,   // instruction port (read only)
  /* verilator lint_on UNUSEDSIGNAL */
  output wb_s2m_t a_o,
  output wb_s2m_t b_o
);
  localparam int AW = $clog2(WORDS);

  logic [31:0] mem [WORDS];

  initial begin
`ifndef SYNTHESIS
    string f;
    if ($value$plusargs("sram=%s", f)) $readmemh(f, mem);
    else
`endif
    if (INIT_FILE != "") $readmemh(INIT_FILE, mem);
  end

  logic [AW-1:0] a_addr, b_addr;
  assign a_addr = a_i.adr[AW+1:2];
  assign b_addr = b_i.adr[AW+1:2];

  logic [31:0] a_dat, b_dat;
  logic        a_ack, b_ack;

  // port A
  always_ff @(posedge clk) begin
    if (a_i.cyc && a_i.stb) begin
      if (a_i.we)
        for (int i = 0; i < 4; i++)
          if (a_i.sel[i]) mem[a_addr][8*i +: 8] <= a_i.dat[8*i +: 8];
      a_dat <= mem[a_addr];
    end
  end
  // port B
  always_ff @(posedge clk) begin
    if (b_i.cyc && b_i.stb) b_dat <= mem[b_addr];
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      a_ack <= 1'b0;
      b_ack <= 1'b0;
    end else begin
      a_ack <= a_i.cyc && a_i.stb;
      b_ack <= b_i.cyc && b_i.stb;
    end
  end
  assign a_o = '{ack: a_ack, err: 1'b0, stall: 1'b0, dat: a_dat};
  assign b_o = '{ack: b_ack, err: 1'b0, stall: 1'b0, dat: b_dat};
endmodule
