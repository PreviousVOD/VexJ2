cd ../../fpga/microcode_probe
open_project j2_microcode_probe.al

elaborate -top j2_tang_primer_original
read_adc ../../../archive/systemverilog-2026-11-14/working-tree/rtl/fpga/tang_primer_original.adc
read_sdc ../../../archive/systemverilog-2026-11-14/working-tree/rtl/fpga/tang_primer_original.sdc

optimize_rtl
map_macro
map
pack
place
route

report_area -io_info -file ../../logs/td/j2_microcode_probe_area.txt
report_timing -file ../../logs/td/j2_microcode_probe_timing.txt
