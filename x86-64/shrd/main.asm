global _start

section .data
; bignum = 0x01020304012345678ABCDEF00
bignum: dd 0xABCDEF00, 0x12345678, 0x01020304 ; defined in reverse to account for little endian
											  ; higher side in higher memory location

section .text
_start:
	mov eax, [bignum+4]
	shrd [bignum], eax, 5
	mov dword eax, [bignum+8]
	shrd [bignum+4], eax, 5
	shr dword [bignum+8], 5

	; this file was a test to see if shrd and shld destroy
	; the source register.

	; They do not.

	; exit
    mov rax, 60
    mov rdi, 0
    syscall
