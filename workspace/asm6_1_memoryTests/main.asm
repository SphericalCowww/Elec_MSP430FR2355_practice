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

main:										;use break point and step mode
			mov.w 	SP, R4					;copy value from register PC to R4
			mov.w 	R4, R5
			mov.w 	R4, R6

			mov.b	PC, R7
			mov.b	R7, R8
			mov.w	R8, R9


			mov.w	#1234h, R4
			mov.w	#0FFFFFh, R5
			mov.b	#0FFFFFh, R6

			mov.w	#123, R7				;right click register values to choose readout format
			mov.w	#1101010b, R8
			mov.w	#'d', R9				;ASCII code for the string


			mov.w	&2000h,	R4				; copy contant from memory 2000h to R4
			mov.w	R4, &2004h				; remember to open Memory Browser
			mov.w	&2002h,	R5
			mov.w	R5, &2006h
			mov.w	&2002h, &2006h

			mov.w	Const1, R6
			mov.w	R6, Var3
			mov.w	Const2, Var4


			jmp 	main

			.data							; got to data memory
			.retain							; handles .data for now

Const1:		.short		1234h				; constant at memory 2000h
Const2:		.short		0CAFEh				; constant at memory 2002h
Var1:		.space		2
Var2:		.space		2
Var3:		.space		2
Var4:		.space		2

                                            

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
            
