create_clock -name clk24 -period 41.667 [get_ports clk24]
create_clock -name soc_clk -period 33.333333 [get_nets {eg4Bufg_o}]
