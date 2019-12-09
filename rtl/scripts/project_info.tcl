source -quiet ../scripts/common.tcl

set project_name [readfile ../_PROJECT_NAME]
set TOP [readfile ../_PROJECT_TOP]
set FPGA_PART [readfile ../_FPGA_PART]

puts $project_name
puts $TOP
puts $FPGA_PART