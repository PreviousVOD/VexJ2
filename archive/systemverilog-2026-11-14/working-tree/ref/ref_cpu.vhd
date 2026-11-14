-- Flat-port wrapper around the original J2 CPU (configuration cpu_sim:
-- reverse_logic decoder, register_file(two_bank)), for ghdl --synth.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu2j0_pack.all;

entity ref_cpu is
  port (
    clk, rst      : in  std_logic;
    -- data bus
    db_en         : out std_logic;
    db_a          : out std_logic_vector(31 downto 0);
    db_rd, db_wr  : out std_logic;
    db_we         : out std_logic_vector(3 downto 0);
    db_do         : out std_logic_vector(31 downto 0);
    db_lock       : out std_logic;
    db_di         : in  std_logic_vector(31 downto 0);
    db_ack        : in  std_logic;
    -- instruction bus
    inst_en       : out std_logic;
    inst_a        : out std_logic_vector(31 downto 1);
    inst_jp       : out std_logic;
    inst_d        : in  std_logic_vector(15 downto 0);
    inst_ack      : in  std_logic;
    -- debug
    dbg_o_ack     : out std_logic;
    dbg_o_d       : out std_logic_vector(31 downto 0);
    dbg_o_rdy     : out std_logic;
    dbg_i_en      : in  std_logic;
    dbg_i_cmd     : in  std_logic_vector(1 downto 0);
    dbg_i_ir      : in  std_logic_vector(15 downto 0);
    dbg_i_d       : in  std_logic_vector(31 downto 0);
    dbg_i_d_en    : in  std_logic;
    -- events
    ev_o_ack      : out std_logic;
    ev_o_lvl      : out std_logic_vector(3 downto 0);
    ev_o_slp      : out std_logic;
    ev_o_dbg      : out std_logic;
    ev_i_en       : in  std_logic;
    ev_i_cmd      : in  std_logic_vector(1 downto 0);
    ev_i_vec      : in  std_logic_vector(7 downto 0);
    ev_i_msk      : in  std_logic;
    ev_i_lvl      : in  std_logic_vector(3 downto 0));
end entity;

architecture rtl of ref_cpu is
  signal db_o    : cpu_data_o_t;
  signal db_i    : cpu_data_i_t;
  signal inst_o  : cpu_instruction_o_t;
  signal inst_i  : cpu_instruction_i_t;
  signal debug_o : cpu_debug_o_t;
  signal debug_i : cpu_debug_i_t;
  signal event_o : cpu_event_o_t;
  signal event_i : cpu_event_i_t;
begin
  -- Bindings of configuration cpu_sim are applied by tools/ref_synth.sh
  u : entity work.cpu(stru)
    port map (clk => clk, rst => rst, db_o => db_o, db_lock => db_lock, db_i => db_i,
              inst_o => inst_o, inst_i => inst_i, debug_o => debug_o, debug_i => debug_i,
              event_o => event_o, event_i => event_i);

  db_en <= db_o.en;  db_a <= db_o.a;  db_rd <= db_o.rd;  db_wr <= db_o.wr;
  db_we <= db_o.we;  db_do <= db_o.d;
  db_i.d <= db_di;   db_i.ack <= db_ack;

  inst_en <= inst_o.en;  inst_a <= inst_o.a;  inst_jp <= inst_o.jp;
  inst_i.d <= inst_d;    inst_i.ack <= inst_ack;

  dbg_o_ack <= debug_o.ack;  dbg_o_d <= debug_o.d;  dbg_o_rdy <= debug_o.rdy;
  debug_i.en   <= dbg_i_en;
  debug_i.cmd  <= cpu_debug_cmd_t'val(to_integer(unsigned(dbg_i_cmd)));
  debug_i.ir   <= dbg_i_ir;
  debug_i.d    <= dbg_i_d;
  debug_i.d_en <= dbg_i_d_en;

  ev_o_ack <= event_o.ack;  ev_o_lvl <= event_o.lvl;
  ev_o_slp <= event_o.slp;  ev_o_dbg <= event_o.dbg;
  event_i.en  <= ev_i_en;
  event_i.cmd <= cpu_event_cmd_t'val(to_integer(unsigned(ev_i_cmd)));
  event_i.vec <= ev_i_vec;
  event_i.msk <= ev_i_msk;
  event_i.lvl <= ev_i_lvl;
end architecture;
