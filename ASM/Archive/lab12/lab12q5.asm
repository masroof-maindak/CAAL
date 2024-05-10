; Bottom up Fibonacci
org 100h

jmp start
break:
    dec cx          ;fib(1) = 0, fib(2) = 1...
    mov ax, cx
    jmp exit
start:
    mov cx, [arg]
    cmp cx, 2       ;check if fib(arg) is already stored
    jbe break
    sub cx, 2       ;must sub cx twice to account for hard-coded values
fibber:
    mov ax, [num1]  ;ax=num1+num2
    add ax, [num2]
    mov bx, [num2]  ;num1 = num2
    mov [num1], bx
    mov [num2], ax  ;num2 = num1+num2
    loop fibber
exit:
    mov ax, 4c00h
    int 21h
arg: dw 10
num1: dw 0
num2: dw 1
