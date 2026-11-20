/* Historical test-ROM target name; the native SoC console is now SCIF. */
/* App */
#include "uart.h"

unsigned char uart_rx_echo(void) {
    unsigned char data = uart_rx();
    uart_tx(data);

    return data;
}

void uart_rx_flush(void) {
    while (uart_rx_ready()) {
        (void)uart_rx();
    }
}

void uart_set_baudrate(void) {
    uart_init();
}
