#include "./funcionsAuxiliars.h"
#include <math.h>


void potencia(uniontype *resultat, uniontype operand1, uniontype operand2){
  if(operand1.type == INT && operand2.type == INT){
    resultat->intV = pow(operand1.intV, operand2.intV);
  }

  if(operand1.type == FLOAT &&  operand2.type == FLOAT){
    resultat->floatV = pow(operand1.floatV, operand2.floatV);
  }
  if(operand1.type == FLOAT &&  operand2.type == INT){
    resultat->floatV = pow(operand1.floatV, operand2.intV);
  }
  if(operand1.type == INT &&  operand2.type == FLOAT){
    resultat->floatV = pow(operand1.intV, operand2.floatV);
  }

}


void modul(uniontype *resultat, uniontype operand1, uniontype operand2){

  if(operand1.type == INT && operand2.type == INT){
    resultat->intV = fmodf(operand1.intV, operand2.intV);
  }

  if(operand1.type == FLOAT && operand2.type == FLOAT){
    resultat->floatV = fmodf(operand1.floatV, operand2.floatV);
  }
  
  if(operand1.type == FLOAT && operand2.type == INT){
    resultat->floatV = fmodf(operand1.floatV, operand2.intV);
  }

  if(operand1.type == INT && operand2.type == FLOAT){
    resultat->floatV = fmodf(operand1.intV, operand2.floatV);
  }
}


void multiplicacio(uniontype *resultat, uniontype operand1, uniontype operand2){
  if(operand1.type == INT && operand2.type == INT){
    resultat->intV = operand1.intV * operand2.intV;
    resultat->type = INT;
  }

  if(operand1.type == FLOAT && operand2.type == FLOAT){
    resultat->floatV = operand1.floatV * operand2.floatV;
    resultat->type = FLOAT;
  }

  if(operand1.type == INT && operand2.type == FLOAT){
    resultat->floatV = operand1.intV * operand2.floatV;
    resultat->type = FLOAT;
  }

  if(operand1.type == FLOAT && operand2.type == INT){
    resultat->floatV = operand1.floatV * operand2.intV;
    resultat->type = FLOAT;
  }

}

void divisio(uniontype *resultat, uniontype operand1, uniontype operand2){
  if((operand2.type == INT && operand2.intV == 0) || (operand2.type == FLOAT && operand2.floatV == 0.0)){
    printf("No es pot dividir per 0!\n");
  }else{

    if(operand1.type == INT && operand2.type == INT){
      resultat->intV = operand1.intV / operand2.intV;
      resultat->type = INT;
    }

    if(operand1.type == FLOAT && operand2.type == FLOAT){
      resultat->floatV = operand1.floatV / operand2.floatV;
      resultat->type = FLOAT;
    }

    if(operand1.type == INT && operand2.type == FLOAT){
      resultat->floatV = operand1.intV / operand2.floatV;
      resultat->type = FLOAT;
    }

    if(operand1.type == FLOAT && operand2.type == INT){
      resultat->floatV = operand1.floatV / operand2.intV;
      resultat->type = FLOAT;
    }
  }


}


void resta(uniontype *resultat, uniontype operand1, uniontype operand2){
  if(operand1.type == INT && operand2.type == INT){
    resultat->intV = operand1.intV - operand2.intV;
    resultat->type = INT;
  }

  if(operand1.type == FLOAT && operand2.type == FLOAT){
    resultat->floatV = operand1.floatV - operand2.floatV;
    resultat->type = FLOAT;
  }

  if(operand1.type == INT && operand2.type == FLOAT){
    resultat->floatV = operand1.intV - operand2.floatV;
    resultat->type = FLOAT;
  }

  if(operand1.type == FLOAT && operand2.type == INT){
    resultat->floatV = operand1.floatV - operand2.intV;
    resultat->type = FLOAT;
  }
}


void negacio(uniontype *resultat, uniontype operand){
  
  if(operand.type == INT){
    resultat->intV = -operand.intV;
    resultat->type = INT;
  }
  if(operand.type == FLOAT){
    resultat->floatV = -operand.floatV;
    resultat->type = FLOAT;
  }

};

void logaritme(uniontype *resultat, uniontype operand){
  resultat->type = FLOAT;
  if(operand.type == FLOAT){
    resultat->floatV = log(operand.floatV);
  }

  if(operand.type == INT){
    resultat->floatV = log(operand.intV);
  }
}



void suma(uniontype *resultat, uniontype operand1, uniontype operand2){
    
    resultat->type = STRING;
    if(operand1.type == STRING && operand2.type == STRING){
      char * aux = (char *) malloc(strlen(operand1.stringV)+ strlen(operand2.stringV));  

      strcpy(aux, operand1.stringV);
      strcat(aux, operand2.stringV);

      resultat->stringV = aux;
    }
    if(operand1.type == STRING && operand2.type == INT){
      char * aux = (char *) malloc(strlen(operand1.stringV) + 10);
      sprintf(aux, "%s%i", operand1.stringV, operand2.intV);
      resultat->stringV = aux;
    }
    if(operand1.type == INT && operand2.type == STRING){
      char * aux = (char *) malloc(strlen(operand2.stringV) + 10);
      sprintf(aux, "%i%s", operand1.intV, operand2.stringV);
      resultat->stringV = aux;
    }
    if(operand1.type == STRING && operand2.type == FLOAT){
      char * aux = (char *) malloc(strlen(operand1.stringV) + 10);
      sprintf(aux, "%s%0.2f", operand1.stringV, operand2.floatV);
      resultat->stringV = aux;
    }
    if(operand1.type == FLOAT && operand2.type == STRING){
      char * aux = (char *) malloc(strlen(operand2.stringV) + 10);
      sprintf(aux, "%0.2f%s", operand1.floatV, operand2.stringV);
      resultat->stringV = aux;
    }
  
    if(operand1.type == INT && operand2.type == INT){
      resultat->intV = operand1.intV + operand2.intV;
      resultat->type = INT;
    }

    if(operand1.type == FLOAT && operand2.type == FLOAT){
      resultat->floatV = operand1.floatV + operand2.floatV;
      resultat->type = FLOAT;
    }

    if(operand1.type == INT && operand2.type == FLOAT){
      resultat->floatV = operand1.intV + operand2.floatV;
      resultat->type = FLOAT;
    }

    if(operand1.type == FLOAT && operand2.type == INT){
      resultat->floatV = operand1.floatV + operand2.intV;
      resultat->type = FLOAT;
    }


}


char * tipoVariable(uniontype variable) {
  switch (variable.type) {
    case INT:
      return "INT";
      break;
    case FLOAT:
      return "FLOAT";
      break;
    case STRING:
      return "STRING";
      break;
  };
}

char * getNom(uniontype variable) {
  char *nom = malloc(10);

  switch (variable.type) {
    case STRING:
      return variable.stringV;
      break;
    case INT:
      sprintf(nom, "%d", variable.intV);
      break;
    case FLOAT:
      sprintf(nom, "%0.2f", variable.floatV);
      break;
  };
  return nom;
}
