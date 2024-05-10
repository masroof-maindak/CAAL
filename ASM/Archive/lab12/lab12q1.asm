;add the numbers at indexes which are multiples of 3
org 100h

mov ax, 0
mov bx, 0
mov cx, 7

summer:
    mov al, [arr+bx]
    add byte [sum], al
    add bx, 3
    loop summer

mov ax, 4c00h
int 21h

arr: db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19
sum: db 0
