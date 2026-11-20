ROOT := $(abspath $(CURDIR)/../..)
REF_COMMON := $(ROOT)/verilog/verif/common
VERILATOR ?= $(ROOT)/tools/local/bin/verilator
SPINAL_DIR := $(ROOT)/spinal
MICRO_BUILD := $(ROOT)/build/spinal/verif/microcoded
MICRO_VERILOG := $(MICRO_BUILD)/rtl/J2Core.v
SPINAL_GENERATED := $(MICRO_VERILOG)
TESTROM := $(ROOT)/build/sw/testrom/main.bin
SIMTESTS := $(ROOT)/build/sw/simtests/rte.bin $(ROOT)/build/sw/simtests/interrupts.bin
SCALA_SRC := $(shell find $(SPINAL_DIR)/src/main/scala -name '*.scala' -type f)
SPINAL_RESOURCES := $(shell find $(SPINAL_DIR)/src/main/resources -type f)
SPINAL_BUILD := $(SPINAL_DIR)/build.sbt $(SPINAL_DIR)/project/build.properties \
	$(SPINAL_DIR)/project/plugins.sbt
HARNESS_HEADERS := $(REF_COMMON)/sysmodel.h
REFSRC := $(ROOT)/reference/soc_top/components/cpu/cpu2j0_pkg.vhd

.PHONY: all generate rom test microcode-test clean

all: $(MICRO_BUILD)/VJ2Core

rom: $(TESTROM) $(SIMTESTS)

test: microcode-test

microcode-test: $(MICRO_BUILD)/VJ2Core $(TESTROM) $(SIMTESTS)
	cd $(MICRO_BUILD) && ./VJ2Core $(TESTROM) --expect "CPU tests passed" --max-cycles 8000000 --quiet
	cd $(MICRO_BUILD) && ./VJ2Core $(ROOT)/build/sw/simtests/rte.bin --max-cycles 2000000 --quiet
	cd $(MICRO_BUILD) && ./VJ2Core $(ROOT)/build/sw/simtests/interrupts.bin --max-cycles 2000000 --quiet

generate: $(SPINAL_GENERATED)

$(SPINAL_GENERATED) &: $(SCALA_SRC) $(SPINAL_RESOURCES) $(SPINAL_BUILD) $(TESTROM) $(SPINAL_DIR)/src/test/scala/j2/core/GenerateCoreVerification.scala
	$(MAKE) -C $(ROOT) toolchain-sbt microcode-data
	cd $(SPINAL_DIR) && J2_SPINAL_OUT=$(dir $(MICRO_VERILOG)) $(ROOT)/tools/local/bin/sbt -batch "Test / runMain j2.core.GenerateCoreVerification"

$(MICRO_BUILD)/VJ2Core: cpp/sh2sim.cpp $(MICRO_VERILOG) $(HARNESS_HEADERS)
	mkdir -p $(MICRO_BUILD)
	cp $(dir $(MICRO_VERILOG))J2Core.v_*.bin $(MICRO_BUILD)/
	$(VERILATOR) --cc --exe --build -O2 -Wno-fatal --top-module J2Core \
		-Mdir $(MICRO_BUILD)/obj -o ../VJ2Core \
		-CFLAGS "-O2 -I$(REF_COMMON)" \
		$(MICRO_VERILOG) cpp/sh2sim.cpp

$(TESTROM): $(REFSRC) $(ROOT)/sw/testrom/Makefile
	$(MAKE) -C $(ROOT) $(TESTROM)

$(SIMTESTS) &: $(REFSRC)
	$(MAKE) -C $(ROOT)/sw/simtests

clean:
	rm -rf $(MICRO_BUILD)
