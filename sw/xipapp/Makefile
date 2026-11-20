ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
OUT := $(ROOT)/build/sw/xipapp
BOARD ?= tang-primer
J2_SRAM_BYTES := $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get sramBytes)
CROSS ?= $(if $(shell command -v sh-elf-gcc),sh-elf-,sh-none-elf-)
ENDIAN := $(if $(findstring sh-none-elf,$(CROSS)),-mb,)
CC := $(CROSS)gcc
ifndef J2_CLOCK_HZ
J2_CLOCK_HZ := $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get clockHz)
endif
J2_UART_BAUD ?= 19200
J2_SCI_BASE := $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get sciBase)
J2_CMT_BASE := $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get cmtBase)
CFLAGS := -m2 $(ENDIAN) -Os -Wall -ffreestanding -fno-builtin -nostdlib \
	-I$(ROOT)/sw/include -I$(ROOT)/sw/bootrom -DJ2_CLOCK_HZ=$(J2_CLOCK_HZ) -DJ2_SCI_BASE=$(J2_SCI_BASE) -DJ2_CMT_BASE=$(J2_CMT_BASE) -DJ2_UART_BAUD=$(J2_UART_BAUD) -DJ2_SRAM_BYTES=$(J2_SRAM_BYTES)
LDFLAGS := -m2 $(ENDIAN) -nostdlib -Wl,--defsym=J2_SRAM_BYTES=$(J2_SRAM_BYTES) -T app.x -Wl,-Map,$(OUT)/main.map
OBJS := $(addprefix $(OUT)/,entry.o main.o intc.o uart.o isa.o isa_asm.o)

all: $(OUT)/main.bin $(OUT)/main.lst

# Command-line clock/baud changes must invalidate reused output directories.
.PHONY: FORCE
FORCE:
$(OUT)/build-config: FORCE
	@mkdir -p $(@D)
	@printf '%s\n' '$(CC)' '$(CFLAGS)' '$(LDFLAGS)' > $@.tmp
	@cmp -s $@.tmp $@ && rm $@.tmp || mv $@.tmp $@
$(OBJS): $(OUT)/build-config

$(OUT)/entry.o: entry.S Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/main.o: main.c Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/intc.o: intc.c Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/isa.o: isa.c Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/isa_asm.o: isa.S Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/uart.o: $(ROOT)/sw/bootrom/uart.c Makefile
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

$(OBJS): $(ROOT)/fpga/$(BOARD)/board.properties $(ROOT)/tools/board_config.py

$(OBJS): $(ROOT)/sw/include/cmt.h $(ROOT)/sw/include/sci.h

$(OBJS): $(ROOT)/sw/include/intc.h $(ROOT)/sw/include/j2_intc_regs.h

include $(ROOT)/sw/board-irqs.mk
