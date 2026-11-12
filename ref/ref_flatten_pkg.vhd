-- Flatten the original J2 VHDL record types into std_logic_vectors whose bit
-- layout equals the SystemVerilog packed structs in rtl/pkg (first field at
-- the MSB, enums encoded by position). Used by the ref_* wrappers so that
-- ghdl --synth produces flat ports that compare 1:1 with the new RTL.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.cpu2j0_components_pack.all;
use work.mult_pkg.all;
use work.decode_pack.all;

package ref_flatten_pkg is
  function e(n : natural; w : natural) return std_logic_vector;
  function b(x : std_logic) return std_logic_vector;

  constant EX_W       : natural := 32+2+3+5+5+5+3+2+2+1+1+3+2+1+1+1+1+2;
  constant EX_STALL_W : natural := 1+1+1+1+3+3+2+2+1+1+1+1+2+1+5+2+2;
  constant ID_W       : natural := 3;
  constant WB_W       : natural := 5+1;
  constant WB_STALL_W : natural := 1+1+1+1+1+2+2+5;
  constant DT_O_W     : natural := 4 + EX_W + EX_STALL_W + ID_W + 5 + WB_W + WB_STALL_W;

  function to_slv(r : pipeline_ex_t) return std_logic_vector;
  function to_slv(r : pipeline_ex_stall_t) return std_logic_vector;
  function to_slv(r : pipeline_id_t) return std_logic_vector;
  function to_slv(r : pipeline_wb_t) return std_logic_vector;
  function to_slv(r : pipeline_wb_stall_t) return std_logic_vector;
end package;

package body ref_flatten_pkg is
  function e(n : natural; w : natural) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(n, w));
  end;

  function b(x : std_logic) return std_logic_vector is
    variable r : std_logic_vector(0 downto 0);
  begin
    r(0) := x;
    return r;
  end;

  function to_slv(r : pipeline_ex_t) return std_logic_vector is
  begin
    return r.imm_val
      & e(xbus_sel_t'pos(r.xbus_sel), 2)
      & e(ybus_sel_t'pos(r.ybus_sel), 3)
      & r.regnum_z & r.regnum_x & r.regnum_y
      & e(alumanip_t'pos(r.alumanip), 3)
      & e(aluinx_sel_t'pos(r.aluinx_sel), 2)
      & e(aluiny_sel_t'pos(r.aluiny_sel), 2)
      & e(arith_func_t'pos(r.arith_func), 1)
      & b(r.arith_ci_en)
      & e(arith_sr_func_t'pos(r.arith_sr_func), 3)
      & e(logic_func_t'pos(r.logic_func), 2)
      & e(logic_sr_func_t'pos(r.logic_sr_func), 1)
      & b(r.mac_busy) & b(r.ma_wr) & b(r.mem_lock)
      & e(mem_size_t'pos(r.mem_size), 2);
  end;

  function to_slv(r : pipeline_ex_stall_t) return std_logic_vector is
  begin
    return b(r.wrpc_z) & b(r.wrsr_z) & b(r.ma_issue) & b(r.wrpr_pc)
      & e(zbus_sel_t'pos(r.zbus_sel), 3)
      & e(sr_sel_t'pos(r.sr_sel), 3)
      & e(t_sel_t'pos(r.t_sel), 2)
      & e(mem_addr_sel_t'pos(r.mem_addr_sel), 2)
      & e(mem_wdata_sel_t'pos(r.mem_wdata_sel), 1)
      & b(r.wrreg_z) & b(r.wrmach) & b(r.wrmacl)
      & e(shiftfunc_t'pos(r.shiftfunc), 2)
      & b(r.mulcom1)
      & e(mult_state_t'pos(r.mulcom2), 5)
      & e(macin1_sel_t'pos(r.macsel1), 2)
      & e(macin2_sel_t'pos(r.macsel2), 2);
  end;

  function to_slv(r : pipeline_id_t) return std_logic_vector is
  begin
    return b(r.incpc) & b(r.if_issue) & b(r.ifadsel);
  end;

  function to_slv(r : pipeline_wb_t) return std_logic_vector is
  begin
    return r.regnum_w & b(r.mac_busy);
  end;

  function to_slv(r : pipeline_wb_stall_t) return std_logic_vector is
  begin
    return b(r.mulcom1) & b(r.wrmach) & b(r.wrmacl) & b(r.wrreg_w) & b(r.wrsr_w)
      & e(macin1_sel_t'pos(r.macsel1), 2)
      & e(macin2_sel_t'pos(r.macsel2), 2)
      & e(mult_state_t'pos(r.mulcom2), 5);
  end;
end package body;
