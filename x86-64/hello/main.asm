global _start

section .data
message: db "Hello, world!", 0xA ; 0xA = \n

section .text
_start:
    mov rax, 1
    mov rdi, 1
    mov rsi, message
    mov rdx, 14
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
