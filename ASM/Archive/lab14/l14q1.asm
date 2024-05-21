; Program that displays a news ticker on the bottom row
org 100h
jmp start

tickerString: db 'Mujtaba'
stringSize: dw 7

Delay:
    push cx
    mov cx, 65535
    a: loop a
    mov cx, 65535
    b: loop b
    mov cx, 65535
    c: loop c
    pop cx
    ret

newsTicker:
    push bp
    mov bp, sp
    pusha

    mov ax, 0xb800
    mov es, ax

    ;first, place the string there normally
    cld
    mov ah, 0x07
    mov cx, [bp+6] ; cx = size
    mov si, [bp+4] ; si = string
    mov di, 3840
    prntr0:
        lodsb
        stosw
        loop prntr0

    ;movement preparation
    mov ax, 0xb800
    mov ds, ax
    mov bx, 3840
    mov ah, 0x07
    std

    mover:
        ;si = end of word
        ;di = end of word + 1
        mov si, bx
        mov cx, [bp+6]

        add si, cx
        add si, cx
        inc cx

        mov di, si
        add di, 2
        
        ;move string
        rep movsw

        ;clear the first index
        sub di, 2
        mov al, 0x20
        stosw
        
        ;next index
        call Delay
        add bx, 2
        cmp bx, 4000
        jne mover
    
    ; Clear the one character left
    mov di, 3998
    stosw

    popa
    pop bp
    ret 4

start:
    push word [stringSize]
    mov ax, tickerString
    push ax
    
    call newsTicker

    mov ax, 4c00h
    int 21h
