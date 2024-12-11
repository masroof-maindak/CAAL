; Reverse an array
org 100h

mov si, arr     ;ptrs for left/right
mov di, arr
add di, [siz]
dec di

swapper:
    mov ah, [si] ;ah = left ptr
    mov al, [di] ;al = right ptr
    mov [si], al
    mov [di], ah
    inc si
    dec di
    cmp si, di
    jna swapper

mov ax, 4c00h
int 21h

arr: db 1, 3, 5, 7, 9, 11, 12, 13, 14, 15
siz: dw 10
