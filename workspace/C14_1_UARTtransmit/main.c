#include <msp430.h> 


/**
 * main.c
 */
unsigned int msgIdx;
char message[] = "Hello World";
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	        // stop watchdog timer

    // transmit setting 1
	UCA1CTLW0 |= UCSWRST;               // put UART A1 into reset
	UCA1CTLW0 |= UCSSEL__SMCLK;         // set clock to ACLK (32768Hz, 16bit to overflow)
	UCA1BRW = 8;                        // set prescaler to 8
	UCA1MCTLW = 0xD600;                 // configure modulation setting to low frequency mode
	// transmit setting 2
	//UCA1CTLW0 |= UCSWRST;               // put UART A1 into reset
	//UCA1CTLW0 |= UCSSEL__ACLK;          // set clock to ACLK (1MHz, 16bit to overflow)
	//UCA1BRW = 3;                        // set prescaler to 3
	//UCA1MCTLW = 0x9200;                 // configure modulation setting to low frequency mode

	P4DIR &= ~BIT1;             // set P4.1 (SW1) as input
	P4REN |= BIT1;              // enable resistor
	P4OUT |= BIT1;              // set resistor to pull up
	P4IES |= BIT1;              // set sensitivity to high-to-low

	//  from "Figure 4. MSP430FR2355 Pinout", the TXD connector of the jumper isolated block
	//is associated with port 4.3; T in TXD for transmit
	P4SEL1 &= ~BIT3;                    // port 4.3 select = 01
	P4SEL0 |= BIT3;                     // put UART A1 on port 4.3

	PM5CTL0 &= ~LOCKLPM5;               // turn on GPIO system

	UCA1CTLW0 &= ~UCSWRST;              // take UART A1 out of reset
	P4IE |= BIT1;                       // enable P4.1 interrupt
	P4IFG &= ~BIT1;                     // clear P4.1 interrupt flag
	__enable_interrupt();               // enable maskable interrupt

	/*
	int i, j;
	char message[] = "Hello World";
	while(1)
	{
	    //UCA1TXBUF = 0b10000000;         // send bit signal via UART A1
	    //for(i=0; i < 10000; i=i+1){}    // delay
        //UCA1TXBUF = 0b00100000;         // send bit signal via UART A1
        //for(i=0; i < 10000; i=i+1){}    // delay
        //UCA1TXBUF = 0b00001000;         // send bit signal via UART A1
        //for(i=0; i < 10000; i=i+1){}    // delay
        //UCA1TXBUF = 0b00000010;         // send bit signal via UART A1
        //for(i=0; i < 10000; i=i+1){}    // delay

	    // check View > Terminal > Serial Terminal > cu.usbmodem1103
	    UCA1TXBUF = 'A';                // 8bit ASCII char format
	    for(i=0; i < 10000; i++){}    // delay
	    for(j=0; j < sizeof(message); j++)
	    {
	        UCA1TXBUF = message[j];       // 8bit ASCII char format
	        for(i=0; i < 1000; i++){}    // delay
	    }
	}
    */

	while(1){}

	return 0;
}

//---Interrupt Routine (ISR)---
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_S1(void)
{
    msgIdx = 0;
    UCA1IE |= UCTXCPTIE;                // turn on Tx complete IRQ
    UCA1IFG &= ~UCTXCPTIFG;             // clear Tx complete flag
    UCA1TXBUF = message[msgIdx];

    P4IFG &= ~BIT1;                     // clear flag for P4.1
}
#pragma vector = EUSCI_A1_VECTOR
__interrupt void ISR_EUSCI_A1(void)
{
    if(msgIdx == sizeof(message))
    {
        UCA1IE &= ~UCTXCPTIE;            // turn off Tx complete IRQ, T for transmit
    }
    else
    {
        msgIdx++;
        // check View > Terminal > Serial Terminal > cu.usbmodem1103
        // note, the 2 TXD pins need to be connected to show up on terminal
        // for registers, see eUSCI_A1
        UCA1TXBUF = message[msgIdx];
    }
    UCA1IFG &= ~UCTXCPTIFG;             // clear Tx complete flag
}


