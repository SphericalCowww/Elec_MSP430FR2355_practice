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
;---------------------------------------

skip0:
			jmp 	init

init0:
			bis.b	#00000001b, &P1DIR		; bit set P1.0 as output. P1.0 = LED1
			bic.b	#LOCKLPM5, &PM5CTL0		; enable digital IO

			mov.b	#00000001b, R4
			mov.b	#BIT0, R5
			mov.b	P1DIR, R6				; can also check P1 in the registers
			mov.b	P1OUT, R7
main0:
			bis.b	#BIT0, &P1OUT			; turn on LED1
			bic.b	#BIT0, &P1OUT			; turn off LED1
			jmp		main0



init:		; recall bit set/clear in sec7.3
			bis.b	#BIT0, &P1DIR			; bit set P1.0 as output. P1.0 = LED1
			bic.b	#BIT0, &P1OUT			; bit set P1.0 to be OFF

			bic.b	#BIT1, &P4DIR			; bit set P4.1 as input. P4.1 = SWITCH1
			bis.b	#BIT1, &P4REN			; bit set P4.1 to enable pull up/down resistor
			bis.b	#BIT1, &P4OUT			; bit set P4.1 to use pull up resistor

			bic.b	#LOCKLPM5, &PM5CTL0		; enable digital IO

main:
poll_S1:
			bit.b	#BIT1, &P4IN			; bit test P4.1, 0/1 if pressed/not
			jnz		poll_S1
toggle_LED1:
			xor.b	#BIT0, &P1OUT			; toggle LED1
			mov.w	#0FFFFh, R4
delay:
			dec.w	R4
			jnz		delay
			jmp		main

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
            
