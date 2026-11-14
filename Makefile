SBT ?= $(CURDIR)/tools/local/bin/sbt
SPINAL_DIR := spinal
SPINAL_OUT := build/spinal/verilog
TD_HOME ?= /home/imi415/Softwares/Tools/TD_4.6.7_Linux
TESTROM := $(CURDIR)/build/sw/testrom/main.bin

.PHONY: all spinal-test spinal-generate spinal-clean spinal-verif spinal-hw-sim \
	spinal-fpga spinal-program sw

all: spinal-test spinal-generate

spinal-test:
	cd $(SPINAL_DIR) && $(SBT) -batch test

spinal-generate:
	mkdir -p $(SPINAL_OUT)
	cd $(SPINAL_DIR) && $(SBT) -batch run

spinal-verif:
	$(MAKE) -C spinal/verif test

spinal-hw-sim:
	$(MAKE) sw
	J2_ROM="$(TESTROM)" $(MAKE) spinal-generate
	$(MAKE) -C spinal/verif tangprimer

spinal-clean:
	rm -rf $(SPINAL_OUT) $(SPINAL_DIR)/target $(SPINAL_DIR)/project/target

sw:
	$(MAKE) -C sw/testrom
	$(MAKE) -C sw/simtests

spinal-fpga:
	$(MAKE) sw
	TD_HOME="$(TD_HOME)" J2_ROM="$(TESTROM)" tools/build_tang_primer_td.sh

spinal-program: spinal-fpga
	TD_HOME="$(TD_HOME)" tools/program_tang_primer_td.sh
