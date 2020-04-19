%{


#include <stdio.h>
#include <stdlib.h>
#include "bison.tab.h"
#include "./symtab/symtab.h"
#include "./funcionsAuxiliars.h"
#include "./C3A.h"

extern FILE* yyin;
extern int yylex();
extern void yyerror();
extern int yyparse();

mode modeActual;
int lineas=1;

FILE* salida;

int variablesLocals = 0;
int linea3a = 0;
char ** instructions;

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

%type <utype> QUAD
%type <utype> GOTO


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

start: calc TKN_NEWLINE program_input  QUAD {

  if (modeActual == PRGM){
    emit("HALT");
    backpatch($3.nextList, $4.intV + 1);
  }

};

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

program_input: program_input QUAD  linea
               {
                  $$ = $3; lineas=lineas+1;   
                  backpatch($1.nextList, $2.intV + 1); 
               } 
               | linea ;


linea :  program_linea { $$ = $1; };

linea : identificador TKN_ASSIGNACIO expressioOboolea TKN_NEWLINE{

  sym_enter($1.stringV, &$3);
  char * operand1 = tipoVariable($3);
  char * operand2 = getNom($3);

  if (modeActual == CALC){
      printf("Assignacio-> Tipo:%s %s:=%s     \n\n", operand1, $1.stringV, operand2);
  }else{
      
        char * instruction = (char*) malloc(50);
        newVariableLocal(&$$.caracter);
        
        sprintf(instruction, "%s := %s", $$.caracter, $3.caracter);
        emit(instruction);
        
        sprintf(instruction, "%s := %s", $1.stringV, $$.caracter);
        emit(instruction);
  }

};

linea : TKN_COMENTARI TKN_NEWLINE {}
linea: TKN_MULTILINEA TKN_NEWLINE {}

linea : expressioOboolea TKN_NEWLINE {

  char * operand1 = tipoVariable($1);
  char * operand2 = getNom($1);

  if (modeActual == CALC){
      printf("Expressio-> Tipo:%s Valor:%s\n\n", operand1, operand2);
  }else{

      char * instruction = (char*) malloc(50);
      sprintf(instruction, "PARAM %s", $1.caracter);
      emit(instruction);

      switch ($1.type){
        case INT:
          sprintf(instruction, "CALL PUTI,1");
          emit(instruction);
          break;
        case FLOAT:
          sprintf(instruction, "CALL PUTF,1");
          emit(instruction);
          break;
      }

  }
   
};


QUAD : { 
  $$.intV = linea3a;
}

GOTO : { 
  emit("GOTO"); 
  $$.nextList = makeList(linea3a);
}


expressioOboolea : expresio | expresioBooleana ;

identificador: VARIABLE | VARIABLE_BOOLEANA;


program_linea : exp_if | exp_while | repeat_linea | for_linea ;

exp_if : TKN_IF TKN_PARENTESISEQUERRA exp_condicio TKN_PARENTESISDRET TKN_THEN TKN_NEWLINE QUAD program_input TKN_FI TKN_NEWLINE {
    
          backpatch($3.trueList, $7.intV + 1);
          $$.nextList = merge($3.falseList, $8.nextList);

};

exp_if : TKN_IF TKN_PARENTESISEQUERRA exp_condicio TKN_PARENTESISDRET TKN_THEN TKN_NEWLINE QUAD program_input TKN_ELSE TKN_NEWLINE  GOTO QUAD program_input TKN_FI TKN_NEWLINE{
  
            backpatch($3.trueList, $7.intV + 1);
            backpatch($3.falseList, $12.intV + 1);
            $$.nextList = merge($11.nextList, merge($8.nextList, $13.nextList));

};

exp_if : TKN_IF TKN_PARENTESISEQUERRA exp_condicio TKN_PARENTESISDRET TKN_THEN TKN_NEWLINE QUAD program_input exp_elif TKN_ELSE TKN_NEWLINE  GOTO program_input TKN_FI TKN_NEWLINE{

          backpatch($3.trueList, $7.intV + 1);
          backpatch($3.falseList, $9.intV);
          $$.nextList = merge($12.nextList, merge($8.nextList, merge($9.nextList, $13.nextList)));

};

exp_elif : exp_elif exp_elif1 {}
                 | exp_elif1;



exp_elif1 : GOTO TKN_ELSEIF TKN_PARENTESISEQUERRA exp_condicio TKN_PARENTESISDRET TKN_THEN TKN_NEWLINE  QUAD program_input QUAD{
    
    $$.intV = $8.intV - 1;
    backpatch($4.trueList, $8.intV + 1);
    backpatch($4.falseList, $10.intV + 2);
    $$.nextList = merge($1.nextList, $9.nextList);
};


exp_while: TKN_WHILE QUAD TKN_PARENTESISEQUERRA exp_condicio TKN_PARENTESISDRET TKN_DO TKN_NEWLINE  QUAD exp_iteracio TKN_DONE TKN_NEWLINE{
  
 
  backpatch($4.trueList, $8.intV + 1);
  backpatch($9.nextList, $2.intV + 1);
  backpatch($9.trueList, $2.intV+ 1);
 
  emit("GOTO");
  
  backpatch(makeList(linea3a), $2.intV + 1);
  $$.nextList = merge($4.falseList, $9.falseList);


};

repeat_linea: TKN_REPEAT TKN_NEWLINE QUAD exp_iteracio TKN_UNTIL TKN_PARENTESISEQUERRA QUAD exp_condicio TKN_PARENTESISDRET  TKN_NEWLINE{
  
  backpatch($8.trueList, $3.intV + 1);
  backpatch($4.nextList, $7.intV + 1);
  backpatch($4.trueList, $3.intV + 1);

  $$.nextList = merge($4.falseList, merge($8.falseList, $4.nextList));


}

for_linea: for_bucle  QUAD exp_iteracio TKN_DONE TKN_NEWLINE {
    
    backpatch($1.trueList, $2.intV + 1);
    backpatch($3.trueList, $2.intV + 1);

    char * instruction = (char*) malloc(50);
    sprintf(instruction, "%s := %s ADDI %s", $1.caracter, $1.caracter, "1");
    emit(instruction);

    emit("GOTO");
    backpatch(makeList(linea3a), $1.intV);

    backpatch($3.nextList, linea3a - 1);
    $$.nextList = merge($1.falseList, $3.falseList);

}

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

  char * instruction = (char*) malloc(50);

  strcpy(instruction, "IF ");
  strcat(instruction, $3.caracter);
  strcat(instruction, " LT ");
  strcat(instruction, $7.caracter);
  strcat(instruction, " GOTO");
  
  emit(instruction);

  $$.trueList = makeList(linea3a);
  emit("GOTO");
  $$.falseList = makeList(linea3a);
  $$.intV = linea3a - 1;



  $$.caracter = $3.caracter;
};

exp_condicio : expresioBooleana {
  $$ = $1;
  
  if($1.type != BOOLEAN){
    printf("Expressio no booleana!");
    yyerror();
  }
}

exp_iteracio: exp_iteracio QUAD exp_linea_iteracio {
        
        backpatch($1.nextList, $2.intV + 1);
        $$.trueList = merge($1.trueList, $3.trueList);
        $$.falseList = merge($1.falseList, $3.falseList);
        $$.nextList = $3.nextList;

      }
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
     log_function_c3a(&$$, &$3);
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

    potencia3a(&$$, &$1, &$3);

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

    modul3a(&$$, &$1, &$3);

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

     multiplicacio3a(&$$, &$1, &$3);

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

     divisio3a(&$$, &$1, &$3);

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

     suma3a(&$$, &$1, &$3);

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

       resta3a(&$$, &$1, &$3);

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

       negacio3a(&$$, &$2);

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

expresioBooleana: TRUE {    
  
  emit("GOTO");
  $$ = $1;
  $$.trueList = makeList(linea3a);
  $$.caracter = getNom($1);
 
 };

expresioBooleana: FALSE {   
  
  emit("GOTO");
  $$ = $1;
  $$.falseList = makeList(linea3a);
  $$.caracter = getNom($1);

};


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
       compare3a(&$$, &$1, $2.stringV, &$3);
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
       not3a(&$$, &$2);
   } 
  
};

expresioBooleana: expresioBooleana TKN_AND QUAD expresioBooleana {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  if (modeActual == CALC){
     and(&$$, $1, $3);
       char * resultat = getNom($$);
      printf("AND: %s || %s = %s \n",  operand1, operand2, resultat);
  }
  else{
       and3a(&$$, &$1, &$4, &$3);
  } 
};

expresioBooleana: expresioBooleana TKN_OR QUAD expresioBooleana {

  char * operand1 = getNom($1);
  char * operand2 = getNom($3);

  if (modeActual == CALC){
      or(&$$, $1, $3);
      char * resultat = getNom($$);
      printf("OR: %s && %s = %s \n",  operand1, operand2, resultat);
  }
  else{

      or3a(&$$, &$1, &$4, &$3);
  } 
  
};

%%


int main(int argc, char **argv)
{
    instructions = (char**) malloc(100 * sizeof(char*));

    yyin = fopen(argv[1], "r");
    if (!yyin) {
      printf("FItxer no trobat!!\n");
      return -1;
    }

    salida = fopen(argv[2], "w");
    if(!salida){
        fprintf(stdout, "\n***Error al abrir archivo de escritura.\n");
        fclose(yyin);
        return -1;
    }
    yyparse();
    fclose(yyin);

    int i=0;   
    if(modeActual==PRGM){
        for(i=0;i<linea3a;i++){
          printf("%s\n", instructions[i]);
          fprintf(salida, "%s\n", instructions[i]);
        }

    }




}

void yyerror()
{

  printf("ERROR semantic linea: %d\n", lineas);
        
}

