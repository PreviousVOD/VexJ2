-- Flat-port wrappers around original J2 datapath units, for ghdl --synth.
--   ref_alu      : the ALU functions from components_pkg.vhd (combinational)
--   ref_regfile  : register_file(two_bank) as configured in datapath.vhm
--   ref_mult     : mult(stru) from mult.vhm
-- Enum ports are encoded by position, matching rtl/pkg enum encodings.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu2j0_components_pack.all;

entity ref_alu is
  port (
    -- arith_unit / arith_update_sr
    a, b         : in  std_logic_vector(31 downto 0);
    arith_func   : in  std_logic_vector(0 downto 0);
    ci           : in  std_logic;
    sr_in        : in  std_logic_vector(7 downto 0);   -- t,s,q,m,int_mask(3:0)
    a_msb, b_msb : in  std_logic;
    arith_sr     : in  std_logic_vector(2 downto 0);
    logic_func   : in  std_logic_vector(1 downto 0);
    logic_sr     : in  std_logic_vector(0 downto 0);
    shift_b      : in  std_logic_vector(5 downto 0);
    shift_c      : in  std_logic;
    shift_func   : in  std_logic_vector(1 downto 0);
    manip_func   : in  std_logic_vector(2 downto 0);
    arith_o      : out std_logic_vector(32 downto 0);
    arith_sr_o   : out std_logic_vector(7 downto 0);
    logic_o      : out std_logic_vector(31 downto 0);
    logic_sr_o   : out std_logic_vector(7 downto 0);
    shift_o      : out std_logic_vector(31 downto 0);
    manip_o      : out std_logic_vector(31 downto 0));
end entity;

architecture rtl of ref_alu is
  function to_sr(v : std_logic_vector(7 downto 0)) return sr_t is
    variable r : sr_t;
  begin
    r.t := v(7); r.s := v(6); r.q := v(5); r.m := v(4); r.int_mask := v(3 downto 0);
    return r;
  end;
  function from_sr(r : sr_t) return std_logic_vector is
  begin
    return r.t & r.s & r.q & r.m & r.int_mask;
  end;
  signal af  : arith_func_t;
  signal asr : arith_sr_func_t;
  signal lf  : logic_func_t;
  signal lsr : logic_sr_func_t;
  signal sf  : shiftfunc_t;
  signal mf  : alumanip_t;
  signal ar  : std_logic_vector(32 downto 0);
  signal lr  : std_logic_vector(31 downto 0);
begin
  af  <= arith_func_t'val(to_integer(unsigned(arith_func)));
  asr <= arith_sr_func_t'val(to_integer(unsigned(arith_sr)));
  lf  <= logic_func_t'val(to_integer(unsigned(logic_func)));
  lsr <= logic_sr_func_t'val(to_integer(unsigned(logic_sr)));
  sf  <= shiftfunc_t'val(to_integer(unsigned(shift_func)));
  mf  <= alumanip_t'val(to_integer(unsigned(manip_func)));

  ar <= arith_unit(a, b, af, ci);
  lr <= logic_unit(a, b, lf);
  arith_o    <= ar;
  arith_sr_o <= from_sr(arith_update_sr(to_sr(sr_in), a_msb, b_msb, ar(31 downto 0), ar(32), af, asr));
  logic_o    <= lr;
  logic_sr_o <= from_sr(logic_update_sr(to_sr(sr_in), lr, lsr));
  shift_o    <= bshifter(a, shift_b, shift_c, sf);
  manip_o    <= manip(a, b, mf);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.cpu2j0_components_pack.all;

entity ref_regfile is
  port (
    clk, rst, ce : in  std_logic;
    addr_ra      : in  std_logic_vector(4 downto 0);
    dout_a       : out std_logic_vector(31 downto 0);
    addr_rb      : in  std_logic_vector(4 downto 0);
    dout_b       : out std_logic_vector(31 downto 0);
    dout_0       : out std_logic_vector(31 downto 0);
    we_wb        : in  std_logic;
    w_addr_wb    : in  std_logic_vector(4 downto 0);
    din_wb       : in  std_logic_vector(31 downto 0);
    we_ex        : in  std_logic;
    w_addr_ex    : in  std_logic_vector(4 downto 0);
    din_ex       : in  std_logic_vector(31 downto 0);
    wr_data_o    : out std_logic_vector(31 downto 0));
end entity;

architecture rtl of ref_regfile is
begin
  u : entity work.register_file(two_bank)
    generic map (ADDR_WIDTH => 5, NUM_REGS => 21, REG_WIDTH => 32)
    port map (clk => clk, rst => rst, ce => ce,
              addr_ra => addr_ra, dout_a => dout_a, addr_rb => addr_rb, dout_b => dout_b,
              dout_0 => dout_0, we_wb => we_wb, w_addr_wb => w_addr_wb, din_wb => din_wb,
              we_ex => we_ex, w_addr_ex => w_addr_ex, din_ex => din_ex,
              wr_data_o => wr_data_o);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mult_pkg.all;

entity ref_mult is
  port (
    clk, rst, slot : in  std_logic;
    wr_m1          : in  std_logic;
    command        : in  std_logic_vector(4 downto 0);
    s              : in  std_logic;
    wr_mach        : in  std_logic;
    wr_macl        : in  std_logic;
    in1, in2       : in  std_logic_vector(31 downto 0);
    mach, macl     : out std_logic_vector(31 downto 0);
    busy           : out std_logic);
end entity;

architecture rtl of ref_mult is
  signal a : mult_i_t;
  signal y : mult_o_t;
begin
  a.wr_m1   <= wr_m1;
  a.command <= mult_state_t'val(to_integer(unsigned(command)));
  a.s       <= s;
  a.wr_mach <= wr_mach;
  a.wr_macl <= wr_macl;
  a.in1     <= in1;
  a.in2     <= in2;
  u : entity work.mult(stru) port map (clk => clk, rst => rst, slot => slot, a => a, y => y);
  mach <= y.mach;
  macl <= y.macl;
  busy <= y.busy;
end architecture;
