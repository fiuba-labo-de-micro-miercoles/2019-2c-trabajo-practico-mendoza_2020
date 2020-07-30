;
;				   Facultad de Ingenieria
;				 Universidad de Buenos Aires
;
;				       Leonel Mendoza
;

.include "m328pdef.inc"

; * * * * * * * * *
;	START MACROS  ;
; * * * * * * * * *

.MACRO SET_SP ;[auxGPR]
	LDI @0, low(RAMEND)
	OUT SPL, @0
	LDI @0, high(RAMEND)
	OUT SPH, @0
.ENDM

.MACRO SET_X ;[LABEL to data memory]
	LDI XL, low(@0)
	LDI XH, high(@0)
.ENDM

.MACRO SET_Y ;[LABEL to data memory]
	LDI YL, low(@0)
	LDI YH, high(@0)
.ENDM

.MACRO SET_Z ;[LABEL to prog memory]
	LDI ZL, low(@0 << 1)
	LDI ZH, high(@0 << 1)
.ENDM

; * * * * * * * * *
;	END MACROS	  ;
; * * * * * * * * *



.DEF aux = R16

.EQU modeFIX = 0
.EQU mode64 = 1
.EQU mode256 = 2
.EQU mode1024 = 3

.CSEG

	.ORG 0X0000					; En esta direccion escribo la instruccion JMP conf
	JMP conf
	
	.ORG OVF1addr
	JMP isr_toggle				; interrupcion del overflow de timer

	.ORG INT_VECTORS_SIZE		; Direccion donde escribir el codigo

conf:
	SET_SP	aux

	LDI		aux, 0x01
	OUT		DDRB, aux
	CLR		aux
	OUT		PORTB, aux
	OUT		DDRD, aux

	LDI		aux, 0b00000000		; compare A & B disabled, WGM11/10 normal
	STS		TCCR1A, aux
	LDI		aux, 0b00000000		; Input Capture Noise Cancel 0, Input Capture Edge 0, WGM13/12 normal
	STS		TCCR1B, aux			; CS no clock source

	LDI		aux, 0b00000001		; Input Capture Int disabled, Compares Int disabled, Overflow int enabled
	STS		TIMSK1, aux

	SEI

main:
	IN		aux, PIND
	ANDI	aux, 0b00000011
    CPI		aux, modeFIX
	BREQ	mfix
	CPI		aux, mode64
	BREQ	m64
	CPI		aux, mode256
	BREQ	m256
	CPI		aux, mode1024
	BREQ	m1024
	;	Delay de 5 ms para evitar pulsos espurios del pulsador
	LDI		R18, 104
    LDI		R19, 229
L1: DEC		R19
    BRNE	L1
    DEC		R18
    BRNE	L1
    RJMP	main
mfix:
	LDS		aux, TCCR1B
	ANDI	aux, 0b11111000		;mask TCCR1B
	STS		TCCR1B, aux
	SBI		PORTB, PB0
	RJMP	main
m64:
	LDS		aux, TCCR1B
	ANDI	aux, 0b11111000		;mask TCCR1B
	ORI		aux, 0b00000011		;CS presc 64 (011)
	STS		TCCR1B, aux
	RJMP	main
m256:
	LDS		aux, TCCR1B
	ANDI	aux, 0b11111000		;mask TCCR1B
	ORI		aux, 0b00000100		;CS presc 256 (100)
	STS		TCCR1B, aux
	RJMP	main
m1024:
	LDS		aux, TCCR1B
	ANDI	aux, 0b11111000		;mask TCCR1B
	ORI		aux, 0b00000101		;CS presc 1024 (101)
	STS		TCCR1B, aux
	RJMP	main

isr_toggle:
	SBIC	PORTB, PB0
	RJMP	led_off
	SBI		PORTB, PB0
end:
	RETI
led_off:
	CBI		PORTB, PB0
	RJMP	end