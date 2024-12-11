; print a hexadecimal number to the screen
; the number of bytes in the number is in cx
org 100h

mov ax, 0xb800          ;point es to video memory
mov es, ax

mov cx, 8               ;cx = number of bytes
mov di, 0

jmp printNum
number: db 1Fh,2Eh,3Dh,4Ch,5Bh,6Ah,79h,88h

printNum:
    ;MSN
    mov dl, [number+bx]
    shr dl, 4           ;'waste' lower 4 bits ['and dl, 0xF0' should also work]
    call prepAscii
    mov [es:di], dx

    ;LSN
    mov dl, [number+bx]
    and dl, 0x0F        ;waste higher 4 bits
    call prepAscii
    mov [es:di+2], dx

    ;next char
    add di, 4
    inc bx
    loop printNum

    ;exit when complete
    jmp exit

    prepAscii:
        cmp dl, 0xA
        jb isNum        ;add 0x30 (1 = ascii 31) if dl has a number
        add dl, 0x37    ;add 0x37 (A = ascii 65) if dl has a char
        jmp asciiReady
        isNum: add dl, 0x30
        asciiReady: mov dh, 07h ;0b-0B-0G-0R|0I-1B-1G-1R
        ret

exit:
    mov ax, 4c00h
    int 21h
