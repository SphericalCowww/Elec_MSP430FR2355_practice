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
           	bic.b	#BIT0, &P1OUT			; bit set P1.0 to be OFF
			bis.b	#BIT6, &P6DIR			; bit set P1.0 to output (LED2)
           	bis.b	#BIT6, &P6OUT			; bit set P6.6 to be ON
           	bic.b	#LOCKLPM5, &PM5CTL0		; enable digital IO

			;---setup timer B0. Check variables in include/msp430fr2355.h; MSP430fr2355.h only has timer B
			bis.w	#TBCLR, 			&TB0CTL	; clear TB0
			;bis.w	#TBSSEL__ACLK, 	 	&TB0CTL	; choose 32.768kHz clock
			bis.w	#TBSSEL__SMCLK, 	&TB0CTL	; choose 1MHz clock
			bis.w	#ID__4, 			&TB0CTL	; set decimation to 4
			bis.w	#MC__CONTINUOUS, 	&TB0CTL	; choose continuous mode
												; timer B is 16bit by default: (1/32.768k)s*2^16 = 2s
			;bis.w	#CNTL_1,			&TB0CTL	; set to 12bit mode: (1/32.768k)s*2^12 ~ 1/8s
			;---setup overflow interrupt for timer B0
			bic.w	#TBIFG,				&TB0CTL	; clear TB0
			bis.w	#TBIE,				&TB0CTL	; enable TB0 overflow

			;---setup timer B1
			bis.w	#TBCLR, 			&TB1CTL	; clear TB1
			bis.w	#TBSSEL__ACLK, 	 	&TB1CTL	; choose 32.768kHz clock
			bis.w	#MC__UP, 			&TB1CTL	; choose continuous mode
			;---setup compare interrupt for timer B1
			bis.w	#32768,				&TB1CCR0	; setup compare (CCR0) value
													; (1/32.768k)s*32768
			bis.w	#CCIE,				&TB1CCTL0	; enable TB1 compare interrupt
			bic.w	#CCIFG,				&TB1CCTL0	; clear TB1

			eint									; enable global maskable interrupts



main:
			jmp		main


;-------------------------------------------------------------------------------
; Interrupt Service Routines (ISR)
;-------------------------------------------------------------------------------
ISR_TB0_Overflow:
			;xor.b	#BIT0, 	&P1OUT			; toggle P1.0 (LED1 on/off)
			;xor.b	#BIT6, 	&P6OUT			; toggle P6.6 (LED2 on/off)
			bic.w	#TBIFG,	&TB0CTL			; clear TB0
			reti

ISR_TB1_Compare:
			xor.b	#BIT6, 	&P6OUT			; toggle P6.6 (LED2 on/off)
			bic.w	#CCIFG,	&TB1CCTL0		; clear TB1
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
            
			.sect	".int42"				; port 4 interrupt (int) vector; word address 0xFFCE
			.short  ISR_TB0_Overflow		; set to go to the ISR_S1 routine

			.sect	".int41"				; compare interrupt vector for TB1
			.short  ISR_TB1_Compare			; set to go to the ISR_S1 routine
