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

; -------- CONSTANTS --------
DOS	EQU	21H		; DOS functions
DPRINT	EQU	09H		; write string to console function
DEXIT	EQU	4CH		; exit to DOS function
RIINIT	EQU	00H		; Rimglib initialize function
RISTRD	EQU	01H		; Rimglib sector read function
RIDONE	EQU	02H		; Rimglib done function

CSEG	SEGMENT	PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
	ORG	100H

EXTRN	RIMG:NEAR

START:	PUSH	CS
	POP	DS

; initialization
	MOV	AL, RIINIT
	MOV	CL, 0
	MOV	BX, OFFSET BUFFER
	MOV	DX, OFFSET FCB
	CALL	RIMG
	OR	AL, AL
	JNZ	ERROR

; read sector 0
	MOV	AL, RISTRD
	MOV	DX, RECNUM
	CALL	RIMG
	OR	AL, AL
	JNZ	ERROR

; print buffer
	MOV	DX, OFFSET BUFFER
	MOV	AH, DPRINT
	INT	DOS
	MOV	AL, 0		; error code = 0
	JMP	EXIT

; handling error
ERROR:	MOV	DX, OFFSET ERRMSG ; error message
	MOV	AH, DPRINT	; print error message
	INT	DOS
	MOV	AL, 1		; error code = 1

EXIT:	MOV	AH, DEXIT	; exit to DOS
	INT	DOS

; -------- DATA AREA --------
RECNUM 	DW	0001h		; logical 128-byte record number
ERRMSG 	DB	'Read error!$'
FCB 	DB	0		; drive
	DB	'R128EXRMIMG'	; 8.3 filename
	DB	25 DUP (?)
BUFFER	DB	128 DUP (?), '$'

CSEG	ENDS
	END	START
