; count the number 1s and 0s in a number
org 100h

mov ax, [num1]          ;select number

numBitCount:
    shr ax, 1           ;right shift to push value to carry
    jc carryHigh
    inc byte [numZeros]
    jmp nextBit
    carryHigh: 
    inc byte [numOnes]
    nextBit:
    cmp ax, 0
    ja numBitCount     ;if ax is not zero, repeat

mov ax, 4c00h
int 21h

; num1: dw 43658
num1: dw 31913 
numZeros: db 0
numOnes: db 0
