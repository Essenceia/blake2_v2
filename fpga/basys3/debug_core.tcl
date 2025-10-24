opt_design 
place_design
route_design 
write_bitstream -force emulator/debug_core.bit
write_debug_probes -force emulator/debug_core.ltx
report_debug_core
