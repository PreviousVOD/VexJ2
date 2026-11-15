ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
OUT := $(ROOT)/build/sw/xiprom
CROSS ?= $(if $(shell command -v sh-elf-gcc),sh-elf-,sh-none-elf-)
ENDIAN := $(if $(findstring sh-none-elf,$(CROSS)),-mb,)
CC := $(CROSS)gcc
CFLAGS := -m2 $(ENDIAN) -Os -Wall -ffreestanding -fno-builtin -nostdlib
LDFLAGS := -m2 $(ENDIAN) -nostdlib -T boot.x -Wl,-Map,$(OUT)/main.map
OBJS := $(addprefix $(OUT)/,entry.o main.o uart.o flash.o)

all: $(OUT)/main.bin $(OUT)/main.lst

$(OUT)/entry.o: entry.S
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/main.elf: $(OBJS) boot.x Makefile
	$(CC) $(LDFLAGS) $(filter %.o,$^) -lgcc -o $@
$(OUT)/main.bin: $(OUT)/main.elf
	$(CROSS)objcopy -O binary $< $@
$(OUT)/main.lst: $(OUT)/main.elf
	$(CROSS)objdump -d $< > $@

clean:
	rm -rf $(OUT)
.PHONY: all clean
