; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
; | r128ex.asm                                                                 |
; | Example filesystem  - entry area                                           |
; +----------------------------------------------------------------------------+

ORG 0000h

; sector size:	128 B
; 
; HEADER (SECTOR #0/ENTRY #0 - 16 B)
	DB	'R1'		; magic word			( 2 B)
	DB	01h, 00h	; filesystem version		( 2 B)
	DB	'EX10'		; chip ID			( 4 B)
	DB	26h, 04h, 28h	; burning date in BCD		( 3 B)
	DW	2		; number of the entry sectors	( 2 B)
	DW	1		; 1st data sector		( 2 B)
	DB	0D7h		; header checksum		( 1 B)

; FILE ENTRY (SECTOR #0/ENTRY #1 - 16 B)
	DB	'HELLO   TXT'	; filename			(11 B)
	DW	1		; start sector			( 2 B)
	DW	66		; filesize in byte		( 2 B)
	DB	17h		; file entry checksum		( 1 B)

; FILE ENTRY (SECTOR #0/ENTRY #2 - 16 B)
	DB	'HELLO   PAS'	; filename			(11 B)
	DW	2		; start sector			( 2 B)
	DW	153		; filesize in byte		( 2 B)
	DB	53h		; file entry checksum		( 1 B)

; FILE ENTRY (SECTOR #0/ENTRY #3 - 16 B)
	DB	'CPMHELLOCOM'	; filename			(11 B)
	DW	4		; start sector			( 2 B)
	DW	8320		; filesize in byte		( 2 B)
	DB	0D7h		; file entry checksum		( 1 B)

; FILE ENTRY (SECTOR #0/ENTRY #4 - 16 B)
	DB	'HELLO   PAS'	; filename			(11 B)
	DW	70		; start sector			( 2 B)
	DW	11524		; filesize in byte		( 2 B)
	DB	2Fh		; file entry checksum		( 1 B)
