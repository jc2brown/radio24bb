source -quiet ../scripts/common.tcl
# source -quiet ../scripts/project_info.tcl

if {$::argc != 2} {
	puts "Usage: xsct $::argv0 project_name top"
	exit 1
}

set PROJECT_NAME [lindex $::argv 0]
set TOP [lindex $::argv 1]

open_project $PROJECT_NAME.xpr
open_run impl_1
exec mkdir -p ../out/
write_bitstream -force ../out/$TOP.bit
write_hwdef -force ../out/$TOP.hdf
exit
