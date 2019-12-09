source ../scripts/common.tcl
# source ../scripts/project_info.tcl

if {$::argc != 1} {
	puts "Usage: xsct $::argv0 project_name"
	exit 1
}

set PROJECT_NAME [lindex $::argv 0]

open_project $PROJECT_NAME.xpr
reset_run synth_1
launch_runs synth_1
wait_on_run synth_1
exit
