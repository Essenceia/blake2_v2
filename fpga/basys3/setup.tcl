set project_dir [lindex $argv 0]
set project_name [lindex $argv 1]
set utils_path [lindex $argv 2]
set src_path [lindex $argv 3]

puts "Creating project $project_name at path [pwd]/$project_dir"
create_project -part xc7a35ticpg236-1L -force $project_name $project_dir

# load src
read_verilog [glob *.v]
read_verilog [glob -directory $src_path *.v]
read_verilog [glob -directory $utils_path *.v]
read_xdc [glob *.xdc]

close_project
exit 0
