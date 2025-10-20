set project_path [lindex $argv 0]
set checkpoint_path [lindex $argv 1]
puts "Implementation script called with project path $project_path, generating checkpoint at $checkpoint_path"

open_project $project_path 

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
