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

; **** CONSTANTS ****
BDOS	EQU	0005h		; BDOS entry point
BRESET	EQU	00h		; - system reset function
BPRINT	EQU	09h		; - print string function
RMINIT	EQU	00h		; Rmemlib initialize function
RMSTRD	EQU	01h		; Rmemlib sector read function

; **** CODE AREA ****
START:	MVI	A, RMINIT	; A = initialize
	LXI	D, ROMIMG	; DE = address of ROMIMG
	LXI	H, BUFFER	; HL = address of buffer
	CALL	RMEM		; call RMEM
	JC	INITER		; detect init error

	MVI	A, RMSTRD	; A = read a sector
	LXI	D, 0000h	; DE = sector number
	CALL	RMEM		; call RMEM
	JC	READER		; detect read error

	LXI	D, BUFFER	; DE = buffer address
	MVI	C, BPRINT	; C = print buffer
	CALL	BDOS		; call BDOS
	JMP	EXIT		; goto exit

INITER:	LXI	D, MSGINI	; DE = init error
	JMP	PRNER

READER:	LXI	D, MSGRED	; DE = read error

PRNER:	MVI	C, BPRINT	; D = print error message
	CALL	BDOS

EXIT:	MVI	C, BRESET	; C = exit to BDOS
	CALL	BDOS		; call BDOS

; **** DATA AREA ****
ROMIMG:	DB	'Rmemlib test ok.',13,10,'$'
MSGINI:	DB	'Init error!$', 0
MSGRED:	DB	'Read error!$', 0
BUFFER:	DS	128
	END	START

