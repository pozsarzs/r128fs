; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | remxlib.asm                                                                |
; | Reading a logical sector from disc, 8080, CP/M, v0.1                       |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

PUBLIC RDSC

; -------- CONSTANTS --------
BDOS	EQU	05h		; BDOS entry point
RNUM	EQU	02h		; number of routines

; -------- CODE AREA --------

;|name   |A  |B      |C    |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:---:|:------:|:-----:|--------|:-----:|:-------|
;|rdsclib|00h|       |     |        |bufaddr|RDINIT  |0      |bufaddr |
;|rdsclib|01h|discid |track|sector  |       |RDSTRD  |errcode|bufaddr |
;
; Error codes:
;   00h. no error		CF = 0
;   01h: bad function		CF = 1
;   07h: sector read error	CF = 1
;
; Preserves: BC, DE
; Clobbers:  AF, HL

; ---- ENTRY POINT AND JUMP TABLE ----
RDSC:	PUSH	B		; save input BC for caller
	PUSH	D		; save input DE for caller

	SHLD	INPRHL		; save input HL for selected routine 
	MOV	H, D
	MOV	L, E
	SHLD	INPRDE		; save input DE for selected routine

	CPI	RNUM		; compare A (function code) with max valid index
	JNC	MNBADF		; if A >= RNUM: invalid function, jump to MNBADF

	ADD	A		; A = A * 2 (word index into jump table)
	MOV	L, A
	MVI	H, 0		; HL = zero-extended offset
	LXI	D, MNJTAB	; DE = address of jump table entry
	DAD	D		; HL = address of table + offset

	MOV	E, M		; load low byte of handler address
	INX	H
	MOV	D, M		; load high byte
	XCHG			; HL = handler address
	PCHL			; indirect jump to selected routine

MNJTAB:	DW	RDINIT		; 0: initialize module
	DW	RDSTRD		; 1: read a logical sector and write to buffer

MNBADF:	POP	D		; restore input DE for caller
	POP	B		; restore input BC for caller
	MVI	A, 01h		; A = 1 (error: bad function)
	LXI	H, 0000h	; HL = 0
	STC			; CF = 1 (return with error)
	RET

; ---- INITIALIZE MODULE -----------------------------------------------

;|name   |A  |B      |C    |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:---:|:------:|:-----:|--------|:-----:|:-------|
;|rdsclib|00h|       |     |        |bufaddr|RDINIT  |0      |bufaddr |

RDINIT:	RET

; ---- READ A LOGICAL SECTOR -------------------------------------------

;|name   |A  |B      |C    |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:---:|:------:|:-----:|--------|:-----:|:-------|
;|rdsclib|01h|discid |track|sector  |       |RDSTRD  |errcode|bufaddr |

RDSTRD:	RET

; -------- DATA AREA --------
INP_B:	DB	0		; input data in B
INP_C:	DB	0		; input data in C
INP_DE:	DW	0		; input data in DE
INP_HL:	DW	0		; input data in HL
BUFADD:	DW	0		; buffer start address
	END
