;Program to toggle a stopwatch by pressing left shift
org 100h

jmp start 

;timekeeping
ticks: dd 0
seconds: dw 0 
minutes: dw 0 
hours: dw 0 

;flags
timerFlag: dw 0 
terminateFlag: dw 0 

;store original ISRs
oldkb: dd 0
oldtt: dd 0
 
printnum:     
    push bp 
    mov bp, sp 
    push es 
    push ax 
    push bx 
    push cx 
    push dx 
    push di 
    mov ax, 0xb800 
    mov es, ax             ; point es to video base 

    mov ax, [bp+4]         ; load number in ax 
    mov bx, 10             ; use base 10 for division 
    mov cx, 0              ; initialize count of digits 
    nextdigit:
        mov dx, 0              ; zero upper half of dividend 
        div bx                 ; divide by 10 
        add dl, 0x30           ; digit -> ascii
        push dx                ; save ascii value on stack 
        inc cx                 ; increment count of values 

        cmp ax, 0              ; is the quotient zero 
        jnz nextdigit          ; if no divide it again 
         
        mov di, 140            ; point di to 70th column + offset
        add di, [bp+6]
    nextpos:
        pop dx                 ; remove a digit from the stack 
        mov dh, 0x07           ; blk BG/wht FG
        mov [es:di], dx        ; print char on screen 
        add di, 2              ; move to next screen location 
        loop nextpos

        pop di 
        pop dx 
        pop cx 
        pop bx 
        pop ax 
        pop es
        pop bp
        ret 4
 
;keyboard ISR - called every time a key is pressed
KB_ISR:
    push ax 
    in al, 0x60
    
    ;if not lctrl, check if escape, else toggle timer
    cmp al, 29
    jne isEscape
    xor word [timerFlag], 1

    ;if not escape, pass to original ISR, else exit
    isEscape:
    cmp al, 0x01
    jne exitKeyboardISR
    mov word [terminateFlag], 1
    mov al, 0x20
    out 0x20, al
    pop ax
    iret

    exitKeyboardISR:
        pop ax 
        jmp far [cs:oldkb]

;tick timerISR - called 18.2 times every second
TT_ISR:
    push ax 
    cmp word [timerFlag], 1
    jne exitTimerISR
        
    ;time b/w 2 ticks = 0.0549254s = 54.92ms = 54.92 _s
    ; 1 second = 1000ms = 100,000 _s where _s is ms*10^2
    ;so now, all we need to do is check if 'ticks' has surpassed
    ;100,000, and if it has, reset it
    
    quotientNotMil:
        ;increment ticks
        add dword [ticks], 5492
        cmp dword [ticks], 100000
        jnae noMoreInc
        inc word [seconds]
        sub dword [ticks], 100000

        ;inc minute if 60 seconds
        cmp word [seconds], 60
        jne noMoreInc
        inc word [minutes]
        mov word [seconds], 0

        ;TODO: clear the right-most '9' left from 59
        ;or somehow figure out a way to pass the number
        ;of digits to the printnum subroutine

        ;inc hour if 60 minutes
        cmp word [minutes], 60
        jne noMoreInc
        inc word [hours]
        mov word [minutes], 0
    
    noMoreInc:
        push word 0xe
        push word [seconds]
        call printnum

        push word 0x8
        push word [minutes]
        call printnum

        push word 0x0
        push word [hours]
        call printnum
 
    exitTimerISR:
        mov al, 0x20 
        out 0x20, al
        pop ax 
        iret

start:
    ;es = 0
    xor ax, ax 
    mov es, ax

    ;store old ISR
    mov eax, [es:8*4]
    mov dword [oldtt], eax
    mov eax, [es:9*4]
    mov dword [oldkb], eax

    ;override w/ custom hook(s)
    cli
    mov word [es:8*4+2], cs
    mov word [es:9*4+2], cs
    mov word [es:8*4], TT_ISR
    mov word [es:9*4], KB_ISR
    sti
    
    shouldTerm:
        cmp word [terminateFlag], 1
        jne shouldTerm

        ;Recover original subroutines
        cli
        mov eax, [cs:oldkb]
        mov dword [es:9*4], eax
        mov eax, [cs:oldtt]
        mov dword [es:8*4], eax
        sti

        ;Terminate gracefully
        mov ax, 4c00h
        int 21h
