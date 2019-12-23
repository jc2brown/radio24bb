
RTL_ROOT?=.

ifeq ($(shell uname), windows32)
PREFIX = cmd /c "
POSTFIX = "
else
PREFIX:=
POSTFIX:=
endif


include $(RTL_ROOT)/rtl_info.mk


ifeq ($(BOARD),microzed7020)
	FPGA_PART:=xc7z020clg400-1
endif
ifeq ($(BOARD),zcu102)
	FPGA_PART:=xczu9eg-ffvb1156-2-e
endif


RTL_FILES:=$(wildcard $(RTL_ROOT)/hdl/*.sv)
XDC_FILES:=$(wildcard $(RTL_ROOT)/xdc/*.xdc)
BD_SCRIPT:=$(wildcard $(RTL_ROOT)/bd/$(BLOCK_DESIGN).tcl)

PROJECT_DIR:=$(RTL_ROOT)/syn
PROJECT_FILE:=$(PROJECT_DIR)/$(PROJECT_NAME).xpr
BD_FILE:=$(PROJECT_DIR)/$(PROJECT_NAME).srcs/sources_1/bd/$(BLOCK_DESIGN)/$(BLOCK_DESIGN).bd
SYNTH_CHECKPOINT:=$(PROJECT_DIR)/$(PROJECT_NAME).runs/synth_1/$(PROJECT_TOP).dcp
IMPL_CHECKPOINT:=$(PROJECT_DIR)/$(PROJECT_NAME).runs/impl_1/$(PROJECT_TOP)_routed.dcp
BIT_FILE:=$(RTL_ROOT)/out/$(PROJECT_TOP).bit
HDF_FILE:=$(RTL_ROOT)/out/$(PROJECT_TOP).hdf
INFO_FILE:=$(RTL_ROOT)/out/rtl_info.mk



$(info )
$(info RTL BUILD CONFIGURATION OVERVIEW)
$(info ----------------------------)
$(info )
$(info -  RTL_ROOT=$(RTL_ROOT))
$(info )
$(info -  BD_SCRIPT=$(BD_SCRIPT))
$(info )
$(info -  PROJECT_NAME=$(PROJECT_NAME))
$(info -  PROJECT_TOP=$(PROJECT_TOP))
$(info -  FPGA_PART=$(FPGA_PART))
$(info )
$(info -  PROJECT_DIR=$(PROJECT_DIR))
$(info -  PROJECT_FILE=$(PROJECT_FILE))
$(info -  BD_FILE=$(BD_FILE))
$(info -  SYNTH_CHECKPOINT=$(SYNTH_CHECKPOINT))
$(info -  IMPL_CHECKPOINT=$(IMPL_CHECKPOINT))
$(info -  BIT_FILE=$(BIT_FILE))
$(info -  HDF_FILE=$(HDF_FILE))
$(info -  INFO_FILE=$(INFO_FILE))
$(info )
#$(call print_sources)
$(info )


all: $(RTL_ROOT)/bit


$(PROJECT_FILE): 
	mkdir -p $(PROJECT_DIR) 
	@cd $(PROJECT_DIR) && \
	$(PREFIX) vivado -mode batch -source ../scripts/create_project.tcl -tclargs $(PROJECT_NAME) $(PROJECT_TOP) $(FPGA_PART) ../hdl ../xdc ../tb $(POSTFIX)


$(BD_FILE): $(BD_SCRIPT) | $(PROJECT_FILE)
	@cd $(PROJECT_DIR) && \
	$(PREFIX) vivado -mode batch -source ../scripts/create_bd.tcl -tclargs $(PROJECT_NAME) ../bd/$(BLOCK_DESIGN).tcl $(POSTFIX)


$(SYNTH_CHECKPOINT): $(RTL_FILES) $(XDC_FILES) $(BD_FILE) | $(PROJECT_FILE)
	mkdir -p $(PROJECT_DIR)/rpt
	mkdir -p $(PROJECT_DIR)/xdc
	@cd $(PROJECT_DIR) && \
	$(PREFIX) vivado -mode batch -source ../scripts/run_synth.tcl -tclargs $(PROJECT_NAME) $(POSTFIX)


$(IMPL_CHECKPOINT): $(SYNTH_CHECKPOINT)
	@cd $(PROJECT_DIR) && \
	$(PREFIX) vivado -mode batch -source ../scripts/run_impl.tcl -tclargs $(PROJECT_NAME) $(POSTFIX)


.SECONDARY: $(HDF_FILE) $(INFO_FILE)
$(BIT_FILE) $(HDF_FILE) $(INFO_FILE): $(IMPL_CHECKPOINT)
	@cd $(PROJECT_DIR) && \
	$(PREFIX) vivado -mode batch -source ../scripts/generate_bit.tcl -tclargs $(PROJECT_NAME) -tclargs $(PROJECT_TOP) $(POSTFIX)
	cp $(RTL_ROOT)/rtl_info.mk $(RTL_ROOT)/out/


.PHONY: $(RTL_ROOT)/proj-no-bd
$(RTL_ROOT)/proj-no-bd: $(PROJECT_FILE)

.PHONY: $(RTL_ROOT)/proj
$(RTL_ROOT)/proj: $(BD_FILE)

.PHONY: $(RTL_ROOT)/bd
$(RTL_ROOT)/bd: $(BD_FILE)

.PHONY: $(RTL_ROOT)/synth
$(RTL_ROOT)/synth: $(SYNTH_CHECKPOINT)

.PHONY: $(RTL_ROOT)/impl
$(RTL_ROOT)/impl: $(IMPL_CHECKPOINT)

.PHONY: $(RTL_ROOT)/bit
$(RTL_ROOT)/bit: $(BIT_FILE) $(HDF_FILE) $(INFO_FILE)

.PHONY: $(RTL_ROOT)/hdf
$(RTL_ROOT)/hdf: $(RTL_ROOT)/bit

.PHONY: $(RTL_ROOT)/info
$(RTL_ROOT)/info: $(RTL_ROOT)/bit


.PHONY: $(RTL_ROOT)/clean
$(RTL_ROOT)/clean :	
	rm -rf $(RTL_ROOT)/syn/
	rm -rf $(RTL_ROOT)/out/

