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
.equ DELAY = 21

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
	SBI DATA_PORT, PORTD2	;prendo y apago de a un LED
	LDI R22,DELAY
	D10ms R22,R23,R24		;uso este delay (~200 ms)
	CBI DATA_PORT, PORTD2

	SBI DATA_PORT, PORTD3
	LDI R22,DELAY
	D10ms R22,R23,R24
	CBI DATA_PORT, PORTD3

	SBI DATA_PORT, PORTD4
	LDI R22,DELAY
	D10ms R22,R23,R24
	CBI DATA_PORT, PORTD4

	SBI DATA_PORT, PORTD5
	LDI R22,DELAY
	D10ms R22,R23,R24
	CBI DATA_PORT, PORTD5

	SBI DATA_PORT, PORTD6
	LDI R22,DELAY
	D10ms R22,R23,R24
	CBI DATA_PORT, PORTD6

	SBI DATA_PORT, PORTD7
	LDI R22,DELAY
	D10ms R22,R23,R24
	CBI DATA_PORT, PORTD7	;de aca regreso al primer pin

	SBI DATA_PORT, PORTD6
	LDI R22,DELAY
	D10ms R22,R23,R24
	CBI DATA_PORT, PORTD6

	SBI DATA_PORT, PORTD5
	LDI R22,DELAY
	D10ms R22,R23,R24
	CBI DATA_PORT, PORTD5

	SBI DATA_PORT, PORTD4
	LDI R22,DELAY
	D10ms R22,R23,R24
	CBI DATA_PORT, PORTD4

	SBI DATA_PORT, PORTD3
	LDI R22,DELAY
	D10ms R22,R23,R24
	CBI DATA_PORT, PORTD3

	JMP start				;reinicio el tren de leds