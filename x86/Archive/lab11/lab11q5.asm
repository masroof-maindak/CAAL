; bubble sort
org 100h

outer:
    mov bx, 0          ;reset swap bit & bx
    mov [swap], bx

inner:
    mov al, [arr+bx]
    cmp al, [arr+bx+1] ;cmp i and i+1
    jbe inorder        ;udest <= usrc (i.e in order)

    mov ah, [arr+bx+1] ;swap i and i+1
    mov [arr+bx+1], al
    mov [arr+bx], ah
    mov ax, 1
    mov [swap], ax     ;indicate swap has been made

inorder:               ;values are now in order
    add bx, 1          ;inc pointer of array
    cmp bl, [size]
    jne inner          ;loop again if not at end

    mov ax, [swap]
    cmp ax, 1
    je outer           ;loop outer if swap happened

mov ax, 4c00h
int 21h

arr: db 4, 14, 125, 22, 81, 23, 12, 8, 10, 1
; arr: db 125, 14, 4
size: db 9
swap: db 0
