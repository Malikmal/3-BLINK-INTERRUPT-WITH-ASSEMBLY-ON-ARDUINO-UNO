;
; AssemblerApplication1.asm
;
; Created: 18/11/2018 11:29:29
; Author : Ikmalil Birri
;
; Replace with your application code

;;;; 3 BLINK INTERRUPT FIX
;
; ARDUINO UNO - ATMEGA328P - CLOCK 16MHz
;
;   NO PRESCALER F = 16 MHz     -> T = 1/16 uS   -> 1/16 uS * 255   = 16 uS (1x OVERFLOW)
; /256 PRESCALER F = 16/256 MHz -> T = 256/16 uS -> 256/16 uS * 255 = 4 mS (1x OVERFLOW)     FIX USE /256 PRESCALER
;
; FIND START TCNT0 
;  IF 1 = 0 mS and 255 = 4 mS  so.. to get 1 mS is
;    -> 255/x = 4/1
;    -> x = 255/4 
;    -> x = 63.75  (~64)
;

  .include "m328Pdef.inc"


.ORG 0x00
	RJMP RESET

.ORG OVF0addr		;TIMER/COUNTER0 OVERFLOW INTERRUPT ADDRESS
	RJMP OVERFLOW0

.DEF overflowcounterL = R25       ;lowbyte
.DEF overflowcounterH = R24       ;highbyte

.ORG 0x0100
RESET :
	LDI overflowcounterL, 0
	LDI overflowcounterH, 0

	LDI R20, HIGH(RAMEND)
	OUT SPH, R20
	LDI R20, LOW(RAMEND)
	OUT SPH, R20

	LDI R20, 1<<TOIE0
	STS TIMSK0, R20	; ENABLE TIMER INTERRRUPT MASK FOR INTERRUPT OVERFLOW
	SEI				; ENABLE INTERRUPT
	LDI R20, -64	; START COUNTER TO GET 1 MS WITH PRESCALER /256 FOR 16MHz CLOCK
	OUT TCNT0, R20
	LDI R20, 0x00
	OUT TCCR0A, R20	; NORMAL CLOCK
	LDI R20, 0x04
	OUT TCCR0B, R20 ; PRESCALING /256
	LDI R20, 0xFF
	OUT DDRB, R20	; MAKE PORTB AS OUTPUT
	//SBI DDRB, 5
MAIN :
	LDI R16,0
	JMP MAIN

.ORG 0x0200
OVERFLOW0 : 
;1xOVERFLOW = 1 mS
	
	;FOR BLINK INTERRUPT every 1 mS on portb.5 = digital pin 13	
	SBIS PORTB, 5
	JMP ONTO0
	CBI PORTB, 5
	JMP ONBACK0
ONTO0:
	SBI PORTB, 5

ONBACK0 :

	INC overflowcounterL			
	CPI overflowcounterL, 0xFF	;check if overflowcounterL is out of 8 bit max(255)
	BREQ  ADDHIGH
	JMP NEXT
ADDHIGH:						;if out of 8 bit max (255) put carry on overflowcounterH 
	INC overflowcounterH		; and set overflowcounterL to be 0 again
	LDI overflowcounterL, 0
NEXT :							
	CPI overflowcounterH, 1		;check if overflowcounterH is 1, result from  statement before
	BREQ NEXT2
	CPI overflowcounterL, 100	; 100 ms,		if overflow has 100 times so that is same with 100 mS
	BREQ GOBLINK1
	CPI overflowcounterL, 200	; 200 ms		if overflow has 200 times so that is same with 200 mS
	BREQ GOBLINK2
	JMP NOTHING 
NEXT2 :
	CPI overflowcounterL, 45  ;	300 mS			if overflow has 300 times so that is same with 300 mS
	BREQ GOBLINK3

NOTHING :					  ; reset TCNT0
	LDI R20, -64
	OUT TCNT0, R20
	RETI
	
;MENGATASI ERROR RELATIVE BRACH OUT OF REACH (BREQ)
GOBLINK1 : RJMP BLINK1
GOBLINK2 : RJMP BLINK2
GOBLINK3 : RJMP BLINK3 



.ORG 0x0300					; BLINK 100 mS on PORTB.0 is same with digital pin 8
BLINK1 :
	SBIS PORTB, 0
	JMP ONTO1
	CBI PORTB, 0

ONBACK1 :					; reset TCNT0
	LDI R20, -64
	OUT TCNT0, R20
	RETI

ONTO1:
	SBI PORTB, 0
	JMP ONBACK1


.ORG 0x0400					; BLINK 200 mS on PORTB.1 is same with digital pin 9
BLINK2 :
	SBIS PORTB, 1
	JMP ONTO2
	CBI PORTB, 1
		
ONBACK2 :					; RESET TCNT0
	LDI R20, -64
	OUT TCNT0, R20
	RETI

ONTO2:
	SBI PORTB, 1
	JMP ONBACK2


.ORG 0x0500				; BLINK 300 mS on PORTB.2 is same with digital pin 10
BLINK3 :
	SBIS PORTB, 2
	JMP ONTO3
	CBI PORTB, 2

ONBACK3 :				; RESET TCNT0		
	LDI R20, -64
	OUT TCNT0, R20
						; reset overflow counter 
	LDI overflowcounterH, 0	
	LDI overflowcounterL, 0
	RETI

ONTO3:
	SBI PORTB, 2
	JMP ONBACK3
