ROOT := $(abspath $(CURDIR)/../..)
ARCHIVE := $(ROOT)/archive/systemverilog-2026-11-14/working-tree/sim
VERILATOR ?= $(ROOT)/tools/local/bin/verilator
SPINAL_DIR := $(ROOT)/spinal
SPINAL_VERILOG := $(ROOT)/build/spinal/verilog/J2Core.v
MICRO_VERILOG := $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v
TANG_VERILOG := $(ROOT)/build/spinal/verilog/J2TangPrimer.v
SPINAL_GENERATED := $(SPINAL_VERILOG) $(MICRO_VERILOG) $(TANG_VERILOG)
BUILD := $(ROOT)/build/spinal/verif/sh2sim
MICRO_BUILD := $(ROOT)/build/spinal/verif/microcoded
TANG_BUILD := $(ROOT)/build/spinal/verif/tangprimer
TESTROM := $(ROOT)/build/sw/testrom/main.bin
SIMTESTS := $(ROOT)/build/sw/simtests/rte.bin $(ROOT)/build/sw/simtests/interrupts.bin
SCALA_SRC := $(wildcard $(SPINAL_DIR)/src/main/scala/j2/*.scala) \
	$(wildcard $(SPINAL_DIR)/src/main/scala/j2/*/*.scala)
SPINAL_BUILD := $(SPINAL_DIR)/build.sbt $(SPINAL_DIR)/project/build.properties \
	$(SPINAL_DIR)/project/plugins.sbt
HARNESS_HEADERS := $(ARCHIVE)/common/sysmodel.h $(ARCHIVE)/common/wbslave.h

.PHONY: all generate rom test microcode-test tangprimer clean

all: $(BUILD)/VJ2Core

rom: $(TESTROM) $(SIMTESTS)

test: $(BUILD)/VJ2Core $(TESTROM) $(SIMTESTS)
	$(BUILD)/VJ2Core $(TESTROM) --expect "CPU tests passed" --max-cycles 8000000 --quiet
	$(BUILD)/VJ2Core $(ROOT)/build/sw/simtests/rte.bin --max-cycles 2000000 --quiet
	$(BUILD)/VJ2Core $(ROOT)/build/sw/simtests/interrupts.bin --max-cycles 2000000 --quiet

microcode-test: $(MICRO_BUILD)/VJ2MicrocodedCore $(TESTROM) $(SIMTESTS)
	cd $(MICRO_BUILD) && ./VJ2MicrocodedCore $(TESTROM) --expect "CPU tests passed" --max-cycles 8000000 --quiet
	cd $(MICRO_BUILD) && ./VJ2MicrocodedCore $(ROOT)/build/sw/simtests/rte.bin --max-cycles 2000000 --quiet
	cd $(MICRO_BUILD) && ./VJ2MicrocodedCore $(ROOT)/build/sw/simtests/interrupts.bin --max-cycles 2000000 --quiet

tangprimer: $(TANG_BUILD)/VJ2TangPrimer
	cd $(TANG_BUILD) && ./VJ2TangPrimer

generate: $(SPINAL_GENERATED)

$(SPINAL_GENERATED) &: $(SCALA_SRC) $(SPINAL_BUILD) $(TESTROM)
	J2_ROM="$(TESTROM)" $(MAKE) -C $(ROOT) spinal-generate

$(BUILD)/VJ2Core: cpp/sh2sim.cpp $(SPINAL_VERILOG) $(HARNESS_HEADERS)
	mkdir -p $(BUILD)
	$(VERILATOR) --cc --exe --build -O2 -Wno-fatal --top-module J2Core \
		-Mdir $(BUILD)/obj -o ../VJ2Core \
		-CFLAGS "-O2 -I$(ARCHIVE)/common" \
		$(SPINAL_VERILOG) cpp/sh2sim.cpp

$(MICRO_BUILD)/VJ2MicrocodedCore: cpp/sh2sim.cpp $(MICRO_VERILOG) $(HARNESS_HEADERS)
	mkdir -p $(MICRO_BUILD)
	cp $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v_*.bin $(MICRO_BUILD)/
	$(VERILATOR) --cc --exe --build -O2 -Wno-fatal --top-module J2MicrocodedCore \
		-Mdir $(MICRO_BUILD)/obj -o ../VJ2MicrocodedCore \
		-CFLAGS "-O2 -DUSE_MICROCODED_CORE -I$(ARCHIVE)/common" \
		$(MICRO_VERILOG) cpp/sh2sim.cpp

$(TESTROM): $(ROOT)/reference/soc_top/README
	$(MAKE) -C $(ROOT)/sw/testrom

$(SIMTESTS) &: $(ROOT)/reference/soc_top/README
	$(MAKE) -C $(ROOT)/sw/simtests

$(ROOT)/reference/soc_top/README: $(ROOT)/jcore-source-latest.tar.gz
	mkdir -p $(ROOT)/reference && tar -xzf $< -C $(ROOT)/reference
	chmod -R a-w $(ROOT)/reference/soc_top && touch $@

$(TANG_BUILD)/VJ2TangPrimer: cpp/tangprimer_sim.cpp $(TANG_VERILOG)
	mkdir -p $(TANG_BUILD)
	cp $(ROOT)/build/spinal/verilog/J2TangPrimer.v_*.bin $(TANG_BUILD)/
	$(VERILATOR) --cc --exe --build -O2 -Wno-fatal --top-module J2TangPrimer \
		-Mdir $(TANG_BUILD)/obj -o ../VJ2TangPrimer \
		$(TANG_VERILOG) cpp/tangprimer_sim.cpp

clean:
	rm -rf $(BUILD) $(MICRO_BUILD) $(TANG_BUILD)
