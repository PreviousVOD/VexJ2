ROOT := $(abspath $(CURDIR)/..)
VERILATOR ?= $(ROOT)/tools/local/bin/verilator
BUILD := $(ROOT)/build/verilog/verif
CPU := $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v
ROM := $(ROOT)/build/verilog/j2_validation_rom.hex
TESTROM := $(ROOT)/build/sw/testrom16550/main.bin
UART_DIR := $(ROOT)/third_party/uart16550/rtl/verilog
UART_SRC := $(wildcard $(UART_DIR)/*.v)
SCALA_SRC := $(wildcard $(ROOT)/spinal/src/main/scala/j2/*.scala) \
	$(wildcard $(ROOT)/spinal/src/main/scala/j2/*/*.scala)
SOC_SRC := $(ROOT)/verilog/j2_validation_rom.v \
	$(ROOT)/verilog/j2_pio.v \
	$(ROOT)/verilog/j2_uart16550.v \
	$(ROOT)/verilog/j2_soc.v \
	$(ROOT)/verilog/j2_tang_primer.v

.PHONY: all test clean

all: test

test: $(BUILD)/Vj2_tang_primer
	cd $(BUILD) && ./Vj2_tang_primer

$(BUILD)/Vj2_tang_primer: Makefile verif/j2_tang_primer_sim.cpp $(CPU) $(ROM) $(SOC_SRC) $(UART_SRC)
	mkdir -p $(BUILD)
	cp $(ROM) $(BUILD)/j2_validation_rom.hex
	cp $(ROOT)/build/spinal/verilog/J2MicrocodedCore.v_*.bin $(BUILD)/
	$(VERILATOR) --cc --exe --build -O2 --no-timing -Wno-fatal -Wno-lint -Wno-style \
		--top-module j2_tang_primer -I$(UART_DIR) -Mdir $(BUILD)/obj \
		-o ../Vj2_tang_primer $(CPU) $(SOC_SRC) $(UART_SRC) \
		$(ROOT)/verilog/verif/j2_tang_primer_sim.cpp

$(CPU): $(SCALA_SRC) $(ROOT)/spinal/build.sbt
	$(MAKE) -C $(ROOT) spinal-generate

$(ROM): $(TESTROM) $(ROOT)/tools/gen_verilog_rom.py
	python3 $(ROOT)/tools/gen_verilog_rom.py $(TESTROM) $@

$(TESTROM): $(ROOT)/reference/soc_top/README
	$(MAKE) -C $(ROOT) $(TESTROM)

$(ROOT)/reference/soc_top/README: $(ROOT)/jcore-source-latest.tar.gz
	mkdir -p $(ROOT)/reference
	tar -xzf $< -C $(ROOT)/reference
	chmod -R a-w $(ROOT)/reference/soc_top
	touch $@

clean:
	rm -rf $(BUILD) $(ROM)
