; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rmemchk.asm                                                                |
; | Reading a logical sector from memory, 8088, DOS, v0.1                      |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

; **** CONSTANTS ****
DOS	EQU	21H		; DOS functions
DPRINT	EQU	09H		; - write string to console
DEXIT	EQU	4CH		; - exit to DOS
RMINIT	EQU	00H		; Rmemlib initialize function
RMSTRD	EQU	01H		; Rmemlib sector read function

; **** CODE AREA ****
CSEG	SEGMENT	PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
	ORG	100H

EXTRN	RMEM:NEAR

START:	PUSH	CS
	POP	DS		; DS = CS

	MOV	AL, RMINIT	; AL = initialization
	MOV	BX, OFFSET BUFFER ; BX = address of BUFFER
	MOV	DX, OFFSET ROMIMG ; DX = address of ROMIMG
	CALL	RMEM		; call RMEM
	OR	AL, AL
	JNZ	INITER		; detect init error

	MOV	AL, RMSTRD	; AL = read sector	
	MOV	DX, 0000h	; DX = sector number
	CALL	RMEM		; call RMEM
	OR	AL, AL
	JNZ	READER		; detect read error

	MOV	DX, OFFSET BUFFER ; DX = buffer address
	MOV	AH, DPRINT	; AH = print buffer
	INT	DOS		; call DOS
	MOV	AL, 0		; error code = 0
	JMP	EXIT		; goto EXIT

INITER:	MOV	DX, OFFSET MSGINI ; DX = init error message
	JMP	PRNER

READER:	MOV	DX, OFFSET MSGRED ; DX = read error message

PRNER:	MOV	AH, DPRINT	; AH = print message
	INT	DOS		; call DOS
	MOV	AL, 1		; error code = 1

EXIT:	MOV	AH, DEXIT	; AH = exit to DOS
	INT	DOS		; call DOS

; **** DATA AREA ****
ROMIMG	DB	'Rmemlib test ok.',13,10,'$'
MSGINI	DB	'Init error!$'
MSGRED	DB	'Read error!$'
BUFFER	DB	128 DUP (?)

CSEG	ENDS
	END	START
