set root [file normalize [file join [file dirname [info script]] ..]]
set out [file join $root build wukong-v1]
source [file join $out board.tcl]
open_checkpoint [file join $out vivado synthesized.dcp]
# Verify generated clock configuration against the shared board profile.
set soc_period [get_property PERIOD [get_clocks pll_CLKOUT0]]
if {abs($soc_period - $board_soc_clock_period) > 0.001} {
    error "SoC generated clock does not match board profile"
}
if {abs([get_property PERIOD [get_clocks clk_pll_i]] - 12.0) > 0.001} {
    error "Unexpected DDR UI clock period"
}
report_clocks -file [file join $out vivado clocks.rpt]
opt_design
place_design
phys_opt_design
route_design
report_utilization -file [file join $out vivado utilization_routed.rpt]
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose \
    -file [file join $out vivado timing_routed.rpt]
report_bus_skew -file [file join $out vivado bus_skew.rpt]
set stream [open [file join $out vivado bus_skew.rpt] r]
set skew_report [read $stream]
close $stream
if {[string first "VIOLATED" $skew_report] >= 0} { error "Bundled-data bus skew failed" }
report_route_status -file [file join $out vivado route_status.rpt]
report_cdc -file [file join $out vivado cdc.rpt]
report_cdc -details -file [file join $out vivado cdc_details.rpt]
set stream [open [file join $out vivado cdc_details.rpt] r]
set cdc_report [read $stream]
close $stream
if {[regexp -line {^CDC-[0-9]+[ \t]+Critical[ \t]+[1-9]} $cdc_report]} {
    error "Critical CDC findings; inspect cdc_details.rpt"
}
report_drc -file [file join $out vivado drc_routed.rpt]
set errors [get_drc_violations -quiet -filter {SEVERITY == Error || SEVERITY == "Critical Warning"}]
if {[llength $errors]} { error "Implementation DRC failures: $errors" }
foreach type {max min} {
    set worst [get_timing_paths -delay_type $type -max_paths 1]
    if {![llength $worst]} { error "No $type timing paths reported" }
    if {[get_property SLACK $worst] < 0} { error "$type timing failed" }
}
write_checkpoint -force [file join $out vivado routed.dcp]
write_bitstream -force -bin_file [file join $out vivado j2_wukong_v1.bit]
if {[file size [file join $out vivado j2_wukong_v1.bin]] > $configuration_slot_bytes} {
    error "Configuration image exceeds its reserved 4 MiB slot"
}
set stream [open [file join $out vivado implementation.pass] w]
puts $stream "WUKONG_IMPLEMENTATION_PASS"
close $stream
exit
