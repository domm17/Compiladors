#include "./C3A.h"
#include "./tipos.h"
#include "funcionsAuxiliars.h"


line * makeList(int linea) {
  line *line = malloc(10);
  line->linea3a = linea;
  return line;
}


void emit(char *instruction) {
 
  instructions[linea3a] = (char*) malloc(50);
  sprintf(instructions[linea3a], "%d: %s", linea3a+1, instruction);
  linea3a++;
}

void newVariableLocal(char ** variable) {
  *variable = (char*) malloc(5 * sizeof(char));
  sprintf(*variable, "$t%02d", variablesLocals);
  variablesLocals++;
}


line * merge(line *llista1, line *llista2) {
  if (llista1 == NULL){
      return llista2;
  }else{
    
    llista1->next = llista2;
    return llista1;
  }

 
  
}


void backpatch(line *lines, int i) {
 
  while (lines) {
    char *instruction = instructions[lines->linea3a - 1];
    
    sprintf(instruction,  "%s %d", instruction ,i);

    instructions[lines->linea3a - 1] = instruction;
    lines = lines->next;
  }
 
}




void potencia3a(uniontype *E, uniontype *E1, uniontype *E2) {
  
  char * instruction = (char*) malloc(50);
  newVariableLocal(&E->caracter);

  sprintf(instruction, "PARAM %s", E1->caracter);
  emit(instruction);

  sprintf(instruction, "PARAM %s", E2->caracter);
  emit(instruction);

  sprintf(instruction, "%s := CALL POW,2", E->caracter);
  emit(instruction);
  
}

void multiplicacio3a(uniontype *E, uniontype *E1, uniontype *E2) {
  char * instruction = (char*) malloc(50 );

  if (E1->type == INT && E2->type == INT) {
    E->type = INT;
    newVariableLocal(&E->caracter);
    sprintf(instruction, "%s := %s MULI %s", E->caracter, E1->caracter, E2->caracter);
  } else{

    newVariableLocal(&E->caracter);
    E->type = FLOAT;
    sprintf(instruction, "%s := %s MULF %s", E->caracter, E1->caracter, E2->caracter);
  }

  emit(instruction);

}


void divisio3a(uniontype *E, uniontype *E1, uniontype *E2) {
  char * instruction = (char*) malloc(50 );


  if (E1->type == INT && E2->type == INT) {
    E->type = INT;
    newVariableLocal(&E->caracter);
    sprintf(instruction, "%s := %s DIVI %s", E->caracter, E1->caracter, E2->caracter);
  } else {

    newVariableLocal(&E->caracter);
    E->type = FLOAT;
    sprintf(instruction, "%s := %s DIVF %s", E->caracter, E1->caracter, E2->caracter);
  } 

  emit(instruction);

}


void resta3a(uniontype *E, uniontype *E1, uniontype *E2) {
  char * instruction = (char*) malloc(50);

  if (E1->type == INT && E2->type == INT) {
    E->type = INT;
    newVariableLocal(&E->caracter);
    sprintf(instruction, "%s := %s SUBI %s", E->caracter, E1->caracter, E2->caracter);
  } 
  else {

    newVariableLocal(&E->caracter);
    E->type = FLOAT;
    sprintf(instruction, "%s := %s SUBF %s", E->caracter, E1->caracter, E2->caracter);
  } 

  emit(instruction);

}


void suma3a(uniontype *E, uniontype *E1, uniontype *E2) {
  char * instruction = (char*) malloc(50);

  if (E1->type == INT && E2->type == INT) {
    E->type = INT;
    newVariableLocal(&E->caracter);
    sprintf(instruction, "%s := %s ADDI %s", E->caracter, E1->caracter, E2->caracter);
  } else{

    newVariableLocal(&E->caracter);
    E->type = FLOAT;
    sprintf(instruction, "%s := %s ADDF %s", E->caracter, E1->caracter, E2->caracter);
  }

  emit(instruction);
  
}





void modul3a(uniontype *E, uniontype *E1, uniontype *E2) {
  char * instruction = (char*) malloc(50 );

  if (E1->type == INT && E2->type == INT) {
    E->type = INT;
    newVariableLocal(&E->caracter);
    sprintf(instruction, "%s := %s MODI %s", E->caracter, E1->caracter, E2->caracter);
  } else {
    newVariableLocal(&E->caracter);
    E->type = FLOAT;
    sprintf(instruction, "%s := %s MODF %s", E->caracter, E1->caracter, E2->caracter);
  }

  emit(instruction);

}

void negacio3a(uniontype *E, uniontype *op) {
  char * instruction = (char*) malloc(50 );
  newVariableLocal(&E->caracter);

  E->type = op->type;
  if (op->type == INT)
    sprintf(instruction, "%s := CHSI %s", E->caracter, op->caracter);
  else
    sprintf(instruction, "%s := CHSF %s", E->caracter, op->caracter);

  emit(instruction);
};


void log_function_c3a(uniontype *E, uniontype *E1) {

  char * instruction = (char*) malloc(50);
  newVariableLocal(&E->caracter);

  sprintf(instruction, "%s := CALL LOG,1", E->caracter);
  emit(instruction);
  
}




void compare3a(uniontype *E, uniontype *E1, char *comp, uniontype *E2) {

  char * instruction = (char*) malloc(50);
  sprintf(instruction, "IF %s ", E1->caracter);

  if (strcmp(comp, ">") == 0){
    strcat(instruction, "GT");
  }
  if (strcmp(comp, "<") == 0){
    strcat(instruction, "LT");
  }
  if (strcmp(comp, "=") == 0){
    strcat(instruction, "EQ");
  }
  if (strcmp(comp, ">=") == 0){
    strcat(instruction, "GE");
  }
  if (strcmp(comp, "<=") == 0){
    strcat(instruction, "LE");
  }
  if (strcmp(comp, "<>") == 0){
    strcat(instruction, "NE");
  }

  if (E1->type == INT && E2->type == INT){
    strcat(instruction, "I ");
    strcat(instruction, E2->caracter);
  }
  else {
    strcat(instruction, "F ");
    strcat(instruction, E2->caracter);

  }

  strcat(instruction, " GOTO");
  emit(instruction);

  E->trueList = makeList(linea3a);
  emit("GOTO");
  E->falseList = makeList(linea3a);
  
  E->intV = linea3a;
  E->type = BOOLEAN;


}



void or3a(uniontype *E, uniontype *E1, uniontype *E2, uniontype *m) {
    E->type = BOOLEAN;
    
    backpatch(E1->falseList, m->intV + 1);
    E->trueList = merge(E1->trueList, E2->trueList);
    E->falseList = E2->falseList;
}



void and3a(uniontype *E, uniontype *E1, uniontype *E2, uniontype *m) {
    E->type = BOOLEAN;
    
    backpatch(E1->trueList, m->intV + 1);
    E->trueList = E2->trueList;
    E->falseList = merge(E1->falseList, E2->falseList);
}


void not3a(uniontype *E, uniontype *E1) {
    E->type = BOOLEAN;
   
    E->trueList = E1->falseList;
    E->falseList = E1->trueList;
}






