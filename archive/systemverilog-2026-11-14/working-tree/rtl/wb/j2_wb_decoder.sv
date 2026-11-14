// Wishbone B4 pipelined address decoder: one master, N slaves.
//
// Slave i is selected when (adr & MASK[i]) == BASE[i]; the first match wins.
// Unmatched addresses go to a built-in loopback slave that acks one cycle
// after accept with data 0 (as the original J-Core SoC did for unmapped
// addresses). Designed for masters with one outstanding access (the J2 bus
// units): the slave that accepted a request answers it, and cyc stays with
// that slave while the master holds cyc (lock).
module j2_wb_decoder
  import j2_wb_pkg::*;
#(
  parameter int                 N    = 2,
  parameter logic [N-1:0][31:0] BASE = '0,
  parameter logic [N-1:0][31:0] MASK = '0
) (
  input  logic             clk,
  input  logic             rst,
  input  wb_m2s_t          m_i,
  output wb_s2m_t          m_o,
  output wb_m2s_t [N-1:0]  s_o,
  input  wb_s2m_t [N-1:0]  s_i
);
  localparam int SW = $clog2(N + 1);
  localparam logic [SW-1:0] NONE = SW'(N);

  logic [SW-1:0] sel_now, sel_q, sel_cur;
  logic          lb_ack;

  always_comb begin
    sel_now = NONE;
    for (int i = N - 1; i >= 0; i--)
      if ((m_i.adr & MASK[i]) == BASE[i]) sel_now = SW'(i);
  end
  // a new request is routed by its address; otherwise keep the slave that
  // accepted the last one (answers, locked sequences)
  assign sel_cur = m_i.stb ? sel_now : sel_q;

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      sel_q  <= NONE;
      lb_ack <= 1'b0;
    end else begin
      if (m_i.cyc && m_i.stb && !m_o.stall) sel_q <= sel_now;
      lb_ack <= m_i.cyc && m_i.stb && sel_now == NONE;
    end
  end

  always_comb begin
    for (int i = 0; i < N; i++) begin
      s_o[i]     = m_i;
      s_o[i].cyc = m_i.cyc && sel_cur == SW'(i);
      s_o[i].stb = m_i.stb && sel_cur == SW'(i);
    end
    if (sel_cur == NONE) m_o = '{ack: lb_ack, err: 1'b0, stall: 1'b0, dat: 32'h0};
    else                 m_o = s_i[sel_cur];
  end
endmodule
