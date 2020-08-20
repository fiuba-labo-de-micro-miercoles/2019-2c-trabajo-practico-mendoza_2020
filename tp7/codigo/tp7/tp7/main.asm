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
.DEF counter = R17

.CSEG

	.ORG 0X0000					; En esta direccion escribo la instruccion JMP conf
	JMP conf
	
	.ORG INT0addr
	JMP isr_lower				; interrupcion para disminuir brillo

	.ORG INT1addr
	JMP isr_higher				; interrupcion para aumentar brillo

	.ORG INT_VECTORS_SIZE		; Direccion donde escribir el codigo

conf:
	SET_SP	aux

	LDI		aux, 0b01000000		; SALIDA al LED por PD6 (OC0A)	
	OUT		DDRD, aux			; ENTRADA de los dos pulsadores por PD2 y PD3 (interrupciones)

	LDI		aux, 0b10000011		; compare A enabled (noninverting), B disabled, WGM11/10 Fast PWM 0xFF
	OUT		TCCR0A, aux
	LDI		aux, 0b00000001		; Input Capture Noise Cancel 0, Input Capture Edge 0, WGM12 Fast PWM 0xFF
	OUT		TCCR0B, aux			; CS clock normal

	LDI		aux, 0b00001111		; Configuro interrupciones (ambas por ascendente)
	STS		EICRA, aux
	LDI		aux, 0b00000011		; Habilito dos INT
	OUT		EIMSK, aux

	LDI		aux, 127			; pongo el brillo en la mitad
	OUT		OCR0A, aux

	SEI		; Habilito interrupciones

main:
	NOP
	RJMP main

isr_lower:
	IN		aux, OCR0A
	CPI		aux, 0
	BREQ	endl		; si es 0 no puedo bajar mas el brillo, dejo como esta
	LDI		counter, 32
loopl:					; el loop ademas de incrementar sirve de delay,
	DEC		aux			; para no triggerear la isr mas de una vez
	BREQ	endl
	DEC		counter
	BRNE	loopl
endl:
	OUT		OCR0A, aux
	RETI

isr_higher:
	IN		aux, OCR0A
	CPI		aux, 255
	BREQ	endh		; si es 255 no puedo subir mas el brillo, dejo como esta
	LDI		counter, 32
looph:					; el loop ademas de incrementar sirve de delay,
	INC		aux			; para no triggerear la isr mas de una vez
	BREQ	ovf
	DEC		counter
	BRNE	looph
endh:
	OUT		OCR0A, aux
	RETI
ovf:					; si llega a 0 despues de incrementar, se paso
	DEC aux				; decremento para volver a 255
	RJMP endh