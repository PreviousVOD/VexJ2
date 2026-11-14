/* Simple 16550 compatible UART routines for GDB stub */

struct st_uart16550
{
  unsigned int RTX;
  unsigned int IER;
  unsigned int IIR;
  unsigned int LCR;
  unsigned int MCR;
  unsigned int LSR;
  unsigned int MSR;
  unsigned int SCR;
};
#define UART 0xabcd0100
#define UART16550 (*(volatile struct st_uart16550 *)UART)

void
uart_tx (unsigned char data)
{
  while (!((UART16550.LSR) & 0x20));
  UART16550.RTX = data;
}

unsigned char
uart_rx (void)
{
  while (!((UART16550.LSR) & 0x1));
  return (UART16550.RTX & 0xff);
}

unsigned char
uart_rx_echo (void)
{
  unsigned char data;

  while (!(UART16550.LSR & 1));
  data = UART16550.RTX & 0xff;

  while (!(UART16550.LSR & 0x20));
  UART16550.RTX = data;
  return data;
}

void
uart_rx_flush (void)
{
  while (UART16550.LSR & 1) UART16550.RTX;
}

void
uart_set_baudrate (void)
{
  /* 24 MHz / (16 * 78) = 19230.769 baud, 0.16% above 19200. */
  UART16550.LCR = 0x83;
  UART16550.RTX = 78;
  UART16550.IER = 0;
  UART16550.LCR = 0x3;
}
