struct st_uart16550 {
    unsigned int RTX;
    unsigned int STATUS;
    unsigned int CLKDIV;
    unsigned int FRAME;
};
#define UART      0xff001000
#define UART16550 (*(volatile struct st_uart16550 *)UART)
#ifndef J2_CLOCK_HZ
#define J2_CLOCK_HZ 32000000
#endif
#define UART_CLOCK_DIVIDER (J2_CLOCK_HZ / (19200 * 5) - 1)

void uart_tx(unsigned char data) {
    while ((UART16550.STATUS & 0xff0000) == 0);
    UART16550.RTX = data;
}

unsigned char uart_rx(void) {
    unsigned int value;

    do {
        value = UART16550.RTX;
    } while (!(value & 0x10000));

    return value & 0xff;
}

unsigned char uart_rx_echo(void) {
    unsigned char data;

    data = uart_rx();
    uart_tx(data);

    return data;
}

void uart_rx_flush(void) {
    while (UART16550.RTX & 0x10000) {
        UART16550.RTX;
    }
}

void uart_set_baudrate(void) {
    UART16550.CLKDIV = UART_CLOCK_DIVIDER;
    UART16550.FRAME  = 7;
}
