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
			mov.b	#10101010b, R4					; right click register value to change to binary format
			inv.b	R4
			; the following R5's are know as bit masks
			mov.b 	#00001111b, R5					; R5 is the "and mask" that clears the first 4 digits of R4
			and.b	R5, R4							;and leave the last 4 digits unchanged
			mov.b 	#00001000b, R5					; R5 is the "test mask" that check the 5th digits of R4
			and.b	R5, R4							;if the digit of R4 is 0, then the Z flag in SR shows 0,
													;otherwise 1

			mov.b	#10101010b, R4
			mov.b 	#00001111b, R5					; R5 is the "set mask" that set the last 4 digits of R4 to 1
			or.b	R5, R4							;and leave the first 4 digits unchanged

			mov.b	#10101010b, R4
			mov.b 	#00001111b, R5					; R5 is the "toggle mask" that complement the last 4 digits of R4 to 1
			xor.b	R5, R4							;and leave the first 4 digits unchanged

			mov.b	#10101010b, R4
			bis.b	#11110000b, R4					; bis: bit set
			bic.b	#00001111b, R4					; bic: bit clear

			mov.b	#10101010b, R4
			bit.b	#00100000b, R4					; bit: bit test, via Z flag in SR
			bit.b	#00010000b, R4					; should give Z=1
			cmp.b   #11110000b, R4					; cmp: compare test, if bit the same, via Z flag in SR
			cmp.b   #10101010b, R4					; should give Z=1
			mov.b	#99, R4
			tst.b   R4								; tst: test, test 0 (Z=1) or negative (N=1)
			mov.b	#-99, R4
			tst.b   R4
			mov.b	#0, R4
			tst.b   R4

			mov.b	#00110001b, R4
			clrc									; C=0
			rla.b	R4								; rotate left arithmetically
			rla.b	R4								; it's equivalent to multiply by 2
			rla.b	R4
			rla.b	R4								; should set C to 1
			rla.b	R4
			rla.b	R4
			rla.b	R4
			mov.b	#00110001b, R4
			clrc
			rlc.b	R4								; rotate left with carry
			rlc.b	R4
			rlc.b	R4
			rlc.b	R4
			rlc.b	R4
			rlc.b	R4
			rlc.b	R4
			mov.b	#50, R4							; remember to change register value format to decimal
			clrc
			rra.b	R4								; rotate right arithmetically
			rra.b	R4								; it's equivalent to dividing by 2
			rra.b	R4
			rra.b	R4
			rra.b	R4
			rra.b	R4
			rra.b	R4
			jmp main

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
            
