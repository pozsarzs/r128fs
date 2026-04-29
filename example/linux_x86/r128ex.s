# +----------------------------------------------------------------------------+
# | R128 ROM filesystem                                                        |
# | Copyright (C) 2026 Pozsar Zsolt <pozsarzs@gmail.com>                       |
# | r128ex.s                                                                   |
# | Example filesystem  - entry area                                           |
# +----------------------------------------------------------------------------+

    .org 0x0000

    # HEADER (SECTOR #0/ENTRY #0 - 16 B)
    .byte 'R','1'
    .byte 0x01, 0x00
    .ascii "EX10"
    .byte 0x26, 0x04, 0x28
    .word 2
    .word 1
    .byte 0xD7

    # FILE ENTRY (SECTOR #0/ENTRY #1 - 16 B)
    .ascii "HELLO   TXT"
    .word 1
    .word 66
    .byte 0x17

    # FILE ENTRY (SECTOR #0/ENTRY #2 - 16 B)
    .ascii "HELLO   PAS"
    .word 2
    .word 153
    .byte 0x53

    # FILE ENTRY (SECTOR #0/ENTRY #3 - 16 B)
    .ascii "CPMHELLOCOM"
    .word 4
    .word 8320
    .byte 0xD7

    # FILE ENTRY (SECTOR #0/ENTRY #4 - 16 B)
    .ascii "HELLO   PAS"
    .word 70
    .word 11524
    .byte 0x2F
