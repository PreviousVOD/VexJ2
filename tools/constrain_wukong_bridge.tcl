# Toggle mailboxes hold source data until destination capture is acknowledged.
# Bound bundled-data paths to one receiving clock period, which is shorter than
# the two-stage synchronized toggle latency; leave destination logic timed.
foreach {channel period} {requests 12.000 responses 31.250} {
    set source_regs [get_cells -hier -filter "NAME =~ bridge/$channel/pushArea_data*_reg*"]
    set target_regs [get_cells -hier -filter "NAME =~ bridge/$channel/popArea_stream_rData*_reg*"]
    if {![llength $source_regs] || ![llength $target_regs]} {
        error "Missing $channel bundled-data registers"
    }
    set_max_delay -datapath_only $period -from $source_regs -to $target_regs
    set_bus_skew $period -from $source_regs -to $target_regs
    set sync_regs [get_cells -hier -filter "NAME =~ bridge/$channel/*_buffercc/buffers_0_reg"]
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
