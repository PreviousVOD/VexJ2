# Build the ORIGINAL simulator tests (reference/.../cpu/sim/tests) unchanged:
# interrupts.S, rte.S. They report through TEST_RESULT (0xBCDE0010) and use
# the event trigger at 0xBCDE0000. Output: build/sw/simtests/<name>.bin
ROOT   := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
SRC    := $(ROOT)/reference/soc_top/components/cpu/sim/tests
OUT    := $(ROOT)/build/sw/simtests
CROSS  ?= $(if $(shell command -v sh-elf-gcc),sh-elf-,sh-none-elf-)
ENDIAN := $(if $(findstring sh-none-elf,$(CROSS)),-mb,)
CC     := $(CROSS)gcc
TESTS  := interrupts rte

all: $(addprefix $(OUT)/,$(addsuffix .bin,$(TESTS)) $(addsuffix .lst,$(TESTS)))

$(OUT)/%.o: $(SRC)/%.S
	@mkdir -p $(@D)
	$(CC) -m2 $(ENDIAN) -g -Wall -I$(SRC) -c $< -o $@
$(OUT)/%.elf: $(OUT)/%.o
	$(CC) -m2 $(ENDIAN) -nostdlib -T $(SRC)/sh32.x $< -lgcc -o $@
$(OUT)/%.bin: $(OUT)/%.elf
	$(CROSS)objcopy -S -O binary $< $@
$(OUT)/%.lst: $(OUT)/%.elf
	$(CROSS)objdump -d $< > $@
clean:
	rm -rf $(OUT)
.PHONY: all clean
.PRECIOUS: $(OUT)/%.o $(OUT)/%.elf
