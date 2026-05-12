; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rimglib.asm                                                                |
; | Reading a logical sector from disc image, 8080, CP/M-80, v0.1              |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

PUBLIC RIMG

; -------- CONSTANTS --------
BDOS	EQU	05h			; BDOS entry point
SETDMA	EQU	1Ah			; BDOS set DMA address function
OPEN	EQU	0Fh			; BDOS open file function
CLOSE	EQU	10h			; BDOS close file function
RDRND	EQU	21h			; BDOS read random function
RNUM	EQU	03h			; Number of routines

; -------- CODE AREA --------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|rimglib|00h|onlyfop|      |fcbaddr |bufaddr|RIINIT  |errcode|bufaddr |
;|rimglib|01h|       |      |sectnum |       |RISTRD  |errcode|bufaddr |
;|rimglib|02h|onlyfcl|      |        |       |RIDONE  |       |        |
;
; Error codes:
;   00h. no error		CF = 0
;   01h: bad function		CF = 1
;   04h: file open error	CF = 1
;   05h: file read error	CF = 1
;   06h: file close error	CF = 1
;
; Preserves: BC, DE
; Clobbers:  AF, HL

; ---- ENTRY POINT AND JUMP TABLE ----
RIMG:	PUSH	B		; save input BC for caller
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

MNJTAB:	DW	RIINIT		; 0: initialize module
	DW	RISTRD		; 1: read a logical sector and write to buffer

MNBADF:	POP	D		; restore input DE for caller
	POP	B		; restore input BC for caller
	MVI	A, 01h		; A = 1 (error: bad function)
	LXI	H, 0000h	; HL = 0
	STC			; CF = 1 (return with error)
	RET

; ---- INITIALIZE MODULE -----------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|rimglib|00h|onlyfop|      |fcbaddr |bufaddr|RIINIT  |errcode|bufaddr |

RIINIT: LDA	INPRB		; get input B data	
	ORA	A
	JNZ	INITOP		; if A = 1 then goto INITOP

	LHLD	INPRDE		; get input DE data	
	SHLD	FCBADD		; store FCB starting address
	XCHG
	LHLD	INPRHL		; get input HL data	
	SHLD	BUFADD		; store buffer starting address

	MVI	C, SETDMA	; set DMA address
	LHLD	BUFADD		; HL = DMA address
	XCHG			; DE = DMA address
	CALL	BDOS		; call BDOS

INITOP:	MVI	C, OPEN		; open file
	LHLD	FCBADD		; HL = FCB address
	XCHG			; DE = FCB address
	CALL	BDOS		; call BDOS
	INR	A		; check result (at error: FFh -> 00h)
	JZ	INITER		; at error go INITER
	XRA	A		; A = 0, CF = 0

INITDN: LHLD	BUFADD		; HL = buffer address
	POP	D		; restore input DE for caller
	POP	B		; restore input BC for caller
	RET

INITER:	MVI	A, 04h		; A = 4, error code
	STC			; CF = 1
	JMP	INITDN		; go INITDN

; ---- READ A LOGICAL SECTOR -------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|rimglib|01h|       |      |sectnum |       |RISTRD  |errcode|bufaddr |

RISTRD:	LHLD	FCBADD		; HL = FCB address
	XCHG			; DE = FCB address
	LHLD	INPRDE		; HL = sector number
	MOV	B, H		; BC = sector number
	MOV	C, L

	LXI	H, 33		; HL = offset
	DAD	D		; HL = FCB address + 33
	MOV	A, C		; A = low byte of sector number
	MOV	M, A		; store in FCB
	INX	H		; HL = FCB address + 34
	MOV	A, B		; A = high byte of sector number
	MOV	M, A		; store in FCB
	INX	H		; HL = FCB address + 35
	XRA	A		; A = 0
	MOV	M, A		; store in FCB

	MVI	C, RDRND	; read random
	LHLD	FCBADD		; HL = FCB address
	XCHG			; DE = FCB address
	CALL	BDOS		; call BDOS

	ORA	A		; set flags
	JNZ	STRDER	; file read error

	XRA	A		; A = 0, CF = 0

STRDDN:	LHLD	BUFADD		; HL = buffer address
	POP	D		; restore input DE for caller
	POP	B		; restore input BC for caller
	RET

STRDER:	MVI	A, 05h		; A = 5, error code
	STC			; CF = 1
	JMP	STRDDN

; ---- CLEANUP MODULE --------------------------------------------------

;|name   |A  |B      |C     |DE      |HL     |function|ret. A |ret. HL |
;|-------|:-:|:-----:|:----:|:------:|:-----:|--------|:-----:|:-------|
;|rimglib|02h|onlyfcl|      |        |       |RIDONE  |       |        |

RIDONE: LDA	INPRB		; get input B data	
	ORA	A
	JNZ	DONECL		; if A = 1 then goto DONECL

	MVI	C, SETDMA	; set DMA address
	LXI	D, 0080h	; DE = default DMA address
	CALL	BDOS		; call BDOS

DONECL:	MVI	C, CLOSE	; close file
	LHLD	FCBADD		; HL = FCB address
	XCHG			; DE = FCB address
	CALL	BDOS		; call BDOS
	INR	A		; check result (at error: FFh -> 00h)
	JZ	DONEER		; at error go DONEER
	XRA	A		; A = 0, CF = 0

DONEDN: LHLD	BUFADD		; HL = buffer address
	POP	D		; restore input DE for caller
	POP	B		; restore input BC for caller
	RET

DONEER:	MVI	A, 06h		; A = 6, error code
	STC			; CF = 1
	JMP	DONEDN		; go DONEDN

; -------- DATA AREA --------
INPRB:	DB	0		; input data in B
INPRDE:	DW	0		; input data in DE
INPRHL:	DW	0		; input data in HL
BUFADD:	DW	0		; buffer start address
FCBADD:	DW	0		; FCB start address
	END
