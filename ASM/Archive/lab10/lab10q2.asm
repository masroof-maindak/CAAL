; add numbers
org 100h

mov ax, [nums]
mov bx, [nums+2]
add ax, bx
mov bx, [nums+4]
add ax, bx

mov ax, 4c00h
int 21h

nums: dw 1, 3, 6
