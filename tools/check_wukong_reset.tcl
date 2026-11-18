set root [file normalize [file join [file dirname [info script]] ..]]
set out [file join $root build wukong-v1]
source [file join $out board.tcl]
create_project -force reset_check [file join $out reset_project] -part $board_part
set_property target_language Verilog [current_project]
read_ip [file join $out ip wukong_reset wukong_reset.xci]
add_files -fileset sim_1 [file join $root fpga wukong-v1 reset_tb.sv]
set_property top wukong_reset_tb [get_filesets sim_1]
set_property xsim.simulate.runtime all [get_filesets sim_1]
launch_simulation -simset sim_1 -mode behavioral
close_sim
set text ""
foreach file [glob [file join $out reset_project reset_check.sim sim_1 behav xsim *.log]] {
    set stream [open $file r]
    append text [read $stream]
    close $stream
}
if {[string first "WUKONG_RESET_PASS:" $text] < 0} { error "Vendor reset simulation did not pass" }
set stream [open [file join $out reset_sim validation.pass] w]
puts $stream "WUKONG_RESET_PASS"
close $stream
exit
