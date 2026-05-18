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
BIOS13	EQU	13h		; BIOS disk handler interrupt
B13RDST	EQU	02h		; - read sector function
RNUM	EQU	02h		; number of routines

CSEG	SEGMENT PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG

PUBLIC  RDSC

; -------- CODE AREA --------

;|name   |AL |BX     |CH  |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:--:|:-----:|:------:|--------|:-----:|:------:|
;|rdsclib|00h|bufaddr|    |       |        |RDINIT  |0      |bufaddr |
;|rdsclib|01h|sector |head|discid |track   |RDSTRD  |errcode|bufaddr |
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

	MOV	INPRBX, BX	; save input BX for selected routine 
	MOV	INPRCH, CH	; save input CL for selected routine
	MOV	INPRCL, CL	; save input CL for selected routine
	MOV	INPRDX, DX	; save input DX for selected routine

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

;|name   |AL |BX     |CH  |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:--:|:-----:|:------:|--------|:-----:|:------:|
;|rdsclib|00h|bufaddr|    |       |        |RDINIT  |0      |bufaddr |

RDINIT:	MOV	BX, INPRBX	; get input BX data	
	MOV	BUFADD, BX	; store buffer starting address

INITDN: MOV	BX, BUFADD	; BX = buffer address
	XOR	AL, AL		; AL = 0, CF = 0
	POP     DI		; restore input DI for caller
	POP     SI		; restore input SI for caller
	POP     CX		; restore input CX for caller
	RET

; ---- READ A SECTOR -------------------------------------------------

;|name   |AL |BX     |CH  |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:--:|:-----:|:------:|--------|:-----:|:------:|
;|rdsclib|01h|sector |head|discid |track   |RDSTRD  |errcode|bufaddr |

RDSTRD:	PUSH	DS		; save DS
	POP	ES		; ES = restored DS

	MOV	AH, B13RDST	; function code
	MOV	AL, 1		; sector number
	MOV	BX, BUFADD	; buffer address
	MOV	CH, BYTE PTR INPRDX ; track number
	MOV	CL, BYTE PTR INPRBX ; sector number
	MOV	DH, INPRCH	; head number
	MOV	DL, INPRCL	; disc drive number
	INT	BIOS13		; call BIOS function
	JC	STRDER		; if C = 1 then goto STRDER
	XOR	AL, AL		; AL = 0, CF = 0
	
STRDDN:	MOV	BX, BUFADD	; BX = buffer address
	POP     DI		; restore input DI for caller
	POP     SI		; restore input SI for caller
	POP     CX		; restore input CX for caller
	RET

STRDER:	MOV	AL, 07h		; AL = 7
	STC			; CF = 1
	JMP	STRDDN		; goto STRDDN

RDSC	ENDP

; -------- DATA AREA --------
INPRBX	DW	0		; input data in BX
INPRCH	DB	0		; input data in CH
INPRCL	DB	0		; input data in CL
INPRDX	DW	0		; input data in DX
BUFADD	DW	0		; buffer start address

CSEG	ENDS
	END
