# Board IRQ definitions are shared by C drivers and assembly vector tables.
# Regenerate on every invocation; write_if_changed preserves incremental builds.
CFLAGS += -I$(OUT)
.PHONY: board-irqs-force
board-irqs-force:
$(OUT)/j2_board_irqs.h: board-irqs-force $(ROOT)/tools/board_config.py $(ROOT)/fpga/$(BOARD)/board.properties
	@mkdir -p $(@D)
	python3 $(ROOT)/tools/board_config.py $(BOARD) --irq-header $@
$(OBJS): $(OUT)/j2_board_irqs.h $(ROOT)/sw/board-irqs.mk
