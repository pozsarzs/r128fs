; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rdsclib.asm                                                                |
; | Reading a logical sector from disc, 8088, DOS, v0.1                        |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

TITLE	RDSC - R128 direct sector read library for DOS
NAME	RDSC

; -------- CONSTANTS --------
DOS	EQU	21h		; DOS functions
RNUM	EQU	08h		; number of routines

CSEG	SEGMENT PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG

PUBLIC  RDSC

; -------- CODE AREA --------

;|name   |AL |BX     |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:-----:|:------:|--------|:-----:|:------:|
;|rdsclib|00h|bufaddr|       |        |RDINIT  |0      |bufaddr |
;|rdsclib|01h|sector |discid |track   |RDSTRD  |errcode|bufaddr |
;
; Error codes:
;   00h. no error		CF = 0
;   01h: bad function		CF = 1
;   07h: sector read error	CF = 1
;
; Preserves: CX, SI, DI

; ---- ENTRY POINT AND JUMP TABLE ----
RDSC	PROC	NEAR
	PUSH	CX		; save input CX for caller
	PUSH	SI		; save input SI for caller
	PUSH	DI		; save input DI for caller

	MOV	INP_BX, BX	; save input BX for selected routine 
	MOV	INP_CL, CL	; save input CL for selected routine
	MOV	INP_DX, DX	; save input DX for selected routine

	CMP	AL, RNUM	; compare function code with max valid index
	JAE	MNBADF		; if A >= RNUM: invalid function, jump to MNBADF

	CBW			; AX = AL
	SHL	AX, 1		; AX = AX * 2 (word index into jump table)
	MOV	SI, AX		; SI = AX
	JMP	WORD PTR MNJTAB[SI] ; indirect jump to selected routine

MNJTAB	DW	RDINIT		; 0: initialise module
	DW	RDSTRD		; 1: read a logical sector and write to buffer

MNBADF:	POP     DI		; restore input DI for caller
	POP     SI		; restore input SI for caller
	POP     CX		; restore input CX for caller
	MOV     AL, 01h		; AL = 1 (error: bad function)
	XOR	BX, BX		; BX = 0
	STC			; CF = 1 (return with error)
	RET

; ---- INITIALIZE MODULE ----------------------------------------

;|name   |AL |BX     |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:-----:|:------:|--------|:-----:|:------:|
;|rdsclib|00h|bufaddr|       |        |RDINIT  |0      |bufaddr |

RDINIT:	RET

; ---- READ LOGICAL SECTOR --------------------------------------

;|name   |AL |BX     |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:-----:|:------:|--------|:-----:|:------:|
;|rdsclib|01h|sector |discid |track   |RDSTRD  |errcode|bufaddr |

RDSTRD:	RET

RDSC	ENDP

; -------- DATA AREA --------
INP_BX	DW	0		; input data in BX
INP_CL	DB	0		; input data in CL
INP_DX	DW	0		; input data in DX

CSEG	ENDS
	END
