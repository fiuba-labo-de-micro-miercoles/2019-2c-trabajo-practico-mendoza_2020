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

	.ORG UDREaddr				; Interrupción de buffer vacío de tx
	JMP isr_txempty

	.ORG UTXCaddr				; Interrupción de fin de transmisión
	JMP isr_txdone

	.ORG URXCaddr				; Interrupción de fin de recepción
	JMP isr_rxdone

	.ORG INT_VECTORS_SIZE		; Direccion donde escribir el codigo

conf:
	SET_SP aux

	LDI	aux, 0b00111110		; PD0 entrada (Rx), PD1 salida (Tx), PD2/3/4/5 salida (LEDs)
	OUT	DDRD, aux
	LDI aux, 0b00100000		; PB5 como salida para comunicar estados de lectura y escritura
	OUT DDRB, aux

	LDI aux, 0x00			; 9600 BAUD @ 16Mhz ? UBRR0 = 103 (tabla ATmega32 datasheet)
	STS UBRR0H, aux
	LDI aux, 103
	STS UBRR0L, aux

	LDI aux, (1 << UCSZ01 | 1 << UCSZ00)	; format ? 8bit data + 1bit stop
	STS UCSR0C, aux

	LDI aux, (0<<RXCIE0 | 1<<TXCIE0 | 1<<UDRIE0 | 0<<RXEN0 | 1<<TXEN0)
	; habilito las interrupciones de transmision y tx buffer vacio
	STS UCSR0B, aux

	SEI
main:
	SET_Z MSJ	
hold:
    NOP
    RJMP	hold

isr_txempty:	; cuando el buffer de tx esta vacio, mando otro dato
	LPM		aux, Z+
	CPI		aux, 0
	BREQ	end_tx		; si no hay mas datos apago la interrupción
	STS		UDR0, aux
reti_txempty:
	RETI
end_tx:
	STS		UDR0, aux ; transmito un ultimo null
	LDI		aux, (1<<RXCIE0 | 0<<TXCIE0 | 0<<UDRIE0 | 1<<RXEN0 | 0<<TXEN0)
	STS		UCSR0B, aux ; deshabilito transmision, habilito recepcion e int recep completa
	RJMP	reti_txempty

isr_txdone:
	RETI

isr_rxdone:		; recibo la orden para prender algun led
	LDS		rdata, UDR0
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
	RETI
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



.ORG	0x500	MSJ: .db ' ', '*', '*', '*', 'H', 'o', 'l', 'a', ' ', 'L', 'a', 'b', 'o', ' ', 'd', 'e', ' ', 'M', 'i', 'c', 'r', 'o', '*', '*', '*', ':', 'E', 's', 'c', 'r', 'i', 'b', 'a', ' ', '1', ',', ' ', '2', ',', ' ', '3', ' ', 'o', ' ', '4', ' ', 'p', 'a', 'r', 'a', ' ', 'c', 'o', 'n', 't', 'r', 'o', 'l', 'a', 'r', ' ', 'l', 'o', 's', ' ', 'L', 'E', 'D', 's', '\r', '\n', 0