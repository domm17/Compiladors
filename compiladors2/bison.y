%{

#include <stdio.h>
#include <stdlib.h>
#include "bison.tab.h"
#include "./symtab/symtab.h"
#include "./funcionsAuxiliars.h"
extern FILE* yyin;
extern int yylex();
extern void yyerror();

mode modeActual;
int lineas=0;


%}

%code requires {
  #include "tipos.h"
}

%union{
  uniontype utype;
  char *caracter;
}

%token <utype> MODE
%token <utype> UTYPE
%token <utype> VARIABLE
%token <utype> VARIABLE_BOOLEANA
%token <utype> TRUE
%token <utype> FALSE

%token TKN_NOT
%token TKN_AND
%token TKN_OR

%token TKN_IF
%token TKN_THEN
%token TKN_ELSE
%token TKN_ELSEIF
%token TKN_FI
%token TKN_WHILE
%token TKN_DO
%token TKN_DONE
%token TKN_REPEAT
%token TKN_UNTIL
%token TKN_FOR
%token TKN_IN
%token TKN_RANGE

%token TKN_NEWLINE
%token TKN_ASSIGNACIO
%token TKN_SUMA
%token TKN_RESTA
%token TKN_MULTIPLICACIO
%token TKN_DIVISIO
%token TKN_POTENCIA
%token TKN_MODUL
%token TKN_PARENTESISEQUERRA
%token TKN_PARENTESISDRET

%token TKN_MULTILINEA
%token TKN_COMENTARI

%token <utype> TKN_LOG
%token <utype> COMP

%type <utype> linea
%type <utype> expressioOboolea
%type <utype> expresio
%type <utype> expresioBooleana
%type <utype> identificador

%type <utype> for_linea
%type <utype> for_bucle
%type <utype> for_variable
%type <utype> exp_if

%type <utype> exp_elif 
%type <utype> exp_elif1
%type <utype> exp_while 

%type <utype> exp_iteracio
%type <utype> exp_linea_iteracio

%type <utype> program_input
%type <utype> exp_condicio 
%type <utype> program_linea

%type <utype> repeat_linea

%left TKN_SUMA TKN_RESTA
%left TKN_MULTIPLICACIO TKN_DIVISIO TKN_MODUL
%left TKN_POTENCIA 

%left TKN_NOT
%left TKN_OR
%left TKN_AND
%left COMP
%left TKN_PARENTESISEQUERRA TKN_PARENTESISDRET

%start start

%%

start: calc TKN_NEWLINE program_input  {};

calc: MODE {
  modeActual = $1.intV;

  switch(modeActual){
    case CALC:
      printf("\tMODE CALCULADORA\n\n");
      break;
    case PRGM:
      printf("\tMODE PROGRAMA\n\n");
      break;
  }
};

program_input: program_input  linea{ $$ = $2; lineas=lineas+1; } 
              | linea ;


linea :  program_linea { $$ = $1; };

linea : identificador TKN_ASSIGNACIO expressioOboolea TKN_NEWLINE{

  sym_enter($1.stringV, &$3);
  char * operand1 = tipoVariable($3);
  char * operand2 = getNom($3);

  if (modeActual == CALC){
      printf("Assignacio-> Tipo:%s %s:=%s     \n\n", operand1, $1.stringV, operand2);
  }

};


linea : TKN_COMENTARI TKN_NEWLINE {}
linea: TKN_MULTILINEA TKN_NEWLINE {}

linea : expressioOboolea TKN_NEWLINE {

  char * operand1 = tipoVariable($1);
  char * operand2 = getNom($1);

  if (modeActual == CALC){
      printf("Expressio-> Tipo:%s Valor:%s\n\n", operand1, operand2);
  }
    
};


expressioOboolea : expresio | expresioBooleana ;

identificador: VARIABLE | VARIABLE_BOOLEANA;


program_linea : exp_if | exp_while | repeat_linea | for_linea ;

exp_if : TKN_IF TKN_PARENTESISEQUERRA exp_condicio TKN_PARENTESISDRET TKN_THEN TKN_NEWLINE  program_input TKN_FI TKN_NEWLINE {};

exp_if : TKN_IF TKN_PARENTESISEQUERRA exp_condicio TKN_PARENTESISDRET TKN_THEN TKN_NEWLINE  program_input TKN_ELSE TKN_NEWLINE   program_input TKN_FI TKN_NEWLINE{
};

exp_if : TKN_IF TKN_PARENTESISEQUERRA exp_condicio TKN_PARENTESISDRET TKN_THEN TKN_NEWLINE  program_input exp_elif TKN_ELSE TKN_NEWLINE  program_input TKN_FI TKN_NEWLINE{
};

exp_elif : exp_elif exp_elif1 {}
                 | exp_elif1;

exp_elif1 :  TKN_ELSEIF TKN_PARENTESISEQUERRA exp_condicio TKN_PARENTESISDRET TKN_THEN TKN_NEWLINE  program_input {};


exp_while: TKN_WHILE  TKN_PARENTESISEQUERRA exp_condicio TKN_PARENTESISDRET TKN_DO TKN_NEWLINE  exp_iteracio TKN_DONE TKN_NEWLINE{};

repeat_linea: TKN_REPEAT TKN_NEWLINE  exp_iteracio TKN_UNTIL TKN_PARENTESISEQUERRA  exp_condicio TKN_PARENTESISDRET TKN_NEWLINE{}

for_linea: for_bucle  exp_iteracio TKN_DONE TKN_NEWLINE {}

for_variable : VARIABLE {
  
  if (sym_lookup($1.stringV, &$$) != SYMTAB_NOT_FOUND){
    printf("La variable ja estava definida");
    yyerror();
  }

  $$.caracter = $1.stringV;
}

for_bucle: TKN_FOR TKN_PARENTESISEQUERRA for_variable TKN_IN expresio TKN_RANGE expresio TKN_PARENTESISDRET TKN_DO TKN_NEWLINE {
  
  if (($5.type != INT && $5.type != FLOAT) || ($7.type != INT && $7.type != FLOAT)){
    printf("Els valors han de ser enters");
    yyerror();
  }

  $$.caracter = $3.caracter;
};

exp_condicio : expresioBooleana {
  $$ = $1;
  
  if($1.type != BOOLEAN){
    printf("Expressio no booleana!");
    yyerror();
  }
}

exp_iteracio: exp_iteracio  exp_linea_iteracio {}
               | exp_linea_iteracio;

exp_linea_iteracio : linea;


expresio: TKN_LOG TKN_PARENTESISEQUERRA expresio TKN_PARENTESISDRET {

  char * operand1 = getNom($3);
  if (modeActual == CALC){
      logaritme(&$$, $3);
      char * resultat = getNom($$);
      printf("Logaritme: %s = %s \n",  operand1, resultat);
  }
  else {
     logaritme(&$$, $3);
  }
  
};

expresio: TKN_PARENTESISEQUERRA expresio TKN_PARENTESISDRET {
  $$ = $2;
};

expresio: expresio TKN_POTENCIA expresio {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  if (modeActual == CALC){
     potencia(&$$, $1, $3);
     char * resultat = getNom($$);
     printf("Potencia: %s ** %s = %s \n",  operand1, operand2, resultat);

  }
  else {
       potencia(&$$, $1, $3);
  } 
  
};

expresio: expresio TKN_MODUL expresio {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  if (modeActual == CALC){
       modul(&$$, $1, $3);
       char * resultat = getNom($$);
       printf("Modul: %s ** %s = %s \n",  operand1, operand2, resultat);
  }
  else{
     modul(&$$, $1, $3);
  }
};

expresio: expresio TKN_MULTIPLICACIO expresio {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  if (modeActual == CALC){
      multiplicacio(&$$, $1, $3);
      char * resultat = getNom($$);
      printf("Multiplicacio: %s * %s = %s \n",  operand1, operand2, resultat);
  }
  else {
     multiplicacio(&$$, $1, $3);
  }
  
};

expresio: expresio TKN_DIVISIO expresio {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  if (modeActual == CALC){

   divisio(&$$, $1, $3);

  char * resultat = getNom($$);
  printf("Divisio: %s / %s = %s \n",  operand1, operand2, resultat);
  }
  else {
     divisio(&$$, $1, $3);
  } 
  
};

expresio: expresio TKN_SUMA expresio {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  if (modeActual == CALC){
     suma(&$$, $1, $3);
    char * resultat = getNom($$);
    printf("Suma: %s + %s   = %s \n",  operand1, operand2, resultat);
  }
  else{
     suma(&$$, $1, $3);
  }
};

expresio: expresio TKN_RESTA expresio {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  if (modeActual == CALC){
      resta(&$$, $1, $3);
      char * resultat = getNom($$);
      printf("Resta: %s - %s = %s \n",  operand1, operand2, resultat);

  }else{
     resta(&$$, $1, $3);
  }
  
};

expresio: TKN_RESTA expresio {
    
  char * operand1 = getNom($2);

  if (modeActual == CALC){
      negacio(&$$, $2);
      char * resultat = getNom($$);
      printf("Negacio: %s = %s \n",  operand1 , resultat);
  }
  else{
       negacio(&$$, $2);
  } 
};

expresio: VARIABLE {
  if (sym_lookup($1.stringV, &$$) == SYMTAB_NOT_FOUND){
    printf("La variable no esta definida");
    yyerror();
  }
  $$.caracter = $1.stringV;
};

expresio: UTYPE {
  $$ = $1;
  $$.caracter = getNom($1);
};


expresioBooleana: TKN_PARENTESISEQUERRA expresioBooleana TKN_PARENTESISDRET{
  $$ = $2;
};

expresioBooleana: VARIABLE_BOOLEANA {
  if (sym_lookup($1.stringV, &$$) == SYMTAB_NOT_FOUND){
    printf("La variable booleana no esta definida");
    yyerror();
  }
};

expresioBooleana: TRUE {  $$ = $1;  $$.caracter = getNom($1); };

expresioBooleana: FALSE {  $$ = $1;  $$.caracter = getNom($1); };


expresioBooleana: expresio COMP expresio {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);
  char * compa = getNom($2);

  if (modeActual == CALC){
      comparacio(&$$, $1, $2.stringV, $3);
      char * resultat = getNom($$);
      printf("COMPARACIO: %s %s %s = %s \n",  operand1, compa, operand2, resultat);
  }
  else {
       comparacio(&$$, $1, $2.stringV, $3);
  }
  
};

expresioBooleana: TKN_NOT expresioBooleana {

  char * operand1 = getNom($2);

  if (modeActual == CALC){
       not(&$$, $2);
       char * resultat = getNom($$);
       printf("NOT: %s = %s \n",  operand1 , resultat);
  }
  else{
       not(&$$, $2);
   } 
  
};

expresioBooleana: expresioBooleana TKN_AND  expresioBooleana {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  if (modeActual == CALC){
     and(&$$, $1, $3);
       char * resultat = getNom($$);
      printf("AND: %s || %s = %s \n",  operand1, operand2, resultat);
  }
  else{
       and(&$$, $1, $3);
  } 
};

expresioBooleana: expresioBooleana TKN_OR  expresioBooleana {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  if (modeActual == CALC){
      or(&$$, $1, $3);
      char * resultat = getNom($$);
      printf("OR: %s && %s = %s \n",  operand1, operand2, resultat);
  }
  else{
       or(&$$, $1, $3);
  } 
  
};

%%

int main(int argc, char **argv)
{
  
    yyin = fopen(argv[1], "r");
    if (!yyin) {
      printf("FItxer no trobat!!\n");
      return -1;
    }
    yyparse();
      
}

void yyerror()
{
    printf("ERROR semantic linea: %d\n", lineas);
}

