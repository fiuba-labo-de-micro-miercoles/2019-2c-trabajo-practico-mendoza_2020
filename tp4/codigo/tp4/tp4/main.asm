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

.MACRO D10ms ; [reg_cycle], [reg_aux1], [reg_aux2]			9.98 ms
delay:
	clr @2
loop1:
	ldi @1,207
loop2:
	DEC @1			;cuento 256 veces con @1
	BRNE loop2
	DEC @2			;cuento 256 veces el conteo de @1 (256*256)
	BRNE loop1
	DEC @0			;cuento "@0" veces el conteo de @2 (@0*256*256)
	BRNE delay
.ENDM

; * * * * * * * * *
;	END MACROS	  ;
; * * * * * * * * *



.DEF aux = R16
.DEF delay_cycle = R17

.CSEG

	.ORG 0X0000					; En esta direccion escribo la instruccion JMP conf
	JMP conf

	.ORG INT0addr				; Direccion donde escribir el JMP a las rutinas de interrupcion
	JMP isr_int0

	.ORG INT_VECTORS_SIZE		; Direccion donde escribir el codigo

conf:
	SET_SP	aux

	LDI		aux, (0 < PD2 || 0 < PD3)
	OUT		DDRD, aux
;	LDI		aux, (1 < PD2 || 1 < PD3)		; En caso de usar R de pull-up/down descomentar
;	OUT		PORTD, aux

	LDI		aux, (1 << PB0 || 1 << PB1)		; Configuracion de puertos para leds
	OUT		DDRB, aux
	LDI		aux, (1 << PB0 || 0 << PB1)		; Inicializo led_0 on y led_1 off
	OUT		PORTB, aux

	; Configuro interrupciones

	LDI		aux, (1 << ISC01 || 0 << ISC00)
	STS		EICRA, aux
	LDI		aux, (1 << INT0)
	OUT		EIMSK, aux

	SEI								; Habilito Interrupciones

main:
    NOP
    RJMP main

isr_int0:
	CBI		PORTB, PB0				; Apago primer LED
	LDI		aux, 5					; 5 ciclos de 1 Hz
loop_leds:
	SBI		PORTB, PB1
	LDI		delay_cycle, 50			; Uso 50 ciclos de delay 10ms (.5 Hz en alto)
	D10ms delay_cycle, R18, R19
	CBI		PORTB, PB1
	LDI		delay_cycle, 50			; Uso 50 ciclos de delay 10ms (.5 Hz en bajo)
	D10ms delay_cycle, R18, R19
	DEC		aux
	BRNE	loop_leds
	SBI		PORTB,PB0						; Cuando termino prendo el primer LED nuevamente
	RETI