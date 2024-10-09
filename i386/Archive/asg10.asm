; Print the multiplication of 2 512 bit numbers
; Fuck this, I know the the theory
org 100h

jmp start
num1: times 3 db 1  ;multiplicand
num2: times 3 db 1  ;multiplier
temp: times 6 db 0  ;2x space multiplicand
rslt: times 6 db 0  ;result

SHREXT:
    mov cx, [numBytes]


SHLEXT:

start:

mov ax4c00h
int 21h

numBytes: db 3
