source -quiet ../scripts/common.tcl
# source -quiet ../scripts/project_info.tcl

if {$::argc != 1} {
	puts "Usage: xsct $::argv0 project_name"
	exit 1
}

set PROJECT_NAME [lindex $::argv 0]

open_project $PROJECT_NAME.xpr
reset_run impl_1
# add_files {../../xdc/maple_top_location_io.xdc}
launch_runs impl_1
wait_on_run impl_1
exit
