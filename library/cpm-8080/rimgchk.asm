; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rimgchk.asm                                                                |
; | Reading a logical sector from image, 8080, CP/M-80, v0.1                   |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

	ORG	100h
	EXTRN	RIMG

; **** CONSTANTS ****
BDOS	EQU	05h		; BDOS entry point
BRESET	EQU	00h		; - system reset function
BCNOUT	EQU	02h		; - console output function
BPRINT	EQU	09h		; - print string function
RIINIT	EQU	00h		; Rimglib initialize function
RISTRD	EQU	01h		; Rimglib sector read function
RIDONE	EQU	02h		; Rimglib done function

; **** CODE AREA ****
START:	MVI	A, RIINIT	; A = initialization and open
	MVI	B, 0		; B = mode
	LXI	D, FCB		; DE = address of FCB
	LXI	H, BUFFER	; HL = address of BUFFER
	CALL	RIMG		; call RIMG
	JC	INITER		; detect init error

	MVI	A, RISTRD	; A = read a record
	LHLD	RECNUM		; HL = record number
	XCHG			; DE <-> HL
	CALL	RIMG		; call RIMG
	JC	READER		; detect read error

	LXI	H, BUFFER	; HL = buffer address
	MVI	B, 128		; B = counter
PRLOOP:	MOV	E, M		; print buffer to console with loop
	MVI	C, BCNOUT	; print to console
	PUSH	B
	PUSH	D
	PUSH	H
	CALL	BDOS		; call BDOS
	POP	H
	POP	D
	POP	B
	INX	H
	DCR	B
	JNZ	PRLOOP

DONE:	MVI	A, RIDONE	; A = close and cleanup
	MVI	B, 0		; B = mode
	CALL	RIMG		; call RIMG
	JMP	EXIT		; goto exit

INITER:	LXI	H, MSGINI	; DE = init error message
	JMP	PRNER

READER:	LXI	H, MSGRED	; DE = read error message

PRNER:	MVI	C, BPRINT	; C = print error message
	XCHG
	CALL	BDOS		; call BDOS

EXIT:	MVI	C, BRESET	; C = exit to BDOS
	CALL	BDOS		; call BDOS

; **** DATA AREA ****
RECNUM:	DW	0001h		; logical 128-byte record number
MSGINI:	DB	'Init error!$'
MSGRED:	DB	'Read error!$'
FCB:	DB	0		; drive
	DB	'R128EXRMIMG'	; 8.3 filename
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0,0,0,0,0,0
	DB	0,0,0,0,0
BUFFER:	DS	128, 0
	END	START
