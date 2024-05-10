; Recursive fibonacci sequence
org 100h

mov ax, 5
push ax
call fibo
pop ax

mov ax, 4c00h
int 21h

fibo:
    push bp
    mov bp, sp
    sub sp, 2       ;create empty space at bp-2 (for fib(n-1))
    pusha
    mov ax, [bp+4]  ;ax = arg

    ;base case #1
        cmp ax, 0
        jne fib1
        mov word [bp+6], 1
        jmp exitFibo

    fib1:
        cmp ax, 1
        jne recursive_calls
        mov word [bp+6], 1
        jmp exitFibo

    recursive_calls:
        ;fib(n-1), stored in bp-2
        sub sp, 2       
        dec ax
        push ax 
        call fibo
        pop word [bp-2]

        ;fib(n-2), stored in dx
        sub sp, 2
        dec ax
        push ax
        call fibo
        pop dx

        ;[sp - 2] creates empty space at top of stack, becomes
        ;the 'bottom' of stack frame for next recursive call

    ;Calculate and store answer in bp+6 (the 'sp-2' we created prior to calling fibo)
    add dx, [bp-2]
    mov [bp+6], dx

    exitFibo:
        popa
        add sp, 2
        pop bp
        ret 2       ;pop address + waste parameter
