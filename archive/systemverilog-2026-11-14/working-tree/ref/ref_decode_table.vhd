-- Flat-port wrappers around the original decode_table architectures, for
-- ghdl --synth --out=verilog. Output layout = SV j2_decode_pkg::decode_table_o_t.
library ieee;
use ieee.std_logic_1164.all;
use work.decode_pack.all;
use work.ref_flatten_pkg.all;

package ref_decode_table_glue is
  function flatten(debug, delay_jump, dispatch, event_ack_0 : std_logic;
                   ex : pipeline_ex_t; ex_stall : pipeline_ex_stall_t;
                   id : pipeline_id_t;
                   ilevel_cap, mac_s_latch, mac_stall_sense, maskint_next, slp : std_logic;
                   wb : pipeline_wb_t; wb_stall : pipeline_wb_stall_t)
    return std_logic_vector;
end package;

package body ref_decode_table_glue is
  function flatten(debug, delay_jump, dispatch, event_ack_0 : std_logic;
                   ex : pipeline_ex_t; ex_stall : pipeline_ex_stall_t;
                   id : pipeline_id_t;
                   ilevel_cap, mac_s_latch, mac_stall_sense, maskint_next, slp : std_logic;
                   wb : pipeline_wb_t; wb_stall : pipeline_wb_stall_t)
    return std_logic_vector is
  begin
    return b(debug) & b(delay_jump) & b(dispatch) & b(event_ack_0)
      & to_slv(ex) & to_slv(ex_stall) & to_slv(id)
      & b(ilevel_cap) & b(mac_s_latch) & b(mac_stall_sense) & b(maskint_next) & b(slp)
      & to_slv(wb) & to_slv(wb_stall);
  end;
end package body;


library ieee;
use ieee.std_logic_1164.all;
use work.decode_pack.all;
use work.ref_flatten_pkg.all;
entity ref_decode_table_simple is
  port (
    next_id_stall : in  std_logic;
    plane         : in  std_logic;
    code          : in  std_logic_vector(15 downto 0);
    addr          : in  std_logic_vector(7 downto 0);
    t_bcc         : in  std_logic;
    o             : out std_logic_vector(DT_O_W-1 downto 0));
end entity;

library ieee;
use ieee.std_logic_1164.all;
use work.decode_pack.all;
use work.ref_flatten_pkg.all;
entity ref_decode_table_reverse is
  port (
    next_id_stall : in  std_logic;
    plane         : in  std_logic;
    code          : in  std_logic_vector(15 downto 0);
    addr          : in  std_logic_vector(7 downto 0);
    t_bcc         : in  std_logic;
    o             : out std_logic_vector(DT_O_W-1 downto 0));
end entity;

library ieee;
use ieee.std_logic_1164.all;
use work.decode_pack.all;
use work.ref_decode_table_glue.all;

architecture rtl of ref_decode_table_simple is
  signal op : operation_t;
  signal debug, delay_jump, dispatch, event_ack_0 : std_logic;
  signal ex : pipeline_ex_t;
  signal ex_stall : pipeline_ex_stall_t;
  signal id : pipeline_id_t;
  signal ilevel_cap, mac_s_latch, mac_stall_sense, maskint_next, slp : std_logic;
  signal wb : pipeline_wb_t;
  signal wb_stall : pipeline_wb_stall_t;
begin
  op.plane <= SYSTEM_INSTR when plane = '1' else NORMAL_INSTR;
  op.code  <= code;
  op.addr  <= addr;
  u : entity work.decode_table(simple_logic)
    port map (clk => '0', next_id_stall => next_id_stall, op => op, t_bcc => t_bcc,
              debug => debug, delay_jump => delay_jump, dispatch => dispatch,
              event_ack_0 => event_ack_0, ex => ex, ex_stall => ex_stall, id => id,
              ilevel_cap => ilevel_cap, mac_s_latch => mac_s_latch,
              mac_stall_sense => mac_stall_sense, maskint_next => maskint_next,
              slp => slp, wb => wb, wb_stall => wb_stall);
  o <= flatten(debug, delay_jump, dispatch, event_ack_0, ex, ex_stall, id,
               ilevel_cap, mac_s_latch, mac_stall_sense, maskint_next, slp, wb, wb_stall);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.decode_pack.all;
use work.ref_decode_table_glue.all;

architecture rtl of ref_decode_table_reverse is
  signal op : operation_t;
  signal debug, delay_jump, dispatch, event_ack_0 : std_logic;
  signal ex : pipeline_ex_t;
  signal ex_stall : pipeline_ex_stall_t;
  signal id : pipeline_id_t;
  signal ilevel_cap, mac_s_latch, mac_stall_sense, maskint_next, slp : std_logic;
  signal wb : pipeline_wb_t;
  signal wb_stall : pipeline_wb_stall_t;
begin
  op.plane <= SYSTEM_INSTR when plane = '1' else NORMAL_INSTR;
  op.code  <= code;
  op.addr  <= addr;
  u : entity work.decode_table(reverse_logic)
    port map (clk => '0', next_id_stall => next_id_stall, op => op, t_bcc => t_bcc,
              debug => debug, delay_jump => delay_jump, dispatch => dispatch,
              event_ack_0 => event_ack_0, ex => ex, ex_stall => ex_stall, id => id,
              ilevel_cap => ilevel_cap, mac_s_latch => mac_s_latch,
              mac_stall_sense => mac_stall_sense, maskint_next => maskint_next,
              slp => slp, wb => wb, wb_stall => wb_stall);
  o <= flatten(debug, delay_jump, dispatch, event_ack_0, ex, ex_stall, id,
               ilevel_cap, mac_s_latch, mac_stall_sense, maskint_next, slp, wb, wb_stall);
end architecture;
