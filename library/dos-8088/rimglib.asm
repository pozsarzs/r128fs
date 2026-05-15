; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rimglib.asm                                                                |
; | Reading a logical sector from image, 8088, DOS, v0.1                       |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

TITLE	RIMG - R128 image sector read library for DOS
NAME	RIMG

; -------- CONSTANTS --------
DOS	EQU	21h		; DOS functions
DSETDMA	EQU	1Ah		; DOS set DMA address function
DOPEN	EQU	0Fh		; DOS open file function
DCLOSE	EQU	10h		; DOS close file function
DRDRND	EQU	21h		; DOS read random function
RNUM	EQU	03h		; number of routines
SECT	EQU	0080h		; logical sector size

CSEG	SEGMENT PUBLIC 'CODE'
	ASSUME	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG

PUBLIC  RIMG

; -------- CODE AREA --------

;|name   |AL |BX     |CL     |DX     |function|ret. AL|ret. BX|
;|-------|:-:|:-----:|:-----:|:-----:|--------|:-----:|:-----:|
;|rimglib|00h|bufaddr|onlyfop|fcbaddr|RIINIT  |errcode|bufaddr|
;|rimglib|01h|       |       |sectnum|RISTRD  |errcode|bufaddr|
;|rimglib|02h|       |onlyfcl|       |RIDONE  |errcode|       |
;
; Error codes:
;   00h. no error		CF = 0
;   01h: bad function		CF = 1
;   04h: file open error	CF = 1
;   05h: file read error	CF = 1
;   06h: file close error	CF = 1
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

MNJTAB	DW	RIINIT		; 0: initialise module
	DW	RISTRD		; 1: read a logical sector and write to buffer
	DW	RIDONE		; 2: clean up and/or close image file

MNBADF:	POP     DI		; restore input DI for caller
	POP     SI		; restore input SI for caller
	POP     CX		; restore input CX for caller
	MOV     AL, 01h		; AL = 1 (error: bad function)
	XOR	BX, BX		; BX = 0
	STC			; CF = 1 (return with error)
	RET

; ---- INITIALIZE MODULE --------------------------------------

;|name   |AL |BX     |CL     |DX     |function|ret. AL|ret. BX|
;|-------|:-:|:-----:|:-----:|:-----:|--------|:-----:|:-----:|
;|rimglib|01h|       |       |sectnum|RISTRD  |errcode|bufaddr|

RIINIT: MOV	AL, INP_CL	; get input CL data	
	OR	AL, AL
	JNZ	INITOP		; if AL = 1 then goto INITOP

	MOV	DX, INP_DX	; get input DX data	
	MOV	FCBADD, DX	; store FCB starting address

	MOV	BX, INP_BX	; get input BX data	
	MOV	BUFADD, BX	; store buffer starting address

	MOV	AH, DSETDMA	; set DMA address
	MOV	DX, BX		; DX = DMA offset address
	INT	DOS		; call DOS

INITOP:
	MOV	AH, DOPEN	; open file
	MOV	DX, FCBADD	; DX = FCB offset address
	INT	DOS		; call BDOS
	INC	AL		; check result (at error: FFh -> 00h)
	JZ	INITER		; at error go INITER
	XOR	AL, AL		; A = 0, CF = 0
	CLC			; CF = 0

INITDN: MOV	BX, BUFADD	; BX = buffer address
	POP     DI		; restore input DI for caller
	POP     SI		; restore input SI for caller
	POP     CX		; restore input CX for caller
	RET

INITER:	MOV	AL, 04h		; A = 4, error code
	STC			; CF = 1
	JMP	SHORT INITDN	; go INITDN

; ---- READ A LOGICAL SECTOR ------------------------------------

;|name   |AL |BX     |CL     |DX      |function|ret. AL|ret. BX |
;|-------|:-:|:-----:|:-----:|:------:|--------|:-----:|:------:|
;|Rimglib|01h|       |       |sectnum |RMSTRD  |errcode|bufaddr |

RISTRD:	MOV	SI, FCBADD	; SI = FCB base address
	MOV	AX, INP_DX	; AX = sector number (from DX)
	
	MOV	[SI+33], AX	; low word of sector
	MOV	BYTE PTR [SI+35], 0 ; high byte

	MOV	AH, DRDRND	
	MOV	DX, SI		; DX = FCB address
	MOV	CX, 1		; Read 1 record
	INT	DOS		

	OR	AL, AL		
	JNZ	STRDER		

	XOR	AL, AL		
	CLC			
	JMP	SHORT STRDDN

STRDER:	MOV	AL, 05h		
	STC			

STRDDN:	MOV	BX, BUFADD	
	POP	DI		
	POP	SI		
	POP	CX		
	RET

; ---- CLEANUP MODULE -----------------------------------------

;|name   |AL |BX     |CL     |DX     |function|ret. AL|ret. BX|
;|-------|:-:|:-----:|:-----:|:-----:|--------|:-----:|:-----:|
;|rimglib|02h|       |onlyfcl|       |RIDONE  |errcode|       |

RIDONE: MOV	AL, INP_CL	; get input B data	
	OR	AL, AL
	JNZ	DONECL		; if AL = 1 then goto DONECL

	MOV	AH, DSETDMA	; set DMA address
	MOV	DX, 0080h	; DX = default DMA offset address
	INT	DOS		; call DOS

DONECL:	MOV	AH, DCLOSE	; close file
	MOV	DX, FCBADD	; DX = FCB offset address
	INT	DOS		; call BDOS
	INC	AL		; check result (at error: FFh -> 00h)
	JZ	DONEER		; at error go DONEER
	XOR	AL, AL		; AL = 0, CF = 0

DONEDN: MOV	BX, 0		; BX = 0
	POP	DI		; restore input DI for caller
	POP	SI		; restore input SI for caller
	POP	CX		; restore input CX for caller
	RET

DONEER:	MOV	AL, 06h		; AL = 6, error code
	STC			; CF = 1
	JMP	SHORT DONEDN	; go DONEDN

RIMG	ENDP

; -------- DATA AREA --------
INP_BX	DW	0		; input data in BX
INP_CL	DB	0		; input data in CL
INP_DX	DW	0		; input data in DX
BUFADD	DW	0		; buffer start address
FCBADD	DW	0		; FCB start address

CSEG	ENDS
	END
