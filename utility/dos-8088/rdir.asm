; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rdir.asm                                                                   |
; | rdir utility, 8088, DOS, v0.1                                              |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

; -------- CONSTANTS --------
DOS	EQU	21H		; DOS functions
DPRINT	EQU	09H		; - write string to console
DEXIT	EQU	4CH		; - exit to DOS

; **** CODE AREA ****

CSEG	SEGMENT	PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG
	ORG	100H

EXTRN	R128:NEAR

START:	PUSH	CS
	POP	DS

;(..)

ERROR:	MOV	DX, OFFSET ERRMSG ; error message
	MOV	AH, DPRINT	; print error message
	INT	DOS
	MOV	AL, 1		; error code = 1

EXIT:	MOV	AH, DEXIT	; exit to DOS
	INT	DOS

; -------- DATA AREA --------
ERRMSG 	DB	'Error!$'

CSEG	ENDS
	END	START
