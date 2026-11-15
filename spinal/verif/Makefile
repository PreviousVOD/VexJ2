ROOT := $(abspath $(CURDIR)/../..)
REF_COMMON := $(ROOT)/verilog/verif/common
VERILATOR ?= $(ROOT)/tools/local/bin/verilator
SPINAL_DIR := $(ROOT)/spinal
MICRO_VERILOG := $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v
SPINAL_GENERATED := $(MICRO_VERILOG)
MICRO_BUILD := $(ROOT)/build/spinal/verif/microcoded
TESTROM := $(ROOT)/build/sw/testrom/main.bin
SIMTESTS := $(ROOT)/build/sw/simtests/rte.bin $(ROOT)/build/sw/simtests/interrupts.bin
SCALA_SRC := $(wildcard $(SPINAL_DIR)/src/main/scala/j2/*.scala) \
	$(wildcard $(SPINAL_DIR)/src/main/scala/j2/*/*.scala)
SPINAL_BUILD := $(SPINAL_DIR)/build.sbt $(SPINAL_DIR)/project/build.properties \
	$(SPINAL_DIR)/project/plugins.sbt
HARNESS_HEADERS := $(REF_COMMON)/sysmodel.h $(REF_COMMON)/wbslave.h
REFSRC := $(ROOT)/reference/soc_top/components/cpu/cpu2j0_pkg.vhd

.PHONY: all generate rom test microcode-test clean

all: $(MICRO_BUILD)/VJ2MicrocodedCore

rom: $(TESTROM) $(SIMTESTS)

test: microcode-test

microcode-test: $(MICRO_BUILD)/VJ2MicrocodedCore $(TESTROM) $(SIMTESTS)
	cd $(MICRO_BUILD) && ./VJ2MicrocodedCore $(TESTROM) --expect "CPU tests passed" --max-cycles 8000000 --quiet
	cd $(MICRO_BUILD) && ./VJ2MicrocodedCore $(ROOT)/build/sw/simtests/rte.bin --max-cycles 2000000 --quiet
	cd $(MICRO_BUILD) && ./VJ2MicrocodedCore $(ROOT)/build/sw/simtests/interrupts.bin --max-cycles 2000000 --quiet

generate: $(SPINAL_GENERATED)

$(SPINAL_GENERATED) &: $(SCALA_SRC) $(SPINAL_BUILD) $(TESTROM)
	J2_ROM="$(TESTROM)" $(MAKE) -C $(ROOT) spinal-generate

$(MICRO_BUILD)/VJ2MicrocodedCore: cpp/sh2sim.cpp $(MICRO_VERILOG) $(HARNESS_HEADERS)
	mkdir -p $(MICRO_BUILD)
	cp $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v_*.bin $(MICRO_BUILD)/
	$(VERILATOR) --cc --exe --build -O2 -Wno-fatal --top-module J2MicrocodedCore \
		-Mdir $(MICRO_BUILD)/obj -o ../VJ2MicrocodedCore \
		-CFLAGS "-O2 -DUSE_MICROCODED_CORE -I$(REF_COMMON)" \
		$(MICRO_VERILOG) cpp/sh2sim.cpp

$(TESTROM): $(REFSRC) $(ROOT)/sw/testrom/Makefile
	$(MAKE) -C $(ROOT) $(TESTROM)

$(SIMTESTS) &: $(REFSRC)
	$(MAKE) -C $(ROOT)/sw/simtests

clean:
	rm -rf $(MICRO_BUILD)
