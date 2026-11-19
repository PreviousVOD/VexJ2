ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
OUT ?= $(ROOT)/build/wukong-v1/rom
CROSS ?= sh-none-elf-
CC := $(CROSS)gcc
J2_UART_BAUD ?= 19200
EXTRA_CFLAGS ?=
CFLAGS := -m2 -mb -Os -Wall -Wextra -ffreestanding -fno-builtin -nostdlib \
  -I$(ROOT)/sw/xiprom -I$(OUT) -include $(OUT)/board.h -DJ2_UART_BAUD=$(J2_UART_BAUD) $(EXTRA_CFLAGS)
OBJS := $(OUT)/entry.o $(OUT)/main.o $(OUT)/uart.o $(OUT)/flash_probe.o $(OUT)/ddr_test.o $(OUT)/ddr_stack.o $(OUT)/image.o $(OUT)/loader.o

.PHONY: all
all: $(OUT)/boot.hex $(OUT)/main.lst

$(OUT)/board.h: $(ROOT)/fpga/wukong-v1/board.properties $(ROOT)/tools/wukong_config.py
	python3 $(ROOT)/tools/wukong_config.py
	@mkdir -p $(OUT)
	@if [ "$(OUT)" != "$(ROOT)/build/wukong-v1/rom" ]; then cp $(ROOT)/build/wukong-v1/rom/board.h $@; fi

$(OUT)/image.o: image.c image.h $(OUT)/board.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/loader.o: loader.c image.h flash.h $(OUT)/board.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/entry.o: $(ROOT)/sw/xiprom/entry.S $(OUT)/board.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/main.o: main.c $(ROOT)/sw/xiprom/uart.h $(OUT)/board.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/ddr_test.o: ddr_test.c $(OUT)/board.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/ddr_stack.o: ddr_stack.S $(OUT)/board.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/flash_probe.o: flash_probe.c $(OUT)/board.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/uart.o: $(ROOT)/sw/xiprom/uart.c $(ROOT)/sw/xiprom/uart.h $(OUT)/board.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/main.elf: $(OBJS) $(ROOT)/sw/xiprom/boot.x Makefile
	$(CC) -m2 -mb -nostdlib -T $(ROOT)/sw/xiprom/boot.x -Wl,-Map,$(OUT)/main.map $(OBJS) -lgcc -o $@
$(OUT)/main.bin: $(OUT)/main.elf
	$(CROSS)objcopy -O binary $< $@
$(OUT)/boot.hex: $(OUT)/main.bin $(ROOT)/tools/gen_verilog_rom.py
	python3 $(ROOT)/tools/gen_verilog_rom.py $< $@
$(OUT)/main.lst: $(OUT)/main.elf
	$(CROSS)objdump -d $< > $@
