#include "tipos.h"
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

void suma(uniontype *resultat, uniontype operand1, uniontype operand2);
void negacio(uniontype *resultat, uniontype operand);
void modul(uniontype *resultat, uniontype operand1, uniontype operand2);
void multiplicacio(uniontype *resultat, uniontype operand1, uniontype operand2);
void divisio(uniontype *result, uniontype operand1, uniontype operand2);
void resta(uniontype *resultat, uniontype operand1, uniontype operand2);
void potencia(uniontype *resultat, uniontype operand1, uniontype operand2);
void logaritme(uniontype *resultat, uniontype operand);

void comparacio(uniontype *resultat, uniontype operand1, char *comp, uniontype operand2);
void and(uniontype *resultat, uniontype operand1, uniontype operand2);
void not(uniontype *resultat, uniontype operand1);
void or(uniontype *resultat, uniontype operand1, uniontype operand2);

char * tipoVariable(uniontype variable);
char * getNom(uniontype variable);