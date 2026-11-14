cd ../../../build/fpga/j2_tang_primer_verilog
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

report_area -io_info -file ../../logs/td_verilog/j2_tang_primer_area.txt
set timing_report ../../logs/td_verilog/j2_tang_primer_timing.txt
report_timing -file $timing_report

set stream [open $timing_report r]
set timing [read $stream]
close $stream
if {![regexp {([0-9]+) errors detected} $timing -> errors]} {
  puts "ERROR: could not find the timing summary in $timing_report"
  exit 1
}
if {$errors != 0} {
  puts "ERROR: timing reported $errors errors; refusing to generate a bitstream"
  exit 1
}

bitgen -bit j2_tang_primer.bit \
  -version 0X0000 \
  -svf j2_tang_primer.svf \
  -svf_comment_on \
  -g ucode:00000000000000000000000000000000
