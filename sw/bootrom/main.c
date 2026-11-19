#include "uart.h"
#include "board.h"
#include "flash.h"

void application_loader(void);

void boot_main(void) {
  uart_init();
  uart_puts(J2_BOARD_NAME " platform ROM\n");
  uart_puts("Application flash offset: ");
  uart_hex(J2_FLASH_OFFSET, 8);
  int quad_ok = flash_init_and_test();
  uart_puts("\nFlash JEDEC ID: ");
  uart_hex(flash_jedec_id, 6);
  uart_puts(quad_ok ? "\nFlash quad XIP: PASS\n" : "\nFlash quad XIP: FAIL\n");
  if (!quad_ok) { uart_puts("Platform failure\n"); for (;;) {} }
  application_loader();
}
