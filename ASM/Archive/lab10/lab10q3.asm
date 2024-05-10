; add numbers
org 100h

mov ax, 6
add ax, 3
mov bx, [num2]
sub bx, [num4]
add ax, bx

mov ax, 4c00h
int 21h

num2: db 0xF
num4: db 0x8
