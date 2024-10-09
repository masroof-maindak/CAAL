all: main

main.o: main.asm
	nasm -f elf64 main.asm

main: main.o
	ld -s -o main main.o

