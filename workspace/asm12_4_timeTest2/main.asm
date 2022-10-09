;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

init:
			bis.b	#BIT0, &P1DIR			; bit set P1.0 to output (LED1)
           	bis.b	#BIT0, &P1OUT			; bit set P1.0 to be ON
           	bic.b	#LOCKLPM5, &PM5CTL0		; enable digital IO
            ;---setup timer B0. Check variables in include/msp430fr2355.h; MSP430fr2355.h only has timer B
			bis.w	#TBCLR, 			&TB0CTL	; clear TB0
			bis.w	#TBSSEL__ACLK, 	 	&TB0CTL	; choose 32.768kHz clock
			bis.w	#MC__UP, 			&TB0CTL	; choose UP mode
			;---set compares
			mov.w	#32768,				&TB0CCR0	; setup compare (CCR0) value, (1/32768)*32768 = 1s
			mov.w	#4096,				&TB0CCR1	; setup compare (CCR1) value
			bis.w	#CCIE,				&TB0CCTL0	; enable TB0 compare interrupt
			bic.w	#CCIFG,				&TB0CCTL0	; clear TB0, CCTL0
			bis.w	#CCIE,				&TB0CCTL1	; enable TB0 compare interrupt, CCTL1
			bic.w	#CCIFG,				&TB0CCTL1	; clear TB0, CCTL1
			eint									; enable global maskable interrupts

			;---set capture
			bis.w	#CAP,				&TB0CCTL2	; enable TB1 capture mode, CCTL2
			bis.w	#CM__BOTH,			&TB0CCTL2	; enable sensing both edges mode
			bis.w	#CCIS__GND,			&TB0CCTL2	; input signal = GND
			bic.w	#CCIFG,				&TB0CCTL2	; clear TB0, CCTL2
			mov.w	#0,					R4			; initialize R4 register to store the time

main:
			jmp		main
;-------------------------------------------------------------------------------
; Interrupt Service Routines (ISR)
;-------------------------------------------------------------------------------
ISR_TB0_PWM_CCR0:	;PWM: pulse width modulation
			xor.w	#CCIS0,		&TB0CCTL2			; cause capture, check in TB0 registers, check in decimal
			mov.w   &TB0CCR2,	R4					; store captured time in R4
			bic.w	#CCIFG,		&TB0CCTL2			; clear TB0, CCTL2, technically not required because of xor.w

			bis.b	#BIT0, 	&P1OUT					; bit set P1.0 to be ON
			bic.w	#CCIFG,	&TB0CCTL0				; clear TB0, CCTL0
			reti
ISR_TB0_PWM_CCR1:
			xor.w	#CCIS0,		&TB0CCTL2			; cause capture, TB0R is the timer value
			mov.w   &TB0CCR2,	R4					; store captured time in R4
			bic.w	#CCIFG,		&TB0CCTL2			; clear TB0, CCTL2

			bic.b	#BIT0, 	&P1OUT					; bit set P1.0 to be OFF
			bic.w	#CCIFG,	&TB0CCTL1				; clear TB0, CCTL1
			reti
                                            

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
			.sect	".int43"				; for TB0CCR0
			.short  ISR_TB0_PWM_CCR0

			.sect	".int42"				; for TB0CCR1
			.short  ISR_TB0_PWM_CCR1



