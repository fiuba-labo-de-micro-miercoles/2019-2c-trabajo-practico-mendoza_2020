;
; tp1.asm
;
; Created: 5/19/2020 22:56:42
; Author : LeoMendU
;

.include "m328pdef.inc"

;defino variables
.equ pinled = PC3
.equ cyc = 1

.cseg

jmp main

main:
	ldi r25,0xff	
	clr r24
	ser r23
	out DDRC,r25	;pongo el portc como salida

loopled:
	sbi PORTC,PC3	;encendido del led
	ldi r22,cyc		;uso este tiempo para el prox retardo
	call retardador22
	cbi PORTC,PC3	;cleareo el pin del puerto para apagar el led
	ldi r22,cyc
	call retardador22
	rjmp loopled

retardador22:			; delay de aproximadamente 10.9 ms * R22
	clr r21
loopretard1:
	clr r20
loopretard2:
	dec r20					;cuento 256 veces con R20
	brne loopretard2
	dec r21					;cuento 256 veces el conteo de R20 (hasta ahora 256*256)
	brne loopretard1
	dec r22					;cuento "R22" veces el conteo de R21 (R22*256*256)
	brne retardador22
	ret