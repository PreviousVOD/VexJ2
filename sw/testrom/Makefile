# Build the ORIGINAL J-Core CPU test ROM (reference/.../components/cpu/testrom)
# unchanged, into build/sw/testrom. Output: main.elf, main.bin (raw image
# loaded at address 0), main.lst (disassembly).
#
# CROSS defaults to Debian's sh-elf- (big-endian); the repository-local
# sh-none-elf- toolchain also works (it defaults to little-endian, so -mb).
ROOT    := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/../..)
SRC     := $(ROOT)/reference/soc_top/components/cpu/testrom
OUT     := $(ROOT)/build/sw/testrom
CROSS   ?= $(if $(shell command -v sh-elf-gcc),sh-elf-,sh-none-elf-)
ENDIAN  := $(if $(findstring sh-none-elf,$(CROSS)),-mb,)
CC      := $(CROSS)gcc
CFLAGS  := -m2 $(ENDIAN) -g -Os -Wall -Wno-builtin-declaration-mismatch -fno-builtin -ffreestanding
LDFLAGS := -m2 $(ENDIAN) -nostdlib -T $(SRC)/startup/sh32.x -Wl,-Map,$(OUT)/main.map

OBJS  := entry.o gdb.o sh2.o main.o version.o uartlite.o
TESTS := testbra testmov testmov2 testalu testshift testmul testmulu testmuls testmull \
         testdmulu testdmuls testmulconf testdiv testmacw testmacl
OBJS  := $(addprefix $(OUT)/,$(OBJS) $(addprefix tests/,$(addsuffix .o,$(TESTS))))

all: $(OUT)/main.bin $(OUT)/main.lst

$(OUT)/version.c:
	@mkdir -p $(@D)
	printf 'char version_string[] = "revision: open\\nbuild: j2 rewrite\\n";\n' > $@
$(OUT)/version.o: $(OUT)/version.c
	$(CC) $(CFLAGS) -c $< -o $@
$(OUT)/main.o: $(SRC)/main.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -fno-inline -c $< -o $@
$(OUT)/%.o: $(SRC)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@
# The J2 shift tests use SHAD/SHLD (SH-3/SH-2A opcodes, implemented by J2).
$(OUT)/tests/%.o: $(SRC)/tests/%.s
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -Wa,-isa=sh2a -c $< -o $@

$(OUT)/main.elf: $(OBJS)
	$(CC) $(LDFLAGS) $^ -lgcc -o $@
$(OUT)/main.bin: $(OUT)/main.elf
	$(CROSS)objcopy -O binary $< $@
$(OUT)/main.lst: $(OUT)/main.elf
	$(CROSS)objdump -d $< > $@

clean:
	rm -rf $(OUT)
.PHONY: all clean
