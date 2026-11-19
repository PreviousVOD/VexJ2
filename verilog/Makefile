ROOT := $(abspath $(CURDIR)/..)
ifndef J2_CLOCK_HZ
J2_CLOCK_HZ := $(shell python3 $(ROOT)/tools/board_config.py tang-primer --get clockHz)
endif
VERILATOR ?= $(ROOT)/tools/local/bin/verilator
BUILD := $(ROOT)/build/verilog/verif
XIP_BUILD := $(ROOT)/build/verilog/xip_verif
CPU := $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v
TOP := $(ROOT)/build/spinal/verilog/j2_tang_primer.v
TEST_TOP := $(ROOT)/build/spinal/verilog-test/j2_tang_primer.v
ROM := $(ROOT)/build/verilog/j2_validation_rom.hex
TESTROM := $(ROOT)/build/sw/testrom16550/main.bin
BOOTROM := $(ROOT)/build/tang-primer/rom/main.bin
XIPAPP := $(ROOT)/build/sw/xipapp/main.bin
XIP_IMAGE := $(ROOT)/build/sw/xipapp/flash.bin
XIP_ROM := $(ROOT)/build/verilog/xip/j2_validation_rom.hex
FLASHSIM_DIR := $(ROOT)/third_party/qspiflash/bench/cpp
SDRAM_SIM := $(ROOT)/verilog/verif/j2_sdram_model.v
GPIO_PAD_SIM := $(ROOT)/verilog/verif/j2_gpio_pad_model.v
SCALA_SRC := $(shell find $(ROOT)/spinal/src/main/scala -name '*.scala' -type f)
SPINAL_RESOURCES := $(shell find $(ROOT)/spinal/src/main/resources -type f)
SPINAL_BUILD := $(ROOT)/spinal/build.sbt $(ROOT)/spinal/project/build.properties \
	$(ROOT)/spinal/project/plugins.sbt $(ROOT)/fpga/tang-primer/board.properties
SOC_SRC := $(TOP) $(SDRAM_SIM) $(GPIO_PAD_SIM)
TEST_SOC_SRC := $(TEST_TOP) $(SDRAM_SIM) $(GPIO_PAD_SIM)

.PHONY: all test xip-test xip-sim-build clean

all: test

xip-sim-build: $(XIP_BUILD)/Vj2_tang_primer

test: $(BUILD)/Vj2_tang_primer
	cd $(BUILD) && ./Vj2_tang_primer
	cd $(BUILD) && ./Vj2_tang_primer --cold-boot

xip-test: $(XIP_BUILD)/Vj2_tang_primer $(XIP_IMAGE)
	cp $(XIP_IMAGE) $(XIP_BUILD)/flash.bin
	cd $(XIP_BUILD) && ./Vj2_tang_primer flash.bin
	cd $(XIP_BUILD) && ./Vj2_tang_primer flash.bin --cold-boot
	cd $(XIP_BUILD) && ./Vj2_tang_primer flash.bin --loader --cold-boot

$(BUILD)/Vj2_tang_primer: Makefile verif/j2_tang_primer_sim.cpp $(TEST_TOP) $(ROM) $(SDRAM_SIM) $(GPIO_PAD_SIM)
	mkdir -p $(BUILD)
	cp $(ROM) $(BUILD)/j2_validation_rom.hex
	cp $(ROOT)/build/spinal/verilog-test/J2MicrocodedCore.v_*.bin $(ROOT)/build/spinal/verilog-test/$(notdir $(TEST_TOP))_*.bin $(BUILD)/
	$(VERILATOR) --cc --language 1364-2005 --exe --build -O2 --no-timing -Wno-fatal -Wno-lint -Wno-style \
		--top-module j2_tang_primer -Mdir $(BUILD)/obj \
		-o ../Vj2_tang_primer \
		-CFLAGS "-O2 -DCLKRATE_HZ=$(J2_CLOCK_HZ)" \
		$(TEST_SOC_SRC) $(ROOT)/verilog/verif/j2_tang_primer_sim.cpp

$(XIP_BUILD)/Vj2_tang_primer: Makefile verif/j2_xip_sim.cpp $(TOP) $(XIP_ROM) $(XIP_IMAGE) $(SDRAM_SIM) $(GPIO_PAD_SIM) \
		$(FLASHSIM_DIR)/flashsim.cpp $(FLASHSIM_DIR)/flashsim.h
	mkdir -p $(XIP_BUILD)
	cp $(XIP_ROM) $(XIP_BUILD)/j2_validation_rom.hex
	cp $(XIP_IMAGE) $(XIP_BUILD)/flash.bin
	cp $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v_*.bin $(ROOT)/build/spinal/verilog/$(notdir $(TOP))_*.bin $(XIP_BUILD)/
	$(VERILATOR) --cc --language 1364-2005 --exe --build -O2 --no-timing -Wno-fatal -Wno-lint -Wno-style \
		--top-module j2_tang_primer -Mdir $(XIP_BUILD)/obj \
		-o ../Vj2_tang_primer \
		-CFLAGS "-O2 -DCLKRATE_HZ=$(J2_CLOCK_HZ) -I$(FLASHSIM_DIR)" \
		$(SOC_SRC) $(ROOT)/verilog/verif/j2_xip_sim.cpp \
		$(FLASHSIM_DIR)/flashsim.cpp

$(TEST_TOP): $(SCALA_SRC) $(SPINAL_RESOURCES) $(SPINAL_BUILD) $(ROM)
	J2_ROM_HEX=$(ROM) J2_SPINAL_OUT=../build/spinal/verilog-test $(MAKE) -C $(ROOT) tang-sim-generate

$(TOP): $(SCALA_SRC) $(SPINAL_RESOURCES) $(SPINAL_BUILD) $(XIP_ROM)
	J2_SPINAL_OUT=../build/spinal/verilog $(MAKE) -C $(ROOT) tang-sim-generate

$(ROM): $(TESTROM) $(ROOT)/tools/gen_verilog_rom.py
	python3 $(ROOT)/tools/gen_verilog_rom.py $(TESTROM) $@

$(XIP_ROM): $(BOOTROM) $(ROOT)/tools/gen_verilog_rom.py
	python3 $(ROOT)/tools/gen_verilog_rom.py $(BOOTROM) $@

$(XIP_IMAGE): $(XIPAPP) $(ROOT)/tools/xip_image.py
	$(ROOT)/tools/xip_image.py pack $(XIPAPP) $@

.PHONY: force-tang-rom
force-tang-rom:

$(BOOTROM): force-tang-rom $(wildcard $(ROOT)/sw/bootrom/* $(ROOT)/sw/include/*.h) $(ROOT)/fpga/tang-primer/board.properties $(ROOT)/tools/board_config.py
	$(MAKE) -C $(ROOT)/sw/bootrom

$(XIPAPP): $(wildcard $(ROOT)/sw/xipapp/* $(ROOT)/sw/include/*.h) $(ROOT)/sw/bootrom/uart.c $(ROOT)/sw/bootrom/uart.h $(ROOT)/fpga/tang-primer/board.properties $(ROOT)/tools/board_config.py
	$(MAKE) -C $(ROOT)/sw/xipapp

$(TESTROM): $(ROOT)/reference/soc_top/components/cpu/cpu2j0_pkg.vhd
	$(MAKE) -C $(ROOT) $(TESTROM)

clean:
	rm -rf $(BUILD) $(XIP_BUILD) $(ROM) $(XIP_ROM)
