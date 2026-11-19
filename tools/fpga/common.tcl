# The board entry point sources a vendor flow, then calls fpga_run.
source $::env(J2_FPGA_CONFIG)
set action $::env(J2_FPGA_ACTION)
proc fpga_hook {name} {
    if {[llength [info procs $name]]} { uplevel #0 $name }
}
proc fpga_pass {path message} {
    set stream [open $path w]
    puts $stream $message
    close $stream
}
