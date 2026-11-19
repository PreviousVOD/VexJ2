# Wukong owns its IP, clock assumptions and CDC/BRAM qualification.
source [file join $::env(J2_FPGA_TOOLS) xilinx.tcl]

proc board_prepare {} {
    global root out board_dir
    source [file join $board_dir reset_ip.tcl]
    set ddr [file join $out ddr]
    file mkdir [file join $ddr ip]
    set xci [file join $ddr ip wukong_mig wukong_mig.xci]
    if {[file exists $xci]} {
        read_ip $xci
    } else {
        create_ip -name mig_7series -vendor xilinx.com -library ip -version 4.2 \
            -module_name wukong_mig -dir [file join $ddr ip]
    }
    set_property CONFIG.XML_INPUT_FILE [file join $board_dir mig.prj] [get_ips wukong_mig]
    set_property generate_synth_checkpoint false [get_files wukong_mig.xci]
    generate_target all [get_ips wukong_mig]
}

proc board_post_synth {} {
    global root out board_dir reports
    read_xdc [file join $board_dir clock_route.xdc]
    source [file join $board_dir constrain_bridge.tcl]
    set brams [get_cells -hier -filter {REF_NAME =~ RAMB*}]
    if {![llength $brams]} { error "No block RAM inferred" }
    foreach owner {soc/rom/ soc/sram/ soc/cpu/J2DecodePlugin_allocation_rom/} {
        set found 0
        foreach cell $brams {
            if {[string first $owner $cell] == 0} { incr found }
        }
        if {!$found} { error "No block RAM inferred for $owner" }
    }
    set f [open [file join $reports memories.txt] w]
    foreach cell $brams { puts $f "$cell [get_property REF_NAME $cell]" }
    close $f
}

proc board_pre_impl {} {
    global board_soc_clock_period
    # Verify generated clock configuration against the shared board profile.
    set soc_period [get_property PERIOD [get_clocks pll_CLKOUT0]]
    if {abs($soc_period - $board_soc_clock_period) > 0.001} {
        error "SoC generated clock does not match board profile"
    }
    if {abs([get_property PERIOD [get_clocks clk_pll_i]] - 12.0) > 0.001} {
        error "Unexpected DDR UI clock period"
    }
}

proc board_post_impl {} {
    global reports
    report_bus_skew -file [file join $reports bus_skew.rpt]
    set stream [open [file join $reports bus_skew.rpt] r]
    set skew_report [read $stream]
    close $stream
    if {[string first "VIOLATED" $skew_report] >= 0} { error "Bundled-data bus skew failed" }
    report_cdc -file [file join $reports cdc.rpt]
    report_cdc -details -file [file join $reports cdc_details.rpt]
    set stream [open [file join $reports cdc_details.rpt] r]
    set cdc_report [read $stream]
    close $stream
    if {[regexp -line {^CDC-[0-9]+[ \t]+Critical[ \t]+[1-9]} $cdc_report]} {
        error "Critical CDC findings; inspect cdc_details.rpt"
    }
}

fpga_run
