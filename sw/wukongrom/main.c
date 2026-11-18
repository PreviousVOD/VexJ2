#include "uart.h"
#include "board.h"

int sf3_quad_init_and_test(void);
extern uint32_t sf3_quad_id;
int ddr_cpu_test(void);

/* Platform diagnostic: configure/test quad flash, then echo UART input. */
void boot_main(void) {
  uart_init();
  uart_puts("Wukong-v1 platform ROM\n");
  uart_puts("Application flash offset: ");
  uart_hex(J2_FLASH_OFFSET, 8);
  int quad_ok = sf3_quad_init_and_test();
  uart_puts("\nSF3 quad ID: ");
  uart_hex(sf3_quad_id, 6);
  uart_puts(quad_ok ? "\nSF3 quad XIP: PASS" : "\nSF3 quad XIP: FAIL");
  int ddr_result = ddr_cpu_test();
  uart_puts(ddr_result ? "\nDDR3 CPU: FAIL " : "\nDDR3 CPU: PASS ");
  uart_hex(ddr_result, 2);
  uart_puts("\nApplication boot pending\n");
  for (;;) {
    if (uart_rx_ready()) uart_tx(uart_rx());
  }
}
