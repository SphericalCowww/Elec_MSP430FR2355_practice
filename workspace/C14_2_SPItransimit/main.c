#include <msp430.h> 

char packet[] = {0x01, 0x03, 0x07, 0x0e};
unsigned int packIdx;

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	        // stop watchdog timer

	UCA0CTLW0 |= UCSWRST;               // put A0 into software reset
	UCA0CTLW0 |= UCSSEL__SMCLK;         // set clock to SMCLK (1MHz, 16bit to overflow)
	UCA0BRW = 10;                        // set prescaler to 10 => 100kHz

	UCA0CTLW0 |= UCSYNC;                // put A0 into SPI mode
	UCA0CTLW0 |= UCMST;                 // put into SPI master

	//UCA0CTLW0 |= UCMODE1;               // turn on STE in active low
	//UCA0CTLW0 &= ~UCMODE0;
    UCA0CTLW0 &= ~UCMODE1;              // turn on STE in active high
    UCA0CTLW0 |= UCMODE0;
	UCA0CTLW0 |= UCSTEM;                // use STE as normal enable

	// from "Figure 4. MSP430FR2355 Pinout", (STE, CLK, SOMI, SIMO) to P(1.4, 1.5, 1.6, 1.7)
	//CLK: clock, SOMI: slave out master in, SIMO: slave in master out, STE: slave transmit enable
    //note: STE also known as chip select (CS) or slave select (SS)
	P1SEL1 &= ~BIT5;                    // port 1.5 select = 01 (SCLK)
    P1SEL0 |= BIT5;                     // put SPI A0 on port 1.5
    P1SEL1 &= ~BIT7;                    // port 1.7 select = 01 (SIMO)
    P1SEL0 |= BIT7;
    P1SEL1 &= ~BIT6;                    // port 1.6 select = 01 (SOMI)
    P1SEL0 |= BIT6;
    P1SEL1 &= ~BIT4;                    // port 1.4 select = 01 (STE)
    P1SEL0 |= BIT4;                     // put SPI A0 on port 1.4

    P4DIR &= ~BIT1;             // set P4.1 (SW1) as input
    P4REN |= BIT1;              // enable resistor
    P4OUT |= BIT1;              // set resistor to pull up
    P4IES |= BIT1;              // set sensitivity to high-to-low

    PM5CTL0 &= ~LOCKLPM5;               // turn on GPIO system

    UCA0CTLW0 &= ~UCSWRST;              // take A0 out of software reset
    P4IE  |= BIT1;                      // enable P4.1 interrupt
    P4IFG &= ~BIT1;                     // clear P4.1 interrupt flag
    UCA0IE  |= UCTXIE;                  // enable A0 interrupt
    UCA0IFG &= ~UCTXIFG;                // clear A0 interrupt flag
    __enable_interrupt();               // enable maskable interrupt

    int i;
	while(1)
	{
	    // check output pin from both P1.5 and P1.7 (+P1.4 for STE); note: rising edge
	    //UCA0TXBUF = 0x00;               // send signal out over SPI SIMO, doesn't support string
	    //for(i=0; i < 10000; i=i+1){}    // delay
	}

	return 0;
}

//---Interrupt Routine (ISR)---
// press right button to send
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_S1(void)
{
    packIdx = 0;
    UCA0TXBUF = packet[packIdx];        // send first byte

    P4IFG &= ~BIT1;                     // clear flag for P4.1
}
#pragma vector = EUSCI_A0_VECTOR
__interrupt void ISR_EUSCI_A0(void)
{
    packIdx++;
    if(packIdx == sizeof(packet))
    {
        UCA0IFG &= ~UCTXIFG;                  // clear A0 interrupt flag
    }
    else
    {
        // check output pin from both P1.5 and P1.7 (+P1.4 for STE); note: rising edge
        UCA0TXBUF = packet[packIdx];
    }
}
