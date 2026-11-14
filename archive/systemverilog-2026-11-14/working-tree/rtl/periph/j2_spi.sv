// J-Core spi2 controller, ported from
// reference/soc_top/components/misc/spi2.vhm.
//
// The controller transfers one byte per transaction.  A write to adr[2]=0
// configures chip selects, loopback, start and clock speed; a write to
// adr[2]=1 supplies TX data.  Reads return status or received data.
module j2_spi
  import j2_wb_pkg::*;
#(
  parameter int CLK_HZ           = 50_000_000,
  parameter int NUM_CS           = 2,
  parameter bit CPOL             = 1'b0,
  parameter bit CPHA             = 1'b0,
  parameter int LOW_SPEED_FREQ   = 400_000,
  parameter int HIGH_SPEED_FREQ  = 12_500_000
) (
  input  logic        clk,
  input  logic        rst,
  /* verilator lint_off UNUSEDSIGNAL */  // lock, tgc
  input  wb_m2s_t     wb_i,
  /* verilator lint_on UNUSEDSIGNAL */
  output wb_s2m_t     wb_o,
  output logic        spi_clk,
  output logic [NUM_CS-1:0] cs,
  input  logic        miso,
  output logic        mosi
);
  localparam int MAX_HALF_PERIOD =
    (CLK_HZ + 2 * LOW_SPEED_FREQ - 1) / (2 * LOW_SPEED_FREQ) - 1;
  localparam int MIN_HALF_PERIOD =
    (CLK_HZ + 2 * HIGH_SPEED_FREQ - 1) / (2 * HIGH_SPEED_FREQ) - 1;
  localparam int CW = $clog2(MAX_HALF_PERIOD + 1);

  typedef enum logic [1:0] {S_IDLE, S_LEAD, S_TRAIL, S_WAIT} state_t;
  typedef struct packed {
    state_t       state;
    logic         sclk;
    logic         ack;
    logic [31:0]  rdata;
    logic [2:0]   edge_pair;
    logic [CW-1:0] cyc_count;
    logic [4:0]   speed;
    logic [NUM_CS-1:0] cs;
    logic         loopback;
    logic [7:0]   rx;
    logic [7:0]   tx;
    logic [8:0]   tx_shift;
    logic [7:0]   rx_shift;
  } spi_reg_t;

  localparam spi_reg_t SPI_RESET = '{
    state: S_IDLE,
    sclk: CPOL,
    ack: 1'b0,
    rdata: '0,
    edge_pair: '0,
    cyc_count: '0,
    speed: 5'h1f,
    cs: {{(NUM_CS-1){1'b0}}, 1'b1},
    loopback: 1'b0,
    rx: '0,
    tx: '0,
    tx_shift: '1,
    rx_shift: '0
  };

  spi_reg_t q, d;
  logic req;
  assign req = wb_i.cyc && wb_i.stb;

  always_comb begin
    logic [CW:0] count_next;
    logic        count_edge;
    logic        start_txn;
    logic        shift;
    logic        sample;
    logic        miso_sample;

    d         = q;
    start_txn = 1'b0;
    shift     = 1'b0;
    sample    = 1'b0;

    // Bus side.  A request is accepted without stalling and acknowledged
    // one cycle after its request edge.
    d.ack   = 1'b0;
    d.rdata = '0;
    if (req && !q.ack) begin
      if (wb_i.we) begin
        if (!wb_i.adr[2]) begin
          d.cs[0]     = wb_i.dat[0];
          start_txn   = wb_i.dat[1];
          d.cs[1]     = wb_i.dat[2];
          d.loopback  = wb_i.dat[3];
          for (int i = 2; i < NUM_CS; i++)
            d.cs[i] = wb_i.dat[2+i];
          d.speed = wb_i.dat[31:27];
        end else begin
          d.tx = wb_i.dat[7:0];
        end
      end else if (!wb_i.adr[2]) begin
        d.rdata[0]   = q.cs[0];
        d.rdata[1]   = q.state != S_IDLE;
        d.rdata[2]   = q.cs[1];
        d.rdata[3]   = q.loopback;
        for (int i = 2; i < NUM_CS; i++)
          d.rdata[2+i] = q.cs[i];
      end else begin
        d.rdata[7:0] = q.rx;
      end
      d.ack = 1'b1;
    end

    // Clock divider.  Zero means this cycle is a clock edge.
    count_next = {1'b1, q.cyc_count} - 1'b1;
    count_edge = !count_next[CW];
    if (q.state == S_IDLE || count_edge) begin
      if (q.speed == 5'd31 || q.speed == 5'd30)
        d.cyc_count = CW'(MAX_HALF_PERIOD);
      else
        d.cyc_count = CW'(q.speed + MIN_HALF_PERIOD);
    end else begin
      d.cyc_count = count_next[CW-1:0];
    end
    if (q.state == S_IDLE) count_edge = 1'b0;

    // Serial state machine.
    unique case (q.state)
      S_IDLE: begin
        d.sclk = CPOL;
        if (start_txn) begin
          d.state    = S_LEAD;
          d.tx_shift = {1'b1, q.tx};
          shift      = !CPHA;
        end
      end
      S_LEAD: if (count_edge) begin
        d.sclk  = !CPOL;
        d.state = S_TRAIL;
        shift   = CPHA;
        sample  = !CPHA;
      end
      S_TRAIL: if (count_edge) begin
        d.sclk = CPOL;
        if (q.edge_pair == 3'd7) d.state = S_WAIT;
        else                     d.state = S_LEAD;
        shift         = !CPHA;
        sample        = CPHA;
        d.edge_pair   = q.edge_pair + 1'b1;
      end
      default: if (count_edge) begin
        d.state = S_IDLE;
        shift   = 1'b1;
        d.rx    = q.rx_shift;
      end
    endcase

    // Use the updated datapath value: starting a transaction loads the TX
    // shift register in the IDLE state above and shifts it in this cycle.
    miso_sample = d.loopback ? d.tx_shift[8] : miso;
    if (sample) d.rx_shift = {d.rx_shift[6:0], miso_sample};
    if (shift)  d.tx_shift = {d.tx_shift[7:0], 1'b1};
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) q <= SPI_RESET;
    else     q <= d;
  end

  assign wb_o     = '{ack: q.ack, err: 1'b0, stall: 1'b0, dat: q.rdata};
  assign spi_clk  = q.sclk;
  assign mosi     = q.tx_shift[8];
  assign cs[0]    = q.cs[0];
  assign cs[NUM_CS-1:1] = ~q.cs[NUM_CS-1:1];
endmodule
