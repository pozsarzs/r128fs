; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | r128lib.asm                                                                |
; | Interface between the app. and hardware-handling modules, 8080, CP/M, v0.1 |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

PUBLIC	R128
EXTRN	RDSC
EXTRN	REMX
EXTRN	RIMG
EXTRN	RMEM

; **** CONSTANTS ****
BDOS	EQU	05h		; BDOS entry point
RINIT	EQU	00h		; R???lib initialize function
RSTRD	EQU	01h		; R???lib sector read function
RDONE	EQU	02h		; R???lib done function
RNUM	EQU	08h		; number of routines

; **** CODE AREA ****

; ---- ENTRY POINT AND JUMP TABLE --------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|r128lib|00h|discid |      |        |bufaddr|R128IN  |errcode|bufaddr |
;|r128lib|01h|       |      |maskaddr|       |R128FF  |errcode|entryptr|
;|r128lib|02h|       |      |        |       |R128FN  |errcode|entryptr|
;|r128lib|03h|       |      |nameaddr|       |R128OP  |errcode|        |
;|r128lib|04h|       |      |count   |bufaddr|R128RD  |errcode|bytesrd |
;|r128lib|05h|       |      |pos     |       |R128SK  |errcode|        |
;|r128lib|06h|       |      |        |       |R128CL  |errcode|        |
;|r128lib|07h|       |      |        |       |R128NF  |errcode|infoptr |
;
; Error codes:
;   00h. no error		CF = 0
;   01h: bad function		CF = 1
;   02h: shift overflow		CF = 1
;   03h: address overflow	CF = 1
;   04h: file open error	CF = 1
;   05h: file read error	CF = 1
;   06h: file close error	CF = 1
;   07h: sector read error	CF = 1
;
; Preserves: BC, DE
; Clobbers:  AF, HL

R128:	PUSH	B		; save input BC for caller
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

MNJTAB:	DW	R128IN		; 0: initialise module
	DW	R128FF		; 1: find first
	DW	R128FN		; 2: find next
	DW	R128OP		; 3: open file
	DW	R128RD		; 4: read file
	DW	R128SK		; 5: seek in file
	DW	R128CL		; 6: close file
	DW	R128NF		; 7: read media or file information

MNBADF:	POP	D		; restore input DE for caller
	POP	B		; restore input BC for caller
	MVI	A, 01h		; A = 1 (error: bad function)
	LXI	H, 0000h	; HL = 0
	STC			; CF = 1 (return with error)
	RET

; ---- INITIALIZE MODULE -----------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|r128lib|00h|discid |      |        |bufaddr|R128IN  |errcode|bufaddr |

R128IN:	RET

; ---- FIND FIRST ------------------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|r128lib|01h|       |      |maskaddr|       |R128FF  |errcode|entryptr|

R128FF:	RET

; ---- FIND NEXT -------------------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|r128lib|02h|       |      |        |       |R128FN  |errcode|entryptr|

R128FN:	RET

; ---- OPEN FILE -------------------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|r128lib|03h|       |      |nameaddr|       |R128OP  |errcode|        |

R128OP:	RET

; ---- READ FILE -------------------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|r128lib|04h|       |      |count   |bufaddr|R128RD  |errcode|bytesrd |

R128RD:	RET

; ---- SEEK IN FILE ----------------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|r128lib|05h|       |      |pos     |       |R128SK  |errcode|        |

R128SK:	RET

; ---- CLOSE FILE ------------------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|r128lib|06h|       |      |        |       |R128CL  |errcode|        |

R128CL:	RET

; ---- READ MEDIA OR FILE INFORMATION ----------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|r128lib|07h|       |      |        |       |R128NF  |errcode|infoptr |

R128NF:	RET

; **** DATA AREA ****
INPRB:	DB	0		; input data in B
INPRC:	DB	0		; input data in C
INPRDE:	DW	0		; input data in DE
INPRHL:	DW	0		; input data in HL
	END
