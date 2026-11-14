// Flat testbench around j2_periph for bus-level peripheral tests.
module tb_periph
  import j2_cpu_pkg::*;
  import j2_wb_pkg::*;
(
  input  logic        clk,
  input  logic        rst,
  input  logic        cyc,
  input  logic        stb,
  input  logic        we,
  input  logic [31:0] adr,
  input  logic [3:0]  sel,
  input  logic [31:0] dat_o,
  output logic        ack,
  output logic        stall,
  output logic [31:0] dat_i,
  input  logic [31:1] ic_fetch_addr,
  input  logic        cpu_event_ack,
  input  logic [3:0]  cpu_event_lvl,
  input  logic        cpu_event_slp,
  input  logic        cpu_event_dbg,
  output logic        event_en,
  output logic [1:0]  event_cmd,
  output logic [7:0]  event_vec,
  output logic        event_msk,
  output logic [3:0]  event_lvl,
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
  wb_m2s_t wb_i;
  wb_s2m_t wb_o;
  cpu_event_i_t event_o;

  assign wb_i = '{
    cyc: cyc, stb: stb, we: we, adr: adr, sel: sel, dat: dat_o,
    lock: 1'b0, tgc: 1'b0
  };
  assign {event_en, event_cmd, event_vec, event_msk, event_lvl} =
         {event_o.en, event_o.cmd, event_o.vec, event_o.msk, event_o.lvl};

  j2_periph u_periph (
    .clk, .rst, .wb_i, .wb_o,
    .ic_fetch_addr,
    .cpu_event_i('{
      ack: cpu_event_ack, lvl: cpu_event_lvl,
      slp: cpu_event_slp, dbg: cpu_event_dbg
    }),
    .cpu_event_o(event_o),
    .rtc_sec, .rtc_nsec,
    .uart_rx, .uart_tx,
    .spi_clk, .spi_cs, .spi_mosi, .spi_miso,
    .pi, .po);

  assign {ack, stall, dat_i} = {wb_o.ack, wb_o.stall, wb_o.dat};
endmodule
