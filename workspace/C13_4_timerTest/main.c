#include <msp430.h> 

int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer
	
	P1DIR |= BIT0;              // set P1.0 (LED1) as output
	P1OUT &= ~BIT0;             // turn LED1 OFF
	PM5CTL0 &= ~LOCKLPM5;       // turn on GPIO system

	TB0CTL |= TBCLR;            // reset timer TB0
	TB0CTL |= TBSSEL__ACLK;     // set clock to ACLK (2s)
	TB0CTL |= MC__CONTINUOUS;   // set continuous mode

	TB0CTL |= TBIE;             // local enable for TB0 overflow
	__enable_interrupt();      // enable maskable interrupt
	TB0CTL &= ~TBIFG;           // clear interrupt flag

	while(1) {}

	return 0;
}

//---Interrupt Routine (ISR)---
#pragma vector = TIMER0_B1_VECTOR
__interrupt void ISR_TB0CTL(void)
{
    P1OUT ^= BIT0;          // toggle LED1
    TB0CTL &= ~TBIFG;       // clear P4.1 interrupt flag
}



