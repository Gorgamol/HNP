#C und ASM modul linken
flagtest: main.o asm.o
		gcc -m32 -o flagtest main.o asm.o

#C Modul kompilieren
main.o: main.c
		gcc -m32 -c -o main.o main.c

#ASM Modul kompilieren
asm.o: addsub.asm
		nasm -f elf -o asm.o addsub.asm
