ROOT := $(abspath $(CURDIR)/..)
VERILATOR ?= $(ROOT)/tools/local/bin/verilator
BUILD := $(ROOT)/build/verilog/verif
XIP_BUILD := $(ROOT)/build/verilog/xip_verif
CPU := $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v
ROM := $(ROOT)/build/verilog/j2_validation_rom.hex
TESTROM := $(ROOT)/build/sw/testrom16550/main.bin
BOOTROM := $(ROOT)/build/sw/xiprom/main.bin
XIPAPP := $(ROOT)/build/sw/xipapp/main.bin
XIP_IMAGE := $(ROOT)/build/sw/xipapp/flash.bin
XIP_ROM := $(ROOT)/build/verilog/xip/j2_validation_rom.hex
UART_DIR := $(ROOT)/third_party/uart16550/rtl/verilog
FLASHSIM_DIR := $(ROOT)/third_party/qspiflash/bench/cpp
UART_SRC := $(wildcard $(UART_DIR)/*.v)
SDRAM_SIM := $(ROOT)/verilog/verif/j2_sdram_model.v
SCALA_SRC := $(wildcard $(ROOT)/spinal/src/main/scala/j2/*.scala) \
	$(wildcard $(ROOT)/spinal/src/main/scala/j2/*/*.scala)
SOC_SRC := $(ROOT)/verilog/j2_validation_rom.v \
	$(ROOT)/verilog/j2_pio.v \
	$(ROOT)/verilog/j2_uart16550.v \
	$(ROOT)/verilog/j2_spiflash.v \
	$(ROOT)/verilog/j2_sdram.v \
	$(ROOT)/verilog/j2_sdram_phy.v \
	$(ROOT)/third_party/qspiflash/rtl/llqspi.v \
	$(ROOT)/verilog/j2_soc.v \
	$(ROOT)/verilog/j2_tang_primer.v

.PHONY: all test xip-test clean

all: test

test: $(BUILD)/Vj2_tang_primer
	cd $(BUILD) && ./Vj2_tang_primer

xip-test: $(XIP_BUILD)/Vj2_tang_primer $(XIP_IMAGE)
	cd $(XIP_BUILD) && ./Vj2_tang_primer flash.bin
	cd $(XIP_BUILD) && ./Vj2_tang_primer flash.bin --loader

$(BUILD)/Vj2_tang_primer: Makefile verif/j2_tang_primer_sim.cpp $(CPU) $(ROM) $(SOC_SRC) $(SDRAM_SIM) $(UART_SRC)
	mkdir -p $(BUILD)
	cp $(ROM) $(BUILD)/j2_validation_rom.hex
	cp $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v_*.bin $(BUILD)/
	$(VERILATOR) --cc --exe --build -O2 --no-timing -Wno-fatal -Wno-lint -Wno-style \
		--top-module j2_tang_primer -I$(UART_DIR) -Mdir $(BUILD)/obj \
		-o ../Vj2_tang_primer $(CPU) $(SOC_SRC) $(SDRAM_SIM) $(UART_SRC) \
		$(ROOT)/verilog/verif/j2_tang_primer_sim.cpp

$(XIP_BUILD)/Vj2_tang_primer: Makefile verif/j2_xip_sim.cpp $(CPU) $(XIP_ROM) $(SOC_SRC) $(SDRAM_SIM) $(UART_SRC) \
		$(FLASHSIM_DIR)/flashsim.cpp $(FLASHSIM_DIR)/flashsim.h
	mkdir -p $(XIP_BUILD)
	cp $(XIP_ROM) $(XIP_BUILD)/j2_validation_rom.hex
	cp $(XIP_IMAGE) $(XIP_BUILD)/flash.bin
	cp $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v_*.bin $(XIP_BUILD)/
	$(VERILATOR) --cc --exe --build -O2 --no-timing -Wno-fatal -Wno-lint -Wno-style \
		--top-module j2_tang_primer -I$(UART_DIR) -Mdir $(XIP_BUILD)/obj \
		-o ../Vj2_tang_primer \
		-CFLAGS "-O2 -DCLKRATE_HZ=24000000 -I$(FLASHSIM_DIR)" \
		$(CPU) $(SOC_SRC) $(SDRAM_SIM) $(UART_SRC) $(ROOT)/verilog/verif/j2_xip_sim.cpp \
		$(FLASHSIM_DIR)/flashsim.cpp

$(CPU): $(SCALA_SRC) $(ROOT)/spinal/build.sbt
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
