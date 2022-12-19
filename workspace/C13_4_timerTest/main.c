#include <msp430.h> 

int capturedTime = 0;           //note: looking for 0x2000 and on, compare to TB0 in the register
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer

	P1DIR |= BIT0;              // set P1.0 (LED1) as output
	P1OUT |= BIT0;              // turn LED1 OFF
	PM5CTL0 &= ~LOCKLPM5;       // turn on GPIO system

	TB0CTL |= TBCLR;            // reset timer TB0
	TB0CTL |= TBSSEL__ACLK;     // set clock to ACLK (32768Hz, 16bit to overflow)
	//TB0CTL |= TBSSEL__SMCLK;    // set clock to ACLK (1MHz, 16bit to overflow)
	//TB0CTL |= CNTL_1;           // set to 12bit
	TB0CTL |= ID__4;            // set decimation to 4

	/*
	//overflow interrupt
	TB0CTL |= MC__CONTINUOUS;   // set continuous mode
	TB0CTL |= TBIE;             // local enable for TB0 overflow
    TB0CTL &= ~TBIFG;           // clear interrupt flag
	 */

    //compare interrupts
	TB0CTL |= MC__UP;           // set in up mode for CCR0
	TB0CCR0 = 16384;            // set compare value CCR0
	TB0CCTL0 |= CCIE;           // local enable for CCR0
	TB0CCTL0 &= ~TBIFG;         // clear interrupt flag CCR0
	TB0CCR1 = 1024;             // set compare value CCR1
	TB0CCTL1 |= CCIE;           // local enable for CCR1
	TB0CCTL1 &= ~TBIFG;         // clear interrupt flag CCR1

	//capture interrupt
	TB0CCTL2 |= CAP;            // put CCR2 into capture mode
	TB0CCTL2 |= CM__BOTH;       // sensitive to both edges
	TB0CCTL2 |= CCIS__GND;      // put capture level at GND

	__enable_interrupt();       // enable maskable interrupt
	while(1) {}

	return 0;
}

//---Interrupt Routine (ISR)---
/*
//overflow ISR
#pragma vector = TIMER0_B1_VECTOR
__interrupt void ISR_TB0IFG(void)
{
    P1OUT ^= BIT0;          // toggle LED1
    TB0CTL &= ~TBIFG;       // clear P4.1 interrupt flag
}
*/
//compare ISR
#pragma vector = TIMER0_B0_VECTOR
__interrupt void ISR_TB0CCR0(void)
{
    P1OUT ^= BIT0;              // toggle LED1
    TB0CCTL0 &= ~TBIFG;         // clear P4.1 interrupt flag CCR0
    TB0CCTL2 ^= CCIS0;          // toggle GND/VCC
    capturedTime = TB0CCTL2;    // store captured value
}
#pragma vector = TIMER0_B1_VECTOR
__interrupt void ISR_TB0CCR1(void)
{
    P1OUT ^= BIT0;              // toggle LED1
    TB0CCTL1 &= ~TBIFG;         // clear P4.1 interrupt flag CCR1
    TB0CCTL2 ^= CCIS0;          // toggle GND/VCC
    capturedTime = TB0CCTL2;    // store captured value
}



