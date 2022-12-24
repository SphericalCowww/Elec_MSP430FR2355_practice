#include <msp430.h> 

int charReceived;
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	        // stop watchdog timer

	UCA0CTLW0 |= UCSWRST;               // put A0 into software reset
	UCA0CTLW0 |= UCSSEL__SMCLK;         // set clock to SMCLK (1MHz, 16bit to overflow)
	UCA0BRW = 10;                       // set prescaler to 10 => 100kHz

	UCA0CTLW0 |= UCSYNC;                // put A0 into SPI mode
	UCA0CTLW0 |= UCMST;                 // put into SPI master

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

    P1DIR |= BIT0;              // set P1.0 to output (LED1)
    P1OUT &= ~BIT0;             // turn off LED1
    P6DIR |= BIT6;              // set P6.6 to output (LED2)
    P6OUT &= ~BIT6;             // turn off LED2

    P4DIR &= ~BIT1;             // set P4.1 (SW1) as input
    P4REN |= BIT1;              // enable resistor
    P4OUT |= BIT1;              // set resistor to pull up
    P4IES |= BIT1;              // set sensitivity to high-to-low
    P2DIR &= ~BIT3;             // set P2.3 (SW2) as input
    P2REN |= BIT3;              // enable resistor
    P2OUT |= BIT3;              // set resistor to pull up
    P2IES |= BIT3;              // set sensitivity to high-to-low

    PM5CTL0 &= ~LOCKLPM5;               // turn on GPIO system

    UCA0CTLW0 &= ~UCSWRST;              // take A0 out of software reset
    P4IE  |= BIT1;                      // enable P4.1 interrupt
    P4IFG &= ~BIT1;                     // clear P4.1 interrupt flag
    P2IE  |= BIT3;                      // enable P2.3 interrupt
    P2IFG &= ~BIT3;                     // clear P2.3 interrupt flag
    UCA0IE  |= UCTXIE;                  // enable A0 interrupt
    UCA0IFG &= ~UCTXIFG;                // clear A0 interrupt flag
    __enable_interrupt();               // enable maskable interrupt

	while(1){}

	return 0;
}

//---Interrupt Routine (ISR)---
// press right button to send
// ??? for some reason, can only send once
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_S1(void)
{
    UCA0TXBUF = 0x05;                   // send signal out over SPI SIMO
    P4IFG &= ~BIT1;                     // clear flag for P4.1
}
#pragma vector = PORT2_VECTOR
__interrupt void ISR_Port2_S2(void)
{
    UCA0TXBUF = 0xaa;                   // send signal out over SPI SIMO
    P2IFG &= ~BIT3;                     // clear flag for P2.3
}
#pragma vector = EUSCI_A0_VECTOR
__interrupt void ISR_EUSCI_A0(void)
{
    charReceived = UCA0RXBUF;           // read signal in from  SPI SOMI
    // note: need to connect SIMO and SOMI ports together for the following to work
    // note: for registers, see eUSCI_A0
    if(charReceived == 0x05)
    {
        P1OUT ^= BIT0;                  // toggle LED1
    }
    else if(charReceived == 0xaa)
    {
        P6OUT ^= BIT6;                  // toggle LED2
    }

}
