%{
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "bison.tab.h"
#include "tipos.h"
#include "funcionsAuxiliars.h"

#include "./symtab/symtab.h"

int nlines=1;
int modeFlex=0;
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
<CALCMODE>"on"                      {modeFlex=1; RETURN_MODE(CALC);}
<CALCMODE>"off"                     {modeFlex=2; RETURN_MODE(PRGM);}
<CALCMODE>"\n"                      BEGIN(INITIAL); RETURN(TKN_NEWLINE);

"/*"[^"*/"]*"*/"                    {if(modeFlex==1){printf("Comentari Multilinea->  %s \n\n", yylval.caracter = strdup(yytext));}; return TKN_MULTILINEA; }
"//"[^\n]*                          {if(modeFlex==1){printf("Comentari->  %s \n\n", yylval.caracter = strdup(yytext));};  return TKN_COMENTARI; } 

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

"while"                             {return TKN_WHILE; }
"do"                                { return TKN_DO; }
"done"                              { return TKN_DONE; }

"repeat"                            { return TKN_REPEAT; }
"until"                             { return TKN_UNTIL; }

"for"                               { return TKN_FOR; }
"in"                                { return TKN_IN; }
".."                                {return TKN_RANGE; }

"if"                                {return TKN_IF; }
"then"                              { return TKN_THEN; }
"else"                              { return TKN_ELSE; }
"elsif"                             { return TKN_ELSEIF; }
"fi"                                { return TKN_FI; }

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
        
        if(modeFlex==1){
            printf("Variable booleana: %s\n",  yylval.utype.stringV);
        }

      } else {
        token = VARIABLE;

        if(modeFlex==1){
            printf("Variable: %s \n",  yylval.utype.stringV);
        }

      }
    }
  } else if (token == COMP) {
    yylval.utype.stringV = strdup(yytext); 
    yylval.utype.type = STRING; 
    if(modeFlex==1){
       printf("Comparacio: %s\n", yylval.utype.stringV);
    }
  } else if (token == TRUE || token == FALSE) {
    yylval.utype.type = BOOLEAN; 
    if (token == TRUE){
      yylval.utype.boolV = true;
      if(modeFlex==1){
       printf("%s: true\n", s);

      }
    } else {
      yylval.utype.boolV = false;
      if(modeFlex==1){
        printf("%s: false\n", s);
      }

    }
  } else if (token != TKN_NEWLINE) {
    if(modeFlex==1){
        printf("%s: %s\n", s, yytext);
    }
  }
  return token;
}

int return_utype(type t) {
  yylval.utype.type = t; 
                                       
  switch(t){
    case INT:
      yylval.utype.intV = atoi(yytext);  
      if(modeFlex==1){
        printf("INT: %i\n", yylval.utype.intV);
      }
      break;
    case FLOAT:
      yylval.utype.floatV = atof(yytext); 
      if(modeFlex==1){
          printf("FLOAT: %0.2f\n", yylval.utype.floatV);                                 
      }

      break;
    case STRING:
      yylval.utype.stringV = strdup(yytext); 
      if(modeFlex==1){
        printf("STRING: %s\n", yylval.utype.stringV); 
      }

      break;
    case BOOLEAN:
      yylval.utype.boolV = strcmp(yytext, "true") == 0; 
      if(modeFlex==1){
        printf("BOOL:  %s\n", yytext, yylval.utype.boolV); 
      }
      break;
  }
  return UTYPE;
}


int return_mode(mode m){
  yylval.utype.intV = m;
  return MODE;
}
