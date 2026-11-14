// Xilinx-uartlite compatible UART, Wishbone B4 pipelined slave.
//
// Ported from reference/soc_top/components/uartlite/{uart.vhm,uartlitedb.vhd}.
// The engine is a statement-by-statement translation of the original
// process; only the bus side changed (one Wishbone request instead of the
// rising edge of the native 'en'; the ack is registered as before).
//
// Registers (only adr[3] is decoded, like the original):
//   0x0/0x4  R: RX FIFO (pop)        W: TX FIFO (push; dropped when full)
//   0x8/0xC  R: STATUS               W: CTRL
//   STATUS: [0] RX valid [1] RX full [2] TX empty [3] TX full [4] IE
//           [5] RX overrun [6] frame error (5, 6 clear on read)
//   CTRL:   [0] reset TX FIFO [1] reset RX FIFO [4] IE
// FIFOs: RX 32, TX 16 deep. 8N1. Baud: 13-bit DDS, 16x oversampling.
// irq (one-cycle pulse, if IE):
//   INTCFG 1: byte received into an empty RX FIFO, or TX FIFO drained
//   INTCFG 0: RX FIFO half full, or RX idle timeout (128 bit-sixteenths)
module j2_uartlite
  import j2_wb_pkg::*;
#(
  parameter longint CLK_HZ = 50_000_000,
  parameter longint BAUD   = 19_200,
  parameter int     INTCFG = 1,
  // DDS increment per clock; default as the original: round(4096*16*bps/fclk)
  parameter int     DDS_INC = int'((4096 * 16 * BAUD + CLK_HZ / 2) / CLK_HZ)
) (
  input  logic    clk,
  input  logic    rst,
  /* verilator lint_off UNUSEDSIGNAL */  // only adr[3], dat[7:0] are used
  input  wb_m2s_t wb_i,
  /* verilator lint_on UNUSEDSIGNAL */
  output wb_s2m_t wb_o,
  output logic    irq,
  input  logic    rx,
  output logic    tx
);
  localparam int RX_LEN  = 32;
  localparam int TX_LEN  = 16;
  localparam int TIMEOUT = 128;

  typedef enum logic [1:0] {S_IDLE, S_START, S_DATA, S_STOP} ustate_t;

  typedef struct packed {
    ustate_t    s;
    logic [7:0] sr;
    logic [2:0] b;
    logic [3:0] phs;
    logic       full;
    logic       ovr;
    logic       ferr;
    logic [1:0] a;     // input synchroniser
    logic [1:0] m;     // majority vote count
  } engine_t;

  typedef struct packed {
    engine_t     rx;
    logic [4:0]  rx_wa, rx_ra;
    engine_t     tx;
    logic [3:0]  tx_wa, tx_ra;
    logic [12:0] dds;
    logic [6:0]  itimeout;
    logic        rxint;
    logic        ien;
    logic        txo;
    logic [7:0]  yd;
    logic        yack;
    logic        yint;
  } uart_reg_t;

  localparam engine_t ENGINE_RESET = '{s: S_IDLE, phs: 4'd15, default: '0};
  localparam uart_reg_t UART_RESET = '{rx: ENGINE_RESET, tx: ENGINE_RESET, rxint: 1'b1,
                                       txo: 1'b1, default: '0};

  uart_reg_t q, d;
  logic [7:0] rxf [RX_LEN];
  logic [7:0] txf [TX_LEN];
  logic       rxf_we, txf_we;
  logic [4:0] rxf_a;
  logic [3:0] txf_a;
  logic [7:0] rxf_d, txf_d;

  logic req, req_we, req_ctrl;
  assign req      = wb_i.cyc && wb_i.stb;
  assign req_we   = wb_i.we;
  assign req_ctrl = wb_i.adr[3];

  always_comb begin
    logic rxe, txe;
    d = q;
    rxf_we = 1'b0; rxf_a = '0; rxf_d = '0;
    txf_we = 1'b0; txf_a = '0; txf_d = '0;

    rxe = (q.rx_wa == q.rx_ra) && !q.rx.full;
    txe = (q.tx_wa == q.tx_ra) && !q.tx.full;

    d.yint = 1'b0;   // interrupt pulse
    d.yack = 1'b0;

    if (d.dds[12]) begin  // 16x baud tick
      // ---------------------------------------------------- transmitter
      if (d.tx.phs == 4'd15) begin
        unique case (d.tx.s)
          S_IDLE : d.txo = 1'b1;
          S_START: begin
            d.txo   = 1'b0;
            d.tx.sr = txf[d.tx_ra];
            d.tx_ra = d.tx_ra + 4'd1;      // pop (wraps at 16)
            d.tx.full = 1'b0;
            if (d.tx_wa == d.tx_ra && d.ien) d.yint = 1'b1;
          end
          S_DATA: begin
            d.txo   = d.tx.sr[0];
            d.tx.sr = {1'b0, d.tx.sr[7:1]};
          end
          default: d.txo = 1'b1;           // S_STOP
        endcase
        unique case (d.tx.s)
          S_IDLE: if (d.tx_wa != d.tx_ra || d.tx.full) begin
            d.tx.s = S_START; d.tx.phs = 4'd0;
          end
          S_START: begin
            d.tx.s = S_DATA; d.tx.phs = 4'd0; d.tx.b = 3'd0;
          end
          S_DATA: begin
            if (d.tx.b == 3'd7) d.tx.s = S_STOP;
            else                d.tx.b = d.tx.b + 3'd1;
            d.tx.phs = 4'd0;
          end
          default: begin  // S_STOP
            if (d.tx_wa != d.tx_ra || d.tx.full) begin
              d.tx.s = S_START; d.tx.phs = 4'd0;
            end else d.tx.s = S_IDLE;
          end
        endcase
      end else begin
        d.tx.phs = d.tx.phs + 4'd1;
      end

      // ------------------------------------------------------- receiver
      if (d.rx.phs == 4'd7 || d.rx.phs == 4'd8 || d.rx.phs == 4'd9) begin
        if (d.rx.a[1]) d.rx.m = d.rx.m + 2'd1;   // majority vote
        d.rx.phs = d.rx.phs + 4'd1;
      end else if (d.rx.phs == 4'd10 && d.rx.s == S_STOP) begin
        d.rx.s   = S_IDLE;                        // end of frame
        d.rx.phs = 4'd15;
        if (d.rx.m > 2'd1) begin
          if (d.rx.full) d.rx.ovr = 1'b1;
          else begin
            if (INTCFG == 1) begin
              if (d.rx_wa == d.rx_ra && d.ien) d.yint = 1'b1;
            end else if (d.rx_wa[3:0] == d.rx_ra[3:0] && (d.rx_wa[4] ^ d.rx_ra[4]) && d.ien) begin
              d.yint  = d.rxint;
              d.rxint = 1'b0;
            end
            rxf_d  = d.rx.sr;
            rxf_a  = d.rx_wa;
            rxf_we = 1'b1;
            d.rx_wa = d.rx_wa + 5'd1;                // wraps at 32
            if (d.rx_wa == d.rx_ra) d.rx.full = 1'b1;
          end
        end else begin
          d.rx.ferr = 1'b1;
        end
      end else if (d.rx.phs == 4'd15) begin
        if (d.rx.s == S_DATA)
          d.rx.sr = {d.rx.m > 2'd1, d.rx.sr[7:1]};
        unique case (d.rx.s)
          S_IDLE: if (!d.rx.a[1]) begin
            d.rx.phs = 4'd0; d.rx.s = S_START;
          end
          S_START: begin
            if (d.rx.m > 2'd1) d.rx.s = S_IDLE;   // false start
            else begin
              d.rx.phs = 4'd0; d.rx.b = 3'd0; d.rx.s = S_DATA;
            end
          end
          S_DATA: begin
            d.rx.phs = 4'd0;
            if (d.rx.b == 3'd7) d.rx.s = S_STOP;
            else                d.rx.b = d.rx.b + 3'd1;
          end
          default: ;
        endcase
        d.rx.m = 2'd0;
      end else begin
        d.rx.phs = d.rx.phs + 4'd1;
      end

      // RX timeout interrupt (INTCFG 0)
      if (INTCFG == 0 && d.ien && !rxe) begin
        if (d.rx.s == S_IDLE) begin
          if (d.itimeout == 7'(TIMEOUT - 1)) begin
            d.yint     = d.rxint;
            d.rxint    = 1'b0;
            d.itimeout = 7'd0;
          end else d.itimeout = d.itimeout + 7'd1;
        end else d.itimeout = 7'd0;
      end else begin
        d.itimeout = 7'd0;
        d.rxint    = 1'b1;
      end
    end

    // 16x baud clock DDS
    d.dds = {1'b0, d.dds[11:0]} + 13'(DDS_INC);

    // bus: read
    if (req && !req_we) begin
      if (!req_ctrl) begin
        if (d.rx_wa != d.rx_ra || d.rx.full) begin
          d.yd = rxf[d.rx_ra];
          d.rx_ra = d.rx_ra + 5'd1;
          d.rx.full = 1'b0;
        end
      end else begin
        d.yd = {1'b0, d.rx.ferr, d.rx.ovr, d.ien, d.tx.full, txe, d.rx.full, !rxe};
        d.rx.ferr = 1'b0;
        d.rx.ovr  = 1'b0;
      end
      d.yack = 1'b1;
    end
    // bus: write
    if (req && req_we) begin
      if (!req_ctrl) begin
        if (d.tx.full) d.tx.ovr = 1'b1;
        else begin
          txf_d  = wb_i.dat[7:0];
          txf_a  = d.tx_wa;
          txf_we = 1'b1;
          d.tx_wa = d.tx_wa + 4'd1;
          if (d.tx_wa == d.tx_ra) d.tx.full = 1'b1;
        end
      end else begin
        if (wb_i.dat[0]) begin d.tx_wa = '0; d.tx_ra = '0; d.tx.full = 1'b0; end
        if (wb_i.dat[1]) begin d.rx_wa = '0; d.rx_ra = '0; d.rx.full = 1'b0; end
        d.ien = wb_i.dat[4];
      end
      d.yack = 1'b1;
    end

    d.rx.a = {d.rx.a[0], rx};   // input synchroniser
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) q <= UART_RESET;
    else     q <= d;
  end

  always_ff @(posedge clk) begin
    if (txf_we) txf[txf_a] <= txf_d;
    if (rxf_we) rxf[rxf_a] <= rxf_d;
  end

  assign wb_o = '{ack: q.yack, err: 1'b0, stall: 1'b0, dat: {24'h0, q.yd}};
  assign irq  = q.yint;
  assign tx   = q.txo;
endmodule
