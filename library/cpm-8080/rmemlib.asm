; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rmemlib.asm                                                                |
; | Handler routines for in-memory filesystem, 8080, CP/M-80, v0.1             |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

PUBLIC	RMEM

; **** CONSTANTS ****
RNUM	EQU	02h		; number of routines
SECT	EQU	0080h		; logical sector size

; **** CODE AREA ****

; ---- ENTRY POINT AND JUMP TABLE --------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|rmemlib|00h|       |      |romaddr |bufaddr|RMINIT  |0      |bufaddr |
;|rmemlib|01h|       |      |sectnum |       |RMSTRD  |errcode|bufaddr |
;
; Error codes:
;   00h. no error		CF = 0
;   01h: bad function		CF = 1
;   02h: shift overflow		CF = 1
;   03h: address overflow	CF = 1
;
; Preserves: BC, DE
; Clobbers:  AF, HL

RMEM:	PUSH	B		; save input BC for caller
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

MNJTAB:	DW	RMINIT		; 0: initialize module
	DW	RMSTRD		; 1: read a logical sector and write to buffer

MNBADF:	POP	D		; restore input DE for caller
	POP	B		; restore input BC for caller
	MVI	A, 01h		; A = 1 (error: bad function)
	LXI	H, 0000h	; HL = 0
	STC			; CF = 1 (return with error)
	RET

; ---- INITIALIZE MODULE -----------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|rmemlib|00h|       |      |romaddr |bufaddr|RMINIT  |0      |bufaddr |

RMINIT:	LHLD	INPRHL		; get input HL data
	SHLD	BUFADD		; store buffer starting address
	LHLD	INPRDE		; get input DE data

	SHLD	ROMADD		; store ROM starting address

INITDN: XRA	A		; A = 0, CF = 0
	LHLD	BUFADD		; HL = buffer address
	POP	D		; restore input DE for caller
	POP	B		; restore input BC for caller
	RET

; ---- READ A LOGICAL SECTOR -------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|rmemlib|01h|       |      |sectnum |       |RMSTRD  |errcode|bufaddr |

RMSTRD: LHLD	INPRDE		; get input DE data
	XCHG			; HL <-> DE
	LHLD	ROMADD		; load ROM start address
	MVI	B, 7		; counter value

STRDSH:	MOV	A, E		; A = E
	ADD	A		; A = A + A (MSB -> CF, LSB = 0)
	MOV	E, A		; E = AE
	MOV	A, D		; A = A
	ADC	A		; A = A + A + CF (MSB -> CF, LSB = previous CF)
	MOV	D, A		; D = A
	JC	STRDE1		; if CF = 1 then goto STRDE1

	DCR	B		; decrement counter
	JNZ	STRDSH		; if b > 0 then goto STRDSH

	DAD	D		; sector address in HL (= HL + DE)
	JC	STRDE2		; if CF = 1 then goto STRDE2

	LXI	B, SECT		; set counter
	PUSH	H		; store sector address
    	LHLD	BUFADD		; HL =  buffer address
	XCHG			; DE <-> HL
	POP	H		; restore HL address
STRDCP:	MOV	A, M		; A = (HL)
	STAX	D		; (DE) = A
	INX	H		; increment sorce pointer
	INX	D		; increment target pointer
	DCX	B		; decrement counter
	MOV	A, B		; A = B
	ORA	C		; A = A OR C
	JNZ	STRDCP		; if BC <> 0 goto STRDCP

	XRA	A		; A = 0, CF = 0
	JMP	STRDDN		; goto STRDDN

STRDE1:	MVI	A, 02h		; A = 2
	STC			; CF = 1
	JMP	STRDDN		; goto STRDDN

STRDE2:	MVI	A, 03h		; A = 3
	STC			; CF = 1
	
STRDDN:	LHLD	BUFADD		; HL = buffer address
	POP	D		; restore input DE for caller
	POP	B		; restore input BC for caller
	RET

; **** DATA AREA ****
INPRDE:	DW	0		; input data in DE
INPRHL:	DW	0		; input data in HL
BUFADD:	DW	0		; buffer start address
ROMADD:	DW	0		; ROM start address
	END
