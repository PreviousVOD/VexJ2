ROOT := $(abspath $(CURDIR)/../..)
ARCHIVE := $(ROOT)/archive/systemverilog-2026-11-14/working-tree/sim
VERILATOR ?= $(ROOT)/tools/local/bin/verilator
SPINAL_VERILOG := $(ROOT)/build/spinal/verilog/Sh2Core.v
BUILD := $(ROOT)/build/spinal/verif/sh2sim
TANG_BUILD := $(ROOT)/build/spinal/verif/tangprimer
TESTROM := $(ROOT)/build/sw/testrom/main.bin

.PHONY: all generate rom test tangprimer clean

all: $(BUILD)/VSh2Core

rom: $(TESTROM)

test: $(BUILD)/VSh2Core $(TESTROM)
	$(BUILD)/VSh2Core $(TESTROM) --expect "CPU tests passed" --max-cycles 8000000 --quiet
	$(BUILD)/VSh2Core $(ROOT)/build/sw/simtests/rte.bin --max-cycles 2000000 --quiet
	$(BUILD)/VSh2Core $(ROOT)/build/sw/simtests/interrupts.bin --max-cycles 2000000 --quiet

tangprimer: $(TANG_BUILD)/VJ2TangPrimer
	cd $(TANG_BUILD) && ./VJ2TangPrimer

generate:
	$(MAKE) -C $(ROOT) spinal-generate

$(SPINAL_VERILOG):
	$(MAKE) -C $(ROOT) spinal-generate

$(BUILD)/VSh2Core: cpp/sh2sim.cpp $(SPINAL_VERILOG)
	mkdir -p $(BUILD)
	$(VERILATOR) --cc --exe --build -O2 -Wno-fatal --top-module Sh2Core \
		-Mdir $(BUILD)/obj -o ../VSh2Core \
		-CFLAGS "-O2 -I$(ARCHIVE)/common" \
		$(SPINAL_VERILOG) cpp/sh2sim.cpp

$(TESTROM):
	$(MAKE) -C $(ROOT)/sw/testrom

$(TANG_BUILD)/VJ2TangPrimer: cpp/tangprimer_sim.cpp $(ROOT)/build/spinal/verilog/J2TangPrimer.v
	mkdir -p $(TANG_BUILD)
	cp $(ROOT)/build/spinal/verilog/J2TangPrimer.v_*.bin $(TANG_BUILD)/
	$(VERILATOR) --cc --exe --build -O2 -Wno-fatal --top-module J2TangPrimer \
		-Mdir $(TANG_BUILD)/obj -o ../VJ2TangPrimer \
		$(ROOT)/build/spinal/verilog/J2TangPrimer.v cpp/tangprimer_sim.cpp

clean:
	rm -rf $(BUILD) $(TANG_BUILD)
