

if {$::argc != 3} {
	puts "Usage: xsct $::argv0 elf_image ps7init boot_stamp"
	exit 1
}


set elf_image [lindex $::argv 0]
set ps7init [lindex $::argv 1]
set boot_stamp [lindex $::argv 2]



puts "elf_image: $elf_image"
puts "ps7init $ps7init"
puts "boot_stamp $boot_stamp"


file delete $boot_stamp


source $ps7init
source $::env(XILINX_SDK_ROOT)/scripts/sdk/util/zynqutils.tcl

connect
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS3*"} -index 0
# loadhw -hw D:/Projects/Baseband/radio24bb_bak/radio24bb.sdk/r24bb_top_hw_platform_0/system.hdf -mem-ranges [list {0x40000000 0xbfffffff}]


configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*" && jtag_cable_name =~ "Digilent JTAG-HS3*"} -index 0
stop



ps7_init
ps7_post_config



targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent JTAG-HS3*"} -index 0
rst -processor

targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent JTAG-HS3*"} -index 0
dow [lindex $::argv 0]



configparams force-mem-access 0

targets -set -nocase -filter {name =~ "ARM*#0" && jtag_cable_name =~ "Digilent JTAG-HS3*"} -index 0
con



open $boot_stamp w+







