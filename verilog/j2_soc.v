`default_nettype none

module j2_soc #(
  parameter ROM_INIT_FILE = "j2_validation_rom.mif"
) (
  input  wire       clk,
  input  wire       reset,
  input  wire       uart_rx,
  output wire       uart_tx,
  output wire [2:0] rgb_led
);
  wire ibus_cyc;
  wire ibus_stb;
  wire ibus_ack;
  wire ibus_we;
  wire [31:0] ibus_adr;
  wire [31:0] ibus_dat_miso;
  wire [31:0] ibus_dat_mosi;
  wire [3:0] ibus_sel;
  wire ibus_lock;

  wire dbus_cyc;
  wire dbus_stb;
  wire dbus_ack;
  wire dbus_we;
  wire [31:0] dbus_adr;
  wire [31:0] dbus_dat_miso;
  wire [31:0] dbus_dat_mosi;
  wire [3:0] dbus_sel;
  wire dbus_lock;

  wire memory_ack;
  wire [31:0] memory_data;
  wire pio_ack;
  wire [31:0] pio_data;
  wire [31:0] pio_out;
  wire uart_ack;
  wire [31:0] uart_data;

  wire select_memory = dbus_adr < 32'h00008000;
  wire select_pio = (dbus_adr & 32'hfffffff0) == 32'habcd0000;
  wire select_uart = (dbus_adr & 32'hffffffe0) == 32'habcd0100;
  wire select_loopback = !select_memory && !select_pio && !select_uart;
  wire loopback_ack = dbus_cyc && dbus_stb && select_loopback;

  wire [31:0] cpu_pc;
  wire [31:0] cpu_sr;
  wire cpu_sleep;
  wire cpu_retired;
  wire cpu_illegal;
  wire cpu_debug_break;
  wire [2:0] cpu_debug_state;
  wire [15:0] cpu_debug_opcode;
  wire cpu_debug_slot_illegal;
  wire cpu_debug_event_pending;
  wire event_ready;
  wire event_ack;

  J2MicrocodedCore cpu (
    .io_ibus_CYC(ibus_cyc),
    .io_ibus_STB(ibus_stb),
    .io_ibus_ACK(ibus_ack),
    .io_ibus_WE(ibus_we),
    .io_ibus_ADR(ibus_adr),
    .io_ibus_DAT_MISO(ibus_dat_miso),
    .io_ibus_DAT_MOSI(ibus_dat_mosi),
    .io_ibus_SEL(ibus_sel),
    .io_ibus_ERR(1'b0),
    .io_ibus_LOCK(ibus_lock),
    .io_dbus_CYC(dbus_cyc),
    .io_dbus_STB(dbus_stb),
    .io_dbus_ACK(dbus_ack),
    .io_dbus_WE(dbus_we),
    .io_dbus_ADR(dbus_adr),
    .io_dbus_DAT_MISO(dbus_dat_miso),
    .io_dbus_DAT_MOSI(dbus_dat_mosi),
    .io_dbus_SEL(dbus_sel),
    .io_dbus_ERR(1'b0),
    .io_dbus_LOCK(dbus_lock),
    .io_event_valid(1'b0),
    .io_event_ready(event_ready),
    .io_event_payload_command(2'b00),
    .io_event_payload_vector(8'b0),
    .io_event_payload_level(4'b0),
    .io_event_payload_bypassMask(1'b0),
    .io_eventAck(event_ack),
    .io_pc(cpu_pc),
    .io_sr(cpu_sr),
    .io_sleep(cpu_sleep),
    .io_retired(cpu_retired),
    .io_illegal(cpu_illegal),
    .io_debugBreak(cpu_debug_break),
    .io_debugState(cpu_debug_state),
    .io_debugOpcode(cpu_debug_opcode),
    .io_debugSlotIllegal(cpu_debug_slot_illegal),
    .io_debugEventPending(cpu_debug_event_pending),
    .reset(reset),
    .clk(clk)
  );

  j2_validation_rom #(.INIT_FILE(ROM_INIT_FILE)) memory (
    .clk(clk),
    .reset(reset),
    .dbus_cyc(dbus_cyc && select_memory),
    .dbus_stb(dbus_stb && select_memory),
    .dbus_ack(memory_ack),
    .dbus_we(dbus_we),
    .dbus_adr(dbus_adr),
    .dbus_dat_miso(memory_data),
    .dbus_dat_mosi(dbus_dat_mosi),
    .dbus_sel(dbus_sel),
    .ibus_cyc(ibus_cyc),
    .ibus_stb(ibus_stb),
    .ibus_ack(ibus_ack),
    .ibus_adr(ibus_adr),
    .ibus_dat_miso(ibus_dat_miso)
  );

  j2_pio pio (
    .clk(clk),
    .reset(reset),
    .bus_cyc(dbus_cyc && select_pio),
    .bus_stb(dbus_stb && select_pio),
    .bus_ack(pio_ack),
    .bus_we(dbus_we),
    .bus_dat_mosi(dbus_dat_mosi),
    .bus_dat_miso(pio_data),
    .pio_out(pio_out)
  );

  j2_uart16550 uart (
    .clk(clk),
    .reset(reset),
    .bus_cyc(dbus_cyc && select_uart),
    .bus_stb(dbus_stb && select_uart),
    .bus_ack(uart_ack),
    .bus_we(dbus_we),
    .bus_adr(dbus_adr),
    .bus_dat_miso(uart_data),
    .bus_dat_mosi(dbus_dat_mosi),
    .uart_rx(uart_rx),
    .uart_tx(uart_tx)
  );

  assign dbus_ack = select_memory ? memory_ack :
                    select_pio ? pio_ack :
                    select_uart ? uart_ack : loopback_ack;
  assign dbus_dat_miso = select_memory ? memory_data :
                         select_pio ? pio_data :
                         select_uart ? uart_data : 32'b0;
  assign rgb_led = pio_out[2:0];
endmodule

`default_nettype wire
