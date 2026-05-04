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
BDOS	EQU	05h			; BDOS system call
RNUM	EQU	02h			; Number of routines

; -------- CODE AREA --------
; Input:     A = function code
;            BC, DE, HL = input data
; Output:    CF = 0, A = output data
;            CF = 1, A = error code
;
; Error codes:
;   01h: bad function
;   02h: file open error
;   03h: file read error
;
; Preserves: BC, DE
; Clobbers:  AF, HL

; ---- ENTRY POINT AND JUMP TABLE ----
RMEM:	PUSH	BC		; save input BC for caller and selected routine
	PUSH	DE		; save input DE for caller and selected routine
	PUSH	HL		; save input HL for selected routine

	CPI	RNUM		; compare A (function code) with max valid index
	JNC	MNBADF		; if A >= RNUM: invalid function, jump to MNBADF

	LXI	D, MNJTAB	; DE = address of jump table entry

	ADD	A		; A = A * 2 (word index into jump table)
	MOV	L, A
	MOV	H, 0		; HL = zero-extended offset
	DAD	D		; HL = address of table + offset

	MOV	E, M		; load low byte of handler address (HL = address)
	INX	H		; increment HL
	MOV	D, M		; load high byte (HL = address)
	XCHG			; DE <-> HL, HL = handler address
	PCHL			; indirect jump to selected routine

MNJTAB:	DW	RIINIT		; 0: set buffer address and sector size
	DW	RISTRD		; 1: read a logical sector and write to buffer

MNBADF:	POP	HL		; restore input HL
	POP	DE		; restore input DE for caller
	POP	BC		; restore input BC for caller
	MVI	A, 01h		; A = 1
	STC			; CF = 1
	RET

; ---- INITIALIZE LIBRARY --------------------
; Input:  HL = buffer start address (0000-FFFFh)
; Output: CF = 0
RIINIT:	SHLD	BUADDR		; store buffer starting address
INITDN: XRA	A		; A = 0, CF = 0
	POP	HL		; restore input HL
	POP	DE		; restore input DE for caller
	POP	BC		; restore input BC for caller
	RET

; ---- READ A LOGICAL SECTOR ----------------------------------
; Input:  DE = sector number (0000-FFFFh)
;         HL = FCB start address (0000-FFFFh)
; Output: CF = 0, A = 0
;         CF = 1, A = error code
RISTRD:	MVI	C, 1Ah		; set DMA address
	LHLD	BUADDR		; HL = DMA address
	XCHG			; DE =  DMA address
	CALL	BDOS		; call BDOS

	POP	HL		; restore input HL for this routine
	POP	DE		; restore input DE for this routine
	PUSH	DE		; save input DE for caller
	XCHG			; DE = FCB address, HL = sector number
	MOV	B, H		; BC = sector number
	MOV	C, L

	MOV	H, D		; H = D
	MOV	L, E		; L = E
	SHLD	RIFCB		; store FCB address

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

	MVI	C, 0Fh		; open file
	LHLD	RIFCB		; HL = FCB address
	XCHG			; DE = FCB address
	CALL	BDOS		; call BDOS

	ORA	A		; set flags
	JNZ	STRDE1		; file open error

	MVI	C, 21h		; read random
	LHLD	RIFCB		; HL = FCB address
	XCHG			; DE = FCB address
	CALL	BDOS		; call BDOS

	ORA	A		; set flags
	JNZ	STRDE2		; file read error

	CALL	STRDCF		; close file
	CALL	STRDDM		; set default DMA address

	XRA	A
	JMP	STRDDN
	
STRDE1:	CALL	STRDDM		; set default DMA address
	MVI	A, 02h		; file open error
	STC
	JMP	STRDDN

STRDE2:	CALL	STRDCF		; close file
	CALL	STRDDM		; set default DMA address
	MVI	A, 03h		; file read error
	STC

STRDDN:	POP	DE		; restore input DE for caller
	POP	BC		; restore input BC for caller
	RET

; ---- CLOSE FILE ---------------------------------------------
STRDCF:	MVI	C, 10h		; close file
	LHLD	RIFCB		; HL = FCB address
	XCHG			; DE = FCB address
	CALL	BDOS		; call BDOS
	RET

; ---- SET DEFAULT DMA ADDRESS --------------------------------
STRDDM: MVI	C, 1Ah		; set DMA address
	LXI	D, 0080h	; DE = default DMA address
	CALL	BDOS		; call BDOS
	RET

; -------- DATA AREA --------
BUADDR:	DW	0		; buffer start address
RIFCB:	DW	0
	END
