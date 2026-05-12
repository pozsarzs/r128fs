; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rimgchk.asm                                                                |
; | Reading a logical sector from image, 8080, CP/M-80, v0.1                   |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

	ORG	100h
	EXTRN	RIMG

; -------- CONSTANTS --------
BDOS	EQU	0005h		; BDOS entry point
RESET	EQU	00h		; BDOS system reset function
CONOUT	EQU	02h		; BDOS console output function
RIINIT	EQU	00h		; Rimglib initialize function
RISTRD	EQU	01h		; Rimglib sector read function
RIDONE	EQU	02h		; Rimglib done function

; -------- CODE AREA --------
START:
; initialization and open
	MVI	A, RIINIT
	MVI	B, 0
	LXI	D, FCB
	LXI	H, BUFFER
	CALL	RIMG
	JC	ERROR

; read record
	MVI	A, RISTRD
	LHLD	RECNUM
	XCHG
	CALL	RIMG
	JC	ERROR

; dump buffer to console
	LXI	H, BUFFER
	MVI	B, 128
PRLOOP:	MOV	E, M
	MVI	C, CONOUT
	PUSH	B
	PUSH	D
	PUSH	H
	CALL	BDOS
	POP	H
	POP	D
	POP	B
	INX	H
	DCR	B
	JNZ	PRLOOP

; close and cleanup
DONE:	MVI	A, RIDONE
	MVI	B, 0
	CALL	RIMG
	LD	C, RESET	; exit to BDOS
	CALL	BDOS

; handling error
ERROR:	LXI	H, ERRMSG
	MVI	C, 09h
	XCHG
	CALL	BDOS
	LD	C, RESET	; exit to BDOS
	CALL	BDOS

; -------- DATA AREA --------
RECNUM:	DW	0001h		; logical 128-byte record number
ERRMSG:	DB	'Read error!$'
FCB:	DB	0		; drive
	DB	'R128EXRMIMG'	; 8.3 filename
	DS	25, 0
BUFFER:	DS	128, 0
	END	START
