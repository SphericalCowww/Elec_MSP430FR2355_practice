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

init:										; can check P1, P4 in the registers
			bis.b	#BIT0, &P1DIR			; bit set P1.0 to output (LED1)
            bic.b	#BIT0, &P1OUT			; bit set P1.0 to be OFF

			bic.b	#BIT1, &P4DIR			; bit set P4.1 as input. P4.1 = SWITCH1
			bis.b	#BIT1, &P4REN			; bit set P4.1 to enable pull up/down resistor
			bis.b	#BIT1, &P4OUT			; bit set P4.1 to use pull up resistor

			;bis.b	#BIT1, &P4IES			; bit set P4.1 sensitivity to HIGH-to-LOW, run when pressed
			bic.b	#BIT1, &P4IES			; bit set P4.1 sensitivity to LOW-to-HIGH, run when released

			bic.b	#LOCKLPM5, &PM5CTL0		; enable digital IO

			bic.b	#BIT1, &P4IFG			; bit clear P4IFG
			bis.b	#BIT1, &P4IE			; bit set P4.1 to enable local interrupt
			eint							; enable global maskable interrupts

main:
			jmp		main


;-------------------------------------------------------------------------------
; Interrupt Service Routines (ISR)
;-------------------------------------------------------------------------------
ISR_S1:
			xor.b	#BIT0, &P1OUT			; toggle P1.0 (LED1 on/off)
			bic.b	#BIT1, &P4IFG			; bit clear P4IFG, otherwise stuck in this ISR
			reti							; return from interrupt

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
            
            								; search "interrupt vector" in the manuals
			.sect	".int22"				; port 4 interrupt (int) vector; word address 0xFFCE
			.short  ISR_S1					; set to go to the ISR_S1 routine
