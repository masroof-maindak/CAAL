; Program that highlights all instances of a 
; search string on screen and exits after 10s
; (non-functional - can't find bug either, but probably pretty minor)
org 100h
jmp start

searchString: db 'files', 0
highlightDone: dw 0
terminateFlag: dw 0
seconds: dw 0
ticks: dw 0
oldtt: dd 0

highlight:
    push bp
    mov bp, sp
    pusha

    mov cx, [bp+6]  ;string size
    jz exitHighlight

    mov ax, 0xb800
    mov es, ax
    mov ds, ax

    mov si, [bp+4]  ;si = di = string location (in video memory)
    mov di, si

    cld
    mov ah, 0x47
    highlightLoop:
        lodsb   ;load byte
        inc si  ;increment si
        stosw   ;store word
        loop highlightLoop

    exitHighlight:
        popa
        pop bp
        ret 4

; subroutine to calculate the length of a null-terminated string
; takes the segment and offset of a string as parameters
strlen:
    push bp
    mov bp, sp
    push es
    push cx
    push di

    CLD             ; direction = 0, i.e di is incremented
    les di, [bp+4]  ;point es:di to string
    mov cx, 0xffff  ;cx = max
    xor al, al      ;al = 0

    ; repeat the following while not equal, or cx != 0 :
        ; 1. inc/dec di depending on D
        ; 2. decrement cx
    ; while WHAT is not equal?: the `SCA`nned `S`tring's `B`yte and the value in al
    repne scasb     
    
    mov ax, 0xffff
    sub ax, cx      ;ax = FFFF-[FFFF-size]
    dec ax          ;ax = size-1 (since size includes 0)
    
    pop di
    pop cx
    pop es
    pop bp
    ret 4

searcher:
    push bp
    mov bp, sp
    sub sp, 2
    pusha

    mov ax, 0xb800
    mov es, ax

    ; Store string size in local variable
    push ds
    push word [bp+4]
    call strlen
    mov [bp-2], ax

    ;Loop through entire screen
    mov bx, 0
    searchLoop:
        mov si, [bp+4]  ;si = start of letter
        mov di, bx      ;di = current pixel's ascii
        
        mov cx, [bp-2]
        comp:
            mov al, [ds:si]
            cmp byte al, [es:di]
            jne continue
            inc si
            add di, 2
            loop comp

        push word [bp-2]    ;length
        push bx             ;starting index
        call highlight
        
        continue:
            add bx, 2
            cmp bx, 4000
            jne searchLoop

    mov word [highlightDone], 1
    add sp, 2
    popa
    pop bp
    ret 2

TT_ISR:
    push ax 
    cmp word [highlightDone], 1
    jne exitTimerISR
    
    incTicks:
        add dword [ticks], 5492
        cmp dword [ticks], 100000
        jnae exitTimerISR
        inc word [seconds]
        sub dword [ticks], 100000

        cmp word [seconds], 5
        jne exitTimerISR
        mov word [terminateFlag], 1
 
    exitTimerISR:
        mov al, 0x20 
        out 0x20, al
        pop ax 
        iret

start:
    ; xor ax, ax
    ; mov es, ax
    ; mov eax, [es:8*4]
    ; mov dword [oldtt], eax
    ;
    ; cli
    ; mov word [es:8*4+2], cs
    ; mov word [es:8*4], TT_ISR
    ; sti

    ;place string there for easy testing
    mov ax, 0xb800
    mov es, ax
    cld
    mov ah, 0x07
    mov cx, 5
    mov si, searchString
    mov di, 0
    prntr0:
        lodsb
        stosw
        loop prntr0

    mov ax, searchString
    push ax
    call searcher

    shouldTerm:
        cmp word [terminateFlag], 1
        jne shouldTerm

        ; cli
        ; mov eax, [cs:oldtt]
        ; mov dword [es:8*4], eax
        ; sti
        ;
        ; mov ax, 4c00h
        ; int 21h
