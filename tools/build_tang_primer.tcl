# Full Tang Dynasty flow. Invoked from build/logs/td.

cd ../../../build/fpga/j2_tang_primer
open_project j2_tang_primer.al

elaborate -top j2_tang_primer
read_adc j2_tang_primer.adc
read_sdc j2_tang_primer.sdc

optimize_rtl
map_macro
map
pack
place
route

report_area -io_info -file ../../logs/td/j2_tang_primer_area.txt
report_timing -file ../../logs/td/j2_tang_primer_timing.txt
bitgen -bit j2_tang_primer.bit \
  -version 0X0000 \
  -svf j2_tang_primer.svf \
  -svf_comment_on \
  -g ucode:00000000000000000000000000000000
