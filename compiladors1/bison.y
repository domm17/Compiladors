%{
#include <stdio.h>
#include <stdlib.h>
#include "bison.tab.h"
#include "./symtab/symtab.h"
#include "./funcionsAuxiliars.h"
#include "tipos.h"
#include <math.h>
#include <string.h>
extern int yylex();
extern void yyerror();
extern FILE* yyin;

int lineas=0;

%}


%code requires {
  #include "tipos.h"
}

%union{
  uniontype utype;
  char *caracter;
}

%token <utype> UTYPE
%token <utype> VARIABLE
%token TKN_SUMA
%token TKN_RESTA
%token TKN_MULTIPLICACIO
%token TKN_DIVISIO
%token TKN_POTENCIA
%token TKN_MODUL
%token TKN_PARENTESISEQUERRA
%token TKN_PARENTESISDRET
%token TKN_NEWLINE
%token TKN_ASSIGNACIO
%token TKN_MULTILINEA
%token TKN_COMENTARI

%token <utype> TKN_LOG
%type <utype> program_input
%type <utype> linea
%type <utype> expresio

%left TKN_SUMA TKN_RESTA
%left TKN_MODUL TKN_MULTIPLICACIO TKN_DIVISIO 
%left TKN_POTENCIA 

%%

program_input: program_input  linea{ $$ = $2; lineas=lineas+1;} 
             | linea ;


linea : VARIABLE TKN_ASSIGNACIO expresio TKN_NEWLINE{
  sym_enter($1.stringV, &$3);

  char * tipo = tipoVariable($3);
  char * nom = getNom($3);
  printf("Assignacio %s %s:=%s     \n\n", tipo, $1.stringV, nom);
    
};

linea : expresio TKN_NEWLINE {
  
  char * tipo = tipoVariable($1);
  char * nom = getNom($1);
  printf("Expressio %s = %s    \n\n", tipo, nom);

};

linea : TKN_COMENTARI TKN_NEWLINE{}

linea: TKN_MULTILINEA TKN_NEWLINE{}


expresio: TKN_LOG TKN_PARENTESISEQUERRA expresio TKN_PARENTESISDRET {
 
  char * operand = getNom($3);
  logaritme(&$$, $3);
  char * resultat = getNom($$);
  printf("Logaritme: %s = %s \n",  operand, resultat);

};

expresio: TKN_PARENTESISEQUERRA expresio TKN_PARENTESISDRET {$$ = $2;};

expresio: expresio TKN_POTENCIA expresio {
  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  potencia(&$$, $1, $3);
  
  char * resultat = getNom($$);
  printf("Potencia: %s ** %s = %s \n",  operand1, operand2, resultat);

};

expresio: expresio TKN_MODUL expresio {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  modul(&$$, $1, $3);
  char * resultat = getNom($$);
  printf("Modul-> %s ** %s = %s \n",  operand1, operand2, resultat);

};

expresio: expresio TKN_MULTIPLICACIO expresio {
  
  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  multiplicacio(&$$, $1, $3);
  char * resultat = getNom($$);
  printf("Multiplicacio: %s * %s = %s \n",  operand1, operand2, resultat);

};

expresio: expresio TKN_DIVISIO expresio {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  divisio(&$$, $1, $3);
  char * resultat = getNom($$);
  printf("Divisio: %s / %s = %s \n",  operand1, operand2, resultat);

};

expresio: expresio TKN_SUMA expresio {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  suma(&$$, $1, $3);
  char * resultat = getNom($$);
  printf("Suma: %s + %s   = %s \n",  operand1, operand2, resultat);

};

expresio: expresio TKN_RESTA expresio {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  resta(&$$, $1, $3);
  
  char * resultat = getNom($$);
  printf("Resta: %s - %s = %s \n",  operand1, operand2, resultat);

};

expresio: TKN_RESTA expresio {

  char * operand1 = getNom($2);

  negacio(&$$, $2);

  char * resultat = getNom($$);
  printf("Negacio: %s = %s \n",  operand1 , resultat);

};

expresio: VARIABLE {
  if (sym_lookup($1.stringV, &$$) == SYMTAB_NOT_FOUND){
 	    printf("La variable no existeix");
      yyerror();
  }
  $$.caracter = $1.stringV;
};

expresio: UTYPE {
  $$ = $1;
  $$.caracter = getNom($1);
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




