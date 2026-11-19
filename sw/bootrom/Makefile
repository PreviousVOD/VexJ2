ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
BOARD ?= tang-primer
OUT ?= $(ROOT)/build/$(BOARD)/rom
CROSS ?= sh-none-elf-
CC := $(CROSS)gcc
J2_UART_BAUD ?= $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get uartBaud)
J2_SRAM_BYTES := $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get sramBytes)
EXTRA_CFLAGS ?=
CFLAGS := -m2 -mb -Os -Wall -Wextra -ffreestanding -fno-builtin -nostdlib \
  -I$(OUT) -include $(OUT)/board.h -DJ2_UART_BAUD=$(J2_UART_BAUD) $(EXTRA_CFLAGS)
OBJS := $(addprefix $(OUT)/,entry.o main.o uart.o flash.o image.o loader.o)

.PHONY: all board-config
all: $(OUT)/boot.hex $(OUT)/main.lst

board-config:
	python3 $(ROOT)/tools/board_config.py $(BOARD)

$(OUT)/board.h: board-config
	@mkdir -p $(OUT)
	@if [ "$(OUT)" != "$(ROOT)/build/$(BOARD)/rom" ]; then cmp -s $(ROOT)/build/$(BOARD)/rom/board.h $@ || cp $(ROOT)/build/$(BOARD)/rom/board.h $@; fi
	@test -s $@

$(OUT)/%.o: %.c $(OUT)/board.h $(wildcard *.h) Makefile
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/%.o: %.S $(OUT)/board.h Makefile
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/main.elf: $(OBJS) boot.x Makefile
	$(CC) -m2 -mb -nostdlib -Wl,--defsym=J2_SRAM_BYTES=$(J2_SRAM_BYTES) -T boot.x -Wl,-Map,$(OUT)/main.map $(OBJS) -lgcc -o $@
$(OUT)/main.bin: $(OUT)/main.elf
	$(CROSS)objcopy -O binary $< $@
$(OUT)/boot.hex: $(OUT)/main.bin $(ROOT)/tools/gen_verilog_rom.py
	python3 $(ROOT)/tools/gen_verilog_rom.py $< $@
$(OUT)/main.lst: $(OUT)/main.elf
	$(CROSS)objdump -d $< > $@
