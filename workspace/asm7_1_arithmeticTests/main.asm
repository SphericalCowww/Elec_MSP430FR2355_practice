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

main:
			mov.w	#371, R4				; can change the value of the registers to deci by right click
			mov.w	#465, R5				; register SR is the status
			add.w	R4, R5

			mov.w	#0FFFEh, R6
			add.w	#0001h, R6				; check N in SR
			add.w	#1, R6					; check Z, C in SR
			add.w	#-1, R6					; check Z, C in SR

			mov.w	#Var1, R4
			mov.w	#Var2, R5
			mov.w	#Sum12, R6
			mov.w   0(R4), R7
			mov.w   0(R5), R8
			add.w	R7, R8					; add smaller 16-bit
			mov.w	R8, 0(R6)
			mov.w   2(R4), R7
			mov.w   2(R5), R8
			addc.w  R7, R8					; add larger 16-bit with carry
			mov.w	R8, 2(R6)

			jmp 	main


			.data
			.retain
Var1:		.long	4444FFFFh
Var2:		.long	33330002h
Sum12:		.space	4



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
            
