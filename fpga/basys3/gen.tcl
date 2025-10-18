set checkpoint_path [lindex $argv 0]
set out_dir [lindex $argv 1]
puts "SVF generation script called with checkpoint path $checkpoint_path, generating to $out_dir"

open_checkpoint $checkpoint_path 

# defines 
set hw_target "alibaba_board_svf_target"
set fpga_device "xcku3p"
set bin_path "$out_dir/[current_project]"

write_bitstream "$bin_path.bit" -force

open_hw_manager 

# connect to hw server with default config
connect_hw_server
puts "connected to hw server at [current_hw_server]"

create_hw_target $hw_target
puts "current hw target [current_hw_target]"

open_hw_target

# single device on scan chain
create_hw_device -part $fpga_device 
puts "scan chain : [get_hw_devices]"

set_property PROGRAM.FILE "$bin_path.bit" [get_hw_device]

#select device to program 
program_hw_device [get_hw_device]

# generate svf file 
write_hw_svf -force "$bin_path.svf"

close_hw_manager
exit 0 
