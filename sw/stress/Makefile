# Lockstep stress program (stress.S + the original CPU self-test routines).
ROOT   := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
TSRC   := $(ROOT)/sw/testrom/original
OUT    := $(ROOT)/build/sw/stress
CROSS  ?= $(if $(shell command -v sh-elf-gcc),sh-elf-,sh-none-elf-)
ENDIAN := $(if $(findstring sh-none-elf,$(CROSS)),-mb,)
CC     := $(CROSS)gcc
TESTS  := testbra testmov2 testalu testshift testmul testmulconf testdiv testmacw testmacl
OBJS   := $(OUT)/stress.o $(addprefix $(OUT)/,$(addsuffix .o,$(TESTS)))

all: $(OUT)/stress.bin $(OUT)/stress.lst
$(OUT)/stress.o: stress.S
	@mkdir -p $(@D)
	$(CC) -m2 $(ENDIAN) -g -c $< -o $@
$(OUT)/%.o: $(TSRC)/tests/%.s
	@mkdir -p $(@D)
	$(CC) -m2 $(ENDIAN) -g -Wa,-isa=sh2a -c $< -o $@
$(OUT)/stress.elf: $(OBJS) stress.x
	$(CC) -m2 $(ENDIAN) -nostdlib -T stress.x $(OBJS) -o $@
$(OUT)/stress.bin: $(OUT)/stress.elf
	$(CROSS)objcopy -O binary $< $@
$(OUT)/stress.lst: $(OUT)/stress.elf
	$(CROSS)objdump -d $< > $@
clean:
	rm -rf $(OUT)
.PHONY: all clean
