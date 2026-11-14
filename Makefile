SBT ?= $(CURDIR)/tools/local/bin/sbt
SPINAL_DIR := spinal
SPINAL_OUT := build/spinal/verilog
TD_HOME ?= /home/imi415/Softwares/Tools/TD_4.6.7_Linux
TESTROM := $(CURDIR)/build/sw/testrom/main.bin
SIMTESTS := $(CURDIR)/build/sw/simtests/rte.bin $(CURDIR)/build/sw/simtests/interrupts.bin
REFSRC := reference/soc_top/README
ARCHIVE := archive/systemverilog-2026-11-14/working-tree
REF_BUILD := $(CURDIR)/build/ref_microcode
REF_VERILOG := $(REF_BUILD)/j2_cpu_flat.v
REF_SIM := $(REF_BUILD)/Vref_cpu
MICROCODE_HEX := spinal/src/main/resources/j2_microcode.hex
MICROCODE_PREDECODE := spinal/src/main/resources/j2_predecode.tsv
MICROCODE_MIF := build/microcode/j2_microcode.mif

export PATH := $(PATH):$(CURDIR)/tools/local/bin:$(CURDIR)/tools/local/sh-none-elf/bin

.PHONY: all spinal-test spinal-generate spinal-clean spinal-verif spinal-microcode-verif spinal-hw-sim \
	reference-verif reference-fpga spinal-fpga spinal-executor-fpga spinal-program sw td-vhdl \
	microcode-data microcode-mif

all: spinal-test spinal-generate

spinal-test: microcode-data
	cd $(SPINAL_DIR) && $(SBT) -batch test

spinal-generate: microcode-data
	mkdir -p $(SPINAL_OUT)
	cd $(SPINAL_DIR) && $(SBT) -batch run

spinal-verif:
	$(MAKE) -C spinal/verif test

spinal-microcode-verif:
	$(MAKE) -C spinal/verif microcode-test

spinal-hw-sim:
	$(MAKE) sw
	J2_ROM="$(TESTROM)" $(MAKE) spinal-generate
	$(MAKE) -C spinal/verif tangprimer

spinal-clean:
	rm -rf $(SPINAL_OUT) $(SPINAL_DIR)/target $(SPINAL_DIR)/project/target

$(REFSRC): jcore-source-latest.tar.gz
	mkdir -p reference && tar -xzf $< -C reference && chmod -R a-w reference/soc_top && touch $@

$(MICROCODE_HEX) $(MICROCODE_PREDECODE) &: $(REFSRC) tools/gen_microcode_data.py
	python3 tools/gen_microcode_data.py

$(MICROCODE_MIF): $(REFSRC) tools/gen_microcode_data.py
	python3 tools/gen_microcode_data.py --mif $@

microcode-data: $(MICROCODE_HEX) $(MICROCODE_PREDECODE)
microcode-mif: $(MICROCODE_MIF)

$(TESTROM): $(REFSRC)
	$(MAKE) -C sw/testrom

$(SIMTESTS) &: $(REFSRC)
	$(MAKE) -C sw/simtests

sw: $(TESTROM) $(SIMTESTS)

td-vhdl: $(TESTROM) $(REFSRC)
	python3 tools/gen_td_vhdl.py --decode microcode --program $(TESTROM)

$(REF_VERILOG): tools/ref_microcode_synth.sh tools/gen_td_vhdl.py fpga/j2_cpu_flat.vhd $(REFSRC)
	tools/ref_microcode_synth.sh

$(REF_SIM): $(REF_VERILOG) $(ARCHIVE)/tests/ref/tb_ref_cpu.cpp \
		$(ARCHIVE)/sim/common/sysmodel.h $(ARCHIVE)/sim/common/wbslave.h
	mkdir -p $(REF_BUILD)
	tools/local/bin/verilator --cc --exe --build -j 4 -O2 --x-assign fast --x-initial fast \
		-Wno-fatal -Wno-lint -Wno-style --prefix Vref_cpu --top-module j2_cpu_flat \
		-Mdir $(REF_BUILD)/obj -o ../Vref_cpu -CFLAGS "-O2 -I$(CURDIR)/$(ARCHIVE)/sim/common" \
		$(REF_VERILOG) $(CURDIR)/$(ARCHIVE)/tests/ref/tb_ref_cpu.cpp

reference-verif: $(REF_SIM) $(TESTROM) $(CURDIR)/build/sw/simtests/rte.bin
	$(REF_SIM) $(TESTROM) --quiet --expect "CPU tests passed" --expect "GDB Stub" --max-cycles 3000000
	$(REF_SIM) $(CURDIR)/build/sw/simtests/rte.bin --quiet

reference-fpga: $(TESTROM) $(REFSRC)
	TD_HOME="$(TD_HOME)" J2_CPU=microcode J2_ROM="$(TESTROM)" tools/build_tang_primer_td.sh

spinal-fpga: $(TESTROM)
	TD_HOME="$(TD_HOME)" J2_CPU=spinal J2_ROM="$(TESTROM)" tools/build_tang_primer_td.sh

spinal-executor-fpga: $(TESTROM)
	TD_HOME="$(TD_HOME)" J2_CPU=spinal J2_ROM="$(TESTROM)" tools/build_tang_primer_td.sh

spinal-program: spinal-fpga
	TD_HOME="$(TD_HOME)" tools/program_tang_primer_td.sh
