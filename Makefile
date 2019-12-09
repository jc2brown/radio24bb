
RTL_ROOT:=rtl
include $(RTL_ROOT)/Makefile

FW_ROOT:=fw
include $(FW_ROOT)/Makefile


.PHONY: all
all: boot 

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
