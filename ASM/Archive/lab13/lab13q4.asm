; random number generator: takes seed via ax, puts 
; b14 xor b15 at b0 and return the answer in ax
org 100h
jmp start

RNG:
    push bx
    push dx
    push ax

    xor bx, bx  ;bx = 0
    xor dx, dx  ;dx = 0

    shl ax, 1   ;carry = bit 15
    jnc bit15
    mov bx, 1   ;bx = 1 if carry is high

    bit15:
        shl ax, 1  ;carry = bit 14
        jnc bit14
        mov dx, 1

    bit14: xor bx, dx  ; bx = b14 xor b15

    pop ax     ;ax = original seed
    shr ax, 1  ;waste rightmost bit
    rcr bx, 1  ;carry = bx
    rcl ax, 1  ;ax bit 0 = b14 xor b15

    pop dx
    pop bx
    ret

start:
    mov ax, 0xC003
    call RNG
mov ax, 4c00h
int 21h
