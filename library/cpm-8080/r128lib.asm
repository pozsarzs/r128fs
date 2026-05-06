; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | r128lib.asm                                                                |
; | Filesystem access routines, 8080, CP/M, v0.1                               |
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

; -------- CODE AREA --------

; (..)

R128:

; (..)

; --- DATA AREA -----------------------------
ADDR:	DB	0		; I/O address
	END

