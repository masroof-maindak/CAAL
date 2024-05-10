; add numbers
org 100h

mov ax, 6
add ax, 3
mov bx, [num2]
sub bx, [num4]
add ax, bx

;exit
mov ax, 4c00h
int 21h

;variables
num2: dw 0xF
num4: dw 0x8
