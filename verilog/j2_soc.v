`default_nettype none

module j2_soc #(
  parameter ROM_INIT_FILE = "j2_validation_rom.mif",
  parameter ROM_HEX_FILE = "j2_validation_rom.hex"
) (
  input  wire       clk,
  input  wire       reset,
  input  wire       uart_rx,
  output wire       uart_tx,
  output wire [2:0] rgb_led,
  output wire       spi_cs_n,
  output wire       spi_sck,
  output wire       spi_mosi,
  input  wire       spi_miso
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
  wire memory_ibus_ack;
  wire [31:0] memory_ibus_data;
  wire pio_ack;
  wire [31:0] pio_data;
  wire [31:0] pio_out;
  wire uart_ack;
  wire [31:0] uart_data;
  wire flash_ibus_ack;
  wire [31:0] flash_ibus_data;
  wire flash_dbus_ack;
  wire [31:0] flash_dbus_data;
  wire sdram_ack;
  wire [31:0] sdram_data;

  wire select_memory = dbus_adr < 32'h00008000;
  wire select_pio = (dbus_adr & 32'hfffffff0) == 32'hff000000;
  wire select_uart = (dbus_adr & 32'hffffffe0) == 32'hff001000;
  wire select_xip = (dbus_adr & 32'hfff00000) == 32'h10000000;
  wire select_sdram = (dbus_adr & 32'hff800000) == 32'h80000000;
  wire select_flash_config = (dbus_adr & 32'hffffffe0) == 32'hff002000;
  wire select_loopback = !select_memory && !select_pio && !select_uart &&
                         !select_xip && !select_sdram && !select_flash_config;
  wire loopback_ack = dbus_cyc && dbus_stb && select_loopback;
  wire select_ibus_xip = (ibus_adr & 32'hfff00000) == 32'h10000000;

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
    .io_event_ready(),
    .io_event_payload_command(2'b00),
    .io_event_payload_vector(8'b0),
    .io_event_payload_level(4'b0),
    .io_event_payload_bypassMask(1'b0),
    .io_eventAck(),
    .reset(reset),
    .clk(clk)
  );

  j2_validation_rom #(
    .INIT_FILE(ROM_INIT_FILE),
    .HEX_FILE(ROM_HEX_FILE)
  ) memory (
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
    .ibus_cyc(ibus_cyc && !select_ibus_xip),
    .ibus_stb(ibus_stb && !select_ibus_xip),
    .ibus_ack(memory_ibus_ack),
    .ibus_adr(ibus_adr),
    .ibus_dat_miso(memory_ibus_data)
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

  j2_spiflash flash (
    .clk(clk),
    .reset(reset),
    .ibus_cyc(ibus_cyc && select_ibus_xip),
    .ibus_stb(ibus_stb && select_ibus_xip),
    .ibus_adr(ibus_adr),
    .ibus_ack(flash_ibus_ack),
    .ibus_dat(flash_ibus_data),
    .dbus_cyc(dbus_cyc && (select_xip || select_flash_config)),
    .dbus_stb(dbus_stb && (select_xip || select_flash_config)),
    .dbus_we(dbus_we),
    .dbus_config(select_flash_config),
    .dbus_adr(dbus_adr),
    .dbus_dat_mosi(dbus_dat_mosi),
    .dbus_ack(flash_dbus_ack),
    .dbus_dat_miso(flash_dbus_data),
    .spi_cs_n(spi_cs_n),
    .spi_sck(spi_sck),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso)
  );

  j2_sdram sdram (
    .clk(clk),
    .reset(reset),
    .bus_cyc(dbus_cyc && select_sdram),
    .bus_stb(dbus_stb && select_sdram),
    .bus_we(dbus_we),
    .bus_sel(dbus_sel),
    .bus_adr(dbus_adr[22:0]),
    .bus_dat_mosi(dbus_dat_mosi),
    .bus_ack(sdram_ack),
    .bus_dat_miso(sdram_data)
  );

  assign ibus_ack = select_ibus_xip ? flash_ibus_ack : memory_ibus_ack;
  assign ibus_dat_miso = select_ibus_xip ? flash_ibus_data : memory_ibus_data;
  assign dbus_ack = select_memory ? memory_ack :
                    select_pio ? pio_ack :
                    select_uart ? uart_ack :
                    select_sdram ? sdram_ack :
                    (select_xip || select_flash_config) ? flash_dbus_ack : loopback_ack;
  assign dbus_dat_miso = select_memory ? memory_data :
                         select_pio ? pio_data :
                         select_uart ? uart_data :
                         select_sdram ? sdram_data :
                         (select_xip || select_flash_config) ? flash_dbus_data : 32'b0;
  assign rgb_led = pio_out[2:0];
endmodule

`default_nettype wire
