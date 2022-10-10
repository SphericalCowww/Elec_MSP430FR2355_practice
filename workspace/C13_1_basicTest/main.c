#include <msp430.h> 


// NOTE: Disassembly in View shows the compiled assembly code; search for main
// NOTE: Project > Properties > Optimization > off to see more understandable assembly code
// Variables instead of Registers now finally shows some items
int main(void)
{
	WDTCTL = WDTPW | WDTHOLD;	// stop watchdog timer

	// bit-wise logic
	// NOTE: set value in Variables binary
	int a = 0b1111111111111110;
	a = ~a;                             // invert all bits in a
	a = a | BIT7;                       // set bit 7 in a
	a = a & ~BIT0;                      // clear bit 0 in a
	a = a ^ BIT4;                       // toggle bit 4 in a

	a = a << 1;                         // bit left-rotate by 1 step
	a = a >> 3;

	int i = 0;
	int count = 0;
	while(1)
	{
	    for(i=0; i<10; i++)
	    {
	        if(i <= 3)
	            count *= i;
	        else
	            count++;
	    }
	}
	return 0;                   // not useful for msp430
}
