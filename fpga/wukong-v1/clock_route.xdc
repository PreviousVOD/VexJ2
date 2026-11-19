# Apply after synthesis creates the input buffer. The board connects its 50 MHz
# oscillator to M22, the N side of a CCIO pair. QMTECH's example also needs an
# input-clock routing exception. Scope it to that input; keep clock-generator outputs global.
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk50_IBUF]
