source -quiet ../scripts/common.tcl
# source -quiet ../scripts/project_info.tcl

if {$::argc != 2} {
	puts "Usage: xsct $::argv0 project_name bd_script"
	exit 1
}

set PROJECT_NAME [lindex $::argv 0]
set BD_SCRIPT [lindex $::argv 1]

open_project $PROJECT_NAME.xpr
source $BD_SCRIPT
validate_bd_design
generate_target all [get_files *.bd]
save_bd_design
