; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rdscchk.asm                                                                |
; | Reading a logical sector from disc, 8080, CP/M, v0.1                       |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

	ORG	100h
	EXTRN	RDSC

; -------- CONSTANTS --------
BDOS	EQU	05h		; BDOS entry point
RDINIT	EQU	00h		; Rdsclib initialize function
RDSTRD	EQU	01h		; Rdsclib sector read function

; -------- CODE AREA --------
START:
; initialization and open

; read record

; dump buffer to console

; handling error

	RET
; -------- DATA AREA --------
BUFFER:	DS	128, 0
	END
