

proc sim {top {wcfg ""}} {
	if { [catch {save_wave_config $wcfg}] } {
		puts "Error saving WCFG or no open WCFG"
	}

	if { [catch {close_sim}] } {
		puts "Error closing sim or no open sim"
	}

	set_property top $top [get_filesets sim_1]
	set_property top_lib xil_defaultlib [get_filesets sim_1]
	set_property -name {xsim.simulate.runtime} -value {1us} -objects [get_filesets sim_1]
	set_property xsim.view $wcfg [get_filesets sim_1]
	launch_simulation
	# open_wave_config $wcfg
	# restart 
	# run 100 us
}


proc sim_siggen {} {
	sim tb_siggen ./siggen_behav.wcfg
}


proc sim_ft601_if {} {
	sim tb_ft601_if {./tb_ft601_if.wcfg}
}


proc sim_top {} {
	sim tb_r24bb ./r24bb_top.wcfg
}


# proc sim_siggen {} {
# 	catch {
# 		save_wave_config {/home/chris.brown/radio24bb/siggen_behav.wcfg}
# 		close_sim
# 	}
# 	set_property top tb_siggen [get_filesets sim_1]
# 	set_property top_lib xil_defaultlib [get_filesets sim_1]
# 	#set_property xsim.view {./siggen_behav.wcfg} [get_filesets sim_1]
# 	set_property -name {xsim.simulate.runtime} -value {1us} -objects [get_filesets sim_1]
# 	launch_simulation
# 	open_wave_config {./siggen_behav.wcfg}
# 	restart 
# 	run 100 us
# }







