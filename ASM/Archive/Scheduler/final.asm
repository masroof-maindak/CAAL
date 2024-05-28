; Scheduler
org 100h
jmp start

oldtt: dd 0
old21: dd 0
PCB: times 16*16 dw 0     ; process control block - for 32 bytes/thread
stacks: times 256*16 dw 0 ; 512 bytes per stack per program
currProc: dw 0
threadCount: dw 1

;structure of one chunk in the PCB:
; 02 bytes - prev/next pointers
; 01 byte  - isAlive
; 01 byte  - priority
; 28 bytes - general purpose registers

LL_IND: EQU 0
PR_IND: EQU 2
AX_IND: EQU 4
BX_IND: EQU 6
CX_IND: EQU 8
DX_IND: EQU 10
SI_IND: EQU 12
DI_IND: EQU 14
BP_IND: EQU 16
SP_IND: EQU 18
CS_IND: EQU 20
DS_IND: EQU 22
ES_IND: EQU 24
SS_IND: EQU 26
FLAG_IND: EQU 28
IP_IND: EQU 30

; receieves argument in ax
; returns in ax the next PCB's number
getNext:
    mov bx, ax
    shl bx, 5
    mov ax, [PCB+LL_IND+bx]
    and ax, 0x00FF  ;to discord 'prev' pointer
    ret

;receives pcb # to init in ax
initPCB:
    push bp
    mov bp, sp

    ; bx to access PCBs
    mov bx, ax
    shl bx, 5

    ; si to access stacks
    mov si, ax
    shl si, 9
    add si, 510 ;move to bottom

    ; Init general purpose registers to 0
    xor ax, ax
    mov [PCB+AX_IND+bx], ax
    mov [PCB+BX_IND+bx], ax
    ; others
    ; todo: ensure 'I' in flag reg is 1
    mov [PCB+ES_IND+bx], ax

    ; get IP and CS from stack
    mov ax, [bp+4]
    mov [PCB+IP_IND+bx], ax
    mov ax, [bp+6]
    mov [PCB+CS_IND+bx], cs
    mov 
    
    ;'push' this thread's original argument to new stack
    mov ax, [bp+10]
    mov [stacks+si], ax
    sub si, 2
    
    ;'push' offset
    mov ax, [bp+8]
    mov [stacks+si], ax
    sub si, 2

    ;'push' segment (cs)
    mov [stacks+si], cs
    sub si, 2

    ;'push' ret trap
    mov [stacks+si], retTrap

    mov [PCB+SP_IND+bx], si
    pop bp
    ret 8

int08isr:
    push bx
    mov bx, [currProc]
    shl bx, 5

    ;STORE
    ;general purpose registers
    mov [PCB+AX_IND+bx], ax
    pop ax
    mov [PCB+BX_IND+bx], ax
    mov [PCB+CX_IND+bx], cx
    mov [PCB+DX_IND+bx], dx
    mov [PCB+SI_IND+bx], si
    mov [PCB+DI_IND+bx], di
    mov [PCB+BP_IND+bx], bp
    mov [PCB+DS_IND+bx], ds
    mov [PCB+ES_IND+bx], es

    ;iret relevant registers
    pop ax
    mov [PCB+IP_IND+bx], ax
    pop ax
    mov [PCB+CS_IND+bx], ax
    pop ax
    mov [PCB+FLAG_IND+bx], ax

    ;stack relevant registers
    mov [PCB+SS_IND+bx], ss
    mov [PCB+SP_IND+bx], sp

    mov ax, [currProc]
    call getNext       ;ax = next
    mov [currProc], ax
    mov bx, ax
    shl bx, 5
    
    ;RESTORE
    ;stack registers
    cli
    mov ax, [PCB+SS_IND+bx]
    mov ss, ax
    mov ax, [PCB+SP_IND+bx]
    mov sp, ax
    sti

    ;iret relevant registers
    mov ax, [PCB+FLAG_IND+bx]
    push ax
    mov ax, [PCB+CS_IND+bx]
    push ax
    mov ax, [PCB+IP_IND+bx]
    push ax

    ;general purpose registers
    mov cx, [PCB+CX_IND+bx]
    mov dx, [PCB+DX_IND+bx]
    mov si, [PCB+SI_IND+bx]
    mov di, [PCB+DI_IND+bx]
    mov bp, [PCB+BP_IND+bx]
    mov ds, [PCB+DS_IND+bx]
    mov es, [PCB+ES_IND+bx]

    ;EoI + restore ax, bx + leave
    mov al, 0x20
    out 0x20, al
    mov ax, [PCB+AX_IND+bx]
    mov bx, [PCB+BX_IND+bx]
    iret

int21isr:
    ; exit if not 4b
    Cmp ah, 0x4b
    jne exitINT21

    ; exit if below 10
    cmp al, 0x10
    jbe exitINT21
    
    createCheck:
        cmp al, 0x10 
        je create_thread_init 
        ;check thread count -> get free pcb -> initpcb -> insert thread

    deleteCheck:
        cmp al, 0x10 
        je delete_thread_init

    suspendCheck:
        cmp al, 0x10 
        je suspend_thread_init

    resumeCheck:
        cmp al, 0x10 
        je resume_thread_init

    jmp exitINT21

    exitINT21:
        jmp [old21]

start:
    xor ax, ax 
    mov es, ax

    ;store original ISRs
    mov eax, [es:8*4]
    mov dword [oldtt], eax
    mov eax, [es:21*4]
    mov dword [old21], eax
    
    ;Replace ISRs
    cli
    mov word [es:8*4+2], cs
    mov word [es:8*4], int08isr
    mov word [es:21*4+2], cs
    mov word [es:21*4], int21isr
    sti

    ;TSR				
    mov dx, start
    add dx, 15
    mov cl, 4
    shr dx, cl
    mov ax, 3100h
    int 21h