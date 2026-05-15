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

; -------- CONSTANTS --------
DOS	EQU	21H		; DOS functions
DPRINT	EQU	09H		; write string to console function
DEXIT	EQU	4CH		; exit to DOS function
RMINIT	EQU	00H		; Rmemlib initialize function
RMSTRD	EQU	01H		; Rmemlib sector read function

CSEG	SEGMENT	PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
	ORG	100H

EXTRN	RMEM:NEAR

START:	PUSH	CS
	POP	DS

; initialization
	MOV	AL, RMINIT
	MOV	BX, OFFSET BUFFER
	MOV	DX, OFFSET ROMIMG
	CALL	RMEM
	OR	AL, AL
	JNZ	INITER

; read sector 0
	MOV	AL, RMSTRD
	MOV	DX, 0000H
	CALL	RMEM
	OR	AL, AL
	JNZ	READER

; print buffer
	MOV	DX, OFFSET BUFFER
	MOV	AH, DPRINT
	INT	DOS
	MOV	AL, 0		; error code = 0
	JMP	EXIT

; handling error
INITER:	MOV	DX, OFFSET MSGINI ; init error
	JMP	PRNER

READER:	MOV	DX, OFFSET MSGRED ; read error

PRNER:	MOV	AH, DPRINT	; print error message
	INT	DOS
	MOV	AL, 1		; error code = 1

EXIT:	MOV	AH, DEXIT	; exit to DOS
	INT	DOS

; -------- DATA AREA --------
ROMIMG	DB	'RMEMLIB TEST OK', 13, 10, '$'
MSGINI	DB	'INIT ERROR$'
MSGRED	DB	'READ ERROR$'
BUFFER	DB	128 DUP (?)

CSEG	ENDS
	END	START
