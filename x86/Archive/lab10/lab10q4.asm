; find the square of 20
org 100h
mov cx, 20
here: add ax, 20
loop here
mov ax,4c00h
int 21h
