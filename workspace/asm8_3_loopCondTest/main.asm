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

while1:	;while(Var1==3)
			cmp.w	#3, Var1
			jnz		end_while1

			mov.w	#1, Var2
			jmp		while1
end_while1:
			; do nothing
;##############################################
			mov.w	#0, R4
			mov.w	#0, R5
			mov.w	#0, R6
main:
for1:
			inc		R4
			cmp.w	#10, R4
			jnz		for1
;##############################################
if1:
			cmp.w	#10, R5
			jnz		else1
			jmp		end_if1
else1:
			inc.w	R5
end_if1:
			; do nothing
;##############################################
which1:
			cmp.w	#0,	R6
			jz		case1_0
			cmp.w	#1,	R6
			jz		case1_1
			cmp.w	#2,	R6
			jz		case1_2
			jmp		default1
case1_0:
			mov.w	#2, R6
			jmp		end_switch1
case1_1:
			mov.w	#4, R6
			jmp		end_switch1
case1_2:
			mov.w	#1, R6
			jmp		end_switch1
default1:
			mov.w	#100, R6
			jmp		end_switch1
end_switch1:
			; do nothing
;##############################################
			jmp main
;##############################################

			.data
			.retain

Var1:		.short	2
Var2:		.space	2

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
            
