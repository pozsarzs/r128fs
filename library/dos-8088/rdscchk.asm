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

; **** CONSTANTS ****
DOS	EQU	21H		; DOS functions
DPRINT	EQU	09H		; - write string to console
DEXIT	EQU	4CH		; - exit to DOS
RDINIT	EQU	00H		; Rdsclib initialize
RDSTRD	EQU	01H		; Rdsclib sector read

; **** CODE AREA ****
CSEG	SEGMENT	PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
	ORG	100H

EXTRN	RDSC:NEAR

START:	PUSH	CS
	POP	DS		; DS = CS

	MOV	AL, RDINIT	; AL = initialization
	MOV	BX, OFFSET BUFFER ; BX = buffer address
	CALL	RDSC		; call RDSC
	OR	AL, AL
	JNZ	INITER		; detect init error

	MOV	AL, RDSTRD	; AL = read sector
	MOV	BX, SECTOR	; BX = sector number
	MOV	CH, HEAD	; CH = head number
	MOV	CL, DISCID	; CL = disk drive number
	MOV	DX, TRACK	; DX = track number
	CALL	RDSC		; call RDSC
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

PRNER:	MOV	AH, DPRINT	; print error message
	INT	DOS		; call DOS
	MOV	AL, 1		; error code = 1

EXIT:	MOV	AH, DEXIT	; exit to DOS
	INT	DOS		; call DOS

; **** DATA AREA ****interrupt
DISCID	DB	80h
HEAD	DB	0
TRACK	DW	0
SECTOR	DW	1
MSGINI	DB	'Init error!$'
MSGRED	DB	'Read error!$'
BUFFER	DB	512 DUP (?), '$'

CSEG	ENDS
	END	START
