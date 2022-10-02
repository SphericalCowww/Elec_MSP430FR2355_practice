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

main:		; check the RESET function in this code. In register SP: stackpointer
			; stack starts right before memory 0x2FFF
			mov.w	#0AAAAh, R4
			mov.w	#0BBBBh, R5
			push.w	R4
			push.w	R5
			pop.w	R6
			;pop.w	R7

			mov.w	#0AAAAh, R4
			call	#subroutine_inv
			mov.w	#0BBBBh, R4
			call	#subroutine_inv
			mov.w	#0CCCCh, R4
			call	#subroutine_inv

			jmp		main
;-------------------------------------------------------------------------------
; Subroutines
;-------------------------------------------------------------------------------
subroutine_inv:		; check 0x8000 for the functions again. In register PC: call address
					; note the return address of subroutine_inv is pushed to the stack
			inv.w	R4
			ret								; return





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
            
