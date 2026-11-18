# Regenerate MIG for the physical DDR3L device and board pinout.
set root [file normalize [file join [file dirname [info script]] ..]]
set out [file join $root build wukong-v1 ddr]
file mkdir $out
file delete -force [file join $out generation.pass]
create_project -force mig_generation [file join $out project] -part xc7a100tfgg676-2
set_property target_language Verilog [current_project]
file mkdir [file join $out ip]
set xci [file join $out ip wukong_mig wukong_mig.xci]
if {[file exists $xci]} {
    read_ip $xci
} else {
    create_ip -name mig_7series -vendor xilinx.com -library ip -version 4.2 \
        -module_name wukong_mig -dir [file join $out ip]
}
set_property CONFIG.XML_INPUT_FILE [file join $root fpga wukong-v1 mig.prj] [get_ips wukong_mig]
set_property generate_synth_checkpoint false [get_files wukong_mig.xci]
generate_target all [get_ips wukong_mig]
set stream [open [file join $out generation.pass] w]
puts $stream "WUKONG_MIG_GENERATION_PASS"
close $stream
exit
