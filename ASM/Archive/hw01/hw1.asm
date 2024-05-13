;Program to take 2s complement of a 512 bit number

org 100h

mov cx, [numInputs]
mov bx, num

onesComplement: 
mov ax, [bx]
not ax
mov [bx], ax
add bx, 2
loop onesComplement

mov cx, [numInputs]
mov bx, num

mov ax, 0xFFFF
add ax, 1

twosComplement:
mov ax, [bx]
adc ax, 0
mov [bx], ax
inc bx
inc bx
loop twosComplement

;exit
mov ax, 4c00h
int 21h

num: dw 13, 20
numInputs: db 2
