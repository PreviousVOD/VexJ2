cd ../../fpga
open_project j2_tang_primer_original.al
# This is volatile FPGA configuration-SRAM loading over JTAG.  It does not
# erase or program the external configuration flash.
download -bit j2_tang_primer_original.bit \
  -mode jtag -spd 4 -sec 64 -cable 0
