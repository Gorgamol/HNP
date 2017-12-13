# Thema: Verbindung eines C-Programms mit einem Assemblermodul

### Funktion im C Modul
```
extern unsigned short addsub(int op1, int op2, int what, int *result)
```
`extern` signalisiert, dass die Funktion woanders definiert wird. `unsigned short` als Datentyp für die Rückgabe der Flags über das EAX-Register. `int op1, int op2` sind die über die Kommandozeile eingegebenen Zahlen für die 16 Bit Addition/Subtraktion. `what => [+] oder [-]` ist die Rechenoperation. `*result` über einen Zeiger auf die Variable result, können wir im ASM Modul zusätzlich zum EAX-Register auch das Ergebnis der Rechnung über die Adresse von `result` zurückgeben.

### Funktion im ASM Modul und veranschaulichung des Stacks
Beim Funktionsaufrauf von addsub im C Modul, werden alle übergebenen Parameter auf den Stack geschoben (das letzte zuerst), dann wird ein Stackframe erzeugt. Der Basepointer wird zum sichern auf den Stack geschoben und als Ankerpunkt auf den Stackpointer gesetzt um mit festen Werten auf die übergebenen Parameter zuzugreifen. Anschließend werden über das EAX-Register die Flags zurückgegeben.
```
Pseudocode Parameter auf den Stack schieben:
  push &result
  push what
  push op2
  push op1
  
 Pseudocode Stackframe erstellen und wieder abbauen:
  push ebp
  mov ebp, esp
  ...code...
  mov esp, ebp
  pop ebp
  
 Pseudocode Flags auf den Stack schieben und in eax zurückgeben:
  pushfd
  pop eax 
```

Grobe veranschaulichung vom Stack
```
+-------------+    
| return Addr | <-- Stackpointer (esp) wandert mit wachsendem stack, Basepointer (ebp) fest verankert
+-------------+ 
| op1         | <-- [ebp + 4] = erster operand
+-------------+    
| op2         | <-- [ebp + 8] = zweiter operand
+-------------+    
| what        | <-- [ebp + 12] = rechenoperation
+-------------+    
| &result     | <-- [ebp + 16] = rückgabe über adresse von ergebnis variable 
+-------------+


+-------------+
| saved ebp   | <-- Stackpointer verschoben, nach push ebp 
+-------------+    
| return Addr | <-- Basepointer (ebp) fest veranktert
+-------------+ 
| op1         | <-- [ebp + 4] = erster operand
+-------------+    
| op2         | <-- [ebp + 8] = zweiter operand
+-------------+    
| what        | <-- [ebp + 12] = rechenoperation
+-------------+    
| &result     | <-- [ebp + 16] = rückgabe über adresse von ergebnis variable 
+-------------+


+-------------+
| flags       | <-- Stackpointer erneut verschoben, nach pushfd
+-------------+
| saved ebp   |  
+-------------+    
| return Addr | <-- Basepointer (ebp) fest verankert
+-------------+ 
| op1         | <-- [ebp + 4] = erster operand
+-------------+    
| op2         | <-- [ebp + 8] = zweiter operand
+-------------+    
| what        | <-- [ebp + 12] = rechenoperation
+-------------+    
| &result     | <-- [ebp + 16] = rückgabe über adresse von ergebnis variable 
+-------------+
```
```
+-------------+
| saved ebp   | <-- pop 32, holt die flags vom stack und verschiebt Stackpointer zurück
+-------------+    
| return Addr | <-- Basepointer (ebp) fest verankert
+-------------+ 
| op1         | <-- [ebp + 4] = erster operand
+-------------+    
| op2         | <-- [ebp + 8] = zweiter operand
+-------------+    
| what        | <-- [ebp + 12] = rechenoperation
+-------------+    
| &result     | <-- [ebp + 16] = rückgabe über adresse von ergebnis variable 
+-------------+


+-------------+    
| return Addr | <-- `pop ebp` und `mov esp, ebp` stellt alten Base Pointer wiederher, Setzt ESP zurück auf anfang vom Stackframe
+-------------+ 
| op1         | 
+-------------+    
| op2         | 
+-------------+    
| what        | 
+-------------+    
| &result     |  
+-------------+
```
Anschließend wird die ASM Subroutine mit `ret` verlassen und der Stack wird zurück gebaut.

### Rückgabewerte im C Programm
```
	short op1 = atoi(argv[1]);
	short op2 = atoi(argv[2]);
	short result = 0;
	unsigned short flags = addsub(op1, op2, what, &result);
```
Das Ergebnis der Rechnung wurde über den Pointer in die `result` variable geschrieben. `flags` bekommt über das EAX Register aus der ASM Subroutine den Status der Flags zugewiesen (16 Bit). Um die einzelnen Flags zu verarbeiten wird eine Schleife verwendet, welche bei jedem durchlauf (16 durchläufe) den Wert (entweder 1 oder 0) von `flags % 2` an die jeweils nächste freie Stelle eines 16 Stellen großen Arrays geschrieben. Für die Aufgabe sind nur folgende Flags relevant:
```
Flagreihenfolge im SBC-86


|x||x||x||x| |O||D||I||T| |S||Z||x||A| |x||P||x||C| 
+-++-++-++-+ +-++-++-++-+ +-++-++-++-+ +-++-++-++-+
|0||0||0||0| |0||0||0||0| |0||0||0||0| |0||0||0||0| 

O = Overflow Flag
D = Direction Flag
I = Interrupt Flag
T = Trap Flag
S = Sign Flag
Z = Zero Flag
A = Auxilliary Flag
P = Parity Flag
C = Carry Flag
```
Die Flags werden von rechts nach links im Array abgelegt. `flagArray[0]` ist also das erste Flag in unserem Array. Da wir außer dem Carry Flag nur das Overflow Flag benötigen, ist außerdem `flagArray[11]` relevant. Nun können wir ganz einfach verifizieren ob unser Ergebnis richtig ist. Wenn ein signed Ergebnis mit signed Operanden falsch ist bzw nach der 16 Bit Addition/Subtraktion aus dem Wertebereich läuft, dann ist das OverflowFlag = 1. Wenn ein unsigned Ergebnis mit unsigned Operanden falsch ist bzw nach der 16 Bit Addition/Subtraktion einen Übetrag hat, dann ist das CarryFlag = 1.

