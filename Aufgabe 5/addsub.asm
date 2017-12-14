section .text

global addsub

subt equ 02h		; C Programm setzt "what" = 2, wenn argv[2] == '-'

addsub:
	push ebp		; Stackframe => Basepointer sichern
	mov ebp, esp		; Basepointer = Stackpointer (ebp als fester ankerpunkt für übergebene funktionsargumente)

	mov eax, [ebp+8]	; op1 vom Stack in eax
	mov ebx, [ebp+16]	; what (+/-) vom Stack in ebx
	cmp ebx, subt		; Prüfe ob Subtraktion
	je subtraktion		; Springe zu subtraktion, wenn gleich (jump equal)

	add ax, [ebp+12]		; op1 + op2 (16 bit addition)
	jmp return		; Überpringe subtraktion

subtraktion:
	sub ax, [ebp+12]		; op1 + op2 (16 bit subtraktion)

return:
	mov ebx, [ebp+20]	; Adresse von übergabeparameter ergebnis in ebx
	mov [ebx], ax		; Ergebnis aus eax über die Adresse zurückgeben

	pushfd			; 32 Bit EFLAGS Register auf den Stack schieben
	pop eax			; Die 32 oberen Bits (EFLAGS Register) vom Stack in eax (EAX Register = Rückgabe an C Programm)

	mov esp, ebp		; Stackpointer wieder auf den Anfang setzen
	pop ebp			; Alten Basepointer wiederherstellen

	ret
