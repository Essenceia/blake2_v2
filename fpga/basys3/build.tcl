set project_path [lindex $argv 0]
set utils_path [lindex $argv 1]
set src_path [lindex $argv 2]
set checkpoint_path [lindex $argv 3]
puts "Implementation script called with project path $project_path and src path $src_path, generating checkpoint at $checkpoint_path"

open_project $project_path 

# load src
read_verilog [glob *.v]
read_verilog [glob -directory $src_path *.v]
read_verilog [glob -directory $utils_path *.v]
read_xdc [glob *.xdc]


# synth
synth_design -top emulator

# implement
opt_design
place_design
route_design
phys_opt_design

write_checkpoint $checkpoint_path -force 
close_project
exit 0
