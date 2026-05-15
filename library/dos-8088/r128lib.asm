; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | r128lib.asm                                                                |
; | Filesystem handler routines, 8088, DOS, v0.1                               |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

TITLE	R128 - R128 filesystem handler library for DOS
NAME	R128

; -------- CONSTANTS --------
DOS	EQU	21h		; DOS functions
RNUM	EQU	08h		; number of routines

CSEG	SEGMENT PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG

PUBLIC  R128
EXTRN	RDSC
EXTRN	REMX
EXTRN	RIMG
EXTRN	RMEM

; -------- CODE AREA --------

;|name   |AL |BX     |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:-----:|:------:|--------|:-----:|:------:|
;|r128lib|00h|bufaddr|discid |        |R128IN  |errcode|bufaddr |
;|r128lib|01h|       |       |maskaddr|R128FF  |errcode|entryptr|
;|r128lib|02h|       |       |        |R128FN  |errcode|entryptr|
;|r128lib|03h|       |       |nameaddr|R128OP  |errcode|        |
;|r128lib|04h|bufaddr|       |count   |R128RD  |errcode|bytesrd |
;|r128lib|05h|       |       |pos     |R128SK  |errcode|        |
;|r128lib|06h|       |       |        |R128CL  |errcode|        |
;|r128lib|07h|       |       |        |R128NF  |errcode|infoptr |
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
; Preserves: CX, SI, DI

; ---- ENTRY POINT AND JUMP TABLE ----
RIMG	PROC	NEAR
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

MNJTAB	DW	R128IN		; 0: initialise module
	DW	R128FF		; 1: find first
	DW	R128FN		; 2: find next
	DW	R128OP		; 3: open file
	DW	R128RD		; 4: read file
	DW	R128SK		; 5: seek in file
	DW	R128CL		; 6: close file
	DW	R128NF		; 7: read media or file information

MNBADF:	POP     DI		; restore input DI for caller
	POP     SI		; restore input SI for caller
	POP     CX		; restore input CX for caller
	MOV     AL, 01h		; AL = 1 (error: bad function)
	XOR	BX, BX		; BX = 0
	STC			; CF = 1 (return with error)
	RET

; ---- INITIALIZE MODULE -----------------------------------------------

;|name   |AL |BX     |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:-----:|:------:|--------|:-----:|:------:|
;|r128lib|00h|bufaddr|discid |        |R128IN  |errcode|bufaddr |

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

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

R128	ENDP

; -------- DATA AREA --------
INP_BX	DW	0		; input data in BX
INP_CL	DB	0		; input data in CL
INP_DX	DW	0		; input data in DX

CSEG	ENDS
	END
