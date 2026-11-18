# Volatile JTAG configuration only. This script never programs SPI flash.
if {$argc != 1} { error "usage: program_wukong.tcl /absolute/path/to/validated.bit" }
set bitstream [file normalize [lindex $argv 0]]
if {![file isfile $bitstream]} { error "missing bitstream: $bitstream" }
open_hw_manager
connect_hw_server
set targets [get_hw_targets]
if {[llength $targets] != 1} { error "expected exactly one JTAG cable, found $targets" }
current_hw_target [lindex $targets 0]
open_hw_target
set devices [get_hw_devices -filter {PART =~ xc7a100t*}]
if {[llength $devices] != 1} { error "expected exactly one XC7A100T, found $devices" }
set device [lindex $devices 0]
current_hw_device $device
set_property PROGRAM.FILE $bitstream $device
program_hw_devices $device
refresh_hw_device $device
close_hw_manager
set stream [open program.pass w]
puts $stream "WUKONG_PROGRAM_PASS"
close $stream
exit
