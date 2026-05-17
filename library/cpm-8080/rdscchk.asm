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

; -------- CONSTANTS --------
BDOS	EQU	05h		; BDOS entry point
BRESET	EQU	00h		; BDOS system reset function
BCONOUT	EQU	02h		; BDOS console output function
BPRINT	EQU	09h		; BDOS print string function
RDINIT	EQU	00h		; Rdsclib initialize function
RDSTRD	EQU	01h		; Rdsclib sector read function

; -------- CODE AREA --------
START:
; initialization and open
	MVI	A, RDINIT
	LXI	H, BUFFER
	CALL	RDSC
	JC	INITER

; read sector
	LDA	DISCID
	MOV	B, A
	MVI	A, RDSTRD
	LHLD	TRACK
	XCHG
	LHLD	SECTOR
	CALL	RDSC
	JC	READER

; dump buffer to console
	LXI	H, BUFFER
	MVI	B, 128
PRLOOP:	MOV	E, M
	MVI	C, BCONOUT
	PUSH	B
	PUSH	D
	PUSH	H
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	INX	H
	DCR	B
	JNZ	PRLOOP
	JMP	EXIT

; handling error
INITER:	LXI	D, MSGINI	; init error
	JMP	PRNER

READER:	LXI	D, MSGRED	; read error

PRNER:	MVI	C, BPRINT	; print error message
	CALL	BDOS
	
EXIT:	MVI	C, BRESET	; exit to BDOS
	CALL	BDOS

; -------- DATA AREA --------
DISCID 	DB	0
TRACK 	DW	1
SECTOR 	DW	1
MSGINI 	DB	'Init error!$', 0
MSGRED 	DB	'Read error!$', 0
BUFFER 	DS	128, 0
	END	START
