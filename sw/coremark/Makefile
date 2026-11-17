ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
UPSTREAM := $(ROOT)/third_party/coremark
CROSS ?= sh-none-elf-
CC := $(CROSS)gcc
J2_CLOCK_HZ ?= 32000000
ITERATIONS ?= 1
RUN ?= performance
ifneq ($(filter $(RUN),performance validation),$(RUN))
$(error RUN must be performance or validation)
endif
OUT := $(ROOT)/build/sw/coremark/$(J2_CLOCK_HZ)/$(RUN)-$(ITERATIONS)
SIM_OUT := $(ROOT)/build/sw/coremark-sim/$(J2_CLOCK_HZ)/$(RUN)-$(ITERATIONS)
FLAGS := -m2 -mb -O2 -Wall -Wextra -ffreestanding -fno-builtin -fno-lto -nostdlib
DEFINES := -DJ2_CLOCK_HZ=$(J2_CLOCK_HZ) -DITERATIONS=$(ITERATIONS) \
  -DTOTAL_DATA_SIZE=2000 -D$(shell echo $(RUN) | tr a-z A-Z)_RUN=1
CFLAGS := $(FLAGS) $(DEFINES) -I. -I$(UPSTREAM) -I$(ROOT)/sw/xiprom \
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
	$(CC) $(FLAGS) -T coremark_sim.x -Wl,-Map,$(SIM_OUT)/main.map \
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
$(OUT)/uart.o: $(ROOT)/sw/xiprom/uart.c $(ROOT)/sw/xiprom/uart.h Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/main.elf: $(OBJS) coremark.x Makefile
	$(CC) $(FLAGS) -T coremark.x -Wl,-Map,$(OUT)/main.map $(OBJS) -lgcc -o $@
$(OUT)/main.bin: $(OUT)/main.elf
	$(CROSS)objcopy -O binary $< $@
$(OUT)/flash.bin: $(OUT)/main.bin $(ROOT)/tools/xip_image.py
	python3 $(ROOT)/tools/xip_image.py pack $< $@
$(OUT)/main.lst: $(OUT)/main.elf
	$(CROSS)objdump -d $< > $@
