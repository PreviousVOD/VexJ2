# Build the original J-Core CPU test ROM into build/sw/testrom.
# CROSS defaults to Debian's sh-elf- (big-endian); the repository-local
# sh-none-elf- toolchain also works (it defaults to little-endian, so -mb).
ROOT    := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
SRC     := $(ROOT)/sw/testrom/original
OUT     := $(ROOT)/build/sw/testrom
CROSS   ?= $(if $(shell command -v sh-elf-gcc),sh-elf-,sh-none-elf-)
ENDIAN  := $(if $(findstring sh-none-elf,$(CROSS)),-mb,)
CC      := $(CROSS)gcc
BOARD ?= tang-primer
J2_CLOCK_HZ ?= $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get clockHz)
J2_SCI_BASE := $(shell python3 $(ROOT)/tools/board_config.py $(BOARD) --get sciBase)
CFLAGS  := -m2 $(ENDIAN) -g -Os -Wall -Wno-builtin-declaration-mismatch \
           -Wno-implicit-function-declaration -fno-builtin -ffreestanding -DJ2_CLOCK_HZ=$(J2_CLOCK_HZ) -DJ2_SCI_BASE=$(J2_SCI_BASE) -I$(ROOT)/sw/include -I$(ROOT)/sw/bootrom
LDFLAGS := -m2 $(ENDIAN) -nostdlib -T $(SRC)/startup/sh32.x -Wl,-Map,$(OUT)/main.map

UART    ?= uartlite
OBJS  := entry.o gdb.o sh2.o main.o version.o $(UART).o
ifeq ($(UART),uart16550)
OBJS += sci_uart.o
endif
TESTS := testbra testmov testmov2 testalu testshift testmul testmulu testmuls testmull \
         testdmulu testdmuls testmulconf testdiv testmacw testmacl
OBJS  := $(addprefix $(OUT)/,$(OBJS) $(addprefix tests/,$(addsuffix .o,$(TESTS))))

all: $(OUT)/main.bin $(OUT)/main.lst

$(OUT)/version.c:
	@mkdir -p $(@D)
	printf 'char version_string[] = "revision: open\\nbuild: j2 rewrite\\n";\n' > $@
$(OUT)/version.o: $(OUT)/version.c
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/main.o: $(SRC)/main.c Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -fno-inline -c $< -o $@
$(OUT)/sci_uart.o: $(ROOT)/sw/bootrom/uart.c $(ROOT)/sw/bootrom/uart.h $(ROOT)/sw/include/sci.h Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/uart16550.o: $(ROOT)/sw/testrom/uart16550.c Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/%.o: $(SRC)/%.c Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/tests/%.o: $(SRC)/tests/%.s Makefile
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -Wa,-isa=sh2 -c $< -o $@

$(OUT)/main.elf: $(OBJS) Makefile $(SRC)/startup/sh32.x
	$(CC) $(LDFLAGS) $(filter %.o,$^) -lgcc -o $@
$(OUT)/main.bin: $(OUT)/main.elf
	$(CROSS)objcopy -O binary $< $@
$(OUT)/main.lst: $(OUT)/main.elf
	$(CROSS)objdump -d $< > $@

clean:
	rm -rf $(OUT)
.PHONY: all clean

$(OBJS): $(ROOT)/fpga/$(BOARD)/board.properties $(ROOT)/tools/board_config.py
