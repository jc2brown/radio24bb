if {$::argc != 5} {
	puts "Usage: xsct $::argv0 stamp hdf hw_dir target_cpu project_name"
	exit 1
}

set stamp [lindex $::argv 0]
set hdf [lindex $::argv 1]
# set hwname [lindex $::argv 2]
set hw_dir [lindex $::argv 2]
set targetcpu [lindex $::argv 3]
set project_name  [lindex $::argv 4]

# setws ${hwname}_hw
setws ${hw_dir}
createhw -name ${project_name}_hw -hwspec ${hdf}

createapp -name ${project_name}_fsbl -app {Zynq FSBL} -hwproject ${project_name}_hw -proc ${targetcpu}
#project -build

# This by default generates a standalone BSP.
# There are hooks to change the defaults, but it might work better to
# use a standalone BSP and build the RTOS separately.
createbsp -name ${project_name}_bsp -hwproject ${project_name}_hw -proc ${targetcpu}

createapp -name ${project_name}_app -app {Empty Application} -bsp ${project_name}_bsp -hwproject ${project_name}_hw -proc ${targetcpu}

# projects -build
# exec bootgen -arch zynq -image ouput.bif -w -o BOOT.bin

# exec touch [lindex $::argv 0].${hwname}.bsp.gen
exec touch ${stamp}
