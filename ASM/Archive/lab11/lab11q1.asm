; add 3 numbers
org 100h

mov al, 3
add [sum], al
mov al, [num1]
add [sum], al
mov al, [num2]
add [sum], al

mov ax,4c00h
int 21h

num1: db 4
num2: db 3
sum: db 0
