# Timing-only experiment on the existing synthesized netlist. No bitstream is
# generated: UART/timer/SPI divisors still belong to the source build.
# Prefer: bash tools/check_wukong_fmax.sh DIVIDER [ROUTED_SEED_DIVIDER]
set root [file normalize [file join [file dirname [info script]] ..]]
if {[llength $argv] < 1 || [llength $argv] > 2} { error "Expected output divider and optional routed seed divider" }
set divider [lindex $argv 0]
if {![string is double -strict $divider] || $divider < 4 || $divider > 128} {
    error "Divider must be numeric from 4 to 128"
}
set seed [lindex $argv 1]
set label div$divider
set checkpoint [file join $root build wukong-v1 vivado synthesized.dcp]
if {[info exists ::env(WUKONG_FMAX_CHECKPOINT)]} { set checkpoint $::env(WUKONG_FMAX_CHECKPOINT) }
if {$seed ne ""} {
    if {![string is double -strict $seed] || $seed < 4 || $seed > 128} { error "Invalid routed seed divider" }
    set label div${divider}-from${seed}
    set checkpoint [file join $root build wukong-v1 fmax div$seed routed.dcp]
}
set out [file join $root build wukong-v1 fmax $label]
file mkdir $out
file delete -force [file join $out results.tsv]
open_checkpoint $checkpoint
set cell [get_cells pll]
set primitive [get_property REF_NAME $cell]
if {[string match MMCME2* $primitive]} {
    set multiplier [get_property CLKFBOUT_MULT_F $cell]
    set divider_property CLKOUT0_DIVIDE_F
    if {abs($divider * 8 - round($divider * 8)) > 0.000001} { error "MMCM divider must use 0.125 steps" }
} elseif {[string match PLLE2* $primitive]} {
    set multiplier [get_property CLKFBOUT_MULT $cell]
    set divider_property CLKOUT0_DIVIDE
    if {$divider != int($divider)} { error "PLL divider must be integral" }
} else { error "Unsupported SoC clock primitive: $primitive" }
set input_period [get_property CLKIN1_PERIOD $cell]
set expected_period [expr {$input_period * [get_property DIVCLK_DIVIDE $cell] * $divider / $multiplier}]
set_property $divider_property $divider $cell
update_timing
set period [get_property PERIOD [get_clocks pll_CLKOUT0]]
if {abs($period - $expected_period) > 0.001} { error "SoC clock did not update" }
if {abs([get_property PERIOD [get_clocks clk_pll_i]] - 12.0) > 0.001} {
    error "DDR UI frequency changed"
}
# Match the bundled response payload bound to its new receiving period.
source [file join $root fpga wukong-v1 bridge_paths.tcl]
set bridge_root [wukong_bridge_root]
set source_regs [get_cells -hier -filter "NAME =~ $bridge_root/responses/pushArea_data*_reg*"]
set target_regs [get_cells -hier -filter "NAME =~ $bridge_root/responses/popArea_stream_rData*_reg*"]
if {![llength $source_regs] || ![llength $target_regs]} { error "Missing response mailbox" }
set_max_delay -datapath_only $period -from $source_regs -to $target_regs
set_bus_skew $period -from $source_regs -to $target_regs
if {$seed eq ""} {
    opt_design
    place_design
    phys_opt_design
    route_design
}
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file [file join $out timing.rpt]
report_timing -from [get_clocks pll_CLKOUT0] -to [get_clocks pll_CLKOUT0] -max_paths 20 -nworst 1 \
    -delay_type max -path_type full_clock_expanded -file [file join $out soc_paths.rpt]
report_bus_skew -file [file join $out bus_skew.rpt]
report_cdc -details -file [file join $out cdc.rpt]
report_drc -file [file join $out drc.rpt]
report_route_status -file [file join $out route.rpt]
set soc [get_timing_paths -from [get_clocks pll_CLKOUT0] -to [get_clocks pll_CLKOUT0] -delay_type max -max_paths 1]
set worst [get_timing_paths -delay_type max -max_paths 1]
set hold [get_timing_paths -delay_type min -max_paths 1]
set drc [get_drc_violations -quiet -filter {SEVERITY == Error || SEVERITY == "Critical Warning"}]
proc read_text {path} { set f [open $path r]; set value [read $f]; close $f; return $value }
set met [expr {[string first "All user specified timing constraints are met." [read_text [file join $out timing.rpt]]] >= 0}]
set skew_ok [expr {[string first "VIOLATED" [read_text [file join $out bus_skew.rpt]]] < 0}]
set cdc_ok [expr {![regexp -line {^CDC-[0-9]+[ \t]+Critical[ \t]+[1-9]} [read_text [file join $out cdc.rpt]]]}]
set passed [expr {$met && $skew_ok && $cdc_ok && ![llength $drc]}]
set f [open [file join $out results.tsv] w]
puts $f "divider\tmhz\tperiod_ns\tsoc_setup_ns\tglobal_setup_ns\tglobal_hold_ns\tpassed\tstart\tend"
puts $f "$divider\t[expr {1000.0/$period}]\t$period\t[get_property SLACK $soc]\t[get_property SLACK $worst]\t[get_property SLACK $hold]\t$passed\t[get_property STARTPOINT_PIN $soc]\t[get_property ENDPOINT_PIN $soc]"
close $f
write_checkpoint -force [file join $out routed.dcp]
puts "WUKONG_FMAX_RESULT: divider=$divider MHz=[expr {1000.0/$period}] soc_slack=[get_property SLACK $soc] passed=$passed"
exit
