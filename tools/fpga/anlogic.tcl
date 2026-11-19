source [file join [file dirname [info script]] common.tcl]
proc fpga_run {} {
    global action work reports top project_file pins_file timing_file jtag_cable
    if {$action eq "program"} {
        set marker [file join [pwd] program.pass]
        cd $work
        open_project $project_file
        download -bit $::env(J2_FPGA_BITSTREAM) -mode jtag -spd 4 -sec 64 -cable $jtag_cable
        fpga_pass $marker "FPGA_PROGRAM_PASS"
        return
    }
    if {$action ne "build"} { error "Anlogic expects build or program" }
    cd $work
    open_project $project_file
    fpga_hook board_prepare
    elaborate -top $top
    read_adc $pins_file
    read_sdc $timing_file
    optimize_rtl
    map_macro
    map
    fpga_hook board_post_synth
    pack
    place
    route
    report_area -io_info -file [file join $reports ${top}_area.txt]
    set timing_report [file join $reports ${top}_timing.txt]
    report_timing -file $timing_report
    set stream [open $timing_report r]
    set timing [read $stream]
    close $stream
    set summaries [regexp -all -inline {([0-9]+) errors detected} $timing]
    if {![llength $summaries]} { error "No timing summary in $timing_report" }
    foreach {summary errors} $summaries {
        if {$errors != 0} { error "Timing reported $errors errors; refusing bitstream generation" }
    }
    fpga_hook board_post_impl
    bitgen -bit ${top}.bit -version 0X0000 -svf ${top}.svf -svf_comment_on \
        -g ucode:00000000000000000000000000000000
    fpga_pass [file join $work implementation.pass] "FPGA_IMPLEMENTATION_PASS"
}
