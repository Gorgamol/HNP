section .text

global addsub

sub equ 02h	; C Programm setzt "what" = 2, wenn argv[2] == '-'

addsub:
	push ebp		; Stackframe => Basepointer sichern
	mov ebp, esp		; Basepointer = Stackpointer (ebp als fester ankerpunkt für übergebene funktionsargumente)

	mov eax, [ebp+4]	; opt1 vom Stack in eax
	mov ebx, [ebp+12]	; what (+/-) vom Stack in ebx
	cmp ebx, sub	; Prüfe ob Subtraktion
	je subtraktion	;	Springe zu subtraktion, wenn gleich (jump equal)

	add ax, [ebp+8]	; opt1 + opt2 (16 bit addition)
	jmp return	; Überpringe subtraktion

subtraktion:
	sub ax, [ebp+8]	; opt1 + opt2 (16 bit subtraktion)

return:
	mov ebx, [ebp+16]	; Adresse von übergabeparameter ergebnis in ebx
	mov [ebx], eax	; Ergebnis aus eax über die Adresse zurückgeben

	pushfd	; 32 Bit EFLAGS Register auf den Stack schieben
	pop eax	; Die 32 oberen Bits (EFLAGS Register) vom Stack in eax (EAX Register = Rückgabe an C Programm)

	mov esp, ebp	; Stackpointer wieder auf den Anfang setzen
	pop ebp	; Alten Basepointer wiederherstellen

	ret
