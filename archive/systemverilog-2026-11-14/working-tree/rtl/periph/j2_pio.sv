// J-Core PIO, ported from reference/soc_top/components/misc/pio.vhd.
//
// Register map (adr[5:2], only the low 64 bytes are decoded by the SoC):
//   0: output pins
//   1: input interrupt mask
//   2: input edge-select mask (0 = rising, 1 = both edges)
//   3: latched input changes; reading clears it
//
// The native bus write is converted to one Wishbone request.  As in the
// original, all four byte lanes are honored for the output register.
module j2_pio
  import j2_wb_pkg::*;
#(
  parameter logic [31:0] DEFAULT_OUT = 32'h8000_0000
) (
  input  logic        clk,
  input  logic        rst,
  /* verilator lint_off UNUSEDSIGNAL */  // lock, tgc
  input  wb_m2s_t     wb_i,
  /* verilator lint_on UNUSEDSIGNAL */
  output wb_s2m_t     wb_o,
  output logic        irq,
  input  logic [31:0] pi,
  output logic [31:0] po
);
  logic [31:0] out_q;
  logic [31:0] pin_q, pin_prev_q;
  logic [31:0] edge_q, changes_q, mask_q;
  logic        changed_read_q;
  logic        irq_prev_q, irq_q;
  logic        ack_q;
  logic [31:0] rdata_q;
  logic [31:0] next_changes;

  logic req;
  logic [3:0] regsel;
  assign req    = wb_i.cyc && wb_i.stb;
  assign regsel = wb_i.adr[5:2];
  assign po     = out_q;
  assign irq    = irq_q & ~irq_prev_q;

  always_comb begin
    rdata_q = pin_q;
    unique case (regsel)
      4'd1: rdata_q = mask_q;
      4'd2: rdata_q = edge_q;
      4'd3: rdata_q = changes_q;
      default: ;
    endcase
  end

  always_comb begin
    next_changes = changes_q;
    for (int i = 0; i < 32; i++) begin
      if (changed_read_q)
        next_changes[i] = 1'b0;
      else if (pin_prev_q[i] && !pin_q[i])
        next_changes[i] = 1'b1;
      else if (!pin_prev_q[i] && pin_q[i] && edge_q[i])
        next_changes[i] = 1'b1;
    end
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      out_q         <= DEFAULT_OUT;
      pin_q         <= '0;
      pin_prev_q    <= '0;
      edge_q        <= '0;
      changes_q     <= '0;
      mask_q        <= '0;
      changed_read_q <= 1'b0;
      irq_prev_q    <= 1'b0;
      irq_q         <= 1'b0;
      ack_q         <= 1'b0;
    end else begin
      pin_q      <= pi;
      pin_prev_q <= pin_q;
      ack_q      <= req;
      changed_read_q <= 1'b0;

      changes_q <= next_changes;

      if (req && wb_i.we) begin
        unique case (regsel)
          4'd0: begin
            if (wb_i.sel[3]) out_q[31:24] <= wb_i.dat[31:24];
            if (wb_i.sel[2]) out_q[23:16] <= wb_i.dat[23:16];
            if (wb_i.sel[1]) out_q[15:8]  <= wb_i.dat[15:8];
            if (wb_i.sel[0]) out_q[7:0]   <= wb_i.dat[7:0];
          end
          4'd1: mask_q <= wb_i.dat;
          4'd2: edge_q <= wb_i.dat;
          default: ;
        endcase
      end else if (req && !wb_i.we && regsel == 4'd3) begin
        changed_read_q <= 1'b1;
      end

      irq_q      <= |(mask_q & next_changes);
      irq_prev_q <= irq_q;
    end
  end

  assign wb_o = '{ack: ack_q, err: 1'b0, stall: 1'b0, dat: rdata_q};
endmodule
