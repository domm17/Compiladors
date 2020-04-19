#ifndef tiposH
#define tiposH

typedef enum {INT, FLOAT, STRING} type;

typedef struct{
  union {
    int intV;
    double floatV;
    char *stringV;
  };
  type type;
  char *caracter;
} uniontype;

#endif
