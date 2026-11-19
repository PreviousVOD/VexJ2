TOOLS_PREFIX := $(CURDIR)/tools/local
TOOLCHAIN_SCRIPT := tools/third_party/build-tools.sh
TOOL_SBT := $(TOOLS_PREFIX)/bin/sbt
TOOL_VERILATOR := $(TOOLS_PREFIX)/bin/verilator
TOOL_SH_GCC := $(TOOLS_PREFIX)/sh-none-elf/bin/sh-none-elf-gcc
SBT ?= $(TOOL_SBT)
VERILATOR ?= $(TOOL_VERILATOR)
SPINAL_DIR := spinal
SPINAL_OUT := build/spinal/verilog
TD_HOME ?=
J2_CLOCK_HZ ?= 32000000
export J2_CLOCK_HZ
TESTROM := $(CURDIR)/build/sw/testrom/main.bin
TESTROM16550 := $(CURDIR)/build/sw/testrom16550/main.bin
BOOTROM := $(CURDIR)/build/sw/xiprom/main.bin
XIP_ROM := $(CURDIR)/build/verilog/xip/j2_validation_rom.hex
XIPAPP := $(CURDIR)/build/sw/xipapp/main.bin
XIP_IMAGE := $(CURDIR)/build/sw/xipapp/flash.bin
# About 16 seconds per seed set on the cached 32 MHz core.
COREMARK_ITERATIONS ?= 300
COREMARK_LABEL ?= refactored
COREMARK_RESULTS ?= build/coremark/$(COREMARK_LABEL)
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

CROSS ?= sh-none-elf-
export CROSS
export PATH := $(TOOLS_PREFIX)/bin:$(TOOLS_PREFIX)/sh-none-elf/bin:$(PATH)

.PHONY: all toolchain toolchain-sbt toolchain-verilator toolchain-sh \
	spinal-test spinal-generate spinal-clean spinal-verif spinal-microcode-verif spinal-hw-sim \
	reference-verif spinal-fpga spinal-program sw td-vhdl \
	microcode-data microcode-mif verilog-hw-sim verilog-fpga verilog-program \
	xip-hw-sim xip-upload fpga-clock-test

all: spinal-test spinal-generate

# The normal XIP application includes the ISA/pipeline regression suite.
# Hardware validation programs volatile FPGA SRAM and dedicated application
# flash, then verifies both the upload boot and a fresh JTAG reboot.
.PHONY: isa-sim isa-hw
isa-sim: spinal-test $(BOOTROM) $(XIP_IMAGE) $(TOOL_VERILATOR)
	$(MAKE) spinal-microcode-verif
	$(MAKE) -C verilog xip-sim-build
	python3 tools/isa_validation.py sim

isa-hw: verilog-fpga
	$(MAKE) fpga-clock-test
	python3 tools/isa_validation.py hardware

.PHONY: coremark-build coremark-sim coremark-fpga-build coremark-hw coremark-compare
coremark-build: $(TOOL_SH_GCC)
	$(MAKE) -C sw/coremark ITERATIONS=$(COREMARK_ITERATIONS) RUN=performance
	$(MAKE) -C sw/coremark ITERATIONS=$(COREMARK_ITERATIONS) RUN=validation

coremark-sim: coremark-build $(BOOTROM) $(XIP_IMAGE) $(TOOL_VERILATOR)
	$(MAKE) -C verilog xip-sim-build
	python3 tools/coremark.py sim --iterations $(COREMARK_ITERATIONS) --output $(COREMARK_RESULTS)/simulation

coremark-fpga-build: coremark-build verilog-fpga
	$(MAKE) fpga-clock-test

coremark-hw: coremark-build
	python3 tools/coremark.py hardware --iterations $(COREMARK_ITERATIONS) --output $(COREMARK_RESULTS)/hardware

coremark-compare:
	python3 tools/coremark.py compare $(COREMARK_BASELINE) $(COREMARK_CANDIDATE)

toolchain: toolchain-sbt toolchain-verilator toolchain-sh
toolchain-sbt: $(TOOL_SBT)
toolchain-verilator: $(TOOL_VERILATOR)
toolchain-sh: $(TOOL_SH_GCC)

$(TOOL_SBT): $(TOOLCHAIN_SCRIPT)
	$(TOOLCHAIN_SCRIPT) sbt

$(TOOL_VERILATOR): $(TOOLCHAIN_SCRIPT)
	$(TOOLCHAIN_SCRIPT) verilator

$(TOOL_SH_GCC): $(TOOLCHAIN_SCRIPT)
	$(TOOLCHAIN_SCRIPT) sh-toolchain

spinal-test spinal-generate: $(TOOL_SBT)
spinal-verif spinal-microcode-verif verilog-hw-sim xip-hw-sim reference-verif fpga-clock-test: $(TOOL_VERILATOR)
$(TESTROM) $(TESTROM16550) $(SIMTESTS) $(BOOTROM) $(XIPAPP): | $(TOOL_SH_GCC)

spinal-test: microcode-data
	cd $(SPINAL_DIR) && $(SBT) -batch test

spinal-generate: microcode-data $(XIP_ROM)
	mkdir -p $(SPINAL_OUT)
	cd $(SPINAL_DIR) && $(SBT) -batch "runMain j2.Generate"

# Wukong builds its platform ROM, quad SF3 interface and MIG DDR integration.
# No implicit programming or shared-flash writes.
VIVADO_HOME ?= /home/imi415/Softwares/Tools/Xilinx/2025.2/Vivado
.PHONY: wukong-rom wukong-generate wukong-synth wukong-bitstream wukong-sim wukong-reset-sim wukong-program wukong-uart
wukong-rom: $(TOOL_SH_GCC)
	python3 tools/wukong_config.py
	$(MAKE) -C sw/wukongrom

wukong-generate: wukong-rom microcode-data $(TOOL_SBT)
	cd $(SPINAL_DIR) && $(SBT) -batch "runMain j2.GenerateWukong"

wukong-synth: wukong-mig wukong-generate
	VIVADO_HOME="$(VIVADO_HOME)" bash tools/build_wukong.sh

wukong-bitstream: wukong-synth
	VIVADO_HOME="$(VIVADO_HOME)" bash tools/implement_wukong.sh

wukong-sim: wukong-boot-sim

wukong-reset-sim: wukong-synth
	mkdir -p build/wukong-v1/reset_sim
	rm -f build/wukong-v1/reset_sim/validation.pass
	cd build/wukong-v1/reset_sim && VIVADO_HOME="$(VIVADO_HOME)" bash "$(CURDIR)/tools/run_vivado.sh" \
		-mode batch -notrace -source "$(CURDIR)/tools/check_wukong_reset.tcl" -log driver.log -journal driver.jou
	test -s build/wukong-v1/reset_sim/validation.pass

# Requires an explicitly supplied, implemented and validated bitstream.
wukong-program:
	test -n "$(WUKONG_BITSTREAM)" && test -f "$(WUKONG_BITSTREAM)"
	mkdir -p build/wukong-v1/program
	rm -f build/wukong-v1/program/program.pass
	cd build/wukong-v1/program && VIVADO_HOME="$(VIVADO_HOME)" bash "$(CURDIR)/tools/run_vivado.sh" -mode batch -notrace \
		-source "$(CURDIR)/tools/program_wukong.tcl" -tclargs "$(abspath $(WUKONG_BITSTREAM))"
	test -s build/wukong-v1/program/program.pass

wukong-uart:
	VIVADO_HOME="$(VIVADO_HOME)" python3 tools/check_wukong_uart.py

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

$(TESTROM): $(REFSRC) sw/testrom/Makefile \
		$(wildcard sw/testrom/original/*.c sw/testrom/original/*.h sw/testrom/original/tests/*.s sw/testrom/original/startup/*.x)
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

$(REF_SIM): $(REF_VERILOG) $(REF_SIM_SRC) $(REF_COMMON)/sysmodel.h $(REF_COMMON)/wbslave.h $(TOOL_VERILATOR)
	mkdir -p $(REF_BUILD)
	$(VERILATOR) --cc --exe --build -j 4 -O2 --x-assign fast --x-initial fast \
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
		$(if $(TD_HOME),--td-home "$(TD_HOME)") --clock-hz "$(J2_CLOCK_HZ)"

spinal-program: verilog-program

verilog-hw-sim: $(TESTROM16550)
	$(MAKE) -C verilog test

$(BOOTROM): $(wildcard sw/xiprom/*)
	$(MAKE) -C sw/xiprom

$(XIP_ROM): $(BOOTROM) tools/gen_verilog_rom.py
	python3 tools/gen_verilog_rom.py $(BOOTROM) $@

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

.PHONY: wukong-mig wukong-ddr-generate wukong-ddr-sim wukong-ddr-bitstream
wukong-mig:
	mkdir -p build/wukong-v1/ddr
	rm -f build/wukong-v1/ddr/generation.pass build/wukong-v1/ddr/implementation.pass
	cd build/wukong-v1/ddr && VIVADO_HOME="$(VIVADO_HOME)" bash "$(CURDIR)/tools/run_vivado.sh" -mode batch -notrace \
		-source "$(CURDIR)/tools/generate_wukong_mig.tcl" -log generate.log -journal generate.jou
	test -s build/wukong-v1/ddr/generation.pass

wukong-ddr-generate: $(TOOL_SBT)
	cd $(SPINAL_DIR) && $(SBT) -batch "runMain j2.GenerateWukongDdr"

wukong-ddr-sim: $(TOOL_SBT) $(TOOL_VERILATOR)
	cd $(SPINAL_DIR) && $(SBT) -batch "testOnly j2.board.WukongDdrBistSpec"

wukong-ddr-bitstream: wukong-mig wukong-ddr-generate
	cd build/wukong-v1/ddr && VIVADO_HOME="$(VIVADO_HOME)" bash "$(CURDIR)/tools/run_vivado.sh" -mode batch -notrace \
		-source "$(CURDIR)/tools/build_wukong_ddr.tcl" -log implementation.log -journal implementation.jou
	test -s build/wukong-v1/ddr/implementation.pass

.PHONY: wukong-ddr-uart
wukong-ddr-uart:
	VIVADO_HOME="$(VIVADO_HOME)" python3 tools/check_wukong_uart.py --ddr

.PHONY: wukong-bridge-sim
wukong-bridge-sim: $(TOOL_SBT) $(TOOL_VERILATOR)
	cd $(SPINAL_DIR) && $(SBT) -batch "testOnly j2.bus.J2WishboneDdrBridgeSpec"

# The simulation firmware changes only baud and host-response timeouts, keeping
# FPGA and simulated ROMs in separate output trees.
.PHONY: wukong-apps wukong-boot-sim wukong-image-test
wukong-apps: $(TOOL_SH_GCC)
	$(MAKE) -C sw/xipapp OUT=$(CURDIR)/build/wukong-v1/app-xip
	python3 tools/xip_image.py pack build/wukong-v1/app-xip/main.bin build/wukong-v1/app-xip/flash.bin
	$(MAKE) -C sw/xipapp OUT=$(CURDIR)/build/wukong-v1/app-ddr LOAD_ADDRESS=0x80400000
	python3 tools/xip_image.py pack build/wukong-v1/app-ddr/main.bin build/wukong-v1/app-ddr/flash.bin --load-address 0x80400000

wukong-boot-sim: wukong-probes wukong-rom microcode-data $(TOOL_SBT) $(TOOL_VERILATOR)
	$(MAKE) -C sw/wukongrom OUT=$(CURDIR)/build/wukong-v1/rom-sim J2_UART_BAUD=1600000 EXTRA_CFLAGS='-DBOOT_WAIT_US=1000 -DRECEIVE_WAIT_US=10000'
	$(MAKE) -C sw/xipapp OUT=$(CURDIR)/build/wukong-v1/app-sim-xip J2_UART_BAUD=1600000
	python3 tools/xip_image.py pack build/wukong-v1/app-sim-xip/main.bin build/wukong-v1/app-sim-xip/flash.bin
	$(MAKE) -C sw/xipapp OUT=$(CURDIR)/build/wukong-v1/app-sim-ddr LOAD_ADDRESS=0x80400000 J2_UART_BAUD=1600000
	python3 tools/xip_image.py pack build/wukong-v1/app-sim-ddr/main.bin build/wukong-v1/app-sim-ddr/flash.bin --load-address 0x80400000
	cd $(SPINAL_DIR) && $(SBT) -batch "Test / runMain j2.board.WukongBootSim"

wukong-image-test: wukong-rom
	python3 tools/test_wukong_image.py

.PHONY: wukong-probes
wukong-probes: $(TOOL_SH_GCC)
	mkdir -p build/wukong-v1/probe-xip build/wukong-v1/probe-ddr
	sh-none-elf-gcc -m2 -mb -nostdlib -T sw/xipapp/app.x sw/wukongrom/test/probe.S -o build/wukong-v1/probe-xip/main.elf
	sh-none-elf-objcopy -O binary build/wukong-v1/probe-xip/main.elf build/wukong-v1/probe-xip/main.bin
	python3 tools/xip_image.py pack build/wukong-v1/probe-xip/main.bin build/wukong-v1/probe-xip/flash.bin
	sh-none-elf-gcc -m2 -mb -nostdlib -T sw/xipapp/app.x -Wl,--defsym=LOAD_ADDRESS=0x80400000 sw/wukongrom/test/probe.S -o build/wukong-v1/probe-ddr/main.elf
	sh-none-elf-objcopy -O binary build/wukong-v1/probe-ddr/main.elf build/wukong-v1/probe-ddr/main.bin
	python3 tools/xip_image.py pack build/wukong-v1/probe-ddr/main.bin build/wukong-v1/probe-ddr/flash.bin --load-address 0x80400000

# Replaces only SF3 application sectors after saving a read-only sector backup.
.PHONY: wukong-boot-hw
wukong-boot-hw: wukong-bitstream wukong-apps
	VIVADO_HOME="$(VIVADO_HOME)" python3 tools/check_wukong_boot.py --upload --image build/wukong-v1/app-ddr/flash.bin --output build/wukong-v1/boot/ddr-upload
	VIVADO_HOME="$(VIVADO_HOME)" python3 tools/check_wukong_boot.py --image build/wukong-v1/app-ddr/flash.bin --output build/wukong-v1/boot/ddr-warm
	VIVADO_HOME="$(VIVADO_HOME)" python3 tools/check_wukong_boot.py --upload --image build/wukong-v1/app-xip/flash.bin --output build/wukong-v1/boot/xip-upload
	VIVADO_HOME="$(VIVADO_HOME)" python3 tools/check_wukong_boot.py --image build/wukong-v1/app-xip/flash.bin --output build/wukong-v1/boot/xip-warm
