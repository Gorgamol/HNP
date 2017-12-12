flagtest: main.o asm.o
	gcc -m32 -o flagtest main.o asm.o

main.o:	main.c
	gcc -m32 -c -o main.o main.c

asm.o:	calc.asm
	nasm -f elf -o asm.o addsub.asm
