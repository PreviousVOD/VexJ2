// Wishbone B4 pipelined slave -> native J-Core bus master bridge.
//
// Lets original J-Core peripherals (native bus: en, a, rd, wr, we, d / d,
// ack) sit behind the Wishbone fabric.
//   - A request is accepted when idle (stall = 0); en/a/rd/wr/we/d are then
//     registered and held until the native slave acks (combinational or
//     after wait states). Reads drive we = 0000, as the original CPU did.
//   - The Wishbone ack (with read data) is given in the cycle after the
//     native ack, while 'en' is low; 'en' is thus low for at least one cycle
//     between accesses, as some original peripherals (uartlite, spi2) act on
//     the rising edge of 'en'. A zero-wait native slave costs 3 cycles.
//   - lock is passed through.
module j2_wb2native
  import j2_wb_pkg::*;
(
  input  logic        clk,
  input  logic        rst,
  /* verilator lint_off UNUSEDSIGNAL */  // tgc
  input  wb_m2s_t     wb_i,
  /* verilator lint_on UNUSEDSIGNAL */
  output wb_s2m_t     wb_o,
  output cpu_data_o_t nat_o,
  output logic        nat_lock,
  input  cpu_data_i_t nat_i
);
  typedef enum logic [1:0] {IDLE, BUSY, DONE} state_t;
  state_t      state;
  logic [31:0] rdata;

  assign wb_o = '{ack: state == DONE, err: 1'b0, stall: state != IDLE, dat: rdata};

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      state <= IDLE;
      nat_o <= NULL_DATA_O;
      rdata <= '0;
    end else begin
      unique case (state)
        IDLE: if (wb_i.cyc && wb_i.stb) begin
          nat_o.en <= 1'b1;
          nat_o.a  <= wb_i.adr;
          nat_o.rd <= !wb_i.we;
          nat_o.wr <= wb_i.we;
          nat_o.we <= wb_i.we ? wb_i.sel : 4'b0000;
          nat_o.d  <= wb_i.dat;
          state    <= BUSY;
        end
        BUSY: if (nat_i.ack) begin
          nat_o    <= NULL_DATA_O;
          rdata    <= nat_i.d;
          state    <= DONE;
        end
        default: state <= IDLE;  // DONE: Wishbone ack, 'en' low
      endcase
    end
  end

  assign nat_lock = wb_i.cyc & wb_i.lock;
endmodule
