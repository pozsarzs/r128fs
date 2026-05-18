; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rimgchk.asm                                                                |
; | Reading a logical sector from image, 8088, DOS, v0.1                       |
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
RIINIT	EQU	00H		; Rimglib initialize function
RISTRD	EQU	01H		; Rimglib sector read function
RIDONE	EQU	02H		; Rimglib done function

; **** CODE AREA ****
CSEG	SEGMENT	PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
	ORG	100H

EXTRN	RIMG:NEAR

START:	PUSH	CS
	POP	DS		; DS = CS

	MOV	AL, RIINIT	; AL = initialization
	MOV	CL, 0		; CL = mode
	MOV	BX, OFFSET BUFFER ; BX = buffer address
	MOV	DX, OFFSET FCB	; DX = FCB address
	CALL	RIMG		; call RIMG
	OR	AL, AL
	JNZ	INITER		; detect init error

	MOV	AL, RISTRD	; AL = read sector
	MOV	DX, RECNUM	; DX = sector number
	CALL	RIMG		; call RIMG
	OR	AL, AL
	JNZ	READER		; detect read error

	MOV	DX, OFFSET BUFFER ; buffer address
	MOV	AH, DPRINT	; print buffer
	INT	DOS
	MOV	AL, 0		; error code = 0
	JMP	EXIT

INITER:	MOV	DX, OFFSET MSGINI ; init error
	JMP	PRNER

READER:	MOV	DX, OFFSET MSGRED ; read error

PRNER:	MOV	AH, DPRINT	; print error message
	INT	DOS		; call DOS
	MOV	AL, 1		; error code = 1

EXIT:	MOV	AH, DEXIT	; exit to DOS
	INT	DOS		; call DOS

; **** DATA AREA ****
RECNUM 	DW	0001h		; logical 128-byte record number
MSGINI:	DB	'Init error!$'
MSGRED:	DB	'Read error!$'
FCB 	DB	0		; drive
	DB	'R128EXRMIMG'	; 8.3 filename
	DB	25 DUP (?)
BUFFER	DB	128 DUP (?), '$'

CSEG	ENDS
	END	START
