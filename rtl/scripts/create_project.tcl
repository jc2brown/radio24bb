source -quiet ../scripts/common.tcl

if {$::argc != 6} {
	puts "Usage: xsct $::argv0 project_name top fpga_part hdl_path xdc_path tb_path"
	exit 1
}

set PROJECT_NAME [lindex $::argv 0]
set TOP [lindex $::argv 1]
set FPGA_PART [lindex $::argv 2]

set hdl_path [lindex $::argv 3]
set xdc_path [lindex $::argv 4]
set tb_path [lindex $::argv 5]

create_project -f -part $FPGA_PART $PROJECT_NAME

set hdl_file_list 	[ add_prefix $hdl_path/ [exec ls $hdl_path/*.sv] ]
set xdc_file_list 	[ add_prefix $xdc_path/ [exec ls $xdc_path/*.xdc] ]
set tb_file_list  	[ add_prefix $tb_path/  [exec ls $tb_path/*.sv] ]

puts_list $hdl_file_list
puts_list $xdc_file_list
puts_list $tb_file_list

set_property report_strategy {No Reports} [get_runs synth_1]
set_property report_strategy {Timing Closure Reports} [get_runs impl_1]

set_param project.defaultIPCacheSetting [ file normalize ../ip_cache ]
config_ip_cache -use_cache_location [ file normalize ../ip_cache ]

set_param general.maxThreads 8
set_property target_language Verilog [current_project]

add_files -fileset sources_1 $hdl_file_list
add_files -fileset constrs_1 $xdc_file_list
add_files -fileset sim_1 	 $tb_file_list


# set_property include_dirs $include_path_list [current_fileset]

# set_property file_type "SystemVerilog"  [ get_files $rtl_fpga_file_list_sv ]
# set_property file_type "Verilog Header" [ get_files $headers_file_list ]
# set_property is_global_include true     [ get_files $headers_file_list ]

set_property top ${TOP} [current_fileset]

# update_compile_order -fileset sources_1
# update_compile_order -fileset sim_1

exit
