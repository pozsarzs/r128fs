; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rmemlib.asm                                                                |
; | Routine collection, 8080, CP/M-80, v0.1                                    |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

PUBLIC RMEM

; -------- CONSTANTS --------
RNUM	EQU	02h			; Number of routines
SECT	EQU	0080h			; Logical sector size

; -------- CODE AREA ---------------
; Input:     A = function code
;            BC, DE, HL = input data
; Output:    CF = 0, A = output data
;            CF = 1, A = error code
;
; Error codes:
;   01h: bad function
;   02h: shift overflow
;   03h: address overflow
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

MNJTAB:	DW	RMINIT		; 0: set buffer address and sector size
	DW	RMSTRD		; 1: read a logical sector and write to buffer

MNBADF:	POP	HL		; restore input HL
	POP	DE		; restore input DE for caller
	POP	BC		; restore input BC for caller
	MVI	A, 01h		; A = 1
	STC			; CF = 1
	RET

; ---- INITIALIZE LIBRARY --------------------
; Input:  HL = buffer start address (0000-FFFFh)
; Output: CF = 0
RMINIT:	SHLD	BUADDR		; store buffer starting address
INITDN: XRA	A		; A = 0, CF = 0
	POP	HL		; restore input HL
	POP	DE		; restore input DE for caller
	POP	BC		; restore input BC for caller
	RET

; ---- READ A LOGICAL SECTOR ----------------------------------
; Input:  DE = the number of the sector to be read (0000-FFFFh)
;         HL = ROM start address (0000-FFFFh)
; Output: CF = 0, A = 0
;         CF = 1, A = error code
RMSTRD:	POP	HL		; restore input HL for this routine
	POP	DE		; restore input DE for this routine
	PUSH	DE		; save input DE for caller
	MVI	B, 7		; B = counter value

STRDSH:	MOV	A, E		; shift DE via A
	ADD	A
	MOV	E, A
	MOV	A, D
	RAL
	MOV	D, A

	JC	STRDE1		; if CF = 1 then goto STRDE1
	DEC	B		; decrement counter
	JNZ	STRDSH		; if B > 0 then goto STRDSH
	DAD	D		; sector address in HL (= HL + DE)
	JC	STRDE2		; if CF = 1 then goto STRDE2

	LXI	B, SECT		; BC = byte counter (128 bytes)
	LHLD	BUADDR		; HL = buffer start address (destination)
	XCHG			; HL <-> DE
STRDLP: MOV	A, M		; A = (HL) read byte from source
	STAX	D		; (DE) = A write byte to destination
	INX	H		; HL++
	INX	D		; DE++
	DCX	B		; BC--
	MOV	A, B		; check if BC == 0
	ORA	C
	JNZ	STRDLP		; loop until BC = 0
	XRA	A		; A = 0, CF = 0
	JMP	STRDDN		; goto STRDDN

STRDE1:	MVI	A, 02h		; A = 2
	STC			; CF = 1
	JMP	STRDDN		; goto STRDDN

STRDE2:	MVI	A, 03h		; A = 3
	STC			; CF = 1
	
STRDDN:	POP	DE		; restore input DE for caller
	POP	BC		; restore input BC for caller
	RET

; -------- DATA AREA --------
BUADDR:	DW	0		; buffer start address
	END
