%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "bison.tab.h"
#include "tipos.h"
#include "funcionsAuxiliars.h"

#include "./symtab/symtab.h"

int nlines=1;

#define RETURN(t) return return_token(t, #t)
#define RETURN_MODE(m) return return_mode(m)
#define RETURN_UTYPE(u) return return_utype(u)

%}


%x CALCMODE

espai [ \t]*
variable [a-zA-Z]+[a-zA-Z0-9]*
enter [0-9]+
real {enter}\.{enter}
string (?:[^\"\\\n]|\\.)*
COMILLAS["]
CADENA{COMILLAS}{variable}{COMILLAS}
 
%%

^{espai}\n
{espai}

"calc"                              if(nlines == 1) BEGIN(CALCMODE); 
<CALCMODE>"on"                      RETURN_MODE(CALC);
<CALCMODE>"off"                     RETURN_MODE(PRGM);
<CALCMODE>"\n"                      BEGIN(INITIAL); RETURN(TKN_NEWLINE);

"/*"[^"*/"]*"*/"                    {printf("Comentari Multilinea->  %s \n\n", yylval.caracter = strdup(yytext)); return TKN_MULTILINEA; }
"//"[^\n]*                          {printf("Comentari->  %s \n\n", yylval.caracter = strdup(yytext)); return TKN_COMENTARI; } 

"+"                                 {return TKN_SUMA; }
"-"                                 {return TKN_RESTA; }
"**"                                {return TKN_POTENCIA; }
"mod"                               {return TKN_MODUL; }
"*"                                 {return TKN_MULTIPLICACIO; }
"/"                                 {return TKN_DIVISIO; }
"log"                               {return TKN_LOG; }
"("                                 {return TKN_PARENTESISEQUERRA; }
")"                                 {return TKN_PARENTESISDRET; }
":="                                {return TKN_ASSIGNACIO; } 

"not"                               {return TKN_NOT; }
"and"                               {return TKN_AND; }
"or"                                {return TKN_OR; }
"true"                              RETURN(TRUE);
"false"                             RETURN(FALSE);

"while"                             {printf("WHILE\n"); return TKN_WHILE; }
"do"                                {printf("DO\n"); return TKN_DO; }
"done"                              {printf("DONE\n"); return TKN_DONE; }

"repeat"                            {printf("REPEAT\n"); return TKN_REPEAT; }
"until"                             {printf("UNTIL\n"); return TKN_UNTIL; }

"for"                               {printf("FOR\n"); return TKN_FOR; }
"in"                                {printf("IN\n"); return TKN_IN; }
".."                                {return TKN_RANGE; }

"if"                                {printf("IF\n"); return TKN_IF; }
"then"                              {printf("THEN\n"); return TKN_THEN; }
"else"                              {printf("ELSE\n"); return TKN_ELSE; }
"elsif"                             {printf("ELSIF\n"); return TKN_ELSEIF; }
"fi"                                {printf("FI\n"); return TKN_FI; }

"="                                 RETURN(COMP);
"<>"                                RETURN(COMP);
">"                                 RETURN(COMP);
"<"                                 RETURN(COMP);
">="                                RETURN(COMP);
"<="                                RETURN(COMP);

{variable}                          RETURN(VARIABLE);
{enter}                             RETURN_UTYPE(INT);
{real}                              RETURN_UTYPE(FLOAT);
{CADENA}                            RETURN_UTYPE(STRING);

"\n"                                { return TKN_NEWLINE; nlines=nlines+1;}  

.                                   { printf("Error sintactic linea %d\n", nlines); }

%%


int return_token(int token, char *s) {
  if (token == VARIABLE) {
    uniontype aux;
    yylval.utype.stringV = strdup(yytext); 

    if (sym_lookup(yylval.utype.stringV, &aux) != SYMTAB_NOT_FOUND){
      yylval.utype.type = aux.type;

      if(aux.type == BOOLEAN){
        token = VARIABLE_BOOLEANA;
        printf("Variable booleana: %s\n",  yylval.utype.stringV);
      } else {
        token = VARIABLE;
        printf("Variable: %s \n",  yylval.utype.stringV);
      }
    }
  } else if (token == COMP) {
    yylval.utype.stringV = strdup(yytext); 
    yylval.utype.type = STRING; 

    printf("Comparacio: %s\n", yylval.utype.stringV);
  } else if (token == TRUE || token == FALSE) {
    yylval.utype.type = BOOLEAN; 
    if (token == TRUE){
      yylval.utype.boolV = true;
      printf("%s: true\n", s);
    } else {
      yylval.utype.boolV = false;
      printf("%s: false\n", s);
    }
  } else if (token != TKN_NEWLINE) {
    printf("%s: %s\n", s, yytext);
  }
  return token;
}

int return_utype(type t) {
  yylval.utype.type = t; 
                                       
  switch(t){
    case INT:
      yylval.utype.intV = atoi(yytext);  
      printf("INT: %i\n", yylval.utype.intV);
      break;
    case FLOAT:
      yylval.utype.floatV = atof(yytext); 
      printf("FLOAT: %0.2f\n", yylval.utype.floatV);                                 
      break;
    case STRING:
      yylval.utype.stringV = strdup(yytext); 
      printf("STRING: %s\n", yylval.utype.stringV); 
      break;
    case BOOLEAN:
      yylval.utype.boolV = strcmp(yytext, "true") == 0; 
      printf("BOOL:  %s\n", yytext, yylval.utype.boolV); 
      break;
  }
  return UTYPE;
}


int return_mode(mode m){
  yylval.utype.intV = m;
  return MODE;
}
