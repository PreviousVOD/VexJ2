# Program volatile FPGA configuration SRAM over JTAG. Do not write SPI flash.

cd ../../../build/fpga/j2_tang_primer_verilog
open_project j2_tang_primer.al
download -bit j2_tang_primer.bit \
  -mode jtag -spd 4 -sec 64 -cable 0
