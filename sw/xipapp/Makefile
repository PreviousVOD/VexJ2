ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
OUT := $(ROOT)/build/sw/xipapp
CROSS ?= $(if $(shell command -v sh-elf-gcc),sh-elf-,sh-none-elf-)
ENDIAN := $(if $(findstring sh-none-elf,$(CROSS)),-mb,)
CC := $(CROSS)gcc
J2_CLOCK_HZ ?= 32000000
CFLAGS := -m2 $(ENDIAN) -Os -Wall -ffreestanding -fno-builtin -nostdlib \
	-I$(ROOT)/sw/xiprom -DJ2_CLOCK_HZ=$(J2_CLOCK_HZ)
LOAD_ADDRESS ?=
LDFLAGS := -m2 $(ENDIAN) -nostdlib -T app.x -Wl,-Map,$(OUT)/main.map
ifneq ($(LOAD_ADDRESS),)
LDFLAGS += -Wl,--defsym=LOAD_ADDRESS=$(LOAD_ADDRESS)
endif
OBJS := $(addprefix $(OUT)/,entry.o main.o uart.o isa.o isa_asm.o)

all: $(OUT)/main.bin $(OUT)/main.lst

$(OUT)/entry.o: entry.S Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/main.o: main.c Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/isa.o: isa.c Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/isa_asm.o: isa.S Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/uart.o: $(ROOT)/sw/xiprom/uart.c Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/main.elf: $(OBJS) app.x Makefile
	$(CC) $(LDFLAGS) $(filter %.o,$^) -lgcc -o $@
$(OUT)/main.bin: $(OUT)/main.elf
	$(CROSS)objcopy -O binary $< $@
$(OUT)/main.lst: $(OUT)/main.elf
	$(CROSS)objdump -d $< > $@

clean:
	rm -rf $(OUT)
.PHONY: all clean
