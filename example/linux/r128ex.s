# +----------------------------------------------------------------------------+
# | R128 ROM filesystem                                                        |
# | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
# | r128ex.s                                                                   |
# | Example filesystem  - entry area                                           |
# +----------------------------------------------------------------------------+

    .org 0x0000

    # HEADER (SECTOR #0/ENTRY #0 - 16 B)
    .byte 'R','1'		# magic word			( 2 B)
    .byte 0x01, 0x00		# filesystem version		( 2 B)
    .ascii "EX10"		# chip ID			( 4 B)
    .byte 0x26, 0x04, 0x28	# burning date in BCD		( 3 B)
    .word 2			# number of the entry sectors	( 2 B)
    .word 1			# 1st data sector		( 2 B)
    .byte 0xD7			# header checksum		( 1 B)

    # FILE ENTRY (SECTOR #0/ENTRY #1 - 16 B)
    .ascii "HELLO   TXT"	# filename			(11 B)
    .word 1			# start sector			( 2 B)
    .word 1			# filesize in sector count	( 2 B)
    .byte 0xD6			# file entry checksum		( 1 B)

    # FILE ENTRY (SECTOR #0/ENTRY #2 - 16 B)
    .ascii "HELLO   PAS"	# filename			(11 B)
    .word 2			# start sector			( 2 B)
    .word 2			# filesize in sector count	( 2 B)
    .byte 0xBC			# file entry checksum		( 1 B)

    # FILE ENTRY (SECTOR #0/ENTRY #3 - 16 B)
    .ascii "CPMHELLOCOM"	# filename			(11 B)
    .word 4			# start sector			( 2 B)
    .word 65			# filesize in sector count	( 2 B)
    .byte 0x78			# file entry checksum		( 1 B)

    # FILE ENTRY (SECTOR #0/ENTRY #4 - 16 B)
    .ascii "DOSHELLOCOM"	# filename			(11 B)
    .word 70			# start sector			( 2 B)
    .word 91			# filesize in sector count	( 2 B)
    .byte 0xDA			# file entry checksum		( 1 B)
