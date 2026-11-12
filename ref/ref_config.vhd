-- Stand-in for the 'config' package that the original build generates from
-- soc_config.mk (tools/soc.mk). Values as used for the Mimas v2 board:
-- 50 MHz CPU / bus clock.
package config is
  constant CFG_SA_WIDTH              : integer := 13;
  constant CFG_DDRDQ_WIDTH           : integer := 16;
  constant CFG_CLK_CPU_DIVIDE        : integer := 20;
  constant CFG_CLK_MEM_2X_DIVIDE     : integer := 10;
  constant CFG_CLK_CPU_PERIOD_NS     : integer := 20;
  constant CFG_CLK_MEM_PERIOD_NS     : integer := 20;
  constant CFG_CLK_BITLINK_PERIOD_NS : integer := 8;
  constant CFG_DDR_READ_SAMPLE_TM    : integer := 2;
  constant CFG_DDR_CK_CYCLE          : integer := 20;
end package;
