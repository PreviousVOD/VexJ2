# Native AHB places CDC mailboxes directly under bridge. Accept the former
# wrapped hierarchy too so historical Fmax checkpoints remain usable. Resolve
# exactly one backend; never silently widen CDC exceptions to unrelated logic.
proc wukong_bridge_root {} {
    set matches {}
    foreach candidate {bridge bridge/bridge} {
        set registers [get_cells -quiet -hier -filter "NAME =~ $candidate/requests/pushArea_data*_reg*"]
        if {[llength $registers]} { lappend matches $candidate }
    }
    if {[llength $matches] != 1} {
        error "Expected exactly one Wukong DDR mailbox backend, found: $matches"
    }
    return [lindex $matches 0]
}
