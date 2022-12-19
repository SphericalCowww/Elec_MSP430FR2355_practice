#include <msp430.h> 


/**
 * main.c
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	        // stop watchdog timer

	UCA1CTLW0 |= UCSWRST;               // put UART A1 into reset
	UCA1CTLW0 |= UCSSEL__SMCLK;         // set clock to ACLK (1MHz, 16bit to overflow)
	UCA1BRW = 8;                        // set prescaler to 8
	UCA1MCTLW = 0xD600;                 // configure modulation setting to low frequency mode

	P4SEL1 &= ~BIT3;                    // port 4 select = 01
	P4SEL0 |= BIT3;                     // put UART A1 on port 4.3
	PM5CTL0 &= ~LOCKLPM5;               // turn on GPIO system

	UCA1CTLW0 &= ~UCSWRST;              // put UART A1 into reset

	int i;
	while(1)
	{
	    UCA1TXBUF = 0b01001101;         // send bit signal via UART A1
	    for(i=0; i < 10000; i=i+1){}    // delay
	    UCA1TXBUF = 0b01101101;         // send bit signal via UART A1
	    for(i=0; i < 10000; i=i+1){}    // delay
	}

	return 0;
}
