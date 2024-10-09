;add from memory until you cross 16 and flip the last bit before reaching 16
org 100h

summer:                 ;keep adding from memory until we cross 15
    mov [sum], al
    mov al, [arr+bx]
    add al, [sum]
    inc bx
    cmp al, 16
    jnae summer

mov ax, [sum]           ;put final sum before passing 15 into ax
mov cx, ax
mov bx, 0xFFFF          ;set bx to max, so it can go to 0 after next move
add bx, 1               ;set carry high, to generate a bx we can xor with

; Skill issue w/ BT
makeBX_AXbits: RCL bx, 1;left shifting bx 'ax' many times
loop makeBX_AXbits

xor ax, bx              ;xor ax (has to <= 15) with 'ax'-th bit

mov ax, 4c00h
int 21h

arr: db 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
sum: dw 0
