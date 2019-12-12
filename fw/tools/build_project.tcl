if {$::argc != 2} {
	puts "Usage: xsct $::argv0 bif bin"
	exit 1
}

set bif [lindex $::argv 0]
set bin [lindex $::argv 1]

exec bootgen -arch zynq -image $bif -w -o $bin

