#include <msp430.h> 

char dataReceived;
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	        // stop watchdog timer

	UCB0CTLW0 |= UCSWRST;               // put B0 into software reset
	UCB0CTLW0 |= UCSSEL__SMCLK;              // set clock to SMCLK (1MHz, 16bit to overflow)
	UCB0BRW = 10;                       // set prescaler to 10 => 100kHz

	UCB0CTLW0 |= UCMODE_3;              // put B0 to I2C mode
	UCB0CTLW0 |= UCMST;                 // put into I2C master
	UCB0I2CSA |= 0x68;                  // set slave address RTC=0x68

	UCB0CTLW1 |= UCASTP_2;              // put into automatic STOP mode
	UCB0TBCNT  = 1;                     // set number of byte to receive

	// check "Figure 4. MSP430FR2355 Pinout" for matching ports
	P1SEL1 &= ~BIT3;                    // port 1.3 select = 01 (SCL, clock)
    P1SEL0 |= BIT3;
    P1SEL1 &= ~BIT2;                    // port 1.2 select = 01 (SCA, data)
    P1SEL0 |= BIT2;

    PM5CTL0 &= ~LOCKLPM5;               // turn on GPIO system

    UCB0CTLW0 &= ~UCSWRST;              // take B0 out of software reset
    UCB0IE  |= UCTXIE0;                 // enable B0 interrupt for Tx0
    UCB0IE  |= UCRXIE0;                 // enable B0 interrupt for Rx0
    __enable_interrupt();               // enable maskable interrupt

    int i;
	while(1)
	{
        UCB0CTLW0 |= UCTR;              // put into Tx mode (read)
        UCB0CTLW0 |= UCTXSTT;           // manually start message
        while((UCB0IFG & UCSTPIFG) == 0)
            UCB0IFG &= ~UCSTPIFG;       // clear the stop flag

	    UCB0CTLW0 &= ~UCTR;             // put into Rx mode (read)
	    UCB0CTLW0 |= UCTXSTT;           // manually start message
	    while((UCB0IFG & UCSTPIFG) == 0)
	        UCB0IFG &= ~UCSTPIFG;       // clear the stop flag

	}
	return 0;
}

//---Interrupt Routine (ISR)---
#pragma vector = EUSCI_B0_VECTOR
__interrupt void EUSCI_B0_I2C_ISR(void)
{

    switch(UCB0IV){
    case 0x16:                      // RXIFG0
        dataReceived = UCB0RXBUF;   // receive data from slave
        break;
    case 0x18:                      // TXIFG0
        UCB0TXBUF = 0x03;           // send register address to slave
        break;
    default:
        break;

    }


}
