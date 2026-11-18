# Only three slow, sticky status signals cross from MIG UI to UART clock.
# Cut the D input of their first synchronizer stage; keep stage-to-stage and
# reset recovery/removal timed. Do not cut the MIG native/PHY clock paths.
set status_syncs [get_cells {init_calib_complete_buffercc/buffers_0_reg io_done_buffercc/buffers_0_reg io_failed_buffercc/buffers_0_reg}]
set_false_path -to [get_pins -of_objects $status_syncs -filter {REF_PIN_NAME == D}]
