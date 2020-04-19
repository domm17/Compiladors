#ifndef prac3typesH
#define prac3typesH

#include <stdbool.h>

typedef enum {CALC, PRGM} mode;
typedef enum {BOOLEAN, INT, FLOAT, STRING} type;

typedef struct{
  union {
    int intV;
    double floatV;
    char *stringV;
    bool boolV;
  };
  type type;
  char *caracter;
} uniontype;

#endif