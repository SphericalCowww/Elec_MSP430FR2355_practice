#include <msp430.h> 


/**
 * main.c
 */
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	        // stop watchdog timer

	// setting 1
	UCA1CTLW0 |= UCSWRST;               // put UART A1 into reset
	UCA1CTLW0 |= UCSSEL__SMCLK;         // set clock to ACLK (32768Hz, 16bit to overflow)
	UCA1BRW = 8;                        // set prescaler to 8
	UCA1MCTLW = 0xD600;                 // configure modulation setting to low frequency mode
	// setting 2
	//UCA1CTLW0 |= UCSWRST;               // put UART A1 into reset
	//UCA1CTLW0 |= UCSSEL__ACLK;          // set clock to ACLK (1MHz, 16bit to overflow)
	//UCA1BRW = 3;                        // set prescaler to 3
	//UCA1MCTLW = 0x9200;                 // configure modulation setting to low frequency mode

	//  from "Figure 4. MSP430FR2355 Pinout", the TXD connector of the jumper isolated block
	//is associated with port 4.3
	P4SEL1 &= ~BIT3;                    // port 4.3 select = 01
	P4SEL0 |= BIT3;                     // put UART A1 on port 4.3
	PM5CTL0 &= ~LOCKLPM5;               // turn on GPIO system

	UCA1CTLW0 &= ~UCSWRST;              // take UART A1 out of reset

	int i;
	while(1)
	{
	    /*
	    UCA1TXBUF = 0b10000000;         // send bit signal via UART A1
	    for(i=0; i < 10000; i=i+1){}    // delay
        UCA1TXBUF = 0b00100000;         // send bit signal via UART A1
        for(i=0; i < 10000; i=i+1){}    // delay
        UCA1TXBUF = 0b00001000;         // send bit signal via UART A1
        for(i=0; i < 10000; i=i+1){}    // delay
        UCA1TXBUF = 0b00000010;         // send bit signal via UART A1
        for(i=0; i < 10000; i=i+1){}    // delay
        */
	    // check View > Terminal > Serial Terminal > cu.usbmodem1103
	    UCA1TXBUF = 'A';                // 8bit ASCII char format
	    for(i=0; i < 10000; i=i+1){}    // delay
        UCA1TXBUF = 'B';                // 8bit ASCII char format
        for(i=0; i < 10000; i=i+1){}    // delay
	}

	return 0;
}
