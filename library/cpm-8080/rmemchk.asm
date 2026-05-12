; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rmemchk.asm                                                                |
; | Reading a logical sector from memory, 8080, CP/M-80, v0.1                  |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

	ORG	100h
	EXTRN	RMEM

; -------- CONSTANTS --------
BDOS	EQU	0005h		; BDOS entry point
RESET	EQU	00h		; BDOS system reset function
PRINT	EQU	09h		; BDOS print string function
RMINIT	EQU	00h		; Rmemlib initialize function
RMSTRD	EQU	01h		; Rmemlib sector read function

; -------- CODE AREA --------
; initialize
START:	MVI	A, RMINIT
	LXI	D, ROMIMG
	LXI	H, BUFFER
	CALL	RMEM
	JC	INITER

; read sector 0
	MVI	A, RMSTRD
	LXI	D, 0000h
	CALL	RMEM
	JC	READER

; print buffer
	LXI	D, BUFFER
	MVI	C, PRINT
	CALL	BDOS
	JMP	EXIT

; handling error
INITER:	LXI	D, MSGINI	; init error
	JMP	PRNER

READER:	LXI	D, MSGRED	; read error

PRNER:	MVI	C, PRINT	; print error message
	CALL	BDOS

EXIT:	LD	C, RESET	; exit to BDOS
	CALL	BDOS

; -------- DATA AREA --------
ROMIMG:	DB	'RMEMLIB TEST OK',13,10,'$'
MSGINI:	DB	'INIT ERROR$', 0
MSGRED:	DB	'READ ERROR$', 0
BUFFER:	DS	128
	END	START
