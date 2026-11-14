// J2 reference SoC using the native SystemVerilog peripheral subsystem.
//
// The external interfaces and address map match j2_soc_ref:
//   0x0xxxxxxx  on-chip SRAM (SRAM_WORDS x 32, mirrored)
//   0xAxxxxxxx  Mimas v2 peripherals
//   other       external Wishbone data port
// Instruction fetches use SRAM for 0x0xxxxxxx and the external port otherwise.
module j2_soc
  import j2_cpu_pkg::*;
  import j2_wb_pkg::*;
#(
  parameter int SRAM_WORDS          = 8192,
  parameter bit ILLEGAL_VEC_FIX     = 1'b1,
  parameter bit ILLEGAL_OPCODE_TRAP = 1'b1,
  parameter int CLK_HZ              = 50_000_000,
  parameter int BUS_PERIOD_NS       = 20,
  parameter string SRAM_INIT_FILE    = ""
) (
  input  logic        clk,
  input  logic        rst,
  output wb_m2s_t     ext_d_o,
  input  wb_s2m_t     ext_d_i,
  output wb_m2s_t     ext_i_o,
  input  wb_s2m_t     ext_i_i,
  input  logic        uart_rx,
  output logic        uart_tx,
  output logic        spi_clk,
  output logic [1:0]  spi_cs,
  output logic        spi_mosi,
  input  logic        spi_miso,
  input  logic [31:0] pi,
  output logic [31:0] po
);
  wb_m2s_t ibus_o, dbus_o;
  wb_s2m_t ibus_i, dbus_i;
  cpu_event_i_t ev_i;
  cpu_event_o_t ev_o;
  /* verilator lint_off UNUSEDSIGNAL */  // debug/RTC are not top-level pins
  cpu_debug_o_t dbg_o;
  logic [63:0] rtc_sec;
  logic [31:0] rtc_nsec;
  /* verilator lint_on UNUSEDSIGNAL */

  j2_cpu #(
    .ILLEGAL_VEC_FIX(ILLEGAL_VEC_FIX),
    .ILLEGAL_OPCODE_TRAP(ILLEGAL_OPCODE_TRAP)
  ) u_cpu (
    .clk, .rst, .ibus_o, .ibus_i, .dbus_o, .dbus_i,
    .debug_i(CPU_DEBUG_NOP), .debug_o(dbg_o),
    .event_i(ev_i), .event_o(ev_o));

  wb_m2s_t [1:0] is_o;
  wb_s2m_t [1:0] is_i;
  wb_m2s_t [2:0] ds_o;
  wb_s2m_t [2:0] ds_i;

  j2_wb_decoder #(
    .N(2),
    .BASE({32'h0000_0000, 32'h0000_0000}),
    .MASK({32'h0000_0000, 32'hf000_0000})
  ) u_idec (
    .clk, .rst, .m_i(ibus_o), .m_o(ibus_i), .s_o(is_o), .s_i(is_i));

  j2_wb_decoder #(
    .N(3),
    .BASE({32'h0000_0000, 32'ha000_0000, 32'h0000_0000}),
    .MASK({32'h0000_0000, 32'hf000_0000, 32'hf000_0000})
  ) u_ddec (
    .clk, .rst, .m_i(dbus_o), .m_o(dbus_i), .s_o(ds_o), .s_i(ds_i));

  j2_wb_sram #(.WORDS(SRAM_WORDS), .INIT_FILE(SRAM_INIT_FILE)) u_sram (
    .clk, .rst,
    .a_i(ds_o[0]), .a_o(ds_i[0]),
    .b_i(is_o[0]), .b_o(is_i[0]));

  assign ext_i_o = is_o[1];
  assign is_i[1] = ext_i_i;
  assign ext_d_o = ds_o[2];
  assign ds_i[2] = ext_d_i;

  j2_periph #(
    .CLK_HZ(CLK_HZ),
    .BUS_PERIOD_NS(BUS_PERIOD_NS)
  ) u_periph (
    .clk, .rst, .wb_i(ds_o[1]), .wb_o(ds_i[1]),
    .ic_fetch_addr(ibus_o.adr[31:1]),
    .cpu_event_i(ev_o), .cpu_event_o(ev_i),
    .rtc_sec, .rtc_nsec,
    .uart_rx, .uart_tx,
    .spi_clk, .spi_cs, .spi_mosi, .spi_miso,
    .pi, .po);
endmodule
