;
;				   Facultad de Ingenieria
;				 Universidad de Buenos Aires
;
;				       Leonel Mendoza
;

;
;	Método para probar en windows 10:
;	Abrir PowerShell, buscar qué COMn es el arduino con: 
;
;		[System.IO.Ports.SerialPort]::getportnames()
;
;	Generar un objeto de la clase puertos:				 
;
;		$port= new-Object System.IO.Ports.SerialPort COMn,9600,None,8,one
;
;	Abrir el puerto:
;
;		$port.open()
;
;	Leer puerto:
;
;		$port.ReadLine()
;
;	Escribir puerto:
;
;		$port.Write()
;
;	Cerrar puerto:
;
;		$port.close()


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
.DEF rdata = R17
.DEF regdata = R18

.EQU LED1 = PD2
.EQU LED2 = PD3
.EQU LED3 = PD4
.EQU LED4 = PD5

.CSEG

	.ORG 0X0000					; En esta direccion escribo la instruccion JMP conf
	JMP conf

	.ORG INT_VECTORS_SIZE		; Direccion donde escribir el codigo

conf:
	SET_SP aux

	LDI	aux, 0b00111110		; PD0 entrada (Rx), PD1 salida (Tx), PD2/3/4/5 salida (LEDs)
	OUT	DDRD, aux

	LDI aux, 0x00			; 9600 BAUD @ 16Mhz ? UBRR0 = 103 (tabla ATmega32 datasheet)
	STS UBRR0H, aux
	LDI aux, 103
	STS UBRR0L, aux

	LDI aux, (1 << UCSZ01 | 1 << UCSZ00)	; format ? 8bit data + 1bit stop
	STS UCSR0C, aux

	LDI aux, (1<<RXEN0 | 1<<TXEN0)
	STS UCSR0B, aux
main:
	SET_Z	MSJ
	CALL	transmit
wait:
    LDS		aux, UCSR0A	; espero recibir datos
	SBRS	aux, RXC0
    RJMP	wait
	LDS		rdata, UDR0
	CALL	toggle_led
	RJMP	wait

transmit:	
	LDS		aux, UCSR0A
	SBRS	aux, UDRE0
	RJMP	transmit	; cuando el buffer de tx esta vacio, mando otro dato
	LPM		aux, Z+
	CPI		aux, 0
	BREQ	end_transmit	; si no hay mas datos apago la interrupción
	STS		UDR0, aux
	RJMP	transmit
end_transmit:
	STS		UDR0, aux ; transmito un ultimo null
	RET


toggle_led:		; prendo el led requerido
	IN		regdata, PORTD		; cargo el estado del puerto
	CPI		rdata, '1'
	BREQ	led1_toggle
	CPI		rdata, '2'
	BREQ	led2_toggle
	CPI		rdata, '3'
	BREQ	led3_toggle
	CPI		rdata, '4'
	BREQ	led4_toggle
	JMP		endrx
led_on:
	EOR		regdata, aux
	OUT		PORTD, regdata
endrx:
	RET
led1_toggle:
	LDI		aux, 0b00000100
	JMP		led_on
led2_toggle:
	LDI		aux, 0b00001000
	JMP		led_on
led3_toggle:
	LDI		aux, 0b00010000
	JMP		led_on
led4_toggle:
	LDI		aux, 0b00100000
	JMP		led_on


.ORG	0x500	MSJ: .db "***Hola Labo de Micro***", '\r', '\n', "Escriba 1, 2, 3 o 4 para controlar los LEDs", '\r', '\n', 0