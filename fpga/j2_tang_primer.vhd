-- EG4S20 Tang Primer validation top for the reference J2 core.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu2j0_pack.all;

entity j2_tang_primer is
  port (
    clk24   : in  std_logic;
    rst_n   : in  std_logic;
    uart_rx : in  std_logic;
    uart_tx : out std_logic;
    rgb_led : out std_logic_vector(2 downto 0)
  );
end entity;

architecture rtl of j2_tang_primer is
  signal rst_sync : std_logic_vector(1 downto 0) := (others => '0');
  signal rst      : std_logic;

  signal db_en, db_rd, db_wr, db_lock : std_logic;
  signal db_a                         : std_logic_vector(31 downto 0);
  signal db_we                        : std_logic_vector(3 downto 0);
  signal db_do                        : std_logic_vector(31 downto 0);
  signal db_di                        : std_logic_vector(31 downto 0);
  signal mem_di                       : std_logic_vector(31 downto 0);
  signal db_ack                       : std_logic;

  signal inst_en                  : std_logic;
  signal inst_a                   : std_logic_vector(31 downto 1);
  signal inst_jp                  : std_logic;
  signal inst_d                   : std_logic_vector(15 downto 0);
  signal inst_ack                 : std_logic;
  signal dbg_o_ack, dbg_o_rdy     : std_logic;
  signal dbg_o_d                  : std_logic_vector(31 downto 0);
  signal ev_o_ack, ev_o_slp, ev_o_dbg : std_logic;
  signal ev_o_lvl                 : std_logic_vector(3 downto 0);

  signal pio_bus_o, uart_bus_o : cpu_data_o_t;
  signal pio_bus_i, uart_bus_i : cpu_data_i_t;
  signal po                    : std_logic_vector(31 downto 0);
  signal uart_irq              : std_logic;
  signal pio_irq               : std_logic;
  signal pio_sel, uart_sel     : std_logic;
  signal mem_sel               : std_logic;

  signal mem_clk  : std_logic;
  signal inst_word : std_logic_vector(31 downto 0);
  signal data_be   : std_logic_vector(3 downto 0);

  component j2_eg4_bram32 is
    generic (
      INIT_FILE : string := "NONE"
    );
    port (
      clk   : in  std_logic;
      addra : in  std_logic_vector(12 downto 0);
      cea   : in  std_logic;
      bea   : in  std_logic_vector(3 downto 0);
      dia   : in  std_logic_vector(31 downto 0);
      doa   : out std_logic_vector(31 downto 0);
      addrb : in  std_logic_vector(12 downto 0);
      ceb   : in  std_logic;
      dib   : in  std_logic_vector(31 downto 0);
      dob   : out std_logic_vector(31 downto 0)
    );
  end component;
begin
  process (clk24)
  begin
    if rising_edge(clk24) then
      rst_sync <= rst_sync(0) & rst_n;
    end if;
  end process;
  rst <= not rst_sync(1);

  cpu0 : entity work.j2_cpu_flat
    port map (
      clk => clk24,
      rst => rst,
      db_en => db_en,
      db_a => db_a,
      db_rd => db_rd,
      db_wr => db_wr,
      db_we => db_we,
      db_do => db_do,
      db_lock => db_lock,
      db_di => db_di,
      db_ack => db_ack,
      inst_en => inst_en,
      inst_a => inst_a,
      inst_jp => inst_jp,
      inst_d => inst_d,
      inst_ack => inst_ack,
      dbg_o_ack => dbg_o_ack,
      dbg_o_d => dbg_o_d,
      dbg_o_rdy => dbg_o_rdy,
      dbg_i_en => '0',
      dbg_i_cmd => "00",
      dbg_i_ir => (others => '0'),
      dbg_i_d => (others => '0'),
      dbg_i_d_en => '0',
      ev_o_ack => ev_o_ack,
      ev_o_lvl => ev_o_lvl,
      ev_o_slp => ev_o_slp,
      ev_o_dbg => ev_o_dbg,
      ev_i_en => '0',
      ev_i_cmd => "00",
      ev_i_vec => (others => '0'),
      ev_i_msk => '0',
      ev_i_lvl => (others => '0')
    );

  mem_clk <= not clk24;
  data_be <= db_we when db_wr = '1' else "0000";
  program_ram : j2_eg4_bram32
    generic map (INIT_FILE => "../../../build/td_vhdl/j2_program.mif")
    port map (
      clk => mem_clk,
      addra => db_a(14 downto 2),
      cea => mem_sel,
      bea => data_be,
      dia => db_do,
      doa => mem_di,
      addrb => inst_a(14 downto 2),
      ceb => inst_en,
      dib => (others => '0'),
      dob => inst_word
    );

  inst_d <= inst_word(31 downto 16) when inst_a(1) = '0' else
            inst_word(15 downto 0);
  inst_ack <= inst_en;

  pio_sel  <= db_en when db_a(31 downto 4) = x"ABCD000" else '0';
  uart_sel <= db_en when db_a(31 downto 4) = x"ABCD010" else '0';
  mem_sel  <= db_en when db_a(31 downto 15) = "00000000000000000" else '0';

  pio_bus_o.en <= pio_sel;
  pio_bus_o.a  <= db_a;
  pio_bus_o.rd <= db_rd and pio_sel;
  pio_bus_o.wr <= db_wr and pio_sel;
  pio_bus_o.we <= db_we when pio_sel = '1' else "0000";
  pio_bus_o.d  <= db_do;

  uart_bus_o.en <= uart_sel;
  uart_bus_o.a  <= db_a;
  uart_bus_o.rd <= db_rd and uart_sel;
  uart_bus_o.wr <= db_wr and uart_sel;
  uart_bus_o.we <= db_we when uart_sel = '1' else "0000";
  uart_bus_o.d  <= db_do;

  pio0 : entity work.pio
    generic map (DEFAULT_OUT => (31 => '1', others => '0'))
    port map (
      clk_bus => clk24,
      reset => rst,
      db_i => pio_bus_o,
      db_o => pio_bus_i,
      irq => pio_irq,
      p_i => (others => '0'),
      p_o => po
    );

  uart0 : entity work.uartlitedb
    generic map (
      intcfg => 1,
      fclk => 24.0e6,
      bps => 19.2e3
    )
    port map (
      clk => clk24,
      rst => rst,
      db_i => uart_bus_o,
      db_o => uart_bus_i,
      int => uart_irq,
      rx => uart_rx,
      tx => uart_tx
    );

  process (pio_sel, uart_sel, mem_sel, pio_bus_i, uart_bus_i, mem_di, db_en)
  begin
    db_ack <= '0';
    db_di <= (others => '0');
    if pio_sel = '1' then
      db_ack <= pio_bus_i.ack;
      db_di <= pio_bus_i.d;
    elsif uart_sel = '1' then
      db_ack <= uart_bus_i.ack;
      db_di <= uart_bus_i.d;
    elsif mem_sel = '1' then
      db_ack <= db_en;
      db_di <= mem_di;
    else
      db_ack <= db_en;
    end if;
  end process;

  rgb_led <= po(2 downto 0);
end architecture;
