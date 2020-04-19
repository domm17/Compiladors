%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "bison.tab.h"
#include "tipos.h"
#include "./symtab/symtab.h"
extern FILE *yyin;

int return_token(int token, char *s) {
  if (token == VARIABLE) {
    uniontype aux;
    yylval.utype.stringV = strdup(yytext); 

    if (sym_lookup(yylval.utype.stringV, &aux) != SYMTAB_NOT_FOUND){
        yylval.utype.type = aux.type;
        token = VARIABLE;
    }
  } 
  return token;
}

int return_utype(type t) {
  yylval.utype.type = t; 
                                       
  switch(t){
    case INT:
      yylval.utype.intV = atoi(yytext);  
      break;
    case FLOAT:
      yylval.utype.floatV = atof(yytext); 
      break;
    case STRING:
      yylval.utype.stringV = strdup(yytext); 
      break;
  }
  return UTYPE;
}


int nlines=0;
#define RETURN(t) return return_token(t, #t)
#define RETURN_UTYPE(u) return return_utype(u)
%}

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

"/*"[^"*/"]*"*/"         { printf("Comentari Multilinea->  %s \n\n", yylval.caracter = strdup(yytext)); return TKN_MULTILINEA; }
"//"[^\n]*               { printf("Comentari->  %s \n\n", yylval.caracter = strdup(yytext)); return TKN_COMENTARI; } 
"+"                      { return TKN_SUMA; }
"-"                      { return TKN_RESTA; }
"**"                     { return TKN_POTENCIA; }
"mod"                    { return TKN_MODUL; }
"*"                      { return TKN_MULTIPLICACIO; }
"/"                      { return TKN_DIVISIO; }
"log"                    { return TKN_LOG; }
"("                      { return TKN_PARENTESISEQUERRA; }
")"                      { return TKN_PARENTESISDRET; }
":="                     { return TKN_ASSIGNACIO; } 
{variable}               RETURN(VARIABLE);
{enter}                  RETURN_UTYPE(INT);
{real}                   RETURN_UTYPE(FLOAT);
{CADENA}                 RETURN_UTYPE(STRING);
"\n"                     { return TKN_NEWLINE; nlines=nlines+1;}

.                        { printf("Error sintactic linea %d\n", nlines); }

%%
