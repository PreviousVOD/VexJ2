// J-Core cache-mode register, ported from
// reference/soc_top/components/icache/icache_modereg.vhm.
//
// The J2 rewrite does not yet include cache arrays, but software and the
// original SoC still use this register block to enable/invalidate caches and
// to request the cache interrupt.
//
// adr[5:2]:
//   0: cpu0 icache enable [0], dcache enable [1], invalidate [9:8]
//   1: cpu1, same layout
//   c: cpu0 instruction fetch address (address << 1 in the original bus)
//   d: cpu1 instruction fetch address
//   f: temporary cache0/1 select bit
module j2_cache_ctrl
  import j2_wb_pkg::*;
(
  input  logic        clk,
  input  logic        rst,
  /* verilator lint_off UNUSEDSIGNAL */  // lock, tgc
  input  wb_m2s_t     wb_i,
  /* verilator lint_on UNUSEDSIGNAL */
  output wb_s2m_t     wb_o,
  input  logic [31:1] ic0_addr,
  input  logic [31:1] ic1_addr,
  output logic        ic0_en,
  output logic        ic0_inv,
  output logic        dc0_en,
  output logic        dc0_inv,
  output logic        ic1_en,
  output logic        ic1_inv,
  output logic        dc1_en,
  output logic        dc1_inv,
  output logic        irq0,
  output logic        irq1,
  output logic        cache01sel
);
  logic        ic0_en_q, dc0_en_q, ic1_en_q, dc1_en_q;
  logic        ic0_int_q, ic1_int_q;
  logic        cache01sel_q;
  logic        ack_q;
  logic [31:0] rdata_q;
  logic        req;
  logic [3:0]  regsel;

  assign req    = wb_i.cyc && wb_i.stb;
  assign regsel = wb_i.adr[5:2];

  assign ic0_en  = ic0_en_q;
  assign dc0_en  = dc0_en_q;
  assign ic1_en  = ic1_en_q;
  assign dc1_en  = dc1_en_q;
  assign irq0    = ic0_int_q;
  assign irq1    = ic1_int_q;
  assign cache01sel = cache01sel_q;

  // Invalidate outputs are one-cycle pulses after a control-register write,
  // matching the original register block.
  assign ic0_inv = req && wb_i.we && regsel == 4'd0 && wb_i.dat[8];
  assign dc0_inv = req && wb_i.we && regsel == 4'd0 && wb_i.dat[9];
  assign ic1_inv = req && wb_i.we && regsel == 4'd1 && wb_i.dat[8];
  assign dc1_inv = req && wb_i.we && regsel == 4'd1 && wb_i.dat[9];

  always_comb begin
    rdata_q = '0;
    unique case (regsel)
      4'd0: rdata_q = 32'h2000_0000 | {30'b0, dc0_en_q, ic0_en_q};
      4'd1: rdata_q = 32'h2000_0000 | {30'b0, dc1_en_q, ic1_en_q};
      4'd12: rdata_q = {ic0_addr, 1'b0};
      4'd13: rdata_q = {ic1_addr, 1'b0};
      4'd15: rdata_q = {31'b0, cache01sel_q};
      default: rdata_q = '0;
    endcase
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      ic0_en_q   <= 1'b0;
      dc0_en_q   <= 1'b0;
      ic1_en_q   <= 1'b0;
      dc1_en_q   <= 1'b0;
      ic0_int_q  <= 1'b0;
      ic1_int_q  <= 1'b0;
      cache01sel_q <= 1'b0;
      ack_q      <= 1'b0;
    end else begin
      ic0_int_q <= 1'b0;
      ic1_int_q <= 1'b0;
      ack_q     <= req;
      if (req && wb_i.we) begin
        unique case (regsel)
          4'd0: begin
            ic0_en_q  <= wb_i.dat[0];
            dc0_en_q  <= wb_i.dat[1];
            ic0_int_q <= wb_i.dat[28];
          end
          4'd1: begin
            ic1_en_q  <= wb_i.dat[0];
            dc1_en_q  <= wb_i.dat[1];
            ic1_int_q <= wb_i.dat[28];
          end
          4'd15: cache01sel_q <= wb_i.dat[0];
          default: ;
        endcase
      end
    end
  end

  assign wb_o = '{ack: ack_q, err: 1'b0, stall: 1'b0, dat: rdata_q};
endmodule
