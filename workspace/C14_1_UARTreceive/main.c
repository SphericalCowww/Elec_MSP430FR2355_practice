#include <msp430.h> 


/**
 * main.c
 */
unsigned int msgIdx;
char message[] = "Hello World";
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	        // stop watchdog timer

	// receive setting
    UCA1CTLW0 |= UCSWRST;               // put A1 into software reset
    UCA1CTLW0 |= UCSSEL__SMCLK;         // set clock to SMCLK (1MHz, 16bit to overflow)
    UCA1BRW = 8;                        // set prescaler to 8
    UCA1MCTLW = 0xD600;                 // configure modulation setting to low frequency mode

    //  from "Figure 4. MSP430FR2355 Pinout", the RXD connector of the jumper isolated block
    //is associated with port 4.2; T in TXD for transmit
    P4SEL1 &= ~BIT2;                    // port 4.2 select = 01
    P4SEL0 |= BIT2;                     // put UART A1 on port 4.2

    P1DIR |= BIT0;                      // set P1.0 to output (LED1)
    P1OUT &= ~BIT0;                     // turn off LED1

    PM5CTL0 &= ~LOCKLPM5;               // turn on GPIO system

	UCA1CTLW0 &= ~UCSWRST;              // take A1 out of software reset
	UCA1IE |= UCRXIE;                   // local enable for A1 RXIFG, R for receive
	__enable_interrupt();               // enable maskable interrupt


	while(1){}

	return 0;
}

//---Interrupt Routine (ISR)---
#pragma vector = EUSCI_A1_VECTOR
__interrupt void EUSCI_A1_RX_ISR(void)
{
    // check input pin from RXD; note: falling edge
    //or check View > Terminal > Serial Terminal > cu.usbmodem1103
    // note: the 2 RXD pins need to be connected to show up on terminal
    // note: for registers, see eUSCI_A1
    if(UCA1RXBUF == 'd')
    {
        P1OUT ^= BIT0;                  /// toggle LED1
    }
}



