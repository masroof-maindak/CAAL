; Scheduler
org 100h
jmp start

oldtt: dd 0
old21: dd 0
PCB: times 16*16 dw 0     ; process control block - for 32 bytes/thread
stacks: times 256*16 dw 0 ; 512 bytes per stack per program
currProc: dw 0            ; PCB number of currently active process
threadCount: dw 1         ; no. of active threads (i.e freFlag = 1)

;structure of one chunk in the PCB:
; 02 bytes - prev/next pointers
; 01 byte  - free flag (i.e not dead)
; 01 byte  - priority
; 28 bytes - general purpose registers

LL_IND: EQU 0
freFlg: EQU 2
PR_IND: EQU 3
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

; receieves current process in ax
; returns in ax the next PCB's number
getNext:
    mov bx, ax
    shl bx, 5
    mov ax, [PCB+LL_IND+bx]
    and ax, 0x00FF  ;to discard 'prev' pointer
    ret

; loops through all PCBs and returns first free
; PCB's number in ax. Places ff if no free found
; Assumes thread_count is within bounds
get_free_pcb:
    ret

;reached via retf from user's subroutine
receive_ret:
    ; deletes curr proc, adjusting LL
    ; ??
    ret

;receives PCB to insert into dispatcher via ax
insert_thread:
    push ax
    mov bx, ax              ;bx = new
    shl bx, 5               ;bx = new's PCB

    xor ax, ax              ;ax = 0
    call getNext            ;ax = 0:0's next
    mov [PCB+LL_IND+bx], ax ;new's prev/next = 0/0's next
    mov bx, ax;             ;bx = 0's next
    shl bx, 5;              ;bx = 0's next's PCB

    pop ax ; ax = new
    mov byte [PCB+LL_IND+bx], al ;0's next's prev = new
    mov byte [PCB+LL_IND+1], al  ;0's next = new
    ret

;receives pcb # to init in ax
init_pcb:
    push bp
    mov bp, sp
    push ax
    push si
    push bx

    ; bx to access PCBs
    mov bx, ax
    shl bx, 5

    ; si to access stacks
    mov si, ax
    shl si, 9
    add si, 510 ;move to bottom

    ; Init general purpose registers
    xor ax, ax
    mov byte [PCB+freFlg+bx], al
    mov byte [PCB+PR_IND+bx], al
    mov word [PCB+AX_IND+bx], ax
    mov word [PCB+BX_IND+bx], ax
    mov word [PCB+CX_IND+bx], ax
    mov word [PCB+DX_IND+bx], ax
    mov word [PCB+SI_IND+bx], ax
    mov word [PCB+DI_IND+bx], ax
    mov word [PCB+BP_IND+bx], ax
    mov word [PCB+DS_IND+bx], ax
    mov word [PCB+ES_IND+bx], ax
    mov word [PCB+FLAG_IND+bx], 0x0200 ; ensure interrupt flag is 1
    mov word [PCB+SS_IND+bx], stacks

    ; get IP and CS from stack
    mov ax, [bp+10]
    mov [PCB+IP_IND+bx], ax
    mov ax, [bp+12]
    mov [PCB+CS_IND+bx], ax
    mov 
    
    ;'push' this thread's original argument (i.e a void* comprising  
    ;a segment-offset pair) to its newly allocated stack
    mov ax, [bp+16]
    mov word [stacks+si], ax
    sub si, 2
    mov ax, [bp+14]
    mov word [stacks+si], ax
    sub si, 2

    ;'push' the segment and address of where the program should go
    ;if it calls for 'ret' - i.e our handler function that deletes the thread
    ;note: assumes user uses RETF
    mov [stacks+si], cs
    sub si, 2
    mov [stacks+si], receive_ret

    mov [PCB+SP_IND+bx], si

    pop bx
    pop si
    pop ax
    pop bp
    ret

int08isr:
    push bx
    mov bx, [currProc]
    shl bx, 5

    ;STORE
    ;general purpose registers
    mov word [PCB+AX_IND+bx], ax
    pop ax
    mov word [PCB+BX_IND+bx], ax
    mov word [PCB+CX_IND+bx], cx
    mov word [PCB+DX_IND+bx], dx
    mov word [PCB+SI_IND+bx], si
    mov word [PCB+DI_IND+bx], di
    mov word [PCB+BP_IND+bx], bp
    mov word [PCB+DS_IND+bx], ds
    mov word [PCB+ES_IND+bx], es

    ;iret relevant registers
    pop ax
    mov word [PCB+IP_IND+bx], ax
    pop ax
    mov word [PCB+CS_IND+bx], ax
    pop ax
    mov word [PCB+FLAG_IND+bx], ax

    ;stack relevant registers
    mov word [PCB+SS_IND+bx], ss
    mov word [PCB+SP_IND+bx], sp

    mov ax, [currProc]
    call getNext       ;ax = next
    mov word [currProc], ax
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
    jne oldINT21

    ; exit if below 10
    cmp al, 0x10
    jbe oldINT21
    
    createCheck:
        cmp al, 0x10 
        jne deleteCheck
        ;check thread count and exit if >= 16
        ;call get_free_pcb
        call init_pcb
        call insert_thread
        add word [thread_count], 1
        iret 8 ;need to iret from here to waste args unlike others

    deleteCheck: ; remove prev/next's LL pointers to/from this one + enable 'avlbl' flag
        cmp al, 0x10 
        jne suspendCheck
        ; if trying to delete 0 or >= 16, exit
        call delete_thread
        sub word [thread_count], 1
        jmp exitINT21

    suspendCheck: ; remove prev/next's LL pointers to/from this one
        cmp al, 0x10
        jne resumeCheck
        ; if trying to suspend 0 or >= 16, exit
        call suspend_thread
        jmp exitINT21

    resumeCheck: ; add this one to prev/next's LL pointers
        cmp al, 0x10 
        jne oldINT21
        ; if trying to resume 0 or >= 16, exit
        call resume_thread

    exitINT21:
        ;do I need to send EoI for i21?
        ;ax SHOULD have ff for failure, ee for success, or PCB no. if insertion
        iret

    oldINT21:
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