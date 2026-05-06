; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | rcopy.asm                                                                  |
; | rcopy utility, 8088, DOS, v0.1                                             |
; +----------------------------------------------------------------------------+
; This is a free software: you can redistribute it and/or modify it under the
; terms of the MIT License.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
; FOR A PARTICULAR PURPOSE.

	ORG	100h
EXTRN	R128
EXTRN	RDSC
EXTRN	RIMG
EXTRN	RMEM

; -------- CODE AREA --------
SECTION .TEXT
START:

; (..)

; -------- DATA AREA --------
SECTION .DATA

MSG01:	DB   	'', 0Dh, 0Ah, '$'
	END

