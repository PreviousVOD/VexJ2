source [file join [file dirname [info script]] common.tcl]
proc fpga_drc {} {
    set errors [get_drc_violations -quiet -filter {SEVERITY == Error || SEVERITY == "Critical Warning"}]
    if {[llength $errors]} { error "DRC failures: $errors" }
}
proc fpga_synth {} {
    global work rtl top source_files board_part pins_file reports
    create_project -in_memory -part $board_part
    set_property target_language Verilog [current_project]
    fpga_hook board_prepare
    foreach source $source_files { read_verilog [file join $rtl $source] }
    cd $rtl
    uplevel #0 [list read_xdc $pins_file]
    # Vivado re-evaluates XDC during synthesis in the calling Tcl scope.
    uplevel #0 [list synth_design -top $top -part $board_part]
    fpga_hook board_post_synth
    set blackboxes [get_cells -quiet -hier -filter {IS_BLACKBOX == 1}]
    if {[llength $blackboxes]} { error "Unresolved black boxes: $blackboxes" }
    foreach port [get_ports *] {
        if {[get_property PACKAGE_PIN $port] eq ""} { error "Unconstrained pin: $port" }
    }
    report_utilization -hierarchical -file [file join $reports utilization.rpt]
    report_timing_summary -file [file join $reports timing_synth.rpt]
    report_drc -file [file join $reports drc_synth.rpt]
    fpga_drc
    write_checkpoint -force [file join $work synthesized.dcp]
    fpga_pass [file join $work synthesis.pass] "FPGA_SYNTH_PASS"
}
proc fpga_implement {} {
    global action work reports top configuration_slot_bytes
    if {$action ne "build"} { uplevel #0 [list open_checkpoint [file join $work synthesized.dcp]] }
    fpga_hook board_pre_impl
    report_clocks -file [file join $reports clocks.rpt]
    opt_design
    place_design
    phys_opt_design
    route_design
    report_utilization -file [file join $reports utilization_routed.rpt]
    report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose \
        -file [file join $reports timing_routed.rpt]
    report_route_status -file [file join $reports route_status.rpt]
    report_drc -file [file join $reports drc_routed.rpt]
    fpga_drc
    foreach type {max min} {
        set worst [get_timing_paths -delay_type $type -max_paths 1]
        if {![llength $worst]} { error "No $type timing paths reported" }
        if {[get_property SLACK $worst] < 0} { error "$type timing failed" }
    }
    fpga_hook board_post_impl
    write_checkpoint -force [file join $work routed.dcp]
    write_bitstream -force -bin_file [file join $work ${top}.bit]
    if {$configuration_slot_bytes > 0 && [file size [file join $work ${top}.bin]] > $configuration_slot_bytes} {
        error "Configuration image exceeds its reserved slot"
    }
    fpga_pass [file join $work implementation.pass] "FPGA_IMPLEMENTATION_PASS"
}
proc fpga_program {} {
    global jtag_part
    set marker [file join [pwd] program.pass]
    open_hw_manager
    connect_hw_server
    set targets [get_hw_targets]
    if {[llength $targets] != 1} { error "Expected exactly one JTAG cable, found $targets" }
    current_hw_target [lindex $targets 0]
    open_hw_target
    set devices [get_hw_devices -filter "PART =~ $jtag_part"]
    if {[llength $devices] != 1} { error "Expected exactly one matching device, found $devices" }
    set device [lindex $devices 0]
    current_hw_device $device
    set_property PROGRAM.FILE $::env(J2_FPGA_BITSTREAM) $device
    program_hw_devices $device
    refresh_hw_device $device
    close_hw_manager
    fpga_pass $marker "FPGA_PROGRAM_PASS"
}
proc fpga_run {} {
    global action
    switch -- $action {
        synth { fpga_synth }
        implement { fpga_implement }
        build { fpga_synth; fpga_implement }
        program { fpga_program }
        default { error "Unknown FPGA action: $action" }
    }
    exit
}
