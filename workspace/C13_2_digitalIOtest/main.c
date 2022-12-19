#include <msp430.h> 

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer

	/*
	P1DIR |= BIT0;              // set P1.0 (LED1) as output
	PM5CTL0 &= ~LOCKLPM5;       // turn on GPIO system
	while(1)
	{
	    P1OUT |= BIT0;          // turn LED1 ON
	    P1OUT &= ~BIT0;         // turn LED1 OFF
	    P1OUT ^= BIT0;          // toggle LED1
	}
	*/

	/*
	P1DIR |= BIT0;              // set P1.0 (LED1) as output
	P1OUT &= ~BIT0;             // turn LED1 OFF

	P4DIR &= ~BIT1;             // set P4.1 (switch1, SW1) as input
	P4REN |= BIT1;              // enable resistor
	P4OUT |= BIT1;              // set resistor to pull up
	PM5CTL0 &= ~LOCKLPM5;       // turn on GPIO system

	int SW1;
	while(1)
	{
	    SW1 = P4IN;             // read P4
	    SW1 &= BIT1;            // clear all bit except bit 1
	    if(SW1 == 0)            // if press
	        P1OUT |= BIT0;      // turn LED1 ON
	    else
	        P1OUT &= ~BIT0;     // turn LED1 OFF
	}
	*/
	P1DIR |= BIT0;              // set P1.0 (LED1) as output
	P1OUT &= ~BIT0;             // turn LED1 OFF

	P4DIR &= ~BIT1;             // set P4.1 (SW1) as input
	P4REN |= BIT1;              // enable resistor
	P4OUT |= BIT1;              // set resistor to pull up
	P4IES |= BIT1;              // set sensitivity to high-to-low
	PM5CTL0 &= ~LOCKLPM5;       // turn on GPIO system

	P4IE  |= BIT1;              // enable P4.1 interrupt
	__enable_interrupt();       // enable maskable interrupt
	P4IFG &= ~BIT1;             // clear P4.1 interrupt flag

	while(1) {}

	return 0;
}

//---Interrupt Routine (ISR)---
#pragma vector = PORT4_VECTOR
__interrupt void ISR_Port4_S1(void)
{
    P1OUT ^= BIT0;          // toggle LED1
    P4IFG &= ~BIT1;         // clear P4.1 interrupt flag
}


