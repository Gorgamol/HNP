#include <stdio.h>
#include <stdlib.h>

extern unsigned short addsub(int op1, int op2, int what, int *result);

int main(int argc, char** argv) {
	
	//Korrekte Parameteranzahl?
	if(argc != 4) {
		printf("\nUngueltige Parameteranzahl!");
		printf("\nNutzung: flagtest [op1] [+/-] [op2]");
		return -1;
	}

	int what = 1; //1 = '+' / 2 = '-'

	//Korrekte Rechenoperation?
	if(*argv[2] == '-') {
		what = 2;
	} else if(*argv[2] != '+') {
		printf("\nUnzulaessige Rechenoperation");
		printf("\nZulaessig: '+', '-'");
		return -1;
	}

	short op1 = atoi(argv[1]);
	short op2 = atoi(argv[3]);
	short result = 0;
	unsigned short flags = addsub(op1, op2, what, (int*) &result);
	int flagArray[16];
	int i;

	//flagArray auffüllen: index 0 = Carry Flag, dann SBC-86 Reihenfolge
	for(i = 0; i < 16; i++) {
		flagArray[i] = flags % 2;
		flags = flags / 2;
	}

	//Ausgabe flags (nur SBC-86 Reihenfolge)
	printf("\nFlags:\nO D I T S Z   A   P   C\n");
	for(i = 11; i >= 0; i--) {
		printf("%d ", flagArray[i]);
	}

	printf("\n\nErgebnis und Operanden Signed: ");
	printf("%d %c %d = %d", op1, *argv[2], op2, result);
	if(flagArray[11] == 0) {	//overflow flag gesetzt? Ja = falsch, Nein = richtig
		printf(" (Ergebnis ist richtig!)\n");
	} else {
		printf(" (Ergebnis ist falsch!)\n");
	}

	printf("\nErgebnis und Operanden Unsigned: ");
	printf("%d %c %d = %d", (unsigned short) op1, *argv[2], (unsigned short) op2, (unsigned short) result);
	if(flagArray[0] == 0) {		//carry flag gesetzt? Ja = falsch, Nein = richtig
		printf(" (Ergebnis ist richtig!)\n");
	} else {
		printf(" (Ergebnis ist falsch!)\n");
	}

	return 0;
}
