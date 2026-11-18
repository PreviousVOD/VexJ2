# Run from build/wukong-v1/vivado, keeping all generated files outside sources.
set root [file normalize [file join [file dirname [info script]] ..]]
set out [file join $root build wukong-v1]
source [file join $out board.tcl]
create_project -in_memory -part $board_part
set_property target_language Verilog [current_project]
source [file join $root tools wukong_ip.tcl]
read_verilog [file join $out rtl j2_wukong_v1.v]
# Spinal emits readmemb paths relative to the RTL working directory.
cd [file join $out rtl]
read_xdc [file join $root fpga wukong-v1 pins.xdc]
synth_design -top j2_wukong_v1 -part $board_part
read_xdc [file join $root fpga wukong-v1 clock_route.xdc]
write_checkpoint -force [file join $out vivado synthesized.dcp]
report_utilization -hierarchical -file [file join $out vivado utilization.rpt]
report_timing_summary -file [file join $out vivado timing_synth.rpt]
report_drc -file [file join $out vivado drc_synth.rpt]
set blackboxes [get_cells -quiet -hier -filter {IS_BLACKBOX == 1}]
if {[llength $blackboxes]} { error "Unresolved black boxes: $blackboxes" }
foreach port [get_ports *] {
    if {[get_property PACKAGE_PIN $port] eq ""} { error "Unconstrained pin: $port" }
}
set errors [get_drc_violations -quiet -filter {SEVERITY == Error || SEVERITY == "Critical Warning"}]
if {[llength $errors]} { error "Synthesis DRC errors: $errors" }
set brams [get_cells -hier -filter {REF_NAME =~ RAMB*}]
if {![llength $brams]} { error "No block RAM inferred" }
foreach owner {soc/rom/ soc/sram/ soc/cpu/J2DecodePlugin_allocation_rom/} {
    set found 0
    foreach cell $brams {
        if {[string first $owner $cell] == 0} { incr found }
    }
    if {!$found} { error "No block RAM inferred for $owner" }
}
set f [open [file join $out vivado memories.txt] w]
foreach cell $brams { puts $f "$cell [get_property REF_NAME $cell]" }
close $f
puts "WUKONG_SYNTH_PASS: [llength $brams] block RAM primitives; no black boxes"
set f [open [file join $out vivado synthesis.pass] w]
puts $f "WUKONG_SYNTH_PASS"
close $f
exit
