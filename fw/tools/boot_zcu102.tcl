file delete boot_psu_cortexa53_0.done

if {$::argc != 2} {
	puts "Usage: xsct $::argv0 elf_image psu_init"
	exit 1
}
set psuinit [lindex $::argv 1]

# load def's
source $::env(XILINX_SDK_ROOT)/scripts/sdk/util/zynqmp_utils.tcl

# select A53 core 0, reset, and download elf binary, start (con)
connect
targets -set -nocase -filter {name =~"*A53*0" && jtag_cable_name =~ "Digilent JTAG-SMT2NC*"} -index 1
rst -processor


# ZCU102 boards with S/N >= 0432055-05 cannot use the psu_init.tcl script due to a DIMM change. 
# Instead, these boards must be initialized by downloading a FSBL before the main A53 program.
# This new procedure is backward-compatible with older boards.
# See https://www.xilinx.com/support/answers/72210.html
#
# Additionally, the FSBL included with SDK 2018.3 must be patched to prevent an ocassional crash during init.
# This patch has been applied to the fsbl.elf used here.
# See https://www.xilinx.com/support/answers/72113.html

dow fsbl.elf
con
after 5000
stop


# Download main program to A53
after 50
dow [lindex $::argv 0]
con

open boot_psu_cortexa53_0.done w+
