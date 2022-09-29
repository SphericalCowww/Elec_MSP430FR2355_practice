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
			mov.b	#253, R4
			mov.b	#0, R5
main:										; the instruction addresses starts in 0x8000 in memory
			;mov.w	#0, R4					; track these addresses via PC (program counter) in registers
			;jmp		action2

			add.b	#1, R4
			cmp		#255, R4
			;jc		c_cond1					; jump if carry = 0 (register SR: C)
			;jnc		c_cond2					; jump if carry = 1 (register SR: C)
			;jz		z_cond1					; jump if zero = 1 (register SR: Z)
			;jnz		z_cond2					; jump if zero = 0 (register SR: Z)

			;tst.b	R4
			;jn		n_cond1					; jump if negative = 1 (register SR: N)
			;jmp		n_cond2

			cmp.b	#8, R5
			jge		e_cond1					; jump if great than equal from cmp (register SR: N xor V=0)
			jl		e_cond2					; jump if less than from cmp (register SR: N xor V=1)

action1:
			mov.w	#1, R4
			jmp		done
action2:
			mov.w	#2, R4
			jmp		action1
c_cond1:
			mov.w	#1, R5
			jmp		main
c_cond2:
			mov.w	#2, R5
			jmp		main
z_cond1:
			mov.w	#3, R5
			jmp		main
z_cond2:
			mov.w	#4, R5
			jmp		main
n_cond1:
			mov.w	#5, R5
			jmp		main
n_cond2:
			mov.w	#6, R5
			jmp		main
e_cond1:
			mov.w	#7, R5
			jmp		main
e_cond2:
			mov.w	#8, R5
			jmp		main
done:
			br		#main					; WARNING: jump to the instruction's address
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
            
