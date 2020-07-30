;
; tp3.asm
;
; Created: 3/3/2020 18:50:25
; Author : LeoMendU
;


.include "m328pdef.inc"

; Defino mis puertos de salida, ciclos de delay

.EQU DD_PORT = DDRD
.EQU DATA_PORT = PORTD
.EQU DELAY = 21
.DEF aux = R16
.DEF counter = R17

.MACRO D10ms ; [reg_cycles], [reg_aux1], [reg_aux2]			~9.98 ms
delay:
	clr @2
loop1:
	ldi @1,207
loop2:
	dec @1			;cuento 256 veces con @1
	brne loop2
	dec @2			;cuento 256 veces el conteo de @1 (256*256)
	brne loop1
	dec @0			;cuento "@0" veces el conteo de @2 (@0*256*256)
	brne delay
.ENDMACRO

.CSEG

	JMP MAIN

.ORG INT_VECTORS_SIZE

main:

	LDI R20, (1<<2 | 1<<3 | 1<<4 | 1<<5 | 1<<6 | 1<<7)
	OUT DD_PORT,R20

start:
	LDI aux, 0b00000100		; prendo y apago de a un LED mediante shifts
	OUT PORTD, aux			; prendo el primero
	LDI counter, 5
loop_forw:
	LSL aux					; shift left
	LDI R22,DELAY
	D10ms R22,R23,R24		;delay (~200 ms)
	OUT PORTD, aux
	DEC counter
	BRNE loop_forw
	LDI counter, 5
loop_back:
	LSR	aux
	LDI R22,DELAY
	D10ms R22,R23,R24		;delay (~200 ms)
	OUT PORTD, aux
	DEC counter
	BRNE loop_back
	LDI	counter, 5
	RJMP loop_forw