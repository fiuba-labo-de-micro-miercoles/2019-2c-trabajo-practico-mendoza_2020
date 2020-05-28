;
; tp2.asm
;
; Created: 5/26/2020 20:46:11
; Author : LeoMendU
;

.include "m328pdef.inc"

; Defino mis puertos de salida/entrada, 
; y su configuracion.

; Quiero usar el puerto D

.EQU PORT_IN = PIND
.EQU PORT_OUT = PORTD
.EQU PORT_CONF = DDRD
.EQU PIN_IN = PIND2
.EQU PIN_OUT = PORTD3

.CSEG

	JMP MAIN

.ORG INT_VECTORS_SIZE

main:

; Inicializo los puertos
	LDI R20, (0<<0 | 0<<1 | 0<<2 | 1<<3)
	OUT PORT_CONF, R20
	SBI PORTD, PIN_IN		; Habilito R de pull-up

start:
; Pregunto LOW
	SBIC PORT_IN, PIN_IN	; Si esta en 1, sigo con la instruccion (apago led)
	CBI PORT_OUT, PIN_OUT	; Si esta en 0, skipeo la instruccion (Pregunto HIGH)
; Pregunto HIGH
	SBIS PORT_IN, PIN_IN	; Si esta en 0, sigo con la instruccion (prendo led)
	SBI PORT_OUT, PIN_OUT	; Si esta en 1, skipeo (Pregunto LOW)
	JMP start