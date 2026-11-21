# Resolve the output actually driving the SoC BUFG. Generated clock names follow
# nets, not output numbers; production uses CLKOUT0, the shared-MMCM study used 2.
proc wukong_soc_clock_pin {} {
    set net [get_nets -of_objects [get_pins clockBuffer/I]]
    set pins [get_pins -of_objects $net -filter {DIRECTION == OUT && REF_PIN_NAME =~ CLKOUT*}]
    if {[llength $pins] != 1} { error "Expected one SoC clock generator output, got $pins" }
    return [lindex $pins 0]
}
proc wukong_soc_clock {} {
    set clocks [get_clocks -of_objects [wukong_soc_clock_pin]]
    if {[llength $clocks] != 1} { error "Expected one SoC generated clock, got $clocks" }
    return [lindex $clocks 0]
}
