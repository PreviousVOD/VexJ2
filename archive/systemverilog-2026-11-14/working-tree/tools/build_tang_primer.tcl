# Tang Dynasty full flow for the original J-Core VHDL CPU on Tang Primer.
# The wrapper starts TD in build/logs/td. Every path below is relative to the
# generated project directory in build/fpga.

cd ../../fpga
if {[catch {open_project j2_tang_primer_original.al} err]} {
  puts "TD open_project failed: $err"
  puts $errorInfo
  exit 1
}

elaborate -top j2_tang_primer_original
read_adc ../../rtl/fpga/tang_primer_original.adc
read_sdc ../../rtl/fpga/tang_primer_original.sdc

optimize_rtl
map_macro
map
pack
place
route

report_area -io_info -file ../logs/td/j2_tang_primer_original_area.txt
report_timing -file ../logs/td/j2_tang_primer_original_timing.txt
bitgen -bit j2_tang_primer_original.bit \
  -version 0X0000 \
  -svf j2_tang_primer_original.svf \
  -svf_comment_on \
  -g ucode:00000000000000000000000000000000
