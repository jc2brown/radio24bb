# get the directory where this script resides
set thisDir [file dirname [info script]]
# source common utilities
source -notrace $thisDir/utils.tcl

# passed into this script w/ -tclargs option to specify
# the path of the board tcl generation script generated with
# save_bd.tcl tool.
set target_bd_tcl $argv
puts $thisDir


puts "INFO: Processing $target_bd_tcl into the project."

# Source the bd.tcl file to create the bd
source $target_bd_tcl

# validate and save the bd design
validate_bd_design
save_bd_design

# If successful, "touch" a file so the make utility will know it's done 
touch {.bd_gen.done}
