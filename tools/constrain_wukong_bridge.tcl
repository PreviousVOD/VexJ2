# Toggle mailboxes hold source data until destination capture is acknowledged.
# Bound bundled-data paths to one receiving clock period, which is shorter than
# the two-stage synchronized toggle latency; leave destination logic timed.
source [file join [file dirname [info script]] wukong_bridge_paths.tcl]
set bridge_root [wukong_bridge_root]
foreach {channel clock_name} {requests clk_pll_i responses pll_CLKOUT0} {
    set clock [get_clocks $clock_name]
    if {[llength $clock] != 1} { error "Expected one receiving clock: $clock_name" }
    set period [get_property PERIOD $clock]
    set source_regs [get_cells -hier -filter "NAME =~ $bridge_root/$channel/pushArea_data*_reg*"]
    set target_regs [get_cells -hier -filter "NAME =~ $bridge_root/$channel/popArea_stream_rData*_reg*"]
    if {![llength $source_regs] || ![llength $target_regs]} {
        error "Missing $channel bundled-data registers"
    }
    set_max_delay -datapath_only $period -from $source_regs -to $target_regs
    set_bus_skew $period -from $source_regs -to $target_regs
    set sync_regs [get_cells -hier -filter "NAME =~ $bridge_root/$channel/*_buffercc/buffers_0_reg"]
    if {[llength $sync_regs] != 2} { error "Expected two $channel toggle synchronizers, got $sync_regs" }
    set_false_path -to [get_pins -of_objects $sync_regs -filter {REF_PIN_NAME == D}]
}

# Asynchronous assertion/synchronous release chains: only the asynchronous
# preset pins are excepted. D/Q paths and reset release into logic stay timed.
foreach name {ddrNotReady bridgeResetRequest} {
    set sync_regs [get_cells -hier -filter "NAME =~ ${name}_asyncAssertSyncDeassert_buffercc/buffers_*_reg"]
    if {[llength $sync_regs] != 2} { error "Expected two $name reset synchronizer stages, got $sync_regs" }
    set_false_path -to [get_pins -of_objects $sync_regs -filter {REF_PIN_NAME == PRE}]
}
