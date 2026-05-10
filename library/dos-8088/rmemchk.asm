; +----------------------------------------------------------------------------+
; | R128 ROM filesystem                                                        |
; | rmemchk.asm                                                                |
; | Reading a logical sector from memory, 8088, DOS, MASM                      |
; +----------------------------------------------------------------------------+

.MODEL SMALL
.STACK 100h

EXTRN RMEM:FAR

; -------- CONSTANTS --------
PRINT   EQU 09h

.DATA

ROMIMG  DB 'RMEMLIB TEST OK',13,10,'$'
MSGINI  DB 'INIT ERROR$'
MSGRED  DB 'READ ERROR$'
BUFFER  DB 128 DUP(?)

.CODE

START:

    ; init DS
    MOV AX, @DATA
    MOV DS, AX

; initialize
    MOV AL, 00h              ; RMINIT
    LEA DX, ROMIMG
    LEA BX, BUFFER
    CALL RMEM
    JC INITER

; read sector 0
    MOV AL, 01h              ; RMSTRD
    MOV DX, 0000h
    CALL RMEM
    JC READER

; print buffer
    LEA DX, BUFFER
    MOV AH, PRINT
    INT 21h
    JMP EXIT

; handling error
INITER:
    LEA DX, MSGINI
    JMP PRNER

READER:
    LEA DX, MSGRED

PRNER:
    MOV AH, PRINT
    INT 21h

EXIT:
    MOV AX, 4C00h
    INT 21h

END START
