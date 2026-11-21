# Regenerate vendor IP from parameters; generated HDL/XCI stay under build/.
file mkdir [file join $out ip]
set ip_file [file join $out ip wukong_reset wukong_reset.xci]
if {[file exists $ip_file]} {
    read_ip $ip_file
} else {
    create_ip -name proc_sys_reset -vendor xilinx.com -library ip -version 5.0 \
        -module_name wukong_reset -dir [file join $out ip]
}
# DDR readiness already has asynchronous assertion and two-cycle synchronous
# release. Do not discard that minimum-width request with an auxiliary filter.
set_property -dict [list CONFIG.C_EXT_RESET_HIGH {1} CONFIG.C_AUX_RESET_HIGH {1} \
    CONFIG.C_EXT_RST_WIDTH {4} CONFIG.C_AUX_RST_WIDTH {1} \
    CONFIG.C_NUM_BUS_RST {1} CONFIG.C_NUM_PERP_RST {1} \
    CONFIG.C_NUM_INTERCONNECT_ARESETN {1} CONFIG.C_NUM_PERP_ARESETN {1}] [get_ips wukong_reset]
set_property generate_synth_checkpoint false [get_files $ip_file]
generate_target all [get_ips wukong_reset]
