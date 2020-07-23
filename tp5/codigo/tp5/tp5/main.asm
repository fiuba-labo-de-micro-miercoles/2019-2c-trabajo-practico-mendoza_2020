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

.CSEG

	.ORG 0X0000					; En esta direccion escribo la instruccion JMP conf
	JMP conf

	.ORG INT_VECTORS_SIZE		; Direccion donde escribir el codigo

conf:
	SET_SP	aux

	LDI		aux, (0 << PC0)		; inicializo puerto de ADC
	OUT		DDRC, aux

	LDI		aux, 0xFF			; inicializo puerto D como salida
	OUT		DDRD, aux

	LDI		aux, 0b10000111		; inicializo ADC Enable, Prescaler 128
	STS		ADCSRA, aux

	LDI		aux, 0b01100000		; Vref=Vcc, Ajusto izq, ADC0
	STS		ADMUX, aux

	SEI

main:
    LDS		aux, ADCSRA
	ORI		aux, 0x40		; or 1 al bit de ADSC (Start Conversion)
	STS		ADCSRA, aux
	LDS		aux, ADCH		; al tener left adjust, necesito solo los ultimos 6 bits para los 6 leds
	LSR		aux				; tomo los 8 msb del resultado del adc
	LSR		aux				; los divido por 4 para quedarme con los 6 msb
	OUT		PORTD, aux		; pongo el resultado en PORTD (LEDS)
    RJMP	main
