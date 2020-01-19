
RTL_ROOT:=rtl
include $(RTL_ROOT)/Makefile

FW_ROOT:=fw
include $(FW_ROOT)/Makefile


.PHONY: all
all: boot 

.PHONY: proj
proj: $(RTL_ROOT)/proj

.PHONY: bit
bit: $(RTL_ROOT)/bit

.PHONY: hdf
hdf: $(RTL_ROOT)/hdf
	
.PHONY: elf
elf: $(FW_ROOT)/elf

.PHONY: boot
boot: $(FW_ROOT)/boot

.PHONY: clean
clean: $(RTL_ROOT)/clean $(FW_ROOT)/clean

# When make is invoked from this directory, fw uses .bit and .hdf files from rtl/out/
# To prevent unbuilt RTL changes from forcing an entire FPGA build,
# this command copies the .bit and .hdf files into fw/ and subsequent invokations of
# make from within fw/ will use the copied files which do not depend on the RTL sources.
.PHONY: copy
copy: 
	cp $(RTL_ROOT)/out/* $(FW_ROOT)
