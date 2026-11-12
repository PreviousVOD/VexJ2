# J2 SystemVerilog rewrite: top-level build.
#
#   make gen          regenerate decoder files from spec/j2_isa.csv
#   make ref          convert original VHDL (reference/) to Verilog (ref/gen/)
#   make lint         verilator -Wall lint of all RTL
#   make test-decode  exhaustive decode-table equivalence vs original
#   make test-unit    ALU / regfile / multiplier differential tests vs original
#   make sw           build test programs (original testrom, sim tests)
#   make test-ref     baseline: original CPU runs the test programs
#   make test-lockstep new CPU vs original CPU, cycle-exact, random bus timing,
#                     random events and debug commands
#   make check        everything above
#
# Tools: system tools on PATH are used when available; the repository-local
# toolchain in tools/local (tools/third_party/build-tools.sh) is the fallback.

SHELL      := /bin/bash
export PATH := $(PATH):$(CURDIR)/tools/local/bin:$(CURDIR)/tools/local/sh-none-elf/bin
VERILATOR  ?= verilator
PYTHON     ?= python3
JOBS       ?= $(shell nproc)
SEED       ?= 1
BUILD      := build

VFLAGS_SIM := --cc --exe --build -j $(JOBS) -O3 --x-assign fast --x-initial fast \
              -Wno-fatal -Wno-lint -Wno-style -CFLAGS -O2

# ------------------------------------------------------------------ sources
RTL_PKGS := rtl/pkg/j2_cpu_pkg.sv rtl/pkg/j2_decode_pkg.sv rtl/pkg/j2_alu_pkg.sv \
            rtl/pkg/j2_wb_pkg.sv rtl/pkg/j2_isa_pkg.sv
RTL_CORE := rtl/core/j2_decode_table.sv rtl/core/j2_decode_core.sv rtl/core/j2_decode.sv \
            rtl/core/j2_regfile.sv rtl/core/j2_mult.sv rtl/core/j2_sr.sv \
            rtl/core/j2_dbus_wbm.sv rtl/core/j2_ibus_wbm.sv rtl/core/j2_debug.sv \
            rtl/core/j2_datapath.sv rtl/core/j2_cpu.sv
RTL_ALL  := $(RTL_PKGS) $(RTL_CORE)

SPEC     := spec/j2_isa.csv
GEN_OUT  := rtl/core/j2_decode_table.sv rtl/pkg/j2_isa_pkg.sv tests/decode/j2_decode_care.sv \
            sim/gen/j2_isa_table.inc

# The original source is extracted (read-only) from the release tarball.
REFSRC := reference/soc_top/README
$(REFSRC): jcore-source-latest.tar.gz
	mkdir -p reference && tar -xzf $< -C reference && chmod -R a-w reference/soc_top && touch $@

.PHONY: all gen ref lint check test-decode test-unit sw test-ref test-lockstep clean
all: check

# --------------------------------------------------------------- generation
gen: $(GEN_OUT)
$(GEN_OUT) &: $(SPEC) tools/gen_decode.py $(REFSRC)
	$(PYTHON) tools/gen_decode.py $(SPEC) \
	  --sv rtl/core/j2_decode_table.sv \
	  --sv-isa-pkg rtl/pkg/j2_isa_pkg.sv \
	  --sv-care tests/decode/j2_decode_care.sv \
	  --c-table sim/gen/j2_isa_table.inc \
	  --check-vhdl reference/soc_top/components/cpu/decode/decode_table_simple.vhd \
	  --check-immval reference/soc_top/components/cpu/decode/decode_pkg.vhd

# ------------------------------------------------------- reference (GHDL)
REF_DECODE := ref/gen/ref_decode_table_simple.v ref/gen/ref_decode_table_reverse.v
REF_UNITS  := ref/gen/ref_alu.v ref/gen/ref_regfile.v ref/gen/ref_mult.v
REF_CPU    := ref/gen/ref_cpu.v ref/gen/ref_cpu_ill.v

ref: $(REF_DECODE) $(REF_UNITS) $(REF_CPU)
$(REF_DECODE) $(REF_UNITS) $(REF_CPU): $(REFSRC)
$(REF_CPU) &: ref/ref_cpu.vhd tools/ref_synth.sh
	tools/ref_synth.sh cpu
$(REF_DECODE) &: ref/ref_decode_table.vhd ref/ref_flatten_pkg.vhd tools/ref_synth.sh
	tools/ref_synth.sh decode_table
$(REF_UNITS) &: ref/ref_core_units.vhd tools/ref_synth.sh
	tools/ref_synth.sh core_units

# --------------------------------------------------------------------- lint
lint: $(RTL_ALL)
	@for top in j2_cpu; do \
	  echo "lint $$top"; \
	  $(VERILATOR) --lint-only -Wall rtl/lint.vlt $(RTL_ALL) --top-module $$top || exit 1; \
	done

# -------------------------------------------------------------------- tests
# $(call vtest,name,top,sources)  ->  build/tests/<name>/V<top>
define vtest
$(BUILD)/tests/$(1)/V$(2): $(3)
	@mkdir -p $(BUILD)/tests/$(1)
	$(VERILATOR) $(VFLAGS_SIM) --top-module $(2) -Mdir $(BUILD)/tests/$(1)/obj \
	  -o ../V$(2) $(abspath $(3)) > $(BUILD)/tests/$(1)/build.log 2>&1 \
	  || { tail -30 $(BUILD)/tests/$(1)/build.log; exit 1; }
endef

$(eval $(call vtest,decode,tb_decode_eq,$(RTL_PKGS) rtl/core/j2_decode_table.sv \
  tests/decode/j2_decode_care.sv $(REF_DECODE) tests/decode/tb_decode_eq.sv \
  tests/decode/tb_decode_eq.cpp))
$(eval $(call vtest,alu,tb_alu,$(RTL_PKGS) ref/gen/ref_alu.v tests/unit/tb_alu.sv \
  tests/unit/tb_alu.cpp))
$(eval $(call vtest,regfile,tb_regfile,rtl/core/j2_regfile.sv ref/gen/ref_regfile.v \
  tests/unit/tb_regfile.sv tests/unit/tb_regfile.cpp))
$(eval $(call vtest,mult,tb_mult,rtl/pkg/j2_cpu_pkg.sv rtl/core/j2_mult.sv ref/gen/ref_mult.v \
  tests/unit/tb_mult.sv tests/unit/tb_mult.cpp))

test-decode: $(BUILD)/tests/decode/Vtb_decode_eq
	$<

test-unit: $(BUILD)/tests/alu/Vtb_alu $(BUILD)/tests/regfile/Vtb_regfile $(BUILD)/tests/mult/Vtb_mult
	$(BUILD)/tests/alu/Vtb_alu $(SEED)
	$(BUILD)/tests/regfile/Vtb_regfile $(SEED)
	$(BUILD)/tests/mult/Vtb_mult $(SEED)

# ----------------------------------------------------------- test programs
TESTROM  := $(BUILD)/sw/testrom/main.bin
SIMTESTS := $(BUILD)/sw/simtests/interrupts.bin $(BUILD)/sw/simtests/rte.bin
STRESS   := $(BUILD)/sw/stress/stress.bin
sw: $(REFSRC)
	$(MAKE) -C sw/testrom
	$(MAKE) -C sw/simtests
	$(MAKE) -C sw/stress
$(TESTROM) $(SIMTESTS): sw

# Original CPU, as released (ref_cpu) and with the illegal-instruction vector
# fix (ref_cpu_ill). Same C++ driver; --prefix keeps the class name.
VREF_FLAGS = $(VFLAGS_SIM) -CFLAGS "-I$(abspath sim/common)" --prefix Vref_cpu
$(BUILD)/tests/ref_cpu/Vref_cpu: ref/gen/ref_cpu.v tests/ref/tb_ref_cpu.cpp sim/common/sysmodel.h
	@mkdir -p $(@D)
	$(VERILATOR) $(VREF_FLAGS) --top-module ref_cpu -Mdir $(@D)/obj -o ../Vref_cpu \
	  $(abspath ref/gen/ref_cpu.v tests/ref/tb_ref_cpu.cpp) > $(@D)/build.log 2>&1 || { tail $(@D)/build.log; exit 1; }
$(BUILD)/tests/ref_cpu_ill/Vref_cpu: ref/gen/ref_cpu_ill.v tests/ref/tb_ref_cpu.cpp sim/common/sysmodel.h
	@mkdir -p $(@D)
	$(VERILATOR) $(VREF_FLAGS) --top-module ref_cpu_ill -Mdir $(@D)/obj -o ../Vref_cpu \
	  $(abspath ref/gen/ref_cpu_ill.v tests/ref/tb_ref_cpu.cpp) > $(@D)/build.log 2>&1 || { tail $(@D)/build.log; exit 1; }

RUN_TESTROM = --quiet --expect "CPU tests passed" --expect "GDB Stub" --max-cycles 3000000
test-ref: sw $(BUILD)/tests/ref_cpu/Vref_cpu $(BUILD)/tests/ref_cpu_ill/Vref_cpu
	@set -e; for cpu in ref_cpu ref_cpu_ill; do \
	  V=$(BUILD)/tests/$$cpu/Vref_cpu; \
	  for lat in "--ilat 0 --dlat 0" "--ilat 1 --dlat 1" "--ilat 1 --dlat 1 --rand 3 --seed $(SEED)"; do \
	    printf "%-12s testrom %-38s " $$cpu "$$lat"; $$V $(TESTROM) $(RUN_TESTROM) $$lat | tail -1; \
	  done; \
	  printf "%-12s rte.S       " $$cpu; $$V $(BUILD)/sw/simtests/rte.bin --quiet | tail -1; \
	done
	@printf "%-12s interrupts.S " ref_cpu_ill; $(BUILD)/tests/ref_cpu_ill/Vref_cpu $(BUILD)/sw/simtests/interrupts.bin --quiet | tail -1
	@echo "note: ref_cpu (as released) fails interrupts.S sub-test 13: illegal instructions vector via VBR+0"

# Lockstep: new j2_cpu (ILLEGAL_VEC_FIX=0) vs ref_cpu, and
# (ILLEGAL_VEC_FIX=1) vs ref_cpu_ill.
LOCKSTEP_SRC = $(RTL_ALL) tests/ref/tb_lockstep.sv tests/ref/tb_lockstep.cpp sim/common/sysmodel.h \
               sim/gen/j2_isa_table.inc
VLOCK_FLAGS  = $(VFLAGS_SIM) -CFLAGS "-I$(abspath sim/common) -I$(abspath sim/gen)" \
               --prefix Vtb_lockstep --top-module tb_lockstep
$(BUILD)/tests/lockstep/Vtb_lockstep: $(LOCKSTEP_SRC) ref/gen/ref_cpu.v
	@mkdir -p $(@D)
	$(VERILATOR) $(VLOCK_FLAGS) -Mdir $(@D)/obj -o ../Vtb_lockstep \
	  $(abspath $(RTL_ALL) ref/gen/ref_cpu.v tests/ref/tb_lockstep.sv tests/ref/tb_lockstep.cpp) \
	  > $(@D)/build.log 2>&1 || { tail -20 $(@D)/build.log; exit 1; }
$(BUILD)/tests/lockstep_ill/Vtb_lockstep: $(LOCKSTEP_SRC) ref/gen/ref_cpu_ill.v
	@mkdir -p $(@D)
	$(VERILATOR) $(VLOCK_FLAGS) -DREF_ILL -Mdir $(@D)/obj -o ../Vtb_lockstep \
	  $(abspath $(RTL_ALL) ref/gen/ref_cpu_ill.v tests/ref/tb_lockstep.sv tests/ref/tb_lockstep.cpp) \
	  > $(@D)/build.log 2>&1 || { tail -20 $(@D)/build.log; exit 1; }

LOCK_SEEDS ?= 1 2 3 4
STRESS_CYCLES ?= 1000000
LOCK_TIMING = --stall 3 --kmin 1 --kmax 4
test-lockstep: sw $(BUILD)/tests/lockstep/Vtb_lockstep $(BUILD)/tests/lockstep_ill/Vtb_lockstep
	@set -e; for v in lockstep lockstep_ill; do V=$(BUILD)/tests/$$v/Vtb_lockstep; \
	  printf "%-13s testrom k=1           " $$v; $$V $(TESTROM) $(RUN_TESTROM) | tail -1; \
	  for s in $(LOCK_SEEDS); do \
	    printf "%-13s testrom seed %-8s " $$v $$s; $$V $(TESTROM) $(RUN_TESTROM) $(LOCK_TIMING) --seed $$s | tail -1; \
	    printf "%-13s rte.S seed %-10s " $$v $$s; $$V $(BUILD)/sw/simtests/rte.bin --quiet $(LOCK_TIMING) --seed $$s | tail -1; \
	    printf "%-13s +irq +dbg seed %-6s " $$v $$s; $$V $(TESTROM) --quiet --max-cycles 200000 $(LOCK_TIMING) --irq-rand 300 --dbg-rand 500 --seed $$s | tail -1; \
	  done; done
	@set -e; V=$(BUILD)/tests/lockstep_ill/Vtb_lockstep; for s in $(LOCK_SEEDS); do \
	  printf "%-13s interrupts.S seed %-3s " lockstep_ill $$s; $$V $(BUILD)/sw/simtests/interrupts.bin --quiet $(LOCK_TIMING) --seed $$s | tail -1; done
	@set -e; for v in lockstep lockstep_ill; do V=$(BUILD)/tests/$$v/Vtb_lockstep; for s in $(LOCK_SEEDS); do \
	  printf "%-13s stress 1M +irq +dbg seed %-3s " $$v $$s; \
	  $$V $(STRESS) --quiet --max-cycles $(STRESS_CYCLES) $(LOCK_TIMING) --irq-rand 200 --dbg-rand 2000 --dbg-safe --no-undef --seed $$s | tail -1; \
	done; done

check: lint test-decode test-unit test-ref test-lockstep

clean:
	rm -rf $(BUILD)
