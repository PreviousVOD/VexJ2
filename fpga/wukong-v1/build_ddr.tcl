set root [file normalize [file join [file dirname [info script]] .. ..]]
set out [file join $root build wukong-v1 ddr]
file delete -force [file join $out implementation.pass]
if {$argc == 1 && [lindex $argv 0] eq "resume"} {
    open_checkpoint [file join $out synthesized.dcp]
} else {
    create_project -in_memory -part xc7a100tfgg676-2
    read_ip [file join $out ip wukong_mig wukong_mig.xci]
    # The platform and DDR diagnostic share the same proc_sys_reset parameters.
    set saved_out $out
    set out [file join $root build wukong-v1]
    source [file join $root fpga wukong-v1 reset_ip.tcl]
    set out $saved_out
    read_verilog [file join $out rtl j2_wukong_ddr_test.v]
    read_xdc [file join $root fpga wukong-v1 ddr_test.xdc]
    synth_design -top j2_wukong_ddr_test -part xc7a100tfgg676-2
    read_xdc [file join $root fpga wukong-v1 clock_route.xdc]
    if {[llength [get_cells -quiet -hier -filter {IS_BLACKBOX == 1}]]} { error "Unresolved DDR black boxes" }
    foreach port [get_ports *] {
        if {[get_property PACKAGE_PIN $port] eq ""} { error "Unconstrained DDR pin: $port" }
    }
    write_checkpoint -force [file join $out synthesized.dcp]
}
set status_syncs [get_cells {init_calib_complete_buffercc/buffers_0_reg io_done_buffercc/buffers_0_reg io_failed_buffercc/buffers_0_reg}]
if {[llength $status_syncs] != 3} { error "Expected three DDR status synchronizers, got $status_syncs" }
read_xdc [file join $root fpga wukong-v1 ddr_cdc.xdc]
opt_design
place_design
phys_opt_design
route_design
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -file [file join $out timing.rpt]
report_utilization -file [file join $out utilization.rpt]
report_cdc -file [file join $out cdc.rpt]
report_drc -file [file join $out drc.rpt]
if {[llength [get_drc_violations -quiet -filter {SEVERITY == Error || SEVERITY == "Critical Warning"}]]} { error "DDR DRC failed" }
foreach type {max min} {
    set path [get_timing_paths -delay_type $type -max_paths 1]
    if {![llength $path] || [get_property SLACK $path] < 0} { error "DDR $type timing failed" }
}
write_checkpoint -force [file join $out routed.dcp]
write_bitstream -force [file join $out j2_wukong_ddr_test.bit]
set stream [open [file join $out implementation.pass] w]
puts $stream "WUKONG_DDR_IMPLEMENTATION_PASS"
close $stream
exit
