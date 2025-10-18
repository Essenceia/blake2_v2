set project_dir [lindex $argv 0]
set project_name [lindex $argv 1]

puts "Creating project $project_name at path [pwd]/$project_dir"
create_project -part xc7a35ticpg236-1L -force $project_name $project_dir

close_project
exit 0
