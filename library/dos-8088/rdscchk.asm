; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rdscchk.asm                                                                |
; | Reading a sector from disc, 8088, DOS, v0.1                                |
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
RDINIT	EQU	00H		; Rdsclib initialize function
RDSTRD	EQU	01H		; Rdsclib sector read function

; -------- CODE AREA --------
CSEG	SEGMENT	PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
	ORG	100H

EXTRN	RDSC:NEAR

START:	PUSH	CS
	POP	DS

; initialization
	MOV	AL, RDINIT
	MOV	BX, OFFSET BUFFER
	CALL	RDSC
	OR	AL, AL
	JNZ	INITER

; read sector
	MOV	AL, RDSTRD
	MOV	BX, SECTOR
	MOV	CH, HEAD
	MOV	CL, DISCID
	MOV	DX, TRACK
	CALL	RDSC
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
DISCID:	DB	0
HEAD:	DB	0
TRACK:	DW	1
SECTOR:	DW	1
MSGINI:	DB	'Init error!$'
MSGRED:	DB	'Read error!$'
BUFFER	DB	512 DUP (?), '$'

CSEG	ENDS
	END	START
