
FW_ROOT?=.

UNAME:=$(shell uname)

-include $(FW_ROOT)/rtl_info.mk

.SUFFIXES:
	
COMPILER_FLAGS:=-Wall -O0 -g3 -c -fmessage-length=0 
CC_FLAGS:=$(COMPILER_FLAGS)
CXX_FLAGS:=$(COMPILER_FLAGS)


#
# Target-specific build configuration
#
ifeq ($(BOARD),microzed7020)
	CC:=arm-none-eabi-gcc
	CXX:=arm-none-eabi-g++
	SIZE:=arm-none-eabi-size
	TARGET_CPU:=ps7_cortexa9_0
	TARGET_SPECIFIC_OPTIONS:=-mcpu=cortex-a9 -mfpu=vfpv3 -mfloat-abi=hard 
endif
ifeq ($(BOARD),zcu102)
	CC:=aarch64-none-elf-gcc
	CXX:=aarch64-none-elf-g++
	SIZE:=aarch64-none-elf-size
	TARGET_CPU:=psu_cortexa53_0
	TARGET_SPECIFIC_OPTIONS:=
endif




ifeq ($(shell uname), windows32)
RM:=$(FW_ROOT)/bin/rm -rf
else
RM:=rm -rf
endif






LD_SRCS += $(FW_ROOT)/lscript/lscript_$(TARGET_CPU).ld


CC_DEPS += \
$(OBJ_DIR)/*.d 


C_DEPS += \
$(OBJ_DIR)/platform.d


XSCT := xsct
ifeq ($(OS),Windows_NT)
	XSCT := xsct.bat
endif


LIBS := -Wl,--build-id=none,--start-group,-lxil,-lgcc,-lc,-lstdc++,--end-group


OUT_DIR:=$(FW_ROOT)/out
OBJ_DIR:=$(FW_ROOT)/obj
WORKSPACE_DIR:=$(FW_ROOT)/workspace
HW_DIR:=$(WORKSPACE_DIR)/$(PROJECT_TOP)_hw
BSP_DIR:=$(WORKSPACE_DIR)/$(PROJECT_TOP)_bsp
APP_DIR:=$(WORKSPACE_DIR)/$(PROJECT_TOP)_app
SRC_DIR:=$(FW_ROOT)/src

SRC_LIST:=$(shell cat $(SRC_DIR)/fw_sources.lst)
$(info $(SRC_LIST))

OBJS:=$(basename $(SRC_LIST))
OBJS:=$(addsuffix .o,$(OBJS))
OBJS:=$(addprefix $(OBJ_DIR)/,$(OBJS))

SRCS:=$(addprefix $(SRC_DIR)/,$(SRC_LIST))


BSP_GEN_STAMP:=$(FW_ROOT)/.$(PROJECT_TOP).bsp.gen
BSP_BUILD_STAMP:=$(FW_ROOT)/.$(PROJECT_TOP).bsp.build

INIT_STAMP:=$(FW_ROOT)/.$(PROJECT_TOP).init.done
BOOT_STAMP:=$(FW_ROOT)/.$(PROJECT_TOP).boot.done

BIT_FILE?=$(FW_ROOT)/$(PROJECT_TOP).bit
HDF_FILE?=$(FW_ROOT)/$(PROJECT_TOP).hdf

ELF_FILE?=$(OUT_DIR)/$(PROJECT_TOP).elf
ELFSIZE_FILE?=$(OUT_DIR)/$(PROJECT_TOP).elf.size


SDK_DEPS:=$(BSP_BUILD_STAMP)


$(info )
$(info FW BUILD CONFIGURATION OVERVIEW)
$(info ----------------------------)
$(info )
$(info -  FW_ROOT=$(FW_ROOT))
$(info -  SRC_DIR=$(SRC_DIR))
$(info -  OBJ_DIR=$(OBJ_DIR))
$(info -  OUT_DIR=$(OUT_DIR))
$(info -  WORKSPACE_DIR=$(WORKSPACE_DIR))
$(info -  HW_DIR=$(HW_DIR))
$(info -  BSP_DIR=$(BSP_DIR))
$(info -  APP_DIR=$(APP_DIR))
$(info )
$(info -  BSP_GEN_STAMP=$(BSP_GEN_STAMP))
$(info -  BSP_BUILD_STAMP=$(BSP_BUILD_STAMP))
$(info )
$(info -  BIT_FILE=$(BIT_FILE))
$(info -  HDF_FILE=$(HDF_FILE))
$(info -  ELF_FILE=$(ELF_FILE))
$(info )
$(info -  PROJECT_TOP=$(PROJECT_TOP))
$(info -  BOARD=$(BOARD))
$(info -  TARGET_CPU=$(TARGET_CPU))
$(info -  TARGET_SPECIFIC_OPTIONS=$(TARGET_SPECIFIC_OPTIONS))
$(info )
$(info -  CC:        $(CC))
$(info -  CC_FLAGS:  $(CC_FLAGS))
$(info )
$(info -  CXX:       $(CXX))
$(info -  CXX_FLAGS: $(CXX_FLAGS))
$(info )
$(info -  SIZE:      $(SIZE))
$(info )
$(info -  SRCS:)
$(foreach e,$(SRCS),$(info --   $e))
$(info )
$(info -  OBJS:)
$(foreach e,$(OBJS),$(info --   $e))
$(info )
$(info -  SDK_DEPS:)
$(foreach e,$(SDK_DEPS),$(info --   $e))
$(info )


.PHONY: $(FW_ROOT)/all
$(FW_ROOT)/all: $(ELF_FILE) 

.PHONY: $(FW_ROOT)/bsp
$(FW_ROOT)/bsp: $(SDK_DEPS)


$(BSP_GEN_STAMP): $(HDF_FILE)
	mv $(SRC_DIR) $(SRC_DIR)_
	rm -rf $(WORKSPACE_DIR)	
	mv $(SRC_DIR)_ $(SRC_DIR)
	$(XSCT) $(FW_ROOT)/tools/gen_hw_bsp.tcl $(BSP_GEN_STAMP) $(HDF_FILE) $(WORKSPACE_DIR) $(TARGET_CPU) $(PROJECT_TOP)
	#rm -rf $(APP_DIR)/src
ifeq ($(UNAME), windows32)
	cmd /c "$(shell cygpath -a -w $(FW_ROOT)/tools/linksrc.bat) $(shell cygpath -a -w $(APP_DIR)/src) $(shell cygpath -a -w $(FW_ROOT)/src) "
else ifeq ($(UNAME), Linux)
	cd $(APP_DIR) && ln -s ../../src src
endif


$(BSP_BUILD_STAMP): $(BSP_GEN_STAMP)
	make -C $(BSP_DIR) -j1
	touch $@

.SECONDARY: $(SRC_DIR) $(wildcard $(SRC_DIR)/*)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cc $(SDK_DEPS)
	mkdir -p $(OBJ_DIR)
	$(CXX) $(COMPILER_FLAGS) -MT"$@" $(TARGET_SPECIFIC_OPTIONS) -I$(BSP_DIR)/$(TARGET_CPU)/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp $(SDK_DEPS)
	mkdir -p $(OBJ_DIR)
	$(CXX) $(COMPILER_FLAGS) -MT"$@" $(TARGET_SPECIFIC_OPTIONS) -I$(BSP_DIR)/$(TARGET_CPU)/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c $(SDK_DEPS)
	mkdir -p $(OBJ_DIR)
	$(CC) $(COMPILER_FLAGS) -MT"$@" $(TARGET_SPECIFIC_OPTIONS) -I$(BSP_DIR)/$(TARGET_CPU)/include -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"

$(ELF_FILE): $(OBJS) $(LD_SRCS) $(USER_OBJS) $(SDK_DEPS) $(BSP_GEN_STAMP)
	mkdir -p $(OUT_DIR)
	$(CXX) $(TARGET_SPECIFIC_OPTIONS) -Wl,-build-id=none -specs=$(FW_ROOT)/Xilinx.spec -Wl,-T -Wl,$(LD_SRCS) -L$(BSP_DIR)/$(TARGET_CPU)/lib -o "$(ELF_FILE)"  $(OBJS)   $(LIBS)
	$(SIZE) $(ELF_FILE) | tee "$(ELFSIZE_FILE)"

.PHONY: $(FW_ROOT)/elf
$(FW_ROOT)/elf: $(ELF_FILE)


.PHONY: $(FW_ROOT)/nuke
$(FW_ROOT)/nuke: $(FW_ROOT)/clean
	-$(RM) $(FW_ROOT)/*.bit $(FW_ROOT)/*.hdf $(FW_ROOT)/rtl_info.mk


.PHONY: $(FW_ROOT)/clean
$(FW_ROOT)/clean:
	-$(RM) $(CC_DEPS) $(EXECUTABLES) $(OBJS) $(C_UPPER_DEPS) $(CXX_DEPS) $(S_UPPER_DEPS) $(C_DEPS) $(CPP_DEPS) 
	-$(RM) $(BSP_GEN_STAMP)
	-$(RM) $(BSP_BUILD_STAMP)
	-$(RM) $(OUT_DIR)
	-$(RM) $(OBJ_DIR)
	-$(RM) $(WORKSPACE_DIR)
	-$(RM) $(FW_ROOT)/.Xil
	-$(RM) $(FW_ROOT)/*.log
	-$(RM) $(FW_ROOT)/.*.done


.PHONY: $(FW_ROOT)/boot
$(FW_ROOT)/boot: $(BIT_FILE) $(ELF_FILE)
	$(XSCT) $(FW_ROOT)/tools/init_$(BOARD).tcl $(BIT_FILE) $(wildcard $(HW_DIR)/ps*_init.tcl) $(INIT_STAMP)
	$(XSCT) $(FW_ROOT)/tools/boot_$(BOARD).tcl $(ELF_FILE) $(wildcard $(HW_DIR)/ps*_init.tcl) $(BOOT_STAMP)



