ROOT := $(abspath $(CURDIR)/..)
J2_CLOCK_HZ ?= 32000000
VERILATOR ?= $(ROOT)/tools/local/bin/verilator
BUILD := $(ROOT)/build/verilog/verif
XIP_BUILD := $(ROOT)/build/verilog/xip_verif
CPU := $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v
TOP := $(ROOT)/build/spinal/verilog/j2_tang_primer.v
TEST_TOP := $(ROOT)/build/spinal/verilog-test/j2_tang_primer.v
ROM := $(ROOT)/build/verilog/j2_validation_rom.hex
TESTROM := $(ROOT)/build/sw/testrom16550/main.bin
BOOTROM := $(ROOT)/build/sw/xiprom/main.bin
XIPAPP := $(ROOT)/build/sw/xipapp/main.bin
XIP_IMAGE := $(ROOT)/build/sw/xipapp/flash.bin
XIP_ROM := $(ROOT)/build/verilog/xip/j2_validation_rom.hex
FLASHSIM_DIR := $(ROOT)/third_party/qspiflash/bench/cpp
SDRAM_SIM := $(ROOT)/verilog/verif/j2_sdram_model.v
GPIO_PAD_SIM := $(ROOT)/verilog/verif/j2_gpio_pad_model.v
SCALA_SRC := $(wildcard $(ROOT)/spinal/src/main/scala/j2/*.scala) \
	$(wildcard $(ROOT)/spinal/src/main/scala/j2/*/*.scala)
SOC_SRC := $(TOP) $(SDRAM_SIM) $(GPIO_PAD_SIM)
TEST_SOC_SRC := $(TEST_TOP) $(SDRAM_SIM) $(GPIO_PAD_SIM)

.PHONY: all test xip-test clean

all: test

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

$(XIP_BUILD)/Vj2_tang_primer: Makefile verif/j2_xip_sim.cpp $(TOP) $(XIP_ROM) $(SDRAM_SIM) $(GPIO_PAD_SIM) \
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

$(TEST_TOP): $(SCALA_SRC) $(ROOT)/spinal/build.sbt $(ROM)
	J2_ROM_HEX=$(ROM) J2_SPINAL_OUT=../build/spinal/verilog-test $(MAKE) -C $(ROOT) spinal-generate

$(TOP): $(SCALA_SRC) $(ROOT)/spinal/build.sbt $(XIP_ROM)
	$(MAKE) -C $(ROOT) spinal-generate

$(ROM): $(TESTROM) $(ROOT)/tools/gen_verilog_rom.py
	python3 $(ROOT)/tools/gen_verilog_rom.py $(TESTROM) $@

$(XIP_ROM): $(BOOTROM) $(ROOT)/tools/gen_verilog_rom.py
	python3 $(ROOT)/tools/gen_verilog_rom.py $(BOOTROM) $@

$(XIP_IMAGE): $(XIPAPP) $(ROOT)/tools/xip_image.py
	$(ROOT)/tools/xip_image.py pack $(XIPAPP) $@

$(BOOTROM): $(wildcard $(ROOT)/sw/xiprom/*)
	$(MAKE) -C $(ROOT)/sw/xiprom

$(XIPAPP): $(wildcard $(ROOT)/sw/xipapp/*)
	$(MAKE) -C $(ROOT)/sw/xipapp

$(TESTROM): $(ROOT)/reference/soc_top/components/cpu/cpu2j0_pkg.vhd
	$(MAKE) -C $(ROOT) $(TESTROM)

clean:
	rm -rf $(BUILD) $(XIP_BUILD) $(ROM) $(XIP_ROM)
