; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rmemlib.asm                                                                |
; | Handler routines for in-memory filesystem, 8088, DOS, v0.1                 |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

TITLE	RMEM - handler routines for in-memory filesystem for DOS
NAME	RMEM

; **** CONSTANTS ****
RNUM	EQU	02h		; number of routines
SECT	EQU	0080h		; logical sector size

; **** CODE AREA ****
CSEG	SEGMENT PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG

PUBLIC  RMEM

; ---- ENTRY POINT AND JUMP TABLE ------------------------------------

;|name   |AL |BX     |CH  |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:--:|:-----:|:------:|--------|:-----:|:------:|
;|rmemlib|00h|bufaddr|    |       |romaddr |RMINIT  |0      |bufaddr |
;|rmemlib|01h|       |    |       |sectnum |RMSTRD  |errcode|bufaddr |
;
; Error codes:
;   00h. no error		CF = 0
;   01h: bad function		CF = 1
;   02h: shift overflow		CF = 1
;   03h: address overflow	CF = 1
;
; Preserves: CX, SI, DI

RMEM	PROC	NEAR
	PUSH	CX		; save input CX for caller
	PUSH	SI		; save input SI for caller
	PUSH	DI		; save input DI for caller

	MOV	INP_BX, BX	; save input BX for selected routine 
	MOV	INP_DX, DX	; save input DX for selected routine

	CMP	AL, RNUM	; compare function code with max valid index
	JAE	MNBADF		; if A >= RNUM: invalid function, jump to MNBADF

	CBW			; AX = AL
	SHL	AX, 1		; AX = AX * 2 (word index into jump table)
	MOV	SI, AX		; SI = AX
	JMP	WORD PTR MNJTAB[SI] ; indirect jump to selected routine

MNJTAB	DW	RMINIT		; 0: initialise module
	DW	RMSTRD		; 1: read a logical sector and write to buffer

MNBADF:	POP	DI		; restore input DI for caller
	POP	SI		; restore input SI for caller
	POP	CX		; restore input DX for caller
	MOV	AL, 01h		; A = 1 (error: bad function)
	XOR	BX, BX		; BX = 0
	STC			; CF = 1 (return with error)
	RET

; ---- INITIALIZE MODULE ---------------------------------------------

;|name   |AL |BX     |CH  |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:--:|:-----:|:------:|--------|:-----:|:------:|
;|rmemlib|00h|bufaddr|    |       |romaddr |RMINIT  |0      |bufaddr |

RMINIT:	MOV	BX, INP_BX	; get input BX data	
	MOV	BUFADD, BX	; store buffer starting address
	MOV	DX, INP_DX	; get input DX data	
	MOV	ROMADD, DX	; store ROM starting address

INITDN: XOR	AL, AL		; A = 0
	CLC			; CF = 0
	POP	DI		; restore input DI for caller
	POP	SI		; restore input SI for caller
	POP	CX		; restore input DX for caller
	RET

; ---- READ A LOGICAL SECTOR -----------------------------------------

;|name   |AL |BX     |CH  |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:--:|:-----:|:------:|--------|:-----:|:------:|
;|rmemlib|01h|       |    |       |sectnum |RMSTRD  |errcode|bufaddr |

RMSTRD:	MOV	AX, INP_DX	; get input DX data to AX
	MOV     CX, 7		; CX = 7 to multiply by 128
    
STRDSH:	SHL	AX, 1		; shift AX to left
	JC	STRDE1		; if C = 1 then goto STRDE1
	LOOP	STRDSH		; if CX > 0 then goto STRDSH

	ADD	AX, ROMADD	; sector address: AX = AX + ROMADD
	JC	STRDE2		; if CF = 1 then goto STRDE2
    
	MOV	SI, AX		; source index: SI = AX = ROM address
	MOV	DI, BUFADD	; destination index: DI = buffer address
	MOV	CX, SECT	; counter: CX = sector count
	CLD			; DF = 0 (forward direction)
	REP	MOVSB		; repeate byte-to-byte block copy

	XOR	AL, AL		; AL = 0
	CLC			; CF = 0
	JMP	SHORT STRDDN	; goto STRDDN

STRDE1:	MOV	AL, 02h		; A = 2
	STC			; CF = 1
	JMP	SHORT STRDDN	; goto STRDDN

STRDE2:	MOV	AL, 03h		; A = 3
	STC			; CF = 1

STRDDN:	MOV	BX, BUFADD	; BX = buffer address
	POP	DI		; restore input DI for caller
	POP	SI		; restore input SI for caller
	POP	CX		; restore input CX for caller
	RET

RMEM	ENDP

; **** DATA AREA ****
INP_BX	DW	0		; input data in BX
INP_DX	DW	0		; input data in DX
BUFADD	DW	0		; buffer start address
ROMADD	DW	0		; ROM start address

CSEG	ENDS
	END
