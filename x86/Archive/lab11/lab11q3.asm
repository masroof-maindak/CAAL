; get the min/max from an array
org 100h

mov cx, 10
mov bx, arr
checkMinMax:
    mov al, [min]
    cmp al, [bx]
    jb prevMinRetained ;if udest (min) < usrc (val)
        mov al, [bx]
        mov [min], al
        prevMinRetained:

    mov al, [max]
    cmp al, [bx]
    ja prevMaxRetained ;if udest (max) > usrc (val)
        mov al, [bx]
        mov [max], al
        prevMaxRetained:

    inc bx
loop checkMinMax

mov ax, 4c00h
int 21h

arr: db 4, 14, 125, 22, 81, 23, 12, 8, 10, 1
min: db 0xFF
max: db 0x00
