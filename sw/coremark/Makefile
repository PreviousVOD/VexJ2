ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
BOARD ?= tang-primer
UPSTREAM := $(ROOT)/third_party/coremark
CROSS ?= sh-none-elf-
CC := $(CROSS)gcc
ifndef J2_CLOCK_HZ
J2_CLOCK_HZ := $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get clockHz)
endif
J2_SRAM_BYTES := $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get sramBytes)
ITERATIONS ?= 300
RUN ?= performance
ifneq ($(filter $(RUN),performance validation),$(RUN))
$(error RUN must be performance or validation)
endif
OUT := $(ROOT)/build/sw/coremark/$(BOARD)/$(J2_CLOCK_HZ)/$(RUN)-$(ITERATIONS)
SIM_OUT := $(ROOT)/build/sw/coremark-sim/$(BOARD)/$(J2_CLOCK_HZ)/$(RUN)-$(ITERATIONS)
FLAGS := -m2 -mb -O2 -Wall -Wextra -ffreestanding -fno-builtin -fno-lto -nostdlib
J2_SCIF_BASE := $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get scifBase)
J2_CMT_BASE := $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get cmtBase)
DEFINES := -DJ2_SRAM_BYTES=$(J2_SRAM_BYTES) -DJ2_CLOCK_HZ=$(J2_CLOCK_HZ) -DJ2_SCIF_BASE=$(J2_SCIF_BASE) -DJ2_CMT_BASE=$(J2_CMT_BASE) -DITERATIONS=$(ITERATIONS) \
  -DTOTAL_DATA_SIZE=2000 -D$(shell echo $(RUN) | tr a-z A-Z)_RUN=1
CFLAGS := $(FLAGS) $(DEFINES) -I. -I$(UPSTREAM) -I$(ROOT)/sw/include -I$(ROOT)/sw/bootrom \
  '-DJ2_COMPILER_FLAGS="$(FLAGS) $(DEFINES)"'
SOURCES := core_list_join core_main core_matrix core_state core_util
OBJS := $(addprefix $(OUT)/,$(addsuffix .o,$(SOURCES))) $(OUT)/core_portme.o $(OUT)/entry.o $(OUT)/uart.o

.PHONY: all check-sources sim
all: check-sources $(OUT)/flash.bin $(OUT)/main.lst

check-sources:
	python3 $(ROOT)/tools/coremark.py check-sources

sim: check-sources $(SIM_OUT)/main.bin $(SIM_OUT)/main.lst

$(SIM_OUT)/sim_entry.o: sim_entry.S Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(SIM_OUT)/main.elf: $(OBJS) $(SIM_OUT)/sim_entry.o coremark_sim.x Makefile
	@mkdir -p $(@D)
	$(CC) $(FLAGS) -Wl,--defsym=J2_SRAM_BYTES=$(J2_SRAM_BYTES) -T coremark_sim.x -Wl,-Map,$(SIM_OUT)/main.map \
		$(OBJS) $(SIM_OUT)/sim_entry.o -lgcc -o $@
$(SIM_OUT)/main.bin: $(SIM_OUT)/main.elf
	$(CROSS)objcopy -O binary $< $@
$(SIM_OUT)/main.lst: $(SIM_OUT)/main.elf
	$(CROSS)objdump -d $< > $@

$(OUT)/%.o: $(UPSTREAM)/%.c $(UPSTREAM)/coremark.h core_portme.h Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/core_portme.o: core_portme.c core_portme.h Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/entry.o: entry.S Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/uart.o: $(ROOT)/sw/bootrom/uart.c $(ROOT)/sw/bootrom/uart.h Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/main.elf: $(OBJS) coremark.x Makefile
	$(CC) $(FLAGS) -Wl,--defsym=J2_SRAM_BYTES=$(J2_SRAM_BYTES) -T coremark.x -Wl,-Map,$(OUT)/main.map $(OBJS) -lgcc -o $@
$(OUT)/main.bin: $(OUT)/main.elf
	$(CROSS)objcopy -O binary $< $@
$(OUT)/flash.bin: $(OUT)/main.bin $(ROOT)/tools/xip_image.py
	python3 $(ROOT)/tools/xip_image.py pack $< $@
$(OUT)/main.lst: $(OUT)/main.elf
	$(CROSS)objdump -d $< > $@

$(OBJS) $(SIM_OUT)/sim_entry.o: $(ROOT)/fpga/$(BOARD)/board.properties $(ROOT)/tools/board_config.py

$(OBJS): $(ROOT)/sw/include/cmt.h $(ROOT)/sw/include/scif.h

$(OBJS): $(ROOT)/sw/include/intc.h $(ROOT)/sw/include/j2_intc_regs.h

include $(ROOT)/sw/board-irqs.mk
