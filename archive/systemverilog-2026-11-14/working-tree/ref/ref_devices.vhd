-- Flat-port wrapper around the ORIGINAL Mimas v2 peripheral subsystem
-- (targets/boards/mimas_v2/devices.vhd, unmodified): AIC (interrupts, PIT,
-- RTC), cache control register, SPI (SD card), PIO (LEDs) and uartlite,
-- with the original address decode. For ghdl --synth.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu2j0_pack.all;
use work.data_bus_pack.all;

entity ref_devices is
  port (
    clk, rst   : in  std_logic;
    -- native peripheral bus (from j2_wb2native)
    db_en      : in  std_logic;
    db_a       : in  std_logic_vector(31 downto 0);
    db_rd      : in  std_logic;
    db_wr      : in  std_logic;
    db_we      : in  std_logic_vector(3 downto 0);
    db_d       : in  std_logic_vector(31 downto 0);
    db_q       : out std_logic_vector(31 downto 0);
    db_ack     : out std_logic;
    -- CPU data-master monitor (AIC breakpoint / bus-error detection)
    mon_en     : in  std_logic;
    mon_ack    : in  std_logic;
    -- CPU events
    ev_o_ack   : in  std_logic;
    ev_o_lvl   : in  std_logic_vector(3 downto 0);
    ev_o_slp   : in  std_logic;
    ev_o_dbg   : in  std_logic;
    ev_i_en    : out std_logic;
    ev_i_cmd   : out std_logic_vector(1 downto 0);
    ev_i_vec   : out std_logic_vector(7 downto 0);
    ev_i_msk   : out std_logic;
    ev_i_lvl   : out std_logic_vector(3 downto 0);
    -- pins
    uart_rx    : in  std_logic;
    uart_tx    : out std_logic;
    spi_clk    : out std_logic;
    spi_cs     : out std_logic_vector(1 downto 0);
    spi_mosi   : out std_logic;
    spi_miso   : in  std_logic;
    pi         : in  std_logic_vector(31 downto 0);
    po         : out std_logic_vector(31 downto 0);
    -- cache control register outputs
    ic_en, ic_inv, dc_en, dc_inv : out std_logic);
end entity;

architecture rtl of ref_devices is
  signal dbus_o  : cpu_data_o_t;
  signal dbus_i  : cpu_data_i_t;
  signal evo     : cpu_event_o_t;
  signal evi     : cpu_event_i_t;
  signal ic0, dc0 : cache_ctrl_t;
begin
  dbus_o.en <= db_en;  dbus_o.a <= db_a;  dbus_o.rd <= db_rd;  dbus_o.wr <= db_wr;
  dbus_o.we <= db_we;  dbus_o.d <= db_d;
  db_q <= dbus_i.d;    db_ack <= dbus_i.ack;
  evo.ack <= ev_o_ack; evo.lvl <= ev_o_lvl; evo.slp <= ev_o_slp; evo.dbg <= ev_o_dbg;
  ev_i_en  <= evi.en;
  ev_i_cmd <= std_logic_vector(to_unsigned(cpu_event_cmd_t'pos(evi.cmd), 2));
  ev_i_vec <= evi.vec;  ev_i_msk <= evi.msk;  ev_i_lvl <= evi.lvl;
  ic_en <= ic0.en;  ic_inv <= ic0.inv;  dc_en <= dc0.en;  dc_inv <= dc0.inv;

  u : entity work.devices(impl)
    port map (
      cache01sel_ctrl_temp => open,
      clk_sys              => clk,
      cpu0_data_master_ack => mon_ack,
      cpu0_data_master_en  => mon_en,
      cpu0_ddr_ibus_o      => NULL_INST_O,
      cpu0_event_i         => evi,
      cpu0_event_o         => evo,
      cpu0_periph_dbus_i   => dbus_i,
      cpu0_periph_dbus_o   => dbus_o,
      cpu1_ddr_ibus_o      => NULL_INST_O,
      cpu1_periph_dbus_i   => open,
      cpu1_periph_dbus_o   => NULL_DATA_O,
      dcache0_ctrl         => dc0,
      dcache1_ctrl         => open,
      flash_clk            => spi_clk,
      flash_cs             => spi_cs,
      flash_miso           => spi_miso,
      flash_mosi           => spi_mosi,
      icache0_ctrl         => ic0,
      icache1_ctrl         => open,
      pi                   => pi,
      po                   => po,
      reset                => rst,
      uart0_rx             => uart_rx,
      uart0_tx             => uart_tx);
end architecture;
