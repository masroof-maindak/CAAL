;Print a rectangle with dimensions
;passed as arguments
org 100h
jmp start
printRect:
    push bp
    mov bp, sp
    pusha

    mov ax, 0xb800
    mov es, ax
    
    ;dimensions
    mov ax, [bp+4]
    mov cx, [bp+6]

    ;start from bottom right
    mov dx, 0x0730
    mov di, 3998

    outer:
        inner:
            mov [es:di], dx
            inc bx
            sub di, 2
            cmp bx, ax
            jne inner
        sub di, 160
        add di, bx
        add di, bx
        mov bx, 0
        loop outer

    popa
    pop bp
    ret

start:
    push 10
    push 5
    call printRect
    mov ax, 4c00h
    int 21h
