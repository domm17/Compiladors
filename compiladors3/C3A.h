#include "tipos.h"
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <regex.h>


extern int variablesLocals;
extern int linea3a;
extern char ** instructions;


void newVariableLocal(char ** variable);
line * makeList(int line_number);
line * merge(line *llista1, line *llista2);
void emit(char *instruction);
void backpatch(line *lines, int position);


void potencia3a(uniontype *resultat, uniontype *operand1, uniontype *operand2);
void multiplicacio3a(uniontype *resultat, uniontype *operand1, uniontype *operand2);
void modul3a(uniontype *resultat, uniontype *operand1, uniontype *operand2);
void divisio3a(uniontype *resultat, uniontype *operand1, uniontype *operand2);
void resta3a(uniontype *resultat, uniontype *operand1, uniontype *operand2);

void suma3a(uniontype *resultat, uniontype *operand1, uniontype *operand2);
void negacio3a(uniontype *resultat, uniontype *operand1);

void compare3a(uniontype *resultat, uniontype *operand1, char *comp, uniontype *operand2);

void not3a(uniontype *resultat, uniontype *operand);
void and3a(uniontype *resultat, uniontype *operand1, uniontype *operand2, uniontype *m);
void or3a(uniontype *resultat, uniontype *operand1, uniontype *operand2, uniontype *m);

void log_function_c3a(uniontype *resultat, uniontype *op);

