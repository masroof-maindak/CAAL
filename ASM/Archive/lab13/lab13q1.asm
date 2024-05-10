; have two characters move from the row at the 
; center of the screen to the middle and back again
org 100h
mov ax, 0xb800
mov es, ax
jmp dancingChar
delay:
    mov cx, 64000
    badloop: loop badloop
    ret
dancingChar:
    pusha
    mov di, 1920 ;center
    mov dh, 0x07
    mov bp, 158  ;offset
    mov bx, 0
    movementIn:
        mov dl, 0x07
        mov [es:di+bp], dx
        mov [es:di+bx], dx
        call delay
        mov dl, 0x20
        mov [es:di+bp], dx
        mov [es:di+bx], dx
        sub bp, 2
        add bx, 2
        cmp bx, bp
        jb movementIn
    movementOut:
        mov dl, 0x07
        mov [es:di+bp], dx
        mov [es:di+bx], dx
        call delay
        mov dl, 0x20
        mov [es:di+bp], dx
        mov [es:di+bx], dx
        add bp, 2
        sub bx, 2
        cmp bx, 0
        ja movementOut
    jmp dancingChar
