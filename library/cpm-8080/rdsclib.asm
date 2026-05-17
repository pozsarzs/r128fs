; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rdsclib.asm                                                                |
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
;|rdsclib|01h|discid |     |track   |sector |RDSTRD  |errcode|bufaddr |
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

	PUSH	A		; save input AF
	SHLD	INPRHL		; save input HL for selected routine 
	MOV	H, D
	MOV	L, E
	SHLD	INPRDE		; save input DE for selected routine
	MOV	A, B
	STA	INPRB		; save input B for selected routine
	POP	A		; restore input AF

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

RDINIT:	LHLD	INPRHL		; get input HL data	
	SHLD	BUFADD		; store buffer starting address

	LHLD	0001h		; HL = BIOS Warm Boot (WBOOT) pointer
	LXI	D, -3		; DE = -3 (0000-0002h: JP nnnn)
	DAD	D		; HL = HL - 3
	SHLD	BFJTAB		; (BFJTAB) = HL, BIOS jump table base address

INITDN: XRA	A		; A = 0, CF = 0
	LHLD	BUFADD		; HL = buffer address
	POP	D		; restore input DE for caller
	POP	B		; restore input BC for caller
	RET

; ---- READ A LOGICAL SECTOR -------------------------------------------

;|name   |A  |B      |C    |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:---:|:------:|:-----:|--------|:-----:|:-------|
;|rdsclib|01h|discid |     |track   |sector |RDSTRD  |errcode|bufaddr |

RDSTRD:	LDA	INPRB		; get input B data
	MOV	C, A
	CALL	BSLDSK		; select disc

	LHLD	INPRDE		; get input DE data
	MOV	B, H
	MOV	C, L
	CALL	BSTRCK		; select track

	LHLD	INPRHL		; get input HL data
	MOV	B, H
	MOV	C, L
	CALL	BSSECT		; select sector

	LHLD	BUFADD
	MOV	B, H
	MOV	C, L
	CALL	BSDMA		; set DMA buffer address

	CALL	BREAD		; read disc

	ORA	A
	JNZ	STRDER	; if result > 0 then goto STRDER
	XRA	A		; A = 0, CF = 0
	JMP	STRDDN		; goto STRDDN

STRDER:	MVI	A, 07h		; A = 7
	STC			; CF = 1
	
STRDDN:	LHLD	BUFADD		; HL = buffer address
	POP	D		; restore input DE for caller
	POP	B		; restore input BC for caller
	RET

; ---- BIOS FUNCTION JUMP TABLE ---------------------------------
BSLDSK:	LHLD	BFJTAB
	LXI	D, 27
	DAD	D
	PCHL			; jump to the BIOS SELDSK routine
BSTRCK:	LHLD	BFJTAB
	LXI	D, 30
	DAD	D
	PCHL			; jump to the BIOS SETTRK routine
BSSECT:	LHLD	BFJTAB
	LXI	D, 33
	DAD	D
	PCHL			; jump to the BIOS SETSEC routine
BSDMA:	LHLD	BFJTAB
	LXI	D, 36
	DAD	D
	PCHL			; jump to the BIOS SETDMA routine
BREAD:	LHLD	BFJTAB
	LXI	D, 39
	DAD	D
	PCHL			; jump to the BIOS READ routine

; -------- DATA AREA --------
INPRB	DB	0		; input data in B
INPRDE	DW	0		; input data in DE
INPRHL	DW	0		; input data in HL
BUFADD	DW	0		; buffer start address
BFJTAB	DW	0		; BIOS functions jump table base address
	END
