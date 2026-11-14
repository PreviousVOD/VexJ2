// Mimas v2 peripheral subsystem in the original address layout.
//
//   0xABCD0000  PIO
//   0xABCD0040  SPI
//   0xABCD00C0  cache control
//   0xABCD0100  uartlite
//   0xABCD0200  AIC
//
// Unmapped addresses use the decoder's one-cycle zero loopback response.
module j2_periph
  import j2_cpu_pkg::*;
  import j2_wb_pkg::*;
#(
  parameter int CLK_HZ = 50_000_000,
  parameter int BUS_PERIOD_NS = 20,
  parameter logic [7:0] VECTOR_NUMBERS [8] = '{
    8'h00, 8'h12, 8'h00, 8'h14, 8'h15, 8'h00, 8'h00, 8'h00
  }
) (
  input  logic        clk,
  input  logic        rst,
  /* verilator lint_off UNUSEDSIGNAL */  // lock, tgc
  input  wb_m2s_t     wb_i,
  /* verilator lint_on UNUSEDSIGNAL */
  output wb_s2m_t     wb_o,
  input  logic [31:1] ic_fetch_addr,
  input  cpu_event_o_t cpu_event_i,
  output cpu_event_i_t cpu_event_o,
  output logic [63:0] rtc_sec,
  output logic [31:0] rtc_nsec,
  input  logic        uart_rx,
  output logic        uart_tx,
  output logic        spi_clk,
  output logic [1:0]  spi_cs,
  output logic        spi_mosi,
  input  logic        spi_miso,
  input  logic [31:0] pi,
  output logic [31:0] po
);
  localparam logic [31:0] PIO_BASE   = 32'habcd_0000;
  localparam logic [31:0] SPI_BASE   = 32'habcd_0040;
  localparam logic [31:0] CACHE_BASE = 32'habcd_00c0;
  localparam logic [31:0] UART_BASE  = 32'habcd_0100;
  localparam logic [31:0] AIC_BASE   = 32'habcd_0200;

  wb_m2s_t [4:0] s_o;
  wb_s2m_t [4:0] s_i;
  logic [7:0] irqs;
  /* verilator lint_off UNUSEDSIGNAL */  // no cache arrays yet
  logic pio_irq, uart_irq, cache_irq0, cache_irq1;
  logic ic0_en, ic0_inv, dc0_en, dc0_inv;
  logic ic1_en, ic1_inv, dc1_en, dc1_inv;
  logic cache01sel;
  /* verilator lint_on UNUSEDSIGNAL */
  logic periph_req;

  assign periph_req = wb_i.cyc && wb_i.stb;

  j2_wb_decoder #(
    .N(5),
    // Packed-array concatenation is little-endian here: the rightmost
    // element is BASE[0], which drives s_o[0] (PIO).
    .BASE({AIC_BASE, UART_BASE, CACHE_BASE, SPI_BASE, PIO_BASE}),
    .MASK({
      32'hffff_ffc0, 32'hffff_fff0, 32'hffff_ffc0,
      32'hffff_fff8, 32'hffff_fff0
    })
  ) u_decode (
    .clk, .rst, .m_i(wb_i), .m_o(wb_o), .s_o(s_o), .s_i(s_i));

  j2_pio u_pio (
    .clk, .rst, .wb_i(s_o[0]), .wb_o(s_i[0]),
    .irq(pio_irq), .pi, .po);

  j2_spi #(.CLK_HZ(CLK_HZ), .NUM_CS(2)) u_spi (
    .clk, .rst, .wb_i(s_o[1]), .wb_o(s_i[1]),
    .spi_clk, .cs(spi_cs), .miso(spi_miso), .mosi(spi_mosi));

  j2_cache_ctrl u_cache (
    .clk, .rst, .wb_i(s_o[2]), .wb_o(s_i[2]),
    .ic0_addr(ic_fetch_addr), .ic1_addr(31'b0),
    .ic0_en, .ic0_inv, .dc0_en, .dc0_inv,
    .ic1_en, .ic1_inv, .dc1_en, .dc1_inv,
    .irq0(cache_irq0), .irq1(cache_irq1), .cache01sel);

  j2_uartlite #(.CLK_HZ(CLK_HZ), .BAUD(19_200), .INTCFG(1)) u_uart (
    .clk, .rst, .wb_i(s_o[3]), .wb_o(s_i[3]),
    .irq(uart_irq), .rx(uart_rx), .tx(uart_tx));

  // The original AIC uses a whole-peripheral-bus strobe/ack for breakpoint
  // and CPU-error detection.  Wishbone accepts the request in this cycle.
  j2_aic #(.BUS_PERIOD_NS(BUS_PERIOD_NS), .VECTOR_NUMBERS(VECTOR_NUMBERS)) u_aic (
    .clk, .rst, .wb_i(s_o[4]), .wb_o(s_i[4]),
    .bus_stb(periph_req), .bus_ack(periph_req),
    .rtc_sec, .rtc_nsec, .irq_i(irqs), .enmi_i(1'b1),
    .event_i(cpu_event_i), .event_o(cpu_event_o));

  always_comb begin
    irqs    = '0;
    irqs[1] = uart_irq;
    irqs[3] = cache_irq0;
    irqs[4] = pio_irq;
  end
endmodule
