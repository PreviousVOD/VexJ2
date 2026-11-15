SBT ?= $(CURDIR)/tools/local/bin/sbt
SPINAL_DIR := spinal
SPINAL_OUT := build/spinal/verilog
TD_HOME ?= /home/imi415/Softwares/Tools/TD_4.6.7_Linux
J2_CLOCK_HZ ?= 30000000
export J2_CLOCK_HZ
TESTROM := $(CURDIR)/build/sw/testrom/main.bin
TESTROM16550 := $(CURDIR)/build/sw/testrom16550/main.bin
BOOTROM := $(CURDIR)/build/sw/xiprom/main.bin
XIPAPP := $(CURDIR)/build/sw/xipapp/main.bin
XIP_IMAGE := $(CURDIR)/build/sw/xipapp/flash.bin
SIMTESTS := $(CURDIR)/build/sw/simtests/rte.bin $(CURDIR)/build/sw/simtests/interrupts.bin
REFSRC := reference/soc_top/components/cpu/cpu2j0_pkg.vhd
REF_BUILD := $(CURDIR)/build/ref_microcode
REF_VERILOG := $(REF_BUILD)/j2_cpu_flat.v
REF_SIM := $(REF_BUILD)/Vref_cpu
REF_SIM_SRC := verilog/verif/ref_cpu.cpp
REF_COMMON := verilog/verif/common
MICROCODE_HEX := spinal/src/main/resources/j2_microcode.hex
MICROCODE_PREDECODE := spinal/src/main/resources/j2_predecode.tsv
MICROCODE_MIF := build/microcode/j2_microcode.mif

export PATH := $(PATH):$(CURDIR)/tools/local/bin:$(CURDIR)/tools/local/sh-none-elf/bin

.PHONY: all spinal-test spinal-generate spinal-clean spinal-verif spinal-microcode-verif spinal-hw-sim \
	reference-verif spinal-fpga spinal-program sw td-vhdl \
	microcode-data microcode-mif verilog-hw-sim verilog-fpga verilog-program \
	xip-hw-sim xip-upload fpga-clock-test

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

spinal-hw-sim: verilog-hw-sim

spinal-clean:
	rm -rf $(SPINAL_OUT) $(SPINAL_DIR)/target $(SPINAL_DIR)/project/target

$(MICROCODE_HEX) $(MICROCODE_PREDECODE) &: $(REFSRC) tools/gen_microcode_data.py
	python3 tools/gen_microcode_data.py

$(MICROCODE_MIF): $(REFSRC) tools/gen_microcode_data.py
	python3 tools/gen_microcode_data.py --mif $@

microcode-data: $(MICROCODE_HEX) $(MICROCODE_PREDECODE)
microcode-mif: $(MICROCODE_MIF)

$(TESTROM): $(REFSRC) sw/testrom/Makefile
	$(MAKE) -C sw/testrom

$(TESTROM16550): $(REFSRC) sw/testrom/Makefile sw/testrom/uart16550.c \
		$(wildcard sw/testrom/original/*.c sw/testrom/original/*.h sw/testrom/original/tests/*.s sw/testrom/original/startup/*.x)
	$(MAKE) -C sw/testrom OUT=$(CURDIR)/build/sw/testrom16550 UART=uart16550

$(SIMTESTS) &: $(REFSRC)
	$(MAKE) -C sw/simtests

sw: $(TESTROM) $(SIMTESTS)

td-vhdl: $(TESTROM) $(REFSRC)
	python3 tools/gen_td_vhdl.py --decode microcode --program $(TESTROM)

$(REF_VERILOG): tools/ref_microcode_synth.sh tools/gen_td_vhdl.py tools/fix_ghdl_verilog.py \
		reference/j2_cpu_flat.vhd $(REFSRC)
	tools/ref_microcode_synth.sh

$(REF_SIM): $(REF_VERILOG) $(REF_SIM_SRC) $(REF_COMMON)/sysmodel.h $(REF_COMMON)/wbslave.h
	mkdir -p $(REF_BUILD)
	tools/local/bin/verilator --cc --exe --build -j 4 -O2 --x-assign fast --x-initial fast \
		-Wno-fatal -Wno-lint -Wno-style --prefix Vref_cpu --top-module j2_cpu_flat \
		-Mdir $(REF_BUILD)/obj -o ../Vref_cpu -CFLAGS "-O2 -I$(CURDIR)/$(REF_COMMON)" \
		$(REF_VERILOG) $(CURDIR)/$(REF_SIM_SRC)

reference-verif: $(REF_SIM) $(TESTROM) $(CURDIR)/build/sw/simtests/rte.bin
	$(REF_SIM) $(TESTROM) --quiet --expect "CPU tests passed" --expect "GDB Stub" --max-cycles 3000000
	$(REF_SIM) $(CURDIR)/build/sw/simtests/rte.bin --quiet

spinal-fpga: verilog-fpga

# Run after generating FPGA RTL (make verilog-fpga). This uses the vendor PLL
# model; the normal SoC simulation deliberately bypasses that primitive.
fpga-clock-test:
	python3 tools/check_fpga_clock.py --rtl build/spinal/verilog-fpga/j2_tang_primer.v \
		--td-home "$(TD_HOME)" --clock-hz "$(J2_CLOCK_HZ)"

spinal-program: verilog-program

verilog-hw-sim: $(TESTROM16550)
	$(MAKE) -C verilog test

$(BOOTROM): $(wildcard sw/xiprom/*)
	$(MAKE) -C sw/xiprom

$(XIPAPP): $(wildcard sw/xipapp/*)
	$(MAKE) -C sw/xipapp

$(XIP_IMAGE): $(XIPAPP) tools/xip_image.py
	tools/xip_image.py pack $(XIPAPP) $@

xip-hw-sim: $(BOOTROM) $(XIP_IMAGE)
	$(MAKE) -C verilog xip-test

xip-upload: $(XIP_IMAGE)
	tools/xip_image.py upload $(XIP_IMAGE)

verilog-fpga: $(BOOTROM) $(XIP_IMAGE)
	TD_HOME="$(TD_HOME)" J2_ROM="$(BOOTROM)" tools/build_tang_primer_verilog_td.sh

verilog-program: verilog-fpga
	TD_HOME="$(TD_HOME)" tools/program_tang_primer_verilog_td.sh
