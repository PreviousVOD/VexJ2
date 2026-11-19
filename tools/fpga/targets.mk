# Board selection is data: fpga/<BOARD>/board.properties + build.tcl.
BOARD ?= tang-primer
VIVADO_HOME ?= /home/imi415/Softwares/Tools/Xilinx/2025.2/Vivado
export VIVADO_HOME TD_HOME
.PHONY: fpga fpga-rtl fpga-synth fpga-impl fpga-program fpga-plan
fpga:
	python3 tools/fpga.py --board "$(BOARD)" build $(if $(J2_ROM),--rom "$(J2_ROM)")
fpga-rtl:
	python3 tools/fpga.py --board "$(BOARD)" generate $(if $(J2_ROM),--rom "$(J2_ROM)")
fpga-synth:
	python3 tools/fpga.py --board "$(BOARD)" synth $(if $(J2_ROM),--rom "$(J2_ROM)")
fpga-impl:
	python3 tools/fpga.py --board "$(BOARD)" implement
fpga-program:
	python3 tools/fpga.py --board "$(BOARD)" program $(if $(BITSTREAM),--bitstream "$(BITSTREAM)")
fpga-plan:
	python3 tools/fpga.py --board "$(BOARD)" build --dry-run
