// Reference SoC: new j2_cpu + Wishbone fabric, with the ORIGINAL Mimas v2
// peripherals (ref/gen/ref_devices.v, converted from VHDL) behind the
// Wishbone -> native bus bridge.
//
// Data address map:
//   0x0xxxxxxx  on-chip SRAM (SRAM_WORDS x 32, mirrored)
//   0xAxxxxxxx  peripherals (original decode: GPIO ABCD0000, SPI ABCD0040,
//               cache ctrl ABCD00C0, UART ABCD0100, AIC ABCD0200; others ack 0)
//   other       external port (DDR region, simulation devices, ...)
// Instruction address map: 0x0xxxxxxx SRAM, other external port.
module j2_soc_ref
  import j2_cpu_pkg::*;
  import j2_wb_pkg::*;
#(
  parameter int SRAM_WORDS          = 8192,
  parameter bit ILLEGAL_VEC_FIX     = 1'b1,
  parameter bit ILLEGAL_OPCODE_TRAP = 1'b1
) (
  input  logic        clk,
  input  logic        rst,
  // external Wishbone port: data and instruction masters
  output wb_m2s_t     ext_d_o,
  input  wb_s2m_t     ext_d_i,
  output wb_m2s_t     ext_i_o,
  input  wb_s2m_t     ext_i_i,
  // pins
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
  cpu_debug_o_t dbg_o;

  j2_cpu #(.ILLEGAL_VEC_FIX(ILLEGAL_VEC_FIX), .ILLEGAL_OPCODE_TRAP(ILLEGAL_OPCODE_TRAP)) u_cpu (
    .clk, .rst, .ibus_o, .ibus_i, .dbus_o, .dbus_i,
    .debug_i(CPU_DEBUG_NOP), .debug_o(dbg_o), .event_i(ev_i), .event_o(ev_o));

  // ---------------------------------------------------------- fabric
  wb_m2s_t [1:0] is_o;  wb_s2m_t [1:0] is_i;   // ibus: 0 SRAM, 1 external
  wb_m2s_t [2:0] ds_o;  wb_s2m_t [2:0] ds_i;   // dbus: 0 SRAM, 1 periph, 2 external

  j2_wb_decoder #(.N(2), .BASE({32'h0000_0000, 32'h0000_0000}),
                  .MASK({32'h0000_0000, 32'hf000_0000})) u_idec (
    .clk, .rst, .m_i(ibus_o), .m_o(ibus_i), .s_o(is_o), .s_i(is_i));
  j2_wb_decoder #(.N(3), .BASE({32'h0000_0000, 32'ha000_0000, 32'h0000_0000}),
                  .MASK({32'h0000_0000, 32'hf000_0000, 32'hf000_0000})) u_ddec (
    .clk, .rst, .m_i(dbus_o), .m_o(dbus_i), .s_o(ds_o), .s_i(ds_i));

  j2_wb_sram #(.WORDS(SRAM_WORDS)) u_sram (
    .clk, .rst, .a_i(ds_o[0]), .a_o(ds_i[0]), .b_i(is_o[0]), .b_o(is_i[0]));

  assign ext_i_o = is_o[1];  assign is_i[1] = ext_i_i;
  assign ext_d_o = ds_o[2];  assign ds_i[2] = ext_d_i;

  // ------------------------------------------- original peripherals
  cpu_data_o_t nat_o;
  cpu_data_i_t nat_i;
  logic        nat_lock;
  logic [1:0]  ev_cmd;

  j2_wb2native u_bridge (.clk, .rst, .wb_i(ds_o[1]), .wb_o(ds_i[1]), .nat_o, .nat_lock, .nat_i);

  ref_devices u_dev (
    .clk, .rst,
    .db_en(nat_o.en), .db_a(nat_o.a), .db_rd(nat_o.rd), .db_wr(nat_o.wr), .db_we(nat_o.we),
    .db_d(nat_o.d), .db_q(nat_i.d), .db_ack(nat_i.ack),
    .mon_en(nat_o.en), .mon_ack(nat_i.ack),
    .ev_o_ack(ev_o.ack), .ev_o_lvl(ev_o.lvl), .ev_o_slp(ev_o.slp), .ev_o_dbg(ev_o.dbg),
    .ev_i_en(ev_i.en), .ev_i_cmd(ev_cmd), .ev_i_vec(ev_i.vec), .ev_i_msk(ev_i.msk),
    .ev_i_lvl(ev_i.lvl),
    .uart_rx, .uart_tx, .spi_clk, .spi_cs, .spi_mosi, .spi_miso, .pi, .po,
    .ic_en(), .ic_inv(), .dc_en(), .dc_inv());
  assign ev_i.cmd = cpu_event_cmd_t'(ev_cmd);
endmodule
