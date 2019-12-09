if {$::argc != 3} {
	puts "Usage: xsct $::argv0 bitstream ps7_init init_stamp"
	exit 1
}

if {![info exists ::env(XILINX_SDK_ROOT)]} {
	puts "Please set XILINX_SDK_ROOT in your environment!"
	exit 1
}




set bitstream [lindex $::argv 0]
set ps7init [lindex $::argv 1]
set init_stamp [lindex $::argv 2]


puts "bitstream: $bitstream"
puts "ps7init $ps7init"
puts "init_stamp $init_stamp"

file delete $init_stamp



# connect to dbg
connect

# load def's
source $::env(XILINX_SDK_ROOT)/scripts/sdk/util/zynqutils.tcl
source $ps7init

# set target to A9 cores and reset
after 1000
# select A9 core 0
targets -set -nocase -filter {name =~"*A9*0" && jtag_cable_name =~ "Digilent JTAG-HS3*"} -index 0
rst

# select PL and load Zopaz FPGA image
targets -set -nocase -filter {name =~"xc7z020" && jtag_cable_name =~ "Digilent JTAG-HS3*"}
fpga $bitstream

# initialize psu
# APU's should be in 'Reset Catch' state
# - using force-mem-access state (no access protection)
# - run mem wr seq for: mio, pll, clock_init, ddr_init
# - start ddr phy
# - run mem wr seq for: peripherals, resetin
# - start serdes (empty)
# - run mem wr seq for: peripherals (power down), afi
# select PS-APU subsystem (nominal target 8)
#targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-SMT2NC*"} -index 1
targets -set -nocase -filter {name =~"*A9*0" && jtag_cable_name =~ "Digilent JTAG-HS3*"} -index 0
ps7_init
after 1000

# fabric reset using EMIO
# psu_ps_pl_isolation_removal
# after 1000
# psu_ps_pl_reset_config




open $init_stamp w+