; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rdscchk.asm                                                                |
; | Reading a logical sector from disc, 8080, CP/M, v0.1                       |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

	ORG	100h
	EXTRN	RDSC

; **** CONSTANTS ****
BDOS	EQU	05h		; BDOS entry point
BRESET	EQU	00h		; - system reset function
BCONOUT	EQU	02h		; - console output function
BPRINT	EQU	09h		; - print string function
RDINIT	EQU	00h		; Rdsclib initialize function
RDSTRD	EQU	01h		; Rdsclib sector read function

; **** CODE AREA ****
START:	MVI	A, RDINIT	; A = initialization
	LXI	H, BUFFER	; HL = buffer address
	CALL	RDSC		; call RDSC
	JC	INITER		; detect init error

	LDA	DISCID		; A = disc ID
	MOV	B, A
	MVI	A, RDSTRD	; A = read sector
	LHLD	TRACK		; HL = track number
	XCHG			; DE <-> HL
	LHLD	SECTOR		; HL = sector number
	CALL	RDSC		; call RDSC
	JC	READER		; detect read error

; dump buffer to console
	LXI	H, BUFFER	; HL = buffer address
	MVI	B, 128		; counter
PRLOOP:	MOV	E, M		; print buffer to console with loop
	MVI	C, BCONOUT	; print to console
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
	JMP	EXIT		; goto EXIT

; handling error
INITER:	LXI	D, MSGINI	; DE = init error message
	JMP	PRNER

READER:	LXI	D, MSGRED	; DE = read error message

PRNER:	MVI	C, BPRINT	; C = print error message
	CALL	BDOS		; call BDOS
	
EXIT:	MVI	C, BRESET	; C = exit to BDOS
	CALL	BDOS		; call BDOS

; **** DATA AREA ****
DISCID 	DB	0
TRACK 	DW	1
SECTOR 	DW	1
MSGINI 	DB	'Init error!$', 0
MSGRED 	DB	'Read error!$', 0
BUFFER 	DS	128, 0
	END	START
